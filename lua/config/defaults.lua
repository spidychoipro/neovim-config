local M = {}

local defaults = {
  leader = " ",
  providers = {
    python3 = false,
    node = false,
    ruby = false,
    perl = false,
  },
  editor = {
    number = true,
    relativenumber = true,
    expandtab = true,
    softtabstop = 4,
    shiftwidth = 4,
    tabstop = 4,
    smartindent = true,
    termguicolors = true,
    signcolumn = "yes",
    clipboard = "unnamedplus",
    splitright = true,
    splitbelow = true,
    scrolloff = 8,
    sidescrolloff = 8,
    updatetime = 200,
    ignorecase = true,
    smartcase = true,
    undofile = true,
    sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,localoptions",
  },
  features = {
    auto_enable_inline_diagnostics = true,
    auto_enable_screenkey = true,
  },
  keymaps = {
    clipboard_paste = true,
    external_runner = true,
  },
  windows = {
    extra_paths = {
      "C:\\Program Files\\Git\\usr\\bin",
      "C:\\Program Files\\7-Zip",
      "$LOCALAPPDATA\\Microsoft\\WinGet\\Links",
      "$LOCALAPPDATA\\Microsoft\\WindowsApps",
      "$APPDATA\\npm",
      "$APPDATA\\Python\\Python314\\Scripts",
    },
    winget_patterns = {
      "$LOCALAPPDATA\\Microsoft\\WinGet\\Packages\\ezwinports.make_*\\bin",
      "$LOCALAPPDATA\\Microsoft\\WinGet\\Packages\\sharkdp.fd_*\\fd-*",
    },
    additional_paths = {},
  },
}

function M.setup()
  vim.g.nvim_config = vim.tbl_deep_extend("keep", vim.g.nvim_config or {}, defaults)
end

return M
