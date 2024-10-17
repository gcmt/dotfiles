local M = {}

--- Prettify image link
---@param ns integer namespace ID
---@param node TSNode
---@param metadata vim.treesitter.query.TSMetadata
---@param context Context
---@return table
function M.render(ns, node, metadata, context)
	local ids = {}
	local row1, col1, row2, col2 = node:range()

	-- add icon
	table.insert(
		ids,
		vim.api.nvim_buf_set_extmark(0, ns, row1, col1, {
			end_col = col2,
			virt_text = { { "  ", "FgVeryDim" } },
			virt_text_pos = "inline",
			invalidate = true,
		})
	)

	return ids
end

return M
