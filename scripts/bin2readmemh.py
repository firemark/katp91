#!/usr/bin/python3
from sys import stdin

data = stdin.buffer.read()

chars = []
for char in data:
    chars.append(char)
    if len(chars) == 2:
        value = '%02x%02x' % (chars[1], chars[0])
        chars = []
        print(value)
