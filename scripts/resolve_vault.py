"""Shared vault-root resolver for claude-obsidian Python scripts.

Resolution chain (most-specific wins):

    $CLAUDE_OBSIDIAN_VAULT                 env var      — per-session override
      -> ~/.claude/claude-obsidian-vault   pointer file — the switchable "active vault"
      -> cwd, if it contains a wiki/ folder              — today's cwd behavior
      -> ``default``                                     — last-resort (the install location)

Usage from a sibling script::

    from pathlib import Path
    from resolve_vault import resolve_vault

    VAULT_ROOT = resolve_vault(Path(__file__).resolve().parent.parent)

The ``default`` is the caller's own ``scripts/..`` so zero-config installs keep
working exactly as before; the resolver only redirects when an env var or
pointer file is present.
"""

import os
from pathlib import Path
from typing import Optional

POINTER = Path.home() / ".claude" / "claude-obsidian-vault"
# Fallback when no caller default is supplied: this module lives in <vault>/scripts/.
_MODULE_DEFAULT = Path(__file__).resolve().parent.parent


def resolve_vault(default: Optional[Path] = None) -> Path:
    """Return the active vault root as an absolute :class:`Path`."""
    env = os.environ.get("CLAUDE_OBSIDIAN_VAULT")
    if env:
        return Path(env).expanduser().resolve()

    try:
        if POINTER.is_file():
            pointed = POINTER.read_text(encoding="utf-8").strip()
            if pointed:
                return Path(pointed).expanduser().resolve()
    except OSError:
        pass

    cwd = Path.cwd()
    if (cwd / "wiki").is_dir():
        return cwd.resolve()

    return (default or _MODULE_DEFAULT).resolve()
