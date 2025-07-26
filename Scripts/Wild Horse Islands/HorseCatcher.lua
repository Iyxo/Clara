-- Horse Catcher Pro - Advanced Island Scanner Edition
-- by Iyxo - 2025-07-26 14:13:40
-- Professional land-only teleportation with smart distribution

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
-- ADVANCED ISLAND SCANNER SYSTEM
-- =================================
local IslandScanner = {
    islandBounds = {},
    gridCache = {},
    landPositions = {},
    lastScanTime = 0,
    scanCooldown = 0.1,
    
    settings = {
        enabled = false,
        waitTime = 0.5,
        landOnly = true,
        smartDistribution = true,
        scanRange = 512,
        gridSize = 50,
        maxRaycastAttempts = 5,
        heightOffset = 5
    },
    
    runtime = {
        isScanning = false,
        currentIsland = "Unknown",
        scanningConnections = {},
        foundHorses = {},
        lastTeleportTime = 0,
        scanPositionIndex = 1,
        currentScanPositions = {}
    },
    
    -- Materiały terenu uznawane za "ląd"
    landMaterials = {
        [Enum.Material.Grass] = true,
        [Enum.Material.Rock] = true,
        [Enum.Material.Sand] = true,
        [Enum.Material.Snow] = true,
        [Enum.Material.Mud] = true,
        [Enum.Material.Ground] = true,
        [Enum.Material.Concrete] = true,
        [Enum.Material.Brick] = true,
        [Enum.Material.Cobblestone] = true,
        [Enum.Material.CrackedLava] = true,
        [Enum.Material.Glacier] = true,
        [Enum.Material.LeafyGrass] = true,
        [Enum.Material.Limestone] = true,
        [Enum.Material.Pavement] = true,
        [Enum.Material.Salt] = true,
        [Enum.Material.Sandstone] = true,
        [Enum.Material.Slate] = true
    }
}

-- Dodaj granice wysp
function IslandScanner.addIslandBounds(islandName, minBounds, maxBounds)
    IslandScanner.islandBounds[islandName] = {
        min = minBounds,
        max = maxBounds,
        center = (minBounds + maxBounds) / 2,
        size = maxBounds - minBounds
    }
end

-- Inicjalizacja granic wysp
IslandScanner.addIslandBounds("Mainland", Vector3.new(-992.5, 6.8, -951.3), Vector3.new(1084.9, 6.7, 861.8))

-- Sprawdź czy pozycja jest na lądzie
function IslandScanner.isLandPosition(position)
    if not IslandScanner.settings.landOnly then
        return true
    end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character}
    
    -- Raycast w dół z wysokości
    local rayOrigin = position + Vector3.new(0, 50, 0)
    local rayDirection = Vector3.new(0, -100, 0)
    
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    if raycastResult and raycastResult.Instance then
        if raycastResult.Instance.Name == "Terrain" then
            local material = raycastResult.Material
            return IslandScanner.landMaterials[material] == true
        end
    end
    
    return false
end

-- Generuj inteligentną siatkę pozycji dla wyspy
function IslandScanner.generateScanPositions(islandName)
    local bounds = IslandScanner.islandBounds[islandName]
    if not bounds then return {} end
    
    local positions = {}
    local gridSize = IslandScanner.settings.gridSize
    
    if IslandScanner.settings.smartDistribution then
        -- Smart Grid System
        local xSteps = math.ceil(bounds.size.X / gridSize)
        local zSteps = math.ceil(bounds.size.Z / gridSize)
        
        for x = 0, xSteps do
            for z = 0, zSteps do
                local baseX = bounds.min.X + (x * gridSize)
                local baseZ = bounds.min.Z + (z * gridSize)
                
                -- Dodaj losowy offset dla naturalności
                local randomOffsetX = (math.random() - 0.5) * gridSize * 0.8
                local randomOffsetZ = (math.random() - 0.5) * gridSize * 0.8
                
                local scanPosition = Vector3.new(
                    math.min(math.max(baseX + randomOffsetX, bounds.min.X), bounds.max.X),
                    bounds.center.Y + IslandScanner.settings.heightOffset,
                    math.min(math.max(baseZ + randomOffsetZ, bounds.min.Z), bounds.max.Z)
                )
                
                -- Sprawdź czy to ląd (jeśli włączone)
                if IslandScanner.isLandPosition(scanPosition) then
                    table.insert(positions, scanPosition)
                end
            end
        end
    else
        -- Pure Random System (fallback)
        for i = 1, 50 do
            local randomX = bounds.min.X + math.random() * bounds.size.X
            local randomZ = bounds.min.Z + math.random() * bounds.size.Z
            local randomPosition = Vector3.new(randomX, bounds.center.Y + IslandScanner.settings.heightOffset, randomZ)
            
            if IslandScanner.isLandPosition(randomPosition) then
                table.insert(positions, randomPosition)
            end
        end
    end
    
    -- Shuffle pozycji dla większej losowości
    for i = #positions, 2, -1 do
        local j = math.random(i)
        positions[i], positions[j] = positions[j], positions[i]
    end
    
    return positions
