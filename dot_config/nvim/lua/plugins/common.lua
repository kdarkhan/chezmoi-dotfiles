-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins

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
    "mason-org/mason-lspconfig.nvim",
    config = function()
      vim.lsp.config("gradle_ls", {
        cmd = { "gradle-language-server" },
        cmd_env = { JAVA_HOME = vim.fn.expand("~/.sdkman/candidates/java/17.0.13-zulu/") },
        init_options = {
          settings = {
            gradleWrapperEnabled = true,
            gradle = {
              nestedProjects = true,
            },
            ["gradle.nestedProjects"] = true,
            ["java.gradle.buildServer.enabled"] = true,
          },
        },
      })
      vim.lsp.enable("gradle_ls")
    end,
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
    opts = function(_, opts)
      require("fzf-lua").config.defaults.keymap.fzf["ctrl-a"] = "toggle-all"
      opts.lsp = vim.tbl_deep_extend("force", opts.lsp or {}, {
        formatter = "path.filename_first",
      })
      opts.oldfiles = vim.tbl_deep_extend("force", opts.oldfiles or {}, {
        formatter = "path.filename_first",
      })
      opts.files = vim.tbl_deep_extend("force", opts.files or {}, {
        formatter = "path.filename_first",
        actions = {
          ["ctrl-g"] = function(selected, opts)
            local paths = {}
            for _, s in ipairs(selected) do
              local entry = require("fzf-lua").path.entry_to_file(s, opts)
              if entry and entry.path then
                table.insert(paths, entry.path)
              end
            end
            if #paths > 0 then
              require("fzf-lua").live_grep({ search_paths = paths })
            end
          end,
        },
      })
      opts.grep = vim.tbl_deep_extend("force", opts.grep or {}, {
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
      })
      return opts
    end,
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
    keys = {
      {
        "<leader>ct",
        function()
          require("jdtls.tests").goto_subjects()
        end,
        desc = "Go to test/source",
      },
    },
    config = function()
      local extendedClientCapabilities = require("jdtls").extendedClientCapabilities
      extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
      extendedClientCapabilities.onCompletionItemSelectedCommand = "editor.action.triggerParameterHints"

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "java" },
        callback = function(ev)
          local root = vim.fs.root(ev.buf, { ".git", "mvnw", "gradlew" }) or vim.fn.getcwd()
          local workspace_dir = vim.fn.expand("~/work/jdtls-workspace/" .. vim.fn.fnamemodify(root, ":t"))
          vim.lsp.start({
            name = "jdtls",
            cmd = {
              "jdtls",
              "--java-executable",
              vim.fn.expand("~/.sdkman/candidates/java/21.0.9-zulu/bin/java"),
              "--jvm-arg=-javaagent:" .. vim.fn.expand("~/work/jdtls-workspace/lombok-1.18.44.jar"),
              "--add-modules=ALL-SYSTEM",
              "--add-opens",
              "java.base/java.util=ALL-UNNAMED",
              "--add-opens",
              "java.base/java.lang=ALL-UNNAMED",
              "-jar",
              "-data",
              workspace_dir,
            },
            root_dir = root,
            init_options = {
              extendedClientCapabilities = extendedClientCapabilities,
            },
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
                      default = true,
                    },
                  },
                },
              },
            },
          })
        end,
      })
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
