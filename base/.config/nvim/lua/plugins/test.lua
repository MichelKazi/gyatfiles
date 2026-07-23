local neotest_metals = vim.fn.expand("~/projects/neotest-metals")
local has_neotest_metals = vim.fn.isdirectory(neotest_metals) == 1

return {
  "nvim-neotest/neotest",
  dependencies = {
    "haydenmeade/neotest-jest",
    "olimorris/neotest-rspec",
    has_neotest_metals and { dir = neotest_metals } or nil,
  },
  opts = function(_, opts)
    opts.adapters = opts.adapters or {}
    table.insert(opts.adapters, require("neotest-rspec"))
    if has_neotest_metals then
      table.insert(
        opts.adapters,
        require("neotest-metals")({
          runner = "sbt",
        })
      )
    end

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
