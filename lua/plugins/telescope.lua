return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
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
    },
    config = function()
      local telescope = require("telescope")
      local trouble = require("trouble.sources.telescope")

      telescope.setup({
        defaults = {
          mappings = {
            i = { ["<c-t>"] = trouble.open },
            n = { ["<c-t>"] = trouble.open },
          },
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
