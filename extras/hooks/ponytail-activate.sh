#!/usr/bin/env bash
# ponytail-activate.sh — SessionStart: inject the active ponytail level.
# State: ~/.config/skillshare/.ponytail-active — shared by claude + codex (lite|full|ultra; absent/off = disabled).
# The ponytail SKILL.md is the single source of truth; this only names the level
# and emits the body. Synced by skillshare (extras: hooks, copy mode).
set -uo pipefail

cfg="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
state="${XDG_CONFIG_HOME:-$HOME/.config}/skillshare/.ponytail-active"  # shared by claude + codex
level="$(cat "$state" 2>/dev/null || echo full)"
[ "$level" = "off" ] && exit 0

skill="$cfg/skills/ponytail/SKILL.md"
[ -f "$skill" ] || skill="$HOME/.codex/skills/ponytail/SKILL.md"

echo "PONYTAIL MODE ACTIVE — level: $level"
# ponytail: no per-level table filtering — name the level, emit the full body.
[ -f "$skill" ] && awk 'NR==1&&/^---/{fm=1;next} fm&&/^---/{fm=0;next} !fm' "$skill"
exit 0
