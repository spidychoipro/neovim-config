# Architecture

This repository keeps behavior grouped by responsibility rather than by plugin manager mechanics.

## Directory Structure

```text
.
|-- init.lua
|-- lua/
|   |-- config/
|   |   |-- defaults.lua
|   |   `-- local.lua
|   |-- vim-options.lua
|   |-- plugins.lua
|   |-- plugins/
|   |   |-- alpha.lua
|   |   |-- auto-session.lua
|   |   |-- completions.lua
|   |   |-- conform-lint.lua
|   |   |-- debugging.lua
|   |   |-- diagnostics.lua
|   |   |-- dracula.lua
|   |   |-- gitsigns.lua
|   |   |-- lsp-config.lua
|   |   |-- lualine.lua
|   |   |-- neo-tree.lua
|   |   |-- overseer.lua
|   |   |-- powershell.lua
|   |   |-- screenkey.lua
|   |   |-- telescope.lua
|   |   |-- treesitter.lua
|   |   |-- trouble.lua
|   |   `-- which-key.lua
|   |-- utils/
|   |   |-- external-runner.lua
|   |   `-- venv.lua
|   `-- overseer/template/current_file.lua
|-- assets/
|-- docs/
|-- lazy-lock.json
`-- pyrightconfig.json
```

## Bootstrap Flow

1. `init.lua` enables the Lua loader.
2. `init.lua` bootstraps `lazy.nvim` if it is missing.
3. `lua/vim-options.lua` applies editor options and base keymaps.
4. `lazy.nvim` imports plugin specs from `lua/plugins/`.

## Key Modules

| Module | Responsibility |
| --- | --- |
| `lua/plugins/lsp-config.lua` | Mason, LSP servers, root detection, attach keymaps |
| `lua/plugins/diagnostics.lua` | Diagnostic signs, inline diagnostics, diagnostic keymaps |
| `lua/plugins/treesitter.lua` | Tree-sitter parser setup and highlighting |
| `lua/plugins/screenkey.lua` | Screenkey setup, auto enable, manual controls |
| `lua/config/defaults.lua` | Shared defaults for editor options and feature toggles |
| `lua/config/local.lua` | Optional `lua/user.lua` and `lua/user/after.lua` loader |
| `lua/plugins/powershell.lua` | Hidden PowerShell Editor Services job cleanup |
| `lua/utils/external-runner.lua` | External terminal execution for supported filetypes |
| `lua/utils/venv.lua` | Python virtual environment detection |
| `lua/overseer/template/current_file.lua` | Build and run task templates |

## Customization Flow

1. `init.lua` loads optional `lua/user.lua`.
2. `lua/config/defaults.lua` fills in any missing defaults.
3. `lua/vim-options.lua` applies the merged settings.
4. Plugins load normally.
5. `init.lua` loads optional `lua/user/after.lua`.

This gives users a safe local override path while preserving the repository defaults for everyone else.

## API Compatibility Notes

The config follows current Neovim APIs:

- `vim.uv` instead of deprecated `vim.loop`
- `vim.fs.root()` instead of older `lspconfig.util.root_pattern()` usage
- `vim.diagnostic.config()` for diagnostic signs
- `vim.lsp.config()` and `vim.lsp.enable()` for LSP setup
- `vim.treesitter.start()` with the `nvim-treesitter` main branch

## Plugin Locking

`lazy-lock.json` stores plugin revisions. Commit this file after plugin updates so other machines can reproduce the same setup.
