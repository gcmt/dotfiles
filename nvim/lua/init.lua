function P(v)
	print(vim.inspect(v))
	return v
end

local function with(module, fn, default)
	local ok, mod = pcall(require, module)
	if ok then
		return fn(mod)
	end
	return default
end

-- REGTEE
----------------------------------------------------------------------------

with("regtee", function(regtee)
	regtee.setup({})
end)

-- CMDFIX
----------------------------------------------------------------------------

with("cmdfix", function(cmdfix)
	cmdfix.setup({
		threshold = 1,
		aliases = { echo = "ehco" },
		ignore = { "Marks", "Buffers", "Jumps", "Bdelete" },
	})
end)

-- GLARE
----------------------------------------------------------------------------

with("glare", function(glare)
	glare.opt.verbosity = vim.log.levels.INFO
	glare.opt.heading.lines_above = 0
	glare.opt.image.icon_position = "left"
	glare.opt.link.icon_position = "left"
	glare.opt.wikilink.icon_position = "left"
end)

-- VESSEL
----------------------------------------------------------------------------

with("vessel", function(vessel)
	vessel.opt.highlight_on_jump = true
	vessel.opt.preview.position = "right"
	vessel.opt.window.max_height = 90

	vessel.opt.buffers.mappings.edit = { "l", "<2-leftmouse>" }
	vessel.opt.buffers.mappings.collapse_directory = { "h", "<rightmouse>" }
	vessel.opt.buffers.mappings.toggle_group = { "L" }
	vessel.opt.buffers.mappings.prev_group = { "<c-k>" }
	vessel.opt.buffers.mappings.next_group = { "<c-j>" }
	vessel.opt.buffers.mappings.pin_increment = { "<c-y>" }
	vessel.opt.buffers.mappings.pin_decrement = { "<c-u>" }
	vessel.opt.buffers.highlights.tree_root = "Magenta"

	vessel.opt.buffers = {
		tree_folder_icons = { " ", "󰉋 " },
		view = "tree",
		directories_first = false,
		wrap_around = false,
		bufname_align = "right",
		directory_handler = function(path, _)
			vim.cmd("Vifm " .. vim.fn.fnameescape(path))
		end,
	}

	local vessel_aug = vim.api.nvim_create_augroup("VesselCustom", { clear = true })
	vim.api.nvim_create_autocmd("User", {
		group = vessel_aug,
		pattern = "VesselBufferlistEnter",
		callback = function()
			vim.keymap.set("n", "b", function()
				local sel = vim.b.vessel.get_selected()
				local path = sel and vim.fs.dirname(sel.path) or vim.fn.getcwd()
				vim.b.vessel.close_window()
				vim.cmd("Vifm " .. vim.fn.fnameescape(path))
			end, { buffer = true })

			vim.keymap.set("n", "B", function()
				vim.b.vessel.close_window()
				vim.cmd("Vifm " .. vim.fn.fnameescape(vim.fn.getcwd()))
			end, { buffer = true })

			vim.keymap.set("n", "f", function()
				vim.b.vessel.close_window()
				vim.cmd("Vifm! " .. vim.fn.fnameescape(vim.fn.getcwd()))
			end, { buffer = true })
		end,
	})
end)

-- LUASNIP
-- https://github.com/L3MON4D3/LuaSnip
----------------------------------------------------------------------------

with("luasnip.loaders.from_snipmate", function(luasnip)
	luasnip.lazy_load()
end)

-- GITSIGNS
-- https://github.com/lewis6991/gitsigns.nvim
----------------------------------------------------------------------------

with("gitsigns", function(gitsigns)
	gitsigns.setup({
		signs = {
			add = { text = "+" },
			change = { text = "*" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "?" },
		},
		signs_staged = {
			add = { text = "+" },
			change = { text = "*" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "?" },
		},
	})
end)

-- DIFFVIEW
-- https://github.com/sindrets/diffview.nvim
----------------------------------------------------------------------------

with("diffview", function(diffview)
	diffview.setup({
		use_icons = false,
		show_help_hints = true,
	})
end)

-- COMPLETION
-- https://github.com/hrsh7th/nvim-cmp
----------------------------------------------------------------------------

with("cmp", function(cmp)
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
end)

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
			local source = string.lower(diagnostic.source or "")
			local ret = string.format("[%s]", source)
			if diagnostic.code ~= nil and source ~= "pyright" then
				ret = string.format("%s %s:", ret, diagnostic.code or -1)
			end
			return string.format("%s %s", ret, diagnostic.message or "")
		end,
		prefix = function(_, i, total)
			if total > 1 then
				-- second return value is highlighting
				return string.format("%s. ", i), ""
			end
			return "", ""
		end,
		suffix = "",
	},
})

local diag_augroup = vim.api.nvim_create_augroup("UserDiagnostics", { clear = true })
vim.api.nvim_create_autocmd("DiagnosticChanged", {
	group = diag_augroup,
	callback = function()
		vim.diagnostic.setloclist({ open = false })
	end,
})
vim.api.nvim_create_autocmd("CursorHold", {
	group = diag_augroup,
	callback = function()
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

vim.fn.sign_define("DiagnosticSignError", { text = "󰋼", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "󰋼", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "󰋼", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "󰋼", texthl = "DiagnosticSignHint" })

-- LSP CONFIG
-- https://github.com/neovim/nvim-lspconfig
-- https://neovim.io/doc/user/lsp.html
----------------------------------------------------------------------------

with("lspconfig", function(lspconfig)
	local lsp_servers = {
		gopls = {
			cmd = { "gopls" },
			filetypes = { "go", "gomod", "gowork", "gotmpl" },
			rootdir = require("lspconfig.util").root_pattern("go.mod", "go.work", ".git"),
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
		lua_ls = {
			on_init = function(client)
				client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
					runtime = {
						version = "LuaJIT",
					},
					workspace = {
						checkThirdParty = false,
						library = {
							vim.env.VIMRUNTIME,
						},
					},
				})
			end,
			settings = {
				Lua = {},
			},
		},
		ts_ls = {},
		eslint = {},
		tailwindcss = {},
		rust_analyzer = {},
		pyright = {},
		yamlls = {},
	}

	local capabilities = vim.tbl_deep_extend(
		"force",
		vim.lsp.protocol.make_client_capabilities(),
		with("cmp_lsp", function(cmp_lsp)
			return cmp_lsp.default_capabilities()
		end, {})
	)

	for server, config in pairs(lsp_servers) do
		config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
		lspconfig[server].setup(config)
	end

	require("lspconfig.ui.windows").default_options.border = "single"
end)

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

with("nvim-treesitter.configs", function(configs)
	local parsers_dir = os.getenv("HOME") .. "/.local/share/nvim"
	vim.opt.runtimepath:prepend(parsers_dir)
	configs.setup({
		parser_install_dir = parsers_dir,
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
			"markdown_inline",
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
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<cr>",
				-- scope_incremental = "<cr>",
				node_incremental = "<cr>",
				node_decremental = "<bs>",
			},
		},
	})
end)
