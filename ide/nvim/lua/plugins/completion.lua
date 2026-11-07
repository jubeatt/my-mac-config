vim.pack.add({
  "https://github.com/rafamadriz/friendly-snippets",
  -- Release tags ship a prebuilt fuzzy matcher binary.
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
})

-- The snippets source picks up friendly-snippets.
require("blink.cmp").setup({
  keymap = {
    preset = "super-tab",
    ["<CR>"] = { "accept", "fallback" },
  },
  completion = {
    documentation = { auto_show = true },
    -- Don't append "()" on accept; functions are often passed, not called.
    accept = { auto_brackets = { enabled = false } },
  },
  signature = { enabled = true },
  sources = {
    default = { "lsp", "snippets" },
    per_filetype = { lua = { inherit_defaults = true, "lazydev" } },
    providers = {
      lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
    },
  },
})
