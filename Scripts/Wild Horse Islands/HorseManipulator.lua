-- Horse Attribute Manipulator - Ultra-Optimized Professional Edition
-- by Iyxo - 2025-07-22 07:41:09
-- Revolutionary horse control with ultra-optimized continuous enforcement

local parentTab, Rayfield, Window = ...

-- =================================
-- SERVICES & ULTRA-OPTIMIZATION
-- =================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- =================================
-- PROFESSIONAL CACHING SYSTEM
-- =================================
local Cache = {
    wildHorses = {},
    manipulatedHorses = {},
    horseData = {},
    lastWildUpdate = 0,
    lastManipulatedUpdate = 0,
    wildUpdateInterval = 2,
    manipulatedUpdateInterval = 0.5,
    maxCacheSize = 1000
}

-- =================================
-- ULTRA-OPTIMIZED HORSE MANIPULATOR SYSTEM
-- =================================
local horseManipulator = {
    -- Status
    isRunning = false,
    manipulatedHorses = {},
    
    -- High-performance connections
    connections = {
        manipulation = nil,
        enforcement = nil,
        scanning = nil,
        cleanup = nil
    },
    
    -- Optimized settings
    settings = {
        -- Core attributes
        fleeDistance = 0,
        behaviour = "Follower",
        enableFollower = true,
        enableFleeDistance = true,
        enableLastPlayerToThrow = true,
        
        -- Performance optimization
        manipulationInterval = 1.5,
        enforcementInterval = 0.25, -- Ultra-fast enforcement
        scanInterval = 2,
        cleanupInterval = 15,
        
        -- Advanced options
        continuousEnforcement = true,
        globalManipulation = true, -- NO DISTANCE LIMITS!
        aggressiveEnforcement = true,
        batchProcessing = true,
        maxBatchSize = 15,
        ultraMode = true
    },
    
    -- High-performance runtime data
    runtime = {
        lastManipulationTime = 0,
        lastEnforcementTime = 0,
        lastScanTime = 0,
        lastCleanupTime = 0,
        manipulatedCount = 0,
        sessionStartTime = 0,
        enforcementCount = 0,
        scanCount = 0,
        batchCount = 0,
        globalScanCount = 0
    },
    
    -- Professional statistics
    statistics = {
        totalManipulated = 0,
        totalEnforcements = 0,
        totalScans = 0,
        totalBatches = 0,
        sessionsRun = 0,
        horsesControlled = 0,
        averageEnforcementTime = 0,
        peakHorsesControlled = 0,
        enforcementsPerSecond = 0,
        globalCoverage = 0
    },
    
    -- Performance monitoring
    performance = {
        enforcementTimes = {},
        manipulationTimes = {},
        scanTimes = {},
        batchTimes = {},
        maxEnforcementTime = 0,
        avgEnforcementTime = 0,
        maxBatchSize = 0
    }
}

-- =================================
-- ULTRA-OPTIMIZED UTILITY FUNCTIONS
-- =================================

-- High-performance horse name getter with aggressive caching
local function getHorseName(horse)
    if not horse then return "Unknown" end
    
    -- Ultra-fast cache check
    local cached = Cache.horseData[horse.Name]
    if cached and cached.name and cached.lastUpdate > tick() - 30 then
        return cached.name
    end
    
    local horseName = "Unknown"
    local success = pcall(function()
        local overheadPart = horse:FindFirstChild("OverheadPart")
        if overheadPart then
            local overhead = overheadPart:FindFirstChild("Overhead")
            if overhead then
                local breedLabel = overhead:FindFirstChild("BreedLabel")
                if breedLabel and breedLabel.Text and breedLabel.Text ~= "" then
                    horseName = breedLabel.Text
                else
                    horseName = horse.Name:sub(2, 9) -- Optimized ID extraction
                end
            end
        end
    end)
    
    -- Aggressive caching
    if success then
        Cache.horseData[horse.Name] = {
            name = horseName,
            lastUpdate = tick(),
            isWild = nil -- Will be set by isWildHorse
        }
    end
    
    return horseName
end

