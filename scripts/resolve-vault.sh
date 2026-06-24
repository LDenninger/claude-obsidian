#!/usr/bin/env bash
# claude-obsidian: shared vault-root resolver (sourced, not executed).
#
# Sourcing this file sets and exports VAULT (and VAULT_ROOT, an alias) using the
# resolution chain below — most-specific wins:
#
#   $CLAUDE_OBSIDIAN_VAULT              env var      — per-session override
#     -> ~/.claude/claude-obsidian-vault  pointer file — the switchable "active vault"
#     -> $RESOLVE_VAULT_ARG / cwd-with-wiki/           — explicit arg or today's cwd behavior
#     -> $(dirname caller)/..                          — last-resort default (the install location)
#
# Callers that legitimately take a vault path as their first argument set
#   RESOLVE_VAULT_ARG="${1:-}"
# *before* sourcing this file. Scripts whose $1 is a flag/subcommand must NOT
# set it, so the arg tier stays empty.
#
# Usage:
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   source "$SCRIPT_DIR/../scripts/resolve-vault.sh"   # from bin/
#   source "$SCRIPT_DIR/resolve-vault.sh"              # from scripts/

__rv_pointer="${HOME}/.claude/claude-obsidian-vault"
__rv_arg="${RESOLVE_VAULT_ARG:-}"
# Default: one level up from the script that sourced us (its parent is the vault root).
__rv_caller="${BASH_SOURCE[1]:-$0}"
__rv_default="$(cd "$(dirname "$__rv_caller")/.." 2>/dev/null && pwd)"

if [ -n "${CLAUDE_OBSIDIAN_VAULT:-}" ]; then
  VAULT="$CLAUDE_OBSIDIAN_VAULT"
elif [ -s "$__rv_pointer" ]; then
  VAULT="$(sed -e 's/[[:space:]]*$//' "$__rv_pointer" | head -n1)"
elif [ -n "$__rv_arg" ]; then
  VAULT="$__rv_arg"
elif [ -d "${PWD}/wiki" ]; then
  VAULT="$PWD"
else
  VAULT="$__rv_default"
fi

# Normalize to an absolute path when the directory already exists (a vault being
# created for the first time may not exist yet — leave those untouched).
if [ -d "$VAULT" ]; then
  VAULT="$(cd "$VAULT" && pwd)"
fi

VAULT_ROOT="$VAULT"
export VAULT VAULT_ROOT
unset __rv_pointer __rv_arg __rv_caller __rv_default
