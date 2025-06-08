-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- local disable_minipairs = function(args)
--   -- vim.b[args.buf].minipairs_disable = true
--   vim.b.minipairs_disable = true
-- end
-- vim.api.nvim_create_autocmd("Filetype", { pattern = "noice", callback = disable_minipairs })
-- vim.api.nvim_create_autocmd("MenuPopup", { callback = disable_minipairs })

-- Proto type does not support documentHighlight
-- vim.api.nvim_create_autocmd("Filetype", {
--   pattern = "proto",
--   callback = function(opts)
--     -- require("lazyvim.plugins.lsp.keymaps").get()["documentHighlight"] = false
--     local keys = require("lazyvim.plugins.lsp.keymaps").get()
--
--     keys[#keys + 1] = { "documentHighlight", false }
--   end,
-- })
-- autocmd TermOpen * setlocal scrollback=-1

vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    vim.opt_local.scrollback = 100000
  end,
})
