local dev_mode = settings.startup["pypp-dev-mode"].value
local create_cache_mode = settings.startup["pypp-create-cache"].value

require('__stdlib__/stdlib/data/data').Util.create_data_globals()

local table = require('__stdlib__/stdlib/utils/table')
local config = require "__pypostprocessing__/prototypes/config"


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
-- PARSER
----------------------------------------------------

local data_parser = require('prototypes/functions/data_parser')
local parser = data_parser.create()
parser:run()

----------------------------------------------------
-- RECIPE CHANGES
----------------------------------------------------

require('prototypes/functions/global-item-replacer')

----------------------------------------------------
-- TECHNOLOGY CHANGES
----------------------------------------------------

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
            for _, ingredient in pairs(tech.unit.ingredients) do
                if ingredient.name == 'science-pack-gold' then
                    for i, ing in pairs(tech.unit.ingredients) do
                        if ing.name == 'automation-science-pack' then
                            tech.unit.ingredients[i] = nil
                            goto continue
                        end
                    end
                end
            end
        end
        ::continue::
    end
end

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

if mods['pyhightech'] and mods['bobelectronics'] then
    data.raw.item['electronic-circuit'].icon_size = 64
    data.raw.item['electronic-circuit'].icon = "__pyhightechgraphics__/graphics/icons/circuit-board-1.png"
    data.raw.item['advanced-circuit'].icon_size = 64
    data.raw.item['advanced-circuit'].icon = "__pyhightechgraphics__/graphics/icons/circuit-board-2.png"
    data.raw.item['processing-unit'].icon_size = 64
    data.raw.item['processing-unit'].icon = "__pyhightechgraphics__/graphics/icons/circuit-board-3.png"
    data.raw.item['intelligent-unit'].icon_size = 32
    data.raw.item['intelligent-unit'].icon = "__pyhightechgraphics__/graphics/icons/intelligent-unit.png"
end