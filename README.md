# Neovim Config

[![Neovim](https://img.shields.io/badge/Neovim-0.12.2-57A143?logo=neovim&logoColor=white)](https://neovim.io/)
[![Plugin manager](https://img.shields.io/badge/plugin%20manager-lazy.nvim-2f81f7)](https://github.com/folke/lazy.nvim)
[![Healthcheck](https://img.shields.io/badge/healthcheck-passing-brightgreen)](./docs/troubleshooting.md#health-checks)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-blue)](#requirements)
[![License](https://img.shields.io/badge/license-not%20specified-lightgrey)](#license)

[한국어 문서](./README.ko.md) · [Install](./docs/installation.md) · [Usage](./docs/usage.md) · [Keymaps](./docs/keymaps.md) · [Architecture](./docs/architecture.md) · [Troubleshooting](./docs/troubleshooting.md)

A fast, IDE-like Neovim configuration focused on language tooling, inline diagnostics, external terminal execution, and a predictable Windows-friendly workflow.

This setup treats Neovim as the editing control center while keeping program execution in a real terminal. It is designed to feel approachable for new users and still stay explicit enough for experienced Neovim users to modify safely.

## Highlights

| Area | What you get |
| --- | --- |
| Language tooling | LSP for Python, Lua, Bash, PowerShell, C, and C++ |
| Diagnostics | E/W/I/H signs plus modern inline diagnostics with `tiny-inline-diagnostic.nvim` |
| Runtime workflow | `<leader>r` runs the current file in an external terminal |
| Windows support | PowerShell 7, Windows Terminal, Mason tool paths, and `.ps1` job cleanup |
| Project navigation | Telescope, Neo-tree, Trouble, Gitsigns, and which-key |
| Debugging and tasks | `nvim-dap`, `dap-ui`, `overseer.nvim`, and task history |
| Sessions | Automatic save and restore with `auto-session` |
| Modern APIs | Neovim 0.12-ready Tree-sitter, LSP, diagnostics, and `vim.uv` usage |

## Preview

![Clean startup dashboard](assets/startup.png)

![Python LSP diagnostics](assets/lsp-python.png)

![External run workflow](assets/external-run.png)

![Which-key leader popup](assets/which-key.png)

![Telescope file search](assets/telescope.png)

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

Lazy.nvim will bootstrap itself on first launch. Mason-managed tools are installed from inside Neovim.

See the full guide: [docs/installation.md](./docs/installation.md).

## Requirements

| Requirement | Notes |
| --- | --- |
| Neovim | Tested with `v0.12.2` |
| Git | Required for lazy.nvim and plugin installs |
| Node.js + npm | Required by several LSP/tooling packages |
| Python | Required for Python tooling and debug support |
| PowerShell 7 (`pwsh`) | Recommended on Windows |
| Windows Terminal (`wt.exe`) | Used by the external runner on Windows |
| `clang` / `clang++` | Used for C and C++ builds/runs |
| `bash` or `sh` | Used for shell scripts |

Mason installs editor-side tools such as `lua-language-server`, `basedpyright`, `bash-language-server`, `powershell-editor-services`, `clangd`, `clang-format`, `debugpy`, `codelldb`, `black`, `isort`, `stylua`, `shellcheck`, and `shfmt`.

## Everyday Commands

| Key | Action |
| --- | --- |
| `<leader>r` | Run current file in an external terminal |
| `<leader>f` | Format current file |
| `<C-p>` | Find files |
| `<leader>/` | Search project text |
| `<C-n>` | Reveal file explorer |
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
| [Keymaps](./docs/keymaps.md) | Complete keymap reference |
| [Architecture](./docs/architecture.md) | Directory layout and module responsibilities |
| [Troubleshooting](./docs/troubleshooting.md) | Health checks, common Windows issues, LSP log cleanup |
| [Contributing](./CONTRIBUTING.md) | Safe contribution workflow and style expectations |

## Repository Layout

```text
.
|-- init.lua                  # Bootstrap lazy.nvim and load local modules
|-- lua/
|   |-- vim-options.lua       # Editor options and base keymaps
|   |-- plugins/              # Plugin specs, setup, and keymaps
|   |-- utils/                # Shared helpers for runners and virtualenvs
|   `-- overseer/template/    # Task templates
|-- assets/                   # README screenshots
|-- docs/                     # User and maintainer documentation
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
