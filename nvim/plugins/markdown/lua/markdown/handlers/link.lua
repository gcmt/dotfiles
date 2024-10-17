local M = {}

--- Prettify link
---@param ns integer namespace ID
---@param node TSNode
---@param metadata vim.treesitter.query.TSMetadata
---@param context Context
---@return table
function M.render(ns, node, metadata, context)
	local ids = {}
	local row1, col1, row2, col2 = node:range()
	local link_destination = node:named_child(1)

	local icon = "󰌹 "
	if link_destination then
		local text = vim.treesitter.get_node_text(link_destination, context.bufnr)
		if string.match(text, "^https?://") or string.match(text, "^www") then
			icon = " "
		end
	end

	-- add icon
	table.insert(
		ids,
		vim.api.nvim_buf_set_extmark(0, ns, row1, col1, {
			virt_text = { { icon, "FgVeryDim" } },
			virt_text_pos = "inline",
			invalidate = true,
		})
	)

	return ids
end

return M
