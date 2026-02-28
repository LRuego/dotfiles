return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
  },
  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local lspconfig = require("lspconfig")

    mason.setup()

    mason_lspconfig.setup({
      ensure_installed = { "pyright", "jsonls", "lua_ls", "sqlls" },
      handlers = {
        function(server_name)
          lspconfig[server_name].setup {}
        end,
      }
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "qml", "qmljs" },
      callback = function(ev)
        local root_dir = vim.fs.dirname(vim.fs.find({ ".git", "qmlls.ini" }, { upward = true, path = ev.file })[1])
        vim.lsp.start({
          name = "qmlls",
          cmd = { "qmlls6" },
          root_dir = root_dir,
        })
      end,
    })
  end,
}
