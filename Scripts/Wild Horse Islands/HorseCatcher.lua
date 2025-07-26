-- Horse Catcher Pro - Simplified Edition
-- by Iyxo - 2025-07-26
-- Simplified horse catching with essential features only

local parentTab, Rayfield, Window = ...

-- =================================
-- SERVICES
-- =================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- =================================
-- SIMPLE CACHE SYSTEM
-- =================================
local Cache = {
    horses = {},
    lastUpdate = 0,
    updateInterval = 2
}

-- =================================
-- HORSE CATCHER SYSTEM
-- =================================
local horseCatcher = {
    isRunning = false,
    currentTarget = nil,
    isAttached = false,
    currentLassoID = nil,
    
    connections = {
        capture = nil,
        targeting = nil
    },
    
    capturedHorses = {},
    statistics = {
        totalCaptured = 0,
        currentStreak = 0
    },
    
    settings = {
        captureCooldown = 0.4,
        attachmentOffset = 4,
        targetingRadius = 200
    },
    
    runtime = {
        lastCaptureTime = 0,
        sessionStartTime = 0
    }
}

-- Game System Detection
local gameSystem = {
    u1 = nil,
    u2 = nil, 
    u3 = nil,
    available = false,
    networkReady = false
}

pcall(function()
    gameSystem.u1 = require(ReplicatedStorage.References)
    gameSystem.u2 = gameSystem.u1.Utilities
    gameSystem.u3 = require(gameSystem.u1.PlayerScripts.Priority.Data)
    gameSystem.available = true
    gameSystem.networkReady = (gameSystem.u2 and gameSystem.u2.Network) and true or false
end)

-- =================================
-- BASIC FUNCTIONS
-- =================================

local function detectCurrentIsland()
    return player:GetAttribute("island") or "Unknown"
end

local function isWildHorse(horse)
    if not horse then return false end
    
    local success, isWild = pcall(function()
        local overheadPart = horse:FindFirstChild("OverheadPart")
        if overheadPart then
            local overhead = overheadPart:FindFirstChild("Overhead")
            if overhead then
                local nameLabel = overhead:FindFirstChild("NameLabel")
                if nameLabel and nameLabel.Text == "Wild" then
                    return true
                end
            end
        end
        return false
    end)
    
    return success and isWild
end

