#!/usr/bin/env python3
"""Playwright screenshot and overflow/console QA for new pages."""
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
        context=browser.new_context(viewport={"width":width,"height":900}, device_scale_factor=1)
        for rel in pages:
            tab=context.new_page()
            tab.on("pageerror",lambda error:issues.append("JS error: "+str(error)))
            tab.on("console",lambda msg, rel=rel: issues.append(f"console error {rel}: {msg.text}") if msg.type=="error" else None)
            tab.goto((root/rel).as_uri(),wait_until="load")
            tab.locator("img").evaluate_all(
                "(imgs) => Promise.all(imgs.map(img => { img.loading = 'eager'; return img.decode().catch(() => null); }))"
            )
            a=tab.evaluate("({scroll:document.documentElement.scrollWidth,width:innerWidth})")
            if a["scroll"]>a["width"]+2:issues.append(f"{width}px {rel}: horizontal overflow {a}")
            bad=tab.locator("img").evaluate_all("(imgs)=>imgs.filter(i=>!i.complete||i.naturalWidth===0).map(i=>i.src)")
            if bad:issues.append(f"{width}px {rel}: broken images {bad}")
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
            tab.screenshot(path=str(out/(rel.replace("/","-").replace(".html",f"-{width}.png"))), full_page=True)
            if rel in ("chapters/25.html","chapters/26.html","chapters/28.html"):
                math_info=tab.locator(".math-scroll").evaluate("(el)=>({tabIndex:el.tabIndex,role:el.getAttribute('role'),label:el.getAttribute('aria-label'),namespace:el.querySelector('math')?.namespaceURI,height:el.getBoundingClientRect().height})")
                if math_info["tabIndex"]!=0 or math_info["role"]!="region" or not math_info["label"] or math_info["namespace"]!="http://www.w3.org/1998/Math/MathML" or math_info["height"]<=0:
                    issues.append(f"{width}px {rel}: MathML region failed accessibility/render checks {math_info}")
                tab.locator(".math-scroll").focus()
                if not tab.locator(".math-scroll").evaluate("(el)=>document.activeElement===el"):
                    issues.append(f"{width}px {rel}: MathML region is not keyboard focusable")
            if width==1440 and rel in ("chapters/21.html","chapters/28.html"):
                tab.emulate_media(media="print")
                tab.screenshot(path=str(out/(rel.replace("/","-").replace(".html","-print.png"))),full_page=True)
                tab.emulate_media(media="screen")
            if rel=="index.html" and width==1440:
                tab.locator("#chapter-search").fill("AXI4-Lite")
                n=tab.locator("#visible-count").inner_text()
                if n!="1":issues.append("catalog search AXI4-Lite should match one chapter; got "+n)
                tab.locator("#chapter-search").fill("")
                tab.locator('[data-filter="1"]').click()
                n=tab.locator("#visible-count").inner_text()
                if n!="5":issues.append("first-stage filter should show 5; got "+n)
            tab.close()
        context.close()
    browser.close()
if issues:
    print("\n".join("FAIL "+s for s in issues))
    sys.exit(1)
print("PASS browser checks: 29 pages x 4 widths; eight native disclosures; print sample; screenshots: qa/screens")
