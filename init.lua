local S = minetest.get_translator(minetest.get_current_modname())
local F = minetest.formspec_escape


k_colorblocks = {
    hueMap = dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/data.lua"),
    palettes = {
        full = {
            image = "k_colorblocks_palette_color_full.png",
            formspec = function(self, player)
                local primary = {
                    "Reds",
                    "Greens",
                    "Blues",
                }
                local cellSize = k_colorblocks.gui_config.cell
                local pad = k_colorblocks.gui_config.pad
                local grids = {
                    -- grey
                    { top = pad * 2, left = pad, istart = 0, iend = 14, w = 15, label = "Greyscale", },
                }

                -- texture index pointer for rest of palette
                local idx = 15


                for p = 1, #primary, 1 do
                    local colstart = 1 + ((p - 1) * 4)
                    local colend = colstart + 3

                    for c = colstart, colend, 1 do
                        local row = (c - 1) % 4
                        local hueAngle = "" .. 30 * (c - 1)
                        table.insert(grids, { top = 1.55 + (2.25 * row), left = pad + ((p - 1) * 2.75), istart = idx, iend = (idx + 19), w = 5, label = k_colorblocks.hueMap[hueAngle] or "" })
                        idx = idx + 20
                    end
                end
                local formspecParts = {}
                local endleft = 0
                local endtop = 0
                for i = 1, #grids, 1 do
                    local formspec, eleft, etop = k_colorblocks:buildColorGrid(grids[i].left, grids[i].top, self.image, grids[i].istart, grids[i].iend, grids[i].w, player)
                    endleft = eleft
                    endtop = etop
                    table.insert(formspecParts, formspec)
                    -- add labels on top
                    table.insert(formspecParts, "label[" .. (grids[i].left) .. "," .. (grids[i].top - 0.1) .. ";" .. F(S(grids[i].label)) .. "]")
                end
                -- 255 is transparent for no reason
                local formspec, _, _ = k_colorblocks:buildColorGrid(grids[1].left + (grids[1].w * cellSize), grids[1].top, self.image, 255, 255, 1, player)
                table.insert(formspecParts, formspec)


                return table.concat(formspecParts), endleft, endtop
            end,
        },
        grey = {
            image = "k_colorblocks_palette_grey_full.png",
            formspec = function(self, player)
                local pad = k_colorblocks.gui_config.pad
                local formspec, eleft, etop = k_colorblocks:buildColorGrid((pad * 2), pad, self.image, 0, 255, 16, player)
                formspec = formspec .. "label[" .. pad .. ",0.7;" .. F(S("Greyscale")) .. "]"
            end,
        }
    },
    -- map of nodes we can apply colours to for quicker lookup.
    nodes = {},
    -- per player gui context
    gui_contexts = {},
    gui_config = {
        cell = 0.5,
        pad = 0.4,
    },
    -- @param offsetLeft    x offset in form
    -- @param offsetTop     y offset in form
    -- @param palette     texture which is a single line of color
    -- @param startIdx    zero index start position on palette
    -- @param endIdx    zero index end position on palette
    -- @param width    width of grid
    buildColorGrid = function(self, offsetLeft, offsetTop, palette, startIdx, endIdx, width, player)
        local parts = {}
        local offsetEndLeft = offsetLeft
        local offsetEndTop = offsetTop

        local playerName = player and player:get_player_name() or nil

        local selectedCol = playerName and self.gui_contexts[playerName] and self.gui_contexts[playerName].selected_col or nil
        local currentCol = playerName and self.gui_contexts[playerName] and self.gui_contexts[playerName].current_col or nil
        local currentColAux = playerName and self.gui_contexts[playerName] and self.gui_contexts[playerName].current_col_aux or nil

        local cellSize = self.gui_config.cell
        --image_button[<X>,<Y>;<W>,<H>;<texture name>;<name>;<label>]

        for idx = startIdx, endIdx, 1 do
            local localIdx = idx - startIdx
            local left = (math.floor(localIdx % width) * cellSize) + offsetLeft
            local top = (math.floor(localIdx / width) * cellSize) + offsetTop

            local texture = palette .. "^[sheet:256x1:" .. idx .. ",0"

            if selectedCol and selectedCol == idx then
                texture = "(" .. texture .. ")^k_colorblocks_selected_gui.png"
            end
            if currentCol and currentCol == idx then
                texture = "(" .. texture .. ")^k_colorblocks_selected_wand.png"
            end
            if currentColAux and currentColAux == idx then
                texture = "(" .. texture .. ")^k_colorblocks_selected_wand_aux.png"
            end

            table.insert(parts, string.format(
                "image_button[%.4f,%.4f;%.4f,%.4f;%s;k_col;%d;false;false]",
                left,
                top,
                cellSize,
                cellSize,
                F(texture),
                idx
            ))
            offsetEndLeft = left + cellSize
            offsetEndTop = top + cellSize
        end

        return table.concat(parts, ""), offsetEndLeft, offsetEndTop
    end,
    showWandGUI = function(self, player, pointed_thing)
        local playerName = player and player:get_player_name() or ""

        if "" == playerName then
            return
        end

        if nil == self.gui_contexts[playerName] then
            self.gui_contexts[playerName] = {
                current_col = 0,
                current_col_size = 0,
                current_col_aux = 0,
                current_col_aux_size = 0,
            }
        end

        self.gui_contexts[playerName].pointed_thing = nil
        self.gui_contexts[playerName].pointed_node = nil

        if
            pointed_thing
            and "node" == pointed_thing.type
            and pointed_thing.under
        then
            local pointed_node = minetest.get_node(pointed_thing.under)
            if pointed_node and nil ~= self.nodes[pointed_node.name] then
                self.gui_contexts[playerName].pointed_thing = pointed_thing
                self.gui_contexts[playerName].pointed_node = pointed_node
            end
        end

        self:refreshWandGui(player)
    end,
    refreshWandGui = function(self, player)
        local formspecgrids, endleft, endtop = self.palettes.full:formspec(player)
        local cell                           = self.gui_config.cell
        local pad                            = self.gui_config.pad

        local formspec                       = "size[" .. (endleft + pad) .. "," .. (endtop + 0.9) .. "]"
            .. "padding[0,0]"
            .. "real_coordinates[true]"
            .. "style_type[*,...;font_size=11]" -- smaller font on everything so it fits.
            .. "hypertext[0.3,0.2;4,0.5;title;" .. S("K Color Picker") .. "]"
            .. formspecgrids
            .. "button_exit[" .. (endleft - 2.0) .. "," .. (endtop + 0.2) .. ";0.7,0.6;ok_aux;" .. F(S("Aux")) .. "]"
            .. "tooltip[ok_aux;" .. S("Set Aux Color and Exit") .. "]"
            .. "button_exit[" .. (endleft - 1.3) .. "," .. (endtop + 0.2) .. ";0.7,0.6;ok;" .. F(S("OK")) .. "]"
            .. "tooltip[ok;" .. S("Set Main Color and Exit") .. "]"
            .. "button_exit[" .. (endleft - 0.6) .. "," .. (endtop + 0.2) .. ";0.9,0.6;cancel;" .. F(S("Cancel")) .. "]"

        local playerName                     = player and player:get_player_name() or nil
        local pn                             = playerName and self.gui_contexts[playerName] and self.gui_contexts[playerName].pointed_node or nil

        -- @todo refactor bottom tiles
        if pn and nil ~= pn.param2 then
            local texture = self.palettes.full.image .. "^[sheet:256x1:" .. pn.param2 .. ",0"

            formspec = formspec
                .. "label[" .. pad .. "," .. (endtop + 0.2) .. ";" .. S("Pointed:") .. "]"
                .. string.format(
                    "image_button[%.4f,%.4f;" .. cell .. "," .. cell .. ";%s;k_col;%d;false;false]",
                    pad,
                    (endtop + 0.3),
                    F(texture),
                    pn.param2
                )
        end

        if nil ~= self.gui_contexts[playerName].current_col then
            local texture = self.palettes.full.image .. "^[sheet:256x1:" .. self.gui_contexts[playerName].current_col .. ",0"

            formspec = formspec
                .. "label[" .. (pad + cell * 2) .. "," .. (endtop + 0.2) .. ";" .. S("Main:") .. "]"
                .. string.format(
                    "image_button[%.4f,%.4f;" .. cell .. "," .. cell .. ";%s;k_col;%d;false;false]",
                    (pad + cell * 2),
                    (endtop + 0.3),
                    F(texture),
                    self.gui_contexts[playerName].current_col
                )
                .. string.format(
                    "dropdown[%.4f,%.4f;" .. cell .. "," .. cell .. ";selected_col_size;0,1,2,3,4,5,6,7,8,9;%d]",
                    --"field[%.4f,%.4f;0.4,0.5;current_col_size;;%d]",
                    (pad + cell * 3),
                    (endtop + 0.3),
                    (self.gui_contexts[playerName].selected_col_size or self.gui_contexts[playerName].current_col_size or 0) + 1
                )
                .. "tooltip[current_col_size;" .. S("Main Color Wand Radius") .. "]"
        end

        if nil ~= self.gui_contexts[playerName].current_col_aux then
            local texture = self.palettes.full.image .. "^[sheet:256x1:" .. self.gui_contexts[playerName].current_col_aux .. ",0"

            formspec = formspec
                .. "label[" .. (pad + cell * 4) .. "," .. (endtop + 0.2) .. ";" .. S("Aux:") .. "]"
                .. string.format(
                    "image_button[%.4f,%.4f;" .. cell .. "," .. cell .. ";%s;k_col;%d;false;false]",
                    (pad + cell * 4),
                    (endtop + 0.3),
                    F(texture),
                    self.gui_contexts[playerName].current_col_aux
                )
                .. string.format(
                    "dropdown[%.4f,%.4f;" .. (cell) .. "," .. cell .. ";selected_col_aux_size;0,1,2,3,4,5,6,7,8,9;%d]",
                    -- "field[%.4f,%.4f;0.4,0.5;current_col_aux_size;;%d]",
                    (pad + cell * 5),
                    (endtop + 0.3),
                    (self.gui_contexts[playerName].selected_col_aux_size or self.gui_contexts[playerName].current_col_aux_size or 0) + 1
                )
                .. "tooltip[current_col_aux_size;" .. S("Aux Color Wand Radius") .. "]"
        end

        minetest.show_formspec(player:get_player_name(), "k_colorblocks_selector", formspec)
    end,
    cacheNode = function(self, nodename)
        if "string" == type(nodename) then
            self.nodes[nodename] = 1
        end
    end,
}

