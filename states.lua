--states.lua
--
--By S. Baranov (spellsweaver@gmail.com)
--For love2d 11.1
-------------
--How to use
-------------
--In main.lua
--states = require("states")
--in love.load() call states.setup()
--From now on, states library will redirect love2d callbacks from your main.lua to state files
--Each state file should be located in "states/" directory and return a table of callbacks that correspond to love2d callbacks
--If you want your callbacks to be state-independant, keep them in your main.lua. This way states library will not redirect them to states.
--If you want a callback to have both state-dependant and state-independant part, 
--keep in in main.lua and call states.(callback name) within love 2d callback
--To switch states (you should probably do this immediately after initialising) use states.switch(filename,params)
--Filename is a name of your state file, while params is a table that will be caught by .open callback within according state file
--Through params you can transfer data to your state files conveniently

--------------

local states = {}

--private variables
local stateFiles = {}

local currentState = "default"

local love2dCallbacksList =
	--except load and errorhandler
	{
		"keypressed",
		"keyreleased",
		"filedropped",
		"directorydropped",
		"draw",
		"update",
		"wheelmoved",
		"mousepressed",
		"mousemoved",
		"mousereleased",
		"textinput",
		"focus",
		"lowmemory",
		"mousefocus",
		"resize",
		"quit",
		"threaderror",
		"visible"
	}

--private functions
local function defaultInitialize(stateFile)
	--fill in dummy functions instead of omitted ones
	for _,callback in pairs(love2dCallbacksList) do
		stateFile[callback] = stateFile[callback] or function() end
		--open callback is run when switching state
		stateFile.open = stateFile.open or function() end
	end
end

local function add(stateName)
	stateFiles[stateName] = require("states/"..stateName)
	defaultInitialize(stateFiles[stateName])
end

--public functions
function states.setup()
	for _,callback in pairs(love2dCallbacksList) do
		states[callback] = 		
		function(...)
			stateFiles[currentState][callback](unpack({...}))
		end
		love[callback] = love[callback] or states[callback]
	end
end

function states.switch(newState,params)
	if not stateFiles[newState] then
		add(newState)
	end

	currentState = newState
	local params = type(params)=="table" and params or {}
	stateFiles[newState].open(params)
end

return states