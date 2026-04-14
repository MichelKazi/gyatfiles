return {
  -- vim-godot for proper auto-indentation (treesitter indent is poor for GDScript)
  { "habamax/vim-godot", ft = { "gdscript", "gd" } },

  -- Extended LSP features (symbol hierarchy, etc.)
  { "teatek/gdscript-extended-lsp.nvim", opts = { view_type = "floating", picker = "snacks" } },

  -- Filetype detection for gdscript
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.filetype.add({
        extension = {
          gd = "gdscript",
        },
      })
    end,
  },

  -- LSP configuration for Godot's built-in language server
  {
    "lsp-gdscript",
    dir = vim.fn.stdpath("config"),
    dependencies = { "neovim/nvim-lspconfig" },
    ft = { "gdscript", "gd" },
    config = function()
      require("lspconfig").gdscript.setup({
        cmd = { "ncat", "localhost", "6005" },
        filetypes = { "gd", "gdscript", "gdscript3" },
        root_dir = function()
          return require("lspconfig.util").root_pattern("project.godot", ".git")(vim.fn.getcwd())
        end,
      })
    end,
  },

  -- DAP configuration for debugging
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      dap.adapters.godot = {
        type = "server",
        host = "127.0.0.1",
        port = 6006,
      }
      dap.configurations.gdscript = {
        {
          type = "godot",
          request = "launch",
          name = "Launch scene",
          project = "${workspaceFolder}",
        },
      }
    end,
  },

  -- Snacks picker config to hide Godot clutter
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = false,
            exclude = {
              "*.uid",
              "server.pipe",
            },
          },
        },
      },
    },
  },
}
