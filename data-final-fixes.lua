local dev_mode = settings.startup["pypp-dev-mode"].value
local create_cache_mode = settings.startup["pypp-create-cache"].value

require('__stdlib__/stdlib/data/data').Util.create_data_globals()

local table = require('__stdlib__/stdlib/utils/table')
local config = require "__pypostprocessing__/prototypes/config"

require('prototypes/functions/global-item-replacer')

if data.raw.technology[settings.startup["log-technology"].value] ~= nil then
    log(serpent.block(data.raw.technology[settings.startup["log-technology"].value]))
end

if debugmode.techcheck then
    --This code is by fgardt
    for _, tech in pairs(data.raw.technology) do
        if not tech.prerequisites then goto continue end
        for _, prereq in pairs(tech.prerequisites) do
            if not data.raw.technology[prereq] then
                log(tech.name .. " is missing prereq: " .. prereq)
                log(serpent.block(tech))
            goto continue
            end
        end
        ::continue::
    end
end
----------------------------------------------------
-- TECHNOLOGY CHANGES
----------------------------------------------------

for name, technology in pairs(data.raw.technology) do
    local keep = technology.normal or technology.expensive
    if keep then
        for k,v in pairs(keep) do
            technology[k] = v
        end
        technology.normal = nil
        technology.expensive = nil
    end
end

for _, tech in pairs(data.raw.technology) do
    if tech.unit.ingredients then
        local inglist = {}
        for i, ingredient in pairs(tech.unit.ingredients) do
            table.insert(inglist, ingredient)
            tech.unit.ingredients[i] = nil
        end
        for _, ing in pairs(inglist) do 
            table.insert(tech.unit.ingredients, { type = "item", name = ing[1], amount = 1 })
        end
    end
end

