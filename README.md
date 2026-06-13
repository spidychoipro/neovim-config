# Neovim Config

A clean, fast, IDE-like Neovim configuration focused on language tooling, external terminal execution, and low-friction editing.

This setup treats Neovim as a control center and keeps program execution in a real external terminal.

## Features

- LSP support for Bash, Python, Lua, PowerShell, C, and C++.
- External run system with `<leader>r`.
- Windows Terminal + PowerShell execution on Windows.
- Linux terminal execution through an available system terminal.
- Formatting with `conform.nvim`.
- Linting with `nvim-lint`.
- Debugging with `nvim-dap`, `debugpy`, and `codelldb`.
- Session management with `auto-session`.
- Task history and optional structured workflows with `overseer.nvim`.
- Discoverable keymaps with `which-key.nvim`.
- PowerShell development support with `powershell.nvim`.

## Philosophy

- External terminal first.
- Minimal but powerful.
- Fast iteration over heavy abstraction.
- IDE-like workflow without bloat.

## Keybindings

| Keybinding | Action |
| --- | --- |
| `<leader>r` | Run current file in an external terminal |
| `<leader>f` | Format current file |
| `<leader>d` | Debug group |
| `<leader>dt` | Toggle breakpoint |
| `<leader>dc` | Continue debug session |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>du` | Step out |
| `<leader>l` | LSP group |
| `<leader>la` | Code action |
| `<leader>lr` | Rename symbol |
| `<leader>ld` | Line diagnostics |
| `<leader>t` | Tasks group |
| `<leader>tr` | Run Overseer task |
| `<leader>tb` | Build Overseer task |
| `<leader>tt` | Toggle Overseer task list |
| `<leader>ta` | Overseer task action |
| `<leader>s` | Session group |
| `<leader>ss` | Search sessions |
| `<leader>sr` | Restore session |
| `<leader>sw` | Save session |
| `<leader>st` | Toggle session autosave |
| `<leader>/` | Live grep |
| `<leader>?` | Buffer-local keymaps |
| `<C-p>` | Find files |
| `<C-n>` | Reveal file explorer |

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

Screenshots can be added here.
