--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Library = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Targets = {}
local Flinging = false
local ToggleButtons = {}
local Protection = true

getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight


local function Notify(title, text, duration)
    Library:Notify({
        Title = title,
        Content = text,
        Duration = duration or 5,
        Image = 4483362458
    })
end


local function EnableCollision(character)
    if not character then return end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end


local function DisableCollision(character)
    if not character then return end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end


local function SetProtection(enable)
    local character = LocalPlayer.Character
    if not character then return end
    if enable and Protection then
        EnableCollision(character)
    else
        DisableCollision(character)
    end
end


local function FlingPlayer(targetPlayer)

    local myChar = LocalPlayer.Character
    local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local myRoot = myHumanoid and myHumanoid.RootPart
    

    local targetChar = targetPlayer.Character
    if not targetChar then return end
    
    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
    local targetRoot = targetHumanoid and targetHumanoid.RootPart
    local targetHead = targetChar:FindFirstChild("Head")
    local targetHandle = targetChar:FindFirstChildOfClass("Accessory") and 
                         targetChar:FindFirstChildOfClass("Accessory"):FindFirstChild("Handle")
    

    if myChar and myHumanoid and myRoot then
        if Protection then SetProtection(true) end
        

        if myRoot.Velocity.Magnitude < 50 then
            getgenv().OldPos = myRoot.Position
        end
        

        if targetHumanoid and targetHumanoid.Sit then
            if Protection then SetProtection(false) end
            return Notify("Error", targetPlayer.Name .. " is sitting", 2)
        end
        

        if targetHead then
            workspace.CurrentCamera.CameraSubject = targetHead
        elseif targetHandle then
            workspace.CurrentCamera.CameraSubject = targetHandle
        elseif targetHumanoid and targetRoot then
            workspace.CurrentCamera.CameraSubject = targetHumanoid
        end
        

        if not targetChar:FindFirstChildWhichIsA("BasePart") then
            if Protection then SetProtection(false) end
            return
        end
        

        local function TeleportAndFling(basePart, positionOffset, angleOffset)
            myRoot.Position = CFrame.new(basePart.Position) * positionOffset * angleOffset
            myChar:SetPrimaryPartCFrame(CFrame.new(basePart.Position) * positionOffset * angleOffset)
            myRoot.Velocity = Vector3.new(9e7, 9e7*10, 9e7)
            myRoot.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        

        local function SuperFling(basePart)
            local duration = 2
            local startTime = tick()
            local angle = 0
            
            repeat
                if myRoot and targetHumanoid then
                    if Protection then EnableCollision(myChar) end
                    
                    if basePart.Velocity.Magnitude < 50 then
                        angle = angle + 100
                        
                        TeleportAndFling(basePart, CFrame.new(0,1.5,0) + targetHumanoid.MoveDirection * basePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(angle),0,0))
                        task.wait()
                        TeleportAndFling(basePart, CFrame.new(0,-1.5,0) + targetHumanoid.MoveDirection * basePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(angle),0,0))
                        task.wait()
                        TeleportAndFling(basePart, CFrame.new(0,1.5,0) + targetHumanoid.MoveDirection * basePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(angle),0,0))
                        task.wait()
                        TeleportAndFling(basePart, CFrame.new(0,-1.5,0) + targetHumanoid.MoveDirection * basePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(angle),0,0))
                        task.wait()
                        TeleportAndFling(basePart, CFrame.new(0,1.5,0) + targetHumanoid.MoveDirection, CFrame.Angles(math.rad(angle),0,0))
                        task.wait()
                        TeleportAndFling(basePart, CFrame.new(0,-1.5,0) + targetHumanoid.MoveDirection, CFrame.Angles(math.rad(angle),0,0))
                        task.wait()
                    else
                        TeleportAndFling(basePart, CFrame.new(0,1.5, targetHumanoid.WalkSpeed), CFrame.Angles(math.rad(90),0,0))
                        task.wait()
                        TeleportAndFling(basePart, CFrame.new(0,-1.5, -targetHumanoid.WalkSpeed), CFrame.Angles(0,0,0))
                        task.wait()
                        TeleportAndFling(basePart, CFrame.new(0,1.5, targetHumanoid.WalkSpeed), CFrame.Angles(math.rad(90),0,0))
                        task.wait()
                        TeleportAndFling(basePart, CFrame.new(0,-1.5,0), CFrame.Angles(math.rad(90),0,0))
                        task.wait()
                        TeleportAndFling(basePart, CFrame.new(0,-1.5,0), CFrame.Angles(0,0,0))
                        task.wait()
                        TeleportAndFling(basePart, CFrame.new(0,-1.5,0), CFrame.Angles(math.rad(90),0,0))
                        task.wait()
                        TeleportAndFling(basePart, CFrame.new(0,-1.5,0), CFrame.Angles(0,0,0))
                        task.wait()
                    end
                end
            until startTime + duration < tick() or not Flinging
        end
        

        workspace.FallenPartsDestroyHeight = 0/0  -- NaN
        

        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Parent = myRoot
        bodyVelocity.Velocity = Vector3.new(0,0,0)
        bodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)
        

        myHumanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        

        if targetRoot then
            SuperFling(targetRoot)
        elseif targetHead then
            SuperFling(targetHead)
        elseif targetHandle then
            SuperFling(targetHandle)
        else
            bodyVelocity:Destroy()
            if Protection then SetProtection(false) end
            return Notify("Error", targetPlayer.Name .. " has no valid parts", 2)
        end
        

        bodyVelocity:Destroy()
        myHumanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = myHumanoid
        

        if getgenv().OldPos then
            repeat
                myRoot.Position = getgenv().OldPos * CFrame.new(0,.5,0)
                myChar:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0,.5,0))
                myHumanoid:ChangeState("GettingUp")
                for _, part in pairs(myChar:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
                    end
                end
                task.wait()
            until (myRoot.Position - getgenv().OldPos.p).Magnitude < 25
            
            workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
        

        if Protection then SetProtection(false) end
    else
        return Notify("Error", "Your character is not ready", 2)
    end
end


local function CountTargets()
    local count = 0
    for _ in pairs(Targets) do
        count = count + 1
    end
    return count
end


local function StartFling()
    if Flinging then return end
    
    local targetCount = CountTargets()
    if targetCount == 0 then
        Notify("Warning", "No targets selected!", 2)
        return
    end
    
    Flinging = true
    if Protection then SetProtection(true) end
    
    Notify("Started", "Flinging " .. targetCount .. " targets", 2)
    
    spawn(function()
        while Flinging do
            local validTargets = {}
            for name, player in pairs(Targets) do
                if player and player.Parent then
                    validTargets[name] = player
                else
                    Targets[name] = nil
                end
            end
            
            for _, player in pairs(validTargets) do
                if Flinging then
                    FlingPlayer(player)
                    wait(0.1)
                else
                    break
                end
            end
            wait(0.5)
        end
    end)
end


local function StopFling()
    if not Flinging then return end
    Flinging = false
    if Protection then SetProtection(false) end
    Notify("Stopped", "Fling has been stopped", 2)
end

local Window = Library:CreateWindow({
    Name = "Simple Fling GUI v1.0",
    LoadingTitle = "Simple Fling GUI",
    LoadingSubtitle = "v1.0",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local FlingTab = Window:CreateTab("Fling", 4483362458)
FlingTab:CreateSection("Controls")

FlingTab:CreateButton({
    Name = "Start Fling",
    Callback = function() StartFling() end
})

FlingTab:CreateButton({
    Name = "Stop Fling",
    Callback = function() StopFling() end
})

FlingTab:CreateButton({
    Name = "Select All Players",
    Callback = function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                Targets[player.Name] = player
            end
        end
        Notify("Selected", "All players selected (" .. CountTargets() .. ")", 2)
    end
})

FlingTab:CreateButton({
    Name = "Deselect All Players",
    Callback = function()
        Targets = {}
        Notify("Deselected", "All players deselected", 2)
    end
})

local playerNames = {}
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        table.insert(playerNames, player.Name)
    end
end

FlingTab:CreateDropdown({
    Name = "Select Players",
    Options = playerNames,
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "SelectedPlayers",
    Callback = function(selected)
        Targets = {}
        for _, name in ipairs(selected) do
            local player = Players:FindFirstChild(name)
            if player then
                Targets[name] = player
            end
        end
        Notify("Updated", CountTargets() .. " targets selected", 2)
    end
})

FlingTab:CreateSection("Protection")

FlingTab:CreateToggle({
    Name = "Auto-Fling Protection",
    CurrentValue = true,
    Flag = "AutoFlingProtection",
    Callback = function(value)
        Protection = value
        if value then
            Notify("Protection", "Auto-Fling Protection enabled", 2)
        else
            Notify("Protection", "Auto-Fling Protection disabled", 2)
        end
    end
})

local PlayersTab = Window:CreateTab("Players", 4483362458)
PlayersTab:CreateSection("Select Targets")

local function CreatePlayerToggles()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not ToggleButtons[player.Name] then
            ToggleButtons[player.Name] = PlayersTab:CreateToggle({
                Name = player.Name,
                CurrentValue = Targets[player.Name] ~= nil,
                Flag = "Target_" .. player.Name,
                Callback = function(value)
                    if value then
                        Targets[player.Name] = player
                    else
                        Targets[player.Name] = nil
                    end
                end
            })
        end
    end
end

local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateSection("Collision")

SettingsTab:CreateButton({
    Name = "Enable Collision",
    Callback = function()
        EnableCollision(LocalPlayer.Character)
        Notify("Collision", "Collision enabled", 2)
    end
})

SettingsTab:CreateButton({
    Name = "Disable Collision",
    Callback = function()
        DisableCollision(LocalPlayer.Character)
        Notify("Collision", "Collision disabled", 2)
    end
})

SettingsTab:CreateSection("General")

SettingsTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        ToggleButtons = {}
        CreatePlayerToggles()
        Notify("Refreshed", "Player list updated", 2)
    end
})

SettingsTab:CreateButton({
    Name = "Destroy GUI",
    Callback = function()
        StopFling()
        if Protection then
            DisableCollision(LocalPlayer.Character)
        end
        Library:Destroy()
    end
})

CreatePlayerToggles()

Players.PlayerAdded:Connect(function(player)
    wait(1)
    if player ~= LocalPlayer and not ToggleButtons[player.Name] then
        ToggleButtons[player.Name] = PlayersTab:CreateToggle({
            Name = player.Name,
            CurrentValue = false,
            Flag = "Target_" .. player.Name,
            Callback = function(value)
                if value then
                    Targets[player.Name] = player
                else
                    Targets[player.Name] = nil
                end
            end
        })
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if Targets[player.Name] then
        Targets[player.Name] = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    if Protection and not Flinging then
        wait(1)
        DisableCollision(character)
    end
end)

Notify("Loaded", "Simple Fling GUI v1.0 loaded successfully", 3)
