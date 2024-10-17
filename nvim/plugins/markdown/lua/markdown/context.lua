---@class Context
---@field bufnr integer
---@field wininfo table
local Context = {}
Context.__index = Context

--- Return a new Context instance
---@return Context
function Context:new()
	local ctx = {}
	setmetatable(ctx, Context)
	local id = vim.api.nvim_get_current_win()
	local wininfo = vim.fn.getwininfo(id)[1]
	ctx.bufnr = wininfo.bufnr
	ctx.wininfo = wininfo
	return ctx
end

return Context
