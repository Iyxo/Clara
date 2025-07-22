-- Horse Manipulator Ultimate Edition - Catch Aura + Optimized
-- by Iyxo - 2025-07-22
-- The most OP horse exploit ever created - Unlimited range + Catch Aura

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
-- ULTIMATE HORSE SYSTEM
-- =================================
local ultimateHorseSystem = {
    -- Status
    manipulationRunning = false,
    catchAuraRunning = false,
    manipulatedHorses = {},
    
    -- Connections
    manipulationConnection = nil,
    enforcementConnection = nil,
    catchAuraConnection = nil,
    
    -- Settings
    settings = {
        -- Manipulation settings
        enableFollower = true,
        enableFleeDistance = true,
        enableLastPlayerToThrow = true,
        continuousEnforcement = true,
        fleeDistance = 0,
        behaviour = "Follower",
        
        -- Catch Aura settings
        catchAuraEnabled = true,
        catchAuraRadius = 150,
        catchCooldown = 0.4,
        autoTargetNearest = true,
        
        -- Performance settings
        manipulationInterval = 1.5,
        enforcementInterval = 0.3,
        catchAuraInterval = 0.5,
        maxProcessPerFrame = 5,
        
        -- Advanced
        unlimitedRange = false,
        smartTargeting = true,
        onlyWildHorses = true
    },
    
    -- Runtime data
    runtime = {
        lastManipulationTime = 0,
        lastEnforcementTime = 0,
        lastCatchTime = 0,
        manipulatedCount = 0,
        catchAttempts = 0,
        sessionStartTime = 0,
        enforcementCount = 0,
        successfulCatches = 0,
        currentTarget = nil
    },
    
    -- Statistics
    statistics = {
        totalManipulated = 0,
        totalEnforcements = 0,
        totalCatchAttempts = 0,
        successfulCatches = 0,
        sessionsRun = 0,
        bestCatchStreak = 0,
        currentCatchStreak = 0
    },
    
    -- Cache for performance
    cache = {
        wildHorses = {},
        manipulatedHorses = {},
        lastCacheUpdate = 0,
        cacheInterval = 2
    }
}

-- Game System Detection
local gameSystem = {
    u1 = nil,
    u2 = nil, 
    u3 = nil,
    available = false,
    remoteEvent = nil
}

-- Initialize game system
pcall(function()
    gameSystem.u1 = require(ReplicatedStorage.References)
    gameSystem.u2 = gameSystem.u1.Utilities
    gameSystem.u3 = require(gameSystem.u1.PlayerScripts.Priority.Data)
    gameSystem.available = true
    gameSystem.remoteEvent = ReplicatedStorage.Communication.Events['']
end)

-- =================================
-- OPTIMIZED CORE FUNCTIONS
-- =================================

-- Get real horse name from BreedLabel (cached)
local function getHorseName(horse)
    if not horse then return "Unknown" end
    
    local horseName = "Unknown"
    pcall(function()
        local overheadPart = horse:FindFirstChild("OverheadPart")
        if overheadPart then
            local overhead = overheadPart:FindFirstChild("Overhead")
            if overhead then
                local breedLabel = overhead:FindFirstChild("BreedLabel")
                if breedLabel and breedLabel.Text and breedLabel.Text ~= "" then
                    horseName = breedLabel.Text
                else
                    horseName = horse.Name:sub(2, 9) -- Better ID display
                end
            end
        end
    end)
    
    return horseName
end

-- Check if horse is wild (optimized)
local function isWildHorse(horse)
    if not horse then return false end
    
    local isWild = false
    pcall(function()
        local overheadPart = horse:FindFirstChild("OverheadPart")
        if overheadPart then
            local overhead = overheadPart:FindFirstChild("Overhead")
            if overhead then
                local nameLabel = overhead:FindFirstChild("NameLabel")
                if nameLabel and nameLabel.Text == "Wild" then
                    isWild = true
                end
            end
        end
    end)
    
    return isWild
end

-- Get lasso ID (optimized)
local function getLassoID()
    local lassoID = "{60769f1f-cade-463b-ae32-adaacc91116f}" -- Default fallback
    
    if gameSystem.available and gameSystem.u3 then
        pcall(function()
            local lastEquipped = gameSystem.u3.GetLocal({"lastEquippedLasso"})
            if lastEquipped then
                lassoID = lastEquipped
            end
        end)
    end
    
    return lassoID
end

