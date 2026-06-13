# Neovim Config

[한국어 문서 보기](./README.ko.md)

A clean, fast, IDE-like Neovim configuration focused on language tooling, external terminal execution, and low-friction editing.

This setup treats Neovim as a control center and keeps program execution in a real external terminal.

## Features

- LSP support for Bash, Python, Lua, PowerShell, C, and C++.
- **Automatic Python Virtual Environment Detection** (.venv, venv, env).
- External run system with `<leader>r`.
- Windows Terminal + PowerShell execution on Windows.
- Linux terminal execution through an available system terminal.
- **Lightweight Git Integration** with Gitsigns.
- **Enhanced Debugging UX** with Dap UI and auto-detection.
- **Project-wide Navigation** with Trouble and Telescope.
- Formatting with `conform.nvim`.
- Linting with `nvim-lint`.
- Session management with `auto-session`.
- Task history and optional structured workflows with `overseer.nvim`.
- Discoverable keymaps with `which-key.nvim`.
- PowerShell development support with `powershell.nvim`.

## Philosophy

- **External terminal first**: Program execution happens in a real terminal, not a partial Neovim emulation.
- **Lightweight & Fast**: No unnecessary bloat or "distro" feel.
- **Stable & Predictable**: Minimal abstractions for maximum maintainability.
- **IDE-like UX**: Modern features where they matter (DAP, Git, LSP).

## Keybindings

### General

| Keybinding | Action |
| --- | --- |
| `<leader>r` | Run current file in an external terminal |
| `<leader>f` | Format current file |
| `<leader>/` | Live grep |
| `<leader>?` | Buffer-local keymaps |
| `<C-p>` | Find files |
| `<C-n>` | Reveal file explorer |

### Git (`<leader>g`)

| Keybinding | Action |
| --- | --- |
| `]c` | Next hunk |
| `[c` | Previous hunk |
| `<leader>gs` | Stage hunk |
| `<leader>gr` | Reset hunk |
| `<leader>gp` | Preview hunk |
| `<leader>gb` | Blame line |

### Debugging (`<leader>d`)

| Keybinding | Action |
| --- | --- |
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue debug session |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>du` | Toggle DAP UI |
| `<leader>dx` | Terminate debug session |

### Tasks (`<leader>t`)

| Keybinding | Action |
| --- | --- |
| `<leader>tr` | Run Overseer task |
| `<leader>tb` | Build Overseer task |
| `<leader>tt` | Toggle Overseer task list |
| `<leader>ta` | Overseer task action |

### Trouble (`<leader>x`)

| Keybinding | Action |
| --- | --- |
| `<leader>xx` | Diagnostics (Trouble) |
| `<leader>xX` | Buffer Diagnostics (Trouble) |
| `<leader>xQ` | Quickfix List (Trouble) |
| `<leader>xL` | Location List (Trouble) |
| `<leader>cl` | LSP Symbols / References (Trouble) |

## Python Virtual Environments

The configuration automatically detects and uses Python virtual environments located in project root:
- `.venv`
- `venv`
- `env`

This works seamlessly for:
- LSP (`basedpyright`)
- DAP (`debugpy`)
- External runner (`<leader>r`)

## Overseer Workflow

Overseer is used for task management. All tasks are configured to run as background jobs with captured output.

- Pressing `Enter` in a task output window will close it.
- Pressing `q` will close the task list or detail window.
- No hanging processes are left behind after task completion.

## External Run System

`<leader>r` runs the current file in a new external terminal window.

Supported filetypes:

| Language | Command |
| --- | --- |
| Python | `python file.py` |
| Lua | `lua file.lua` or `luajit file.lua` |
| Bash | `bash file.sh` |
| PowerShell | `pwsh file.ps1` |
| C | `clang file.c -g -o file` then run |
| C++ | `clang++ file.cpp -g -o file` then run |

Execution rules:

- Runs from the file directory.
- Supports paths with spaces.
- Does not block Neovim.
- Keeps the terminal open after execution.

## Requirements

- Neovim v0.11+
- Git
- Node.js and npm
- Python
- PowerShell 7+ (`pwsh`)
- Windows Terminal (`wt.exe`) on Windows
- A system terminal on Linux, such as `x-terminal-emulator`, `gnome-terminal`, `konsole`, `alacritty`, `kitty`, `wezterm`, or `xterm`
- `clang` and `clang++`
- `bash` or `sh`

Mason installs the editor-side tooling:

- `lua-language-server`
- `basedpyright`
- `bash-language-server`
- `powershell-editor-services`
- `clangd`
- `clang-format`
- `debugpy`
- `codelldb`
- `black`
- `isort`
- `stylua`
- `shellcheck`
- `shfmt`

## Installation

### Windows

Clone the repository:

```powershell
git clone https://github.com/spidychoipro/neovim-config "$env:LOCALAPPDATA\nvim"
```

If a config already exists, back it up first:

```powershell
Rename-Item "$env:LOCALAPPDATA\nvim" "$env:LOCALAPPDATA\nvim.backup"
git clone https://github.com/spidychoipro/neovim-config "$env:LOCALAPPDATA\nvim"
```

### Linux

Clone the repository:

```bash
git clone https://github.com/spidychoipro/neovim-config ~/.config/nvim
```

If a config already exists, back it up first:

```bash
mv ~/.config/nvim ~/.config/nvim.backup
git clone https://github.com/spidychoipro/neovim-config ~/.config/nvim
```

### Symlink Alternative

Clone anywhere and symlink it into Neovim's config directory.

Windows PowerShell:

```powershell
New-Item -ItemType SymbolicLink -Path "$env:LOCALAPPDATA\nvim" -Target "C:\path\to\neovim-config"
```

Linux:

```bash
ln -s /path/to/neovim-config ~/.config/nvim
```

## Screenshots

![Clean startup dashboard](assets/startup.png)

![Python LSP diagnostics](assets/lsp-python.png)

![External run workflow](assets/external-run.png)

![Which-key leader popup](assets/which-key.png)

![Telescope file search](assets/telescope.png)
