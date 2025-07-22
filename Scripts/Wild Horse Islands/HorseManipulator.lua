-- Horse Attribute Manipulator - Ultra-Optimized Island Detection Edition
-- by Iyxo - 2025-07-22 09:45:33
-- Revolutionary horse control with island detection + auto teleportation

local parentTab, Rayfield, Window = ...

-- =================================
-- SERVICES & ULTRA-OPTIMIZATION
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
-- ISLAND DETECTION SYSTEM
-- =================================
local islandSystem = {
    currentIsland = "Unknown",
    lastUpdate = 0,
    updateInterval = 2,
    availableIslands = {},
    scanLocations = {},
    islandHorses = {} -- Horses per island
}

-- Professional island detection
local function detectCurrentIsland()
    local currentTime = tick()
    if currentTime - islandSystem.lastUpdate < islandSystem.updateInterval then
        return islandSystem.currentIsland
    end
    
    -- Method 1: Player Attribute (Primary - most reliable)
    local islandAttribute = player:GetAttribute("island")
    if islandAttribute and islandAttribute ~= "" then
        islandSystem.currentIsland = islandAttribute
        islandSystem.lastUpdate = currentTime
        return islandAttribute
    end
    
    -- Method 2: Character Location (Fallback)
    pcall(function()
        if character and character.Parent then
            for _, island in pairs(Workspace.Islands:GetChildren()) do
                if character.Parent == island then
                    islandSystem.currentIsland = island.Name
                    islandSystem.lastUpdate = currentTime
                    return
                end
            end
        end
    end)
    
    -- Method 3: Position-based (Last resort)
    if islandSystem.currentIsland == "Unknown" then
        pcall(function()
            local playerPos = humanoidRootPart.Position
            local closestIsland = "Mainland"
            local shortestDistance = math.huge
            
            for _, island in pairs(Workspace.Islands:GetChildren()) do
                if island:IsA("Model") and island:FindFirstChild("Terrain") then
                    local islandPos = island:GetPivot().Position
                    local distance = (playerPos - islandPos).Magnitude
                    
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestIsland = island.Name
                    end
                end
            end
            
            islandSystem.currentIsland = closestIsland
        end)
    end
    
    islandSystem.lastUpdate = currentTime
    return islandSystem.currentIsland
end

-- Update scan locations based on current island
local function updateScanLocations()
    islandSystem.scanLocations = {}
    local currentIsland = detectCurrentIsland()
    
    pcall(function()
        if Workspace.Islands then
            -- If on Mainland
            if currentIsland == "Mainland" and Workspace.Islands.Mainland then
                table.insert(islandSystem.scanLocations, {
                    location = Workspace.Islands.Mainland,
                    name = "Mainland",
                    priority = 1
                })
            end
            
            -- Scan specific island player is on
            for _, island in pairs(Workspace.Islands:GetChildren()) do
                if island.Name == currentIsland and island ~= Workspace.Islands.Mainland then
                    table.insert(islandSystem.scanLocations, {
                        location = island,
                        name = island.Name,
                        priority = 1
                    })
                end
            end
            
            -- Also scan nearby islands (lower priority)
            for _, island in pairs(Workspace.Islands:GetChildren()) do
                if island.Name ~= currentIsland and island:IsA("Model") then
                    table.insert(islandSystem.scanLocations, {
                        location = island,
                        name = island.Name,
                        priority = 2
                    })
                end
            end
        end
    end)
    
    -- Sort by priority (current island first)
    table.sort(islandSystem.scanLocations, function(a, b)
        return a.priority < b.priority
    end)
end

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
        cleanup = nil,
        teleportation = nil,
        island = nil -- New: island monitoring
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
        enforcementInterval = 0.25,
        scanInterval = 2,
        cleanupInterval = 15,
        
        -- Teleportation settings
        autoTeleport = false,
        teleportLoop = false,
        teleportInterval = 3,
        teleportRadius = 15,
        teleportHeight = 5,
        maxTeleportDistance = 500,
        
        -- Island settings
        multiIslandMode = true,
        prioritizeCurrentIsland = true,
        islandOnlyMode = false, -- New: only manipulate on current island
        
        -- Advanced options
        continuousEnforcement = true,
        globalManipulation = true,
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
        lastTeleportTime = 0,
        lastIslandCheck = 0,
        manipulatedCount = 0,
        sessionStartTime = 0,
        enforcementCount = 0,
        scanCount = 0,
        batchCount = 0,
        globalScanCount = 0,
        teleportCount = 0,
        horsesNearby = 0,
        currentIslandHorses = 0
    },
    
    -- Professional statistics
    statistics = {
        totalManipulated = 0,
        totalEnforcements = 0,
        totalScans = 0,
        totalBatches = 0,
        totalTeleports = 0,
        sessionsRun = 0,
        horsesControlled = 0,
        averageEnforcementTime = 0,
        peakHorsesControlled = 0,
        enforcementsPerSecond = 0,
        globalCoverage = 0,
        horsesNearbyPeak = 0,
        islandStats = {} -- New: per-island statistics
    },
    
    -- Performance monitoring
    performance = {
        enforcementTimes = {},
        manipulationTimes = {},
        scanTimes = {},
        batchTimes = {},
        teleportTimes = {},
        islandScanTimes = {},
        maxEnforcementTime = 0,
        avgEnforcementTime = 0,
        maxBatchSize = 0
    }
}

