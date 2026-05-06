local M = {}

function M.setup()
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("claudevim_boot", { clear = true }),
    once = true,
    callback = function()
      require("claudevim.layout").open()
    end,
  })
end

return M
