return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    opts = {
      integrations = {
        snacks = true,
      },
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gm", "<cmd>Neogit<cr>", desc = "Open Neogit(magit-like)" },
    },
  },
}