-- OPTIMIZED: Get all horses with caching system
local function updateHorseCache()
    local currentTime = tick()
    if currentTime - ultimateHorseSystem.cache.lastCacheUpdate < ultimateHorseSystem.cache.cacheInterval then
        return
    end
    
    local wildHorses = {}
    local manipulatedHorses = {}
    local playerPos = humanoidRootPart.Position
    
    pcall(function()
        local function scanLocation(location)
            for _, child in pairs(location:GetChildren()) do
                if child.Name:match("%{[%w%-]+%}") and child:FindFirstChild("HumanoidRootPart") then
                    local humanoid = child:FindFirstChild("Humanoid")
                    if humanoid and not Players:GetPlayerFromCharacter(child) and humanoid.Health > 0 then
                        local distance = (playerPos - child.HumanoidRootPart.Position).Magnitude
                        
                        if ultimateHorseSystem.settings.onlyWildHorses and isWildHorse(child) then
                            table.insert(wildHorses, {
                                horse = child,
                                distance = distance,
                                name = getHorseName(child),
                                velocity = child.HumanoidRootPart.Velocity.Magnitude
                            })
                        end
                        
                        -- Check if manipulated
                        if ultimateHorseSystem.manipulatedHorses[child.Name] then
                            table.insert(manipulatedHorses, child)
                        end
                    end
                end
            end
        end
        
        -- Scan all locations
        if Workspace.Islands and Workspace.Islands.Mainland then
            scanLocation(Workspace.Islands.Mainland)
        end
        if Workspace.Islands then
            scanLocation(Workspace.Islands)
        end
    end)
    
    -- Sort by distance for catch aura
    table.sort(wildHorses, function(a, b) return a.distance < b.distance end)
    
    ultimateHorseSystem.cache.wildHorses = wildHorses
    ultimateHorseSystem.cache.manipulatedHorses = manipulatedHorses
    ultimateHorseSystem.cache.lastCacheUpdate = currentTime
end

-- Get filtered horses based on settings
local function getFilteredHorses()
    updateHorseCache()
    
    local filtered = {}
    
    for _, horseData in pairs(ultimateHorseSystem.cache.wildHorses) do
        local include = true
        
        -- Range filter (unless unlimited)
        if not ultimateHorseSystem.settings.unlimitedRange then
            if horseData.distance > ultimateHorseSystem.settings.catchAuraRadius then
                include = false
            end
        end
        
        -- Skip already manipulated
        if ultimateHorseSystem.manipulatedHorses[horseData.horse.Name] then
            include = false
        end
        
        if include then
            table.insert(filtered, horseData)
        end
    end
    
    return filtered
end

-- =================================
-- ATTRIBUTE MANIPULATION (OPTIMIZED)
-- =================================

-- CONTINUOUS ATTRIBUTE ENFORCEMENT (SUPER FAST)
local function enforceHorseAttributes(horse)
    if not horse then return false end
    
    local success = false
    
    pcall(function()
        local changed = false
        
        -- FORCE behaviour to Follower (if enabled)
        if ultimateHorseSystem.settings.enableFollower then
            if horse:GetAttribute("behaviour") ~= ultimateHorseSystem.settings.behaviour then
                horse:SetAttribute("behaviour", ultimateHorseSystem.settings.behaviour)
                changed = true
            end
            
            if horse:GetAttribute("followPlayer") ~= player.Name then
                horse:SetAttribute("followPlayer", player.Name)
                changed = true
            end
        end
        
        -- FORCE flee distance to 0 (if enabled)
        if ultimateHorseSystem.settings.enableFleeDistance then
            if horse:GetAttribute("fleeDistance") ~= ultimateHorseSystem.settings.fleeDistance then
                horse:SetAttribute("fleeDistance", ultimateHorseSystem.settings.fleeDistance)
                changed = true
            end
        end
        
        -- FORCE last player to throw lasso (if enabled)
        if ultimateHorseSystem.settings.enableLastPlayerToThrow then
            if horse:GetAttribute("lastPlayerToThrowLasso") ~= player.Name then
                horse:SetAttribute("lastPlayerToThrowLasso", player.Name)
                changed = true
            end
        end
        
        if changed then
            ultimateHorseSystem.runtime.enforcementCount = ultimateHorseSystem.runtime.enforcementCount + 1
            ultimateHorseSystem.statistics.totalEnforcements = ultimateHorseSystem.statistics.totalEnforcements + 1
        end
        
        success = true
    end)
    
    return success
end

