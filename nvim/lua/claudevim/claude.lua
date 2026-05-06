local layout = require("claudevim.layout")

local M = {}

function M.focus_claude()
  local win = layout.find_claude_win()
  if not win then
    vim.notify("claudevim: claude pane not found, restarting", vim.log.levels.WARN)
    layout.open()
    win = layout.find_claude_win()
    if not win then return end
  end
  vim.api.nvim_set_current_win(win)
  vim.cmd("startinsert")
end

function M.focus_editor()
  local win = layout.find_editor_win()
  if win then
    vim.api.nvim_set_current_win(win)
  end
end

function M.restart_claude()
  local state = layout.state()
  -- Mark this exit as expected so on_exit doesn't tear down all of claudevim.
  state.expecting_exit = true
  if state.claude_win and vim.api.nvim_win_is_valid(state.claude_win) then
    vim.api.nvim_win_close(state.claude_win, true)
  end
  if state.claude_buf and vim.api.nvim_buf_is_valid(state.claude_buf) then
    pcall(vim.api.nvim_buf_delete, state.claude_buf, { force = true })
  end
  state.claude_win = nil
  state.claude_buf = nil
  state.claude_job = nil
  layout.open()
end

return M