end

-- Sprawdź czy w pobliżu są konie
function IslandScanner.detectNearbyHorses()
    local playerPos = humanoidRootPart.Position
    local nearbyHorses = {}
    
    -- Sprawdź cache koni
    for _, horseData in pairs(Cache.horses) do
        if horseData.horse and horseData.horse:FindFirstChild("HumanoidRootPart") then
            local distance = (playerPos - horseData.horse.HumanoidRootPart.Position).Magnitude
            if distance <= IslandScanner.settings.scanRange then
                table.insert(nearbyHorses, {
                    horse = horseData.horse,
                    distance = distance,
                    position = horseData.horse.HumanoidRootPart.Position
                })
            end
        end
    end
    
    return nearbyHorses
end

-- Znajdź konie na całej wyspie
function IslandScanner.findIslandHorses()
    local islandName = detectCurrentIsland()
    local bounds = IslandScanner.islandBounds[islandName]
    if not bounds then return {} end
    
    local islandHorses = {}
    
    for _, horseData in pairs(Cache.horses) do
        if horseData.horse and horseData.horse:FindFirstChild("HumanoidRootPart") then
            local horsePos = horseData.horse.HumanoidRootPart.Position
            
            -- Sprawdź czy koń jest w granicach wyspy
            if horsePos.X >= bounds.min.X and horsePos.X <= bounds.max.X and
               horsePos.Z >= bounds.min.Z and horsePos.Z <= bounds.max.Z then
                table.insert(islandHorses, {
                    horse = horseData.horse,
                    position = horsePos,
                    distance = (humanoidRootPart.Position - horsePos).Magnitude
                })
            end
        end
    end
    
    -- Sortuj po odległości
    table.sort(islandHorses, function(a, b) return a.distance < b.distance end)
    
    return islandHorses
end

-- Bezpieczna teleportacja z land-only
function IslandScanner.teleportToPosition(targetPosition)
    local currentTime = os.clock()
    if currentTime - IslandScanner.runtime.lastTeleportTime < IslandScanner.settings.waitTime then
        return false
    end
    
    -- Dodatkowa weryfikacja terenu
    if IslandScanner.settings.landOnly then
        local attempts = 0
        local finalPosition = targetPosition
        
        while attempts < IslandScanner.settings.maxRaycastAttempts do
            if IslandScanner.isLandPosition(finalPosition) then
                break
            end
            
            -- Spróbuj pozycję w pobliżu
            local offset = Vector3.new(
                (math.random() - 0.5) * 20,
                0,
                (math.random() - 0.5) * 20
            )
            finalPosition = targetPosition + offset
            attempts = attempts + 1
        end
        
        -- Jeśli nie znaleziono lądu, anuluj teleportację
        if attempts >= IslandScanner.settings.maxRaycastAttempts then
            return false
        end
        
        targetPosition = finalPosition
    end
    
    -- Wykonaj teleportację
    humanoidRootPart.CFrame = CFrame.new(targetPosition)
    IslandScanner.runtime.lastTeleportTime = currentTime
    
    return true
end

-- Główna logika skanowania
function IslandScanner.performScan()
    if not IslandScanner.settings.enabled or not horseCatcher.isRunning then
        return
    end
    
    local currentTime = os.clock()
    if currentTime - IslandScanner.lastScanTime < IslandScanner.scanCooldown then
        return
    end
    
    IslandScanner.lastScanTime = currentTime
    
    -- Sprawdź czy w pobliżu są konie
    local nearbyHorses = IslandScanner.detectNearbyHorses()
    
    if #nearbyHorses > 0 then
        -- Konie w pobliżu - zatrzymaj skanowanie
        if IslandScanner.runtime.isScanning then
            IslandScanner.runtime.isScanning = false
            Rayfield:Notify({
               Title = "Scan Paused",
               Content = "Horse detected nearby - stopping scan",
               Duration = 1,
            })
        end
        return
    end
    
    -- Brak koni w pobliżu - sprawdź całą wyspę
    local islandHorses = IslandScanner.findIslandHorses()
    
    if #islandHorses > 0 then
        -- Znaleziono konie na wyspie - teleportuj się do najbliższego
        local targetHorse = islandHorses[1]
        local targetPosition = targetHorse.position + Vector3.new(
            (math.random() - 0.5) * 40,
            IslandScanner.settings.heightOffset,
            (math.random() - 0.5) * 40
        )
        
        if IslandScanner.teleportToPosition(targetPosition) then
            Rayfield:Notify({
               Title = "Horse Found",
               Content = "Teleporting to horse location",
               Duration = 1,
            })
        end
        return
    end
    
    -- Brak koni na wyspie - rozpocznij/kontynuuj systematyczne skanowanie
    if not IslandScanner.runtime.isScanning then
        IslandScanner.runtime.isScanning = true
        local currentIsland = detectCurrentIsland()
        IslandScanner.runtime.currentScanPositions = IslandScanner.generateScanPositions(currentIsland)
        IslandScanner.runtime.scanPositionIndex = 1
        
        Rayfield:Notify({
           Title = "Island Scan Started",
           Content = "Scanning " .. currentIsland .. " for horses",
           Duration = 2,
        })
    end
    
    -- Kontynuuj systematyczne skanowanie
    if #IslandScanner.runtime.currentScanPositions > 0 then
        local targetPosition = IslandScanner.runtime.currentScanPositions[IslandScanner.runtime.scanPositionIndex]
        
        if IslandScanner.teleportToPosition(targetPosition) then
            IslandScanner.runtime.scanPositionIndex = IslandScanner.runtime.scanPositionIndex + 1
            
            -- Jeśli skończono pozycje, wygeneruj nowe
            if IslandScanner.runtime.scanPositionIndex > #IslandScanner.runtime.currentScanPositions then
                local currentIsland = detectCurrentIsland()
                IslandScanner.runtime.currentScanPositions = IslandScanner.generateScanPositions(currentIsland)
                IslandScanner.runtime.scanPositionIndex = 1
            end
        end
    end
