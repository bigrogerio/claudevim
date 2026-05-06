return {
  {
    "nvim-treesitter/nvim-treesitter",
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
