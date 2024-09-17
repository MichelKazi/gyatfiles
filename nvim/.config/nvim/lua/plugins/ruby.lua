function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

local nvim_lsp = require("lspconfig")
-- TODO: add a keybinding to show all breakpoints

-- https://www.reddit.com/r/ruby/comments/1ctwtrd/comment/l4grs82/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
local function start_ruby_debugger()
  -- TODO: make this custom just like testing since it stops always at the 1st line
  local dap = require("dap")
  vim.fn.setenv("RUBYOPT", "-rdebug/open")
  dap.continue()
end

local function start_rspec_debugger()
  local command = "rspec"
  local dap = require("dap")
  if file_exists("bin/rspec") then
    vim.notify("Using bin/rspec", vim.log.levels.DEBUG)
    command = "bin/rspec"
  else
    vim.notify("No bin/rspec found, using rspec, did you remember to run `bundle binstubs --all`", vim.log.levels.INFO)
  end
  -- add the current file to the command
  -- https://github.com/ruby/debug?tab=readme-ov-file#invoke-as-a-remote-debuggee
  -- vim.fn.setenv("RUBYOPT", "-rdebug/open_nonstop")
  vim.fn.setenv("RUBYOPT", "-rdebug/open")
  local status, err = pcall(function()
    dap.run({
      type = "ruby",
      name = "debug current rspec file",
      request = "attach",
      command = command,
      -- current_file = true,
      port = 38698,
      server = "127.0.0.1",
      -- localfs = true,
      waiting = 100,
      stopOnEntry = false,
    })
  end)
  if not status then
    vim.notify(
      "Failed to start the debugger, did you create the bin directory by running 'bundle binstubs --all': " .. err,
      vim.log.levels.WARN
    )
  end
  -- unset rubyopt of there is clashing with rubocop when trying to lint/config
  dap.listeners.after.event_terminated["unset_rubyopt"] = function()
    vim.fn.setenv("RUBYOPT", "")
  end
  dap.listeners.after.event_exited["unset_rubyopt"] = function()
    vim.fn.setenv("RUBYOPT", "")
  end
end

local function sorbet_root_pattern(...)
  local patterns = { "sorbet/config" }
  return require("lspconfig.util").root_pattern(unpack(patterns))(...)
end

local ruby_config = {
  { "tpope/vim-rails" },
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      servers = {
        ruby_lsp = {
          mason = false,
          cmd = { vim.fn.expand("~/.rbenv/shims/ruby-lsp") },
        },
        sorbet = {
          cmd = { "srb", "tc", "--lsp" },
          filetypes = { "ruby" },
          root_dir = function(fname)
            return sorbet_root_pattern(fname)
          end,
        },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "suketa/nvim-dap-ruby",
        -- commit = "7b2c026baeedcd5aa0687067ea640767e9d45faf",
      },
      {
        "rcarriga/nvim-dap-ui",
        lazy = true,
        -- disable default keybindings
        keys = function()
          return {}
        end,
        opts = {},
        config = function(_)
          local dap = require("dap")
          local dapui = require("dapui")

          -- conditionally configure debugger based in filetype of code we are debugging
          local function get_elements()
            local filetype = vim.bo.filetype
            local elements = {
              {
                id = "repl",
                size = 0.4,
                mappings = {
                  n = {
                    close = { "q", "<Esc>" },
                  },
                },
              },
              {
                id = "scopes",
                size = 0.25,
              },
            }

            local languages_without_console = { "ruby", "go", "python" }
            if not filetype.find(table.concat(languages_without_console, ","), filetype) then
              table.insert(elements, 2, {
                id = "console",
                size = 0.35,
              })
            else
              elements[1].size = 0.55
              elements[2].size = 0.45
            end

            return elements
          end

          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.setup({
              layouts = {
                {
                  elements = get_elements(),
                  position = "bottom",
                  size = 20,
                },
              },
            })
            dapui.open({})
          end
        end,
      },
    },
    optional = true,
    config = function()
      -- icons and a visual line when for the debug session
      local Config = require("lazyvim.config")
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      for name, sign in pairs(Config.icons.dap) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define(
          "Dap" .. name,
          { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
        )
      end

      require("dap-ruby").setup()

      local dap = require("dap")
    end,
    keys = function()
      return {
        {
          "<leader>db",
          function()
            require("dap").toggle_breakpoint()
          end,
          desc = "Toggle Breakpoint",
        },
        {
          "<leader>dB",
          function()
            require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
          end,
          desc = "Set Conditional Breakpoint",
        },
        {
          "<leader>dc",
          function()
            local filetype = vim.bo.filetype
            if filetype == "ruby" then
              start_ruby_debugger()
            else
              require("dap").continue()
            end
          end,
          desc = "Start/Continue",
        },
        {
          "<leader>ds",
          function()
            require("dapui").toggle()
          end,
          desc = "See last session result",
        },
        {
          "<leader>di",
          function()
            require("dap").step_into()
          end,
          desc = "Step Into",
        },
        {
          "<leader>do",
          function()
            require("dap").step_over()
          end,
          desc = "Step Over",
        },
        {
          "<leader>dr",
          function()
            require("dap").restart()
          end,
          desc = "Restart",
        },
        {
          "<leader>dt",
          function()
            local filetype = vim.bo.filetype
            if filetype == "ruby" then
              start_rspec_debugger()
            else
              vim.notify("No test method for filetype: " .. filetype, vim.log.levels.WARN)
            end
          end,
          desc = "Debug the closest test method above the cursor",
        },
        {
          "<leader>dw",
          function()
            require("dap.ui.widgets").hover()
          end,
          desc = "Widgets",
        },
        {
          "<leader>de",
          function()
            require("dap").terminate()
          end,
          desc = "End the debug session",
        },
      }
    end,
  },
}

return ruby_config
