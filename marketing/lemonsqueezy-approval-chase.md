# Lemon Squeezy — approval chase + go-live checklist

## 1. First: check status yourself (2 min, may need no email)
Log into Lemon Squeezy → look at the top of the dashboard / Settings → Stores:
- A banner like "Your store is under review" / "Activating" = still pending, normal (2–3 business days).
- "Store activated" / test-mode toggle is now switchable to live = **you're approved, skip to section 3.**
- A request for more info (ID, business details, payout) = they're blocked on you; provide it — that's usually the real hold-up.

If it's just "under review" and it's been ≥3 business days, send the message below.

---

## 2. Paste-ready message to Lemon Squeezy support
Send via the in-dashboard chat/help widget, or support@lemonsqueezy.com from your account email.

**Subject:** Store activation status — SeatScout

> Hi team,
>
> I submitted my store "SeatScout" for activation on [DATE you submitted] and completed the identity/KYC steps. Could you let me know where it is in the review queue, and whether anything else is needed from me to finish activation?
>
> I'm ready to go live (products and checkout are configured in test mode) and just need the account approved to switch to live payments. Happy to provide any additional verification.
>
> Thanks,
> Uğur — SeatScout (seatscout.dev)

Fill in [DATE]. Keep it short; support reads hundreds of these.

---

## 3. The moment it's approved — go-live sequence
Lemon Squeezy products built in TEST mode do NOT carry over to live. Steps:

1. Toggle the store **out of Test mode** (top bar).
2. For each product (Lite, Solo $49, Pro $129): open it → **"Copy to Live Mode"** (creates the live version + a NEW checkout URL).
3. Copy the **3 live checkout URLs** (Lite / Solo / Pro).
4. **Send me those 3 URLs.** I'll:
   - replace the "Notify me" mailto buttons + any test URLs in `site/index.html` with the live checkout links,
   - flip the pricing note back to "buy now",
   - redeploy to Cloudflare,
   - swap the Composio Lemon Squeezy test key note so the revenue pulse reads live sales.
5. Do one real test purchase (you can refund yourself) to confirm the flow end to end.

After that the funnel is fully open: traffic → free Lite → paid Solo/Pro with working checkout.

---

## 4. If LS approval drags (backup, don't act yet)
If they reject or it stalls past ~a week, the pre-vetted fallback is **Polar.sh** (merchant-of-record, pays out to Turkey via Stripe Connect Express, ~4% + processing). I can stand up the same 3 products there quickly. Hold this unless LS actually falls through.
