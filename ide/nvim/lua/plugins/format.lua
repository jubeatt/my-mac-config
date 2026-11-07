vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

-- biome-check also applies safe lint fixes. Oxlint fixes stay off the save path: each
-- `oxlint --fix` run rebuilds the type-aware program and reloads JS plugins (~700 ms),
-- so run the project's lint fix instead.
-- LSP formatting stays off so tsc / jsonls never touch the file.
-- Filetypes follow the matching LSP configs; entries are added in priority order.
local formatters_by_ft = {}
for _, tool in ipairs({
  { formatter = "biome-check", server = "biome" },
  { formatter = "oxfmt", server = "oxfmt" },
}) do
  for _, ft in ipairs(vim.lsp.config[tool.server].filetypes) do
    formatters_by_ft[ft] = formatters_by_ft[ft] or {}
    table.insert(formatters_by_ft[ft], tool.formatter)
  end
end

require("conform").setup({
  formatters_by_ft = formatters_by_ft,
  -- Oxfmt picks the nearest .oxfmtrc.json, so a project without one gets ~/.oxfmtrc.json
  -- (linked from this repo).
  default_format_opts = { stop_after_first = true },
  formatters = {
    -- Biome runs only where the project has its config file.
    ["biome-check"] = { require_cwd = true },
  },
  format_on_save = { timeout_ms = 1000 },
  -- Most projects use only one of these tools, so silently skip the rest.
  notify_no_formatters = false,
})
