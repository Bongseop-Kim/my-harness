#!/usr/bin/env bash
# pre-bash-guard.sh — PreToolUse: Bash hook
#
# Bash 명령에서 시크릿 파일 접근 + 위험 명령 패턴을 매칭하면 차단.
# 차단 방식: stderr 메시지 + exit 2 (Claude Code/Codex 모두 호환).
#
# ⚠️ 안전망이지 방어선 아님:
#   - 셸 토큰 우회 (공백 변형, `cd /; rm -rf .`, 변수 indirection, base64 디코드) 가능
#   - Codex apply_patch 경로는 PreToolUse 미발동 — 파일 직접 쓰기는 못 막음
#   - 진짜 방어선은 pre-commit hook + CI

set -uo pipefail
# trap 으로 ERR 막지 않음 — 이 스크립트는 exit 2 차단이 핵심 책임

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${HOOK_DIR}/lib/common.sh"

PATTERNS_FILE="${HOOK_DIR}/danger-patterns.txt"

read_hook_input

# 1. command 추출
COMMAND="$(safe_jq '.tool_input.command')"
[[ -z "$COMMAND" ]] && exit 0

# 2. 패턴 파일 없으면 silent skip
[[ ! -f "$PATTERNS_FILE" ]] && exit 0

# 3. 두 단계 매칭:
#    Pass 1 — [ALLOW] 패턴 우선 검사. 매칭되면 즉시 통과 (화이트리스트)
#    Pass 2 — [SECRET]/[DANGER] 패턴 검사. 매칭되면 exit 2

# Pass 1: ALLOW
while IFS= read -r line; do
  case "$line" in
    ''|\#*) continue ;;
    '[ALLOW] '*)
      pattern="${line#'[ALLOW] '}"
      if printf '%s' "$COMMAND" | grep -E -q -- "$pattern" 2>/dev/null; then
        # 안전 경로 매칭 — 차단하지 않고 통과
        exit 0
      fi
      ;;
  esac
done < "$PATTERNS_FILE"

# Pass 2: SECRET / DANGER
while IFS= read -r line; do
  case "$line" in
    ''|\#*) continue ;;
  esac

  category=""
  pattern=""
  case "$line" in
    '[SECRET] '*)
      category="시크릿 파일 접근"
      pattern="${line#'[SECRET] '}"
      ;;
    '[DANGER] '*)
      category="위험 명령"
      pattern="${line#'[DANGER] '}"
      ;;
    *)
      continue
      ;;
  esac

  if printf '%s' "$COMMAND" | grep -E -q -- "$pattern" 2>/dev/null; then
    {
      printf '🚫 [pre-bash-guard] %s 패턴 차단\n' "$category"
      printf '   명령: %s\n' "$COMMAND"
      printf '   매칭: %s\n' "$pattern"
      printf '   (안전망 — 의도된 명령이면 패턴 수정: %s)\n' "$PATTERNS_FILE"
    } >&2
    exit 2
  fi
done < "$PATTERNS_FILE"

exit 0
