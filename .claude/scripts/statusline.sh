#!/usr/bin/env bash

# https://code.claude.com/docs/en/statusline#full-json-schema
input=$(cat)

IFS=$'\t' read -r MODEL EFFORT CTX_USED RL_5H RL_7D CWD SESSION_ID SESSION_NAME WORKTREE < <(
  echo "$input" | jq -r '[
    (.model.display_name // ""),
    (.effort.level // ""),
    ((.context_window.used_percentage // (100 - (.context_window.remaining_percentage // 100))) | ceil),
    (.rate_limits.five_hour.used_percentage // "" | if . == "" then . else ceil end),
    (.rate_limits.seven_day.used_percentage // "" | if . == "" then . else ceil end),
    (.cwd // ""),
    (.session_id // ""),
    (.session_name // ""),
    (.worktree.name // "")
  ] | map(tostring | if . == "" then "-" else . end) | @tsv'
)
for v in MODEL EFFORT RL_5H RL_7D CWD SESSION_ID SESSION_NAME WORKTREE; do
  [ "${!v}" = "-" ] && printf -v "$v" ''
done

RESET=$'\e[0m' DIM=$'\e[2m' RED=$'\e[31m' GREEN=$'\e[32m' YELLOW=$'\e[33m'
BLUE=$'\e[34m' MAGENTA=$'\e[35m' CYAN=$'\e[36m'
SEP="${DIM}│${RESET}"

used_color() {
  local pct=$1 warn=$2 crit=$3
  if [ "$pct" -ge "$crit" ]; then echo "$RED"; elif [ "$pct" -ge "$warn" ]; then echo "$YELLOW"; else echo "$GREEN"; fi
}
bar() {
  local pct=$1 width=$2 filled i out=""
  filled=$(((pct * width + 50) / 100))
  for ((i = 0; i < width; i++)); do
    if [ "$i" -lt "$filled" ]; then out+="▰"; else out+="▱"; fi
  done
  echo "$out"
}

# session_name には /rename や AI 生成のタイトルしか入らず、SendMessage の宛先に使う自動命名（例: foo-3f）は来ない。
# 宛先と一致させるため Claude Code の非公開の状態ファイルを引き、読めなければ session_name に退く
peer_name() {
  [ -n "$SESSION_ID" ] || return 0
  local f
  f=$(grep -lF "\"$SESSION_ID\"" "$HOME"/.claude/sessions/*.json 2>/dev/null | head -n1)
  [ -n "$f" ] && jq -r --arg id "$SESSION_ID" 'select(.sessionId == $id) | .name // empty' "$f" 2>/dev/null
}
NAME=$(peer_name)
NAME=${NAME:-$SESSION_NAME}

line1=()
dir=${CWD:-$PWD}
line1+=("${BLUE}${dir/#$HOME/\~}${RESET}")

if status=$(git -C "$dir" --no-optional-locks status --porcelain=v2 --branch 2>/dev/null); then
  branch=$(awk '/^# branch.head /{print $3}' <<<"$status")
  read -r ahead behind < <(awk '/^# branch.ab /{print substr($3,2), substr($4,2)}' <<<"$status")
  changes=$(grep -vc '^#' <<<"$status")
  git_part="${CYAN}"$'\ue0a0'" ${branch}${RESET}"
  if [ "$changes" -gt 0 ]; then git_part+=" ${YELLOW}±${changes}${RESET}"; fi
  [ "${ahead:-0}" -gt 0 ] && git_part+=" ${DIM}↑${ahead}${RESET}"
  [ "${behind:-0}" -gt 0 ] && git_part+=" ${DIM}↓${behind}${RESET}"
  line1+=("$git_part")
fi
[ -n "$WORKTREE" ] && line1+=("${DIM}wt:${RESET}${MAGENTA}${WORKTREE}${RESET}")
[ -n "$NAME" ] && line1+=("${DIM}⇄${RESET} ${MAGENTA}${NAME}${RESET}")

line2=()
[ -n "$MODEL" ] && line2+=("${MAGENTA}${MODEL}${RESET}${EFFORT:+ ${DIM}${EFFORT}${RESET}}")
# コンテキストはレート制限より手前で応答品質が落ち始めるので、閾値を低めに置く
c=$(used_color "$CTX_USED" 50 80)
line2+=("ctx ${c}$(bar "$CTX_USED" 12) ${CTX_USED}%${RESET}")
if [ -n "$RL_5H" ]; then
  c=$(used_color "$RL_5H" 70 90)
  line2+=("5h ${c}$(bar "$RL_5H" 5) ${RL_5H}%${RESET}")
fi
if [ -n "$RL_7D" ]; then
  c=$(used_color "$RL_7D" 70 90)
  line2+=("7d ${c}$(bar "$RL_7D" 5) ${RL_7D}%${RESET}")
fi

join() {
  local out="" p
  for p in "$@"; do out+="${out:+ $SEP }$p"; done
  printf '%s\n' "$out"
}
join "${line1[@]}"
join "${line2[@]}"
