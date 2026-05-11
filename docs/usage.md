# Usage

This configuration aims to keep common workflows close to hand without hiding how they work.

## Daily Workflow

1. Open a project with `nvim`.
2. Use `<C-p>` to find files.
3. Use `<leader>/` to search project text.
4. Use `<leader>r` to run the current file in an external terminal.
5. Use `<leader>xx` when you want a diagnostics list.
6. Use `:checkhealth` after upgrades or toolchain changes.

## Personal Preferences

Use `lua/user.lua` for local preferences such as relative line numbers, screenkey auto-start, inline diagnostic auto-start, or extra Windows tool paths.

See [customization.md](./customization.md) for the supported options.

## External Runner

`<leader>r` runs the current file outside Neovim in a real terminal.

| Filetype | Behavior |
| --- | --- |
| Python | Runs with the detected virtual environment or system Python |
| Lua | Runs with `lua` or `luajit` |
| Bash / sh | Runs with `bash` |
| PowerShell | Runs with `pwsh` |
| C | Builds with `clang`, then runs |
| C++ | Builds with `clang++`, then runs |

The runner:

- runs from the file's directory;
- supports paths with spaces;
- keeps Neovim responsive;
- uses Windows Terminal on Windows when available.

## Diagnostics

Diagnostics use Neovim's modern `vim.diagnostic.config()` API.

| Feature | Behavior |
| --- | --- |
| Sign column | Shows `E`, `W`, `I`, and `H` |
| Inline messages | Rendered by `tiny-inline-diagnostic.nvim` |
| Virtual text | Disabled to avoid duplicate messages |
| Virtual lines | Disabled to avoid layout jumps |
| Trouble | Available with `<leader>xx` and related keymaps |

Inline diagnostics automatically turn back on when a file is opened. Manual controls remain available:

| Key | Action |
| --- | --- |
| `<leader>ll` | Toggle inline diagnostics |
| `<leader>ld` | Disable inline diagnostics until the next file |

## Screenkey

`screenkey.nvim` starts automatically and can also be controlled manually.

| Key | Action |
| --- | --- |
| `<leader>uk` | Toggle screenkey |
| `<leader>uK` | Redraw screenkey |
| `<leader>uo` | Disable screenkey until the next file |

## Python Projects

The config detects virtual environments named:

- `.venv`
- `venv`
- `env`

This applies to:

- `basedpyright`
- `debugpy`
- the external runner

Single Python files outside a project use a temporary root to prevent `basedpyright` from scanning the whole user profile.

## Sessions

`auto-session` saves and restores project sessions.

| Key | Action |
| --- | --- |
| `<leader>ss` | Search sessions |
| `<leader>sr` | Restore session |
| `<leader>sw` | Save session |
| `<leader>st` | Toggle session autosave |

## Tasks

`overseer.nvim` provides repeatable build/run tasks.

| Key | Action |
| --- | --- |
| `<leader>tr` | Run a task |
| `<leader>tb` | Build a task |
| `<leader>tt` | Toggle task list |
| `<leader>ta` | Task action |
