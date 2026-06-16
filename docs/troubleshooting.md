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

### Windows: Parser compilation fails with "Error: program not found" (cl.exe)

If you see multiple `[nvim-treesitter/install/<lang>] error: Error: Failed to compile parser` messages on startup,
the `ensure_missing_parsers()` function is trying to build parsers that are not bundled with Neovim, but no C compiler
(`cl.exe`, `gcc`, or `cc`) was found on your system.

**Root cause:** Neovim 0.12 ships bundled parsers (c, lua, markdown, markdown_inline, query, vim, vimdoc) at
`lib/nvim/parser/`, but the nvim-treesitter plugin's `get_installed()` only checks the user data directory and
misses them. This made the config attempt to re-install already-bundled parsers, and also attempt to compile
non-bundled parsers (bash, cpp, json, powershell, python) without a compiler.

**Fix applied in this config:** `lua/plugins/treesitter.lua` now scans **both** the user parser directory and the
Neovim bundled parser directory for `.dll` files, and checks for a C compiler before attempting any compile-based
install. Missing parsers are reported as a warning instead of crashing.

**To install missing parsers** (bash, cpp, json, powershell, python):

1. Install a C compiler:
   - **MSVC (recommended on Windows):** Install [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022)
     with the "Desktop development with C++" workload, or install the full Visual Studio.
   - **MinGW-w64 / GCC:** Install MSYS2 or a MinGW-w64 toolchain.

2. After installing a compiler, restart Neovim and run:
   ```vim
   :TSInstall bash cpp json powershell python
   ```

Alternatively, set the environment variable to skip auto-install entirely:

```powershell
$env:NVIM_SKIP_TS_AUTO_INSTALL=1
```

## Neo-tree Opens Slowly

If Neo-tree appears empty for a while or Neovim pauses when opening the file explorer, check whether the current directory or your Windows home directory is accidentally a very large Git worktree.

This config keeps Neo-tree git status enabled for normal projects, but it avoids the expensive status and gitignored scans when the Git root is the user profile. Neo-tree keeps its default `async_directory_scan = "auto"` behavior so command-based opens can render the shallow file list immediately.

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
