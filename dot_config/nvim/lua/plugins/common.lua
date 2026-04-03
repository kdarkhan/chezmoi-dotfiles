-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins

local path_aliases = {
  { "src/main/java/com/", "smjc/" },
  { "src/test/java/com/", "stjc/" },
}

-- `to` must be a self-contained string: it runs in a subprocess (multiprocess mode)
-- and cannot capture upvalues. We generate the gsub lines at config load time.
-- The function also puts the filename first (like path.filename_first) so that
-- truncation hides the parent directory rather than the filename.
local _to_lines = {}
for _, a in ipairs(path_aliases) do
  _to_lines[#_to_lines + 1] = ('  s = s:gsub("%s", "%s")'):format(a[1], a[2])
end
local fzf_fmt_to = string.format(
  [[
  return function(s, _, m)
    local _path = m.path
%s
    local tail = _path.tail(s)
    local parent = _path.parent(s)
    if parent then
      return tail .. "\t" .. _path.remove_trailing(parent)
    end
    return tail
  end
]],
  table.concat(_to_lines, "\n")
)

-- `from` runs in the main process, so a regular closure is fine.
-- It reverses the filename-first reorder, then reverses the path aliases.
local function fzf_fmt_from(s)
  -- fzf-lua prepends "<icon><nbsp>" to entries; strip everything up to the last nbsp
  -- (utils.nbsp is U+2002 EN SPACE, \xe2\x80\x82) so we get a clean path.
  local nbsp = "\xe2\x80\x82"
  local _, last_nbsp_end = s:find(".*" .. nbsp)
  if last_nbsp_end then
    s = s:sub(last_nbsp_end + 1)
  end
  -- Reverse filename-first reorder: "tail\tparent" -> "parent/tail"
  local tail, parent = s:match("^([^\t]+)\t(.+)$")
  if tail and parent then
    s = parent .. "/" .. tail
  end
  -- Reverse path aliases. Skip aliases with empty replacement — those are
  -- display-only transforms (e.g. extension stripping) that can't be reversed here.
  for _, a in ipairs(path_aliases) do
    s = s:gsub(a[2], a[1])
  end
  return s
end

return {
  -- Configure LazyVim to load theme
  -- {
  --   "LazyVim/LazyVim",
  --   opts = {
  --     -- colorscheme = "kanagawa-wave",
  --     -- colorscheme = "habamax",
  --     colorscheme = "everforest",
  --   },
  -- },
  -- LSP keymaps
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            { "gK", vim.diagnostic.open_float, desc = "Diagnostic float" },
            {
              "gp",
              function()
                vim.diagnostic.jump({ count = -1 })
              end,
              desc = "Diagnostic prev",
            },
            {
              "gn",
              function()
                vim.diagnostic.jump({ count = 1 })
              end,
              desc = "Diagnostic next",
            },
          },
        },
      },
    },
  },
  {
    "sainnhe/everforest",
    config = function()
      -- Optionally configure and load the colorscheme
      -- directly inside the plugin declaration.
      vim.g.everforest_enable_italic = true
      vim.g.everforest_background = "hard"
      vim.cmd.colorscheme("everforest")
    end,
  },

  -- { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

  -- change trouble config
  {
    "folke/trouble.nvim",
    -- opts will be merged with the parent spec
    opts = { use_diagnostic_signs = true },
  },

  -- add symbols-outline
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
    config = true,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        "bash",
        "go",
        "html",
        "java",
        "javascript",
        "json",
        "kotlin",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      })

      require("vim.treesitter.query").set(
        "markdown",
        "highlights",
        [[
        ;From MDeiml/tree-sitter-markdown
        [
          (fenced_code_block_delimiter)
        ] @punctuation.delimiter
        ]]
      )
    end,
  },

  -- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
  -- { import = "lazyvim.plugins.extras.lang.json" },

  -- add any tools you want to have installed below
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        -- "flake8",
        "shfmt",
        "gradle-language-server",
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      { "<leader>fe", false },
      { "<leader>fE", false },
      {
        "<leader>fE",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
        end,
        desc = "Explorer NeoTree (Root Dir)",
      },
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        markdown = { "mdformat" },
        java = { "google-java-format", lsp_format = "never" },
      },
    },
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration
      "nvim-mini/mini.pick", -- optional
      "folke/snacks.nvim", -- optional

      "neovim/nvim-lspconfig", -- To find git repo
    },
    config = true,
    keys = {
      {
        "<leader>ag",
        function()
          local root_finder = require("lspconfig.util").root_pattern(".git")
          local cur = vim.fn.resolve(vim.fn.expand("%:p"))
          local found = root_finder(cur)
          if found ~= nil then
            require("neogit").open({ cwd = found })
          else
            print("No git dir found for " .. cur)
          end
        end,
        desc = "Neogit",
      },
    },
  },
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        ghost_text = {
          enabled = true,
        },
      },
      keymap = {
        ["<C-j>"] = {
          function(cmp)
            cmp.select_next({ count = 10 })
          end,
        },
        ["<C-k>"] = {
          function(cmp)
            cmp.select_prev({ count = 10 })
          end,
        },
      },
    },
  },
  {
    "snacks.nvim",
    opts_not = {
      scroll = { enabled = false },
    },

    opts = function(_, opts)
      local keys = opts.dashboard and opts.dashboard.preset and opts.dashboard.preset.keys or {}
      opts.scroll.enabled = false
      for _, key in ipairs(keys) do
        if key.key == "c" then
          key.action = function()
            require("fzf-lua").files({
              cwd = vim.fn.stdpath("config"),
              follow = true,
            })
          end
          break
        end
      end
      return opts
    end,
  },
  {
    "ibhagwan/fzf-lua",
    opts = {
      formatters = {
        java_aliases = {
          to = fzf_fmt_to,
          from = fzf_fmt_from,
          enrich = function(o)
            o.fzf_opts = vim.tbl_extend("keep", o.fzf_opts or {}, { ["--tabstop"] = 1 })
            return o
          end,
        },
      },
      files = { formatter = "path.filename_first" },
      grep = {
        formatter = "path.filename_first",
        actions = {
          ["ctrl-y"] = function(selected, opts)
            local entry = require("fzf-lua").path.entry_to_file(selected[1], opts)
            if entry and entry.path and entry.line then
              local lines = vim.fn.readfile(entry.path)
              local text = lines[entry.line]
              if text then
                vim.fn.setreg("+", vim.trim(text))
              end
            end
          end,
        },
      },
      -- files = { formatter = "java_aliases" },
      -- grep = { formatter = "java_aliases" },
    },
    keys = {
      { "<leader>sG", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
      { "<leader>sg", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
      { "<leader>ff", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
      { "<leader>fF", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
      { "<leader><space>", LazyVim.pick("files", { root = false }), desc = "Find Files" },
      {
        "<leader>fc",
        LazyVim.pick("files", { cwd = vim.fn.stdpath("config"), follow = true }),
        desc = "Find Config File",
      },
      {
        "<leader>fC",
        LazyVim.pick("files", { cwd = vim.fn.stdpath("data") .. "/lazy", follow = true }),
        desc = "Find Plugin File",
      },
    },
  },
  {
    "brianhuster/unnest.nvim",
  },
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java", "groovy" },
    config = function()
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
      local workspace_dir = vim.fn.expand("~/work/jdtls-workspace/" .. project_name)
      -- local root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),
      -- local lsp_util = require('nvim_lsp').util;
      -- local root_dir = lsp_util.root_pattern('.git') or

      require("lspconfig").gradle_ls.setup({
        cmd_env = {
          JAVA_HOME = vim.fn.expand("~/.sdkman/candidates/java/17.0.13-zulu/"),
        },
      })
      vim.lsp.config("jdtls", {
        cmd = {
          vim.fn.expand("~/opt/jdtls/bin/jdtls"),
          "--java-executable",
          vim.fn.expand("~/.sdkman/candidates/java/21.0.9-zulu/bin/java"),
          "--jvm-arg=-javaagent:" .. vim.fn.expand("~/work/jdtls-workspace/lombok-1.18.44.jar"),
          "-data",
          workspace_dir,
        },
        root_markers = { ".git", "mvnw", "gradlew" },
        settings = {
          java = {
            configuration = {
              runtimes = {
                {
                  name = "JavaSE-11",
                  path = vim.fn.expand("~/.sdkman/candidates/java/11.0.18-zulu/"),
                },
                {
                  name = "JavaSE-17",
                  path = vim.fn.expand("~/.sdkman/candidates/java/17.0.13-zulu/"),
                },
              },
            },
          },
        },
      })
      vim.lsp.enable("jdtls")
    end,
  },
  -- {
  --   "folke/snacks.nvim",
  --   opts = function(_, opts)
  --     local keys = opts.dashboard and opts.dashboard.preset and opts.dashboard.preset.keys or {}
  --     for _, key in ipairs(keys) do
  --       if key.key == "c" then
  --         key.action = function()
  --           require("fzf-lua").files({
  --             cwd = vim.fn.stdpath("config"),
  --             fd_opts = "--color=never --type f --type l --hidden --follow --exclude .git",
  --           })
  --         end
  --         break
  --       end
  --     end
  --     return opts
  --   end,
  -- },
}
