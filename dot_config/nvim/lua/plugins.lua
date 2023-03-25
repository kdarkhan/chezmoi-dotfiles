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

  if vim.g['neovide'] then
    vim.o.guifont = 'JetBrainsMonoNL Nerd Font Mono:h10'
    vim.g['neovide_cursor_vfx_mode'] = 'pixiedust'
  end
end

local function set_keymap_helper(lhs, rhs, opts, mode)
  if mode == nil then
    mode = 'n'
  end

  local actual_opts = {
    noremap = true,
    silent = true,
  }

  if type(rhs) == 'function' then
    actual_opts['callback'] = rhs
    rhs = ''
  elseif rhs == nil then
    rhs = ''
  end

  if opts ~= nil then
    actual_opts = vim.tbl_extend('force', actual_opts, opts)
  end

  vim.api.nvim_set_keymap(mode, lhs, rhs, actual_opts)
end

local function setup_autocommands()
  local trailing_group = vim.api.nvim_create_augroup('TrailingWhitespace', {})
  local define_hl_group = function()
    vim.api.nvim_set_hl(0, 'ExtraWhitespace', { ctermbg = 'red', bg = 'red' })
  end
  define_hl_group()
  vim.api.nvim_create_autocmd('ColorScheme', {
    pattern = '*',
    callback = define_hl_group,
    group = trailing_group,
  })
  vim.api.nvim_create_autocmd(
    { 'BufWinEnter', 'InsertEnter', 'InsertLeave', 'BufWinLeave' },
    {
      pattern = '*',
      callback = function(args)
        if
          vim.tbl_contains(
            { 'neo-tree', 'noice', 'TelescopePrompt', 'help' },
            vim.bo.filetype
          )
        then
          return
        end
        if args.event == 'BufWinEnter' or args.event == 'InsertLeave' then
          vim.fn.matchadd('ExtraWhitespace', [[\s\+$]])
        elseif args.event == 'InsertEnter' then
          vim.fn.clearmatches()
          vim.fn.matchadd('ExtraWhitespace', [[\s\+\%#\@<!$]])
        elseif args.event == 'BufWinLeave' then
          vim.fn.clearmatches()
        end
      end,
      group = trailing_group,
    }
  )

  local misc_group = vim.api.nvim_create_augroup('MiscGroup', {})
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'markdown,gitcommit,hgcommit',
    callback = function()
      vim.wo.spell = true
    end,
    group = misc_group,
  })
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'python',
    command = 'set colorcolumn=80',
    group = misc_group,
  })
  vim.api.nvim_create_autocmd('BufRead', {
    pattern = '*',
    command = 'let &l:modifiable = !&readonly',
    group = misc_group,
  })
  vim.api.nvim_create_autocmd('BufReadPost', {
    pattern = '*',
    callback = function()
      vim.fn.setpos('.', vim.fn.getpos('\'"'))
    end,
    group = misc_group,
  })
end

