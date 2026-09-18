# Reddit Warm-Up Kit — SeatScout

> Goal: take u/Inevitable_Market293 from 0→credible so the launch posts land instead of getting auto-removed.
> Account: **u/Inevitable_Market293** · created 2026-06-30 · karma 1 · email-verified (Google).
> Rule of thumb: **comment for value first, never lead with a link, let the account age ~5–7 days before any post that mentions SeatScout.**

---

## 0. Why the wait (don't skip)
New + low-karma accounts hit AutoMod filters on the big subs. A day-1 account dropping a link in r/sysadmin or r/msp typically gets:
- the post silently removed (you won't even see it's gone), and/or
- the account flagged as spam → shadowban, and/or
- **seatscout.dev added to a domain blocklist** across subs — hard to reverse.

Five to seven days of genuine commenting fixes the age+karma gate and gives you a real footprint a mod can look at and trust.

---

## 1. Profile setup (light touch — do NOT over-brand)
Keep it looking like a real admin, not a marketing account.
- **Avatar:** pick any default snoovatar, or a simple non-logo image. *Don't* use the SeatScout logo — that's the astroturf tell.
- **Display name:** something human, e.g. "M365 admin" or just leave the username.
- **Bio (about):** one neutral line, no product mention. Example: *"Sysadmin, mostly Microsoft 365 / Entra. Here for the war stories."*
- **Settings:** turn OFF "allow search engines" only if you want privacy; otherwise leave defaults. Make sure email is verified (it is).
- **Join these subs now** (so your home feed surfaces good threads to comment on): r/sysadmin, r/msp, r/Office365, r/PowerShell, r/sysadministrator, r/Intune, r/AZURE, r/us(your)country sysadmin if any.

---

## 2. The 7-day warm-up schedule
Aim for **3–5 helpful comments/day**. Quality > volume. Upvotes will trickle in; that's your karma.

| Day | Action | Target |
|-----|--------|--------|
| 1–2 | Comment only. Answer questions you actually know (M365 licensing, PowerShell, Entra, Intune). No links, no tool mentions. | ~10–20 comment karma |
| 3–4 | Keep commenting. Start a *non-promo* discussion post if you have a genuine question. | ~30–50 karma |
| 5 | Comment in r/msp + r/sysadmin specifically so those subs have your history. | account 5+ days old |
| 6–7 | First **value post** (method writeup) in r/PowerShell or r/Office365 — link in a *comment*, not the post. | first qualified traffic |
| 8+ | r/sysadmin value post, then r/msp via their promo thread. | launch proper |

Don't post the same content to multiple subs same-day (Reddit flags cross-posting spam). Space them 24h+ and reword.

---

## 3. Paste-ready helpful comments (NO links, NO SeatScout)
Use these as starting points — **edit each to fit the actual thread** (generic copy-paste reads as bot). Find threads via the subs above or search "license", "inactive users", "E5", "signInActivity", "offboarding".

**A) Someone asking how to find unused/inactive M365 licenses**
> The read-only way I do it: `Get-MgSubscribedSku` gives you purchased vs consumed per SKU (the gap = unassigned seats you're paying for). Then `Get-MgUser` with `assignedLicenses`, `accountEnabled` and `signInActivity` to catch disabled-but-licensed and never-signed-in accounts. Heads up: `signInActivity` needs Entra ID P1 — without it you can still get disabled/unassigned, just not last-sign-in.

**B) Thread about the July price increase / cutting M365 cost**
> Before anyone buys more seats, worth auditing what's already idle — most tenants I've seen have a chunk of disabled accounts still licensed and a pile of never-signed-in users from offboarding gaps. Reclaiming those at renewal usually offsets a good part of an increase. The unassigned purchased seats are the cleanest win — pure refund, zero risk.

**C) E5 vs E3 debate**
> The honest test is feature usage, not the org chart. Pull who's actually using the E5-only stuff (Defender P2, advanced compliance, Power BI Pro inclusions, etc.). Plenty of E5 seats only ever touch what E3 already covers — that's ~$21/user/mo back. Just validate usage per user before downgrading or you'll get help-desk tickets.

**D) Someone frustrated with the M365 admin center reporting**
> The admin center usage reports are fine for a glance but painful for license cost work. PowerShell + Graph (`Get-MgSubscribedSku`, user `signInActivity`) gets you the raw numbers you can actually pivot on. Export to CSV and you can hand finance real dollars instead of seat counts.

**E) Offboarding / disabled accounts question**
> Disabling the account doesn't stop the license billing — that's the one that bites people. Worth a recurring check for `accountEnabled = false` users that still have `assignedLicenses`. Same for shared mailboxes that quietly got a license attached; they don't need one under 50GB.

**F) PowerShell / Graph beginner asking where to start with reporting**
> `Connect-MgGraph -Scopes "Organization.Read.All","User.Read.All","Directory.Read.All","AuditLog.Read.All"` (all read-only) gets you most license reporting. `Get-MgSubscribedSku` for what you own, `Get-MgUser -All -Property ...` for per-user state. Watch the legacy SKU part numbers — e.g. Business Premium is still `SPB`, Business Standard is `O365_BUSINESS_PREMIUM`. They're not intuitive.

**G) "How do you prove savings to management?"**
> Translate seats into money. "47 inactive users" gets a shrug; "$X/yr recoverable at our per-seat price" gets a meeting. Multiply each reclaimable seat by your *actual* contract price (not list) and lead with the total. Finance moves on dollars, not UPNs.

**H) MSP packaging client work**
> License review is a great low-friction foot-in-the-door for optimization engagements — every tenant has waste and it's an easy "we found you $X" conversation. Keep it read-only so there's no "connect your tenant to a third party" objection; running it in the client's own tenant kills that pushback.

---

## 4. When the account is ready: the value posts
Use the drafts already in `launch-kit.md` (§1 r/sysadmin, §2 r/msp, §5 Tech Community) — they're written value-first with the link in a comment. Reminders:
- **r/sysadmin:** post the method, put the link in your own first comment. Disclose you built it ("Disclosure: I made this, free tier is genuinely free").
- **r/msp:** do NOT post promo to the main feed — use their self-promotion/monthly thread, or you'll get banned. Check the sub's pinned rules first.
- **r/PowerShell:** frame as a script/method share, not a product.
- **r/Office365:** tolerant of tool shares if value-first.

---

## 5. Hard don'ts
- ❌ No links until the account has age + karma and the post is genuinely useful.
- ❌ No copy-paste identical comments — edit every one.
- ❌ No posting the same writeup to 3 subs the same day.
- ❌ No SeatScout logo as avatar / no product name in bio.
- ❌ Don't argue with mods — if a post is removed, message them politely or move on.
- ❌ Don't buy upvotes/karma — instant ban risk.

---

*Reddit is the highest-intent free channel for this product — worth doing patiently. Ping me to reword comments for specific threads, or when the account's warmed up and you want the posts tuned.*
