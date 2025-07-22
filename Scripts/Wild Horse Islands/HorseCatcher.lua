-- Horse Catcher Pro - Advanced Scanning Edition
-- by Iyxo - 2025-07-22 22:20:28
-- Revolutionary horse catching with intelligent scanning and auto-detection

local parentTab, Rayfield, Window = ...

-- =================================
-- SERVICES & OPTIMIZATION
-- =================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- =================================
-- ENHANCED ISLAND DETECTION & BOUNDS SYSTEM
-- =================================
local islandSystem = {
    currentIsland = "Unknown",
    lastUpdate = 0,
    updateInterval = 3,
    availableIslands = {},
    islandHorseCount = {},
    
    -- Auto-detected island bounds
    islandBounds = {
        ["Mainland"] = {
            corner1 = Vector3.new(-992.5, 6.8, -951.3),
            corner2 = Vector3.new(1084.9, 6.7, 861.8)
        },
        -- More islands will be auto-detected or manually added
    }
}

local function detectCurrentIsland()
    local currentTime = tick()
    if currentTime - islandSystem.lastUpdate < islandSystem.updateInterval then
        return islandSystem.currentIsland
    end
    
    -- Method 1: Player attribute (most reliable)
    local islandAttribute = player:GetAttribute("island")
    if islandAttribute and islandAttribute ~= "" then
        islandSystem.currentIsland = islandAttribute
        islandSystem.lastUpdate = currentTime
        return islandAttribute
    end
    
    -- Method 2: Character parent check
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
    
    -- Method 3: Distance-based detection
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

-- Auto-detect island bounds
local function autoDetectIslandBounds(islandName)
    if islandSystem.islandBounds[islandName] then
        return islandSystem.islandBounds[islandName]
    end
    
    -- Try to auto-detect bounds
    pcall(function()
        if Workspace.Islands:FindFirstChild(islandName) then
            local island = Workspace.Islands[islandName]
            if island:FindFirstChild("Terrain") then
                local terrain = island.Terrain
                local minPoint, maxPoint = terrain:ReadVoxels(terrain.MaxExtents.Min, terrain.MaxExtents.Max)
                
                -- Create bounds with some padding
                local padding = 200
                islandSystem.islandBounds[islandName] = {
                    corner1 = Vector3.new(minPoint.X - padding, minPoint.Y, minPoint.Z - padding),
                    corner2 = Vector3.new(maxPoint.X + padding, maxPoint.Y + 200, maxPoint.Z + padding)
                }
            else
                -- Fallback: use model bounds
                local cf, size = island:GetBoundingBox()
                local padding = 300
                islandSystem.islandBounds[islandName] = {
                    corner1 = cf.Position - size/2 - Vector3.new(padding, 0, padding),
                    corner2 = cf.Position + size/2 + Vector3.new(padding, 200, padding)
                }
            end
        end
    end)
    
    return islandSystem.islandBounds[islandName]
end

-- =================================
-- ADVANCED SCANNING SYSTEM
-- =================================
local scanningSystem = {
    isScanning = false,
    scanMode = "random", -- "random" or "terrain"
    scanSpeed = 500, -- milliseconds between scans
    autoScan = true,
    stopOnHorseFound = true,
    
    -- Horse location database
    knownHorseLocations = {},
    scannedPositions = {},
    
    connections = {},
    
    settings = {
        scanPointsPerCycle = 8,
        landOnly = true,
        smartDistribution = true,
        maxKnownLocations = 100,
        locationExpireTime = 600 -- 10 minutes
    }
}

-- Check if position is on land
local function isOnLand(position)
    if not scanningSystem.settings.landOnly then return true end
    
    local success, result = pcall(function()
        local raycast = workspace:Raycast(position + Vector3.new(0, 10, 0), Vector3.new(0, -50, 0))
        
        if raycast and raycast.Instance then
            if raycast.Instance:IsA("Terrain") then
                local material = raycast.Material
                local landMaterials = {
                    Enum.Material.Grass, Enum.Material.Ground, Enum.Material.Rock,
                    Enum.Material.Sand, Enum.Material.Snow, Enum.Material.Mud,
                    Enum.Material.LeafyGrass, Enum.Material.Concrete, Enum.Material.Brick,
                    Enum.Material.Cobblestone
                }
                
                for _, landMat in pairs(landMaterials) do
                    if material == landMat then return true end
                end
                
                return material ~= Enum.Material.Water
            else
                return true
            end
        end
        return false
    end)
    
    return success and result
end

