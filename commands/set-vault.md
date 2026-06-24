---
description: Set (or show) the active claude-obsidian vault that every skill, script, and hook will use. Writes the switchable ~/.claude/claude-obsidian-vault pointer.
---

Set or show the **active vault** used by every claude-obsidian skill, script, and hook.

Usage:
- `/set-vault /path/to/vault` — switch the active vault
- `/set-vault` — show the currently active vault

This is the switchable pointer at the top of the resolution chain consumed by `scripts/resolve-vault.sh` and `scripts/resolve_vault.py`:

```
$CLAUDE_OBSIDIAN_VAULT              # per-session env override (wins over the pointer)
  → ~/.claude/claude-obsidian-vault # the pointer this command writes  ← you are here
  → a wiki/ folder in the cwd
  → the plugin install location
```

## What to do

Run the switch command, passing the user's path as a single quoted argument (omit the argument entirely if the user gave none, so it prints the current vault):

```bash
bash "${CLAUDE_PLUGIN_ROOT:-.}/bin/use-vault.sh" "<path the user gave, or nothing>"
```

`use-vault.sh` resolves the path to absolute, verifies the directory exists, and writes it to `~/.claude/claude-obsidian-vault`. Then:

- Report the resulting active vault back to the user (quote the script's output).
- If the target directory has **no `wiki/` folder yet**, tell the user it isn't provisioned and offer to scaffold it — either `/wiki` or `bash "${CLAUDE_PLUGIN_ROOT:-.}/bin/setup-vault.sh" "<path>"`.
- If the user has `$CLAUDE_OBSIDIAN_VAULT` set in their environment, remind them it overrides the pointer for the current session until unset.

Never hardcode a vault path anywhere — switching the pointer is the only supported way to change the active vault.
