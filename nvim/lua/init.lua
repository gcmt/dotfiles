-- COMPLETION
----------------------------------------------------------------------------

local cmp_lsp = require("cmp_nvim_lsp")
local cmp = require("cmp")

cmp.setup({
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		["<TAB>"] = cmp.mapping.select_next_item(),
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
	}),
	sorting = {
		comparators = {
			cmp.config.compare.offset,
			cmp.config.compare.exact,
			cmp.config.compare.score,
			cmp.config.compare.recently_used,
			cmp.config.compare.locality,
			cmp.config.compare.kind,
			cmp.config.compare.sort_text,
			cmp.config.compare.length,
			cmp.config.compare.order,
		},
	},
})

-- DIAGNOSTICS
----------------------------------------------------------------------------

vim.diagnostic.config({
	float = {
		header = "",
		border = "single",
		source = false,
		focusable = false,
		suffix = function(diagnostic, i, total)
			local rv = diagnostic.source
			if diagnostic.code ~= nil and diagnostic.source ~= "Pyright" then
				rv = rv .. string.format(", %s", diagnostic.code)
			end
			return string.format(" (%s) ", rv), "Comment"
		end,
		prefix = function(diagnostic, i, total)
			if total > 1 then
				return "+ ", "Comment"
			else
				return " "
			end
		end,
		format = function(diagnostic)
			return string.format("%s", diagnostic.message)
		end,
	},
	virtual_text = false,
	update_in_insert = false,
	signs = true,
	underline = true,
})

diag_augroup = vim.api.nvim_create_augroup("UserDiagnostics", { clear = true })
vim.api.nvim_create_autocmd("DiagnosticChanged", {
	group = diag_augroup,
	callback = function(args)
		vim.diagnostic.setloclist({ open = false })
	end,
})
vim.api.nvim_create_autocmd("CursorHold", {
	group = diag_augroup,
	callback = function(args)
		vim.diagnostic.open_float()
	end,
})

vim.fn.sign_define("DiagnosticSignError", { text = "*", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "*", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "^", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "^", texthl = "DiagnosticSignHint" })

-- LSP CONFIG
----------------------------------------------------------------------------

-- https://github.com/neovim/nvim-lspconfig
local lspconfig = require("lspconfig")
local capabilities = cmp_lsp.default_capabilities()

lspconfig.gopls.setup({ capabilities = capabilities })
lspconfig.tsserver.setup({ capabilities = capabilities })
lspconfig.rust_analyzer.setup({ capabilities = capabilities })
lspconfig.pyright.setup({ capabilities = capabilities })
lspconfig.yamlls.setup({ capabilities = capabilities })

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>l", vim.diagnostic.setloclist)
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "<leader>D", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "<leader>d", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "<leader>i", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "<leader>k", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<leader>r", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "<leader>s", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<leader>t", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "<leader>c", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "<leader>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
	end,
})

-- TREESITTER
----------------------------------------------------------------------------

require("nvim-treesitter.configs").setup({
	ensure_installed = { "vim", "python", "go", "javascript", "rust", "yaml" },
	sync_install = false,
	ignore_install = { "" },
	highlight = {
		enable = false,
		disable = { "" },
		additional_vim_regex_highlighting = false,
	},
	indent = {
		enable = true,
		disable = { "" },
	},
})
