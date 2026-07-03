"""Generates the app icon (1024px) with Pillow — no image model needed.
Design: deep-teal gradient, gold 'awareness/voice' rings radiating from a
Kaaba mark (black cube + gold kiswa band + door). Run:
    uv run --with pillow python make_icon.py
"""
from PIL import Image, ImageDraw

SIZE = 1024
TOP = (16, 84, 82)       # teal
BOTTOM = (9, 43, 42)      # deep teal
GOLD = (212, 174, 84)
KAABA = (16, 17, 19)

img = Image.new("RGB", (SIZE, SIZE), BOTTOM)
px = img.load()
for y in range(SIZE):                       # vertical gradient
    t = y / (SIZE - 1)
    r = int(TOP[0] + (BOTTOM[0] - TOP[0]) * t)
    g = int(TOP[1] + (BOTTOM[1] - TOP[1]) * t)
    b = int(TOP[2] + (BOTTOM[2] - TOP[2]) * t)
    for x in range(SIZE):
        px[x, y] = (r, g, b)

overlay = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
d = ImageDraw.Draw(overlay)

cx, cy = SIZE // 2, 500
# radiating "voice / awareness" rings behind the Kaaba
for radius, alpha, width in [(300, 150, 14), (390, 95, 12), (480, 55, 10)]:
    d.ellipse([cx - radius, cy - radius, cx + radius, cy + radius],
              outline=GOLD + (alpha,), width=width)

img.paste(overlay, (0, 0), overlay)

# Kaaba: black cube with a gold band and a door
side = 300
x0, y0 = cx - side // 2, cy - side // 2
x1, y1 = cx + side // 2, cy + side // 2
d2 = ImageDraw.Draw(img)
d2.rounded_rectangle([x0, y0, x1, y1], radius=18, fill=KAABA)
band_y = y0 + 78
d2.rectangle([x0, band_y, x1, band_y + 34], fill=GOLD)              # kiswa gold band
door_w = 54
d2.rectangle([cx - door_w // 2, y1 - 96, cx + door_w // 2, y1], fill=GOLD)  # door

img.save("../Sources/Assets.xcassets/AppIcon.appiconset/icon_1024.png")
print("wrote icon_1024.png")
