return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- The `main` branch is the new architecture and is compatible with
    -- Neovim 0.12+. The legacy `master` branch has not kept up with the
    -- API changes in nvim 0.12 and crashes in the highlighter.
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      local ensure = {
        "lua", "vim", "vimdoc", "bash", "json", "yaml", "toml",
        "markdown", "markdown_inline", "python", "javascript",
        "typescript", "tsx", "html", "css", "go", "rust",
      }

      require("nvim-treesitter").install(ensure)

      -- New-API treesitter does not auto-attach highlighting; we do it on
      -- FileType. `pcall` swallows the harmless "no parser for X" cases
      -- (terminal buffers, alpha dashboard, etc.).
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("claudevim_treesitter", { clear = true }),
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
}
