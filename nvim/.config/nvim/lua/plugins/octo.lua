return {
  "pwntester/octo.nvim",
  opts = {
    submit_win = {
      approve_review = { lhs = "<C-y>", desc = "approve review" },
      comment_review = { lhs = "<C-m>", desc = "comment review" },
      request_changes = { lhs = "<C-r>", desc = "request changes review" },
      close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
    },
  },
  keys = {
    { "<leader>o", "<cmd>Octo<CR>", desc = "List Issues (Octo)" },
  },
}
