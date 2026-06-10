return {
  {
    "folke/snacks.nvim",
    opts = {
      animate = { enabled = true },
      bigfile = {
        notify = true,
        size = 1024 * 1024, -- 1M
        line_length = 1000,
      },
      explorer = {
        replace_netrw = true,
      },
      terminal = {
        win = {
          keys = {
            nav_h = false,
            nav_j = false,
            nav_k = false,
            nav_l = false,
          },
        },
      },
      picker = {
        win = {
          input = {
            keys = {
              ["<a-t>"] = { "trouble_open", mode = { "i", "n" } },
            },
          },
          list = {
            keys = {
              ["<a-t>"] = { "trouble_open", mode = { "i", "n" } },
            },
          },
        },
        sources = {
          explorer = {
            win = {
              list = {
                keys = {
                  ["a"] = { "explorer_add", desc = "add" },
                  ["d"] = { "explorer_del", desc = "delete" },
                  ["r"] = { "explorer_rename", desc = "rename" },
                  ["c"] = { "explorer_copy", desc = "copy" },
                  ["m"] = { "explorer_move", desc = "move" },
                  ["O"] = { "explorer_open", desc = "open by OS App" },
                  ["y"] = { "explorer_yank", mode = { "n", "x" }, desc = "yank" },
                  ["p"] = { "explorer_paste", desc = "paste" },
                  ["u"] = { "explorer_update", desc = "update" },
                  ["C"] = { "tcd", desc = "change dir" },
                  ["Z"] = { "explorer_close_all", desc = "fold all dirs" },
                  ["<Tab>"] = { "confirm", desc = "󰳽 confirm" },
                  ["<BS>"] = { "explorer_up", desc = " parent dir" },
                  ["]g"] = { "explorer_git_next", desc = "󰒭 next git" },
                  ["[g"] = { "explorer_git_prev", desc = "󰒮 prev git" },
                  ["]d"] = { "explorer_diagnostic_next", desc = "󰒭 next diagnostic" },
                  ["[d"] = { "explorer_diagnostic_prev", desc = "󰒮 prev diagnostic" },
                  ["]w"] = { "explorer_warn_next", desc = "󰒭 next warn" },
                  ["[w"] = { "explorer_warn_prev", desc = "󰒮 prev warn" },
                  ["]e"] = { "explorer_error_next", desc = "󰒭 next error" },
                  ["[e"] = { "explorer_error_prev", desc = "󰒮 prev error" },
                  ["<leader>/"] = { "picker_grep", desc = "󱁴 grep" },
                  -- disabled keys
                  -- https://github.com/folke/snacks.nvim/discussions/582
                  ["<C-/>"] = false, -- { "picker_grep", desc = "󱁴 grep" },
                  ["<C-C>"] = false, -- { "tcd" },
                  ["<S-C>"] = false,
                  ["P"] = false, -- { "toggle_preview", desc = "toggle preview" },
                  ["I"] = false, -- { "toggle_ignored", desc = "toggle ignored" },
                  ["H"] = false, -- { "toggle_hidden", desc = "toggle hidden" },
                  ["zb"] = false,
                  ["zt"] = false,
                  ["zz"] = false,
                  ["<c-a>"] = false, -- "select_all",
                  ["<c-s>"] = false, -- "edit_split",
                  ["<c-v>"] = false, -- "edit_vsplit",
                  ["<c-w>H"] = false, -- "layout_left",
                  ["<c-w>J"] = false, -- "layout_bottom",
                  ["<c-w>K"] = false, -- "layout_top",
                  ["<c-w>L"] = false, -- "layout_right",
                },
              },
            },
          },
        },
      },
    },
  },
}
