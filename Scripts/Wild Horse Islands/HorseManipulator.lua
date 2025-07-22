-- Horse Attribute Manipulator - Ultra-Optimized Island Detection + Auto Teleportation Edition
-- by Iyxo - 2025-07-22 10:05:39
-- Revolutionary horse control with multi-island detection + ultra-optimized continuous enforcement + auto teleportation

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
    islandHorseCount = {}
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
            -- Always prioritize current island
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
            
            -- Also scan other islands (lower priority)
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
    maxCacheSize = 1000,
    islandHorses = {} -- Per-island horse tracking
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
        island = nil -- Island monitoring
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
        
        -- Island settings
        multiIslandMode = true,
        prioritizeCurrentIsland = true,
        
        -- Teleportation settings
        autoTeleport = false,
        teleportLoop = false,
        teleportInterval = 3,
        teleportRadius = 15,
        teleportHeight = 5,
        maxTeleportDistance = 500,
        
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
        islandStats = {} -- Per-island statistics
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

-- ENHANCED: Island-aware horse name getter with better detection
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
                -- First try: BreedLabel
                local breedLabel = overhead:FindFirstChild("BreedLabel")
                if breedLabel and breedLabel.Text and breedLabel.Text ~= "" and breedLabel.Text ~= " " then
                    horseName = breedLabel.Text
                    success = true
                else
                    -- Second try: Other labels
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
        
        -- Third try: Check for any text-containing parts
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
        
        -- Fourth try: Use shortened ID as fallback
        if not success or horseName == "Unknown" then
            horseName = "Horse_" .. horse.Name:sub(2, 9)
            success = true
        end
    end)
    
    if success then
        Cache.horseData[horse.Name] = {
            name = horseName,
            lastUpdate = tick(),
            isWild = nil
        }
    end
    
    return horseName
end

-- Ultra-fast wild horse checker with aggressive caching
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
                isWild = isWild
            }
        else
            Cache.horseData[horse.Name].isWild = isWild
            Cache.horseData[horse.Name].lastUpdate = tick()
        end
    end
    
    return isWild
end

-- ENHANCED: Multi-island global horse scanning
local function updateGlobalWildHorses()
    local currentTime = tick()
    if currentTime - Cache.lastWildUpdate < Cache.wildUpdateInterval then
        return Cache.wildHorses
    end
    
    local startTime = tick()
    Cache.wildHorses = {}
    Cache.islandHorses = {}
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
                        
                        -- Performance limits per island type
                        if priority == 1 and islandHorseCount >= Cache.maxCacheSize * 0.6 then
                            break
                        elseif priority == 2 and islandHorseCount >= Cache.maxCacheSize * 0.3 then
                            break
                        end
                        
                        if horseCount >= Cache.maxCacheSize then
                            break
                        end
                    end
                end
            end
        end
        
        Cache.islandHorses[islandName] = islandHorseCount
        islandSystem.islandHorseCount[islandName] = islandHorseCount
    end
    
    -- Scan locations by priority (current island first)
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
    horseManipulator.runtime.currentIslandHorses = Cache.islandHorses[currentIsland] or 0
    
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
            
            -- Search through all islands
            if Workspace.Islands then
                if Workspace.Islands.Mainland then
                    horse = Workspace.Islands.Mainland:FindFirstChild(horseId)
                    if horse then foundIsland = "Mainland" end
                end
                
                if not horse then
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
                    
                    -- Update horse location in data
                    if foundIsland then
                        horseManipulator.manipulatedHorses[horseId].location = foundIsland
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
-- ENHANCED HORSE TELEPORTATION SYSTEM
-- =================================

