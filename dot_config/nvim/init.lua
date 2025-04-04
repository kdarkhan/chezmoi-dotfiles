-- Do not start nvim inside nvim terminal
if os.getenv("NVIM") ~= nil then
  vim.cmd.quit()
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
