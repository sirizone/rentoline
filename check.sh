#!/usr/bin/env bash
# check.sh — the "ground truth" gate. Claude must run this and see it PASS before deploying.
# This is what breaks the endless fix-loop: it turns "looks done" into a real pass/fail signal.
# Edit the commands below to match this repo's actual package.json scripts.
set -uo pipefail
cd "$(dirname "$0")"

fail=0
step () { # step "name" command...
  echo "──▶ $1"
  if "${@:2}"; then echo "   ✅ $1"; else echo "   ❌ $1 FAILED"; fail=1; fi
}

# --- edit these to your real scripts (per-app or root) ---
step "typecheck" npm run typecheck
step "lint"      npm run lint
step "build"     npm run build
# step "unit tests" npm test
# ---------------------------------------------------------

echo
if [ "$fail" -eq 0 ]; then
  echo "✅ ALL CHECKS PASSED — safe to deploy."
  exit 0
else
  echo "❌ CHECKS FAILED — DO NOT deploy. Fix the root cause and re-run ./check.sh."
  exit 1
fi
