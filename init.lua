local has_beacon_mod = minetest.get_modpath("beacon")

local skybox_list = {}

local register_skybox = function(def)
	table.insert(skybox_list, def)
end

register_skybox({
	name = "space",
	miny = 1000,
	maxy = 5000,
	gravity = 0.8,
	textures = {"space_sky.png","space_sky2.png","space_sky.png","space_sky.png","space_sky.png","space_sky.png"}
})

register_skybox({
	name = "moon",
	miny = 5001,
	maxy = 6000,
	gravity = 0.1654,
	always_day = true,
	textures = {"space_sky.png","space_sky.png","space_sky.png","space_sky.png","space_sky.png","space_sky.png"}
})

register_skybox({
	-- https://github.com/Ezhh/other_worlds/blob/master/skybox.lua
	name = "deepspace",
	miny = 6001,
	maxy = 10000,
	gravity = 0.1,
	always_day = true,
	fly = true,
	textures = {
		"sky_pos_z.png",
		"sky_neg_z.png^[transformR180",
		"sky_neg_y.png^[transformR270",
		"sky_pos_y.png^[transformR270",
		"sky_pos_x.png^[transformR270",
		"sky_neg_x.png^[transformR90"
	}
})


local timer = 0
local skybox_cache = {} -- playername -> skybox name
local priv_cache = {} -- playername -> {priv=}

local update_skybox = function(player)
	local t0 = minetest.get_us_time()

	local pos = player:get_pos()
	local name = player:get_player_name()

	if not pos then
		-- yeah, it happens apparently :)
		return
	end

	local privs = priv_cache[name]

	if not privs then
		privs = minetest.get_player_privs(name)
	end

	local player_is_admin = privs.privs
	local green_beacon_near = nil

	local current_skybox = skybox_cache[name]

	for _,box in pairs(skybox_list) do
		if pos.y > box.miny and pos.y < box.maxy then
			-- height match found

			if current_skybox == box.name then
				-- already active

				if math.random(3) == 1 then
					-- randomize
					player:set_physics_override({gravity=box.gravity})
				end
				return

			else
				minetest.log("action", "[skybox] Setting skybox: " .. box.name .. " for player " .. name)

				-- new skybox
				skybox_cache[name] = box.name

				player:set_sky({r=0, g=0, b=0},"skybox", box.textures)
				player:set_clouds({density=0,speed=0})
				player:set_physics_override({gravity=box.gravity})
				if box.always_day then
					player:override_day_night_ratio(1)
				end
				if not player_is_admin then
					local player_has_fly_privs = privs.fly

					if box.fly and not player_has_fly_privs then
						privs.fly = true
						minetest.set_player_privs(name, privs)
					end
					if not box.fly and player_has_fly_privs then
						privs.fly = nil
						minetest.set_player_privs(name, privs)
					end
					priv_cache[name] = privs
				end


			        local t1 = minetest.get_us_time()
			        local diff = t1 - t0
			        if diff > 10000 then
			                minetest.log("warning", "[skybox] update for player " .. name .. " took " .. diff .. " us")
			        end

				return
			end
		end
	end

	if has_beacon_mod then
		green_beacon_near = minetest.find_node_near(pos, beacon.config.effects_radius, {"beacon:greenbase"})
	end

	-- no match, return to default
	if not player_is_admin and not green_beacon_near then
		if privs.fly then
			minetest.log("action", "[skybox] revoking fly priv for player: " .. name)
			privs.fly = nil
			minetest.set_player_privs(name, privs)
			priv_cache[name] = privs
		end
	end

	if current_skybox == "" then
		-- already in default
		return
	end

	minetest.log("action", "[skybox] Restoring default skybox for player: " .. name)

	player:override_day_night_ratio(nil)
	skybox_cache[name] = ""
	player:set_sky({r=0, g=0, b=0},"regular",{})
	player:set_clouds({
		thickness=16,
		color={r=240, g=240, b=255, a=229},
		ambient={r=0, g=0, b=0, a=255},
		density=0.4,
		height=120,
		speed={y=-2,x=0}
	})
	player:set_physics_override({gravity=1, jump=1})

	local t1 = minetest.get_us_time()
	local diff = t1 - t0
	if diff > 10000 then
		minetest.log("warning", "[skybox] update for player " .. name .. " took " .. diff .. " us")
	end
end

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < 2 then return end
	timer=0
	local t0 = minetest.get_us_time()
	local players = minetest.get_connected_players()
	for i, player in pairs(players) do
		update_skybox(player)
	end
	local t1 = minetest.get_us_time()
	local delta_us = t1 -t0
	if delta_us > 25000 then
		minetest.log("warning", "[skybox] update took " .. delta_us .. " us")
	end
end)

minetest.register_on_respawnplayer(function(player)
	minetest.after(2,function()
		update_skybox(player)
	end)
end)

minetest.register_on_joinplayer(function(player)
	minetest.after(2, function()
		update_skybox(player)
	end)
end)

