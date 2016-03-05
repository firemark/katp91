#!/bin/env python3
from colorsys import hsv_to_rgb

line_format = "8'b{:08b}: {{r, g, b}} = 9'b{};"


def rgb_to_bits(rgb):
    bits = (int(round(v * 7.0)) for v in rgb)
    return "{:03b}{:03b}{:03b}".format(*bits)


def bits_to_hsv(bits):
    conv = lambda i: int(i, 2) / 7.0
    r = conv(bits[0:3])
    g = conv(bits[3:6])
    b = conv(bits[6:9])
    return hsv_to_rgb(r, g, b)
   
if __name__ == "__main__":
    tuples = set(
        rgb_to_bits(
            hsv_to_rgb(h / 14.0, s / 4.0, v / 6.0)
        )
        for v in range(1, 7)
        for s in range(1, 5)
        for h in range(1, 15)
    )

    ordered_tuples = sorted(tuples, key=bits_to_hsv)
    len_tuples = len(ordered_tuples)
    len_empty_tuples = 256 - len_tuples - 8

    all_tuples = ordered_tuples + ['000000000'] * len_empty_tuples + [
        "{0:03b}{0:03b}{0:03b}".format(v) for v in range(8)
    ]

    for i, rgb in enumerate(all_tuples):
        print(line_format.format(i, rgb))
