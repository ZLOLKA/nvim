local keymaps = require('keymaps')

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
  -- gopls = {},  -- Golang
  sqlls = {},  -- SQL
  buf_ls = {},  -- Protobuf
  neocmake = {},  -- CMake
  bashls = {},  -- Bash
  pylsp = {},  -- Python
  jsonls = {
    json = {
      format = {
        enable = 9 --true,
      },
      validate = { enable = true },
      trailingCommas = 'ignore',
      allowTrailingCommas = true,
      DocumentLanguageSettings = {
        trailingCommas = 'ignore',
        allowTrailingCommas = true,
      },
    }
    },
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
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

local lspconfig = require 'lspconfig'

local configs = require 'lspconfig.configs'

-- Check if the config is already defined (useful when reloading this file)
if not configs.clangd then
  local cmd = {
    'clangd',
    '--compile-commands-dir=./build',
    '--background-index',
    '--all-scopes-completion=true',
    '--completion-style=detailed',
    '--pch-storage=memory',
    '--enable-config',
    '--clang-tidy',
    '-j', '32',
  }

  configs.clangd = {
    default_config = {
      cmd = cmd,
      filetypes = { 'cpp', 'hpp', 'c', 'h', 'hxx', 'cxx' },
      root_dir = function(fname)
        return vim.fn.getcwd()
      end,
      single_file_support = false,
    },
  }
end

lspconfig.clangd.setup {
  capabilities = capabilities,
  on_attach = keymaps.on_attach,
  settings = {
    maxNumberOfProblems = 10000000
  },
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

