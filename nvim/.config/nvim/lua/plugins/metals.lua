-- Load LSP progress handler
require("config.lsp-progress")

local Util = require("lazyvim.util")
local map = Util.safe_keymap_set
local picker = require("snacks.picker")

-- ============================================================================
-- DAP Configuration for Scala
-- ============================================================================
local function setup_dap()
  local dap, dapui = require("dap"), require("dapui")

  -- Auto-open DAP UI on debug sessions
  dap.listeners.before.attach.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.launch.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated.dapui_config = function()
    -- Keep UI open after termination
  end
  dap.listeners.before.event_exited.dapui_config = function()
    -- Keep UI open after exit
  end

  -- Scala debug configurations
  dap.configurations.scala = {
    {
      type = "scala",
      request = "launch",
      name = "RunOrTest",
      metals = {
        runType = "runOrTestFile",
        jvmOptions = { "-J--illegal-access=permit" },
      },
    },
    {
      type = "scala",
      request = "launch",
      name = "Test Target",
      metals = {
        runType = "testTarget",
        jvmOptions = { "-J--illegal-access=permit" },
      },
    },
  }
end

-- ============================================================================
-- Keymaps
-- ============================================================================
local function setup_keymaps(bufnr)
  local telescope = require("telescope")
  local dap = require("dap")

  -- Metals Commands
  map("n", "<leader>me", function()
    telescope.extensions.metals.commands()
  end, { desc = "Metals commands" })

  map("n", "<leader>mr", function()
    require("metals").restart_metals()
  end, { desc = "Restart Metals" })

  map("n", "<leader>mA", function()
    require("metals").new_scala_file()
  end, { desc = "New Scala file" })

  map("n", "<leader>mss", function()
    require("metals").scan_sources()
  end, { desc = "Scan sources" })

  map("n", "<leader>md", function()
    local buf = vim.api.nvim_get_current_buf()
    local enabled = vim.diagnostic.is_enabled()
    vim.diagnostic.enable(not enabled, { bufnr = buf })
  end, { desc = "Toggle diagnostics" })

  -- Compilation
  map("n", "<leader>mcc", function()
    require("metals").compile_cascade()
  end, { desc = "Metals compile cascade" })

  map("n", "<leader>mcx", function()
    require("metals").compile_clean()
  end, { desc = "Metals compile clean" })

  -- Code Formatting & Actions
  map("n", "--", vim.lsp.buf.format, { desc = "Format with scalaFmt" })

  map("n", "==", function()
    require("metals").organize_imports()
  end, { desc = "Organize imports" })

  map("n", "<leader>mf", function()
    vim.lsp.buf.format()
    require("metals").run_scalafix()
  end, { desc = "Format and run scalafix" })

  map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

  -- Navigation
  map("n", "gD", picker.lsp_definitions, { desc = "Go to definition" })
  map("n", "gi", picker.lsp_implementations, { desc = "Go to implementation" })
  map("n", "gr", picker.lsp_references, { desc = "Go to references" })
  map("n", "gds", picker.lsp_symbols, { desc = "Go to document symbol" })
  map("n", "gws", picker.lsp_workspace_symbols, { desc = "Go to workspace symbol" })

  -- LSP Actions
  map("n", "K", vim.lsp.buf.hover, { desc = "Show hover" })
  map("n", "<leader>sh", vim.lsp.buf.signature_help, { desc = "Show signature help" })
  map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
  map("n", "<leader>cl", vim.lsp.codelens.run, { desc = "Run codelens" })

  -- Worksheets
  map("n", "<leader>ws", function()
    require("metals").hover_worksheet()
  end, { desc = "Hover worksheet" })

  -- Diagnostics
  map("n", "<leader>Da", vim.diagnostic.setqflist, { desc = "All workspace diagnostics" })
  map("n", "<leader>De", function()
    vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.E })
  end, { desc = "All workspace errors" })
  map("n", "<leader>Dw", function()
    vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.W })
  end, { desc = "All workspace warnings" })
  map("n", "<leader>D", vim.diagnostic.setloclist, { desc = "Buffer diagnostics only" })

  -- Debug Adapter Protocol (DAP)
  map("n", "<leader>mt", function()
    dap.run({
      type = "scala",
      request = "launch",
      name = "RunOrTest",
      metals = {
        runType = "runOrTestFile",
        jvmOptions = { "-J--illegal-access=permit" },
      },
    })
  end, { desc = "Run/Test current file" })

  map("n", "<leader>dc", function()
    require("dap").continue()
  end, { desc = "Continue debugging" })

  map("n", "<leader>dr", function()
    require("dap").repl.toggle()
  end, { desc = "Toggle REPL" })

  map("n", "<leader>dK", function()
    require("dap.ui.widgets").hover()
  end, { desc = "Hover widget" })

  map("n", "<leader>dt", function()
    require("dap").toggle_breakpoint()
  end, { desc = "Toggle breakpoint" })

  map("n", "<leader>dso", function()
    require("dap").step_over()
  end, { desc = "Step over" })

  map("n", "<leader>dsi", function()
    require("dap").step_into()
  end, { desc = "Step into" })

  map("n", "<leader>dl", function()
    require("dap").run_last()
  end, { desc = "Run last" })
