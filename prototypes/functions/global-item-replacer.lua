local dr = data.raw
local dri = dr.item
local drf = dr.fluid
local drr = dr.recipe

local function find_type(item)
    if dri[item] then return 'item' end
    if drf[item] then return 'fluid' end
    for prototype in pairs(defines.prototypes.item) do
        if dr[prototype][item] then return prototype end
    end
    return nil
end

local blacklisted_recipes = {}
local old_to_new = {}

local function add_blacklist(blacklisted_recipes)
    if type(blacklisted_recipes) ~= 'table' then
        blacklisted_recipes = {blacklisted_recipes}
    end

    for b, blacklisted_recipe in pairs(blacklisted_recipes) do
        blacklisted_recipes[blacklisted_recipe] = true
    end
end

--replace an item/fluid in every recipes ingredients/results
--best used to merge items that are duplicated in mods that should be the same
local function global_item_replacer(old, new, blacklisted_recipe)
    if not find_type(old) or not find_type(new) then
        log('WARNING: global_item_replacer failed for ' .. old .. ' -> ' .. new)
        return
    end
    old_to_new[old] = new
end

local function replace(product)
    if product[1] then
        product.name = product[1]
        product.amount = product[2]
        product.type = 'item'
        product[1] = nil
        product[2] = nil
    end
    local new = old_to_new[product.name]
    product.name = new
    if drf[new] then product.type = 'fluid' end
end

local function process_recipe(recipe)
    if recipe and recipe.ingredients and recipe.results then
        for _, ingredient in pairs(recipe.ingredients) do
            if old_to_new[ingredient.name or ingredient[1]] then replace(ingredient) end
        end
        for _, result in pairs(recipe.results) do
            if old_to_new[result.name or result[1]] then replace(result) end
        end
        if recipe.main_product and old_to_new[recipe.main_product] then
            recipe.main_product = old_to_new[recipe.main_product]
        end
    end
end

local function finalize()
    for name, recipe in pairs(drr) do
        if not blacklisted_recipes[name] then
            process_recipe(recipe)
            --process_recipe(recipe.normal)
            --process_recipe(recipe.expensive)
        end
    end

    for old, _ in pairs(old_to_new) do
        local old_type = find_type(old)
        local prototype = dr[old_type][old]
        local place_result = prototype.place_result
        if place_result then
            for name, type in pairs(dr) do
                if name ~= old_type and type[place_result] then
                    break
                end
            end
        end
    end
end

local function no_blacklist_finalize()
    for name, recipe in pairs(drr) do
        process_recipe(recipe)
        process_recipe(recipe.normal)
        process_recipe(recipe.expensive)
    end

    for old, _ in pairs(old_to_new) do
        local old_type = find_type(old)
        local prototype = dr[old_type][old]
        local place_result = prototype.place_result
        if place_result then
            for name, type in pairs(dr) do
                if name ~= old_type and type[place_result] then
                    break
                end
            end
        end
    end
end


local function building_item_replacer(old, new)
    if dri[old] ~= nil then
        if dri[new] ~= nil then
            local recipes = table.deepcopy(drr)
            for recipe in pairs(recipes) do
                fun.ingredient_replace(recipe, old, new)
                fun.results_replacer(recipe, old, new)
            end
        end
    end
end

