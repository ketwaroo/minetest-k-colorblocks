local S = minetest.get_translator(minetest.get_current_modname())

-- at least one sound where possible.
local defaultNodeSound = {}

if minetest.get_modpath("default") then
    defaultNodeSound = default.node_sound_stone_defaults()
elseif minetest.get_modpath("mcl_sounds") then
    defaultNodeSound = mcl_sounds.node_sound_stone_defaults()
end

local quartzGlow = 11
local defaultHardness = 5
local defaultBlastResistance = 100

minetest.register_node("k_colorblocks:quartz_glow_block", {
    description = S("Stainable Glowing Block of Quartz"),
    is_ground_content = false,
    tiles = { "k_colorblocks_quartz_block_top.png", "k_colorblocks_quartz_block_top.png", "k_colorblocks_quartz_block_side.png" },
    groups = { pickaxey = 1, quartz_block = 1, building_block = 1, material_stone = 1, stonecuttable = 1, k_colorblocks = 1 },
    sounds = defaultNodeSound,
    light_source = quartzGlow,
    paramtype2 = "color",
    palette = k_colorblocks.palettes.full.image,
    _mcl_blast_resistance = defaultBlastResistance,
    _mcl_hardness = defaultHardness,

})
minetest.register_node("k_colorblocks:quartz_block", {
    description = S("Stainable Block of Quartz"),
    is_ground_content = false,
    tiles = { "k_colorblocks_quartz_block_top.png", "k_colorblocks_quartz_block_top.png", "k_colorblocks_quartz_block_side.png" },
    groups = { pickaxey = 1, quartz_block = 1, building_block = 1, material_stone = 1, stonecuttable = 1, k_colorblocks = 1 },
    sounds = defaultNodeSound,
    paramtype2 = "color",
    palette = k_colorblocks.palettes.full.image,
    _mcl_blast_resistance = defaultBlastResistance,
    _mcl_hardness = defaultHardness,

})

-- plain blocks
local plainblocks = {}

table.insert(plainblocks, "white")
for i = 0, 345, 15 do
    table.insert(plainblocks, "hue_" .. i)
end

for i = 1, #plainblocks, 1 do
    local label = plainblocks[i]
    minetest.register_node("k_colorblocks:block_plain_glow_" .. label, {
        description = S("Stainable Plain Glowing Block " .. label),
        is_ground_content = false,
        tiles = { "k_colorblocks_node_plain_tiles.png^[sheet:25x1:" .. (i - 1) .. ",0" },
        groups = { pickaxey = 1, quartz_block = 1, building_block = 1, material_stone = 1, stonecuttable = 1, k_colorblocks = 1 },
        sounds = defaultNodeSound,
        light_source = quartzGlow,
        paramtype2 = "color",
        palette = k_colorblocks.palettes.full.image,
        _mcl_blast_resistance = defaultBlastResistance,
        _mcl_hardness = defaultHardness,
    })

    minetest.register_node("k_colorblocks:block_plain_" .. label, {
        description = S("Stainable Plain Block " .. label),
        is_ground_content = false,
        tiles = { "k_colorblocks_node_plain_tiles.png^[sheet:25x1:" .. (i - 1) .. ",0" },
        groups = { pickaxey = 1, quartz_block = 1, building_block = 1, material_stone = 1, stonecuttable = 1, k_colorblocks = 1 },
        sounds = defaultNodeSound,
        paramtype2 = "color",
        palette = k_colorblocks.palettes.full.image,
        _mcl_blast_resistance = defaultBlastResistance,
        _mcl_hardness = defaultHardness,
    })
end