end

-- ============================================================================
-- Plugin Configuration
-- ============================================================================
return {
  "scalameta/nvim-metals",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "folke/snacks.nvim",
      opts = {
        notifier = {
          enabled = true,
        },
      },
    },
    {
      "j-hui/fidget.nvim",
      enabled = false,
    },
    {
      "m00qek/baleia.nvim",
      version = "*",
      config = function()
        vim.g.baleia = require("baleia").setup({})

        -- Command to colorize the current buffer
        vim.api.nvim_create_user_command("BaleiaColorize", function()
          vim.g.baleia.once(vim.api.nvim_get_current_buf()) ---@diagnostic disable-line
        end, { bang = true })

        -- Auto-colorize DAP REPL output
        vim.api.nvim_create_autocmd("FileType", {
          desc = "Force colorize on dap-repl",
          pattern = "dap-repl",
          group = vim.api.nvim_create_augroup("auto_colorize", { clear = true }),
          callback = function()
            vim.g.baleia.automatically(vim.api.nvim_get_current_buf()) ---@diagnostic disable-line
          end,
        })

        -- Command to show logs
        vim.api.nvim_create_user_command("BaleiaLogs", vim.g.baleia.logger.show, { bang = true })
      end,
    },
    {
      "mfussenegger/nvim-dap",
      dependencies = {
        "rcarriga/nvim-dap-ui",
      },
      config = setup_dap,
    },
  },
  ft = { "scala", "sbt", "java" },
  opts = function()
    local metals_config = require("metals").bare_config()

    -- Metals Server Settings
    metals_config.settings = {
      showImplicitArguments = true,
      excludedPackages = {
        "akka.actor.typed.javadsl",
        "com.github.swagger.akka.javadsl",
      },
      javaHome = "/Users/mkazi/.sdkman/candidates/java/current",
      -- Fixed: JVM options should be separate strings
      ammoniteJvmProperties = {
        "--add-opens",
        "java.base/java.util.concurrent=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
      },
      -- Optimized for large projects like Strava's gauntlet
      serverProperties = { "-Xmx8G" },
    }

    -- Metals Init Options
    -- statusBarProvider "off" enables LSP progress notifications via snacks.nvim
    metals_config.init_options = {
      statusBarProvider = "off",
      disableColorOutput = false,
    }

    -- LSP Capabilities
    if package.loaded["blink.cmp"] then
      metals_config.capabilities = require("blink-cmp").get_lsp_capabilities()
    else
      metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()
    end

    -- On Attach Handler
    metals_config.on_attach = function(client, bufnr)
      require("metals").setup_dap()
      setup_keymaps(bufnr)
    end

    return metals_config
  end,
  config = function(self, metals_config)
    local metals = require("metals")
    local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "scala", "sbt" },
      callback = function()
        metals.initialize_or_attach(metals_config)
      end,
      group = nvim_metals_group,
    })
  end,
}
