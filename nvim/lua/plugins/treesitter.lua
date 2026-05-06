return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- Pin to the legacy `master` branch. The repo's new default `main` has
    -- a different API and does not expose `nvim-treesitter.configs`.
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "lua", "vim", "vimdoc", "bash", "json", "yaml", "toml",
        "markdown", "markdown_inline", "python", "javascript",
        "typescript", "tsx", "html", "css", "go", "rust",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
}
