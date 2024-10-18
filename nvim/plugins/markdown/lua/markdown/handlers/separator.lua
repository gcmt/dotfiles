local M = {}

--- Prettify separator line
---@param ns integer namespace ID
---@param node TSNode
---@param metadata vim.treesitter.query.TSMetadata
---@param context Context
---@return table
function M.render(ns, node, metadata, context)
	local ids = {}
	local row1, col1, row2, col2 = node:range()

	table.insert(
		ids,
		vim.api.nvim_buf_set_extmark(0, ns, row1, col1, {
			virt_text = { { string.rep("🭷", context.wininfo.width), "NonText" } },
			virt_text_pos = "overlay",
			virt_text_hide = true,
			invalidate = true,
		})
	)

	return ids
end

return M