-- Generate smart scan points
local function generateScanPoints(islandName, count)
    local bounds = autoDetectIslandBounds(islandName)
    if not bounds then return {} end
    
    local points = {}
    local minX = math.min(bounds.corner1.X, bounds.corner2.X)
    local maxX = math.max(bounds.corner1.X, bounds.corner2.X)
    local minZ = math.min(bounds.corner1.Z, bounds.corner2.Z)
    local maxZ = math.max(bounds.corner1.Z, bounds.corner2.Z)
    local avgY = (bounds.corner1.Y + bounds.corner2.Y) / 2
    
    if scanningSystem.scanMode == "terrain" and scanningSystem.settings.smartDistribution then
        -- Smart grid distribution
        local gridSize = math.ceil(math.sqrt(count))
        local stepX = (maxX - minX) / gridSize
        local stepZ = (maxZ - minZ) / gridSize
        
        for i = 0, gridSize - 1 do
            for j = 0, gridSize - 1 do
                if #points >= count then break end
                
                local baseX = minX + (i + 0.5) * stepX
                local baseZ = minZ + (j + 0.5) * stepZ
                local randomX = baseX + (math.random() - 0.5) * stepX * 0.5
                local randomZ = baseZ + (math.random() - 0.5) * stepZ * 0.5
                local randomY = avgY + math.random(-50, 150)
                
                local point = Vector3.new(randomX, randomY, randomZ)
                
                -- Check if on land
                if scanningSystem.settings.landOnly then
                    local attempts = 0
                    while not isOnLand(point) and attempts < 5 do
                        randomX = baseX + (math.random() - 0.5) * stepX
                        randomZ = baseZ + (math.random() - 0.5) * stepZ
                        point = Vector3.new(randomX, randomY, randomZ)
                        attempts = attempts + 1
                    end
                end
                
                table.insert(points, point)
            end
        end
    else
        -- Random distribution (includes known horse locations)
        local knownLocations = {}
        for id, data in pairs(scanningSystem.knownHorseLocations) do
            if tick() - data.lastSeen < scanningSystem.settings.locationExpireTime then
                table.insert(knownLocations, data.position)
            else
                scanningSystem.knownHorseLocations[id] = nil
            end
        end
        
        -- Add known locations first (up to 50% of scan points)
        local maxKnownPoints = math.floor(count * 0.5)
        for i = 1, math.min(#knownLocations, maxKnownPoints) do
            local pos = knownLocations[i]
            local nearbyPos = pos + Vector3.new(
                math.random(-100, 100),
                math.random(-20, 50),
                math.random(-100, 100)
            )
            table.insert(points, nearbyPos)
        end
        
        -- Fill remaining with random points
        for i = #points + 1, count do
            local attempts = 0
            local point
            
            repeat
                local randomX = minX + (maxX - minX) * math.random()
                local randomZ = minZ + (maxZ - minZ) * math.random()
                local randomY = avgY + math.random(-50, 150)
                point = Vector3.new(randomX, randomY, randomZ)
                attempts = attempts + 1
            until not scanningSystem.settings.landOnly or isOnLand(point) or attempts > 10
            
            table.insert(points, point)
        end
    end
    
    return points
end

-- Scan for horses at position
local function scanHorsesAtPosition(position, islandName)
    local foundHorses = {}
    
    pcall(function()
        local island = Workspace.Islands:FindFirstChild(islandName)
        if not island then return end
        
        for _, child in pairs(island:GetChildren()) do
            if child.Name:find("{") and child:FindFirstChild("HumanoidRootPart") then
                local distance = (position - child.HumanoidRootPart.Position).Magnitude
                
                if distance <= 512 then -- Within streaming range
                    local humanoid = child:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health > 0 and not Players:GetPlayerFromCharacter(child) then
                        -- Check if wild horse
                        local isWild = false
                        pcall(function()
                            local overhead = child:FindFirstChild("OverheadPart")
                            if overhead and overhead:FindFirstChild("Overhead") then
                                local nameLabel = overhead.Overhead:FindFirstChild("NameLabel")
                                if nameLabel and nameLabel.Text == "Wild" then
                                    isWild = true
                                end
                            end
                        end)
                        
                        if isWild then
                            local horseName = "Unknown"
                            pcall(function()
                                local breedLabel = child.OverheadPart.Overhead:FindFirstChild("BreedLabel")
                                if breedLabel and breedLabel.Text ~= "" then
                                    horseName = breedLabel.Text
                                else
                                    horseName = child.Name:sub(2, 9) .. "..."
                                end
                            end)
                            
                            foundHorses[child.Name] = {
                                object = child,
                                name = horseName,
                                position = child.HumanoidRootPart.Position,
                                distance = distance,
                                scanPoint = position,
                                timestamp = tick()
                            }
                            
                            -- Add to known locations
                            scanningSystem.knownHorseLocations[child.Name] = {
                                position = child.HumanoidRootPart.Position,
                                lastSeen = tick(),
                                name = horseName
                            }
                        end
                    end
                end
            end
        end
    end)
    
    return foundHorses
end

-- Start scanning process
local function startScanning()
    if scanningSystem.isScanning then return end
    
    scanningSystem.isScanning = true
    local currentIsland = detectCurrentIsland()
    
    spawn(function()
        while scanningSystem.isScanning and scanningSystem.autoScan do
            -- Check if horse catcher is running and has no target
            if horseCatcher.isRunning and not horseCatcher.currentTarget then
                local originalPos = humanoidRootPart.CFrame
                local scanPoints = generateScanPoints(currentIsland, scanningSystem.settings.scanPointsPerCycle)
                local foundAnyHorse = false
                
                for _, point in ipairs(scanPoints) do
                    if not scanningSystem.isScanning then break end
                    
                    -- Teleport to scan point
                    humanoidRootPart.CFrame = CFrame.new(point)
                    wait(scanningSystem.scanSpeed / 1000)
                    
                    -- Scan for horses
                    local foundHorses = scanHorsesAtPosition(point, currentIsland)
                    
                    if next(foundHorses) then
                        foundAnyHorse = true
                        
                        if scanningSystem.stopOnHorseFound then
                            -- Stay near the horse for the catcher to pick it up
                            break
                        end
                    end
                    
                    table.insert(scanningSystem.scannedPositions, {
                        position = point,
                        timestamp = tick(),
                        horsesFound = table.getn(foundHorses)
                    })
                end
                
                -- Return to original position if no horses found
                if not foundAnyHorse then
                    humanoidRootPart.CFrame = originalPos
                end
            end
            
            wait(2) -- Wait before next scan cycle
        end
    end)
end

-- Stop scanning
local function stopScanning()
    scanningSystem.isScanning = false
end

-- =================================
-- CAPTURE PROGRESS SYSTEM
-- =================================
local captureProgressSystem = {
    trackedHorses = {},
    lastUpdate = 0,
    updateInterval = 0.5,
    maxTracked = 100
}

local function getCaptureProgress(horse)
    if not horse or not horse.Parent then return nil end
    
    local progressData = {
        current = 0,
        max = 0,
        text = "0/0",
        isComplete = false,
        exists = false
    }
    
    pcall(function()
        local captureProgress = horse:FindFirstChild("CaptureProgress")
        if captureProgress then
            local progress = captureProgress:FindFirstChild("Progress")
            if progress then
                local textLabel = progress:FindFirstChild("TextLabel")
                if textLabel and textLabel.Text then
                    progressData.exists = true
                    progressData.text = textLabel.Text
                    
                    local current, max = progressData.text:match("(%d+)/(%d+)")
                    if current and max then
                        progressData.current = tonumber(current)
                        progressData.max = tonumber(max)
                        progressData.isComplete = (progressData.current >= progressData.max and progressData.max > 0)
                    end
                end
            end
        end
    end)
    
    return progressData
end

-- =================================
-- NOCLIP SYSTEM FOR SMOOTH MODE
-- =================================
local noclipSystem = {
    active = false,
    originalCanCollide = {},
    connections = {}
}

local function enableNoclip()
    if noclipSystem.active then return end
    
    noclipSystem.active = true
    
    local function setNoclip(object)
        if object:IsA("BasePart") and object.CanCollide then
            noclipSystem.originalCanCollide[object] = true
            object.CanCollide = false
        end
    end
    
    pcall(function()
        for _, part in pairs(character:GetChildren()) do
            setNoclip(part)
        end
    end)
    
    noclipSystem.connections.childAdded = character.ChildAdded:Connect(function(child)
        if noclipSystem.active then
            wait(0.1)
            setNoclip(child)
        end
    end)
end

local function disableNoclip()
    if not noclipSystem.active then return end
    
    noclipSystem.active = false
    
    pcall(function()
        for part, _ in pairs(noclipSystem.originalCanCollide) do
            if part and part.Parent then
                part.CanCollide = true
            end
        end
    end)
    
    noclipSystem.originalCanCollide = {}
    
    if noclipSystem.connections.childAdded then
        noclipSystem.connections.childAdded:Disconnect()
        noclipSystem.connections.childAdded = nil
    end
end

-- =================================
-- CACHING SYSTEM
-- =================================
local Cache = {
    horses = {},
    horsesById = {},
    lastUpdate = 0,
    updateInterval = 1.5,
    maxCacheSize = 500,
    islandHorses = {}
}

-- =================================
-- HORSE CATCHER SYSTEM
-- =================================
local horseCatcher = {
    isRunning = false,
    currentTarget = nil,
    currentTargetProgress = nil,
    isAttached = false,
    lassoEquipped = false,
    currentLassoID = nil,
    
    connections = {
        capture = nil,
        targeting = nil,
        movement = nil,
        cleanup = nil,
        islandMonitor = nil,
        progressMonitor = nil,
        lassoProtection = nil
    },
    
    capturedHorses = {},
    statistics = {
        totalCaptured = 0,
        sessionsRun = 0,
        currentStreak = 0,
        totalAttempts = 0,
        successfulCaptures = 0,
        bestStreak = 0,
        averageCaptureTime = 0,
        horsesPerMinute = 0,
        islandStats = {},
        progressStats = {
            totalProgressHits = 0,
            averageProgressToCapture = 0,
            fastestCapture = 999,
            slowestCapture = 0
        }
    },
    
    settings = {
        movementMode = "attachment",
        pulseInterval = 0.8,
        pulseDistance = 8,
        captureCooldown = 0.4,
        smartTargeting = true,
        aggressiveTargeting = true,
        
        progressMonitoring = true,
        abandonOnStuckProgress = true,
        maxStuckProgressTime = 15,
        
        safeDistance = 5,
        attachmentOffset = 4,
        targetingRadius = 300,
        batchProcessing = true,
        maxBatchSize = 5
    },
    
    runtime = {
        lastCaptureTime = 0,
        lastPulseTime = 0,
        lastTargetingTime = 0,
        lastCleanupTime = 0,
        lastIslandCheck = 0,
        lastProgressCheck = 0,
        lastLassoCheck = 0,
        
        currentTargetStartTime = 0,
        lastProgressChange = 0,
        lastProgressValue = "0/0",
        progressStuckTime = 0,
        
        sessionStartTime = 0,
        lastSuccessfulCapture = 0,
        forceDetach = false,
        targetingCount = 0,
        captureAttempts = 0,
        currentIslandHorses = 0
    }
}

-- Game System Detection
local gameSystem = {
    u1 = nil,
    u2 = nil, 
    u3 = nil,
    available = false,
    remoteEvent = nil,
    networkReady = false
}

pcall(function()
    gameSystem.u1 = require(ReplicatedStorage.References)
    gameSystem.u2 = gameSystem.u1.Utilities
    gameSystem.u3 = require(gameSystem.u1.PlayerScripts.Priority.Data)
    gameSystem.available = true
    gameSystem.networkReady = (gameSystem.u2 and gameSystem.u2.Network) and true or false
    gameSystem.remoteEvent = ReplicatedStorage.Communication.Events['']
end)

-- =================================
-- HORSE FUNCTIONS
-- =================================

local function getHorseName(horse)
    if not horse then return "Unknown" end
    
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
                    horseName = horse.Name:sub(2, 9)
                end
            end
        end
    end)
    
    if success then
        Cache.horsesById[horse.Name] = Cache.horsesById[horse.Name] or {}
        Cache.horsesById[horse.Name].name = horseName
    end
    
    return horseName