-- use this way to allow press and hold application.
-- may have a performance impact
minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
    local playerName = puncher and puncher:get_player_name() or ""

    if
    -- @todo simplify these checks
        "" ~= playerName
        and nil ~= k_colorblocks.nodes[node.name]
        and nil ~= k_colorblocks.gui_contexts[playerName]
        and "k_colorblocks:wand" == puncher:get_wielded_item():get_name()
    then
        local pc = puncher:get_player_control()
        local newCol = nil
        local radius = 0

        if pc.aux1 and nil ~= k_colorblocks.gui_contexts[playerName].current_col_aux then
            newCol = k_colorblocks.gui_contexts[playerName].current_col_aux
            radius = k_colorblocks.gui_contexts[playerName].current_col_aux_size
        elseif nil ~= k_colorblocks.gui_contexts[playerName].current_col then
            newCol = k_colorblocks.gui_contexts[playerName].current_col
            radius = k_colorblocks.gui_contexts[playerName].current_col_size
        end

        if nil == newCol then
            return
        end

        -- checks colour change to maybe prevents extra node changes
        if newCol ~= node.param2 and 0 == radius then
            -- print(dump("set "..newCol).. dump(node))
            node.param2 = newCol
            minetest.set_node(pos, node)
            return
        end

        -- only paint the surface
        local faceDir = vector.direction(pointed_thing.above, pointed_thing.under)
        local axesToPaint = {}
        local axisToSkip = ""
        local axisToSkipDir = 0

        for axis, value in pairs(faceDir) do
            if 0 == value then
                table.insert(axesToPaint, axis)
            else
                axisToSkip = axis
                axisToSkipDir = value
            end
        end
        for i = (-1 * radius), radius, 1 do
            for j = (-1 * radius), radius, 1 do
                local delta = {}
                delta[axesToPaint[1]] = i
                delta[axesToPaint[2]] = j
                delta[axisToSkip] = 0
                local deltaPos = vector.add(pos, delta)

                local deltaNode = minetest.get_node(deltaPos)
                if
                    nil ~= deltaNode
                    and nil ~= k_colorblocks.nodes[deltaNode.name]
                    and newCol ~= deltaNode.param2
                then
                    deltaNode.param2 = newCol
                    minetest.set_node(deltaPos, deltaNode)
                end
            end
        end


        --local meta = minetest.get_meta(pos)
        --meta:set_int("k_colorblocks_col", node.param2)
    end