end

-- Start scanning system
function IslandScanner.startScanning()
    if IslandScanner.runtime.scanningConnections.main then
        return false
    end
    
    IslandScanner.runtime.scanningConnections.main = RunService.Heartbeat:Connect(function()
        IslandScanner.performScan()
    end)
    
    Rayfield:Notify({
       Title = "Island Scanner Active",
       Content = "Smart land-only scanning enabled",
       Duration = 2,
    })
    
    return true
end

-- Stop scanning system
function IslandScanner.stopScanning()
    for name, connection in pairs(IslandScanner.runtime.scanningConnections) do
        if connection then
            connection:Disconnect()
            IslandScanner.runtime.scanningConnections[name] = nil
        end
    end
    
    IslandScanner.runtime.isScanning = false
    IslandScanner.runtime.currentScanPositions = {}
    
    Rayfield:Notify({
       Title = "Island Scanner Stopped",
       Content = "Scanning disabled",
       Duration = 2,
    })
end

-- =================================
-- ENHANCED ISLAND DETECTION SYSTEM
-- =================================
local islandSystem = {
    currentIsland = "Unknown",
    lastUpdate = 0,
    updateInterval = 3,
    availableIslands = {},
    islandHorseCount = {}
}

local function detectCurrentIsland()
    local currentTime = os.clock()
    if currentTime - islandSystem.lastUpdate < islandSystem.updateInterval then
        return islandSystem.currentIsland
    end
    
    local islandAttribute = player:GetAttribute("island")
    if islandAttribute and islandAttribute ~= "" then
        islandSystem.currentIsland = islandAttribute
        islandSystem.lastUpdate = currentTime
        return islandAttribute
    end
    
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
    
    if islandSystem.currentIsland == "Unknown" then
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
    end
    
    islandSystem.lastUpdate = currentTime
    return islandSystem.currentIsland
end

-- =================================
-- PROFESSIONAL CAPTURE PROGRESS SYSTEM
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
    
    return progressData
end

local function updateCaptureProgressTracking()
    local currentTime = os.clock()
    if currentTime - captureProgressSystem.lastUpdate < captureProgressSystem.updateInterval then
        return
    end
    
    captureProgressSystem.lastUpdate = currentTime
    
    for horseId, data in pairs(captureProgressSystem.trackedHorses) do
        if currentTime - data.lastSeen > 30 then
            captureProgressSystem.trackedHorses[horseId] = nil
        end
    end
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
    
    -- Apply to current character
    for _, part in pairs(character:GetChildren()) do
        setNoclip(part)
    end
    
    -- Monitor for new parts
    noclipSystem.connections.childAdded = character.ChildAdded:Connect(function(child)
        if noclipSystem.active then
            wait(0.1) -- Wait for part to load
            setNoclip(child)
        end
    end)
end

local function disableNoclip()
    if not noclipSystem.active then return end
    
    noclipSystem.active = false
    
    -- Restore original collision
    for part, _ in pairs(noclipSystem.originalCanCollide) do
        if part and part.Parent then
            part.CanCollide = true
        end
    end
    
    noclipSystem.originalCanCollide = {}
    
    -- Disconnect monitoring
    if noclipSystem.connections.childAdded then
        noclipSystem.connections.childAdded:Disconnect()
        noclipSystem.connections.childAdded = nil
    end
end

