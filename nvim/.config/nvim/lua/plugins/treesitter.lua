return {
  { "HiPhish/rainbow-delimiters.nvim" },
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      { "RRethy/nvim-treesitter-endwise" },
      { "RRethy/nvim-treesitter-textsubjects" },
    },
    opts = function(_, opts)
      opts.endwise = { enable = true }
      opts.indent = { enable = true, disable = { "yaml", "ruby" } }
      opts.textsubjects = {
        enable = true,
        prev_selection = ",",
        keymaps = {
          ["."] = "textsubjects-smart",
          [";"] = "textsubjects-container-outer",
          ["i;"] = "textsubjects-container-inner",
        },
      }
      opts.ensure_installed = {
        "bash",
        "embedded_template",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "ruby",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      }
    end,
  },
}
