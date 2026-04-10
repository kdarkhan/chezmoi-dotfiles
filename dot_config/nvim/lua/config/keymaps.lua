-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- vim.keymap.del("n", "L")
-- vim.keymap.del("n", "H")

-- vim.keymap.set("n", "gb", "<cmd>bnext<cr>", { desc = "Next Buffer" })
-- vim.keymap.set("n", "gB", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })

vim.keymap.set("n", "gI", "gi", { desc = "Go to last insert" })

vim.keymap.set({ "n", "x", "o" }, "<CR>", function()
  require("flash").treesitter()
end, { desc = "Flash Treesitter" })

require("which-key").add({ { "<leader>t", group = "test" } })

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

local function jira_picker()
  local jira_base_url = vim.fn.getenv("JIRA_BASE_URL")
  require("fzf-lua").fzf_exec(
    "acli jira workitem search"
      .. " --jql 'assignee = currentUser() AND statusCategory != Done'"
      .. " --fields 'key,summary'"
      .. " --csv"
      .. " --limit 100"
      .. " | tail -n +2"
      .. " | awk -F',' '{key=$1; sub(/^[^,]*,/,\"\"); printf \"%-15s %s\\n\", key, $0}'",
    {
      prompt = "Jira> ",
      actions = {
        ["default"] = function(selected)
          if not (selected and selected[1]) then
            return
          end
          local key = selected[1]:match("^(%S+)")
          if key and vim.bo.modifiable then
            vim.api.nvim_put({ key }, "c", true, true)
          end
        end,
        ["ctrl-y"] = function(selected)
          if not (selected and selected[1]) then
            return
          end
          local key = selected[1]:match("^(%S+)")
          if key then
            local url = jira_base_url .. "/browse/" .. key
            vim.fn.setreg("+", url)
            vim.notify("Copied: " .. url)
          end
        end,
        ["alt-enter"] = function(selected)
          if not (selected and selected[1]) then
            return
          end
          local key = selected[1]:match("^(%S+)")
          if key then
            vim.ui.open(jira_base_url .. "/browse/" .. key)
          end
        end,
      },
    }
  )
end

vim.keymap.set("n", "<leader>fj", jira_picker, { desc = "Jira issue picker" })

if vim.g.neovide then
  -- Linux
  vim.keymap.set("i", "<C-S-V>", "<C-R>+")

  -- MacOS
  local function paste()
    vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
  end
  vim.keymap.set({ "n", "i", "v", "c", "t" }, "<D-v>", paste, { silent = true, desc = "Paste" })

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
