
# Skybox management mod

![](https://github.com/pandorabox-io/skybox/workflows/luacheck/badge.svg)

Register your skyboxes in a central place

# Api

```lua
-- register a skybox
skybox.register(skybox_def)
```

* `skybox_def` (table)
  * **name** id/name of the skybox, has to be unique
	* **miny** minimum matching y-height
	* **maxy** maximum y-height
	* **sky_type** (*optional*) string to pass onto `player:set_sky()`
	* **sky_color** (*optional*) color to pass onto `player:set_sky()`
	* **always_day** (*optional*) day_night_ratio ratio is overriden to 1.0 if this is true
	* **textures** (*optional*) 6 textures of a texured skybox
	* **clouds** (*optional*) clouds to pass onto `player:set_clouds()`

# Examples

## Dark caves

```lua
skybox.register({
	name = "earth_cave",
	miny = -32000,
	maxy = -50,
	sky_type = "plain",
	sky_color = {r=0, g=0, b=0}
})
```


## Space
* auto-granted fly-priv

```lua
skybox.register({
	-- https://github.com/Ezhh/other_worlds/blob/master/skybox.lua
	name = "deepspace",
	miny = 6001,
	maxy = 10999,
	always_day = true,
	textures = {
		"sky_pos_z.png",
		"sky_neg_z.png^[transformR180",
		"sky_neg_y.png^[transformR270",
		"sky_pos_y.png^[transformR270",
		"sky_pos_x.png^[transformR270",
		"sky_neg_x.png^[transformR90"
	}
})

```

## Custom matcher

TODO

## Custom skybox function

TODO
