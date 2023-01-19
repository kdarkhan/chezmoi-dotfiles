return {
  {
    'lewis6991/gitsigns.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('gitsigns').setup({
        linehl = true,
        numhl = true,
        diffopts = {
          internal = true,
        },
      })
      vim.api.nvim_set_keymap(
        'n',
        '<leader>og',
        ':Gitsigns toggle_current_line_blame<CR>',
        { noremap = true, silent = true, desc = 'Toggle git blame' }
      )
    end,
  },
  {
    'mhinz/vim-signify',
    config = function()
      vim.g.signify_skip = { vcs = { allow = { 'hg' } } }
      -- replicate gitsigns.nvim highlighting
      vim.g.signify_sign_add = '┃' -- default '+'
      vim.g.signify_sign_delete = '▁' -- default = '_'
      vim.g.signify_sign_delete_first_line = '▔' -- default '‾'
      vim.g.signify_sign_change = '┃' -- default '!'
      -- vim.g.signify_sign_change_delete     = vim.g.signify_sign_change . vim.g.signify_sign_delete_first_line
      vim.api.nvim_set_hl(0, 'SignifySignAdd', { link = 'diffAdded' })
      vim.api.nvim_set_hl(0, 'SignifySignChange', { link = 'diffChanged' })
      vim.api.nvim_set_hl(
        0,
        'SignifySignChangeDelete',
        { link = 'SignifySingChange' }
      )
      vim.api.nvim_set_hl(0, 'SignifySignDelete', { link = 'diffRemoved' })
      vim.api.nvim_set_hl(
        0,
        'SignifySignDeleteFirstLine',
        { link = 'SignifySignDelete' }
      )
    end,
  },
}
