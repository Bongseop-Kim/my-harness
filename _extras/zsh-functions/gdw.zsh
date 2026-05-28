# git diff shortstat watch — colorized live view via viddy
# Requires: viddy, git
gdw() {
  viddy -n 1 --no-title "git diff --shortstat | awk '{gsub(/[0-9]+ insertions?\(\+\)/, \"\033[32m&\033[0m\"); gsub(/[0-9]+ deletions?\(-\)/, \"\033[31m&\033[0m\"); print} END {if (NR==0) print \" 0 files changed\"}'"
}
