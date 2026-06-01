#!/usr/bin/env python3
"""Regenerate public/kilter-board-holds.json from public/kilter-board.svg."""

import json
import re
from collections import defaultdict
from pathlib import Path
from xml.etree import ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
SVG_PATH = ROOT / "public" / "kilter-board.svg"
OUT_PATH = ROOT / "public" / "kilter-board-holds.json"

MERGE_DIST = 22
MIN_AREA = 50
MIN_DIMENSION = 4
ROWS = 22
BG = {"#FDFDFD", "#fdfdfd"}
NUM_RE = re.compile(r"-?\d*\.?\d+")


def local(tag: str) -> str:
    return tag.split("}")[-1] if "}" in tag else tag


def path_bbox(d: str):
    nums = [float(n) for n in NUM_RE.findall(d)]
    if len(nums) < 2:
        return None
    xs, ys = nums[0::2], nums[1::2]
    x0, y0, x1, y1 = min(xs), min(ys), max(xs), max(ys)
    width, height = x1 - x0, y1 - y0
    if width < MIN_DIMENSION or height < MIN_DIMENSION:
        return None
    area = width * height
    if area < MIN_AREA:
        return None
    return x0, y0, x1, y1, area, width, height


def hold_radius(width: float, height: float) -> int:
    size = max(width, height)
    return int(max(10, min(18, size * 0.55)))


def merge_holds(paths):
    paths_sorted = sorted(paths, key=lambda item: -item[4])
    merged = []

    for x0, y0, x1, y1, _area, width, height in paths_sorted:
        cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
        for index, hold in enumerate(merged):
            hx = (hold[0] + hold[2]) / 2
            hy = (hold[1] + hold[3]) / 2
            if ((cx - hx) ** 2 + (cy - hy) ** 2) ** 0.5 < MERGE_DIST:
                merged[index] = [
                    min(hold[0], x0),
                    min(hold[1], y0),
                    max(hold[2], x1),
                    max(hold[3], y1),
                ]
                break
        else:
            merged.append([x0, y0, x1, y1])

    result = []
    for hold in merged:
        x0, y0, x1, y1 = hold
        width, height = x1 - x0, y1 - y0
        result.append(((x0 + x1) / 2, (y0 + y1) / 2, hold_radius(width, height)))
    return result


def assign_row_ids(holds):
    ys = [point[1] for point in holds]
    y_min, y_max = min(ys), max(ys)
    row_spacing = (y_max - y_min) / ROWS

    rows = defaultdict(list)
    for cx, cy, radius in holds:
        row_index = int((cy - y_min) / row_spacing) + 1
        row_index = max(1, min(ROWS, row_index))
        rows[row_index].append((cx, cy, radius))

    sorted_rows = sorted(
        rows.keys(),
        key=lambda row: sum(point[1] for point in rows[row]) / len(rows[row]),
    )

    result = []
    for new_row_index, old_row_index in enumerate(sorted_rows, 1):
        row_holds = sorted(rows[old_row_index], key=lambda point: point[0])
        for col_index, (cx, cy, radius) in enumerate(row_holds, 1):
            result.append(
                {
                    "id": f"r{new_row_index}c{col_index}",
                    "cx": round(cx, 2),
                    "cy": round(cy, 2),
                    "r": radius,
                }
            )
    return result


def main():
    root = ET.parse(SVG_PATH).getroot()
    paths = []

    for element in root.iter():
        if local(element.tag) != "path":
            continue
        fill = (element.get("fill") or "").upper()
        if not fill or fill in BG:
            continue
        data = element.get("d")
        if not data:
            continue
        bbox = path_bbox(data)
        if bbox:
            paths.append(bbox)

    holds = merge_holds(paths)
    result = assign_row_ids(holds)

    OUT_PATH.write_text(json.dumps(result, separators=(",", ":")))
    print(f"Wrote {len(result)} holds to {OUT_PATH}")


if __name__ == "__main__":
    main()
