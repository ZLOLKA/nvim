local keymaps = require('keymaps')

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
  gopls = {},  -- Golang
  sqlls = {},  -- SQL
  bufls = {},  -- Protobuf
  neocmake = {},  -- CMake
  bashls = {},  -- Bash
  -- pyright = {},  -- Python
  -- rust_analyzer = {},  -- Rust
  -- tsserver = {},  -- TypeScript

  lua_ls = {  -- Lua
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

local lspconfig = require 'lspconfig'

local configs = require 'lspconfig.configs'

-- Check if the config is already defined (useful when reloading this file)
if not configs.clangd then
  configs.clangd = {
    default_config = {
      cmd = { 'clangd', '--log=verbose', },
      filetypes = { 'cpp', 'hpp', 'c', 'h', 'hxx', 'cxx' },
      root_dir = function(fname)
        return lspconfig.util.find_git_ancestor(fname)
      end,
    },
  }
end

lspconfig.clangd.setup {
  capabilities = capabilities,
  on_attach = keymaps.on_attach,
  settings = {
    maxNumberOfProblems = 100
  }
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = keymaps.on_attach,
      settings = servers[server_name],
    }
  end,
}

