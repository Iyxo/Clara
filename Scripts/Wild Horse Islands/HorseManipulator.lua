-- Horse Attribute Manipulator - Fixed Horse Names Edition
-- by Iyxo - 2025-07-22 07:48:25
-- Revolutionary horse control with FIXED horse name detection

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
-- FIXED HORSE NAME FUNCTIONS - USING HORSE MONITOR LOGIC
-- =================================

-- FIXED: Professional horse name getter using same logic as Horse Monitor
local function getHorseName(horse)
    if not horse then return "Unknown" end
    
    -- Ultra-fast cache check
    local cached = Cache.horseData[horse.Name]
    if cached and cached.name and cached.lastUpdate > tick() - 30 then
        return cached.name
    end
    
    local horseName = "Unknown"
    local breedName = "Unknown"
    
    local success = pcall(function()
        -- FIXED: Same logic as Horse Monitor
        local overheadPart = horse:FindFirstChild("OverheadPart")
        if overheadPart then
            local overhead = overheadPart:FindFirstChild("Overhead")
            if overhead then
                -- Get breed name first (this is the actual horse name)
                local breedLabel = overhead:FindFirstChild("BreedLabel")
                if breedLabel and breedLabel.Text and breedLabel.Text ~= "" then
                    breedName = breedLabel.Text
                    horseName = breedLabel.Text  -- Use breed as name
                else
                    -- Fallback to shortened ID
                    horseName = horse.Name:sub(2, 9)
                end
            end
        end
    end)
    
    -- Aggressive caching with FIXED data structure
    if success then
        Cache.horseData[horse.Name] = {
            name = horseName,
            breed = breedName,
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
                breed = "Unknown",
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

-- FIXED: Get comprehensive horse data like Horse Monitor
local function getHorseData(horse)
    if not horse then return nil end
    
    local horseData = {
        id = horse.Name,
        shortId = horse.Name:sub(2, 9),
        name = "Unknown",
        breed = "Unknown",
        status = "Unknown",
        distance = 0,
        position = Vector3.new(0, 0, 0),
        health = 0,
        velocity = 0,
        attributes = {},
        isWild = false,
        isValid = false
    }
    
    pcall(function()
        -- Basic data
        if horse:FindFirstChild("HumanoidRootPart") then
            horseData.position = horse.HumanoidRootPart.Position
            horseData.distance = math.floor((humanoidRootPart.Position - horse.HumanoidRootPart.Position).Magnitude)
            horseData.velocity = math.floor(horse.HumanoidRootPart.Velocity.Magnitude)
            horseData.isValid = true
        end
        
        if horse:FindFirstChild("Humanoid") then
            horseData.health = math.floor(horse.Humanoid.Health)
        end
        
        -- FIXED: Overhead data - same as Horse Monitor
        local overheadPart = horse:FindFirstChild("OverheadPart")
        if overheadPart then
            local overhead = overheadPart:FindFirstChild("Overhead")
            if overhead then
                -- Name/Status
                local nameLabel = overhead:FindFirstChild("NameLabel")
                if nameLabel then
                    horseData.status = nameLabel.Text
                    horseData.isWild = (nameLabel.Text == "Wild")
                end
                
                -- FIXED: Breed name (this is the actual horse name)
                local breedLabel = overhead:FindFirstChild("BreedLabel")
                if breedLabel and breedLabel.Text ~= "" then
                    horseData.breed = breedLabel.Text
                    horseData.name = breedLabel.Text  -- Use breed as name
                else
                    horseData.name = horseData.shortId
                end
            end
        end
        
        -- Attributes
        horseData.attributes = {
            behaviour = horse:GetAttribute("behaviour") or "None",
            followPlayer = horse:GetAttribute("followPlayer") or "None",
            fleeDistance = horse:GetAttribute("fleeDistance") or "None",
            lastPlayerToThrow = horse:GetAttribute("lastPlayerToThrowLasso") or "None",
            species = horse:GetAttribute("species") or "Unknown"
        }
    end)
    
    return horseData
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
                        
                        -- FIXED: Get comprehensive horse data
                        local horseData = getHorseData(child)
                        Cache.wildHorses[horseCount] = {
                            horse = child,
                            location = locationName,
                            distance = horseData.distance,
                            name = horseData.name,  -- FIXED: Include name
                            breed = horseData.breed -- FIXED: Include breed
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

-- FIXED: PROFESSIONAL INITIAL MANIPULATION with proper name detection
local function manipulateHorseAttributes(horse)
    if not horse then return false end
    
    local startTime = tick()
    local success = false
    
    -- FIXED: Get proper horse name using same logic as Horse Monitor
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
        
        -- FIXED: Add to manipulated list with enhanced metadata and PROPER NAME
        horseManipulator.manipulatedHorses[horse.Name] = {
            name = horseName,  -- FIXED: Now contains actual horse name (Arabian, etc.)
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
    
    return success, horseName  -- FIXED: Return actual horse name
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
       Content = "Global enforcement active | No distance limits | FIXED horse names",
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
                    
                    -- FIXED: Show actual horse name in notifications
                    if manipulatedThisRound <= 3 then
                        Rayfield:Notify({
                           Title = "🎭 " .. horseName .. " Controlled!",
                           Content = horseName .. " from " .. horseData.location .. " is now under control!",
                           Duration = 2,
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

-- [RESZTA KODU POZOSTAJE TAK SAMA - UI SECTIONS, STATUS UPDATES, etc.]
-- Skopiować resztę z poprzedniej wersji, ale z poprawionymi nazwami

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

-- [Kopiuj resztę UI z poprzedniej wersji...]

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
-- FIXED INITIALIZATION
-- =================================
Rayfield:Notify({
   Title = "🚀 Ultra Horse Manipulator Loaded!",
   Content = "FIXED horse names | Ultra-optimized global control | Professional grade",
   Duration = 6,
   Image = 4483362458,
})

Rayfield:Notify({
   Title = "🐎 Horse Names FIXED!",
   Content = "Now showing real names: Arabian, Mustang, Friesian, etc.!",
   Duration = 5,
   Image = 4483362458,
})

print("🚀 Ultra Horse Attribute Manipulator - FIXED Names Edition Loaded!")
print("🐎 FIXED: Now shows real horse names (Arabian, Mustang, etc.)")
print("🌍 Features: Global unlimited control, proper name detection")
print("⚡ Performance: Ultra-batch processing, intelligent caching")
print("🔥 Ultra Grade: No limits, maximum efficiency, PROPER NAMES!")
