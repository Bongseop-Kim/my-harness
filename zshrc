
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$HOME/miniconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Python 별칭 설정
alias python='python3'
alias pip='pip3'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"


# yazi: change shell cwd to the directory exited from yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# fzf: use ripgrep for fast hidden-file aware file discovery
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='rg --files --hidden --follow --glob "!.git/*" --glob "!node_modules/*" --glob "!dist/*" --glob "!build/*" -0 | xargs -0 -n1 dirname | sort -u'
if [[ -o interactive && -t 0 ]]; then
	eval "$(fzf --zsh)"
fi

# zoxide: smarter cd
eval "$(zoxide init zsh)"

# Custom zsh functions synced from my-harness (~/.config/zsh-functions/)
if [ -d "$HOME/.config/zsh-functions" ]; then
  for f in "$HOME/.config/zsh-functions"/*.zsh(N); do source "$f"; done
fi

# AI commit message via Codex Spark (ChatGPT Pro)
gc() {
  git add .
  local diff
  diff=$(git diff --staged)
  if [[ -z "$diff" ]]; then
    echo "No changes to commit."
    return 1
  fi

  # Stat은 항상 포함 (파일별 변경량 요약 — 모델 판단용)
  local stat
  stat=$(git diff --staged --stat)

  local diff_lines
  diff_lines=$(printf '%s\n' "$diff" | wc -l | tr -d ' ')
  local MAX_LINES=5000

  local rules='형식: [모듈] 동사형 제목 (50자, 마침표 없음). 필요하면 빈 줄 후 본문 (72자 wrap).
내용: 제목=무엇, 본문=왜. 어떻게는 적지 말 것.
판단: stat에 lockfile(package-lock.json, yarn.lock, pnpm-lock.yaml, Podfile.lock 등)이나
생성물(dist/, build/, *.snap, *.generated.*)이 의도와 무관해 보이면
본문 첫 줄에 그 사실을 짧게 명시.
출력: 메시지 텍스트만. 코드블록·백틱·설명·진행 상황 금지. 마지막 출력이 메시지여야 함.'

  local msg prompt diff_file
  if (( diff_lines <= MAX_LINES )); then
    # Small diff — single-call mode (prompt에 직접 포함)
    prompt='다음 git staged 변경을 보고 한국어 커밋 메시지만 출력하세요.

'"$rules"'

## Stat
'"$stat"'

## Staged diff
'"$diff"

    echo "Generating with gpt-5.3-codex-spark (single-call, $diff_lines lines)..."
    if ! msg=$(codex exec -m gpt-5.3-codex-spark "$prompt"); then
      echo "Codex failed (exit $?)."
      return 1
    fi
  else
    # Large diff — agent mode (codex가 임시 파일을 부분 read)
    diff_file=$(mktemp -t gc-diff.XXXXXX) || { echo "mktemp failed."; return 1; }
    printf '%s\n' "$diff" > "$diff_file"

    prompt='한국어 커밋 메시지를 생성하세요. Diff가 '"$diff_lines"'줄로 커서 prompt에 직접 포함하지 못했습니다.

진행 순서:
1. 아래 stat을 보고 변경 범위 파악
2. 필요하면 다음 파일을 부분 read해서 의미 있는 hunk 확인 (전체를 다 읽지 말 것):
   '"$diff_file"'
3. 한 번에 충분한 정보가 모이면 메시지 출력하고 종료

'"$rules"'

## Stat
'"$stat"

    echo "Generating with gpt-5.3-codex-spark (agent, $diff_lines lines → $diff_file)..."
    if ! msg=$(codex exec -m gpt-5.3-codex-spark -s read-only "$prompt"); then
      rm -f "$diff_file"
      echo "Codex failed (exit $?)."
      return 1
    fi
    rm -f "$diff_file"
  fi

  # Sanitize — 코드블록 fence·인라인 백틱 제거
  msg=$(printf '%s\n' "$msg" | sed -E '/^[[:space:]]*```/d' | sed 's/`//g')

  # 앞뒤 빈 줄 trim
  msg=$(printf '%s\n' "$msg" | awk '
    { line[NR] = $0 }
    /[^[:space:]]/ { if (!s) s = NR; e = NR }
    END { for (i = s; i <= e; i++) print line[i] }
  ')

  if [[ -z "$msg" ]]; then
    echo "Empty response from codex (after sanitize)."
    return 1
  fi

  echo ""
  echo "--- Suggested commit message ---"
  echo "$msg"
  echo "--------------------------------"
  echo ""

  read "REPLY?Commit with this message? (y/N) "
  echo ""
  if [[ "$REPLY" == "y" || "$REPLY" == "Y" ]]; then
    # -F - (stdin)로 멀티라인 본문 보존
    printf '%s\n' "$msg" | git commit -F -
  else
    echo "Cancelled."
  fi
}



# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"

# git merge/pull 시 커밋 메시지 편집기 열지 않음
export GIT_MERGE_AUTOEDIT=no

# 이 PC에만 필요한 설정·비밀값 (저장소에 넣지 않음)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
