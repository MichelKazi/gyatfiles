local function start_ruby_debugger()
  vim.fn.setenv("RUBYOPT", "-rdebug/open")
  require("dap").continue()
end

-- only override necessary settings
local ruby_config = {
  { "tpope/vim-rails" },
  {
    "nvim-neotest/neotest",
    commit = "52fca6717ef972113ddd6ca223e30ad0abb2800c",
    lazy = true,
    dependencies = {
      "olimorris/neotest-rspec",
    },
    opts = function(_, opts)
      opts.adapters = {
        require("neotest-rspec"),
      }
    end,
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "suketa/nvim-dap-ruby",
    },
    config = function()
      local dap_ruby = require("dap-ruby")
      dap_ruby.setup()
    end,
  },
}

return ruby_config
