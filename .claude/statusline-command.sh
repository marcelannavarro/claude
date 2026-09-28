#!/usr/bin/env bash
# ~/.claude/statusline-command.sh
# Minimal-mono status line for Claude Code.
# Unicode + 24-bit truecolor, dim dot separators, no icons. Renders in any font.
# Reads JSON from stdin; uses jq for field extraction.

input=$(cat)

# ── 24-bit truecolor palette (Catppuccin Mocha) ────────────
c() { printf '\033[38;2;%sm' "$1"; }
RESET=$'\033[0m'
BLUE=$(c '137;180;250')    # model
LAV=$(c '180;190;254')     # directory
GREEN=$(c '166;227;161')   # clean git / additions / low ctx
YELLOW=$(c '249;226;175')  # dirty git / mid ctx
RED=$(c '243;139;168')     # deletions / high ctx
PEACH=$(c '250;179;135')   # cost
TEXT=$(c '205;214;244')    # primary text
DIM=$(c '108;112;134')     # separators / meta

jqr() { printf '%s' "$input" | jq -r "$1" 2>/dev/null; }

# Render "<pct>% <coloured bar>" — args: percentage, block_count (default 8)
pbar() {
  local pct=$1 n=${2:-8} p f i bar bc
  p=$(awk "BEGIN{printf \"%.0f\", $pct}")
  f=$(awk "BEGIN{f=int($pct*$n/100+0.5); if(f>$n)f=$n; if(f<0)f=0; print f}")
  bar=""; for ((i=0;i<f;i++)); do bar="${bar}▓"; done; for ((i=f;i<n;i++)); do bar="${bar}░"; done
  if   [ "$p" -lt 50 ]; then bc=$GREEN; elif [ "$p" -lt 80 ]; then bc=$YELLOW; else bc=$RED; fi
  printf '%s%s%% %s%s%s' "$TEXT" "$p" "$bc" "$bar" "$RESET"
}
segs=()

# 1. Model (strip a leading "claude-", shorten "(1M context)")
model=$(jqr '.model.display_name // empty'); model=${model#claude-}
model=${model/"(1M context)"/"(1M)"}
[ -n "$model" ] && segs+=("${BLUE}${model}${RESET}")

# 1b. Effort level (colour escalates with intensity)
effort=$(jqr '.effort.level // empty')
if [ -n "$effort" ]; then
  case "$effort" in
    low) ec=$DIM ;; medium) ec=$BLUE ;; high) ec=$YELLOW ;;
    xhigh) ec=$PEACH ;; max) ec=$RED ;; *) ec=$TEXT ;;
  esac
  segs+=("${ec}${effort}${RESET}")
fi

# 2. Current directory (basename)
dir=$(jqr '.workspace.current_dir // .cwd // empty')
[ -n "$dir" ] && segs+=("${LAV}$(basename "$dir")${RESET}")

# 3. Git branch + dirty marker
if [ -n "$dir" ] && git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$dir" branch --show-current 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    if [ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]; then
      segs+=("${YELLOW}${branch}●${RESET}")   # ● = uncommitted changes
    else
      segs+=("${GREEN}${branch}${RESET}")
    fi
  fi
fi

# 4. Context window (bar) + usage rate limits (bars) — all via pbar()
pct=$(jqr '.context_window.used_percentage // empty')
[ -n "$pct" ] && segs+=("${DIM}ctx ${RESET}$(pbar "$pct" 8)")

u5=$(jqr '.rate_limits.five_hour.used_percentage // empty')
[ -n "$u5" ] && segs+=("${DIM}5h ${RESET}$(pbar "$u5" 5)")
u7=$(jqr '.rate_limits.seven_day.used_percentage // empty')
[ -n "$u7" ] && segs+=("${DIM}7d ${RESET}$(pbar "$u7" 5)")

# 6. Duration
dur=$(jqr '.cost.total_duration_ms // 0')
if [ "${dur%.*}" -gt 0 ] 2>/dev/null; then
  s=$(( ${dur%.*} / 1000 ))
  if   [ "$s" -ge 3600 ]; then d="$((s/3600))h$(((s%3600)/60))m"
  elif [ "$s" -ge 60 ];   then d="$((s/60))m"
  else                          d="${s}s"; fi
  segs+=("${DIM}${d}${RESET}")
fi

# 7. Lines added / removed
add=$(jqr '.cost.total_lines_added // 0'); del=$(jqr '.cost.total_lines_removed // 0')
if [ "${add%.*}" -gt 0 ] 2>/dev/null || [ "${del%.*}" -gt 0 ] 2>/dev/null; then
  segs+=("${GREEN}+${add}${RESET} ${RED}-${del}${RESET}")
fi

# 8. Output style (only when non-default)
style=$(jqr '.output_style.name // empty')
[ -n "$style" ] && [ "$style" != "default" ] && segs+=("${DIM}${style}${RESET}")

# 9. Version (dim)
ver=$(jqr '.version // empty')
[ -n "$ver" ] && segs+=("${DIM}v${ver}${RESET}")

# ── join with a dim dot separator ──────────────────────────
sep="${DIM} · ${RESET}"
out=""
for s in "${segs[@]}"; do [ -z "$out" ] && out="$s" || out="${out}${sep}${s}"; done
printf '%b\n' "$out"
