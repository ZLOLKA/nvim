local plugins_names = {
  "lualine",
  "Comment",
  "ibl",
  "gitsigns",
  "telescope",
  "nvim-tree",
  "nvim-treesitter.configs",
  "neodev",
  "mason",
  "mason-lspconfig",
  "fidget",
  "cmp",
  "nvim-dap-projects",
  "vim-dadbod-ui",
  "winbar",
  "navic",
  "navbuddy",
}
for _, plugin_name in ipairs(plugins_names) do
  require("plugins_settings." .. plugin_name)
end
