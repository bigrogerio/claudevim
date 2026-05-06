local map = vim.keymap.set

-- Window navigation: works in normal, visual, and terminal mode.
map({ "n", "v" }, "<C-h>", "<C-w>h", { desc = "Window left" })
map({ "n", "v" }, "<C-j>", "<C-w>j", { desc = "Window down" })
map({ "n", "v" }, "<C-k>", "<C-w>k", { desc = "Window up" })
map({ "n", "v" }, "<C-l>", "<C-w>l", { desc = "Window right" })

-- Terminal mode: <C-\><C-n> drops to normal mode first, then <C-w>X moves windows.
map("t", "<C-h>", [[<C-\><C-n><C-w>h]], { desc = "Window left (term)" })
map("t", "<C-j>", [[<C-\><C-n><C-w>j]], { desc = "Window down (term)" })
map("t", "<C-k>", [[<C-\><C-n><C-w>k]], { desc = "Window up (term)" })
map("t", "<C-l>", [[<C-\><C-n><C-w>l]], { desc = "Window right (term)" })

-- Escape terminal mode with double-Esc (single Esc is consumed by claude itself).
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Claude pane controls
local claude = function() return require("claudevim.claude") end
map("n", "<leader>cc", function() claude().focus_claude() end, { desc = "Focus claude pane" })
map("n", "<leader>ce", function() claude().focus_editor() end, { desc = "Focus editor pane" })
map("n", "<leader>cr", function() claude().restart_claude() end, { desc = "Restart claude" })

-- Save / quit shortcuts
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>confirm qa<cr>", { desc = "Quit all" })

-- Better up/down on wrapped lines
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Clear search highlight
map("n", "<Esc>", "<cmd>noh<cr><Esc>", { desc = "Clear hlsearch" })
