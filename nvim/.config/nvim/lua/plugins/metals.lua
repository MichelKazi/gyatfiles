-- =============================================================================
-- Keymaps
-- =============================================================================
local function setup_keymaps(bufnr)
  local Util = require("lazyvim.util")
  local map = Util.safe_keymap_set
  local picker = require("snacks.picker")
  local util = require("util")
  local opts = { buffer = bufnr }

  -- Metals Commands (under <leader>m)
  map("n", "<leader>me", function()
    require("telescope").extensions.metals.commands()
  end, vim.tbl_extend("force", opts, { desc = "Metals commands" }))

  map("n", "<leader>mr", function()
    require("metals").restart_metals()
  end, vim.tbl_extend("force", opts, { desc = "Restart Metals" }))

  map("n", "<leader>mi", function()
    require("metals").info()
  end, vim.tbl_extend("force", opts, { desc = "Metals info" }))

  map("n", "<leader>mA", function()
    require("metals").new_scala_file()
  end, vim.tbl_extend("force", opts, { desc = "New Scala file" }))

  map("n", "<leader>mss", function()
    require("metals").scan_sources()
  end, vim.tbl_extend("force", opts, { desc = "Scan sources" }))

  map("n", "<leader>md", util.diagnostics.toggle, vim.tbl_extend("force", opts, { desc = "Toggle diagnostics" }))

  -- Compilation
  map("n", "<leader>mcc", function()
    require("metals").compile_cascade()
  end, vim.tbl_extend("force", opts, { desc = "Compile cascade" }))

  map("n", "<leader>mcx", function()
    require("metals").compile_clean()
  end, vim.tbl_extend("force", opts, { desc = "Compile clean" }))

  -- Code Formatting & Actions
  map("n", "--", vim.lsp.buf.format, vim.tbl_extend("force", opts, { desc = "Format" }))

  map("n", "==", function()
    require("metals").organize_imports()
  end, vim.tbl_extend("force", opts, { desc = "Organize imports" }))

  map("n", "<leader>mf", function()
    vim.lsp.buf.format()
    require("metals").run_scalafix()
  end, vim.tbl_extend("force", opts, { desc = "Format + scalafix" }))

  -- Navigation (using snacks picker)
  map("n", "gD", picker.lsp_definitions, vim.tbl_extend("force", opts, { desc = "Definition" }))
  map("n", "gi", picker.lsp_implementations, vim.tbl_extend("force", opts, { desc = "Implementation" }))
  map("n", "gr", picker.lsp_references, vim.tbl_extend("force", opts, { desc = "References" }))
  map("n", "gds", picker.lsp_symbols, vim.tbl_extend("force", opts, { desc = "Document symbols" }))
  map("n", "gws", picker.lsp_workspace_symbols, vim.tbl_extend("force", opts, { desc = "Workspace symbols" }))

  -- LSP Actions
  map("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover" }))
  map("n", "<leader>sh", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))
  map("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
  map("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
  map("n", "<leader>cl", vim.lsp.codelens.run, vim.tbl_extend("force", opts, { desc = "Run codelens" }))

  -- Worksheets
  map("n", "<leader>ws", function()
    require("metals").hover_worksheet()
  end, vim.tbl_extend("force", opts, { desc = "Hover worksheet" }))

  -- Diagnostics
  map("n", "<leader>Da", vim.diagnostic.setqflist, vim.tbl_extend("force", opts, { desc = "All diagnostics" }))
  map("n", "<leader>De", function()
    vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.E })
  end, vim.tbl_extend("force", opts, { desc = "Errors only" }))
  map("n", "<leader>Dw", function()
    vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.W })
  end, vim.tbl_extend("force", opts, { desc = "Warnings only" }))

  -- DAP keymaps (under <leader>d)
  local dap = require("dap")
  local dapui = require("dapui")

  map("n", "<leader>dt", function()
    require("metals").run_scalafix()
    dap.continue()
  end, vim.tbl_extend("force", opts, { desc = "Debug test/run" }))

  map("n", "<leader>dc", dap.continue, vim.tbl_extend("force", opts, { desc = "Continue" }))
  map("n", "<leader>db", dap.toggle_breakpoint, vim.tbl_extend("force", opts, { desc = "Toggle breakpoint" }))
  map("n", "<leader>dB", function()
    dap.set_breakpoint(vim.fn.input("Condition: "))
  end, vim.tbl_extend("force", opts, { desc = "Conditional breakpoint" }))
  map("n", "<leader>do", dap.step_over, vim.tbl_extend("force", opts, { desc = "Step over" }))
  map("n", "<leader>di", dap.step_into, vim.tbl_extend("force", opts, { desc = "Step into" }))
  map("n", "<leader>du", dap.step_out, vim.tbl_extend("force", opts, { desc = "Step out" }))
  map("n", "<leader>dr", dap.repl.toggle, vim.tbl_extend("force", opts, { desc = "Toggle REPL" }))
  map("n", "<leader>dl", dap.run_last, vim.tbl_extend("force", opts, { desc = "Run last" }))
  map("n", "<leader>dx", dap.terminate, vim.tbl_extend("force", opts, { desc = "Terminate" }))
  map("n", "<leader>dU", dapui.toggle, vim.tbl_extend("force", opts, { desc = "Toggle DAP UI" }))
  map("n", "<leader>de", dapui.eval, vim.tbl_extend("force", opts, { desc = "Eval under cursor" }))
  map("v", "<leader>de", dapui.eval, vim.tbl_extend("force", opts, { desc = "Eval selection" }))
