local S = minetest.get_translator(minetest.get_current_modname())
local F = minetest.formspec_escape

local quartzGlow = 11
local defaultHardness = 5
local defaultBlastResistance = 100

k_colorblocks = {

    -- map of nodes we can apply colours to for quicker lookup.
    nodes = {},
    -- per player gui context
    gui_contexts = {

    },
    cacheNode = function(self, nodename)
        if "string" == type(nodename) then
            self.nodes[nodename] = 1
        end
    end,
}

-- cache nodes with the group
minetest.register_on_mods_loaded(function()
    for nodename, def in pairs(minetest.registered_nodes) do
        if def.groups.k_colorblocks then
            k_colorblocks:cacheNode(nodename)
        end
    end
end)

-- @param offsetLeft    x offset in form
-- @param offsetTop     y offset in form
-- @param palette     texture which is a single line of color
-- @param startIdx    zero index start position on palette
-- @param endIdx    zero index end position on palette
-- @param width    width of grid
local function buildColorGrid(offsetLeft, offsetTop, palette, startIdx, endIdx, width, player)
    local parts = {}
    local offsetEndLeft = offsetLeft
    local offsetEndTop = offsetTop

    local playerName = player and player:get_player_name() or nil
    local currentCol = playerName and k_colorblocks.gui_contexts[playerName] and k_colorblocks.gui_contexts[playerName].current_col or nil
    local selectedCol = playerName and k_colorblocks.gui_contexts[playerName] and k_colorblocks.gui_contexts[playerName].selected_col or nil

    --image_button[<X>,<Y>;<W>,<H>;<texture name>;<name>;<label>]

    for idx = startIdx, endIdx, 1 do
        local localIdx = idx - startIdx
        local left = (math.floor(localIdx % width) * 0.5) + offsetLeft
        local top = (math.floor(localIdx / width) * 0.5) + offsetTop

        local texture = palette .. "^[sheet:256x1:" .. idx .. ",0"
        if currentCol and currentCol == idx then
            texture = "(" .. texture .. ")^k_colorblocks_selected_wand.png"
        end
        if selectedCol and selectedCol == idx then
            texture = "(" .. texture .. ")^k_colorblocks_selected_gui.png"
        end

        table.insert(parts, string.format(
            "image_button[%.4f,%.4f;0.5,0.5;%s;k_col;%d;false;false]",
            left,
            top,
            F(texture),
            idx
        ))
        offsetEndLeft = left + 0.5
        offsetEndTop = top + 0.5
    end

    return table.concat(parts, ""), offsetEndLeft, offsetEndTop
end

local palettes = {
    full = {
        image = "k_colorblocks_palette_color_full.png",
        formspec = function(self, player)
            local primary = {
                "Reds",
                "Greens",
                "Blues",
            }
            -- colour names were lifted off wikipedia
            local colours = {
                "Red",
                "Orange",
                "Yellow",
                "Chartreuse",
                "Green",
                "Spring green",
                "Cyan",
                "Azure",
                "Blue",
                "Violet",
                "Magenta",
                "Rose",
            }

            local grids = {
                -- grey
                { top = 0.8, left = 0.4, istart = 0, iend = 14, w = 15, label = "Greyscale", },
            }

            -- texture index pointer for rest of palette
            local idx = 15

            for p = 1, #primary, 1 do
                local colstart = 1 + ((p - 1) * 4)
                local colend = colstart + 3

                for c = colstart, colend, 1 do
                    local row = (c - 1) % 4
                    table.insert(grids, { top = 1.55 + (2.25 * row), left = 0.4 + ((p - 1) * 2.75), istart = idx, iend = (idx + 19), w = 5, label = colours[c] })
                    idx = idx + 20
                end
            end
            local formspecParts = {}
            local endleft = 0
            local endtop = 0
            for i = 1, #grids, 1 do
                local formspec, eleft, etop = buildColorGrid(grids[i].left, grids[i].top, self.image, grids[i].istart, grids[i].iend, grids[i].w, player)
                endleft = eleft
                endtop = etop
                table.insert(formspecParts, formspec)
                -- add labels on top
                table.insert(formspecParts, "label[" .. (grids[i].left) .. "," .. (grids[i].top - 0.1) .. ";" .. F(S(grids[i].label)) .. "]")
            end
            -- 255 is transparent for no reason
            local formspec, _, _ = buildColorGrid(grids[1].left + (grids[1].w * 0.5), grids[1].top, self.image, 255, 255, 1, player)
            table.insert(formspecParts, formspec)


            return table.concat(formspecParts), endleft, endtop
        end,
    },
    grey = {
        image = "k_colorblocks_palette_grey_full.png",
        formspec = function(self, player)
            local formspec, eleft, etop = buildColorGrid(0.8, 0.4, self.image, 0, 255, 16, player)
            formspec = formspec .. "label[0.4,0.7;" .. F(S("Greyscale")) .. "]"
        end,
    }
}

