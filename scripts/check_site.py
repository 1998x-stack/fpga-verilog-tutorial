#!/usr/bin/env python3
"""Offline structural validation for HTML, local fragments, SVG and evidence."""
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlsplit, unquote
import json
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parent.parent
errors = []
MATH_TAGS = {
    "math", "mi", "mn", "mo", "mtext", "mrow", "mfrac", "msub", "msup",
    "msubsup", "munder", "munderover", "mtable", "mtr", "mtd", "msqrt", "mroot",
}

class Inspector(HTMLParser):
    def __init__(self):
        super().__init__()
        self.paths = []
        self.ids = set()
        self.h1s = 0
        self.figure_stack = []
        self.svg_depth = 0
        self.math_stack = []
    def handle_starttag(self, tag, attrs):
        props = dict(attrs)
        if tag == "h1":
            self.h1s += 1
        if tag == "figure":
            self.figure_stack.append({"media": False, "caption": False, "caption_text": "", "in_caption": False})
        if tag in ("img", "svg") and self.figure_stack:
            self.figure_stack[-1]["media"] = True
        if tag == "figcaption" and self.figure_stack:
            self.figure_stack[-1]["caption"] = True
            self.figure_stack[-1]["in_caption"] = True
        if tag == "img" and not props.get("alt", "").strip():
            errors.append("image missing alt text")
        if tag == "svg":
            self.svg_depth += 1
        if tag == "math":
            if self.svg_depth:
                errors.append("MathML must not be nested inside SVG")
            if not props.get("aria-label", "").strip() and not props.get("aria-labelledby", "").strip():
                errors.append("MathML missing accessible name")
        if tag in MATH_TAGS:
            if self.math_stack and self.math_stack[-1][0] == "mfrac":
                self.math_stack[-1][1] += 1
            self.math_stack.append([tag, 0])
        if "id" in props:
            if props["id"] in self.ids:
                errors.append("duplicate HTML id: " + props["id"])
            self.ids.add(props["id"])
        for key in ("href", "src"):
            if key in props:
                self.paths.append(props[key])
    def handle_data(self, data):
        if self.figure_stack and self.figure_stack[-1]["in_caption"]:
            self.figure_stack[-1]["caption_text"] += data
    def handle_endtag(self, tag):
        if tag == "svg":
            self.svg_depth = max(0, self.svg_depth - 1)
        if tag == "figcaption" and self.figure_stack:
            self.figure_stack[-1]["in_caption"] = False
        if tag == "figure" and self.figure_stack:
            fig = self.figure_stack.pop()
            if not fig["media"]:
                errors.append("figure has no img or svg media")
            if not fig["caption"] or not fig["caption_text"].strip():
                errors.append("figure missing nonempty figcaption")
        if tag in MATH_TAGS:
            for i in range(len(self.math_stack) - 1, -1, -1):
                if self.math_stack[i][0] == tag:
                    node = self.math_stack.pop(i)
                    if tag == "mfrac" and node[1] != 2:
                        errors.append(f"MathML mfrac must have exactly two element children; found {node[1]}")
                    break

html_info = {}
for file in ROOT.rglob("*.html"):
    rel = str(file.relative_to(ROOT))
    parser = Inspector()
    try:
        parser.feed(file.read_text(encoding="utf-8"))
        parser.close()
    except Exception as exc:
        errors.append(f"{rel}: failed to parse: {exc}")
        continue
    if file.parent.name == "chapters" and file.stem in tuple(f"{i:02}" for i in range(1, 29)) and parser.h1s != 1:
        errors.append(f"{rel}: must have exactly 1 h1; found {parser.h1s}")
    html_info[file.resolve()] = parser

svg_info = {}
for file in ROOT.rglob("*.svg"):
    rel = str(file.relative_to(ROOT))
    try:
        root = ET.parse(file).getroot()
        ns = "{http://www.w3.org/2000/svg}"
        if root.tag != ns + "svg":
            errors.append(rel + ": wrong root namespace")
        if "viewBox" not in root.attrib:
            errors.append(rel + ": viewBox missing")
        if root.find(ns + "title") is None:
            errors.append(rel + ": title missing")
        if root.find(ns + "desc") is None and file.name != "favicon.svg":
            errors.append(rel + ": desc missing")
        ids = [el.attrib["id"] for el in root.iter() if "id" in el.attrib]
        if len(ids) != len(set(ids)):
            errors.append(rel + ": duplicate SVG id")
        idset = set(ids)
        for el in root.iter():
            refs = el.attrib.get("aria-labelledby", "").split()
            for ref in refs:
                if ref not in idset:
                    errors.append(rel + f": aria-labelledby target missing: {ref}")
        svg_info[file.resolve()] = idset
    except Exception as exc:
        errors.append(f"{rel}: invalid XML: {exc}")

# Resolve both local files and cross-page fragments, not just file existence.
for file, parser in html_info.items():
    rel = str(file.relative_to(ROOT))
    for target in parser.paths:
        u = urlsplit(target)
        if u.scheme or u.netloc:
            if u.scheme == "javascript":
                errors.append(f"{rel}: javascript: URL is not allowed")
            continue
        dest = file if not u.path else (file.parent / unquote(u.path)).resolve()
        if not dest.is_relative_to(ROOT):
            errors.append(f"{rel}: path escapes root: {target}")
            continue
        if not dest.exists():
            errors.append(f"{rel}: missing local link: {target}")
            continue
        if u.fragment:
            frag = unquote(u.fragment)
            if dest.suffix.lower() == ".html":
                target_parser = html_info.get(dest)
                if target_parser and frag not in target_parser.ids:
                    errors.append(f"{rel}: missing HTML fragment {target}")
            elif dest.suffix.lower() == ".svg":
                ids = svg_info.get(dest, set())
                if frag not in ids:
                    errors.append(f"{rel}: missing SVG fragment {target}")

# Validate the evidence ledger against the Olah-style schema.
try:
    evidence = json.loads((ROOT / "data/evidence.json").read_text(encoding="utf-8"))
    if evidence.get("schema_version") != 2:
        errors.append("data/evidence.json: schema_version must be 2")
    if not isinstance(evidence.get("checks"), list):
        errors.append("data/evidence.json: checks must be an array")
    else:
        allowed = {"verified", "derived", "illustrative", "unverified"}
        seen = set()
        required = ("id", "claim", "kind", "source_url", "locator", "status", "notes", "chapters")
        for i, item in enumerate(evidence["checks"]):
            for key in required:
                if key not in item or item[key] in (None, "", []):
                    errors.append(f"data/evidence.json: check {i} missing {key}")
            ident = item.get("id")
            if ident in seen:
                errors.append(f"data/evidence.json: duplicate id {ident}")
            seen.add(ident)
            if item.get("status") not in allowed:
                errors.append(f"data/evidence.json: invalid status for {ident}: {item.get('status')}")
            source = item.get("source_url", "")
            if not source.startswith("https://"):
                errors.append(f"data/evidence.json: source_url must be HTTPS for {ident}")
            if not isinstance(item.get("chapters"), list):
                errors.append(f"data/evidence.json: chapters must be an array for {ident}")
    if not isinstance(evidence.get("limitations"), list):
        errors.append("data/evidence.json: limitations must be an array")
except Exception as exc:
    errors.append("data/evidence.json: " + str(exc))

if errors:
    print("\n".join("ERROR " + s for s in errors))
    sys.exit(1)
print("PASS local links + cross-page fragments, 28 chapter H1s, figure captions, image alt, MathML structure, SVG XML/labels, and evidence schema")
