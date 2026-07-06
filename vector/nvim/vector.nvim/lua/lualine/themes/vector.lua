-- vector lualine theme — mode colors follow the channel logic:
-- normal = cyan (the "active window" channel), insert = green, visual = pink,
-- replace = crimson, command = amber. Sections b/c sit on surface/grid layers.
local c = require("vector.palette")
local b, n = c.base, c.neon

local function mode(color)
  return {
    a = { fg = b.bg, bg = color, gui = "bold" },
    b = { fg = color, bg = b.grid },
    c = { fg = b.faint, bg = b.surface },
  }
end

local theme = {
  normal   = mode(n.cyan),
  insert   = mode(n.green),
  visual   = mode(n.pink),
  replace  = mode(n.crimson),
  command  = mode(n.amber),
  terminal = mode(n.violet),
  inactive = {
    a = { fg = b.dim, bg = b.surface },
    b = { fg = b.dim, bg = b.surface },
    c = { fg = b.dim, bg = b.surface },
  },
}
return theme
