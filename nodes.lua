local S = minetest.get_translator(minetest.get_current_modname())



-- cache nodes with the group
minetest.register_on_mods_loaded(function()
    local autoRegister = minetest.settings:get_bool("k_colorblocks.autoregister_nodes", false)

    -- mapping of paramtype2 -> [new paramtype2, palette]
    local paramtypemap = {
        none = { "color", k_colorblocks.palettes.full.image },
        color = { "color", k_colorblocks.palettes.full.image },
        -- @todo below needs some work...
        -- degrotate = { "colordegrotate", k_colorblocks.palettes.full.image},
        -- facedir = { "colorfacedir", k_colorblocks.palettes.full.image }, -- could use `color4dir` for more colours
        --color4dir = { "color4dir", k_colorblocks.palettes.full.image },
        -- wallmounted = { "colorwallmounted", k_colorblocks.palettes.full.image },
    }

    for key, def in pairs(minetest.registered_nodes) do
        if def.groups.k_colorblocks then
            k_colorblocks:cacheNode(key)
        end

        if
            autoRegister
            and (
                def.groups.concrete
                or def.groups.concrete_powder
                or string.find(key, "mcl_stairs:slab_concrete_")
                --or string.find(key, "mcl_stairs:stair_concrete_") -- rotation issues.
                or def.groups.wool
                or def.groups.carpet
                or def.groups.glass                      -- because stained glass. seems to work even with connected glass. not with paramtype2 = "glasslikeliquidlevel"
                or string.find(key, "mcl_light_blocks:") -- the kids like light blocks
                or def.groups.hardened_clay
                or def.groups.glazed_terracotta          -- make patterns pop
                or def.groups.snowy                      -- default snow. needs testing in snowy weather.
                or def.groups.snow_cover                 -- needs testing in snowy weather.
                or def.groups.snow_top
                or def.groups.ice                        -- ice castles
            )
        then
            if paramtypemap[def.paramtype2] then
                local newparamtype2 = paramtypemap[def.paramtype2][1] or def.paramtype2
                local newpalette = paramtypemap[def.paramtype2][2] or def.palette

                def.groups.k_colorblocks = 1

                local overrides = {
                    paramtype2 = newparamtype2,
                    palette    = newpalette,
                    group      = def.groups,
                }
                minetest.override_item(key, overrides)
                k_colorblocks:cacheNode(key)
            end
        end
    end
end)


-- at least one sound where possible.
local sounds = {
    default = {},
    glass = {},
}

if minetest.get_modpath("default") then
    sounds.default = default.node_sound_stone_defaults()
    sounds.glass = default.node_sound_glass_defaults()
elseif minetest.get_modpath("mcl_sounds") then
    sounds.default = mcl_sounds.node_sound_stone_defaults()
    sounds.glass = mcl_sounds.node_sound_glass_defaults()
end

local glowLevel = 11
local defaultHardness = 5
local defaultBlastResistance = 100 -- to shoo the creepers away

minetest.register_node("k_colorblocks:quartz_glow_block", {
    description = S("Stainable Glowing Block of Quartz"),
    is_ground_content = false,
    tiles = { "k_colorblocks_quartz_block_top.png", "k_colorblocks_quartz_block_top.png", "k_colorblocks_quartz_block_side.png" },
    groups = { pickaxey = 1, quartz_block = 1, building_block = 1, material_stone = 1, stonecuttable = 1, k_colorblocks = 1 },
    sounds = sounds.default,
    light_source = glowLevel,
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
    sounds = sounds.default,
    paramtype2 = "color",
    palette = k_colorblocks.palettes.full.image,
    _mcl_blast_resistance = defaultBlastResistance,
    _mcl_hardness = defaultHardness,

})

minetest.register_node("k_colorblocks:glass", {
    description = S("Stainable Glass"),
    drawtype = "glasslike_framed",
    is_ground_content = false,
    tiles = { "k_colorblocks_glass.png", "k_colorblocks_glass_detail.png" },
    use_texture_alpha = "blend",
    paramtype = "light",
    sunlight_propagates = true,
    groups = { handy = 1, glass = 1, building_block = 1, material_glass = 1, k_colorblocks = 1 },
    sounds = sounds.glass,
    paramtype2 = "color",
    palette = k_colorblocks.palettes.full.image,
    _mcl_blast_resistance = defaultBlastResistance,
    _mcl_hardness = defaultHardness,
})

minetest.register_node("k_colorblocks:glass_glow", {
    description = S("Glowing Stainable Glass"),
    drawtype = "glasslike_framed",
    is_ground_content = false,
    tiles = { "k_colorblocks_glass.png", "k_colorblocks_glass_detail.png" },
    use_texture_alpha = "blend",
    paramtype = "light",
    sunlight_propagates = true,
    groups = { handy = 1, glass = 1, building_block = 1, material_glass = 1, k_colorblocks = 1 },
    sounds = sounds.glass,
    paramtype2 = "color",
    light_source = glowLevel,
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
        sounds = sounds.default,
        light_source = glowLevel,
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
        sounds = sounds.default,
        paramtype2 = "color",
        palette = k_colorblocks.palettes.full.image,
        _mcl_blast_resistance = defaultBlastResistance,
        _mcl_hardness = defaultHardness,
    })
    
    -- translucent varients
    minetest.register_node("k_colorblocks:block_plain_glow_translucent_" .. label, {
        description = S("Stainable Plain Glowing Translucent Block " .. label),
        is_ground_content = false,
        tiles = { "k_colorblocks_node_plain_tiles_translucent.png^[sheet:25x1:" .. (i - 1) .. ",0" },
        use_texture_alpha = "blend",
        groups = { pickaxey = 1, quartz_block = 1, building_block = 1, material_stone = 1, stonecuttable = 1, k_colorblocks = 1 },
        sounds = sounds.default,
        light_source = glowLevel,
        paramtype2 = "color",
        palette = k_colorblocks.palettes.full.image,
        _mcl_blast_resistance = defaultBlastResistance,
        _mcl_hardness = defaultHardness,
    })

    minetest.register_node("k_colorblocks:block_plain_translucent_" .. label, {
        description = S("Stainable Plain Translucent Block " .. label),
        is_ground_content = false,
        tiles = { "k_colorblocks_node_plain_tiles_translucent.png^[sheet:25x1:" .. (i - 1) .. ",0" },
        use_texture_alpha = "blend",
        groups = { pickaxey = 1, quartz_block = 1, building_block = 1, material_stone = 1, stonecuttable = 1, k_colorblocks = 1 },
        sounds = sounds.default,
        paramtype2 = "color",
        palette = k_colorblocks.palettes.full.image,
        _mcl_blast_resistance = defaultBlastResistance,
        _mcl_hardness = defaultHardness,
    })
end