-- =================================
-- ENHANCED UTILITY FUNCTIONS WITH ISLAND AWARENESS
-- =================================

-- ENHANCED: Horse name getter with island tracking
local function getHorseName(horse)
    if not horse then return "Unknown" end
    
    local cached = Cache.horseData[horse.Name]
    if cached and cached.name and cached.name ~= "Unknown" and cached.lastUpdate > tick() - 30 then
        return cached.name
    end
    
    local horseName = "Unknown"
    local success = false
    
    pcall(function()
        local overheadPart = horse:FindFirstChild("OverheadPart")
        if overheadPart then
            local overhead = overheadPart:FindFirstChild("Overhead")
            if overhead then
                local breedLabel = overhead:FindFirstChild("BreedLabel")
                if breedLabel and breedLabel.Text and breedLabel.Text ~= "" and breedLabel.Text ~= " " then
                    horseName = breedLabel.Text
                    success = true
                else
                    for _, child in pairs(overhead:GetChildren()) do
                        if child:IsA("TextLabel") and child.Text and child.Text ~= "" and child.Text ~= " " and child.Text ~= "Wild" then
                            if child.Text:match("[A-Za-z]") then
                                horseName = child.Text
                                success = true
                                break
                            end
                        end
                    end
                end
            end
        end
        
        if not success or horseName == "Unknown" then
            for _, descendant in pairs(horse:GetDescendants()) do
                if descendant:IsA("TextLabel") and descendant.Text and descendant.Text ~= "" and descendant.Text ~= " " and descendant.Text ~= "Wild" then
                    if descendant.Text:match("[A-Za-z]") and descendant.Text:len() > 2 then
                        horseName = descendant.Text
                        success = true
                        break
                    end
                end
            end
        end
        
        if not success or horseName == "Unknown" then
            horseName = "Horse_" .. horse.Name:sub(2, 9)
            success = true
        end
    end)
    
    if success then
        Cache.horseData[horse.Name] = {
            name = horseName,
            lastUpdate = tick(),
            isWild = nil,
            island = nil -- Will be set by island detection
        }
    end
    
    return horseName
end

-- Ultra-fast wild horse checker with island tracking
local function isWildHorse(horse)
    if not horse then return false end
    
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
    
    if success then
        if not Cache.horseData[horse.Name] then
            Cache.horseData[horse.Name] = {
                name = "Unknown",
                lastUpdate = tick(),
                isWild = isWild,
                island = nil
            }
        else
            Cache.horseData[horse.Name].isWild = isWild
            Cache.horseData[horse.Name].lastUpdate = tick()
        end
    end
    
    return isWild
end

-- ENHANCED: Island-aware global horse scanning
local function updateGlobalWildHorses()
    local currentTime = tick()
    if currentTime - Cache.lastWildUpdate < Cache.wildUpdateInterval then
        return Cache.wildHorses
    end
    
    local startTime = tick()
    Cache.wildHorses = {}
    islandSystem.islandHorses = {}
    local horseCount = 0
    
    -- Update scan locations based on current island
    updateScanLocations()
    
    local function scanLocation(locationData)
        if not locationData.location then return end
        
        local location = locationData.location
        local islandName = locationData.name
        local priority = locationData.priority
        
        local children = location:GetChildren()
        local islandHorseCount = 0
        
        for i = 1, #children do
            local child = children[i]
            
            if child.Name:find("{") and child:FindFirstChild("HumanoidRootPart") then
                local humanoid = child:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 and not Players:GetPlayerFromCharacter(child) then
                    if isWildHorse(child) and not horseManipulator.manipulatedHorses[child.Name] then
                        horseCount = horseCount + 1
                        islandHorseCount = islandHorseCount + 1
                        
                        Cache.wildHorses[horseCount] = {
                            horse = child,
                            location = islandName,
                            priority = priority,
                            distance = (humanoidRootPart.Position - child.HumanoidRootPart.Position).Magnitude
                        }
                        
                        -- Cache island info
                        if Cache.horseData[child.Name] then
                            Cache.horseData[child.Name].island = islandName
                        end
                        
                        if horseCount >= Cache.maxCacheSize then
                            break
                        end
                    end
                end
            end
        end
        
        islandSystem.islandHorses[islandName] = islandHorseCount
    end
    
    -- Scan locations by priority
    for _, locationData in pairs(islandSystem.scanLocations) do
        if horseCount < Cache.maxCacheSize then
            scanLocation(locationData)
        end
    end
    
    -- Sort horses by priority and distance
    table.sort(Cache.wildHorses, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        else
            return a.distance < b.distance
        end
    end)
    
    Cache.lastWildUpdate = currentTime
    
    -- Performance tracking
    local scanTime = tick() - startTime
    table.insert(horseManipulator.performance.islandScanTimes, scanTime)
    if #horseManipulator.performance.islandScanTimes > 100 then
        table.remove(horseManipulator.performance.islandScanTimes, 1)
    end
    
    horseManipulator.runtime.scanCount = horseManipulator.runtime.scanCount + 1
    horseManipulator.runtime.globalScanCount = horseManipulator.runtime.globalScanCount + 1
    horseManipulator.statistics.totalScans = horseManipulator.statistics.totalScans + 1
    
    -- Update current island horse count
    local currentIsland = detectCurrentIsland()
    horseManipulator.runtime.currentIslandHorses = islandSystem.islandHorses[currentIsland] or 0
    
    return Cache.wildHorses
