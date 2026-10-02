# Rento Line — Work Brief for Laptop Claude

> هذا الملف جهّزته جلسة Claude سحابية بعد تدقيق خارجي كامل للموقع.
> افتح Claude على اللابتوب (Desktop app أو `claude` في مجلد المشروع)، وأعطِه هذا الملف، ونفّذ المهام بالترتيب.
> اللابتوب يملك SSH + المفاتيح، فهو ينفّذ مباشرة على السيرفر. اشتغل بأمان: نسخة احتياطية قبل كل تعديل، build + تحقّق قبل النشر، نقطة تراجع جاهزة، وفرّغ كاش Cloudflare بعد النشر ثم تحقّق.

## Context
- **Server:** `root@2.29.40.77` (Hetzner). Project at `/opt/autorental`.
- **Stack:** Next.js storefront + Medusa admin + Express API (monorepo under `apps/`).
- **pm2 apps:** `rentoline-api`, `rentoline-blog`, `rentoline-media-worker`, `rentoline-storefront`.
- **Hosts:** `api.rentoline.com` → DNS-only, nginx + Express. `rentoline.com` → behind Cloudflare, Next.js. `admin.rentoline.com` → admin panel.
- **Indexed languages (intentional):** en, ar, ru only. es/zh/th/ur are `noindex` on purpose — leave as-is.

## Audit summary (external crawl of 1,423 sitemap pages — site is healthy)
Passing: 0 noindex-in-sitemap conflicts · 0 missing titles/descriptions · 0 missing alt (20,540 imgs) · exactly 1 h1/page · 0 heading skips · rich structured data (AutoRental, Vehicle, Offer, FAQPage…) · TTFB median ~0.3s · 0 pages >1MB · all 919 sitemap images now on `rentoline.com` (old api-host image issue fixed).

---

## TASK 1 — 🔴 SECURITY (do first)
Secrets were found in plaintext `.bak` files on the server (727 files, ~41 MB). Matches: `sk_live` (Stripe), `whsec_` (Stripe webhook), `AKIA…` (AWS), `sk-proj` (OpenAI), `BEGIN PRIVATE KEY`.
1. **Rotate every one of those keys** at its provider (Stripe dashboard, AWS IAM, OpenAI platform). Update the real `.env`, then `pm2 restart` the affected app.
2. After rotating, remove or move the secret-bearing `.bak` files out of the web/app tree:
   `find /opt/autorental -name '*.bak*' -path '*api-keys*' -o -name '.env.bak*'` → review, then delete.
3. Confirm `.gitignore` still excludes `.env`, `.env.*`, `*.bak*`, `dist`, `.next`, `*.log`.

## TASK 2 — 🟡 MARKETING TRACKING (high value: makes ad spend measurable)
Finding: only GA4 (`G-K3X6L731BD`) is live on the site. The Google **Ads** tag (`AW-18483330836`) is NOT installed anywhere → ad conversions are currently unmeasured.
1. **Install the Google Ads tag.** Either (a) in Google Tag Manager, add the Ads account as a *destination* of the existing Google tag, or (b) add `AW-18483330836` alongside the GA4 snippet in the storefront `<head>`. Find it via:
   `grep -rn "G-K3X6L731BD\|googletagmanager\|gtag" /opt/autorental/apps/storefront --include=*.tsx --include=*.ts -l`
2. **WhatsApp conversion tracking.** There are ~1,548 `wa.me` links and clicks are invisible. Add a click handler on every WhatsApp CTA that fires: GA4 event `generate_lead`, a Google Ads conversion, and Meta CAPI `Lead` (server-side). Capture which car/company/page/UTM drove it; log leads in the admin.
3. **Meta Pixel + Conversions API** for the same events.

## TASK 3 — 🟡 SEO fixes (small)
1. **17 titles >60 chars** — trim them (max observed 73). Find with a crawl or in the title-generation code.
2. **2 duplicate title pairs** — `/ar/cars` and `/ar/rent-a-car-dubai` share a title (same in `/ru`). Differentiate the title, or make one canonical to the other.
3. **Broken internal link** `/cdn-cgi/l/email-protection` returns 404, linked from 36 pages (the `agents` page). Fix Cloudflare Email Obfuscation or remove the plaintext email that triggers it.
4. **1 page 502** — `/th/cars/united-arab-emirates/dubai/massa-cadillac-escalade` (th is noindex, low priority, but check why it errors).

## TASK 4 — 🟢 SECURITY HEADERS (quick wins)
1. `rentoline.com` (front) is missing `Content-Security-Policy`, `Referrer-Policy`, `Permissions-Policy` — the API already has them. Add via `next.config.js` headers() or the front nginx block.
2. Hide version disclosure: `server_tokens off;` (nginx), `app.disable('x-powered-by')` (Express), remove `X-Powered-By: Next.js`.
3. `X-XSS-Protection` — set to `0` (the `1; mode=block` value is deprecated).

---

## Marketing growth notes (low-budget ad playbook — reference, not code)
Dubai car rental = very expensive CPC. Win small-budget by: **(0)** fix tracking first (Task 2) or spend is blind. **(1)** retarget WhatsApp-clickers + site visitors before cold. **(2)** Meta Click-to-WhatsApp ads (cheapest for this model). **(3)** Google Search on exact/phrase high-intent terms only — NOT PMax on a small budget. **(4)** strong negative-keyword list. Free levers: Google Business Profile + review stars (`google_place_id` per company → unlocks rating stars, the single biggest CTR lever), Reels of luxury cars, SEO.

## Safe-deploy checklist (every change)
`cp file file.bak-$(date +%F)` → edit → `npm run build` + lint/typecheck → `pm2 restart <app>` → verify endpoint 200 → purge Cloudflare cache → re-verify. Keep a rollback point. Never commit `.env`/`.bak`/secrets.
