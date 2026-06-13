# Troubleshooting

Use this page when something looks broken after a Neovim, plugin, or toolchain update.

## Health Checks

Run the broad health check:

```vim
:checkhealth
```

Run targeted checks:

```vim
:checkhealth vim.deprecated vim.lsp nvim-treesitter screenkey lazy
```

## Deprecated API Warnings

If `vim.deprecated` reports a warning, check whether the stack trace points to this config or to a plugin.

If it points to this config, update the config to the newer API. Current examples in this repo:

- use `vim.uv`, not `vim.loop`;
- use `vim.diagnostic.config()` for signs, not `sign_define()`;
- use `vim.fs.root()` for root detection;
- use `vim.lsp.config()` and `vim.lsp.enable()` for LSP setup.

If the warning comes from a plugin, prefer updating the plugin first.

## Large LSP Log

If `:checkhealth vim.lsp` reports a large log file, close all Neovim processes and clear the log.

Windows PowerShell:

```powershell
Clear-Content "$env:LOCALAPPDATA\nvim-data\lsp.log"
```

Linux:

```bash
truncate -s 0 ~/.local/state/nvim/lsp.log 2>/dev/null || truncate -s 0 ~/.local/share/nvim/lsp.log
```

## Tree-sitter

Update parsers:

```vim
:TSUpdate
```

Check parser health:

```vim
:checkhealth nvim-treesitter vim.treesitter
```

## Neo-tree Opens Slowly

If Neo-tree appears empty for a while or Neovim pauses when opening the file explorer, check whether the current directory or your Windows home directory is accidentally a very large Git worktree.

This config keeps Neo-tree git status enabled for normal projects, but it avoids the expensive ignored/untracked scan when the Git root is the user profile. The filesystem scan is also forced async with `async_directory_scan = "always"` so `<C-n>` does not block the editor.

Auto-session also skips the Windows home directory and removes stale Neo-tree nofile buffers before saving sessions. That prevents old sessions from restoring an empty `neo-tree filesystem [1]` buffer before Neo-tree has reloaded.

## Python Diagnostics Are Slow

This config prevents single files like `C:\Users\david\wow.py` from making `basedpyright` scan the whole user profile.

For real projects, add one of these files to mark the project root:

- `pyrightconfig.json`
- `basedpyrightconfig.json`
- `pyproject.toml`
- `requirements.txt`
- `setup.py`
- `setup.cfg`
- `tox.ini`

## PowerShell Files Do Not Quit Cleanly

The PowerShell plugin integration tracks hidden PowerShell Editor Services jobs and stops them before quitting. If `:wqa` still reports a running job:

1. Save your files.
2. Run `:qa!` only if you are sure nothing needs saving.
3. Restart Neovim.
4. Run `:checkhealth vim.lsp`.

## Lazy.nvim

Update plugins:

```vim
:Lazy update
```

Sync plugins after changing specs:

```vim
:Lazy sync
```

Commit `lazy-lock.json` after updates.
