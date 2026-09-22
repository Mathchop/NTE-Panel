local NpcAutoKill = {}
local RunService = game:GetService("RunService")
local Config = _G.gitRequire("../Config") or require("./Config")
local Utils = _G.gitRequire("../Utils") or require("./Utils")

local player = game:GetService("Players").LocalPlayer

local NPC_DISTANCE_LIMIT = 15
local NPC_KILL_COOLDOWN = 1.5
local NPC_KILL_TIMEOUT = 1.5

local NPCS_NAMES = {
	--NINJAS
	"Sound Ninja",
	"Rogue Ninja",
	"Reanimated Ninja",
	--BOSSES
	"Monashiki",
	"Gimshiki",
	"Jigan"
}

local HIGHLIGHT_FILLCOLORS = {
	["Ennemy"] = Color3.fromRGB(255, 0, 0)
}

local HIGHLIGHT_OUTLINECOLORS = {
	["Ennemy"] = Color3.fromRGB(255, 150, 150)
}

local teleportedNpc: Model = nil
local teleportedTime = nil
local cooldownTime = nil
NpcAutoKill._blackList = {} :: {Model}
NpcAutoKill._highlights = {} :: {Highlight}

local function getHighlight(object: Instance): Highlight
	return object:FindFirstChild("NTE_Highlight")
end

local function destroyAllHighlights()
	if #NpcAutoKill._highlights > 0 then
		for _, highlight in pairs(NpcAutoKill._highlights) do
			highlight:Destroy()
		end

		table.clear(NpcAutoKill._highlights)
	end
end

local function destroyHighlight(object: Instance): Highlight
	local highLight = getHighlight(object)

	if highLight then
		highLight:Destroy()
	end
end

local function highlightObject(object: Instance, highlightType: string): Highlight
	destroyHighlight(object)

	local newHighlight = Instance.new("Highlight")
	newHighlight.FillColor = HIGHLIGHT_FILLCOLORS[highlightType]
	newHighlight.OutlineColor = HIGHLIGHT_OUTLINECOLORS[highlightType]
	newHighlight.Name = "NTE_Highlight"
	newHighlight.Parent = object

	table.insert(NpcAutoKill._highlights, newHighlight)

	return newHighlight
end

local function getNpcsKillable()
	local workspaceChildren = workspace:GetChildren()
	local npcs = {} :: {Model}

	for _, child in pairs(workspaceChildren) do
		if child:IsA("Model") and table.find(NPCS_NAMES, child.Name) then
			local humanoid: Humanoid = child:FindFirstChild("Humanoid")
			
			if not humanoid then
				continue
			end
			
			if humanoid.Health == 0 then
				destroyHighlight(child)

				continue
			end

			table.insert(npcs, child)
		end
	end

	return npcs
end

function NpcAutoKill.loop()
	if next(NpcAutoKill._blackList) then
		local whiteList = {} :: {Model}

		for i, scroll in pairs(NpcAutoKill._blackList) do
			local child = NpcAutoKill._blackList[i]

			if child and child.Parent == nil then
				whiteList[i] = scroll
			end
		end

		for i, scroll in pairs(whiteList) do
			NpcAutoKill._blackList[i] = nil
		end
	end

	if Utils.isPlayerDead() or not Config.HacksEnabled then
		destroyAllHighlights()

		return
	end

	local npcs = getNpcsKillable()

	if not next(npcs) then
		return
	end

	local character = player.Character
	local root: BasePart = character:FindFirstChild("HumanoidRootPart")
	
	if teleportedNpc ~= nil then
		local humanoid: Humanoid = teleportedNpc:FindFirstChild("Humanoid")
		
		if humanoid.Health ~= 0 and os.time() - teleportedTime < NPC_KILL_TIMEOUT then
			humanoid:ChangeState(Enum.HumanoidStateType.Dead)
			
			return
		end
		
		table.insert(NpcAutoKill._blackList, teleportedNpc)
		destroyHighlight(teleportedNpc)
		
		teleportedNpc = nil
		teleportedTime = nil
		
		Utils.teleportPlayer(CFrame.new(0, 0, 0))
		
		cooldownTime = os.clock()
	else
		if cooldownTime ~= nil then
			if os.clock() - cooldownTime < NPC_KILL_COOLDOWN then
				return
			end
			
			cooldownTime = nil
		end
		
		local whitelistNpcs = {}
		
		for _, npc in pairs(npcs) do
			if table.find(NpcAutoKill._blackList, npc) then
				continue
			end
			
			table.insert(whitelistNpcs, npc)
		end
		
		if #whitelistNpcs == 0 then
			return
		end
		
		local npc = whitelistNpcs[math.random(1, #whitelistNpcs)]
		
		local npcRoot: BasePart = npc:FindFirstChild("HumanoidRootPart")
		local playerDis = (npc:FindFirstChild("HumanoidRootPart").Position - root.Position).Magnitude

		if not getHighlight(npc) then
			highlightObject(npc, "Ennemy")
		end

		teleportedNpc = npc
		teleportedTime = os.clock()
		Utils.teleportPlayer(CFrame.new(npcRoot.Position) * CFrame.new(5, 3, 0))

		local humanoid: Humanoid = npc:FindFirstChild("Humanoid")
		humanoid:ChangeState(Enum.HumanoidStateType.Dead)
	end
end

return NpcAutoKill
