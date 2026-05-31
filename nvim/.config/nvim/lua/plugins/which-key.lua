return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        -- TODO too many keys to confuse me
        -- (^use) what is the Capital key do
        {
          "<leader>fb",
          function()
            Snacks.picker.buffers()
          end,
          desc = "Buffers (^all)",
        },
        {
          "<leader>fB",
          function()
            Snacks.picker.buffers({ hidden = true, nofile = true })
          end,
          desc = "Buffers (all)",
          hidden = true,
        },
        {
          "<leader>fe",
          function()
            Snacks.explorer({ cwd = LazyVim.root() })
          end,
          desc = "Explorer (root dir ^cwd)",
        },
        {
          "<leader>fE",
          function()
            Snacks.explorer()
          end,
          desc = "Explorer (root dir)",
          hidden = true,
        },
        { "<leader>ff", LazyVim.pick("files"), desc = "Find Files (^cwd)" },
        { "<leader>fF", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)", hidden = true },
        { "<leader>fr", LazyVim.pick("oldfiles"), desc = "Recent (^cwd)" },
        {
          "<leader>fR",
          function()
            Snacks.picker.recent({ filter = { cwd = true } })
          end,
          desc = "Recent (cwd)",
          hidden = true,
        },
        { "<leader>sg", LazyVim.pick("live_grep"), desc = "Grep (Root Dir) (^cwd)" },
        { "<leader>sG", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)", hidden = true },
        {
          "<leader>sw",
          LazyVim.pick("grep_word"),
          desc = "Visual selection or word (Root Dir) (^cwd)",
          mode = { "n", "x" },
        },
        {
          "<leader>sW",
          LazyVim.pick("grep_word", { root = false }),
          desc = "Visual selection or word (cwd)",
          mode = { "n", "x" },
          hidden = true,
        },
      },
    },
  },
}
