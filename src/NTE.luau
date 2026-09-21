local UserInputService = game:GetService("UserInputService")
local NTEConfig = _G.gitRequire("./NTEConfig")

local UIPanel = _G.gitRequire("./UIPanel")
local ScrollsAutoPicker = _G.gitRequire("./ScrollsAutoPicker")

local HACKS_TOGGLE_KEY = Enum.KeyCode.T

local NTE = {}

function NTE.start()
	print("NTE STARTING")
	
	UIPanel.init()
	
	UIPanel.setSideInfo("hacksEnabled", "Hacks enabled: "..tostring(NTEConfig.HacksEnabled))
	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
		if gameProcessedEvent then
			return
		end

		if input.KeyCode == HACKS_TOGGLE_KEY then
			print("TOGGLING HACK TO ", not NTEConfig.HacksEnabled)
			NTEConfig.HacksEnabled = not NTEConfig.HacksEnabled
			UIPanel.setSideInfo("hacksEnabled", "Hacks enabled: "..tostring(NTEConfig.HacksEnabled))
		end
	end)
	
	ScrollsAutoPicker.start()
end

return NTE
