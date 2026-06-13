# Installation

This guide is written for both first-time Neovim users and people who already keep multiple editor configurations.

## Before You Start

Install these system tools first:

| Tool | Why it matters |
| --- | --- |
| Neovim `0.12+` | Required for the current LSP, diagnostic, and Tree-sitter APIs |
| Git | Used by lazy.nvim to install plugins |
| Node.js and npm | Required by several language servers |
| Python | Required by Python tooling and debug support |
| PowerShell 7 (`pwsh`) | Recommended on Windows |
| clang / clang++ | Used by C and C++ workflows |
| bash or sh | Used by shell script workflows |

## Windows

Back up any existing config:

```powershell
Rename-Item "$env:LOCALAPPDATA\nvim" "$env:LOCALAPPDATA\nvim.backup" -ErrorAction SilentlyContinue
```

Clone the repository:

```powershell
git clone https://github.com/spidychoipro/neovim-config "$env:LOCALAPPDATA\nvim"
```

Start Neovim:

```powershell
nvim
```

The first launch installs `lazy.nvim` and plugin dependencies. Open Mason with:

```vim
:Mason
```

## Linux

Back up any existing config:

```bash
mv ~/.config/nvim ~/.config/nvim.backup 2>/dev/null || true
```

Clone the repository:

```bash
git clone https://github.com/spidychoipro/neovim-config ~/.config/nvim
```

Start Neovim:

```bash
nvim
```

## Symlink Install

If you prefer to keep the repo somewhere else, clone it into a projects folder and symlink it.

Windows PowerShell:

```powershell
New-Item -ItemType SymbolicLink -Path "$env:LOCALAPPDATA\nvim" -Target "C:\path\to\neovim-config"
```

Linux:

```bash
ln -s /path/to/neovim-config ~/.config/nvim
```

## After Install

Run a health check:

```vim
:checkhealth
```

Install or update parsers:

```vim
:TSUpdate
```

Update plugins:

```vim
:Lazy update
```

## Expected Tooling

Mason manages editor-side packages, including:

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