end

local function isWildHorse(horse)
    if not horse then return false end
    
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
    
    if success then
        Cache.horsesById[horse.Name] = Cache.horsesById[horse.Name] or {}
        Cache.horsesById[horse.Name].isWild = isWild
    end
    
    return isWild
end

-- Enhanced horse cache with scanning integration
local function updateHorseCache()
    local currentTime = tick()
    if currentTime - Cache.lastUpdate < Cache.updateInterval then
        return Cache.horses
    end
    
    local startTime = tick()
    Cache.horses = {}
    Cache.islandHorses = {}
    local horseCount = 0
    local currentIsland = detectCurrentIsland()
    
    local function scanLocation(location, islandName, priority)
        if not location then return end
        
        local children = location:GetChildren()
        local localHorseCount = 0
        
        for i = 1, #children do
            local child = children[i]
            
            if child.Name:find("{") and child:FindFirstChild("HumanoidRootPart") then
                local humanoid = child:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 and not Players:GetPlayerFromCharacter(child) then
                    if isWildHorse(child) and not horseCatcher.capturedHorses[child.Name] then
                        local distance = (humanoidRootPart.Position - child.HumanoidRootPart.Position).Magnitude
                        
                        horseCount = horseCount + 1
                        localHorseCount = localHorseCount + 1
                        
                        Cache.horses[horseCount] = {
                            horse = child,
                            island = islandName,
                            priority = priority,
                            distance = distance
                        }
                        
                        if horseCount >= Cache.maxCacheSize then
                            break
                        end
                    end
                end
            end
        end
        
        Cache.islandHorses[islandName] = localHorseCount
    end
    
    -- Enhanced scanning with known horse locations
    pcall(function()
        if Workspace.Islands then
            local currentIslandPriority = 1
            
            for _, island in pairs(Workspace.Islands:GetChildren()) do
                if island:IsA("Model") and island.Name ~= "Islands" then
                    local priority = (island.Name == currentIsland) and currentIslandPriority or 2
                    scanLocation(island, island.Name, priority)
                end
            end
            
            if Workspace.Islands:FindFirstChild("Mainland") then
                local priority = (currentIsland == "Mainland") and currentIslandPriority or 2
                scanLocation(Workspace.Islands.Mainland, "Mainland", priority)
            end
        end
    end)
    
    -- Add horses from known locations (if not found in regular scan)
    for id, data in pairs(scanningSystem.knownHorseLocations) do
        if tick() - data.lastSeen < 60 then -- Only recent locations
            local found = false
            for _, cached in pairs(Cache.horses) do
                if cached.horse and cached.horse.Name == id then
                    found = true
                    break
                end
            end
            
            if not found then
                horseCount = horseCount + 1
                Cache.horses[horseCount] = {
                    horse = nil, -- Virtual horse
                    island = currentIsland .. " (Known)",
                    priority = 4, -- Lower priority
                    distance = (humanoidRootPart.Position - data.position).Magnitude,
                    knownLocation = data.position,
                    virtualHorse = true
                }
            end
        end
    end
    
    table.sort(Cache.horses, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        else
            return a.distance < b.distance
        end
    end)
    
    Cache.lastUpdate = currentTime
    horseCatcher.runtime.targetingCount = horseCatcher.runtime.targetingCount + 1
    horseCatcher.runtime.currentIslandHorses = Cache.islandHorses[currentIsland] or 0
    
    return Cache.horses
end

-- Auto-equip and protect lasso system
local function equipLasso()
    if horseCatcher.lassoEquipped and horseCatcher.currentLassoID then
        return true, horseCatcher.currentLassoID
    end
    
    local success = false
    local toolID = nil
    
    if gameSystem.available and gameSystem.u3 and gameSystem.networkReady then
        local lastEquipped = gameSystem.u3.GetLocal({"lastEquippedLasso"})
        if lastEquipped then
            local inventoryItem = gameSystem.u3.GetLocal({"inventory", lastEquipped})
            if inventoryItem then
                pcall(function()
                    local currentlyEquipped = gameSystem.u3.GetLocal({"temporary", "equippedEquipment"})
                    if currentlyEquipped ~= lastEquipped then
                        gameSystem.u2.Network:FireServer("Inventory", "Use", lastEquipped)
                    end
                    success = true
                    toolID = lastEquipped
                end)
            end
        else
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
    end
    
    if not success then
        toolID = "{60769f1f-cade-463b-ae32-adaacc91116f}"
        success = true
    end
    
    if success then
        horseCatcher.lassoEquipped = true
        horseCatcher.currentLassoID = toolID
    end
    
    return success, toolID
end

local function protectLasso()
    if not horseCatcher.isRunning then return end
    
    local currentTime = tick()
    if currentTime - horseCatcher.runtime.lastLassoCheck < 1 then return end
    
    horseCatcher.runtime.lastLassoCheck = currentTime
    
    pcall(function()
        if gameSystem.available and gameSystem.u3 and gameSystem.networkReady then
            local currentlyEquipped = gameSystem.u3.GetLocal({"temporary", "equippedEquipment"})
            
            if not currentlyEquipped or currentlyEquipped ~= horseCatcher.currentLassoID then
                if horseCatcher.currentLassoID then
                    local inventoryItem = gameSystem.u3.GetLocal({"inventory", horseCatcher.currentLassoID})
                    if inventoryItem then
                        gameSystem.u2.Network:FireServer("Inventory", "Use", horseCatcher.currentLassoID)
                    else
                        equipLasso()
                    end
                end
            end
        end
    end)
end

