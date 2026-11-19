#!/bin/sh
# 저장소의 설정을 홈 디렉터리에 symlink로 연결한다. 여러 번 실행해도 안전하다.
set -eu
REPO=$(cd "$(dirname "$0")" && pwd)

link() { # link <원본> <대상>: 이미 연결돼 있으면 건너뛰고, 다른 파일이 있으면 백업 후 연결
  src=$1 dst=$2
  [ "$(readlink "$dst" 2>/dev/null)" = "$src" ] && return 0
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mv "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
    echo "백업: $dst"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "연결: $dst -> $src"
}

link "$REPO/zshrc" "$HOME/.zshrc"
for name in ghostty nvim yazi zsh-functions; do
  link "$REPO/extras/$name" "$HOME/.config/$name"
done
for tool in .claude .codex; do
  link "$REPO/extras/hooks" "$HOME/$tool/hooks"
  for skill in "$REPO"/skills/*/; do
    skill=${skill%/}
    link "$skill" "$HOME/$tool/skills/$(basename "$skill")"
  done
done
