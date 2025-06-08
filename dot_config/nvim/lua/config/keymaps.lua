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

vim.keymap.set("n", "<leader>nl", function()
  require("noice").cmd("last")
end, { desc = "Noice last" })

vim.keymap.set("n", "<leader>na", function()
  require("noice").cmd("all")
end, { desc = "Noice all" })

vim.keymap.set("n", "<leader>nh", function()
  require("noice").cmd("history")
end, { desc = "Noice history" })

vim.keymap.set("n", "<leader>nh", function()
  require("noice").cmd("dismiss")
end, { desc = "Noice dismiss" })

vim.keymap.set("n", "<leader>aj", ":%!python -m json.tool<cr>", { desc = "Json format" })

vim.keymap.set("n", "<leader>ac", function()
  local root_finder = require("lspconfig.util").root_pattern(".git")
  local cur = vim.fn.resolve(vim.fn.expand("%:p"))
  local found = root_finder(cur)
  if found ~= nil then
    vim.fn.chdir(found)
    print("Moved to " .. found)
  else
    print("No git dir found for " .. cur)
  end
end, { desc = "Autocd to cur file" })

if vim.g.neovide then
  -- Linux
  vim.keymap.set("i", "<C-S-V>", "<C-R>+")

  -- MacOS
  vim.keymap.set("c", "<D-v>", "<C-R>+") -- Paste command mode
  vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli') -- Paste insert mode

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
else
  -- Disable tmux stuff
  vim.keymap.del("n", "<M-j>")
  vim.keymap.del("n", "<M-k>")
end

-- Make copy/paste work in Neovide
-- https://neovide.dev/faq.html#how-can-i-use-cmd-ccmd-v-to-copy-and-paste
vim.api.nvim_set_keymap("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })
