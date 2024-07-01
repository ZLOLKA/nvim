local keymaps = require('keymaps')

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = {
    'c', 'cpp', 'cmake', 'lua', 'python', 'rust', 'vim', 'go', 'sql'
  },

  highlight = { enable = true },
  indent = { enable = true, disable = { 'python' } },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<c-backspace>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = keymaps.v.select_textobjects,
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = keymaps.n.goto_next_start,
      goto_next_end = keymaps.n.goto_next_end,
      goto_previous_start = keymaps.n.goto_previous_start,
      goto_previous_end = keymaps.n.goto_previous_end,
    },
    swap = {
      enable = true,
      swap_next = keymaps.n.swap_next,
      swap_previous = keymaps.n.swap_previous,
    },
  },
}