-- INITIAL ATTRIBUTE MANIPULATION
local function manipulateHorseAttributes(horse)
    if not horse then return false end
    
    local success = false
    local horseName = getHorseName(horse)
    
    pcall(function()
        -- Set all attributes at once
        if ultimateHorseSystem.settings.enableFollower then
            horse:SetAttribute("behaviour", ultimateHorseSystem.settings.behaviour)
            horse:SetAttribute("followPlayer", player.Name)
        end
        
        if ultimateHorseSystem.settings.enableFleeDistance then
            horse:SetAttribute("fleeDistance", ultimateHorseSystem.settings.fleeDistance)
        end
        
        if ultimateHorseSystem.settings.enableLastPlayerToThrow then
            horse:SetAttribute("lastPlayerToThrowLasso", player.Name)
        end
        
        -- Mark as manipulated
        ultimateHorseSystem.manipulatedHorses[horse.Name] = {
            name = horseName,
            time = tick(),
            controlled = true
        }
        
        ultimateHorseSystem.runtime.manipulatedCount = ultimateHorseSystem.runtime.manipulatedCount + 1
        ultimateHorseSystem.statistics.totalManipulated = ultimateHorseSystem.statistics.totalManipulated + 1
        
        success = true
    end)
    
    return success, horseName
end

-- =================================
-- CATCH AURA SYSTEM - THE MAGIC!
-- =================================

-- ULTIMATE CATCH AURA - Auto catches nearest horse
local function performCatchAura()
    if not ultimateHorseSystem.catchAuraRunning then return end
    if not gameSystem.available or not gameSystem.u2 then return end
    
    local currentTime = tick()
    if currentTime - ultimateHorseSystem.runtime.lastCatchTime < ultimateHorseSystem.settings.catchCooldown then
        return
    end
    
    local horses = getFilteredHorses()
    if #horses == 0 then return end
    
    -- Get target based on settings
    local target = nil
    if ultimateHorseSystem.settings.autoTargetNearest then
        target = horses[1] -- Already sorted by distance
    else
        target = ultimateHorseSystem.runtime.currentTarget and 
                 {horse = ultimateHorseSystem.runtime.currentTarget} or horses[1]
    end
    
    if not target or not target.horse then return end
    
    local horse = target.horse
    local lassoID = getLassoID()
    
    pcall(function()
        -- CONFIRMED WORKING CATCH METHOD
        gameSystem.u2.Network:FireServer("Equipment", lassoID, "Activate", horse)
        
        ultimateHorseSystem.runtime.lastCatchTime = currentTime
        ultimateHorseSystem.runtime.catchAttempts = ultimateHorseSystem.runtime.catchAttempts + 1
        ultimateHorseSystem.statistics.totalCatchAttempts = ultimateHorseSystem.statistics.totalCatchAttempts + 1
        ultimateHorseSystem.runtime.currentTarget = horse
        
        -- Check if caught (simple check)
        spawn(function()
            wait(1)
            if isHorseCaptured(horse) then
                ultimateHorseSystem.runtime.successfulCatches = ultimateHorseSystem.runtime.successfulCatches + 1
                ultimateHorseSystem.statistics.successfulCatches = ultimateHorseSystem.statistics.successfulCatches + 1
                ultimateHorseSystem.statistics.currentCatchStreak = ultimateHorseSystem.statistics.currentCatchStreak + 1
                
                if ultimateHorseSystem.statistics.currentCatchStreak > ultimateHorseSystem.statistics.bestCatchStreak then
                    ultimateHorseSystem.statistics.bestCatchStreak = ultimateHorseSystem.statistics.currentCatchStreak
                end
                
                Rayfield:Notify({
                   Title = "🎯 Horse Caught!",
                   Content = getHorseName(horse) .. " | Streak: " .. ultimateHorseSystem.statistics.currentCatchStreak,
                   Duration = 2,
                   Image = 4483362458,
                })
            end
        end)
    end)
end

-- Check if horse was captured
local function isHorseCaptured(horse)
    if not horse or not horse.Parent then return true end
    
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
        
        local humanoid = horse:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            captured = true
        end
    end)
    
    return captured
end

