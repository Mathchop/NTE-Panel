local UserInputService = game:GetService("UserInputService")
local Config = _G.gitRequire("./Config")
local Utils = _G.gitRequire("./Utils")

local UIPanel = _G.gitRequire("./UIPanel")
local NpcAutoKill = _G.gitRequire("./Autos/NpcAutoKill")
local ScrollsAutoPicker = _G.gitRequire("./Autos/ScrollsAutoPicker")

local HACKS_TOGGLE_KEY = Enum.KeyCode.T

local NTE = {}

function NTE.start()
	Utils.log("NTE STARTING")
	
	UIPanel.init()
	
	UIPanel.setSideInfo("hacksEnabled", "Hacks enabled: "..tostring(Config.HacksEnabled))
	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
		if gameProcessedEvent then
			return
		end

		if input.KeyCode == HACKS_TOGGLE_KEY then
			Config.HacksEnabled = not Config.HacksEnabled
			Utils.log("TOGGLING HACK TO "..tostring(Config.HacksEnabled))
			UIPanel.setSideInfo("hacksEnabled", "Hacks enabled: "..tostring(Config.HacksEnabled))
		end
	end)
	
	task.spawn(function()
		while task.wait(0.1) do
			NpcAutoKill.loop()
			ScrollsAutoPicker.loop()
		end
	end)
end

return NTE
