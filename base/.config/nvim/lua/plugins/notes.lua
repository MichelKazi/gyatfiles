local Util = require("lazyvim.util")
local map = Util.safe_keymap_set
return {
  "RutaTang/quicknote.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  config = function()
    local quicknote = require("quicknote")
    local telescope = require("telescope")

    quicknote.setup({
      mode = "portable", -- "portable" | "resident", default to "portable"
      sign = "📝", -- This is used for the signs on the left side (refer to ShowNoteSigns() api).
      -- You can change it to whatever you want (eg. some nerd fonts icon), 'N' is default
      filetype = "md",
      git_branch_recognizable = true, -- If true, quicknote will separate notes by git branch
      -- But it should only be used with resident mode,  it has not effect used with portable mode
    })
    -- telescope
    telescope.setup({
      extensions = {
        quicknote = {
          defaultScope = "CWD",
        },
      },
    })

    telescope.load_extension("quicknote")

    -- keymaps
    map("n", "<leader>na", function()
      quicknote.NewNoteAtCurrentLine()
    end, { desc = "New note at current line" })
    map("n", "<leader>nA", function()
      quicknote.NewNoteAtGlobal()
    end, { desc = "New global note" })
    map("n", "<leader>nd", function()
      quicknote.DeleteNoteAtCurrentLine()
    end, { desc = "New global note" })
    map("n", "<leader>fn", ":Telescope quicknote [scope=cwd]<CR>", { desc = "Find notes [cwd]" })
    map("n", "<leader>fN", ":Telescope quicknote [scope=global]<CR>", { desc = "Find notes [Global]" })
  end,
}
