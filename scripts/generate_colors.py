#!/bin/env python3
from colorsys import hsv_to_rgb

line_format = "8'b{:08b}: {{r, g, b}} = 9'b{:03b}{:03b}{:03b};"

tuples = [
    hsv_to_rgb(h / 14.0, s / 6.0, v / 3.0)
    for v in range(1, 4)
    for s in range(1, 7)
    for h in range(1, 15)
] + [
    (0.0, 0.0, 0.0),
    (0.33, 0.33, 0.33),
    (0.66, 0.66, 0.66),
    (1.0, 1.0, 1.0),
]

for i, rgb in enumerate(tuples):
    r, g, b = (int(v * 7.0) for v in rgb)
    print(line_format.format(i, r, g, b))
