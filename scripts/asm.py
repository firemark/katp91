#!/bin/env python3
import re
import sys
from itertools import chain
from functools import wraps

math_opcodes = {
    'ADD': 0b0000,
    'ADC': 0b0001,
    'SUB': 0b0010,
    'SBC': 0b0011,
    'AND': 0b0100,
    'OR': 0b0110,
    'XOR': 0b0111,
    'MOV': 0b1011,
    'CMP': 0b1111,
}

other_opcodes = {
    'NOP': 0b0000,
    'RET': 0b0001,
    'RETI': 0b0010,
    'HLT': 0b0111,
}

branch_opcodes = {
    'BREQ': 0b0000,
    'BRNE': 0b0001,
    'BRLT': 0b0010,
    'BRGE': 0b0011,
    'BRC': 0b0100,
    'BRO': 0b0101,
    'BRN': 0b0110,
    'BRNC': 0b0111,
    'BRNO': 0b1000,
    'BRNN': 0b1001,
    'BRLO': 0b0100,
    'BRSH': 0b0111,
    'RJMP': 0b1100,
    'RCALL': 0b1101,
}

long_opcodes = {
    'JMP': 0b1110,
    'CALL': 0b1111,
}

branch_opcodes.update(long_opcodes)

math_opcodes16 = math_opcodes.copy()
math_opcodes16.update({
    'LD': 0b1000,
    'LDI': 0b1001,
    'LDD': 0b1010,
    'ST': 0b1100,
    'STI': 0b1101,
    'STD': 0b1110,
})

single_reg_opcodes = {
    'NEG': 0b0000,
    'COM': 0b0001,
    'LSL': 0b0010,
    'LSR': 0b0011,
    'ROL': 0b0100,
    'ROR': 0b0101,
    'RLC': 0b0110,
    'RRC': 0b0111,
    'INC': 0b1000,
    'DEC': 0b1001,
}

single_reg_opcodes16 = single_reg_opcodes.copy()
single_reg_opcodes16.update({
    'PUSH': 0b1110,
    'POP': 0b1111,
})


def f_join(*args):
    return '^%s$' % r'\s+'.join(args)


FOP = r'(?P<op>\w+)'
FVAL = r'(?P<val>0x[0-9A-F]+|[0-9]+|@[A-Z][\w@]+)'
FRX_16 = r'(?P<x>[A-D]X)'
FRY_16 = r'(?P<y>[A-D]X)'
FRX_8 = r'(?P<x>[A-D][HL])'
FRY_8 = r'(?P<y>[A-D][HL])'
FLABEL = r'(?P<label>[.A-Z_][A-Z0-9_]+)'
FFLAGS = r'(?P<flags>[A-Z]+)'
raw_asm_formats = [
    ('DB', f_join('DB', FVAL)),
    ('CRVMATH', f_join(FOP, FRX_8, FVAL)),
    ('CRRMATH', f_join(FOP, FRX_8, FRY_8)),
    ('CRSMATH', f_join(FOP, FRX_8)),
    ('WRRMATH', f_join(FOP, FRX_16, FRY_16)),
    ('WRSMATH', f_join(FOP, FRX_16)),
    ('SFLAG', f_join('SFLAG', FFLAGS)),
    ('UFLAG', f_join('UFLAG', FFLAGS)),
    ('BRANCH', f_join(FOP, FLABEL)),  # OR LONG - determited by opcodes
    ('OTHER', f_join(FOP)),
    ('NOTHING', r'^$'),
]

asm_formats = [
    (group_name, re.compile(reg, re.I))
    for (group_name, reg) in raw_asm_formats
]

asm_format_lengths = {
    'CRVMATH': 1,
    'CRRMATH': 1,
    'CRSMATH': 1,
    'WRRMATH': 1,
    'WRSMATH': 1,
    'SFLAG': 1,
    'UFLAG': 1,
    'BRANCH': 1,
    'LONG': 2,
    'OTHER': 1,
    'NOTHING': 0,
}


