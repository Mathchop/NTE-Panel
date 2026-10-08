local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MM2 Ultimate+",
   LoadingTitle = "MM2 Ultimate+",
   LoadingSubtitle = "Full Version",
   ConfigurationSaving = {Enabled = false},
   KeySystem = false
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ========== VARIABLES ==========
local flying, noclip, antiFling, speedEnabled = false, false, false, false
local flySpeed, walkSpeed, jumpPower = 50, 16, 50
local bv, bg
local selectedTarget = nil -- joueur actuellement sélectionné
local flingPower = 9000

-- ========== UTILS ==========
local function getRoot(char)
   return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHum(char)
   return char and char:FindFirstChildOfClass("Humanoid")
end

local function getMyRoot()
   return getRoot(LocalPlayer.Character)
end

local function getMyHum()
   return getHum(LocalPlayer.Character)
end

-- Détection rôles (basique)
local function getMurderer()
   for _, plr in pairs(Players:GetPlayers()) do
      if plr ~= LocalPlayer and plr.Character then
         local tool = plr.Character:FindFirstChildOfClass("Tool")
         if tool and (tool.Name:lower():find("knife") or tool.Name:lower():find("sword")) then
            return plr
         end
      end
   end
   return nil
end

local function getSheriff()
   for _, plr in pairs(Players:GetPlayers()) do
      if plr ~= LocalPlayer and plr.Character then
         local tool = plr.Character:FindFirstChildOfClass("Tool")
         if tool and (tool.Name:lower():find("gun") or tool.Name:lower():find("pistol") or tool.Name:lower():find("revolver")) then
            return plr
         end
      end
   end
   return nil
end

local function getRandomPlayer()
   local list = {}
   for _, plr in pairs(Players:GetPlayers()) do
      if plr ~= LocalPlayer then table.insert(list, plr) end
   end
   return #list > 0 and list[math.random(1, #list)] or nil
end

local function getRandomInnocent()
   local list = {}
   local murderer = getMurderer()
   local sheriff = getSheriff()
   for _, plr in pairs(Players:GetPlayers()) do
      if plr ~= LocalPlayer and plr ~= murderer and plr ~= sheriff then
         table.insert(list, plr)
      end
   end
   return #list > 0 and list[math.random(1, #list)] or nil
end

local function resolveTarget()
   if selectedTarget == "Murderer" then return getMurderer()
   elseif selectedTarget == "Sheriff" then return getSheriff()
   elseif selectedTarget == "Random" then return getRandomPlayer()
   elseif selectedTarget == "Random Innocent" then return getRandomInnocent()
   elseif selectedTarget and Players:FindFirstChild(selectedTarget) then
      return Players:FindFirstChild(selectedTarget)
   end
   return nil
end

-- ========== TARGET TAB (PANEL DE SÉLECTION) ==========
local TargetTab = Window:CreateTab("Target", nil)

TargetTab:CreateSection("Sélection du joueur")

local playerList = {}
for _, plr in pairs(Players:GetPlayers()) do
   if plr ~= LocalPlayer then table.insert(playerList, plr.Name) end
end

TargetTab:CreateDropdown({
   Name = "Joueur spécifique",
   Options = playerList,
   CurrentOption = {},
   MultipleOptions = false,
   Callback = function(opt)
      selectedTarget = opt[1]
      Rayfield:Notify({Title="Target", Content="Cible: "..tostring(selectedTarget), Duration=2})
   end,
})

TargetTab:CreateButton({
   Name = "🎯 Sélectionner le Murderer",
   Callback = function()
      selectedTarget = "Murderer"
      local m = getMurderer()
      Rayfield:Notify({Title="Target", Content=m and ("Murderer: "..m.Name) or "Murderer introuvable", Duration=3})
   end,
})

TargetTab:CreateButton({
   Name = "🎯 Sélectionner le Sheriff",
   Callback = function()
      selectedTarget = "Sheriff"
      local s = getSheriff()
      Rayfield:Notify({Title="Target", Content=s and ("Sheriff: "..s.Name) or "Sheriff introuvable", Duration=3})
   end,
})

TargetTab:CreateButton({
   Name = "🎲 Joueur Aléatoire",
   Callback = function()
      selectedTarget = "Random"
      local r = getRandomPlayer()
      Rayfield:Notify({Title="Target", Content=r and ("Random: "..r.Name) or "Aucun joueur", Duration=3})
   end,
})

TargetTab:CreateButton({
   Name = "🎲 Innocent Aléatoire",
   Callback = function()
      selectedTarget = "Random Innocent"
      local r = getRandomInnocent()
      Rayfield:Notify({Title="Target", Content=r and ("Innocent: "..r.Name) or "Aucun innocent", Duration=3})
   end,
})

TargetTab:CreateButton({
   Name = "🔄 Refresh liste joueurs",
   Callback = function()
      Rayfield:Notify({Title="Info", Content="Relance le script pour refresh la liste", Duration=3})
   end,
})