local function findOptimalTarget()
    local horses = updateHorseCache()
    if #horses == 0 then return nil end
    
    local playerPos = humanoidRootPart.Position
    local currentIsland = detectCurrentIsland()
    local candidates = {}
    
    for i = 1, math.min(#horses, horseCatcher.settings.maxBatchSize * 2) do
        local horseData = horses[i]
        if horseData then
            local horse = horseData.horse
            local distance = horseData.distance
            
            -- Handle virtual horses (known locations)
            if horseData.virtualHorse and horseData.knownLocation then
                -- Teleport near known location to load the horse
                humanoidRootPart.CFrame = CFrame.new(horseData.knownLocation + Vector3.new(0, 50, 0))
                wait(0.5)
                
                -- Try to find the actual horse after teleporting
                horse = nil
                pcall(function()
                    local island = Workspace.Islands:FindFirstChild(currentIsland)
                    if island then
                        for _, child in pairs(island:GetChildren()) do
                            if child.Name:find("{") and child:FindFirstChild("HumanoidRootPart") then
                                local dist = (horseData.knownLocation - child.HumanoidRootPart.Position).Magnitude
                                if dist < 100 and isWildHorse(child) then
                                    horse = child
                                    break
                                end
                            end
                        end
                    end
                end)
                
                if not horse then continue end
            end
            
            if horse and horse:FindFirstChild("HumanoidRootPart") then
                local horsePos = horse.HumanoidRootPart.Position
                distance = (playerPos - horsePos).Magnitude
                local velocity = horse.HumanoidRootPart.Velocity.Magnitude
                
                if distance > horseCatcher.settings.targetingRadius then
                    continue
                end
                
                local score = 1000
                
                if horseData.island == currentIsland then
                    score = score + 500
                elseif horseData.priority == 1 then
                    score = score + 200
                end
                
                if distance < 50 then
                    score = score + 300
                elseif distance < 100 then
                    score = score + 200
                elseif distance < 200 then
                    score = score + 100
                else
                    score = score - (distance * 0.5)
                end
                
                if velocity > 5 then
                    score = score + 400
                elseif velocity > 2 then
                    score = score + 200
                elseif velocity > 0.5 then
                    score = score + 100
                else
                    score = score - 100
                end
                
                local heightDiff = math.abs(horsePos.Y - playerPos.Y)
                if heightDiff < 10 then
                    score = score + 150
                elseif heightDiff < 25 then
                    score = score + 50
                else
                    score = score - (heightDiff * 2)
                end
                
                table.insert(candidates, {
                    horse = horse,
                    score = score,
                    distance = distance,
                    velocity = velocity,
                    island = horseData.island,
                    priority = horseData.priority
                })
            end
        end
    end
    
    if #candidates > 0 then
        table.sort(candidates, function(a, b) return a.score > b.score end)
        return candidates[1].horse
    end
    
    return nil
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
        horseCatcher.runtime.captureAttempts = horseCatcher.runtime.captureAttempts + 1
        horseCatcher.statistics.totalAttempts = horseCatcher.statistics.totalAttempts + 1
    end)
    
    return success
end

