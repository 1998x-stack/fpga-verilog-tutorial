#!/usr/bin/env python3
"""Offline-only static validation of local references and standalone SVGs."""
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlsplit, unquote
import json
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parent.parent
errors = []

class Inspector(HTMLParser):
    def __init__(self):
        super().__init__()
        self.paths = []
        self.ids = set()
        self.fragments = []
        self.h1s = 0
    def handle_starttag(self, tag, attrs):
        props = dict(attrs)
        if tag == "h1": self.h1s += 1
        if "id" in props:
            if props["id"] in self.ids: errors.append("duplicate HTML id: "+props["id"])
            self.ids.add(props["id"])
        for key in ("href", "src"):
            if key in props:
                self.paths.append(props[key])

def validate_html(file):
    rel = str(file.relative_to(ROOT))
    parser=Inspector()
    try: parser.feed(file.read_text(encoding="utf-8"))
    except Exception as exc:
        errors.append(f"{rel}: failed to parse: {exc}");return
    if file.parent.name=="chapters" and file.stem in ("01","02","03","04","05") and parser.h1s!=1:
        errors.append(f"{rel}: must have exactly 1 h1; found {parser.h1s}")
    for target in parser.paths:
        u=urlsplit(target)
        if u.scheme or u.netloc or target.startswith(("#","data:","mailto:","tel:")):
            if target.startswith("#") and target[1:] not in parser.ids: errors.append(f"{rel}: missing fragment {target}")
            continue
        if not u.path:continue
        path=(file.parent/unquote(u.path)).resolve()
        if not path.is_relative_to(ROOT):
            errors.append(f"{rel}: path escapes root: {target}")
        elif not path.exists():
            errors.append(f"{rel}: missing local link: {target}")

for file in ROOT.rglob("*.html"): validate_html(file)
for file in ROOT.rglob("*.svg"):
    rel=str(file.relative_to(ROOT))
    try:
        r=ET.parse(file).getroot()
        ns="{http://www.w3.org/2000/svg}"
        if r.tag != ns+"svg":errors.append(rel+": wrong root namespace")
        if "viewBox" not in r.attrib:errors.append(rel+": viewBox missing")
        if r.find(ns+"title") is None:errors.append(rel+": title missing")
        if r.find(ns+"desc") is None and file.name!="favicon.svg":errors.append(rel+": desc missing")
    except Exception as exc:
        errors.append(f"{rel}: invalid XML: {exc}")
try:json.loads((ROOT/"data/evidence.json").read_text(encoding="utf-8"))
except Exception as exc:errors.append("data/evidence.json: "+str(exc))
if errors:
    print("\n".join("ERROR "+s for s in errors))
    sys.exit(1)
print("PASS local links, new chapter H1s, SVG XML, and evidence ledger")
