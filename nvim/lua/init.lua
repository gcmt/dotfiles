P = function(v)
	print(vim.inspect(v))
	return v
end

-- COMPLETION
-- https://github.com/hrsh7th/nvim-cmp
----------------------------------------------------------------------------

local cmp_lsp = require("cmp_nvim_lsp")
local cmp = require("cmp")

cmp.setup({
	preselect = cmp.PreselectMode.None,
	window = {
		completion = cmp.config.window.bordered({ border = "single" }),
		documentation = cmp.config.window.bordered({ border = "single" }),
	},
	mapping = cmp.mapping.preset.insert({
		["<TAB>"] = cmp.mapping.select_next_item(),
		["<C-Space>"] = cmp.mapping.select_prev_item(),
		["<C-b>"] = cmp.mapping.scroll_docs(-3),
		["<C-f>"] = cmp.mapping.scroll_docs(3),
		["<C-a>"] = cmp.mapping.abort(),
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "nvim_lsp_signature_help" },
		{ name = "buffer", keyword_length = 2 },
		{ name = "path" },
	}),
	formatting = {
		fields = { "abbr", "kind", "menu" },
	},
	-- matching = {
	-- disallow_fuzzy_matching = true,
	-- disallow_fullfuzzy_matching = true,
	-- disallow_partial_fuzzy_matching = true,
	-- disallow_partial_matching = false,
	-- disallow_prefix_unmatching = true,
	-- },
	sorting = {
		comparators = {
			cmp.config.compare.exact,
			cmp.config.compare.offset,
			cmp.config.compare.score,
			cmp.config.compare.recently_used,
			cmp.config.compare.locality,
			cmp.config.compare.kind,
			cmp.config.compare.sort_text,
			cmp.config.compare.length,
			cmp.config.compare.order,
		},
	},
	performance = {
		debounce = 0,
		throttle = 0,
	},
})

-- DIAGNOSTICS
-- https://neovim.io/doc/user/diagnostic.html
----------------------------------------------------------------------------

vim.diagnostic.config({
	virtual_text = false,
	update_in_insert = false,
	signs = true,
	underline = true,
	float = {
		header = "",
		border = "single",
		source = false,
		focusable = false,
		format = function(diagnostic)
			local source = string.lower(diagnostic.source)
			local ret = string.format("[%s]", source)
			if diagnostic.code ~= nil and source ~= "pyright" then
				ret = string.format("%s %s:", ret, diagnostic.code)
			end
			return string.format("%s %s", ret, diagnostic.message)
		end,
		prefix = function(diagnostic, i, total)
			if total > 1 then
				return string.format("%s. ", i)
			end
			return ""
		end,
		suffix = "",
	},
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
		-- check if any floating window already exists
		for _, win in pairs(vim.api.nvim_tabpage_list_wins(0)) do
			if vim.api.nvim_win_get_config(win).zindex then
				return
			end
		end
		vim.diagnostic.open_float()
	end,
})

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>l", vim.diagnostic.setloclist)
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)

vim.fn.sign_define("DiagnosticSignError", { text = "✖", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "✖", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "✖", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "✖", texthl = "DiagnosticSignHint" })

-- LSP CONFIG
-- https://github.com/neovim/nvim-lspconfig
-- https://neovim.io/doc/user/lsp.html
----------------------------------------------------------------------------

local lspconfig = require("lspconfig")
local lsputil = require("lspconfig/util")

local lsp_servers = {
	gopls = {
		cmd = { "gopls" },
		filetypes = { "go", "gomod", "gowork", "gotmpl" },
		rootdir = lsputil.root_pattern("go.mod", "go.work", ".git"),
		settings = {
			gopls = {
				completeUnimported = true,
				usePlaceholders = false,
				analyses = {
					unusedparams = true,
				},
			},
		},
	},
	tsserver = {},
	eslint = {},
	tailwindcss = {},
	rust_analyzer = {},
	pyright = {},
	yamlls = {},
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())

for server, config in pairs(lsp_servers) do
	config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
	lspconfig[server].setup(config)
end

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(ev)
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "<leader>D", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "<leader>d", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "<leader>i", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "<leader>k", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gk", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<leader>r", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "<leader>s", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<leader>t", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "<leader>c", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "<leader>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
	end,
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "single",
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = "single",
})

vim.lsp.inlay_hint.enable()

-- TREESITTER
-- https://github.com/nvim-treesitter/nvim-treesitter
-- https://neovim.io/doc/user/treesitter.html
----------------------------------------------------------------------------

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"vim",
		"python",
		"go",
		"javascript",
		"typescript",
		"rust",
		"lua",
		"yaml",
		"markdown",
		"html",
		"sql",
	},
	sync_install = false,
	ignore_install = { "" },
	highlight = {
		enable = true,
		disable = { "" },
		additional_vim_regex_highlighting = false,
	},
	indent = {
		enable = true,
		disable = { "" },
	},
})
