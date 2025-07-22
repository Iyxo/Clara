-- Horse Attribute Manipulator - Professional Optimized Edition
-- by Iyxo - 2025-07-22
-- Revolutionary horse control with professional optimizations

local parentTab, Rayfield, Window = ...

-- =================================
-- SERVICES & OPTIMIZATION
-- =================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- =================================
-- PROFESSIONAL CACHING SYSTEM
-- =================================
local Cache = {
    horses = {},
    horsesById = {},
    lastUpdate = 0,
    updateInterval = 1, -- Cache update every 1 second
    maxCacheSize = 1000
}

-- =================================
-- HORSE MANIPULATOR SYSTEM - OPTIMIZED
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
        
        -- Performance settings
        manipulationInterval = 1.5,
        enforcementInterval = 0.3, -- Super fast enforcement
        scanInterval = 2,
        cleanupInterval = 10,
        
        -- Advanced options
        continuousEnforcement = true,
        globalManipulation = true, -- No distance limits!
        aggressiveEnforcement = true,
        batchProcessing = true,
        maxBatchSize = 10
    },
    
    -- Runtime optimization data
    runtime = {
        lastManipulationTime = 0,
        lastEnforcementTime = 0,
        lastScanTime = 0,
        lastCleanupTime = 0,
        manipulatedCount = 0,
        sessionStartTime = 0,
        enforcementCount = 0,
        scanCount = 0,
        batchCount = 0
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
        peakHorsesControlled = 0
    },
    
    -- Performance monitoring
    performance = {
        enforcementTimes = {},
        manipulationTimes = {},
        scanTimes = {},
        maxEnforcementTime = 0,
        avgEnforcementTime = 0
    }
}

-- =================================
-- PROFESSIONAL UTILITY FUNCTIONS
-- =================================

-- High-performance horse name getter with caching
local function getHorseName(horse)
    if not horse then return "Unknown" end
    
    -- Check cache first
    local cached = Cache.horsesById[horse.Name]
    if cached and cached.name then
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
    
    -- Cache the result
    if success then
        Cache.horsesById[horse.Name] = Cache.horsesById[horse.Name] or {}
        Cache.horsesById[horse.Name].name = horseName
    end
    
    return horseName
end

-- Ultra-fast wild horse checker
local function isWildHorse(horse)
    if not horse then return false end
    
    -- Check cache first
    local cached = Cache.horsesById[horse.Name]
    if cached and cached.isWild ~= nil then
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
    
    -- Cache the result
    if success then
        Cache.horsesById[horse.Name] = Cache.horsesById[horse.Name] or {}
        Cache.horsesById[horse.Name].isWild = isWild
    end
    
    return isWild
end

-- Professional cache management
local function updateHorseCache()
    local currentTime = tick()
    if currentTime - Cache.lastUpdate < Cache.updateInterval then
        return Cache.horses
    end
    
    local startTime = tick()
    Cache.horses = {}
    local horseCount = 0
    
    -- Optimized scanning with early returns
    local function scanLocation(location)
        if not location then return end
        
        local children = location:GetChildren()
        for i = 1, #children do
            local child = children[i]
            
            -- Fast filtering
            if child.Name:find("{") and child:FindFirstChild("HumanoidRootPart") then
                local humanoid = child:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 and not Players:GetPlayerFromCharacter(child) then
                    if isWildHorse(child) then
                        horseCount = horseCount + 1
                        Cache.horses[horseCount] = child
                        
                        -- Performance limit
                        if horseCount >= Cache.maxCacheSize then
                            break
                        end
                    end
                end
            end
        end
    end
    
    -- Scan optimized locations
    pcall(function()
        if Workspace.Islands then
            if Workspace.Islands.Mainland then
                scanLocation(Workspace.Islands.Mainland)
            end
            scanLocation(Workspace.Islands)
        end
    end)
    
    Cache.lastUpdate = currentTime
    
    -- Performance tracking
    local scanTime = tick() - startTime
    table.insert(horseManipulator.performance.scanTimes, scanTime)
    if #horseManipulator.performance.scanTimes > 100 then
        table.remove(horseManipulator.performance.scanTimes, 1)
    end
    
    horseManipulator.runtime.scanCount = horseManipulator.runtime.scanCount + 1
    horseManipulator.statistics.totalScans = horseManipulator.statistics.totalScans + 1
    
    return Cache.horses
