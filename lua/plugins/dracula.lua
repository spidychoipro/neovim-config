return {
  {
    "Mofiqul/dracula.nvim",
    name = "dracula",
    priority = 1000,
    init = function()
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("ApplyColorscheme", { clear = true }),
        callback = function()
          if not vim.g.colors_name then
            pcall(vim.cmd.colorscheme, "dracula")
          end
        end,
      })
    end,
    config = function()
      if not vim.g.colors_name then
        vim.cmd.colorscheme("dracula")
      end
    end,
  },
}