-- Movement functions
local function pulseTeleportToHorse(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") then return false end
    
    local currentTime = tick()
    if currentTime - horseCatcher.runtime.lastPulseTime < horseCatcher.settings.pulseInterval then
        return false
    end
    
    pcall(function()
        local horseRoot = horse.HumanoidRootPart
        local horsePos = horseRoot.Position
        local horseVelocity = horseRoot.Velocity
        
        local prediction = horsePos + (horseVelocity * 0.4)
        
        local approaches = {
            horseRoot.CFrame.RightVector * horseCatcher.settings.pulseDistance,
            horseRoot.CFrame.RightVector * -horseCatcher.settings.pulseDistance,
            horseRoot.CFrame.LookVector * -horseCatcher.settings.pulseDistance,
            (horseRoot.CFrame.RightVector + horseRoot.CFrame.LookVector).Unit * horseCatcher.settings.pulseDistance
        }
        
        local bestOffset = approaches[1]
        local shortestDist = math.huge
        local playerPos = humanoidRootPart.Position
        
        for _, offset in pairs(approaches) do
            local targetPos = prediction + offset
            local dist = (playerPos - targetPos).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                bestOffset = offset
            end
        end
        
        local heightOffset = Vector3.new(0, 3, 0)
        local finalPos = prediction + bestOffset + heightOffset
        
        humanoidRootPart.CFrame = CFrame.lookAt(finalPos, horsePos)
        horseCatcher.runtime.lastPulseTime = currentTime
    end)
    
    return true
end

local function attachToHorse(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") then return false end
    
    pcall(function()
        for _, attachment in pairs(humanoidRootPart:GetChildren()) do
            if (attachment.Name == "HorseAttachment" or attachment.Name:find("Weld")) and attachment:IsA("WeldConstraint") then
                attachment:Destroy()
            end
        end
        
        local horseRoot = horse.HumanoidRootPart
        local horsePos = horseRoot.Position
        local horseVelocity = horseRoot.Velocity
        
        local prediction = horsePos + (horseVelocity * 0.2)
        local sideOffset = horseRoot.CFrame.RightVector * horseCatcher.settings.attachmentOffset
        local heightOffset = Vector3.new(0, 3.5, 0)
        
        humanoidRootPart.CFrame = CFrame.lookAt(prediction + sideOffset + heightOffset, prediction)
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

local function smoothFollow(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") then return false end
    
    pcall(function()
        local horsePos = horse.HumanoidRootPart.Position
        local horseVelocity = horse.HumanoidRootPart.Velocity
        local currentPos = humanoidRootPart.Position
        
        local prediction = horsePos + (horseVelocity * 0.3)
        local direction = (prediction - currentPos).Unit
        local distance = (prediction - currentPos).Magnitude
        
        if distance > horseCatcher.settings.safeDistance + 1 then
            local targetPos = prediction - direction * horseCatcher.settings.safeDistance
            targetPos = targetPos + Vector3.new(0, 2.5, 0)
            
            local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.lookAt(targetPos, prediction)})
            tween:Play()
        end
    end)
    
    return true
end

local function detachFromHorse()
    pcall(function()
        for _, attachment in pairs(humanoidRootPart:GetChildren()) do
            if (attachment.Name == "HorseAttachment" or attachment.Name:find("Weld")) then
                if attachment:IsA("WeldConstraint") or attachment:IsA("Weld") then
                    attachment:Destroy()
                end
            end
        end
        horseCatcher.isAttached = false
        horseCatcher.runtime.forceDetach = false
    end)
end

local function isHorseCapturedOrComplete(horse)
    if not horse or not horse.Parent then
        return true, "Horse disappeared"
    end
    
    local captured = false
    local horseName = "Unknown"
    local reason = ""
    
    pcall(function()
        local progressData = getCaptureProgress(horse)
        if progressData.exists and progressData.isComplete then
            captured = true
            reason = "Progress complete (" .. progressData.text .. ")"
        end
        
        if not captured then
            local overheadPart = horse:FindFirstChild("OverheadPart")
            if overheadPart then
                local overhead = overheadPart:FindFirstChild("Overhead")
                if overhead then
                    local nameLabel = overhead:FindFirstChild("NameLabel")
                    if nameLabel and nameLabel.Text ~= "Wild" then
                        captured = true
                        reason = "Name changed from Wild"
                    end
                    
                    local breedLabel = overhead:FindFirstChild("BreedLabel")
                    if breedLabel and breedLabel.Text ~= "" then
                        horseName = breedLabel.Text
                    end
                end
            end
        end
        
        if not captured then
            local humanoid = horse:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then
                captured = true
                reason = "Horse died/removed"
            end
        end
    end)
    
    if captured then
        horseCatcher.capturedHorses[horse.Name] = true
        horseCatcher.statistics.totalCaptured = horseCatcher.statistics.totalCaptured + 1
        horseCatcher.statistics.currentStreak = horseCatcher.statistics.currentStreak + 1
        horseCatcher.statistics.successfulCaptures = horseCatcher.statistics.successfulCaptures + 1
        horseCatcher.runtime.lastSuccessfulCapture = tick()
        
        local captureTime = tick() - horseCatcher.runtime.currentTargetStartTime
        if captureTime < horseCatcher.statistics.progressStats.fastestCapture then
            horseCatcher.statistics.progressStats.fastestCapture = captureTime
        end
        if captureTime > horseCatcher.statistics.progressStats.slowestCapture then
            horseCatcher.statistics.progressStats.slowestCapture = captureTime
        end
        
        local currentIsland = detectCurrentIsland()
        if not horseCatcher.statistics.islandStats[currentIsland] then
            horseCatcher.statistics.islandStats[currentIsland] = 0
        end
        horseCatcher.statistics.islandStats[currentIsland] = horseCatcher.statistics.islandStats[currentIsland] + 1
        
        if horseCatcher.statistics.currentStreak > horseCatcher.statistics.bestStreak then
            horseCatcher.statistics.bestStreak = horseCatcher.statistics.currentStreak
        end
        
        local sessionTime = tick() - horseCatcher.runtime.sessionStartTime
        horseCatcher.statistics.horsesPerMinute = (horseCatcher.statistics.currentStreak / (sessionTime / 60))
        
        Rayfield:Notify({
           Title = "🎉 " .. horseName .. " Captured!",
           Content = "Island: " .. currentIsland .. " | Reason: " .. reason .. " | Time: " .. string.format("%.1f", captureTime) .. "s | Streak: " .. horseCatcher.statistics.currentStreak,
           Duration = 3,
           Image = 4483362458,
        })
        
        -- Resume scanning if auto-scan is enabled
        if scanningSystem.autoScan and not scanningSystem.isScanning then
            startScanning()
        end
    end
    
    return captured, reason
end

-- =================================
-- MAIN LOGIC
-- =================================
local function startHorseCatching()
    if horseCatcher.isRunning then return false end
    
    local lassoReady, lassoID = equipLasso()
    if not lassoReady then
        Rayfield:Notify({
           Title = "❌ Lasso Required!",
           Content = "No lasso found in inventory!",
           Duration = 4,
           Image = 4483362458,
        })
        return false
    end
    
    if not gameSystem.available or not gameSystem.networkReady then
        Rayfield:Notify({
           Title = "❌ Network System Error!",
           Content = "Cannot access game network system!",
           Duration = 4,
           Image = 4483362458,
        })
        return false
    end
    
    horseCatcher.isRunning = true
    horseCatcher.runtime.sessionStartTime = tick()
    horseCatcher.statistics.sessionsRun = horseCatcher.statistics.sessionsRun + 1
    horseCatcher.statistics.currentStreak = 0
    
    -- Reset runtime variables
    horseCatcher.runtime.lastCaptureTime = 0
    horseCatcher.runtime.lastPulseTime = 0
    horseCatcher.runtime.targetingCount = 0
    horseCatcher.runtime.captureAttempts = 0
    horseCatcher.runtime.lastIslandCheck = 0
    horseCatcher.runtime.lastProgressCheck = 0
    horseCatcher.runtime.lastLassoCheck = 0
    horseCatcher.runtime.currentTargetStartTime = 0
    horseCatcher.runtime.lastProgressChange = 0
    horseCatcher.runtime.lastProgressValue = "0/0"
    horseCatcher.runtime.progressStuckTime = 0
    
    local movementMode = horseCatcher.settings.movementMode == "pulse" and "Pulse TP" or 
                        horseCatcher.settings.movementMode == "attachment" and "Attachment" or "Smooth"
    
    local currentIsland = detectCurrentIsland()
    
    if horseCatcher.settings.movementMode == "smooth" then
        enableNoclip()
    end
    
    -- Start auto-scanning
    if scanningSystem.autoScan then
        startScanning()
    end
    
    Rayfield:Notify({
       Title = "🚀 Ultra Horse Catching Started!",
       Content = "Island: " .. currentIsland .. " | Mode: " .. movementMode .. " | Auto-Scan: " .. (scanningSystem.autoScan and "ON" or "OFF"),
       Duration = 3,
       Image = 4483362458,
    })
    
    -- Island monitoring
    horseCatcher.connections.islandMonitor = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        
        local currentTime = tick()
        if currentTime - horseCatcher.runtime.lastIslandCheck < 5 then return end
        
        detectCurrentIsland()
        horseCatcher.runtime.lastIslandCheck = currentTime
    end)
    
    -- Lasso protection
    horseCatcher.connections.lassoProtection = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        protectLasso()
    end)
    
    -- Progress monitoring
    horseCatcher.connections.progressMonitor = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning or not horseCatcher.currentTarget then return end
        
        local currentTime = tick()
        if currentTime - horseCatcher.runtime.lastProgressCheck < 0.5 then return end
        
        local progressData = getCaptureProgress(horseCatcher.currentTarget)
        
        if progressData.exists then
            horseCatcher.currentTargetProgress = progressData
            
            if progressData.text ~= horseCatcher.runtime.lastProgressValue then
                horseCatcher.runtime.lastProgressChange = currentTime
                horseCatcher.runtime.lastProgressValue = progressData.text
                horseCatcher.runtime.progressStuckTime = 0
                
                horseCatcher.statistics.progressStats.totalProgressHits = horseCatcher.statistics.progressStats.totalProgressHits + 1
            else
                horseCatcher.runtime.progressStuckTime = currentTime - horseCatcher.runtime.lastProgressChange
            end
        end
        
        horseCatcher.runtime.lastProgressCheck = currentTime
    end)
    
    -- Main capture loop
    horseCatcher.connections.capture = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        
        -- Check if current target was captured
        if horseCatcher.currentTarget then
            local captured, reason = isHorseCapturedOrComplete(horseCatcher.currentTarget)
            if captured then
                if horseCatcher.settings.movementMode == "attachment" then
                    detachFromHorse()
                end
                horseCatcher.currentTarget = nil
                horseCatcher.currentTargetProgress = nil
                horseCatcher.runtime.currentTargetStartTime = 0
                horseCatcher.runtime.lastProgressChange = 0
                horseCatcher.runtime.lastProgressValue = "0/0"
                horseCatcher.runtime.progressStuckTime = 0
                return
            end
        end
        
        -- Check for stuck progress
        if horseCatcher.currentTarget and horseCatcher.settings.abandonOnStuckProgress then
            if horseCatcher.runtime.progressStuckTime > horseCatcher.settings.maxStuckProgressTime then
                Rayfield:Notify({
                   Title = "⏭️ Skipping Stuck Horse",
                   Content = "No progress for " .. math.floor(horseCatcher.runtime.progressStuckTime) .. "s - Moving to next target",
                   Duration = 2,
                   Image = 4483362458,
                })
                
                if horseCatcher.settings.movementMode == "attachment" then
                    detachFromHorse()
                end
                horseCatcher.currentTarget = nil
                horseCatcher.currentTargetProgress = nil
                horseCatcher.runtime.currentTargetStartTime = 0
                horseCatcher.runtime.lastProgressChange = 0
                horseCatcher.runtime.lastProgressValue = "0/0"
                horseCatcher.runtime.progressStuckTime = 0
                return
            end
        end
        
        -- Find new target
        if not horseCatcher.currentTarget then
            -- Stop scanning when we find a target
            if scanningSystem.isScanning and scanningSystem.stopOnHorseFound then
                stopScanning()
            end
            
            if horseCatcher.settings.smartTargeting then
                horseCatcher.currentTarget = findOptimalTarget()
            else
                local horses = updateHorseCache()
                horseCatcher.currentTarget = horses[1] and (horses[1].horse or horses[1])
            end
            
            if horseCatcher.currentTarget then
                horseCatcher.runtime.currentTargetStartTime = tick()
                horseCatcher.runtime.lastProgressChange = tick()
                horseCatcher.runtime.lastProgressValue = "0/0"
                horseCatcher.runtime.progressStuckTime = 0
                horseCatcher.currentTargetProgress = getCaptureProgress(horseCatcher.currentTarget)
            else
                if horseCatcher.settings.movementMode == "attachment" then
                    detachFromHorse()
                end
                
                -- Resume scanning if no horses found
                if scanningSystem.autoScan and not scanningSystem.isScanning then
                    startScanning()
                end
                return
            end
        end
        
        -- Execute movement and capture
        if horseCatcher.currentTarget then
            if horseCatcher.settings.movementMode == "pulse" then
                pulseTeleportToHorse(horseCatcher.currentTarget)
            elseif horseCatcher.settings.movementMode == "attachment" then
                if not horseCatcher.isAttached or horseCatcher.runtime.forceDetach then
                    attachToHorse(horseCatcher.currentTarget)
                end
            elseif horseCatcher.settings.movementMode == "smooth" then
                smoothFollow(horseCatcher.currentTarget)
            end
            
            captureHorse(horseCatcher.currentTarget)
        else
            if horseCatcher.settings.movementMode == "attachment" then
                detachFromHorse()
            end
        end
    end)
    
    return true
