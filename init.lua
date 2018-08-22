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
	alyways_day = true,
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

local skybox_cache = {} -- player -> skybox name

local update_skybox = function(player)
	local pos = player:getpos()
	local name = player:get_player_name()

	local current_skybox = skybox_cache[name]

	for _,box in pairs(skybox_list) do
		if pos.y > box.miny and pos.y < box.maxy then
			-- height match found

			if current_skybox == box.name then
				-- already active
				player:set_physics_override({gravity=box.gravity})
				return

			else
				-- new skybox
				skybox_cache[name] = box.name

				player:set_sky({r=0, g=0, b=0},"skybox", box.textures)
				player:set_clouds({density=0,speed=0})
				player:set_physics_override({gravity=box.gravity})
				if box.always_day then
					player:override_day_night_ratio(1)
				end
				return
			end
		end
	end

	-- no match, return to default
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

end

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < 1 then return end
	timer=0

	for i, player in pairs(minetest.get_connected_players()) do
		update_skybox(player)
	end
end)

minetest.register_on_respawnplayer(function(player)
	minetest.after(0.1,function()
		update_skybox(player)
	end)
end)

minetest.register_on_joinplayer(function(player)
	update_skybox(player)
end)

