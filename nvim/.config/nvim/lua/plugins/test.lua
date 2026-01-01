return {
  "nvim-neotest/neotest",
  dependencies = {
    "haydenmeade/neotest-jest",
    "olimorris/neotest-rspec",
    { dir = "~/projects/neotest-metals" },
  },
  opts = function(_, opts)
    opts.adapters = opts.adapters or {}
    table.insert(opts.adapters, require("neotest-rspec"))
    table.insert(
      opts.adapters,
      require("neotest-metals")({
        runner = "sbt",
      })
    )

    -- Summary panel configuration
    opts.summary = opts.summary or {}
    opts.summary.mappings = {
      jumpto = "<CR>",
      expand = { "<Space>", "<2-LeftMouse>" },
      expand_all = "e",
      output = "o",
      short = "O",
      attach = "a",
      run = "r",
      mark = "m",
      run_marked = "R",
      clear_marked = "M",
      stop = "u",
      next_failed = "J",
      prev_failed = "K",
    }
  end,
}