class LineParserError(Exception):
    
    def __init__(self, num, msg):
        full_msg = 'Error in line {}: {}'.format(num, msg)
        return super().__init__(full_msg)


def line_parse_safe(func, default=None):
    @wraps(func)
    def inner(self, errs, *args, **kwargs):
        try:
            return func(self, *args, **kwargs)
        except LineParserError as e:
            errs.append(str(e))
            return default() if default else []
    inner.__name__ = 'safe_%s' % inner.__name__
    return inner



def reg16_to_int(val):
    return ord(val.upper()) - ord('A')


def reg8_to_int(val):
    reg16 = reg16_to_int(val[0])
    high_or_low = int(val[1].upper() == 'H')
    return (reg16 << 1) | high_or_low


def conv_to_word(*items):
    word = 0
    i = 0
    for size, value in items:
        word |= value << i
        i += size
    assert i == 16
    return word


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
            if self.label is not None and self.label.startswith('.'):
                new_addr = self.SPECIAL_LABELS.get(self.label)
                if new_addr is None:
                    self.raise_error('unknown special label: %s' % self.label)

        self.group = group_name
        self.data = match.groupdict()

    SPECIAL_LABELS = {
        '.MAIN': 0x2000,
        '.BOOT': 0x0000,
        '.MEM': 0x0400,
        '.INT_BUTTONS': 0x0040,
    }
    def get_new_addr_from_group(self, old_addr):
        if self.label is not None and self.label.startswith('.'):
            new_addr = self.SPECIAL_LABELS[self.label]
            return new_addr
        if self.data is None:
            return old_addr
        group = self.group
        op = self.data.get('op')
        if op is not None and group == 'BRANCH':
            opcode = self.get_opcode(op, long_opcodes, raise_error=False)
            if opcode is not None:
                group = 'LONG'
        return asm_format_lengths.get(group, 0) + old_addr

    def to_bytecode(self):
        method = getattr(self, 'group_%s' % self.group.lower(), None)
        if method is None:
            self.raise_error('syntax is not implemented yet')

        return method(**self.data)

    def raise_error(self, msg):
        raise LineParserError(self.num, msg)

    safe_set_group_and_label = line_parse_safe(set_group_and_label)
    safe_to_bytecode = line_parse_safe(to_bytecode)

    def group_crvmath(self, op, x, val):
        opcode = self.get_opcode(op, math_opcodes)
        rx = reg8_to_int(x)
        if val.startswith('@'):
            if val.startswith('@low@'):
                label = val[5:]
                val = self.labels.get(label.upper())
                if val is None:
                    self.raise_error('Label %s is unknown' % label)
            elif val.startswith('@high@'):
                label = val[6:]
                val = self.labels.get(label.upper())
                if val is None:
                    self.raise_error('Label %s is unknown' % label)
                val = val >> 8
            else:
                self.raise_error('unknown macro: %s' % val)
        u2 = self.val_to_u2(val, 8)
        return [
            conv_to_word([1, 0b0], [3, rx], [8, u2], [4, opcode])
        ]

    def group_db(self, val):
        u2 = self.val_to_u2(val, 16)
        return [u2]

    def group_crrmath(self, op, x, y):
        opcode = self.get_opcode(op, math_opcodes)
        rx = reg8_to_int(x)
        ry = reg8_to_int(y)
        return [
            conv_to_word([5, 0b00111], [3, rx], [3, ry], [1, 0], [4, opcode])
        ]

    def group_crsmath(self, op, x):
        opcode = self.get_opcode(op, single_reg_opcodes)
        rx = reg8_to_int(x)
        return [
            conv_to_word([5, 0b01111], [3, rx], [4, 0], [4, opcode])
        ]

    def group_wrrmath(self, op, x, y):
        opcode = self.get_opcode(op, math_opcodes16)
        rx = reg16_to_int(x[0])
        ry = reg16_to_int(y[0])
        return [
            conv_to_word([5, 0b10111], [1, 0], [2, rx], [1, 0], [2, ry], [1, 0], [4, opcode])
        ]

    def group_wrsmath(self, op, x):
        opcode = self.get_opcode(op, single_reg_opcodes16)
        rx = reg16_to_int(x[0])
        return [
            conv_to_word([5, 0b11111], [1, 0], [2, rx], [4, 0], [4, opcode])
        ]

    def group_sflag(self, flags):
        bitmask = self.get_flags(flags)
        return [
            conv_to_word([5, 0b00011], [3, 0], [8, bitmask]),
        ]

    def group_uflag(self, flags):
        bitmask = self.get_flags(flags)
        return [
            conv_to_word([5, 0b10011], [3, 0], [8, bitmask]),
        ]

    def group_branch(self, op, label):
        byte_list = self.group_long(op, label)
        if byte_list is not None:
            return byte_list
        opcode = self.get_opcode(op, branch_opcodes)
        address = self.labels.get(label.upper())
        if address is None:
            self.raise_error('Label %s is unknown' % label)
        distance = address - self.addr
        u2 = self.val_to_u2(distance, 10)
        return [
            conv_to_word([2, 0b01], [10, u2], [4, opcode])
        ]

    def group_long(self, op, label):
        opcode = self.get_opcode(op, long_opcodes, raise_error=False)
        if opcode is None:
            return None
        address = self.labels.get(label.upper())
        if address is None:
            self.raise_error('Label %s is unknown' % label)
        return [
            conv_to_word([5, 0b11011], [7, 0], [4, opcode]),
            address,
        ]

    def group_other(self, op):
        opcode = self.get_opcode(op, other_opcodes)
        return [
            conv_to_word([5, 0b11011], [7, 0], [4, opcode]),
        ]

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
            bval = -bval
            return ((bval & mask) ^ mask) + 1
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

    FLAG_TO_BITMASK = {
        'H': 1 << 7,  # halt
        'I': 1 << 4,  # interrupt
        'C': 1 << 3,  # carry
        'O': 1 << 2,  # overflow
        'Z': 1 << 1,  # zero
        'N': 1 << 0,  # negative
    }
    def get_flags(self, flags):
        flags = flags.upper()
        bitmask = 0
        for flag in flags:
            flag_bitmask = self.FLAG_TO_BITMASK.get(flag)
            if not flag_bitmask:
                self.raise_error('%r flag is unknown' % flag)
            bitmask |= flag_bitmask
        return bitmask

