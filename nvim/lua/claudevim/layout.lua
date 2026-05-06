local M = {}

-- Shared state across the claudevim module.
local state = {
  editor_win = nil,
  claude_win = nil,
  claude_buf = nil,
  claude_job = nil,
}

function M.state() return state end

local function claude_command()
  -- Reconstruct the exact arg list from the numbered env vars set by the
  -- shim. Using a list (rather than a string) means termopen exec's claude
  -- directly with no shell parsing — args with spaces, quotes, etc. survive
  -- unchanged.
  local cmd = { "claude" }
  local argc = tonumber(vim.env.CLAUDEVIM_CLAUDE_ARGC or "") or 0
  for idx = 0, argc - 1 do
    local val = vim.env["CLAUDEVIM_CLAUDE_ARG_" .. idx]
    if val ~= nil then
      table.insert(cmd, val)
    end
  end
  return cmd
end

local function spawn_claude_in_current_win()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)

  vim.bo[buf].bufhidden = "wipe"
  vim.b[buf].claudevim_claude = true

  local job = vim.fn.termopen(claude_command(), {
    on_exit = function()
      state.claude_job = nil
      if state.expecting_exit then
        -- Triggered by restart_claude(); keep claudevim running.
        state.expecting_exit = false
        return
      end
      -- Claude exited on its own (user typed `exit`, `/quit`, Ctrl-D, …).
      -- Close claudevim too. `confirm` prompts about unsaved edits in the
      -- editor pane instead of dropping them silently.
      vim.schedule(function()
        pcall(vim.cmd, "confirm qa")
      end)
    end,
  })

  vim.bo[buf].buflisted = false

  local win = vim.api.nvim_get_current_win()
  -- Force terminal-friendly window options here. The TermOpen autocmd is not
  -- always reliable for window-local options because :setlocal at TermOpen
  -- time can race with later option propagation.
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].cursorline = false
  vim.wo[win].foldcolumn = "0"

  state.claude_buf = buf
  state.claude_win = win
  state.claude_job = job
end

-- Fraction of total columns occupied by the claude pane. Override in your
-- config (~/.config/claudevim/lua/config/options.lua) before claudevim loads:
--   vim.g.claudevim_split_ratio = 0.4   -- claude takes 40%, editor 60%
local function split_ratio()
  local r = tonumber(vim.g.claudevim_split_ratio) or 0.5
  -- clamp to a sane range so the user can't accidentally hide a pane
  if r < 0.2 then r = 0.2 end
  if r > 0.8 then r = 0.8 end
  return r
end

function M.open()
  state.editor_win = vim.api.nvim_get_current_win()

  vim.cmd("botright vsplit")
  local claude_width = math.floor(vim.o.columns * split_ratio())
  vim.cmd("vertical resize " .. claude_width)

  spawn_claude_in_current_win()

  -- Re-render the alpha dashboard for the new editor pane width. Alpha caches
  -- its layout based on the window size at first render; without this it stays
  -- centered for the pre-split width and looks crooked.
  vim.schedule(function()
    if state.editor_win and vim.api.nvim_win_is_valid(state.editor_win) then
      local buf = vim.api.nvim_win_get_buf(state.editor_win)
      if vim.bo[buf].filetype == "alpha" then
        vim.api.nvim_win_call(state.editor_win, function()
          pcall(vim.cmd, "AlphaRedraw")
        end)
      end
    end
  end)

  -- Focus the claude pane and drop straight into terminal mode.
  vim.api.nvim_set_current_win(state.claude_win)
  vim.cmd("startinsert")
end

function M.is_claude_buf(buf)
  return vim.b[buf] and vim.b[buf].claudevim_claude == true
end

function M.find_claude_win()
  if state.claude_win and vim.api.nvim_win_is_valid(state.claude_win) then
    return state.claude_win
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if M.is_claude_buf(buf) then
      state.claude_win = win
      state.claude_buf = buf
      return win
    end
  end
  return nil
end

function M.find_editor_win()
  if state.editor_win and vim.api.nvim_win_is_valid(state.editor_win) then
    local buf = vim.api.nvim_win_get_buf(state.editor_win)
    if not M.is_claude_buf(buf) then
      return state.editor_win
    end
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    if not M.is_claude_buf(buf) and ft ~= "neo-tree" then
      state.editor_win = win
      return win
    end
  end
  return nil
end

return M