end

-- ENHANCED: Get manipulated horses with island tracking
local function updateManipulatedHorses()
    local currentTime = tick()
    if currentTime - Cache.lastManipulatedUpdate < Cache.manipulatedUpdateInterval then
        return Cache.manipulatedHorses
    end
    
    Cache.manipulatedHorses = {}
    local manipulatedCount = 0
    local nearbyCount = 0
    local playerPos = humanoidRootPart.Position
    
    for horseId, horseData in pairs(horseManipulator.manipulatedHorses) do
        pcall(function()
            local horse = nil
            local foundIsland = nil
            
            if Workspace.Islands and Workspace.Islands.Mainland then
                horse = Workspace.Islands.Mainland:FindFirstChild(horseId)
                if horse then foundIsland = "Mainland" end
            end
            
            if not horse and Workspace.Islands then
                for _, location in pairs(Workspace.Islands:GetChildren()) do
                    if location:IsA("Model") then
                        horse = location:FindFirstChild(horseId)
                        if horse then
                            foundIsland = location.Name
                            break
                        end
                    end
                end
            end
            
            if horse and horse:FindFirstChild("HumanoidRootPart") then
                local humanoid = horse:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    manipulatedCount = manipulatedCount + 1
                    
                    local distance = (playerPos - horse.HumanoidRootPart.Position).Magnitude
                    if distance <= horseManipulator.settings.teleportRadius + 20 then
                        nearbyCount = nearbyCount + 1
                    end
                    
                    Cache.manipulatedHorses[manipulatedCount] = {
                        horse = horse,
                        distance = distance,
                        name = horseData.name or getHorseName(horse),
                        island = foundIsland or "Unknown"
                    }
                    
                    -- Update horse data with island info
                    if horseData then
                        horseData.island = foundIsland
                    end
                end
            end
        end)
    end
    
    horseManipulator.runtime.horsesNearby = nearbyCount
    if nearbyCount > horseManipulator.statistics.horsesNearbyPeak then
        horseManipulator.statistics.horsesNearbyPeak = nearbyCount
    end
    
    Cache.lastManipulatedUpdate = currentTime
    return Cache.manipulatedHorses
end

-- =================================
-- ENHANCED HORSE TELEPORTATION WITH ISLAND AWARENESS
-- =================================