def parse_to_bytecode(data):
    errs = []
    striped_lines = (
        line.partition(';')[0].strip() for line in data.split('\n')
    )
    lines = [
        LineParser(line, num)
        for num, line in enumerate(striped_lines, start=1)
    ]
    for line_parser in lines:
        line_parser.safe_set_group_and_label(errs)
    shout_errors(errs)

    addr = 0x0000
    for line_parser in lines:
        line_parser.addr = addr
        addr = line_parser.get_new_addr_from_group(addr)
        
    labels = {
        line_parser.label: line_parser.addr 
        for line_parser in lines
        if line_parser.label is not None
    }
    for line_parser in lines:
        line_parser.labels = labels
    shout_errors(errs)

    last_addr = max(line.addr for line in lines)
    bytecode = [0] * (last_addr + 1)
    for line_parser in lines:
        bytecode_list = line_parser.safe_to_bytecode(errs)
        size = len(bytecode_list)
        addr = line_parser.addr
        bytecode[addr:addr + size] = bytecode_list
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
    write = sys.stdout.buffer.write
    for word in bytecode: # ironic :/
        lbyte = word & 0xFF
        hbyte = (word >> 8) & 0xFF
        write(bytes([lbyte, hbyte]))
    #sys.stdout.write(',\n'.join( hex(b) for b in bytecode ))

