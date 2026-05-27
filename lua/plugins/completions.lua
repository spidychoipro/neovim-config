local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1

return {
  {
    "hrsh7th/cmp-nvim-lsp",
    lazy = true,
  },
  {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    build = not is_windows and "make install_jsregexp" or false,
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "windwp/nvim-autopairs",
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      local key_confirming_completion = false
      local key_confirm_token = 0
      local cmp_autopairs_filetypes = vim.deepcopy(cmp_autopairs.filetypes)

      local function strip_snippet_placeholder_text(body)
        return body:gsub("%${(%d+):([^{}]*)}", "${%1}")
      end

      local function can_jump(direction)
        if luasnip.locally_jumpable then
          return luasnip.locally_jumpable(direction)
        end

        return luasnip.jumpable(direction)
      end

      local function completion_already_inserts_pair(item)
        if item.data and type(item.data) == 'table' and item.data.funcParensDisabled then
          return true
        end

        local insert_text = item.insertText
        local text_edit = item.textEdit and item.textEdit.newText

        return (insert_text and insert_text:match('[%(%[%$]'))
            or (text_edit and text_edit:match('[%(%[%$]'))
      end

      local function add_call_parentheses(char, item, bufnr)
        if char == '' or completion_already_inserts_pair(item) then
          return
        end

        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local line = vim.api.nvim_get_current_line()
        local char_before = line:sub(col, col)
        local char_after = line:sub(col + 1, col + 1)

        if char_before == char or char_after == char then
          return
        end

        -- Do not add parentheses when defining a function/method
        local line_to_cursor = line:sub(1, col)
        if line_to_cursor:match("def%s+" .. item.label .. "%s*$") -- Python
            or line_to_cursor:match("function%s+" .. item.label .. "%s*$") -- Lua/JS
        then
          return
        end

        vim.api.nvim_buf_set_text(bufnr, row - 1, col, row - 1, col, { '()' })
        vim.api.nvim_win_set_cursor(0, { row, col + 1 })
      end

      cmp_autopairs_filetypes['*']['('].handler = add_call_parentheses
      if cmp_autopairs_filetypes.python then
        cmp_autopairs_filetypes.python['('].handler = add_call_parentheses
      end

      local cmp_confirm_done = cmp_autopairs.on_confirm_done({
        filetypes = cmp_autopairs_filetypes,
      })

      local function confirm_completion()
        key_confirm_token = key_confirm_token + 1
        local token = key_confirm_token

        key_confirming_completion = true
        local confirmed = cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })

        if confirmed then
          vim.defer_fn(function()
            if key_confirm_token == token then
              key_confirming_completion = false
            end
          end, 1000)
        else
          key_confirming_completion = false
        end

        return confirmed
      end

      cmp.event:on('confirm_done', function(event)
        if key_confirming_completion then
          key_confirm_token = key_confirm_token + 1
          key_confirming_completion = false
          cmp_confirm_done(event)
        end
      end)

      cmp.setup({
        preselect = cmp.PreselectMode.None,
        completion = {
          completeopt = "menu,menuone,noinsert,noselect",
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(strip_snippet_placeholder_text(args.body))  -- LuaSnip만 사용
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              if not cmp.get_selected_entry() then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
              end

              if not confirm_completion() then
                fallback()
              end
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            elseif can_jump(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            elseif can_jump(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },      -- LSP 자동완성 (이게 핵심!)
          {
            name = 'luasnip',
            entry_filter = function(entry, ctx)
              local kind = entry:get_kind()
              local label = entry.completion_item.label
              local ft = vim.bo.filetype

              -- Only filter snippets (this is what causes the "visual mode" selection)
              if kind ~= require('cmp.types').lsp.CompletionItemKind.Snippet then
                return true
              end

              -- 1. Python specific filters
              if ft == 'python' then
                -- Filter magic methods: __init__, __str__, etc.
                if label:match("^__.*__$") then return false end
                
                -- Filter core keywords that are usually redundant with LSP
                local py_keywords = {
                  'class', 'def', 'if', 'else', 'elif', 'for', 'while', 'try', 'except', 'finally',
                  'with', 'async', 'await', 'return', 'yield', 'import', 'from', 'raise', 'pass',
                  'break', 'continue', 'lambda', 'global', 'nonlocal', 'assert', 'del'
                }
                for _, kw in ipairs(py_keywords) do
                  if label == kw then return false end
                end
              end

              -- 2. Lua specific filters
              if ft == 'lua' then
                local lua_keywords = {
                  'local', 'function', 'if', 'then', 'else', 'elseif', 'end', 'for', 'while',
                  'repeat', 'until', 'do', 'return', 'break'
                }
                for _, kw in ipairs(lua_keywords) do
                  if label == kw then return false end
                end
              end

              -- 3. C/C++ specific filters
              if ft == 'c' or ft == 'cpp' then
                local cpp_keywords = {
                  'class', 'struct', 'union', 'enum', 'typedef', 'if', 'else', 'for', 'while',
                  'do', 'switch', 'case', 'default', 'return', 'try', 'catch', 'namespace', 'public',
                  'protected', 'private', 'template', 'typename', 'virtual', 'inline'
                }
                for _, kw in ipairs(cpp_keywords) do
                  if label == kw then return false end
                end
              end

              -- 4. Shell/Bash specific filters
              if ft == 'sh' or ft == 'bash' then
                local sh_keywords = {
                  'if', 'then', 'else', 'elif', 'fi', 'for', 'while', 'until', 'do', 'done',
                  'case', 'esac', 'function'
                }
                for _, kw in ipairs(sh_keywords) do
                  if label == kw then return false end
                end
              end

              -- 5. Global catch-all for very common triggers that are almost always annoying as snippets
              local common = { 'if', 'else', 'for', 'while', 'return', 'class', 'function' }
              for _, kw in ipairs(common) do
                if label == kw then return false end
              end

              return true
            end
          },
        }, {
          { name = 'buffer' },        -- 버퍼에서 단어
          { name = 'path' },          -- 파일 경로
        })
      })

      -- 이거 꼭 넣어줘야 LSP에서 capabilities 받음!
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      -- 전역 변수로 저장 → lsp-config.lua에서 사용
      vim.g.cmp_capabilities = capabilities
    end,
  },
}
