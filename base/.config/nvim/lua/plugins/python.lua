local python_config = {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruff_lsp = {
          cmd = { vim.fn.expand("/Users/mkazi/.local/bin/ruff-lsp") },
          filetypes = { "python" },
        },
      },
    },
  },
}

return python_config