end

local function stopHorseCatching()
    horseCatcher.isRunning = false
    
    -- Stop scanning
    stopScanning()
    
    -- Disable noclip
    disableNoclip()
    
    for name, connection in pairs(horseCatcher.connections) do
        if connection then
            connection:Disconnect()
            horseCatcher.connections[name] = nil
        end
    end
    
    detachFromHorse()
    horseCatcher.currentTarget = nil
    horseCatcher.currentTargetProgress = nil
    
    local sessionTime = tick() - horseCatcher.runtime.sessionStartTime
    local minutes = math.floor(sessionTime / 60)
    local seconds = math.floor(sessionTime % 60)
    
    local currentIsland = detectCurrentIsland()
    
    Rayfield:Notify({
       Title = "🏁 Session Ended",
       Content = "Island: " .. currentIsland .. " | Captured: " .. horseCatcher.statistics.currentStreak .. " | Time: " .. minutes .. "m " .. seconds .. "s",
       Duration = 5,
       Image = 4483362458,
    })
    
    horseCatcher.statistics.currentStreak = 0
end

-- =================================
-- ENHANCED UI WITH SCANNING FEATURES
-- =================================

-- Scanning Control Section
local ScanningControlSection = parentTab:CreateSection("🔍 Advanced Scanning System")

local AutoScanToggle = parentTab:CreateToggle({
   Name = "🚀 AutoScan",
   CurrentValue = true,
   Flag = "AutoScanToggle",
   Callback = function(Value)
      scanningSystem.autoScan = Value
      if Value and horseCatcher.isRunning and not horseCatcher.currentTarget then
          startScanning()
      elseif not Value then
          stopScanning()
      end
   end,
})

local ScanModeDropdown = parentTab:CreateDropdown({
   Name = "🎯 Scan Mode",
   Options = {"random", "terrain"},
   CurrentOption = {"random"},
   MultipleOptions = false,
   Flag = "ScanModeDropdown",
   Callback = function(Option)
      scanningSystem.scanMode = Option[1]
   end,
})

local ScanSpeedSlider = parentTab:CreateSlider({
   Name = "⚡ Scan Speed",
   Range = {100, 2000},
   Increment = 100,
   Suffix = "ms",
   CurrentValue = 500,
   Flag = "ScanSpeedSlider",
   Callback = function(Value)
      scanningSystem.scanSpeed = Value
   end,
})

local StopOnHorseToggle = parentTab:CreateToggle({
   Name = "⏹️ Stop Scan on Horse Found",
   CurrentValue = true,
   Flag = "StopOnHorseToggle",
   Callback = function(Value)
      scanningSystem.stopOnHorseFound = Value
   end,
})

local ScanPointsSlider = parentTab:CreateSlider({
   Name = "📍 Scan Points per Cycle",
   Range = {4, 20},
   Increment = 1,
   Suffix = " points",
   CurrentValue = 8,
   Flag = "ScanPointsSlider",
   Callback = function(Value)
      scanningSystem.settings.scanPointsPerCycle = Value
   end,
})

-- CaptureProgress Control Section
local CaptureProgressSection = parentTab:CreateSection("🎯 CaptureProgress System")

local ProgressMonitoringToggle = parentTab:CreateToggle({
   Name = "📊 CaptureProgress Monitoring",
   CurrentValue = true,
   Flag = "ProgressMonitoringToggle",
   Callback = function(Value)
      horseCatcher.settings.progressMonitoring = Value
   end,
})

local AbandonStuckToggle = parentTab:CreateToggle({
   Name = "⏭️ Abandon Stuck Progress",
   CurrentValue = true,
   Flag = "AbandonStuckProgressToggle",
   Callback = function(Value)
      horseCatcher.settings.abandonOnStuckProgress = Value
   end,
})

local MaxStuckProgressSlider = parentTab:CreateSlider({
   Name = "⏳ Max Stuck Progress Time",
   Range = {5, 30},
   Increment = 1,
   Suffix = "s",
   CurrentValue = 15,
   Flag = "MaxStuckProgressSlider",
   Callback = function(Value)
      horseCatcher.settings.maxStuckProgressTime = Value
   end,
})

-- Main Control Section
local MainControlSection = parentTab:CreateSection("🎯 Professional Control")

