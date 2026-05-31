#!/usr/bin/env bash
# post-bash-commit-hint.sh — PostToolUse: Bash hook
#
# git commit 성공 후 최근 커밋에 React 파일이 있으면
# react-doctor 회귀 점검 안내를 stdout (plain text) 으로 주입.
#
# ⚠️ 가벼운 reminder 역할. 핵심 회귀 점검은 CI 가 담당.
# ⚠️ 안전망이지 방어선 아님.

set -uo pipefail
trap 'exit 0' ERR

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HOOK_DIR}/lib/common.sh"

read_hook_input

# 1. command + success 추출
COMMAND="$(safe_jq '.tool_input.command')"
SUCCESS="$(safe_jq '.tool_response.success')"

[[ -z "$COMMAND" ]] && exit 0

# 2. git commit 명령인지 확인 (간단 매칭 — git revert/cherry-pick 등 제외)
if ! printf '%s' "$COMMAND" | grep -E -q '(^|[[:space:]])git[[:space:]]+commit([[:space:]]|$)'; then
  exit 0
fi

# 3. 성공 여부 — tool_response.success 가 false 면 skip
#    (필드가 없으면 통과 — Codex 는 다른 키 형태일 수 있음)
case "$SUCCESS" in
  false|0) exit 0 ;;
esac

# 4. 최근 커밋의 변경 파일에서 React 파일 검출
#    cwd 가 git repo 이고 HEAD 가 있어야 함
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  exit 0
fi

CHANGED="$(git show --name-only --pretty=format: HEAD 2>/dev/null | sed '/^$/d' || true)"
[[ -z "$CHANGED" ]] && exit 0

if printf '%s\n' "$CHANGED" | grep -E -q '\.(tsx|jsx|ts|js)$'; then
  cat <<'EOF'
[post-commit] 최근 커밋에 React 코드 변경 있음.
가벼운 회귀 점검을 원하면: npx react-doctor@latest --diff
EOF
fi

exit 0
