#!/usr/bin/env bash
# common.sh — duego hook 공통 헬퍼
#
# ⚠️  안전망이지 방어선 아님.
#   - 셸 토큰 우회 (공백 변형, 변수 indirection, 인터프리터 base64) 가능
#   - Codex apply_patch는 PreToolUse/PostToolUse 발동 X — 파일 편집 차단 불가
#   - 진짜 방어선은 별도 트랙(pre-commit, CI)에 둠
#
# 사용: 다른 hook 스크립트에서 `source "$HOOK_LIB/common.sh"`

set -uo pipefail

# 디버그 모드 — DUEGO_HOOK_DEBUG=1 이면 /tmp/duego-hook.log 에 stderr 기록
if [[ "${DUEGO_HOOK_DEBUG:-}" == "1" ]]; then
  exec 2>>/tmp/duego-hook.log
  set -x
fi

# stdin 으로 받은 JSON 을 단 한 번 캡처해서 변수에 저장
# 호출 측에서 $HOOK_INPUT 사용
read_hook_input() {
  HOOK_INPUT="$(cat 2>/dev/null || true)"
  export HOOK_INPUT
}

# jq 실패해도 빈 문자열 반환 — set -e 환경에서도 안전
safe_jq() {
  local query="$1"
  local input="${2:-${HOOK_INPUT:-}}"
  if [[ -z "$input" ]]; then
    printf ''
    return 0
  fi
  printf '%s' "$input" | jq -r "$query // empty" 2>/dev/null || printf ''
}

# 경로에서 duego 프로젝트 식별
# stdout: frontend | mobile | backend | other
detect_project() {
  local path="${1:-}"
  case "$path" in
    */duego-saas-frontend/*)    printf 'frontend' ;;
    */duego-saas-mobile/*)      printf 'mobile' ;;
    */duego-saas-backend-core/*) printf 'backend' ;;
    *)                           printf 'other' ;;
  esac
}

# 디바운스 — 같은 키가 N초 내 두 번째 호출이면 1 반환 (skip 의미)
# 사용: if debounce "format-$file" 5; then ...실행...; fi
debounce() {
  local key="$1"
  local within_sec="${2:-5}"
  local cache_dir="${HOME}/.cache/duego-hooks"
  local marker
  marker="${cache_dir}/$(printf '%s' "$key" | shasum -a 1 | cut -d' ' -f1)"
  mkdir -p "$cache_dir" 2>/dev/null || true

  if [[ -f "$marker" ]]; then
    local last now diff
    last="$(stat -f %m "$marker" 2>/dev/null || stat -c %Y "$marker" 2>/dev/null || echo 0)"
    now="$(date +%s)"
    diff=$(( now - last ))
    if (( diff < within_sec )); then
      return 1
    fi
  fi
  : > "$marker"
  return 0
}
