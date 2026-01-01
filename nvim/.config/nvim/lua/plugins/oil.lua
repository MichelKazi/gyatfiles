return {
  "stevearc/oil.nvim",
  opts = {
    delete_to_trash = true,
    keymaps = {
      ["<backspace>"] = { "actions.parent", mode = "n" },
    },
  },
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
}
