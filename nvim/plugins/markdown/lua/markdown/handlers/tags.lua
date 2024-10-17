local M = {}

--- Prettify tagged line
---@param ns integer namespace ID
---@param node TSNode
---@param metadata vim.treesitter.query.TSMetadata
---@param context Context
---@return table
function M.render(ns, node, metadata, context)
	local ids = {}
	local row1, col1, row2, col2 = node:range()

	-- Find all tags at the start
	local tags = {}
	local start = 0
	local text = vim.split(vim.treesitter.get_node_text(node, context.bufnr), "\n")[1]
	while true do
		local i, j = string.find(text, "^#[a-z_-]+", start + 1)
		if j then
			table.insert(tags, { i, j })
			local _, k = string.find(text, "^%s+", j + 1)
			if k then
				start = k
			else
				start = j
			end
		else
			break
		end
	end

	for _, tag in ipairs(tags) do
		-- add icon
		table.insert(
			ids,
			vim.api.nvim_buf_set_extmark(0, ns, row1, tag[1] - 1, {
				end_col = tag[2],
				virt_text = { { "  ", { "FgVeryDim", "BgAccent" } } },
				virt_text_pos = "inline",
				hl_group = "BgAccent",
				invalidate = true,
				end_right_gravity = true,
			})
		)

		-- add right padding
		table.insert(
			ids,
			vim.api.nvim_buf_set_extmark(0, ns, row1, tag[2], {
				end_col = tag[2],
				virt_text = { { " ", "BgAccent" } },
				virt_text_pos = "inline",
				hl_group = "BgAccent",
				invalidate = true,
			})
		)

		-- conceal hash character
		table.insert(
			ids,
			vim.api.nvim_buf_set_extmark(0, ns, row1, tag[1] - 1, {
				end_col = tag[1],
				conceal = "",
			})
		)
	end

	return ids
end

return M
