debugmode = debugmode or {}
debugmode.techcheck = settings.startup["debug-techcheck"].value
debugmode.logging = settings.startup["debug-logging"].value
if debugmode.logging then 
log(serpent.block(settings.startup)) 
if not mods['aai-loaders'] then
log(serpent.block(mods)) end 
end

local py_utils = require("__pypostprocessing__/prototypes/functions/utils")
if type(py_utils) == 'boolean' or py_utils == nil then
	error('\n\n\n\nPyanodons Post Processing Touched by an Angel failed to load properly! Please report this to the mod author.\nError details: Pyanodons Post Processing is not installed correctly.\n\n\n\n') 
end