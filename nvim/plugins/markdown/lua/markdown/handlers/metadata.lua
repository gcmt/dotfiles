local M = {}

--- Prettify yaml metadata
---@param ns integer namespace ID
---@param node TSNode
---@param metadata vim.treesitter.query.TSMetadata
---@param context Context
---@return table
function M.render(ns, node, metadata, context)
	local ids = {}
	local row1, col1, row2, col2 = node:range()

	--- overlay on fisrt line
	table.insert(
		ids,
		vim.api.nvim_buf_set_extmark(0, ns, row1, col1, {
			virt_text = { { string.rep("🭷", 4), "NonText" } },
			virt_text_pos = "overlay",
			virt_text_hide = true,
			invalidate = true,
		})
	)

	--- overlay on last line
	table.insert(
		ids,
		vim.api.nvim_buf_set_extmark(0, ns, row2 - 1, col2, {
			virt_text = { { string.rep("🭷", 4), "NonText" } },
			virt_text_pos = "overlay",
			virt_text_hide = true,
			invalidate = true,
		})
	)

	return ids
end

return M
