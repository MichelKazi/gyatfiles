-- Drop into lua/plugins/colorscheme.lua alongside the existing entries.
-- Points lazy.nvim at the local plugin dir (adjust if you move the repo),
-- registers vector as the LazyVim colorscheme, and wires the lualine theme.
return {
  {
    "vector.nvim",
    dir = vim.fn.expand("~/gyatfiles/vector/nvim/vector.nvim"),
    lazy = false,
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "vector" },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = { options = { theme = "vector" } },
  },
}
