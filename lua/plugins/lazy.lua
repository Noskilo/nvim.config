-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out,                            "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000
	},
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.8',
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function()
			require('telescope').setup({
				defaults = {
					file_ignore_patterns = { 'node_modules', '.git', 'dist' },
				},
			})
		end
	},
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup {}
		end,
	},
	{ 'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons' },
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},
	{
		'terrortylor/nvim-comment',
		config = function()
			require("nvim_comment").setup({ creat_mappings = false })
		end
	},
	{
		'rmagatti/auto-session',
		config = function()
			require('auto-session').setup({
				auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
				session_lens = {
					buftypes_to_ignore = {},
					load_on_setup = true,
					theme_conf = { border = true },
					previewer = false,
				}
			})
		end
	},
	{
		'github/copilot.vim'
	},
	{
		{
			'VonHeikemen/lsp-zero.nvim',
			branch = 'v4.x',
			lazy = true,
			config = false,
		},
		{
			'williamboman/mason.nvim',
			lazy = false,
			opts = {},
		},

		-- Autocompletion
		{
			'hrsh7th/nvim-cmp',
			event = 'InsertEnter',
			config = function()
				local cmp = require('cmp')

				cmp.setup({
					sources = {
						{ name = 'nvim_lsp' },
					},
					mapping = cmp.mapping.preset.insert({
						['<C-.>'] = cmp.mapping.complete(),
						['<C-u>'] = cmp.mapping.scroll_docs(-4),
						['<C-d>'] = cmp.mapping.scroll_docs(4),
					}),
					snippet = {
						expand = function(args)
							vim.snippet.expand(args.body)
						end,
					},
				})
			end
		},

		-- LSP
		{
			'neovim/nvim-lspconfig',
			cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
			event = { 'BufReadPre', 'BufNewFile' },
			dependencies = {
				{ 'hrsh7th/cmp-nvim-lsp' },
				{ 'williamboman/mason.nvim' },
				{ 'williamboman/mason-lspconfig.nvim' },
			},
			init = function()
				-- Reserve a space in the gutter
				-- This will avoid an annoying layout shift in the screen
				vim.opt.signcolumn = 'yes'
			end,
			config = function()
				local lsp_defaults = require('lspconfig').util.default_config

				-- Add cmp_nvim_lsp capabilities settings to lspconfig
				-- This should be executed before you configure any language server
				lsp_defaults.capabilities = vim.tbl_deep_extend(
					'force',
					lsp_defaults.capabilities,
					require('cmp_nvim_lsp').default_capabilities()
				)

				-- LspAttach is where you enable features that only work
				-- if there is a language server active in the file
				vim.api.nvim_create_autocmd('LspAttach', {
					desc = 'LSP actions',
					callback = function(event)
						local opts = { buffer = event.buf }

						vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
						vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
						vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
						vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>',
							opts)
						vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>',
							opts)
						vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
						vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>',
							opts)
						vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
						vim.keymap.set({ 'n', 'x' }, '<F3>',
							'<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
						vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>',
							opts)
					end,
				})

				require('mason-lspconfig').setup({
					ensure_installed = {},
					handlers = {
						-- this first function is the "default handler"
						-- it applies to every language server without a "custom handler"
						function(server_name)
							require('lspconfig')[server_name].setup({})
						end,

						eslint = function()
							require('lspconfig').eslint.setup({
								root_dir =
								"/home/noskilo/development/transect/transect-nx",
							})
						end,

						ts_ls = function()
							require('lspconfig').ts_ls.setup({
								commands = {
									OrganizeImports = {
										function()
											vim.lsp.buf.execute_command(
												{
													command =
													"_typescript.organizeImports",
													arguments = { vim.api.nvim_buf_get_name(0) },
													title = "",
												})
										end,
										description = "Organize Imports",
									}
								}
							})
						end,

						angularls = function()
							require('lspconfig').angularls.setup({
								root_dir = require('lspconfig/util').root_pattern(
									"nx.json", ".git"),
								filetypes = { 'typescript', 'html' },
							})
						end,

						lua_ls = function()
							require('lspconfig').lua_ls.setup({
								settings = {
									Lua = {
										diagnostics = {
											-- Get the language server to recognize the `vim` global
											globals = { 'vim' },
										},
									},
								},
							})
						end,
					}
				})
			end
		}
	},
})
