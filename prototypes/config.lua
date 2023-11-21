local list = require "__pypostprocessing__.luagraphs.data.list"

local config = "__pypostprocessing__.prototypes.config"

config.GRAPHICS_MODS = list.fromArray { "__pyalienlifegraphics__", "__pyalienlifegraphics2__", "__pyalienlifegraphics3__",
        "__pyalternativeenergygraphics__", "__pycoalprocessinggraphics__", "__pyfusionenergygraphics__", "__pyhightechgraphics__",
        "__pyindustry__", "__pypetroleumhandlinggraphics__", "__pyraworesgraphics__", "__pyaliensgraphics__", "__pystellarexpeditiongraphics__",
        "__angelsrefining__", "__angelspetrochem__", "__angelssmelting__", "__angelsbioprocessing__", "__angelsindustries__", "__angelsexploration__",
    	}

return config