local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MM2 Hub",
   LoadingTitle = "MM2 Hub",
   LoadingSubtitle = "Stable Version",
   ConfigurationSaving = {Enabled = false},
   KeySystem = false
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables
local flying = false
local flySpeed = 50
local bv, bg
local noclip = false

-- ========== MOVEMENT ==========
local MovementTab = Window:CreateTab("Movement", nil)

local function startFly()
   local char = LocalPlayer.Character
   if not char then return end
   local root = char:FindFirstChild("HumanoidRootPart")
   local hum = char:FindFirstChildOfClass("Humanoid")
   if not root or not hum then return end

   flying = true
   hum.PlatformStand = true

   bv = Instance.new("BodyVelocity")
   bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
   bv.Velocity = Vector3.zero
   bv.Parent = root

   bg = Instance.new("BodyGyro")
   bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
   bg.P = 9e4
   bg.Parent = root
end

local function stopFly()
   flying = false
   if bv then bv:Destroy() bv = nil end
   if bg then bg:Destroy() bg = nil end
   local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
   if hum then hum.PlatformStand = false end
end

MovementTab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Callback = function(Value)
      if Value then startFly() else stopFly() end
   end,
})

MovementTab:CreateSlider({
   Name = "Fly Speed",
   Range = {20, 120},
   Increment = 5,
   CurrentValue = 50,
   Callback = function(Value)
      flySpeed = Value
   end,
})

RunService.RenderStepped:Connect(function()
   if not flying or not bv or not bg then return end
   local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
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
   Callback = function(Value)
      noclip = Value
   end,
})

RunService.Stepped:Connect(function()
   if noclip and LocalPlayer.Character then
      for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
         if part:IsA("BasePart") then
            part.CanCollide = false
         end
      end
   end
end)

MovementTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 150},
   Increment = 2,
   CurrentValue = 16,
   Callback = function(Value)
      local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
      if hum then hum.WalkSpeed = Value end
   end,
})

-- ========== COMBAT ==========
local CombatTab = Window:CreateTab("Combat", nil)

CombatTab:CreateButton({
   Name = "Fling All (10s)",
   Callback = function()
      local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
      if not root then return end
      local oldPos = root.CFrame
      local start = tick()

      Rayfield:Notify({Title="Fling", Content="Fling All lancé", Duration=3})

      while tick() - start < 10 do
         for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
               root.CFrame = plr.Character.HumanoidRootPart.CFrame
               root.AssemblyLinearVelocity = Vector3.new(9000, 9000, 9000)
               root.AssemblyAngularVelocity = Vector3.new(9000, 9000, 9000)
               task.wait()
            end
         end
         task.wait()
      end

      root.CFrame = oldPos
      root.AssemblyLinearVelocity = Vector3.zero
      root.AssemblyAngularVelocity = Vector3.zero
      Rayfield:Notify({Title="Fling", Content="Terminé", Duration=2})
   end,
})

CombatTab:CreateButton({
   Name = "Kill All (si Murderer)",
   Callback = function()
      local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
      if not tool then
         Rayfield:Notify({Title="Erreur", Content="Équipe ton knife", Duration=3})
         return
      end

      for _, plr in pairs(Players:GetPlayers()) do
         if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            local old = root.CFrame
            root.CFrame = plr.Character.HumanoidRootPart.CFrame
            tool:Activate()
            task.wait(0.12)
            root.CFrame = old
         end
      end
   end,
})

-- ========== TELEPORT ==========
local TPTab = Window:CreateTab("Teleport", nil)

local selected = nil

local function refreshPlayers()
   local list = {}
   for _, plr in pairs(Players:GetPlayers()) do
      if plr ~= LocalPlayer then
         table.insert(list, plr.Name)
      end
   end
   return list
end

TPTab:CreateDropdown({
   Name = "Joueur",
   Options = refreshPlayers(),
   CurrentOption = {},
   MultipleOptions = false,
   Callback = function(Option)
      selected = Option[1]
   end,
})

TPTab:CreateButton({
   Name = "TP to Player",
   Callback = function()
      if not selected then return end
      local target = Players:FindFirstChild(selected)
      if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
         local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
         if root then
            root.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
         end
      end
   end,
})

-- ========== MISC ==========
local MiscTab = Window:CreateTab("Misc", nil)

MiscTab:CreateButton({
   Name = "Reset Character",
   Callback = function()
      local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
      if hum then hum.Health = 0 end
   end,
})

MiscTab:CreateButton({
   Name = "Destroy GUI",
   Callback = function()
      stopFly()
      noclip = false
      Rayfield:Destroy()
   end,
})

Rayfield:Notify({
   Title = "MM2 Hub",
   Content = "Chargé avec succès",
   Duration = 4
})
