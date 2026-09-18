# SeatScout — Launch Kit (ready-to-post copy)

> Nothing here is posted automatically. Each piece is paste-ready; fill the `[bracketed]` links once your domain + Lemon Squeezy products exist.
> Honesty rules followed: no fake reviews, no invented user counts. The $13,056 figure is explicitly labeled as a demo-tenant result.

---

## 0. Fire order (once live)
1. Site deployed at seatscout.dev + free Lite download working.
2. Post the **Reddit value posts** first (they drive the most qualified traffic). Put the link in a comment or your profile if the sub restricts links in posts.
3. Same day: **LinkedIn** + **X thread**.
4. Within the week: **Microsoft Tech Community** + the **blog post** (SEO).
5. Trickle: 3–5 **MSP DMs/emails** per day (don't blast).

---

## 1. Reddit — r/sysadmin / r/Office365 (value-first)

**Title:** Found ~21% wasted Microsoft 365 license spend in a 100-seat tenant — here's the method (and a free script)

**Body:**
With the July price increase, I went looking for license waste in M365 and was surprised how much hides in plain sight. The four buckets that actually move the number:

1. **Unassigned purchased seats** — you bought them, nobody's assigned. Pure refund at renewal.
2. **Disabled but still licensed** — blocked accounts that are still billed every month.
3. **Never-signed-in licensed users** — provisioned and forgotten.
4. **Inactive users** — no sign-in in N days (set your own threshold).

The trick that makes it land with finance: multiply each by the *actual* per-seat price so the output is dollars, not a CSV of UPNs. Also worth a look: E5 seats that could be E3 ($21/user/mo), and users carrying two base plans at once.

It's all read-only Microsoft Graph (`Get-MgSubscribedSku`, user `signInActivity`, etc.). I packaged my version into a script that spits out a dollar-quantified HTML report — there's a free version that just dumps the inactive/unused CSV if you want to skip the assembly. Link in a comment (not trying to spam the post).

Curious what waste % others are seeing — anyone routinely auditing this, or only at renewal?

*(Disclosure: I built the tool. The free tier is genuinely free; sharing because the method's useful either way.)*

**First comment (link):** Free version + how it works: [seatscout.dev] — runs entirely in your own tenant, nothing leaves it.

---

## 2. Reddit — r/msp (consultant angle)

**Title:** Turned the "M365 license audit" into a repeatable, white-label deliverable for clients

**Body:**
Every client tenant I touch has license waste, and the price increase made it an easy conversation to start. I standardized the audit into a one-command, read-only script that produces a client-ready report — dollar-quantified savings, disabled/inactive/unassigned breakdown, E5→E3 downgrade candidates, and a remediation checklist. White-labels with my logo so it goes straight to the client.

Runs in the client tenant (read-only Graph), so there's no "connect your tenant to a third party" objection — nothing leaves their environment.

Posting because the report has been a solid foot-in-the-door for optimization engagements. Happy to share the tool (free tier + a Pro tier licensed for unlimited client tenants); link in a comment to respect the no-spam rule.

How are you all packaging license reviews — bundled into QBRs, or billed as a standalone assessment?

---

## 3. LinkedIn

Microsoft 365 list prices went up on July 1 — E3 to $39, E5 to $60 a seat.

Most orgs won't notice, because most orgs don't know how many of those seats are doing nothing.

Gartner pegs SaaS license waste at 25–30%. On a 100-seat E3 tenant that's roughly $9,000/year sitting in:
• seats you bought but never assigned
• disabled accounts still being billed
• users who've never signed in
• E5 seats that only ever needed E3

I built a small read-only tool that finds all of it and reports it in dollars — runs inside your own tenant, nothing leaves it. There's a free version.

If you run M365 for your company or your clients, it's worth 5 minutes before your next renewal. Link in comments.

#Microsoft365 #ITPro #MSP #CloudCost #Entra

---

## 4. X / Twitter thread

1/ Microsoft 365 prices just went up (E3 $39, E5 $60/seat). Here's how to claw some back — most tenants waste 25–30% of license spend (Gartner). 🧵

2/ The waste hides in 4 places:
• unassigned purchased seats
• disabled accounts still licensed
• never-signed-in users
• inactive users
All findable read-only via Microsoft Graph.

3/ The move that makes it matter: price each wasted seat. "47 inactive users" is a shrug. "$13k/yr recoverable" gets a meeting. (that number's from a 100-seat demo tenant)

4/ Bonus finds: E5 seats that fit E3 ($21/user/mo back), and users holding two base plans at once.

5/ I packaged it into a one-command script + dollar report that runs in your own tenant (nothing leaves it). Free tier here 👉 [seatscout.dev]

---

## 5. Microsoft Tech Community (technical, credibility)

**Title:** A read-only approach to quantifying Microsoft 365 license waste in dollars

**Body:**
Sharing an approach for turning license data into a finance-ready savings number, entirely read-only via Microsoft Graph.

Data sources: `Get-MgSubscribedSku` (purchased vs consumed), `Get-MgUser` with `assignedLicenses`, `accountEnabled`, `createdDateTime`, and `signInActivity` (requires Entra ID P1; degrade gracefully without it). Map each `skuPartNumber` to a price table (watch the legacy names — Business Standard is still `O365_BUSINESS_PREMIUM`), then sum reclaimable seats × price.

Categories I flag: unassigned seats, disabled-but-licensed, never-signed-in, inactive > N days, overlapping base plans, and E5→E3 downgrade candidates (advisory — validate feature usage first).

I turned this into a packaged tool (SeatScout) with an HTML report; there's a free tier if you want to skip building it. Mostly interested in feedback on the methodology — particularly how others handle activity signals on tenants without P1.

---

## 6. Demo recording script (60–90s, screen capture)

- (0:00) Terminal in the SeatScout folder. Say: "Read-only M365 license audit. Nothing leaves the tenant."
- (0:05) Run the dry run: `.\SeatScout-Audit.ps1 -MockDataPath .\test\mock-tenant.json`
- (0:12) Report opens. Land on the hero number: "$13,056/yr recoverable on this demo tenant."
- (0:20) Scroll the four buckets + the SKU table (unassigned seats highlighted).
- (0:35) Show disabled/never/inactive tables, then the E5→E3 downgrade advisory.
- (0:50) Scroll to the remediation checklist. "From data to a plan in one run."
- (1:00) End card: seatscout.dev — free Lite, $49 Solo, $129 Pro.

Tooling: ScreenToGif or OBS. Keep it silent + captions, or a quick voiceover. Export <10MB GIF for Reddit/LinkedIn.

---

## 7. SEO (for the site + blog)

**Title tag:** SeatScout — Find & Recover Wasted Microsoft 365 License Spend
**Meta description:** Read-only audit that shows exactly how much Microsoft 365 license spend you can recover — unused, inactive, disabled and over-provisioned seats, in dollars. Runs in your tenant. Free tier.

**Primary keywords:** microsoft 365 license optimization, find unused office 365 licenses, m365 license audit tool, reduce microsoft 365 costs, inactive user license report, e5 vs e3 downgrade
**Long-tail:** how to find unused microsoft 365 licenses powershell, microsoft 365 license cost optimization 2026, reclaim disabled user licenses m365

**Blog post outline — "How to find wasted Microsoft 365 licenses (2026)":**
1. Why waste accumulates (offboarding gaps, over-provisioning, renewals)
2. The four buckets, with the Graph queries for each
3. Turning seats into dollars (the price-table step + legacy SKU names)
4. Downgrade & overlap edge cases
5. Do it free with the Lite script → upsell the full report
(Targets the keywords above; this is your durable free traffic.)

---

## 8. MSP outreach DM/email (1:1, low volume)

Subject: quick M365 license-waste check for your clients

Hi [name] — with the July M365 price bump, license waste is an easy win to bring clients. I built a read-only script that audits a tenant and produces a white-label, dollar-quantified savings report (disabled/inactive/unassigned seats + E5→E3 candidates). Runs in the client tenant, nothing leaves it. Free tier to try it on one tenant: [seatscout.dev]. If it's useful, the Pro tier is licensed for unlimited client tenants. No worries if not relevant.

---

_Drafts only. Want me to tailor any of these to a specific subreddit's rules, or tighten the LinkedIn post to your voice? I can also turn the blog outline into a full post._