-- =================================
-- PROFESSIONAL CACHING SYSTEM
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
-- OPTIMIZED GARBAGE COLLECTION
-- =================================
local function optimizeGC()
    -- Batch cleanup instead of individual removes
    if #horseCatcher.performance.captureTimes > 100 then
        local newTable = {}
        local startIndex = #horseCatcher.performance.captureTimes - 50
        for i = startIndex, #horseCatcher.performance.captureTimes do
            table.insert(newTable, horseCatcher.performance.captureTimes[i])
        end
        horseCatcher.performance.captureTimes = newTable
    end
    
    if #horseCatcher.performance.targetingTimes > 50 then
        local newTable = {}
        local startIndex = #horseCatcher.performance.targetingTimes - 25
        for i = startIndex, #horseCatcher.performance.targetingTimes do
            table.insert(newTable, horseCatcher.performance.targetingTimes[i])
        end
        horseCatcher.performance.targetingTimes = newTable
    end
    
    if #horseCatcher.performance.progressCheckTimes > 50 then
        local newTable = {}
        local startIndex = #horseCatcher.performance.progressCheckTimes - 25
        for i = startIndex, #horseCatcher.performance.progressCheckTimes do
            table.insert(newTable, horseCatcher.performance.progressCheckTimes[i])
        end
        horseCatcher.performance.progressCheckTimes = newTable
    end
end

