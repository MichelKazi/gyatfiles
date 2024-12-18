return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy", -- Or `LspAttach`
    priority = 1000, -- needs to be loaded in first
    config = function()
      require("tiny-inline-diagnostic").setup()
    end,
  },
  {
    {
      "j-hui/fidget.nvim",
      enabled = false,
      opts = {
        -- options
        display = {
          render_limit = 3,
          done_ttl = 2,
        },
      },
    },
  },
}
