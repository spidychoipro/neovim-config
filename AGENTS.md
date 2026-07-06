# AI Guidelines for Neovim Config

## Bug Definition

"Bug" includes not only runtime errors but also:

1. **Deprecated functions/APIs** — Any function or API marked as deprecated in the official Neovim documentation. Replace with the recommended successor (e.g., `vim.fn.readdir` → `vim.fs.dir`).

2. **Future-deprecated patterns** — APIs that are not yet deprecated but have a newer preferred alternative in the latest Neovim stable, and the older API is expected to be deprecated in a future release.

3. **Version-gated removals** — Any API that has been removed or changed in a way that would break the config on the latest Neovim stable.

## Priority

| Severity | Criteria |
|---|---|
| 🔴 Critical | API removed in current Neovim stable → config crashes |
| 🟡 Warning | API deprecated with a documented replacement → config still works but logs deprecation warnings, or will break in next release |
| 🟢 Info | Not deprecated but a newer preferred alternative exists |

## Scope

Check all `.lua` files under `lua/`, `init.lua`, and any other configuration files in the repository.
