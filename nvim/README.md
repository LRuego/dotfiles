# Neovim Configuration

This directory contains the configuration for Neovim, managed using `lazy.nvim`.

## Installed Plugins

Below is a list of the plugins installed in this configuration, categorized by their function.

### Core Plugin Management

- **[lazy.nvim](https://github.com/folke/lazy.nvim)**: The plugin manager itself. Handles lazy-loading of all other plugins.

### UI & Appearance

- **[tokyonight.nvim](https://github.com/folke/tokyonight.nvim)**: The colorscheme.
- **[lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)**: A fast and easy-to-configure statusline.
- **[nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)**: Adds file-type icons to Neovim.
- **[which-key.nvim](https://github.com/folke/which-key.nvim)**: Displays a popup with possible keybindings.
- **[neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)**: A file explorer tree.

### Development & Code Intelligence

- **[mason.nvim](https://github.com/williamboman/mason.nvim)**: Manages LSP servers, DAP servers, linters, and formatters.
- **[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)**: Configurations for the Neovim Language Server Protocol client.
- **[nvim-cmp](https://github.com/hrsh7th/nvim-cmp)**: A completion engine for Neovim.
- **[LuaSnip](https://github.com/L3MON4D3/LuaSnip)**: A snippet engine.
- **[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)**: Provides advanced syntax highlighting, indentation, and more.

### Utility

- **[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)**: A highly extendable fuzzy finder.
- **[gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)**: Git integration for the sign column.

### Libraries & Dependencies

These plugins are required by other plugins to function correctly.

- `plenary.nvim`
- `nui.nvim`
- `mason-lspconfig.nvim`
- `cmp-nvim-lsp`
- `cmp-buffer`
- `cmp-path`
- `cmp_luasnip`
