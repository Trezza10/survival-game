"""Bake aligned approximate relief normals for registered sprite-sheet regions.

Run with Python + Pillow + NumPy after adding regions to environment_regions.json.
Source color textures are read only. Output normal atlases share source dimensions.
"""
from pathlib import Path
import json
import numpy as np
from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parents[1]

def bake():
    regions = json.loads((ROOT / 'assets/environment_regions.json').read_text())['regions']
    for sheet in sorted({entry['sheet'] for entry in regions.values()}):
        source = Image.open(ROOT / f'assets/sheets/{sheet}.png').convert('RGBA')
        output = np.zeros((source.height, source.width, 4), dtype=np.uint8)
        output[:, :, :3] = (128, 128, 255)
        for entry in regions.values():
            if entry['sheet'] != sheet:
                continue
            x, y, width, height = entry['rect']
            rgba = np.asarray(source.crop((x, y, x + width, y + height)))
            rgb = rgba[:, :, :3].astype(np.float32) / 255.0
            r, g, b = rgb[:, :, 0], rgb[:, :, 1], rgb[:, :, 2]
            matte = ((r > .85) & (b > .75) & (g < .35)) | ((g > .90) & (r < .45) & (b < .55)) | ((b > .90) & (r < .35) & (g < .45)) | ((r > .95) & (g < .20) & (b < .20)) | ((r > .96) & (g > .96) & (b < .35))
            alpha = rgba[:, :, 3].copy()
            alpha[matte] = 0
            mask = Image.fromarray(alpha)
            # Broad silhouette curvature plus restrained color relief.
            radius = max(2.0, min(width, height) * .055)
            dome = np.asarray(mask.filter(ImageFilter.GaussianBlur(radius))).astype(np.float32) / 255.0
            luminance = (rgb @ np.array([.2126, .7152, .0722], dtype=np.float32)) * alpha / 255.0
            smooth = np.asarray(Image.fromarray(np.uint8(luminance * 255)).filter(ImageFilter.GaussianBlur(1.5))).astype(np.float32) / 255.0
            heightmap = dome * .8 + smooth * .2
            dy, dx = np.gradient(heightmap)
            strength = max(5.0, radius * 3.0)
            normal = np.stack((-dx * strength, dy * strength, np.ones_like(dx)), axis=2)
            normal /= np.linalg.norm(normal, axis=2, keepdims=True)
            packed = np.clip((normal * .5 + .5) * 255, 0, 255).astype(np.uint8)
            packed[alpha == 0] = (128, 128, 255)
            output[y:y+height, x:x+width, :3] = packed
            output[y:y+height, x:x+width, 3] = alpha
        target = ROOT / f'assets/normals/{sheet}_normal.png'
        Image.fromarray(output).save(target)
        print(f'Baked {target.name}: {source.width} x {source.height}')

if __name__ == '__main__':
    bake()
