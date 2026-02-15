OpenCode Workflow Commands

This folder is the single source of truth for your global OpenCode workflow commands.

Contents:

- `commands/*.md`: slash command templates
- `manage.sh`: install/sync utility

Usage:

1. Install commands on current machine

```bash
./manage.sh install
```

This creates a symlink:

- `~/.config/opencode/commands -> <repo>/commands`

2. Check status

```bash
./manage.sh status
```

3. Pull external edits back into repo

```bash
./manage.sh pull
```

Notes:

- If an existing `~/.config/opencode/commands` directory exists, install will back it up first.
- Restart OpenCode after command changes so the command registry reloads.
