return {
  'dracula/vim',
  name = 'dracula',
  lazy = false,
  priority = 1000,
  config = function()
    vim.opt.termguicolors = true
    vim.cmd('colorscheme dracula')
  end
}