-- =================================
-- MAIN SYSTEM LOGIC - OPTIMIZED & ULTIMATE
-- =================================
local function startUltimateSystem()
    if ultimateHorseSystem.manipulationRunning then return false end
    
    ultimateHorseSystem.manipulationRunning = true
    ultimateHorseSystem.runtime.sessionStartTime = tick()
    ultimateHorseSystem.statistics.sessionsRun = ultimateHorseSystem.statistics.sessionsRun + 1
    ultimateHorseSystem.runtime.manipulatedCount = 0
    ultimateHorseSystem.runtime.enforcementCount = 0
    ultimateHorseSystem.runtime.catchAttempts = 0
    ultimateHorseSystem.runtime.successfulCatches = 0
    ultimateHorseSystem.statistics.currentCatchStreak = 0
    
    Rayfield:Notify({
       Title = "🚀 Ultimate Horse System Started!",
       Content = "Manipulation + Catch Aura active | Range: " .. (ultimateHorseSystem.settings.unlimitedRange and "UNLIMITED" or ultimateHorseSystem.settings.catchAuraRadius),
       Duration = 4,
       Image = 4483362458,
    })
    
    -- MANIPULATION CONNECTION (Optimized)
    ultimateHorseSystem.manipulationConnection = RunService.Heartbeat:Connect(function()
        if not ultimateHorseSystem.manipulationRunning then return end
        
        local currentTime = tick()
        if currentTime - ultimateHorseSystem.runtime.lastManipulationTime < ultimateHorseSystem.settings.manipulationInterval then
            return
        end
        
        local horses = getFilteredHorses()
        local manipulated = 0
        
        for i, horseData in pairs(horses) do
            if manipulated >= ultimateHorseSystem.settings.maxProcessPerFrame then break end
            
            local horse = horseData.horse
            if not ultimateHorseSystem.manipulatedHorses[horse.Name] then
                local success, horseName = manipulateHorseAttributes(horse)
                if success then
                    manipulated = manipulated + 1
                end
            end
        end
        
        ultimateHorseSystem.runtime.lastManipulationTime = currentTime
    end)
    
    -- ENFORCEMENT CONNECTION (Super fast)
    if ultimateHorseSystem.settings.continuousEnforcement then
        ultimateHorseSystem.enforcementConnection = RunService.Heartbeat:Connect(function()
            if not ultimateHorseSystem.manipulationRunning then return end
            
            local currentTime = tick()
            if currentTime - ultimateHorseSystem.runtime.lastEnforcementTime < ultimateHorseSystem.settings.enforcementInterval then
                return
            end
            
            local processed = 0
            for _, horse in pairs(ultimateHorseSystem.cache.manipulatedHorses) do
                if processed >= ultimateHorseSystem.settings.maxProcessPerFrame then break end
                enforceHorseAttributes(horse)
                processed = processed + 1
            end
            
            ultimateHorseSystem.runtime.lastEnforcementTime = currentTime
        end)
    end
    
    return true
end

local function startCatchAura()
    if ultimateHorseSystem.catchAuraRunning then return false end
    
    ultimateHorseSystem.catchAuraRunning = true
    
    Rayfield:Notify({
       Title = "🎯 Catch Aura Started!",
       Content = "Auto-catching enabled | Range: " .. (ultimateHorseSystem.settings.unlimitedRange and "UNLIMITED" or ultimateHorseSystem.settings.catchAuraRadius),
       Duration = 3,
       Image = 4483362458,
    })
    
    -- CATCH AURA CONNECTION
    ultimateHorseSystem.catchAuraConnection = RunService.Heartbeat:Connect(function()
        if not ultimateHorseSystem.catchAuraRunning then return end
        
        local currentTime = tick()
        if currentTime - ultimateHorseSystem.runtime.lastCatchTime >= ultimateHorseSystem.settings.catchAuraInterval then
            performCatchAura()
        end
    end)
    
    return true
end

local function stopUltimateSystem()
    ultimateHorseSystem.manipulationRunning = false
    
    if ultimateHorseSystem.manipulationConnection then
        ultimateHorseSystem.manipulationConnection:Disconnect()
        ultimateHorseSystem.manipulationConnection = nil
    end
    
    if ultimateHorseSystem.enforcementConnection then
        ultimateHorseSystem.enforcementConnection:Disconnect()
        ultimateHorseSystem.enforcementConnection = nil
    end
    
    local sessionTime = tick() - ultimateHorseSystem.runtime.sessionStartTime
    local minutes = math.floor(sessionTime / 60)
    local seconds = math.floor(sessionTime % 60)
    
    Rayfield:Notify({
       Title = "🛑 Ultimate System Stopped",
       Content = "Manipulated: " .. ultimateHorseSystem.runtime.manipulatedCount .. " | Enforcements: " .. ultimateHorseSystem.runtime.enforcementCount,
       Duration = 4,
       Image = 4483362458,
    })
end

local function stopCatchAura()
    ultimateHorseSystem.catchAuraRunning = false
    
    if ultimateHorseSystem.catchAuraConnection then
        ultimateHorseSystem.catchAuraConnection:Disconnect()
        ultimateHorseSystem.catchAuraConnection = nil
    end
    
    Rayfield:Notify({
       Title = "🛑 Catch Aura Stopped",
       Content = "Caught: " .. ultimateHorseSystem.runtime.successfulCatches .. " | Attempts: " .. ultimateHorseSystem.runtime.catchAttempts,
       Duration = 3,
       Image = 4483362458,
    })
end

-- =================================
-- UI SECTIONS & CONTROLS - ULTIMATE EDITION
-- =================================

-- 🚀 ULTIMATE CONTROL SECTION
local UltimateControlSection = parentTab:CreateSection("🚀 Ultimate Control")

