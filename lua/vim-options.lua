local config = vim.g.nvim_config or {}
local editor = config.editor or {}
local providers = config.providers or {}
local keymaps = config.keymaps or {}
local windows = config.windows or {}

vim.g.mapleader = config.leader

-- WSL may auto-detect win32yank.exe even when it cannot reliably access the
-- Windows clipboard. Pin the provider to Neovim's documented WSL commands.
local is_wsl = vim.env.WSL_DISTRO_NAME ~= nil or vim.env.WSL_INTEROP ~= nil
if is_wsl then
  local paste_command = {
    "powershell.exe",
    "-NoLogo",
    "-NoProfile",
    "-NonInteractive",
    "-Command",
    '$text = Get-Clipboard -Raw; if ($null -ne $text) { [Console]::Out.Write($text.ToString().Replace("`r", "")) }',
  }

  vim.g.clipboard = {
    name = "WslClipboard",
    copy = {
      ["+"] = { "clip.exe" },
      ["*"] = { "clip.exe" },
    },
    paste = {
      ["+"] = paste_command,
      ["*"] = paste_command,
    },
    cache_enabled = 0,
  }
end

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
vim.opt.sessionoptions = editor.sessionoptions
vim.opt.wrap = editor.wrap
vim.opt.linebreak = editor.linebreak
-- Old auto-session files can restore a local colorcolumn after startup.
vim.opt.colorcolumn = ""

vim.opt.lazyredraw = false
vim.opt.synmaxcol = 200
vim.opt.redrawtime = 1500
vim.opt.ttimeoutlen = 50
vim.opt.timeoutlen = 500
vim.opt.shortmess:append("sI")
vim.opt.showmode = false
vim.opt.shada = "!,'500,<50,s10,h"

local colorcolumn_group = vim.api.nvim_create_augroup("NoColorColumn", { clear = true })

local function clear_colorcolumns()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      vim.wo[win].colorcolumn = ""
    end
  end
end

vim.api.nvim_create_autocmd({ "VimEnter", "SessionLoadPost" }, {
  group = colorcolumn_group,
  callback = clear_colorcolumns,
  desc = "Remove color columns restored by sessions",
})

vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
  group = colorcolumn_group,
  callback = function()
    vim.opt_local.colorcolumn = ""
  end,
  desc = "Keep buffers free of color columns",
})

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

    vim.defer_fn(function()
      for _, pattern in ipairs(windows.winget_patterns or {}) do
        for _, path in ipairs(vim.fn.glob(vim.fn.expand(pattern), false, true)) do
          if vim.fn.isdirectory(path) == 1 then
            prepend_path(path)
          end
        end
      end
    end, 5000)
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

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("TextWrap", { clear = true }),
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.wo.wrap = true
    vim.wo.linebreak = true
  end,
})

vim.api.nvim_create_autocmd("BufReadPre", {
  group = vim.api.nvim_create_augroup("LargeFileOpts", { clear = true }),
  callback = function(args)
    local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(args.buf))
    if size > 1024 * 512 then
      vim.bo[args.buf].syntax = ""
      vim.b[args.buf].large_file = true
      vim.bo[args.buf].undofile = false
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("LargeFileDisableTreesitter", { clear = true }),
  pattern = "*",
  callback = function(args)
    if vim.b[args.buf] and vim.b[args.buf].large_file then
      pcall(vim.treesitter.stop, args.buf)
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("CheckHealthFullScreen", { clear = true }),
  pattern = "checkhealth",
  callback = function(args)
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(args.buf) then
        return
      end

      local health_win = vim.fn.bufwinid(args.buf)
      if health_win == -1 or vim.api.nvim_win_get_config(health_win).relative ~= "" then
        return
      end

      local tab = vim.api.nvim_win_get_tabpage(health_win)
      local normal_windows = 0
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
        if vim.api.nvim_win_get_config(win).relative == "" then
          normal_windows = normal_windows + 1
        end
      end

      if normal_windows > 1 then
        vim.api.nvim_set_current_win(health_win)
        vim.cmd("wincmd T")
      end
    end)
  end,
})
