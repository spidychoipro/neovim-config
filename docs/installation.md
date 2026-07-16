# Installation

This guide is written for both first-time Neovim users and people who already keep multiple editor configurations.

## Before You Start

Install these system tools first:

| Tool | Why it matters | Install |
| --- | --- | --- |
| Neovim `0.12+` | Required for the current LSP, diagnostic, and Tree-sitter APIs | `winget install Neovim.Neovim` |
| Git | Used by lazy.nvim to install plugins | `winget install Git.Git` |
| PowerShell 7 (`pwsh`) | Recommended on Windows | `winget install Microsoft.PowerShell` |
| Windows Terminal (`wt.exe`) | External runner terminal | `winget install Microsoft.WindowsTerminal` |
| ripgrep | Telescope `live_grep` | `winget install BurntSushi.ripgrep.MSVC` |
| LLVM / `clangd` | Used by C and C++ workflows | `winget install LLVM.LLVM` |
| Node.js and npm | Required by several language servers | [nodejs.org](https://nodejs.org/) |
| Python | Required by Python tooling and debug support | [python.org](https://www.python.org/) |

One-shot install (run PowerShell as admin):

```powershell
winget install Git.Git Microsoft.PowerShell Microsoft.WindowsTerminal ^
  BurntSushi.ripgrep.MSVC LLVM.LLVM
```

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

## WSL (Bash or Zsh)

Follow the Linux backup and clone steps above, but install this shell wrapper before starting Neovim:

```bash
if [ -n "${ZSH_VERSION:-}" ]; then
  rc_file="${ZDOTDIR:-$HOME}/.zshrc"
else
  rc_file="$HOME/.bashrc"
fi

if ! grep -Fq '# Neovim WSL DA1 startup filter' "$rc_file" 2>/dev/null; then
  cat >> "$rc_file" <<'EOF'

# Neovim WSL DA1 startup filter
nvim() {
  command nvim \
    --cmd 'lua dofile(vim.fn.stdpath("config") .. "/lua/utils/wsl-terminal.lua")' \
    "$@"
}
EOF
fi

exec "$SHELL" -l
```

The wrapper loads `lua/utils/wsl-terminal.lua` with `--cmd`, before `init.lua` can receive a fragmented Windows Terminal DA1 response as Normal-mode input. `vim.fn.stdpath("config")` keeps the command valid for both the normal `~/.config/nvim` install and a shared config selected through XDG environment variables.

Run `nvim` after the new shell prompt appears. Do not install this wrapper on native Windows or Linux; the regular platform instructions remain unchanged.

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
