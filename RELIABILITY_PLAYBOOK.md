# Reliability Playbook — Stop Claude From "Fixing Forever"

> Deep-check result. Sources: Anthropic's official Claude Code best-practices, 2026 research on agent reliability (TDD-agents, spec-driven development, agentic guardrails), and the top GitHub tooling. The method below is what the whole industry converged on in 2026.

## The root cause (this is the whole answer)
Anthropic's own docs say it plainly:
> "Claude stops when the work **looks** done. Without a check it can run, 'looks done' is the only signal available, and **you become the verification loop**: every mistake waits for you to notice it."

That is exactly the "fixing fixing all my life" loop. The agent guesses → you find the bug → it guesses again. Research agrees: without test/build infrastructure, agents "spin in infinite loops of guesses."

**The fix is not a smarter model. It is giving Claude a pass/fail check it runs itself.** Then the loop closes on its own: Claude does the work, runs the check, reads the result, and iterates until it passes — before it ever reaches you.

## The 6 mechanisms (in priority order)

### 1. A verification gate Claude runs itself  ⭐ most important
Give Claude something that returns pass/fail: tests, a build exit code, a linter, or a screenshot diff. We added **`./check.sh`** (typecheck + lint + build). Rule in CLAUDE.md: *do not say "done" until `./check.sh` passes, and paste the output as evidence.*
- Harder gate: a **Stop hook** that runs `./check.sh` as a script and **blocks the turn from ending** until it passes — deterministic, not advisory.
- Across a session: set it as a `/goal` condition so a separate evaluator re-checks after every turn.

### 2. Spec before code (stop solving the wrong problem)
The 2026 failure mode is "drift": confident, plausible code that quietly solves the wrong thing. Write a short spec with acceptance criteria BEFORE coding. Anthropic's trick: *"I want to build X. Interview me using AskUserQuestion about edge cases and tradeoffs, then write the spec to SPEC.md."* Then start a fresh session to implement against SPEC.md.
- Tooling if you want structure: **github/spec-kit**, **spec-kitty/spec-kitty** (⭐1.6k, adds a "Charter" that governs HOW agents build + review gates).

### 3. CLAUDE.md — persistent rules (stop repeating the same mistake)
A short file Claude reads every session. We added one. Keep it ruthlessly pruned — for each line ask *"would removing this cause a mistake?"* If not, cut it. A bloated CLAUDE.md makes Claude ignore the important rules.

### 4. Hooks — guarantees, not suggestions
CLAUDE.md is advisory; **hooks are deterministic**. Examples: run the linter after every file edit; block writes to `.env`/migrations; run `./check.sh` on Stop. Ask Claude: *"write a hook that runs ./check.sh and blocks the turn from ending until it passes."*

### 5. Adversarial review in a fresh context
Before "done," have a **subagent** review the diff against the plan in a clean context (it sees the diff, not the reasoning). Anthropic ships `/code-review` for this. Tell it to flag only correctness/requirement gaps, not style — a reviewer asked for gaps always finds some.

### 6. Context hygiene (half of all agent mistakes)
Performance degrades as context fills. Rules from Anthropic:
- `/clear` between unrelated tasks.
- **If you've corrected Claude twice on the same issue, stop** — `/clear` and rewrite the prompt with what you learned. A clean session beats a long polluted one.
- Use **subagents** for research so exploration doesn't eat your main context.
- Scope prompts: name the file, the symptom, what "fixed" looks like, and "address the root cause, don't suppress the error."

## The one-time setup for this project
1. Put **`CLAUDE.md`** at the project root (auto-loaded every session).
2. Make **`./check.sh`** real: edit it to this repo's actual `package.json` scripts, then `chmod +x check.sh`.
3. Add a **Stop hook** running `./check.sh` (ask Claude to write it into `.claude/settings.json`).
4. For any non-trivial task: **spec → plan → code → ./check.sh → /code-review → deploy one change → verify → purge Cloudflare → re-verify.**
5. Between unrelated tasks: `/clear`.

## Marketing "without errors" — same principle
You cannot make an AI never err; you make errors **rare, auto-caught, and cheap to undo**:
- **Measure first.** Install the Google Ads tag + WhatsApp conversion tracking (see WORK_BRIEF). An agent optimizing ads with no conversion data is guessing — same broken loop, but with your money.
- **Human-in-the-loop on every write.** Use an ads MCP that gates writes behind approval (e.g. `amekala/ads-mcp`, `markifact/markifact-mcp`, `pipeboard-co/meta-ads-mcp`). Claude proposes, you approve, then it executes.
- **Hard guardrails.** Budget caps the agent cannot exceed; campaigns created PAUSED by default.
- **Weekly loop.** Claude reads real conversion data → proposes changes → you approve → it applies. The conversion data is the "check.sh" of marketing: the pass/fail signal that stops the guessing.

## Sources
- Anthropic — Best practices for Claude Code (code.claude.com/docs/en/best-practices)
- Beyond Autocomplete: Agentic Coding Workflow 2026 (kilo.ai)
- Spec-Driven Development with AI Coding Agents 2026 (tryzeroshot.com)
- github/spec-kit · spec-kitty/spec-kitty · wesammustafa/Claude-Code-Everything-You-Need-to-Know
