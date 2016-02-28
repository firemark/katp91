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
    'CLC': 0b0000,
    'CLZ': 0b0001,
    'CLO': 0b0010,
    'CLN': 0b0011,
    'STC': 0b1000,
    'STZ': 0b1001,
    'STO': 0b1010,
    'STN': 0b1011,
    'NOP': 0b1100,
    'RET': 0b1110,
    'HLT': 0b1111,
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

extended_opcodes = {
    'JMP': 0b0000,
    'CALL': 0b0001,
}

branch_opcodes.update(extended_opcodes)

reg_memory_opcodes = {
    'LD': 0b000,
    'LDI': 0b001,
    'LDD': 0b010,
    'ST': 0b100,
    'STI': 0b101,
    'STD': 0b110,
}

simple_reg_opcodes = {
    'NEG': 0b0000,
    'COM': 0b0001,
    'LSL': 0b0010,
    'LSR': 0b0011,
    'ROL': 0b0100,
    'ROR': 0b0101,
    'RLC': 0b0110,
    'RRC': 0b0111,
    'PUSH': 0b1000,
    'POP': 0b1001,
}

raw_asm_formats = [
    ('MATH_CONST', r'^(?P<op>\w+)\s+R(?P<x>[0-9A-F])\s+(?P<val>0x[0-9A-F]+|[0-9]+)$'),
    ('MATH_REG', r'^(?P<op>\w+)\s+R(?P<x>[0-9A-F])\s+R(?P<y>[0-9A-F]+)$'),
    ('MATH_EREG', r'^(?P<op>\w+)\s+ER(?P<x>\d)\s+ER(?P<y>\d+)$'),
    ('REG_MEMORY', r'^(?P<op>\w+)\s+R(?P<x>[0-9A-F])\s+ER(?P<y>\d+)$'),
    ('SIMPLE_REG', r'^(?P<op>\w+)\s+R(?P<x>[0-9A-F])$'),
    ('BRANCH', r'^(?P<op>\w+)\s+(?P<label>\w+)$'),
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
    'SIMPLE_REG': 2,
    'REG_MEMORY': 2,
    'BRANCH': 2,
    'EXTENDED': 4,
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

    def get_bytes_from_group(self):
        group = self.group
        op = self.data.get('op')
        if op is not None and group == 'BRANCH':
            opcode = self.get_opcode(op, extended_opcodes, raise_error=False)
            if opcode is not None:
                group = 'EXTENDED'
        return asm_format_lengths.get(group, 0)

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
        byte_list = self.group_extended(op, label)
        if byte_list is not None:
            return byte_list
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
        return [
            ((opcode & 0b111) << 5) + 0b1111,
            ((opcode & 0b1000) >> 3) + (ix << 1) + (iy << 3)
        ]

    def group_reg_memory(self, op, x, y):
        ix = int(x, 16)
        iy = int(y)
        if iy > 3:
            self.raise_error('register ER%s is unknown' % y)
        opcode = self.get_opcode(op, reg_memory_opcodes)
        return [
            ((opcode & 0b1) << 7) + 0b111111,
            (opcode >> 1) + (ix << 2) + (iy << 6)
        ]
    
    def group_simple_reg(self, op, x):
        opcode = self.get_opcode(op, simple_reg_opcodes)
        ix = int(x, 16)
        return [
            ((opcode & 0b11) << 6) + 0b11111,
            (opcode >> 2) + (ix << 2),
        ]

    def group_extended(self, op, label):
        opcode = self.get_opcode(op, extended_opcodes, raise_error=False)
        if opcode is None:
            return None
        val = self.labels.get(label.upper())
        if val is None:
            self.raise_error('Label %s is unknown' % label)
        return [
            0b1111111,
            opcode,
            val & 0xFF,
            (val >> 8) & 0xFF,
        ]

    def group_other(self, op):
        opcode = self.get_opcode(op, other_opcodes)
        return [0b11111111, opcode]

    def group_nothing(self):
        return []

    @staticmethod
    def val_to_u2(val, bit_size=8):
        mask = 2 ** bit_size - 1

        if isinstance(val, int):
            bval = val
        elif val.startswith('0x'):
            bval = int(val[2:], 16)
        else:
            bval = int(val)

        if bval < 0:
            return (((bval * -1) & mask) ^ mask) + 1
        else:
            return bval & mask  

    def get_opcode(self, op, opcodes, raise_error=True):
        op = op.upper()
        opcode = opcodes.get(op)
        if opcode is None and raise_error:
            self.raise_error(
                'operator {} is unknown - available operators are {}'.format(
                    op, ', '.join(opcodes)
                )
            )
        return opcode
        

def parse_to_bytecode(data):
    errs = []
    striped_lines = (
        line.partition(';')[0].strip() for line in data.split('\n')
    )
    lines = [
        LineParser(line, num)
        for num, line in 
        enumerate(striped_lines)
    ]
    addr = 0x2000
    for line_parser in lines:
        line_parser.safe_set_group_and_label(errs)
        line_parser.addr = addr
        addr += line_parser.get_bytes_from_group()
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
    return [0x00] * 0x2000 + bytecode


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

