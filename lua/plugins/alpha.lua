local function go_to_dashboard()
  vim.cmd.Alpha()
end

return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  cmd = "Alpha",
  keys = {
    { "<leader>hh", go_to_dashboard, desc = "Go to dashboard" },
  },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },

  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.startify")

    local function new_file()
      local buf = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_win_set_buf(0, buf)
    end

    local new_file_button = dashboard.button("e", "New file")
    new_file_button.on_press = new_file
    new_file_button.opts.keymap = {
      "n",
      "e",
      new_file,
      { noremap = true, silent = true, nowait = true },
    }

    dashboard.section.top_buttons.val = {
      new_file_button,
    }

    dashboard.section.header.val = {
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                     ]],
      [[       ████ ██████           █████      ██                     ]],
      [[      ███████████             █████                             ]],
      [[      █████████ ███████████████████ ███   ███████████   ]],
      [[     █████████  ███    █████████████ █████ ██████████████   ]],
      [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
      [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
      [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                       ]],
    }

    alpha.setup(dashboard.opts)
  end,
}