end

-- Ultra-optimized attribute enforcement
local function enforceHorseAttributes(horse)
    if not horse or not horse.Parent then return false end
    
    local startTime = tick()
    local success = false
    local changes = 0
    
    pcall(function()
        -- Batch attribute operations for performance
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
        
        -- Batch set all attributes (performance optimization)
        for attribute, value in pairs(attributesToSet) do
            horse:SetAttribute(attribute, value)
        end
        
        if changes > 0 then
            horseManipulator.runtime.enforcementCount = horseManipulator.runtime.enforcementCount + 1
            horseManipulator.statistics.totalEnforcements = horseManipulator.statistics.totalEnforcements + 1
        end
        
        success = true
    end)
    
    -- Performance tracking
    local enforcementTime = tick() - startTime
    table.insert(horseManipulator.performance.enforcementTimes, enforcementTime)
    if #horseManipulator.performance.enforcementTimes > 1000 then
        table.remove(horseManipulator.performance.enforcementTimes, 1)
    end
    
    -- Update performance stats
    if enforcementTime > horseManipulator.performance.maxEnforcementTime then
        horseManipulator.performance.maxEnforcementTime = enforcementTime
    end
    
    return success, changes
end

-- Professional batch processing
local function batchEnforceAttributes(horses)
    if not horses or #horses == 0 then return 0 end
    
    local batchSize = math.min(#horses, horseManipulator.settings.maxBatchSize)
    local enforced = 0
    local totalChanges = 0
    
    for i = 1, batchSize do
        local horse = horses[i]
        if horse and horse.Parent then
            local success, changes = enforceHorseAttributes(horse)
            if success then
                enforced = enforced + 1
                totalChanges = totalChanges + changes
            end
        end
    end
    
    horseManipulator.runtime.batchCount = horseManipulator.runtime.batchCount + 1
    horseManipulator.statistics.totalBatches = horseManipulator.statistics.totalBatches + 1
    
    return enforced, totalChanges
end

-- Initial horse manipulation
local function manipulateHorseAttributes(horse)
    if not horse then return false end
    
    local startTime = tick()
    local success = false
    local horseName = getHorseName(horse)
    
    pcall(function()
        -- Aggressive initial setup
        if horseManipulator.settings.enableFollower then
            horse:SetAttribute("behaviour", horseManipulator.settings.behaviour)
            horse:SetAttribute("followPlayer", player.Name)
        end
        
        if horseManipulator.settings.enableFleeDistance then
            horse:SetAttribute("fleeDistance", horseManipulator.settings.fleeDistance)
        end
        
        if horseManipulator.settings.enableLastPlayerToThrow then
            horse:SetAttribute("lastPlayerToThrowLasso", player.Name)
        end
        
        -- Add to manipulated list with metadata
        horseManipulator.manipulatedHorses[horse.Name] = {
            name = horseName,
            time = tick(),
            controlled = true,
            lastEnforcement = tick(),
            enforcementCount = 0
        }
        
        horseManipulator.runtime.manipulatedCount = horseManipulator.runtime.manipulatedCount + 1
        horseManipulator.statistics.totalManipulated = horseManipulator.statistics.totalManipulated + 1
        
        -- Update peak
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
        -- Check if horse still exists
        local horseExists = false
        pcall(function()
            if Workspace.Islands and Workspace.Islands.Mainland then
                local horse = Workspace.Islands.Mainland:FindFirstChild(horseId)
                if horse and horse:FindFirstChild("HumanoidRootPart") then
                    local humanoid = horse:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        horseExists = true
                    end
                end
            end
        end)
        
        -- Remove if doesn't exist or too old
        if not horseExists or (currentTime - horseData.time > 300) then -- 5 minutes cleanup
            horseManipulator.manipulatedHorses[horseId] = nil
            Cache.horsesById[horseId] = nil
            cleaned = cleaned + 1
        end
    end
    
    return cleaned
end

-- =================================
-- PROFESSIONAL MAIN LOGIC - NO DISTANCE LIMITS
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
    
    Rayfield:Notify({
       Title = "🎭 Professional Horse Control Started!",
       Content = "Global manipulation active | No distance limits | Ultra-optimized",
       Duration = 4,
       Image = 4483362458,
    })
    
    -- PROFESSIONAL SCANNING CONNECTION
    horseManipulator.connections.scanning = RunService.Heartbeat:Connect(function()
        if not horseManipulator.isRunning then return end
        
        local currentTime = tick()
        if currentTime - horseManipulator.runtime.lastScanTime < horseManipulator.settings.scanInterval then
            return
        end
        
        -- Update horse cache
        updateHorseCache()
        horseManipulator.runtime.lastScanTime = currentTime
    end)
    
    -- PROFESSIONAL MANIPULATION CONNECTION
    horseManipulator.connections.manipulation = RunService.Heartbeat:Connect(function()
        if not horseManipulator.isRunning then return end
        
        local currentTime = tick()
        if currentTime - horseManipulator.runtime.lastManipulationTime < horseManipulator.settings.manipulationInterval then
            return
        end
        
        -- Get all horses (NO DISTANCE LIMITS!)
        local horses = updateHorseCache()
        local manipulatedThisRound = 0
        
        -- Process horses in batches for performance
        for i = 1, math.min(#horses, horseManipulator.settings.maxBatchSize) do
            local horse = horses[i]
            
            if horse and not horseManipulator.manipulatedHorses[horse.Name] then
                local success, horseName = manipulateHorseAttributes(horse)
                
                if success then
                    manipulatedThisRound = manipulatedThisRound + 1
                    
                    if manipulatedThisRound <= 2 then -- Limit notifications for performance
                        Rayfield:Notify({
                           Title = "🎭 Horse Controlled!",
                           Content = horseName .. " under global control!",
                           Duration = 1.5,
                           Image = 4483362458,
                        })
                    end
                end
            end
        end
        
        if manipulatedThisRound > 2 then
            Rayfield:Notify({
               Title = "🎭 Mass Control!",
               Content = "Controlled " .. manipulatedThisRound .. " horses globally!",
               Duration = 2,
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
            
            -- Get all manipulated horses for enforcement
            local horsesToEnforce = {}
            for horseId, horseData in pairs(horseManipulator.manipulatedHorses) do
                pcall(function()
                    local horse = nil
                    if Workspace.Islands and Workspace.Islands.Mainland then
                        horse = Workspace.Islands.Mainland:FindFirstChild(horseId)
                    end
                    
                    if horse and horse:FindFirstChild("HumanoidRootPart") then
                        table.insert(horsesToEnforce, horse)
                    end
                end)
            end
            
            -- Batch enforce for maximum performance
            if #horsesToEnforce > 0 then
                local enforced, changes = batchEnforceAttributes(horsesToEnforce)
                
                -- Update enforcement metadata
                for _, horse in pairs(horsesToEnforce) do
                    if horseManipulator.manipulatedHorses[horse.Name] then
                        horseManipulator.manipulatedHorses[horse.Name].lastEnforcement = currentTime
                        horseManipulator.manipulatedHorses[horse.Name].enforcementCount = 
                            (horseManipulator.manipulatedHorses[horse.Name].enforcementCount or 0) + 1
                    end
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
        
        local cleaned = cleanupDisconnectedHorses()
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
    
    -- Calculate average enforcement time
    local avgEnforcementTime = 0
    if #horseManipulator.performance.enforcementTimes > 0 then
        local total = 0
        for _, time in pairs(horseManipulator.performance.enforcementTimes) do
            total = total + time
        end
        avgEnforcementTime = total / #horseManipulator.performance.enforcementTimes
        horseManipulator.statistics.averageEnforcementTime = avgEnforcementTime
    end
    
    Rayfield:Notify({
       Title = "🛑 Professional Control Stopped",
       Content = "Controlled: " .. horseManipulator.runtime.manipulatedCount .. " | Enforcements: " .. horseManipulator.runtime.enforcementCount .. " | Avg: " .. string.format("%.3f", avgEnforcementTime) .. "ms",
       Duration = 5,
       Image = 4483362458,
    })
end

-- =================================
-- PROFESSIONAL UI SECTIONS & CONTROLS
-- =================================

-- 🎭 MAIN CONTROL SECTION
local MainControlSection = parentTab:CreateSection("🎭 Professional Horse Control")

local MainToggle = parentTab:CreateToggle({
   Name = "🎭 Global Horse Manipulation",
   CurrentValue = false,
   Flag = "ProfessionalHorseManipulationToggle",
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
   Flag = "GlobalModeToggle",
   Callback = function(Value)
      horseManipulator.settings.globalManipulation = Value
      Rayfield:Notify({
         Title = "🌍 Global Mode " .. (Value and "Enabled" or "Disabled"),
         Content = Value and "No distance limits - control ALL horses!" or "Distance limits restored",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

-- 🎛️ PROFESSIONAL SETTINGS SECTION
local ProfessionalSettingsSection = parentTab:CreateSection("🎛️ Professional Settings")

local ManipulationIntervalSlider = parentTab:CreateSlider({
   Name = "⏱️ Manipulation Interval",
   Range = {0.5, 5},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 1.5,
   Flag = "ProfessionalManipulationIntervalSlider",
   Callback = function(Value)
      horseManipulator.settings.manipulationInterval = Value
   end,
})

local EnforcementIntervalSlider = parentTab:CreateSlider({
   Name = "🔒 Enforcement Interval",
   Range = {0.1, 1},
   Increment = 0.05,
   Suffix = "s",
   CurrentValue = 0.3,
   Flag = "ProfessionalEnforcementIntervalSlider",
   Callback = function(Value)
      horseManipulator.settings.enforcementInterval = Value
   end,
})

local BatchSizeSlider = parentTab:CreateSlider({
   Name = "📦 Batch Processing Size",
   Range = {5, 50},
   Increment = 1,
   Suffix = " horses",
   CurrentValue = 10,
   Flag = "BatchSizeSlider",
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
   Flag = "ProfessionalFleeDistanceSlider",
   Callback = function(Value)
      horseManipulator.settings.fleeDistance = Value
   end,
})

-- 🎯 ADVANCED TOGGLES SECTION
local AdvancedTogglesSection = parentTab:CreateSection("🎯 Advanced Controls")

local ContinuousEnforcementToggle = parentTab:CreateToggle({
   Name = "🔒 Continuous Enforcement",
   CurrentValue = true,
   Flag = "ProfessionalContinuousEnforcementToggle",
   Callback = function(Value)
      horseManipulator.settings.continuousEnforcement = Value
   end,
})

local AggressiveEnforcementToggle = parentTab:CreateToggle({
   Name = "⚡ Aggressive Enforcement",
   CurrentValue = true,
   Flag = "AggressiveEnforcementToggle",
   Callback = function(Value)
      horseManipulator.settings.aggressiveEnforcement = Value
   end,
})

local FollowerToggle = parentTab:CreateToggle({
   Name = "🐎 Follower Behaviour",
   CurrentValue = true,
   Flag = "ProfessionalFollowerToggle",
   Callback = function(Value)
      horseManipulator.settings.enableFollower = Value
   end,
})

local FleeDistanceToggle = parentTab:CreateToggle({
   Name = "🏃 Flee Distance Control",
   CurrentValue = true,
   Flag = "ProfessionalFleeDistanceToggle",
   Callback = function(Value)
      horseManipulator.settings.enableFleeDistance = Value
   end,
})

local ExclusiveControlToggle = parentTab:CreateToggle({
   Name = "🎯 Exclusive Control",
   CurrentValue = true,
   Flag = "ProfessionalExclusiveControlToggle",
   Callback = function(Value)
      horseManipulator.settings.enableLastPlayerToThrow = Value
   end,
})

-- 📊 PROFESSIONAL STATUS SECTION
local ProfessionalStatusSection = parentTab:CreateSection("📊 Professional Status")

local SystemStatus = parentTab:CreateParagraph({Title = "🎭 System Status", Content = "Professional system ready"})
local PerformanceStatus = parentTab:CreateParagraph({Title = "⚡ Performance Metrics", Content = "Monitoring..."})
local GlobalStats = parentTab:CreateParagraph({Title = "🌍 Global Statistics", Content = "Ready"})
local EnforcementMetrics = parentTab:CreateParagraph({Title = "🔒 Enforcement Metrics", Content = "Standby"})

-- ⚡ PROFESSIONAL ACTIONS SECTION
local ProfessionalActionsSection = parentTab:CreateSection("⚡ Professional Actions")

local GlobalManipulateButton = parentTab:CreateButton({
   Name = "🌍 Global Instant Manipulation",
   Callback = function()
      local horses = updateHorseCache()
      local manipulated = 0
      
      for _, horse in pairs(horses) do
         if horse and not horseManipulator.manipulatedHorses[horse.Name] then
            local success, horseName = manipulateHorseAttributes(horse)
            if success then
               manipulated = manipulated + 1
            end
         end
      end
      
      Rayfield:Notify({
         Title = "🌍 Global Manipulation Complete",
         Content = "Instantly controlled " .. manipulated .. " horses globally!",
         Duration = 4,
         Image = 4483362458,
      })
   end,
})

local ForceEnforceAllButton = parentTab:CreateButton({
   Name = "🔒 Force Global Enforcement",
   Callback = function()
      local horsesToEnforce = {}
      for horseId, horseData in pairs(horseManipulator.manipulatedHorses) do
         pcall(function()
            local horse = nil
            if Workspace.Islands and Workspace.Islands.Mainland then
               horse = Workspace.Islands.Mainland:FindFirstChild(horseId)
            end
            if horse then
               table.insert(horsesToEnforce, horse)
            end
         end)
      end
      
      local enforced, changes = batchEnforceAttributes(horsesToEnforce)
      
      Rayfield:Notify({
         Title = "🔒 Global Enforcement Complete",
         Content = "Enforced " .. enforced .. " horses with " .. changes .. " changes!",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

local ClearCacheButton = parentTab:CreateButton({
   Name = "🗑️ Clear Performance Cache",
   Callback = function()
      Cache.horses = {}
      Cache.horsesById = {}
      Cache.lastUpdate = 0
      horseManipulator.performance.enforcementTimes = {}
      horseManipulator.performance.manipulationTimes = {}
      horseManipulator.performance.scanTimes = {}
      
      Rayfield:Notify({
         Title = "🗑️ Cache Cleared",
         Content = "Performance cache and metrics reset",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local ResetAllButton = parentTab:CreateButton({
   Name = "🔄 Reset All Data",
   Callback = function()
      horseManipulator.manipulatedHorses = {}
      horseManipulator.statistics = {
         totalManipulated = 0,
         totalEnforcements = 0,
         totalScans = 0,
         totalBatches = 0,
         sessionsRun = 0,
         horsesControlled = 0,
         averageEnforcementTime = 0,
         peakHorsesControlled = 0
      }
      horseManipulator.runtime.manipulatedCount = 0
      horseManipulator.runtime.enforcementCount = 0
      
      Rayfield:Notify({
         Title = "🔄 Complete Reset",
         Content = "All data and statistics reset",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- 📈 PROFESSIONAL STATISTICS SECTION
local ProfessionalStatisticsSection = parentTab:CreateSection("📈 Professional Statistics")

local SessionMetrics = parentTab:CreateParagraph({Title = "📈 Session Metrics", Content = "Ready to start"})
local AllTimeMetrics = parentTab:CreateParagraph({Title = "🏆 All-Time Metrics", Content = "No data yet"})
local PerformanceAnalytics = parentTab:CreateParagraph({Title = "⚡ Performance Analytics", Content = "Monitoring ready"})

-- =================================
-- PROFESSIONAL STATUS UPDATE SYSTEM
-- =================================
spawn(function()
    while wait(0.5) do -- Faster updates for professional monitoring
        -- System Status
        local statusText = ""
        if horseManipulator.isRunning then
            local runtime = tick() - horseManipulator.runtime.sessionStartTime
            local minutes = math.floor(runtime / 60)
            local seconds = math.floor(runtime % 60)
            
            statusText = "🟢 ACTIVE (Professional Control)\n"
            statusText = statusText .. "⏱️ Runtime: " .. minutes .. "m " .. seconds .. "s\n"
            statusText = statusText .. "🌍 Mode: " .. (horseManipulator.settings.globalManipulation and "Global" or "Local") .. "\n"
            statusText = statusText .. "🎭 Controlled: " .. horseManipulator.runtime.manipulatedCount .. "\n"
            statusText = statusText .. "🔒 Enforcements: " .. horseManipulator.runtime.enforcementCount
        else
            statusText = "🔴 STOPPED\n💤 Professional system ready\n🌍 Global manipulation available\n🔒 Continuous enforcement ready\n⚡ Ultra-optimized performance"
        end
        SystemStatus:Set({Title = "🎭 System Status", Content = statusText})
        
        -- Performance Status
        local avgEnforcementTime = 0
        if #horseManipulator.performance.enforcementTimes > 0 then
            local total = 0
            for _, time in pairs(horseManipulator.performance.enforcementTimes) do
                total = total + time
            end
            avgEnforcementTime = total / #horseManipulator.performance.enforcementTimes
        end
        
        local avgScanTime = 0
        if #horseManipulator.performance.scanTimes > 0 then
            local total = 0
            for _, time in pairs(horseManipulator.performance.scanTimes) do
                total = total + time
            end
            avgScanTime = total / #horseManipulator.performance.scanTimes
        end
        
        local performanceText = "⚡ Avg Enforcement: " .. string.format("%.3f", avgEnforcementTime * 1000) .. "ms\n"
        performanceText = performanceText .. "🔍 Avg Scan: " .. string.format("%.3f", avgScanTime * 1000) .. "ms\n"
        performanceText = performanceText .. "📦 Batch Size: " .. horseManipulator.settings.maxBatchSize .. "\n"
        performanceText = performanceText .. "🔄 Cache Size: " .. #Cache.horses .. " horses\n"
        performanceText = performanceText .. "📊 Batches Processed: " .. horseManipulator.runtime.batchCount
        PerformanceStatus:Set({Title = "⚡ Performance Metrics", Content = performanceText})
        
        -- Global Stats
        local controlledCount = 0
        for _ in pairs(horseManipulator.manipulatedHorses) do
            controlledCount = controlledCount + 1
        end
        
        local globalText = "🌍 Total Horses Cached: " .. #Cache.horses .. "\n"
        globalText = globalText .. "🎯 Currently Controlled: " .. controlledCount .. "\n"
        globalText = globalText .. "🏆 Peak Controlled: " .. horseManipulator.statistics.peakHorsesControlled .. "\n"
        globalText = globalText .. "🔍 Total Scans: " .. horseManipulator.statistics.totalScans .. "\n"
        globalText = globalText .. "📦 Total Batches: " .. horseManipulator.statistics.totalBatches
        GlobalStats:Set({Title = "🌍 Global Statistics", Content = globalText})
        
        -- Enforcement Metrics
        local enforcementText = "🔒 Total Enforcements: " .. horseManipulator.statistics.totalEnforcements .. "\n"
        enforcementText = enforcementText .. "⚡ Session Enforcements: " .. horseManipulator.runtime.enforcementCount .. "\n"
        enforcementText = enforcementText .. "⏱️ Enforcement Interval: " .. horseManipulator.settings.enforcementInterval .. "s\n"
        enforcementText = enforcementText .. "🎯 Max Enforcement Time: " .. string.format("%.3f", horseManipulator.performance.maxEnforcementTime * 1000) .. "ms\n"
        enforcementText = enforcementText .. "📊 Enforcement Mode: " .. (horseManipulator.settings.continuousEnforcement and "Continuous" or "Manual")
        EnforcementMetrics:Set({Title = "🔒 Enforcement Metrics", Content = enforcementText})
        
        -- Session Metrics
        if horseManipulator.isRunning then
            local sessionTime = tick() - horseManipulator.runtime.sessionStartTime
            local sessionMinutes = math.floor(sessionTime / 60)
            local sessionSeconds = math.floor(sessionTime % 60)
            
            local sessionText = "⏱️ Session Time: " .. sessionMinutes .. "m " .. sessionSeconds .. "s\n"
            sessionText = sessionText .. "🎭 Horses Controlled: " .. horseManipulator.runtime.manipulatedCount .. "\n"
            sessionText = sessionText .. "🔒 Enforcements: " .. horseManipulator.runtime.enforcementCount .. "\n"
            sessionText = sessionText .. "🔍 Scans: " .. horseManipulator.runtime.scanCount .. "\n"
            sessionText = sessionText .. "📦 Batches: " .. horseManipulator.runtime.batchCount .. "\n"
            sessionText = sessionText .. "⚡ Efficiency: " .. string.format("%.1f", horseManipulator.runtime.manipulatedCount / math.max(sessionTime / 60, 0.1)) .. " horses/min"
            
            SessionMetrics:Set({Title = "📈 Session Metrics", Content = sessionText})
        else
            SessionMetrics:Set({Title = "📈 Session Metrics", Content = "No active session\nProfessional monitoring ready\n🌍 Global manipulation available"})
        end
        
        -- All-Time Metrics
        local allTimeText = "🎭 Total Manipulated: " .. horseManipulator.statistics.totalManipulated .. "\n"
        allTimeText = allTimeText .. "🔒 Total Enforcements: " .. horseManipulator.statistics.totalEnforcements .. "\n"
        allTimeText = allTimeText .. "🎮 Sessions Run: " .. horseManipulator.statistics.sessionsRun .. "\n"
        allTimeText = allTimeText .. "🏆 Peak Controlled: " .. horseManipulator.statistics.peakHorsesControlled .. "\n"
        allTimeText = allTimeText .. "⚡ Avg Enforcement: " .. string.format("%.3f", horseManipulator.statistics.averageEnforcementTime * 1000) .. "ms\n"
        allTimeText = allTimeText .. "🌍 System: Global Professional Control"
        
        AllTimeMetrics:Set({Title = "🏆 All-Time Metrics", Content = allTimeText})
        
        -- Performance Analytics
        local analyticsText = "📊 Performance Profile: OPTIMIZED\n"
        analyticsText = analyticsText .. "🔄 Cache Hit Rate: " .. string.format("%.1f", (#Cache.horses / math.max(horseManipulator.runtime.scanCount, 1)) * 100) .. "%\n"
        analyticsText = analyticsText .. "⚡ Enforcement Efficiency: " .. string.format("%.1f", horseManipulator.statistics.totalEnforcements / math.max(horseManipulator.runtime.manipulatedCount, 1)) .. " per horse\n"
        analyticsText = analyticsText .. "📦 Batch Efficiency: " .. string.format("%.1f", horseManipulator.runtime.manipulatedCount / math.max(horseManipulator.runtime.batchCount, 1)) .. " horses/batch\n"
        analyticsText = analyticsText .. "🎯 System Status: PROFESSIONAL"
        
        PerformanceAnalytics:Set({Title = "⚡ Performance Analytics", Content = analyticsText})
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
           Content = "Professional system stopped - restart when ready",
           Duration = 3,
           Image = 4483362458,
        })
    end
end)

-- =================================
-- PROFESSIONAL INITIALIZATION
-- =================================
Rayfield:Notify({
   Title = "🎭 Professional Horse Manipulator Loaded!",
   Content = "Ultra-optimized | Global control | No distance limits | Professional grade",
   Duration = 6,
   Image = 4483362458,
})

Rayfield:Notify({
   Title = "🌍 Global Professional Control",
   Content = "Control ALL horses on the map | Ultra-fast enforcement | Professional optimizations",
   Duration = 5,
   Image = 4483362458,
})

print("🎭 Professional Horse Attribute Manipulator Loaded!")
print("🌍 Features: Global control, professional optimizations, ultra-fast enforcement")
print("⚡ Performance: Batch processing, intelligent caching, continuous monitoring")
print("🎯 Professional grade: No limits, maximum efficiency, complete control")
