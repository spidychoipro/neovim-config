# Neovim Config

[![Neovim](https://img.shields.io/badge/Neovim-0.12.2-57A143?logo=neovim&logoColor=white)](https://neovim.io/)
[![Plugin manager](https://img.shields.io/badge/plugin%20manager-lazy.nvim-2f81f7)](https://github.com/folke/lazy.nvim)
[![Healthcheck](https://img.shields.io/badge/healthcheck-passing-brightgreen)](./docs/troubleshooting.md#health-checks)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-blue)](#requirements)
[![License](https://img.shields.io/badge/license-not%20specified-lightgrey)](#license)

[한국어 문서](./README.ko.md) · [Install](./docs/installation.md) · [Usage](./docs/usage.md) · [Customization](./docs/customization.md) · [Keymaps](./docs/keymaps.md) · [Architecture](./docs/architecture.md) · [Troubleshooting](./docs/troubleshooting.md)

A fast, IDE-like Neovim configuration focused on language tooling, inline diagnostics, external terminal execution, and a predictable Windows-friendly workflow.

This setup treats Neovim as the editing control center while keeping program execution in a real terminal. It is designed to feel approachable for new users and still stay explicit enough for experienced Neovim users to modify safely.

## Highlights

| Area | What you get |
| --- | --- |
| Language tooling | LSP for Python, Lua, Bash, PowerShell, C, and C++ |
| Diagnostics | E/W/I/H signs plus modern inline diagnostics with `tiny-inline-diagnostic.nvim` |
| Runtime workflow | `<leader>r` runs the current file in an external terminal |
| Windows support | PowerShell 7, Windows Terminal, Mason tool paths, and `.ps1` job cleanup |
| Project navigation | Telescope, Neo-tree, Trouble, Gitsigns, which-key, and `flash.nvim` |
| Editing help | Yank notifications and beginner-friendly yank history with `yanky.nvim` |
| Debugging and tasks | `nvim-dap`, `dap-ui`, `overseer.nvim`, and task history |
| Sessions | Automatic save and restore with `auto-session` |
| Modern APIs | Neovim 0.12-ready Tree-sitter, LSP, diagnostics, and `vim.uv` usage |
| Local customization | Optional `lua/user.lua` overrides that stay out of git |

## Preview

![Clean startup dashboard](assets/startup.png)

![Python LSP diagnostics](assets/lsp-python.png)

![External run workflow](assets/external-run.png)

![Which-key leader popup](assets/which-key.png)

![Telescope file search](assets/telescope.png)

## Requirements

| Tool | Purpose | Install |
| --- | --- | --- |
| Neovim | Editor | `winget install Neovim.Neovim` |
| Git | Plugin installs, bash/grep toolchain | `winget install Git.Git` |
| PowerShell 7 | External runner, plugin support | `winget install Microsoft.PowerShell` |
| Windows Terminal | External runner terminal | `winget install Microsoft.WindowsTerminal` |
| ripgrep | Telescope `live_grep` | `winget install BurntSushi.ripgrep.MSVC` |
| `fd` | Faster Telescope `find_files` | `winget install sharkdp.fd` |
| LLVM / `clangd` | C/C++ LSP, compilation, formatting | `winget install LLVM.LLVM` |
| `make` | Tree-sitter parser compilation | `winget install ezwinports.make` |
| Zig | Zig LSP and build support | `winget install zig.zig` |
| 7-Zip | File archiving support | `winget install 7zip.7zip` |
| Node.js / npm | LSP server runtime | [nodejs.org](https://nodejs.org/) |
| Python | Python LSP, formatters, debugger | [python.org](https://www.python.org/) |

One-shot install (run PowerShell as admin):

```powershell
winget install Git.Git Microsoft.PowerShell Microsoft.WindowsTerminal ^
  BurntSushi.ripgrep.MSVC sharkdp.fd ezwinports.make LLVM.LLVM ^
  7zip.7zip zig.zig
```

Node.js and Python are best installed from the official websites linked above.

Mason installs editor-side tools such as `lua-language-server`, `basedpyright`, `bash-language-server`, `powershell-editor-services`, `clangd`, `clang-format`, `debugpy`, `codelldb`, `black`, `isort`, `stylua`, `shellcheck`, and `shfmt`.

## Quick Start

### Windows

```powershell
Rename-Item "$env:LOCALAPPDATA\nvim" "$env:LOCALAPPDATA\nvim.backup" -ErrorAction SilentlyContinue
git clone https://github.com/spidychoipro/neovim-config "$env:LOCALAPPDATA\nvim"
nvim
```

### Linux

```bash
mv ~/.config/nvim ~/.config/nvim.backup 2>/dev/null || true
git clone https://github.com/spidychoipro/neovim-config ~/.config/nvim
nvim
```

### WSL (Bash or Zsh)

WSL needs the terminal-response filter to load before `init.lua`. Clone the config, then install the startup wrapper in the active shell profile:

```bash
mv ~/.config/nvim ~/.config/nvim.backup 2>/dev/null || true
git clone https://github.com/spidychoipro/neovim-config ~/.config/nvim

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

Run `nvim` after the new shell prompt appears. Native Windows and Linux do not need this wrapper.

Lazy.nvim will bootstrap itself on first launch. Mason-managed tools are installed from inside Neovim.

See the full guide: [docs/installation.md](./docs/installation.md).

## Everyday Commands

| Key | Action |
| --- | --- |
| `<leader>r` | Run current file in an external terminal |
| `<leader>f` | Format current file |
| `<C-p>` | Find files |
| `<leader>/` | Search project text |
| `<C-n>` | Reveal file explorer |
| `<leader>hh` | Return to the dashboard |
| `<leader>j` | Jump quickly with Flash |
| `<leader>p` | Open yank history |
| `<leader>xx` | Open Trouble diagnostics |
| `<leader>ll` | Toggle inline diagnostics |
| `<leader>ld` | Disable inline diagnostics until the next file |
| `<leader>uk` | Toggle screenkey |
| `<leader>uo` | Disable screenkey until the next file |

See the complete list: [docs/keymaps.md](./docs/keymaps.md).

## Documentation

| Document | Purpose |
| --- | --- |
| [Installation](./docs/installation.md) | Install, backup, and platform setup |
| [Usage](./docs/usage.md) | Daily workflows, diagnostics, external runner, sessions |
| [Customization](./docs/customization.md) | Local preferences without editing shared config files |
| [Keymaps](./docs/keymaps.md) | Complete keymap reference |
| [Architecture](./docs/architecture.md) | Directory layout and module responsibilities |
| [Troubleshooting](./docs/troubleshooting.md) | Health checks, common Windows issues, LSP log cleanup |
| [Contributing](./CONTRIBUTING.md) | Safe contribution workflow and style expectations |

## Customization

Machine-specific preferences can live in `lua/user.lua`, which is ignored by git. This lets users adjust small choices without editing the shared repository files.

Start with [examples/user.lua](./examples/user.lua), then see [docs/customization.md](./docs/customization.md).

## Repository Layout

```text
.
|-- init.lua                  # Bootstrap lazy.nvim and load local modules
|-- lua/
|   |-- config/               # Shared defaults and optional local config loader
|   |-- vim-options.lua       # Editor options and base keymaps
|   |-- plugins/              # Plugin specs, setup, and keymaps
|   |-- utils/                # Shared helpers for runners and virtualenvs
|   `-- overseer/template/    # Task templates
|-- assets/                   # README screenshots
|-- docs/                     # User and maintainer documentation
|-- examples/                 # Copyable local customization examples
|-- lazy-lock.json            # Locked plugin revisions
`-- pyrightconfig.json        # Python workspace exclusions
```

## Health Check

Run this after updates or when something feels off:

```vim
:checkhealth
```

Useful targeted checks:

```vim
:checkhealth vim.deprecated vim.lsp nvim-treesitter screenkey lazy
```

Current local verification shows no deprecated Neovim API calls. The only known non-breaking warning can be a large `lsp.log` file if Neovim has been running for a long time.

## Contributing

Contributions are welcome, especially improvements that keep the setup clear, fast, and easy to recover. Before opening changes, please read [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

No license file is currently included in this repository. Until a license is added, all rights remain with the repository owner.
