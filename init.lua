-- Neovim min version is 0.10.0

require('load_packages')

require('vim_options')

local keymaps = require('keymaps')

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

require('plugins_settings')

-- TODO: Configurate DAP
--
-- local dap = require('dap')
-- local dap_port = 13001
-- dap.adapters.codelldb = {
--   type = 'server',
--   -- host = '127.0.0.1',
--   port = dap_port,
--   executable = {
--     command = 'codelldb',
--     args = {'--port', dap_port},
--     detached = false,
--   },
-- }
-- dap.configurations.cpp = {
--   {
--     name = "Launch file",
--     type = "codelldb",
--     request = "launch",
--     program = function()
--       return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
--     end,
--     cwd = '${workspaceFolder}',
--     stopOnEntry = false,
--   },
-- }
-- dap.configurations.c = dap.configurations.cpp
-- dap.configurations.rust = dap.configurations.cpp

require("nvim-tree.api").tree.open()

