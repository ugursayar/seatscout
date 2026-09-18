# Polar.sh fallback kit — ready to execute (prepared 2026-07-02)

> **Trigger gate:** Execute only if Lemon Squeezy is still silent/unapproved by **Mon Jul 6** (≈6 business days) or rejects the store. Until then, do nothing here.
> If LS approves first: ignore this file, follow `marketing/lemonsqueezy-approval-chase.md` §3.

---

## 0. What changed since the original fallback note (verified 2026-07-02)

- **Fee advantage is gone.** Polar restructured pricing May 27, 2026. New orgs start on **Starter: 5% + 50¢ per transaction** — effectively the same as Lemon Squeezy. Add **+1.5% for international (non-US) cards** — most of our buyers. Old 4% + 40¢ rate is closed to new orgs. ([fees](https://polar.sh/docs/merchant-of-record/fees))
- **The real advantage now: no pre-sale activation gate.** Polar lets you **sell immediately**; account review (KYC survey + passport/selfie, up to 14 days) happens **before first payout**, not before selling. Funnel opens day 1; cash waits in balance until review clears. ([account reviews](https://polar.sh/docs/merchant-of-record/account-reviews))
- **Turkey confirmed supported** for payouts via Stripe Connect Express (payouts product, not Stripe Payments — works even though Stripe standalone isn't in Turkey). ([supported countries](https://polar.sh/docs/merchant-of-record/supported-countries))
- Other fees: **$15/chargeback**; payouts cost (Stripe, no Polar markup) $2/month of active payout + 0.25% + $0.25 + ~1% cross-border conversion outside EU. Manual withdrawals supported — batch payouts monthly to cut fixed fees.

**Net:** Polar ≈ LS on cost. Choose it for speed-to-selling, not margin.

## 1. Uğur-only steps (~30–40 min)

1. **Sign up** at polar.sh (use the LS-registered email for consistency) → create org **SeatScout**.
2. **Check individual business type for Turkey** (2 min, before anything else): Stripe [verification matrix](https://docs.stripe.com/connect/required-verification-information) → Platform Country `US`, Dashboard `express`, Service Agreement `recipient`, Capability `transfers`, Account Country `Turkey` → confirm `individual` is offered. If not, it's company-only — stop and we reassess.
3. **Connect payout**: Dashboard → Finance → Account → Stripe Connect Express onboarding (IBAN/bank).
4. **Create 3 products** (Products → New → one-time purchase):

   | Product | Price | Benefit: File Download | Description (paste) |
   |---|---|---|---|
   | SeatScout Lite | Free | `dist/SeatScout-Lite.zip` | Free Microsoft 365 license audit — finds unused paid seats in your tenant and shows the reclaim summary. Read-only, runs locally, nothing leaves your tenant. |
   | SeatScout Solo | $49 | `dist/SeatScout-Solo.zip` | The full audit: every finding, dollar-quantified HTML report + CSVs, remediation checklist. One tenant. Buy once, own it — a single reclaimed E3 seat pays for it in under two months. |
   | SeatScout Pro | $129 | `dist/SeatScout-Pro.zip` | Everything in Solo, white-label reports with your own brand, licensed for unlimited client tenants. Built for consultants and MSPs. |

   Checkout collects the customer email automatically (incl. the free Lite — that's our list).
5. **Create 3 checkout links** (Products → product → Checkout Link) → **send me all 3 URLs**.
6. Per Polar's own guidance, complete setup **before** their review email arrives ("build first, submit second" — a complete store + live site = faster review). Reply to their 24-h survey email promptly; have passport ready for KYC.

## 2. My steps (same day you send the URLs)

1. `site/index.html` swap map:
   - L175 Solo `mailto:hello@…Notify me` → Polar Solo checkout URL, label "Get Solo — $49"
   - L187 Pro `mailto:hello@…Notify me` → Polar Pro checkout URL, label "Get Pro — $129"
   - L92/161/210 Lite direct `/download/SeatScout-Lite.zip` → Polar Lite checkout URL (switches Lite from anonymous download to email-captured download)
   - L148 copy: drop "paid tiers launch shortly (tap Notify me…)" → buy-now wording
2. You run `npx wrangler deploy` from `SeatScout/` (or I prep the exact command + diff for review first).
3. Rewire `seatscout-weekly-pulse` scheduled task from Lemon Squeezy to the Polar API (org access token you create under Settings → API).
4. Smoke test list (same as Gate 4 in RELEASE-CHECKLIST, LS URLs → Polar URLs).

## 3. If LS approves after we've gone live on Polar

Don't run both checkouts for the same SKU. Either stay on Polar (working funnel wins) or do one clean cutover back — decide then based on which is live and converting. No prep needed now.

---
Sources: [Polar fees](https://polar.sh/docs/merchant-of-record/fees) · [supported countries](https://polar.sh/docs/merchant-of-record/supported-countries) · [account reviews](https://polar.sh/docs/merchant-of-record/account-reviews) · verified 2026-07-02.
