# Customization

This config is meant to be shared as a stable base while still giving users a safe place for machine-specific preferences.

## Local User File

Create a local file:

```text
lua/user.lua
```

This file is ignored by git. It loads before the main options, so it can change defaults without modifying the repository.

Start from the example:

```text
examples/user.lua
```

## Available Settings

```lua
vim.g.nvim_config = {
  leader = " ",
  editor = {
    relativenumber = true,
    scrolloff = 8,
    updatetime = 200,
  },
  features = {
    auto_enable_inline_diagnostics = true,
    auto_enable_screenkey = true,
  },
  keymaps = {
    clipboard_paste = true,
    external_runner = true,
  },
  providers = {
    python3 = false,
    node = false,
    ruby = false,
    perl = false,
  },
  windows = {
    additional_paths = {
      "C:\\Tools\\bin",
    },
  },
}
```

## Common Tweaks

Disable relative line numbers:

```lua
vim.g.nvim_config = {
  editor = {
    relativenumber = false,
  },
}
```

Disable automatic screenkey startup while keeping the manual toggle:

```lua
vim.g.nvim_config = {
  features = {
    auto_enable_screenkey = false,
  },
}
```

Disable automatic inline diagnostics while keeping `<leader>ll`:

```lua
vim.g.nvim_config = {
  features = {
    auto_enable_inline_diagnostics = false,
  },
}
```

Add a Windows-only tool path:

```lua
vim.g.nvim_config = {
  windows = {
    additional_paths = {
      "C:\\Tools\\bin",
    },
  },
}
```

## After-Load Hook

For custom keymaps or plugin tweaks that should run after lazy.nvim setup, create:

```text
lua/user/after.lua
```

Example:

```lua
vim.keymap.set("n", "<leader>un", function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "Toggle relative number" })
```

## Safety Notes

- Keep `lua/user.lua` local and untracked.
- Prefer `vim.g.nvim_config` for simple preferences.
- Use `lua/user/after.lua` only for keymaps or tweaks that need plugins to be loaded.
- Run `:checkhealth vim.deprecated vim.lsp nvim-treesitter screenkey lazy` after larger changes.