-- ========== MOVEMENT ==========
local MovementTab = Window:CreateTab("Movement", nil)

local function startFly()
   local root, hum = getMyRoot(), getMyHum()
   if not root or not hum then return end
   flying = true
   hum.PlatformStand = true
   bv = Instance.new("BodyVelocity")
   bv.MaxForce = Vector3.new(9e9,9e9,9e9)
   bv.Velocity = Vector3.zero
   bv.Parent = root
   bg = Instance.new("BodyGyro")
   bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
   bg.P = 9e4
   bg.Parent = root
end

local function stopFly()
   flying = false
   if bv then bv:Destroy() bv = nil end
   if bg then bg:Destroy() bg = nil end
   local hum = getMyHum()
   if hum then hum.PlatformStand = false end
end

MovementTab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Callback = function(v) if v then startFly() else stopFly() end end,
})

MovementTab:CreateSlider({
   Name = "Fly Speed",
   Range = {20, 150},
   Increment = 5,
   CurrentValue = 50,
   Callback = function(v) flySpeed = v end,
})

RunService.RenderStepped:Connect(function()
   if not flying or not bv or not bg then return end
   local root = getMyRoot()
   if not root then return end
   bg.CFrame = Camera.CFrame
   local move = Vector3.zero
   if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
   if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
   if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
   if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
   if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
   if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
   bv.Velocity = move.Magnitude > 0 and move.Unit * flySpeed or Vector3.zero
end)

MovementTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Callback = function(v) noclip = v end,
})

RunService.Stepped:Connect(function()
   if noclip and LocalPlayer.Character then
      for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
         if p:IsA("BasePart") then p.CanCollide = false end
      end
   end
end)

MovementTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 200},
   Increment = 4,
   CurrentValue = 16,
   Callback = function(v)
      walkSpeed = v
      local hum = getMyHum()
      if hum then hum.WalkSpeed = v end
   end,
})

MovementTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 300},
   Increment = 10,
   CurrentValue = 50,
   Callback = function(v)
      jumpPower = v
      local hum = getMyHum()
      if hum then hum.UseJumpPower = true hum.JumpPower = v end
   end,
})

MovementTab:CreateToggle({
   Name = "Anti-Fling (Protection)",
   CurrentValue = false,
   Callback = function(v)
      antiFling = v
      Rayfield:Notify({Title="Anti-Fling", Content=v and "Activé" or "Désactivé", Duration=2})
   end,
})

-- Anti-Fling loop
RunService.Heartbeat:Connect(function()
   if not antiFling then return end
   local root = getMyRoot()
   if root and root.AssemblyLinearVelocity.Magnitude > 150 then
      root.AssemblyLinearVelocity = Vector3.zero
      root.AssemblyAngularVelocity = Vector3.zero
   end
end)

-- ========== COMBAT ==========
local CombatTab = Window:CreateTab("Combat", nil)

CombatTab:CreateSection("Fling")

CombatTab:CreateSlider({
   Name = "Fling Power",
   Range = {3000, 20000},
   Increment = 500,
   CurrentValue = 9000,
   Callback = function(v) flingPower = v end,
})

CombatTab:CreateButton({
   Name = "Fling Target",
   Callback = function()
      local target = resolveTarget()
      if not target or not target.Character then
         Rayfield:Notify({Title="Erreur", Content="Aucune cible valide", Duration=3})
         return
      end
      local root = getMyRoot()
      local tRoot = getRoot(target.Character)
      if not root or not tRoot then return end

      local old = root.CFrame
      Rayfield:Notify({Title="Fling", Content="Fling de "..target.Name, Duration=3})

      for i = 1, 25 do
         root.CFrame = tRoot.CFrame
         root.AssemblyLinearVelocity = Vector3.new(flingPower, flingPower, flingPower)
         root.AssemblyAngularVelocity = Vector3.new(flingPower, flingPower, flingPower)
         task.wait()
      end
      root.CFrame = old
      root.AssemblyLinearVelocity = Vector3.zero
      root.AssemblyAngularVelocity = Vector3.zero
   end,
})

CombatTab:CreateButton({
   Name = "Fling All",
   Callback = function()
      local root = getMyRoot()
      if not root then return end
      local old = root.CFrame
      Rayfield:Notify({Title="Fling", Content="Fling All (8s)", Duration=3})
      local start = tick()
      while tick() - start < 8 do
         for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and getRoot(plr.Character) then
               root.CFrame = getRoot(plr.Character).CFrame
               root.AssemblyLinearVelocity = Vector3.new(flingPower, flingPower, flingPower)
               root.AssemblyAngularVelocity = Vector3.new(flingPower, flingPower, flingPower)
               task.wait()
            end
         end
         task.wait()
      end
      root.CFrame = old
      root.AssemblyLinearVelocity = Vector3.zero
      root.AssemblyAngularVelocity = Vector3.zero
   end,
})

CombatTab:CreateSection("Kill")

