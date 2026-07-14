local M = {}

local function find_latest_python_scripts()
  local appdata = vim.fn.expand("$APPDATA")
  if appdata == "" or appdata == "$APPDATA" then
    return nil
  end

  local dirs = vim.fn.glob(appdata .. "\\Python\\Python3*\\Scripts", false, true)
  if #dirs > 0 then
    table.sort(dirs)
    return dirs[#dirs]
  end

  return nil
end

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
    sessionoptions = "blank,buffers,curdir,folds,help,tabpages,localoptions",
    wrap = false,
    linebreak = false,
    colorcolumn = "",
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
    },
    winget_patterns = {
      "$LOCALAPPDATA\\Microsoft\\WinGet\\Packages\\ezwinports.make_*\\bin",
      "$LOCALAPPDATA\\Microsoft\\WinGet\\Packages\\sharkdp.fd_*\\fd-*",
    },
    additional_paths = {},
  },
}

local py_scripts = find_latest_python_scripts()
if py_scripts then
  table.insert(defaults.windows.extra_paths, py_scripts)
end

local function validate_user_config(user_config)
  local known_keys = {
    leader = true, providers = true, editor = true,
    features = true, keymaps = true, windows = true,
  }

  for key, _ in pairs(user_config) do
    if not known_keys[key] then
      vim.schedule(function()
        vim.notify(
          string.format("[defaults] Unknown config key '%s' in user.lua — may be misspelled or outdated", key),
          vim.log.levels.WARN
        )
      end)
    end
  end
end

function M.setup()
  local user_config = vim.g.nvim_config or {}
  validate_user_config(user_config)
  vim.g.nvim_config = vim.tbl_deep_extend("keep", user_config, defaults)
end

return M
