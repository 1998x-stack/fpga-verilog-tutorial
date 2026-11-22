#!/usr/bin/env python3
"""Playwright screenshot, offline asset, figure, MathML and responsive QA."""
from pathlib import Path
import sys
from playwright.sync_api import sync_playwright

root=Path(__file__).resolve().parent.parent
pages=["index.html"]+[f"chapters/{i:02}.html" for i in range(1,29)]
out=root/"qa"/"screens"
out.mkdir(parents=True,exist_ok=True)
issues=[]

with sync_playwright() as p:
    browser=p.chromium.launch(headless=True)
    for width in (360,390,768,1440):
        context=browser.new_context(viewport={"width":width,"height":900},device_scale_factor=1)
        for rel in pages:
            tab=context.new_page()
            tab.on("pageerror",lambda error, rel=rel:issues.append(f"JS error {rel}: {error}"))
            tab.on("console",lambda msg, rel=rel:issues.append(f"console error {rel}: {msg.text}") if msg.type=="error" else None)
            tab.on("requestfailed",lambda req, rel=rel:issues.append(f"request failed {rel}: {req.url}") if req.url.startswith(("http://","https://")) else None)
            tab.goto((root/rel).as_uri(),wait_until="load")
            tab.locator("img").evaluate_all(
                "(imgs) => Promise.all(imgs.map(img => { img.loading = 'eager'; return img.decode().catch(() => null); }))"
            )
            a=tab.evaluate("({scroll:document.documentElement.scrollWidth,width:innerWidth})")
            if a["scroll"]>a["width"]+2:
                issues.append(f"{width}px {rel}: horizontal document overflow {a}")
            bad=tab.locator("img").evaluate_all("(imgs)=>imgs.filter(i=>!i.complete||i.naturalWidth===0).map(i=>i.src)")
            if bad:
                issues.append(f"{width}px {rel}: broken images {bad}")
            figures=tab.locator("figure").evaluate_all(
                "(els)=>els.map(el=>({media:!!el.querySelector('img,svg'),caption:(el.querySelector('figcaption')?.textContent||'').trim(),imageAlt:[...el.querySelectorAll('img')].every(img=>!!img.alt.trim())}))"
            )
            for index,fig in enumerate(figures):
                if not fig["media"] or not fig["caption"] or not fig["imageAlt"]:
                    issues.append(f"{width}px {rel}: figure {index} missing media, caption or alt text: {fig}")
            remote_assets=tab.locator('script[src],link[rel="stylesheet"][href],img[src],iframe[src],source[src]').evaluate_all(
                "(els)=>els.map(el=>el.src||el.href).filter(url=>/^https?:/i.test(url))"
            )
            if remote_assets:
                issues.append(f"{width}px {rel}: non-offline external assets {remote_assets}")
            if tab.locator("svg math").count():
                issues.append(f"{width}px {rel}: MathML nested inside SVG")
            if width==1440 and rel.startswith("chapters/2") and rel in [f"chapters/{i:02}.html" for i in range(21,29)]:
                disclosure=tab.locator("details.exercise summary")
                if disclosure.count()!=1:
                    issues.append(f"{rel}: expected one native exercise disclosure")
                else:
                    disclosure.click()
                    if not tab.locator("details.exercise").evaluate("(el)=>el.open"):
                        issues.append(f"{rel}: exercise disclosure did not open")
                    disclosure.click()
                    if tab.locator("details.exercise").evaluate("(el)=>el.open"):
                        issues.append(f"{rel}: exercise disclosure did not close")
            if rel in ("chapters/25.html","chapters/26.html","chapters/28.html"):
                regions=tab.locator(".math-scroll").evaluate_all(
                    "(els)=>els.map(el=>({tabIndex:el.tabIndex,role:el.getAttribute('role'),label:el.getAttribute('aria-label'),height:el.getBoundingClientRect().height,clientWidth:el.clientWidth,scrollWidth:el.scrollWidth,maths:[...el.querySelectorAll('math')].map(m=>({namespace:m.namespaceURI,label:m.getAttribute('aria-label'),height:m.getBoundingClientRect().height}))}))"
                )
                if not regions:
                    issues.append(f"{width}px {rel}: no accessible MathML scroll region")
                for index,region in enumerate(regions):
                    if region["tabIndex"]!=0 or region["role"]!="region" or not region["label"] or region["height"]<=0 or not region["maths"]:
                        issues.append(f"{width}px {rel}: invalid MathML scroll region {index}: {region}")
                    for m in region["maths"]:
                        if m["namespace"]!="http://www.w3.org/1998/Math/MathML" or not m["label"] or m["height"]<=0:
                            issues.append(f"{width}px {rel}: MathML element not accessible/rendered: {m}")
                fractions=tab.locator(".math-scroll mfrac").evaluate_all(
                    "(els)=>els.map(el=>{const c=[...el.children];const r=c.map(x=>x.getBoundingClientRect());return {children:c.length,rects:r.map(x=>({x:x.x,y:x.y,width:x.width,height:x.height}))}})"
                )
                for fraction in fractions:
                    if fraction["children"]!=2 or len(fraction["rects"])!=2 or any(r["width"]<=0 or r["height"]<=0 for r in fraction["rects"]) or fraction["rects"][0]["y"]>=fraction["rects"][1]["y"]:
                        issues.append(f"{width}px {rel}: stacked fraction layout failed: {fraction}")
                if rel=="chapters/26.html" and not fractions:
                    issues.append("chapters/26.html: FIR equation fraction was not found")
                for index in range(len(regions)):
                    region=tab.locator(".math-scroll").nth(index)
                    region.focus()
                    if not region.evaluate("(el)=>document.activeElement===el"):
                        issues.append(f"{width}px {rel}: MathML region {index} is not keyboard focusable")
                    overflow=region.evaluate("(el)=>el.scrollWidth>el.clientWidth+1")
                    if overflow:
                        region.evaluate("(el)=>{el.scrollLeft=0}")
                        tab.keyboard.press("ArrowRight")
                        if region.evaluate("(el)=>el.scrollLeft<=0"):
                            issues.append(f"{width}px {rel}: overflowing MathML region {index} cannot scroll by keyboard")
            tab.screenshot(path=str(out/(rel.replace("/","-").replace(".html",f"-{width}.png"))),full_page=True)
            if width==1440 and rel in ("chapters/21.html","chapters/28.html"):
                tab.emulate_media(media="print")
                tab.screenshot(path=str(out/(rel.replace("/","-").replace(".html","-print.png"))),full_page=True)
                tab.emulate_media(media="screen")
            if rel=="index.html" and width==1440:
                tab.locator("#chapter-search").fill("AXI4-Lite")
                n=tab.locator("#visible-count").inner_text()
                if n!="1":
                    issues.append("catalog search AXI4-Lite should match one chapter; got "+n)
                tab.locator("#chapter-search").fill("")
                tab.locator('[data-filter="1"]').click()
                n=tab.locator("#visible-count").inner_text()
                if n!="5":
                    issues.append("first-stage filter should show 5; got "+n)
            tab.close()
        context.close()
    browser.close()
if issues:
    print("\n".join("FAIL "+s for s in issues))
    sys.exit(1)
print("PASS browser checks: 29 pages x 4 widths; 8 native disclosures; offline assets; figure captions; MathML fractions and keyboard scrolling; print samples; screenshots: qa/screens")
