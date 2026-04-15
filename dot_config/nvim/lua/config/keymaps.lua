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

vim.keymap.set("n", "<leader>aj", function()
  if not vim.bo.modifiable then
    vim.notify("Buffer is not modifiable", vim.log.levels.ERROR)
    return
  end
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local input = table.concat(lines, "\n")
  local result = vim.fn.system("jq .", input)
  if vim.v.shell_error == 0 then
    local formatted = vim.split(result, "\n", { plain = true })
    -- jq output ends with a newline, remove the trailing empty string
    if formatted[#formatted] == "" then
      table.remove(formatted)
    end
    vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted)
  else
    vim.notify(result, vim.log.levels.ERROR)
  end
end, { desc = "Json format" })

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
      ["ctrl-s"] = function()
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

local _term_objects = {} -- buf -> snacks terminal object

-- Intercept all snacks terminal creation so the picker works for any terminal
vim.schedule(function()
  local orig_open = Snacks.terminal.open
  Snacks.terminal.open = function(cmd, opts)
    local term = orig_open(cmd, opts)
    if term and term.buf then
      _term_objects[term.buf] = term
    end
    return term
  end
end)

for i = 1, 4 do
  vim.keymap.set({ "n", "t" }, "<leader>" .. i, function()
    local term = Snacks.terminal(nil, { env = { TERM_NUM = tostring(i) } })
    if term and term.buf then
      vim.b[term.buf].term_leader_idx = i
    end
  end, { desc = "Terminal " .. i })
end

vim.keymap.set("n", "<leader>ft", function()

  local terms = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
      local title = vim.b[buf].term_title or ""
      local shell = vim.api.nvim_buf_get_name(buf):match(":([^:]+)$") or "?"
      local idx = vim.b[buf].term_leader_idx
      local idx_str = idx and ("[" .. idx .. "]") or "   "
      local label = string.format("%d\t%s %-6s %s", buf, idx_str, shell, title)
      table.insert(terms, { label = label, buf = buf })
    end
  end
  if #terms == 0 then
    vim.notify("No terminals open", vim.log.levels.INFO)
    return
  end
  require("fzf-lua").fzf_exec(
    vim.tbl_map(function(x) return x.label end, terms),
    {
      prompt = "Terminals> ",
      fzf_opts = { ["--no-sort"] = true },
      previewer = {
        _ctor = function()
          local p = require("fzf-lua.previewer.builtin").buffer_or_file:extend()
          function p:parse_entry(entry_str)
            local bufnr = tonumber(entry_str:match("^(%d+)\t"))
            if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
              return { bufnr = bufnr, terminal = true }
            end
            return {}
          end
          return p
        end,
      },
      actions = {
        ["default"] = function(selected)
          if not (selected and selected[1]) then return end
          local bufnr = tonumber(selected[1]:match("^(%d+)\t"))
          if not bufnr then return end
          local term_obj = _term_objects[bufnr]
          if term_obj and term_obj:buf_valid() then
            term_obj:show()
            term_obj:focus()
            vim.cmd("startinsert")
          end
        end,
      },
    }
  )
end, { desc = "Terminal picker" })

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
