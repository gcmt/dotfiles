local M = {}

local tags = require("markdown.handlers.tags")
local heading = require("markdown.handlers.heading")
local codeblock = require("markdown.handlers.codeblock")
local codeinline = require("markdown.handlers.codeinline")
local blockquote = require("markdown.handlers.blockquote")
local link = require("markdown.handlers.link")
local list = require("markdown.handlers.list")
local image = require("markdown.handlers.image")
local separator = require("markdown.handlers.separator")
local callout = require("markdown.handlers.callout")
local metadata = require("markdown.handlers.metadata")

local handlers = {
	heading = heading.render,
	tags = tags.render,
	codeblock = codeblock.render,
	codeinline = codeinline.render,
	blockquote = blockquote.render,
	link = link.render,
	list = list.render,
	image = image.render,
	separator = separator.render,
	callout = callout.render,
	metadata = metadata.render,
}

--- Return handler for the given capture
---@param capture string
---@return function
function M.get(capture)
	if not handlers[capture] then
		error(string.format("unhandled capture: %s", capture))
	end
	return handlers[capture]
end

return M
