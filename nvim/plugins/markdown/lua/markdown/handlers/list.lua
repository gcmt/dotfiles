local M = {}

--- Prettify ordered list
---@param ns integer namespace ID
---@param node TSNode
---@param metadata vim.treesitter.query.TSMetadata
---@param context Context
---@return table
function M.render(ns, node, metadata, context)
	local ids = {}

	-- add incremental numbers
	for n = 0, node:named_child_count() do
		local list_item = node:named_child(n)
		if not list_item then
			goto continue
		end
		local text = vim.treesitter.get_node_text(list_item, context.bufnr)
		if not string.match(text, "^%d") then
			break
		end
		local row1, col1 = list_item:range()
		table.insert(
			ids,
			vim.api.nvim_buf_set_extmark(0, ns, row1, col1, {
				end_row = col1 + 1,
				virt_text = { { tostring(n + 1), "Normal" } },
				virt_text_pos = "overlay",
				virt_text_hide = true,
				invalidate = true,
			})
		)
		::continue::
	end

	return ids
end

return M
