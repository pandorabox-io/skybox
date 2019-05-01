
skybox = {
  list = {},
  priv_cache = {}
}

local MP = minetest.get_modpath("skybox")

dofile(MP.."/privs.lua")
dofile(MP.."/fly.lua")
dofile(MP.."/skybox.lua")

print("[OK] Skybox")
