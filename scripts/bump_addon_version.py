#!/usr/bin/env python3
import re, sys, pathlib

if len(sys.argv) != 2:
    print("Usage: bump_addon_version.py <path/to/config.yaml>")
    sys.exit(1)

p = pathlib.Path(sys.argv[1])
s = p.read_text(encoding="utf-8")

m = re.search(r'^(version:\s*")(\d+)\.(\d+)\.(\d+)(")', s, re.M)
if not m:
    # Try a looser match: version: "X.Y" -> add .1
    m2 = re.search(r'^(version:\s*")(\d+)\.(\d+)(")', s, re.M)
    if m2:
        new = f'{m2.group(1)}{m2.group(2)}.{m2.group(3)}.1{m2.group(4)}'
        s2 = s[:m2.start()] + new + s[m2.end():]
        p.write_text(s2, encoding="utf-8")
        print("Bumped to:", f"{m2.group(2)}.{m2.group(3)}.1")
        sys.exit(0)
    # Default to 0.0.1
    s2 = re.sub(r'^(version:\s*")(.*?)(")', r'\g<1>0.0.1\3', s, flags=re.M)
    p.write_text(s2, encoding="utf-8")
    print("Bumped to:", "0.0.1")
    sys.exit(0)

major, minor, patch = int(m.group(2)), int(m.group(3)), int(m.group(4))
patch += 1
new_version = f'{major}.{minor}.{patch}'
new_line = f'{m.group(1)}{new_version}{m.group(5)}'
s2 = s[:m.start()] + new_line + s[m.end():]
p.write_text(s2, encoding="utf-8")
print("Bumped to:", new_version)
