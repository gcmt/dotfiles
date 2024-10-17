vim.api.nvim_buf_create_user_command(0, "Prettify", function(_)
	require("markdown").prettify()
end, { nargs = 0 })

vim.api.nvim_buf_create_user_command(0, "Raw", function(_)
	require("markdown").raw()
end, { nargs = 0 })

require("markdown").setup_autocommands()
