-- Copy this file to lua/user.lua and edit it for local preferences.
-- lua/user.lua is ignored by git, so your machine-specific choices stay local.

vim.g.nvim_config = {
  -- Keep <Space> by default. Change this before plugins load if you prefer another leader.
  leader = " ",

  editor = {
    relativenumber = true,
    scrolloff = 8,
    updatetime = 200,
  },

  features = {
    -- Defaults keep the repository behavior unchanged.
    auto_enable_inline_diagnostics = true,
    auto_enable_screenkey = true,
  },

  keymaps = {
    clipboard_paste = true,
    external_runner = true,
  },

  providers = {
    -- Set a provider to true if you intentionally use Neovim's provider integration.
    python3 = false,
    node = false,
    ruby = false,
    perl = false,
  },

  windows = {
    -- Add machine-specific tool folders without editing lua/vim-options.lua.
    additional_paths = {
      -- "C:\\Tools\\bin",
    },
  },
}
