return {
  -- Disable fidget.nvim (using snacks.nvim notifier + lsp-progress instead)
  { "j-hui/fidget.nvim", enabled = false },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    config = function()
      require("tiny-inline-diagnostic").setup()
    end,
  },
}