local function setup_keymaps()
  -- Remap space as leader key
  set_keymap_helper('<Space>', '<Nop>')

  -- Remap for dealing with word wrap
  set_keymap_helper('k', "v:count == 0 ? 'gk' : 'k'", { expr = true })
  set_keymap_helper('j', "v:count == 0 ? 'gj' : 'j'", { expr = true })

  set_keymap_helper('<leader>q', ':q!<CR>', { desc = 'Quit without saving' })

  -- options

  set_keymap_helper(
    '<leader>ow',
    ':set list!<CR>',
    { desc = 'Toggle visible whitespace' }
  )
  set_keymap_helper(
    '<leader>ob',
    ':IndentBlanklineToggle<CR>',
    { desc = 'Togggle IndentBlankLine' }
  )

  -- files
  set_keymap_helper(
    '<leader>ft',
    ':NeoTreeRevealToggle<CR>',
    { desc = 'NeoTree toggle' }
  )
  set_keymap_helper(
    '<leader>ff',
    ':NeoTreeReveal<CR>',
    { desc = 'NeoTree find' }
  )
  set_keymap_helper(
    '<leader>to',
    ':AerialToggle<CR>',
    { desc = 'Aerial toggle' }
  )

  -- actions
  set_keymap_helper(
    '<leader>aw',
    ':let _s=@/<Bar>:%s/\\s\\+$//e<Bar>:let @/=_s<Bar><CR>',
    { desc = 'Remove trailing whitespace' }
  )
  set_keymap_helper(
    '<leader>ac',
    ":let @+=expand('%:p')<CR>",
    { desc = 'Copy filename' }
  )
  set_keymap_helper(
    '<leader>aj',
    ':%!python3 -m json.tool<CR>',
    { desc = 'JSON format with python3' }
  )
  set_keymap_helper('<leader>am', ':make<CR>', { desc = 'Run make' })

  -- buffers
  set_keymap_helper('<leader>bn', ':bnext<CR>', { desc = 'Buffer next' })
  set_keymap_helper('<leader>bp', ':bprev<CR>', { desc = 'Buffer prev' })
  set_keymap_helper('<leader>bd', ':bdelete<CR>', { desc = 'Buffer delete' })

  -- tabs
  set_keymap_helper('<leader>tn', ':tabnext<CR>', { desc = 'Tab next' })
  set_keymap_helper('<leader>tp', ':tabprev<CR>', { desc = 'Tab prev' })
  set_keymap_helper('<leader>tt', ':tabnew<CR>', { desc = 'Tab new' })
  set_keymap_helper('<leader>tc', ':tabclose<CR>', { desc = 'Tab close' })

  -- Y yank until the end of line
  set_keymap_helper(
    'Y',
    'y$',
    { noremap = true, desc = 'Yank until the end of line' }
  )

  set_keymap_helper('<Tab>', '>gv', nil, 'x')
  set_keymap_helper('<S-Tab>', '<gv', nil, 'x')

  set_keymap_helper('gy', ':OSCYankVisual<CR>', nil, 'v')
end

local function visual_selection_range()
  local _, csrow, cscol, _ = unpack(vim.fn.getpos('v'))
  local _, cerow, cecol, _ = unpack(vim.fn.getcurpos())
  if csrow < cerow or (csrow == cerow and cscol <= cecol) then
    return csrow, cscol, cerow, cecol
  else
    return cerow, cecol, csrow, cscol
  end
end

