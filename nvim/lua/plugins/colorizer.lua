return {
  "NvChad/nvim-colorizer.lua",
  config = function()
    require("colorizer").setup({
      filetypes = { "*" }, -- Enable for all filetypes
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = true,
        RRGGBBAA = true,
        AARRGGBB = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        mode = "background",
        virtualtext = "■",
      },
    })
    
    -- Register keymaps
    vim.keymap.set("n", "<leader>ct", "<cmd>ColorizerToggle<cr>", { desc = "Toggle Colorizer" })
    vim.keymap.set("n", "<leader>cr", "<cmd>ColorizerReloadAllBuffers<cr>", { desc = "Reload Colorizer" })
  end,
}
