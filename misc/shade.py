from PIL import Image
import math
import numpy as np
import sys

w = 1600
s = 240
e = 400

sz = 80
filename = "Shade.png" if len(sys.argv) < 2 else sys.argv[1]

d = np.zeros((sz, sz, 4), dtype=np.uint8)
for i in range(sz):
    for j in range(sz):
        r = math.sqrt((i - sz / 2) ** 2 + (j - sz / 2) ** 2)
        f = (w * r / sz - s) / (e - s)
        f = max(0, f)
        f = min(1, f)
        d[i][j][3] = 255 * f

img = Image.frombuffer("RGBA", (sz, sz), d, "raw", "RGBA", 0, 1)
img.save(filename, "PNG")
