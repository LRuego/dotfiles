-- nvim-treesitter `main` branch (master is frozen at Neovim 0.11 and breaks on 0.12).
-- Needs the tree-sitter CLI to build parsers: `pacman -S tree-sitter-cli`.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- main doesn't support lazy-loading
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install({
      "c", "lua", "vim", "vimdoc", "python", "javascript", "typescript",
      "json", "html", "css", "sql", "qmljs", "markdown", "markdown_inline",
    })

    -- Highlighting and indent are turned on per buffer now.
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        if not pcall(vim.treesitter.start, args.buf) then return end
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    -- Incremental selection is built into Neovim 0.12 (visual `an` grows, `in` shrinks); keep the old keys.
    vim.keymap.set("n", "<C-space>", "van", { remap = true, desc = "Select treesitter node" })
    vim.keymap.set("x", "<C-space>", "an", { remap = true, desc = "Grow selection to parent node" })
    vim.keymap.set("x", "<C-backspace>", "in", { remap = true, desc = "Shrink selection to child node" })
  end,
}
