local function is_file_buffer(buf)
  return buf > 0
    and vim.api.nvim_buf_is_valid(buf)
    and vim.api.nvim_buf_get_name(buf) ~= ""
    and vim.bo[buf].buftype == ""
end

local function go_to_dashboard()
  if vim.bo.filetype == "alpha" then
    local alternate = vim.fn.bufnr("#")
    if is_file_buffer(alternate) then
      vim.cmd("buffer #")
    end
    return
  end

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