local MainToggle = parentTab:CreateToggle({
   Name = "🚀 Ultra Horse Catching",
   CurrentValue = false,
   Flag = "UltraHorseCatchingMainToggle",
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

-- Movement Settings Section
local MovementSettingsSection = parentTab:CreateSection("📍 Movement & Optimization")

local MovementDropdown = parentTab:CreateDropdown({
   Name = "📍 Movement Mode",
   Options = {"attachment", "pulse", "smooth"},
   CurrentOption = {"attachment"},
   MultipleOptions = false,
   Flag = "UltraHorseMovementModeDropdown",
   Callback = function(Option)
      local oldMode = horseCatcher.settings.movementMode
      horseCatcher.settings.movementMode = Option[1]
      
      if horseCatcher.isRunning then
          if Option[1] == "smooth" and oldMode ~= "smooth" then
              enableNoclip()
          elseif Option[1] ~= "smooth" and oldMode == "smooth" then
              disableNoclip()
          end
      end
      
      Rayfield:Notify({
         Title = "📍 Movement Updated",
         Content = "Now using: " .. Option[1]:upper() .. " mode" .. (Option[1] == "smooth" and " (Noclip)" or ""),
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local PulseIntervalSlider = parentTab:CreateSlider({
   Name = "⚡ Pulse Interval",
   Range = {0.4, 2},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0.8,
   Flag = "UltraHorsePulseIntervalSlider",
   Callback = function(Value)
      horseCatcher.settings.pulseInterval = Value
   end,
})

local PulseDistanceSlider = parentTab:CreateSlider({
   Name = "📏 Pulse Distance", 
   Range = {4, 15},
   Increment = 1,
   Suffix = " studs",
   CurrentValue = 8,
   Flag = "UltraHorsePulseDistanceSlider",
   Callback = function(Value)
      horseCatcher.settings.pulseDistance = Value
   end,
})

local CaptureCooldownSlider = parentTab:CreateSlider({
   Name = "⏱️ Capture Cooldown",
   Range = {0.2, 1},
   Increment = 0.05,
   Suffix = "s",
   CurrentValue = 0.4,
   Flag = "UltraHorseCaptureCooldownSlider",
   Callback = function(Value)
      horseCatcher.settings.captureCooldown = Value
   end,
})

local SmartTargetingToggle = parentTab:CreateToggle({
   Name = "🧠 Smart Targeting",
   CurrentValue = true,
   Flag = "UltraHorseSmartTargetingToggle",
   Callback = function(Value)
      horseCatcher.settings.smartTargeting = Value
   end,
})

-- Status Section
local LiveStatusSection = parentTab:CreateSection("📊 Status")

local IslandInfo = parentTab:CreateParagraph({Title = "🏝️ Island Information", Content = "Detecting current island..."})
local ScanningStatus = parentTab:CreateParagraph({Title = "🔍 Scanning Status", Content = "Scanner ready"})
local TargetInfo = parentTab:CreateParagraph({Title = "🐎 Current Target", Content = "No target selected"})

-- Quick Actions Section
local QuickActionsSection = parentTab:CreateSection("⚡ Quick Actions")

local StartScanButton = parentTab:CreateButton({
   Name = "🔍 Manual Scan",
   Callback = function()
      if not scanningSystem.isScanning then
          startScanning()
          Rayfield:Notify({
             Title = "🔍 Manual Scan Started",
             Content = "Scanning current island for horses...",
             Duration = 2,
             Image = 4483362458,
          })
      end
   end,
})

local ClearKnownLocationsButton = parentTab:CreateButton({
   Name = "🗑️ Clear Known Locations",
   Callback = function()
      scanningSystem.knownHorseLocations = {}
      Rayfield:Notify({
         Title = "🗑️ Known Locations Cleared",
         Content = "Horse location database cleared",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local ClearCacheButton = parentTab:CreateButton({
   Name = "🗑️ Clear Cache",
   Callback = function()
      Cache.horses = {}
      Cache.horsesById = {}
      Cache.islandHorses = {}
      Cache.lastUpdate = 0
      
      Rayfield:Notify({
         Title = "🗑️ Cache Cleared",
         Content = "Performance cache optimized",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

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

-- Statistics Section
local StatisticsSection = parentTab:CreateSection("📈 Statistics")

local SessionStats = parentTab:CreateParagraph({Title = "📈 Session Metrics", Content = "Ready for session"})
local ScanningStats = parentTab:CreateParagraph({Title = "🔍 Scanning Statistics", Content = "No scanning data yet"})
local IslandStats = parentTab:CreateParagraph({Title = "🏝️ Island Statistics", Content = "No island data yet"})

-- =================================
-- ENHANCED STATUS UPDATE SYSTEM
-- =================================
spawn(function()
    while wait(1) do
        local currentIsland = detectCurrentIsland()
        
        -- Island Information
        local islandText = "🏝️ Current Island: " .. currentIsland .. "\n"
        islandText = islandText .. "🐎 Horses on Island: " .. (horseCatcher.runtime.currentIslandHorses or 0) .. "\n"
        
        local totalIslands = 0
        local totalHorses = 0
        for islandName, horseCount in pairs(Cache.islandHorses) do
            totalIslands = totalIslands + 1
            totalHorses = totalHorses + horseCount
        end
        
        islandText = islandText .. "🌍 Islands Scanned: " .. totalIslands .. "\n"
        islandText = islandText .. "📊 Total Horses: " .. totalHorses .. "\n"
        islandText = islandText .. "🔍 Auto-Detection: ✅"
        
        -- Show island bounds status
        local bounds = autoDetectIslandBounds(currentIsland)
        if bounds then
            islandText = islandText .. "\n📐 Island Bounds: ✅"
        else
            islandText = islandText .. "\n📐 Island Bounds: ❌ (Auto-detecting...)"
        end
        
        IslandInfo:Set({Title = "🏝️ Island Information", Content = islandText})
        
        -- Scanning Status
        local scanningText = ""
        if scanningSystem.isScanning then
            scanningText = "🔄 Status: ACTIVE SCANNING\n"
            scanningText = scanningText .. "🎯 Mode: " .. scanningSystem.scanMode:upper() .. "\n"
            scanningText = scanningText .. "⚡ Speed: " .. scanningSystem.scanSpeed .. "ms\n"
            scanningText = scanningText .. "📍 Points per Cycle: " .. scanningSystem.settings.scanPointsPerCycle .. "\n"
            scanningText = scanningText .. "🏝️ Current Island: " .. currentIsland
        else
            scanningText = "⏸️ Status: " .. (scanningSystem.autoScan and "AUTO-STANDBY" or "DISABLED") .. "\n"
            scanningText = scanningText .. "🎯 Mode: " .. scanningSystem.scanMode:upper() .. "\n"
            scanningText = scanningText .. "📍 Known Locations: " .. table.getn(scanningSystem.knownHorseLocations) .. "\n"
            scanningText = scanningText .. "🔍 Last Scan: " .. (scanningSystem.lastScanTime and string.format("%.1f", tick() - scanningSystem.lastScanTime) .. "s ago" or "Never") .. "\n"
            scanningText = scanningText .. "⏹️ Stop on Horse: " .. (scanningSystem.stopOnHorseFound and "✅" or "❌")
        end
        
        ScanningStatus:Set({Title = "🔍 Scanning Status", Content = scanningText})
        
        -- Target Information
        local targetText = ""
        if horseCatcher.currentTarget then
            local targetName = getHorseName(horseCatcher.currentTarget)
            local distance = math.floor((humanoidRootPart.Position - horseCatcher.currentTarget.HumanoidRootPart.Position).Magnitude)
            local velocity = math.floor(horseCatcher.currentTarget.HumanoidRootPart.Velocity.Magnitude)
            local timeOnTarget = tick() - horseCatcher.runtime.currentTargetStartTime
            
            targetText = "🐎 " .. targetName .. "\n"
            targetText = targetText .. "📏 Distance: " .. distance .. " studs\n"
            targetText = targetText .. "🏃 Speed: " .. velocity .. " studs/s\n"
            targetText = targetText .. "⏱️ Target Time: " .. string.format("%.1f", timeOnTarget) .. "s\n"
            
            if horseCatcher.currentTargetProgress and horseCatcher.currentTargetProgress.exists then
                targetText = targetText .. "📊 Progress: " .. horseCatcher.currentTargetProgress.text
            else
                targetText = targetText .. "📊 Progress: No data"
            end
            
            if horseCatcher.settings.movementMode == "attachment" then
                targetText = targetText .. "\n🔗 Attached: " .. (horseCatcher.isAttached and "✅" or "❌")
            elseif horseCatcher.settings.movementMode == "pulse" then
                local nextPulse = math.max(0, horseCatcher.settings.pulseInterval - (tick() - horseCatcher.runtime.lastPulseTime))
                targetText = targetText .. "\n⚡ Next Pulse: " .. string.format("%.1f", nextPulse) .. "s"
            else
                targetText = targetText .. "\n🌊 Smooth Follow: ✅ (Noclip)"
            end
        else
            local wildCount = #Cache.horses
            local knownCount = table.getn(scanningSystem.knownHorseLocations)
            targetText = "🔍 Scanning for targets...\n🐎 Cached horses: " .. wildCount .. "\n📍 Known locations: " .. knownCount .. "\n🎯 Smart targeting: " .. (horseCatcher.settings.smartTargeting and "✅" or "❌") .. "\n🏝️ Island horses: " .. (horseCatcher.runtime.currentIslandHorses or 0)
            
            if scanningSystem.autoScan then
                targetText = targetText .. "\n🚀 Auto-scan: ACTIVE"
            else
                targetText = targetText .. "\n🚀 Auto-scan: DISABLED"
            end
        end
        TargetInfo:Set({Title = "🐎 Current Target", Content = targetText})
        
        -- Session Statistics
        if horseCatcher.isRunning then
            local sessionTime = tick() - horseCatcher.runtime.sessionStartTime
            local sessionMinutes = math.floor(sessionTime / 60)
            local sessionSeconds = math.floor(sessionTime % 60)
            
            local sessionText = "⏱️ Session Time: " .. sessionMinutes .. "m " .. sessionSeconds .. "s\n"
            sessionText = sessionText .. "🐎 Horses Captured: " .. horseCatcher.statistics.currentStreak .. "\n"
            sessionText = sessionText .. "📈 Capture Rate: " .. string.format("%.1f", horseCatcher.statistics.horsesPerMinute) .. "/min\n"
            sessionText = sessionText .. "🏝️ Current Island: " .. currentIsland .. "\n"
            sessionText = sessionText .. "📊 Mode: " .. horseCatcher.settings.movementMode:upper() .. (horseCatcher.settings.movementMode == "smooth" and " (Noclip)" or "") .. "\n"
            sessionText = sessionText .. "🔍 Auto-Scan: " .. (scanningSystem.autoScan and "ON" or "OFF")
            
            SessionStats:Set({Title = "📈 Session Metrics", Content = sessionText})
        else
            SessionStats:Set({Title = "📈 Session Metrics", Content = "No active session\nAdvanced scanning ready\nCaptureProgress monitoring ready\n🚀 Auto-lasso & protection ready"})
        end
        
        -- Scanning Statistics
        local scanStatsText = "🔍 Scanning Performance:\n"
        scanStatsText = scanStatsText .. "📍 Total Scan Points: " .. #scanningSystem.scannedPositions .. "\n"
        scanStatsText = scanStatsText .. "🐎 Known Horse Locations: " .. table.getn(scanningSystem.knownHorseLocations) .. "\n"
        scanStatsText = scanStatsText .. "🎯 Scan Mode: " .. scanningSystem.scanMode:upper() .. "\n"
        scanStatsText = scanStatsText .. "⚡ Current Speed: " .. scanningSystem.scanSpeed .. "ms\n"
        
        -- Calculate average horses found per scan
        local totalHorsesFound = 0
        for _, scan in pairs(scanningSystem.scannedPositions) do
            totalHorsesFound = totalHorsesFound + (scan.horsesFound or 0)
        end
        local avgHorsesPerScan = #scanningSystem.scannedPositions > 0 and (totalHorsesFound / #scanningSystem.scannedPositions) or 0
        scanStatsText = scanStatsText .. "📊 Avg Horses/Scan: " .. string.format("%.2f", avgHorsesPerScan)
        
        ScanningStats:Set({Title = "🔍 Scanning Statistics", Content = scanStatsText})
        
        -- Island Statistics
        local islandStatsText = "🏝️ Per-Island Captures:\n"
        local hasStats = false
        for islandName, captures in pairs(horseCatcher.statistics.islandStats) do
            islandStatsText = islandStatsText .. "• " .. islandName .. ": " .. captures .. " horses\n"
            hasStats = true
        end
        
        if not hasStats then
            islandStatsText = islandStatsText .. "No captures yet"
        else
            islandStatsText = islandStatsText .. "\n🌍 Total Islands: " .. totalIslands .. "\n"
            islandStatsText = islandStatsText .. "🎯 Best Island: "
            local bestIsland = "None"
            local maxCaptures = 0
            for islandName, captures in pairs(horseCatcher.statistics.islandStats) do
                if captures > maxCaptures then
                    maxCaptures = captures
                    bestIsland = islandName
                end
            end
            islandStatsText = islandStatsText .. bestIsland .. " (" .. maxCaptures .. ")"
        end
        
        IslandStats:Set({Title = "🏝️ Island Statistics", Content = islandStatsText})
    end
end)

-- Character respawn handling
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    horseCatcher.isAttached = false
    horseCatcher.lassoEquipped = false
    horseCatcher.currentLassoID = nil
    
    disableNoclip()
    stopScanning()
    
    islandSystem.currentIsland = "Unknown"
    islandSystem.lastUpdate = 0
    
    if horseCatcher.isRunning then
        stopHorseCatching()
        MainToggle:Set(false)
        
        Rayfield:Notify({
           Title = "🔄 Character Respawned",
           Content = "Horse catching stopped - restart when ready",
           Duration = 3,
           Image = 4483362458,
        })
    end
end)

-- =================================
-- INITIALIZATION
-- =================================
Rayfield:Notify({
   Title = "🚀 Ultra Horse Catcher Pro Loaded!",
   Content = "Advanced scanning | Auto-island detection | CaptureProgress monitoring | Intelligent horse location tracking",
   Duration = 5,
   Image = 4483362458,
})

local initialIsland = detectCurrentIsland()

if gameSystem.available and gameSystem.networkReady then
    Rayfield:Notify({
       Title = "✅ Advanced System Ready!",
       Content = "Island: " .. initialIsland .. " | All features operational | Auto-scanning ready!",
       Duration = 4,
       Image = 4483362458,
    })
else
    Rayfield:Notify({
       Title = "⚠️ Performance Warning",
       Content = "Network system issues detected | Island: " .. initialIsland,
       Duration = 4,
       Image = 4483362458,
    })
end

-- Auto-detect island bounds on startup
spawn(function()
    wait(2)
    local detectedIsland = detectCurrentIsland()
    if detectedIsland ~= "Unknown" then
        autoDetectIslandBounds(detectedIsland)
        Rayfield:Notify({
           Title = "🎯 Advanced System Ready!",
           Content = "Island: " .. detectedIsland .. " | Bounds auto-detected | All systems operational!",
           Duration = 3,
           Image = 4483362458,
        })
    end
end)

-- Initialize scanning system variables
scanningSystem.lastScanTime = nil

-- Global functions for external access
_G.HorseCatcher = {
    startScanning = startScanning,
    stopScanning = stopScanning,
    getKnownLocations = function() return scanningSystem.knownHorseLocations end,
    getCurrentIsland = detectCurrentIsland,
    addIslandBounds = function(islandName, corner1, corner2)
        islandSystem.islandBounds[islandName] = {
            corner1 = corner1,
            corner2 = corner2
        }
    end
}

print("🚀 Ultra Horse Catcher Pro - Advanced Scanning Edition Loaded!")
print("📊 Features:")
print("   🔍 Intelligent scanning system (random/terrain modes)")
print("   📍 Horse location memory and tracking")
print("   🏝️ Automatic island detection and bounds")
print("   ⚡ Customizable scan speed and behavior")
print("   🎯 Stop scanning when horse found")
print("   🚀 AutoScan toggle for hands-free operation")
print("   📊 Real-time progress tracking and statistics")
print("   🌊 Noclip smooth mode with land-only teleportation")
print("   🛡️ Auto-lasso protection and management")
print("   🎪 CaptureProgress monitoring with smart abandonment")
print("🌍 Current Island: " .. initialIsland)
print("🎯 Ready for advanced horse catching!")
