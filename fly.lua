

local skybox.update_player_fly = function(player, privs, can_fly)
	local player_is_admin = privs.privs
	local player_can_always_fly = privs.skybox_fly
	local name = player:get_player_name()

	if player_is_admin or player_can_always_fly then
		-- not touching admin privs
		return
	end

	if privs.fly and can_fly then
		-- already fly granted
		return
	end

	if not privs.fly and not can_fly then
		-- no fly
		return
	end

	if not privs.fly and can_fly then
		-- grant fly
		privs = minetest.get_player_privs(name)
		privs.fly = true
		minetest.set_player_privs(name, privs)
		skybox.priv_cache[name] = privs
		return
	end

	if privs.fly and not can_fly then
		-- revoke fly
		privs = minetest.get_player_privs(name)
		privs.fly = nil
		minetest.set_player_privs(name, privs)
		skybox.priv_cache[name] = privs
		return
	end
end
