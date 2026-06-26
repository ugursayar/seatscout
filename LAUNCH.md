# SeatScout — Launch Playbook (private, owner only)

> Not for buyers. This is your go-to-market + the manual gates only you can do.
> Everything technical (engine, report, site, copy) is built. The steps below are the human/account parts.

---

## A. Manual gates (do these — ~30–45 min, ~$15 cash)

Ordered. Costs in **bold**.

1. **Buy the domain** — `seatscout.com` was available at time of build (**~$12–15/yr**).
   Register at any registrar (e.g. https://www.godaddy.com/domainsearch/find?domainToCheck=seatscout.com or Cloudflare Registrar, which is at-cost).
   Backups if taken: `skusaver.com`, `idleseat.com`, `tenanttrim.com`.

2. **Create a Lemon Squeezy account** (merchant-of-record; works from Turkey, handles global VAT) — **free**, takes a % per sale (~5% + 50¢).
   - Sign up → create a **Store** "SeatScout".
   - Add **payout**: your bank (IBAN) / Wise. LS pays out internationally.
   - You'll do identity/tax onboarding here — this is the part only you can do.

3. **Create 3 products** in Lemon Squeezy:
   | Product | Price | File to upload |
   |---------|-------|----------------|
   | SeatScout Lite | $0 (free, collects email) | `dist/SeatScout-Lite.zip` |
   | SeatScout Solo | $49 one-time | `dist/SeatScout-Solo.zip` |
   | SeatScout Pro | $129 one-time | `dist/SeatScout-Pro.zip` |
   - Turn on "collect email", enable license keys if you want (optional).
   - Copy each product's **checkout URL**.

4. **Wire the site**: open `site/index.html`, replace the placeholders:
   - `LEMONSQUEEZY_LITE_URL`, `LEMONSQUEEZY_SOLO_URL`, `LEMONSQUEEZY_PRO_URL`
   - `LEMONSQUEEZY_SUPPORT_EMAIL` (use a simple support address)
   (Tell me when accounts exist and I'll do the find-replace + any tweaks.)

5. **Deploy the site** — **free**. Cloudflare Pages or Vercel: drag the `site/` folder (and `sample/`) or connect a GitHub repo. Point `seatscout.com` DNS at it. (I can write the exact steps / a deploy config when you're ready.)

6. **One real-tenant test** (the validation gate): run
   `.\SeatScout-Audit.ps1 -InactiveDays 30`
   against your own or a free **Microsoft 365 Developer tenant** (free, https://developer.microsoft.com/microsoft-365/dev-program). Send me the console output (redact names) so I confirm live Graph fields match the parser. This is the only thing I couldn't run in my sandbox (no PowerShell/Graph there).

That's the whole cash outlay to first sale: **the domain (~$15).** Everything else is free tiers. ~$985 of the $1,000 stays untouched.

---

## B. Distribution — the first 30 days

No ads needed. This is a B2B tool with a clear pain; you win with **helpful presence where M365 admins already are**, using the free Lite as the hook.

**The loop:** free Lite → email captured → report shows their waste → upsell Solo/Pro.

### Channels (highest signal first)
- **Reddit**: r/sysadmin, r/Office365, r/msp, r/sysadministrator. Don't spam — post a genuinely useful breakdown ("How we found 21% license waste in a 100-seat M365 tenant — method + free script") and mention the free Lite at the end. MSP subreddit is gold for the Pro tier.
- **Microsoft Tech Community** (techcommunity.microsoft.com) — M365 / Entra forums. Answer license-cost questions, link the free tool.
- **PowerShell.org / r/PowerShell** — share the approach (devs respect read-only, no-data-leaves tooling).
- **LinkedIn** — you have a profile + dev network. Post the July-2026 price-hike angle + the sample report image. Tag #Microsoft365 #MSP #ITPro.
- **Spiceworks Community** — SMB IT admins, very on-target.
- **dev.to / Hashnode** — a technical write-up of the Graph queries (SEO + credibility), CTA to the tool.

### Content to ship (I can draft all of these)
1. Launch post: "Microsoft 365 just got up to 33% more expensive. Here's how to claw some back." (the price-hike timing is your wedge — use it now).
2. The sample report as an image for social.
3. A short Loom/GIF of running the script → report (you record once; I'll script it).
4. SEO landing copy for keywords: *microsoft 365 license optimization tool, find unused office 365 licenses, m365 license audit script, reduce microsoft 365 costs*.

### SEO note
The site is static and fast (good). Add a short blog later targeting the keywords above — that's the durable, free traffic channel. AdminDroid/CoreView rank for these; you compete on "cheap, self-run, nothing leaves your tenant, instant $ report."

---

## C. Pricing rationale

- **Free Lite** kills the "there are free scripts" objection *and* builds your email list (the real asset).
- **$49 Solo** = impulse range for an admin; one reclaimed E3 seat ($39/mo) pays for it in ~6 weeks.
- **$129 Pro** captures consultants/MSPs, who use it across many tenants and bill clients off the report. This is where the margin is — push Pro in MSP channels.

Don't discount early. If anything, the Pro tier is underpriced for the value (a consultant bills more than $129 for one audit) — raise it later once you have a testimonial or two.

---

## D. Honest targets (no hype)

Most digital products make <$1k/mo; outcome depends on distribution, which is the work. A realistic, conservative arc:
- **Weeks 1–4:** ship, post in 3–4 channels, collect first Lite emails, land first 1–5 paid sales.
- **Months 2–3:** a small content trail + word of mouth → low hundreds/mo is a credible base case; a single MSP buying Pro moves the needle.
- **Months 4–12:** compounding SEO + a second product (e.g. the AppSource graduation, or a Teams/SharePoint storage-cost auditor reusing this engine).

Even a slow result (a few hundred $/mo) beats the ~$50–120/yr the $1,000 would earn invested — by 10–100x — at almost zero capital risk. That's the conservative thesis holding.

---

## E. Roadmap (after first revenue)
1. **Graduate to Microsoft AppSource** as a transactable offer (3% fee, B2B discovery) — higher trust, recurring potential.
2. **Sibling tools, same engine:** SharePoint/OneDrive storage-cost auditor, Teams/phone license auditor, shared-mailbox-vs-licensed checker. Each is a new SKU to the same buyers.
3. **Scheduled monitoring** version (recurring revenue) once you're ready to host (only when worth the added data-handling responsibility).

---

_Ping me at any step — I'll do the find-replace, write the launch posts, record-script the demo, and prep the AppSource listing when you're there._
