-- lazy.nvim Configuration --
require("config.lazy")
vim.keymap.set('n', '<leader>l', '<cmd>Lazy<cr>', { desc = 'Open lazy.nvim' })

-- lualine Configuration --
require('lualine').setup {
  options = {
	theme = 'tokyonight-night'
	},
}

vim.opt.cursorline = true

-- copy paste --
vim.opt.clipboard = "unnamedplus"

-- fix terminal title --
vim.opt.title = true
vim.opt.titlestring = "%t %m - nvim"

-- Keymaps --
-- Use black hole register for 'x' so it doesn't overwrite clipboard
vim.keymap.set('n', 'x', '"_x')
-- Paste over selection without overwriting clipboard with the deleted text
vim.keymap.set('x', 'p', '"_dP')

-- Toggle Diagnostics for current buffer
vim.keymap.set('n', '<leader>d', function()
  local enabled = vim.diagnostic.is_enabled({ bufnr = 0 })
  vim.diagnostic.enable(not enabled, { bufnr = 0 })
  print("Diagnostics: " .. (enabled and "OFF" or "ON"))
end, { desc = "Toggle Diagnostics (Buffer)" })

vim.cmd.colorscheme 'tokyonight'
vim.opt.nu = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