local function refreshWandGui(player)
    local formspecgrids, endleft, endtop = palettes.full:formspec(player)

    local formspec                       = "size[" .. (endleft + 0.4) .. "," .. (endtop + 0.9) .. "]"
        .. "padding[0,0]"
        .. "real_coordinates[true]"
        .. "label[0.3,0.3;" .. F(S("K Color Picker")) .. "]"
        .. formspecgrids
        .. "button_exit[" .. (endleft - 2) .. "," .. (endtop + 0.1) .. ";0.75,0.5;ok;" .. F(S("OK")) .. "]"
        .. "button_exit[" .. (endleft - 1) .. "," .. (endtop + 0.1) .. ";0.75,0.5;cancel;" .. F(S("Cancel")) .. "]"

    local playerName                     = player and player:get_player_name() or nil
    local pn                             = playerName and k_colorblocks.gui_contexts[playerName] and k_colorblocks.gui_contexts[playerName].pointed_node or nil

    if pn and nil ~= pn.param2 then
        local texture = palettes.full.image .. "^[sheet:256x1:" .. pn.param2 .. ",0"

        formspec = formspec
            .. "label[0.5," .. (endtop + 0.2) .. ";" .. S("Pointed") .. "]"
            .. "label[0.5," .. (endtop + 0.4) .. ";" .. S("Block") .. "]"
            .. "label[0.5," .. (endtop + 0.6) .. ";" .. S("Color") .. "]"
            .. string.format(
                "image_button[%.4f,%.4f;0.5,0.5;%s;k_col;%d;false;false]",
                1.5,
                (endtop + 0.1),
                F(texture),
                pn.param2
            )
    end

    minetest.show_formspec(player:get_player_name(), "k_colorblocks_selector", formspec)
end

local function showWandGUI(player, pointed_thing)
    local playerName = player and player:get_player_name() or ""

    if "" == playerName then
        return
    end

    if nil == k_colorblocks.gui_contexts[playerName] then
        k_colorblocks.gui_contexts[playerName] = {}
    end

    if
        pointed_thing
        and "node" == pointed_thing.type
        and pointed_thing.under
    then
        local pointed_node = minetest.get_node(pointed_thing.under)

        if pointed_node and nil ~= k_colorblocks.nodes[pointed_node.name] then
            k_colorblocks.gui_contexts[playerName].pointed_thing = pointed_thing
            k_colorblocks.gui_contexts[playerName].pointed_node = pointed_node
        else
            k_colorblocks.gui_contexts[playerName].pointed_thing = nil
            k_colorblocks.gui_contexts[playerName].pointed_node = nil
        end
    end

    refreshWandGui(player)
end

