local RunService = game:GetService("RunService")
local Config = _G.gitRequire("../Config")
local Utils = _G.gitRequire("../Utils") or require("./Utils")

local player = game:GetService("Players").LocalPlayer
local camera = workspace.Camera

local TAKESCROLL_MAX_TIME = 0.75

local playerOldPos: CFrame = nil
local playerOldVelocity: Vector3 = nil
local cameraOldPos: CFrame = nil

local ScrollsAutoPicker = {}

ScrollsAutoPicker._scrollsBlacklist = {} :: {BasePart}

local function getScrollTpPos(scroll: BasePart, character: Model)
	return CFrame.new(scroll.CFrame.Position + Vector3.new(0, 3, 0)) * character:GetPivot().Rotation
end

local function takeScroll(scroll: BasePart)
	if Utils.isPlayerDead() then
		return
	end

	local character = player.Character
	local root: BasePart = character:FindFirstChild("HumanoidRootPart")
	local prompt: ProximityPrompt = scroll:FindFirstChildOfClass("ProximityPrompt")

	prompt.RequiresLineOfSight = false
	prompt.HoldDuration = 0

	local tpCFrame = getScrollTpPos(scroll, character)
	local result = Utils.teleportPlayer(tpCFrame)

	Utils.log("TP PLAYER TO SCROLL")

	if result then	
		local promptPressed = false
		local recordedTime = os.clock()

		prompt.Triggered:Once(function()
			promptPressed = true
			Utils.log("PRESSED PROMPT")
		end)

		prompt:InputHoldBegin()

		while not promptPressed and os.clock() - recordedTime < TAKESCROLL_MAX_TIME do
			if not scroll then
				break
			end

			prompt:InputHoldBegin()

			Utils.log("STILL NOT PRESSED")

			if (scroll.Position - root.Position).Magnitude > (prompt.MaxActivationDistance - 1) then
				tpCFrame = getScrollTpPos(scroll, character)

				Utils.teleportPlayer(tpCFrame)
				Utils.log("SCROLL MOVED, RE TELEPORTING")
			end

			task.wait(0.1)
		end

		if not promptPressed then
			Utils.log("STILL PRESSED, ASSUMING WE CANT TAKE THIS SCROLL")
			table.insert(ScrollsAutoPicker._scrollsBlacklist, scroll)
		end

		prompt:InputHoldEnd()
	end
end

local function getScrolls()
	local workspaceChildren = workspace:GetChildren()
	local scrolls = {} :: {BasePart}

	for _, child in pairs(workspaceChildren) do
		if (child.Name == "CashScroll" or child.Name == "EScroll") and child:IsA("BasePart") then
			local prompt = child:FindFirstChildOfClass("ProximityPrompt")

			if prompt then
				table.insert(scrolls, child)
			end
		end
	end

	return scrolls
end

function ScrollsAutoPicker.loop()
	if next(ScrollsAutoPicker._scrollsBlacklist) then
		local scrollsWhitelist = {} :: {BasePart}

		for i, scroll in pairs(ScrollsAutoPicker._scrollsBlacklist) do
			local child = ScrollsAutoPicker._scrollsBlacklist[i]

			if child and child.Parent == nil then
				scrollsWhitelist[i] = scroll
			end
		end

		for i, scroll in pairs(scrollsWhitelist) do
			ScrollsAutoPicker._scrollsBlacklist[i] = nil
		end
	end

	if Utils.isPlayerDead() or not Config.HacksEnabled then
		return
	end

	local scrolls = getScrolls()

	if not next(scrolls) then
		return
	end

	local character = player.Character
	local root: BasePart = character:FindFirstChild("HumanoidRootPart")

	playerOldPos = character:GetPivot()
	playerOldVelocity = root.AssemblyLinearVelocity
	cameraOldPos = camera.CFrame

	for _, scroll in pairs(scrolls) do
		if table.find(ScrollsAutoPicker._scrollsBlacklist, scroll) then
			continue
		end

		takeScroll(scroll)
	end

	Utils.log("FINISHED TAKING SCROLLS")
	Utils.teleportPlayer(playerOldPos, playerOldVelocity, cameraOldPos)
end

return ScrollsAutoPicker
