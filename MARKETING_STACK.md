# Open-Source Marketing Stack — Rento Line

> Result of a deep web-wide research sweep (7 parallel researchers across the whole internet, not just GitHub, then a ranked synthesis). Tailored to Rento Line: Dubai car-rental marketplace on Next.js storefront + Medusa admin + Express API, WhatsApp-first lead-gen, active on IG/FB/X/TikTok/Pinterest.

## 🚀 Start here (top 3, highest impact-per-effort)

1. **Server-side conversion tracking FIRST — before any ad spend.** Stand up **RudderStack**, instrument the booking funnel + WhatsApp click-to-chat as server events, forward to **GA4 + Google Ads + Meta CAPI**. This closes the "Ads tag not installed" gap AND recovers off-site WhatsApp bookings that client tags miss (iOS/ad-blockers). Pair with **Umami** (15-min Node/Docker deploy) or **Matomo** for the dashboard. *Nothing paid ships until this forwards conversions.*
2. **Chatwoot + WAHA** for the WhatsApp inbox (your #1 channel). WAHA puts your existing number behind Chatwoot in one Docker container, no Meta approval — every click-to-chat becomes a labeled, followed-up lead. (Migrate to Meta's official Cloud API via Evolution API before pointing heavy paid traffic at it.)
3. **Dub** for branded short links + per-channel UTMs across all 5 socials (use free Cloud tier). With step 1's tracking, you learn within weeks which of IG/FB/X/TikTok/Pinterest actually produces chats and bookings. Also quick: the **Medusa reviews plugin** (npm install, no new service) → AggregateRating rich snippets that lift booking-page CTR.

## 📦 Full recommended stack (ranked)

| # | Need | Primary pick | Self-host | Alternative |
|---|------|--------------|-----------|-------------|
| 1 | Analytics + conversion | **[Matomo](https://matomo.org/)** — full GA4 replacement, own your data (UAE PDPL), WhatsApp click = Goal, UTM per channel, Medusa e-commerce | Medium (PHP/MySQL, Docker) | **Umami v2** — best stack fit (Node+Postgres, 15-min), cookieless; no heatmaps |
| 2 | Ad conversion layer | **[RudderStack](https://github.com/rudderlabs/rudder-server)** — server-side events → GA4 + Google Ads + Meta CAPI from one pipeline; fixes the missing Ads tag + recovers WhatsApp conversions | Medium (Docker+Postgres) | **Jitsu** (MIT) if license freedom matters |
| 3 | WhatsApp inbox (#1) | **[Chatwoot](https://github.com/chatwoot/chatwoot) + WAHA** — all channels in one agent inbox; every lead labeled & tracked; add **Typebot** to auto-qualify | Medium (Rails); WAHA Easy | **Evolution API** gateway (Baileys→official Cloud API) |
| 4 | CRM / leads | **[Frappe CRM](https://github.com/frappe/crm)** — native 2-way WhatsApp + web-to-lead, Kanban pipeline, one-command Docker | Easy (Docker) | **Twenty** — Node/TS, best stack fit, build connectors yourself |
| 5 | Link / UTM attribution | **[Dub](https://github.com/dubinc/dub)** — brand every wa.me + link-in-bio, per-channel UTM + QR, attributes clicks→bookings | Hard self-host → use free Cloud | **Shlink** — bulletproof single container, plainer analytics |
| 6 | Email / lifecycle | **[Plunk](https://github.com/useplunk/plunk)** — Node/TS, event API: booking-created, abandoned-quote, "pickup tomorrow" drips; on AWS SES (~$0.10/1k) | Medium (Node+Postgres+Redis+SES) | **Listmonk** — single Go binary, $5 VPS; **Mautic** if you need email+SMS+WhatsApp in one flow |
| 7 | Social scheduling | **[Postiz](https://github.com/gitroomhq/postiz-app)** — Node, all 5 networks + LinkedIn, AI drafting, calendar, ~37k⭐ | Medium (Docker + per-network dev apps) | **TryPost** — most permissive free self-host |
| 8 | A/B testing | **[GrowthBook](https://github.com/growthbook/growthbook)** — real stats engine, reads your GA4→BigQuery, SDK in Next.js/Express, feature flags | Easy–Medium (Docker+Mongo) | **PostHog Cloud** — funnels+replay+heatmaps+experiments, free tier |
| 9 | Reviews / reputation | **[Lambda Curry Medusa Reviews](https://github.com/lambda-curry/medusa-plugins)** — Medusa-native, owns data, emits Review/AggregateRating schema for rich snippets | Easy (npm plugin) | Pair with a managed **Google Business Profile** for off-site/Maps |
| 10 | SEO / rank tracking | **[SerpBear](https://github.com/towfiqi/serpbear)** — Next.js+SQLite, tracks Dubai terms (+Arabic), GSC integration | Easy (1 container + SERP API key) | **SEOnaut** — technical crawler/audit (broken links, redirects, dup meta) |

## 🔌 How it wires together (for your Node stack)
- **Tracking is the gate:** nothing paid ships until RudderStack forwards GA4 + Google Ads + Meta CAPI. RudderStack + Umami/Matomo + Dub = the measurement foundation.
- **Same-runtime quick wins (lowest ops):** Umami, Plunk, Postiz, Typebot, Medusa reviews plugin are all Node/Next.js — deploy with your existing skills.
- **Off-stack but best-in-class (own container, talk over REST):** Matomo (PHP), Chatwoot (Rails), Frappe CRM (Python).
- **Event flow:** Express fires events → Plunk (lifecycle email) + RudderStack (analytics/ad conversions). WhatsApp leads: WAHA/Evolution → Chatwoot inbox → Frappe CRM pipeline. Typebot qualifies leads (car class, dates, pickup, visa) before a human picks up.
- **Licensing:** mostly MIT/GPL/AGPL, free to self-host internally. RudderStack is source-available (ELv2 — fine unless you resell it). AGPL only matters if you redistribute a modified build (you won't).
- **Honest cloud caveats:** PostHog and Dub are self-hostable but heavy (ClickHouse/Kafka, Tinybird) — use their free/EU cloud tiers; everything else runs fine on a small VPS.
