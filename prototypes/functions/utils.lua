local table = require "__stdlib__.stdlib.utils.table"
local string = require "__stdlib__.stdlib.utils.string"
local config = require "__PyPPTBaA__.prototypes.config"

local defines = require "__pypostprocessing__.prototypes.functions.defines"

local utils = require "__pypostprocessing__.prototypes.functions.utils"

function utils.is_accepted_tech(tech)
    local icons = tech.icons
    if not icons then icons = {{ icon = tech.icon }} end

    for _, icon in pairs(icons or {}) do
        local mod = icon and table.first(string.split(icon.icon, '/'))

        if not config.GRAPHICS_MODS:contains(mod) and mod ~= '__base__' and mod ~= '__core__' then
            return false
        end
    end

    return true
end

return utils