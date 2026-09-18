# SeatScout — Final launch posts (paste-ready)

> ✅ **CLEARED TO POST as of 2026-07-03.** Store live, all three checkouts smoke-tested, Lite delivery confirmed, support@ working. Pricing claims re-verified 2026-07-03: E3 $36→$39, E5 $57→$60 effective July 1, 2026 (Microsoft licensing announcement).

All links below point to **https://seatscout.dev** (the site frames the value better than a raw checkout link).

---

## 1) Reddit — r/sysadmin or r/Office365  (post the value, link in a comment)

**Title:** Found ~21% wasted Microsoft 365 license spend in a 100-seat tenant — here's the method

**Body:**
With the July price bump (E3 → $39, E5 → $60/seat) I went hunting for license waste and was surprised how much hides in plain sight. The four buckets that actually move the number:

1. **Unassigned purchased seats** — bought, assigned to nobody. Cleanest refund at renewal.
2. **Disabled but still licensed** — blocked accounts still billed monthly.
3. **Never-signed-in licensed users** — provisioned and forgotten.
4. **Inactive users** — no sign-in in N days (you pick the threshold).

What makes it land with finance: multiply each by the *actual* per-seat price so the output is dollars, not a CSV of UPNs. Bonus finds: E5 seats that fit E3 ($21/user/mo back), and users holding two base plans at once.

It's all read-only Microsoft Graph (`Get-MgSubscribedSku`, user `signInActivity`, etc.). One gotcha: on tenants without Entra ID P1, asking for `signInActivity` 403s the whole user query — you have to retry without it.

Curious what waste % others see — do you audit this routinely or only at renewal?

*(Disclosure: I built a tool that does this end-to-end; there's a free version. Happy to drop the link in a comment if that's allowed here — not trying to spam the post.)*

**→ First comment:** Free version (CSV of unused/inactive seats, runs read-only in your own tenant): https://seatscout.dev

**Reddit rules to respect:** Many subs require some comment karma + account age before links. Post the value as the main thread; put the link in a comment or your profile. Read each sub's self-promo rule first. Reply to every comment for the first few hours — engagement drives reach.

---

## 2) Reddit — r/msp  (consultant angle — your Pro tier)

**Title:** Turned the "M365 license audit" into a repeatable, white-label client deliverable

**Body:**
Every client tenant I touch has license waste, and the price increase made it an easy QBR conversation. I standardized the audit into a one-command, read-only script that outputs a client-ready report: dollar-quantified savings, disabled/inactive/unassigned breakdown, E5→E3 downgrade candidates, and a remediation checklist. White-labels with my logo, so it goes straight to the client.

Runs in the client tenant (read-only Graph) — no "connect your tenant to a third party" objection, nothing leaves their environment.

How do you all package license reviews — bundled into QBRs, or billed as a standalone assessment? (Happy to share the tool; link in a comment to respect the no-spam rule.)

**→ Comment link:** https://seatscout.dev

---

## 3) LinkedIn  (your network + the price-hike hook)

Microsoft 365 list prices went up on July 1 — E3 to $39, E5 to $60 per seat.

Most orgs won't feel it, because most don't know how many of those seats are doing nothing.

Gartner pegs SaaS license waste at 25–30%. On a 100-seat E3 tenant that's ~$9,000/year sitting in:
• seats you bought but never assigned
• disabled accounts still being billed
• users who've never signed in
• E5 seats that only ever needed E3

I built a small read-only tool that finds all of it and reports it in dollars — runs inside your own tenant, nothing leaves it. There's a free version.

If you run M365 for your company or your clients, it's worth 5 minutes before your next renewal → https://seatscout.dev

#Microsoft365 #ITPro #MSP #CloudCost #Entra

*(Attach the sample-report screenshot or the demo GIF — visual posts get ~2x reach.)*

---

## 4) X / Twitter thread

1/ Microsoft 365 prices just went up (E3 $39, E5 $60/seat). Here's how to claw some back — most tenants waste 25–30% of license spend (Gartner). 🧵

2/ The waste hides in 4 places, all findable read-only via Microsoft Graph:
• unassigned purchased seats
• disabled accounts still licensed
• never-signed-in users
• inactive users

3/ The move that makes it matter: price each wasted seat. "47 inactive users" is a shrug. "$13k/yr recoverable" gets a meeting. (number from a 100-seat demo tenant)

4/ Bonus: E5 seats that fit E3 ($21/user/mo back), and users holding two base plans at once.

5/ I packaged it into a one-command script + dollar report that runs in your own tenant (nothing leaves it). Free tier 👉 https://seatscout.dev

---

## 5) Microsoft Tech Community  (credibility, slower burn)

**Title:** A read-only approach to quantifying Microsoft 365 license waste in dollars

**Body:**
Sharing a method for turning license data into a finance-ready savings number, entirely read-only via Microsoft Graph. Sources: `Get-MgSubscribedSku` (purchased vs consumed) + `Get-MgUser` (`assignedLicenses`, `accountEnabled`, `createdDateTime`, `signInActivity`). Map each `skuPartNumber` to a price table (watch the legacy names — Business Standard is still `O365_BUSINESS_PREMIUM`), then sum reclaimable seats × price.

Two gotchas worth flagging: `signInActivity` needs Entra ID P1 (and 403s the whole query without it — retry without the property), and free/self-service SKUs report a giant "unlimited" prepaid count you must exclude before summing unassigned seats.

I packaged this into a tool (SeatScout) with an HTML report and a free tier — but mostly interested in how others handle activity signals on tenants without P1.

---

## 6) Demo GIF — shot list (record once, reuse everywhere)

Record at ~1280×720, silent with captions. Tool: ScreenToGif (Windows) or OBS. Export <10 MB.

| Time | On screen | Caption |
|------|-----------|---------|
| 0:00 | Terminal in the SeatScout folder | "Read-only M365 license audit. Nothing leaves your tenant." |
| 0:04 | Type & run: `.\SeatScout-Audit.ps1 -MockDataPath .\test\mock-tenant.json` | "One command." |
| 0:10 | Report opens; cursor lands on the hero number | "$13,056/yr recoverable (demo tenant)." |
| 0:18 | Scroll the 4 buckets + SKU table | "Unassigned, disabled, inactive, never-used — in dollars." |
| 0:30 | Show disabled/inactive tables, then E5→E3 advisory | "Even E5→E3 downgrade candidates." |
| 0:42 | Scroll to remediation checklist | "From data to an action plan in one run." |
| 0:50 | End card: logo + seatscout.dev + Free / $49 / $129 | "seatscout.dev — free tier" |

Use the GIF in the LinkedIn post and as the Reddit first-comment visual.

---

## Posting schedule (locked 2026-07-03, staggered for Reddit account age)
1. **Fri–Sun (Jul 3–5):** 2–3 genuine value comments/day on r/sysadmin & r/msp — paste-ready drafts in `weekend-warmup-comments.md`, no product mention. Goal: account age 7+ and real karma before launch post.
2. **Mon Jul 6, ~16:00 TR (9am ET):** LinkedIn post (attach `brand/og-card.png` or sample-report screenshot; GIF optional later).
3. **Mon Jul 6 PM (US afternoon):** X thread.
4. **Tue Jul 7 or Wed Jul 8, AM US:** r/sysadmin value post — link ONLY in first comment. Reply to every comment for the first hours.
5. **Thu Jul 9:** r/msp post.
6. **Within the week:** Microsoft Tech Community + share a blog post for SEO.
7. **Ongoing:** 3–5 personalized MSP DMs/day from ugur@ — never bulk.
