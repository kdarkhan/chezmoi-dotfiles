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

local jira_done = false
local jira_role = "assignee"
local jira_base_url = vim.fn.getenv("JIRA_BASE_URL")

local function jira_picker()
  local jql = jira_role .. " = currentUser()"
  if not jira_done then
    jql = jql .. " AND statusCategory != Done"
  end
  jql = jql .. " ORDER BY updated DESC"

  local cmd = "acli jira workitem search --jql "
    .. vim.fn.shellescape(jql)
    .. " --fields key,summary --json --limit 100"
    .. [[ | jq -r '.[] | .key + "  " + .fields.summary']]

  local function get_key(selected)
    if not (selected and selected[1]) then
      return nil
    end
    return selected[1]:match("^(%S+)")
  end

  require("fzf-lua").fzf_exec(cmd, {
    prompt = string.format("[%s|%s] Jira> ", jira_role, jira_done and "all" or "open"),
    actions = {
      ["default"] = function(selected)
        local key = get_key(selected)
        if key and vim.bo.modifiable then
          vim.api.nvim_put({ key }, "c", true, true)
        end
      end,
      ["ctrl-y"] = function(selected)
        local key = get_key(selected)
        if key then
          local url = jira_base_url .. "/browse/" .. key
          vim.fn.setreg("+", url)
          vim.notify("Copied: " .. url)
        end
      end,
      ["alt-enter"] = function(selected)
        local key = get_key(selected)
        if key then
          vim.ui.open(jira_base_url .. "/browse/" .. key)
        end
      end,
      ["ctrl-d"] = function()
        jira_done = not jira_done
        vim.schedule(jira_picker)
      end,
      ["ctrl-r"] = function()
        jira_role = jira_role == "assignee" and "reporter" or "assignee"
        vim.schedule(jira_picker)
      end,
    },
  })
end

if jira_base_url ~= vim.NIL and jira_base_url ~= "" then
  vim.keymap.set("n", "<leader>fj", jira_picker, { desc = "Jira issue picker" })
end

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
