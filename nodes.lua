local S = minetest.get_translator(minetest.get_current_modname())


-- lookup of nodes that shouldn't be affected by auto register.
k_colorblocks.autoRegisterProtectedNodes = {}

-- cherry blossom leaves don't wilt
k_colorblocks.autoRegisterProtectedNodes["mcl_trees:leaves_cherry_blossom"] = 1

-- cache nodes with the group
minetest.register_on_mods_loaded(function()
    local autoRegister = minetest.settings:get_bool("k_colorblocks.autoregister_nodes", false)
    local iNSaNiTy = minetest.settings:get_bool("k_colorblocks.iNSaNiTy", false)

    -- mapping of paramtype2 -> [new paramtype2, palette]
    local paramtypemap = {
        none = { "color", k_colorblocks.palettes.full.image },
        -- @todo below needs some work...
        -- degrotate = { "colordegrotate", k_colorblocks.palettes.full.image},
        -- facedir = { "colorfacedir", k_colorblocks.palettes.full.image }, -- could use `color4dir` for more colours
        -- wallmounted = { "colorwallmounted", k_colorblocks.palettes.full.image },
    }

    for key, def in pairs(minetest.registered_nodes) do
        if def.groups.k_colorblocks then
            k_colorblocks:cacheNode(key)
        end
        if
            nil == k_colorblocks.autoRegisterProtectedNodes[key]
            and (
                iNSaNiTy
                or (
                    autoRegister
                    and (
                        -- @todo make list configurable perhaps.
                        def.groups.concrete
                        or def.groups.concrete_powder
                        or string.find(key, "mcl_stairs:slab_concrete_")
                        --or string.find(key, "mcl_stairs:stair_concrete_") -- rotation issues.
                        or def.groups.wool
                        or def.groups.carpet
                        or def.groups.glass                  -- because stained glass. seems to work even with connected glass. not with paramtype2 = "glasslikeliquidlevel"
                        or string.find(key, "mcl_light_blocks:") -- the kids like light blocks
                        or def.groups.hardened_clay
                        or def.groups.glazed_terracotta      -- make patterns pop
                        or def.groups.snowy                  -- default snow. needs testing in snowy weather.
                        or def.groups.snow_cover             -- needs testing in snowy weather.
                        or def.groups.snow_top
                        or def.groups.ice                    -- ice castles
                    )
                )
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

-- why is this not built into core helpers???
local function table_merge(t1, t2)
    local tx = table.copy(t1)
    for key, value in pairs(t2) do
        if "table" == type(value) then
            tx[key] = table_merge(tx[key] or {}, value)
        else
            tx[key] = value
        end
    end
    return tx
end

local glowLevel = 11
local defaultHardness = 5
local defaultBlastResistance = 100 -- to shoo the creepers away
local defaultGroups = { handy = 1, pickaxey = 1, building_block = 1, }

-- must supply tiles
local registerColorBlock = function(name, desc, overrides)
    local def = {
        is_ground_content = false,
        description = S(string.format("Stainable %s", desc)),
        paramtype2 = "color",
        palette = k_colorblocks.palettes.full.image,
        _mcl_blast_resistance = defaultBlastResistance,
        _mcl_hardness = defaultHardness,
        groups = defaultGroups,
    };

    def = table_merge(def, overrides or {})
    def.groups.k_colorblocks = 1
    --print(dump(def))
    minetest.register_node("k_colorblocks:" .. name, def)

    local defGlo        = table.copy(def)
    -- glow variant
    defGlo.description  = S(string.format("Stainable %s Glow", desc))
    defGlo.light_source = glowLevel
    minetest.register_node("k_colorblocks:" .. name .. "_glow", defGlo)
end

registerColorBlock(
    "quartz",
    "Quartz Block",
    {
        tiles = { "k_colorblocks_quartz_block_top.png", "k_colorblocks_quartz_block_top.png", "k_colorblocks_quartz_block_side.png" },
        groups = { quartz_block = 1, material_stone = 1, stonecuttable = 1, },
    }
)

minetest.register_alias("k_colorblocks:quartz_block", "k_colorblocks:quartz")
minetest.register_alias("k_colorblocks:quartz_glow_block", "k_colorblocks:quartz_glow")

registerColorBlock(
    "glass",
    "Glass",
    {
        tiles = { "k_colorblocks_glass.png", "k_colorblocks_glass_detail.png" },
        drawtype = "glasslike_framed",
        use_texture_alpha = "blend",
        groups = { glass = 1, material_glass = 1, },
        sounds = sounds.glass,
        paramtype = "light",
        sunlight_propagates = true,
    }
)

-- plain blocks
local plainblocks = {}

table.insert(plainblocks, {
    name = "white",
    label = "White",
})

local useColourName = minetest.settings:get_bool("k_colorblocks.use_colorname", true)

if true == minetest.settings:get_bool("k_colorblocks.register_colored_nodes", true) then
    for i = 0, 345, 15 do
        table.insert(plainblocks,
            {
                name = "hue_" .. i,
                label = useColourName and k_colorblocks.hueMap["" .. i] or ("Hue " .. i),
            })
    end
end

for i = 1, #plainblocks, 1 do
    local label = plainblocks[i].label
    local slug = plainblocks[i].name
    local altSlug = string.gsub(string.lower(label), " ", "_")

    registerColorBlock(
        "plain_" .. slug,
        "Plain " .. label,
        {
            tiles = { "k_colorblocks_node_plain_tiles.png^[sheet:25x1:" .. (i - 1) .. ",0" },
        }
    )
    minetest.register_alias("k_colorblocks:block_plain_" .. slug, "k_colorblocks:plain_" .. slug)
    minetest.register_alias("k_colorblocks:block_plain_glow_" .. slug, "k_colorblocks:plain_" .. slug .. "_glow")

    -- translucent varients
    registerColorBlock(
        "plain_translucent_" .. slug,
        "Plain " .. label .. " Translucent",
        {
            tiles = { "k_colorblocks_node_plain_tiles_translucent.png^[sheet:25x1:" .. (i - 1) .. ",0" },
            drawtype = "glasslike",
            use_texture_alpha = "blend",
        }
    )
    minetest.register_alias("k_colorblocks:block_plain_translucent_" .. slug, "k_colorblocks:plain_translucent_" .. slug)
    minetest.register_alias("k_colorblocks:block_plain_glow_translucent_" .. slug, "k_colorblocks:plain_translucent_" .. slug .. "_glow")

    -- node name aliases. for occasional unknown blocks between updates.
    if altSlug ~= slug then
        minetest.register_alias("k_colorblocks:plain_" .. altSlug, "k_colorblocks:plain_" .. slug)
        minetest.register_alias("k_colorblocks:plain_translucent_" .. altSlug, "k_colorblocks:plain_translucent_" .. slug)
        minetest.register_alias("k_colorblocks:plain_translucent_" .. altSlug .. "_glow", "k_colorblocks:plain_translucent_" .. slug .. "_glow")
    end
end
