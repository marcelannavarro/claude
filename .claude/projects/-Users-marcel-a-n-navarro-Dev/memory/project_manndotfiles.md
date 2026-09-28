---
name: project-manndotfiles
description: "manndotfiles is Marcel's macOS-only chezmoi dotfiles repo, audited file-by-file on 2026-07-09 post-overhaul — clean bill of health, two residual permission-seed footguns noted"
metadata: 
  node_type: memory
  type: project
  originSessionId: 43b6cb0b-e1f1-42dc-8ef4-9e7f125b67ad
---

`navarroangelo/manndotfiles` (cloned to `~/Dev/manndotfiles`) is a chezmoi dotfiles repo for an Angular/Nx engineer doing Accenture client work. On 2026-07-09 it went through a "macOS-only overhaul + implementation-readiness hardening" (dropped prior Windows/Linux support — deleted `install/setup.ps1`, `packages.winget.txt`, `packages.apt.sh`, `dot_zshrc.tmpl`/`dot_zprofile.tmpl`, and a `nitpick` Claude skill). I did a full exhaustive audit right after this overhaul — read every file in the repo (not sampled), grepped for exfil/eval/secret patterns, scanned the entire git history (all 12 commits) for leaked emails/tokens/keys, and verified server-side that the repo is private with 0 forks and only one ref (`main`, no tags) — so no fork could be carrying pre-rewrite history.

**Result: clean.** No secrets in history (only emails found: the personal Gmail, `noreply@anthropic.com` commit trailer, and obvious doc placeholders). No curl-pipe-to-root beyond the official Homebrew installer. No obfuscation/eval-of-remote-content/exfil URLs anywhere. The vendored `claude/skills/playwright-skill` (largest chunk of third-party code, ~1,900 lines) is confirmed to be the real `lackeyjb/playwright-skill` open-source Claude skill (MIT, verified via WebSearch against the public GitHub repo) — code matches upstream in structure/intent, nothing added.

Two residual items I flagged as non-blocking but worth the user's awareness (not fixed, just noted — his call whether to tighten):
- `claude/settings.seed.json` auto-allows `Bash(npm install:*)` and `Bash(npm run:*)` — the latter lets Claude run *any* named script in a package.json without prompting, which is a real (if common) trust delegation.
- Same file auto-allows `git reset:*`, `git rebase:*`, `git checkout:*` — can destroy local uncommitted work without a confirmation prompt (local footgun, not a compliance/egress issue — no `git push`/`gh api`/`vercel deploy` etc. are allow-listed, matching the intended work-profile compliance design).

**Why:** Marcel asked for a "deep, exhaustive, extensive, and authoritative audit" before ever running the bootstrap, specifically because the repo had just been "overhauled" and he wanted stale assumptions cleared rather than carried forward.

**How to apply:** Treat the prior "history was scrubbed once for a leaked secret" concern as resolved and verified, not just claimed — don't re-flag it as an open risk. If asked to help run/extend this repo, the two permission-seed items above are the only standing discussion points; everything else already passed a full line-by-line review. See [[user_profile]] for who Marcel is.

**Bootstrap status:** actually executed against Marcel's live Mac (`marcel.a.n.navarro@accenture.com` account) on 2026-07-09 — chezmoi initialized with `machine = "work"`, `email = "marcel.a.n.navarro@accenture.com"`, `chezmoi apply` + `install/setup.sh` both completed successfully (verified: all 7 Brewfile packages, fnm with Node 22/24, npm globals, all 19 Claude plugins, all 14 VS Code extensions, azure-devops CLI extension). This machine's prior `~/.zprofile` had NVM setup that the dotfiles repo replaced with fnm-only — original backed up to `~/.zprofile.pre-chezmoi.bak` before applying. Remaining manual steps the user still needs to do: `gh auth login`, `az login`, sign in to `claude`, restart shell. If asked about this machine's state later, it's already bootstrapped — don't re-run init from scratch without checking current state first.

**Post-bootstrap additions (2026-07-09):** `direnv` and `uv` installed via Homebrew (not in original Brewfile — added during zimmermann-pwa project-init sweep). `direnv` shell hook added to `dot_zshrc` (commit `88c9aef`, "shell: add direnv hook to zshrc"). `direnv allow` run for `~/Dev/zimmermann-pwa`.

**Two-clone gotcha:** `~/Dev/manndotfiles` and `~/.local/share/chezmoi` are two independent git clones of the same GitHub remote — chezmoi only reads the latter. Always commit/push from `~/.local/share/chezmoi` (or via `chezmoi cd`), then pull into `~/Dev/manndotfiles` to keep them in sync. Edits to `~/Dev/manndotfiles` alone will NOT be picked up by chezmoi.
