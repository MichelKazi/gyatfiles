return {
  "cbochs/grapple.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  opts = function(_, opts)
    require("telescope").load_extension("grapple")
    opts.scope = "git_branch"
    return opts
  end,
  event = { "BufReadPost", "BufNewFile" },
  cmd = "Grapple",
  keys = {
    { "<leader>H", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
    { "<leader>h", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple open tags window" },
    {
      "<leader>fh",
      "<cmd>Telescope grapple tags<cr>",
      desc = "Telescope Grapple tags",
    },
    { "<leader>n", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple cycle next tag" },
    { "<leader>N", "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple cycle previous tag" },
  },
}
