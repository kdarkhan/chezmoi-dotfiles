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
    opts = {
      scroll = { enabled = false },
    },
  },

  {
    "ibhagwan/fzf-lua",
    keys = {
      { "<leader>sG", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
      { "<leader>sg", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
      { "<leader>ff", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
      { "<leader>fF", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
      { "<leader><space>", LazyVim.pick("files", { root = false }), desc = "Find Files" },
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
}
