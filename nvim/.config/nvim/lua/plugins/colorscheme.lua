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
      theme = {
        highlights = {
          Visual = { fg = "#000000", bg = "#ff3895", italic = true, bold = true },
        },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      opts.colorscheme = "cyberdream"
      return opts
    end,
  },
}

return colorscheme
