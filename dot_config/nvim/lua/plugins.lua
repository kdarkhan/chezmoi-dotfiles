local function setup_options()
  -- Incremental live completion
  vim.o.inccommand = 'nosplit'
  vim.o.laststatus = 3

  vim.o.jumpoptions = 'stack'

  -- Set highlight on search
  vim.o.hlsearch = true

  vim.o.scrolloff = 2
  vim.o.cursorline = true

  vim.o.keymap = 'russian-jcukenwin'
  vim.o.iminsert = 0

  -- Make line numbers default
  vim.wo.number = true

  -- Do not save when switching buffers
  vim.o.hidden = true

  vim.o.guicursor = 'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,'
    .. 'a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,'
    .. 'sm:block-blinkwait175-blinkoff150-blinkon175'

  -- Enable mouse mode
  vim.o.mouse = 'a'

  -- Enable break indent
  vim.o.breakindent = true

  -- Save undo history
  vim.o.undofile = true

  vim.o.ignorecase = true
  vim.o.smartcase = true

  -- Default indents
  vim.o.shiftwidth = 2
  vim.o.tabstop = 2
  vim.o.expandtab = false
  vim.o.autoindent = true

  -- Decrease update time
  vim.o.updatetime = 250
  vim.wo.signcolumn = 'yes'

  vim.o.termguicolors = true

  vim.opt.listchars = { space = '·', tab = '▸ ' }
  -- Set completeopt to have a better completion experience
  vim.o.completeopt = 'menu,menuone,noselect'
end

