# SeatScout — Demo GIF/video storyboard (production-ready)

**Goal:** in ~60 seconds, show "one read-only command → a dollar-quantified report." No talking required — on-screen captions carry it.
**Outputs:** a GIF (<10 MB) for Reddit, and an MP4 (1280×720) for LinkedIn/X (looks sharper, autoplays). Record once at high quality, export both.
**Golden rule:** record entirely with the **bundled mock data** (`test\mock-tenant.json`) — no real tenant, no real names, no sign-in popup. Nothing to redact, and the $13,056 number shows.

---

## Pre-flight (5 min setup before recording)
- **Terminal:** Windows Terminal, dark theme, font size ~18–20, window ~1280×720. `Clear-Host` so the screen is empty.
- **Working dir:** `cd D:\tools\claude\EarnMoney\SeatScout`
- **Browser:** a clean window (no bookmarks bar, no extensions visible), ready to open the generated report. Set zoom so the hero number + cards fill the view.
- **Capture tool:** ScreenToGif (easiest on Windows) or OBS. Capture a fixed 1280×720 region. **15 fps** for the GIF is plenty.
- **Captions:** add as overlay text in ScreenToGif (or in CapCut/Clipchamp for the MP4). Keep each ≤6 words, high-contrast.

---

## Scene-by-scene

| # | Time | On screen | Exact action | Caption overlay |
|---|------|-----------|--------------|-----------------|
| 1 | 0:00–0:04 | Empty terminal in the SeatScout folder | (already `cd`'d, screen cleared) | **"Microsoft 365 license waste — found in one command."** |
| 2 | 0:04–0:10 | Type the command, slowly enough to read | Type: `.\SeatScout-Audit.ps1 -MockDataPath .\test\mock-tenant.json` then Enter | **"Read-only. Runs in your own tenant."** |
| 3 | 0:10–0:16 | Console prints the run + RESULTS lines | (let it run; cursor on the `Recoverable: $1,088/mo → $13,056/yr` line) | **"$13,056/yr recoverable."** |
| 4 | 0:16–0:22 | Switch to browser, open `SeatScout-Report.html`, land on hero | Open the generated report; pause on the big green number | **"A report you can hand to a CFO."** |
| 5 | 0:22–0:32 | Slow scroll: the 4 summary cards + the "Where the money is" bars | Scroll smoothly | **"Unassigned · disabled · inactive · never-used."** |
| 6 | 0:32–0:42 | Scroll the SKU table + the disabled/inactive tables | Continue scrolling | **"Every wasted seat, priced from your own rates."** |
| 7 | 0:42–0:50 | The E5→E3 downgrade advisory section | Pause briefly on it | **"Even E5 → E3 downgrade candidates."** |
| 8 | 0:50–0:56 | The remediation checklist | Pause on the numbered checklist | **"From data to an action plan."** |
| 9 | 0:56–1:00 | End card (static) | Cut to a still: SeatScout logo + text | **"seatscout.dev — free tier · $49 · $129"** |

**End-card still:** use `brand/og-card.png` (already on-brand) or a plain slide: logo + "seatscout.dev" + "Free · $49 · $129". Hold 3–4 seconds so it's readable when the GIF loops.

---

## Editing & export
- **Trim** dead air between scenes; keep momentum. Target 55–65s.
- **Speed up** the scrolls slightly (1.25×) if it runs long — keep the hero number on screen long enough to read.
- **GIF:** 1280×720 (or 1100px wide), 15 fps, optimized to **<10 MB** (Reddit/most platforms cap there). ScreenToGif → "Save as GIF" → reduce colors / frame-skip if over.
- **MP4:** 1280×720, H.264, ~30 fps — for LinkedIn/X/landing page. Smaller file, sharper.

---

## Bonus: 6-second hero loop (optional)
A tiny looping clip for the top of the landing page or an X reply:
- 0:00–0:02 type the command → 0:02–0:04 RESULTS line ($13,056/yr) → 0:04–0:06 cut to the report hero number. Loop. No captions needed.

---

## Where to use it
- **LinkedIn / X:** attach the MP4 (native video ≈ 2× reach vs a link).
- **Reddit:** drop the GIF in your first comment alongside the link.
- **Landing page:** optional — embed the MP4 muted+autoplay+loop in the hero or the "report" section later.
- **Product Hunt / dev.to:** the GIF makes a strong header image if you post there.
