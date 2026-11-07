require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Each module adds its own plugins with vim.pack.add(), so later modules can rely on
-- earlier ones: ui sets up mini.icons and which-key for everything after it.
require("plugins.ui")
require("plugins.image")
require("plugins.treesitter")
require("plugins.editing")
require("plugins.windows")
require("plugins.files")
require("plugins.search")
require("plugins.git")
require("plugins.terminal")
require("plugins.test")
require("plugins.lsp")
require("plugins.lint")
-- Reads formatter filetypes from the nvim-lspconfig configs.
require("plugins.format")
require("plugins.completion")