for _, tech in pairs(data.raw.technology) do
    if tech.unit == nil then
        goto continue
    end

    -- Holds the final ingredients for the current tech
    local tech_ingredients_to_use = {}

    local add_military_science = false
    local highest_science_pack = 'automation-science-pack'
    -- Add the current ingredients for the technology
    for _, ingredient in pairs(tech.unit and tech.unit.ingredients or {}) do
        local pack = ingredient.name or ingredient[1]
        if pack ~= nil then
            if pack == "military-science-pack" and not config.TC_MIL_SCIENCE_IS_PROGRESSION_PACK then
                add_military_science = true
            elseif config.SCIENCE_PACK_INDEX[pack] then
                if config.SCIENCE_PACK_INDEX[highest_science_pack] < config.SCIENCE_PACK_INDEX[pack] then
                    highest_science_pack = pack
                end
            else -- not one of ours, sir
                tech_ingredients_to_use[pack] = ingredient.amount or ingredient[2]
            end
        end
    end

    -- Add any missing ingredients that we want present
    for _, ingredient in pairs(config.TC_TECH_INGREDIENTS_PER_LEVEL[highest_science_pack]) do
        tech_ingredients_to_use[ingredient.name or ingredient[1]] = ingredient.amount or ingredient[2]
    end
    -- Add military ingredients if applicable
    if add_military_science then
        tech_ingredients_to_use["military-science-pack"] = config.TC_MIL_SCIENCE_PACK_COUNT_PER_LEVEL[highest_science_pack]
    end
    -- Push a copy of our final list to .ingredients
    tech.unit.ingredients = {}
    for pack_name, pack_amount in pairs(tech_ingredients_to_use) do
        tech.unit.ingredients[#tech.unit.ingredients+1] = {name = pack_name, amount = pack_amount}
    end
    ::continue::
end

--[[
if mods['bobtech'] 
and data.raw.item["alien-artifact"]
and data.raw.item["alien-artifact-blue"]
and data.raw.item["alien-artifact-orange"]
and data.raw.item["alien-artifact-purple"]
and data.raw.item["alien-artifact-yellow"]
and data.raw.item["alien-artifact-green"]
and data.raw.item["alien-artifact-red"]
then
    for t, tech in pairs(data.raw.technology) do
        if tech.unit.ingredients then
            for i, ingredient in pairs(tech.unit.ingredients) do
                if ingredient.name == 'science-pack-gold' then
                    TECHNOLOGY(tech):remove_pack('automation-science-pack')
                    goto continue
                end
            end
        end
        ::continue::
    end
end
]]--

----------------------------------------------------
-- RECIPE INGREDIENTS DEDUPER
----------------------------------------------------
for i, ings in pairs(data.raw.recipe) do
    --log(serpent.block(ings))
    local inglist = {}
    if ings.ingredients ~= nil then
        for a, ing in pairs(ings.ingredients) do
            if ing.name ~= nil then
                if data.raw.item[ing.name] or data.raw.fluid[ing.name] or data.raw.module[ing.name] or data.raw.tool[ing.name] or data.raw.ammo[ing.name] then
                    if not inglist[ing.name] then
                        --log(serpent.block(ing))
                        --log(ing.name)
                        inglist[ing.name] = true
                    else
                        data.raw.recipe[ings.name].ingredients[a] = nil
                    end
                else
                    data.raw.recipe[ings.name].ingredients[a] = nil
                end
            elseif type(ing[1]) == 'string' then
                --log(serpent.block(ing))
                if not inglist[ing[1]] then
                    inglist[ing[1]] = true
                else
                    data.raw.recipe[ings.name].ingredients[a] = nil
                end
            end
        end
    end

    if ings.normal ~= nil then
        --log(serpent.block(ings))
        for a, ing in pairs(ings.normal.ingredients) do
            if ing.name ~= nil then
                if data.raw.item[ing.name] or data.raw.fluid[ing.name] or data.raw.module[ing.name] or data.raw.tool[ing.name] or data.raw.ammo[ing.name] then
                    if not inglist[ing.name] then
                        --log(serpent.block(ing))
                        --log(ing.name)
                        inglist[ing.name] = true
                    else
                        data.raw.recipe[ings.name].normal.ingredients[a] = nil
                    end
                else
                    data.raw.recipe[ings.name].normal.ingredients[a] = nil
                end
            elseif type(ing[1]) == 'string' then
                --log(serpent.block(ing))
                if not inglist[ing[1]] then
                    inglist[ing[1]] = true
                else
                    data.raw.recipe[ings.name].normal.ingredients[a] = nil
                end
            end
        end
    end
    --reset inglist for expensive ingredients
    inglist = {}

    if ings.expensive ~= nil then
        --log(serpent.block(ings))
        --log(serpent.block(ings.expensive))
        if ings.expensive ~= false then
            if ings.expensive.ingredients ~= nil then
                for a, ing in pairs(ings.expensive.ingredients) do
                    if ing.name ~= nil then
                        if data.raw.item[ing.name] or data.raw.fluid[ing.name] or data.raw.module[ing.name] or data.raw.tool[ing.name] or data.raw.ammo[ing.name] then
                            if not inglist[ing.name] then
                                --log(serpent.block(ing))
                                --log(ing.name)
                                inglist[ing.name] = true
                            else
                                data.raw.recipe[ings.name].expensive.ingredients[a] = nil
                            end
                        else
                            data.raw.recipe[ings.name].expensive.ingredients[a] = nil
                        end
                    elseif type(ing[1]) == 'string' then
                        --log(serpent.block(ing))
                        if not inglist[ing[1]] then
                            inglist[ing[1]] = true
                        else
                            data.raw.recipe[ings.name].expensive.ingredients[a] = nil
                        end
                    end
                end
            end
        end
    end
end

data.raw.item['electronic-circuit'].icon_size = 64
data.raw.item['electronic-circuit'].icon = "__pyhightechgraphics__/graphics/icons/circuit-board-1.png"
data.raw.item['advanced-circuit'].icon_size = 64
data.raw.item['advanced-circuit'].icon = "__pyhightechgraphics__/graphics/icons/circuit-board-2.png"
data.raw.item['processing-unit'].icon_size = 64
data.raw.item['processing-unit'].icon = "__pyhightechgraphics__/graphics/icons/circuit-board-3.png"
data.raw.item['intelligent-unit'].icon_size = 32
data.raw.item['intelligent-unit'].icon = "__pyhightechgraphics__/graphics/icons/intelligent-unit.png"
