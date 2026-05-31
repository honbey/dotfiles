return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- https://github.com/astral-sh/ruff-lsp/issues/384#issuecomment-1941556771
      pyright = {
        settings = {
          pyright = {
            disableOrganizeImports = true, -- Using Ruff
          },
          python = {
            analysis = {
              typeCheckingMode = "standard", -- checking type
            },
          },
        },
      },
    },
  },
}
