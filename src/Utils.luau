local RunService = game:GetService("RunService")

local player = game:GetService("Players").LocalPlayer
local camera = workspace.Camera

local Utils = {}

function Utils.log(...)
	local args = {...}

	if RunService:IsStudio() then
		print("[NTE PANEL]", table.unpack(args))
	end
end

function Utils.isPlayerDead()
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

function Utils.teleportPlayer(cframe: CFrame, velocity: Vector3?, camCFrame: CFrame)
	if Utils.isPlayerDead() then
		return false
	end

	local character = player.Character
	local root: BasePart = character:FindFirstChild("HumanoidRootPart")

	character:PivotTo(cframe)

	if velocity then
		task.wait()
		root.AssemblyLinearVelocity = velocity
	end

	if camCFrame then
		camera.CFrame = camCFrame
	end

	return true
end

return Utils
