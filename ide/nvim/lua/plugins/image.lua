vim.pack.add({ "https://github.com/folke/snacks.nvim" })

require("snacks").setup({
  image = { enabled = true },
})

-- Herdr panes report 0 pixels in TIOCGWINSZ; use the cell size .zshrc queried.
local herdr_cell_width, herdr_cell_height = (vim.env.HERDR_CELL_SIZE or ""):match("^(%d+)x(%d+)$")
if herdr_cell_width then
  local image_terminal = require("snacks.image.terminal")
  local terminal_size = image_terminal.size
  image_terminal.size = function()
    local size = terminal_size()
    if size.cell_width == 0 then
      size.cell_width = tonumber(herdr_cell_width)
      size.cell_height = tonumber(herdr_cell_height)
      size.width = size.columns * size.cell_width
      size.height = size.rows * size.cell_height
      size.scale = math.max(1, size.cell_width / 8)
    end
    return size
  end
end

-- Images stay blank after switching buffers; drop once snacks.nvim PR #2635 is merged.
local image_placement = require("snacks.image.placement")
local placement_update = image_placement.update
image_placement.update = function(self)
  if self.hidden and self:ready() and #self:wins() > 0 then
    self.hidden = false
  end
  return placement_update(self)
end
