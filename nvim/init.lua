vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.number = true

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

-- fix terminal title --
vim.opt.title = true
vim.opt.titlestring = "%t %m - nvim"

-- Keymaps --

-- Use black hole register for 'x' so it doesn't overwrite clipboard
vim.keymap.set('n', 'x', '"_x')

-- Paste over selection without overwriting clipboard with the deleted text
vim.keymap.set('x', 'p', '"_dP')

-- Move line up/down (normal mode)
vim.keymap.set("n", "<a-j>", ":m .+1<cr>==")
vim.keymap.set("n", "<a-k>", ":m .-2<cr>==")

-- Indent/dedent line (normal mode)
vim.keymap.set("n", "<a-h>", "<<")
vim.keymap.set("n", "<a-l>", ">>")

-- Move selection up/down (visual mode)
vim.keymap.set("v", "<a-j>", ":m '>+1<cr>gv=gv")
vim.keymap.set("v", "<a-k>", ":m '<-2<cr>gv=gv")

-- Indent/dedent selection and reselect (visual mode)
vim.keymap.set("v", "<a-h>", "<gv")
vim.keymap.set("v", "<a-l>", ">gv")

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
