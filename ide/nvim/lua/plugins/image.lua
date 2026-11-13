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

local function cache_svg(data)
  local ok, svg = pcall(vim.base64.decode, data)
  if not ok then
    return
  end
  local root = Snacks.image.config.cache
  local file = ("%s/%s.svg"):format(root, vim.fn.sha256(svg):sub(1, 16))
  if vim.fn.filereadable(file) == 0 then
    vim.fn.mkdir(root, "p")
    local fd = assert(io.open(file, "w"))
    fd:write(svg)
    fd:close()
  end
  return file
end

-- Concealed data URIs still take wrapped rows, and snacks skips images on lines not fully visible.
local open_floating_preview = vim.lsp.util.open_floating_preview
vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
  contents = vim.tbl_map(function(line)
    return (line:gsub("data:image/svg%+xml;base64,([%w+/=]+)", cache_svg))
  end, contents)
  return open_floating_preview(contents, syntax, opts)
end
