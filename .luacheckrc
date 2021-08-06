unused_args = false
allow_defined_top = true

globals = {
	"skybox",
	"travelnet"
}

read_globals = {
	-- Stdlib
	string = {fields = {"split"}},
	table = {fields = {"copy", "getn"}},

	-- Minetest
	"minetest",
	"vector", "ItemStack",
	"dump"
}
