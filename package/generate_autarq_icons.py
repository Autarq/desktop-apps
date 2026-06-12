#!/usr/bin/env python3
"""Generate native AUTARQ app icons from the canonical square source image."""

from __future__ import annotations

import argparse
import shutil
import subprocess
import tempfile
from pathlib import Path

from PIL import Image


PACKAGE_DIR = Path(__file__).resolve().parent
DESKTOP_APPS_DIR = PACKAGE_DIR.parent
DEFAULT_SOURCE = PACKAGE_DIR / "assets" / "autarq-now-logo.png"

MAC_APPICON_DIR = DESKTOP_APPS_DIR / "macos" / "ONLYOFFICE" / "Images.xcassets" / "AppIcon.appiconset"
MAC_PRODUCT_ICON_DIR = DESKTOP_APPS_DIR / "macos" / "ONLYOFFICE" / "Resources" / "ProductIcons"
LINUX_ICON_DIR = DESKTOP_APPS_DIR / "package" / "common" / "linux" / "icons"

WINDOWS_ICO_PATHS = [
    DESKTOP_APPS_DIR / "win-linux" / "res" / "icons" / "desktopeditors.ico",
    DESKTOP_APPS_DIR / "win-linux" / "extras" / "projicons" / "res" / "icons" / "desktopeditors.ico",
    DESKTOP_APPS_DIR / "win-linux" / "extras" / "update-daemon" / "res" / "icons" / "desktopeditors.ico",
]

QT_RUNTIME_PNGS = {
    DESKTOP_APPS_DIR / "win-linux" / "res" / "icons" / "app-icon_64.png": 64,
    DESKTOP_APPS_DIR / "win-linux" / "res" / "icons" / "dock.png": 32,
    DESKTOP_APPS_DIR / "win-linux" / "res" / "icons" / "dock@1.5x.png": 48,
    DESKTOP_APPS_DIR / "win-linux" / "res" / "icons" / "dock@2x.png": 64,
}

MAC_APPICON_SIZES = {
    "16x16.png": 16,
    "32x32.png": 32,
    "32x32-1.png": 32,
    "64x64.png": 64,
    "128x128.png": 128,
    "256x256.png": 256,
    "256x256-1.png": 256,
    "512x512.png": 512,
    "512x512-1.png": 512,
    "1024x1024.png": 1024,
}

LINUX_ICON_SIZES = [16, 24, 32, 48, 64, 128, 256]
ICO_SIZES = [16, 20, 24, 28, 30, 32, 36, 40, 48, 56, 60, 64, 72, 80, 96, 256]

ICONSET_SIZES = {
    "icon_16x16.png": 16,
    "icon_16x16@2x.png": 32,
    "icon_32x32.png": 32,
    "icon_32x32@2x.png": 64,
    "icon_128x128.png": 128,
    "icon_128x128@2x.png": 256,
    "icon_256x256.png": 256,
    "icon_256x256@2x.png": 512,
    "icon_512x512.png": 512,
    "icon_512x512@2x.png": 1024,
}

MAC_PRODUCT_ICONS = [
    "autarq-write.icns",
    "autarq-sheets.icns",
    "autarq-keynote.icns",
    "autarq-pdf.icns",
]


def load_source(path: Path) -> Image.Image:
    image = Image.open(path).convert("RGBA")
    width, height = image.size
    if width != height:
        side = min(width, height)
        left = (width - side) // 2
        top = (height - side) // 2
        image = image.crop((left, top, left + side, top + side))
    return image


def save_png(source: Image.Image, path: Path, size: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    resized = source.resize((size, size), Image.Resampling.LANCZOS)
    resized.save(path, format="PNG", optimize=True)


def generate_icns(source: Image.Image) -> Path:
    iconutil = shutil.which("iconutil")
    if not iconutil:
        raise RuntimeError("iconutil is required to generate macOS .icns files")

    temp_dir = Path(tempfile.mkdtemp(prefix="autarq-icon-"))
    iconset_dir = temp_dir / "AutarqApp.iconset"
    iconset_dir.mkdir()
    for filename, size in ICONSET_SIZES.items():
        save_png(source, iconset_dir / filename, size)

    output = temp_dir / "AutarqApp.icns"
    subprocess.run([iconutil, "-c", "icns", str(iconset_dir), "-o", str(output)], check=True)
    return output


def generate_all(source_path: Path) -> None:
    source = load_source(source_path)

    for filename, size in MAC_APPICON_SIZES.items():
        save_png(source, MAC_APPICON_DIR / filename, size)

    icns = generate_icns(source)
    for filename in MAC_PRODUCT_ICONS:
        target = MAC_PRODUCT_ICON_DIR / filename
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(icns, target)

    for size in LINUX_ICON_SIZES:
        save_png(source, LINUX_ICON_DIR / f"{size}x{size}.png", size)

    for path, size in QT_RUNTIME_PNGS.items():
        save_png(source, path, size)

    ico_source = source.resize((1024, 1024), Image.Resampling.LANCZOS)
    for path in WINDOWS_ICO_PATHS:
        path.parent.mkdir(parents=True, exist_ok=True)
        ico_source.save(path, format="ICO", sizes=[(size, size) for size in ICO_SIZES])


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    args = parser.parse_args()
    generate_all(args.source)


if __name__ == "__main__":
    main()
