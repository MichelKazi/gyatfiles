local colorscheme = {
  -- hard contrast and black bg for gruvbox colorscheme:
  {
    "ellisonleao/gruvbox.nvim",
    config = function()
      require("gruvbox").setup({
        contrast = "hard",
        palette_overrides = {
          dark0_hard = "#0E0E0F",
        },
      })
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      color_overrides = {
        mocha = {
          base = "#000000",
          mantle = "#000000",
          crust = "#000000",
        },
      },
      transparent_background = true, -- disables setting the background color.
    },
  },
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      highlights = {
        Visual = { fg = "#000000", bg = "#ff3895", italic = true, bold = true },
      },
    },
  },
  {
    "srcery-colors/srcery-vim",
  },
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      opts.colorscheme = "srcery"

      vim.api.nvim_set_hl(0, "Operator", { fg = "#FF0000" })
      vim.api.nvim_set_hl(0, "Delimiter", { fg = "#FF0000" })
      vim.api.nvim_set_hl(0, "Special", { fg = "#FF0000" })
      return opts
    end,
  },
}

return colorscheme
