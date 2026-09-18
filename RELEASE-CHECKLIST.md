# SeatScout — Release checklist (single source of truth)

Everything's built. This is the exact sequence to go from "store in review" to "live and selling," then to "driving traffic." Do it top to bottom.

## ✅ Already done
- Domain `seatscout.dev` (Cloudflare) · site + blog live · brand/logo/favicon · OG share card
- Professional email: support@ / hello@ / ugur@ (Cloudflare routing → your inbox)
- Lemon Squeezy store: identity verified, contact email set, 3 products created + zips uploaded
- Site buttons currently wired to **test-mode** checkout URLs (placeholders for go-live)
- Content: 4 SEO posts + comparison page, email nurture sequence, launch posts, outreach templates
- Weekly pulse scheduled (Mondays)

## ✅ Gate 1 — Activate the store (you)
- [x] Click **Activate your store** in Lemon Squeezy → **approved 2026-07-03** (Polar fallback cancelled).

## ✅ Gate 2 — Go live on Lemon Squeezy (you, after approval)
- [x] Turn **off Test mode**.
- [x] **Copy to Live Mode** for each product: Lite, Solo, Pro (test products do NOT auto-transfer).
- [x] Copy the **3 LIVE checkout URLs** and send them to me (done 2026-07-03).

## ✅ Gate 3 — Wire + deploy (me + you)
- [x] I replace the URLs in `site/index.html` with the live ones (2026-07-03: hero, all 3 plan buttons, bottom CTA — Lite now goes through LS checkout for email capture; "Notify me" mailtos removed). Also deleted `site/download/` so Lite can't bypass email capture.
- [x] `npx wrangler deploy` — done 2026-07-03.

## ✅ Gate 4 — Smoke test (you, ~5 min on seatscout.dev)
- [x] **Get Solo $49** / **Get Pro $129** → checkout opens with correct product + price (live). ✓ 2026-07-03
- [x] **Download free Lite** → completes, asks for email, delivers `SeatScout-Lite.zip`. *(First try failed with S3 AccessDenied — "Copy to Live Mode" didn't carry product files/logos. Fixed 2026-07-03 by re-uploading all files + logos on the live products. Lesson for future products: always re-upload files after copy-to-live.)*
- [x] Footer **Support** → support@seatscout.dev. *(Was broken: Cloudflare Email Routing sat in the half-disabled "unlock records" state — MX/SPF resolved publicly but routing service was off. Re-enabled via wizard 2026-07-03; status Enabled/Locked. If mail ever stops arriving, check Email Routing status first.)*
- [x] Open `seatscout.dev/blog/` → all 4 posts load. ✓ 2026-07-03

## ✅ Gate 5 — SEO (you, 10 min, one-time)
- [x] Google Search Console → property verified. ✓ 2026-07-03
- [x] Sitemap submitted; pages indexing. ✓ 2026-07-03

## ⏳ Gate 6 — Launch (you) — copy is in `marketing/launch-posts-final.md`
- [ ] Day 1 AM: r/sysadmin value post → reply to every comment.
- [ ] Day 1 PM: LinkedIn + X thread (attach `brand/og-card.png` or the demo GIF).
- [ ] Day 2: r/msp post.
- [ ] Within the week: Microsoft Tech Community + share a blog post.
- [ ] Ongoing: 3–5 MSP outreach sends/day from ugur@ (`marketing/outreach-templates.md`).

## ⏳ Gate 7 — Convert (you, when emails start coming in)
- [ ] Load the `marketing/email-sequence.md` drip into Lemon Squeezy email (or your newsletter tool).
- [ ] Record the 60-sec demo GIF (shot list in `marketing/launch-posts-final.md` §6) for posts.

---

**The only hard dependency is Gate 1 (Lemon Squeezy approval).** Everything after it is fast. Ping me at Gate 2 with the live URLs and I'll handle the wiring.
