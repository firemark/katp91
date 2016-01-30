#!/bin/env python3
import re
import sys
from itertools import chain

math_constant_opcodes = {
    'ADD': 0b0000,
    'SUB': 0b0010,
    'AND': 0b0100,
    'OR': 0b0110,
    'XOR': 0b1000,
    'MOV': 0b1010,
    'CMP': 0b1100,
}

math_reg_opcodes = {
    'SWP': 0b0011,
}
math_reg_opcodes.update(math_constant_opcodes)

other_opcodes = {
    'HLT': 0b111,
    'NOP': 0b110,
}

raw_asm_formats = {
    'MATH_CONST': r'^(?P<op>\w+)\s*R(?P<x>[0-9A-F])\s*(?P<val>0x[0-9A-F]+|[0-9]+)$',
    'MATH_REG': r'^(?P<op>\w+)\s*R(?P<x>[0-9A-F])\s*R(?P<y>[0-9A-F]+)$',
    'OTHER': r'^(?P<op>\w+)$',
}

asm_formats = {
    group_name: re.compile(reg, re.I)
    for (group_name, reg) in raw_asm_formats.items()
}


class LineParserError(Exception):
    
    def __init__(self, num, msg):
        full_msg = 'Error in line {}: {}'.format(num, msg)
        return super().__init__(full_msg)


class LineParser(object):
    line = ''
    num = 0

    def __init__(self, line, num):
        self.line = line
        self.num = num

    def safe_parse(self, errs):
        try:
            return self.parse()
        except LineParserError as e:
            errs.append(str(e))

    def parse(self):
        group_name, match = next(filter(
            lambda o: o[1] is not None,
            (
                (name, reg.match(self.line)) 
                for name, reg in asm_formats.items()
            ) 
        ), (None, None))
        if group_name is None:
            raise LineParserError(self.num, 'syntax error')

        method = getattr(self, 'group_%s' % group_name.lower(), None)
        if method is None:
            raise LineParserError(self.num, 'syntax is not implemented yet')

        return method(**match.groupdict())

    def group_math_const(self, op, x, val):
        opcode = self.get_opcode(op, math_constant_opcodes)
        return [
            (int(x, 16) << 4) + opcode,
            self.val_to_int(val),
        ]  

    def group_math_reg(self, op, x, y):
        opcode = self.get_opcode(op, math_reg_opcodes)
        return [
            (opcode << 4) + 0b111,
            (int(y, 16) << 4) + int(x, 16),
        ]

    def group_other(self, op):
        opcode = self.get_opcode(op, other_opcodes)
        return [(opcode << 5) +  0b11111, 0x00]

    @staticmethod
    def val_to_int(val):
        if val.startswith('0x'):
            return int(val[2:4], 16)
        return int(val) & 255

    def get_opcode(self, op, opcodes):
        op = op.upper()
        opcode = opcodes.get(op)
        if opcode is None:
            raise LineParserError(
                self.num, 
                'operator {} is unknown - available operators are {}'.format(
                    op, ', '.join(math_opcodes)
                )
            )
        return opcode
        

def parse_to_bytecode(data):
    errs = []
    bytecode = list(chain.from_iterable(
        LineParser(line, num).safe_parse(errs)
        for num, line in 
        enumerate(line.partition(';')[0].strip() for line in data.split('\n'))
        if line
    ))
    if not errs:
        return bytecode

    sys.stderr.write('\n'.join(errs))
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

