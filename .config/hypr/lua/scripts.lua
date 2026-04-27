local _M = {}
function _M.getHostname()
	local f = io.popen("/bin/hostname")
	if f then
		local hostname = f:read("*a") or ""
		f:close()
		hostname = string.gsub(hostname, "\n$", "")
		return hostname
	end
end

function _M.randomiseWallpaper(time)
	hl.timer(function()
		hl.exec_cmd("waypaper --random ")
	end, { timeout = time, type = "repeat" })
end

function _M.toggleDolphin()
	local wins = hl.get_windows({ class = "org.kde.dolphin" })
	local active = hl.get_active_window()

	if #wins == 0 then
		hl.exec_cmd("dolphin")
		return
	end

	local win = wins[1]

	if active ~= nil and active.address == win.address then
		hl.dispatch(hl.dsp.window.move({
			window = win,
			workspace = "special:shadowrealm",
			follow = false,
		}))
        return
	end

	local ws = hl.get_active_workspace()

	if ws ~= nil then
		hl.dispatch(hl.dsp.window.move({
			window = win,
			workspace = ws,
			follow = false,
		}))
	end

	hl.dispatch(hl.dsp.focus({ window = win }))
end
return _M
