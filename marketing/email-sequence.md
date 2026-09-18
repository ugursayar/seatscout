# SeatScout — Lite → Paid email sequence

> Goal: turn a free Lite download (email captured at checkout) into a Solo/Pro purchase.
> Where to run it: Lemon Squeezy email automations, or any newsletter tool (Buttondown, MailerLite, Resend, etc.).
> Tone: helpful first, never pushy. No fake claims. The "$13,056" figure is always labeled as a demo-tenant example.
> Sender: SeatScout · support@seatscout.dev (or hello@seatscout.dev)

Timing is from the moment someone downloads Lite. Adjust to taste.

---

## Email 0 — instant (on Lite download)
**Subject:** Your SeatScout Lite is ready (2-minute setup)
**Alt subject (A/B):** Run your first M365 license audit in 2 minutes

Hi — thanks for grabbing SeatScout Lite.

It's read-only and runs entirely in your own tenant — nothing is sent anywhere. To run it:

1. Unzip it.
2. In PowerShell, from the folder: `.\SeatScout-Audit.ps1 -Lite`
3. Sign in when prompted (read-only consent), and you'll get a CSV of your inactive, never-signed-in, and disabled-but-licensed seats.

That CSV alone usually surfaces a few licenses worth reclaiming. If you'd rather see the whole picture in dollars, that's what the paid tiers add — more on that in a couple of days.

Any trouble running it? Just reply to this email.

— SeatScout

---

## Email 1 — +2 days
**Subject:** Did it find anything?
**Alt subject:** What the Lite CSV usually misses

Quick nudge: if you haven't run SeatScout Lite yet, it's two minutes — `.\SeatScout-Audit.ps1 -Lite` from the folder.

When you do, you'll get the *list* of wasted seats. What Lite doesn't do is the part that gets a renewal conversation moving: putting a **dollar figure** on it and catching the bigger wins — unassigned purchased seats, overlapping plans, and E5→E3 downgrade candidates.

On a 100-seat demo tenant, those add up to ~$13,056/year recoverable. Your number will be your own — but it's rarely zero.

If that number would be useful to have in writing, reply and I'll point you to the right tier.

— SeatScout

---

## Email 2 — +4 days
**Subject:** From "47 inactive users" to "$X/year"
**Alt subject:** The report that gets a yes from finance

A list of inactive users gets a shrug. A number gets a meeting.

SeatScout **Solo** ($49, one-time) takes the same read-only scan and produces a CFO-ready HTML report: every wasted seat priced from your own license costs, the annual total, all findings as CSVs, plus overlapping-plan and E5→E3 downgrade candidates and a remediation checklist.

One reclaimed E3 seat ($39/mo) pays for Solo in about six weeks. Everything after that is savings.

→ See Solo: https://seatscout.dev/#pricing

— SeatScout

---

## Email 3 — +7 days (consultant/MSP angle)
**Subject:** If you audit other people's tenants
**Alt subject:** Turn a license audit into a billable deliverable

If you run M365 for clients, license waste is one of the easiest wins to bring to a QBR — and an easy upsell into an optimization engagement.

SeatScout **Pro** ($129, one-time) is licensed for **unlimited client tenants** and **white-labels** the report with your own name and logo. Run it read-only in a client's tenant, hand them a branded, dollar-quantified savings report, and let the number make your case.

→ See Pro: https://seatscout.dev/#pricing

(If you only need your own tenant, Solo's the one.)

— SeatScout

---

## Email 4 — +12 days (timing nudge, then stop)
**Subject:** Before your next renewal
**Alt subject:** The price increase is the easy part to offset

Microsoft 365 prices rose up to 33% this year. The increase is usually smaller than the waste already sitting in a tenant — and renewal is exactly when reclaiming it counts.

If you've been meaning to get the full SeatScout report, now's the moment:
→ https://seatscout.dev/#pricing

That's the last you'll hear from me on this — the free Lite is yours to keep either way. Reply anytime if you have questions.

— SeatScout

---

### Notes
- Suppress paid emails (2–4) for anyone who already bought Solo/Pro.
- If Lemon Squeezy's built-in emails are enough, you can run just Email 0 (delivery) + Email 2 (Solo nudge) and skip the rest.
- Keep it plain-text-ish; it reads as a founder writing, not a marketing blast — that converts better for this audience.