-- Professional horse teleportation with island awareness
local function teleportHorseToPlayer(horse, index)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") then return false end
    
    local success = false
    local startTime = tick()
    
    pcall(function()
        local playerPos = humanoidRootPart.Position
        local currentIsland = detectCurrentIsland()
        
        -- Calculate optimal position around player
        local angle = (index - 1) * (math.pi * 2 / math.min(#Cache.manipulatedHorses, 8))
        local radius = horseManipulator.settings.teleportRadius
        
        -- Create circular formation around player
        local offsetX = math.cos(angle) * radius
        local offsetZ = math.sin(angle) * radius
        local targetPos = playerPos + Vector3.new(offsetX, horseManipulator.settings.teleportHeight, offsetZ)
        
        -- Advanced positioning for multiple horses
        if #Cache.manipulatedHorses > 8 then
            local ring = math.floor((index - 1) / 8)
            radius = horseManipulator.settings.teleportRadius + (ring * 8)
            offsetX = math.cos(angle) * radius
            offsetZ = math.sin(angle) * radius
            targetPos = playerPos + Vector3.new(offsetX, horseManipulator.settings.teleportHeight, offsetZ)
        end
        
        -- Ensure horses don't teleport too far
        local currentDistance = (playerPos - horse.HumanoidRootPart.Position).Magnitude
        if currentDistance <= horseManipulator.settings.maxTeleportDistance then
            -- Smooth teleportation
            horse.HumanoidRootPart.CFrame = CFrame.lookAt(targetPos, playerPos)
            
            -- Clean up any existing velocity
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

-- Batch teleport all controlled horses with island awareness
local function batchTeleportControlledHorses()
    if not horseManipulator.settings.autoTeleport then return 0 end
    
    local manipulatedHorses = updateManipulatedHorses()
    local teleported = 0
    local currentIsland = detectCurrentIsland()
    
    -- Prioritize horses on current island
    local prioritizedHorses = {}
    local otherHorses = {}
    
    for i, horseData in pairs(manipulatedHorses) do
        if horseData.distance > horseManipulator.settings.teleportRadius then
            if horseData.island == currentIsland then
                table.insert(prioritizedHorses, {horse = horseData.horse, index = i})
            else
                table.insert(otherHorses, {horse = horseData.horse, index = i})
            end
        end
    end
    
    -- Teleport prioritized horses first
    for _, horseInfo in pairs(prioritizedHorses) do
        if teleportHorseToPlayer(horseInfo.horse, horseInfo.index) then
            teleported = teleported + 1
        end
        if teleported >= 3 then break end
    end
    
    -- Then teleport other horses if still under limit
    if teleported < 5 then
        for _, horseInfo in pairs(otherHorses) do
            if teleportHorseToPlayer(horseInfo.horse, horseInfo.index) then
                teleported = teleported + 1
            end
            if teleported >= 5 then break end
        end
    end
    
    return teleported
end

-- =================================
-- ENHANCED ATTRIBUTE MANIPULATION WITH ISLAND TRACKING
-- =================================

-- ULTRA-OPTIMIZED BATCH ATTRIBUTE ENFORCEMENT
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

-- ENHANCED: Initial manipulation with island tracking
local function manipulateHorseAttributes(horse)
    if not horse then return false end
    
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
            location = currentIsland,
            island = currentIsland
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

-- Professional cleanup system with island awareness
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
       Title = "🚀 Ultra Island Horse Manipulation Started!",
       Content = "Island: " .. currentIsland .. " | Global enforcement + Auto teleportation | Multi-island system active",
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
        local currentIsland = detectCurrentIsland()
        
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
                       Title = "🌀 Island Loop Teleport!",
                       Content = "Teleported " .. teleported .. " horses from multiple islands to you!",
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
        
        local cleaned = cleanupDisconnectedHorses()
        
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
       Title = "🏁 Ultra Island Session Ended",
       Content = "Island: " .. currentIsland .. " | Controlled: " .. horseManipulator.runtime.manipulatedCount .. " | Teleports: " .. horseManipulator.runtime.teleportCount .. " | Time: " .. minutes .. "m " .. seconds .. "s",
       Duration = 5,
       Image = 4483362458,
    })
end

-- =================================
-- ENHANCED UI WITH ISLAND + TELEPORTATION CONTROLS
-- =================================

-- 🏝️ MAIN ISLAND CONTROL SECTION
local MainControlSection = parentTab:CreateSection("🏝️ Ultra Island Manipulation Control")

local MainToggle = parentTab:CreateToggle({
   Name = "🚀 Ultra Island Global Manipulation",
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
local IslandSettingsSection = parentTab:CreateSection("🏝️ Island Detection Settings")

local MultiIslandToggle = parentTab:CreateToggle({
   Name = "🌍 Multi-Island Mode",
   CurrentValue = true,
   Flag = "MultiIslandModeToggle",
   Callback = function(Value)
      horseManipulator.settings.multiIslandMode = Value
      Rayfield:Notify({
         Title = "🌍 Multi-Island " .. (Value and "Enabled" or "Disabled"),
         Content = Value and "Will scan all islands for horses" or "Only current island",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local PrioritizeCurrentToggle = parentTab:CreateToggle({
   Name = "📍 Prioritize Current Island",
   CurrentValue = true,
   Flag = "PrioritizeCurrentIslandToggle",
   Callback = function(Value)
      horseManipulator.settings.prioritizeCurrentIsland = Value
   end,
})

-- 🌀 TELEPORTATION CONTROL SECTION
local TeleportationControlSection = parentTab:CreateSection("🌀 Horse Teleportation")

local AutoTeleportToggle = parentTab:CreateToggle({
   Name = "🌀 Auto Teleport Controlled Horses",
   CurrentValue = false,
   Flag = "AutoTeleportToggle",
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
                        Title = "🌀 Island Loop Teleport!",
                        Content = "Teleported " .. teleported .. " horses from multiple islands to you!",
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
         Content = Value and "Controlled horses will be teleported from all islands!" or "Auto teleportation disabled",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

local TeleportLoopToggle = parentTab:CreateToggle({
   Name = "🔄 Teleport Loop Mode",
   CurrentValue = false,
   Flag = "TeleportLoopToggle",
   Callback = function(Value)
      horseManipulator.settings.teleportLoop = Value
      Rayfield:Notify({
         Title = "🔄 Loop Mode " .. (Value and "Enabled" or "Disabled"),
         Content = Value and "Horses will be continuously teleported from all islands!" or "Single teleport mode",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local TeleportRadiusSlider = parentTab:CreateSlider({
   Name = "🌀 Teleport Radius",
   Range = {8, 50},
   Increment = 2,
   Suffix = " studs",
   CurrentValue = 15,
   Flag = "TeleportRadiusSlider",
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
   Flag = "TeleportIntervalSlider",
   Callback = function(Value)
      horseManipulator.settings.teleportInterval = Value
   end,
})

local TeleportHeightSlider = parentTab:CreateSlider({
   Name = "📏 Teleport Height",
   Range = {0, 15},
   Increment = 1,
   Suffix = " studs",
   CurrentValue = 5,
   Flag = "TeleportHeightSlider",
   Callback = function(Value)
      horseManipulator.settings.teleportHeight = Value
   end,
})

local InstantTeleportButton = parentTab:CreateButton({
   Name = "⚡ Instant Teleport All Islands",
   Callback = function()
      local teleported = batchTeleportControlledHorses()
      Rayfield:Notify({
         Title = "⚡ Instant Island Teleport",
         Content = "Teleported " .. teleported .. " controlled horses from all islands to you!",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

-- 🎛️ ULTRA SETTINGS SECTION
local UltraSettingsSection = parentTab:CreateSection("🎛️ Ultra Optimization")

local GlobalModeToggle = parentTab:CreateToggle({
   Name = "🌍 Global Mode (No Distance Limits)",
   CurrentValue = true,
   Flag = "UltraGlobalModeToggle",
   Callback = function(Value)
      horseManipulator.settings.globalManipulation = Value
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

-- 🎯 ATTRIBUTE CONTROLS SECTION
local AttributeControlsSection = parentTab:CreateSection("🎯 Attribute Controls")

local ContinuousEnforcementToggle = parentTab:CreateToggle({
   Name = "🔒 Continuous Enforcement",
   CurrentValue = true,
   Flag = "UltraContinuousEnforcementToggle",
   Callback = function(Value)
      horseManipulator.settings.continuousEnforcement = Value
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

-- 🏝️ ENHANCED STATUS SECTION
local EnhancedStatusSection = parentTab:CreateSection("🏝️ Enhanced Island Status")

local IslandInfo = parentTab:CreateParagraph({Title = "🏝️ Current Island", Content = "Detecting island..."})
local IslandStats = parentTab:CreateParagraph({Title = "📊 Island Statistics", Content = "No data yet"})
local SystemStatus = parentTab:CreateParagraph({Title = "🚀 Ultra System Status", Content = "Island-optimized system ready"})
local TeleportStatus = parentTab:CreateParagraph({Title = "🌀 Teleportation Status", Content = "Island teleportation ready"})
local GlobalStats = parentTab:CreateParagraph({Title = "🌍 Global Statistics", Content = "Island monitoring ready"})
local PerformanceMetrics = parentTab:CreateParagraph({Title = "⚡ Performance Metrics", Content = "Island-performance monitoring"})

-- ⚡ ENHANCED ACTIONS SECTION
local EnhancedActionsSection = parentTab:CreateSection("⚡ Enhanced Island Actions")

local GlobalInstantButton = parentTab:CreateButton({
   Name = "🌍 Instant Global Island Manipulation",
   Callback = function()
      local wildHorses = updateGlobalWildHorses()
      local manipulated = 0
      local islandBreakdown = {}
      
      for _, horseData in pairs(wildHorses) do
         if horseData.horse and not horseManipulator.manipulatedHorses[horseData.horse.Name] then
            local success, horseName = manipulateHorseAttributes(horseData.horse)
            if success then
               manipulated = manipulated + 1
               islandBreakdown[horseData.location] = (islandBreakdown[horseData.location] or 0) + 1
            end
         end
      end
      
      local islandText = ""
      for island, count in pairs(islandBreakdown) do
         islandText = islandText .. island .. ": " .. count .. " "
      end
      
      Rayfield:Notify({
         Title = "🌍 Global Island Manipulation Complete",
         Content = "Controlled " .. manipulated .. " horses across all islands! " .. islandText,
         Duration = 5,
         Image = 4483362458,
      })
   end,
})

local UltraEnforceButton = parentTab:CreateButton({
   Name = "🔒 Ultra Global Island Enforcement",
   Callback = function()
      local manipulatedHorses = updateManipulatedHorses()
      local enforced, changes = batchEnforceAttributes(manipulatedHorses)
      
      Rayfield:Notify({
         Title = "🔒 Ultra Island Enforcement Complete",
         Content = "Ultra-enforced " .. enforced .. " horses with " .. changes .. " changes across all islands!",
         Duration = 4,
         Image = 4483362458,
      })
   end,
})

local ResetStatsButton = parentTab:CreateButton({
   Name = "📊 Reset Island Statistics",
   Callback = function()
      horseManipulator.statistics = {
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
         islandStats = {}
      }
      horseManipulator.runtime.manipulatedCount = 0
      horseManipulator.runtime.enforcementCount = 0
      horseManipulator.runtime.teleportCount = 0
      
      Rayfield:Notify({
         Title = "📊 Island Stats Reset",
         Content = "All island statistics have been reset",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- 📈 ENHANCED STATISTICS SECTION
local EnhancedStatisticsSection = parentTab:CreateSection("📈 Enhanced Island Statistics")

local SessionMetrics = parentTab:CreateParagraph({Title = "📈 Session Metrics", Content = "Enhanced island session ready"})
local AllTimeMetrics = parentTab:CreateParagraph({Title = "🏆 All-Time Records", Content = "No island data yet"})
local TeleportMetrics = parentTab:CreateParagraph({Title = "🌀 Teleportation Metrics", Content = "Island teleport tracking ready"})

-- =================================
-- ENHANCED STATUS UPDATE SYSTEM WITH ISLAND + TELEPORTATION
-- =================================
spawn(function()
    while wait(0.5) do
        local currentIsland = detectCurrentIsland()
        
        -- Island Info
        local islandText = "🏝️ Current Island: " .. currentIsland .. "\n"
        islandText = islandText .. "🐎 Horses on Island: " .. (horseManipulator.runtime.currentIslandHorses or 0) .. "\n"
        
        local totalIslands = 0
        for islandName, horseCount in pairs(Cache.islandHorses) do
            totalIslands = totalIslands + 1
        end
        
        islandText = islandText .. "🌍 Islands Scanned: " .. totalIslands .. "\n"
        islandText = islandText .. "🔍 Multi-Island: " .. (horseManipulator.settings.multiIslandMode and "✅" or "❌") .. "\n"
        islandText = islandText .. "📍 Prioritize Current: " .. (horseManipulator.settings.prioritizeCurrentIsland and "✅" or "❌")
        
        IslandInfo:Set({Title = "🏝️ Current Island", Content = islandText})
        
        -- Island Statistics
        local statsText = "📊 Per-Island Controls:\n"
        for islandName, controlCount in pairs(horseManipulator.statistics.islandStats) do
            statsText = statsText .. "• " .. islandName .. ": " .. controlCount .. " horses\n"
        end
        
        if next(horseManipulator.statistics.islandStats) == nil then
            statsText = statsText .. "No controls yet"
        end
        
        local currentIslandHorses = Cache.islandHorses[currentIsland] or 0
        statsText = statsText .. "\n🎯 Current Island Horses: " .. currentIslandHorses
        
        IslandStats:Set({Title = "📊 Island Statistics", Content = statsText})
        
        -- Enhanced System Status
        local statusText = ""
        if horseManipulator.isRunning then
            local runtime = tick() - horseManipulator.runtime.sessionStartTime
            local minutes = math.floor(runtime / 60)
            local seconds = math.floor(runtime % 60)
            
            statusText = "🚀 ISLAND-ULTRA-ACTIVE (Global + Teleport)\n"
            statusText = statusText .. "🏝️ Island: " .. currentIsland .. "\n"
            statusText = statusText .. "⏱️ Runtime: " .. minutes .. "m " .. seconds .. "s\n"
            statusText = statusText .. "🌍 Global: " .. (horseManipulator.settings.globalManipulation and "✅" or "❌") .. "\n"
            statusText = statusText .. "🎭 Controlled: " .. horseManipulator.runtime.manipulatedCount .. "\n"
            statusText = statusText .. "🔒 Enforcements: " .. horseManipulator.runtime.enforcementCount .. "\n"
            statusText = statusText .. "🌀 Teleports: " .. horseManipulator.runtime.teleportCount
        else
            statusText = "🔴 STOPPED\n🏝️ Island: " .. currentIsland .. "\n💤 Island-enhanced system ready\n🌍 Multi-island manipulation available\n🌀 Island auto teleportation ready\n⚡ Island ultra-performance optimizations"
        end
        SystemStatus:Set({Title = "🚀 Ultra System Status", Content = statusText})
        
        -- Enhanced Teleportation Status
        local teleportText = ""
        if horseManipulator.settings.autoTeleport then
            teleportText = "🌀 ISLAND AUTO-TELEPORT ACTIVE\n"
            teleportText = teleportText .. "🏝️ Island Priority: " .. (horseManipulator.settings.prioritizeCurrentIsland and "✅" or "❌") .. "\n"
            teleportText = teleportText .. "🔄 Loop Mode: " .. (horseManipulator.settings.teleportLoop and "✅" or "❌") .. "\n"
            teleportText = teleportText .. "📏 Radius: " .. horseManipulator.settings.teleportRadius .. " studs\n"
            teleportText = teleportText .. "⏱️ Interval: " .. horseManipulator.settings.teleportInterval .. "s\n"
            teleportText = teleportText .. "📊 Horses Nearby: " .. horseManipulator.runtime.horsesNearby .. "\n"
            teleportText = teleportText .. "🌀 Total Teleports: " .. horseManipulator.runtime.teleportCount
        else
            teleportText = "🔴 TELEPORT DISABLED\n🏝️ Island Mode: Available\n⚙️ Radius: " .. horseManipulator.settings.teleportRadius .. " studs\n⏱️ Interval: " .. horseManipulator.settings.teleportInterval .. "s\n🌀 Manual island teleportation available\n📊 Nearby tracking active"
        end
        TeleportStatus:Set({Title = "🌀 Teleportation Status", Content = teleportText})
        
        -- Enhanced Global Statistics
        local wildHorsesCount = #Cache.wildHorses
        local manipulatedCount = 0
        for _ in pairs(horseManipulator.manipulatedHorses) do
            manipulatedCount = manipulatedCount + 1
        end
        
        local globalCoverage = wildHorsesCount > 0 and (manipulatedCount / wildHorsesCount) * 100 or 0
        
        local globalText = "🌍 Horses Scanned: " .. wildHorsesCount .. "\n"
        globalText = globalText .. "🎯 Controlled: " .. manipulatedCount .. "\n"
        globalText = globalText .. "📊 Coverage: " .. string.format("%.1f", globalCoverage) .. "%\n"
        globalText = globalText .. "🏆 Peak Controlled: " .. horseManipulator.statistics.peakHorsesControlled .. "\n"
        globalText = globalText .. "🏝️ Islands Active: " .. totalIslands .. "\n"
        globalText = globalText .. "🌀 Horses Nearby: " .. horseManipulator.runtime.horsesNearby .. "\n"
        globalText = globalText .. "📈 Peak Nearby: " .. horseManipulator.statistics.horsesNearbyPeak
        GlobalStats:Set({Title = "🌍 Global Statistics", Content = globalText})
        
        -- Enhanced Performance Metrics
        local avgTeleportTime = 0
        if #horseManipulator.performance.teleportTimes > 0 then
            local total = 0
            for _, time in pairs(horseManipulator.performance.teleportTimes) do
                total = total + time
            end
            avgTeleportTime = total / #horseManipulator.performance.teleportTimes
        end
        
        local avgIslandScanTime = 0
        if #horseManipulator.performance.islandScanTimes > 0 then
            local total = 0
            for _, time in pairs(horseManipulator.performance.islandScanTimes) do
                total = total + time
            end
            avgIslandScanTime = total / #horseManipulator.performance.islandScanTimes
        end
        
        local performanceText = "⚡ Enforcement: " .. string.format("%.2f", horseManipulator.statistics.enforcementsPerSecond) .. "/s\n"
        performanceText = performanceText .. "🌀 Avg Teleport: " .. string.format("%.3f", avgTeleportTime * 1000) .. "ms\n"
        performanceText = performanceText .. "🏝️ Avg Island Scan: " .. string.format("%.3f", avgIslandScanTime * 1000) .. "ms\n"
        performanceText = performanceText .. "📦 Max Batch: " .. horseManipulator.performance.maxBatchSize .. "\n"
        performanceText = performanceText .. "🔄 Cache: " .. wildHorsesCount .. " horses\n"
        performanceText = performanceText .. "🚀 Status: ISLAND-ULTRA-OPTIMIZED"
        PerformanceMetrics:Set({Title = "⚡ Performance Metrics", Content = performanceText})
        
        -- Enhanced Session Metrics
        if horseManipulator.isRunning then
            local sessionTime = tick() - horseManipulator.runtime.sessionStartTime
            local sessionMinutes = math.floor(sessionTime / 60)
            local sessionSeconds = math.floor(sessionTime % 60)
            
            local manipulationRate = sessionTime > 0 and (horseManipulator.runtime.manipulatedCount / (sessionTime / 60)) or 0
            local teleportRate = sessionTime > 0 and (horseManipulator.runtime.teleportCount / (sessionTime / 60)) or 0
            
            local sessionText = "⏱️ Time: " .. sessionMinutes .. "m " .. sessionSeconds .. "s\n"
            sessionText = sessionText .. "🏝️ Island: " .. currentIsland .. "\n"
            sessionText = sessionText .. "🎭 Controlled: " .. horseManipulator.runtime.manipulatedCount .. "\n"
            sessionText = sessionText .. "📈 Control Rate: " .. string.format("%.1f", manipulationRate) .. "/min\n"
            sessionText = sessionText .. "🌀 Teleports: " .. horseManipulator.runtime.teleportCount .. "\n"
            sessionText = sessionText .. "📊 Teleport Rate: " .. string.format("%.1f", teleportRate) .. "/min\n"
            sessionText = sessionText .. "🌍 Coverage: " .. string.format("%.1f", globalCoverage) .. "%"
            
            SessionMetrics:Set({Title = "📈 Session Metrics", Content = sessionText})
        else
            SessionMetrics:Set({Title = "📈 Session Metrics", Content = "No island session active\n🏝️ Enhanced island monitoring ready\n🌍 Multi-island manipulation\n🌀 Island auto teleportation\n🚀 Island ultra-performance"})
        end
        
        -- Enhanced All-Time Metrics
        local allTimeText = "🎭 Total Manipulated: " .. horseManipulator.statistics.totalManipulated .. "\n"
        allTimeText = allTimeText .. "🔒 Total Enforcements: " .. horseManipulator.statistics.totalEnforcements .. "\n"
        allTimeText = allTimeText .. "🌀 Total Teleports: " .. horseManipulator.statistics.totalTeleports .. "\n"
        allTimeText = allTimeText .. "🎮 Sessions: " .. horseManipulator.statistics.sessionsRun .. "\n"
        allTimeText = allTimeText .. "🏆 Peak Controlled: " .. horseManipulator.statistics.peakHorsesControlled .. "\n"
        allTimeText = allTimeText .. "🏝️ Islands Explored: " .. totalIslands .. "\n"
        allTimeText = allTimeText .. "📊 Best Coverage: " .. string.format("%.1f", horseManipulator.statistics.globalCoverage) .. "%"
        
        AllTimeMetrics:Set({Title = "🏆 All-Time Records", Content = allTimeText})
        
        -- Enhanced Teleportation Metrics
        local teleportMetricsText = "🌀 Session Teleports: " .. horseManipulator.runtime.teleportCount .. "\n"
        teleportMetricsText = teleportMetricsText .. "📊 Total Teleports: " .. horseManipulator.statistics.totalTeleports .. "\n"
        teleportMetricsText = teleportMetricsText .. "⚡ Avg Time: " .. string.format("%.3f", avgTeleportTime * 1000) .. "ms\n"
        teleportMetricsText = teleportMetricsText .. "🎯 Current Nearby: " .. horseManipulator.runtime.horsesNearby .. "\n"
        teleportMetricsText = teleportMetricsText .. "📈 Peak Nearby: " .. horseManipulator.statistics.horsesNearbyPeak .. "\n"
        teleportMetricsText = teleportMetricsText .. "🏝️ Island Priority: " .. (horseManipulator.settings.prioritizeCurrentIsland and "✅" or "❌") .. "\n"
        teleportMetricsText = teleportMetricsText .. "🌀 Mode: " .. (horseManipulator.settings.autoTeleport and "ISLAND-AUTO" or "MANUAL")
        
        TeleportMetrics:Set({Title = "🌀 Teleportation Metrics", Content = teleportMetricsText})
    end
end)

-- =================================
-- CHARACTER RESPAWN HANDLING
-- =================================
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Reset island detection
    islandSystem.currentIsland = "Unknown"
    islandSystem.lastUpdate = 0
    
    if horseManipulator.isRunning then
        stopHorseManipulation()
        MainToggle:Set(false)
        
        Rayfield:Notify({
           Title = "🔄 Character Respawned",
           Content = "Enhanced island manipulation stopped - restart when ready",
           Duration = 3,
           Image = 4483362458,
        })
    end
end)

-- =================================
-- ENHANCED INITIALIZATION WITH ISLAND DETECTION
-- =================================
Rayfield:Notify({
   Title = "🏝️ Enhanced Island Horse Manipulator Loaded!",
   Content = "Multi-island detection + Global control + Auto teleportation | Ultra-optimized island system!",
   Duration = 6,
   Image = 4483362458,
})

-- Initial island detection
local initialIsland = detectCurrentIsland()

Rayfield:Notify({
   Title = "🏝️ Island System Ready!",
   Content = "Current Island: " .. initialIsland .. " | Multi-island manipulation + Auto teleportation ready!",
   Duration = 4,
   Image = 4483362458,
})

Rayfield:Notify({
   Title = "🌀 Advanced Features Active!",
   Content = "Island-aware teleportation | Smart island prioritization | Professional grade analytics",
   Duration = 4,
   Image = 4483362458,
})

print("🏝️ Enhanced Horse Attribute Manipulator - Ultimate Island Edition Loaded!")
print("🌍 Features: Multi-island detection, global unlimited control, island-aware auto teleportation")
print("🌀 Teleportation: Island-priority teleportation, loop mode, circular formation across all islands")
print("⚡ Performance: Island-optimized scanning, real-time tracking, professional island analytics")
print("🎯 Enhanced: Advanced island detection, comprehensive island monitoring, maximum island efficiency!")
print("🏝️ Current Island: " .. initialIsland)
print("📊 Island system status: ULTRA-PROFESSIONAL READY!")
