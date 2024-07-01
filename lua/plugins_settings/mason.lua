-- Setup mason so it can manage external tooling
require('mason').setup({
  registries = {
    "github:mason-org/mason-registry",
    "lua:mason-registry.index"
  }
})

