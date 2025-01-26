require("plugins")

vim.o.background = "dark"
vim.cmd([[highlight Normal guibg=#000000C0]])
vim.opt.number = true
vim.opt.relativenumber = true


-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- empty setup using defaults
require("nvim-tree").setup()

-- OR setup with some options
require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})

vim.api.nvim_set_keymap("n", "<leader>t", ":echo 'Leader key works!'<CR>", { noremap = true, silent = true })

-- Configure Indentation
-- Set tabstop to 4 spaces
vim.opt.tabstop = 4
-- Set shiftwidth to 4 spaces (for indentation)
vim.opt.shiftwidth = 4
-- Set softtabstop to 4 (so pressing <Tab> inserts 4 spaces)
vim.opt.softtabstop = 4
-- Enable expanding tabs to spaces
vim.opt.expandtab = true
-- Enable smart tabbing (use tab or spaces intelligently)
vim.opt.smarttab = true


-- Configure Autocomplete
local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)  -- Use LuaSnip for snippets
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'luasnip' },
  },
})
