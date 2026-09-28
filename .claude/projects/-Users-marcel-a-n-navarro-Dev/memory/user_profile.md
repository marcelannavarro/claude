---
name: user-profile
description: "Marcel's role, employer, and dev-environment habits — Angular/Nx engineer at Accenture, maintains a cross-platform chezmoi dotfiles repo, treats Claude Code as a configured/curated tool"
metadata: 
  node_type: memory
  type: user
  originSessionId: 33e619b1-5d7c-4c95-bee5-9a19d3b8597a
---

Marcel Angelo Navarro is an Angular multi-frontend platform engineer, consulting through **Accenture** (work email `marcel.a.n.navarro@accenture.com`; personal git identity uses `marcelxangelo@gmail.com`). Core stack: Angular CLI, Nx (monorepo/micro-frontends, Module Federation added per-project rather than globally), pnpm via corepack, Azure CLI/DevOps, Playwright for testing.

He maintains `navarroangelo/manndotfiles` (cloned locally at `~/Dev/manndotfiles`), a chezmoi-managed dotfiles repo spanning macOS/Linux-WSL/native-Windows, with a personal/work machine-profile split (chezmoi prompts once, remembered thereafter). See [[project-manndotfiles]] for the compliance-hardening details.

He is also stepping into a **Frontend Lead** role (dual IC + Lead mandate) on an Accenture client engagement: the Zimmermann PWA Kit commerce migration (`~/Dev/zimmermann-pwa`, cloned 2026-07-09 — a Salesforce Commerce Cloud storefront for a luxury Australian fashion brand, React/Chakra despite his Angular background). He maintains a personal operating manual for this role, `~/Dev/Zimmermann_Frontend_Lead_Playbook.md`, distilled from a Manila AI-engineering training week — see [[project-zimmermann-pwa]] for the project-side discrepancies surfaced while grounding that playbook in the real repo.

He is a heavy Claude Code user who treats the tool itself as configured infrastructure: curated plugin list (official Anthropic `claude-plugins-official` marketplace only — third-party marketplaces were deliberately removed for compliance), a hand-built minimal-mono status line (24-bit truecolor, model/effort/dir/git-branch/context-bar/rate-limit bars via `claude/statusline-command.sh`), and iterates on his own Claude Code settings collaboratively with Claude itself (commits in manndotfiles are co-authored by "Claude Opus 4.8"). Default effort level in his seeded settings is `high`, TUI is `fullscreen`.

**How to apply:** When working in `~/Dev/manndotfiles` or on his Claude Code config, expect a security/compliance-conscious, minimalist, cross-platform-correctness mindset — prefer official/signed install sources over `curl | bash`, keep personal vs. work concerns separated, and don't casually add convenience permissions that widen code-egress (git push, gh api, deploy commands) without flagging it first. When working on the Zimmermann playbook or codebase, keep the personal-vs-project layering distinction sharp: `manndotfiles/claude/` is his global, cross-client Claude Code tool config (permissions, plugins, effort dial, statusline — no prose instructions file), while `zimmermann-pwa/.claude/` + `AGENTS.md` is the team's shared, project-scoped rules contract. Don't conflate the two.