end)

local dblclkTime = tonumber(0)
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if "k_colorblocks_selector" ~= formname then
        return
    end

    local playerName = player and player:get_player_name() or nil
    local selected = 0

    if playerName and nil ~= fields.k_col then
        selected = tonumber(fields.k_col)
        k_colorblocks.gui_contexts[playerName].selected_col = selected

        -- track selected brush sizes temporarily
        k_colorblocks.gui_contexts[playerName].selected_col_size = math.abs(tonumber(fields.selected_col_size) or 0)
        k_colorblocks.gui_contexts[playerName].selected_col_aux_size = math.abs(tonumber(fields.selected_col_aux_size) or 0)

        k_colorblocks:refreshWandGui(player)

        local newDblclkTime = tonumber(minetest.get_us_time())
        -- registers a "double click" on a color
        if 333333 > (newDblclkTime - dblclkTime) then
            fields.ok = 1
            minetest.close_formspec(playerName, "k_colorblocks_selector")
        end
        dblclkTime = newDblclkTime
    end

    if k_colorblocks.gui_contexts[playerName].selected_col then
        if fields.ok then
            k_colorblocks.gui_contexts[playerName].current_col = k_colorblocks.gui_contexts[playerName].selected_col
        end

        if fields.ok_aux then
            k_colorblocks.gui_contexts[playerName].current_col_aux = k_colorblocks.gui_contexts[playerName].selected_col
        end
    end

    -- don't need to track brush sizes past this point
    k_colorblocks.gui_contexts[playerName].selected_col_size = nil
    k_colorblocks.gui_contexts[playerName].selected_col_aux_size = nil
    if fields.ok then
        k_colorblocks.gui_contexts[playerName].current_col_size = math.abs(tonumber(fields.selected_col_size) or 0)
        k_colorblocks.gui_contexts[playerName].selected_col_aux_size = math.abs(tonumber(fields.selected_col_aux_size) or 0)
    end

    if fields.ok_aux then
        k_colorblocks.gui_contexts[playerName].current_col_aux_size = math.abs(tonumber(fields.selected_col_aux_size) or 0)
        k_colorblocks.gui_contexts[playerName].selected_col_aux_size = math.abs(tonumber(fields.selected_col_aux_size) or 0)
    end

    -- print(dump(fields)..dump(k_colorblocks.gui_contexts[playerName]))
