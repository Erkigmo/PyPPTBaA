local table = require('__stdlib__/stdlib/utils/table')
local config = require "__pypostprocessing__/prototypes/config"

local data_parser = {}
data_parser.__index = data_parser

local logging = settings.startup["pypp-verbose-logging"].value

function data_parser.create()
    local d = {}

    setmetatable(d, data_parser)

    d.processed_techs = {}
    d.processed_recipes = {}
    d.processed_items = {}
    d.processed_fluids = {}

    return d
end


function data_parser:run()
	for _, recipe in pairs(data.raw.recipe) do
        if recipe.enabled ~= false and not recipe.hidden then
            self:parse_recipe(recipe)
        end
    end
    if logging then
    	log('Parsed Recipes for PyPPTBaA:')
    	log(serpent.block(self.processed_recipes))
    end
	
	for _, tech in pairs(data.raw.technology) do
        if tech.enabled ~= false and not tech.hidden then
            self:parse_tech(tech)
        end
    end
    if logging then
    	log('Parsed techs for PyPPTBaA:')
    	log(serpent.block(self.processed_techs))
    end
end

function data_parser:parse_recipe(recipe)
	if self.processed_recipes[recipe] then
        return
    else
        self.processed_recipes[recipe] = true
    end
    local keep = recipe.normal or recipe.expensive
    if keep then
        for k,v in pairs(keep) do
            recipe[k] = v
        end
        recipe.normal = nil
       	recipe.expensive = nil
    end
end

function data_parser:parse_tech(tech)
	if self.processed_techs[tech.name] then
        return
    else
       self.processed_techs[tech.name] = true
    end

    local keep = tech.normal or tech.expensive
    if keep then
        for k,v in pairs(keep) do
            tech[k] = v
        end
        tech.normal = nil
        tech.expensive = nil
    end
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

return data_parser