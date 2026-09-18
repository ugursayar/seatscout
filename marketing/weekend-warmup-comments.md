# Weekend warm-up comments — paste-ready (Jul 3–5)

> From the 2026-07-03 digest. **Zero product mentions** — this is pure warm-up per the kit rule (account must be day 7+ before anything names SeatScout). Post from **u/Inevitable_Market293**. Tweak a phrase or two so they read as yours; don't post two comments within the same hour.
>
> All dollar figures verified 2026-07-03: E3 $39/E5 $60 (post-July-1 rates), Copilot add-on $30/user/mo, Copilot Studio $200/mo per 25k credits or $0.01/credit PAYG.

---

## Friday Jul 3 — two comments

### 1. r/sysadmin — "July 2026 Microsoft 365 Changes Admins Should Know" ⭐ post this one first (hot thread, 335 score, ages fast)
https://www.reddit.com/r/sysadmin/comments/1uki6j3/july_2026_microsoft_365_changes_admins_should_know/

```
One thing I'd add to the price-increase item: before your renewal lands on the new rates, it's worth an hour to reconcile what you're actually using. Get-MgSubscribedSku gives purchased vs consumed per SKU — the delta is seats you're paying for that nobody holds. Then sweep for disabled-but-still-licensed accounts (accountEnabled eq false, with assignedLicenses) and anyone with no sign-in in 90+ days via signInActivity.

Two gotchas: signInActivity needs Entra P1, and on tenants without it the property 403s the whole user query — you have to retry without it. And free/self-service SKUs report an absurd "unlimited" prepaid count you need to exclude before summing.

Every seat you drop before renewal is $39/mo at the new E3 rate. First-time audits on older tenants tend to turn up double-digit waste percentages.
```

### 2. r/sysadmin — "Best practice for deleting old disabled Microsoft 365 accounts without losing data in 2026?"
https://www.reddit.com/r/sysadmin/comments/1u9cwy6/best_practice_for_deleting_old_disabled_microsoft/

```
One angle the thread is skipping: disabled ≠ unlicensed. Every disabled account still holding E3/E5 keeps billing every month — $39/seat at the new E3 rate. On inherited tenants that pile is usually bigger than anyone expects.

Sequence that's worked for me: convert the mailbox to shared (free under 50 GB, keeps the data accessible), move OneDrive content to a SharePoint library or archive, then strip the license the same day — not "later", later never comes. Finish with a tenant-wide Graph query for accountEnabled eq false + assignedLicenses to catch the ones already leaking.

One real exception before you strip: a shared mailbox under litigation/retention hold still needs a license (EXO Plan 2 or the archiving add-on). Check holds first or legal will find you.
```

---

## Saturday Jul 4 — two comments

### 3. r/sysadmin — "365 Group Based Licenisng"
https://www.reddit.com/r/sysadmin/comments/1ujy819/365_group_based_licenisng/

```
Group-based licensing fails silently when the SKU pool runs dry, and it does NOT retry on its own once seats free up — that bites everyone once.

Check Get-MgSubscribedSku and compare prepaidUnits.enabled vs consumedUnits for the SKU. Then Entra admin center > Groups > your group > Licenses shows the per-group error state. The fix is "Reprocess" on the group (or the reprocessLicenseAssignment Graph action if you're scripting it).

One more trap since you're assigning via dynamic groups: if the group assigns multiple SKUs (say E3 plus an add-on) and any one pool is short, the whole assignment fails for that user — not just the missing SKU.
```

### 4. r/Office365 — "Copilot license"
https://www.reddit.com/r/Office365/comments/1ul3slj/copilot_license/

```
The distinction that decides your cost: the M365 Copilot add-on ($30/user/mo) licenses a person; Copilot Studio licenses the workload. For a SharePoint FAQ-style agent, the build/configure side needs the seat — viewers' usage can instead draw from Copilot Studio capacity.

On the Studio side: $200/mo per 25k-credit pack, or a pay-as-you-go meter at $0.01/credit through an Azure subscription. For a single-widget trial the PAYG meter is the low-commitment path — no upfront license, you just pay for what the agent consumes.

If you go the per-seat route instead, mind NCE terms: an annual commit can't be reduced mid-term. A monthly-term seat costs a bit more but keeps the exit open while you evaluate.
```

---

## Sunday Jul 5 — one comment

### 5. r/msp — "Upgrading yearly commitment Business Standard to Premium possible? (Non profit)"
https://www.reddit.com/r/msp/comments/1uf01er/upgrading_yearly_commitment_business_standard_to/

```
The asymmetry to know: NCE allows a mid-term upgrade (Business Standard → Premium) with prorated credit through your CSP, but downgrades only happen at anniversary. So "commit Standard now, upgrade later if needed" is the safe direction — the reverse would lock you in.

Sizing tip before the annual commit, especially for a nonprofit: count actually-active users (last sign-in), not the roster. Volunteer and alumni accounts that haven't signed in for months are common, and an annual NCE commit means paying for those seats until renewal whether anyone returns or not.
```

---

## After posting
- Log each in `reddit-posted-log.md` (subreddit | thread | permalink) so the auto-task never double-comments a thread.
- Reply to any responses — replies earn more karma than the comment itself.
- Monday: LinkedIn ~16:00 TR, X thread in the US afternoon (`launch-posts-final.md` §3–4).