end

-- =============================================================================
-- Plugin Configuration
-- =============================================================================
return {
  "scalameta/nvim-metals",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "mfussenegger/nvim-dap",
      config = function()
        local dap = require("dap")
        -- Scala debug configurations
        dap.configurations.scala = {
          {
            type = "scala",
            request = "launch",
            name = "Run or Test",
            metals = { runType = "runOrTestFile" },
          },
          {
            type = "scala",
            request = "launch",
            name = "Test Target",
            metals = { runType = "testTarget" },
          },
        }
      end,
    },
    {
      "rcarriga/nvim-dap-ui",
      dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
      config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        dapui.setup({
          controls = {
            element = "repl",
            enabled = true,
          },
          floating = {
            border = "rounded",
            mappings = { close = { "q", "<Esc>" } },
          },
          icons = {
            collapsed = "▸",
            current_frame = "→",
            expanded = "▾",
          },
          layouts = {
            {
              elements = {
                { id = "scopes", size = 0.5 },
                { id = "stacks", size = 0.25 },
                { id = "breakpoints", size = 0.25 },
              },
              size = 40,
              position = "left",
            },
            {
              elements = {
                { id = "repl", size = 1.0 },
              },
              size = 0.3,
              position = "bottom",
            },
          },
          render = {
            indent = 1,
            max_value_lines = 100,
          },
        })

        -- Only auto-open, never auto-close
        dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = nil
        dap.listeners.before.event_exited["dapui_config"] = nil
        dap.listeners.after.event_terminated["dapui_config"] = nil
        dap.listeners.after.event_exited["dapui_config"] = nil

        -- Set winbar labels for DAP UI panes
        vim.api.nvim_create_autocmd("BufWinEnter", {
          callback = function()
            local ft = vim.bo.filetype
            local labels = {
              dapui_scopes = " Scopes",
              dapui_stacks = " Stacks",
              dapui_breakpoints = " Breakpoints",
              dapui_watches = " Watches",
              dapui_console = " Console",
              ["dap-repl"] = " REPL",
            }
            if labels[ft] then
              vim.opt_local.winbar = labels[ft]
            end
          end,
        })
      end,
    },
    {
      "theHamsta/nvim-dap-virtual-text",
      dependencies = { "mfussenegger/nvim-dap" },
      opts = {
        commented = true,
        virt_text_pos = "eol",
      },
    },
    {
      "m00qek/baleia.nvim",
      version = "*",
      config = function()
        vim.g.baleia = require("baleia").setup({})
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "dap-repl",
          group = vim.api.nvim_create_augroup("auto_colorize", { clear = true }),
          callback = function()
            vim.g.baleia.automatically(vim.api.nvim_get_current_buf())
          end,
        })
      end,
    },
  },
  ft = { "scala", "sbt", "java" },
  opts = function()
    local metals_config = require("metals").bare_config()

    metals_config.settings = {
      -- Performance: Show implicit arguments (useful but can be disabled if slow)
      showImplicitArguments = true,
      showImplicitConversionsAndClasses = false, -- Disable for performance
      showInferredType = true,

      -- Performance: Exclude packages from indexing
      excludedPackages = {
        "akka.actor.typed.javadsl",
        "com.github.swagger.akka.javadsl",
        "akka.stream.javadsl",
        "akka.http.javadsl",
      },

      -- Use sbt BSP directly (better for complex builds with codegen like thrift)
      fallbackScalaVersion = "2.13.12",

      -- JVM settings
      javaHome = "/Users/mkazi/.sdkman/candidates/java/current",
      serverProperties = {
        "-Xmx8G",
        "-XX:+UseG1GC",
        "-XX:+UseStringDeduplication",
      },

      -- Ammonite
      ammoniteJvmProperties = {
        "--add-opens", "java.base/java.util.concurrent=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
        "--add-opens", "java.base/java.util=ALL-UNNAMED",
      },

      -- Build settings for large projects with codegen (thrift, etc.)
      autoImportBuild = "all", -- Re-import when build changes (needed for codegen)
      defaultBspToBuildTool = true, -- Use sbt BSP directly, not Bloop
    }

    metals_config.init_options = {
      statusBarProvider = "off",
      disableColorOutput = false,
      compilerOptions = {
        snippetAutoIndent = false,
      },
    }

    -- Capabilities
    if package.loaded["blink.cmp"] then
      metals_config.capabilities = require("blink-cmp").get_lsp_capabilities()
    else
      metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()
    end

    metals_config.on_attach = function(client, bufnr)
      require("metals").setup_dap()
      setup_keymaps(bufnr)

      -- Performance: Disable semantic tokens if slow (uncomment if needed)
      -- client.server_capabilities.semanticTokensProvider = nil
    end

    return metals_config
  end,
  config = function(self, metals_config)
    local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "scala", "sbt" },
      callback = function()
        require("metals").initialize_or_attach(metals_config)
      end,
      group = nvim_metals_group,
    })
  end,
}
