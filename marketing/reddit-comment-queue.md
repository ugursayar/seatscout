# Reddit Comment Queue — SeatScout warm-up

> Account: u/Inevitable_Market293. Paste from your OWN browser. Space them ~3-5/day. Edit each lightly so it fits the live thread (don't paste verbatim). NO links, NO SeatScout mention during warm-up.
> Tick the box once posted.

---

## Fresh — do these first

- [ ] **1. r/sysadmin — "Gentle reminder: M365 license prices increase in July. Audit your licenses"** (Jun 16, 25c)
  https://www.reddit.com/r/sysadmin/comments/1u7daez/gentle_reminder_microsoft_365_license_prices/

  > Good nudge. The cleanest pre-renewal win is the gap between purchased and assigned seats — `Get-MgSubscribedSku` shows prepaid vs consumed, and the difference is pure refund at renewal. After that, disabled-but-still-licensed accounts and never-signed-in users from offboarding gaps. Pricing each one out in actual dollars is what gets finance to act before the increase lands.

- [ ] **2. r/msp — "Am I reading the M365 Copilot licensing correctly?"** (Jun 15, 14c)
  https://www.reddit.com/r/msp/comments/1u6rj37/am_i_reading_the_m365_copilot_licensing_correctly/

  > The part that trips most people up is that Copilot value is entirely usage-dependent — same problem as justifying E5 over E3. Before selling the seat, look at whether the user actually lives in the apps Copilot rides on. Easiest client conversation is to pull real activity first, then map seats to who'd actually use it, rather than blanket-licensing.

- [ ] **3. r/sysadmin — "June 2026 Microsoft 365 Changes Admins Should Know"** (Jun 2, 26c)
  https://www.reddit.com/r/sysadmin/comments/1tunhuh/june_2026_microsoft_365_changes_admins_should_know/

  > Solid roundup. With the price changes, worth pairing this with a quick license-waste pass — disabled accounts still carrying licenses and shared mailboxes that quietly got a paid license are the usual suspects. `signInActivity` (needs Entra ID P1) catches the never/inactive users too.

- [ ] **4. r/Office365 — "How does one become eligible to purchase an Office 365 F3 license?"** (Jun 9, 21c)
  https://www.reddit.com/r/Office365/comments/1u1gmd6/how_does_one_become_eligible_to_purchase_an/

  > F3 is meant for frontline/kiosk workers and there's a seat cap relative to your other licensing, which is usually what blocks the purchase. Worth confirming whether F3 actually covers what those users need (50GB mailbox, web/mobile apps only, no desktop Office) before committing — it's easy to under-license and generate help-desk tickets.

---

## Evergreen — perfect topical fit, still get traffic

- [ ] **5. r/sysadmin — "How are you tracking 'Zombie' SaaS seats?"** (Mar, 27c)
  https://www.reddit.com/r/sysadmin/comments/1rw2nnd/how_are_you_guys_tracking_zombie_saas_seats/

  > For M365 specifically: `Get-MgSubscribedSku` for purchased-vs-consumed, then `Get-MgUser` with `accountEnabled` + `signInActivity` to catch the zombies — disabled-but-licensed and no-sign-in-in-N-days. Export to CSV and you've got a repeatable monthly sweep instead of a one-off.

- [ ] **6. r/sysadmin — "Moved from MSP to internal IT, now I see how much MSPs let clients waste on M365"** (Mar, 23c)
  https://www.reddit.com/r/sysadmin/comments/1s8r4dc/moved_from_msp_to_internal_it_now_i_see_how_much/

  > Really common. The waste is almost always the same buckets: unassigned prepaid seats, disabled users still licensed, and E5 seats that never needed more than E3. None of it shows up unless someone actually reconciles purchased vs used per SKU — which is exactly the step that gets skipped.

---

## Daily refill
The scheduled task **"reddit-warmup-feed" (8:07am daily)** drops a fresh batch like this each morning. Click **Run now** once to pre-approve the Reddit tool.

## After ~5-7 days (account aged + karma banked)
Switch to the value posts in `launch-kit.md` (§1 r/sysadmin, §2 r/msp via their promo thread, §5 Tech Community) — link in a comment, with disclosure. See `reddit-warmup-kit.md` for the full playbook.
