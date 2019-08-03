
skybox.register = function(def)
	print("[skybox] registering " .. def.name .. " from " .. def.miny .. " to " .. def.maxy)
	table.insert(skybox.list, def)
end


local timer = 0
local skybox_cache = {} -- playername -> skybox name

-- returns the skybox or nil
skybox.get_skybox_for_player = function(player)
	local pos = player:get_pos()

	if not pos then
		-- yeah, it happens apparently :)
		return
	end

	for _,box in pairs(skybox.list) do
		if pos.y > box.miny and pos.y < box.maxy then
			-- height match found
			return box
		end
	end
end

-- sets the default skybox for the player
skybox.set_default_skybox = function(player)
	local name = player:get_player_name()

	minetest.log("action", "[skybox] Restoring default skybox for player: " .. name)

	skybox_cache[name] = ""

	player:override_day_night_ratio(nil)
	player:set_sky({r=0, g=0, b=0},"regular",{})
	player:set_clouds({
		thickness=16,
		color={r=243, g=214, b=255, a=229},
		ambient={r=0, g=0, b=0, a=255},
		density=0.4,
		height=200,
		speed={y=-2,x=-1}
	})

end

skybox.update_skybox = function(player)
	local pos = player:get_pos()
	local name = player:get_player_name()

	if not pos then
		-- yeah, it happens apparently :)
		return
	end

	local current_skybox = skybox_cache[name]

	local box = skybox.get_skybox_for_player(player)

	if box then
		if current_skybox ~= box.name then
			minetest.log("action", "[skybox] Setting skybox: " .. box.name .. " for player " .. name)

			-- new skybox
			skybox_cache[name] = box.name

			if box.message then
				-- send skybox message
				minetest.chat_send_player(name, box.message)
			end

			local sky_type = box.sky_type or "skybox"
			local sky_color = box.sky_color or {r=0, g=0, b=0}

			player:set_sky(sky_color, sky_type, box.textures or {})
			player:set_clouds(box.clouds or {density=0,speed=0})
			if box.always_day then
				player:override_day_night_ratio(1)
			end

			return
		end

	else

		-- set default skybox

		if current_skybox == "" then
			-- already in default
			return
		end

		skybox.set_default_skybox(player)
	end
end

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < 0.5 then return end
	timer=0
	local t0 = minetest.get_us_time()

	local players = minetest.get_connected_players()
	for i, player in pairs(players) do
		skybox.update_skybox(player)
	end

	local t1 = minetest.get_us_time()
	local delta_us = t1 -t0
	if delta_us > 150000 then
		minetest.log("warning", "[skybox] update took " .. delta_us .. " us")
	end
end)

minetest.register_on_leaveplayer(function(player)
	-- clear cache
	local name = player:get_player_name()
	skybox_cache[name] = nil
end)

minetest.register_on_joinplayer(function(player)
	minetest.after(0, function()
		skybox.update_skybox(player)
	end)
end)
