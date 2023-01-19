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
			'onsails/lspkind.nvim',
		},
		config = function()
			local cmp = require('cmp')
			local luasnip = require('luasnip')
			local cmp_autopairs = require('nvim-autopairs.completion.cmp')

			local has_words_before = function()
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api
							.nvim_buf_get_lines(0, line - 1, line, true)[1]
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
				formatting = {
					format = require('lspkind').cmp_format({
						mode = 'symbol_text',
						menu = ({
							luasnip = "[SNP]",
							nvim_lsp = "[LSP]",
							buffer = "[BUF]",
							path = "[PTH]",
						}),
						maxwidth = 50,
						ellipsis_char = '…',
					}),
				}
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
