#!/usr/bin/python3
from sys import stdin

data = stdin.buffer.read()

for char in data:
    print('%02x' % char)
