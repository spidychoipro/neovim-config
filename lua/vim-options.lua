local config = vim.g.nvim_config or {}
local editor = config.editor or {}
local providers = config.providers or {}
local keymaps = config.keymaps or {}
local windows = config.windows or {}

vim.g.mapleader = config.leader

if providers.python3 == false then
  vim.g.loaded_python3_provider = 0
end

if providers.node == false then
  vim.g.loaded_node_provider = 0
end

if providers.ruby == false then
  vim.g.loaded_ruby_provider = 0
end

if providers.perl == false then
  vim.g.loaded_perl_provider = 0
end

vim.opt.number = editor.number
vim.opt.relativenumber = editor.relativenumber
vim.opt.expandtab = editor.expandtab
vim.opt.softtabstop = editor.softtabstop
vim.opt.shiftwidth = editor.shiftwidth
vim.opt.tabstop = editor.tabstop
vim.opt.smartindent = editor.smartindent
vim.opt.termguicolors = editor.termguicolors
vim.opt.signcolumn = editor.signcolumn
vim.opt.clipboard = editor.clipboard
vim.opt.splitright = editor.splitright
vim.opt.splitbelow = editor.splitbelow
vim.opt.scrolloff = editor.scrolloff
vim.opt.sidescrolloff = editor.sidescrolloff
vim.opt.updatetime = editor.updatetime
vim.opt.ignorecase = editor.ignorecase
vim.opt.smartcase = editor.smartcase
vim.opt.undofile = editor.undofile
vim.o.sessionoptions = editor.sessionoptions

local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
if is_windows then
  local function prepend_path(path)
    if vim.fn.isdirectory(path) == 1 and not vim.env.PATH:find(path, 1, true) then
      vim.env.PATH = path .. ";" .. vim.env.PATH
    end
  end

  prepend_path(vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin"))

  vim.schedule(function()
    local extra_paths = vim.list_extend(vim.deepcopy(windows.extra_paths or {}), windows.additional_paths or {})

    for _, path in ipairs(extra_paths) do
      prepend_path(vim.fn.expand(path))
    end

    for _, pattern in ipairs(windows.winget_patterns or {}) do
      for _, path in ipairs(vim.fn.glob(vim.fn.expand(pattern), false, true)) do
        if vim.fn.isdirectory(path) == 1 then
          prepend_path(path)
        end
      end
    end
  end)
end

if keymaps.clipboard_paste then
  vim.keymap.set("n", "<C-S-v>", '"+p')
  vim.keymap.set("i", "<C-S-v>", function()
    local text = vim.fn.getreg('+')
    vim.api.nvim_put({ text }, 'c', true, true)
  end)
end

if keymaps.external_runner then
  vim.keymap.set("n", "<leader>r", function()
    require("utils.external-runner").run_current_file()
  end, { desc = "Run current file" })
end
