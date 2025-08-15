local function start_ruby_debugger()
  vim.fn.setenv("RUBYOPT", "-rdebug/open")
  require("dap").continue()
end

-- only override necessary settings
local ruby_config = {
  { "tpope/vim-rails" },
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
