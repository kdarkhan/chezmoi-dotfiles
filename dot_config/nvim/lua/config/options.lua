-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.clipboard = ""
vim.opt.relativenumber = false

vim.o.shell = "fish"

if vim.g.neovide then
  vim.o.guifont = "Iosevka Nerd Font Mono:h12"
  -- vim.o.guifont = "VictorMono NF:h10"
  vim.g.neovide_floating_blur_amount_y = 2.0
  vim.g.neovide_scroll_animation_length = 0.3
  vim.g.neovide_scroll_animation_far_lines = 10
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_cursor_trail_size = 0.8
  vim.g.neovide_cursor_vfx_mode = "pixiedust"

  -- Enable transparency
  vim.o.winblend = 20
  vim.o.pumblend = 20
  vim.api.nvim_set_hl(0, "PmenuSel", { blend = 0 })
else
  -- vim.g.clipboard = {
  --   name = "OSC 52",
  --   copy = {
  --     ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
  --     ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  --   },
  --   paste = {
  --     ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
  --     ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
  --   },
  -- }
end