-- use this way to allow press and hold application.
-- may have a performance impact
minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
    local playerName = puncher and puncher:get_player_name() or ""
    if
        "" ~= playerName
        and nil ~= k_colorblocks.nodes[node.name]
        and "k_colorblocks:wand" == puncher:get_wielded_item():get_name()
        and nil ~= k_colorblocks.gui_contexts[playerName]
        and nil ~= k_colorblocks.gui_contexts[playerName].current_col
    then
        -- print(dump(pos) .. dump(node))
        node.param2 = k_colorblocks.gui_contexts[playerName].current_col
        minetest.set_node(pos, node)
        --local meta = minetest.get_meta(pos)
        --meta:set_int("k_colorblocks_col", node.param2)
    end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    -- print(dump(formname) .. dump(fields))
    if "k_colorblocks_selector" ~= formname then
        return
    end

    local playerName = player and player:get_player_name() or nil


    if playerName and fields.k_col then
        k_colorblocks.gui_contexts[playerName].selected_col = tonumber(fields.k_col)
        refreshWandGui(player)
    end

    if fields.ok and k_colorblocks.gui_contexts[playerName].selected_col then
        k_colorblocks.gui_contexts[playerName].current_col = k_colorblocks.gui_contexts[playerName].selected_col
    end

    if fields.cancel or fields.quit then
        k_colorblocks.gui_contexts[playerName].pointed_thing = nil
    end
end)

-- minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
--     print(dump(newnode) .. itemstack:to_string())
-- end)

-- tool to switch things.
minetest.register_tool("k_colorblocks:wand", {
    description = S("Wand of the Application of the Kolor"),
    inventory_image = "k_colorblocks_wand.png",
    -- keep it to creative mode srsly
    -- tbd: range might not be working as expected sometimes?
    range = 40,
    wield_scale = { x = 1.5, y = 1.5, z = 1.5, },
    groups = { tool = 1, fire_immune = 1 },
    liquids_pointable = false,
    tool_capabilities = {
        full_punch_interval = 0,
        max_drop_level = 10,
        punch_attack_uses = 0,
    },
    _mcl_toollike_wield = true,
    -- so that it can't actually dig anything
	_mcl_diggroups = {
		handy = { speed = 0, level = 0, uses = 0 },
		hoey = { speed = 0, level = 0, uses = 0 },
		pickaxey = { speed = 0, level = 0, uses = 0 },
		shovely = { speed = 0, level = 0, uses = 0 },
		axey = { speed = 0, level = 0, uses = 0 },
		swordy = { speed = 0, level = 0, uses = 0 },
		swordy_cobweb = { speed = 0, level = 0, uses = 0 },
		shearsy_cobweb = { speed = 0, level = 0, uses = 0 }
	},
    -- on_use = function(stack, player, pt)
    --     apply_color(player, pt)
    --     return stack
    -- end,
    on_place = function(stack, player, pt)
        showWandGUI(player, pt)
    end,
    on_secondary_use = function(stack, player, pt)
        showWandGUI(player, pt)
    end,
})

-- at least one sound where possible.
local defaultNodeSound = {}

if minetest.get_modpath("default") then
    defaultNodeSound = default.node_sound_stone_defaults()
elseif minetest.get_modpath("mcl_sounds") then
    defaultNodeSound = mcl_sounds.node_sound_stone_defaults()
end


minetest.register_node("k_colorblocks:quartz_glow_block", {
    description = S("Stainable Glowing Block of Quartz"),
    is_ground_content = false,
    tiles = { "k_colorblocks_quartz_block_top.png", "k_colorblocks_quartz_block_top.png", "k_colorblocks_quartz_block_side.png" },
    groups = { pickaxey = 1, quartz_block = 1, building_block = 1, material_stone = 1, stonecuttable = 1, k_colorblocks = 1 },
    sounds = defaultNodeSound,
    light_source = quartzGlow,
    paramtype2 = "color",
    palette = palettes.full.image,
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
    palette = palettes.full.image,
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
        palette = palettes.full.image,
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
        palette = palettes.full.image,
        _mcl_blast_resistance = defaultBlastResistance,
        _mcl_hardness = defaultHardness,
    })
end
