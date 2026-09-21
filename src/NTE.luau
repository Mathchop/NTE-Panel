local UserInputService = game:GetService("UserInputService")
local NTEConfig = require("./NTEConfig")

local ScrollsAutoPicker = require("./ScrollsAutoPicker")

local HACKS_TOGGLE_KEY = Enum.KeyCode.T

local NTE = {}

function NTE.start()
	print("NTE STARTING")
	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
		if gameProcessedEvent then
			return
		end

		if input.KeyCode == HACKS_TOGGLE_KEY then
			print("TOGGLING HACK TO ", not NTEConfig.HacksEnabled)
			NTEConfig.HacksEnabled = not NTEConfig.HacksEnabled
		end
	end)
	
	ScrollsAutoPicker.start()
end

return NTE