CombatTab:CreateButton({
   Name = "Kill Target (Murderer)",
   Callback = function()
      local target = resolveTarget()
      local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
      if not target or not tool then
         Rayfield:Notify({Title="Erreur", Content="Cible ou knife manquant", Duration=3})
         return
      end
      local root = getMyRoot()
      local tRoot = getRoot(target.Character)
      if not root or not tRoot then return end
      local old = root.CFrame
      root.CFrame = tRoot.CFrame
      tool:Activate()
      task.wait(0.15)
      root.CFrame = old
   end,
})

CombatTab:CreateButton({
   Name = "Kill All (Murderer)",
   Callback = function()
      local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
      if not tool then
         Rayfield:Notify({Title="Erreur", Content="Équipe ton knife", Duration=3})
         return
      end
      for _, plr in pairs(Players:GetPlayers()) do
         if plr ~= LocalPlayer and plr.Character and getRoot(plr.Character) then
            local root = getMyRoot()
            local old = root.CFrame
            root.CFrame = getRoot(plr.Character).CFrame
            tool:Activate()
            task.wait(0.12)
            root.CFrame = old
         end
      end
   end,
})

-- ========== TELEPORT ==========
local TPTab = Window:CreateTab("Teleport", nil)

TPTab:CreateButton({
   Name = "TP to Target",
   Callback = function()
      local target = resolveTarget()
      if not target or not target.Character then
         Rayfield:Notify({Title="Erreur", Content="Aucune cible", Duration=2})
         return
      end
      local root = getMyRoot()
      local tRoot = getRoot(target.Character)
      if root and tRoot then
         root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)
      end
   end,
})

TPTab:CreateButton({
   Name = "Bring Target",
   Callback = function()
      local target = resolveTarget()
      if not target or not target.Character then return end
      local root = getMyRoot()
      local tRoot = getRoot(target.Character)
      if root and tRoot then
         -- Client-side bring (limité)
         tRoot.CFrame = root.CFrame * CFrame.new(0, 0, -3)
         Rayfield:Notify({Title="Bring", Content="Tentative de bring (client)", Duration=2})
      end
   end,
})

TPTab:CreateButton({
   Name = "TP to Lobby",
   Callback = function()
      local root = getMyRoot()
      if root then root.CFrame = CFrame.new(0, 120, 0) end
   end,
})

-- ========== FUN ==========
local FunTab = Window:CreateTab("Fun", nil)

FunTab:CreateButton({
   Name = "Spin Target",
   Callback = function()
      local target = resolveTarget()
      if not target or not target.Character then return end
      local tRoot = getRoot(target.Character)
      if not tRoot then return end
      Rayfield:Notify({Title="Spin", Content="Spin de "..target.Name, Duration=3})
      task.spawn(function()
         for i = 1, 40 do
            if tRoot and tRoot.Parent then
               tRoot.CFrame = tRoot.CFrame * CFrame.Angles(0, math.rad(45), 0)
            end
            task.wait(0.05)
         end
      end)
   end,
})

FunTab:CreateButton({
   Name = "Launch Target Up",
   Callback = function()
      local target = resolveTarget()
      if not target or not target.Character then return end
      local tRoot = getRoot(target.Character)
      if tRoot then
         tRoot.AssemblyLinearVelocity = Vector3.new(0, 300, 0)
      end
   end,
})

FunTab:CreateButton({
   Name = "Void Target",
   Callback = function()
      local target = resolveTarget()
      if not target or not target.Character then return end
      local tRoot = getRoot(target.Character)
      if tRoot then
         tRoot.CFrame = CFrame.new(0, -500, 0)
      end
   end,
})

FunTab:CreateButton({
   Name = "Invisible (Local)",
   Callback = function()
      local char = LocalPlayer.Character
      if not char then return end
      for _, p in pairs(char:GetDescendants()) do
         if p:IsA("BasePart") or p:IsA("Decal") then
            p.Transparency = 1
         end
      end
      Rayfield:Notify({Title="Invisible", Content="Tu es invisible localement", Duration=3})
   end,
})

FunTab:CreateButton({
   Name = "Spam Jump Target",
   Callback = function()
      local target = resolveTarget()
      if not target or not target.Character then return end
      local hum = getHum(target.Character)
      if hum then
         task.spawn(function()
            for i = 1, 15 do
               hum.Jump = true
               task.wait(0.15)
            end
         end)
      end
   end,
})

-- ========== MISC ==========
local MiscTab = Window:CreateTab("Misc", nil)

MiscTab:CreateButton({
   Name = "Reset Character",
   Callback = function()
      local hum = getMyHum()
      if hum then hum.Health = 0 end
   end,
})

MiscTab:CreateButton({
   Name = "Rejoin",
   Callback = function()
      game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
   end,
})

MiscTab:CreateButton({
   Name = "Destroy GUI",
   Callback = function()
      stopFly()
      noclip = false
      antiFling = false
      Rayfield:Destroy()
   end,
})

Rayfield:Notify({
   Title = "MM2 Ultimate+",
   Content = "Hub chargé ! Utilise l'onglet Target",
   Duration = 5
})
