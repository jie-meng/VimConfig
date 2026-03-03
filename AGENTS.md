# AGENTS.md

## Project Context

This repository stores personal Vim/Neovim configuration.

- `vim/`: legacy Vim setup and install scripts.
- `nvim/`: primary Neovim setup (Lua-based, managed with `lazy.nvim`).

## Important Paths

- `nvim/init.lua`: Neovim entry file.
- `nvim/lua/config/`: core config modules (options, keymaps, autocmds, lazy setup, etc.).
- `nvim/lua/plugins/`: plugin specs and plugin-specific config.

## Operational Scripts

- `nvim/install-mac.sh`: install/setup on macOS.
- `nvim/install-ubuntu.sh`: install/setup on Ubuntu/Debian.
- `nvim/sync-to-system.sh`: sync project config to `~/.config/nvim`.

## Sync Policy (Important)

`nvim/sync-to-system.sh` is intentionally **direct overwrite**:

- it removes existing `~/.config/nvim`;
- it copies this repo's `nvim/` directory to `~/.config/nvim`;
- it does **not** create backups.

Do not reintroduce backup/rollback logic unless explicitly requested.

## Editing Guidelines for Agents

- Keep changes minimal and focused.
- Preserve existing Lua style and plugin organization.
- Update docs (`README.md` / `nvim/README.md`) when behavior changes.
- Prefer not to add new tools/scripts unless requested.