local function get_visual_selection(separator)
  separator = separator or '\\n'
  local csrow, cscol, cerow, cecol = visual_selection_range()

  local lines = vim.api.nvim_buf_get_lines(
    vim.api.nvim_get_current_buf(),
    csrow - 1,
    cerow,
    false
  )
  if #lines == 1 then
    return string.sub(lines[1], cscol, cecol)
  elseif #lines > 1 then
    local result = { string.sub(lines[1], cscol) }
    for i = 2, #lines - 1, 1 do
      table.insert(result, lines[i])
    end
    table.insert(result, string.sub(lines[#lines], 1, cecol))
    return table.concat(result, separator)
  end
  return ''
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
  set_keymap_helper('<leader><leader>', function()
    require('telescope.builtin').find_files({
      -- find_command = { 'rg', '--files', '-.', '--no-ignore', '-g', '!.git/' },
    })
  end)

  set_keymap_helper('<leader>fg', require('telescope.builtin').live_grep)

  set_keymap_helper('<leader>fg', function()
    local text = get_visual_selection()
    require('telescope.builtin').live_grep({
      default_text = text,
    })
  end, nil, 'v')

  set_keymap_helper('<leader>fd', function()
    require('telescope.builtin').find_files({
      find_command = {
        'rg',
        '--no-ignore',
        '-L',
        '--hidden',
        '--files',
        vim.fn.expand('~/.config/nvim'),
      },
    })
  end)

  set_keymap_helper('<leader>bb', require('telescope.builtin').buffers)
  set_keymap_helper(
    '<leader>fb',
    require('telescope.builtin').current_buffer_fuzzy_find
  )
  set_keymap_helper('<leader>fh', require('telescope.builtin').help_tags)
  set_keymap_helper('<leader>fs', require('telescope.builtin').treesitter)
  set_keymap_helper('<leader>fo', require('telescope.builtin').oldfiles)
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

function MyLspOnAttach(_, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  require('lsp_signature').on_attach()

  local function buf_set_keymap_normal(lhs, callback, rhs)
    vim.api.nvim_buf_set_keymap(
      bufnr,
      'n',
      lhs,
      rhs or '',
      { noremap = true, silent = true, callback = callback }
    )
  end

  -- Mappings.

  buf_set_keymap_normal('gD', vim.lsp.buf.declaration)
  buf_set_keymap_normal('gd', require('telescope.builtin').lsp_definitions)
  buf_set_keymap_normal('gt', require('telescope.builtin').lsp_type_definitions)
  buf_set_keymap_normal('gr', require('telescope.builtin').lsp_references)
  buf_set_keymap_normal('gi', require('telescope.builtin').lsp_implementations)
  buf_set_keymap_normal('K', vim.lsp.buf.hover)
  buf_set_keymap_normal('<C-k>', vim.lsp.buf.signature_help)
  buf_set_keymap_normal('<leader>lwa', vim.lsp.buf.add_workspace_folder)
  buf_set_keymap_normal('<leader>lwr', vim.lsp.buf.remove_workspace_folder)
  buf_set_keymap_normal('<leader>lwl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end)
  buf_set_keymap_normal(
    '<leader>lwd',
    require('telescope.builtin').lsp_workspace_diagnostics
  )
  buf_set_keymap_normal('<leader>lr', vim.lsp.buf.rename)
  -- buf_set_keymap_normal('<leader>la', '', vim.lsp.buf.code_action)
  buf_set_keymap_normal('<leader>la', nil, ':CodeActionMenu<CR>')
  buf_set_keymap_normal(
    '<leader>ls',
    require('telescope.builtin').lsp_workspace_symbols
  )
  buf_set_keymap_normal('<leader>ld', vim.lsp.diagnostic.show_line_diagnostics)
  buf_set_keymap_normal('<leader>lf', vim.lsp.buf.format)
  buf_set_keymap_normal('gp', vim.lsp.diagnostic.goto_prev)
  buf_set_keymap_normal('gn', vim.lsp.diagnostic.goto_next)

  -- buf_set_keymap_helper('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', map_opts)
  vim.cmd([[
		command! Format execute 'lua vim.lsp.buf.format({ async = true })'
		augroup MyLspHold
						autocmd! * <buffer>
						autocmd CursorHold,CursorHoldI <buffer> lua require('nvim-lightbulb').update_lightbulb()
		augroup END
	]])
end

local function setup_lsp()
  local lsp_servers = { 'clangd', 'gopls' }

  require('trouble').setup({})

  require('fidget').setup({})

  local lspconfig = require('lspconfig')

  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  require('rust-tools').setup({
    server = {
      on_attach = MyLspOnAttach,
      capabilities = capabilities,
    },
  })

  local null_ls = require('null-ls')
  local null_ls_sources = {
    null_ls.builtins.completion.spell.with({
      filetypes = { 'markdown', 'gitcommit', 'hgcommit' },
    }),
  }
  if vim.fn.executable('cspell') == 1 then
    table.insert(
      null_ls_sources,
      null_ls.builtins.diagnostics.cspell.with({
        filetypes = { 'markdown', 'gitcommit', 'hgcommit' },
        extra_args = { '--config', vim.fn.expand('~/.config/cspell.json') },
      })
    )
  end

  if vim.fn.executable('stylua') == 1 then
    table.insert(null_ls_sources, null_ls.builtins.formatting.stylua)
  end

  null_ls.setup({
    sources = null_ls_sources,
    on_attach = MyLspOnAttach,
  })

  for _, lsp in ipairs(lsp_servers) do
    lspconfig[lsp].setup({
      cmd = (lsp == 'clangd' and {
        'clangd',
        '--background-index',
        '-query-driver',
        '/usr/bin/avr-gcc,/usr/bin/arm-none-eabi-gcc',
      } or nil),
      on_attach = MyLspOnAttach,
      capabilities = capabilities,
      flags = { debounce_text_changes = 150 },
    })
  end

  require('neodev').setup({})
  require('lspconfig').lua_ls.setup({
    capabilities = capabilities,
    on_attach = MyLspOnAttach,
    settings = {
      Lua = {
        workspace = {
          checkThirdParty = false,
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    },
  })
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
        'folke/neodev.nvim',
        'kosayoda/nvim-lightbulb',
        'hrsh7th/nvim-cmp',
        'jose-elias-alvarez/null-ls.nvim',
      },
      config = setup_lsp,
    },
    {
      'weilbith/nvim-code-action-menu',
      cmd = 'CodeActionMenu',
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
        require('nvim-treesitter.configs').setup({
          ensure_installed = {
            'bash',
            'c',
            'cpp',
            'css',
            'help',
            'html',
            'java',
            'json',
            'lua',
            'markdown',
            'markdown_inline',
            'proto',
            'python',
            'regex',
            'rust',
            'sql',
            'typescript',
            'vim',
            'yaml',
          },
          highlight = {
            enable = true, -- false will disable the whole extension
          },
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = '<CR>',
              node_incremental = '<CR>',
              scope_incremental = 'BS',
              node_decremental = '<S-CR>',
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
            swap = {
              enable = true,
              swap_next = {
                ['<leader>ss'] = '@parameter.inner',
              },
              swap_previous = {
                ['<leader>sS'] = '@parameter.inner',
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

local function get_statusline_plugins()
  return {
    {
      'nvim-lualine/lualine.nvim',
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
                return vim.tbl_count(vim.lsp.get_active_clients()) > 0
              end,
            },
          },
          lualine_c = { 'filename', 'lsp_progress' },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
      },
    },
  }
end

local function get_visual_tweak_plugins()
  return {
    {
      'rebelot/kanagawa.nvim',
      config = function()
        require('kanagawa').setup({
          overrides = function(colors)
            return {
              Visual = { bg = colors.palette.waveBlue2 },
            }
          end,
        })
        vim.cmd([[colorscheme kanagawa-wave]])
      end,
      dependencies = { 'indent-blankline.nvim' },
      priority = 9000,
    },
    {
      'nvim-tree/nvim-web-devicons',
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
      'karb94/neoscroll.nvim',
      enabled = false,
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
        'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
        'MunifTanjim/nui.nvim',
      },
      config = function()
        require('neo-tree').setup({
          popup_border_style = 'rounded',
          enable_git_status = true,
          enable_diagnostics = true,
          window = {
            width = 40,
          },
          filesystem = {
            window = {
              position = 'left',
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
        wk.setup({})

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

  append_to_table(get_treesitter_plugins(), plugins)
  append_to_table(get_telescope_plugins(), plugins)
  append_to_table(get_statusline_plugins(), plugins)
  append_to_table(get_visual_tweak_plugins(), plugins)
  append_to_table(get_lsp_plugins(), plugins)
  append_to_table(get_other_plugins(), plugins)

  return plugins
end

local function setup_filetypes()
  vim.filetype.add({
    pattern = {
      ['.*/waybar/config'] = 'jsonc',
    },
  })
end

setup_options()
setup_autocommands()
setup_keymaps()
setup_filetypes()

return get_all_plugins()
