local M = {}

--- Prettify inline code
---@param ns integer namespace ID
---@param node TSNode
---@param metadata vim.treesitter.query.TSMetadata
---@param context Context
---@return table
function M.render(ns, node, metadata, context)
	local ids = {}
	local row1, col1, row2, col2 = node:range()

	if row1 ~= row2 then
		-- can happen
		return {}
	end

	-- add background
	table.insert(
		ids,
		vim.api.nvim_buf_set_extmark(0, ns, row1, col1, {
			end_col = col2,
			hl_group = "BgAccent",
			invalidate = true,
		})
	)

	-- conceal first delimiter
	table.insert(
		ids,
		vim.api.nvim_buf_set_extmark(0, ns, row1, col1, {
			end_col = col1 + 1,
			hl_group = "BgAccent",
			conceal = " ",
		})
	)

	-- conceal last delimiter
	table.insert(
		ids,
		vim.api.nvim_buf_set_extmark(0, ns, row1, col2 - 1, {
			end_col = col2,
			hl_group = "BgAccent",
			conceal = " ",
		})
	)

	return ids
end

return M
