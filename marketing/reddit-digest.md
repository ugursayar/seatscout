# Reddit reply digest (SeatScout warm-up)

> Daily read-only digest of fresh M365 licensing/cost threads worth a personal reply from Uğur's own named Reddit account. Newest section on top. Any product mention must carry a plain disclosure ("disclosure: I built a tool for this").

## 2026-09-17

Searched r/sysadmin, r/Office365, r/msp, r/microsoft365, r/PowerShell, r/Intune, r/entra — sort new, month filter, 6 scoped queries (the Composio tool has no `subreddits` parameter, so queries use the `subreddit:` search operator), ~145 posts scanned, 52 passed the keyword filter, deduped against both logs. Three picks. Thin day: most of the license-cost surface in this window was already logged 09-15/09-16.

**Pricing note:** no dollar figures below. Pull list prices the day you post.

Skipped: t3_1wcvav1 (r/msp, CSP indirect-reseller $1k TTM requirement, 25 comments — reseller program economics, not seat waste; already well answered), t3_1wddfsb (r/PowerShell multi-tenant Partner Center script — passed over on 09-16 for the same reason, it's a Security Defaults/MFA-inventory question with licensing only as a filter; leaving it skipped for consistency), t3_1w9sjk9 (tenant blocked / MCA billing review — billing drama, not seat spend), t3_1wcdi8m (auto-expanding archive limit — storage, not licence), t3_1wgn79z's sibling storage/Copilot threads (no cost hook).

---

### 1. r/PowerShell — "Script to find unused M365 licenses - feedback on the usage-report approach?" *(top pick)*

- **Age / activity:** 2 days old (2026-09-14), 3 comments — unlocked, not archived, OP actively iterating (already shipped 1.2.1 mid-thread)
- **Link:** https://www.reddit.com/r/PowerShell/comments/1wgn79z/script_to_find_unused_m365_licenses_feedback_on/
- **Why it fits:** This is literally SeatScout's core algorithm, published as an open-source PowerShell module, with the author explicitly asking "is my approach right?" He already hit the two traps you know cold — `signInActivity` needing Entra ID P1, and the usage-report name-obfuscation setting. Highest-value thread on the board: an author who wants critique, three comments deep, and you can out-detail everyone.
- **Reply angle:** u/robofski already caught the interactive-vs-non-interactive sign-in gap and OP fixed it, so skip that. Give him the three failure modes still in the script: (a) `getOffice365ActiveUserDetail` only covers Exchange/SharePoint/OneDrive/Teams/Yammer — a user living in Power BI, Project, or Visio looks dormant on the fallback path, so the non-P1 branch needs a "services covered" caveat in the output, not just a date; (b) `ConsumedUnits` from `Get-MgSubscribedSku` is the only honest denominator — a per-user scan misses licences assigned to groups with no members and misses *purchased-but-unassigned* seats entirely, which on most tenants is the bigger number than the dormant-user pile, so `PrepaidUnits.Enabled - ConsumedUnits` deserves its own line in the report; (c) disabled-but-licensed accounts should be a separate bucket from "no activity in 90 days" because the remediation differs — one is safe to strip today, the other needs a manager conversation. Also worth flagging that group-based licensing means you cannot just call `Set-MgUserLicense` on the results; you have to pull them out of the assigning group or the licence comes straight back.
- **Disclosure:** you're commenting on a competing free tool, so disclose up front if you say anything product-adjacent — "disclosure: I build a commercial tool in this space, so take the critique with that in mind." That framing actually makes the feedback land better.

---

### 2. r/entra — "Entra ID Conditional Access showing 'Licensing overage' — how to identify the cause?"

- **Age / activity:** 2 days old (2026-09-15), 8 comments, 16 points — unlocked, not archived
- **Link:** https://www.reddit.com/r/entra/comments/1wh80u9/entra_id_conditional_access_showing_licensing/
- **Why it fits:** Same purchased-vs-consumed reconciliation as always, measured against CA evaluation rather than assignment. **Note:** this is the same OP and same body text as t3_1whk6zz (r/Intune), which was yesterday's top pick — it's a crosspost. This copy has the real traction (16 points vs 2), so if you only answer one, answer this one.
- **Reply angle:** u/Mizetings already nailed the core mechanic (one P2 licence activates P2 tenant-wide; unscoped policies put you out of compliance) and u/JasonNotBorn dropped a LazyAdmin article, so don't restate either. Add the reconciliation nobody gave: `Get-MgSubscribedSku | Where SkuPartNumber -match 'AAD_PREMIUM' | Select SkuPartNumber, @{n='Purchased';e={$_.PrepaidUnits.Enabled}}, ConsumedUnits`, then diff that against the distinct users appearing in CA-evaluated sign-in logs — the delta is his overage, name by name. The practical fix is almost always exclusion groups rather than a purchase order, because break-glass accounts, unlicensed guests, and disabled-but-not-yet-deleted users all count toward the evaluated total. Close u/Shock720's open question honestly: nothing breaks and no policy stops enforcing — it's a compliance/true-up exposure, not an outage, which is exactly why it sits ignored for months and then costs real money at renewal.
- **Disclosure:** not needed unless he asks how you'd automate the diff. If you mention the product, add "disclosure: I built a tool for this".

---

### 3. r/entra — "Entra ID geo-restriction — do I need P2 for all users?"

- **Age / activity:** 2 days old (2026-09-15), 20 comments — unlocked, not archived, busy but not saturated on the licensing angle
- **Link:** https://www.reddit.com/r/entra/comments/1wh3ojq/entra_id_georestriction_do_i_need_p2_for_all_users/
- **Why it fits:** 500 users about to be over-licensed on a wrong assumption. OP explicitly asks for "the most cost-effective approach" — that's the SeatScout question in plain language, and the thread has drifted almost entirely into security-architecture debate.
- **Reply angle:** The "P1 is enough, P2 is only for risk-based policies" answer is well covered — u/CloudKnox3010 and u/tfrederick74656 both got there. Take the cost thread the others dropped: at 500 users the real question is what he *already owns*, because Business Premium and M365 E3 both bundle Entra ID P1 and E5 bundles P2, so a large share of those 500 may need zero incremental spend. Point him at `Get-MgSubscribedSku | Select SkuPartNumber, @{n='Purchased';e={$_.PrepaidUnits.Enabled}}, ConsumedUnits` to see the actual entitlement picture in one shot, and warn him about the trap that produces the overage banner in thread #2 above: if any single user in the tenant holds P2, the P2 features light up tenant-wide and an unscoped CA policy silently puts him out of compliance. Mixed-SKU tenants should scope CA policies to a licensed security group from day one.
- **Disclosure:** not needed for this reply. Add the plain disclosure only if you reference the product.

---

## 2026-09-16

Searched r/sysadmin, r/Office365, r/msp, r/microsoft365, r/PowerShell, r/Intune, sort new, week+month filters, 8 scoped queries, ~131 unique posts scanned. Most of the license-cost traffic from this window was already logged on 09-15, so the genuinely new surface is thin. Four picks, one of them (#1) posted today and still effectively uncontested on the part that matters.

**Pricing note:** no dollar figures below. Pull list prices the day you post.

Skipped: t3_1w9sjk9 (M365 tenant blocked via MCA billing review, 61 comments — billing drama, not seat waste), t3_1waw72i (license propagation delay — already correctly answered with "24 hours"), t3_1wddfsb (multi-tenant Graph script, 11 comments — it's a Security Defaults question, licensing only incidentally), t3_1wg77tt (Office 2016 VL activation break from KB5002914 — perpetual-licence bug, not M365 cost), t3_1whqadh / t3_1whnlsn (E5 *developer* tenant + nonprofit grant issues — not real-org seat spend), t3_1wfxwiu (PowerShell script-estate management, 53 comments — good thread, zero licensing hook).

---

### 1. r/Intune — "Entra ID Conditional Access showing 'Licensing overage' — how to identify the cause?" *(top pick)*

- **Age / activity:** posted today (2026-09-16), 4 comments, 2 points — unlocked, not archived, still early
- **Link:** https://www.reddit.com/r/Intune/comments/1whk6zz/entra_id_conditional_access_showing_licensing/
- **Why it fits:** This is the purest form of the SeatScout problem — the org is *consuming* more P1/P2 entitlement than it *purchased*, and OP has no idea which users are driving it. Same purchased-vs-consumed reconciliation, just measured against CA evaluation instead of assignment.
- **Reply angle:** Two commenters already correctly pointed at Entra admin center → Billing → Licenses, so don't repeat that. Add the part nobody covered: the "Conditional Access users" metric counts *every unique user who had a policy evaluated*, which means break-glass accounts, unlicensed guests, and disabled-but-not-yet-removed accounts all inflate it — so the fix is usually exclusion groups, not a purchase order. Give him the actual reconciliation: `Get-MgSubscribedSku | Select SkuPartNumber, @{n='Purchased';e={$_.PrepaidUnits.Enabled}}, ConsumedUnits` for the AAD_PREMIUM / AAD_PREMIUM_P2 SKUs, then pull the CA-evaluated user list from sign-in logs and diff the two — the delta is his overage, name by name. Note that the License Usage report lags ~a few days, so a scoping fix won't clear the banner immediately.
- **Disclosure:** not needed unless he asks how you'd automate the diff. If you mention the product, add "disclosure: I built a tool for this".

---

### 2. r/Office365 — "O365 Mailbox Access Issue"

- **Age / activity:** 3 days old, 13 comments, score 0 — unlocked, not archived
- **Link:** https://www.reddit.com/r/Office365/comments/1wezhdy/o365_mailbox_access_issue/
- **Why it fits:** OP is paying for *licensed* mailboxes that several staff share via username/password, and is fighting MFA prompts and Full Access/auto-mapping as a result. That's textbook avoidable seat spend — shared mailboxes are free up to 50 GB and need no licence at all.
- **Reply angle:** One commenter said "why not just use a shared mailbox" and stopped there; take it the rest of the way. Walk him through `Set-Mailbox -Identity x -Type Shared`, confirm the mailbox is under 50 GB first (over that, or with litigation hold / in-place archive, it still needs an Exchange Online Plan licence), then strip the licence and watch it come back to the pool. Worth adding that shared-account passwords also break his MFA story, so the conversion fixes the security problem and the billing problem in one move — and that the two users still erroring are almost certainly an Outlook profile cache issue, fixed by a fresh profile after the conversion.
- **Disclosure:** not needed. Pure advice; don't force a product mention here.

---

### 3. r/sysadmin — "M365 Hybrid Exchange mailbox remote move to M365 still capped at 50GB"

- **Age / activity:** 1 day old, 7 comments, 2 points — unlocked, not archived, OP actively replying
- **Link:** https://www.reddit.com/r/sysadmin/comments/1wh2024/m365_hybrid_exchange_mailbox_remote_move_to_m365/
- **Why it fits:** Add-on SKU provisioned but not actually consumed by the target object — the same "you bought it, it isn't being used" gap SeatScout exists to surface, here in add-on form.
- **Reply angle:** The `Exchange_Storage_50GB` add-on applies to the *cloud* mailbox object; on a remote move the target quota is stamped from the MoveRequest, so provisioning it after the move starts changes nothing. Tell him to check `Get-MoveRequestStatistics` / the move report for the target quota it actually picked up, and to verify with `Get-Mailbox | fl ProhibitSendReceiveQuota` after the move rather than trusting the portal checkbox. On his E3-then-downgrade plan: flag the real risk, which is that a mailbox above 50 GB that lands back on Business Standard can stop sending and receiving — and that a temporary Exchange Online Plan 2 seat is far cheaper than an E3 for a one-off migration.
- **Disclosure:** not needed.

---

### 4. r/Office365 — "Microsoft Places - desk licensing" *(low traffic — only worth it if you have spare time)*

- **Age / activity:** 6 days old, 2 comments, 1 point — unlocked, not archived, but quiet
- **Link:** https://www.reddit.com/r/Office365/comments/1wcje8j/microsoft_places_desk_licensing/
- **Why it fits:** He is sitting on *unallocated* "Teams Shared Space — Single Spaces" licences he is already paying for while the desks they were bought for are unbookable. Purchased ≠ consumed, in a SKU almost nobody audits.
- **Reply angle:** Both existing commenters are on the right track — the licence attaches to the desk's underlying resource mailbox user object, not to anything in the Places admin console. Give him the concrete path: find the desk objects with `Get-Place -Type Desk` / `Get-Mailbox -RecipientTypeDetails EquipmentMailbox`, confirm each has a backing user object, assign the Shared Space SKU there, then re-check `Get-MgSubscribedSku` to confirm ConsumedUnits actually moved. Worth noting the post-1-April rule that desks created before the licensing change behave differently from ones created after — and that unassigned seats keep billing regardless.
- **Disclosure:** if you mention that unassigned-but-billed SKUs are exactly what you built a tool to catch, say "disclosure: I built a tool for this".

---

## 2026-09-15

Searched r/sysadmin, r/Office365, r/msp, r/microsoft365, r/PowerShell, r/Intune, sort new, week+month filters, 12 scoped queries, ~120 posts scanned, ~55 of them unseen and ≤10 days old. Three picks. One of them (#1) is the best warm-up target surfaced in weeks: high traffic, directly on the offboarding→billing seam, and the entire comment section has missed the money angle.

Note on the seen-log gap: the last run was 09-11, so this pass covers a four-day window rather than one day.

Skipped: t3_1w9sjk9 (tenant blocked by MCA billing review, 61 comments — dramatic but resolved per OP's edit, and it's fraud-flagging not seat waste), t3_1w7vgpj (OneDrive 1TB→10GB — turned out to be a *Developer*-tenant enforcement, not a real-org licensing issue; already explained in-thread), t3_1waw72i (license propagation delay, 3 comments, score 0 — correctly answered with "24 hours", nothing to add), t3_1wckmk6 (KMS→A5 Education subscription activation — Windows activation, not seat cost, and already well answered), t3_1wcje8j (Microsoft Places desk licensing, 1 comment — still too quiet), t3_1waj162 (dupe of the already-logged t3_1waj7ya).

**Pricing note:** no dollar figures below. Pull list prices the day you post.

---

### 1. r/sysadmin — "What do you check before disabling a Microsoft 365 user?" *(top pick)*

- **Age / activity:** 4 days old, 178 comments, 123 points — unlocked, not archived, still getting replies
- **Link:** https://www.reddit.com/r/sysadmin/comments/1wdv0cn/what_do_you_check_before_disabling_a_microsoft/
- **Context:** OP asks what gets checked beyond the obvious (email, OneDrive, groups, licences) — Power Apps, Flows, connections, SharePoint ownership — and whether anyone has an offboarding process that catches everything. The thread went straight to jokes: top comment (298 pts) is *"I check the box that says 'user disabled' and that's about it"*, second is *"Nothing. Not our problem."* One good serious answer walks through the hybrid AD→EXO sequence and does end with "finally remove license."
- **Why it fits:** This is the exact seam SeatScout sits on. Out of 178 comments the *billing* consequence of a disabled account has essentially not been raised — and blocking sign-in does nothing to the invoice.

**Reply angle:** The one thing missing from a thread full of "just disable it": blocking sign-in and disabling the account does **not** release the licence. The SKU stays assigned, keeps counting against `consumedUnits`, and keeps billing until someone explicitly unassigns it — so a tenant that has been disabling-and-forgetting for two years is paying for every one of those people. Concrete check anyone can run in two minutes: `Get-MgSubscribedSku | Select SkuPartNumber, @{n='Purchased';e={$_.PrepaidUnits.Enabled}}, ConsumedUnits` to see purchased-vs-assigned, then cross-reference `Get-MgUser -All -Property DisplayName,AccountEnabled,AssignedLicenses` filtered to `AccountEnabled -eq $false` — that intersection is pure waste. Second half, which answers OP's actual question about dependencies: convert to a shared mailbox and you can drop the licence entirely (under the shared-mailbox size cap, and provided there's no archive or litigation hold, which both still need one), but do the Power Automate / Power Apps / SharePoint ownership reassignment *before* the account is deleted, because flow ownership can't be transferred once the owner object is gone — that is the real reason to keep the account around, not the licence. If he mentions the tool: *disclosure: I built a tool for this.*

---

### 2. r/sysadmin — "Reverting Win11 Enterprise to Pro for AppLocker (GPO) — How do you handle physical PCs, VMs, and M365 licensing groups?"

- **Age / activity:** 4 days old, 16 comments, 9 points — unlocked, technical crowd, OP engaged
- **Link:** https://www.reddit.com/r/sysadmin/comments/1wdn0ol/reverting_win11_enterprise_to_pro_for_applocker/
- **Context:** A previous admin put the fleet on Windows Enterprise E3 purely to enforce AppLocker via GPO, using group-based licensing plus a pushed key (`slmgr /ipk` + `/ato`). Since KB5024351 removed the edition check for AppLocker, OP wants to drop the E3 subscriptions, revert to Pro, and "save a few grand." Existing answers are good on the *technical* revert — unassign the licence and subscription-activated devices step down, but a `/ipk`-pushed key puts the machine on a KMS/MAK channel where unassigning does nothing.
- **Why it fits:** Everyone in the thread is answering the OS question. Nobody has answered the question OP actually cares about — *does the bill go down?* — and the answer is "not automatically," which is SeatScout's whole thesis.

**Reply angle:** Agree with the `slmgr /dli` advice and add the part that decides whether he actually saves the money: unassigning the E3 group frees the *assignment*, not the *seat*. `Get-MgSubscribedSku` will show `ConsumedUnits` drop while `PrepaidUnits.Enabled` stays exactly where it was — he keeps paying for every one of those seats until he reduces the subscription quantity in the admin centre or through his CSP. Second point, worth flagging before he plans the project: on an annual NCE term seat count can go up mid-term but reductions generally only take effect at the renewal date, so the calendar matters more than the technical work — he should check his term end date first and sequence the AppLocker migration to land before it, otherwise the "few grand" waits a full year. Also worth asking what else the E3 was covering (Credential Guard, Universal Print, Autopatch) so the saving is measured net, not gross. If he mentions the tool: *disclosure: I built a tool for this.*

---

### 3. r/microsoft365 — "GoDaddy lies"

- **Age / activity:** 1 day old, 5 comments, 0 points — unlocked, fresh, low competition
- **Link:** https://www.reddit.com/r/microsoft365/comments/1wg0ug0/godaddy_lies/
- **Context:** OP discovered GoDaddy sells a "Business Professional" plan that reads like Business Premium but is built on Business Standard, with a federated UI that hides the admin centre so you can't see what you actually own. Top reply (3 pts) pushes back — these are GoDaddy-exclusive SKUs from Microsoft, "you made an incorrect assumption" — so there's an open disagreement and room for a neutral, factual answer.
- **Why it fits:** "You cannot see what you are actually paying for" is the lighter, consumer-facing version of the same visibility problem. Low-competition thread, and a genuinely useful answer costs three lines.

**Reply angle:** Stay out of the is-it-lying argument and give people the check instead: once defederated, `Connect-MgGraph -Scopes Organization.Read.All` then `Get-MgSubscribedSku | Select SkuPartNumber, ServicePlans` prints the real SKU part numbers and every service plan inside them, which settles what you own without trusting any reseller's marketing name. The practical distinction for anyone reading the thread and wondering if it matters: the Premium-tier security and device-management service plans (Entra ID P1, Intune, Defender for Business, conditional access) are the difference, and if they aren't in that `ServicePlans` list you don't have them regardless of what the plan is called — which also means any conditional-access policy you were counting on isn't licensed. Worth adding that the same command is how you verify *any* CSP or reseller invoice against reality, not just GoDaddy. If he mentions the tool: *disclosure: I built a tool for this.*

---

## 2026-09-11

Searched r/sysadmin, r/Office365, r/msp, r/PowerShell, r/Intune (+ r/microsoft365, r/entra), sort new, week+month filters, 8 scoped queries, ~60 unseen posts ≤12 days old scanned. Thin day: two fresh, on-topic, low-competition threads — both about *licensing automation*, which is the same audience as seat-waste. Only 2 picks rather than 3–5; the rest was noise. Skipped again: t3_1w7nl61 (msp client hand-over), t3_1waw72i (license propagation delay, unchanged since yesterday), t3_1waj162 (dupe of 09-09's t3_1waj7ya), t3_1wcje8j (Microsoft Places desk licensing — niche, 1 comment, not seat waste), t3_1wd9zly (recreated leaver mailbox bouncing 550 5.1.351 — X500/LegacyExchangeDN issue, already answered correctly by first commenter), t3_1w9sjk9 (tenant blocked by MCA review — 61 comments, resolved).

**Pricing note:** no dollar figures below. Pull list prices the day you post.

---

### 1. r/microsoft365 — "How do you handle exceptions in an automated Microsoft 365 licensing model?" *(top pick)*

- **Age / activity:** <1 day old, 3 comments, 2 points — unlocked, OP (oOJotta) is replying and just asked a follow-up nobody has answered
- **Link:** https://www.reddit.com/r/microsoft365/comments/1wcpbkd/how_do_you_handle_exceptions_in_an_automated/
- **Context:** Group-based licensing via dynamic groups keyed on jobTitle/userType; identity flow Okta → AD → Entra. OP wants a clean override (e.g. an F3-role user who needs E3) and is considering an extensionAttribute. Two answers so far: "exception groups / coded extension attributes, gets confusing" and "on-prem groups populated by script" — the latter got OP's follow-up "but how do you assign licenses with that?" which is still open.
- **Why it fits:** Exactly the mechanism that produces the seat waste SeatScout finds — an override that stacks a second base SKU on a user, or an exception that never expires. Nobody has raised the billing consequence yet.

**Reply angle:** Endorse the extensionAttribute approach (it flows cleanly through Entra Connect from AD, which their Okta→AD→Entra chain already does), but make the two rules mutually exclusive *in the rule text*, not by hoping precedence works: the F3 rule must carry `-and (user.extensionAttribute10 -ne "E3")` and the E3 rule `(user.extensionAttribute10 -eq "E3") -or (<normal E3 criteria>)`. Reason: an exception user who lands in both groups gets both suites — for F3+E3 the Exchange plans conflict and the user shows up under *Users with license errors*, but for non-conflicting combos both SKUs are consumed and billed with no error. Then the part nobody says: exceptions accumulate. Put an owner and a review date on each override (a second attribute or just a spreadsheet), and every quarter compare the exception list against `Get-MgUser -Property SignInActivity` / usage — the E3 exception from two years ago whose user changed roles is the single most common thing that survives a licensing audit. Answer OP's open follow-up too: script-populated on-prem groups still sync to Entra and can be assigned licenses there as ordinary (non-dynamic) groups. If he mentions the tool: *disclosure: I built a tool for this.*

---

### 2. r/Office365 — "Automation - User license provisioning."

- **Age / activity:** <1 day old, 4 comments, 3 points — unlocked, no OP reply yet
- **Link:** https://www.reddit.com/r/Office365/comments/1wcsfhf/automation_user_license_provisioning/
- **Context:** Hybrid shop: create in AD → Entra Connect → `Enable-RemoteMailbox` on a kept-alive on-prem Exchange → assign license → add to mail-enabled group. Asks how to automate. Answers so far: drop the on-prem Exchange servers (management-tools-only), use group-based licensing or Graph, PowerShell+Graph, and one good "make it idempotent state checks, not sleeps" comment.
- **Why it fits:** The joiner pipeline is half the story; the leaver pipeline is where seats leak. Nobody has mentioned offboarding, and the group-based-licensing tip has a specific gotcha that decides whether it saves money or not.

**Reply angle:** Don't repeat the decommission / group-based-licensing advice — build on it with the two things that bite in practice. First, ordering and lag: after step 2 the object doesn't exist in Graph until the next Entra Connect cycle (30 min default), so the licensing step must poll for the user, and if licensing is done directly via Graph, `usageLocation` must be set first or the assignment fails — the number-one silent failure in home-grown provisioning scripts. Second, whatever they automate for joiners, mirror for leavers: disabling an AD account does *not* remove the user from a licensing group, so the license (and bill) stays until someone remembers. Put `(user.accountEnabled -eq true)` in the dynamic rule so disabling the account releases the seat automatically — with the caveat that removing the license starts the 30-day mailbox deletion clock, so the offboarding runbook must convert to shared mailbox / apply hold *before* the disable, not after. Close with: run `Get-MgUser -Filter "accountEnabled eq false" -Property AssignedLicenses` once today — most hybrid tenants find a handful already. If he mentions the tool: *disclosure: I built a tool for this.*

---

## 2026-09-10

Searched r/sysadmin, r/Office365, r/msp, r/PowerShell, r/Intune (+ r/microsoft365, r/entra), sort new, month filter, 8 scoped queries, 54 unseen posts ≤12 days old scanned. Quiet day for pure license-waste threads; the fresh ones are about feature under-use rather than seat waste, which is an adjacent angle worth taking. 4 picks (one is a 0-comment tool-feedback post — first-mover). Skipped: r/msp "offboard a client" (t3_1w7nl61 — hand-over, not licensing), r/Office365 "Assigning product licenses horrendously slow" (t3_1waw72i — propagation delay, 3 comments), r/sysadmin "license validation issues" (t3_1w5girb — activation bug), r/Office365 "licensing assigned by AD group" (t3_1waj162 — same OP/topic as yesterday's t3_1waj7ya), r/microsoft365 "most underused M365 features" (t3_1wbv6sc — same poster as pick #1, feature list, not cost).

**Pricing note:** no dollar figures below. Pull list prices the day you post.

---

### 1. r/Office365 — "How much of your Microsoft 365 licensing are you actually using?" *(top pick)*

- **Age / activity:** <1 day old, 10 comments, 0 points — active, unlocked, replies still landing this morning
- **Link:** https://www.reddit.com/r/Office365/comments/1wbvhi8/how_much_of_your_microsoft_365_licensing_are_you/
- **Context:** OP asks whether orgs get their money's worth from E5/Business Premium beyond Outlook/Teams. Answers so far are all *feature* under-use: Purview untouched, CA = one MFA policy, PIM without auth contexts, Defender P2 defaults. One comment (progenyofeniac): "assigning less than half the service plans and barely using half of those." Nobody has raised the *seat* side.
- **Why it fits:** Thread is about waste; every answer is "you own it but don't configure it." The missing half is "you pay for seats nobody holds or uses" — measurable, not opinion. Additive, not competing.

**Reply angle:** Agree with the feature-gap comments, then add the other kind of waste that is far easier to measure and cut: seats. Three numbers from one script: `Get-MgSubscribedSku` PrepaidUnits.Enabled vs ConsumedUnits (paid-but-unassigned), licensed users with `AccountEnabled -eq $false` (offboarded but still billed — the most common finding), and licensed users with no interactive sign-in in 90 days via `Get-MgUser -Property SignInActivity` (needs Entra ID P1, which E3/E5/BP already include). Point out feature under-use can't be fixed by a script, but seat waste can be fixed at the next NCE renewal by lowering the count — and that the two combine badly: an E5 seat on a disabled account is paying for Purview *and* nobody. If he mentions the tool: *disclosure: I built a tool for this.*

---

### 2. r/Office365 — "Microsoft 365 F1"

- **Age / activity:** <1 day old, 7 comments, 2 points — OP (mjung79) actively replying; one commenter (blud_13) has covered the Exchange/OWA controls well
- **Link:** https://www.reddit.com/r/Office365/comments/1wbs7nz/microsoft_365_f1/
- **Context:** OP is evaluating F1 for frontline/retail staff. Complains F1 is "read-only Office web + calendar-only kiosk mailbox" on paper, but Microsoft ships no control to enforce it — compliance is "ask users not to." Existing answers: `Set-CASMailbox -OWAEnabled $false`, EWS block since July, restrict OneDrive by security group, site-level Read permission.
- **Why it fits:** It's the reverse of SeatScout's usual case — right-sizing *down* to F1/F3 is where the biggest per-seat savings are, and OP's real blocker is the audit ("who is actually a frontline user vs. who's on E3 out of habit"). The enforcement question is answered; the sizing question isn't.

**Reply angle:** Don't repeat the CASMailbox answer. Add the sizing side: before rolling F1 out, run the candidate population through `SignInActivity` and mailbox usage (`Get-MailboxStatistics`, `Get-MgUser -Property SignInActivity`) — users with no desktop-app activation (`Get-MgUserLicenseDetail` service plan status, or Office activation report in admin center) and near-empty mailboxes are the F1/F3 candidates, and you'll usually find some already-disabled accounts in the same pass. Note the compliance trade-off honestly: F1 is a *licensing* restriction not a *technical* one, so keep a written record of the sizing decision per user group — that's what an audit asks for. If he mentions the tool: *disclosure: I built a tool for this.*

---

### 3. r/PowerShell — "Microsoft Entra Object Inspector" (open-source, read-only Entra assessment tool)

- **Age / activity:** ~3 days old, 0 comments, 0 points — unanswered; author explicitly asks for "critical technical feedback from people who work with Entra"
- **Link:** https://www.reddit.com/r/PowerShell/comments/1w8wcjr/microsoft_entra_object_inspector/
- **Context:** Developer shares a read-only Entra ID assessment tool and asks for technical critique. No replies yet.
- **Why it fits:** Peer-to-peer builder conversation, zero competition, and Uğur has direct experience with the exact Graph gotchas such a tool hits. Goodwill post; no pitch needed.

**Reply angle:** Give real technical feedback from having built something similar — the things that bite read-only Entra tooling: `signInActivity` is only returned with `$select` and only with `AuditLog.Read.All`, and it's null on tenants without Entra ID P1 (handle the null, don't report "never signed in"); `assignedLicenses` vs `licenseAssignmentStates` (group-inherited licenses and error states only show in the latter); `PrepaidUnits` has Enabled/Suspended/Warning buckets, not just one number; `-ConsistencyLevel eventual` + `$count` for `endsWith` filters; and the 2026 WAM enforcement for delegated interactive Graph sessions if it runs interactively. Ask what auth model it uses (delegated vs app-only) since that decides which of these apply. Open with *disclosure: I've built a commercial license-audit tool that hits the same endpoints* — that's the honest frame for "I've seen these bugs."

---

### 4. r/microsoft365 — "Gartner's new Purview report says 47% of E5 licensees are not getting full value"

- **Age / activity:** <1 day old, 2 comments, 4 points — light; **note: OP is a Rencore employee (disclosed)** and the only replies ask for the paywalled source. Lower priority; skip if time is short.
- **Link:** https://www.reddit.com/r/microsoft365/comments/1wbjmyj/gartners_new_purview_report_says_47_of_e5/
- **Context:** Vendor-posted summary of a Gartner Purview guide: 47% of E5 orgs say they're not getting full value; causes listed as tier complexity, poor E3/E5 feature awareness, governance gaps. Asks how others close "the gap between what you are licensed for and what is actually deployed."
- **Why it fits:** Same "E5 value" framing as pick #1 from the compliance-vendor angle. A short, sourced counterpoint keeps Uğur visible on the topic without engaging the vendor pitch.

**Reply angle:** Keep it short and don't argue with the report. Point out the report measures *feature* value; the first thing to check before buying governance tooling is whether every E5 seat is even held by an active person — `Get-MgSubscribedSku` consumed vs purchased and licensed-but-disabled accounts take ten minutes and often free up more budget than any Purview rollout. Then: the real E3-vs-E5 decision is per-user, not tenant-wide — mixed SKU assignment is fully supported and the E5-only service plans (Purview premium, Defender P2, PIM) can be checked per user via `Get-MgUserLicenseDetail` to see who actually has them enabled. Add *disclosure: I built a tool for this* since the thread is already vendor-flavoured and honesty is the differentiator.

---

## 2026-09-09

Searched r/sysadmin, r/Office365, r/msp, r/PowerShell, r/Intune (+ r/microsoft365, r/entra), sort new, month filter, 7 scoped queries, ~75 unseen posts ≤12 days old scanned. Week is dominated by the second tenant-block saga (t3_1w9sjk9, t3_1w1qc0i), the "IT manager stuck in 1995" rant (491 comments), and non-MS vendor hikes (ESET, ThreatDown). 3 picks. Skipped: r/Office365 "OneDrive 1TB→10GB on E5" (t3_1w7vgpj — storage, StorageScout territory, 3 comments), r/msp "offboard a client" (t3_1w7nl61 — pass-through licensing mentioned but it's a hand-over question), r/microsoft365 "Whichm365.com" (still reads as an ad), r/sysadmin "Why depend on Microsoft" (118 comments, philosophy).

**Pricing note:** no dollar figures below. Pull list prices the day you post.

---

### 1. r/sysadmin — "Day to day life of M365 admin" *(top pick)*

- **Age / activity:** ~2 days old, 98 comments, 144 points — active, unlocked, OP replying
- **Link:** https://www.reddit.com/r/sysadmin/comments/1w9iy17/day_to_day_life_of_m365_admin/
- **Context:** New M365 admin asks what the job is beyond tickets ("assign license here, off board that guy there"). Top answers are jokes about MS UI churn and support; the only substantive ones say "review sign-in logs, admin roles, guest access, CA" (skulled_eel, 41 pts) and one mention of "analyse our license structure and constantly optimise" (ZaradimLako) with no how-to.
- **Why it fits:** OP literally lists license assignment and offboarding as the job, and nobody has given the recurring license-hygiene checklist. This is SeatScout's core loop, framed as an admin routine.

**Reply angle:** Give a concrete monthly checklist, not a vibe: (1) `Get-MgSubscribedSku` — compare PrepaidUnits.Enabled vs ConsumedUnits per SKU; the gap is seats you pay for and nobody holds; (2) licensed users with `AccountEnabled = $false` — disabled ≠ unlicensed, offboarding that stops at "block sign-in" keeps billing; (3) licensed users with no interactive sign-in in 60/90 days via `Get-MgUser -Property SignInActivity` (needs Entra ID P1 — Business Premium/E3/E5 include it); (4) shared mailboxes that still carry a user license (`Get-Mailbox -RecipientTypeDetails SharedMailbox` cross-checked against assignedLicenses); (5) group-based licensing errors (`licenseProcessingState`) so drift doesn't hide in a group. Point out the counts don't become savings until the NCE renewal count is lowered — put the renewal date in the calendar. If he mentions the tool: *disclosure: I built a tool for this.*

---

### 2. r/Office365 — "Help - licensing assigned by AD group"

- **Age / activity:** ~1 day old, 8 comments, 1 point — OP's immediate issue already resolved (sync delay), thread still open
- **Link:** https://www.reddit.com/r/Office365/comments/1waj7ya/help_licensing_assigned_by_ad_group/
- **Context:** Consultant took over a client with group-based licensing inherited via on-prem AD groups; couldn't downgrade a user to mail-only; saw "licensing error – dependent services are missing." Turned out to be Entra Connect sync lag. Two closing comments mention "license drift" as the real pain but stop there.
- **Why it fits:** The unanswered part — the "dependent services missing" error and how group-based licensing silently wastes seats — is exactly the audit case SeatScout covers. Additive, short.

**Reply angle:** Explain the leftover error: "dependent services are missing" is a group-license conflict — usually one group assigns a plan whose service (e.g. Exchange Online) is disabled in the group's plan mask, or two groups assign overlapping SKUs; find it with `Get-MgGroup -Property licenseProcessingState` / `Get-MgUserLicenseDetail` and fix the group, not the user, since user-level edits get reverted on the next reprocess. Add the takeover tip: when inheriting group-based licensing, export group→SKU mapping once (`Get-MgGroup -Filter "assignedLicenses/any()"`) and check for users who ended up in *two* licensing groups (a Business Standard + E3 double-assignment is invisible in the user list but shows in ConsumedUnits). No product pitch needed here; if it comes up, *disclosure: I built a tool for this.*

---

### 3. r/PowerShell — "Filtering and cost-effective ways to grab user data"

- **Age / activity:** ~5 days old, 5 comments, 1 point — under-answered
- **Link:** https://www.reddit.com/r/PowerShell/comments/1w745c1/filtering_and_costeffective_ways_to_grab_user_data/
- **Context:** Rewriting a mailbox-provisioning script; wants to key off *licensing state* instead of OU. Plans `Get-ADGroupMember` → `Get-ADUser` → filter proxyAddresses. Asks whether filtering on licensed-user data is faster.
- **Why it fits:** "Which users are actually licensed" is the query SeatScout runs; a clean Graph answer here is useful and on-brand without any pitch.

**Reply angle:** Suggest querying the source of truth rather than AD group membership: `Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq <guid>)" -Property Id,UserPrincipalName,ProxyAddresses,AccountEnabled -All` returns only users who *hold* the SKU (server-side filter, one call, no per-user foreach), then filter proxyAddresses client-side for the missing SMTP entry. Note the trap: an AD licensing group tells you who *should* be licensed; assignedLicenses tells you who *is* — group-based licensing errors and disabled accounts make those two lists diverge, so comparing them is a free audit. Mention `-ConsistencyLevel eventual` + `-CountVariable` if they add `endsWith` filters. No disclosure needed unless he mentions a product.

---

## 2026-09-04

Searched r/sysadmin, r/Office365, r/msp, r/PowerShell, r/Intune (+ r/microsoft365, r/entra), sort new, week filter, 7 scoped queries, 79 unseen posts ≤12 days old scanned. Thin day again: the week is dominated by the M365 deauth/outage saga, passkey/SMS-retirement threads, and vendor price hikes outside Microsoft (FreshDesk, ESET, ThreatLocker). 2 picks. Skipped: r/sysadmin "How does your IT team handle separate M365 admin accounts day to day?" (t3_1w69j0t — good license angle: cloud-only admin accounts on a 225-user Business Premium tenant don't need a BP seat, and BP's 300-seat cap counts them; but 143 comments already, it's a browser-profile/PIM workflow debate, over the "not hundreds" bar), r/Office365 "Hidden folder in a shared account mailbox" (t3_1vvsl1y — licensed-user-instead-of-shared-mailbox, but 12 days old), r/sysadmin "license validation" errors (support/outage, not seats).

**Pricing note:** no dollar figures below. Pull list prices the day you post.

---

### 1. r/sysadmin — "Redirecting emails from accounts without a license" *(top pick)*

- **Age / activity:** <1 day old, 22 comments, 3 points — OP is engaged and confused; unlocked
- **Link:** https://www.reddit.com/r/sysadmin/comments/1w6a28y/redirecting_emails_from_accounts_without_a_license/
- **Context:** Contractors ended; OP removed the license but kept the accounts, set a redirect, and the redirect died the moment the license came off. Asks how to forward without "paying for additional licenses." Replies all say "convert to shared mailbox" or "move the alias to a DL"; one (blud_13) flags the external-forwarding 5.7.520 block. Nobody has explained *why* it broke or the sequencing/timer that matters.
- **Why it fits:** Textbook offboarding-license moment — the exact "still paying for leavers" and "licensed account vs shared mailbox" gap SeatScout audits. Additive answer, not a repeat.

**Reply angle:** Explain the mechanism: removing the Exchange license doesn't just disable features, the mailbox goes into a 30-day soft-deleted grace and mail-flow settings (redirect, rules) stop applying — that's why it worked "operational" and died after. Order of operations is convert-to-shared *first* (`Set-Mailbox -Type Shared`), *then* remove the license; a shared mailbox under 50 GB with no archive/hold needs no license, so the redirect or delegation keeps working at zero seat cost. Two follow-ups people miss: (a) block sign-in on those accounts (`Update-MgUser -AccountEnabled:$false`) since a leaver account that still exists is a security hole regardless of license; (b) the freed seats aren't savings until the count is actually reduced at NCE renewal — `Get-MgSubscribedSku` PrepaidUnits vs ConsumedUnits shows how many you're still paying for but not using. If it comes up: *disclosure: I built a tool for this.*

---

### 2. r/sysadmin — "Looking for Audit Logon and Logoff Software"

- **Age / activity:** ~1 day old, 3 comments, 3 points — early, under-answered
- **Link:** https://www.reddit.com/r/sysadmin/comments/1w5q48z/looking_for_audit_logon_and_logoff_software/
- **Context:** School moving from on-prem AD + UserLock to Entra-joined/Intune, wants to keep tracking computer-lab logon activity to prove machines are "actively used." Replies point at Entra sign-in logs and the 7-day (free) / 30-day (P1/P2) retention wall, plus "define the report first."
- **Why it fits:** Same primitive SeatScout is built on — Entra sign-in data as the "is this actually used" signal — applied to devices instead of seats. Good place to show the signInActivity / Log Analytics pattern without any product pitch.

**Reply angle:** Point out the split: per-*user* last-activity is cheap via `Get-MgUser -Property SignInActivity` (needs Entra ID P1, which A3/A5 and Business Premium include) and answers "who hasn't signed in in 60/90 days"; per-*device* lab usage needs the sign-in log stream itself (device name/ID is in every interactive sign-in event), so route SignInLogs via Diagnostic Settings to Log Analytics and query by DeviceDetail — retention then becomes a workspace setting, not a licensing tier. Add the practical warning that "logoff" doesn't exist as a clean cloud event; measure sessions by sign-in gaps or the Intune device `lastSyncDateTime` instead. No product mention needed; if he pivots to "and which licensed users aren't using anything" add *disclosure: I built a tool for this.*

---

## 2026-09-03

Searched r/sysadmin, r/Office365, r/msp, r/PowerShell, r/Intune (+ r/microsoft365, r/entra) for licensing/cost threads from the last ~10 days (subreddit-scoped queries, week/month filters, ~80 unseen posts scanned). Very slow day: the Oct 1 price/margin threads are already surfaced, and the rest is tenant-deauth DR, Conditional Access, Autopilot, and a partner-benefit redemption escalation (support problem, not a seat problem). 2 picks. Skipped again: r/microsoft365 "Whichm365.com" (score 0, read as an ad) and r/sysadmin "35+ M365 Changes September" (changelog, no question to answer).

**Pricing note:** no dollar figures below. Pull list prices the day you post.

---

### 1. r/sysadmin — "365 Business Premium vs Sentinel One" *(top pick)*

- **Age / activity:** ~1 day old, 33 comments, 3 points — OP is new to IT and reading replies; unlocked
- **Link:** https://www.reddit.com/r/sysadmin/comments/1w5555c/365_business_premium_vs_sentinel_one/
- **Context:** Sole IT at an ~80-person SaaS company. Just moved *everyone* from Business Basic to Business Premium for Intune + CA, now asking whether to keep N-Sight/SentinelOne or use the Defender for Business that BP includes. Answers so far are all EDR/MDR/RMM (Huntress, Action1, keep RMM for 3rd-party patching). Nobody has questioned the "everyone on Premium" decision or the double-paid overlap.
- **Why it fits:** Classic tier-up-the-whole-tenant moment. BP vs Basic is a ~3–4x per-seat difference; at 80 users a blanket upgrade is the largest cost decision this person has made, and it's unexamined.

**Reply angle:** Agree Defender for Business is real EDR and paying for S1 on top is double-paying — but add the license-shape question nobody asked: does every one of the 80 need Premium? Premium earns its price on users with a managed Windows device under CA; shared-device, frontline, contractor and service-style accounts are usually fine on Basic (or F-SKUs) with a *device*-based Intune posture. Concrete check: `Get-MgSubscribedSku` for prepaid vs consumed (unassigned annual-term seats can't be reduced until renewal, so know the number now), then `Get-MgUser -Property AssignedLicenses,SignInActivity,AccountEnabled` to find licensed accounts with no sign-in in 60–90 days and disabled-but-licensed leavers — BP includes Entra ID P1, so `signInActivity` is available to them. "Everything on Premium" is fine as a starting point; the mistake is never revisiting it before the annual term locks. *Disclosure: I built a tool for this* if it comes up.

---

### 2. r/msp — "AI Readiness Tools"

- **Age / activity:** ~6 days old, 29 comments, 17 points — still getting replies
- **Link:** https://www.reddit.com/r/msp/comments/1w0cxmx/ai_readiness_tools/
- **Context:** MSP wants a tool to scan client environments (folder permissions, oversharing) before rolling out M365 Copilot. Thread is entirely data-governance: SharePoint Advanced Management DAG reports, Inforcer, Restricted SharePoint Search, sensitivity labels, "what business problem are you solving." Nobody has raised the seat/usage side of readiness.
- **Why it fits:** Copilot is the highest-cost SKU an MSP will ever resell per seat, and "readiness" threads never include "who will actually use it." That's the PilotScout/SeatScout lane, and it's an additive answer rather than a competing one.

**Reply angle:** Agree oversharing is the first gate, then add the second gate the thread is missing: seat readiness. Before a client buys Copilot for everyone, pick the pilot from real signal — Copilot usage reports (admin center → Reports → Usage → Microsoft 365 Copilot) show last-activity per user once a pilot exists, and for the pre-pilot pick use Teams/Outlook/OneDrive activity and `signInActivity` (needs Entra ID P1) to exclude accounts that barely touch M365 at all. Pair it with a 60–90-day post-rollout check of assigned-vs-active Copilot seats and pull seats that never activated; that's where the recurring cost lives, and the reseller looks good for catching it before the client does. *Disclosure: I built a tool for this* if it comes up.

---

## 2026-09-02

Searched r/sysadmin, r/Office365, r/msp, r/PowerShell, r/Intune (+ r/microsoft365, r/entra) for licensing/cost threads from the last ~12 days. ~110 subreddit-scoped queries, ~70 unseen on-topic posts scanned. Slow day: the Oct 1 CSP price/margin story continues (yesterday's two threads already surfaced), the rest of the feed is career posts, Intune enrollment issues, and the Adobe unlicensed-users thread (off-lane). 3 picks. Skipped r/microsoft365 "Whichm365.com" thread — commenters are calling it an ad, wrong place to show up with a product.

**Pricing note:** no dollar figures below. Pull list prices the day you post.

---

### 1. r/msp — "Upcoming Pricing Changes - Updated Information from PAX8" *(top pick)*

- **Age / activity:** ~1 day old, 20 comments, 49 points — active, unlocked
- **Link:** https://www.reddit.com/r/msp/comments/1w4g184/upcoming_pricing_changes_updated_information_from/
- **Context:** Follow-up to yesterday's 5% thread. OP got the full PAX8 rep answer: Change #1 = 5% increase on annual-term/monthly-billed subs from Oct 1; Change #2 = partner margin on "less-favored" legacy/standalone M365 SKUs (E1/E3 O365, EXO, SPO, standalone plans) cut to ~12%. MSRP unchanged, so it's a margin squeeze not a "price increase." Comments: thanks, Sherweb-vs-PAX8 margin comparisons, "will other distis follow."
- **Why it fits:** The margin cut lands hardest on exactly the SKUs that are most often over-assigned (standalone EXO/SPO, legacy O365 E1/E3). MSPs will be re-pricing every client before Oct 1 — that's the audit moment.

**Reply angle:** Add the operational response nobody has posted: if your margin on legacy standalone SKUs drops to 12%, the cheapest lever is not renegotiating with the disti, it's removing seats you're reselling at a loss of goodwill. Before you touch client pricing, run `Get-MgSubscribedSku` per tenant and compare `PrepaidUnits.Enabled` vs `ConsumedUnits` — unassigned-but-purchased seats on annual terms are pure margin loss now. Then cross assigned seats with `signInActivity` (Entra ID P1 needed for the property) for 60–90-day-idle and still-licensed disabled accounts. Reframing "5% increase" as "we found 8% dead seats" is a QBR win instead of a price-rise email. *Disclosure: I built a tool for this* if SeatScout comes up.

---

### 2. r/msp — "M365 CoPilot licenses still showing as GoDaddy managed, even after defederation?"

- **Age / activity:** ~2 days old, 8 comments, 6 points — OP still replying, unresolved
- **Link:** https://www.reddit.com/r/msp/comments/1w3iug3/m365_copilot_licenses_still_showing_as_godaddy/
- **Context:** Defederated from GoDaddy last year; a handful of GoDaddy-purchased Copilot licenses still show as "managed by GoDaddy.com, LLC" and are coming up for expiration. OP asks whether to just wait for expiry and how to fully remove them. Answers so far: "re-read the tminus guide, wait it out, reprovision via your CSP." OP's follow-up (with screenshot) still isn't answered concretely.
- **Why it fits:** Subscription-ownership vs license-assignment confusion is exactly the `Get-MgSubscribedSku` teaching moment, and Copilot seats are the highest-cost SKU to leave hanging.

**Reply angle:** Answer the mechanics: the subscription object stays owned by the partner who sold it, so it will show GoDaddy until it expires — you can't "take it over," only let it lapse and buy replacements through your CSP. Practical check before expiry: `Get-MgSubscribedSku` shows each Copilot SKU with `PrepaidUnits` and `ConsumedUnits` plus `CapabilityStatus`; make sure the users assigned to the GoDaddy-sourced SKU are moved to the CSP-sourced SKU (same SkuId, different subscription — assignment is by SkuId so the switch is transparent) before `capabilityStatus` flips to Suspended, or they lose Copilot for the grace window. Also: use this moment to check whether all those Copilot seats are actually used — Copilot usage reports in the admin center show last activity per user; don't repurchase seats nobody touched. Disclose if the tool comes up.

---

### 3. r/Office365 — "My company is splitting a business unit and I need to move around 300 users… to a new tenant"

- **Age / activity:** ~5 days old, 26 comments, 19 points — still getting answers
- **Link:** https://www.reddit.com/r/Office365/comments/1w0ijdz/my_company_is_splitting_a_business_unit_and_i/
- **Context:** 1000-user tenant, 300 users going to a new company/tenant; mailboxes, OneDrive, SharePoint, Teams, groups. Answers cover the migration tooling (BitTitan, Quest, AvePoint Fly, delta sync, domain can't exist in two tenants). Nobody has mentioned licensing on either side.
- **Why it fits:** A tenant split is a license event twice over: 300 seats stranded on the source tenant after cutover, and a fresh purchase on the target where it's tempting to mirror the old SKU mix 1:1.

**Reply angle:** Add the licensing checklist the thread lacks. Source side: after cutover the 300 accounts still hold licenses until you unassign them — if they're on annual NCE terms you can't reduce the count mid-term, so time the cutover and the renewal window together and plan the reduction request in the 7-day window at renewal. Target side: don't clone the old assignment; pull `Get-MgUser -Property AssignedLicenses,SignInActivity` for the 300 movers first and buy for what they actually use (E5 features rarely, service accounts, long-inactive people who shouldn't be migrated at all). Also disable, don't delete, source accounts for 30 days post-cutover, but unassign the license on day 1 — a disabled licensed account still bills. Disclose if the tool comes up.

---

## 2026-09-01

Searched r/sysadmin, r/Office365, r/msp, r/PowerShell, r/Intune for licensing/cost threads from the last ~10 days. 10 search queries, ~116 unseen posts scanned. The feed was dominated by yesterday's Exchange Online outage (many high-traffic threads, none reply-worthy for us). 3 picks, all posted within the last 24h, all live and unlocked. The big story: **Microsoft's Oct 1 CSP price change** — two fresh r/msp threads, both confused about what actually changes. That's our lane: renewal pressure = audit-before-renewal advice.

**Pricing note:** no dollar figures hardcoded below — the 5% figure is from the PAX8 notice quoted in thread #1, not our claim. Pull current list prices the day you post.

---

### 1. r/msp — "For the second year in a row, Microsoft is increasing prices by 5% on annual subscriptions that are billed monthly" *(top pick)*

- **Age / activity:** ~17h old, 41 comments, 67 points — hot and still moving
- **Link:** https://www.reddit.com/r/msp/comments/1w3izyk/for_the_second_year_in_a_row_microsoft_is/
- **Context:** OP posted the PAX8 notice: from Oct 1, 2026, CSP annual-term subscriptions billed monthly get another 5% increase; existing commitments keep their price until next renewal. Comments are mostly venting ("raise your customers' prices"), plus one genuine question working out the annual-prepay vs annual-monthly vs month-to-month deltas that nobody has answered cleanly.
- **Why it fits:** Renewal-pricing pressure is SeatScout's core trigger. Nobody in 41 comments has said the obvious practical thing: the increase lands *at renewal*, so the weeks before renewal are exactly when you shrink the seat count.

**Reply angle:** Skip the venting; answer the math question and add the lever everyone's missing. The price change only hits at your next renewal, which makes the pre-renewal weeks the one moment the waste is free to remove — run `Get-MgSubscribedSku` and compare `prepaidUnits` vs `consumedUnits` per SKU, then cross-check assigned seats against `signInActivity` (needs Entra ID P1) for people who haven't signed in for 90 days, including disabled accounts that still hold licenses — those bill like everyone else. Cutting 5% of dead seats more than cancels a 5% list increase, and for MSPs it's a client-facing QBR win rather than a margin squeeze. If SeatScout comes up, add: *disclosure: I built a tool for this.*

---

### 2. r/Office365 — "How do you guys deal with old shared mailboxes nobody wants to delete?"

- **Age / activity:** ~12h old, 17 comments, 7 points
- **Link:** https://www.reddit.com/r/Office365/comments/1w3rhbm/how_do_you_guys_deal_with_old_shared_mailboxes/
- **Context:** Shared mailboxes piling up — dead projects, defunct departments, former employees — and every deletion request gets "better keep it just in case." One strong comment already covers activity detection via message trace; nobody has touched the licensing dimension.
- **Why it fits:** Mailbox lifecycle is offboarding, and offboarding is where license waste hides. The unclaimed angle in this thread is which of these mailboxes cost money and which don't.

**Reply angle:** Add the cost layer: a shared mailbox under 50GB needs no license at all — the expensive version of this problem is former-employee mailboxes kept "just in case" as *licensed users*, billing monthly for someone who left last year. So triage by cost first: licensed ex-employee mailboxes → convert to shared (free under 50GB) or delete-while-on-hold as inactive mailboxes if retention is the real concern; already-shared mailboxes are cost-free clutter you can solve with an owner + review-date policy. Also worth echoing the warning not to trust `LastLogonTime` on shared mailboxes — delegate access doesn't move it. Disclose if the tool comes up.

---

### 3. r/msp — "Microsoft Prices After 1 October"

- **Age / activity:** ~20h old, 10 comments, 2 points — effectively unanswered
- **Link:** https://www.reddit.com/r/msp/comments/1w3dxyr/microsoft_prices_after_1_october/
- **Context:** OP asks what the "New Margin Model" means for O365 E1/E3, Exchange Online, SharePoint Online, OneDrive Extra Storage, and M365 Apps SKUs after Oct 1. The three comments so far are "Pax8 was very unclear" and guesses about an 80/20 split. Confusion, no authority.
- **Why it fits:** Same Oct 1 event as pick #1, but framed as a question nobody has answered. A clear explanation here is durable and searchable, and the listed SKUs are exactly the ones a license audit touches.

**Reply angle:** Separate the two things being conflated: the *list-price* change (the 5% increase on annual-term-billed-monthly, per the PAX8 notice circulating — link the other thread) versus the *margin/split* change, which is distributor-specific — the 80/20 language is about how the distributor shares margin with the MSP, so the real answer comes from their Pax8 account manager, not Reddit. Then the practical advice: whatever the margin model does, the client-side bill is set at renewal, so reviewing which of those E1/E3/EXO seats are actually consumed before the renewal date matters more than the split mechanics. Verify the current PAX8 wording before posting; don't state margin numbers as fact.

---

## 2026-08-31

Searched r/sysadmin, r/Office365, r/msp, r/PowerShell, r/Intune (plus r/microsoft365 and r/entra) for licensing/cost threads from the last ~10 days. 16 search queries, ~90 unseen posts scanned; core licensing volume was thin this week (several strong threads were already surfaced on 08-26/08-28, and one promising r/msp "licenses increased sixfold" thread turned out to be HaloPSA pricing, already resolved by the OP — skipped). 4 picks: 3 core, 1 adjacent. All live, none locked or archived.

**Pricing note:** no dollar figures hardcoded below — pull current per-seat list prices the day you post.

---

### 1. r/PowerShell — "Microsoft To Enforce WAM for Delegated Interactive Graph Sessions" *(top pick)*

- **Age / activity:** 3 days old, 18 comments, 26 points
- **Link:** https://www.reddit.com/r/PowerShell/comments/1w0lsf7/microsoft_to_enforce_wam_for_delegated_interactive/
- **Context:** Microsoft will force the default Graph Command Line Tools app to use Web Account Manager for interactive sign-in. Commenters are worried about cached-token weirdness, module assembly clashes, and Mac/Linux (no WAM there).
- **Why it fits:** Every license-audit workflow in SeatScout's world starts with `Connect-MgGraph`. This is exactly the audience — admins running `Get-MgSubscribedSku` / `signInActivity` scripts interactively — hitting an auth change that breaks their habit.

**Reply angle:** The practical takeaway is that anything scheduled or repeatable (license reports, inactive-user sweeps) shouldn't be riding delegated interactive auth in the first place — register your own app, grant application permissions (`User.Read.All`, `Organization.Read.All`, `AuditLog.Read.All` for signInActivity), auth with a certificate, and WAM enforcement never touches you. It also fixes the cached-token complaint in the top comments, since app-only tokens are deterministic. Keep interactive for ad-hoc poking only. Don't speculate on the Mac/Linux behavior — answer the automation half you know cold.

---

### 2. r/sysadmin — "managing AI in enterprise environment"

- **Age / activity:** 1 day old, 10 comments, 12 points
- **Link:** https://www.reddit.com/r/sysadmin/comments/1w2xacg/managing_ai_in_enterprise_environment/
- **Context:** Org blocked all AI except Copilot; one department now needs Claude. E5 tenant, Purview DLP mid-rollout, domain federated through Okta — OP explicitly asks "correct me if I'm wrong" on whether session policies work with Okta SSO.
- **Why it fits:** E5/Purview/Copilot licensing mechanics plus a direct invitation to correct a technical point. Nobody in the thread has touched the cost dimension of running Copilot org-wide *and* Claude per-department.

**Reply angle:** Answer the question actually asked: Conditional Access App Control proxies apps that get their tokens from Entra — M365 apps still do even with an Okta-federated domain, but a third-party AI app SSO'd directly against Okta never transits Entra, so Defender session policies won't see it (verify current behavior before posting; this moves fast). The unclaimed angle: scope the Claude purchase to the one department and put a usage gate on the Copilot estate before renewal — the Copilot usage report shows who actually uses their seat, and paying for two AI stacks per user is only defensible for people demonstrably using both. If PilotScout comes up, add: *disclosure: I built a tool for this.*

---

### 3. r/Office365 — "Group licensing working?"

- **Age / activity:** 4 days old, 2 comments, low score — effectively unanswered
- **Link:** https://www.reddit.com/r/Office365/comments/1vzhojp/group_licensing_working/
- **Context:** Group-based licensing silently not applying during a rushed onboarding; OP "fixed" it by removing and re-adding users, and separately saw a Teams Phone license flip to "non-renewing" and back. Nobody has explained the mechanism.
- **Why it fits:** Pure licensing mechanics, unanswered, from an admin in visible distress ("I desperately need this thing to work correctly"). Small thread, but the answer is durable and searchable.

**Reply angle:** Explain *why* remove/re-add worked: group license assignment is an async reprocess job, and it silently stalls on missing `usageLocation`, sku conflicts, or service-plan prerequisites (one commenter is right that Teams Phone needs its Teams/Skype dependencies applied first). The clean fix is forcing reprocessing — user → Licenses → Reprocess in Entra, or `POST /users/{id}/reprocessLicenseAssignment` via Graph — and checking the group's Licenses blade for per-user error states instead of re-adding and hoping. That turns his lottery into a diagnosable pipeline.

---

### 4. r/sysadmin — "How the hell are y'all managing enterprise Claude?" *(adjacent — founder credibility, not core M365)*

- **Age / activity:** 1 day old, 51 comments, 58 points
- **Link:** https://www.reddit.com/r/sysadmin/comments/1w2e0x8/how_the_hell_are_yall_managing_enterprise_claude/
- **Context:** Admin stuck rolling out Claude Enterprise for ~200 users; core complaint is governing plugins/MCP/skills/hooks — allowlist-everything feels unmaintainable. Answers so far are vendors, "block it all," or generic zero-trust.
- **Why it fits:** Not an M365 licensing thread — it's here because you run this stack daily and build plugins/MCP servers yourself. First-hand operational answers in a 50-comment thread is exactly the reputation-building the warm-up is for.

**Reply angle:** Speak from actual use: the workable middle is a curated internal plugin/skill set (one commenter's "own marketplace" approach) rather than per-request allowlisting — review a small set of plugins/MCP servers once, publish those, and treat new requests as additions to a catalog, not exceptions to a firewall. Add what the vendors won't: MCP tool grants are where the real blast radius is, so review what tools a server exposes (write vs read) rather than the plugin wrapper. Honest, no product tie-in needed.

## 2026-08-28

Searched r/sysadmin, r/Office365, r/msp, r/PowerShell, r/Intune (plus r/microsoft365 and r/entra, consistent with prior runs) for M365 license waste / cost / tier / offboarding / Graph-audit threads from the last ~10 days. 60 unseen threads matched; 5 worth a personal reply, ranked. All five are live — none locked, archived or removed.

**Note on pricing:** none of the angles below hardcode a dollar figure. Pull the current per-seat list price from Microsoft's own pricing page the day you post and do the arithmetic live — quoting a stale price in a licensing thread is the fastest way to lose the room.

---

### 1. r/Office365 — "Does my small business need MS Business Premium?" *(top pick)*

- **Age / activity:** 3 days old, 40 comments, 11 points
- **Link:** https://www.reddit.com/r/Office365/comments/1vy5gu2/does_my_small_business_need_ms_business_premium/
- **Context:** 15-user medical practice on Business Basic, weighing a move to Business Premium.
- **Why it fits:** This is the exact seat-tier decision SeatScout exists to answer. The thread has 40 comments and *not one* has done the actual per-seat math or raised mixed licensing — everyone jumped to "yes, Premium" or "hire an MSP."

**Reply angle:** The unasked question is whether all 15 users need Premium. Split the roster by what each person actually touches — a front-desk user who only needs email and a browser can stay on Basic while the clinical staff who handle a managed laptop and patient data go to Premium; you buy Intune, Defender for Business and Entra ID P1 only for the seats that use them, and at 15 users that delta compounds every month. Worth adding that Microsoft's BAA covers its in-scope services across the commercial M365 plans rather than being a Premium-only unlock, so HIPAA alone isn't the argument for the upgrade — the device management and conditional access are. If you mention the tool, add: *disclosure: I built a tool for this.*

---

### 2. r/Office365 — "Microsoft 365 Admin Portal is a Complete Cluster - Renewal Broken, Support Useless"

- **Age / activity:** 3 days old, 9 comments, 6 points
- **Link:** https://www.reddit.com/r/Office365/comments/1vy0e5t/microsoft_365_admin_portal_is_a_complete_cluster/
- **Context:** Business Standard subscription expiring Sept 1; renewal link routes to the wrong products, support unreachable.
- **Why it fits:** A renewal moment is the one time a business will actually look at seat counts. Two commenters already pointed at Admin Center > Billing > Your products, so the differentiated contribution is what to *check* before clicking renew.

**Reply angle:** Since he's being forced into the billing pages anyway, this is the moment to reconcile what he's paying for against what's assigned — `Get-MgSubscribedSku | Select SkuPartNumber, @{n='Purchased';e={$_.PrepaidUnits.Enabled}}, ConsumedUnits` shows purchased vs consumed per SKU in one line, and the gap is seats he's about to renew for nobody. Also worth flagging that renewing at last year's quantity is the default failure mode, and that whether he bought direct or through a CSP determines who actually controls the renewal quantity. Add the disclosure line if he links the tool.

---

### 3. r/msp — "Billing system with TDSynnex integration?"

- **Age / activity:** 10 days old, 13 comments, 7 points
- **Link:** https://www.reddit.com/r/msp/comments/1vs4lxp/billing_system_with_tdsynnex_integration/
- **Context:** New-ish MSP reselling o365 through TD Synnex, unhappy with Work365, looking for a PSA/billing system that reconciles license quantities.
- **Why it fits:** Distributor-billed quantity vs actually-assigned seats is the exact reconciliation SeatScout does. Existing answers all name PSAs (Halo, Autotask, DealHub); nobody has named the underlying data problem.

**Reply angle:** The integration is only half the problem — the number that matters is distributor-billed quantity minus seats actually assigned in each client tenant, and no PSA computes that for you because it only ever sees the invoice side. Pulling assigned counts per tenant from Graph and diffing them against the TD Synnex quantity catches the seats that were provisioned for a leaver and never reclaimed, which is margin sitting in plain sight. Disclose the tool if he mentions it.

---

### 4. r/sysadmin — "M365 primary tenant with a Google Workspace subsidiary, full migration vs. hybrid vs. third-party MDM?"

- **Age / activity:** Under 1 day old, 3 comments, 7 points
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vzzgod/m365_primary_tenant_with_a_google_workspace/
- **Context:** Solo IT ops, parent on M365 + Entra ID, ~100-user subsidiary entirely on Google Workspace. Migrate, hybrid, or third-party MDM?
- **Why it fits:** Very fresh, almost no competition, and the cost dimension is completely absent from the two existing replies. SeatScout's angle is the one nobody has taken.

**Reply angle:** Both existing answers argue the technical merits without pricing the option — a hybrid that runs for a year means paying two per-seat stacks for 100 people the whole time, and that carrying cost usually dwarfs the one-off migration effort people are trying to avoid. Also worth noting the second commenter's SAML-federation suggestion depends on Entra ID P1, so he should confirm what the parent tenant's SKU actually includes before designing around conditional access. Framing it as "what does 12 months of hybrid cost vs a weekend of cutover" gives him the number he needs to take to whoever signs off.

---

### 5. r/sysadmin — "New position, need some help" *(lower priority — adjacent, not core)*

- **Age / activity:** Under 1 day old, 8 comments, 1 point
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vzzj3m/new_position_need_some_help/
- **Context:** Embedded MSP tech at a school, ~5 years experience, listing gaps and inefficiencies and asking where to start.
- **Why it fits:** Weaker fit than the four above — the thread is mostly about imaging and provisioning, and the replies have gone to Autopilot / Windows Configuration Designer. Only reply if you can lead with something useful on his actual questions first.
- **Caveat:** Don't force a licensing answer into a provisioning thread. Skip this one if you're short on time.

**Reply angle:** After answering the provisioning question, the cheap early win in a school tenant is auditing who still holds a license — graduated students and departed staff routinely stay licensed for years because nobody owns the offboarding step, and blocking sign-in doesn't release the seat, so a disabled account keeps billing until the SKU is actually removed. `Get-MgSubscribedSku` gives him purchased vs consumed per SKU in about a minute and turns into a visible win he can show his manager in week one. Disclosure line applies if he names the tool.

---

**Skipped, and why:**

- `t3_1vujyjg` r/sysadmin "Adobe Licensing Specialist Asking Us to Delete Unlicensed Users" — 123 comments and Adobe, not M365. Too saturated, wrong stack.
- `t3_1vz3dl9` r/msp "Licenses increased sixfold by licensing partner" — HaloPSA billing dispute, no M365 angle you have real experience with.
- `t3_1vsgul1` r/Office365 "20-30% of Copilot Licenses go unused" — zero comments, link post with no discussion to join.
- `t3_1vx178n` r/microsoft365 "M365 Licensing Changes 2026 Explained | E3, E5 & NEW E7" — 1 comment, appears to be self-promo video with no discussion.

## 2026-08-27

> Ran 36 scoped searches across r/sysadmin, r/Office365, r/msp, r/Intune, r/PowerShell, r/microsoft365, r/entra (sort=new, week and month windows), using the single-subreddit short-query form (`subreddit:X <one-or-two-keyword>`) that remains the only reliable syntax for this connector. ~120 posts reviewed against the 84-entry seen-log; 9 threads pulled for full comment reads. **Four picked** — a better yield than usual, mostly because two very strong offboarding threads landed on 08-26.
>
> All four verified unlocked and unarchived with live discussion. Every technical claim in the angles below was checked against Microsoft Learn before writing — the unlicensed-OneDrive enforcement clock (which changed on 2026-07-01 and is *newer than most of the advice being given in these threads*), the shared-mailbox 50 GB licensing thresholds, the NCE seven-day cancellation window, the `signInActivity` prerequisites, and the Power Platform connection-owner behaviour. Sources at the end of this section.
>
> **Standing note for this run:** do not quote Copilot or M365 list prices from memory in any reply. Pricing moved on 2026-07-01 and the secondary sources disagree. Check Microsoft's own product page before putting a dollar figure in a comment.

### 1. r/microsoft365 — What are your steps for archiving a user in 365?
- **Age:** 1 day (posted 2026-08-26) | **Comments:** 19 (unlocked, active, practitioner-heavy, no vendor replies)
- **Link:** https://www.reddit.com/r/microsoft365/comments/1vysfay/what_are_your_steps_for_archiving_a_user_in_365/
- **Why it fits:** Best pick of the run and dead centre of SeatScout's problem. Nineteen comments describing offboarding procedures and **not one mentions what is still being billed** at each step. Better still, there is a specific unanswered question: **RandomSkratch** asks *"Do you need to keep the user account around but unlicensed? … Do you happen to have MS Learn link that talks about this?"* — nobody supplied one. **Anna__Banana__** got the OneDrive timeline roughly right (60/93 days) but her "1 year perm delete" is now the 2026-07-01 cumulative-nonpayment clock, which is a meaningful correction. **Chazus** advises "remove license, just don't delete the account at all," which is right for the mailbox and wrong for OneDrive. **reevesjeremy** keeps accounts licensed for 30 days post-disable — a deliberate cost he may not have priced.
- **Suggested angle:** Answer RandomSkratch with the actual link and the consequence chain, because the answer is genuinely counterintuitive. Microsoft's OneDrive doc states plainly that the OneDrive retention clock starts **only** when the user object is deleted from Entra ID — *"No other action causes the cleanup process to occur, including blocking the user from signing in or removing the user's license."* So keeping the account is correct for retention. But the unlicensed OneDrive runs its own clock regardless: read-only at day 60, archived at day 93, gone from eDiscovery at day 275, and subject to deletion at 365 cumulative unpaid days under the enforcement that began 2026-07-01. That's the gap in "just don't delete the account" — the mailbox survives, the OneDrive quietly does not, unless a licence is reassigned or unlicensed-account billing is enabled. Then the two cost facts nobody has stated: setting `accountEnabled = false` does not touch `assignedLicenses`, so a disabled account keeps billing at full rate (fine as a deliberate 30-day handover window, as long as it's priced); and "convert to shared mailbox and drop the licence" is only free under 50 GB — over 50 GB, or with in-place archiving or litigation hold, the shared mailbox needs Exchange Online Plan 2 (or EOP1 + the Exchange Online Archiving add-on), and non-compliant shared mailboxes now surface as a Service Health advisory in the tenant. No product mention needed; this is a pure technical contribution. Disclose only if someone asks what he uses.

### 2. r/sysadmin — Quick way to audit a user's access across platforms without checking each one manually?
- **Age:** 1 day (posted 2026-08-26) | **Comments:** 13 (unlocked, active)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vyxq8b/quick_way_to_audit_a_users_access_across/
- **Why it fits:** ~1,000 employees, 30+ locations, hybrid AD/Entra, already built a Microsoft Form + Power Automate offboarding flow — and explicitly constrained: *"we're owned by a PE firm, so cost control is a big deal here. Whatever I do needs to be lean, not 'buy an enterprise IGA suite' territory."* That is SeatScout's buyer describing himself. Most of the thread answers a question he didn't ask ("use SSO") when his five problem apps demonstrably aren't SSO'd. The sharpest reply is **AddendumWorking9756**: those apps are all billed per seat, so AP already receives an authoritative monthly roster — sitting at 1 upvote and undeveloped.
- **Caveat before replying:** two vendors (**Setyl**, **Reftab**) have already posted disclosed pitches. That means a disclosed reply fits the thread's norms, but it also means a third vendor-shaped comment gets discounted. Lead with the free technical answer and let the tool come up only if asked.
- **Suggested angle:** Point out that the Microsoft half of his inventory is free and he already owns it — no new tool, which is the constraint he set. `Get-MgSubscribedSku` gives `PrepaidUnits.Enabled` vs `ConsumedUnits` per SKU (purchased-but-unassigned seats as a hard number); `Get-MgUser -Property assignedLicenses,accountEnabled,signInActivity` gives the per-user side. Two gotchas worth the comment on their own: `signInActivity` needs Entra ID P1/P2 **and** both `AuditLog.Read.All` and `Directory.Read.All` — missing the second produces an intermittent "tenant doesn't have premium license" error that looks like a licensing problem and isn't; and `signInActivity` supports `$filter` but **not in combination with any other filterable property**, so you can't filter on `accountEnabled` and `signInActivity` in one query — pull the set first, then `$select=signInActivity` over it in pages of 500. Then back AddendumWorking9756 properly: for Files.com, Adobe, Genesys, LogMeIn and GoTo, the monthly per-seat invoice *is* the authoritative roster, it costs nothing to maintain, and reconciling it against the HR-active list catches leavers the managers forgot. That reconciliation is also the only version of this that outputs a dollar figure rather than a checklist — which is what a PE-owned finance function will actually read. If the tool comes up: "disclosure: I built a tool for the Microsoft side of this."

### 3. r/microsoft365 — How to add Copilot Business
- **Age:** 3 days (posted 2026-08-24) | **Comments:** 12 (unlocked; OP still replying as of 08-26)
- **Why it fits:** OP now has a **duplicate subscription** and is chasing the refund least likely to land. He held a reseller-sold annual Business Standard paid through May, couldn't add the Copilot add-on ("This product is unavailable"), spent 2.5 hours with Microsoft support, and has now subscribed to the Business Standard + Copilot bundle direct while asking the reseller to refund the unused portion of the original. Nobody in the thread has mentioned the seven-day window, and it is **time-critical** — this is worth a reply today rather than tomorrow.
- **Link:** https://www.reddit.com/r/microsoft365/comments/1vworfr/how_to_add_copilot_business/
- **Suggested angle:** First, the greyed-out add-on was structural, not a fault: an add-on has to attach to the base subscription within the same billing account, and a reseller/CSP-managed base can't take a direct-purchased add-on — which is why **mayuan11's** "change the billing account at the top" was the right instinct and dead-ended when OP only had one. Second, and the actionable part: check the start date on the bundle he just bought. On a direct (MCA) subscription you can cancel for a prorated credit or refund only within **seven days** of subscription start or renewal; past that the only lever is turning off recurring billing, and he pays to term. Third, the reseller refund he's chasing is the weaker path — under NCE the seven-day window on that original subscription closed months ago and the partner is billed for the full term regardless, so a goodwill credit is the most he can expect. The better ask of the reseller is a **scheduled change via Manage Renewal** so the old Business Standard doesn't silently renew into a second duplicate in May; worth adding that scheduled changes are deleted if anyone turns autorenew off, so leave autorenew **on**. **Do not quote a price** — check the current Business Standard + Copilot list price on Microsoft's own page first if a number is needed at all. No product mention; this one is pure goodwill in a sub where he wants standing.

### 4. r/microsoft365 — How are you tracking dependencies across Microsoft 365?
- **Age:** 5 days (posted 2026-08-22) | **Comments:** 8, 9 points (unlocked, OP responsive)
- **Link:** https://www.reddit.com/r/microsoft365/comments/1vvmike/how_are_you_tracking_dependencies_across/
- **Why it fits:** OP's question is literally *"What will break if we remove this user, SharePoint site, group, app or flow?"* — the blast-radius half of offboarding, and the reason admins leave seats assigned "just in case" and keep paying for them indefinitely. **BrabantNL** and **guubermt** give the correct target state (never run automation as a user), which OP politely notes doesn't help with an inherited tenant. That inherited-tenant question is still unanswered.
- **Caveat before replying:** OP's follow-ups read like product discovery rather than a working admin — he steers three separate replies toward "a maintained data backend that builds those relationships from the tenant itself." Possibly a founder validating an idea. Not a reason to skip a good technical answer, but Uğur should treat it as a public comment, not a lead, and should not pitch into it.
- **Suggested angle:** Skip the architecture debate and give the one dependency that is documented and checkable today. Per Microsoft's own troubleshooting guidance, when the account that **created** a Power Platform connection is disabled or deleted, the connection becomes invalid **for everyone who shares it**, not just the leaver — and the fix is another user re-authorising the connection, which transfers ownership. So the practical move is a pre-flight, not a post-mortem: enumerate connections and cloud flows owned by the leaver *before* setting `accountEnabled = false`, because afterwards you're debugging other people's broken flows without knowing why. Then the honest limitation nobody has stated: there is no single tenant-wide dependency graph. Entra group membership, SharePoint site-collection admin, Power Platform connection ownership and flow ownership are four separate queries against four surfaces, and a per-leaver script that hits those four is achievable where a general-purpose map is not. That answers the inherited-tenant reality without contradicting BrabantNL's correct design advice. No product mention.

### Reviewed and dropped
- **r/msp "Licenses increased sixfold by licensing partner"** (t3_1vz3dl9, 08-26, 19c, 15 pts) — looks on-topic from the title but it's HaloPSA reseller billing, not M365, and OP posted an UPDATE that the reseller reverted to the original agreement. Resolved; nothing to add.
- **r/microsoft365 "Password expiration - Blocked Users"** (t3_1vxsrja, 08-25, 17c) — "blocked users" is password-rotation compliance, not licensing. OP has also explicitly told the thread to stop advising him off his policy. Do not engage.
- **r/sysadmin "Anyone else seeing M365 Group/Team automatic renewal not happening correctly?"** (t3_1vy0hj9, 08-25, 5c) + **"M365 group autorenewal"** (t3_1vx6bl9, 08-24, 1c) — group *expiration policy*, not licence renewal, despite the wording. Genuinely interesting signal (two tenants, different expiry windows, same failure shape, reported hours apart, and **Crispinwhere**/**meatwad75892** both confirm `expirationDateTime` is still a month out while the warning mail fires) but there is nothing seat-cost-shaped to contribute and three people already converged on the diagnosis. **Flagging as a topic to watch, not a reply target.**
- **r/Office365 "Group licensing working?"** (t3_1vzhojp, 08-27, 2c) — freshest thread of the run and squarely group-based licensing, but OP self-resolved in an edit (removed from the licensing group and re-added) and **topher358** already supplied the correct cause class (service-plan prerequisites). Too thin to reply to.
- **r/sysadmin "Business Premium DfCA groups"** (t3_1vwzpy9, 08-24, 2c) — both replies already answered it correctly and completely (BP gets Cloud Discovery only; device groups are an MDE construct). Nothing left.
- **r/sysadmin "I'm about to have to do everything, and I have questions."** (t3_1vy5q0m, 08-25, 21c) — solo admin standing up a new ~70-user tenant. Licensing is one line of a nine-part infrastructure question and the thread has moved to Cisco vs UniFi and backups. Weak fit.
- **r/sysadmin "Adobe Licensing Specialist Asking Us to Delete Unlicensed Users"** (t3_1vujyjg, 08-21, 122c, 455+ pts) — resurfaced yet again, now the biggest licensing thread in the sub. Still Adobe, still venting. Per the standing instruction from 08-26: **stop re-checking this one.**
- **r/msp** business threads — "losing our largest customer" (1vzr9ma), "Work beyond MSP services, how to price?" (1vz6ggd), "MSPs Pushing Managed End User Services" (1vyoiqf, 64c). All MSP pricing and commercial strategy, no M365 seat angle.
- Remainder of the sweep was off-topic for M365 seat cost: the 08-24 Office activation outage (OP1460815), EXO mailbox quota and provisioning bugs, GDAP/CIPP tooling, Intune enrolment and Windows Update Ring issues, certificate management, break-glass/CA design, server hardware pricing, and the usual career threads.

### Sources checked for this section
- Unlicensed OneDrive enforcement — read-only day 60, archived day 93, out of eDiscovery day 275, deletion risk at 365 cumulative unpaid days (clock effective 2026-07-01; EDU/GCC/DoD excluded) — [Manage unlicensed OneDrive user accounts](https://learn.microsoft.com/sharepoint/unlicensed-onedrive-accounts)
- OneDrive retention clock starts only on Entra user deletion — *"No other action causes the cleanup process to occur, including blocking the user from signing in or removing the user's license"* — [OneDrive retention and deletion](https://learn.microsoft.com/sharepoint/retention-and-deletion)
- Shared mailbox free to 50 GB; >50 GB, in-place archiving, or litigation hold requires Exchange Online Plan 2 (or EOP1 + Exchange Online Archiving add-on) — [About shared mailboxes](https://learn.microsoft.com/microsoft-365/admin/email/about-shared-mailboxes) and [Exchange Online limits](https://learn.microsoft.com/office365/servicedescriptions/exchange-online-service-description/exchange-online-limits#mailbox-storage-limits)
- Non-compliant shared mailboxes raise a Service Health advisory — [Service advisory for non-compliant shared mailboxes](https://learn.microsoft.com/microsoft-365/enterprise/microsoft-365-non-compliant-shared-mailboxes-exo-service-advisory)
- MCA direct subscriptions: prorated credit/refund only within seven days of start or renewal; after that, turn off recurring billing — [Cancel your subscription in the Microsoft 365 admin center](https://learn.microsoft.com/microsoft-365/commerce/subscriptions/cancel-your-subscription)
- NCE license-based: prorated refund within seven calendar days of any term; seat reductions only within seven days of when licences were added; scheduled changes require an active subscription with autorenew **on**, and are deleted by cancelling, turning off autorenew, changing quantity, upgrading a SKU or converting a trial — [Manage customer subscriptions](https://learn.microsoft.com/partner-center/customers/create-a-new-subscription) and [NCE cancellation policy](https://learn.microsoft.com/partner-center/customers/new-commerce-cancellation-policy)
- `signInActivity` requires Entra ID P1/P2 and `AuditLog.Read.All`; `Directory.Read.All` also required or the "tenant doesn't have premium license" error appears intermittently; supports `$filter` but not alongside any other filterable property; `$top` caps at 500 — [user resource type](https://learn.microsoft.com/graph/api/resources/user?view=graph-rest-1.0#properties), [How to detect and investigate inactive user accounts](https://learn.microsoft.com/entra/identity/monitoring-health/howto-manage-inactive-user-accounts), [Neither tenant is B2C or tenant doesn't have premium license](https://learn.microsoft.com/troubleshoot/entra/entra-id/users-groups-entra-apis/b2c-or-tenant-premium-license-sign-in-activities)
- Power Platform connection owner disabled or deleted invalidates the connection for all users sharing it; fix is re-authorisation by another user, which transfers ownership — [Troubleshoot broken connections in Microsoft Power Platform](https://learn.microsoft.com/troubleshoot/power-platform/power-automate/connections/troubleshoot-broken-connections)

---

## 2026-08-26

> Ran 28 scoped searches across r/sysadmin, r/Office365, r/msp, r/Intune, r/PowerShell, r/microsoft365, r/entra (sort=new, week-to-month windows), using the single-subreddit short-query form that the 08-24 run established as the only reliable syntax for this connector — `subreddit:X <one-or-two-keyword>`, never `subreddit:X OR subreddit:Y` with a keyword phrase, which still returns r/all firehose junk. ~150 posts reviewed and cross-checked against the 85-entry seen-log; 6 threads pulled for full comment reads. **Three picked.** Widening into r/microsoft365 and r/entra (which the older query set under-covered) is what surfaced the best pick this run — worth keeping in the standing rotation.
>
> All three picks were verified unlocked and unarchived, with live discussion. Technical claims in the angles below were checked against Microsoft Learn before writing: the Entra ID P1/P2 requirement for `signInActivity`, the `$filter`-incompatibility gotcha, and the NCE seven-day seat-reduction window. Sources listed at the end of this section.

### 1. r/microsoft365 — Customer 365 licensing reports
- **Age:** 5 days (posted 2026-08-21) | **Comments:** 13 (unlocked, MSP practitioners, no vendor pile-on beyond one disclosed AdminDroid rep)
- **Link:** https://www.reddit.com/r/microsoft365/comments/1vu1zve/customer_365_licensing_reports/
- **Why it fits:** Best-fit thread of the run and squarely SeatScout's problem statement. OP is an MSP: *"how everyone is handling sending customers reports of their current Microsoft 365 licensing usage. We have both Ninja one and cipp but seemingly no way to do it."* Every one of the 13 replies answers **delivery** — CIPP report builder, CIPP executive summary → license category, PowerShell + Graph `sendMail` on a scheduled job, Halo PSA report aggregation, AdminDroid. Not one addresses **what belongs in the report**. That gap is the whole reply.
- **Suggested angle:** The delivery question is well answered above; the content question isn't. A licensing report that just lists assigned SKUs per user gives the customer nothing to act on. Two columns change that: (a) `Get-MgSubscribedSku` → compare `PrepaidUnits.Enabled` against `ConsumedUnits` per SKU, so purchased-but-unassigned seats appear as a hard number rather than something you'd have to eyeball; (b) per-user last activity, joined in from `signInActivity.lastSuccessfulSignInDateTime` (needs Entra ID P1/P2 on the customer tenant plus `AuditLog.Read.All` **and** `Directory.Read.All` — the second one is easy to miss and produces an intermittent "tenant doesn't have premium license" error without it), or from the `getOffice365ActiveUserDetail` report if the tenant is Free-tier. Then the timing point that makes it worth sending at all: under NCE, license-based seats can only be reduced within seven calendar days of term start or renewal completion, so put the renewal date on the report and land it a couple of weeks before — mid-term it's informational only. If SeatScout comes up, disclose it plainly ("disclosure: I built a tool for this"); the advice stands without it.

### 2. r/sysadmin — Re-enabling a disabled account can cause an unexpected Teams membership issue
- **Age:** 4 days (posted 2026-08-22) | **Comments:** 36, 92 points (unlocked, still drawing replies)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vv9qe8/reenabling_a_disabled_account_can_cause_an/
- **Why it fits:** Disabled-account lifecycle is SeatScout's core territory, and this thread has a specific, unanswered opening rather than a generic one. Commenter **Edexote** speculates: *"Maybe the licenses are being removed after the disabling and not returning after enabling?"* — nobody corrected it. **PoolTough3222** separately lands near the same idea: runs a monthly export of private-channel members, notes *"Same report is useful at license review time."* **wakehorn** already gave the correct root cause (private channels are their own SharePoint site collections, so membership doesn't ride along with the group object).
- **Suggested angle:** Correct Edexote's guess directly, since it's a common and expensive misconception: setting `accountEnabled = false` does not touch `assignedLicenses` at all. The seat stays assigned and keeps billing — which is exactly why disabled accounts are the most common source of paid-but-idle seats, and also why the license is *not* what's breaking private-channel membership here (wakehorn's site-collection explanation is the right one). Then the constructive add on PoolTough3222's export: if you're already dumping private-channel membership at offboarding, add `assignedLicenses` and `signInActivity.lastSuccessfulSignInDateTime` to the same export — one script then covers both the re-enable rebuild and the reclaim list. Worth flagging the Graph gotcha: `signInActivity` supports `$filter` but **not in combination with any other filterable property**, so you can't filter on `accountEnabled eq false` and `signInActivity` in one query — pull the disabled set first, then `$select=signInActivity` over that set in batches. No product mention needed here; it's a pure technical contribution. Disclose only if someone asks what he uses.

### 3. r/sysadmin — Microsoft Billing
- **Age:** 6 days (posted 2026-08-20) | **Comments:** 29 (unlocked; note the tone — see caveat)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vtdijw/microsoft_billing/
- **Why it fits:** OP manages M365 Business licences for a client, wants a renewal cost estimate, and can't get a pro-forma out of the portal. **PoolTough3222** gave the correct mechanical answer (export the subscriptions view; SKU × seat count × term × commit type against current list price) and noted the two things that break the math — mid-term seat drift and month-to-month lines. The reconciliation half is still open, and OP's confusion about autorenew is unresolved.
- **Caveat before replying:** the thread has an edge to it — **Frothyleet** tells OP to *"evaluate whether you are qualified to be a MSP"*, and OP's own follow-up is defensive. A straightforwardly useful, non-condescending answer will stand out, but don't engage the pile-on.
- **Suggested angle:** Build the estimate on **consumed** seats, not purchased ones. `Get-MgSubscribedSku` gives `PrepaidUnits.Enabled` vs `ConsumedUnits` per SKU; the gap is already paid for, unassigned, and will renew at full quantity by default — that's usually where a renewal estimate diverges from the invoice. Then the timing rule that decides whether the estimate is even actionable: under NCE, license-based subscriptions can only be cancelled or reduced within seven calendar days of term start or of renewal completion; after that the quantity is committed for the term, and a reduction has to be entered as a **scheduled change via Manage Renewal**, which only works while the subscription is active *and* autorenew is left **on**. That directly answers OP's autorenew experiment: switching autorenew off to reveal a price also deletes any scheduled change and is the wrong lever. Also worth noting for accuracy: if this client is under a CSP/reseller rather than direct, the reseller controls the renewal quantity and OP should be asking them for the pro-forma. No product mention needed; disclose if it comes up.

### Reviewed and dropped
- **r/microsoft365 "I built a free open-source dashboard that shows where your M365 storage actually goes"** (t3_1vpq7ay, 08-16, 16c, 39 pts) — closest thematic neighbour of the run and genuinely good work (PowerShell 7 + Pode, Graph Reports API, SQLite, MIT). Dropped deliberately: it's another builder's free open-source launch in StorageScout's exact domain, and a reply from a paid-competitor founder reads as sniping no matter how cleanly it's disclosed. Same discipline the 08-18 and 08-24 runs applied to founder show-and-tells. If Uğur wants to engage here, the honest move is a GitHub issue or PR on the repo, not a Reddit comment.
- **r/sysadmin "Adobe Licensing Specialist Asking Us to Delete Unlicensed Users"** (t3_1vujyjg, 08-21, 120c, 464 pts) — resurfaced again with even more volume. Still Adobe Creative Cloud, not M365; still mostly venting rather than technical. Same drop reason as 08-24. **Stop re-checking this one.**
- **r/Office365 "Microsoft 365 Admin Portal is a Complete Cluster - Renewal Broken, Support Useless"** (t3_1vy0e5t, 08-25, 9c) — renewal-adjacent on the title, but it's a support-failure vent, and a commenter already surfaced the real cause (there was an admin-portal/renewal outage bulletin). Nothing SeatScout-shaped to add beyond "check Billing > Your products", which three people already said.
- **r/sysadmin "Another M365 issue?"** (t3_1vx4l38, 08-24, 29c, 42 pts) — the 08-24 M365 activation-token outage. Resolved same day, pure incident thread despite the "licensing token" wording.
- **r/microsoft365 "Microsoft 365 Licensing Changes 2026 Explained | E3, E5 & NEW E7"** (t3_1vx178n, 08-24) — YouTube link post, 1 comment, no discussion to join. The E7 SKU is worth tracking as a topic, though; it surfaced in the Entra licensing docs too. Flagging for content, not for reply.
- **r/entra "73 offboardings last year. the checklist was never the problem"** (t3_1vai6i4, 07-30, 2c) — right topic, but 27 days old and effectively dead.
- Remainder of the sweep was off-topic for M365 seat cost: Windows Server / Dell Unity / ShadowProtect / Business Central product keys, Intune enrolment and Windows Update Ring bugs, EXO mailbox and quota threads, MSP tooling (IT Glue vs Hudu, SIEM/MDR, CPOR), Meraki and network hardware quotes, and the usual career and AI-policy threads.

### Sources checked for this section
- `signInActivity` requires Entra ID P1/P2 and `AuditLog.Read.All`; not returned for users who never signed in or last signed in before April 2020; supports `$filter` but not alongside other filterable properties — [user resource type, Microsoft Graph](https://learn.microsoft.com/graph/api/resources/user?view=graph-rest-1.0#properties)
- `lastSuccessfulSignInDateTime` available from 1 Dec 2023, not backfilled — [signInActivity resource type](https://learn.microsoft.com/graph/api/resources/signinactivity?view=graph-rest-1.0)
- `Directory.Read.All` also required or the premium-license check errors intermittently — [Neither tenant is B2C or tenant doesn't have premium license](https://learn.microsoft.com/troubleshoot/entra/entra-id/users-groups-entra-apis/b2c-or-tenant-premium-license-sign-in-activities)
- NCE license-based seats: prorated refund / reduction only within seven calendar days of purchase; window reopens only at renewal — [Cancellation policy for the new commerce experience](https://learn.microsoft.com/partner-center/customers/new-commerce-cancellation-policy)
- Scheduled seat reductions require active subscription + autorenew on; turning autorenew off or changing quantity deletes saved scheduled changes — [Manage customer subscriptions](https://learn.microsoft.com/partner-center/customers/create-a-new-subscription#subscription-renewals)

## 2026-08-24

> First round (8 queries) confirmed the recurring connector bug again: combining `subreddit:X OR subreddit:Y OR ...` with a keyword phrase in the same `search_query` returns unfiltered r/all firehose junk (salamander care, dating advice, casino spam), not scoped results — same failure mode logged repeatedly since 08-11. Second round switched to single-subreddit-scoped queries (`subreddit:sysadmin license`, `subreddit:Office365 license`, `subreddit:msp license`, `subreddit:Intune license`, `subreddit:sysadmin copilot`, `subreddit:Office365 seats`, sort=new, no OR) — this returned real, correctly-scoped results. ~105 posts reviewed across r/sysadmin, r/Office365, r/msp, r/Intune since 08-20, cross-checked against the 85-entry seen-log. **Nothing new picked — quality bar not met this run.**
>
> **Reviewed and dropped:** r/sysadmin "Adobe Licensing Specialist Asking Us to Delete Unlicensed Users" (t3_1vujyjg, 438pts, 118c, 2026-08-21) — closest thing to a fit on volume, and thematically adjacent (vendor pressuring removal of unlicensed/unused seats, the exact SeatScout shape), but it's Adobe Creative Cloud licensing, not M365 — wrong vendor, and the thread itself is almost entirely jokes/venting about Adobe's reputation rather than technical discussion. Dropping on ecosystem discipline, same as prior Google Workspace drops. r/Office365 "20-30% of Copilot Licenses go unused" resurfaced again (already in seen-log, 08-19/08-20). Everything else in the sweep was non-licensing: Mac Office activation troubleshooting, mailbox/OWA/archive quota questions, Intune enrollment and device-inventory bugs, MSP tooling threads (IT Glue/Hudu, CPOR, hypervisors), AI-policy and Copilot-vs-Claude discussion (already seen 08-10), and a Gartner AI-governance hype-cycle link post.

## 2026-08-21

> Ran ~7 scoped `subreddit:X (keyword OR keyword...)` searches across r/sysadmin, r/Office365, r/msp, r/PowerShell, r/Intune, sort=new, week-to-month (r/PowerShell/Get-MgSubscribedSku widened to year since that phrasing is rare), covering license waste/cost, unused/unassigned seats, E5-vs-E3, offboarding/disabled-account/signInActivity, Copilot ROI, and Get-MgSubscribedSku scripting angles. Cross-checked every hit against the 84-entry seen-log. **Nothing new picked — quality bar not met this run.**
>
> **Reviewed and dropped:** r/Office365 "20-30% of Copilot Licenses go unused" and its 0-comment crosspost — the real thread was already surfaced 08-20 (seen-log), the crosspost is a duplicate with no discussion. r/entra's Conditional Access licensing thread crossposted to r/Office365 (t3_1vrrp72) — same story as the 08-19 entry, already seen. r/Intune "What licenses do I need for MDM Auto Enrollment" — OP already self-resolved (MDM authority misconfig, edited into the post) before I found it, no open angle left. r/msp "CPOR questions" — Partner Center solutions-partner credit mechanics, not seat-licensing waste, doesn't fit SeatScout's angle. Everything else in the sweep was off-topic for M365 seat waste specifically: VMware/Dell hardware pricing, Jamf-vs-Intune iPad licensing, Google Workspace (not M365) governance and EDU seat pauses, Business Central/Dell Unity product-key licensing, MSP margin/hypervisor/tooling threads, and Intune/Outlook bug reports with no cost angle.

## 2026-08-20

> Corrected the search connector's query syntax this run — `REDDIT_SEARCH_ACROSS_SUBREDDITS` has no `subreddits` array param (past runs' notes about "OR-sweeps" were passing a param the tool silently ignored, returning unfiltered r/all firehose junk). Actual schema takes one `search_query` string; multi-subreddit scoping has to go inline as `subreddit:X OR subreddit:Y` inside that string, and long compound queries with both subreddit-OR and keyword-OR return 0 hits (same connector quirk prior digests noted) — short, single-keyword-per-call queries work. Ran ~10 scoped searches across r/sysadmin, r/Office365, r/msp, r/PowerShell, r/Intune (license waste/unassigned, E5-vs-E3, disabled-account offboarding, Get-MgSubscribedSku, signInActivity, budget/spend, wasted/true-up), sort=new, week-to-month window, cross-checked against the seen-log. **One picked.**
>
> **Reviewed and dropped:** r/sysadmin "Office 365 license on RDSH" and "Recommendations for finding a new Microsoft CSP" resurfaced but are already in the seen-log (08-19, 08-14). Everything else in the sweep was non-licensing (Intune enrollment/PRT troubleshooting, EPM policy debugging, backup-tool cost comparisons unrelated to M365, AI-policy drafts, Windows Update errors, an "incompetent MSP" Windows Server licensing rant) or a subscription-deactivation billing dispute with no waste/audit angle.

### 1. r/Office365 — 20-30% of Copilot Licenses go unused
- **Age:** <1 day | **Comments:** 12 (unlocked, active discussion through today)
- **Link:** https://www.reddit.com/r/Office365/comments/1vstt8b/2030_of_copilot_licenses_go_unused/
- **Why it fits:** Directly on SeatScout/PilotScout's core thesis — unused Copilot seats still billed. Genuine back-and-forth in the comments (not just OP's post): one commenter (7eregrine) says he manually checks licenses monthly and removes "dead weight"; others debate whether it's a training gap or a product-quality gap. Note: the OP (IgniteAISolutionsUK) reads as a consultant's content-marketing post, not a real user question — reply to the thread's actual discussion, not to OP's pitch.
- **Suggested angle:** Build on 7eregrine's manual process with the automatable version: pull `Get-MgSubscribedSku` for purchased-vs-consumed Copilot counts, then cross-reference Entra ID sign-in/usage activity (needs P1) to flag seats with zero Copilot prompts in 30-60 days — that's the real waste number, separate from the "is Copilot good" debate the thread is having. Disabled/departed-employee accounts are the other common leak since license removal isn't automatic. Disclosure: I built PilotScout for exactly this scan if it comes up naturally.

## 2026-08-19

> Targeted `subreddit:` OR-sweeps across r/sysadmin, r/Office365, r/msp, r/PowerShell, r/Intune (license waste/cost, E5-vs-E3, true-up/renewal, seat-utilization, offboarding, signInActivity/Get-MgSubscribedSku phrasings), time-boxed to the last week/month since the 08-17 run (08-18 had nothing new). Long compound-OR queries against "seat utilization / license reclamation / right-size" and r/PowerShell-specific M365 queries returned zero hits — thin week again. **Two picked, both genuinely fresh (posted 08-18, both still open).**
>
> **Reviewed and dropped:** the rest of the sweep was non-licensing troubleshooting (Outlook signature bug, AVD sign-in errors, RDS CAL upgrades, backup-tool cost comparisons unrelated to M365), general career/AI-policy threads, or already in the seen-log (r/sysadmin "AIP P1 renewal", "August 2026 Updates roundup", r/msp "Clients with field employees").

### 1. r/sysadmin — Office 365 license on RDSH
- **Age:** <1 day | **Comments:** 13 (unlocked, active — last reply ~08-18 evening)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vrq9uu/office_365_license_on_rdsh/
- **Why it fits:** OP says outright: "I am doing the fun job of auditing our Microsoft licenses... trying to decide if we are wasting any of it." Question is narrowly about Business Premium (with Shared Computer Activation) vs Enterprise for Office apps on an RDSH cluster. Existing replies already nailed the SCA/GPO answer (Business Premium works, some GPOs are Enterprise-only) — the audit-methodology half of OP's stated goal is still untouched.
- **Suggested angle:** Once the app-tier question is settled, note that on an RDSH audit the bigger waste lever usually isn't SKU tier parity, it's seat assignment: pull `Get-MgSubscribedSku` for purchased-vs-consumed counts, and check `signInActivity` on the RDSH-only accounts (needs Entra ID P1) — disabled or never-signed-in accounts on Business Premium are billed the same as active ones. Worth saying explicitly since OP is already deep in m365maps-style tier comparison and may not have gotten to the seat-count half yet. If mentioning SeatScout: "disclosure: I built a tool for this" — the advice holds without it.

### 2. r/entra (crossposted to r/Office365) — Calculating the Licensing Requirement for Entra Conditional Access Policies
- **Age:** <1 day | **Comments:** 1 on r/entra original, 0 on the r/Office365 crosspost — very fresh, low competition
- **Link:** https://www.reddit.com/r/entra/comments/1vrroy8/calculating_the_licensing_requirement_for_entra/ (crosspost: https://www.reddit.com/r/Office365/comments/1vrrp72/calculating_the_licensing_requirement_for_entra/)
- **Why it fits:** A well-known M365 blogger (office365itpros) shares a PowerShell script that reconciles Conditional Access policy conditions against Entra P1-licensed users, to find accounts that need a P1 license added — i.e., closing a compliance gap. Same `Get-MgSubscribedSku`/CA-licensing territory SeatScout operates in, just the opposite direction (under-licensed, not wasted spend).
- **Suggested angle:** Genuine technical add, not a pitch: note the same reconciliation logic run in reverse also surfaces the opposite problem — P1/P2 licenses still assigned to accounts no longer covered by any CA condition (offboarded, role-changed, disabled), which is reclaimable spend sitting next to the compliance gap the script already finds. A one-line suggestion to extend the script's set comparison the other direction is useful on its own; no product mention needed here unless it comes up naturally.

## 2026-08-18

> Broad `subreddit:` sweeps across r/sysadmin, r/Office365, r/msp, r/PowerShell, r/Intune (single-term and short-OR queries; long compound OR queries returned zero hits again — same connector quirk noted before, keep queries short). ~110 posts reviewed across the past month, cross-checked against the seen-log and the 08-17 digest picks. **Nothing new picked — quality bar not met this run.**
>
> The three threads that would have looked promising on title alone are all yesterday's picks re-appearing in the search index (r/msp "Clients with field employees" t3_1vp2u5d, r/sysadmin "AI deployment path discussion" t3_1vmakpl, r/msp "Onboarding vs Project work" t3_1vlbgjz) — already in reddit-digest-seen.md, correctly skipped.
>
> **Reviewed and dropped, with reasons:**
> - **"What licenses do I need for MDM Auto Enrollment with Intune?"** (r/Intune, t3_1vpelmd, 3d, 12c) — same one 08-17 already dropped for the same reason: OP edited the post, issue was an MDM-authority misconfig, not a licensing question. Still resolved, still noise.
> - **"[Rust/WASM] Streaming a 1 GB Microsoft CSP reconciliation CSV..."** (r/sysadmin, t3_1vndco5) — third run in a row this one surfaces in search. Still another founder's tool show-and-tell (OP confirms in-thread the writeup went through an LLM for structure), still not a licensing-advice thread. Stop re-checking this one; it will not become a fit.
> - **"How should a 20-person growth company think about IT?"** (r/sysadmin, t3_1vqw2c9, 1d, 74c) — real CFO, real budget-and-governance question, active discussion. Wrong ecosystem: they're on Google Workspace/Drive, not M365, so an M365 licensing-hygiene angle (and any SeatScout mention) doesn't fit without being a platform pitch. Skipped on topic discipline, not quality.
> - Everything else from this sweep was either non-M365 (VMware/hardware pricing, Papercut, Tenable, backup tooling), already-resolved troubleshooting threads, or too far from a licensing-cost angle to carry a real reply.
>
> No fresh, on-topic, unseen thread cleared the bar today. Re-run tomorrow; the standing E5/E3/storage/Copilot-cost threads mostly seem to have cycled out of the ~month search window already.

## 2026-08-17

> 11 queries across 3 rounds, all subreddit-scoped with the inline `subreddit:` operator (no repeat of the 08-14 `restrict_to_subreddits` mistake). After the seen-log and a ~10-day cut: ~60 unseen threads, 5 read in full (post + top comments). **Three picked; none locked or archived.** Thin week for pure licensing-cost threads — the seen-log has absorbed most of the standing E5/E3 and storage threads, and the new crop skews career/hardware.
>
> **Deliberately dropped, with reasons:**
> - **"What licenses do I need for MDM Auto Enrollment with Intune?"** (r/Intune, t3_1vpelmd, 2d, 12c) — best topical fit of the run on paper, but OP edited the post: "I figured it out… MDM authority was not set to Intune." Resolved thread; a reply now is noise.
> - **"Incompetent MSP?"** (r/sysadmin, t3_1vp48mf, 2d, 33c, 0pts) — Windows Server Datacenter down-edition keys, so server licensing, not M365 seats; OP is being piled on for a least-privilege misconception and the thread is hostile. Nothing to win there.
> - **"Microsoft 365 Lighthouse won't let me access users"** (r/msp, t3_1vqcznw, <1d, 4c) — fresh and answerable (GDAP role assignment + Lighthouse's per-tenant license prerequisites), but it's admin config, not license cost. Left out on topic discipline; fine as a manual reply if you want an easy early answer today.
> - **"[Rust/WASM] Streaming a 1 GB Microsoft CSP reconciliation CSV"** (t3_1vndco5) — dropped again, same reason as 08-14: another founder's show-and-tell.
> - **"PSA: Google has paused additional free EDU Workspace licenses"** (t3_1vqixwo) and **RVTools/Broadcom renewal checklist** (t3_1vq7d76) — licensing cost, wrong ecosystem (Google / VMware).
>
> **Pricing caution (same rule as 08-14):** no list prices asserted below. F3-vs-Business-Premium deltas and GoDaddy markups change; pull the numbers from your own admin center / CSP sheet before posting them.

### 1. r/msp — Clients with field employees
- **Age:** ~2 days | **Comments:** 41 (unlocked, active — comments still arriving within the last 24h)
- **Link:** https://www.reddit.com/r/msp/comments/1vp2u5d/clients_with_field_employees/
- **Why it fits:** Healthcare client, 15 office users on Business Premium, 60 field users going onto F3, phones only. This is seat-tier right-sizing at 4:1 scale — SeatScout's exact ground. The thread has drifted to MSP pricing tiers; nobody has actually laid out what F3 *includes* technically, which is the half of OP's question (securing company data on personal phones) still open.
- **Suggested angle:** F3 carries Intune Plan 1 and Entra ID P1, so the BYOD gap OP describes is closable without touching personal devices: App Protection Policies (MAM without enrollment) on Teams/Outlook/Office mobile, plus Conditional Access requiring protected apps — no device enrollment fight with field staff. State the honest caveats: F3's small mailbox/OneDrive caps and no desktop Office apps, which is fine for phone-first CNAs but should be said out loud before someone expects laptop parity. Close with the cost hygiene point: because F3 includes Entra ID P1, `signInActivity` works — re-audit quarterly, since field-staff seats that never activate are pure waste to hand back at renewal. One commenter (xtc46) already ties the MSP support tier to the license type; you can second that with the licensing mechanics underneath it. If you mention SeatScout, disclose plainly: "disclosure: I built a tool that flags never-signed-in licensed users." The advice stands without the mention.

### 2. r/sysadmin — AI deployment path discussion.
- **Age:** ~5 days | **Comments:** 15 (unlocked, active into 08-13; 0pts but the discussion is real — includes one long Microsoft-partner reply)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vmakpl/ai_deployment_path_discussion/
- **Why it fits:** Solo IT at a nonprofit healthcare Microsoft shop, weighing self-hosted LibreChat + API against buying Copilot licenses because org-wide Copilot "seems much cheaper" to avoid. That premise — don't buy seats you can't prove people will use — is PilotScout's core loop.
- **Suggested angle:** Split the decision the thread is blurring. (a) Copilot Chat is already included with their M365 licenses at no extra cost and carries Enterprise Data Protection — for appointment-notes-grade usage that may be the whole answer. (b) If they want tenant-grounded M365 Copilot, don't license org-wide: pilot a small group, then read the Copilot usage report in the admin center and buy only for proven users; nonprofit pricing exists, so quote from the nonprofit portal, not list. (c) Healthcare-specific and unsaid in-thread: whatever path, the BAA story decides it — M365 Copilot sits under Microsoft's existing DPA/BAA, while LibreChat + third-party model APIs each need their own agreement, and that compliance overhead is a real cost the "cheaper" math omits. If you mention PilotScout: "disclosure: I built a tool that audits Copilot seat usage."

### 3. r/msp — Onboarding vs Project work - where to draw the line?
- **Age:** ~6 days | **Comments:** 39 (unlocked, active over several days)
- **Link:** https://www.reddit.com/r/msp/comments/1vlbgjz/onboarding_vs_project_work_where_to_draw_the_line/
- **Why it fits:** Two insurance agencies on GoDaddy-managed M365 need defederation plus tenant build-out. The billing question (charge it as a project) is settled in-thread; the M365 licensing mechanics — the part a 20-hour estimate lives or dies on — are barely touched beyond one commenter's list of GoDaddy pain points.
- **Suggested angle:** Add the license side the quotes miss: GoDaddy-resold seats don't transfer — they're repurchased direct/CSP at cutover, so new licenses must be staged and assigned immediately after defederation or mail and OneDrive access breaks mid-migration. Practical sweetener for OP's client conversation: pull the current GoDaddy per-seat invoice and compare it line-by-line with CSP pricing — the resale markup, priced over a year, often funds a chunk of the project fee. And cutover is the cheapest moment to right-size: audit unassigned and never-signed-in accounts *before* repurchasing rather than mirroring the old seat count into the new tenant. Disclosure line if SeatScout comes up.

## 2026-08-14

> 14 queries across 3 rounds. **Round 1 was wasted:** I passed `restrict_to_subreddits` as a parameter and the connector silently ignored it, returning threads from r/srilanka, r/Biohacking and r/EasyTakeoffs. That parameter does not exist on `REDDIT_SEARCH_ACROSS_SUBREDDITS` — the only way to scope a subreddit is the inline `subreddit:` operator inside `search_query`, exactly as the 08-11 note said. Cost one round; noted again so it stops recurring.
>
> After the seen-log and an 11-day cut: 75 fresh unseen threads, 5 read in full (post + all top comments). **Four picked; none locked or archived.** Two licensing claims verified against Microsoft Learn before writing the angles (#1/#2 share the verification).
>
> **Read the warning on #1 and #2 before you post.** They are the same story in the same subreddit 24 hours apart, and they are the two best threads of the run. **Pick one, not both.** Two replies from your account on near-identical Entra-licensing threads in r/entra inside a week reads as campaigning, and this is the exact topic where you have a commercial interest. If forced to choose: **#1**, because the "evaluated vs targeted" gap is a real technical error in Microsoft's own blade and nobody in the thread has said it.
>
> **New theme worth tracking:** Microsoft has started surfacing an Entra ID P1/P2 *licensing overage* banner on the Conditional Access page. This is the first time Microsoft itself is telling admins they are under-licensed for a feature they already switched on — the mirror image of SeatScout's pitch (over-licensed for seats nobody uses). Expect a wave of these threads over the next month. Being early and technically correct here is worth more than any launch post.
>
> **Deliberately dropped, with reasons:**
> - **"Best way to extend SharePoint storage?"** (r/microsoft365, t3_1vm5dwq, 3d, 20c) — StorageScout's exact ground and OP is a Business Premium tenant blowing past pooled 2TB. **Dropped:** 20 comments have already covered version history limits, automatic versioning, PnP cleanup, archiving, the Preservation Hold Library and per-GB pricing. Nothing left to add but a product link, and a link into a fully-answered thread is just an ad.
> - **"PSA Regarding CIPP Hosted - its amazing"** (r/msp, t3_1vnl7wa, 1d, 38c, 42pts) — high traffic, right audience, but it's a satisfied-customer PSA about hosting performance. No licensing question to answer; showing up with a different tool is a hijack.
> - **"Recommendations for finding a new Microsoft CSP"** is kept as #3, but note the pattern in it: three of five replies are vendors pitching themselves and asking for DMs. Your reply is only worth posting if it is the one non-pitch in there. Do not add a fourth pitch.
> - **"[Rust/WASM] Streaming a 1 GB Microsoft CSP reconciliation CSV"** (r/sysadmin, t3_1vndco5, 1d, 6c) — licence-billing reconciliation, so topically adjacent, but it's another founder's show-and-tell about his own tool. Two tool authors in one thread helps neither.
> - **"Entra Admin Center Flags Licensing Problems with Conditional Access"** (r/Office365, t3_1vn5sxp) — the empty crosspost dropped on 08-13. Still 2 comments, still nothing to answer. The r/entra original is #2 below.
> - **"Why Is Business Standard + Copilot Cheaper Than Business Basic + Copilot?"** is kept as #4 but it is the weakest of the four — see the note in its entry.
> - Tenant-deauthenticated megathread (445c), VMware/hardware price hikes (407c), BYO laptop (240c) — dropped again, same reasons as prior runs.
>
> **Pricing caution:** no list prices asserted anywhere below. Every number is either a commenter's own claim (labelled) or a placeholder for your own admin centre / CSP sheet. Price it yourself before you post it.

### 1. r/entra — New license compliance warning on the CA page
- **Age:** ~3 days | **Comments:** 3 (unlocked, active, OP is a known blogger and is answering)
- **Link:** https://www.reddit.com/r/entra/comments/1vmfp7x/new_license_compliance_warning_on_the_ca_page/
- **Why it fits:** This is purchased-versus-consumed reconciliation, which is literally your product's core loop — only pointed at Entra ID P1 instead of M365 seats. OP has already spotted the important flaw ("the license usage blade shows *evaluated* users, not *targeted* users") but the thread's only open technical question — whether shared mailboxes count — is answered loosely and half-wrong.
- **Suggested angle:** Sharpen the evaluated-vs-targeted point with the licensing rule underneath it, because that rule is what makes the blade's number the wrong one to budget against. Microsoft's Conditional Access licensing page says P1 is required **for each user targeted by a policy**, and the Entra licensing fundamentals rule is that a licence is assigned **per user object, not per human** — so one person operating a standard account plus a separate privileged account inside CA scope is two P1s, not one. That's the answer to the shared-mailbox sub-thread too: the mailbox itself never authenticates, so it isn't the licensable object — the delegated *user accounts* reaching it are, and they need P1 if CA is enforced on them. Practical close: a policy scoped to All users with exclusions still evaluates far fewer accounts than it targets in any given window, so the blade under-reports; do the count from the policy assignment side (targeted groups minus exclusions, resolved to accounts) and compare it against `Get-MgSubscribedSku` P1/P2 **prepaidUnits vs consumedUnits**, then multiply the gap by your own per-seat rate off the CSP invoice. One more thing nobody has mentioned that admins will want to know: per Microsoft's own doc, when CA licences lapse the policies are **not** auto-disabled or deleted — you can view and delete them but not update them. Your product does the same purchased-vs-consumed reconciliation for M365 seats, so **if you mention it, disclose plainly: "disclosure: I build a tool that does this for M365 seats."** The advice above stands on its own without the mention, which is the better version of this reply.

### 2. r/entra — Entra Admin Center Flags Licensing Problems with Conditional Access
- **Age:** ~1 day | **Comments:** 11 (unlocked, active, OP replying to everyone)
- **Link:** https://www.reddit.com/r/entra/comments/1vn5sfq/entra_admin_center_flags_licensing_problems_with/
- **Why it fits:** Same banner as #1, but the live question here is the one you can answer best: u/Nate379 asks what happens to **unlicensed admin accounts** that are deliberately kept separate from their owner's licensed account. OP's guess is right in outcome but hedged ("my bet is..."), and u/WeirdSysAdmin's "you're supposed to license them with EMS" is directionally right but unsourced.
- **Suggested angle:** Confirm it with the citation instead of a guess. Entra licensing is per user object, and the governing rule is "each user that benefits from a feature must be licensed" — so a secondary admin account whose sign-ins are evaluated by CA policies needs its own P1, and the fact that a licensed human owns it changes nothing. Then the genuinely useful nuance for this exact scenario: **break-glass accounts that are properly excluded from every CA policy are not being protected by CA and so aren't in scope** — which is a decent argument for keeping the exclusion tight and documented rather than quietly leaving admin accounts in scope unlicensed. Also worth flagging that this cuts the other way and in your favour: admins about to buy P1 for every account should first check `Get-MgSubscribedSku` for P1 entitlement they already own inside suites (Business Premium includes CA features per Microsoft's licensing page), because a chunk of tenants are already covered and don't know it. **Only post this if you skipped #1** — see the warning at the top of this section.
- **Note:** the OP is an office365itpros author and the post is an article link. Standard practice in r/entra, and the discussion is real, but keep your reply about the technical question, not the article.

### 3. r/sysadmin — Recommendations for finding a new Microsoft CSP
- **Age:** ~1 day | **Comments:** 5 (unlocked, brand new, four of five replies are vendors pitching or asking for DMs)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vnpnyb/recommendations_for_finding_a_new_microsoft_csp/
- **Why it fits:** 150 users, west coast US, currently at ~10% under Microsoft direct, moving CSP because of **billing errors** and slow support. Everyone is answering "which CSP" and nobody is answering the thing that actually determines his bill. This is your ground: you cannot tell whether a CSP's billing is wrong without a purchased-vs-assigned reconciliation, and a transfer is the one moment when the seat count gets re-baselined.
- **Suggested angle:** Give him the pre-transfer checklist nobody offered. First, before he asks anyone for a quote, pull `Get-MgSubscribedSku` and compare **prepaidUnits.enabled against consumedUnits per SKU** — that delta is exactly the class of thing his current CSP's billing errors would be hiding, and it's also the number every new CSP will quote him against. If he's paying for more seats than are assigned, a transfer at the wrong count locks the waste in for a whole term. Second, cross-check assigned seats against real usage: `signInActivity.lastSuccessfulSignInDateTime` on the user object shows who genuinely hasn't signed in — worth telling him that this property needs Entra ID P1/P2 and the `AuditLog.Read.All` permission, since a Business Standard tenant will just get an error and think the API is broken. Third, the trap specific to his situation: **a disabled account still consumes its licence** — disabling on offboarding does not stop the billing, only removing the licence assignment does, so his "150 users" is likely a smaller number of actual working humans. Fourth, transfer mechanics, backing u/Artistic_Lie4039's caveat: NCE subscription terms don't reset on transfer, and the outgoing partner can refuse or delay the request, so time it against his renewal anniversary rather than mid-term. u/Artistic_Lie4039's 12–15% figure is his own pitch, not a market rate — the discount is worth less than getting the seat count right. No product mention needed here; if you add one, disclose it plainly.

### 4. r/microsoft365 — Why Is Business Standard + Copilot Cheaper Than Business Basic + Copilot?
- **Age:** ~5 days | **Comments:** 4 (unlocked, not archived, but effectively answered — see note)
- **Link:** https://www.reddit.com/r/microsoft365/comments/1vkwtug/why_is_business_standard_copilot_cheaper_than/
- **Why it fits:** PilotScout's territory — a buyer about to add Copilot seats on top of the wrong base SKU. u/cotd345 has the pricing mechanic (a 1-year promo on Basic+Copilot, not the ongoing rate) and u/Accomplished_Dot1445 has the reason (Copilot's real value lives in desktop Office, which Basic doesn't include).
- **Suggested angle:** Thin margin here, so only post if you can add the part both answers skipped: **the renewal cliff is the whole story, and it compounds.** A 1-year promo price on a Copilot add-on means year two reprices at standard rate on a seat count he will by then have grown into, and Copilot add-ons are the SKU most likely to be over-bought early and under-used — so the number to plan for is not the promo delta but standard-rate × the seats still actually in use at renewal. Practical follow-through: whatever he buys, set a calendar check at month 3 and pull Copilot **assigned vs active** usage from the M365 admin centre usage reports before the anniversary, because unassigning an idle Copilot seat mid-term does not refund it — the only cheap moment to right-size is the renewal. And confirm his quote's term and whether the promo applies to renewal in writing. If this is where you mention PilotScout, disclose it: "disclosure: I built a tool that reports Copilot seat usage." **Honest read: this thread is 5 days old with 4 comments and the question is answered — lowest priority of the four. Skip it if you only have time for one reply today.**

## 2026-08-13

> 15 queries across 3 rounds. The inline `subreddit:` filter documented on 08-11 worked first time this run — no wasted round. 353 unique threads returned, 68 fresh-and-unseen after the seen-log and an 11-day cut, 6 candidates fully read (post body + all top comments). **Four picked; none locked or archived.** Two licensing claims verified against Microsoft Learn before writing the angles (#1 and #2).
>
> Honest read: **thin again, and skewed old.** Only #1 is both fresh and squarely on topic. #2 and #3 are 12–13 days old, outside the usual window — included because both are strongly on-topic, under-answered, and #2 has a flatly wrong answer sitting in it that Microsoft's own doc contradicts. If you only have time for one today, do #1: it is a live licence-sizing decision for 75 seats with the buyer asking "how would you price this?" out loud.
>
> **Deliberately dropped, with reasons:**
> - **"How do you handle canceling software seats when someone leaves?"** (r/sysadmin, t3_1vdp47s, 10d, 69c) — topically this is SeatScout's thesis statement verbatim ("we'd been paying for seats belonging to people who left months ago, it just kept quietly billing") and it was the first thing I picked up. **Dropped on purpose:** a commenter has publicly accused OP of running vendor market research ("You posted this in different subs today and don't respond"), and OP has replied to nobody in 69 comments. You showing up there as the founder of a licence-audit tool reads as exactly the thing being accused. Not worth the association.
> - **"AI deployment path discussion"** (r/sysadmin, t3_1vmakpl, 0d, 15c) — Copilot licensing, fresh, PilotScout's ground. But four commenters have already covered nonprofit grant pricing, the M365 Copilot vs Copilot Chat split, and the Enterprise Data Protection doc. Little left to add and it's drifting into model choice. Re-check if OP comes back with a concrete SKU question.
> - **Inuvika OVD VDI licensing pair** (t3_1vlhdad r/msp, t3_1vlhj02 r/sysadmin) — same call as 08-11: QMTH and Windows Server activation, not M365 seats.
> - **Entra Connect mass-disable lockout** (r/sysadmin, t3_1vn3inw, 68c) — disabled accounts do keep consuming licences, but raising that while someone is locked out of their own tenant is tone-deaf. Skip.
> - **"Entra Admin Center Flags Licensing Problems with Conditional Access"** (r/Office365, t3_1vn5sxp, <1d) — link-only crosspost from r/entra, empty body, 1 comment. Nothing to answer yet; worth a re-check tomorrow if it grows.
> - VMware/hardware price hikes (401c), tenant-deauthenticated megathread (449c), MemberOf retirement (249c), CIPP frustration (103c) — all dropped again for the same reasons as prior runs.
>
> **Pricing caution:** commenter figures below are quoted as *their* claims and labelled as such. No list prices asserted. Price everything against your own admin centre / CSP sheet before you post a number.

### 1. r/msp — Recommendation for secure communication platform for home health care field staff?
- **Age:** ~1 day | **Comments:** 39 (unlocked, active, several partial answers, no consensus)
- **Link:** https://www.reddit.com/r/msp/comments/1vm0seb/recommendation_for_secure_communication_platform/
- **Why it fits:** An MSP sizing licences for 15 office staff + 60 field CNAs/nurses who are currently on WhatsApp, and he ends the post with "how would you price something like this?" That is a live 75-seat licensing decision asked out loud. The thread has thrown out F3, Business Basic, Business Premium and nonprofit pricing, but **nobody has drawn the F1-vs-F3 line**, which is the entire decision for 60 mobile-only users who "don't really need email."
- **Suggested angle:** Give him the line nobody drew, from the Microsoft Learn E-to-F comparison. **F1 has no Exchange mailbox rights at all** — an Exchange Kiosk plan is provisioned purely to light up the Teams calendar, and Microsoft explicitly recommends disabling Outlook on the web for F1 users. F1 is also *read-only* in the web and mobile Office apps. **F3** gets a 2 GB mailbox (Outlook on the web only, no Outlook desktop) and full web/mobile editing. Both give full Teams chat/meetings/channels and 2 GB OneDrive; neither includes desktop Office, and F-plan mobile apps are limited to screens under 10.9 inches — which matters if any nurse carries a tablet. So "they don't need email" maps cleanly to F1, but the moment a nurse must edit a doc or hold a real mailbox it's F3, and re-licensing 60 people later is worse than getting it right now. Second point, backing u/PacificTSP: his claim that F3 carries Entra ID P1 and Intune is the strongest argument against a standalone chat app — the MDM and Conditional Access you'd otherwise buy separately are already inside the SKU. (Microsoft's Autopilot requirements page lists F1/F3 as satisfying the Entra ID + MDM requirement on their own, which supports that; confirm on the Modern Work plan comparison sheet before you state it flatly.) Close with the thing that actually costs MSPs money here: 15 office and 60 field are **two different user types**, and the expensive mistake is putting all 75 on one tier "to keep it simple." u/terselated's $6–7/nurse/month for Business Basic is his number, not a quote — price F1 and F3 against your own CSP sheet. Pure advice; no product mention needed, so no disclosure required.

### 2. r/sysadmin — Autopilot Costs
- **Age:** 12 days (older than the usual window — flagged) | **Comments:** 27 (unlocked, not archived, no accepted answer, OP never marked resolved)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vbk3ci/autopilot_costs/
- **Why it fits:** Pure entitlement-versus-cost confusion, which is your ground: "if you have certain Microsoft 365 licences then it's basically free. But only a small number of our users have these licences." And there is a **flatly wrong answer sitting in the thread** that Microsoft's own doc contradicts — u/Sasataf12 says "Autopilot is free. No license needed." u/L-xtreme's reply is the closest to correct but doesn't cover the standalone route.
- **Suggested angle:** Correct it with the citation, politely, since the wrong answer is the one a skimmer will take. Microsoft's Windows Autopilot requirements page lists Autopilot as requiring **one of**: M365 Business Premium; M365 F1 or F3; Academic A1/A3/A5; Enterprise E3/E5; EMS E3/E5; Intune for Education; **or** Entra ID P1/P2 plus an Intune subscription. Same page carries the note that matters for his case: when an M365 subscription is used, licences still have to be *assigned to users* before they can enrol devices in Intune. So there is no per-device Autopilot SKU and never has been — and the answer to the $X-per-device question he was hoping for is that option 7 (Entra ID P1 + Intune Plan 1 standalone) is the cheap path for users who don't otherwise need an M365 suite. Then the point that's actually his problem: the licence follows the **user**, not the laptop, so the number he needs to budget is how many *distinct people* will receive an Autopilot-provisioned device — not how many machines he images per year. Worth adding that a `Get-MgSubscribedSku` purchased-vs-consumed pass usually shows an org is closer to covered than it assumed, because suites bought for other reasons already carry the entitlement. Pure advice; no product mention needed.

### 3. r/sysadmin — Email Signatures Managed - What Are You Using and Cost?
- **Age:** 6 days | **Comments:** 22 (unlocked, active, lots of tool names, nobody answered the licensing half)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vgsxsg/email_signatures_managed_what_are_you_using_and/
- **Why it fits:** OP asked three things — what tool, "what they are paying **per mailbox**", and "**how licensing works**." Twelve replies name tools and two quote real numbers (u/JCochran84: CodeTwo ~$3k/yr for 300 users; u/almightyloaf666: Signitic ~$1/user — both their figures, not verified). **Nobody addressed the per-mailbox question**, which is precisely where this category leaks money.
- **Suggested angle:** Answer the half of his question everyone skipped. Signature platforms bill per mailbox, and "mailbox" in a vendor's counting is not the same object as "licensed user" — the connector typically sees shared mailboxes, room and equipment mailboxes, and the mailboxes of departed staff that were converted to shared instead of deleted. So before comparing $1/user against $3k/year, get the number you'll actually be invoiced on: count licensed user mailboxes, count shared/room/equipment separately, then **ask each vendor in writing which of those categories they count**, because the answer differs by vendor and it's the difference between a 300-seat quote and a 380-seat quote. On his GCCH bonus question: confirm the vendor operates in GCC High specifically, not just "FedRAMP authorised" — most cloud signature services work by routing mail through their own service, and that routing is the part that trips in GCCH. Also worth endorsing: u/AshleyDodd's and u/--RedDawg--'s DIY answers (`Set-MailboxMessageConfiguration` for OWA/new Outlook plus a login-context script for Outlook classic) are legitimate at his size and cost nothing per mailbox. No product mention needed.

### 4. r/sysadmin — Microsoft MFA just for Office - any other options?
- **Age:** 13 days (oldest here — the MFA question is effectively answered, expect low visibility) | **Comments:** 9 (unlocked, not archived)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vapylj/microsoft_mfa_just_for_office_any_other_options/
- **Why it fits:** The single best licensing-waste story in the batch. A Google Workspace shop carrying **180 Microsoft 365 Apps for Business seats** attached to `first.last@company.onmicrosoft.com` addresses that, in OP's own words, "have no use beyond validating our subscription." The thread correctly solved the MFA question and then stopped — **nobody asked whether he should be paying for 180 subscription seats at all.**
- **Suggested angle:** Agree with the federation answers first so you're adding rather than contradicting — u/Neat_Smart named the actual mechanism (federate, then set `federatedIdpMfaBehavior` to `acceptIfMfaDoneByFederatedIdp` so Entra trusts Google's MFA instead of enforcing its own), and that is the right fix for the ticket wave he's dreading. Then make the observation nobody made: he is describing 180 recurring per-user subscriptions whose entire job is to activate a desktop app for people who never sign into the tenant. Two commenters gestured at perpetual licensing without naming it — the specific answer is **Office LTSC** under volume licensing with KMS/MAK activation, which needs no per-user identity, which means no MFA prompt and no `onmicrosoft.com` accounts to maintain. Give him both sides honestly, because this is a spreadsheet exercise and not a slam dunk: LTSC is a frozen feature set with no cloud services and a shorter support tail per release, and the capex over a 3–5 year horizon may or may not beat 180 subscription seats depending on his refresh cycle. The framing worth handing him is that his MFA problem and his licensing problem are the same problem — he's paying a subscription to maintain identities he doesn't want to exist. Pure advice; no product mention needed, and resist adding one here.

## 2026-08-12

> 16 queries across 3 rounds (first round wasted again on the missing `subreddit:` filter — see 08-11 note; the connector's search tool ignores `restrict_to_subreddit`, the sub list **must** go inside `search_query`). ~75 unique threads reviewed, 8 skipped via seen-log. **Four picked; post bodies + comments fetched and read on all four, none locked or archived.** One licensing claim verified against Microsoft Learn before writing the angle (see #1).
>
> Honest read: **licensing-specific volume is still thin, but #1 is the best single thread in a week** — a live licensing-compliance misunderstanding where the OP's premise is wrong, three commenters are partly right, and nobody has cited the actual doc. That's the cheapest possible value-add. #2 is a whole post about *avoiding* Exchange licences on admin accounts — SeatScout's exact subject matter — and it's a day old with only weak answers. #3 is the weekly vendor-pricing megathread which explicitly invites Microsoft CSP licensing questions; low effort, recurring, worth being a known face in. #4 is adjacent (security tooling) but has a real "you may already be paying for this" angle nobody has stated plainly.
>
> Deliberately dropped: the VMware/hardware price-hike thread (393 comments, on-prem not M365), the tenant-deauthenticated megathread (450 comments, still running), MemberOf retirement (247 comments), "CIPP - Why is it so frustrating?" (103 comments, setup-pain rant not cost — same call as 08-10), the Inuvika/VDI licensing pair in r/sysadmin + r/msp (Windows Server / RDS CAL and QMTH territory, not M365 seats, and the r/msp copy was auto-filtered by the karma bot), and "Time to get a new license I guess.." in r/Office365 (empty body, zero comments — nothing to answer).
>
> **Pricing caution:** no list prices are quoted below on purpose. Price everything against your own admin centre / CSP invoice before you post a number.

### 1. r/Intune — Able to use Remote Help with just the F3 License?
- **Age:** ~1 day | **Comments:** 9 (unlocked, active, answers partially right but unsourced)
- **Link:** https://www.reddit.com/r/Intune/comments/1vlcr06/able_to_use_remote_help_with_just_the_f3_license/
- **Why it fits:** This is the exact failure mode SeatScout exists for, inverted: a feature that *works* for a user who isn't entitled to it. OP believes Remote Help is included in E3/E5/EMS (it isn't), and is surprised an F3-only user can launch it. Two commenters correctly say tenant-level enablement ≠ per-user entitlement, but nobody has cited the doc or named the compliance exposure. Verified before writing this: Microsoft Learn states Remote Help "requires a subscription in addition to Microsoft Intune Plan 1 or Plan 2" and needs "a Remote Help license for everyone targeted to use the service — both helpers and sharers."
- **Suggested angle:** Correct the premise first — Remote Help isn't included in E3/E5/EMS at all; it's a standalone add-on to Intune or part of the Intune Suite (only the Education A-SKUs bundle it). Then explain the behaviour: the tenant toggle under Tenant administration > Remote Help flips on once *any* eligible licence exists, and Microsoft doesn't hard-block per user at session time, so an F3 user can connect while being unlicensed for it. The compliance point that nobody has made: the doc requires the licence for helpers *and* sharers, so if his helpdesk supports 300 F3 users, that's 300 add-on seats at true-up, not one. Practical close: pull who's actually used it from the Remote Help audit/monitor report, compare against the add-on seats you own, and decide deliberately — buy for the real population, or turn the tenant toggle off and use Quick Assist (no licence) for the F3 tier. Pure advice; no product mention needed, so no disclosure required.

### 2. r/sysadmin — 365 Elevated account as alias on regular to get mail? Some don't work due to conflict
- **Age:** ~1 day | **Comments:** 12 (unlocked, active, no accepted answer yet)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vlhza5/365_elevated_account_as_alias_on_regular_to_get/
- **Why it fits:** The entire post is a licence-avoidance design for privileged accounts — "to avoid giving our elevated accounts Exchange licences, we created SMTP aliases" — plus a real Entra Connect breakage (three accounts failing with duplicate proxyAddress, almost certainly because they *used* to hold Exchange licences). Both halves are your ground. Existing replies are scattered: shared-mailbox suggestions with no detail on the duplicate-attribute fix, one commenter who admits their approach "doesn't solve your license avoidance goal", and one off-topic third-party alias plug.
- **Suggested angle:** Give him the answer that solves both halves at once. Shared mailboxes are the right destination — they need no licence under the size cap, and they can be delegated to the regular account so mail from the cloud service lands where he wants without a second licence. For the three broken ones: the duplicate proxyAddress is stale metadata, so re-licensing and deleting the SMTP entry from the mailbox is a loop; the fix is at the source object — clear the residual proxyAddresses on the on-prem AD object in the attribute editor (or on the cloud object if the mailbox already soft-deleted into Purview retention), let a delta sync clear it, then convert. Worth adding the wider point since he's clearly cost-conscious: privileged/break-glass accounts are one of the most common places licences quietly sit assigned long after anyone remembers why — a `Get-MgSubscribedSku` purchased-vs-consumed check plus a pass over assigned licences on `accountEnabled = false` accounts usually turns up more than the three he's chasing. If you mention SeatScout, add: "disclosure: I built a tool for this."

### 3. r/sysadmin — Am I Getting Fucked Friday, August 7th 2026
- **Age:** 5 days | **Comments:** 19 (unlocked, weekly recurring thread, still the current week's)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vi2zmm/am_i_getting_fucked_friday_august_7th_2026/
- **Why it fits:** The subreddit's weekly vendor-quote sanity-check thread, and the OP body explicitly lists "Software licensing: This includes Microsoft CSPs" as in-scope. Right now it's all hardware lead-times and DIA circuit pricing — no Microsoft licensing answers at all, so the lane is completely open. Recurring format means this is a standing weekly slot rather than a one-off, which is the cheapest possible way to become a familiar name in the sub.
- **Suggested angle:** Don't post a wall — answer someone's Microsoft quote when one appears, or offer the standing check: before comparing CSP quotes at all, reconcile the seat *count* you're being quoted for against the seats you actually consume (`Get-MgSubscribedSku`: prepaidUnits.enabled vs consumedUnits), because renewals are routinely quoted off last term's number and the delta is pure overspend regardless of which partner wins on unit price. Add the second pass — assigned seats on disabled accounts and on accounts with no `signInActivity` in 90+ days (property needs Entra ID P1) — since that's the number that changes the quote size, not the discount. **Practical note:** this thread rolls weekly, so if you'd rather engage fresh, the 08-14 edition drops Friday and answering early in that one gets far more visibility than a day-5 reply here. Optional product mention; disclose plainly if you make one.

### 4. r/sysadmin — phishing sims in a mixed M365 + Google Workspace setup? (~250 users)
- **Age:** 6 days | **Comments:** 13 (unlocked, active, thoughtful thread)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vgvbay/phishing_sims_in_a_mixed_m365_google_workspace/
- **Why it fits:** Adjacent — security tooling, not licensing — but OP explicitly asks "what's it actually cost you around 250 seats" and is weighing paid platforms against Defender's built-in Attack Simulation Training. Nobody has told him to check what his M365 tier already entitles him to before spending. Note one commenter has already disclosed they're building a competing product in-thread, so disclosure is the established norm here — good, low-risk place to model it.
- **Suggested angle:** Short, one job only: before pricing KnowBe4 or Hoxhunt for 250 seats, check which tier your M365 half is actually on — Attack Simulation Training comes with Defender for Office 365 Plan 2, which is bundled into E5, so a chunk of orgs on E5 are quoting for a product they already own. The catch a commenter already flagged is real and you should agree with it: ASM only delivers into Exchange Online mailboxes, so it can't cover the Google half — which makes the honest framing "what fraction of my 250 is on M365, and is the Google remainder big enough to justify paying for a second platform for everyone?" rather than an all-or-nothing tool choice. Stay out of the tool-recommendation fight; the licensing observation is the only thing you add. No product mention needed here — resist it, it's a security thread.

## 2026-08-11

> 18 queries across 3 rounds, ~60 unique threads reviewed, 10 skipped via seen-log. **Three picked; comments fetched and read on all three, all unlocked and still active.** Note: the first search round silently returned garbage (random subreddits — the connector's search tool has no `subreddits` parameter, the sub filter must go inside `search_query` as `subreddit:x OR subreddit:y`); re-ran correctly. Worth remembering for future runs.
>
> Honest read: **this is a thin day for licensing specifically.** Deliberately dropped: the VMware/hardware price-hike thread (375 comments, not M365), the tenant-deauthenticated megathread (449 comments), MemberOf retirement (247 comments), the "lifetime Office licence" student post in r/Office365 (consumer), and t3_1vffg0a again (r/sysadmin twin of the OneDrive-unlimited thread whose r/Office365 crosspost was surfaced 08-07 — still the same answer, don't double-post). #1 below is the standout; #2 and #3 are adjacent-fit and only worth your time if you have spare capacity today.
>
> **Pricing caution:** OP figures and commenter prices below are *their* claims — quote as such. Verify anything you state against your own admin centre / price list.

### 1. r/sysadmin — MS Azure Question: AVD on a Windows Server image needs RDS CALs - and if you're Entra-only, there's no clean way to buy them?
- **Age:** ~1 day | **Comments:** 2 (unlocked, essentially unanswered — highest-leverage thread in the digest)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vkt0b2/ms_azure_question_avd_on_a_windows_server_image/
- **Why it fits:** A genuinely hard licensing dead-end, laid out well by OP: Windows Server 2025 session host in AVD, Entra-joined with no AD DS, 120-day RDS grace period expired, 4 users. He's correctly identified that per-user CALs need an AD user object to write tracking data to, and that License Mobility to Azure is an SA benefit tied to user CALs, not device CALs. Two replies so far, both hedged ("I can't remember off rip"). This is pure SKU-and-entitlement reasoning — your strongest ground — and a fresh thread with 2 comments is where a correct answer actually gets seen.
- **Suggested angle:** Give him the option he hasn't listed: the RDS CAL requirement is a *Windows Server* requirement, so the clean exit is to stop running the session host on Server. Windows 11 Enterprise multi-session in AVD carries the user's desktop entitlement from M365 E3/E5/BP/F3 — no RDS CAL at all, no AD DS needed for licence tracking. He says the ERP blocks multi-session, so the real question is whether the ERP must live *on the session host* or can be split onto a separate Server VM (no RDP users on it, so no CALs) with the 4 users on a small multi-session pool. That's cheaper than Entra Domain Services, which is ~$100+/mo just to satisfy CAL tracking for 4 people — worth pricing both against 4 × Windows 365 Enterprise, which u/Frothyleet floated and which is the other clean answer. Pure advice, no product mention, no disclosure needed.

### 2. r/msp — What margin are you actually running at 150 users / $165 per user?
- **Age:** 3 days | **Comments:** 33 (unlocked, active, several detailed replies)
- **Link:** https://www.reddit.com/r/msp/comments/1viqobg/what_margin_are_you_actually_running_at_150_users/
- **Why it fits:** Adjacent, not core — but there's an obvious unclaimed angle. Every reply so far attacks the same lever (ticket volume: "450/month is high", "why so many tickets"). Nobody has mentioned the *cost* side of the $165, and licence drift in client tenants is pure margin leak for a fixed-per-user-price MSP.
- **Suggested angle:** Point out that everyone is optimising the labour side and nobody has audited the product side of the $165. At a fixed price per managed user, every M365 seat assigned to a departed, disabled, or never-signed-in account is straight margin loss — and it accumulates quietly between renewals. Concrete method: per tenant, compare `Get-MgSubscribedSku` prepaidUnits.enabled vs consumedUnits to find seats bought but never assigned, then cross-reference assigned licences against `signInActivity` (needs Entra ID P1 on the tenant) and `accountEnabled = false` for seats being billed on dead accounts. Reconciling billed seats to his own headcount of 150 is a one-afternoon exercise with a direct margin number attached. If you mention SeatScout, add: "disclosure: I built a tool for this."

### 3. r/sysadmin — I've just become the only sysadmin in a company — what open-source/self-hosted tools would you consider essential?
- **Age:** ~1 day | **Comments:** 35 (unlocked, very active)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vl0daw/ive_just_become_the_only_sysadmin_in_a_company/
- **Why it fits:** Adjacent — a "what do I do first" thread, not a licensing one. But the environment is M365, IT was outsourced (so nobody has looked at the bill in years), OP is also a developer, and the useful replies are converging on "inventory what you have before adding anything." One commenter listed "licensing cleanup" in passing and nobody expanded it. Low-effort, high-visibility, and it's a natural place for a PowerShell-flavoured answer.
- **Suggested angle:** Agree with the "inventory before you build" crowd, then give the M365-specific version nobody has: before standing up a single self-hosted service, run a licensing baseline — `Get-MgSubscribedSku` for purchased-vs-consumed seats, then assigned licences filtered by `accountEnabled = false` and `signInActivity` older than 90 days. A tenant that's been outsourced for years almost always has seats billing for leavers, and unlike Zabbix or BookStack it's a half-day of work that produces a real dollar number you can put in front of the person who just hired you. Good political capital in month one. Since he's a developer, the Graph PowerShell snippet is the whole answer. Optional product mention; if you make one, disclose it plainly.

## 2026-08-10

> 19 queries across 3 rounds (msp-specific queries returned zero twice — that subreddit is quiet on licensing this week), ~40 unique threads reviewed, 5 skipped via seen-log. **Four picked; comments fetched and read on the three r/sysadmin ones, all unlocked and still active.** Dropped on purpose: Entra MemberOf-retirement (247 comments — again over the noise threshold), the tenant-deauthenticated megathread (447 comments, trust rant not licensing), CIPP-frustration in r/msp (setup pain, not cost), and the r/sysadmin twin of the OneDrive-unlimited thread (t3_1vffg0a) because its r/Office365 crosspost was already surfaced 08-07.
>
> Honest read: #1 is the best licensing thread in weeks — hours old, small, and the existing answers are partially *wrong*, which is the easiest way to add value. #2 is a big active thread squarely on Copilot-vs-Claude seat strategy where nobody has done the cost/governance math yet.
>
> **Pricing caution:** OP figures and commenter prices below are *their* claims — quote as such. Verify anything you state against your own admin centre / price list.

### 1. r/sysadmin — What do I do about AIP P1, renewal soon
- **Age:** hours (posted this morning) | **Comments:** 14 (unlocked, answers contradictory so far)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vkezak/what_do_i_do_about_aip_p1_renewal_soon/
- **Why it fits:** Small company (<20), 5 standalone AIP P1 licenses up for renewal, told to swap to Entra ID P1. Crucial detail most commenters missed: the 5 accounts are NOT on Business Premium — they're bare admin accounts, NEDs on Exchange P1 only, and a locked-down contractor. OP also quotes ID P1 at £658.40/yr/user (off by ~10x; commenters put it near £65). Answers so far conflate AIP P1 with Entra ID P1 — exactly the SKU-vs-service-plan confusion you untangle for a living.
- **Suggested angle:** Separate the two questions. (a) AIP P1 ≠ Entra ID P1 — AIP retirement pushes you toward Purview Information Protection entitlements, which BP/E3 users already have; the question is only about these 5 non-BP accounts, so first check what they actually *used* AIP for (applying labels vs merely reading protected mail — reading needs no paid license). (b) Admin accounts don't inherently "require" Entra ID P1 — they need it only if they consume P1 features like Conditional Access; MFA alone works via security defaults or per-user MFA. Then the money move: `Get-MgSubscribedSku` and look at the service plans in each SKU before buying anything — his BP seats already carry Entra ID P1 + AIP P1 service plans, so the fix may be scoping CA policies rather than 5 new licenses. Pure advice thread — no product mention, no disclosure needed.

### 2. r/sysadmin — Claude M365 Connector vs Copilot — are we creating long-term technical debt?
- **Age:** 4 days | **Comments:** 54 (unlocked, score ~81, replies still arriving)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vh95hf/claude_m365_connector_vs_copilot_are_we_creating/
- **Why it fits:** OP asks three explicit questions (why Claude over Copilot, broad vs role-scoped, long-term governance debt). The thread is full of "we ditched Copilot for Claude" anecdotes but nobody has answered the *governance/cost* question with a method. You run both stacks daily and built a Copilot seat auditor — this is your exact seam.
- **Suggested angle:** Answer the debt question head-on: the bigger lock-in is rarely the model, it's the per-seat annual commit plus the Graph permission sprawl — both platforms create it. Concrete method: start role-scoped, not org-wide; pull the Copilot usage report (admin center / Graph) monthly and treat sub-10%-active seats as renewal-negotiation material; inventory the OAuth grants each connector adds so you can actually migrate later. Commenters' price points ($30/user/mo Copilot, cited in-thread) make the math vivid at 100+ seats. If you reference your Copilot seat-usage tool, add the plain disclosure: "disclosure: I built a tool for this."

### 3. r/Office365 — How much does Cowork -actually- cost?
- **Age:** 3 days | **Comments:** 38 (unlocked, active)
- **Link:** https://www.reddit.com/r/Office365/comments/1vi9uk2/how_much_does_cowork_actually_cost/
- **Why it fits:** Consultant's client wants Cowork; OP finds the light-vs-heavy task billing examples "super vague" and fears recommending a tool whose cost he can't predict. You use Cowork daily for real work — you can answer with observed usage patterns instead of marketing copy, which nobody in the thread has done.
- **Suggested angle:** Speak from your own months of daily use: describe what a typical light task vs a heavy multi-step session looks like in practice and how consumption behaved for you — no invented numbers, your real experience only. Then the consultant-grade advice: don't estimate, meter — run a 2-4 week pilot with the client's 3-5 heaviest intended users, set a budget cap, and extrapolate from measured burn; consumption billing concentrates in a small cohort (same top-10% pattern as every seat-waste audit), so per-user visibility matters more than the rate card. No product mention needed.

### 4. r/sysadmin — Built a mini-SIS from SharePoint + Power Automate because we can't afford a real one. Am I crazy?
- **Age:** 3 days | **Comments:** 5 (unlocked, low competition; top comment already warns about per-flow licensing)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vi4kx2/built_a_minisis_from_sharepoint_power_automate/
- **Why it fits:** Solo IT at a tiny non-profit school built intake/approval/rostering on SharePoint Lists + Power Automate and asks for a reality check. This is your home turf twice over: SharePoint architecture and Power Platform licensing traps. Only 4 substantive replies, none complete.
- **Suggested angle:** Reassure on scale (20-30 students on a SP List is fine; SPFx front-end adds no licensing cost), then flag the two real risks: licensing — stay on standard connectors under the seeded M365 rights; the moment a flow needs premium connectors or HTTP actions you're into per-user/per-flow Power Automate licensing, and a Graph-based script (scheduled, app-registration auth) does the Google-provisioning step without any premium license; and security — writing generated passwords back into a SharePoint list is plaintext credential storage teachers can potentially see; push credentials through the Google Admin SDK invite/reset flow instead and store only usernames. Pure advice; disclosure only if you name your Power Platform tool.

## 2026-08-07

> Connector back after yesterday's blocked run — toolkit mounted, schema trap avoided (inline `subreddit:` operators from the first query). 10 queries, ~90 unique threads reviewed, 7 skipped via seen-log. **Three picked, all unlocked, comments fetched and read on all three.** Dropped on purpose: the Entra MemberOf-retirement thread (221 comments — group-based-licensing angle is real but a reply would drown) and a 10-day-old Intune Pro→Enterprise activation thread (36 comments, core answer already given).
>
> Honest read: still no clean "audit our seats" thread this week. The interesting shift is #1 — consumption-billed AI (MS CoWork credits) generating the exact waste patterns seat licensing has: top-10% concentration, no per-user visibility, all-or-nothing enable/disable. Same discipline sells in both worlds.
>
> **Pricing caution:** price examples in your own admin centre / partner portal numbers only. OP figures below are *their* claims — quote as such, never as fact.

### 1. r/sysadmin — Any other large orgs quit CoWork?
- **Age:** 7 days | **Comments:** 59 (unlocked, ~110 upvotes, replies still arriving)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vbzkft/any_other_large_orgs_quit_cowork/
- **Why it fits:** OP rolled MS CoWork to 400-500 users on a 100k credit grant, says the top 10% burned most of it, and extrapolates $6-12M/yr at full rollout — so they killed it entirely. The comments are war stories (one org: "$30k a day, disabled after two days") plus exactly one governance datapoint (per-user caps of 25-30k credits/month). Nobody has framed it as a licensing-discipline problem, which is your home turf: consumption concentration in a small cohort is the same distribution seat-waste audits find every time.
- **Suggested angle:** Don't defend or trash CoWork — offer the middle path OP says he's missing ("until we figure out a better plan"). All-or-nothing is the licensing mistake in new clothes: enable per department against a stated use case, set per-user credit caps (one commenter already runs 25-30k/month), and pull the consumption report monthly the way you'd pull Copilot usage before renewal — the top-10% pattern OP saw is normal and manageable, not a reason to zero it. If you draw the parallel to auditing Copilot seat usage and name your tool, add the plain disclosure: "disclosure: I built a tool for this."

### 2. r/Office365 — Unlimited OneDrive storage with Office 365 E3 or above (SharePoint Plan 2)
- **Age:** 3 days | **Comments:** 8 (unlocked, low competition — only three substantive replies, none complete)
- **Link:** https://www.reddit.com/r/Office365/comments/1vffbcr/unlimited_onedrive_storage_with_office_365_e3_or/
- **Why it fits:** OP is asking precisely the entitlement-history question you know cold from the storage work: does the old 5TB→25TB-on-request path still exist under E3/E5, or is "unlimited" gone? Replies so far: "pay-as-you-go now, it ain't cheap", a link to the Jan 2026 retirement of standalone SharePoint/ODfB Plans 1 & 2, and one confused non-answer. Nobody has assembled the full picture or told him what to do about it.
- **Suggested angle:** Assemble the timeline: the 25TB-on-request mechanism lived in the ODfB Plan 2 / SharePoint Plan 2 service description; with the standalone plans retired (a commenter already linked the partner-center announcement) the current E3/E5 language — "up to 5 TB initial... based on the default quota for the tenant", more via your Microsoft rep — means negotiated, not automatic, plus Extra Storage pay-as-you-go for overage. Then the practical move: before fighting for 25TB per user, pull actual per-user consumption from the Graph OneDrive usage report — in most tenants a handful of users drive nearly all storage growth, and it's cheaper to handle them specifically. Disclosure line if you mention your storage tool. **Verify the retirement announcement link and current E3 storage note yourself before posting — service descriptions moved around this year.**

### 3. r/sysadmin — Need Project/Tasks Ideas (solo admin, 800 users)
- **Age:** 2 days | **Comments:** 13 (unlocked, active; generic answers so far)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vgimcr/need_projecttasks_ideas/
- **Why it fits:** Solo sysadmin at an 800-person company asking for high-impact projects, management "wants AI in their approach". She's already done a device cleanup and written an offboarding script — the adjacent move is license hygiene, and no reply has given it more than three words (one bullet says "review costs... eliminate unnecessary licenses" with zero how). A concrete, scriptable audit recipe stands out among the backup/MFA/documentation boilerplate.
- **Suggested angle:** Suggest the license audit as the visibility project: one, `Get-MgSubscribedSku` — compare `prepaidUnits.enabled` vs `consumedUnits` per SKU to find purchased-never-assigned seats; two, cross licensed users against `signInActivity` for 90-day-inactive (needs Entra ID P1, which an 800-seat org almost certainly has); three, list `accountEnabled -eq $false` users still holding licences — disabling doesn't stop the billing, so wire licence removal into the offboarding script she already wrote. Price the findings at their real per-seat rate and it becomes the report management remembers; schedule it monthly and it's also the "AI/automation" win they asked for. Disclosure only if you name your tool.

> **No Reddit access this run.** The Composio Reddit connector (`mcp__34f0d3d1-...__COMPOSIO_MULTI_EXECUTE_TOOL`) was not mounted in this session — no toolkit "reddit" tool existed to call. Fallback paths are also closed: `WebSearch` refuses reddit.com (blocked to the crawler), and `web_fetch` refuses reddit URLs for lack of provenance.
>
> Nothing was searched, so nothing was picked and nothing was appended to `reddit-digest-seen.md`. No fabricated threads below — the 2026-08-05 section is still the newest real digest.
>
> **Fix before the next run:** re-authorize the Composio Reddit connector so the toolkit is present at task start. Worth checking whether the connector grant was cleared (same failure mode noted in the finance-dashboard artifact memory).

## 2026-08-05

> Schema trap hit **again** on the first query of this run — passed `subreddits` and `size`, got r/AusVisa and r/70mai back. **Third time. Burn it in: `REDDIT_SEARCH_ACROSS_SUBREDDITS` accepts only `search_query` (put `subreddit:` operators *inline*), `sort`, `limit`, `time_filter`, `result_type`, `restrict_sr`, `after`/`before`.** There is no `subreddits` parameter and no `size` parameter.
>
> 13 queries after correction, ~130 unique threads reviewed, 8 already in the seen-log. **Four picked, all unlocked, all created within 5 days.** Honest read on the week: there is no clean "we're overpaying for seats, help" thread out there right now. What there *is* — and it is arguably better — is a 234-upvote budget thread where a sysadmin volunteers that his CFO just approved *$20k/month in licensing they don't need* while fighting him over three laptops. That is the SeatScout thesis in someone else's words, upvoted, with nobody offering a way to actually measure it. Pick #1.
>
> The other three are storage-and-SKU economics rather than pure seat waste, which is where the M365 conversation has been sitting all week (the 100GB mailbox change is still generating threads).
>
> **Pricing caution:** quote current list prices from your own admin centre / partner portal. Do not repeat any figure from this digest, from other commenters, or from vendor blogs as fact. Same for retirement dates — verify in Message Center before citing.

### 1. r/sysadmin — Why your IT department budget makes no sense
- **Age:** 5 days | **Comments:** 70 (unlocked, 234 upvotes, still receiving replies)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vbv6hv/why_your_it_department_budget_makes_no_sense/
- **Why it fits:** u/Mindestiny's comment is the whole pitch, unprompted: *"I just spent an afternoon going back and forth with the CFO over 3 MacBooks. $5000... Then he approved $20k/mo in increased spending for licensing we don't need without batting an eye."* u/TommyVe adds that IT buys every licence other departments ask for and nobody pays it back, so managers approve everything. Two people describing licence spend as unmeasured and unchallenged — and not one reply tells them how to put a number on it. That gap is yours.
- **Suggested angle:** Reply to Mindestiny, not the OP. The reason nobody fights the $20k line is that nobody can show what's inside it, and "licensing we don't need" is an opinion until it's a number. Give him the number: `Get-MgSubscribedSku` and compare `prepaidUnits.enabled` against `consumedUnits` — that delta is seats you bought and never assigned, billed every month, and it takes one command. Then the second cut: pull `accountEnabled -eq $false` users who still hold a licence, because disabling an account does nothing to the bill. Two lists, priced at your own per-seat cost, and the CFO conversation stops being about MacBooks. If you mention your own tooling, disclose it plainly: "disclosure: I built a tool that does this."

### 2. r/sysadmin — Microsoft 365 August 2026 Updates: 30+ Changes Every Admin Should Know
- **Age:** 2 days | **Comments:** 38 (unlocked, 383 upvotes, comments still arriving)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vea2os/microsoft_365_august_2026_updates_30_changes/
- **Why it fits:** The monthly roundup thread — high traffic, high signal, and the audience is exactly admins scanning for what will cost them. Two items in the post have direct licence-cost consequences that no commenter has picked up: Purview's new archive-to-M365-Archive option for inactive OneDrive/SharePoint files, and the Aug 3 block on new Partner Tier 1/Tier 2 support role assignments. Comments so far are about calendar phishing and Copilot annoyances — the cost angle is wide open.
- **Suggested angle:** Add a comment flagging the two line items with money attached rather than re-listing them. On the archive item: moving inactive files to M365 Archive changes what you pay for storage but it is billed separately from the seat, so budget it as a new line rather than a saving until you've priced it in your own tenant. On the partner-role retirement: if any of your tenants are supported through a partner using those roles, that access path is closing and you want to know now, not at renewal. Then the practical close — while everyone is reading the change list, this is also the month to run `Get-MgSubscribedSku` and check `prepaidUnits.enabled` vs `consumedUnits`, because the changes people budget for are rarely where the money actually leaks. Only disclose a product if you name it.

> **Verify before posting #2:** re-read both bullet points in Message Center yourself. Roundup posts get details wrong and correcting one incorrectly in public is worse than not commenting.

### 3. r/Office365 — Combating 100GB M365 user, 50GB Outlook File Limit
- **Age:** 1 day | **Comments:** 35 (unlocked, active; crossposted to r/sysadmin at 78 comments — reply in **one** of them, not both)
- **Link:** https://www.reddit.com/r/Office365/comments/1vfkprt/combating_100gb_m365_user_50gb_outlook_file_limit/
- **Why it fits:** User at 80GB of a 100GB mailbox, OST hitting the 50GB cap, a GPO forcing "download all" that OP says he can't change. Every answer is the same three words — "enable the archive" — and not one of them addresses the part that actually decides whether he can: which SKU he's on and whether the archive is entitlement or add-on. That is the licensing dimension of a thread everyone is treating as an Outlook problem.
- **Suggested angle:** Point out that the archive advice is correct but incomplete, because online archive availability and auto-expanding archive are SKU-dependent — before he promises his users anything he should confirm what his current plan entitles versus what needs a per-user add-on, and price that add-on against the seat he's already paying for. The genuinely useful detail nobody has said: online archive contents do **not** cache into the OST, which is precisely why it fixes his 50GB problem while a bigger mailbox would not. Add the cheap check from the thread that did land — deleted items and recoverable items still count against the quota, and emptying them has clawed back double-digit GB before touching licensing at all. No product mention needed here; this one is pure credibility.

### 4. r/Office365 — Microsoft 365 Setup Considerations with GoDaddy
- **Age:** 1 day | **Comments:** 9 (unlocked, low volume but every comment is on-topic)
- **Link:** https://www.reddit.com/r/Office365/comments/1vf70ju/microsoft_365_setup_considerations_with_godaddy/
- **Why it fits:** Small thread, but it is *entirely* about paying too much per seat through a reseller. Commenters: *"they MILK the shit out of subscriptions, the mark up is insane"*, *"the most common question I see about GoDaddy with M365 is how do I get rid of it"*. Nobody has given the person reading this a way to check whether they're actually overpaying or a picture of what leaving costs. Lower reach than #1–#3, but the highest concentration of buying-intent readers.
- **Suggested angle:** Skip piling on — add the arithmetic instead. Tell them to open their GoDaddy invoice, get the actual per-seat monthly figure for each SKU, and put it next to the current published price for the same SKU bought direct or through a CSP partner; the delta times seat count times twelve is the real number, and it's usually the first time anyone has seen it. Then the part people underestimate: the cost of leaving isn't the licence, it's that the tenant is administered through GoDaddy, so budget the partner-of-record change and the admin-access handover as the actual project. Worth adding that reseller markup is only half the leak — most tenants are also carrying seats they never assigned, so run `Get-MgSubscribedSku` and check `prepaidUnits.enabled` vs `consumedUnits` before renegotiating anything, or you'll just buy the same waste at a better rate. Disclose if you name the tool.

> **Do not use figures from this digest.** #4 in particular depends on a price comparison — pull both numbers live before you post.

## 2026-08-04

> Schema lesson from 08-03 held only halfway: first query this run still passed `subreddits` and `size` and got junk back from r/DogDayCare and r/Nepal. **Reminder, again: `REDDIT_SEARCH_ACROSS_SUBREDDITS` takes only `search_query` (put `subreddit:` operators inline), `sort`, `limit`, `time_filter`, `result_type`, `restrict_sr`, `after`/`before`.** Corrected queries plus a direct `REDDIT_RETRIEVE_REDDIT_POST` new-listing pull on r/Office365 and r/msp (keyword search under-returns on those two — the msp pick below never appeared in any keyword query).
>
> ~110 unique threads reviewed, 8 already in the seen-log. **Four picked, all unlocked, all created within 5 days.** Thin week for pure seat-waste questions; the volume is storage-cost and mailbox-structure. But #1 contains the single best opening this digest has surfaced: a CIPP user reporting *yesterday* that his offboarding automation silently fails to strip licenses and he only finds out at renewal. That is SeatScout's exact thesis, stated by someone else, unprompted.
>
> **Pricing caution:** quote current list prices from your own admin centre / partner portal. Do not repeat any figure from this digest or from other commenters as fact. Same for retirement dates — verify in Message Center before citing.

### 1. r/msp — Best features/tools to use with CIPP
- **Age:** 3 days | **Comments:** 13 (unlocked, still moving — newest comment posted today)
- **Link:** https://www.reddit.com/r/msp/comments/1vc16cs/best_featurestools_to_use_with_cipp/
- **Why it fits:** u/TechnicalMayhem404 commented yesterday: *"We use offboarding, however sometimes it doesn't fully complete. For example, it doesn't remove all licenses all the time, so we find at next renewal they have it assigned still."* Nobody has answered him. That is the failure mode SeatScout exists to catch, described in the wild by an MSP who is already paying for it, and it lands in a thread whose OP explicitly asked what else CIPP can do.
- **Suggested angle:** Reply to that comment, not the OP. Point out the structural problem: offboarding automation is fire-and-forget — if the Graph call to remove the license fails, or the license came from a group-based assignment that the wizard can't strip, nothing tells you. The fix is a *detective* control, not a better wizard: run `Get-MgSubscribedSku` per tenant and compare `prepaidUnits.enabled` to `consumedUnits`, then cross-check every consumed seat against `accountEnabled -eq $false` — disabled accounts keep billing as long as a license is attached. Run it monthly, not at renewal. If you mention your own tooling, say plainly: "disclosure: I built a tool that does this across tenants."

### 2. r/sysadmin — M365 OneDrive Storage and EOL of OneDrive for Business Plan 2
- **Age:** 1 day | **Comments:** 8 (unlocked, active, and every answer so far is a one-liner)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1ver6vn/m365_onedrive_storage_and_eol_of_onedrive_for/
- **Why it fits:** OP is paying for a full Business Premium seat purely as a container — a dedicated "archive user" holding 5.8 TB. That is a licensed seat with no human behind it, which is the exact category of spend SeatScout reports on. The five replies so far ("Sharepoint bro", "use your Synology") don't engage with the cost question at all.
- **Suggested angle:** Name the real trade he's making: he is renting a *user identity* to get storage, and a Business Premium seat is an expensive per-GB rate for cold data. Two concrete moves. (a) Archive-per-project as SharePoint sites and put them in Microsoft 365 Archive — cold-tier storage is billed per GB against the tenant, with no seat attached, so pull both numbers off your own Purchase services / billing page and compare annual cost per TB against the seat. (b) If he keeps a container account, it does not need Business Premium — the Office apps and Intune rights are dead weight on an account nobody signs into. Worth flagging that quotas above 5 TB on a single OneDrive were always a support-ticket exception, so the migration is coming regardless of the Plan 2 timeline.

### 3. r/sysadmin — AI-assisted Active Directory audit: how I found dormant privileged accounts using Claude and PowerShell
- **Age:** 5 days | **Comments:** 12 (unlocked; OP is getting piled on for uploading client data to an LLM)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vb3p6c/aiassisted_active_directory_audit_how_i_found/
- **Why it fits:** Dormant-account hunting with PowerShell is precisely the muscle SeatScout is built on, and the on-prem version of this audit has a cloud twin nobody in the thread has mentioned. Also your exact toolchain (Claude + PowerShell), so you can speak to it first-hand.
- **Suggested angle:** Do **not** defend the "upload the CSV to an LLM" step — the criticism is fair and siding with it will cost you credibility in that sub. Lead with the correction: the analysis is a sort and a date filter, so keep the data local. Then add the value nobody gave him — the same audit in Entra is a different query with a real gotcha: `Get-ADUser LastLogonDate` is per-DC and not replicated, so you need to check every DC or use `LastLogonTimeStamp` with its 9–14 day lag; and on the cloud side, `signInActivity` on `Get-MgUser` is gated behind Entra ID P1, which is why so many tenants think they have no dormant-account data. Close the loop to money: dormant *and licensed* is the version of this audit that has a dollar figure attached.

### 4. r/Office365 — Multiple domains, at least 1 separate mailbox for each domain, but just one M365 Business?
- **Age:** 4 days | **Comments:** 12 (unlocked; OP posted a self-answer that is partly wrong and now sits as the thread's conclusion)
- **Link:** https://www.reddit.com/r/Office365/comments/1vbiood/multiple_domains_at_least_1_separate_mailbox_for/
- **Why it fits:** "How many licenses do I actually need?" is the entry-level version of the whole SeatScout question, and this thread's accepted answer will be read by everyone who searches this later. OP's summary claims each shared mailbox eats into his plan's storage and that each has its own login — both wrong in ways that cost people money.
- **Suggested angle:** Short, purely corrective, no product mention needed. A shared mailbox is not licensed and does not consume your user's quota — it is its own 50 GB mailbox and it costs nothing; you only need a license on it if it must exceed 50 GB or needs an in-place archive or litigation hold. You do not and should not sign into it: grant Full Access + Send As to the licensed user and every mailbox appears in Outlook automatically. Net result for his three-domain case is one paid seat, not four — which is the point worth leaving in the thread.

## 2026-08-03

> **Made the same schema mistake a third time.** First pass this run passed `restrict_to_subreddit` and `size` to `REDDIT_SEARCH_ACROSS_SUBREDDITS` — both silently ignored, returning junk from r/nostalgia, r/fanshawe and r/maplecasino. **The only valid params are `search_query` (put `subreddit:` operators inline), `sort`, `limit`, `time_filter`, `result_type`, `restrict_sr`, `after`/`before`.** Verified against `COMPOSIO_GET_TOOL_SCHEMAS` this time — that call takes ten seconds and should be step zero of every run.
>
> First run since 07-30 (nothing ran 07-31 → 08-02). Six corrected queries, `time_filter: week` on the five target subs plus one `month` sweep on waste-specific phrases. 48 unique threads returned, 9 already in the seen-log. **Four picked, all unlocked and unarchived, all created within 6 days.** The week's fresh volume is again *device/shared-user licensing* rather than pure seat waste, plus one genuinely good spend-tracking thread that is the single best SeatScout-adjacent opening of the run. #1 is the highest value: 42 comments and the OP's actual use case only surfaced in a downvoted reply at the bottom that nobody has answered.
>
> **Pricing caution for every reply below:** quote current list prices from your own admin-centre / partner portal. Do not repeat any figure from this digest or from other commenters as fact.

### 1. r/sysadmin — M365 licensing options for casual warehouse staff needing one app
- **Age:** 2 days | **Comments:** 42 (unlocked, very active, but OP's real use case is buried and unanswered)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vd04gr/m365_licensing_options_for_casual_warehouse_staff/
- **Why it fits:** Core "am I paying per head for something that barely needs a head" question. The thread spent 42 comments demanding "which app?" — and when OP finally answered in a −1 comment ("a Power App on a shared iPad… another is SharePoint on a shared iPad… they're refusing any licence costs so I'm assuming generic or guest account is my only option") nobody replied. That answer changes everything and lands squarely in both SeatScout and PowerScout territory.
- **Suggested angle:** Reply to that buried comment, not the top of the thread. Two concrete points. (a) **The Power App is the licensing question, not the identity.** If it uses only standard connectors against SharePoint, the seeded Power Apps use rights inside the M365 SKU may already cover it; if it touches premium connectors or Dataverse, no F/E SKU covers it and he needs Power Apps Premium or a per-app plan regardless of which identity SKU he picks — so he should check the app's connector list *first*, because that may make the whole F3-vs-guest debate irrelevant. (b) **Kill the B2B guest idea now.** Entra External ID is licensed for external collaborators; using guest accounts for your own employees isn't a supported way to avoid seats, and it also loses him the MFA/auditability he said he wanted. For SharePoint-only users, price standalone SharePoint Online Plan 1 against F3 — that's the legitimate cheap path and nobody in 42 comments has mentioned it.

### 2. r/sysadmin — IT Directors, Managers - Keeping Track Of Spend
- **Age:** 3 days | **Comments:** 20 (unlocked, thoughtful, and every answer is downstream of the same blind spot)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1vc3la2/it_directors_managers_keeping_track_of_spend/
- **Why it fits:** The best pure-SeatScout thread of the week. Fifteen people answered "get the GL report from Accounting and put it in Excel" — which tracks *what was invoiced*, never *what was used*. That gap is the entire premise of the product, and one commenter is literally a software license manager who built his own dashboard because Flexera's procurement side annoys him.
- **Suggested angle:** Make the distinction, don't pitch. Accounting's numbers are authoritative for **spend** and useless for **waste** — the invoice for 400 E3 seats looks identical whether 400 or 310 people are actually signing in. Give him the two-minute version he can run today: `Get-MgSubscribedSku` and compare `PrepaidUnits.Enabled` against `ConsumedUnits` per SKU for purchased-but-unassigned seats, then `Get-MgUser` with `signInActivity` (needs AuditLog.Read.All and an Entra ID P1 in the tenant) for assigned-but-dormant ones — and note that **disabled accounts keep billing** as long as a licence is attached, which is where most of the surprise sits. Suggest he add one "assigned vs. actually used" column next to each licence line in the spreadsheet he already keeps; that turns his tracker into a forecast. If you mention your own tool at all, add "disclosure: I built a tool that does this" plainly — but this thread is strong enough on the PowerShell alone, and the license-manager commenter is worth a reply of his own.

### 3. r/Office365 — Onedrive travails and what now?
- **Age:** 4 days | **Comments:** 16 (unlocked, OP still actively troubleshooting, two decent answers and no complete one)
- **Link:** https://www.reddit.com/r/Office365/comments/1vb4apx/onedrive_travails_and_what_now/
- **Why it fits:** StorageScout territory more than SeatScout, but it's the same "cost that only appears once the pool tips over" story from the 07-30 digest — and OP now needs a decision, not a diagnosis. He hit the OneDrive 1TB wall, found a 1.8TB three-year-old restored subsite eating the quota, and is asking what small businesses should do when they need more than the per-user and tenant defaults.
- **Suggested angle:** Straighten out the storage model, which nobody has laid out cleanly: OneDrive defaults to 1TB per user, going beyond that needs 5+ seats of a qualifying plan and is raised in the admin centre (past 5TB it's a support request) — so the "5 user minimum" his Copilot chat surfaced is real, but it's a plan-eligibility rule, not a bug. Then the actual recommendation: shared company data does not belong in OneDrive; move it to a SharePoint site, where the tenant pool grows with licensed seats, and only then price the Extra File Storage add-on against simply archiving the 1.8TB of three-year-old snapshot to cold storage. Add the audit habit — before buying storage, find the orphaned OneDrives of departed users, which is usually where the pool actually went. Nice organic hook for the archive-vs-add-on math; disclose plainly if you name the tool.

### 4. r/msp — Non-Microsoft application stacks (optional / lower value)
- **Age:** 2 days | **Comments:** 46 (unlocked and busy, but half the thread is a political argument)
- **Link:** https://www.reddit.com/r/msp/comments/1vd1zim/nonmicrosoft_application_stacks/
- **Why it fits:** Only loosely. OP asks whether clients are leaving M365 for Proton and similar; the replies split between "no such trend" and EU sovereignty concerns. Relevant because cost is the unstated third driver behind most "should we leave Microsoft" conversations, and there's an honest, non-salesy point to make.
- **Suggested angle:** Only reply if you want the r/msp visibility — the thread is drifting political and the ROI is lower than #1–#3. If you do: one commenter already declared his Microsoft bias upfront and made the mature-enough argument well, so build on it rather than repeat it. The useful addition is that when the driver is cost rather than sovereignty, right-sizing usually beats migrating — most tenants carry a meaningful share of purchased-but-unassigned and assigned-but-dormant seats, and a migration priced against a *bloated* M365 bill flatters the alternative. Sovereignty is a real requirement and a different conversation; cost usually isn't a reason to move. Skip any product mention here.

---

## 2026-07-30

> **Confirming yesterday's note the hard way:** this run's first search pass passed a `subreddits` array and a `size` param to `REDDIT_SEARCH_ACROSS_SUBREDDITS` — both are silently ignored and the call returned junk from r/Slack, r/Salary and r/NIOCORP_MINE. The real schema is `search_query` (with `subreddit:` operators inline), `limit`, `sort`, `time_filter`, `result_type`, `restrict_sr`. **Read this digest's own header before searching, not just the seen-log.**
>
> Six corrected queries across the five target subs, `time_filter: month`, `sort: new`. Four threads below, all unlocked, all created within 8 days. The batch is thinner than yesterday's on pure seat-count waste — the fresh volume this week is *device vs user licensing*, which is the same "am I paying per-head for something that doesn't need a head" question from a different direction. #1 is the strongest: the OP's actual question was never answered and his cost premise is wrong. #4 contains a confidently stated answer that is incorrect, which is the cleanest correction opportunity of the run.

### 1. r/Office365 — Unlicensed OneDrive user accounts / user-to-shared-mailbox conversions
- **Age:** 7 days | **Comments:** 10 (unlocked, OP engaged and thanking people, but his real question went unanswered)
- **Link:** https://www.reddit.com/r/Office365/comments/1v558b0/unlicensed_onedrive_user_accounts_user_to_shared/
- **Why it fits:** Textbook SeatScout scenario — inactive users, mailboxes converted to shared, licences pulled, but the AD-synced user objects and their OneDrive sites left behind. OP explicitly asked whether he can delete the user account and keep the shared mailbox, and *nobody answered that question*; the accepted reply ("delete the OneDrive site") answers a different one. He then shrugged with "I suspect we'll just pay the charges" based on a premise that isn't right.
- **Suggested angle:** Answer the question he actually asked: for a directory-synced object, don't delete the user — deleting the on-prem AD account soft-deletes the Entra object and takes the shared mailbox with it into the 30-day recycle bin, which is exactly the anchor breakage he's worried about. Keep the AD object, leave it disabled, licence removed, and delete the OneDrive site separately (his accepted answer, but now with the reason attached). Then correct the cost premise: Microsoft doesn't invoice him a line item for an unlicensed OneDrive — that storage is consumed from the **tenant** SharePoint pool, and the pool is sized off licensed seats, so orphaned OneDrives don't show up as a charge until the tenant tips over into buying add-on storage, at which point it looks like a storage problem rather than an offboarding problem. That reframe is worth more to him than the PowerShell.

### 2. r/Intune — Intune Only License?
- **Age:** 1 day | **Comments:** 7 (freshest of the batch, active, unlocked)
- **Link:** https://www.reddit.com/r/Intune/comments/1va05t0/intune_only_license/
- **Why it fits:** Direct right-sizing question — OP runs Gmail for mail and wants to strip A1/A3 down to an Intune-only SKU for users who only sign in to a laptop and do MFA. The thread is decent (Entra ID P1 being required to *evaluate* Conditional Access has been raised twice) but it's all licensing theory and nobody has touched the two things that decide whether this actually saves money.
- **Suggested angle:** Confirm the P1 point is real — CA evaluation is licensed per user, so Intune Plan 1 alone won't cover him if he's enforcing MFA via CA rather than Security Defaults, and standalone Intune P1 + standalone Entra ID P1 can land close enough to A3 that the swap isn't worth the churn. Tell him to price all three combinations at his own academic rate before touching anything. Second, the operational trap: removing A1/A3 pulls the Exchange entitlement and the mailbox enters a 30-day soft-delete — if any of those accounts ever received mail, even calendar invites, he needs to decide about that data *before* the licence comes off, not after. Worth adding `Get-MgSubscribedSku` (compare `prepaidUnits.enabled` to `consumedUnits`) so he sees how many A1/A3 seats he's already paying for and not assigning — that number often makes the standalone-SKU question moot.

### 3. r/sysadmin — Licensing for 365 for AD Users (F3 vs per-device Defender/Intune)
- **Age:** 7 days | **Comments:** 12 (unlocked; OP posted his final plan asking "anything I'm missing?" and nobody replied)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1v4lb94/licensing_for_365_for_ad_users/
- **Why it fits:** OP is trying to license a small group of limited users as cheaply as possible and has landed on "Defender for Endpoint device licence + Intune device licence + Entra P1 per user." His closing comment is an explicit open invitation with zero responses — the cheapest high-value reply in this batch. He also says his own Microsoft partner gave him an answer he couldn't make sense of, so he's actively looking for someone to sanity-check the arithmetic.
- **Suggested angle:** Tell him his plan probably doesn't save what he thinks. Intune device-only licensing is for devices with **no** associated user — the moment a user signs in interactively and he wants Conditional Access on that sign-in, he's buying per-user Entra ID P1 anyway, and once he's per-user for P1 the device-licence saving on Intune shrinks to very little. So price the honest comparison: (a) M365 F3 per user, versus (b) Entra ID P1 + Intune P1 + Defender per user, versus (c) his device-licence hybrid, at his actual rates for his actual head count. Also worth clearing up the confusion still visible in his replies: the "kiosk" in M365 F3 is an *Exchange* Kiosk mailbox, not a restricted Intune enrolment mode — F3's Intune P1 is the full entitlement, so the enrolment limitation he's designing around may not exist.

### 4. r/Intune — Licensing 5 shared Samsung tablets: dedicated vs fully managed
- **Age:** 3 days | **Comments:** 5 (unlocked, quiet, and one confident answer is wrong)
- **Link:** https://www.reddit.com/r/Intune/comments/1v885lz/licensing_5_shared_samsung_tablets_dedicated_vs/
- **Why it fits:** Same "don't pay per-head for a headless device" question, small and concrete. OP is post-fire, moving fast, and asked directly whether the guidance is still current. One commenter told him "licensing-wise you're good without per-user EMS on these" — which reads as *free*, and that's the error worth correcting before he builds it that way. Another commenter got it right ("license the users or license the device") but didn't spell out the consequence.
- **Suggested angle:** Confirm Corporate-Owned Dedicated Devices is the right enrolment mode for a userless warehouse kiosk, then correct the free-lunch reading: dropping per-user licensing doesn't mean no licence — a device managed without a licensed user needs an **Intune Device** SKU, so he's swapping a per-user cost for a per-device cost, not eliminating it. At five tablets the calculation is trivial and device licences almost certainly win, but he should know he's buying something so it doesn't surface at renewal as five unexplained managed devices. Practical note for his timeline: dedicated-device profiles lock down harder by default, so budget an hour for device-restriction tweaks to let Chrome and the LOB apps update.

## 2026-07-29

> **Connector restored.** The Composio Reddit connector authenticated successfully for the first time since 2026-07-15 — five blocked runs (07-17, 07-20, 07-22, 07-23, 07-24) are now closed out. Note for future runs: `REDDIT_SEARCH_ACROSS_SUBREDDITS` has **no `subreddits` parameter**; passing one is silently ignored and returns junk from unrelated subs. Use the `subreddit:` operator inside `search_query` instead (e.g. `(subreddit:sysadmin OR subreddit:msp) (license OR licensing)`).
>
> Because of the 14-day gap, this run swept `time_filter: month` across all five target subs. Backlog from 07-15 to 07-19 has aged past the ~10-day window and was skipped deliberately. Five threads below, all created within 8 days, all unlocked and unarchived. #1 and #2 are the strongest — both have a factually contested question sitting unresolved, which is the best possible opening for a precise answer.

### 1. r/Office365 — What happens to Exchange Archives with an unlicensed account?
- **Age:** 8 days | **Comments:** 16 (unlocked, still active, and the answers openly contradict each other)
- **Link:** https://www.reddit.com/r/Office365/comments/1v22jo5/what_happens_to_exchange_archives_with_an/
- **Why it fits:** This is SeatScout's exact scenario described by the OP himself — offboarded staff, account blocked, mailbox converted to shared, licence pulled, user object never deleted. He's mid-audit and asking what he's actually left behind. The thread is the single best opportunity of this run because the commenters are directly contradicting one another: one says the archive is deleted when the licence goes, another says theirs survived over a year, a third claims a 30-day grace that he's seen stretch to six months. Nobody has separated *what Microsoft documents* from *what people observed*.
- **Suggested angle:** Untangle the two separate limits people are conflating: an unlicensed shared mailbox is capped at 50 GB and does **not** support an online archive — if an archive must be retained, it needs Exchange Online Plan 2 (or Exchange Online Archiving) assigned to the shared mailbox, and that's a supported, documented requirement rather than a grey area. Then give him the audit query he actually needs: `Get-EXOMailbox -RecipientTypeDetails SharedMailbox -Properties ArchiveStatus,ArchiveGuid` joined against assigned SKUs, so he can list every shared mailbox that has an archive but no licence backing it — that's the set at risk, and it's usually much smaller than people fear. Add the flip side that matters to his audit: blocked-but-not-deleted users who *kept* a licence are the opposite error and are billing every month, findable via `Get-MgSubscribedSku` (`prepaidUnits.enabled` vs `consumedUnits`) plus `Get-MgUser -Property signInActivity,accountEnabled`.

### 2. r/sysadmin — M365 Extra Storage Costs Solution ($24k/year)
- **Age:** 7 days | **Comments:** 24 (unlocked, high-quality thread, OP still replying)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1v36d9x/m365_extra_storage_costs_solution/
- **Why it fits:** OP is paying roughly $2,000/month for ~6 TB of add-on storage and is about to solve it by re-platforming onto Azure Blob. Direct StorageScout territory. The thread has already covered version history (top comment) and the SharePoint archive tier, and one commenter (`Smart_Dumb`) noticed the arithmetic doesn't add up but nobody followed the thread. That unfinished observation is the opening.
- **Suggested angle:** Pick up where `Smart_Dumb` stopped — his own numbers don't reconcile. Extra File Storage is billed per GB per month, so ~6 TB should not land at $2,000; tell him to pull the actual line item off the invoice and divide, because either he's well over 6 TB or he's being billed on a different SKU than he thinks, and both answers change the decision. Then the point nobody has raised: before comparing storage tiers, find out *whose* storage it is. A large share of surprise SharePoint/OneDrive growth in a tenant this size is OneDrive belonging to people who left — unlicensed or orphaned accounts whose sites are still counted against the tenant quota. Deleting nothing and just reclaiming those usually beats a migration project. If he mentions his own tooling here, add "disclosure: I built a tool for this."

### 3. r/sysadmin — Large license number Microsoft direct (1,200 × M365 E3)
- **Age:** 2 days | **Comments:** 24 (fresh, active, unlocked — best timing of the batch)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1v7wh72/large_license_number_microsoft_direct/
- **Why it fits:** OP wants to break away from a reseller and buy 1,200 E3 seats directly. Every reply so far argues *channel* — direct vs CSP vs EA, discounts, partner support. Not one person has questioned the 1,200. One commenter (`bjc1960`) got closest with "they always want to add licenses, they never want to remove licenses," which is the whole thesis and nobody picked it up.
- **Suggested angle:** Agree with the consensus that at 1,200 seats direct rarely beats a good reseller, then add the part nobody said: a renegotiation is the one moment you can safely shrink the seat count, and almost nobody counts before they sign. Tell him to run `Get-MgSubscribedSku` and compare `prepaidUnits.enabled` against `consumedUnits` for the E3 SKU — unassigned-but-paid seats show up immediately — then pull `Get-MgUser -Property signInActivity,accountEnabled,assignedLicenses` and count licensed accounts that are disabled or haven't signed in in 90 days. Note `signInActivity` needs Entra ID P1, which E3 already includes. At 1,200 seats a 5% overcount is real money against his own per-seat rate, and it's the cheapest hour of work in the whole migration.

### 4. r/sysadmin — Business Premium user account to shared mailbox after the 100GB storage change
- **Age:** 4 days | **Comments:** 3 (quiet, but score is positive and an early answer would own the thread)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1v5f12e/business_premium_user_account_to_shared_mailbox/
- **Why it fits:** OP inherited an offboarding procedure and posted his licence-reclaim decision matrix asking for verification. This is literally the "when can I pull the licence" question SeatScout exists to answer, posted by someone actively standardising the process. One commenter validated most of the matrix; OP's explicit auto-expanding-archive question is still unanswered.
- **Suggested angle:** Confirm the matrix is broadly right and close the open question directly — the 100 GB user mailbox change did not move the 50 GB ceiling on an unlicensed shared mailbox, and auto-expanding archive is not supported on an unlicensed shared mailbox at all, so that row needs Exchange Online Plan 2 the same as the others. Then flag the ordering trap in his procedure: convert to shared *first*, confirm the conversion completed, and only then remove the licence — pulling the licence first is where people lose access to the archive and end up re-licensing to fix it. On his eDiscovery question, exporting an auto-expanding archive to PST works but splits across multiple files, so it's worth testing on one mailbox before he writes it into the runbook.

### 5. r/Office365 — Office 365 Copilot (user lost OneDrive after licence swap)
- **Age:** 2 days | **Comments:** 17 (unlocked; the licensing question is answered, the consequence is not)
- **Link:** https://www.reddit.com/r/Office365/comments/1v7jnvp/office_365_co_pilot/
- **Why it fits:** PilotScout territory. OP removed users' base M365 licence and assigned a Copilot licence in its place. Eight people have correctly told him Copilot is an add-on and he needs both — but nobody has addressed what he actually reported, which is that a production user has lost OneDrive and Teams access *right now*.
- **Suggested angle:** Skip re-explaining the add-on point (it's been made eight times) and answer the urgent part: removing the base licence removed the OneDrive and Exchange entitlement, and that data enters a grace state rather than vanishing — reassign the original licence to those users today and access should return, but he should verify each user's OneDrive contents afterward rather than assume. Then the cost point worth making once he's stable: Copilot is a per-user monthly add-on on top of a full licence, not a substitute for one, so his 2–3 pilot users are additive spend — worth agreeing up front how he'll measure whether those seats get used before anyone expands the pilot. If he mentions his own tooling, add "disclosure: I built a tool for this."

---


## 2026-07-24

> **Run blocked — no search performed (5th consecutive).** Unchanged cause: the Composio Reddit connector (`plugin:composio-tools:composio`, task server `34f0d3d1…`) still requires authentication. The system explicitly confirms this run is non-interactive and lists `plugin:composio-tools:composio` under "servers requiring authorization," so OAuth cannot be completed here. Direct `select:` load of `COMPOSIO_MULTI_EXECUTE_TOOL` returned no matching tool. Nothing searched, surfaced, or appended to the seen-log.
>
> **No new threads surfaced since 2026-07-14 — ten days now unreviewed.** The gap has reached the ~10-day relevance window, so threads from mid-July are now aging out entirely. Recommendation escalated: **pause this scheduled task** until Composio is re-authorized interactively (claude.ai connector settings or `/mcp`). Continuing the daily schedule only appends identical blocked-run notes with zero warm-up value.

## 2026-07-23

> **Run blocked — no search performed (4th consecutive).** Same cause: the Composio Reddit connector (`plugin:composio-tools:composio`, task server `34f0d3d1…`) requires authentication and this scheduled run is non-interactive, so OAuth can't be completed. Confirmed via three tool searches that no Reddit search/retrieve action is loadable. Nothing searched, surfaced, or appended to the seen-log.
>
> **No new threads surfaced since 2026-07-14 — nine days now unreviewed.** Recommendation stands: **pause this scheduled task** until Composio is re-authorized in an interactive session (claude.ai connector settings or `/mcp`), otherwise each daily run just appends another identical blocked-run note.

## 2026-07-22

> **Run blocked — no search performed (3rd consecutive).** The Composio Reddit connector is still not authorized: `plugin:composio-tools:composio` is listed as requiring authentication, and the task's Reddit tool (`COMPOSIO_MULTI_EXECUTE_TOOL`, server `34f0d3d1…`) returns no loadable schema. This run is non-interactive, so the OAuth flow cannot be completed here. Web search remains a dead fallback — reddit.com is not accessible to the search agent and routing around it is out of bounds.
>
> Nothing searched, nothing surfaced, nothing appended to the seen-log. **The digest has now produced no new threads since 2026-07-14 — eight days of r/sysadmin, r/Office365, r/msp, r/PowerShell, r/Intune activity is unreviewed.** Anything fresh from that window will have aged past the ~10-day relevance cutoff by the time the connector is restored, so those threads are effectively lost for warm-up purposes.
>
> **To fix:** re-authorize Composio in an interactive session (claude.ai connector settings, or `/mcp`). Given three straight blocked runs, strongly consider **pausing this scheduled task** until the connector is reconnected — otherwise every daily run just appends another identical blocked-run note.

## 2026-07-20

> **Run blocked again — no search performed.** Same cause as 2026-07-17: the Composio Reddit connector (`plugin:composio-tools:composio`) is listed as requiring authentication, and this scheduled run is non-interactive so OAuth can't be completed. Web search fallback confirmed dead — reddit.com is not accessible to the search user agent, and routing around that is out of bounds.
>
> Nothing searched, nothing surfaced, nothing appended to the seen-log. **This is now the second logged blocked run and the digest has produced no new threads since 2026-07-14** — roughly six days of r/sysadmin, r/Office365, r/msp, r/PowerShell, r/Intune activity is unreviewed. Those threads remain eligible whenever the connector is restored, but the freshest ones will have aged past the ~10-day window by then.
>
> **To fix:** re-authorize Composio in an interactive session (claude.ai connector settings, or `/mcp`). Until that happens every daily run will produce this same note, so it may be worth pausing the schedule rather than accumulating blocked-run entries.

## 2026-07-17

> **Run blocked — no search performed.** The Composio Reddit connector (`plugin:composio-tools:composio`) reported that it requires re-authentication, and the scheduled run is non-interactive so the OAuth flow can't be completed here. Web search is not a usable fallback: reddit.com is not accessible to the search user agent, and fetching it by other means is out of bounds.
>
> Nothing was searched, nothing surfaced, nothing appended to the seen-log. This is a *gap*, not a "nothing relevant found" — the last ~2 days of threads are unreviewed and will still be eligible on the next successful run.
>
> **To fix:** re-authorize the Composio connector in an interactive session (claude.ai connector settings, or `/mcp`). The next run picks up normally once it's connected.

## 2026-07-15

> Nothing surfaced. Searched r/sysadmin, r/Office365, r/msp, r/PowerShell, r/Intune (sort: new) plus tight waste/cost keyword passes. Every strongly on-topic thread in the last ~10 days (offboarding, disabled-user billing, volume-license reductions, MS pricing model, NCE transfer, E5 activation) was already surfaced in a prior run and is in the seen-log. The only genuinely new threads this run were tangential and not worth a reply:
> - **1uwhffz** r/sysadmin "Is the OneDrive data limit for M365 Business accounts shared?" (0.5d, 8c) — storage entitlement per SKU, not license cost/waste.
> - **1uu9prm** r/sysadmin "Microsoft Entra ID question" (2.9d, 2c) — a near-duplicate repost of the already-surfaced 1uv46ec; about cached-credential sign-in after disabling an account (device management/CA), not licensing.
> - **1uqm897** r/Office365 education-license eligibility for a training tenant (6.9d, 2c) — licensing compliance/eligibility, not waste or cost reclaim.
> - **1ur981s** r/msp Google→M365 email migration under 100 mailboxes (6.3d, 54c) — migration tooling.
>
> Holding to quality over quantity — surfacing these would push low-value or off-topic replies. Next stronger candidates will appear as the price-increase and offboarding cycles refresh.

## 2026-07-14

> Another thin day for pure license-waste threads — the July price-increase wave is over and most new licensing chatter is CSP/billing mechanics. Four threads below. #1 is the strongest (real license-assignment automation question with 25 comments); #2 is fresh and #3 is a genuine M365 billing edge case. Nothing surfaced in r/PowerShell or r/Intune worth the effort.

### 1. r/sysadmin — Solo IT at a fintech: role mapping and onboarding automation
- **Age:** 6 days | **Comments:** 25 (active, unlocked, still getting replies as of 2026-07-11)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1uqn8ey/solo_it_at_a_fintech_looking_for_advice_on_role/
- **Why it fits:** OP is explicitly planning Entra dynamic groups + automated license assignment as part of joiner-mover-leaver. Nobody in the thread has said the quiet part: group-based licensing is where license waste is *prevented*, and the leaver half is where it's *created*. Directly SeatScout's territory.
- **Suggested angle:** Point out that dynamic groups solve onboarding but do nothing for leavers — a disabled Entra account keeps its license and keeps billing, forever, and nobody notices until renewal. Recommend he wire a monthly `Get-MgSubscribedSku` check (`prepaidUnits.enabled` vs `consumedUnits`) into his source-of-truth doc from day one, and pull `signInActivity` from `Get-MgUser` to find licensed users who haven't signed in in 90 days — noting that `signInActivity` needs Entra ID P1 minimum, which a fintech almost certainly already has. Concrete, no product mention needed.

### 2. r/sysadmin — M365 HK Tenant to UAE Migration
- **Age:** 1 day | **Comments:** 9 (fresh, unlocked, answers so far are all "ask a CSP")
- **Link:** https://www.reddit.com/r/sysadmin/comments/1uv1z34/m_365_hk_tenant_to_uae_migration/
- **Why it fits:** Head office moved HK → Dubai; tenant country is locked at creation, so procurement can't buy locally. It's a licensing/billing problem people are trying to solve with a full T2T migration. Cost-per-seat and regional list-price differences are the actual decision inputs, and nobody has supplied them.
- **Suggested angle:** Agree with the "don't migrate a tenant to fix a billing address" camp, then add substance: a global CSP or a Microsoft Customer Agreement via the UAE entity can usually invoice locally against the existing tenant — the regional lock affects *who can sell*, not *who can pay*. Suggest he price both paths in real dollars first (seat count × regional list price × 12 vs. T2T project cost), because a T2T for a few hundred seats will normally cost more than years of the billing friction he's trying to remove.

### 3. r/sysadmin — Microsoft Partner and 365 benefits not aligned anymore
- **Age:** 7 days | **Comments:** 10 (unlocked, contradictory answers — MS support told OP one thing, commenters report another)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1upwe0m/microsoft_partner_and_365_benefits_not_aligned/
- **Why it fits:** Partner Success Core now only renews *after* expiry, leaving a 2-day gap where the bundled Business Premium seats theoretically stop working. Microsoft support suggested buying a trial to bridge it. This is a licensing-mechanics question where a precise answer is worth a lot and currently absent.
- **Suggested angle:** M365 subscriptions enter a 30-day grace period at expiry — users keep full service, so the "2 days without subscription" panic is likely unfounded (two commenters already hinted at this; nobody spelled out the grace/disabled/deprovisioned lifecycle). Lay out the three stages (Active → Expired/grace 30d → Disabled 90d → Deprovisioned) and tell him to verify the seats' state in the admin center rather than buying a bridging trial he doesn't need.

### 4. r/sysadmin — What's your offboarding process for service accounts and API keys?
- **Age:** 6 days | **Comments:** 2 (low traffic but score 8, unlocked — early comment could own the thread)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1ur2w0a/whats_your_offboarding_process_for_service/
- **Why it fits:** Offboarding-coverage question with one generic "we have IAM" reply. The undocumented-service-account problem has a licensing tail nobody mentions: orphaned service/shared accounts sitting on paid seats.
- **Suggested angle:** Add the angle nobody's covered — the accounts most likely to be missed are the ones with no owner, and in M365 those are often still *licensed*. Cheap discovery: list every licensed user, join against `signInActivity`, and anything licensed with zero interactive sign-ins in 90 days is either a service account nobody documented or a leaver nobody offboarded — both worth a ticket. If he mentions his own tooling here, add "disclosure: I built a tool for this."

---

## 2026-07-13

> Thin day. Six search passes across r/sysadmin, r/Office365, r/msp, r/PowerShell, r/Intune surfaced almost nothing new on license waste/cost — the July price-increase wave has passed and the remaining licensing chatter is transfer/CSP mechanics. Four threads below; #1 and #2 are the only ones worth real effort.

### 1. r/sysadmin — Microsoft Entra Question (disabled user can still sign in to laptop)
- **Age:** 0.5 days | **Comments:** 10 (fresh, unlocked, active — right answer is half-formed; several commenters are dunking rather than explaining)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1uv46ec/microsoft_entra_question/
- **Why it fits:** Textbook offboarding gap: OP bought Entra ID P2, disabled the user and the device, and the ex-user still logs in. This is exactly the "disabled ≠ offboarded ≠ unlicensed" story SeatScout is built around.
- **Suggested angle:** Explain the mechanism, not just the verdict: on an Entra-joined Windows 11 device the PIN/password unlock is validated against the cached credential (NGC container + cached logon), so Entra account disable only blocks *new cloud token issuance* — it never revokes the local unlock. Without Intune there is no device-side enforcement path; the levers are (a) Conditional Access + `Revoke-MgUserSignInSession` to kill token refresh (P2 covers this), and (b) recovering or wiping the device, since a P2 license alone cannot log a user out of hardware you don't manage. Then the cost point: P2 at list is ~2× P1, and if the only thing they wanted was device control, Business Premium bundles Intune *and* Entra ID P1 for less than buying P2 standalone plus a device-management gap — worth pricing both in the admin center before they buy more P2 seats. No product mention needed here; pure expertise.

### 2. r/msp — Microsoft NCE mid-term license transfer
- **Age:** 3.0 days | **Comments:** 37 (active, unlocked; lots of "call partner support" noise, little on the seat/cost mechanics)
- **Link:** https://www.reddit.com/r/msp/comments/1usykz2/microsoft_nce_midterm_license_transfer/
- **Why it fits:** NCE term-commitment mechanics are the cost side of M365 that most admins only meet when they're stuck paying for seats they no longer want — SeatScout's core pain.
- **Suggested angle:** Be concrete about what the customer actually owns: an NCE annual subscription is a *commitment* — the losing partner has to approve the transfer, and if they stall, the practical outs are (a) wait for the term end and place a new order with the new partner (renewal must be cancelled before the auto-renew window), or (b) escalate via the customer, not the partner, since Microsoft treats the tenant owner as the party of record. Meanwhile, tell them to pull the tenant's actual seat position with `Get-MgSubscribedSku` (prepaidUnits.enabled vs consumedUnits) before the new order — mid-term transfers are the classic moment where a customer re-buys the seat count on the old invoice rather than the count they actually use, and pays for the gap for 12 months.

### 3. r/msp — Looking for CSP in the UK (80 seats)
- **Age:** 4.3 days | **Comments:** 34 (unlocked, still moving; thread is mostly CSPs pitching themselves — a vendor-neutral technical answer stands out)
- **Link:** https://www.reddit.com/r/msp/comments/1urozcy/looking_for_csp_in_the_uk/
- **Why it fits:** "We're shopping around for new 365 licenses" for 80 seats — the moment to right-size, and nobody in the thread has said so. (Note: adjacent to the r/sysadmin UK-CSP thread already surfaced 2026-07-10; different OP, different sub.)
- **Suggested angle:** Before comparing CSP quotes, tell them to compare against their *real* consumption: `Get-MgSubscribedSku` gives purchased vs consumed per SKU, and Entra `signInActivity` (needs Entra ID P1, which they almost certainly have) gives last-sign-in per user — disabled and never-signed-in accounts still bill at full seat price. On 80 seats a 10–15% dead-seat rate is normal, and every quote they collect is priced against an inflated number. Ask the CSP whether they'll do a seat-count true-down at renewal, and get it in writing. If he references his own tooling here, add: "disclosure: I built a tool for this."

### 4. r/Intune — Windows 11 Enterprise Subscription Activation (M365 E5) failing 0xC004C003 on Autopilot
- **Age:** 5.2 days | **Comments:** 3 (quiet, but unanswered — high chance of being *the* answer)
- **Link:** https://www.reddit.com/r/Intune/comments/1uqpahx/
- **Why it fits:** Subscription Activation failures are almost always a licensing/SKU-assignment problem misread as a deployment problem — squarely SeatScout's "what is this seat actually entitled to" territory.
- **Suggested angle:** 0xC004C003 on Subscription Activation is nearly always entitlement, not imaging: confirm the *Windows 10/11 Enterprise* service plan is actually enabled inside the E5 SKU for that user (E5 assignment ≠ every service plan on), that the device is Entra-joined (not registered), and that the machine is running Pro with a genuine digital licence before the step-up applies. `Get-MgUserLicenseDetail` for the user will show whether the Enterprise service plan is `Enabled` or `Disabled` — a group-based licensing template with that plan switched off is the usual culprit, and it's invisible in the Intune blade. Worth stating plainly that the E5 seat is being paid for either way.

---

## 2026-07-10

### 1. r/sysadmin — M365 Auto "Encrypting" of outbound PHI emails
- **Age:** 1.6 days | **Comments:** 32 (active, unlocked; core answer partially given — the cost math is still missing)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1uqtlvw/m365_auto_encrypting_of_outbound_phi_emails/
- **Why it fits:** M365 neophyte convinced he needs ~$50/user E5 for something Business Premium already does — SKU-confusion-driven overbuying is exactly SeatScout territory; commenters said "Purview" but nobody has laid out the minimum-license path cleanly.
- **Suggested angle:** Confirm the cheaper path: Office 365 Message Encryption rides on Azure Information Protection P1, which Business Premium includes — an Exchange transport rule (recipient external + keyword/sensitive-info match → apply OME) needs no E5. BP's Exchange DLP also carries the medical sensitive-info types via the HIPAA template, so start there and tune. For 15 users, price BP vs E5 in the admin center and show the annual delta in real dollars (verify current prices, July changes apply). Add the SECURE-subject manual trigger as the safety valve — keyword dictionaries always miss. Pure expertise, no product tie.

### 2. r/sysadmin — Looking for a 365 CSP in the UK
- **Age:** 0.7 days | **Comments:** 12 (fresh; thread is pure MSP self-promo and DM-bait — a vendor-neutral answer will stand out)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1urp0a3/looking_for_a_365_csp_in_the_uk/
- **Why it fits:** 80-seat license purchase decision with every reply pitching their own MSP; nobody has said "right-size the count before you sign an annual NCE term."
- **Suggested angle:** Before moving 80 seats anywhere, audit what's actually assigned and used: `Get-MgSubscribedSku` (prepaidUnits vs consumedUnits) for the purchased-vs-assigned gap, plus a `signInActivity` sweep (needs Entra P1) for licensed users who never sign in — because NCE annual commitments lock the seat count for 12 months and you can't reduce mid-term. Then pick the CSP on mechanics, not vibes: renewal price protection, support model, and whether the portal lets you self-serve seat changes. If SeatScout comes up, add the plain disclosure ("disclosure: I built a tool for this").

### 3. r/Intune — Allow access to unlicensed admins
- **Age:** 10.4 days | **Comments:** 20 (older but still active; good answers scattered — nobody has framed the reclaim value)
- **Link:** https://www.reddit.com/r/Intune/comments/1uj1yui/allow_access_to_unlicensed_admins/
- **Why it fits:** Separate admin accounts carrying P2 + Intune licenses they never "use" is textbook license waste — the unlicensed-admins toggle exists precisely to reclaim those seats.
- **Suggested angle:** Confirm the thread's consensus: Intune RBAC works for unlicensed admins once the toggle is on, but it's one-way — you can't revert. The nuance worth adding: keep Entra P1/P2 on admin accounts for PIM and risk-based CA, reclaim the Intune/suite license; a handful of edge cases (device enrollment, certificate/Tunnel connectors) still need a temporarily licensed account. Then quantify it: count your admin accounts × the suite license each carries, and check `signInActivity` to prove they never touch licensed workloads — that's the reclaimable spend. Disclosure if the tool gets mentioned.

### 4. r/Intune — Intune Remote Help Helpdesk Licensing
- **Age:** 9.9 days | **Comments:** 15 (conflicting answers in-thread — a sourced, precise reply resolves it)
- **Link:** https://www.reddit.com/r/Intune/comments/1ujjdnb/intune_remote_help_helpdesk_licensing/
- **Why it fits:** Person-vs-account licensing confusion on a paid add-on — the licensing fine print SeatScout's audience wrestles with, and half the thread has it wrong.
- **Suggested angle:** Back the correct comment: Microsoft user-subscription licensing attaches to the person, not the account object — a technician's separate admin account doesn't need a second Remote Help license if their primary account is licensed (same principle as admin accounts generally). Confirm Remote Help is a paid per-user add-on on top of Intune, and flag the frontline gotcha: F-SKU users being helped need the add-on too or you're out of compliance. Link Microsoft's licensing docs rather than arguing from memory — that's what settles these threads.

### 5. r/Office365 — Can't add someone (internal user) to any Team
- **Age:** 1.6 days | **Comments:** 4 (early; three shallow guesses so far — a concrete fix will anchor it)
- **Link:** https://www.reddit.com/r/Office365/comments/1uqtwm7/cant_add_someone_internal_user_to_any_team/
- **Why it fits:** Rehire whose account went user → shared mailbox → licensed user again; offboarding lifecycle mechanics in reverse, squarely in Uğur's admin wheelhouse — credibility builder, no product tie.
- **Suggested angle:** The shared-mailbox conversion almost certainly left `HiddenFromAddressListsEnabled` set to true, and Teams people-search honors it: `Get-Mailbox user | fl HiddenFromAddressListsEnabled, RecipientTypeDetails` — clear the flag, confirm the mailbox came back as UserMailbox, and verify the Teams service plan is actually enabled inside the assigned license. Then allow up to 24–48h of directory sync before retesting. One commenter asked about GAL visibility — this is the concrete version of that hunch.

## 2026-07-09

### 1. r/sysadmin — How are you all managing offboarding access/tasks?
- **Age:** 1 day | **Comments:** 5 (early, unlocked — a concrete answer will anchor the thread)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1ur221s/how_are_you_all_managing_offboarding_accesstasks/
- **Why it fits:** Large E5 org with no real offboarding process — ex-employee mailboxes and license reclaim are exactly the leak SeatScout hunts; one commenter already flagged that Lifecycle Workflows needs Entra ID Governance, but nobody has laid out the license-reclaim sequence.
- **Suggested angle:** Build on the Governance-add-on comment (it's correct — Lifecycle Workflows isn't in E5) and give the zero-extra-cost sequence: block sign-in → convert mailbox to shared **before** removing the license (≤50GB shared mailboxes are free, mail keeps flowing for the manager) → remove the license the same day so the seat returns to the pool, all scriptable with Graph on a schedule. Add the safety net: a monthly `signInActivity` sweep (Entra P1, which E5 includes) catches offboards that slipped through and are still burning an E5 seat. If SeatScout comes up, add the plain disclosure ("disclosure: I built a tool for this").

### 2. r/Office365 — Microsoft subscriptions for a small law firm
- **Age:** 10 days | **Comments:** 88 (busy and older — reply only to add the numbers nobody has run)
- **Link:** https://www.reddit.com/r/Office365/comments/1uie17m/microsoft_subscriptions_for_a_small_law_firm/
- **Why it fits:** 8 staff, previously 15 Business Premium subs at a 16% reseller margin, now 10 Business Standard for 8 users — overbought seats and SKU confusion in one thread; top comments argue "hire IT" but nobody has quantified the waste.
- **Suggested angle:** Skip the hire-IT lecture (done to death in-thread) and run his actual numbers: 10 licences for 8 people is 2 seats of pure waste, visible in Billing > Licenses (assigned vs purchased) or `Get-MgSubscribedSku` (consumedUnits vs prepaidUnits) — and the old setup was 15 for 8. On the SKU question, be fair: Business Premium's premium over Standard buys Intune, Conditional Access and Defender for Business, which a firm holding client files should seriously weigh, so right-size the count first, then upgrade the SKU with the savings. Quote current per-seat prices from the admin center rather than memory (July price changes apply).

### 3. r/Office365 — Multiple emails (one license, 4 people needing mail)
- **Age:** 2 days | **Comments:** 9
- **Link:** https://www.reddit.com/r/Office365/comments/1uqadoi/multiple_emails/
- **Why it fits:** Owner keeps 4 users on third-party email because full M365 suites feel too expensive — the classic "mail-only users don't need a full seat" licensing-mix question SeatScout's audience lives with.
- **Suggested angle:** Point out the mix-and-match option: mail-only users can sit on Exchange Online Plan 1 (a real 50GB mailbox on the company domain, no Office apps) while the one person who needs desktop Office keeps Apps for Business — licenses in one tenant don't have to match. Warn against the tempting shortcut: shared mailboxes as free pseudo-users violates licensing the moment someone signs into one directly. Quote the current EXO Plan 1 price from the admin center vs what the third party charges so the trade-off is in real dollars.

### 4. r/Office365 — Alternatives to GoDaddy o365 subscription?
- **Age:** 2 days | **Comments:** 12
- **Link:** https://www.reddit.com/r/Office365/comments/1upie1a/alternatives_to_godaddy_o365_subscription/
- **Why it fits:** Sub-10-user business stuck on GoDaddy's locked-down M365 reseller tenant after a security incident — licensing ownership and cost-control question where most replies just say "leave GoDaddy" without the how.
- **Suggested angle:** Explain that GoDaddy resells M365 through a restricted CSP arrangement, and there's a documented **defederation** path that converts the tenant to self-managed without migrating mailboxes — data and domain stay, but plan for it carefully: passwords reset during the cutover and MFA needs re-registering. After defederation they can buy the same SKUs direct from Microsoft or any CSP at list price and finally own the admin center, including the MFA/password controls that started this thread. Straight factual advice; no product tie needed unless it comes up naturally, then disclose plainly.

## 2026-07-08

### 1. r/sysadmin — Reductions in volume licenses M365 Admin?
- **Age:** <1 day | **Comments:** 2 (early — a substantive answer will be *the* answer)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1uqe2b2/reductions_in_volume_licenses_m365_admin/
- **Why it fits:** Available license counts dropped 500→170 overnight across 4 SKUs (3 others went up) outside any renewal — exactly the purchased-vs-consumed visibility problem SeatScout is built around.
- **Suggested angle:** The down-some/up-some pattern usually means a subscription transition, not lost seats: a renewal or billing migration (CSP/MCA-E) replaces one subscription object with another, or a promo/trial slid into Suspended. Point him to Billing > Your products to check each SKU's status and look for duplicated entries, then `Get-MgSubscribedSku` comparing `prepaidUnits.enabled/suspended/warning` vs `consumedUnits` — units sitting in `suspended`/`warning` reveal a lapsed subscription in grace period. If seats truly vanished mid-term, open a billing ticket with the subscription IDs. If SeatScout comes up, add the plain disclosure ("disclosure: I built a tool for this").

### 2. r/sysadmin — Anyone running a 365 business premium homelab?
- **Age:** <1 day | **Comments:** 26
- **Link:** https://www.reddit.com/r/sysadmin/comments/1uq84nk/anyone_running_a_365_business_premium_homelab/
- **Why it fits:** "Cheapest legitimate way to lab Intune/Autopilot/Entra hybrid join" is a pure license-selection/cost question, fresh and busy.
- **Suggested angle:** One Business Premium seat on an NCE **monthly** term is the practical route — slightly more per month than annual but cancellable anytime, and it carries Intune, Autopilot and Entra ID P1 for the whole lab tenant (devices don't consume seats, only the user does). Worth noting the old free M365 Developer Program E5 sandbox is now gated behind Visual Studio Enterprise/Partner benefits, which is why BP-for-one became the default lab answer. Quote current pricing from the admin center rather than from memory — July price changes apply.

### 3. r/Office365 — Exchange 365 Mailbox Quotas
- **Age:** 4 days | **Comments:** 4
- **Link:** https://www.reddit.com/r/Office365/comments/1umtkoh/exchange_365_mailbox_quotas/
- **Why it fits:** Mailbox shows 47/50GB but the inbox is only 20GB — RecoverableItems under retention hold eats the quota; commenters gave the mechanism, nobody has priced the licensing lever.
- **Suggested angle:** Confirm the mechanics (retention/litigation hold pins RecoverableItems and it counts against the primary quota; `Get-MailboxFolderStatistics -FolderScope RecoverableItems` shows exactly where the 27GB sits), then add the choice the thread is missing: if the hold must stay, an Exchange Online Plan 2 / E3 seat doubles the primary quota to 100GB and unlocks auto-expanding archive — price that per-seat bump against simply scoping the retention policy tighter. Keep it plainly factual and cite cmdlets: a commenter is already annoyed at an AI-generated wrong answer in this thread.

### 4. r/msp — Client wants to purchase all licensed
- **Age:** 8 days | **Comments:** 105 (busiest and oldest of the batch — reply only to add the missing angle)
- **Link:** https://www.reddit.com/r/msp/comments/1ujfqga/client_wants_to_purchase_all_licensed/
- **Why it fits:** MSP debating whether a client can self-purchase the M365 stack — license ownership economics; top comments cover "say no" and GDAP but nobody has quantified the hygiene gap.
- **Suggested angle:** Agree with the emerging consensus (M365 self-purchase is workable since GDAP keeps management identical; the rest of the stack, hold firm) but add the dollars nobody mentioned: client-owned tenants with no one watching license hygiene routinely carry unassigned and inactive-but-licensed seats, so bake a quarterly purchased-vs-consumed review (`Get-MgSubscribedSku` + a `signInActivity` sweep) into the management fee — it makes the MSP's value measurable. Include the plain disclosure if SeatScout gets named.

## 2026-07-07

### 1. r/sysadmin — Anyone else downgrading their Microsoft 365 sub?
- **Age:** 6 days | **Comments:** 151 (busy but unlocked and still moving; a substantive comment can still land)
- **Link:** https://www.reddit.com/r/sysadmin/comments/1ukkgmd/anyone_else_downgrading_their_microsoft_365_sub/
- **Why it fits:** Score ~220 thread of orgs being pushed E5→E3 by renewal quotes — the exact cost-pressure conversation SeatScout lives in; top comments debate value but nobody has laid out a concrete pre-downgrade audit.
- **Suggested angle:** Add the methodology the thread lacks: before downgrading wholesale, inventory which E5-only features are actually consumed — Entra P2 (PIM, access reviews, risk-based CA), Defender suite, Purview — because that list becomes your re-license/third-party gap plan. Then run `Get-MgSubscribedSku` (prepaidUnits vs consumedUnits) and a `signInActivity` sweep (still works on E3 — it needs Entra P1) to find seats that shouldn't be renewed on *any* SKU; often mixed licensing (E5 for the security/IT slice, E3 for the rest) beats a flat downgrade. If SeatScout comes up, add the plain disclosure.

### 2. r/sysadmin — Teams Phone massive price increase expected?
- **Age:** 1 day | **Comments:** 13
- **Link:** https://www.reddit.com/r/sysadmin/comments/1up1h8i/teams_phone_massive_price_increase_expected/
- **Why it fits:** OP's Teams Phone seats jumped from $8-9 to ~MSRP after a billing-model switch — real-dollar license pricing confusion with only partial answers so far.
- **Suggested angle:** Explain the mechanism, not just the number: promo/negotiated pricing doesn't survive a MOSA→MCA-E (or CSP) migration — the seats reprice at current list (~$17.85 for Teams Phone with Calling Plan), and the "double bill" is usually arrears-vs-advance billing overlapping one month. Advise pulling invoice line items in the admin center, counting purchased vs actually-assigned Teams Phone seats before renewal, and getting a CSP quote to compare against direct MCA-E list.

### 3. r/Office365 — Help me understand the pricing model between all MS plans.
- **Age:** <1 day | **Comments:** 27
- **Link:** https://www.reddit.com/r/Office365/comments/1upphjh/help_me_understand_the_pricing_model_between_all/
- **Why it fits:** Classic "lost in Business vs Enterprise vs E1/E3/E5" confusion; m365maps.com got mentioned but nobody has given a decision path with real prices.
- **Suggested angle:** Give the 4-line map: Business plans (Basic/Standard/Premium) cap at 300 seats, Enterprise (E1/E3/E5) is unlimited; "Office 365 EX" is apps+services only while "Microsoft 365 EX" adds Entra/Intune/security — that prefix trap causes most mischarges. Then the decision path: need desktop Office? rules out Basic/E1; need device management or conditional access? Business Premium or M365 E3; then price per user/month annually and only pay E5 where its security stack is actually used.

## 2026-07-03

### 1. r/Office365 — Copilot license
- **Age:** 1 day | **Comments:** 5
- **Link:** https://www.reddit.com/r/Office365/comments/1ul3slj/copilot_license/
- **Why it fits:** Business Standard user unsure which Copilot SKU an AI-enabled SharePoint FAQ widget needs — pure license-selection/cost question.
- **Suggested angle:** Clarify the decision in real dollars: the M365 Copilot add-on (~$30/user/mo, annual commitment under NCE) stacks on Business Standard, and per current licensing only the person configuring the widget needs it — viewers don't. Contrast with Copilot Studio (~$200/mo tenant capacity) which only pays off if they plan multiple agents. Suggest starting with a single monthly-term seat (slightly pricier per month) for the trial, since NCE annual seats can't be reduced mid-term.

### 2. r/sysadmin — 365 Group Based Licenisng
- **Age:** 3 days | **Comments:** 7
- **Link:** https://www.reddit.com/r/sysadmin/comments/1ujy819/365_group_based_licenisng/
- **Why it fits:** Group-based licensing via dynamic groups silently stopped applying — exactly the license-assignment plumbing SeatScout lives in.
- **Suggested angle:** Add what the thread is missing: group assignment halts silently when the SKU pool runs dry and does not retry on its own. Run `Get-MgSubscribedSku` and compare `prepaidUnits.enabled` vs `consumedUnits` to confirm free seats, check the group's error state in Entra ID > Groups > Licenses, then hit "Reprocess" (or the Graph `reprocessLicenseAssignment` action). Mention the multi-SKU gotcha a commenter raised: if the group assigns E3 + an add-on and either pool is short, nothing gets applied.

### 3. r/sysadmin — July 2026 Microsoft 365 Changes Admins Should Know
- **Age:** 2 days | **Comments:** 67
- **Link:** https://www.reddit.com/r/sysadmin/comments/1uki6j3/july_2026_microsoft_365_changes_admins_should_know/
- **Why it fits:** High-visibility monthly roundup (score 335) landing exactly when July price increases hit — natural spot for a pre-renewal audit comment.
- **Suggested angle:** Add the cost-action footnote: before renewing at the new July prices, reconcile purchased vs consumed with `Get-MgSubscribedSku`, then sweep for disabled-but-still-licensed accounts (`accountEnabled eq false` + `assignedLicenses`) and 90-day-inactive users via `signInActivity` — noting signInActivity needs Entra ID P1. If SeatScout comes up, add "disclosure: I built a small tool that automates this sweep."

### 4. r/msp — Upgrading yearly commitment Business Standard to Premium possible? (Non profit)
- **Age:** 8 days | **Comments:** 18
- **Link:** https://www.reddit.com/r/msp/comments/1uf01er/upgrading_yearly_commitment_business_standard_to/
- **Why it fits:** NCE commitment mechanics + nonprofit pricing — SKU upgrade/downgrade rules are core licensing-cost territory.
- **Suggested angle:** Confirm the asymmetry: NCE allows a mid-term *upgrade* from Business Standard to Premium with prorated credit, but never a downgrade until the anniversary — so their "Standard now, Premium later if needed" plan is safe. Add the sizing tip: before the annual commit, count actually-active users (last sign-in via `signInActivity`) so they don't lock in seats for dormant accounts for a full year.

### 5. r/sysadmin — Best practice for deleting old disabled Microsoft 365 accounts without losing data in 2026?
- **Age:** 15 days (older than the usual 10-day window, still active) | **Comments:** 36
- **Link:** https://www.reddit.com/r/sysadmin/comments/1u9cwy6/best_practice_for_deleting_old_disabled_microsoft/
- **Why it fits:** Inherited pile of disabled-but-licensed accounts — the single most SeatScout-shaped problem in this batch; thread covers data retention but nobody has priced the waste.
- **Suggested angle:** Add the licensing-cost lens the 36 comments skip: disabled ≠ free — every disabled account still holding E3/E5 keeps billing (~$33+/seat/mo for E3 after the July increase). Sequence: export or convert to shared mailbox (≤50GB needs no license), move OneDrive to SharePoint, then strip the license the same day; finish with a tenant sweep for `accountEnabled eq false` + `assignedLicenses` via Graph to find seats already leaking money. If he references SeatScout, include the plain disclosure.
