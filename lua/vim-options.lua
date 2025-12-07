vim.opt.nu = true
vim.opt.relativenumber = true
vim.expandtab = true
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.g.mapleader =  " "
vim.opt.clipboard = "unnamedplus"

vim.keymap.set("n", "<C-S-v>", '"+p')
vim.keymap.set("i", "<C-S-v>", function()
  local text = vim.fn.getreg('+')
  vim.api.nvim_put({text}, 'c', true, true)
end)
