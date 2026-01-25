-- lazy.nvim Configuration --
require("config.lazy")
vim.keymap.set('n', '<leader>l', '<cmd>Lazy<cr>', { desc = 'Open lazy.nvim' })

-- lualine Configuration --
require('lualine').setup {
  options = {
	theme = 'tokyonight-night'
	},
}

-- copy paste --
vim.opt.clipboard = "unnamedplus"

-- Keymaps --
-- Use black hole register for 'x' so it doesn't overwrite clipboard
vim.keymap.set('n', 'x', '"_x')
-- Paste over selection without overwriting clipboard with the deleted text
vim.keymap.set('x', 'p', '"_dP')

vim.cmd.colorscheme 'tokyonight'
vim.opt.nu = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