end)

-- minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
--     print(dump(newnode) .. itemstack:to_string())
-- end)

-- really prevent digging things up.
local nodigcap = { times = { [1] = math.huge, [2] = math.huge, [3] = math.huge }, uses = 0, maxlevel = 1 }
-- tool to switch things.
minetest.register_tool("k_colorblocks:wand", {
    description = S("Wand of the Application of the Kolor"),
    inventory_image = "k_colorblocks_wand.png",
    -- keep it to creative mode srsly
    -- tbd: range might not be working as expected sometimes?
    range = 200,
    light_level = 14,
    wield_scale = { x = 1.0, y = 1.0, z = 1.0, },
    groups = { tool = 1, fire_immune = 1 },
    liquids_pointable = false,
    tool_capabilities = {
        full_punch_interval = 0,
        max_drop_level = 0,
        groupcaps = {
            bendy                   = nodigcap,
            pickaxey                = nodigcap,
            snappy                  = nodigcap,
            fleshy                  = nodigcap,
            cracky                  = nodigcap,
            choppy                  = nodigcap,
            crumbly                 = nodigcap,
            unbreakable             = nodigcap,
            dig_immediate           = nodigcap,
            oddly_breakable_by_hand = nodigcap,
        },
        damage_groups = { fleshy = 0, cracky = 0, },
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
    on_place = function(stack, player, pt)
        k_colorblocks:showWandGUI(player, pt)
    end,
    on_secondary_use = function(stack, player, pt)
        k_colorblocks:showWandGUI(player, pt)
    end,
})


-- node registration
dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/nodes.lua")
