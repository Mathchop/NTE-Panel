local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MM2 Ultimate Hub",
   LoadingTitle = "MM2 Ultimate",
   LoadingSubtitle = "by Grok",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "MM2Ultimate",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables
local flying = false
local flySpeed = 50
local bv, bg
local flinging = false
local noclip = false
local speedEnabled = false
local walkSpeed = 16
local jumpPower = 50

-- ========== COMBAT TAB ==========
local CombatTab = Window:CreateTab("Combat", 4483362458)

CombatTab:CreateSection("Kill Options")

CombatTab:CreateButton({
   Name = "Kill All (Murderer)",
   Callback = function()
      local knife = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
      if not knife then
         Rayfield:Notify({Title="Error", Content="Tu n'as pas de knife équipé", Duration=3})
         return
      end
      for _, player in pairs(Players:GetPlayers()) do
         if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local target = player.Character.HumanoidRootPart
            local oldPos = LocalPlayer.Character.HumanoidRootPart.CFrame
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame
            knife:Activate()
            task.wait(0.15)
            LocalPlayer.Character.HumanoidRootPart.CFrame = oldPos
         end
      end
      Rayfield:Notify({Title="Kill All", Content="Tentative terminée", Duration=3})
   end,
})

CombatTab:CreateButton({
   Name = "Fling All",
   Callback = function()
      Rayfield:Notify({Title="Fling", Content="Fling All lancé (10s)", Duration=3})
      local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
      if not root then return end

      local oldPos = root.CFrame
      flinging = true

      task.spawn(function()
         local start = tick()
         while flinging and tick() - start < 10 do
            for _, player in pairs(Players:GetPlayers()) do
               if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                  local target = player.Character.HumanoidRootPart
                  root.CFrame = target.CFrame
                  root.AssemblyLinearVelocity = Vector3.new(9999, 9999, 9999)
                  root.AssemblyAngularVelocity = Vector3.new(9999, 9999, 9999)
                  task.wait()
               end
            end
            task.wait()
         end
         flinging = false
         root.CFrame = oldPos
         root.AssemblyLinearVelocity = Vector3.zero
         root.AssemblyAngularVelocity = Vector3.zero
         Rayfield:Notify({Title="Fling", Content="Fling All terminé", Duration=3})
      end)
   end,
})

CombatTab:CreateButton({
   Name = "Stop Fling",
   Callback = function()
      flinging = false
      Rayfield:Notify({Title="Fling", Content="Arrêté", Duration=2})
   end,
})

-- ========== MOVEMENT TAB ==========
local MovementTab = Window:CreateTab("Movement", 4483362458)

MovementTab:CreateSection("Fly")

local function startFly()
   local char = LocalPlayer.Character
   if not char then return end
   local root = char:FindFirstChild("HumanoidRootPart")
   local hum = char:FindFirstChildOfClass("Humanoid")
   if not root or not hum then return end

   flying = true
   hum.PlatformStand = true

   bv = Instance.new("BodyVelocity")
   bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
   bv.Velocity = Vector3.zero
   bv.Parent = root

   bg = Instance.new("BodyGyro")
   bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
   bg.P = 3000
   bg.CFrame = Camera.CFrame
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
   Flag = "FlyToggle",
   Callback = function(Value)
      if Value then
         startFly()
         Rayfield:Notify({Title="Fly", Content="Activé (E pour toggle aussi)", Duration=3})
      else
         stopFly()
      end
   end,
})

MovementTab:CreateSlider({
   Name = "Fly Speed",
   Range = {20, 150},
   Increment = 5,
   CurrentValue = 50,
   Flag = "FlySpeed",
   Callback = function(Value)
      flySpeed = Value
   end,
})

-- Fly loop
RunService.RenderStepped:Connect(function()
   if not flying or not bv or not bg then return end
   local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
   if not root then return end

   bg.CFrame = Camera.CFrame

   local move = Vector3.zero
   local look = Camera.CFrame.LookVector
   local right = Camera.CFrame.RightVector

   if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + look end
   if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - look end
   if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - right end
   if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + right end
   if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
   if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end

   bv.Velocity = move.Magnitude > 0 and move.Unit * flySpeed or Vector3.zero
end)

-- Keybind E pour fly
UserInputService.InputBegan:Connect(function(input, gpe)
   if gpe then return end
   if input.KeyCode == Enum.KeyCode.E then
      if flying then stopFly() else startFly() end
   end
end)

MovementTab:CreateSection("Other")

MovementTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "Noclip",
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
   Range = {16, 200},
   Increment = 4,
   CurrentValue = 16,
   Flag = "WalkSpeed",
   Callback = function(Value)
      walkSpeed = Value
      local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
      if hum then hum.WalkSpeed = Value end
   end,
})

MovementTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 300},
   Increment = 10,
   CurrentValue = 50,
   Flag = "JumpPower",
   Callback = function(Value)
      jumpPower = Value
      local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
      if hum then
         hum.UseJumpPower = true
         hum.JumpPower = Value
      end
   end,
})

-- ========== TELEPORT TAB ==========
local TPTab = Window:CreateTab("Teleport", 4483362458)

TPTab:CreateSection("Players")

local function getPlayerNames()
   local names = {}
   for _, player in pairs(Players:GetPlayers()) do
      if player ~= LocalPlayer then
         table.insert(names, player.Name)
      end
   end
   return names
end

local selectedPlayer = nil

TPTab:CreateDropdown({
   Name = "Select Player",
   Options = getPlayerNames(),
   CurrentOption = {},
   MultipleOptions = false,
   Flag = "PlayerSelect",
   Callback = function(Option)
      selectedPlayer = Option[1]
   end,
})

TPTab:CreateButton({
   Name = "Teleport to Player",
   Callback = function()
      if not selectedPlayer then
         Rayfield:Notify({Title="Error", Content="Sélectionne un joueur", Duration=2})
         return
      end
      local target = Players:FindFirstChild(selectedPlayer)
      if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
         local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
         if root then
            root.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
         end
      end
   end,
})

TPTab:CreateButton({
   Name = "Refresh Player List",
   Callback = function()
      Rayfield:Notify({Title="Info", Content="Relance le script pour refresh la liste", Duration=3})
   end,
})

TPTab:CreateSection("Map")

TPTab:CreateButton({
   Name = "TP to Lobby",
   Callback = function()
      local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
      if root then
         root.CFrame = CFrame.new(0, 100, 0) -- approximatif, change selon la map
         Rayfield:Notify({Title="TP", Content="Téléporté vers le lobby (approximatif)", Duration=3})
      end
   end,
})

-- ========== VISUALS TAB ==========
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

VisualsTab:CreateSection("ESP")

local espEnabled = false
local espFolder = Instance.new("Folder")
espFolder.Name = "MM2ESP"
espFolder.Parent = game.CoreGui

local function clearESP()
   for _, v in pairs(espFolder:GetChildren()) do
      v:Destroy()
   end
end

local function createESP(player)
   if player == LocalPlayer then return end
   local char = player.Character
   if not char then return end
   local head = char:FindFirstChild("Head")
   if not head then return end

   local billboard = Instance.new("BillboardGui")
   billboard.Name = player.Name
   billboard.Adornee = head
   billboard.Size = UDim2.new(0, 200, 0, 50)
   billboard.StudsOffset = Vector3.new(0, 3, 0)
   billboard.AlwaysOnTop = true
   billboard.Parent = espFolder

   local label = Instance.new("TextLabel")
   label.Size = UDim2.new(1, 0, 1, 0)
   label.BackgroundTransparency = 1
   label.Text = player.Name
   label.TextColor3 = Color3.fromRGB(255, 255, 255)
   label.TextStrokeTransparency = 0.5
   label.Font = Enum.Font.GothamBold
   label.TextSize = 14
   label.Parent = billboard
end

VisualsTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "ESP",
   Callback = function(Value)
      espEnabled = Value
      clearESP()
      if Value then
         for _, player in pairs(Players:GetPlayers()) do
            createESP(player)
         end
      end
   end,
})

Players.PlayerAdded:Connect(function(player)
   if espEnabled then
      player.CharacterAdded:Connect(function()
         task.wait(1)
         createESP(player)
      end)
   end
end)

-- ========== MISC TAB ==========
local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:CreateSection("Utility")

MiscTab:CreateButton({
   Name = "Reset Character",
   Callback = function()
      local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
      if hum then hum.Health = 0 end
   end,
})

MiscTab:CreateButton({
   Name = "Rejoin Server",
   Callback = function()
      game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
   end,
})

MiscTab:CreateButton({
   Name = "Destroy GUI",
   Callback = function()
      stopFly()
      flinging = false
      noclip = false
      clearESP()
      Rayfield:Destroy()
   end,
})

-- Notification de chargement
Rayfield:Notify({
   Title = "MM2 Ultimate Hub",
   Content = "Chargé avec succès !",
   Duration = 5,
   Image = 4483362458
})

print("MM2 Ultimate Hub loaded")
