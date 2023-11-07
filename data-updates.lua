local py_utils = require("__pypostprocessing__/prototypes/functions/utils")
require('__stdlib__/stdlib/data/data').Util.create_data_globals()

local function set_underground_recipe(underground, belt, prev_underground, prev_belt)
    local dist = data.raw['underground-belt'][underground].max_distance + 1
    local prev_dist = 0

    if prev_underground then
        prev_dist = data.raw['underground-belt'][prev_underground].max_distance + 1
        local recipe_data = data.raw.recipe[belt].normal or data.raw.recipe[belt]
        local belt_count = py_utils.standardize_products(recipe_data.results, nil, recipe_data.result, recipe_data.result_count)[1].amount
        local fluid = false

        for _, ing in pairs(py_utils.standardize_products(recipe_data.ingredients)) do
            if ing.name ~= prev_belt then
                RECIPE(underground):remove_ingredient(ing.name)
                    :add_ingredient{ type = ing.type, name = ing.name, amount = ing.amount * prev_dist / belt_count}

                if ing.type == "fluid" then fluid = true end
            end
        end

        if fluid and (RECIPE(underground).category or "crafting")  == "crafting" then
            RECIPE(underground):set_fields{ category = "crafting-with-fluid" }
        end
    end

    RECIPE(underground):remove_ingredient(belt):add_ingredient{ type = "item", name = belt, amount = dist - prev_dist}
end

if mods['boblogistics'] then
    set_underground_recipe("basic-underground-belt", "basic-transport-belt", nil, nil)
    set_underground_recipe("underground-belt", "transport-belt", "basic-underground-belt", "basic-transport-belt")
    set_underground_recipe("fast-underground-belt", "fast-transport-belt", "underground-belt", "transport-belt")
    set_underground_recipe("express-underground-belt", "express-transport-belt", "fast-underground-belt", "fast-transport-belt")
    set_underground_recipe("turbo-underground-belt", "turbo-transport-belt", "express-underground-belt", "express-transport-belt")
    set_underground_recipe("ultimate-underground-belt", "ultimate-transport-belt", "turbo-underground-belt", "turbo-transport-belt")
end

if register_cache_file ~= nil then
    register_cache_file({'pycoalprocessing', 'pyfusionenergy', 'pyindustry', 'pyrawores', 'pypetroleumhandling', 'pyalienlife', 'pyhightech', 'pyalternativeenergy', 'PyCoalTBaA'}, "__PyPPTBaA__/cached-configs/pyalienlife+pyalternativeenergy+pycoalprocessing+PyCoalTBaA+pyfusionenergy+pyhightech+pyindustry+pypetroleumhandling+pyrawores.lua")
end