-- =================================
-- ULTRA-OPTIMIZED HORSE CATCHER SYSTEM
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
            fastestCapture = 999,
            slowestCapture = 0
        }
    },
    
    settings = {
        movementMode = "attachment",
        captureCooldown = 0.4,
        smartTargeting = true,
        abandonOnStuckProgress = true,
        maxStuckProgressTime = 15,
        attachmentOffset = 4,
        targetingRadius = 300
    },
    
    runtime = {
        lastCaptureTime = 0,
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
        currentIslandHorses = 0,
        sessionCapturedCount = 0
    },
    
    performance = {
        captureTimes = {},
        targetingTimes = {},
        progressCheckTimes = {},
        maxCaptureTime = 0,
        avgCaptureTime = 0
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
-- ULTRA-OPTIMIZED HORSE FUNCTIONS
-- =================================

local function getHorseName(horse)
    if not horse then return "Unknown" end
    
    local cached = Cache.horsesById[horse.Name]
    if cached and cached.name then
        return cached.name
    end
    
    local horseName = "Unknown"
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
    
    Cache.horsesById[horse.Name] = Cache.horsesById[horse.Name] or {}
    Cache.horsesById[horse.Name].name = horseName
    
    return horseName
end

local function isWildHorse(horse)
    if not horse then return false end
    
    local cached = Cache.horsesById[horse.Name]
    if cached and cached.isWild ~= nil then
        return cached.isWild
    end
    
    local isWild = false
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
    
    Cache.horsesById[horse.Name] = Cache.horsesById[horse.Name] or {}
    Cache.horsesById[horse.Name].isWild = isWild
    
    return isWild
end

local function updateHorseCache()
    local currentTime = os.clock()
    if currentTime - Cache.lastUpdate < Cache.updateInterval then
        return Cache.horses
    end
    
    local startTime = os.clock()
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
    
    table.sort(Cache.horses, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        else
            return a.distance < b.distance
        end
    end)
    
    Cache.lastUpdate = currentTime
    
    local scanTime = os.clock() - startTime
    table.insert(horseCatcher.performance.targetingTimes, scanTime)
    
    horseCatcher.runtime.targetingCount = horseCatcher.runtime.targetingCount + 1
    horseCatcher.runtime.currentIslandHorses = Cache.islandHorses[currentIsland] or 0
    
    return Cache.horses
end

-- Auto-equip and protect lasso system (always active)
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
                local currentlyEquipped = gameSystem.u3.GetLocal({"temporary", "equippedEquipment"})
                if currentlyEquipped ~= lastEquipped then
                    gameSystem.u2.Network:FireServer("Inventory", "Use", lastEquipped)
                end
                success = true
                toolID = lastEquipped
            end
        else
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

-- Lasso protection system (always active)
local function protectLasso()
    if not horseCatcher.isRunning then
        return
    end
    
    local currentTime = os.clock()
    if currentTime - horseCatcher.runtime.lastLassoCheck < 1 then
        return
    end
    
    horseCatcher.runtime.lastLassoCheck = currentTime
    
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
end

local function findOptimalTarget()
    local horses = updateHorseCache()
    if #horses == 0 then return nil end
    
    local playerPos = humanoidRootPart.Position
    local currentIsland = detectCurrentIsland()
    local candidates = {}
    
    for i = 1, math.min(#horses, 10) do
        local horseData = horses[i]
        if horseData and horseData.horse and horseData.horse:FindFirstChild("HumanoidRootPart") then
            local horse = horseData.horse
            local horsePos = horse.HumanoidRootPart.Position
            local distance = (playerPos - horsePos).Magnitude
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
            
            local raycast = workspace:Raycast(playerPos, (horsePos - playerPos).Unit * distance)
            if not raycast or raycast.Instance == horse then
                score = score + 100
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
    
    local currentTime = os.clock()
    if currentTime - horseCatcher.runtime.lastCaptureTime < horseCatcher.settings.captureCooldown then
        return false
    end
    
    local startTime = os.clock()
    local success = false
    
    if gameSystem.available and gameSystem.networkReady then
        gameSystem.u2.Network:FireServer("Equipment", horseCatcher.currentLassoID, "Activate", horse)
        success = true
    end
    
    horseCatcher.runtime.lastCaptureTime = currentTime
    horseCatcher.runtime.captureAttempts = horseCatcher.runtime.captureAttempts + 1
    horseCatcher.statistics.totalAttempts = horseCatcher.statistics.totalAttempts + 1
    
    if success then
        local captureTime = os.clock() - startTime
        table.insert(horseCatcher.performance.captureTimes, captureTime)
        
        if captureTime > horseCatcher.performance.maxCaptureTime then
            horseCatcher.performance.maxCaptureTime = captureTime
        end
    end
    
    return success
end

-- Movement functions
local function attachToHorse(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") then return false end
    
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
    
    return true
end

-- Enhanced smooth follow with noclip
local function smoothFollow(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") then return false end
    
    local horsePos = horse.HumanoidRootPart.Position
    local horseVelocity = horse.HumanoidRootPart.Velocity
    local currentPos = humanoidRootPart.Position
    
    local prediction = horsePos + (horseVelocity * 0.3)
    local direction = (prediction - currentPos).Unit
    local distance = (prediction - currentPos).Magnitude
    local safeDistance = 5
    
    if distance > safeDistance + 1 then
        local targetPos = prediction - direction * safeDistance
        targetPos = targetPos + Vector3.new(0, 2.5, 0)
        
        local tweenInfo = TweenInfo.new(
            0.4,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        
        local tween = TweenService:Create(
            humanoidRootPart,
            tweenInfo,
            {CFrame = CFrame.lookAt(targetPos, prediction)}
        )
        tween:Play()
    end
    
    return true
end

local function detachFromHorse()
    for _, attachment in pairs(humanoidRootPart:GetChildren()) do
        if (attachment.Name == "HorseAttachment" or attachment.Name:find("Weld")) then
            if attachment:IsA("WeldConstraint") or attachment:IsA("Weld") then
                attachment:Destroy()
            end
        end
    end
    horseCatcher.isAttached = false
    horseCatcher.runtime.forceDetach = false
end

local function isHorseCapturedOrComplete(horse)
    if not horse or not horse.Parent then
        return true, "Horse disappeared"
    end
    
    local captured = false
    local horseName = "Unknown"
    local reason = ""
    
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
    
    if captured then
        horseCatcher.capturedHorses[horse.Name] = true
        horseCatcher.statistics.totalCaptured = horseCatcher.statistics.totalCaptured + 1
        horseCatcher.statistics.currentStreak = horseCatcher.statistics.currentStreak + 1
        horseCatcher.statistics.successfulCaptures = horseCatcher.statistics.successfulCaptures + 1
        horseCatcher.runtime.lastSuccessfulCapture = os.clock()
        horseCatcher.runtime.sessionCapturedCount = horseCatcher.runtime.sessionCapturedCount + 1
        
        local captureTime = os.clock() - horseCatcher.runtime.currentTargetStartTime
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
        
        local sessionTime = os.clock() - horseCatcher.runtime.sessionStartTime
        horseCatcher.statistics.horsesPerMinute = (horseCatcher.statistics.currentStreak / (sessionTime / 60))
        
        Rayfield:Notify({
           Title = "Horse Captured!",
           Content = horseName .. " on " .. currentIsland,
           Duration = 2,
        })
    end
    
    return captured, reason
end

local function cleanupSystem()
    local currentTime = os.clock()
    if currentTime - horseCatcher.runtime.lastCleanupTime < 15 then
        return
    end
    
    if #Cache.horses > Cache.maxCacheSize * 0.8 then
        local newHorses = {}
        local startIndex = math.floor(Cache.maxCacheSize * 0.6)
        for i = startIndex, #Cache.horses do
            table.insert(newHorses, Cache.horses[i])
        end
        Cache.horses = newHorses
    end
    
    optimizeGC()
    updateCaptureProgressTracking()
    
    horseCatcher.runtime.lastCleanupTime = currentTime
end

-- =================================
-- ENHANCED MAIN LOGIC
-- =================================
local function startHorseCatching()
    if horseCatcher.isRunning then return false end
    
    local lassoReady, lassoID = equipLasso()
    if not lassoReady then
        Rayfield:Notify({
           Title = "Error",
           Content = "No lasso found!",
           Duration = 3,
        })
        return false
    end
    
    if not gameSystem.available or not gameSystem.networkReady then
        Rayfield:Notify({
           Title = "Error",
           Content = "Network system error",
           Duration = 3,
        })
        return false
    end
    
    horseCatcher.isRunning = true
    horseCatcher.runtime.sessionStartTime = os.clock()
    horseCatcher.statistics.sessionsRun = horseCatcher.statistics.sessionsRun + 1
    horseCatcher.statistics.currentStreak = 0
    horseCatcher.runtime.lastCaptureTime = 0
    horseCatcher.runtime.targetingCount = 0
    horseCatcher.runtime.captureAttempts = 0
    horseCatcher.runtime.lastIslandCheck = 0
    horseCatcher.runtime.lastProgressCheck = 0
    horseCatcher.runtime.lastLassoCheck = 0
    horseCatcher.runtime.sessionCapturedCount = 0
    
    horseCatcher.runtime.currentTargetStartTime = 0
    horseCatcher.runtime.lastProgressChange = 0
    horseCatcher.runtime.lastProgressValue = "0/0"
    horseCatcher.runtime.progressStuckTime = 0
    
    local movementMode = horseCatcher.settings.movementMode == "attachment" and "Attachment" or "Smooth"
    local currentIsland = detectCurrentIsland()
    
    -- Enable noclip for smooth mode
    if horseCatcher.settings.movementMode == "smooth" then
        enableNoclip()
    end
    
    -- Start island scanner if enabled
    if IslandScanner.settings.enabled then
        IslandScanner.startScanning()
    end
    
    Rayfield:Notify({
       Title = "Started!",
       Content = movementMode .. " mode on " .. currentIsland,
       Duration = 2,
    })
    
    horseCatcher.connections.islandMonitor = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        
        local currentTime = os.clock()
        if currentTime - horseCatcher.runtime.lastIslandCheck < 5 then
            return
        end
        
        detectCurrentIsland()
        horseCatcher.runtime.lastIslandCheck = currentTime
    end)
    
    horseCatcher.connections.lassoProtection = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        protectLasso()
    end)
    
    horseCatcher.connections.progressMonitor = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning or not horseCatcher.currentTarget then return end
        
        local currentTime = os.clock()
        if currentTime - horseCatcher.runtime.lastProgressCheck < 0.5 then
            return
        end
        
        local startTime = os.clock()
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
        
        local checkTime = os.clock() - startTime
        table.insert(horseCatcher.performance.progressCheckTimes, checkTime)
    end)
    
    horseCatcher.connections.capture = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        
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
        
        if horseCatcher.currentTarget and horseCatcher.settings.abandonOnStuckProgress then
            if horseCatcher.runtime.progressStuckTime > horseCatcher.settings.maxStuckProgressTime then
                Rayfield:Notify({
                   Title = "Skipping",
                   Content = "Stuck horse - moving to next",
                   Duration = 2,
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
        
        if not horseCatcher.currentTarget then
            if horseCatcher.settings.smartTargeting then
                horseCatcher.currentTarget = findOptimalTarget()
            else
                local horses = updateHorseCache()
                horseCatcher.currentTarget = horses[1] and (horses[1].horse or horses[1])
            end
            
            if horseCatcher.currentTarget then
                horseCatcher.runtime.currentTargetStartTime = os.clock()
                horseCatcher.runtime.lastProgressChange = os.clock()
                horseCatcher.runtime.lastProgressValue = "0/0"
                horseCatcher.runtime.progressStuckTime = 0
                horseCatcher.currentTargetProgress = getCaptureProgress(horseCatcher.currentTarget)
            else
                if horseCatcher.settings.movementMode == "attachment" then
                    detachFromHorse()
                end
                return
            end
        end
        
        if horseCatcher.currentTarget then
            if horseCatcher.settings.movementMode == "attachment" then
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
    
    horseCatcher.connections.cleanup = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        cleanupSystem()
    end)
    
    return true
end

local function stopHorseCatching()
    horseCatcher.isRunning = false
    
    -- Stop island scanner
    IslandScanner.stopScanning()
    
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
    
    local sessionTime = os.clock() - horseCatcher.runtime.sessionStartTime
    local minutes = math.floor(sessionTime / 60)
    local seconds = math.floor(sessionTime % 60)
    
    local currentIsland = detectCurrentIsland()
    
    Rayfield:Notify({
       Title = "Session Ended",
       Content = "Captured " .. horseCatcher.runtime.sessionCapturedCount .. " horses",
       Duration = 3,
    })
    
    horseCatcher.statistics.currentStreak = 0
end

-- =================================
-- SIMPLIFIED UI
-- =================================

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

-- Island Scanner Section
local IslandScannerSection = parentTab:CreateSection("🌍 Advanced Island Scanner")

local ScannerToggle = parentTab:CreateToggle({
   Name = "🔍 Smart Island Scanning",
   CurrentValue = false,
   Flag = "IslandScannerToggle",
   Callback = function(Value)
      IslandScanner.settings.enabled = Value
      if Value and horseCatcher.isRunning then
         IslandScanner.startScanning()
      else
         IslandScanner.stopScanning()
      end
   end,
})

local LandOnlyToggle = parentTab:CreateToggle({
   Name = "🌱 Land-Only Teleportation",
   CurrentValue = true,
   Flag = "LandOnlyToggle",
   Callback = function(Value)
      IslandScanner.settings.landOnly = Value
   end,
})

local SmartDistributionToggle = parentTab:CreateToggle({
   Name = "🧠 Smart Grid Distribution",
   CurrentValue = true,
   Flag = "SmartDistributionToggle",
   Callback = function(Value)
      IslandScanner.settings.smartDistribution = Value
   end,
})

local ScanWaitTimeSlider = parentTab:CreateSlider({
   Name = "⏱️ Scan Wait Time",
   Range = {0.1, 5},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = 0.5,
   Flag = "ScanWaitTimeSlider",
   Callback = function(Value)
      IslandScanner.settings.waitTime = Value
   end,
})

local GridSizeSlider = parentTab:CreateSlider({
   Name = "📐 Grid Size",
   Range = {25, 100},
   Increment = 5,
   Suffix = " studs",
   CurrentValue = 50,
   Flag = "GridSizeSlider",
   Callback = function(Value)
      IslandScanner.settings.gridSize = Value
   end,
})

-- Progress Control Section
local ProgressControlSection = parentTab:CreateSection("⏭️ Progress Control")

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

-- Movement Settings Section
local MovementSettingsSection = parentTab:CreateSection("📍 Movement & Optimization")

local MovementDropdown = parentTab:CreateDropdown({
   Name = "📍 Movement Mode",
   Options = {"attachment", "smooth"},
   CurrentOption = {"attachment"},
   MultipleOptions = false,
   Flag = "UltraHorseMovementModeDropdown",
   Callback = function(Option)
      local oldMode = horseCatcher.settings.movementMode
      horseCatcher.settings.movementMode = Option[1]
      
      -- Handle noclip for smooth mode
      if horseCatcher.isRunning then
          if Option[1] == "smooth" and oldMode ~= "smooth" then
              enableNoclip()
          elseif Option[1] ~= "smooth" and oldMode == "smooth" then
              disableNoclip()
          end
      end
      
      Rayfield:Notify({
         Title = "Movement Updated",
         Content = "Using " .. Option[1] .. " mode",
         Duration = 2,
      })
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

-- Simplified Status Section
local LiveStatusSection = parentTab:CreateSection("📊 Status")

local IslandInfo = parentTab:CreateParagraph({Title = "🏝️ Island Information", Content = "Detecting current island..."})
local TargetInfo = parentTab:CreateParagraph({Title = "🐎 Current Target", Content = "No target selected"})
local ScannerInfo = parentTab:CreateParagraph({Title = "🔍 Scanner Status", Content = "Scanner inactive"})

-- Quick Actions Section
local QuickActionsSection = parentTab:CreateSection("⚡ Quick Actions")

local ClearCacheButton = parentTab:CreateButton({
   Name = "🗑️ Clear Cache",
   Callback = function()
      Cache.horses = {}
      Cache.horsesById = {}
      Cache.islandHorses = {}
      Cache.lastUpdate = 0
      horseCatcher.performance.captureTimes = {}
      horseCatcher.performance.targetingTimes = {}
      horseCatcher.performance.progressCheckTimes = {}
      
      Rayfield:Notify({
         Title = "Cache Cleared",
         Content = "Performance cache optimized",
         Duration = 2,
      })
   end,
})

local ResetCapturedButton = parentTab:CreateButton({
   Name = "🔄 Reset Captured List",
   Callback = function()
      horseCatcher.capturedHorses = {}
      Rayfield:Notify({
         Title = "List Reset",
         Content = "Captured horses list cleared",
         Duration = 2,
      })
   end,
})

-- =================================
-- SIMPLIFIED STATUS UPDATE SYSTEM
-- =================================
spawn(function()
    while wait(1) do
        local currentIsland = detectCurrentIsland()
        
        -- Island Information
        local islandText = "🏝️ Current Island: " .. currentIsland .. "\n"
        islandText = islandText .. "🔍 Auto-Scanning: ✅"
        
        IslandInfo:Set({Title = "🏝️ Island Information", Content = islandText})
        
        -- Target Information
        local targetText = ""
        if horseCatcher.currentTarget then
            local targetName = getHorseName(horseCatcher.currentTarget)
            local distance = math.floor((humanoidRootPart.Position - horseCatcher.currentTarget.HumanoidRootPart.Position).Magnitude)
            local velocity = math.floor(horseCatcher.currentTarget.HumanoidRootPart.Velocity.Magnitude)
            local timeOnTarget = os.clock() - horseCatcher.runtime.currentTargetStartTime
            
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
            else
                targetText = targetText .. "\n🌊 Smooth Follow: ✅ (Noclip)"
            end
        else
            local wildCount = #Cache.horses
            targetText = "🔍 Scanning for targets...\n🐎 Wild horses: " .. wildCount .. "\n🎯 Smart targeting: " .. (horseCatcher.settings.smartTargeting and "✅" or "❌")
        end
        TargetInfo:Set({Title = "🐎 Current Target", Content = targetText})
        
        -- Scanner Information
        local scannerText = ""
        if IslandScanner.settings.enabled then
            if IslandScanner.runtime.isScanning then
                local scanPositions = #IslandScanner.runtime.currentScanPositions
                local currentIndex = IslandScanner.runtime.scanPositionIndex
                local progress = scanPositions > 0 and math.floor((currentIndex / scanPositions) * 100) or 0
                
                scannerText = "🔍 Status: Active Scanning\n"
                scannerText = scannerText .. "📍 Progress: " .. progress .. "% (" .. currentIndex .. "/" .. scanPositions .. ")\n"
                scannerText = scannerText .. "🌱 Land-Only: " .. (IslandScanner.settings.landOnly and "✅" or "❌") .. "\n"
                scannerText = scannerText .. "🧠 Smart Grid: " .. (IslandScanner.settings.smartDistribution and "✅" or "❌") .. "\n"
                scannerText = scannerText .. "⏱️ Wait Time: " .. IslandScanner.settings.waitTime .. "s"
            else
                local nearbyHorses = IslandScanner.detectNearbyHorses()
                local islandHorses = IslandScanner.findIslandHorses()
                
                if #nearbyHorses > 0 then
                    scannerText = "⏸️ Status: Paused (Horse Nearby)\n"
                    scannerText = scannerText .. "🐎 Nearby Horses: " .. #nearbyHorses .. "\n"
                elseif #islandHorses > 0 then
                    scannerText = "🎯 Status: Horse Found on Island\n"
                    scannerText = scannerText .. "🐎 Island Horses: " .. #islandHorses .. "\n"
                else
                    scannerText = "🔍 Status: Ready to Scan\n"
                    scannerText = scannerText .. "🏝️ Island: " .. currentIsland .. "\n"
                end
                
                scannerText = scannerText .. "🌱 Land-Only: " .. (IslandScanner.settings.landOnly and "✅" or "❌") .. "\n"
                scannerText = scannerText .. "📐 Grid Size: " .. IslandScanner.settings.gridSize .. " studs"
            end
        else
            scannerText = "❌ Status: Disabled\n"
            scannerText = scannerText .. "🔍 Enable scanner to start intelligent island exploration\n"
            scannerText = scannerText .. "🌱 Features: Land-only teleportation, Smart grid distribution\n"
            scannerText = scannerText .. "⚡ Performance: Optimized for minimal lag"
        end
        ScannerInfo:Set({Title = "🔍 Scanner Status", Content = scannerText})
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
    IslandScanner.stopScanning()
    
    islandSystem.currentIsland = "Unknown"
    islandSystem.lastUpdate = 0
    
    if horseCatcher.isRunning then
        stopHorseCatching()
        MainToggle:Set(false)
        
        Rayfield:Notify({
           Title = "Character Respawned",
           Content = "Horse catching stopped - scanner disabled",
           Duration = 3,
        })
    end
end)

-- =================================
-- INITIALIZATION
-- =================================
Rayfield:Notify({
   Title = "Horse Catcher Pro Loaded",
   Content = "Advanced Island Scanner ready!",
   Duration = 3,
})

local initialIsland = detectCurrentIsland()

if gameSystem.available and gameSystem.networkReady then
    Rayfield:Notify({
       Title = "System Ready",
       Content = "Island: " .. initialIsland .. " | Land-only scanning available",
       Duration = 3,
    })
else
    Rayfield:Notify({
       Title = "Warning",
       Content = "Network issues detected - basic mode only",
       Duration = 3,
    })
end

spawn(function()
    wait(2)
    local detectedIsland = detectCurrentIsland()
    if detectedIsland ~= "Unknown" then
        -- Check if island bounds are defined
        local bounds = IslandScanner.islandBounds[detectedIsland]
        if bounds then
            Rayfield:Notify({
               Title = "Ready!",
               Content = "Island: " .. detectedIsland .. " | Scanner bounds configured",
               Duration = 2,
            })
        else
            Rayfield:Notify({
               Title = "Ready!",
               Content = "Island: " .. detectedIsland .. " | Configure bounds for optimal scanning",
               Duration = 3,
            })
        end
    end
end)
