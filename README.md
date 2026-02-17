OpenCode Global Config

This repo is the single source of truth for your full OpenCode config.

What is tracked:

- Anything portable under `~/.config/opencode` can live here.
- Common examples: `commands/`, `agents/`, `subagents/`, `context/`, `opencode.json`, `opencode-notifier.json`.
- If you add new OpenCode config folders later, they are automatically included because the whole config directory is symlinked.
- `manage.sh` manages the symlink workflow.

Usage:

1. Install full config on current machine

```bash
./manage.sh install
```

This creates a symlink:

- `~/.config/opencode -> <repo>`

2. Check status

```bash
./manage.sh status
```

3. Unlink and restore a local config directory

```bash
./manage.sh unlink
```

4. Add more config folders

- Create them in this repo (for example `agents/`, `subagents/`, `context/`).
- Because `~/.config/opencode` points to this repo, OpenCode sees them automatically.

Notes:

- If an existing `~/.config/opencode` directory exists, install backs it up first.
- Sensitive/runtime files are ignored via `.gitignore` (for example auth tokens and logs).
- Restart OpenCode after config changes so the command registry reloads.
