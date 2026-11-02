#!/usr/bin/env python3
"""Generates the launcher and stat icons. Drawn at 8x and downsampled so edges stay smooth."""
import math
import os

from PIL import Image, ImageDraw

SCALE = 8
OUT = os.path.join(os.path.dirname(__file__), "..", "resources", "drawables")

AMBER = (242, 167, 27, 255)
FOAM = (255, 246, 221, 255)
WHITE = (255, 255, 255, 255)
HEART = (255, 77, 94, 255)
BOLT = (255, 197, 61, 255)
BADGE = (43, 26, 6, 255)


def canvas(size):
    img = Image.new("RGBA", (size * SCALE, size * SCALE), (0, 0, 0, 0))
    return img, ImageDraw.Draw(img), size * SCALE


def save(img, size, name):
    img.resize((size, size), Image.LANCZOS).save(os.path.join(OUT, name))


def mug(d, s, x, y, w, h, stroke):
    """Rounded mug with a curved handle and a foam head; (x, y, w, h) are fractions of s."""
    left, top, right, bottom = x * s, y * s, (x + w) * s, (y + h) * s
    r = h * 0.42 * s / 2
    pen = max(1, int(stroke * s))
    d.arc([right - r, top + h * s * 0.22, right + r * 1.1, bottom - h * s * 0.2], -90, 90, fill=WHITE, width=pen)
    d.rounded_rectangle([left, top, right, bottom], radius=h * 0.2 * s, fill=AMBER)
    bump = w * s / 4.6
    for i in range(4):
        cx = left + (i + 0.5) * (right - left) / 4
        d.ellipse([cx - bump, top - bump * 0.9, cx + bump, top + bump * 1.1], fill=FOAM)


def launcher():
    img, d, s = canvas(54)
    d.ellipse([0, 0, s - 1, s - 1], fill=BADGE, outline=AMBER, width=2 * SCALE)
    mug(d, s, 0.27, 0.36, 0.38, 0.40, 0.05)
    save(img, 54, "launcher_icon.png")


def clock():
    img, d, s = canvas(24)
    pen = int(0.11 * s)
    d.ellipse([pen / 2, pen / 2, s - pen / 2, s - pen / 2], outline=WHITE, width=pen)
    c = s / 2
    d.line([(c, c), (c, s * 0.24)], fill=WHITE, width=pen)
    d.line([(c, c), (s * 0.70, s * 0.60)], fill=WHITE, width=pen)
    save(img, 24, "icon_clock.png")


def rate():
    img, d, s = canvas(24)
    mug(d, s, 0.12, 0.30, 0.56, 0.60, 0.09)
    save(img, 24, "icon_rate.png")


def heart():
    img, d, s = canvas(24)
    points = []
    for i in range(240):
        t = 2 * math.pi * i / 240
        px = 16 * math.sin(t) ** 3
        py = 13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t)
        points.append((s / 2 + px * s / 35, s * 0.46 - py * s / 35))
    d.polygon(points, fill=HEART)
    save(img, 24, "icon_heart.png")


def stress():
    img, d, s = canvas(24)
    points = [(0.60, 0.04), (0.20, 0.56), (0.47, 0.56), (0.38, 0.96), (0.80, 0.40), (0.52, 0.40)]
    d.polygon([(x * s, y * s) for x, y in points], fill=BOLT)
    save(img, 24, "icon_stress.png")


if __name__ == "__main__":
    launcher()
    clock()
    rate()
    heart()
    stress()
