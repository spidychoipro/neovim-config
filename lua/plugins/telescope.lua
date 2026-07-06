return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      { "<C-p>", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>/", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Find buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Find help" },
      { "<leader>'", "<cmd>Telescope resume<CR>", desc = "Resume last picker" },
      { "<leader>gt", "<cmd>Telescope git_status<CR>", desc = "Git status" },
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Git commits" },
      { "<leader>gC", "<cmd>Telescope git_branches<CR>", desc = "Git branches" },
    },
    config = function()
      local telescope = require("telescope")
      local trouble_ok, trouble = pcall(require, "trouble.sources.telescope")

      telescope.setup({
        defaults = {
          mappings = trouble_ok and {
            i = { ["<c-t>"] = trouble.open },
            n = { ["<c-t>"] = trouble.open },
          } or {},
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })

      telescope.load_extension("ui-select")
    end,
  },
}
