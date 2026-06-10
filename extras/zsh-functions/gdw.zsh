# git diff shortstat watch — colorized live view via viddy
# Requires: viddy, git
gdw() {
  viddy -n 1 --no-title "printf '\033[36m%s\033[0m\n' \"\$(git branch --show-current)\"; git diff HEAD --shortstat | awk '{gsub(/[0-9]+ insertions?\(\+\)/, \"\033[32m&\033[0m\"); gsub(/[0-9]+ deletions?\(-\)/, \"\033[31m&\033[0m\"); print} END {if (NR==0) print \" 0 tracked files changed\"}'; git status --porcelain=v1 --untracked-files=all | awk 'BEGIN {count=0} /^\?\?/ {count++} END {if (count > 0) printf \" %d untracked files\n\", count}'"
}
