local keymaps = require('keymaps')

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
  ansiblels = {},  -- Ansible
  bashls = {},  -- Bash
  buf_ls = {},  -- Protobuf
  dockerls = {},  -- Docker
  gitlab_ci_ls = {},  -- Gitlab CI
  jsonls = {  -- JSON
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
  ltex_plus = {},  -- LATEX
  lua_ls = {  -- Lua
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
  neocmake = {},  -- CMake
  pylsp = {},  -- Python
  sqlls = {},  -- SQL
  yamlls = {},  -- YAML
}

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

local servers_names = {}
for k, v in pairs(servers) do
    table.insert(servers_names, k)
    vim.lsp.config(k, {
        capabilities = capabilities,
        on_attach = keymaps.on_attach,
        settings = v,
    })
end

mason_lspconfig.setup {
  ensure_installed = servers_names,
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

