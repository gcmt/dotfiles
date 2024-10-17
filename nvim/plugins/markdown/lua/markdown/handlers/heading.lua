local M = {}

--- Prettify heading
---@param ns integer namespace ID
---@param node TSNode
---@param metadata vim.treesitter.query.TSMetadata
---@param context Context
---@return table
function M.render(ns, node, metadata, context)
	local ids = {}

	local text
	local n = string.match(node:type(), "atx_h([1-6])_marker")
	if n == "1" then
		text = "━"
	elseif n == "2" then
		text = "━"
	elseif n == "3" then
		text = "🭷"
	elseif n == "4" then
		text = "─"
	elseif n == "5" then
		text = "┄"
	elseif n == "6" then
		text = "┄"
	end

	local row1, col1, row2, col2 = node:range()

	-- insert line below the heading
	table.insert(
		ids,
		vim.api.nvim_buf_set_extmark(0, ns, row1, col2, {
			virt_lines = { { { string.rep(text, context.wininfo.width), "NonText" } } },
			virt_text_pos = "inline",
			invalidate = true,
		})
	)

	-- conceal hash characters
	table.insert(
		ids,
		vim.api.nvim_buf_set_extmark(0, ns, row1, col1, {
			end_col = col1 + tonumber(n) + 1,
			conceal = "",
		})
	)

	return ids
end

return M
