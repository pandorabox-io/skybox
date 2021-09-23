

-- sets the default skybox for the player
function skybox.set_default_skybox(player)
	player:override_day_night_ratio(nil)

	-- https://github.com/minetest/minetest/blob/4a3728d828fa8896b49e80fdc68f5d7647bf45b7/src/skyparams.h#L75-L88
	player:set_sky({
		clouds = true,
		type = "regular",
		sky_color = {
			day_sky = "#61b5f5",
			day_horizon = "#90d3f6",
			dawn_sky = "#b4bafa",
			dawn_horizon = "#bac1f0",
			night_sky = "#006bff",
			night_horizon = "#4090ff",
			indoors = "#646464",
			fog_tint_type = "default",
		}
	})

	player:set_moon({ visible = true })
	player:set_sun({ visible = true, sunrise_visible = true })
	player:set_stars({ visible = true })

	player:set_clouds({
		thickness=16,
		color={r=243, g=214, b=255, a=229},
		ambient={r=0, g=0, b=0, a=255},
		density=0.4,
		height=200,
		speed={y=-2,x=-1}
	})

end