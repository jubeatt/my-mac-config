vim.pack.add({ "https://github.com/folke/snacks.nvim" })

require("snacks").setup({
  image = { enabled = true },
})

-- Images stay blank after switching buffers; drop once snacks.nvim PR #2635 is merged.
local image_placement = require("snacks.image.placement")
local placement_update = image_placement.update
image_placement.update = function(self)
  if self.hidden and self:ready() and #self:wins() > 0 then
    self.hidden = false
  end
  return placement_update(self)
end
