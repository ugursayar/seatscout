# SeatScout — Deploy the site (free, ~10 min)

The marketing site lives in `site/` (landing page + blog). It's static HTML — no build step. Cloudflare Pages hosts it free, with free SSL, and works fine from a **private** GitHub repo.

---

## Option 1 — Cloudflare Pages from the GitHub repo (recommended)

1. Create a free Cloudflare account → **Workers & Pages** → **Create** → **Pages** → **Connect to Git**.
2. Authorize Cloudflare for GitHub and pick **ugursayar/seatscout** (private is fine).
3. Build settings:
   - **Framework preset:** None
   - **Build command:** *(leave empty)*
   - **Build output directory:** `site`
4. **Save and Deploy.** You'll get a `*.pages.dev` URL in ~1 minute. Test it.
5. **Custom domain:** Pages → your project → **Custom domains** → add `seatscout.com` (and `www`). Follow the DNS prompt.
   - Easiest: move the domain's nameservers to Cloudflare (Cloudflare will tell you the two NS records to set at your registrar). Then the domain + DNS + SSL are all managed in one place.
6. Every `git push` to `main` auto-redeploys. (My Composio push path already keeps the repo current.)

**Result:** `https://seatscout.com` serves `site/index.html`, and `https://seatscout.com/blog/how-to-find-wasted-microsoft-365-licenses` serves the blog post.

---

## Option 2 — Drag-and-drop (no Git)

Cloudflare Pages → **Create** → **Upload assets** → drag the **contents of the `site/` folder** (not the folder itself) → Deploy. Add the custom domain as in step 5 above. Re-upload to update.

---

## After deploy — wire the store

Once your Lemon Squeezy products exist, the three buttons in `site/index.html` need the real URLs (currently placeholders):
- `LEMONSQUEEZY_LITE_URL`
- `LEMONSQUEEZY_SOLO_URL`
- `LEMONSQUEEZY_PRO_URL`
- `LEMONSQUEEZY_SUPPORT_EMAIL`

Send me the checkout URLs and I'll do the find-replace and push — the site auto-redeploys.

---

## Notes
- Keep the paid `dist/*.zip` files **out** of the public site — they're delivered via Lemon Squeezy after purchase, not hosted here. (`.gitignore` already excludes `dist/`.)
- The `sample/SeatScout-Report.html` is safe to publish (demo data only) and is linked from the landing page.
