local player = game:GetService("Players").LocalPlayer
local playerGui = player.PlayerGui

local UIPanel = {}

UIPanel.ScreenGui = nil :: ScreenGui

UIPanel.SideInfosFrame = nil :: Frame
UIPanel.SideInfos = {} :: {[string]: string}

local function newFrame(name: string, size: UDim2, pos: UDim2, anchor: Vector2?, transparent: boolean?): Frame
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = size
	frame.Position = pos
	
	if anchor then
		frame.AnchorPoint = anchor
	end
	
	if transparent then
		frame.BackgroundTransparency = 1
	end
	
	return frame
end

local function updateSideInfos()
	local updatedTexts = {} :: {TextLabel}
	
	for id, message in pairs(UIPanel.SideInfos) do
		local msgText: TextLabel = UIPanel.SideInfosFrame:FindFirstChild("M_"..id)
		
		if not msgText then
			local newText = Instance.new("TextLabel")
			newText.Name = "M_"..id
			newText.Size = UDim2.fromScale(1, 0.1)
			newText.TextScaled = true
			newText.Parent = UIPanel.SideInfosFrame
			
			newText.Text = message
			
			msgText = newText
		else
			if msgText.Text ~= message then
				msgText.Text = message
			end
		end
		
		table.insert(updatedTexts, msgText)
	end
	
	for _, child in pairs(UIPanel.SideInfosFrame:GetChildren()) do
		if string.find(child.Name, "M_") and child:IsA("TextLabel") and not table.find(updatedTexts, child) then
			child:Destroy()
		end
	end
end

function UIPanel.setSideInfo(id: string, message: string)
	UIPanel.SideInfos[id] = message
	
	updateSideInfos()
end

function UIPanel.init()
	local newPanel = Instance.new("ScreenGui")
	newPanel.Name = "NTE_Panel"
	newPanel.Parent = playerGui
	
	newPanel.ScreenInsets = Enum.ScreenInsets.None
	
	UIPanel.ScreenGui = newPanel
	
	local sideInfo = newFrame("SideInfos", UDim2.new(0.18, 0, 0.4, 0), UDim2.fromScale(1, 0), Vector2.new(1, 0), false)
	sideInfo.Parent = UIPanel.ScreenGui
	
	local uiList = Instance.new("UIListLayout", sideInfo)
	
	UIPanel.SideInfosFrame = sideInfo
	
	UIPanel.setSideInfo("version", "Docteur Panel 1.0.0")
	UIPanel.setSideInfo("test", "TEST")
	UIPanel.setSideInfo("test", "TEST2")
end

return UIPanel
