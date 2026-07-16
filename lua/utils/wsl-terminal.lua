local M = {}

local esc = "\27"

local function is_wsl()
  return vim.env.WSL_DISTRO_NAME ~= nil or vim.env.WSL_INTEROP ~= nil
end

function M.setup()
  if not is_wsl() then
    return
  end

  -- WSL uses the explicit Windows clipboard provider configured in
  -- vim-options.lua, so the UIEnter OSC 52 probe is unnecessary.
  vim.g.termfeatures = vim.tbl_extend("force", vim.g.termfeatures or {}, { osc52 = false })

  -- Neovim 0.12 can discard a key when an on_key callback returns an empty
  -- string. Older versions must be upgraded instead of using this workaround.
  if vim.fn.has("nvim-0.12") ~= 1 then
    return
  end

  if vim.g.wsl_da1_filter_initialized then
    return
  end
  vim.g.wsl_da1_filter_initialized = true

  local namespace = vim.api.nvim_create_namespace("WslDa1StartupFilter")
  local previous = ""
  local candidate
  local generation = 0

  local function replay(keys)
    vim.schedule(function()
      vim.api.nvim_feedkeys(keys, "nt", false)
    end)
  end

  local function expire_candidate(current_generation)
    vim.defer_fn(function()
      if candidate and generation == current_generation then
        local keys = candidate
        candidate = nil
        replay(keys)
      end
    end, 250)
  end

  vim.on_key(function(_, typed)
    if typed == "" then
      return
    end

    if candidate then
      candidate = candidate .. typed

      if candidate:match("^%[%?[%d;]+c$") then
        candidate = nil
        return ""
      end

      if candidate:match("^%[%?[%d;]*$") then
        return ""
      end

      local keys = candidate
      candidate = nil
      replay(keys)
      return ""
    end

    if previous == esc and typed == "[" then
      candidate = "["
      previous = ""
      generation = generation + 1
      expire_candidate(generation)
      return ""
    end

    previous = typed == esc and esc or ""
  end, namespace)

  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      vim.defer_fn(function()
        vim.on_key(nil, namespace)
        if candidate then
          replay(candidate)
          candidate = nil
        end
      end, 1000)
    end,
    desc = "Stop filtering leaked WSL DA1 responses after startup",
  })
end

M.setup()

return M
