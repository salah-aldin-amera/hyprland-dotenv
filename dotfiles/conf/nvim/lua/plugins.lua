local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

-- Install your plugins here
return packer.startup(function(use)
	use ("wbthomason/packer.nvim") -- Have packer manage itself	

	use("nvim-lua/plenary.nvim") -- Lua functions that Telescope plugins use
	use("nvim-telescope/telescope.nvim")

	use {
	  'nvim-tree/nvim-tree.lua',
	  requires = {
	    'nvim-tree/nvim-web-devicons', -- optional
	  },
	}

	use ("folke/which-key.nvim")

    use {
        'neovim/nvim-lspconfig', -- LSP configuration
        'hrsh7th/nvim-cmp',      -- Completion plugin
        'hrsh7th/cmp-nvim-lsp',  -- LSP source for nvim-cmp
        'hrsh7th/cmp-buffer',    -- Buffer completion source
        'hrsh7th/cmp-path',      -- Path completion source
        'saadparwaiz1/cmp_luasnip', -- Snippet completion
        'L3MON4D3/LuaSnip',        -- Snippet engine
    }

	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)


