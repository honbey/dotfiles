return {
  {
    "mason-org/mason.nvim",
    opts = {
      registry_cache = {
        refresh = false,
      },
      ui = {
        check_outdated_packages_on_open = false,
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        taplo = {
          root_markers = { ".taplo.toml", "taplo.toml", ".git", "." },
        },
      },
    },
  },
}
