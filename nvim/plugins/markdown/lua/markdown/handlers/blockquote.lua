local M = {}

--- Prettify code block
---@param ns integer namespace ID
---@param node TSNode
---@param metadata vim.treesitter.query.TSMetadata
---@param context Context
---@return table
function M.render(ns, node, metadata, context)
	local ids = {}
	local row1, col1, row2, col2 = node:range()

	-- add background
	table.insert(
		ids,
		vim.api.nvim_buf_set_extmark(0, ns, row1, col1, {
			end_row = row2,
			end_col = col2,
			hl_eol = true,
			invalidate = true,
		})
	)

	-- insert decoration
	for lnum = row2 - 1, row1, -1 do
		table.insert(
			ids,
			vim.api.nvim_buf_set_extmark(0, ns, lnum, col1, {
				virt_text = { { "▋ ", "NonText" } },
				virt_text_pos = "overlay",
				virt_text_hide = true,
				invalidate = true,
			})
		)
	end

	return ids
end

return M
