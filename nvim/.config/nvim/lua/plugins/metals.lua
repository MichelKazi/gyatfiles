local Util = require("lazyvim.util")
local map = Util.safe_keymap_set
local picker = require("snacks.picker")

local function find_file_in_dir(dir, title)
  local builtin = require("telescope.builtin")
  local filename = vim.fn.expand("%:t:r")
  local search_term = dir .. filename
  builtin.find_files({ search_file = search_term, prompt_title = title })
end

---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
local progress = vim.defaulttable()
vim.api.nvim_create_autocmd("LspProgress", {
  ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
    if not client or type(value) ~= "table" then
      return
    end
    local p = progress[client.id]

    for i = 1, #p + 1 do
      if i == #p + 1 or p[i].token == ev.data.params.token then
        p[i] = {
          token = ev.data.params.token,
          msg = ("[%3d%%] %s%s"):format(
            value.kind == "end" and 100 or value.percentage or 100,
            value.title or "",
            value.message and (" **%s**"):format(value.message) or ""
          ),
          done = value.kind == "end",
        }
        break
      end
    end

    local msg = {} ---@type string[]
    progress[client.id] = vim.tbl_filter(function(v)
      return table.insert(msg, v.msg) or not v.done
    end, p)

    local spinner = { "🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘", "🌑", "🌒" }
    vim.notify(table.concat(msg, "\n"), "info", {
      id = "lsp_progress",
      title = client.name,
      opts = function(notif)
        notif.icon = #progress[client.id] == 0 and " "
          or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
      end,
    })
  end,
})

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
          vim.g.baleia.once(vim.api.nvim_get_current_buf())
        end, { bang = true })

        vim.api.nvim_create_autocmd("FileType", {
          desc = "Force colorize on dap-repl",
          pattern = "dap-repl",
          group = vim.api.nvim_create_augroup("auto_colorize", { clear = true }),
          callback = function()
            vim.g.baleia.automatically(vim.api.nvim_get_current_buf())
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
        "nvim-neotest/nvim-nio",
      },
      config = function(self, opts)
        -- Debug settings if you're using nvim-dap
        local dap, dapui = require("dap"), require("dapui")
        dap.listeners.before.attach.dapui_config = function()
          dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
          dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
          dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
          dapui.close()
        end

        dap.configurations.scala = {
          {
            type = "scala",
            request = "launch",
            name = "RunOrTest",
            metals = {
              runType = "runOrTestFile",
              jvmOptions = { "-J--illegal-access=permit" },
              --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
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
      end,
    },
  },
  ft = { "scala", "sbt", "java" },
  opts = function()
    local metals_config = require("metals").bare_config()

    metals_config.settings = {
      showImplicitArguments = true,
      excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
      javaHome = "/Users/mkazi/.sdkman/candidates/java/current",
      ammoniteJvmProperties = {
        " --add-opens java.base/java.util.concurrent=ALL-UNNAMED --add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.util=ALL-UNNAMED",
      },
      -- defaultBspToBuildTool = true,
    }

    -- *READ THIS*
    -- I *highly* recommend setting statusBarProvider to either "off" or "on"
    --
    -- "off" will enable LSP progress notifications by Metals and you'll need
    -- to ensure you have a plugin like fidget.nvim installed to handle them.
    --
    -- "on" will enable the custom Metals status extension and you *have* to have
    -- a have settings to capture this in your statusline or else you'll not see
    -- any messages from metals. There is more info in the help docs about this
    metals_config.init_options = {
      statusBarProvider = "off",
      disableColorOutput = false,
    }

    if package.loaded["blink.cmp"] then
      metals_config.capabilities = require("blink-cmp").get_lsp_capabilities()
    else
      metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()
    end

    metals_config.on_attach = function(client, bufnr)
      local telescope = require("telescope")

      map("n", "<leader>mt", function()
        find_file_in_dir("test", "Find Related Spec")
      end, { desc = "Find Related Spec" })

      map("n", "<leader>mm", function()
        find_file_in_dir("main", "Find Related Production File")
      end, { desc = "Find Production Files" })

      require("metals").setup_dap()

      map("n", "<leader>me", function()
        telescope.extensions.metals.commands()
      end, { desc = "Metals commands" })

      map("n", "gD", picker.lsp_definitions, { desc = "Go to definition" })

      map("n", "K", vim.lsp.buf.hover, { desc = "Show hover" })

      map("n", "gi", picker.lsp_implementations, { desc = "Go to implementation" })

      map("n", "gr", picker.lsp_references, { desc = "Go to references" })

      map("n", "gds", picker.lsp_symbols, { desc = "Go to document symbol" })

      map("n", "gws", picker.lsp_workspace_symbols, { desc = "Go to workspace symbol" })

      map("n", "<leader>cl", vim.lsp.codelens.run, { desc = "Run codelens" })

      map("n", "<leader>sh", vim.lsp.buf.signature_help, { desc = "Show signature help" })

      map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })

      map("n", "--", vim.lsp.buf.format, { desc = "Format with scalaFmt" })

      map("n", "<leader>mf", vim.lsp.buf.format, { desc = "Format with scalaFmt" })

      map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

      map("n", "<leader>mcc", function()
        require("metals").compile_cascade()
      end, { desc = "Metals compile cascade" })

      map("n", "<leader>mcx", function()
        require("metals").compile_clean()
      end, { desc = "Metals compile clean" })

      map("n", "<leader>mr", function()
        require("metals").restart_metals()
      end, { desc = "Restart Metals" })

      map("n", "<leader>mss", function()
        require("metals").scan_sources()
      end, { desc = "Scan sources" })

      map("n", "<leader>mA", function()
        require("metals").new_scala_file()
      end, { desc = "New Scala file" })

      map("n", "<leader>ws", function()
        require("metals").hover_worksheet()
      end, { desc = "Hover worksheet" })

      map("n", "<leader>Da", vim.diagnostic.setqflist, { desc = "All workspace diagnostics" })

      map("n", "<leader>De", function()
        vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.E })
      end, { desc = "All workspace errors" })

      map("n", "<leader>Dw", function()
        vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.W })
      end, { desc = "All workspace warnings" })

      map("n", "<leader>D", vim.diagnostic.setloclist, { desc = "Buffer diagnostics only" })

      map("n", "Dn", function()
        vim.diagnostic.goto_prev({ wrap = false })
      end, { desc = "Go to previous diagnostic" })

      map("n", "]c", function()
        vim.diagnostic.goto_next({ wrap = false })
      end, { desc = "Go to next diagnostic" })

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

      map("n", "<leader>md", function()
        local buf = vim.api.nvim_get_current_buf()
        local enabled = vim.diagnostic.is_enabled()
        vim.diagnostic.enable(not enabled, { bufnr = buf })
      end, { desc = "Toggle diagnostics" })
    end

    return metals_config
  end,
  config = function(self, metals_config)
    local metals = require("metals")
    local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "scala", "sbt", "thrift" },
      callback = function()
        metals.initialize_or_attach(metals_config)
      end,
      group = nvim_metals_group,
    })
  end,
}