-- Ultra-fast wild horse checker with aggressive caching
local function isWildHorse(horse)
    if not horse then return false end
    
    -- Ultra-fast cache check
    local cached = Cache.horseData[horse.Name]
    if cached and cached.isWild ~= nil and cached.lastUpdate > tick() - 30 then
        return cached.isWild
    end
    
    local isWild = false
    local success = pcall(function()
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
    
    -- Aggressive caching
    if success then
        if not Cache.horseData[horse.Name] then
            Cache.horseData[horse.Name] = {
                name = "Unknown",
                lastUpdate = tick(),
                isWild = isWild
            }
        else
            Cache.horseData[horse.Name].isWild = isWild
            Cache.horseData[horse.Name].lastUpdate = tick()
        end
    end
    
    return isWild
end

-- ULTRA-OPTIMIZED GLOBAL HORSE SCANNING - NO DISTANCE LIMITS!
local function updateGlobalWildHorses()
    local currentTime = tick()
    if currentTime - Cache.lastWildUpdate < Cache.wildUpdateInterval then
        return Cache.wildHorses
    end
    
    local startTime = tick()
    Cache.wildHorses = {}
    local horseCount = 0
    
    -- Ultra-optimized global scanning
    local function scanLocation(location, locationName)
        if not location then return end
        
        local children = location:GetChildren()
        for i = 1, #children do
            local child = children[i]
            
            -- Ultra-fast filtering
            if child.Name:find("{") and child:FindFirstChild("HumanoidRootPart") then
                local humanoid = child:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 and not Players:GetPlayerFromCharacter(child) then
                    if isWildHorse(child) and not horseManipulator.manipulatedHorses[child.Name] then
                        horseCount = horseCount + 1
                        Cache.wildHorses[horseCount] = {
                            horse = child,
                            location = locationName,
                            distance = (humanoidRootPart.Position - child.HumanoidRootPart.Position).Magnitude
                        }
                        
                        -- Performance limit
                        if horseCount >= Cache.maxCacheSize then
                            break
                        end
                    end
                end
            end
        end
    end
    
    -- GLOBAL SCANNING - ALL LOCATIONS
    pcall(function()
        if Workspace.Islands then
            if Workspace.Islands.Mainland then
                scanLocation(Workspace.Islands.Mainland, "Mainland")
            end
            scanLocation(Workspace.Islands, "Islands")
            
            -- Scan additional locations if they exist
            for _, location in pairs(Workspace.Islands:GetChildren()) do
                if location:IsA("Model") and location ~= Workspace.Islands.Mainland then
                    scanLocation(location, location.Name)
                end
            end
        end
    end)
    
    Cache.lastWildUpdate = currentTime
    
    -- Performance tracking
    local scanTime = tick() - startTime
    table.insert(horseManipulator.performance.scanTimes, scanTime)
    if #horseManipulator.performance.scanTimes > 100 then
        table.remove(horseManipulator.performance.scanTimes, 1)
    end
    
    horseManipulator.runtime.scanCount = horseManipulator.runtime.scanCount + 1
    horseManipulator.runtime.globalScanCount = horseManipulator.runtime.globalScanCount + 1
    horseManipulator.statistics.totalScans = horseManipulator.statistics.totalScans + 1
    
    return Cache.wildHorses
end

-- ULTRA-OPTIMIZED MANIPULATED HORSE TRACKING
local function updateManipulatedHorses()
    local currentTime = tick()
    if currentTime - Cache.lastManipulatedUpdate < Cache.manipulatedUpdateInterval then
        return Cache.manipulatedHorses
    end
    
    Cache.manipulatedHorses = {}
    local manipulatedCount = 0
    
    -- Ultra-fast manipulated horse collection
    for horseId, horseData in pairs(horseManipulator.manipulatedHorses) do
        pcall(function()
            local horse = nil
            if Workspace.Islands and Workspace.Islands.Mainland then
                horse = Workspace.Islands.Mainland:FindFirstChild(horseId)
            end
            
            -- Scan all locations for manipulated horses
            if not horse and Workspace.Islands then
                for _, location in pairs(Workspace.Islands:GetChildren()) do
                    if location:IsA("Model") then
                        horse = location:FindFirstChild(horseId)
                        if horse then break end
                    end
                end
            end
            
            if horse and horse:FindFirstChild("HumanoidRootPart") then
                local humanoid = horse:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    manipulatedCount = manipulatedCount + 1
                    Cache.manipulatedHorses[manipulatedCount] = horse
                end
            end
        end)
    end
    
    Cache.lastManipulatedUpdate = currentTime
    return Cache.manipulatedHorses
end

-- ULTRA-OPTIMIZED BATCH ATTRIBUTE ENFORCEMENT
local function batchEnforceAttributes(horses)
    if not horses or #horses == 0 then return 0, 0 end
    
    local startTime = tick()
    local batchSize = math.min(#horses, horseManipulator.settings.maxBatchSize)
    local enforced = 0
    local totalChanges = 0
    
    -- Ultra-fast batch processing
    for i = 1, batchSize do
        local horse = horses[i]
        if horse and horse.Parent then
            local changes = 0
            
            pcall(function()
                -- Batch attribute operations for maximum performance
                local attributesToSet = {}
                
                -- Check and prepare follower attributes
                if horseManipulator.settings.enableFollower then
                    local currentBehaviour = horse:GetAttribute("behaviour")
                    if currentBehaviour ~= horseManipulator.settings.behaviour then
                        attributesToSet.behaviour = horseManipulator.settings.behaviour
                        changes = changes + 1
                    end
                    
                    local currentFollowPlayer = horse:GetAttribute("followPlayer")
                    if currentFollowPlayer ~= player.Name then
                        attributesToSet.followPlayer = player.Name
                        changes = changes + 1
                    end
                end
                
                -- Check and prepare flee distance
                if horseManipulator.settings.enableFleeDistance then
                    local currentFleeDistance = horse:GetAttribute("fleeDistance")
                    if currentFleeDistance ~= horseManipulator.settings.fleeDistance then
                        attributesToSet.fleeDistance = horseManipulator.settings.fleeDistance
                        changes = changes + 1
                    end
                end
                
                -- Check and prepare exclusive control
                if horseManipulator.settings.enableLastPlayerToThrow then
                    local currentLastPlayer = horse:GetAttribute("lastPlayerToThrowLasso")
                    if currentLastPlayer ~= player.Name then
                        attributesToSet.lastPlayerToThrowLasso = player.Name
                        changes = changes + 1
                    end
                end
                
                -- Ultra-fast batch attribute setting
                for attribute, value in pairs(attributesToSet) do
                    horse:SetAttribute(attribute, value)
                end
                
                if changes > 0 then
                    enforced = enforced + 1
                    totalChanges = totalChanges + changes
                    
                    -- Update enforcement metadata
                    if horseManipulator.manipulatedHorses[horse.Name] then
                        horseManipulator.manipulatedHorses[horse.Name].lastEnforcement = tick()
                        horseManipulator.manipulatedHorses[horse.Name].enforcementCount = 
                            (horseManipulator.manipulatedHorses[horse.Name].enforcementCount or 0) + 1
                    end
                end
            end)
        end
    end
    
    -- Performance tracking
    local batchTime = tick() - startTime
    table.insert(horseManipulator.performance.batchTimes, batchTime)
    if #horseManipulator.performance.batchTimes > 100 then
        table.remove(horseManipulator.performance.batchTimes, 1)
    end
    
    if batchSize > horseManipulator.performance.maxBatchSize then
        horseManipulator.performance.maxBatchSize = batchSize
    end
    
    horseManipulator.runtime.batchCount = horseManipulator.runtime.batchCount + 1
    horseManipulator.runtime.enforcementCount = horseManipulator.runtime.enforcementCount + enforced
    horseManipulator.statistics.totalBatches = horseManipulator.statistics.totalBatches + 1
    horseManipulator.statistics.totalEnforcements = horseManipulator.statistics.totalEnforcements + enforced
    
    return enforced, totalChanges
end

-- PROFESSIONAL INITIAL MANIPULATION
local function manipulateHorseAttributes(horse)
    if not horse then return false end
    
    local startTime = tick()
    local success = false
    local horseName = getHorseName(horse)
    
    pcall(function()
        -- Ultra-fast initial setup with batch operations
        local attributesToSet = {}
        
        if horseManipulator.settings.enableFollower then
            attributesToSet.behaviour = horseManipulator.settings.behaviour
            attributesToSet.followPlayer = player.Name
        end
        
        if horseManipulator.settings.enableFleeDistance then
            attributesToSet.fleeDistance = horseManipulator.settings.fleeDistance
        end
        
        if horseManipulator.settings.enableLastPlayerToThrow then
            attributesToSet.lastPlayerToThrowLasso = player.Name
        end
        
        -- Batch set all attributes
        for attribute, value in pairs(attributesToSet) do
            horse:SetAttribute(attribute, value)
        end
        
        -- Add to manipulated list with enhanced metadata
        horseManipulator.manipulatedHorses[horse.Name] = {
            name = horseName,
            time = tick(),
            controlled = true,
            lastEnforcement = tick(),
            enforcementCount = 0,
            location = "Unknown" -- Will be updated by scanning
        }
        
        horseManipulator.runtime.manipulatedCount = horseManipulator.runtime.manipulatedCount + 1
        horseManipulator.statistics.totalManipulated = horseManipulator.statistics.totalManipulated + 1
        
        -- Update peak statistics
        local currentControlled = 0
        for _ in pairs(horseManipulator.manipulatedHorses) do
            currentControlled = currentControlled + 1
        end
        
        if currentControlled > horseManipulator.statistics.peakHorsesControlled then
            horseManipulator.statistics.peakHorsesControlled = currentControlled
        end
        
        success = true
    end)
    
    -- Performance tracking
    local manipulationTime = tick() - startTime
    table.insert(horseManipulator.performance.manipulationTimes, manipulationTime)
    if #horseManipulator.performance.manipulationTimes > 100 then
        table.remove(horseManipulator.performance.manipulationTimes, 1)
    end
    
    return success, horseName
end

-- Professional cleanup system
local function cleanupDisconnectedHorses()
    local currentTime = tick()
    local cleaned = 0
    
    for horseId, horseData in pairs(horseManipulator.manipulatedHorses) do
        local horseExists = false
        
        -- Check if horse still exists in any location
        pcall(function()
            if Workspace.Islands then
                if Workspace.Islands.Mainland then
                    local horse = Workspace.Islands.Mainland:FindFirstChild(horseId)
                    if horse and horse:FindFirstChild("HumanoidRootPart") then
                        local humanoid = horse:FindFirstChild("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            horseExists = true
                        end
                    end
                end
                
                -- Check other locations
                if not horseExists then
                    for _, location in pairs(Workspace.Islands:GetChildren()) do
                        if location:IsA("Model") and location ~= Workspace.Islands.Mainland then
                            local horse = location:FindFirstChild(horseId)
                            if horse and horse:FindFirstChild("HumanoidRootPart") then
                                local humanoid = horse:FindFirstChild("Humanoid")
                                if humanoid and humanoid.Health > 0 then
                                    horseExists = true
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end)
        
        -- Remove if doesn't exist or too old
        if not horseExists or (currentTime - horseData.time > 600) then -- 10 minutes cleanup
            horseManipulator.manipulatedHorses[horseId] = nil
            Cache.horseData[horseId] = nil
            cleaned = cleaned + 1
        end
    end
    
    return cleaned
end

-- =================================
-- ULTRA-OPTIMIZED MAIN LOGIC - GLOBAL MANIPULATION
-- =================================
local function startHorseManipulation()
    if horseManipulator.isRunning then return false end
    
    horseManipulator.isRunning = true
    horseManipulator.runtime.sessionStartTime = tick()
    horseManipulator.statistics.sessionsRun = horseManipulator.statistics.sessionsRun + 1
    horseManipulator.runtime.manipulatedCount = 0
    horseManipulator.runtime.enforcementCount = 0
    horseManipulator.runtime.scanCount = 0
    horseManipulator.runtime.batchCount = 0
    horseManipulator.runtime.globalScanCount = 0
    
    Rayfield:Notify({
       Title = "🚀 Ultra Horse Manipulation Started!",
       Content = "Global enforcement active | No distance limits | Ultra-optimized performance",
       Duration = 4,
       Image = 4483362458,
    })
    
    -- ULTRA-OPTIMIZED SCANNING CONNECTION
    horseManipulator.connections.scanning = RunService.Heartbeat:Connect(function()
        if not horseManipulator.isRunning then return end
        
        local currentTime = tick()
        if currentTime - horseManipulator.runtime.lastScanTime < horseManipulator.settings.scanInterval then
            return
        end
        
        -- Global horse cache update
        updateGlobalWildHorses()
        horseManipulator.runtime.lastScanTime = currentTime
    end)
    
    -- PROFESSIONAL MANIPULATION CONNECTION
    horseManipulator.connections.manipulation = RunService.Heartbeat:Connect(function()
        if not horseManipulator.isRunning then return end
        
        local currentTime = tick()
        if currentTime - horseManipulator.runtime.lastManipulationTime < horseManipulator.settings.manipulationInterval then
            return
        end
        
        -- Get ALL wild horses globally (NO DISTANCE LIMITS!)
        local wildHorses = updateGlobalWildHorses()
        local manipulatedThisRound = 0
        
        -- Process horses in optimized batches
        local batchSize = math.min(#wildHorses, horseManipulator.settings.maxBatchSize)
        for i = 1, batchSize do
            local horseData = wildHorses[i]
            if horseData and horseData.horse and not horseManipulator.manipulatedHorses[horseData.horse.Name] then
                local success, horseName = manipulateHorseAttributes(horseData.horse)
                
                if success then
                    manipulatedThisRound = manipulatedThisRound + 1
                    
                    -- Limit notifications for performance
                    if manipulatedThisRound <= 3 then
                        Rayfield:Notify({
                           Title = "🎭 Global Control!",
                           Content = horseName .. " (" .. horseData.location .. ") controlled!",
                           Duration = 1.5,
                           Image = 4483362458,
                        })
                    end
                end
            end
        end
        
        if manipulatedThisRound > 3 then
            Rayfield:Notify({
               Title = "🌍 Mass Global Control!",
               Content = "Controlled " .. manipulatedThisRound .. " horses across all locations!",
               Duration = 3,
               Image = 4483362458,
            })
        end
        
        horseManipulator.runtime.lastManipulationTime = currentTime
    end)
    
    -- ULTRA-FAST CONTINUOUS ENFORCEMENT
    if horseManipulator.settings.continuousEnforcement then
        horseManipulator.connections.enforcement = RunService.Heartbeat:Connect(function()
            if not horseManipulator.isRunning then return end
            
            local currentTime = tick()
            if currentTime - horseManipulator.runtime.lastEnforcementTime < horseManipulator.settings.enforcementInterval then
                return
            end
            
            -- Get all manipulated horses for ultra-fast enforcement
            local manipulatedHorses = updateManipulatedHorses()
            
            -- Ultra-fast batch enforcement
            if #manipulatedHorses > 0 then
                local enforced, changes = batchEnforceAttributes(manipulatedHorses)
                
                -- Calculate enforcement rate
                local sessionTime = currentTime - horseManipulator.runtime.sessionStartTime
                if sessionTime > 0 then
                    horseManipulator.statistics.enforcementsPerSecond = horseManipulator.runtime.enforcementCount / sessionTime
                end
            end
            
            horseManipulator.runtime.lastEnforcementTime = currentTime
        end)
    end
    
    -- PROFESSIONAL CLEANUP CONNECTION
    horseManipulator.connections.cleanup = RunService.Heartbeat:Connect(function()
        if not horseManipulator.isRunning then return end
        
        local currentTime = tick()
        if currentTime - horseManipulator.runtime.lastCleanupTime < horseManipulator.settings.cleanupInterval then
            return
        end
        
        -- Performance cleanup
        local cleaned = cleanupDisconnectedHorses()
        
        -- Cache cleanup for performance
        if #Cache.wildHorses > Cache.maxCacheSize * 0.8 then
            for i = Cache.maxCacheSize * 0.6, #Cache.wildHorses do
                Cache.wildHorses[i] = nil
            end
        end
        
        horseManipulator.runtime.lastCleanupTime = currentTime
    end)
    
    return true
end

local function stopHorseManipulation()
    horseManipulator.isRunning = false
    
    -- Disconnect all connections professionally
    for name, connection in pairs(horseManipulator.connections) do
        if connection then
            connection:Disconnect()
            horseManipulator.connections[name] = nil
        end
    end
    
    local sessionTime = tick() - horseManipulator.runtime.sessionStartTime
    local minutes = math.floor(sessionTime / 60)
    local seconds = math.floor(sessionTime % 60)
    
    -- Calculate professional metrics
    local avgEnforcementTime = 0
    if #horseManipulator.performance.enforcementTimes > 0 then
        local total = 0
        for _, time in pairs(horseManipulator.performance.enforcementTimes) do
            total = total + time
        end
        avgEnforcementTime = total / #horseManipulator.performance.enforcementTimes
        horseManipulator.statistics.averageEnforcementTime = avgEnforcementTime
    end
    
    -- Calculate global coverage
    local totalWildHorses = #Cache.wildHorses
    local controlledHorses = 0
    for _ in pairs(horseManipulator.manipulatedHorses) do
        controlledHorses = controlledHorses + 1
    end
    
    if totalWildHorses > 0 then
        horseManipulator.statistics.globalCoverage = (controlledHorses / totalWildHorses) * 100
    end
    
    Rayfield:Notify({
       Title = "🏁 Ultra Manipulation Stopped",
       Content = "Controlled: " .. horseManipulator.runtime.manipulatedCount .. " | Enforcements: " .. horseManipulator.runtime.enforcementCount .. " | Coverage: " .. string.format("%.1f", horseManipulator.statistics.globalCoverage) .. "%",
       Duration = 5,
       Image = 4483362458,
    })
end

-- =================================
-- PROFESSIONAL UI SECTIONS & CONTROLS
-- =================================

-- 🎭 MAIN CONTROL SECTION
local MainControlSection = parentTab:CreateSection("🎭 Ultra Manipulation Control")

local MainToggle = parentTab:CreateToggle({
   Name = "🚀 Ultra Global Manipulation",
   CurrentValue = false,
   Flag = "UltraHorseManipulationToggle",
   Callback = function(Value)
      if Value then
         local success = startHorseManipulation()
         if not success then
            MainToggle:Set(false)
         end
      else
         stopHorseManipulation()
      end
   end,
})

local GlobalModeToggle = parentTab:CreateToggle({
   Name = "🌍 Global Mode (No Distance Limits)",
   CurrentValue = true,
   Flag = "UltraGlobalModeToggle",
   Callback = function(Value)
      horseManipulator.settings.globalManipulation = Value
      Rayfield:Notify({
         Title = "🌍 Global Mode " .. (Value and "Enabled" or "Disabled"),
         Content = Value and "Ultra-global control - ALL horses across the map!" or "Limited range mode",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

local UltraModeToggle = parentTab:CreateToggle({
   Name = "⚡ Ultra Performance Mode",
   CurrentValue = true,
   Flag = "UltraPerformanceModeToggle",
   Callback = function(Value)
      horseManipulator.settings.ultraMode = Value
      if Value then
         horseManipulator.settings.enforcementInterval = 0.25
         horseManipulator.settings.maxBatchSize = 15
      else
         horseManipulator.settings.enforcementInterval = 0.5
         horseManipulator.settings.maxBatchSize = 10
      end
   end,
})

-- 🎛️ ULTRA SETTINGS SECTION
local UltraSettingsSection = parentTab:CreateSection("🎛️ Ultra Optimization")

local ManipulationIntervalSlider = parentTab:CreateSlider({
   Name = "⏱️ Manipulation Interval",
   Range = {0.5, 5},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 1.5,
   Flag = "UltraManipulationIntervalSlider",
   Callback = function(Value)
      horseManipulator.settings.manipulationInterval = Value
   end,
})

local EnforcementIntervalSlider = parentTab:CreateSlider({
   Name = "🔒 Enforcement Interval",
   Range = {0.1, 1},
   Increment = 0.05,
   Suffix = "s",
   CurrentValue = 0.25,
   Flag = "UltraEnforcementIntervalSlider",
   Callback = function(Value)
      horseManipulator.settings.enforcementInterval = Value
   end,
})

local BatchSizeSlider = parentTab:CreateSlider({
   Name = "📦 Ultra Batch Size",
   Range = {5, 25},
   Increment = 1,
   Suffix = " horses",
   CurrentValue = 15,
   Flag = "UltraBatchSizeSlider",
   Callback = function(Value)
      horseManipulator.settings.maxBatchSize = Value
   end,
})

local FleeDistanceSlider = parentTab:CreateSlider({
   Name = "🏃 Flee Distance Override",
   Range = {0, 100},
   Increment = 5,
   Suffix = " studs",
   CurrentValue = 0,
   Flag = "UltraFleeDistanceSlider",
   Callback = function(Value)
      horseManipulator.settings.fleeDistance = Value
   end,
})

-- 🎯 ULTRA CONTROLS SECTION
local UltraControlsSection = parentTab:CreateSection("🎯 Ultra Controls")

local ContinuousEnforcementToggle = parentTab:CreateToggle({
   Name = "🔒 Continuous Enforcement",
   CurrentValue = true,
   Flag = "UltraContinuousEnforcementToggle",
   Callback = function(Value)
      horseManipulator.settings.continuousEnforcement = Value
   end,
})

local AggressiveEnforcementToggle = parentTab:CreateToggle({
   Name = "⚡ Aggressive Enforcement",
   CurrentValue = true,
   Flag = "UltraAggressiveEnforcementToggle",
   Callback = function(Value)
      horseManipulator.settings.aggressiveEnforcement = Value
   end,
})

local FollowerToggle = parentTab:CreateToggle({
   Name = "🐎 Follower Behaviour",
   CurrentValue = true,
   Flag = "UltraFollowerToggle",
   Callback = function(Value)
      horseManipulator.settings.enableFollower = Value
   end,
})

local FleeDistanceToggle = parentTab:CreateToggle({
   Name = "🏃 Flee Distance Control",
   CurrentValue = true,
   Flag = "UltraFleeDistanceToggle",
   Callback = function(Value)
      horseManipulator.settings.enableFleeDistance = Value
   end,
})

local ExclusiveControlToggle = parentTab:CreateToggle({
   Name = "🎯 Exclusive Control",
   CurrentValue = true,
   Flag = "UltraExclusiveControlToggle",
   Callback = function(Value)
      horseManipulator.settings.enableLastPlayerToThrow = Value
   end,
})

-- 📊 ULTRA STATUS SECTION
local UltraStatusSection = parentTab:CreateSection("📊 Ultra Status")

local SystemStatus = parentTab:CreateParagraph({Title = "🚀 Ultra System Status", Content = "Ultra-optimized system ready"})
local GlobalStats = parentTab:CreateParagraph({Title = "🌍 Global Statistics", Content = "Global monitoring ready"})
local PerformanceMetrics = parentTab:CreateParagraph({Title = "⚡ Performance Metrics", Content = "Ultra-performance monitoring"})
local EnforcementMetrics = parentTab:CreateParagraph({Title = "🔒 Enforcement Metrics", Content = "Ultra-enforcement ready"})

-- ⚡ ULTRA ACTIONS SECTION
local UltraActionsSection = parentTab:CreateSection("⚡ Ultra Actions")

local GlobalInstantButton = parentTab:CreateButton({
   Name = "🌍 Instant Global Manipulation",
   Callback = function()
      local wildHorses = updateGlobalWildHorses()
      local manipulated = 0
      
      for _, horseData in pairs(wildHorses) do
         if horseData.horse and not horseManipulator.manipulatedHorses[horseData.horse.Name] then
            local success, horseName = manipulateHorseAttributes(horseData.horse)
            if success then
               manipulated = manipulated + 1
            end
         end
      end
      
      Rayfield:Notify({
         Title = "🌍 Global Manipulation Complete",
         Content = "Instantly controlled " .. manipulated .. " horses globally across all locations!",
         Duration = 5,
         Image = 4483362458,
      })
   end,
})

local UltraEnforceButton = parentTab:CreateButton({
   Name = "🔒 Ultra Global Enforcement",
   Callback = function()
      local manipulatedHorses = updateManipulatedHorses()
      local enforced, changes = batchEnforceAttributes(manipulatedHorses)
      
      Rayfield:Notify({
         Title = "🔒 Ultra Enforcement Complete",
         Content = "Ultra-enforced " .. enforced .. " horses with " .. changes .. " changes across all locations!",
         Duration = 4,
         Image = 4483362458,
      })
   end,
})

local ClearUltraCacheButton = parentTab:CreateButton({
   Name = "🗑️ Clear Ultra Cache",
   Callback = function()
      Cache.wildHorses = {}
      Cache.manipulatedHorses = {}
      Cache.horseData = {}
      Cache.lastWildUpdate = 0
      Cache.lastManipulatedUpdate = 0
      horseManipulator.performance = {
         enforcementTimes = {},
         manipulationTimes = {},
         scanTimes = {},
         batchTimes = {},
         maxEnforcementTime = 0,
         avgEnforcementTime = 0,
         maxBatchSize = 0
      }
      
      Rayfield:Notify({
         Title = "🗑️ Ultra Cache Cleared",
         Content = "Ultra-performance cache optimized",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local ResetUltraStatsButton = parentTab:CreateButton({
   Name = "📊 Reset Ultra Statistics",
   Callback = function()
      horseManipulator.statistics = {
         totalManipulated = 0,
         totalEnforcements = 0,
         totalScans = 0,
         totalBatches = 0,
         sessionsRun = 0,
         horsesControlled = 0,
         averageEnforcementTime = 0,
         peakHorsesControlled = 0,
         enforcementsPerSecond = 0,
         globalCoverage = 0
      }
      horseManipulator.runtime.manipulatedCount = 0
      horseManipulator.runtime.enforcementCount = 0
      
      Rayfield:Notify({
         Title = "📊 Ultra Stats Reset",
         Content = "All ultra statistics have been reset",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- 📈 ULTRA STATISTICS SECTION
local UltraStatisticsSection = parentTab:CreateSection("📈 Ultra Statistics")

local SessionMetrics = parentTab:CreateParagraph({Title = "📈 Ultra Session Metrics", Content = "Ultra session ready"})
local AllTimeMetrics = parentTab:CreateParagraph({Title = "🏆 Ultra All-Time Records", Content = "No data yet"})
local GlobalAnalytics = parentTab:CreateParagraph({Title = "🌍 Global Analytics", Content = "Global analytics ready"})

-- =================================
-- ULTRA-OPTIMIZED STATUS UPDATE SYSTEM
-- =================================
spawn(function()
    while wait(0.5) do -- Ultra-fast updates
        -- Ultra System Status
        local statusText = ""
        if horseManipulator.isRunning then
            local runtime = tick() - horseManipulator.runtime.sessionStartTime
            local minutes = math.floor(runtime / 60)
            local seconds = math.floor(runtime % 60)
            
            statusText = "🚀 ULTRA-ACTIVE (Global Control)\n"
            statusText = statusText .. "⏱️ Runtime: " .. minutes .. "m " .. seconds .. "s\n"
            statusText = statusText .. "🌍 Mode: " .. (horseManipulator.settings.globalManipulation and "Global Ultra" or "Limited") .. "\n"
            statusText = statusText .. "🎭 Controlled: " .. horseManipulator.runtime.manipulatedCount .. "\n"
            statusText = statusText .. "🔒 Enforcements: " .. horseManipulator.runtime.enforcementCount .. "\n"
            statusText = statusText .. "⚡ Ultra Mode: " .. (horseManipulator.settings.ultraMode and "✅" or "❌")
        else
            statusText = "🔴 STOPPED\n💤 Ultra-optimized system ready\n🌍 Global manipulation available\n🔒 Ultra-enforcement ready\n⚡ Ultra-performance optimizations\n🚀 Maximum efficiency mode"
        end
        SystemStatus:Set({Title = "🚀 Ultra System Status", Content = statusText})
        
        -- Global Statistics
        local wildHorsesCount = #Cache.wildHorses
        local manipulatedCount = 0
        for _ in pairs(horseManipulator.manipulatedHorses) do
            manipulatedCount = manipulatedCount + 1
        end
        
        local globalCoverage = wildHorsesCount > 0 and (manipulatedCount / wildHorsesCount) * 100 or 0
        
        local globalText = "🌍 Total Horses Scanned: " .. wildHorsesCount .. "\n"
        globalText = globalText .. "🎯 Currently Controlled: " .. manipulatedCount .. "\n"
        globalText = globalText .. "📊 Global Coverage: " .. string.format("%.1f", globalCoverage) .. "%\n"
        globalText = globalText .. "🏆 Peak Controlled: " .. horseManipulator.statistics.peakHorsesControlled .. "\n"
        globalText = globalText .. "🔍 Global Scans: " .. horseManipulator.runtime.globalScanCount .. "\n"
        globalText = globalText .. "📦 Batches Processed: " .. horseManipulator.runtime.batchCount
        GlobalStats:Set({Title = "🌍 Global Statistics", Content = globalText})
        
        -- Performance Metrics
        local avgEnforcementTime = 0
        if #horseManipulator.performance.enforcementTimes > 0 then
            local total = 0
            for _, time in pairs(horseManipulator.performance.enforcementTimes) do
                total = total + time
            end
            avgEnforcementTime = total / #horseManipulator.performance.enforcementTimes
        end
        
        local avgBatchTime = 0
        if #horseManipulator.performance.batchTimes > 0 then
            local total = 0
            for _, time in pairs(horseManipulator.performance.batchTimes) do
                total = total + time
            end
            avgBatchTime = total / #horseManipulator.performance.batchTimes
        end
        
        local performanceText = "⚡ Avg Enforcement: " .. string.format("%.3f", avgEnforcementTime * 1000) .. "ms\n"
        performanceText = performanceText .. "📦 Avg Batch: " .. string.format("%.3f", avgBatchTime * 1000) .. "ms\n"
        performanceText = performanceText .. "🚀 Max Batch Size: " .. horseManipulator.performance.maxBatchSize .. "\n"
        performanceText = performanceText .. "🔄 Cache Size: " .. wildHorsesCount .. " wild horses\n"
        performanceText = performanceText .. "📊 Enforcements/sec: " .. string.format("%.1f", horseManipulator.statistics.enforcementsPerSecond)
        PerformanceMetrics:Set({Title = "⚡ Performance Metrics", Content = performanceText})
        
        -- Enforcement Metrics
        local enforcementText = "🔒 Total Enforcements: " .. horseManipulator.statistics.totalEnforcements .. "\n"
        enforcementText = enforcementText .. "⚡ Session Enforcements: " .. horseManipulator.runtime.enforcementCount .. "\n"
        enforcementText = enforcementText .. "⏱️ Enforcement Interval: " .. horseManipulator.settings.enforcementInterval .. "s\n"
        enforcementText = enforcementText .. "🎯 Max Enforcement Time: " .. string.format("%.3f", horseManipulator.performance.maxEnforcementTime * 1000) .. "ms\n"
        enforcementText = enforcementText .. "📊 Enforcement Mode: " .. (horseManipulator.settings.continuousEnforcement and "Ultra-Continuous" or "Manual") .. "\n"
        enforcementText = enforcementText .. "🌍 Global Enforcement: " .. (horseManipulator.settings.globalManipulation and "✅" or "❌")
        EnforcementMetrics:Set({Title = "🔒 Enforcement Metrics", Content = enforcementText})
        
        -- Session Metrics
        if horseManipulator.isRunning then
            local sessionTime = tick() - horseManipulator.runtime.sessionStartTime
            local sessionMinutes = math.floor(sessionTime / 60)
            local sessionSeconds = math.floor(sessionTime % 60)
            
            local manipulationRate = sessionTime > 0 and (horseManipulator.runtime.manipulatedCount / (sessionTime / 60)) or 0
            local enforcementRate = sessionTime > 0 and (horseManipulator.runtime.enforcementCount / (sessionTime / 60)) or 0
            
            local sessionText = "⏱️ Session Time: " .. sessionMinutes .. "m " .. sessionSeconds .. "s\n"
            sessionText = sessionText .. "🎭 Horses Controlled: " .. horseManipulator.runtime.manipulatedCount .. "\n"
            sessionText = sessionText .. "📈 Control Rate: " .. string.format("%.1f", manipulationRate) .. "/min\n"
            sessionText = sessionText .. "🔒 Enforcements: " .. horseManipulator.runtime.enforcementCount .. "\n"
            sessionText = sessionText .. "⚡ Enforcement Rate: " .. string.format("%.1f", enforcementRate) .. "/min\n"
            sessionText = sessionText .. "🌍 Global Coverage: " .. string.format("%.1f", globalCoverage) .. "%"
            
            SessionMetrics:Set({Title = "📈 Ultra Session Metrics", Content = sessionText})
        else
            SessionMetrics:Set({Title = "📈 Ultra Session Metrics", Content = "No ultra session active\nUltra-optimized monitoring ready\n🌍 Global manipulation available\n🚀 Ultra-performance ready"})
        end
        
        -- All-Time Metrics
        local allTimeText = "🎭 Total Manipulated: " .. horseManipulator.statistics.totalManipulated .. "\n"
        allTimeText = allTimeText .. "🔒 Total Enforcements: " .. horseManipulator.statistics.totalEnforcements .. "\n"
        allTimeText = allTimeText .. "🎮 Sessions Run: " .. horseManipulator.statistics.sessionsRun .. "\n"
        allTimeText = allTimeText .. "🏆 Peak Controlled: " .. horseManipulator.statistics.peakHorsesControlled .. "\n"
        allTimeText = allTimeText .. "⚡ Avg Enforcement: " .. string.format("%.3f", horseManipulator.statistics.averageEnforcementTime * 1000) .. "ms\n"
        allTimeText = allTimeText .. "🌍 Best Coverage: " .. string.format("%.1f", horseManipulator.statistics.globalCoverage) .. "%"
        
        AllTimeMetrics:Set({Title = "🏆 Ultra All-Time Records", Content = allTimeText})
        
        -- Global Analytics
        local cacheEfficiency = Cache.wildHorses and #Cache.wildHorses > 0 and (horseManipulator.runtime.scanCount / #Cache.wildHorses) or 0
        local controlEfficiency = wildHorsesCount > 0 and (manipulatedCount / wildHorsesCount) or 0
        
        local analyticsText = "📊 Cache Efficiency: " .. string.format("%.1f", cacheEfficiency * 100) .. "%\n"
        analyticsText = analyticsText .. "🎯 Control Efficiency: " .. string.format("%.1f", controlEfficiency * 100) .. "%\n"
        analyticsText = analyticsText .. "🌍 Global Reach: " .. (horseManipulator.settings.globalManipulation and "UNLIMITED" or "LIMITED") .. "\n"
        analyticsText = analyticsText .. "⚡ Performance Profile: ULTRA-OPTIMIZED\n"
        analyticsText = analyticsText .. "🚀 System Status: PROFESSIONAL ULTRA\n"
        analyticsText = analyticsText .. "🔥 Mode: MAXIMUM EFFICIENCY"
        
        GlobalAnalytics:Set({Title = "🌍 Global Analytics", Content = analyticsText})
    end
end)

-- =================================
-- CHARACTER RESPAWN HANDLING
-- =================================
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    if horseManipulator.isRunning then
        stopHorseManipulation()
        MainToggle:Set(false)
        
        Rayfield:Notify({
           Title = "🔄 Character Respawned",
           Content = "Ultra manipulation stopped - restart when ready",
           Duration = 3,
           Image = 4483362458,
        })
    end
end)

-- =================================
-- ULTRA-OPTIMIZED INITIALIZATION
-- =================================
Rayfield:Notify({
   Title = "🚀 Ultra Horse Manipulator Loaded!",
   Content = "Ultra-optimized global control | No distance limits | Maximum performance | Professional grade",
   Duration = 6,
   Image = 4483362458,
})

Rayfield:Notify({
   Title = "🌍 Ultra Global Control Ready",
   Content = "Control ALL horses across the entire map | Ultra-fast enforcement | Revolutionary system",
   Duration = 5,
   Image = 4483362458,
})

print("🚀 Ultra Horse Attribute Manipulator - Professional Ultra Edition Loaded!")
print("🌍 Features: Global unlimited control, ultra-optimized performance, professional analytics")
print("⚡ Performance: Ultra-batch processing, intelligent caching, real-time monitoring")
print("🔥 Ultra Grade: No limits, maximum efficiency, complete global dominance")
print("🎯 Revolutionary: Control every horse on the map with ultra-performance!")
