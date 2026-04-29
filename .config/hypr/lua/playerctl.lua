local whitelist = { spotify = true, tidal = true, strawberry = true }
local last_player = nil

local function get_active_player()
    local handle = io.popen("playerctl -l 2>/dev/null")
    local players = handle:read("*a")
    handle:close()

    for player in players:gmatch("[^\n]+") do
        local name = player:match("^([^.]+)")
        if whitelist[name:lower()] then
            local status = io.popen("playerctl --player=" .. player .. " status 2>/dev/null")
            local state = status:read("*a"):gsub("%s+$", "")
            status:close()
            if state == "Playing" then
                last_player = player
                return player
            end
        end
    end

    return last_player
end

local function run(cmd)
    local player = get_active_player()
    local player_flag = player and ("--player=" .. player) or ("--player=spotify,tidal,strawberry")
    os.execute("playerctl " .. player_flag .. " " .. cmd)
end

return {
	play_pause = function()
		run("play-pause")
	end,
	next = function()
		run("next")
	end,
	previous = function()
		run("previous")
	end,
	stop = function()
		run("stop")
	end,
	volume_up = function()
		run("volume 0.02+")
	end,
	volume_down = function()
		run("volume 0.02-")
	end,
}
