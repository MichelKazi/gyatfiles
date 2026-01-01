return {
  "mrjones2014/smart-splits.nvim",
  event = "VeryLazy",
  keys = {
    { "<C-e>", function() require("smart-splits").start_resize_mode() end, desc = "Resize mode" },
    { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move left" },
    { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move down" },
    { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move up" },
    { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move right" },
  },
}
