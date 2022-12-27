local function bootstrap_lazy()
  local use_dev = false

  if use_dev then
    vim.opt.runtimepath:prepend(vim.fn.expand('~/work/lazy.nvim'))
  else
    -- bootstrap from github
    local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
    if not vim.loop.fs_stat(lazypath) then
      print('Installing lazy because it is missing')

      vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        '--single-branch',
        'git@github.com:folke/lazy.nvim.git',
        lazypath,
      })
    end
    vim.opt.runtimepath:prepend(lazypath)
  end

  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '
  require('lazy').setup('plugins')
end

bootstrap_lazy()
