vim.g.mapleader = " "
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.updatetime = 200
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,localoptions"

local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
if is_windows then
  local function prepend_path(path)
    if vim.fn.isdirectory(path) == 1 and not vim.env.PATH:find(path, 1, true) then
      vim.env.PATH = path .. ";" .. vim.env.PATH
    end
  end

  prepend_path(vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin"))

  vim.schedule(function()
    local extra_paths = {
      "C:\\Program Files\\Git\\usr\\bin",
      "C:\\Program Files\\7-Zip",
      vim.fn.expand("$LOCALAPPDATA\\Microsoft\\WinGet\\Links"),
      vim.fn.expand("$LOCALAPPDATA\\Microsoft\\WindowsApps"),
      vim.fn.expand("$APPDATA\\npm"),
      vim.fn.expand("$APPDATA\\Python\\Python314\\Scripts"),
    }

    for _, path in ipairs(extra_paths) do
      prepend_path(path)
    end

    local winget_patterns = {
      vim.fn.expand("$LOCALAPPDATA\\Microsoft\\WinGet\\Packages\\ezwinports.make_*\\bin"),
      vim.fn.expand("$LOCALAPPDATA\\Microsoft\\WinGet\\Packages\\sharkdp.fd_*\\fd-*"),
    }

    for _, pattern in ipairs(winget_patterns) do
      for _, path in ipairs(vim.fn.glob(pattern, false, true)) do
        if vim.fn.isdirectory(path) == 1 then
          prepend_path(path)
        end
      end
    end
  end)
end

vim.keymap.set("n", "<C-S-v>", '"+p')
vim.keymap.set("i", "<C-S-v>", function()
  local text = vim.fn.getreg('+')
  vim.api.nvim_put({text}, 'c', true, true)
end)

vim.keymap.set("n", "<leader>r", function()
  require("utils.external-runner").run_current_file()
end, { desc = "Run current file" })
