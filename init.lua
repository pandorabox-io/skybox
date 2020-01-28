
skybox = {
  list = {},

  -- map name -> bool
  ignore_players = {}
}

local MP = minetest.get_modpath("skybox")

dofile(MP.."/register.lua")
dofile(MP.."/skybox.lua")

print("[OK] Skybox")