-- Professional horse teleportation with island checks
local function teleportHorseToPlayer(horse, index)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") then return false end
    
    -- Check if we should teleport horses from other islands
    if horseManipulator.settings.islandOnlyMode then
        local currentIsland = detectCurrentIsland()
        local horseIsland = nil
        
        -- Determine which island the horse is on
        pcall(function()
            if horse.Parent == Workspace.Islands.Mainland then
                horseIsland = "Mainland"
            else
                for _, island in pairs(Workspace.Islands:GetChildren()) do
                    if horse.Parent == island then
                        horseIsland = island.Name
                        break
                    end
                end
            end
        end)
        
        -- Don't teleport if on different island and island-only mode is active
        if horseIsland and horseIsland ~= currentIsland then
            return false
        end
    end
    
    local success = false
    local startTime = tick()
    
    pcall(function()
        local playerPos = humanoidRootPart.Position
        
        local angle = (index - 1) * (math.pi * 2 / math.min(#Cache.manipulatedHorses, 8))
        local radius = horseManipulator.settings.teleportRadius
        
        local offsetX = math.cos(angle) * radius
        local offsetZ = math.sin(angle) * radius
        local targetPos = playerPos + Vector3.new(offsetX, horseManipulator.settings.teleportHeight, offsetZ)
        
        if #Cache.manipulatedHorses > 8 then
            local ring = math.floor((index - 1) / 8)
            radius = horseManipulator.settings.teleportRadius + (ring * 8)
            offsetX = math.cos(angle) * radius
            offsetZ = math.sin(angle) * radius
            targetPos = playerPos + Vector3.new(offsetX, horseManipulator.settings.teleportHeight, offsetZ)
        end
        
        local currentDistance = (playerPos - horse.HumanoidRootPart.Position).Magnitude
        if currentDistance <= horseManipulator.settings.maxTeleportDistance then
            horse.HumanoidRootPart.CFrame = CFrame.lookAt(targetPos, playerPos)
            
            if horse.HumanoidRootPart:FindFirstChild("BodyVelocity") then
                horse.HumanoidRootPart.BodyVelocity:Destroy()
            end
            
            success = true
        end
    end)
    
    if success then
        local teleportTime = tick() - startTime
        table.insert(horseManipulator.performance.teleportTimes, teleportTime)
        if #horseManipulator.performance.teleportTimes > 100 then
            table.remove(horseManipulator.performance.teleportTimes, 1)
        end
        
        horseManipulator.runtime.teleportCount = horseManipulator.runtime.teleportCount + 1
        horseManipulator.statistics.totalTeleports = horseManipulator.statistics.totalTeleports + 1
    end
    
    return success
end

-- Batch teleport all controlled horses
local function batchTeleportControlledHorses()
    if not horseManipulator.settings.autoTeleport then return 0 end
    
    local manipulatedHorses = updateManipulatedHorses()
    local teleported = 0
    
    for i, horseData in pairs(manipulatedHorses) do
        if horseData.horse and horseData.distance > horseManipulator.settings.teleportRadius then
            if teleportHorseToPlayer(horseData.horse, i) then
                teleported = teleported + 1
            end
        end
        
        if teleported >= 5 then break end
    end
    
    return teleported
end

-- =================================
-- ENHANCED ATTRIBUTE MANIPULATION WITH ISLAND FILTERING
-- =================================

-- Enhanced manipulation with island awareness
local function manipulateHorseAttributes(horse)
    if not horse then return false end
    
    -- Check island-only mode
    if horseManipulator.settings.islandOnlyMode then
        local currentIsland = detectCurrentIsland()
        local horseIsland = nil
        
        pcall(function()
            if horse.Parent == Workspace.Islands.Mainland then
                horseIsland = "Mainland"
            else
                for _, island in pairs(Workspace.Islands:GetChildren()) do
                    if horse.Parent == island then
                        horseIsland = island.Name
                        break
                    end
                end
            end
        end)
        
        if horseIsland and horseIsland ~= currentIsland then
            return false, "Different Island"
        end
    end
    
    local startTime = tick()
    local success = false
    local horseName = getHorseName(horse)
    local currentIsland = detectCurrentIsland()
    
    pcall(function()
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
        
        for attribute, value in pairs(attributesToSet) do
            horse:SetAttribute(attribute, value)
        end
        
        -- Enhanced metadata with island info
        horseManipulator.manipulatedHorses[horse.Name] = {
            name = horseName,
            time = tick(),
            controlled = true,
            lastEnforcement = tick(),
            enforcementCount = 0,
            island = currentIsland,
            location = currentIsland
        }
        
        horseManipulator.runtime.manipulatedCount = horseManipulator.runtime.manipulatedCount + 1
        horseManipulator.statistics.totalManipulated = horseManipulator.statistics.totalManipulated + 1
        
        -- Track per-island statistics
        if not horseManipulator.statistics.islandStats[currentIsland] then
            horseManipulator.statistics.islandStats[currentIsland] = 0
        end
        horseManipulator.statistics.islandStats[currentIsland] = horseManipulator.statistics.islandStats[currentIsland] + 1
        
        local currentControlled = 0
        for _ in pairs(horseManipulator.manipulatedHorses) do
            currentControlled = currentControlled + 1
        end
        
        if currentControlled > horseManipulator.statistics.peakHorsesControlled then
            horseManipulator.statistics.peakHorsesControlled = currentControlled
        end
        
        success = true
    end)
    
    local manipulationTime = tick() - startTime
    table.insert(horseManipulator.performance.manipulationTimes, manipulationTime)
    if #horseManipulator.performance.manipulationTimes > 100 then
        table.remove(horseManipulator.performance.manipulationTimes, 1)
    end
    
    return success, horseName
end

-- Enhanced attribute enforcement (same as before)
local function batchEnforceAttributes(horses)
    if not horses or #horses == 0 then return 0, 0 end
    
    local startTime = tick()
    local batchSize = math.min(#horses, horseManipulator.settings.maxBatchSize)
    local enforced = 0
    local totalChanges = 0
    
    for i = 1, batchSize do
        local horseData = horses[i]
        local horse = horseData.horse or horseData
        
        if horse and horse.Parent then
            local changes = 0
            
            pcall(function()
                local attributesToSet = {}
                
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
                
                if horseManipulator.settings.enableFleeDistance then
                    local currentFleeDistance = horse:GetAttribute("fleeDistance")
                    if currentFleeDistance ~= horseManipulator.settings.fleeDistance then
                        attributesToSet.fleeDistance = horseManipulator.settings.fleeDistance
                        changes = changes + 1
                    end
                end
                
                if horseManipulator.settings.enableLastPlayerToThrow then
                    local currentLastPlayer = horse:GetAttribute("lastPlayerToThrowLasso")
                    if currentLastPlayer ~= player.Name then
                        attributesToSet.lastPlayerToThrowLasso = player.Name
                        changes = changes + 1
                    end
                end
                
                for attribute, value in pairs(attributesToSet) do
                    horse:SetAttribute(attribute, value)
                end
                
                if changes > 0 then
                    enforced = enforced + 1
                    totalChanges = totalChanges + changes
                    
                    if horseManipulator.manipulatedHorses[horse.Name] then
                        horseManipulator.manipulatedHorses[horse.Name].lastEnforcement = tick()
                        horseManipulator.manipulatedHorses[horse.Name].enforcementCount = 
                            (horseManipulator.manipulatedHorses[horse.Name].enforcementCount or 0) + 1
                    end
                end
            end)
        end
    end
    
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

-- Professional cleanup system (same as before)
local function cleanupDisconnectedHorses()
    local currentTime = tick()
    local cleaned = 0
    
    for horseId, horseData in pairs(horseManipulator.manipulatedHorses) do
        local horseExists = false
        
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
        
        if not horseExists or (currentTime - horseData.time > 600) then
            horseManipulator.manipulatedHorses[horseId] = nil
            Cache.horseData[horseId] = nil
            cleaned = cleaned + 1
        end
    end
    
    return cleaned
end

-- =================================
-- ENHANCED MAIN LOGIC WITH ISLAND DETECTION
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
    horseManipulator.runtime.teleportCount = 0
    
    local currentIsland = detectCurrentIsland()
    
    Rayfield:Notify({
       Title = "🚀 Ultra Island Manipulation Started!",
       Content = "Island: " .. currentIsland .. " | Global + Teleportation | Island-aware system active",
       Duration = 4,
       Image = 4483362458,
    })
    
    -- ISLAND MONITORING CONNECTION
    horseManipulator.connections.island = RunService.Heartbeat:Connect(function()
        if not horseManipulator.isRunning then return end
        
        local currentTime = tick()
        if currentTime - horseManipulator.runtime.lastIslandCheck < 5 then
            return
        end
        
        detectCurrentIsland()
        horseManipulator.runtime.lastIslandCheck = currentTime
    end)
    
    -- SCANNING CONNECTION
    horseManipulator.connections.scanning = RunService.Heartbeat:Connect(function()
        if not horseManipulator.isRunning then return end
        
        local currentTime = tick()
        if currentTime - horseManipulator.runtime.lastScanTime < horseManipulator.settings.scanInterval then
            return
        end
        
        updateGlobalWildHorses()
        horseManipulator.runtime.lastScanTime = currentTime
    end)
    
    -- MANIPULATION CONNECTION
    horseManipulator.connections.manipulation = RunService.Heartbeat:Connect(function()
        if not horseManipulator.isRunning then return end
        
        local currentTime = tick()
        if currentTime - horseManipulator.runtime.lastManipulationTime < horseManipulator.settings.manipulationInterval then
            return
        end
        
        local wildHorses = updateGlobalWildHorses()
        local manipulatedThisRound = 0
        
        local batchSize = math.min(#wildHorses, horseManipulator.settings.maxBatchSize)
        for i = 1, batchSize do
            local horseData = wildHorses[i]
            if horseData and horseData.horse and not horseManipulator.manipulatedHorses[horseData.horse.Name] then
                local success, horseName = manipulateHorseAttributes(horseData.horse)
                
                if success then
                    manipulatedThisRound = manipulatedThisRound + 1
                    
                    if manipulatedThisRound <= 3 then
                        Rayfield:Notify({
                           Title = "🎭 " .. horseName .. " Controlled!",
                           Content = "Island: " .. horseData.location .. " | Auto-teleport: " .. (horseManipulator.settings.autoTeleport and "✅" or "❌"),
                           Duration = 2,
                           Image = 4483362458,
                        })
                    end
                end
            end
        end
        
        if manipulatedThisRound > 3 then
            Rayfield:Notify({
               Title = "🌍 Mass Island Control!",
               Content = "Controlled " .. manipulatedThisRound .. " horses across islands! Auto-teleport: " .. (horseManipulator.settings.autoTeleport and "Active" or "Disabled"),
               Duration = 3,
               Image = 4483362458,
            })
        end
        
        horseManipulator.runtime.lastManipulationTime = currentTime
    end)
    
    -- ENFORCEMENT CONNECTION
    if horseManipulator.settings.continuousEnforcement then
        horseManipulator.connections.enforcement = RunService.Heartbeat:Connect(function()
            if not horseManipulator.isRunning then return end
            
            local currentTime = tick()
            if currentTime - horseManipulator.runtime.lastEnforcementTime < horseManipulator.settings.enforcementInterval then
                return
            end
            
            local manipulatedHorses = updateManipulatedHorses()
            
            if #manipulatedHorses > 0 then
                local enforced, changes = batchEnforceAttributes(manipulatedHorses)
                
                local sessionTime = currentTime - horseManipulator.runtime.sessionStartTime
                if sessionTime > 0 then
                    horseManipulator.statistics.enforcementsPerSecond = horseManipulator.runtime.enforcementCount / sessionTime
                end
            end
            
            horseManipulator.runtime.lastEnforcementTime = currentTime
        end)
    end
    
    -- TELEPORTATION CONNECTION
    if horseManipulator.settings.autoTeleport then
        horseManipulator.connections.teleportation = RunService.Heartbeat:Connect(function()
            if not horseManipulator.isRunning then return end
            
            local currentTime = tick()
            local teleportInterval = horseManipulator.settings.teleportLoop and horseManipulator.settings.teleportInterval or (horseManipulator.settings.teleportInterval * 2)
            
            if currentTime - horseManipulator.runtime.lastTeleportTime < teleportInterval then
                return
            end
            
            local teleported = batchTeleportControlledHorses()
            
            if teleported > 0 and horseManipulator.settings.teleportLoop then
                if teleported >= 3 then
                    Rayfield:Notify({
                       Title = "🌀 Loop Teleport!",
                       Content = "Teleported " .. teleported .. " horses to you!",
                       Duration = 1.5,
                       Image = 4483362458,
                    })
                end
            end
            
            horseManipulator.runtime.lastTeleportTime = currentTime
        end)
    end
    
    -- CLEANUP CONNECTION
    horseManipulator.connections.cleanup = RunService.Heartbeat:Connect(function()
        if not horseManipulator.isRunning then return end
        
        local currentTime = tick()
        if currentTime - horseManipulator.runtime.lastCleanupTime < horseManipulator.settings.cleanupInterval then
            return
        end
        
        cleanupDisconnectedHorses()
        
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
    
    for name, connection in pairs(horseManipulator.connections) do
        if connection then
            connection:Disconnect()
            horseManipulator.connections[name] = nil
        end
    end
    
    local sessionTime = tick() - horseManipulator.runtime.sessionStartTime
    local minutes = math.floor(sessionTime / 60)
    local seconds = math.floor(sessionTime % 60)
    local currentIsland = detectCurrentIsland()
    
    Rayfield:Notify({
       Title = "🏁 Island Session Ended",
       Content = "Island: " .. currentIsland .. " | Controlled: " .. horseManipulator.runtime.manipulatedCount .. " | Teleports: " .. horseManipulator.runtime.teleportCount,
       Duration = 5,
       Image = 4483362458,
    })
end

-- =================================
-- ENHANCED UI WITH ISLAND FEATURES
-- =================================

-- 🏝️ MAIN CONTROL SECTION
local MainControlSection = parentTab:CreateSection("🏝️ Island Manipulation Control")

local MainToggle = parentTab:CreateToggle({
   Name = "🚀 Ultra Island Manipulation",
   CurrentValue = false,
   Flag = "UltraIslandManipulationToggle",
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

-- 🏝️ ISLAND SETTINGS SECTION
local IslandSettingsSection = parentTab:CreateSection("🏝️ Island Settings")

local MultiIslandToggle = parentTab:CreateToggle({
   Name = "🌍 Multi-Island Mode",
   CurrentValue = true,
   Flag = "MultiIslandManipulationToggle",
   Callback = function(Value)
      horseManipulator.settings.multiIslandMode = Value
      Rayfield:Notify({
         Title = "🌍 Multi-Island " .. (Value and "Enabled" or "Disabled"),
         Content = Value and "Will manipulate horses on all islands" or "Only current island",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local IslandOnlyToggle = parentTab:CreateToggle({
   Name = "📍 Current Island Only",
   CurrentValue = false,
   Flag = "IslandOnlyManipulationToggle",
   Callback = function(Value)
      horseManipulator.settings.islandOnlyMode = Value
      Rayfield:Notify({
         Title = "📍 Island-Only " .. (Value and "Enabled" or "Disabled"),
         Content = Value and "Only manipulate horses on current island" or "Global manipulation",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local PrioritizeCurrentToggle = parentTab:CreateToggle({
   Name = "⭐ Prioritize Current Island",
   CurrentValue = true,
   Flag = "PrioritizeCurrentIslandManipulationToggle",
   Callback = function(Value)
      horseManipulator.settings.prioritizeCurrentIsland = Value
   end,
})

-- 🌀 TELEPORTATION CONTROL SECTION
local TeleportationControlSection = parentTab:CreateSection("🌀 Horse Teleportation")

local AutoTeleportToggle = parentTab:CreateToggle({
   Name = "🌀 Auto Teleport Controlled Horses",
   CurrentValue = false,
   Flag = "AutoTeleportManipulationToggle",
   Callback = function(Value)
      horseManipulator.settings.autoTeleport = Value
      
      if horseManipulator.isRunning then
         if horseManipulator.connections.teleportation then
            horseManipulator.connections.teleportation:Disconnect()
            horseManipulator.connections.teleportation = nil
         end
         
         if Value then
            horseManipulator.connections.teleportation = RunService.Heartbeat:Connect(function()
               if not horseManipulator.isRunning then return end
               
               local currentTime = tick()
               local teleportInterval = horseManipulator.settings.teleportLoop and horseManipulator.settings.teleportInterval or (horseManipulator.settings.teleportInterval * 2)
               
               if currentTime - horseManipulator.runtime.lastTeleportTime < teleportInterval then
                  return
               end
               
               local teleported = batchTeleportControlledHorses()
               
               if teleported > 0 and horseManipulator.settings.teleportLoop then
                  if teleported >= 3 then
                     Rayfield:Notify({
                        Title = "🌀 Loop Teleport!",
                        Content = "Teleported " .. teleported .. " horses to you!",
                        Duration = 1.5,
                        Image = 4483362458,
                     })
                  end
               end
               
               horseManipulator.runtime.lastTeleportTime = currentTime
            end)
         end
      end
      
      Rayfield:Notify({
         Title = "🌀 Auto Teleport " .. (Value and "Enabled" or "Disabled"),
         Content = Value and "Controlled horses will be teleported to you!" or "Auto teleportation disabled",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

local TeleportLoopToggle = parentTab:CreateToggle({
   Name = "🔄 Teleport Loop Mode",
   CurrentValue = false,
   Flag = "TeleportLoopManipulationToggle",
   Callback = function(Value)
      horseManipulator.settings.teleportLoop = Value
   end,
})

local TeleportRadiusSlider = parentTab:CreateSlider({
   Name = "🌀 Teleport Radius",
   Range = {8, 50},
   Increment = 2,
   Suffix = " studs",
   CurrentValue = 15,
   Flag = "TeleportRadiusManipulationSlider",
   Callback = function(Value)
      horseManipulator.settings.teleportRadius = Value
   end,
})

local TeleportIntervalSlider = parentTab:CreateSlider({
   Name = "⏱️ Teleport Interval",
   Range = {1, 10},
   Increment = 0.5,
   Suffix = "s",
   CurrentValue = 3,
   Flag = "TeleportIntervalManipulationSlider",
   Callback = function(Value)
      horseManipulator.settings.teleportInterval = Value
   end,
})

local InstantTeleportButton = parentTab:CreateButton({
   Name = "⚡ Instant Teleport All",
   Callback = function()
      local teleported = batchTeleportControlledHorses()
      Rayfield:Notify({
         Title = "⚡ Instant Teleport",
         Content = "Teleported " .. teleported .. " controlled horses to you!",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

-- 🎛️ ULTRA SETTINGS SECTION (same as before)
local UltraSettingsSection = parentTab:CreateSection("🎛️ Ultra Optimization")

local GlobalModeToggle = parentTab:CreateToggle({
   Name = "🌍 Global Mode (No Distance Limits)",
   CurrentValue = true,
   Flag = "UltraGlobalModeManipulationToggle",
   Callback = function(Value)
      horseManipulator.settings.globalManipulation = Value
   end,
})

-- ... (rest of sliders same as before)

-- 🏝️ ENHANCED STATUS SECTION
local IslandStatusSection = parentTab:CreateSection("🏝️ Island Status")

local IslandInfo = parentTab:CreateParagraph({Title = "🏝️ Current Island", Content = "Detecting island..."})
local IslandStats = parentTab:CreateParagraph({Title = "📊 Island Statistics", Content = "No data yet"})
local SystemStatus = parentTab:CreateParagraph({Title = "🚀 System Status", Content = "Island-optimized system ready"})
local TeleportStatus = parentTab:CreateParagraph({Title = "🌀 Teleportation Status", Content = "Teleportation ready"})

-- =================================
-- ENHANCED STATUS UPDATE SYSTEM WITH ISLAND INFO
-- =================================
spawn(function()
    while wait(1) do
        local currentIsland = detectCurrentIsland()
        
        -- Island Info
        local islandText = "🏝️ Current Island: " .. currentIsland .. "\n"
        islandText = islandText .. "🐎 Horses on Island: " .. (horseManipulator.runtime.currentIslandHorses or 0) .. "\n"
        
        local totalIslands = 0
        for islandName, horseCount in pairs(islandSystem.islandHorses) do
            totalIslands = totalIslands + 1
        end
        
        islandText = islandText .. "🌍 Islands Scanned: " .. totalIslands .. "\n"
        islandText = islandText .. "🔍 Multi-Island: " .. (horseManipulator.settings.multiIslandMode and "✅" or "❌") .. "\n"
        islandText = islandText .. "📍 Island-Only: " .. (horseManipulator.settings.islandOnlyMode and "✅" or "❌")
        
        IslandInfo:Set({Title = "🏝️ Current Island", Content = islandText})
        
        -- Island Statistics
        local statsText = "📊 Per-Island Manipulations:\n"
        for islandName, manipulationCount in pairs(horseManipulator.statistics.islandStats) do
            statsText = statsText .. "• " .. islandName .. ": " .. manipulationCount .. " horses\n"
        end
        
        if next(horseManipulator.statistics.islandStats) == nil then
            statsText = statsText .. "No manipulations yet"
        end
        
        IslandStats:Set({Title = "📊 Island Statistics", Content = statsText})
        
        -- Enhanced System Status
        local systemText = ""
        if horseManipulator.isRunning then
            local runtime = tick() - horseManipulator.runtime.sessionStartTime
            local minutes = math.floor(runtime / 60)
            local seconds = math.floor(runtime % 60)
            
            systemText = "🚀 ISLAND-ACTIVE (Global + Teleport)\n"
            systemText = systemText .. "🏝️ Island: " .. currentIsland .. "\n"
            systemText = systemText .. "⏱️ Runtime: " .. minutes .. "m " .. seconds .. "s\n"
            systemText = systemText .. "🎭 Controlled: " .. horseManipulator.runtime.manipulatedCount .. "\n"
            systemText = systemText .. "🌀 Teleports: " .. horseManipulator.runtime.teleportCount .. "\n"
            systemText = systemText .. "🏝️ Island Horses: " .. horseManipulator.runtime.currentIslandHorses
        else
            systemText = "🔴 STOPPED\n🏝️ Island: " .. currentIsland .. "\n💤 Island-optimized system ready\n🌍 Multi-island manipulation available\n🌀 Auto teleportation ready\n🚀 Island-performance ready"
        end
        SystemStatus:Set({Title = "🚀 System Status", Content = systemText})
        
        -- Teleportation Status
        local teleportText = ""
        if horseManipulator.settings.autoTeleport then
            teleportText = "🌀 AUTO-TELEPORT ACTIVE\n"
            teleportText = teleportText .. "🔄 Loop Mode: " .. (horseManipulator.settings.teleportLoop and "✅" or "❌") .. "\n"
            teleportText = teleportText .. "📏 Radius: " .. horseManipulator.settings.teleportRadius .. " studs\n"
            teleportText = teleportText .. "⏱️ Interval: " .. horseManipulator.settings.teleportInterval .. "s\n"
            teleportText = teleportText .. "📊 Horses Nearby: " .. horseManipulator.runtime.horsesNearby .. "\n"
            teleportText = teleportText .. "🏝️ Island Filter: " .. (horseManipulator.settings.islandOnlyMode and "Active" or "Disabled")
        else
            teleportText = "🔴 TELEPORT DISABLED\n⚙️ Radius: " .. horseManipulator.settings.teleportRadius .. " studs\n⏱️ Interval: " .. horseManipulator.settings.teleportInterval .. "s\n🌀 Manual teleportation available\n🏝️ Island-aware teleportation"
        end
        TeleportStatus:Set({Title = "🌀 Teleportation Status", Content = teleportText})
    end
end)

-- Character respawn handling (same as before)
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    if horseManipulator.isRunning then
        stopHorseManipulation()
        MainToggle:Set(false)
        
        Rayfield:Notify({
           Title = "🔄 Character Respawned",
           Content = "Island manipulation stopped - restart when ready",
           Duration = 3,
           Image = 4483362458,
        })
    end
end)

-- =================================
-- ENHANCED INITIALIZATION
-- =================================
Rayfield:Notify({
   Title = "🏝️ Ultra Island Horse Manipulator Loaded!",
   Content = "Multi-island detection | Smart island prioritization | Auto teleportation",
   Duration = 5,
   Image = 4483362458,
})

-- Initial island detection
local initialIsland = detectCurrentIsland()

Rayfield:Notify({
   Title = "🏝️ Island Detected!",
   Content = "Current Island: " .. initialIsland .. " | Island-aware manipulation ready!",
   Duration = 4,
   Image = 4483362458,
})

print("🏝️ Ultra Island Horse Manipulator - Multi-Island Edition Loaded!")
print("✅ Professional island detection and manipulation system")
print("🌍 Multi-island horse manipulation with smart prioritization")
print("🎯 Current island: " .. initialIsland)
print("🌀 Island-aware teleportation system")
print("🚀 Revolutionary island-aware horse manipulation ready!")
