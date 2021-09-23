
local timer = 0
local skybox_cache = {} -- playername -> skybox name

-- returns the skybox or nil
function skybox.get_skybox_for_player(player)
	local pos = player:get_pos()

	if not pos then
		-- yeah, it happens apparently :)
		return
	end

	-- newly selected skybox, if any
	local newbox

	for _,box in pairs(skybox.list) do
		-- potential candidate, compared against priority
		local candidate

		if type(box.match) == "function" then
			-- custom matcher
			if box.match(player, pos) then
				-- box matched
				candidate = box
			end

		-- compare heights
		elseif pos.y > box.miny and pos.y < box.maxy then
			-- height match found
			candidate = box
		end

		if not newbox and candidate then
			-- no old skybox, apply directly
			newbox = candidate

		elseif newbox and candidate then
			-- compare priority, if any. otherwise ignore new box
			if newbox.priority and candidate.priority then
				if candidate.priority > newbox.priority then
					-- select new box
					newbox = candidate
				end
			elseif not newbox.priority and candidate.priority then
				-- candidate has priority, select it
				newbox = candidate
			end
		end
	end

	return newbox
end

function skybox.update_skybox(player)
	local pos = player:get_pos()
	local name = player:get_player_name()

	if skybox.ignore_players[name] then
		skybox_cache[name] = nil
		return
	end

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

			player:set_sky({
				type = box.sky_type or "skybox",
				base_color = box.sky_color or {r=0, g=0, b=0},
				textures = box.textures,
				sky_color = {
					day_sky = "#000000",
					day_horizon = "#000000",
					dawn_sky = "#000000",
					dawn_horizon = "#000000",
					night_sky = "#000000",
					night_horizon = "#000000",
					indoors = "#000000",
					fog_tint_type = "default",
				}
			})

			player:set_moon({ visible = false })
			player:set_sun({ visible = false, sunrise_visible = false })
			player:set_stars({ visible = false })

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

		minetest.log("action", "[skybox] Setting default skybox for player " .. name)
		skybox_cache[name] = ""
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
