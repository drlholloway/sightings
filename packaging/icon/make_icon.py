#!/usr/bin/env python3
"""Draw the Sightings icon (Nessie as a plotted curve) and write the platform masters.

Outputs (in apps/workbench/assets/icon/):
  icon_1024.png        full-bleed square, rounded corners baked in (Linux, Android legacy)
  icon_android_fg.png  transparent, artwork inside the adaptive-icon safe zone
  icon_macos.png       transparent canvas, Apple-style rounded square at 824/1024
  icon_256.png         window icon for Linux
Run with: python3 packaging/icon/make_icon.py
"""
import math
import os
import sys

from PIL import Image, ImageDraw

SS = 4  # supersampling factor
OUT = os.path.join(os.path.dirname(__file__), "..", "..", "apps", "workbench", "assets", "icon")

BG = (18, 60, 58, 255)        # deep teal
LOCH = (12, 46, 44, 255)      # darker band below the water line
AXIS = (86, 132, 128, 255)    # muted axis / grid
INK = (242, 232, 213, 255)    # cream trace
EYE = (201, 48, 48, 255)      # lead red


def draw_art(img, box, with_background):
    """Draw the artwork into `box` = (x, y, size) of `img` (already supersampled)."""
    x0, y0, size = box
    s = size / 1000.0
    d = ImageDraw.Draw(img)

    def P(x, y):
        return (x0 + x * s, y0 + y * s)

    water = 610
    if with_background:
        d.rectangle([P(0, water), P(1000, 1000)], fill=LOCH)
        # faint grid on the plot area
        for gx in range(120, 1000, 170):
            d.line([P(gx, 90), P(gx, water)], fill=(30, 76, 74, 255), width=int(4 * s))
        for gy in range(water - 170, 60, -170):
            d.line([P(120, gy), P(1000, gy)], fill=(30, 76, 74, 255), width=int(4 * s))
    # axes: y axis on the left, x axis is the water line
    aw = int(18 * s)
    d.line([P(120, 100), P(120, water)], fill=AXIS, width=aw)
    d.line([P(120, water), P(990, water)], fill=AXIS, width=aw)

    wu = 84          # trace width in artwork units
    w = wu * s       # ... and in device pixels

    def cap(x, y):
        d.ellipse([P(x - wu / 2, y - wu / 2), P(x + wu / 2, y + wu / 2)], fill=INK)

    def hump(cx, r):
        bb = [P(cx - r, water - r), P(cx + r, water + r)]
        d.arc(bb, 180, 360, fill=INK, width=int(w))
        cap(cx - r, water)
        cap(cx + r, water)

    hump(290, 175)
    hump(580, 115)
    # neck: quarter arc rising to the right
    ncx, ncy, nr = 895, water, 200
    d.arc([P(ncx - nr, ncy - nr), P(ncx + nr, ncy + nr)], 180, 270, fill=INK, width=int(w))
    cap(ncx - nr, water)
    # head: ellipse continuing from the top of the neck
    hx, hy, hw, hh = 905, water - 200, 180, 100
    d.ellipse([P(hx - hw / 2, hy - hh / 2), P(hx + hw / 2, hy + hh / 2)], fill=INK)
    # eye
    ex, ey = 940, water - 215
    d.ellipse([P(ex - 17, ey - 17), P(ex + 17, ey + 17)], fill=EYE)


def rounded_mask(size, radius):
    m = Image.new("L", (size, size), 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)
    return m


def render(canvas, draw_fn):
    big = Image.new("RGBA", (canvas * SS, canvas * SS), (0, 0, 0, 0))
    draw_fn(big)
    return big.resize((canvas, canvas), Image.LANCZOS)


def main():
    os.makedirs(OUT, exist_ok=True)
    N = 1024

    # 1. full-bleed master with rounded corners (Linux, Android legacy, docs)
    def full(big):
        bg = Image.new("RGBA", big.size, BG)
        big.paste(bg)
        draw_art(big, (0, 0, N * SS), True)
        big.putalpha(rounded_mask(N * SS, int(N * SS * 0.18)))
    full_img = render(N, full)
    full_img.save(os.path.join(OUT, "icon_1024.png"))
    full_img.resize((256, 256), Image.LANCZOS).save(os.path.join(OUT, "icon_256.png"))
    full_img.resize((512, 512), Image.LANCZOS).save(os.path.join(OUT, "icon_512.png"))

    # 2. Android adaptive foreground: launchers mask the inner 72/108 of the
    #    canvas and the safe zone is a 66/108 circle, so keep the art in the
    #    central 56% square (its corners then stay inside that circle).
    def fg(big):
        inner = int(N * SS * 0.56)
        off = (N * SS - inner) // 2
        draw_art(big, (off, off, inner), False)
    render(N, fg).save(os.path.join(OUT, "icon_android_fg.png"))

    # 3. macOS: rounded square 824/1024 centred on a transparent canvas
    def mac(big):
        inner = int(N * SS * 824 / 1024)
        off = (N * SS - inner) // 2
        tile = Image.new("RGBA", (inner, inner), BG)
        draw_art(tile, (0, 0, inner), True)
        tile.putalpha(rounded_mask(inner, int(inner * 0.225)))
        big.paste(tile, (off, off), tile)
    render(N, mac).save(os.path.join(OUT, "icon_macos.png"))

    print("wrote", sorted(os.listdir(OUT)))


if __name__ == "__main__":
    sys.exit(main())
