#!/usr/bin/env bash
# skill-router.sh — UserPromptSubmit hook
#
# 사용자 프롬프트의 키워드를 skill-rules.json 과 매칭해서
# 활성화 권장 스킬 reminder 를 stdout (plain text) 으로 주입.
#
# ⚠️ 안전망이지 방어선 아님. 매칭은 단순 키워드 substring.
# ⚠️ Codex 호환: stdout plain text 만 사용 (hookSpecificOutput JSON 금지).

set -uo pipefail
trap 'exit 0' ERR

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HOOK_DIR}/lib/common.sh"

RULES_FILE="${HOOK_DIR}/skill-rules.json"

read_hook_input

# 1. prompt 추출
PROMPT="$(safe_jq '.prompt')"
[[ -z "$PROMPT" ]] && exit 0

# 2. slash command 는 즉시 통과 (라우터의 중복 안내 방지)
case "$PROMPT" in
  /*) exit 0 ;;
esac

# 3. rules 파일 없거나 jq 없으면 silent skip
[[ ! -f "$RULES_FILE" ]] && exit 0
command -v jq >/dev/null 2>&1 || exit 0

# 4. 매칭된 (스킬, reminder) 수집
#    jq 로 각 룰을 패턴 OR 정규식으로 만들고, $PROMPT 와 매칭되면 reminder 출력
MATCHES="$(
  jq -r --arg p "$PROMPT" '
    .userPromptSubmit[]
    | . as $rule
    | ($rule.patterns | map(ascii_downcase) | join("|")) as $alt
    | if ($alt | length) > 0 and ($p | ascii_downcase | test($alt; "x")) then
        "[skill-router] " + $rule.skill + "\n" + $rule.reminder
      else
        empty
      end
  ' "$RULES_FILE" 2>/dev/null
)"

# 5. 매칭 결과를 plain text 로 stdout 출력 (Claude Code & Codex 모두 컨텍스트로 처리)
if [[ -n "$MATCHES" ]]; then
  printf '%s\n' "$MATCHES"
fi

exit 0
