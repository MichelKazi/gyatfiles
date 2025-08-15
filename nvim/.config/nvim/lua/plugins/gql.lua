return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      graphql = {
        cmd = { "graphql-lsp", "server", "-m", "stream" },
        filetypes = { "graphql" },
      },
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("FileType", {

      pattern = "graphql",

      callback = function(ev)
        vim.lsp.start({
          name = "apollo-language-server",
          cmd = { "rover", "lsp", "--supergraph-config", "supergraph.yaml" },
          root_dir = vim.fs.root(ev.buf, { "supergraph.yaml" }),
        })
      end,
    })
  end,
}