local UltimateToggle = parentTab:CreateToggle({
   Name = "🚀 Ultimate Horse System",
   CurrentValue = false,
   Flag = "UltimateHorseSystemToggle",
   Callback = function(Value)
      if Value then
         local success = startUltimateSystem()
         if not success then
            UltimateToggle:Set(false)
         end
      else
         stopUltimateSystem()
      end
   end,
})

local CatchAuraToggle = parentTab:CreateToggle({
   Name = "🎯 Catch Aura",
   CurrentValue = false,
   Flag = "CatchAuraToggle",
   Callback = function(Value)
      if Value then
         local success = startCatchAura()
         if not success then
            CatchAuraToggle:Set(false)
         end
      else
         stopCatchAura()
      end
   end,
})

local UnlimitedRangeToggle = parentTab:CreateToggle({
   Name = "♾️ Unlimited Range",
   CurrentValue = false,
   Flag = "UnlimitedRangeToggle",
   Callback = function(Value)
      ultimateHorseSystem.settings.unlimitedRange = Value
      Rayfield:Notify({
         Title = "♾️ Range " .. (Value and "UNLIMITED" or "Limited"),
         Content = Value and "All horses on the map!" or "Range limited to radius",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- 🎯 CATCH AURA SETTINGS SECTION
local CatchAuraSettingsSection = parentTab:CreateSection("🎯 Catch Aura Settings")

local CatchAuraRadiusSlider = parentTab:CreateSlider({
   Name = "📍 Catch Aura Radius",
   Range = {25, 500},
   Increment = 5,
   Suffix = " studs",
   CurrentValue = 150,
   Flag = "CatchAuraRadiusSlider",
   Callback = function(Value)
      ultimateHorseSystem.settings.catchAuraRadius = Value
   end,
})

local CatchCooldownSlider = parentTab:CreateSlider({
   Name = "⏱️ Catch Cooldown",
   Range = {0.1, 2},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0.4,
   Flag = "CatchCooldownSlider",
   Callback = function(Value)
      ultimateHorseSystem.settings.catchCooldown = Value
   end,
})

local CatchAuraIntervalSlider = parentTab:CreateSlider({
   Name = "🔄 Catch Interval",
   Range = {0.1, 2},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0.5,
   Flag = "CatchAuraIntervalSlider",
   Callback = function(Value)
      ultimateHorseSystem.settings.catchAuraInterval = Value
   end,
})

local AutoTargetToggle = parentTab:CreateToggle({
   Name = "🎯 Auto Target Nearest",
   CurrentValue = true,
   Flag = "AutoTargetToggle",
   Callback = function(Value)
      ultimateHorseSystem.settings.autoTargetNearest = Value
   end,
})

-- 🎛️ MANIPULATION SETTINGS SECTION
local ManipulationSettingsSection = parentTab:CreateSection("🎛️ Manipulation Settings")

local ManipulationIntervalSlider = parentTab:CreateSlider({
   Name = "⏱️ Manipulation Interval",
   Range = {0.5, 5},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 1.5,
   Flag = "ManipulationIntervalSlider",
   Callback = function(Value)
      ultimateHorseSystem.settings.manipulationInterval = Value
   end,
})

local EnforcementIntervalSlider = parentTab:CreateSlider({
   Name = "🔒 Enforcement Interval",
   Range = {0.1, 1},
   Increment = 0.05,
   Suffix = "s",
   CurrentValue = 0.3,
   Flag = "EnforcementIntervalSlider",
   Callback = function(Value)
      ultimateHorseSystem.settings.enforcementInterval = Value
   end,
})

local MaxProcessSlider = parentTab:CreateSlider({
   Name = "⚡ Max Process Per Frame",
   Range = {1, 10},
   Increment = 1,
   Suffix = " horses",
   CurrentValue = 5,
   Flag = "MaxProcessSlider",
   Callback = function(Value)
      ultimateHorseSystem.settings.maxProcessPerFrame = Value
   end,
})

-- 🎯 ATTRIBUTE TOGGLES SECTION
local AttributeTogglesSection = parentTab:CreateSection("🎯 Attribute Controls")

local ContinuousEnforcementToggle = parentTab:CreateToggle({
   Name = "🔒 Continuous Enforcement",
   CurrentValue = true,
   Flag = "ContinuousEnforcementToggle",
   Callback = function(Value)
      ultimateHorseSystem.settings.continuousEnforcement = Value
   end,
})

local FollowerToggle = parentTab:CreateToggle({
   Name = "🐎 Enable Follower Behaviour",
   CurrentValue = true,
   Flag = "FollowerToggle",
   Callback = function(Value)
      ultimateHorseSystem.settings.enableFollower = Value
   end,
})

local FleeDistanceToggle = parentTab:CreateToggle({
   Name = "🏃 Enable Flee Distance Control",
   CurrentValue = true,
   Flag = "FleeDistanceToggle",
   Callback = function(Value)
      ultimateHorseSystem.settings.enableFleeDistance = Value
   end,
})

local LastPlayerToggle = parentTab:CreateToggle({
   Name = "🎯 Enable Exclusive Control",
   CurrentValue = true,
   Flag = "LastPlayerToggle",
   Callback = function(Value)
      ultimateHorseSystem.settings.enableLastPlayerToThrow = Value
   end,
})

-- 📊 LIVE STATUS SECTION
local LiveStatusSection = parentTab:CreateSection("📊 Live Status")

local UltimateStatus = parentTab:CreateParagraph({Title = "🚀 Ultimate System Status", Content = "Ready"})
local CatchAuraStatus = parentTab:CreateParagraph({Title = "🎯 Catch Aura Status", Content = "Ready"})
local PerformanceStats = parentTab:CreateParagraph({Title = "⚡ Performance Stats", Content = "Optimized"})
local TargetInfo = parentTab:CreateParagraph({Title = "🐎 Target Information", Content = "None"})

-- ⚡ ULTIMATE ACTIONS SECTION
local UltimateActionsSection = parentTab:CreateSection("⚡ Ultimate Actions")

local SuperChargeButton = parentTab:CreateButton({
   Name = "⚡ SUPERCHARGE ALL",
   Callback = function()
      local horses = getFilteredHorses()
      local manipulated = 0
      local enforced = 0
      
      for _, horseData in pairs(horses) do
         local horse = horseData.horse
         if not ultimateHorseSystem.manipulatedHorses[horse.Name] then
            if manipulateHorseAttributes(horse) then
               manipulated = manipulated + 1
            end
         else
            if enforceHorseAttributes(horse) then
               enforced = enforced + 1
            end
         end
      end
      
      Rayfield:Notify({
         Title = "⚡ SUPERCHARGED!",
         Content = "Manipulated: " .. manipulated .. " | Enforced: " .. enforced,
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

local CatchNearestButton = parentTab:CreateButton({
   Name = "🎯 Catch Nearest Now",
   Callback = function()
      performCatchAura()
      Rayfield:Notify({
         Title = "🎯 Catch Attempt",
         Content = "Attempting to catch nearest horse",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local ClearCacheButton = parentTab:CreateButton({
   Name = "🗑️ Clear Cache",
   Callback = function()
      ultimateHorseSystem.cache.wildHorses = {}
      ultimateHorseSystem.cache.manipulatedHorses = {}
      ultimateHorseSystem.cache.lastCacheUpdate = 0
      ultimateHorseSystem.manipulatedHorses = {}
      ultimateHorseSystem.runtime.manipulatedCount = 0
      
      Rayfield:Notify({
         Title = "🗑️ Cache Cleared",
         Content = "All cached data cleared",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local ResetStatsButton = parentTab:CreateButton({
   Name = "📊 Reset All Statistics",
   Callback = function()
      ultimateHorseSystem.statistics = {
         totalManipulated = 0,
         totalEnforcements = 0,
         totalCatchAttempts = 0,
         successfulCatches = 0,
         sessionsRun = 0,
         bestCatchStreak = 0,
         currentCatchStreak = 0
      }
      ultimateHorseSystem.runtime.enforcementCount = 0
      ultimateHorseSystem.runtime.catchAttempts = 0
      ultimateHorseSystem.runtime.successfulCatches = 0
      
      Rayfield:Notify({
         Title = "📊 Stats Reset",
         Content = "All statistics have been reset",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- 📈 ULTIMATE STATISTICS SECTION
local UltimateStatisticsSection = parentTab:CreateSection("📈 Ultimate Statistics")

local SessionStats = parentTab:CreateParagraph({Title = "📈 Session Statistics", Content = "Ready to start"})
local CatchStats = parentTab:CreateParagraph({Title = "🎯 Catch Statistics", Content = "Ready to start"})
local AllTimeStats = parentTab:CreateParagraph({Title = "🏆 All-Time Records", Content = "No data yet"})

-- =================================
-- ULTIMATE STATUS UPDATE SYSTEM
-- =================================
spawn(function()
    while wait(0.5) do -- Faster updates for better UX
        -- Ultimate System Status
        local statusText = ""
        if ultimateHorseSystem.manipulationRunning then
            local runtime = tick() - ultimateHorseSystem.runtime.sessionStartTime
            local minutes = math.floor(runtime / 60)
            local seconds = math.floor(runtime % 60)
            
            statusText = "🟢 ACTIVE (Ultimate Mode)\n"
            statusText = statusText .. "⏱️ Runtime: " .. minutes .. "m " .. seconds .. "s\n"
            statusText = statusText .. "♾️ Range: " .. (ultimateHorseSystem.settings.unlimitedRange and "UNLIMITED" or ultimateHorseSystem.settings.catchAuraRadius .. " studs") .. "\n"
            statusText = statusText .. "🎭 Manipulated: " .. ultimateHorseSystem.runtime.manipulatedCount .. "\n"
            statusText = statusText .. "🔒 Enforcements: " .. ultimateHorseSystem.runtime.enforcementCount
        else
            statusText = "🔴 STOPPED\n💤 Ready to start\n⚡ Ultimate optimization ready\n🚀 Most OP horse exploit ever\n🎯 Manipulation + Catch Aura available"
        end
        UltimateStatus:Set({Title = "🚀 Ultimate System Status", Content = statusText})
        
        -- Catch Aura Status
        local catchText = ""
        if ultimateHorseSystem.catchAuraRunning then
            catchText = "🟢 ACTIVE (Auto-Catching)\n"
            catchText = catchText .. "🎯 Attempts: " .. ultimateHorseSystem.runtime.catchAttempts .. "\n"
            catchText = catchText .. "✅ Successful: " .. ultimateHorseSystem.runtime.successfulCatches .. "\n"
            catchText = catchText .. "🔥 Current Streak: " .. ultimateHorseSystem.statistics.currentCatchStreak .. "\n"
            catchText = catchText .. "⏱️ Cooldown: " .. ultimateHorseSystem.settings.catchCooldown .. "s"
        else
            catchText = "🔴 STOPPED\n💤 Ready to start\n🎯 Auto-catch system ready\n⚡ Instant catch available\n🎪 Most OP catch system"
        end
        CatchAuraStatus:Set({Title = "🎯 Catch Aura Status", Content = catchText})
        
        -- Performance Stats
        local horses = getFilteredHorses()
        local perfText = "🐎 Cached Horses: " .. #ultimateHorseSystem.cache.wildHorses .. "\n"
        perfText = perfText .. "🎯 Available Targets: " .. #horses .. "\n"
        perfText = perfText .. "⚡ Max Process/Frame: " .. ultimateHorseSystem.settings.maxProcessPerFrame .. "\n"
        perfText = perfText .. "🔄 Cache Update: " .. string.format("%.1f", ultimateHorseSystem.cache.cacheInterval) .. "s\n"
        perfText = perfText .. "🚀 System: OPTIMIZED"
        PerformanceStats:Set({Title = "⚡ Performance Stats", Content = perfText})
        
        -- Target Information
        local targetText = ""
        if #horses > 0 then
            local nearest = horses[1]
            targetText = "🐎 Nearest: " .. nearest.name .. "\n"
            targetText = targetText .. "📏 Distance: " .. math.floor(nearest.distance) .. " studs\n"
            targetText = targetText .. "🏃 Speed: " .. math.floor(nearest.velocity) .. " studs/s\n"
            
            if ultimateHorseSystem.runtime.currentTarget then
                local currentName = getHorseName(ultimateHorseSystem.runtime.currentTarget)
                targetText = targetText .. "🎯 Current Target: " .. currentName
            else
                targetText = targetText .. "🎯 Current Target: Auto-selecting"
            end
        else
            targetText = "🔍 Scanning for targets...\n"
            if ultimateHorseSystem.settings.unlimitedRange then
                targetText = targetText .. "♾️ Range: UNLIMITED\n📊 Searching entire map"
            else
                targetText = targetText .. "📍 Range: " .. ultimateHorseSystem.settings.catchAuraRadius .. " studs\n📊 No targets in range"
            end
        end
        TargetInfo:Set({Title = "🐎 Target Information", Content = targetText})
        
        -- Session Statistics
        if ultimateHorseSystem.manipulationRunning then
            local sessionTime = tick() - ultimateHorseSystem.runtime.sessionStartTime
            local sessionMinutes = math.floor(sessionTime / 60)
            local sessionSeconds = math.floor(sessionTime % 60)
            
            local sessionText = "⏱️ Session Time: " .. sessionMinutes .. "m " .. sessionSeconds .. "s\n"
            sessionText = sessionText .. "🎭 Horses Manipulated: " .. ultimateHorseSystem.runtime.manipulatedCount .. "\n"
            sessionText = sessionText .. "🔒 Enforcements: " .. ultimateHorseSystem.runtime.enforcementCount .. "\n"
            sessionText = sessionText .. "⚡ Performance: OPTIMIZED\n"
            sessionText = sessionText .. "♾️ Range: " .. (ultimateHorseSystem.settings.unlimitedRange and "UNLIMITED" or "Limited")
            
            SessionStats:Set({Title = "📈 Session Statistics", Content = sessionText})
        else
            SessionStats:Set({Title = "📈 Session Statistics", Content = "No active session\nStart ultimate system to see stats\n🚀 Most OP system ready"})
        end
        
        -- Catch Statistics
        if ultimateHorseSystem.catchAuraRunning then
            local successRate = 0
            if ultimateHorseSystem.runtime.catchAttempts > 0 then
                successRate = math.floor((ultimateHorseSystem.runtime.successfulCatches / ultimateHorseSystem.runtime.catchAttempts) * 100)
            end
            
            local catchText = "🎯 Session Attempts: " .. ultimateHorseSystem.runtime.catchAttempts .. "\n"
            catchText = catchText .. "✅ Session Successful: " .. ultimateHorseSystem.runtime.successfulCatches .. "\n"
            catchText = catchText .. "📊 Success Rate: " .. successRate .. "%\n"
            catchText = catchText .. "🔥 Current Streak: " .. ultimateHorseSystem.statistics.currentCatchStreak .. "\n"
            catchText = catchText .. "🏆 Best Streak: " .. ultimateHorseSystem.statistics.bestCatchStreak
            
            CatchStats:Set({Title = "🎯 Catch Statistics", Content = catchText})
        else
            CatchStats:Set({Title = "🎯 Catch Statistics", Content = "No active catch aura\nStart catch aura to see stats\n🎯 Most OP catch system ready"})
        end
        
        -- All-Time Statistics
        local controlledCount = 0
        for _ in pairs(ultimateHorseSystem.manipulatedHorses) do
            controlledCount = controlledCount + 1
        end
        
        local totalSuccessRate = 0
        if ultimateHorseSystem.statistics.totalCatchAttempts > 0 then
            totalSuccessRate = math.floor((ultimateHorseSystem.statistics.successfulCatches / ultimateHorseSystem.statistics.totalCatchAttempts) * 100)
        end
        
        local allTimeText = "🎭 Total Manipulated: " .. ultimateHorseSystem.statistics.totalManipulated .. "\n"
        allTimeText = allTimeText .. "🔒 Total Enforcements: " .. ultimateHorseSystem.statistics.totalEnforcements .. "\n"
        allTimeText = allTimeText .. "🎯 Total Catch Attempts: " .. ultimateHorseSystem.statistics.totalCatchAttempts .. "\n"
        allTimeText = allTimeText .. "✅ Total Successful Catches: " .. ultimateHorseSystem.statistics.successfulCatches .. "\n"
        allTimeText = allTimeText .. "📊 Overall Success Rate: " .. totalSuccessRate .. "%\n"
        allTimeText = allTimeText .. "🏆 Best Catch Streak: " .. ultimateHorseSystem.statistics.bestCatchStreak .. "\n"
        allTimeText = allTimeText .. "🎮 Sessions Run: " .. ultimateHorseSystem.statistics.sessionsRun .. "\n"
        allTimeText = allTimeText .. "🎯 Currently Controlled: " .. controlledCount
        
        AllTimeStats:Set({Title = "🏆 All-Time Records", Content = allTimeText})
    end
end)

-- =================================
-- CHARACTER RESPAWN HANDLING
-- =================================
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Stop all systems if running
    if ultimateHorseSystem.manipulationRunning then
        stopUltimateSystem()
        UltimateToggle:Set(false)
    end
    
    if ultimateHorseSystem.catchAuraRunning then
        stopCatchAura()
        CatchAuraToggle:Set(false)
    end
    
    Rayfield:Notify({
       Title = "🔄 Character Respawned",
       Content = "Ultimate system stopped - restart when ready",
       Duration = 3,
       Image = 4483362458,
    })
end)

-- =================================
-- ULTIMATE INITIALIZATION
-- =================================
Rayfield:Notify({
   Title = "🚀 ULTIMATE HORSE SYSTEM LOADED!",
   Content = "Most OP horse exploit ever created | Manipulation + Catch Aura + Unlimited Range!",
   Duration = 6,
   Image = 4483362458,
})

Rayfield:Notify({
   Title = "⚡ ULTIMATE FEATURES",
   Content = "🎭 Attribute Manipulation | 🎯 Catch Aura | ♾️ Unlimited Range | 🔒 Continuous Enforcement",
   Duration = 5,
   Image = 4483362458,
})

Rayfield:Notify({
   Title = "🎪 PERFORMANCE OPTIMIZED",
   Content = "Caching system | Frame limiting | Optimized loops | Maximum efficiency!",
   Duration = 4,
   Image = 4483362458,
})

print("🚀 ULTIMATE HORSE MANIPULATOR - CATCH AURA EDITION LOADED!")
print("🎯 Features: Manipulation + Catch Aura + Unlimited Range + Performance Optimization")
print("⚡ This is the most OP horse exploit ever created!")
print("🔥 Horses come to you + Auto-catch + No flee + Exclusive control = ULTIMATE DOMINATION!")
