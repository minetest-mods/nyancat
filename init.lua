
local node_sound
if minetest.global_exists("default") then
	node_sound = default.node_sound_defaults()
elseif minetest.global_exists("sounds") then
	node_sound = sounds.node()
end

minetest.register_node("nyancat:nyancat", {
	description = "Nyan Cat",
	tiles = {"nyancat_side.png", "nyancat_side.png", "nyancat_side.png",
		"nyancat_side.png", "nyancat_back.png", "nyancat_front.png"},
	paramtype = "light",
	light_source = minetest.LIGHT_MAX,
	paramtype2 = "facedir",
	groups = {cracky = 2},
	is_ground_content = false,
	sounds = node_sound,
})

minetest.register_node("nyancat:nyancat_rainbow", {
	description = "Nyan Cat Rainbow",
	tiles = {
		"nyancat_rainbow.png^[transformR90",
		"nyancat_rainbow.png^[transformR90",
		"nyancat_rainbow.png"
	},
	paramtype = "light",
	light_source = minetest.LIGHT_MAX,
	paramtype2 = "facedir",
	groups = {cracky = 2},
	is_ground_content = false,
	sounds = node_sound,
})


minetest.register_craft({
	type = "fuel",
	recipe = "nyancat:nyancat",
	burntime = 1,
})

minetest.register_craft({
	type = "fuel",
	recipe = "nyancat:nyancat_rainbow",
	burntime = 1,
})


-- Mapgen
nyancat = {}

function nyancat.place(pos, facedir, length)
	if facedir > 3 then
		facedir = 0
	end
	local tailvec = minetest.facedir_to_dir(facedir)
	local p = {x = pos.x, y = pos.y, z = pos.z}
	minetest.set_node(p, {name = "nyancat:nyancat", param2 = facedir})
	for i = 1, length do
		p.x = p.x + tailvec.x
		p.z = p.z + tailvec.z
		minetest.set_node(p, {name = "nyancat:nyancat_rainbow", param2 = facedir})
	end
end

function nyancat.generate(minp, maxp, seed)
	local height_min = -31000
	local height_max = -32
	if maxp.y < height_min or minp.y > height_max then
		return
	end
	local y_min = math.max(minp.y, height_min)
	local y_max = math.min(maxp.y, height_max)
	local volume = (maxp.x - minp.x + 1) * (y_max - y_min + 1) * (maxp.z - minp.z + 1)
	local pr = PseudoRandom(seed + 9324342)
	local max_num_nyancats = math.floor(volume / (16 * 16 * 16))
	for i = 1, max_num_nyancats do
		if pr:next(0, 1000) == 0 then
			local x0 = pr:next(minp.x, maxp.x)
			local y0 = pr:next(minp.y, maxp.y)
			local z0 = pr:next(minp.z, maxp.z)
			local p0 = {x = x0, y = y0, z = z0}
			nyancat.place(p0, pr:next(0, 3), pr:next(3, 15))
		end
	end
end

minetest.register_on_generated(function(minp, maxp, seed)
	nyancat.generate(minp, maxp, seed)
end)

-- Legacy compat
if minetest.global_exists("default") then
	minetest.register_alias("default:nyancat", "nyancat:nyancat")
	minetest.register_alias("default:nyancat_rainbow", "nyancat:nyancat_rainbow")
	default.make_nyancat = nyancat.place
	default.generate_nyancats = nyancat.generate
end
