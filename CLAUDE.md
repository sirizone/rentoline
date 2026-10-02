# CLAUDE.md — Rento Line

> Place this file at the root of the directory Claude works in (the project root, e.g. `/opt/autorental`).
> Claude Code loads it automatically every session. Keep it SHORT — if a rule isn't preventing a real mistake, delete it.

## Project
- Monorepo at `/opt/autorental`: `apps/storefront` (Next.js, public site), `apps/admin` (Medusa admin), `packages/api` (Express API).
- Runs under **pm2**: `rentoline-api`, `rentoline-blog`, `rentoline-media-worker`, `rentoline-storefront`.
- Hosts: `rentoline.com` (Next.js, **behind Cloudflare**), `api.rentoline.com` (nginx+Express, DNS-only), `admin.rentoline.com`.
- Git: origin = gitea `http://localhost:3000/octavion/autotorental.git`. Branches carry real work — never force-push or delete shared branches.

## Commands (VERIFY these against package.json before relying on them)
- Build: `npm run build` (or per-app: `npm run build -w apps/storefront`)
- Lint / typecheck: `npm run lint` · `npm run typecheck`
- Verify-before-deploy gate: `./check.sh` (see below)
- Restart after deploy: `pm2 restart <app> --update-env`

## Workflow — IMPORTANT
- For any change touching **more than one file or code you don't fully know**: explore + write a short plan FIRST, then code. One-line fixes can skip the plan.
- **Back up before editing**: `cp <file> <file>.bak-$(date +%F)` — but NEVER commit `.bak` files.
- **Always run `./check.sh` and show its output before deploying.** Do not say "done" until build/lint/typecheck pass. Paste the evidence.
- Deploy **one change at a time**, verify the endpoint returns 200, keep a rollback point.
- After deploying anything on `rentoline.com`: **purge Cloudflare cache, THEN re-verify** — Cloudflare caches HTML, so an un-purged check reads the old page and lies.

## Never
- Never commit or push `.env`, `.env.*`, `*.bak*`, `dist`, `.next`, secrets, or API keys.
- Never suppress an error to make a build pass — fix the root cause.
- Never skip, disable, or delete a test to get green.

## Gotchas (non-obvious, cost real time before)
- **Admin (Medusa) ships a prebuilt CSS bundle** — some Tailwind classes (e.g. `mb-5`, `sm:grid-cols-4`, `mt-1.5`) are NOT in it and silently do nothing. Use inline styles for those in admin components.
- **Secrets leaked in `.bak` files** on the server (`sk_live`, `AKIA`, `sk-proj`, `whsec_`, private keys). Rotate them and keep `.bak` out of git.
- `api.rentoline.com/robots.txt` is `Disallow: /` by design — don't "fix" it blindly; images now serve from `rentoline.com`.
- Indexed languages are **en, ar, ru only**; es/zh/th/ur are `noindex` on purpose.