global_item_replacer('coke', 'solid-coke')
global_item_replacer('limestone', 'solid-limestone')
global_item_replacer('acidgas', 'gas-acid')
global_item_replacer('salt', 'solid-salt')
global_item_replacer('sand', 'solid-sand')
global_item_replacer('syngas', 'gas-synthesis')
global_item_replacer('methanol', 'gas-methanol')
global_item_replacer('carbon-dioxide', 'gas-carbon-dioxide')
global_item_replacer('carbon', 'solid-carbon')
global_item_replacer('lime', 'solid-lime')
global_item_replacer('angels-plate-chrome', 'chromium')
global_item_replacer('solid-clay', 'clay')
global_item_replacer('phenolic-board', 'phenolicboard')
global_item_replacer('fibreglass-board', 'fiberglass')
global_item_replacer('solid-fertilizer', 'fertiliser')
global_item_replacer('benzene', 'gas-benzene')
global_item_replacer('propene', 'gas-propene')
global_item_replacer('acetone', 'gas-acetone')
global_item_replacer('chloromethane', 'gas-chlor-methane')
global_item_replacer('methane', 'gas-methane')
global_item_replacer('methanal', 'gas-formaldehyde')
global_item_replacer('ammonia', 'gas-ammonia')
global_item_replacer('ech', 'gas-epichlorhydrin')
global_item_replacer('ethylene', 'gas-ethylene')
global_item_replacer('glass-fiber', 'angels-coil-glass-fiber')
global_item_replacer('wooden-board', 'fiberboard')
global_item_replacer('advanced-processing-unit', 'intelligent-unit')
global_item_replacer('superior-circuit-board', 'intelligent-unit')
global_item_replacer('electronic-components', 'transistor')
global_item_replacer('basic-electronic-components', 'resistor2')
global_item_replacer('processing-electronics', 'kondo-processor')
global_item_replacer('intergrated-electronics', 'microchip')
global_item_replacer('module-processor-board', 'pcb2')
global_item_replacer('module-processor-board-2', 'pcb3')
global_item_replacer('module-processor-board-3', 'pcb4')
global_item_replacer('multi-layer-circuit-board', 'pcb4')
global_item_replacer('solid-sodium-chlorate', 'sodium-chlorate')
global_item_replacer('black-liquor', 'liquid-black-liquor')
global_item_replacer('acetic-acid', 'liquid-acetic-acid')
global_item_replacer('bio-raw-meat', 'meat')
global_item_replacer('liquid-molten-aluminium', 'molten-aluminium')
global_item_replacer('liquid-molten-copper', 'molten-copper')
global_item_replacer('liquid-molten-iron', 'molten-iron')
global_item_replacer('liquid-molten-lead', 'molten-lead')
global_item_replacer('liquid-molten-silver', 'molten-silver')
global_item_replacer('liquid-molten-nickel', 'molten-nickel')
global_item_replacer('liquid-molten-steel', 'molten-steel')
global_item_replacer('liquid-molten-tin', 'molten-tin')
global_item_replacer('liquid-molten-titanium', 'molten-titanium')
global_item_replacer('liquid-molten-zinc', 'molten-zinc')
global_item_replacer('liquid-molten-chrome', 'molten-chromium')
global_item_replacer('hydrogen', 'gas-hydrogen')
global_item_replacer('chlorine', 'gas-chlorine')
global_item_replacer('oxygen', 'gas-oxygen')
global_item_replacer('nitrogen', 'gas-nitrogen')
global_item_replacer('hydrogen-chloride', 'gas-hydrogen-chloride')
global_item_replacer('solid-salt', 'salt')
global_item_replacer('solid-sodium-carbonate', 'sodium-carbonate')
global_item_replacer('solid-sodium-hydroxide', 'sodium-hydroxide')
global_item_replacer('solid-sodium-sulfate', 'sodium-sulfate')
global_item_replacer('liquid-fuel-oil', 'fuel-oil')
global_item_replacer('glycerol', 'liquid-glycerol')
global_item_replacer('empty-petri-dish', 'petri-dish')
global_item_replacer('basic-circuit-board', 'pcb1')
global_item_replacer('centrifuge', 'centrifuge-mk01')
global_item_replacer('centrifuge-2', 'centrifuge-mk02')
global_item_replacer('centrifuge-3', 'centrifuge-mk03')
global_item_replacer('bob-valve', 'py-check-valve')
global_item_replacer('bob-overflow-valve', 'py-overflow-valve')
global_item_replacer('bob-topup-valve', 'py-underflow-valve')
global_item_replacer('construction-robot', 'py-construction-robot-01')
global_item_replacer('filtration-unit', 'carbon-filter')
global_item_replacer('filtration-unit-2', 'carbon-filter-mk02')
global_item_replacer('filtration-unit-3', 'carbon-filter-mk03')
global_item_replacer('ore-floatation-cell', 'flotation-cell-mk01')
global_item_replacer('ore-floatation-cell-2', 'flotation-cell-mk02')
global_item_replacer('ore-floatation-cell-3', 'flotation-cell-mk03')
global_item_replacer('ore-leaching-plant', 'leaching-station-mk01')
global_item_replacer('ore-leaching-plant-2', 'leaching-station-mk02')
global_item_replacer('ore-leaching-plant-3', 'leaching-station-mk03')
global_item_replacer('barreling-pump', 'barrel-machine-mk01')
global_item_replacer('silicon','angels-mono-silicon')
global_item_replacer('silicon-carbide','sic')
global_item_replacer('wood-charcoal','charcoal-briquette')
global_item_replacer('resin','saps')
global_item_replacer('solid-soil','soil')
global_item_replacer('pressured-air','gas-compressed-air')
--global_item_replacer('pcb1','circuit-red')
global_item_replacer('cellulose','cellulose-fiber')
global_item_replacer('quartz-crucible','angels-quartz-crucible')
global_item_replacer('tinned-copper-cable','tinned-cable')
global_item_replacer('battery-equipment','battery-mk01')
global_item_replacer('battery-mk2-equipment','nexelit-battery')
global_item_replacer('liquid-naphtha','naphtha')
global_item_replacer('residual-gas','gas-residual')
--aluminium
global_item_replacer('ore-aluminium','bauxite-ore')
global_item_replacer('aluminium-plate','angels-plate-aluminium')
--chrome
global_item_replacer('ore-chromium','chrome-ore')
--lead
global_item_replacer('ore-lead','lead-ore')
global_item_replacer('lead-plate','angels-plate-lead')
--nickel
global_item_replacer('ore-nickel','nickel-ore')
global_item_replacer('nickel-plate','angels-plate-nickel')
--tin
global_item_replacer('ore-tin','tin-ore')
global_item_replacer('tin-plate','angels-plate-tin')
--zinc
global_item_replacer('ore-zinc','zinc-ore')
global_item_replacer('zinc-plate','angels-plate-zinc')

--This will totally make it load faster, with no bugs whatsoever
if blacklisted_recipes[1] ~= nil then
    finalize()
else
    no_blacklist_finalize()
end

--buildings
building_item_replacer('washer', 'washing-plant')
building_item_replacer('washer-mk02', 'washing-plant-2')
building_item_replacer('coke', 'solid-coke')
building_item_replacer('solid-soil','soil')
building_item_replacer('basic-circuit-board', 'pcb1')
building_item_replacer('fibreglass-board', 'fiberglass')
building_item_replacer('intergrated-electronics', 'microchip')