local function setup_autocommands()
  vim.api.nvim_exec(
    [[
  augroup customColors
    autocmd!
    autocmd ColorScheme * highlight Normal guibg=NONE
    autocmd ColorScheme * if &ft != "neo-tree" | highlight ExtraWhitespace ctermbg=red guibg=red
    autocmd BufWinEnter * if &ft != "neo-tree" | match ExtraWhitespace /\s\+$/
    autocmd InsertEnter * if &ft != "neo-tree" | match ExtraWhitespace /\s\+\%#\@<!$/
    autocmd InsertLeave * if &ft != "neo-tree" | match ExtraWhitespace /\s\+$/
    autocmd BufWinLeave * if &ft != "neo-tree" | call clearmatches()
  augroup end

  augroup CustomStuff
    autocmd!
    " Highlight on YANK
    autocmd TextYankPost * silent! lua vim.highlight.on_yank { higroup="IncSearch", timeout=1500 }
    " Spell enable
    autocmd FileType markdown,gitcommit,hgcommit,python setlocal spell
    " Make genfiles readonly
    autocmd BufRead,BufNewFile,BufEnter */google3/blaze-genfiles/* let &readonly = 1 | let &modifiable = 0
    autocmd FileType python set colorcolumn=80


    " autocmd BufWritePost init.lua PackerCompile

    autocmd BufRead * let &l:modifiable = !&readonly
    autocmd BufReadPost * call setpos(".", getpos("'\""))
  augroup end
  ]],
    false
  )
end

local function setup_keymaps()
  -- Remap space as leader key
  vim.api.nvim_set_keymap(
    '',
    '<Space>',
    '<Nop>',
    { noremap = true, silent = true }
  )

  -- Remap for dealing with word wrap
  vim.api.nvim_set_keymap(
    'n',
    'k',
    "v:count == 0 ? 'gk' : 'k'",
    { noremap = true, expr = true, silent = true }
  )
  vim.api.nvim_set_keymap(
    'n',
    'j',
    "v:count == 0 ? 'gj' : 'j'",
    { noremap = true, expr = true, silent = true }
  )

  vim.api.nvim_set_keymap('n', '<leader>q', ':q!<CR>', { noremap = true })

  -- options
  vim.api.nvim_set_keymap(
    'n',
    '<leader>ow',
    ':set list!<CR>',
    { noremap = true, silent = true }
  )
  vim.api.nvim_set_keymap(
    'n',
    '<leader>ob',
    ':IndentBlanklineToggle<CR>',
    { noremap = true, silent = true }
  )

  -- files
  vim.api.nvim_set_keymap(
    'n',
    '<leader>ft',
    ':NeoTreeRevealToggle<CR>',
    { noremap = true, silent = true }
  )
  vim.api.nvim_set_keymap(
    'n',
    '<leader>ff',
    ':NeoTreeReveal<CR>',
    { noremap = true, silent = true }
  )
  vim.api.nvim_set_keymap(
    'n',
    '<leader>to',
    ':AerialToggle<CR>',
    { noremap = true, silent = true }
  )

  -- actions
  vim.api.nvim_set_keymap(
    'n',
    '<leader>aw',
    ':let _s=@/<Bar>:%s/\\s\\+$//e<Bar>:let @/=_s<Bar><CR>',
    { noremap = true }
  )
  vim.api.nvim_set_keymap(
    'n',
    '<leader>ac',
    ":let @+=expand('%:p')<CR>",
    { noremap = true }
  )
  vim.api.nvim_set_keymap(
    'n',
    '<leader>aj',
    ':%!python3 -m json.tool<CR>',
    { noremap = true }
  )
  vim.api.nvim_set_keymap('n', '<leader>am', ':make<CR>', { noremap = true })

  -- buffers
  vim.api.nvim_set_keymap('n', '<leader>bn', ':bnext<CR>', { noremap = true })
  vim.api.nvim_set_keymap('n', '<leader>bp', ':bprev<CR>', { noremap = true })
  vim.api.nvim_set_keymap('n', '<leader>bd', ':bdelete<CR>', { noremap = true })

  -- tabs
  vim.api.nvim_set_keymap('n', '<leader>tn', ':tabnext<CR>', { noremap = true })
  vim.api.nvim_set_keymap('n', '<leader>tp', ':tabprev<CR>', { noremap = true })
  vim.api.nvim_set_keymap('n', '<leader>tt', ':tabnew<CR>', { noremap = true })
  vim.api.nvim_set_keymap(
    'n',
    '<leader>tc',
    ':tabclose<CR>',
    { noremap = true }
  )

  -- Y yank until the end of line
  vim.api.nvim_set_keymap('n', 'Y', 'y$', { noremap = true })

  vim.api.nvim_set_keymap('x', '<Tab>', '>gv', { noremap = true })
  vim.api.nvim_set_keymap('x', '<S-Tab>', '<gv', { noremap = true })

  vim.api.nvim_set_keymap('v', 'gy', ':OSCYank<CR>', { noremap = true })
end

local function MyTelescopeConfig()
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  -- Telescope
  require('telescope').setup({
    defaults = {
      layout_strategy = 'vertical',
      selection_strategy = 'follow',
      -- path_display = opts.path_display,
      history = {
        path = '~/.local/share/nvim/telescope_history.sqlite3',
        limit = 100,
      },
      mappings = {
        i = {
          ['<C-Y>'] = function(prompt_bufnr)
            -- This helper copies the current line from the previewer below the cursor.
            -- Handy when searching for imports of Java identifiers
            local entry =
              require('telescope.actions.state').get_selected_entry()
            local picker = action_state.get_current_picker(prompt_bufnr)

            local line = nil

            if entry.lnum and picker.previewer then
              local bufnr = picker.previewer.state.bufnr
              line = vim.fn.getbufline(bufnr, entry.lnum)[1]
            end

            actions.close(prompt_bufnr)

            -- if line and vim.api.nvim_buf_get_option(0, 'modifiable') then
            --   vim.fn.append('.', line)
            -- end
            vim.fn.setreg('"', line, 'l')
          end,
          ['<C-Down>'] = require('telescope.actions').cycle_history_next,
          ['<C-Up>'] = require('telescope.actions').cycle_history_prev,
        },
      },
    },
    extensions = {
      fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
      },
    },
  })

  -- Add leader shortcuts
  vim.api.nvim_set_keymap('n', '<leader><leader>', '', {
    noremap = true,
    silent = true,
    callback = function()
      require('telescope.builtin').find_files({
        -- find_command = { 'rg', '--files', '-.', '--no-ignore', '-g', '!.git/' },
      })
    end,
  })

  vim.api.nvim_set_keymap('n', 'fg', '', {
    noremap = true,
    silent = true,
    callback = require('telescope.builtin').live_grep,
  })

  vim.api.nvim_set_keymap('n', '<leader>bb', '', {
    noremap = true,
    silent = true,
    callback = require('telescope.builtin').buffers,
  })
  vim.api.nvim_set_keymap('n', '<leader>fb', '', {
    noremap = true,
    silent = true,
    callback = require('telescope.builtin').current_buffer_fuzzy_find,
  })
  vim.api.nvim_set_keymap('n', '<leader>fh', '', {
    noremap = true,
    silent = true,
    callback = require('telescope.builtin').help_tags,
  })
  -- vim.api.nvim_set_keymap('n', '<leader>st', [[<cmd>lua require('telescope.builtin').tags()<CR>]], { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<leader>fs', '', {
    noremap = true,
    silent = true,
    callback = require('telescope.builtin').treesitter,
  })
  -- vim.api.nvim_set_keymap('n', '<leader>so', [[<cmd>lua require('telescope.builtin').tags{ only_current_buffer = true }<CR>]], { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<leader>fo', '', {
    noremap = true,
    silent = true,
    callback = require('telescope.builtin').oldfiles,
  })
end

local function get_telescope_plugins()
  return {
    {
      'nvim-telescope/telescope.nvim',
      dependencies = {
        { 'nvim-lua/popup.nvim' },
        { 'nvim-lua/plenary.nvim' },
      },
      -- TODO: workaround for upvalues not being propagated by Packer.use
      -- https://github.com/wbthomason/packer.nvim/issues/655
      -- https://github.com/wbthomason/packer.nvim/pull/402
      config = MyTelescopeConfig,
    },
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      config = function()
        require('telescope').load_extension('fzf')
      end,
    },
    {
      'nvim-telescope/telescope-smart-history.nvim',
      dependencies = 'kkharji/sqlite.lua',
      config = function()
        require('telescope').load_extension('smart_history')
      end,
    },
  }
end

function MyLspConfig(opts)
  opts = opts or {}
  local servers = opts.servers or {}
  -- local sumneko_root_path = opts.sumneko_root_path
  -- or '/usr/share/lua-language-server'
  -- local sumneko_binary = opts.sumneko_binary or 'lua-language-server'

  require('trouble').setup({})

  require('fidget').setup({})

  local lsp_signature = require('lsp_signature')

  local lspconfig = require('lspconfig')

  local aerial = require('aerial')

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(client, bufnr, attach_opts)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    lsp_signature.on_attach()

    local function buf_set_keymap(lhs, rhs, callback)
      vim.api.nvim_buf_set_keymap(
        bufnr,
        lhs,
        rhs,
        '',
        { noremap = true, silent = true, callback = callback }
      )
    end

    -- Mappings.
    -- local map_opts = { noremap = true, silent = true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap('n', 'gD', vim.lsp.buf.declaration)
    -- buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', map_opts)
    buf_set_keymap('n', 'gd', require('telescope.builtin').lsp_definitions)
    -- buf_set_keymap('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', map_opts)
    buf_set_keymap('n', 'gt', require('telescope.builtin').lsp_type_definitions)
    -- buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', map_opts)
    buf_set_keymap('n', 'gr', require('telescope.builtin').lsp_references)
    -- buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', map_opts)
    buf_set_keymap('n', 'gi', require('telescope.builtin').lsp_implementations)
    buf_set_keymap('n', 'K', vim.lsp.buf.hover)
    buf_set_keymap('n', '<C-k>', vim.lsp.buf.signature_help)
    buf_set_keymap('n', '<leader>lwa', vim.lsp.buf.add_workspace_folder)
    buf_set_keymap('n', '<leader>lwr', vim.lsp.buf.remove_workspace_folder)
    buf_set_keymap('n', '<leader>lwl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end)
    buf_set_keymap(
      'n',
      '<leader>lwd',
      require('telescope.builtin').lsp_workspace_diagnostics
    )
    buf_set_keymap('n', '<leader>lr', vim.lsp.buf.rename)
    -- buf_set_keymap('n', '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>', map_opts)
    buf_set_keymap(
      'n',
      '<leader>la',
      require('telescope.builtin').lsp_code_actions
    )
    buf_set_keymap(
      'n',
      '<leader>ls',
      require('telescope.builtin').lsp_workspace_symbols
    )
    buf_set_keymap('n', '<leader>ld', vim.lsp.diagnostic.show_line_diagnostics)
    buf_set_keymap('n', '<leader>lf', vim.lsp.buf.format({ async = true }))
    buf_set_keymap('n', 'gp', vim.lsp.diagnostic.goto_prev)
    buf_set_keymap('n', 'gn', vim.lsp.diagnostic.goto_next)

    -- buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', map_opts)
    vim.cmd(
      [[ command! Format execute 'lua vim.lsp.buf.format({ async = true })' ]]
    )
  end

  local rust_tools = require('rust-tools')
  rust_tools.setup({
    server = {
      on_attach = on_attach,
    },
  })

  -- null_ls setup
  -- local null_ls = require('null-ls')
  -- null_ls.setup({
  --   sources = {
  --     -- null_ls.builtins.diagnostics.cspell,
  --     null_ls.builtins.formatting.stylua,
  --   },
  --   debug = false,
  --   on_attach = on_attach,
  -- })

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

  -- Use a loop to conveniently call 'setup' on multiple servers and
  -- map buffer local keybindings when the language server attaches
  for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup({
      cmd = (lsp == 'clangd' and {
        'clangd',
        '--background-index',
        '-query-driver',
        '/usr/bin/avr-gcc,/usr/bin/arm-none-eabi-gcc',
      } or nil),
      on_attach = on_attach,
      capabilities = capabilities,
      flags = { debounce_text_changes = 150 },
    })
  end

  -- local path = vim.split(package.path, ';')
  -- local library = {}

  -- -- this is the ONLY correct way to setup your path
  -- table.insert(path, 'lua/?.lua')
  -- table.insert(path, 'lua/?/init.lua')

  -- local function add(lib)
  --   for _, p in pairs(vim.fn.expand(lib, false, true)) do
  --     p = vim.loop.fs_realpath(p)
  --     if p then
  --       library[p] = true
  --     end
  --   end
  -- end

  -- -- add runtime
  -- add('$VIMRUNTIME')

  -- -- add your config
  -- add('~/.config/nvim')

  -- -- add plugins
  -- -- if you're not using packer, then you might need to change the paths below
  -- add('~/.local/share/nvim/site/pack/packer/opt/*')
  -- add('~/.local/share/nvim/site/pack/packer/start/*')

  local runtime_path = vim.split(package.path, ';')
  table.insert(runtime_path, 'lua/?.lua')
  table.insert(runtime_path, 'lua/?/init.lua')

  require('lspconfig').sumneko_lua.setup({
    capabilities = capabilities,
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
          -- Setup your lua path
          path = runtime_path,
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { 'vim' },
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file('', true),
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    },
  })

  -- require('lspconfig').sumneko_lua.setup({
  --   on_new_config = function(config, root)
  --     local libs = vim.tbl_deep_extend('force', {}, library)
  --     libs[root] = nil
  --     config.settings.Lua.workspace.library = libs
  --     return config
  --   end,
  --   cmd = { sumneko_binary, '-E', sumneko_root_path .. '/main.lua' },
  --   on_attach = on_attach,
  --   capabilities = capabilities,
  --   flags = { debounce_text_changes = 150 },
  --   settings = {
  --     Lua = {
  --       runtime = {
  --         -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
  --         version = 'LuaJIT',
  --         -- Setup your lua path
  --         path = path,
  --       },
  --       diagnostics = {
  --         -- Get the language server to recognize the `vim` global
  --         globals = { 'vim' },
  --       },
  --       workspace = {
  --         -- Make the server aware of Neovim runtime files
  --         library = vim.api.nvim_get_runtime_file('', true),
  --       },
  --       -- Do not send telemetry data containing a randomized but unique identifier
  --       telemetry = { enable = false },
  --     },
  --   },
  -- })
end

local function get_lsp_plugins()
  return {
    {
      'neovim/nvim-lspconfig',
      dependencies = {
        'j-hui/fidget.nvim',
        'folke/trouble.nvim',
        'ray-x/lsp_signature.nvim',
        'simrat39/rust-tools.nvim',
        -- 'jose-elias-alvarez/null-ls.nvim',
      },
      -- after = 'aerial.nvim',
      -- TODO: workaround for upvalues not being propagated by Packer.use
      -- https://github.com/wbthomason/packer.nvim/issues/655
      -- https://github.com/wbthomason/packer.nvim/pull/402
      -- config = string.format('MyLspConfig(%s)', vim.inspect(opts)),
      config = MyLspConfig,
    },
  }
end

local function get_treesitter_plugins()
  return {
    {
      'nvim-treesitter/nvim-treesitter', -- Additional textobjects for treesitter
      dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
      },
      config = function()
        -- Treesitter configuration
        -- Parsers must be installed manually via :TSInstall
        require('nvim-treesitter.configs').setup({
          ensure_installed = {
            'c',
            'lua',
            'rust',
            'vim',
            'help',
            'markdown',
            'java',
            'css',
            'typescript',
            'yaml',
            'html',
            'sql',
          },
          highlight = {
            enable = true, -- false will disable the whole extension
          },
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = 'gss',
              node_incremental = 'gsi',
              scope_incremental = 'gsc',
              node_decremental = 'gsd',
            },
          },
          indent = { enable = false },
          textobjects = {
            select = {
              enable = true,
              lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
              keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@class.outer',
                ['ic'] = '@class.inner',
              },
            },
            move = {
              enable = true,
              set_jumps = true, -- whether to set jumps in the jumplist
              goto_next_start = {
                [']m'] = '@function.outer',
                [']]'] = '@class.outer',
              },
              goto_next_end = {
                [']M'] = '@function.outer',
                [']['] = '@class.outer',
              },
              goto_previous_start = {
                ['[m'] = '@function.outer',
                ['[['] = '@class.outer',
              },
              goto_previous_end = {
                ['[M'] = '@function.outer',
                ['[]'] = '@class.outer',
              },
            },
          },
          autotag = { enable = true },
        })
      end,
    },
    {
      'romgrk/nvim-treesitter-context',
      config = function()
        require('treesitter-context').setup()
      end,
      dependencies = { 'nvim-treesitter/nvim-treesitter' },
    },
  }
end

local function get_completion_plugins()
  -- Autocompletion and snippets
  return {
    {
      'hrsh7th/nvim-cmp',
      dependencies = {
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        'saadparwaiz1/cmp_luasnip',
        'windwp/nvim-autopairs',
        'L3MON4D3/LuaSnip',
      },
      config = function()
        local cmp = require('cmp')
        local luasnip = require('luasnip')
        local cmp_autopairs = require('nvim-autopairs.completion.cmp')

        local has_words_before = function()
          local line, col = unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0
            and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
                :sub(col, col)
                :match('%s')
              == nil
        end

        cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

        cmp.setup({
          snippet = {
            expand = function(args)
              require('luasnip').lsp_expand(args.body)
            end,
          },
          mapping = {
            ['<C-d>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.close(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            ['<Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              elseif has_words_before() then
                cmp.complete()
              else
                fallback()
              end
            end, { 'i', 's' }),

            ['<S-Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { 'i', 's' }),
          },
          sources = {
            { name = 'luasnip' },
            { name = 'nvim_lsp' },
            { name = 'buffer' },
            { name = 'path' },
          },
        })

        -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline('/', { sources = { { name = 'buffer' } } })

        -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline(':', {
          sources = cmp.config.sources(
            { { name = 'path' } },
            { { name = 'cmdline' } }
          ),
        })
      end,
    },
  }
end

local function MyStatuslineConfig(opts)
  opts = {
    options = { section_separators = '', component_separators = '' },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = {
        'branch',
        'diff',
        {
          'diagnostics',
          sources = { 'nvim_diagnostic' },
          always_visible = function()
            return vim.tbl_count(vim.lsp.buf_get_clients()) > 0
          end,
        },
      },
      lualine_c = { 'filename', 'lsp_progress' },
      lualine_x = { 'encoding', 'fileformat', 'filetype' },
      lualine_y = { 'progress' },
      lualine_z = { 'location' },
    },
  }

  require('lualine').setup(opts)
end

local function get_statusline_plugins()
  return {
    {
      'nvim-lualine/lualine.nvim',
      config = MyStatuslineConfig,
    },
  }
end

local function get_visual_tweak_plugins()
  return {
    {
      'rebelot/kanagawa.nvim',
      config = function()
        require('kanagawa').setup({})
        vim.cmd([[colorscheme kanagawa]])
      end,
      dependencies = { 'indent-blankline.nvim' },
      priority = 9000,
    },
    {
      'kyazdani42/nvim-web-devicons',
      config = function()
        require('nvim-web-devicons').setup()
      end,
    },
    {
      'lukas-reineke/indent-blankline.nvim',
      config = function()
        vim.api.nvim_exec(
          [[
          augroup IndentBlankline
            autocmd!
            autocmd ColorScheme * highlight IndentBlanklineIndent1 guifg=#E06C75 blend=nocombine
            autocmd ColorScheme * highlight IndentBlanklineIndent2 guifg=#E5C07B blend=nocombine
            autocmd ColorScheme * highlight IndentBlanklineIndent3 guifg=#98C379 blend=nocombine
            autocmd ColorScheme * highlight IndentBlanklineIndent4 guifg=#56B6C2 blend=nocombine
            autocmd ColorScheme * highlight IndentBlanklineIndent5 guifg=#61AFEF blend=nocombine
            autocmd ColorScheme * highlight IndentBlanklineIndent6 guifg=#C678DD blend=nocombine
          augroup end
          ]],
          false
        )

        require('indent_blankline').setup({
          space_char_blankline = ' ',
          use_treesitter = true,
          show_first_indent_level = false,
          filetype_exclude = { 'help', 'packer', 'terminal', 'neo-tree' },
          char_highlight_list = {
            'IndentBlanklineIndent1',
            'IndentBlanklineIndent2',
            'IndentBlanklineIndent3',
            'IndentBlanklineIndent4',
            'IndentBlanklineIndent5',
            'IndentBlanklineIndent6',
          },
        })
      end,
    },
    {
      'lewis6991/gitsigns.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
        require('gitsigns').setup({
          signs = {
            add = { text = '+' },
            change = { text = '~' },
            delete = { text = '_' },
            topdelete = { text = '‾' },
            changedelete = { text = '~' },
          },
        })
      end,
    },
    {
      'karb94/neoscroll.nvim',
      config = function()
        require('neoscroll').setup({
          eashing_function = 'sine',
          cursor_scroll_alone = true,
          stop_eof = true,
        })

        local neoscroll_conf = {}
        -- Syntax: t[keys] = {function, {function arguments}}
        neoscroll_conf['<C-u>'] = {
          'scroll',
          { '-vim.wo.scroll', 'true', '150' },
        }
        neoscroll_conf['<C-d>'] = {
          'scroll',
          { 'vim.wo.scroll', 'true', '150' },
        }
        neoscroll_conf['<C-b>'] = {
          'scroll',
          { '-vim.api.nvim_win_get_height(0)', 'true', '200' },
        }
        neoscroll_conf['<C-f>'] = {
          'scroll',
          { 'vim.api.nvim_win_get_height(0)', 'true', '200' },
        }
        neoscroll_conf['<C-y>'] = { 'scroll', { '-0.10', 'false', '50' } }
        neoscroll_conf['<C-e>'] = { 'scroll', { '0.10', 'false', '50' } }
        neoscroll_conf['zt'] = { 'zt', { '100' } }
        neoscroll_conf['zz'] = { 'zz', { '100' } }
        neoscroll_conf['zb'] = { 'zb', { '100' } }

        require('neoscroll.config').set_mappings(neoscroll_conf)
      end,
    },
  }
end

local function get_other_plugins()
  return {
    'windwp/nvim-ts-autotag',
    {
      'mg979/vim-visual-multi',
      config = function()
        vim.g['VM_leader'] = { default = '\\', visual = 'z', buffer = 'z' }
      end,
    },
    {
      'windwp/nvim-autopairs',
      config = function()
        require('nvim-autopairs').setup()
      end,
    },

    -- Trees
    {
      'nvim-neo-tree/neo-tree.nvim',
      branch = 'main',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'kyazdani42/nvim-web-devicons', -- not strictly required, but recommended
        'MunifTanjim/nui.nvim',
      },
      config = function()
        require('neo-tree').setup({
          popup_border_style = 'rounded',
          enable_git_status = true,
          enable_diagnostics = true,
          filesystem = {
            window = {
              position = 'left',
              width = 40,
              mappings = {
                ['<2-LeftMouse>'] = 'open',
                ['<cr>'] = 'open',
                ['S'] = 'open_split',
                ['s'] = 'open_vsplit',
                ['C'] = 'close_node',
                ['<bs>'] = 'navigate_up',
                ['.'] = 'set_root',
                ['H'] = 'toggle_hidden',
                ['I'] = 'toggle_gitignore',
                ['R'] = 'refresh',
                ['/'] = 'filter_as_you_type',
                ['f'] = 'filter_on_submit',
                ['<c-x>'] = 'clear_filter',
                ['a'] = 'add',
                ['d'] = 'delete',
                ['r'] = 'rename',
                ['c'] = 'copy_to_clipboard',
                ['x'] = 'cut_to_clipboard',
                ['p'] = 'paste_from_clipboard',
                ['bd'] = 'buffer_delete',
              },
            },
            follow_current_file = true,
          },
          buffers = {
            show_unloaded = true,
            window = {
              position = 'left',
              mappings = {
                ['<2-LeftMouse>'] = 'open',
                ['<cr>'] = 'open',
                ['S'] = 'open_split',
                ['s'] = 'open_vsplit',
                ['<bs>'] = 'navigate_up',
                ['.'] = 'set_root',
                ['R'] = 'refresh',
                ['a'] = 'add',
                ['d'] = 'delete',
                ['r'] = 'rename',
                ['c'] = 'copy_to_clipboard',
                ['x'] = 'cut_to_clipboard',
                ['p'] = 'paste_from_clipboard',
              },
            },
          },
          git_status = {
            window = {
              position = 'float',
              mappings = {
                ['<2-LeftMouse>'] = 'open',
                ['<cr>'] = 'open',
                ['S'] = 'open_split',
                ['s'] = 'open_vsplit',
                ['C'] = 'close_node',
                ['R'] = 'refresh',
                ['d'] = 'delete',
                ['r'] = 'rename',
                ['c'] = 'copy_to_clipboard',
                ['x'] = 'cut_to_clipboard',
                ['p'] = 'paste_from_clipboard',
                ['A'] = 'git_add_all',
                ['gu'] = 'git_unstage_file',
                ['ga'] = 'git_add_file',
                ['gr'] = 'git_revert_file',
                ['gc'] = 'git_commit',
                ['gp'] = 'git_push',
                ['gg'] = 'git_commit_and_push',
              },
            },
          },
        })
      end,
    },
    {
      'stevearc/aerial.nvim',
      config = function()
        require('aerial').setup()
      end,
    },
    {
      'L3MON4D3/LuaSnip',
      dependencies = { 'rafamadriz/friendly-snippets' },
      config = function()
        require('luasnip.loaders.from_vscode').lazy_load()
      end,
    },

    -- Tools
    'ojroques/vim-oscyank',
    'tpope/vim-commentary',
    -- 'tpope/vim-surround',
    {
      'kylechui/nvim-surround',
      config = function()
        require('nvim-surround').setup({})
      end,
    },
    'tpope/vim-sleuth',
    'justinmk/vim-sneak',

    {
      'folke/which-key.nvim',
      config = function()
        local wk = require('which-key')
        wk.register({
          f = { 'file' },
          a = { 'actions' },
          b = { 'buffers' },
          o = { 'options' },
          t = { 'tabs' },
          l = {
            name = 'lsp',
            w = { 'workspace' },
          },
        }, {
          prefix = '<leader>',
        })
        wk.setup({})
      end,
    },
  }
end

local function append_to_table(from, to)
  for _, plugin in ipairs(from) do
    table.insert(to, plugin)
  end
end

local function get_all_plugins()
  local plugins = {}

  append_to_table(get_completion_plugins(), plugins)
  append_to_table(get_treesitter_plugins(), plugins)
  append_to_table(get_telescope_plugins(), plugins)
  append_to_table(get_statusline_plugins(), plugins)
  append_to_table(get_visual_tweak_plugins(), plugins)
  append_to_table(get_lsp_plugins(), plugins)
  append_to_table(get_other_plugins(), plugins)

  return plugins
end

setup_options()
setup_autocommands()
setup_keymaps()

return get_all_plugins()
