return {
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      {
        "folke/snacks.nvim",
        optional = true,
        opts = {
          picker = {
            input = {},
            actions = {
              opencode_send = function(...)
                return require("opencode").snacks_picker_send(...)
              end,
            },
            win = {
              input = {
                keys = {
                  ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
                },
              },
            },
          },
        },
      },
    },
    config = function()
      local opencode_cmd = "opencode --port"
      local snacks_terminal_opts = {
        win = {
          position = "right",
          enter = false,
        },
      }

      vim.g.opencode_opts = {
        server = {
          start = function()
            require("snacks.terminal").open(opencode_cmd, snacks_terminal_opts)
          end,
        },
      }
      --vim.o.autoread = true -- Required for `vim.g.opencode_opts.events.reload`
    end,
    keys = {
      {
        "<leader>oa",
        function()
          require("opencode").ask("@this: ")
        end,
        desc = "Ask OpenCode",
        mode = { "n", "x" },
      },
      {
        "<leader>os",
        function()
          require("opencode").select()
        end,
        desc = "Select to OpenCode",
        mode = { "n", "x" },
      },
      {
        "go",
        function()
          return require("opencode").operator("@this ")
        end,
        desc = "Add range to OpenCode",
        mode = { "n", "x" },
        expr = true,
      },
      {
        "gt",
        function()
          return require("opencode").operator("@this ") .. "_"
        end,
        desc = "Add line to OpenCode",
        mode = { "n", "x" },
        expr = true,
      },
      {
        "<leader>op",
        function()
          require("opencode").command("session.half.page.up")
        end,
        desc = "Scroll OpenCode up",
      },
      {
        "<leader>on",
        function()
          require("opencode").command("session.half.page.down")
        end,
        desc = "Scroll OpenCode down",
      },
    },
  },
}
