-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- disbale `q:`
vim.keymap.set("n", "\\", "q")
vim.keymap.set("n", "q", "<nop>", { noremap = true })
vim.keymap.set("n", "Q", "<nop>", { noremap = true })

-- not use ctrl-hjkl to navigate windows
vim.keymap.del("n", "<c-h>")
vim.keymap.del("n", "<c-j>")
vim.keymap.del("n", "<c-k>")
vim.keymap.del("n", "<c-l>")

-- blackhole register
vim.keymap.set("n", "_", '"_')

-- or <c-\\><c-n>
vim.keymap.set("i", "<c-g>", "<esc>", { remap = true })
vim.keymap.set("n", "<c-g>", "<esc>", { remap = true })
vim.keymap.set("t", "<c-g>", "<esc>", { remap = true })
