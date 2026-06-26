local function fix_lualine_separators()
  local sections = { 'a', 'b', 'c', 'x' }
  local modes = { 'normal', 'insert', 'visual', 'replace', 'command', 'terminal', 'inactive' }

  for _, mode in ipairs(modes) do
    local bg = {}
    local ok = true
    for _, sec in ipairs(sections) do
      local hl = vim.api.nvim_get_hl(0, { name = 'lualine_' .. sec .. '_' .. mode })
      if hl and hl.bg then
        bg[sec] = hl.bg
      else
        hl = vim.api.nvim_get_hl(0, { name = 'Normal' })
        if hl and hl.bg then
          bg[sec] = hl.bg
        else
          ok = false
          break
        end
      end
    end
    if ok then
      for i = 1, #sections - 1 do
        local l, r = sections[i], sections[i + 1]
        vim.api.nvim_set_hl(0, 'lualine_' .. l .. '_' .. mode .. '_separator_right', {
          fg = bg[l], bg = bg[r],
        })
        vim.api.nvim_set_hl(0, 'lualine_' .. r .. '_' .. mode .. '_separator_left', {
          fg = bg[l], bg = bg[r],
        })
      end
    end
  end
end

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  config = function()
    require('lualine').setup({
      options = {
        theme = 'dracula',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = {
          { 'branch', icon = '' },
          {
            'diff',
            symbols = { added = '+', modified = '~', removed = '-' },
          },
        },
        lualine_c = { 'filename' },
        lualine_x = {
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = { error = "E:", warn = "W:", info = "I:", hint = "H:" },
            colored = true,
            update_in_insert = true,
          },
          'encoding',
          'fileformat',
          'filetype',
          'progress',
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
      },
    })

    fix_lualine_separators()
    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = '*',
      callback = fix_lualine_separators,
    })
  end,
}
