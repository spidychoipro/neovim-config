local function get_hanvim_path()
  local dev_path = "C:/Users/swpar/plugin/hanvim.nvim"
  if vim.fn.isdirectory(dev_path) == 1 then
    return dev_path
  end

  local home_path = vim.fn.expand("~/plugins/hanvim.nvim")
  if vim.fn.isdirectory(home_path) == 1 then
    return home_path
  end

  vim.fn.mkdir(vim.fn.expand("~/plugins"), "p")
  local repo = "https://github.com/spidychoipro/hanvim.nvim"
  local target = vim.fn.expand("~/plugins/hanvim.nvim")
  vim.fn.system({ "git", "clone", "--filter=blob:none", repo, target })
  if vim.v.shell_error == 0 then
    return target
  end

  return nil
end

local hanvim_path = get_hanvim_path()

local plugins = {
  require("plugins.alpha"),
  require("plugins.auto-session"),
  require("plugins.comment"),
  require("plugins.completions"),
  require("plugins.conform-lint"),
  require("plugins.debugging"),
  require("plugins.diagnostics"),
  require("plugins.dracula"),
  require("plugins.flash"),
  require("plugins.gitsigns"),
  require("plugins.lsp-config"),
  require("plugins.lualine"),
  require("plugins.neo-tree"),
  require("plugins.overseer"),
  require("plugins.powershell"),
  require("plugins.screenkey"),
  require("plugins.telescope"),
  require("plugins.treesitter"),
  require("plugins.trouble"),
  require("plugins.which-key"),
  require("plugins.yanky"),
}

if hanvim_path then
  table.insert(plugins, { dir = hanvim_path })
end

return plugins
