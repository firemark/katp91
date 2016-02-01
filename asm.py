#!/bin/env python3
import re
import sys
from itertools import chain
from functools import wraps, reduce

math_opcodes = {
    'ADD': 0b0000,
    'ADC': 0b0001,
    'SUB': 0b0010,
    'SBC': 0b0011,
    'AND': 0b0100,
    'OR': 0b0110,
    'XOR': 0b1000,
    'MOV': 0b1010,
    'CMP': 0b1100,
}

other_opcodes = {
    'HLT': 0b111,
    'NOP': 0b110,
}

branch_opcodes = {
    'BREQ': 0b0000,
    'BRNE': 0b0001,
    'BRLT': 0b0010,
    'BRGE': 0b0011,
    'BRC': 0b00100,
    'BRO': 0b0101,
    'BRN': 0b0110,
    'BRNC': 0b0111,
    'BRNO': 0b1000,
    'BRNN': 0b1001,
    'BRLO': 0b1010,
    'BRSH': 0b1011,
    'RJMP': 0b1100,
}

raw_asm_formats = [
    ('MATH_CONST', r'^(?P<op>\w+)\s+R(?P<x>[0-9A-F])\s+(?P<val>0x[0-9A-F]+|[0-9]+)$'),
    ('MATH_REG', r'^(?P<op>\w+)\s+R(?P<x>[0-9A-F])\s+R(?P<y>[0-9A-F]+)$'),
    ('MATH_EREG', r'^(?P<op>\w+)\s+ER(?P<x>\d)\s+ER(?P<y>\d+)$'),
    ('BRANCH', r'^(?P<op>\w+)\s+(?P<label>\w+)'),
    ('OTHER', r'^(?P<op>\w+)$'),
    ('NOTHING', r'^$'),
]

asm_formats = [
    (group_name, re.compile(reg, re.I))
    for (group_name, reg) in raw_asm_formats
]

asm_format_lengths = {
    'MATH_CONST': 2,
    'MATH_REG': 2,
    'MATH_EREG': 2,
    'BRANCH': 2,
    'SPECIAL': 4,
    'OTHER': 2,
    'NOTHING': 0,
}


class LineParserError(Exception):
    
    def __init__(self, num, msg):
        full_msg = 'Error in line {}: {}'.format(num, msg)
        return super().__init__(full_msg)


def line_parse_safe(func):
    @wraps(func)
    def inner(self, errs, *args, **kwargs):
        try:
            return func(self, *args, **kwargs)
        except LineParserError as e:
            errs.append(str(e))
            return []
    inner.__name__ = 'safe_%s' % inner.__name__
    return inner

class LineParser(object):
    line = ''
    group = ''
    label = None
    labels = None
    data = None
    num = 0
    addr = 0

    def __init__(self, line, num):
        self.line = line
        self.num = num

    def set_group_and_label(self):
        label, part, line = self.line.rpartition(':')
        line = line.strip()
        group_name, match = next(filter(
            lambda o: o[1] is not None,
            (
                (name, reg.match(line)) 
                for name, reg in asm_formats
            ) 
        ), (None, None))

        if group_name is None:
            self.raise_error('syntax error')
        if part == ':':
            self.label = label.strip().upper()

        self.group = group_name
        self.data = match.groupdict()

    def to_bytecode(self):
        method = getattr(self, 'group_%s' % self.group.lower(), None)
        if method is None:
            self.raise_error('syntax is not implemented yet')

        return method(**self.data)

    def raise_error(self, msg):
        raise LineParserError(self.num, msg)

    safe_set_group_and_label = line_parse_safe(set_group_and_label)
    safe_to_bytecode = line_parse_safe(to_bytecode)

    def group_math_const(self, op, x, val):
        opcode = self.get_opcode(op, math_opcodes)
        return [
            (int(x, 16) << 4) + opcode,
            self.val_to_u2(val),
        ]  

    def group_branch(self, op, label):
        opcode = self.get_opcode(op, branch_opcodes)
        val = self.labels.get(label.upper())
        if val is None:
            self.raise_error('Label %s is unknown' % label)
        distance = val - self.addr
        u2 = self.val_to_u2(distance, 9)
        return [
            0b11 + (opcode << 3) + ((u2 >> 8) << 7),
            u2 & 0b11111111
        ]

    def group_math_reg(self, op, x, y):
        opcode = self.get_opcode(op, math_opcodes)
        return [
            (opcode << 4) + 0b111,
            (int(y, 16) << 4) + int(x, 16),
        ]

    def group_math_ereg(self, op, x, y):
        ix = int(x)
        if ix > 3:
            self.raise_error('register ER%s is unknown' % x)
        iy = int(y)
        if iy > 3:
            self.raise_error('register ER%s is unknown' % y)
        opcode = self.get_opcode(op, math_opcodes)
        return[
            ((opcode & 0b111) << 5) + 0b1111,
            ((opcode & 0b1000) >> 3) + (int(x) << 1) + (int(y) << 3)
        ]

    def group_other(self, op):
        opcode = self.get_opcode(op, other_opcodes)
        return [(opcode << 5) +  0b11111, 0x00]

    def group_nothing(self):
        return []

    @staticmethod
    def val_to_u2(val, bit_size=8):
        mask = 2**bit_size - 1

        if isinstance(val, int):
            bval = val
        elif val.startswith('0x'):
            bval = int(val[2:4], 16)
        else:
            bval = int(val)

        if bval < 0:
            return (((bval * -1) & mask) ^ mask) + 1
        else:
            return bval & mask  

    def get_opcode(self, op, opcodes):
        op = op.upper()
        opcode = opcodes.get(op)
        if opcode is None:
            self.raise_error(
                'operator {} is unknown - available operators are {}'.format(
                    op, ', '.join(opcodes)
                )
            )
        return opcode
        

def parse_to_bytecode(data):
    errs = []
    lines = [
        LineParser(line, num)
        for num, line in 
        enumerate(line.partition(';')[0].strip() for line in data.split('\n'))
    ]
    addr = 0x2000
    for line_parser in lines:
        line_parser.safe_set_group_and_label(errs)
        line_parser.addr = addr
        addr += asm_format_lengths.get(line_parser.group, 0)
    labels = {
        line_parser.label: line_parser.addr 
        for line_parser in lines
        if line_parser.label is not None
    }
    for line_parser in lines:
        line_parser.labels = labels
    shout_errors(errs)
    
    bytecode = list(chain.from_iterable(
        line_parser.safe_to_bytecode(errs)
        for line_parser in lines
    ))
    shout_errors(errs)
    return bytecode


def shout_errors(errs):
    if not errs:
        return
    sys.stderr.write('\n'.join(errs) + '\n')
    exit(-1)

if __name__ == '__main__':
    if len(sys.argv) > 0:
        with open(sys.argv[1]) as f:
            data = f.read()
    else:
        data = sys.stdin.read()
    bytecode = parse_to_bytecode(data)
    sys.stdout.buffer.write(bytes(bytecode))
    #sys.stdout.write(',\n'.join( hex(b) for b in bytecode ))

