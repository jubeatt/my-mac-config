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

local placement_state = image_placement.state
if placement_state then
  image_placement.state = function(self)
    local state = placement_state(self)
    if self.opts.inline and state.loc.height == 1 then
      local terminal_size = Snacks.image.terminal.size()
      local image_size = Snacks.image.util.dim(self.img.file)
      local cell_ratio = terminal_size.cell_height / terminal_size.cell_width
      state.loc.width = math.max(1, math.floor(image_size.width / image_size.height * cell_ratio + 0.5))
    end
    return state
  end
end

local image_doc = require("snacks.image.doc")
image_doc.transforms.markdown_inline = function(img, ctx)
  if not (img.src and img.src:find("^data:image/svg%+xml;base64,")) then
    return
  end
  image_doc.transforms.data_img(img, ctx)
  -- Lucide previews share a base64 prefix, so the default content_id collides across icons.
  img.content_id = nil
  img.ext = "svg"
end
