#!/usr/bin/env bash
# claude-obsidian: switch or show the active vault.
#
# Usage:
#   bash bin/use-vault.sh /path/to/vault   # switch the active vault
#   bash bin/use-vault.sh                   # show the currently active vault
#
# The active vault is recorded in ~/.claude/claude-obsidian-vault, the pointer
# file consulted by scripts/resolve-vault.sh and scripts/resolve_vault.py.
# A per-session $CLAUDE_OBSIDIAN_VAULT env var still overrides the pointer.
set -euo pipefail

PTR="$HOME/.claude/claude-obsidian-vault"

if [ $# -eq 0 ]; then
  echo "Active vault: ${CLAUDE_OBSIDIAN_VAULT:-$(cat "$PTR" 2>/dev/null || echo '(unset)')}"
  if [ -n "${CLAUDE_OBSIDIAN_VAULT:-}" ]; then
    echo "  (from \$CLAUDE_OBSIDIAN_VAULT — overrides the pointer file)"
  fi
  exit 0
fi

if [ ! -d "$1" ]; then
  echo "ERR: not a directory: $1" >&2
  exit 1
fi
VAULT="$(cd "$1" && pwd)"   # resolve to absolute, verify it exists

mkdir -p "$(dirname "$PTR")"
echo "$VAULT" > "$PTR"
echo "✓ Active vault → $VAULT"

if [ ! -d "$VAULT/wiki" ]; then
  echo "  note: $VAULT has no wiki/ folder yet — run 'bash bin/setup-vault.sh $VAULT' to provision it." >&2
fi
