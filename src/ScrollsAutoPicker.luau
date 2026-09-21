local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local NTEConfig = gitRequire("./NTEConfig")

local player = game:GetService("Players").LocalPlayer
local camera = workspace.Camera

local TAKESCROLL_MAX_TIME = 0.75

local playerOldPos: CFrame = nil
local playerOldVelocity: Vector3 = nil
local cameraOldPos: CFrame = nil

local ScrollsAutoPicker = {}

ScrollsAutoPicker._scrollsBlacklist = {} :: {BasePart}

local function log(...)
	local args = {...}

	if RunService:IsStudio() then
		print(table.unpack(args))
	end
end

local function isPlayerDead()
	local character = player.Character

	if not character then
		return true
	end

	local huamnoid = character:FindFirstChildOfClass("Humanoid")

	if not huamnoid or huamnoid.Health == 0 then
		return true
	end

	return false
end

local function teleportPlayer(cframe: CFrame, velocity: Vector3?)
	if isPlayerDead() then
		return false
	end

	local character = player.Character
	local root: BasePart = character:FindFirstChild("HumanoidRootPart")

	character:PivotTo(cframe)

	if velocity then
		task.wait()
		root.AssemblyLinearVelocity = velocity
	end

	return true
end

local function getScrollTpPos(scroll: BasePart, character: Model)
	return CFrame.new(scroll.CFrame.Position + Vector3.new(0, 3, 0)) * character:GetPivot().Rotation
end

local function takeScroll(scroll: BasePart)
	if isPlayerDead() then
		return
	end

	local character = player.Character
	local root: BasePart = character:FindFirstChild("HumanoidRootPart")
	local prompt: ProximityPrompt = scroll:FindFirstChildOfClass("ProximityPrompt")

	prompt.RequiresLineOfSight = false
	prompt.HoldDuration = 0

	local tpCFrame = getScrollTpPos(scroll, character)
	local result = teleportPlayer(tpCFrame)

	log("TP PLAYER TO SCROLL")

	if result then	
		local promptPressed = false
		local recordedTime = os.clock()

		prompt.Triggered:Once(function()
			promptPressed = true
			log("PRESSED PROMPT")
		end)

		prompt:InputHoldBegin()

		while not promptPressed and os.clock() - recordedTime < TAKESCROLL_MAX_TIME do
			if not scroll then
				break
			end

			prompt:InputHoldBegin()

			log("STILL NOT PRESSED")

			if (scroll.Position - root.Position).Magnitude > (prompt.MaxActivationDistance - 1) then
				tpCFrame = getScrollTpPos(scroll, character)

				teleportPlayer(tpCFrame)
				log("SCROLL MOVED, RE TELEPORTING")
			end

			task.wait(0.1)
		end

		if not promptPressed then
			log("STILL PRESSED, ASSUMING WE CANT TAKE THIS SCROLL")
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

function ScrollsAutoPicker.start()
	print("STARTING SCROLLS AUTO PICKER")
	task.spawn(function()
		while task.wait(0.1) do
			print("LOOP")
			if next(ScrollsAutoPicker._scrollsBlacklist) then
				for i = #ScrollsAutoPicker._scrollsBlacklist, 1, -1 do
					local child = ScrollsAutoPicker._scrollsBlacklist[i]

					if child and child.Parent == nil then
						table.remove(ScrollsAutoPicker._scrollsBlacklist, i)
					end
				end
			end

			if isPlayerDead() or not NTEConfig.HacksEnabled then
				continue
			end

			local scrolls = getScrolls()

			if not next(scrolls) then
				continue
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

			log("FINISHED TAKING SCROLLS")
			teleportPlayer(playerOldPos, playerOldVelocity)
			camera.CFrame = cameraOldPos
		end
	end)
end

return ScrollsAutoPicker
