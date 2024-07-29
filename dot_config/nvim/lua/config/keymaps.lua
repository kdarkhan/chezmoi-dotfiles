-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- vim.keymap.del("n", "L")
-- vim.keymap.del("n", "H")

-- vim.keymap.set("n", "gb", "<cmd>bnext<cr>", { desc = "Next Buffer" })
-- vim.keymap.set("n", "gB", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })

vim.keymap.set("n", "gh", "H", { desc = "Prev Buffer" })
vim.keymap.set("n", "gl", "L", { desc = "Next Buffer" })

vim.keymap.set("x", "<Tab>", ">gv")
vim.keymap.set("x", "<S-Tab>", "<gv")

vim.keymap.set("v", "gy", '"+y')

if vim.g.neovide then
  vim.keymap.set("i", "<C-S-V>", "<C-R>+")

  -- Change scale factor
  vim.g.neovide_scale_factor = 1.0
  local change_scale_factor = function(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
    -- vim.api.nvim__redraw({ valid = false })
  end
  vim.keymap.set("n", "<C-=>", function()
    change_scale_factor(1.15)
  end)
  vim.keymap.set("n", "<C-->", function()
    change_scale_factor(1 / 1.15)
  end)
end
