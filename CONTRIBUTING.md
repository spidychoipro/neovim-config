# Contributing

Thanks for improving this Neovim configuration. The goal is to keep the setup fast, readable, and easy to recover when an update changes plugin or Neovim APIs.

## Principles

- Preserve existing features and keymaps unless a change explicitly requires otherwise.
- Prefer current Neovim APIs over deprecated compatibility paths.
- Keep plugin configuration close to the plugin file in `lua/plugins/`.
- Keep Windows behavior working, especially PowerShell, Mason paths, and external terminal execution.
- Document user-facing changes in `README.md` or `docs/`.

## Local Workflow

1. Make a focused change.
2. Run health checks:

   ```vim
   :checkhealth
   :checkhealth vim.deprecated vim.lsp nvim-treesitter screenkey lazy
   ```

3. If plugin specs changed, run:

   ```vim
   :Lazy sync
   ```

4. If Tree-sitter changed, run:

   ```vim
   :TSUpdate
   ```

5. Review the diff:

   ```bash
   git diff
   ```

## Documentation Style

- Use clear headings and short sections.
- Prefer tables for keymaps, tools, and feature summaries.
- Use fenced code blocks with language names.
- Keep paths and commands copy-friendly.
- Avoid adding badges that imply CI or licensing that does not exist.

## Pull Request Checklist

- [ ] Existing keymaps still work.
- [ ] `:checkhealth vim.deprecated` has no config-owned warnings.
- [ ] `:checkhealth nvim-treesitter vim.treesitter` is clean or warnings are explained.
- [ ] Python LSP still avoids scanning the whole user profile for single files.
- [ ] PowerShell files can save and quit cleanly.
- [ ] Documentation is updated for user-facing changes.
