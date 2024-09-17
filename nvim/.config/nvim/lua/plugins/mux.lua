return {
  "mrjones2014/smart-splits.nvim",
  config = function()
    local Util = require("lazyvim.util")
    local map = Util.safe_keymap_set
    local splits = require("smart-splits")
    map("n", "<C-e>", function()
      splits.start_resize_mode()
    end)

    map("n", "<C-h>", function()
      splits.move_cursor_left()
    end)

    map("n", "<C-j>", function()
      splits.move_cursor_down()
    end)

    map("n", "<C-k>", function()
      splits.move_cursor_up()
    end)

    map("n", "<C-l>", function()
      splits.move_cursor_right()
    end)
  end,
}