local function updateHorseCache()
    local currentTime = tick()
    if currentTime - Cache.lastUpdate < Cache.updateInterval then
        return Cache.horses
    end
    
    Cache.horses = {}
    local horseCount = 0
    local playerPos = humanoidRootPart.Position
    
    pcall(function()
        if Workspace.Islands then
            for _, island in pairs(Workspace.Islands:GetChildren()) do
                if island:IsA("Model") then
                    for _, child in pairs(island:GetChildren()) do
                        if child.Name:find("{") and child:FindFirstChild("HumanoidRootPart") then
                            local humanoid = child:FindFirstChild("Humanoid")
                            if humanoid and humanoid.Health > 0 and not Players:GetPlayerFromCharacter(child) then
                                if isWildHorse(child) and not horseCatcher.capturedHorses[child.Name] then
                                    local distance = (playerPos - child.HumanoidRootPart.Position).Magnitude
                                    
                                    if distance <= horseCatcher.settings.targetingRadius then
                                        horseCount = horseCount + 1
                                        Cache.horses[horseCount] = {
                                            horse = child,
                                            distance = distance
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- Sort by distance
    table.sort(Cache.horses, function(a, b)
        return a.distance < b.distance
    end)
    
    Cache.lastUpdate = currentTime
    return Cache.horses
end

local function equipLasso()
    if horseCatcher.currentLassoID then
        return true
    end
    
    local success = false
    local toolID = nil
    
    if gameSystem.available and gameSystem.u3 and gameSystem.networkReady then
        pcall(function()
            local inventory = gameSystem.u3.GetLocal({"inventory"}) or {}
            for itemId, itemData in pairs(inventory) do
                if itemId:find("{") and itemData.id then
                    local itemInfo = gameSystem.u1.Items.GetInfo(itemData.id)
                    if itemInfo and itemInfo.name and itemInfo.name:lower():find("lasso") then
                        gameSystem.u2.Network:FireServer("Inventory", "Use", itemId)
                        success = true
                        toolID = itemId
                        break
                    end
                end
            end
        end)
    end
    
    if not success then
        toolID = "{60769f1f-cade-463b-ae32-adaacc91116f}"
        success = true
    end
    
    if success then
        horseCatcher.currentLassoID = toolID
    end
    
    return success
end

local function findTarget()
    local horses = updateHorseCache()
    return horses[1] and horses[1].horse
end

local function captureHorse(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") or not horseCatcher.currentLassoID then
        return false
    end
    
    local currentTime = tick()
    if currentTime - horseCatcher.runtime.lastCaptureTime < horseCatcher.settings.captureCooldown then
        return false
    end
    
    local success = false
    
    pcall(function()
        if gameSystem.available and gameSystem.networkReady then
            gameSystem.u2.Network:FireServer("Equipment", horseCatcher.currentLassoID, "Activate", horse)
            success = true
        end
        horseCatcher.runtime.lastCaptureTime = currentTime
    end)
    
    return success
end

local function attachToHorse(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") then return false end
    
    pcall(function()
        -- Remove existing attachments
        for _, attachment in pairs(humanoidRootPart:GetChildren()) do
            if attachment.Name == "HorseAttachment" and attachment:IsA("WeldConstraint") then
                attachment:Destroy()
            end
        end
        
        local horseRoot = horse.HumanoidRootPart
        local horsePos = horseRoot.Position
        local sideOffset = horseRoot.CFrame.RightVector * horseCatcher.settings.attachmentOffset
        local heightOffset = Vector3.new(0, 3, 0)
        
        humanoidRootPart.CFrame = CFrame.lookAt(horsePos + sideOffset + heightOffset, horsePos)
        wait(0.03)
        
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = humanoidRootPart
        weld.Part1 = horseRoot
        weld.Parent = humanoidRootPart
        weld.Name = "HorseAttachment"
        
        horseCatcher.isAttached = true
    end)
    
    return true
end

local function detachFromHorse()
    pcall(function()
        for _, attachment in pairs(humanoidRootPart:GetChildren()) do
            if attachment.Name == "HorseAttachment" and attachment:IsA("WeldConstraint") then
                attachment:Destroy()
            end
        end
        horseCatcher.isAttached = false
    end)
end

local function isHorseCaptured(horse)
    if not horse or not horse.Parent then
        return true
    end
    
    local captured = false
    
    pcall(function()
        local overheadPart = horse:FindFirstChild("OverheadPart")
        if overheadPart then
            local overhead = overheadPart:FindFirstChild("Overhead")
            if overhead then
                local nameLabel = overhead:FindFirstChild("NameLabel")
                if nameLabel and nameLabel.Text ~= "Wild" then
                    captured = true
                end
            end
        end
        
        if not captured then
            local humanoid = horse:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then
                captured = true
            end
        end
    end)
    
    if captured then
        horseCatcher.capturedHorses[horse.Name] = true
        horseCatcher.statistics.totalCaptured = horseCatcher.statistics.totalCaptured + 1
        horseCatcher.statistics.currentStreak = horseCatcher.statistics.currentStreak + 1
        
        Rayfield:Notify({
           Title = "🎉 Horse Captured!",
           Content = "Streak: " .. horseCatcher.statistics.currentStreak,
           Duration = 2,
           Image = 4483362458,
        })
    end
    
    return captured
end

-- =================================
-- MAIN LOGIC
-- =================================
local function startHorseCatching()
    if horseCatcher.isRunning then return false end
    
    if not equipLasso() then
        Rayfield:Notify({
           Title = "❌ No Lasso Found!",
           Content = "Lasso required to catch horses",
           Duration = 3,
           Image = 4483362458,
        })
        return false
    end
    
    if not gameSystem.available or not gameSystem.networkReady then
        Rayfield:Notify({
           Title = "❌ Network Error!",
           Content = "Cannot access game systems",
           Duration = 3,
           Image = 4483362458,
        })
        return false
    end
    
    horseCatcher.isRunning = true
    horseCatcher.runtime.sessionStartTime = tick()
    horseCatcher.statistics.currentStreak = 0
    
    local currentIsland = detectCurrentIsland()
    
    Rayfield:Notify({
       Title = "🚀 Horse Catching Started!",
       Content = "Island: " .. currentIsland,
       Duration = 2,
       Image = 4483362458,
    })
    
    horseCatcher.connections.capture = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        
        -- Check current target
        if horseCatcher.currentTarget then
            if isHorseCaptured(horseCatcher.currentTarget) then
                detachFromHorse()
                horseCatcher.currentTarget = nil
                return
            end
        end
        
        -- Find new target if needed
        if not horseCatcher.currentTarget then
            horseCatcher.currentTarget = findTarget()
            if horseCatcher.currentTarget then
                attachToHorse(horseCatcher.currentTarget)
            else
                detachFromHorse()
                return
            end
        end
        
        -- Capture current target
        if horseCatcher.currentTarget then
            if not horseCatcher.isAttached then
                attachToHorse(horseCatcher.currentTarget)
            end
            captureHorse(horseCatcher.currentTarget)
        end
    end)
    
    return true
end

local function stopHorseCatching()
    horseCatcher.isRunning = false
    
    for name, connection in pairs(horseCatcher.connections) do
        if connection then
            connection:Disconnect()
            horseCatcher.connections[name] = nil
        end
    end
    
    detachFromHorse()
    horseCatcher.currentTarget = nil
    
    local sessionTime = tick() - horseCatcher.runtime.sessionStartTime
    local minutes = math.floor(sessionTime / 60)
    local seconds = math.floor(sessionTime % 60)
    
    Rayfield:Notify({
       Title = "🏁 Session Ended",
       Content = "Captured: " .. horseCatcher.statistics.currentStreak .. " | Time: " .. minutes .. "m " .. seconds .. "s",
       Duration = 3,
       Image = 4483362458,
    })
end

-- =================================
-- SIMPLIFIED UI
-- =================================

-- Main Control
local MainControlSection = parentTab:CreateSection("🎯 Horse Catcher")

local MainToggle = parentTab:CreateToggle({
   Name = "🚀 Start Horse Catching",
   CurrentValue = false,
   Flag = "HorseCatchingMainToggle",
   Callback = function(Value)
      if Value then
         local success = startHorseCatching()
         if not success then
            MainToggle:Set(false)
         end
      else
         stopHorseCatching()
      end
   end,
})

-- Settings
local SettingsSection = parentTab:CreateSection("⚙️ Settings")

local CaptureCooldownSlider = parentTab:CreateSlider({
   Name = "⏱️ Capture Cooldown",
   Range = {0.2, 1},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0.4,
   Flag = "CaptureCooldownSlider",
   Callback = function(Value)
      horseCatcher.settings.captureCooldown = Value
   end,
})

local AttachmentOffsetSlider = parentTab:CreateSlider({
   Name = "📏 Attachment Distance",
   Range = {2, 8},
   Increment = 1,
   Suffix = " studs",
   CurrentValue = 4,
   Flag = "AttachmentOffsetSlider",
   Callback = function(Value)
      horseCatcher.settings.attachmentOffset = Value
   end,
})

local TargetingRadiusSlider = parentTab:CreateSlider({
   Name = "🎯 Targeting Range",
   Range = {100, 300},
   Increment = 25,
   Suffix = " studs",
   CurrentValue = 200,
   Flag = "TargetingRadiusSlider",
   Callback = function(Value)
      horseCatcher.settings.targetingRadius = Value
   end,
})

-- Status
local StatusSection = parentTab:CreateSection("📊 Status")

local StatusInfo = parentTab:CreateParagraph({Title = "📊 Current Status", Content = "Ready to start"})

-- Quick Actions
local ActionsSection = parentTab:CreateSection("⚡ Actions")

local ResetCapturedButton = parentTab:CreateButton({
   Name = "🔄 Reset Captured List",
   Callback = function()
      horseCatcher.capturedHorses = {}
      Rayfield:Notify({
         Title = "✅ List Reset",
         Content = "Captured horses list cleared",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- =================================
-- STATUS UPDATE
-- =================================
spawn(function()
    while wait(2) do
        local currentIsland = detectCurrentIsland()
        local horseCount = #Cache.horses
        
        local statusText = "🏝️ Island: " .. currentIsland .. "\n"
        statusText = statusText .. "🐎 Wild Horses: " .. horseCount .. "\n"
        
        if horseCatcher.isRunning then
            local sessionTime = tick() - horseCatcher.runtime.sessionStartTime
            local minutes = math.floor(sessionTime / 60)
            local seconds = math.floor(sessionTime % 60)
            
            statusText = statusText .. "⏱️ Session: " .. minutes .. "m " .. seconds .. "s\n"
            statusText = statusText .. "🏆 Captured: " .. horseCatcher.statistics.currentStreak .. "\n"
            
            if horseCatcher.currentTarget then
                statusText = statusText .. "🎯 Status: Targeting\n"
                statusText = statusText .. "🔗 Attached: " .. (horseCatcher.isAttached and "✅" or "❌")
            else
                statusText = statusText .. "🔍 Status: Searching"
            end
        else
            statusText = statusText .. "📊 Status: Stopped\n"
            statusText = statusText .. "🏆 Total Captured: " .. horseCatcher.statistics.totalCaptured
        end
        
        StatusInfo:Set({Title = "📊 Current Status", Content = statusText})
    end
end)

-- Character respawn handling
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    horseCatcher.isAttached = false
    horseCatcher.currentLassoID = nil
    
    if horseCatcher.isRunning then
        stopHorseCatching()
        MainToggle:Set(false)
        
        Rayfield:Notify({
           Title = "🔄 Character Respawned",
           Content = "Horse catching stopped",
           Duration = 2,
           Image = 4483362458,
        })
    end
end)

-- =================================
-- INITIALIZATION
-- =================================
Rayfield:Notify({
   Title = "🚀 Horse Catcher Loaded!",
   Content = "Simplified edition ready | Island: " .. detectCurrentIsland(),
   Duration = 3,
   Image = 4483362458,
})
