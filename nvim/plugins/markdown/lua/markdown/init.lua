local M = {}

local Context = require("markdown.context")
local handlers = require("markdown.handlers")
local queries = require("markdown.queries")

local NS = vim.api.nvim_create_namespace("__markdown__")
local EXTMARKS = {}

local function clear_all()
	vim.api.nvim_buf_clear_namespace(0, NS, 0, -1)
end

local function get_extmarks()
	return vim.api.nvim_buf_get_extmarks(0, NS, 0, -1, {})
end

local function render(query, context)
	return function(tree, _)
		for id, node, metadata in query:iter_captures(tree:root(), context.bufnr) do
			local capture = query.captures[id]
			local handler = handlers.get(capture)
			EXTMARKS[capture] = EXTMARKS[capture] or {}
			for _, extmark in ipairs(handler(NS, node, metadata, context)) do
				table.insert(EXTMARKS[capture], extmark)
			end
		end
	end
end

function M.prettify()
	clear_all()
	local context = Context:new()
	for lang, query in pairs(queries) do
		local parser = vim.treesitter.get_parser(context.bufnr, lang)
		parser:for_each_tree(render(vim.treesitter.query.parse(lang, query), context))
	end
end

function M.raw()
	clear_all()
end

function M.toggle()
	if #get_extmarks() == 0 then
		M.prettify()
	else
		M.raw()
	end
end

function M.setup_autocommands()
	AUGROUP = vim.api.nvim_create_augroup("__markdown__", { clear = true })
	vim.api.nvim_create_autocmd({ "BufModifiedSet" }, {
		group = AUGROUP,
		buffer = 0,
		callback = function()
			if #get_extmarks() > 0 then
				M.prettify()
			end
		end,
	})
	vim.api.nvim_create_autocmd({ "InsertEnter" }, {
		group = AUGROUP,
		buffer = 0,
		callback = function()
			local lnum = vim.fn.line(".")
			vim.api.nvim_buf_clear_namespace(0, NS, lnum - 1, lnum)
		end,
	})
	vim.api.nvim_create_autocmd({ "InsertLeave", "WinResized" }, {
		group = AUGROUP,
		buffer = 0,
		callback = function()
			if #get_extmarks() > 0 then
				M.prettify()
			end
		end,
	})
end

return M
