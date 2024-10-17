local M = {}

local callouts = {
	["[!NOTE]"] = { overlay = "󰋽 Note", hlgroup = "FgDim" },
	["[!TIP]"] = { overlay = "󰌶 Tip", hlgroup = "FgDim" },
	["[!IMPORTANT]"] = { overlay = "󰅾 Important", hlgroup = "FgDim" },
	["[!WARNING]"] = { overlay = "󰀪 Warning", hlgroup = "FgDim" },
	["[!CAUTION]"] = { overlay = "󰳦 Caution", hlgroup = "FgDim" },
	["[!ABSTRACT]"] = { overlay = "󰨸 Abstract", hlgroup = "FgDim" },
	["[!SUMMARY]"] = { overlay = "󰨸 Summary", hlgroup = "FgDim" },
	["[!TLDR]"] = { overlay = "󰨸 Tldr", hlgroup = "FgDim" },
	["[!INFO]"] = { overlay = "󰋽 Info", hlgroup = "FgDim" },
	["[!TODO]"] = { overlay = "󰗡 Todo", hlgroup = "FgDim" },
	["[!HINT]"] = { overlay = "󰌶 Hint", hlgroup = "FgDim" },
	["[!SUCCESS]"] = { overlay = " Success", hlgroup = "FgDim" },
	["[!CHECK]"] = { overlay = " Check", hlgroup = "FgDim" },
	["[!DONE]"] = { overlay = " Done", hlgroup = "FgDim" },
	["[!QUESTION]"] = { overlay = "󰘥 Question", hlgroup = "FgDim" },
	["[!HELP]"] = { overlay = "󰘥 Help", hlgroup = "FgDim" },
	["[!FAQ]"] = { overlay = "󰘥 Faq", hlgroup = "FgDim" },
	["[!ATTENTION]"] = { overlay = "󰀪 Attention", hlgroup = "FgDim" },
	["[!FAILURE]"] = { overlay = " Failure", hlgroup = "FgDim" },
	["[!FAIL]"] = { overlay = " Fail", hlgroup = "FgDim" },
	["[!MISSING]"] = { overlay = " Missing", hlgroup = "FgDim" },
	["[!DANGER]"] = { overlay = "󱐌 Danger", hlgroup = "FgDim" },
	["[!ERROR]"] = { overlay = "󱈸 Error", hlgroup = "FgDim" },
	["[!BUG]"] = { overlay = "󰨰 Bug", hlgroup = "FgDim" },
	["[!EXAMPLE]"] = { overlay = " Example", hlgroup = "FgDim" },
	["[!QUOTE]"] = { overlay = "󱆨 Quote", hlgroup = "FgDim" },
	["[!CITE]"] = { overlay = "󱆨 Cite", hlgroup = "FgDim" },
}

--- Prettify shortcut link
---@param ns integer namespace ID
---@param node TSNode
---@param metadata vim.treesitter.query.TSMetadata
---@param context Context
---@return table
function M.render(ns, node, metadata, context)
	local ids = {}
	local row1, col1, row2, col2 = node:range()

	local text = vim.treesitter.get_node_text(node, context.bufnr)
	local overlay, hlgroup
	if callouts[text] then
		overlay = callouts[text].overlay
		hlgroup = callouts[text].hlgroup
	else
		overlay = text
		hlgroup = "Normal"
	end

	table.insert(
		ids,
		vim.api.nvim_buf_set_extmark(0, ns, row1, col1, {
			end_col = col2,
			virt_text = { { overlay .. " ", hlgroup } },
			virt_text_pos = "overlay",
			virt_text_hide = true,
			invalidate = true,
		})
	)

	return ids
end

return M
