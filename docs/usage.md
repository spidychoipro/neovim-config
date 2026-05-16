# Usage

This configuration aims to keep common workflows close to hand without hiding how they work.

## Daily Workflow

1. Open a project with `nvim`.
2. Use `<C-p>` to find files.
3. Use `<leader>/` to search project text.
4. Use `<C-n>` to reveal the current file in Neo-tree.
5. Use `<leader>hh` to return to the dashboard.
6. Use `<leader>j` when you want to jump to visible text quickly.
7. Use `<leader>r` to run the current file in an external terminal.
8. Use `<leader>xx` when you want a diagnostics list.
9. Use `:checkhealth` after upgrades or toolchain changes.

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

## File Explorer

`<C-n>` opens Neo-tree and reveals the current file.

Neo-tree keeps git status and diagnostics enabled. If the Windows user profile itself is a Git worktree, Neo-tree skips the expensive home-directory git status and gitignored scans while keeping git integration active in normal project repositories.

## Fast Movement

`flash.nvim` adds one beginner-friendly jump command without replacing normal Vim motions.

| Key | Action |
| --- | --- |
| `<leader>j` | Start a Flash jump |

Examples:

- Press `<leader>j`, type `print`, then press the label shown beside the match to jump there.
- In Visual mode, press `<leader>j` to extend the selection to a visible match.
- In Operator-pending mode, use `d<leader>j` to delete up to a visible target.

## Yank And Paste

Yanking text now shows a small `Copied` notice near the bottom of the editor. It fades out automatically. If the notice fails, Neovim shows an error message instead of failing silently.

`yanky.nvim` keeps a simple yank history while preserving the familiar paste keys.

| Key | Action |
| --- | --- |
| `p` | Paste after the cursor or selection |
| `P` | Paste before the cursor or selection |
| `<leader>p` | Open yank history |
| `[y` | After a paste, replace it with the previous yank |
| `]y` | After a paste, replace it with the next yank |

Examples:

- Yank one line with `yy`, move somewhere else, then press `p` to paste it.
- Yank several different words or lines, press `<leader>p`, choose the older yank you want, and paste it from the history window.
- Paste with `p`, then press `[y` to swap that pasted text to the previous yank. Press `]y` to move forward again.

## Persistent Undo

Persistent undo is enabled with `vim.opt.undofile = true`, so undo history survives closing and reopening Neovim.

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

The Windows home directory is excluded from automatic sessions so Neovim does not treat the whole user profile as one large project. Project folders still save and restore normally.

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
