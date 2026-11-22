#!/usr/bin/env python3
"""Playwright screenshot and overflow/console QA for new pages."""
from pathlib import Path
import sys
from playwright.sync_api import sync_playwright

root=Path(__file__).resolve().parent.parent
pages=["index.html"]+[f"chapters/{i:02}.html" for i in range(1,11)]
out=root/"qa"/"screens"
out.mkdir(parents=True,exist_ok=True)
issues=[]

with sync_playwright() as p:
    browser=p.chromium.launch(headless=True)
    for width in (360,390,1440):
        context=browser.new_context(viewport={"width":width,"height":900}, device_scale_factor=1)
        for rel in pages:
            tab=context.new_page()
            tab.on("pageerror",lambda error:issues.append("JS error: "+str(error)))
            tab.goto((root/rel).as_uri(),wait_until="load")
            tab.locator("img").evaluate_all(
                "(imgs) => Promise.all(imgs.map(img => { img.loading = 'eager'; return img.decode().catch(() => null); }))"
            )
            a=tab.evaluate("({scroll:document.documentElement.scrollWidth,width:innerWidth})")
            if a["scroll"]>a["width"]+2:issues.append(f"{width}px {rel}: horizontal overflow {a}")
            bad=tab.locator("img").evaluate_all("(imgs)=>imgs.filter(i=>!i.complete||i.naturalWidth===0).map(i=>i.src)")
            if bad:issues.append(f"{width}px {rel}: broken images {bad}")
            tab.screenshot(path=str(out/(rel.replace("/","-").replace(".html",f"-{width}.png"))), full_page=True)
            if rel=="index.html" and width==1440:
                tab.locator("#chapter-search").fill("AXI")
                n=tab.locator("#visible-count").inner_text()
                if n!="1":issues.append("catalog search AXI should match one chapter; got "+n)
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
print("PASS browser checks: 11 pages x 3 widths; screenshots: qa/screens")
