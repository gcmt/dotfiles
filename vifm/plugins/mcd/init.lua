local function mcd(info)
	local path = info.argv[1]

	if vifm.exists(path) then
		vifm.errordialog("mcd", "Directory already exists: " .. path)
		return
	end

	if not vifm.makepath(path) then
		vifm.errordialog("mcd", "Failed to create directory: " .. path)
		return
	end

	if not vifm.currview():cd(path) then
		vifm.errordialog("mcd", "Failed move into directory: " .. path)
	end
end

local added = vifm.cmds.add({
	name = "Mcd",
	description = "create directory and enter it",
	handler = mcd,
	maxargs = 1,
})

if not added then
	vifm.sb.error("Failed to register :mcd")
end

return {}
