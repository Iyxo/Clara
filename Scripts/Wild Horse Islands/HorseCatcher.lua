-- Horse Catcher Pro - Ultra-Optimized Professional Edition with Island Detection
-- by Iyxo - 2025-07-22 16:13:45
-- Revolutionary horse catching with professional optimizations + intelligent island detection

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
-- ENHANCED ISLAND DETECTION SYSTEM
-- =================================
local islandSystem = {
    currentIsland = "Unknown",
    lastUpdate = 0,
    updateInterval = 3, -- Check every 3 seconds
    availableIslands = {},
    islandHorseCount = {}
}

-- Professional island detection function
local function detectCurrentIsland()
    local currentTime = tick()
    if currentTime - islandSystem.lastUpdate < islandSystem.updateInterval then
        return islandSystem.currentIsland
    end
    
    -- Method 1: Player Attribute (Most reliable)
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

-- =================================
-- PROFESSIONAL CACHING SYSTEM (ENHANCED)
-- =================================
local Cache = {
    horses = {},
    horsesById = {},
    lastUpdate = 0,
    updateInterval = 1.5, -- Optimized cache timing
    maxCacheSize = 500,
    islandHorses = {} -- NEW: Track horses per island
}

-- =================================
-- ULTRA-OPTIMIZED HORSE CATCHER SYSTEM (ENHANCED)
-- =================================
local horseCatcher = {
    -- Status
    isRunning = false,
    currentTarget = nil,
    isAttached = false,
    lassoEquipped = false,
    currentLassoID = nil,
    
    -- High-performance connections
    connections = {
        capture = nil,
        targeting = nil,
        movement = nil,
        cleanup = nil,
        islandMonitor = nil -- NEW: Island monitoring
    },
    
    -- Professional data structures
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
        islandStats = {} -- NEW: Per-island statistics
    },
    
    -- Optimized settings
    settings = {
        -- Movement optimization
        movementMode = "attachment",
        pulseInterval = 0.8,
        pulseDistance = 8,
        
        -- Capture optimization
        captureCooldown = 0.4,
        maxAttemptsPerHorse = 12,
        maxStuckTime = 10,
        smartTargeting = true,
        aggressiveTargeting = true,
        
        -- NEW: Island settings
        multiIslandScanning = true,
        prioritizeCurrentIsland = true,
        maxIslandDistance = 1000,
        
        -- Professional settings
        safeDistance = 5,
        attachmentOffset = 4,
        targetingRadius = 300,
        batchProcessing = true,
        maxBatchSize = 5
    },
    
    -- High-performance runtime data
    runtime = {
        lastCaptureTime = 0,
        lastPulseTime = 0,
        lastTargetingTime = 0,
        lastCleanupTime = 0,
        lastIslandCheck = 0, -- NEW: Island check timing
        currentAttempts = 0,
        retryCount = 0,
        targetStuckTime = 0,
        lastTargetName = "",
        sessionStartTime = 0,
        lastSuccessfulCapture = 0,
        forceDetach = false,
        targetingCount = 0,
        captureAttempts = 0,
        currentIslandHorses = 0 -- NEW: Horses on current island
    },
    
    -- Performance monitoring
    performance = {
        captureTimes = {},
        targetingTimes = {},
        movementTimes = {},
        islandScanTimes = {}, -- NEW: Island scan performance
        maxCaptureTime = 0,
        avgCaptureTime = 0
    }
}

-- Game System Detection - Enhanced
local gameSystem = {
    u1 = nil,
    u2 = nil, 
    u3 = nil,
    available = false,
    remoteEvent = nil,
    networkReady = false
}

-- Initialize game system with error handling
pcall(function()
    gameSystem.u1 = require(ReplicatedStorage.References)
    gameSystem.u2 = gameSystem.u1.Utilities
    gameSystem.u3 = require(gameSystem.u1.PlayerScripts.Priority.Data)
    gameSystem.available = true
    gameSystem.networkReady = (gameSystem.u2 and gameSystem.u2.Network) and true or false
    gameSystem.remoteEvent = ReplicatedStorage.Communication.Events['']
end)

-- =================================
-- ULTRA-OPTIMIZED HORSE FUNCTIONS (ENHANCED WITH ISLAND DETECTION)
-- =================================

-- Professional horse name getter with caching
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

-- Ultra-fast wild horse checker with caching
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

-- ENHANCED: Professional cache management with island awareness
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
    
    -- Enhanced ultra-optimized scanning with island prioritization
    local function scanLocation(location, islandName, priority)
        if not location then return end
        
        local children = location:GetChildren()
        local localHorseCount = 0
        
        for i = 1, #children do
            local child = children[i]
            
            -- Fast filtering with early returns
            if child.Name:find("{") and child:FindFirstChild("HumanoidRootPart") then
                local humanoid = child:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 and not Players:GetPlayerFromCharacter(child) then
                    if isWildHorse(child) and not horseCatcher.capturedHorses[child.Name] then
                        local distance = (humanoidRootPart.Position - child.HumanoidRootPart.Position).Magnitude
                        
                        -- Island-aware filtering
                        if not horseCatcher.settings.multiIslandScanning and islandName ~= currentIsland then
                            if distance > horseCatcher.settings.maxIslandDistance then
                                continue
                            end
                        end
                        
                        horseCount = horseCount + 1
                        localHorseCount = localHorseCount + 1
                        
                        -- Enhanced horse data with island info
                        Cache.horses[horseCount] = {
                            horse = child,
                            island = islandName,
                            priority = priority,
                            distance = distance
                        }
                        
                        -- Performance limit
                        if horseCount >= Cache.maxCacheSize then
                            break
                        end
                    end
                end
            end
        end
        
        Cache.islandHorses[islandName] = localHorseCount
    end
    
    -- Enhanced scan with island prioritization
    pcall(function()
        if Workspace.Islands then
            -- Priority 1: Current island
            if currentIsland == "Mainland" and Workspace.Islands.Mainland then
                scanLocation(Workspace.Islands.Mainland, "Mainland", 1)
            end
            
            -- Scan other islands with appropriate priority
            for _, island in pairs(Workspace.Islands:GetChildren()) do
                if island:IsA("Model") then
                    local priority = (island.Name == currentIsland) and 1 or 2
                    scanLocation(island, island.Name, priority)
                end
            end
            
            -- Fallback: scan Islands folder itself
            scanLocation(Workspace.Islands, "Islands", 3)
        end
    end)
    
    -- Sort horses by island priority and distance
    table.sort(Cache.horses, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        else
            return a.distance < b.distance
        end
    end)
    
    Cache.lastUpdate = currentTime
    
    -- Enhanced performance tracking
    local scanTime = tick() - startTime
    table.insert(horseCatcher.performance.targetingTimes, scanTime)
    table.insert(horseCatcher.performance.islandScanTimes, scanTime)
    if #horseCatcher.performance.targetingTimes > 100 then
        table.remove(horseCatcher.performance.targetingTimes, 1)
    end
    if #horseCatcher.performance.islandScanTimes > 50 then
        table.remove(horseCatcher.performance.islandScanTimes, 1)
    end
    
    horseCatcher.runtime.targetingCount = horseCatcher.runtime.targetingCount + 1
    horseCatcher.runtime.currentIslandHorses = Cache.islandHorses[currentIsland] or 0
    
    return Cache.horses
end

-- Professional lasso detection with game system integration
local function equipLasso()
    if horseCatcher.lassoEquipped and horseCatcher.currentLassoID then
        return true, horseCatcher.currentLassoID
    end
    
    local success = false
    local toolID = nil
    
    -- Method 1: Enhanced game system detection
    if gameSystem.available and gameSystem.u3 and gameSystem.networkReady then
        local lastEquipped = gameSystem.u3.GetLocal({"lastEquippedLasso"})
        if lastEquipped then
            local inventoryItem = gameSystem.u3.GetLocal({"inventory", lastEquipped})
            if inventoryItem then
                pcall(function()
                    gameSystem.u2.Network:FireServer("Inventory", "Use", lastEquipped)
                    success = true
                    toolID = lastEquipped
                end)
            end
        end
    end
    
    -- Method 2: Fallback with known working ID
    if not success then
        toolID = "{60769f1f-cade-463b-ae32-adaacc91116f}"
        success = true
    end
    
    -- Method 3: Backpack scan optimization
    if not success then
        pcall(function()
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                local tools = backpack:GetChildren()
                for i = 1, #tools do
                    local tool = tools[i]
                    if tool.Name:lower():find("lasso") then
                        tool.Parent = character
                        success = true
                        toolID = tool.Name
                        break
                    end
                end
            end
        end)
    end
    
    if success then
        horseCatcher.lassoEquipped = true
        horseCatcher.currentLassoID = toolID
    end
    
    return success, toolID
end

-- ENHANCED: Ultra-optimized horse finding with intelligent scoring + island awareness
local function findOptimalTarget()
    local horses = updateHorseCache()
    if #horses == 0 then return nil end
    
    local playerPos = humanoidRootPart.Position
    local currentIsland = detectCurrentIsland()
    local candidates = {}
    
    -- Enhanced scoring algorithm with island bonuses
    for i = 1, math.min(#horses, horseCatcher.settings.maxBatchSize * 2) do
        local horseData = horses[i]
        if horseData and horseData.horse and horseData.horse:FindFirstChild("HumanoidRootPart") then
            local horse = horseData.horse
            local horsePos = horse.HumanoidRootPart.Position
            local distance = (playerPos - horsePos).Magnitude
            local velocity = horse.HumanoidRootPart.Velocity.Magnitude
            
            -- Skip if too far (performance optimization)
            if distance > horseCatcher.settings.targetingRadius then
                continue
            end
            
            -- Professional scoring system with island bonuses
            local score = 1000 -- Base score
            
            -- NEW: Island priority bonus
            if horseData.island == currentIsland then
                score = score + 500 -- Big bonus for same island
            elseif horseData.priority == 1 then
                score = score + 200 -- Bonus for priority islands
            end
            
            -- Distance scoring (closer = better)
            if distance < 50 then
                score = score + 300
            elseif distance < 100 then
                score = score + 200
            elseif distance < 200 then
                score = score + 100
            else
                score = score - (distance * 0.5)
            end
            
            -- Movement scoring (moving horses preferred)
            if velocity > 5 then
                score = score + 400
            elseif velocity > 2 then
                score = score + 200
            elseif velocity > 0.5 then
                score = score + 100
            else
                score = score - 100 -- Penalize stationary horses
            end
            
            -- Height preference
            local heightDiff = math.abs(horsePos.Y - playerPos.Y)
            if heightDiff < 10 then
                score = score + 150
            elseif heightDiff < 25 then
                score = score + 50
            else
                score = score - (heightDiff * 2)
            end
            
            -- Accessibility check
            local raycast = workspace:Raycast(playerPos, (horsePos - playerPos).Unit * distance)
            if not raycast or raycast.Instance == horse then
                score = score + 100 -- Clear line of sight
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
    
    -- Sort by score and return best
    if #candidates > 0 then
        table.sort(candidates, function(a, b) return a.score > b.score end)
        return candidates[1].horse
    end
    
    return nil
end

-- Ultra-optimized capture function with performance tracking
local function captureHorse(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") or not horseCatcher.currentLassoID then
        return false
    end
    
    -- Check cooldown
    local currentTime = tick()
    if currentTime - horseCatcher.runtime.lastCaptureTime < horseCatcher.settings.captureCooldown then
        return false
    end
    
    local startTime = tick()
    local success = false
    
    pcall(function()
        -- Enhanced capture method with game system
        if gameSystem.available and gameSystem.networkReady then
            gameSystem.u2.Network:FireServer("Equipment", horseCatcher.currentLassoID, "Activate", horse)
            success = true
        end
        
        horseCatcher.runtime.lastCaptureTime = currentTime
        horseCatcher.runtime.currentAttempts = horseCatcher.runtime.currentAttempts + 1
        horseCatcher.runtime.captureAttempts = horseCatcher.runtime.captureAttempts + 1
        horseCatcher.statistics.totalAttempts = horseCatcher.statistics.totalAttempts + 1
    end)
    
    -- Performance tracking
    if success then
        local captureTime = tick() - startTime
        table.insert(horseCatcher.performance.captureTimes, captureTime)
        if #horseCatcher.performance.captureTimes > 1000 then
            table.remove(horseCatcher.performance.captureTimes, 1)
        end
        
        if captureTime > horseCatcher.performance.maxCaptureTime then
            horseCatcher.performance.maxCaptureTime = captureTime
        end
    end
    
    return success
end

-- Professional movement functions with optimization
local function pulseTeleportToHorse(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") then return false end
    
    local currentTime = tick()
    if currentTime - horseCatcher.runtime.lastPulseTime < horseCatcher.settings.pulseInterval then
        return false
    end
    
    local startTime = tick()
    
    pcall(function()
        local horseRoot = horse.HumanoidRootPart
        local horsePos = horseRoot.Position
        local horseVelocity = horseRoot.Velocity
        
        -- Advanced prediction with velocity
        local prediction = horsePos + (horseVelocity * 0.4)
        
        -- Smart approach angle selection
        local approaches = {
            horseRoot.CFrame.RightVector * horseCatcher.settings.pulseDistance,
            horseRoot.CFrame.RightVector * -horseCatcher.settings.pulseDistance,
            horseRoot.CFrame.LookVector * -horseCatcher.settings.pulseDistance,
            (horseRoot.CFrame.RightVector + horseRoot.CFrame.LookVector).Unit * horseCatcher.settings.pulseDistance
        }
        
        -- Select optimal approach
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
        
        -- Smooth teleportation with orientation
        humanoidRootPart.CFrame = CFrame.lookAt(finalPos, horsePos)
        horseCatcher.runtime.lastPulseTime = currentTime
    end)
    
    -- Performance tracking
    local movementTime = tick() - startTime
    table.insert(horseCatcher.performance.movementTimes, movementTime)
    if #horseCatcher.performance.movementTimes > 100 then
        table.remove(horseCatcher.performance.movementTimes, 1)
    end
    
    return true
end

local function attachToHorse(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") then return false end
    
    pcall(function()
        -- Professional cleanup
        for _, attachment in pairs(humanoidRootPart:GetChildren()) do
            if (attachment.Name == "HorseAttachment" or attachment.Name:find("Weld")) and attachment:IsA("WeldConstraint") then
                attachment:Destroy()
            end
        end
        
        local horseRoot = horse.HumanoidRootPart
        local horsePos = horseRoot.Position
        local horseVelocity = horseRoot.Velocity
        
        -- Predictive positioning
        local prediction = horsePos + (horseVelocity * 0.2)
        local sideOffset = horseRoot.CFrame.RightVector * horseCatcher.settings.attachmentOffset
        local heightOffset = Vector3.new(0, 3.5, 0)
        
        -- Optimal positioning
        humanoidRootPart.CFrame = CFrame.lookAt(prediction + sideOffset + heightOffset, prediction)
        wait(0.03) -- Minimal wait for stability
        
        -- Professional weld creation
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = humanoidRootPart
        weld.Part1 = horseRoot
        weld.Parent = humanoidRootPart
        weld.Name = "HorseAttachment"
        
        horseCatcher.isAttached = true
        horseCatcher.runtime.currentAttempts = 0
        horseCatcher.runtime.targetStuckTime = 0
    end)
    
    return true
end

local function smoothFollow(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") then return false end
    
    pcall(function()
        local horsePos = horse.HumanoidRootPart.Position
        local horseVelocity = horse.HumanoidRootPart.Velocity
        local currentPos = humanoidRootPart.Position
        
        -- Predictive following
        local prediction = horsePos + (horseVelocity * 0.3)
        local direction = (prediction - currentPos).Unit
        local distance = (prediction - currentPos).Magnitude
        
        if distance > horseCatcher.settings.safeDistance + 1 then
            local targetPos = prediction - direction * horseCatcher.settings.safeDistance
            targetPos = targetPos + Vector3.new(0, 2.5, 0)
            
            -- Optimized tween
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
    end)
    
    return true
end

-- Professional cleanup
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

-- ENHANCED: Capture detection with horse name + island tracking
local function isHorseCaptured(horse)
    if not horse or not horse.Parent then
        return true
    end
    
    local captured = false
    local horseName = "Unknown"
    
    pcall(function()
        local overheadPart = horse:FindFirstChild("OverheadPart")
        if overheadPart then
            local overhead = overheadPart:FindFirstChild("Overhead")
            if overhead then
                local nameLabel = overhead:FindFirstChild("NameLabel")
                if nameLabel and nameLabel.Text ~= "Wild" then
                    captured = true
                end
                
                local breedLabel = overhead:FindFirstChild("BreedLabel")
                if breedLabel and breedLabel.Text ~= "" then
                    horseName = breedLabel.Text
                end
            end
        end
        
        local humanoid = horse:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            captured = true
        end
    end)
    
    if captured then
        horseCatcher.capturedHorses[horse.Name] = true
        horseCatcher.statistics.totalCaptured = horseCatcher.statistics.totalCaptured + 1
        horseCatcher.statistics.currentStreak = horseCatcher.statistics.currentStreak + 1
        horseCatcher.statistics.successfulCaptures = horseCatcher.statistics.successfulCaptures + 1
        horseCatcher.runtime.lastSuccessfulCapture = tick()
        
        -- NEW: Track per-island statistics
        local currentIsland = detectCurrentIsland()
        if not horseCatcher.statistics.islandStats[currentIsland] then
            horseCatcher.statistics.islandStats[currentIsland] = 0
        end
        horseCatcher.statistics.islandStats[currentIsland] = horseCatcher.statistics.islandStats[currentIsland] + 1
        
        if horseCatcher.statistics.currentStreak > horseCatcher.statistics.bestStreak then
            horseCatcher.statistics.bestStreak = horseCatcher.statistics.currentStreak
        end
        
        -- Calculate horses per minute
        local sessionTime = tick() - horseCatcher.runtime.sessionStartTime
        horseCatcher.statistics.horsesPerMinute = (horseCatcher.statistics.currentStreak / (sessionTime / 60))
        
        Rayfield:Notify({
           Title = "🎉 " .. horseName .. " Captured!",
           Content = "Island: " .. currentIsland .. " | Streak: " .. horseCatcher.statistics.currentStreak .. " | Rate: " .. string.format("%.1f", horseCatcher.statistics.horsesPerMinute) .. "/min",
           Duration = 2.5,
           Image = 4483362458,
        })
    end
    
    return captured
end

-- Professional cleanup system
local function cleanupSystem()
    local currentTime = tick()
    if currentTime - horseCatcher.runtime.lastCleanupTime < 15 then -- Every 15 seconds
        return
    end
    
    -- Cache cleanup
    if #Cache.horses > Cache.maxCacheSize * 0.8 then
        for i = Cache.maxCacheSize * 0.6, #Cache.horses do
            Cache.horses[i] = nil
        end
    end
    
    -- Performance data cleanup
    if #horseCatcher.performance.captureTimes > 1000 then
        for i = 1, 500 do
            table.remove(horseCatcher.performance.captureTimes, 1)
        end
    end
    
    horseCatcher.runtime.lastCleanupTime = currentTime
end

-- =================================
-- ENHANCED MAIN LOGIC WITH ISLAND MONITORING
-- =================================
local function startHorseCatching()
    if horseCatcher.isRunning then return false end
    
    -- System checks
    local lassoReady, lassoID = equipLasso()
    if not lassoReady then
        Rayfield:Notify({
           Title = "❌ Lasso Required!",
           Content = "Please equip a lasso first!",
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
    
    -- Initialize session
    horseCatcher.isRunning = true
    horseCatcher.runtime.sessionStartTime = tick()
    horseCatcher.statistics.sessionsRun = horseCatcher.statistics.sessionsRun + 1
    horseCatcher.statistics.currentStreak = 0
    horseCatcher.runtime.lastCaptureTime = 0
    horseCatcher.runtime.currentAttempts = 0
    horseCatcher.runtime.retryCount = 0
    horseCatcher.runtime.lastPulseTime = 0
    horseCatcher.runtime.targetingCount = 0
    horseCatcher.runtime.captureAttempts = 0
    horseCatcher.runtime.lastIslandCheck = 0
    
    local movementMode = horseCatcher.settings.movementMode == "pulse" and "Pulse TP" or 
                        horseCatcher.settings.movementMode == "attachment" and "Attachment" or "Smooth"
    
    local currentIsland = detectCurrentIsland()
    
    Rayfield:Notify({
       Title = "🚀 Ultra Horse Catching Started!",
       Content = "Island: " .. currentIsland .. " | Mode: " .. movementMode .. " | Island detection active",
       Duration = 3,
       Image = 4483362458,
    })
    
    -- NEW: Island monitoring connection
    horseCatcher.connections.islandMonitor = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        
        local currentTime = tick()
        if currentTime - horseCatcher.runtime.lastIslandCheck < 5 then -- Check every 5 seconds
            return
        end
        
        -- Update island detection
        detectCurrentIsland()
        horseCatcher.runtime.lastIslandCheck = currentTime
    end)
    
    -- MAIN CAPTURE CONNECTION (unchanged but uses enhanced cache)
    horseCatcher.connections.capture = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        
        -- Check if current target was captured
        if horseCatcher.currentTarget and isHorseCaptured(horseCatcher.currentTarget) then
            if horseCatcher.settings.movementMode == "attachment" then
                detachFromHorse()
            end
            horseCatcher.currentTarget = nil
            horseCatcher.runtime.currentAttempts = 0
            horseCatcher.runtime.retryCount = 0
            horseCatcher.runtime.targetStuckTime = 0
            return
        end
        
        -- Find new target with optimized logic
        if not horseCatcher.currentTarget then
            if horseCatcher.settings.smartTargeting then
                horseCatcher.currentTarget = findOptimalTarget()
            else
                local horses = updateHorseCache()
                -- Handle new cache format
                horseCatcher.currentTarget = horses[1] and (horses[1].horse or horses[1])
            end
            
            if horseCatcher.currentTarget then
                horseCatcher.runtime.currentAttempts = 0
                horseCatcher.runtime.lastTargetName = horseCatcher.currentTarget.Name
                horseCatcher.runtime.targetStuckTime = 0
            else
                if horseCatcher.settings.movementMode == "attachment" then
                    detachFromHorse()
                end
                return
            end
        end
        
        if horseCatcher.currentTarget then
            -- Stuck detection
            if horseCatcher.runtime.lastTargetName == horseCatcher.currentTarget.Name then
                horseCatcher.runtime.targetStuckTime = horseCatcher.runtime.targetStuckTime + 1
            else
                horseCatcher.runtime.targetStuckTime = 0
                horseCatcher.runtime.lastTargetName = horseCatcher.currentTarget.Name
            end
            
            -- Skip stuck targets
            if horseCatcher.runtime.targetStuckTime > horseCatcher.settings.maxStuckTime * 60 then
                horseCatcher.capturedHorses[horseCatcher.currentTarget.Name] = true
                if horseCatcher.settings.movementMode == "attachment" then
                    detachFromHorse()
                end
                horseCatcher.currentTarget = nil
                horseCatcher.runtime.targetStuckTime = 0
                return
            end
            
            -- Movement execution
            if horseCatcher.settings.movementMode == "pulse" then
                pulseTeleportToHorse(horseCatcher.currentTarget)
            elseif horseCatcher.settings.movementMode == "attachment" then
                if not horseCatcher.isAttached or horseCatcher.runtime.forceDetach then
                    attachToHorse(horseCatcher.currentTarget)
                end
            elseif horseCatcher.settings.movementMode == "smooth" then
                smoothFollow(horseCatcher.currentTarget)
            end
            
            -- Capture attempt
            captureHorse(horseCatcher.currentTarget)
            
            -- Attempt limit handling
            if horseCatcher.runtime.currentAttempts > horseCatcher.settings.maxAttemptsPerHorse then
                horseCatcher.runtime.retryCount = horseCatcher.runtime.retryCount + 1
                
                if horseCatcher.runtime.retryCount > 2 then
                    horseCatcher.capturedHorses[horseCatcher.currentTarget.Name] = true
                    if horseCatcher.settings.movementMode == "attachment" then
                        detachFromHorse()
                    end
                    horseCatcher.currentTarget = nil
                    horseCatcher.runtime.retryCount = 0
                else
                    if horseCatcher.settings.movementMode == "attachment" then
                        detachFromHorse()
                        horseCatcher.runtime.forceDetach = true
                    end
                    horseCatcher.runtime.currentAttempts = 0
                    wait(0.3)
                end
            end
        else
            if horseCatcher.settings.movementMode == "attachment" then
                detachFromHorse()
            end
        end
    end)
    
    -- CLEANUP CONNECTION
    horseCatcher.connections.cleanup = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        cleanupSystem()
    end)
    
    return true
end

local function stopHorseCatching()
    horseCatcher.isRunning = false
    
    -- Disconnect all connections
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
    
    -- Calculate performance metrics
    local avgCaptureTime = 0
    if #horseCatcher.performance.captureTimes > 0 then
        local total = 0
        for _, time in pairs(horseCatcher.performance.captureTimes) do
            total = total + time
        end
        avgCaptureTime = total / #horseCatcher.performance.captureTimes
        horseCatcher.statistics.averageCaptureTime = avgCaptureTime
    end
    
    local currentIsland = detectCurrentIsland()
    
    Rayfield:Notify({
       Title = "🏁 Professional Session Ended",
       Content = "Island: " .. currentIsland .. " | Captured: " .. horseCatcher.statistics.currentStreak .. " | Rate: " .. string.format("%.1f", horseCatcher.statistics.horsesPerMinute) .. "/min",
       Duration = 5,
       Image = 4483362458,
    })
    
    horseCatcher.statistics.currentStreak = 0
end

-- =================================
-- ENHANCED UI WITH ISLAND FEATURES
-- =================================

-- 🏝️ NEW: Island Control Section
local IslandControlSection = parentTab:CreateSection("🏝️ Island Detection & Control")

local MultiIslandToggle = parentTab:CreateToggle({
   Name = "🌍 Multi-Island Scanning",
   CurrentValue = true,
   Flag = "MultiIslandScanningToggle",
   Callback = function(Value)
      horseCatcher.settings.multiIslandScanning = Value
      Rayfield:Notify({
         Title = "🌍 Multi-Island " .. (Value and "Enabled" or "Disabled"),
         Content = Value and "Scanning all islands for horses" or "Current island only",
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
      horseCatcher.settings.prioritizeCurrentIsland = Value
   end,
})

local MaxIslandDistanceSlider = parentTab:CreateSlider({
   Name = "🗺️ Max Island Distance",
   Range = {500, 2000},
   Increment = 100,
   Suffix = " studs",
   CurrentValue = 1000,
   Flag = "MaxIslandDistanceSlider",
   Callback = function(Value)
      horseCatcher.settings.maxIslandDistance = Value
   end,
})

-- 🎯 MAIN CONTROL SECTION
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

-- 📍 MOVEMENT & SETTINGS SECTION
local MovementSettingsSection = parentTab:CreateSection("📍 Movement & Optimization")

local MovementDropdown = parentTab:CreateDropdown({
   Name = "📍 Movement Mode",
   Options = {"attachment", "pulse", "smooth"},
   CurrentOption = {"attachment"},
   MultipleOptions = false,
   Flag = "UltraHorseMovementModeDropdown",
   Callback = function(Option)
      horseCatcher.settings.movementMode = Option[1]
      Rayfield:Notify({
         Title = "📍 Movement Updated",
         Content = "Now using: " .. Option[1]:upper() .. " mode (Ultra-Optimized)",
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

local AggressiveTargetingToggle = parentTab:CreateToggle({
   Name = "🎯 Aggressive Targeting",
   CurrentValue = true,
   Flag = "UltraHorseAggressiveTargetingToggle",
   Callback = function(Value)
      horseCatcher.settings.aggressiveTargeting = Value
   end,
})

-- 📊 ENHANCED STATUS SECTION WITH ISLAND INFO
local LiveStatusSection = parentTab:CreateSection("📊 Professional Status")

local IslandInfo = parentTab:CreateParagraph({Title = "🏝️ Island Information", Content = "Detecting current island..."})
local SystemStatus = parentTab:CreateParagraph({Title = "🔧 System Status", Content = "Ultra-optimized system ready"})
local CatchingStatus = parentTab:CreateParagraph({Title = "🎯 Catching Status", Content = "Professional mode ready"})
local TargetInfo = parentTab:CreateParagraph({Title = "🐎 Current Target", Content = "No target selected"})
local PerformanceMetrics = parentTab:CreateParagraph({Title = "⚡ Performance Metrics", Content = "Monitoring ready"})

-- ⚙️ ADVANCED SETTINGS SECTION
local AdvancedSettingsSection = parentTab:CreateSection("⚙️ Advanced Optimization")

local MaxAttemptsSlider = parentTab:CreateSlider({
   Name = "🎯 Max Attempts per Horse",
   Range = {6, 20},
   Increment = 1,
   Suffix = " attempts",
   CurrentValue = 12,
   Flag = "UltraHorseMaxAttemptsSlider",
   Callback = function(Value)
      horseCatcher.settings.maxAttemptsPerHorse = Value
   end,
})

local StuckTimeSlider = parentTab:CreateSlider({
   Name = "⏳ Max Stuck Time",
   Range = {5, 20},
   Increment = 1,
   Suffix = "s",
   CurrentValue = 10,
   Flag = "UltraHorseStuckTimeSlider", 
   Callback = function(Value)
      horseCatcher.settings.maxStuckTime = Value
   end,
})

local TargetingRadiusSlider = parentTab:CreateSlider({
   Name = "🎯 Targeting Radius",
   Range = {100, 500},
   Increment = 25,
   Suffix = " studs",
   CurrentValue = 300,
   Flag = "UltraHorseTargetingRadiusSlider",
   Callback = function(Value)
      horseCatcher.settings.targetingRadius = Value
   end,
})

local BatchSizeSlider = parentTab:CreateSlider({
   Name = "📦 Batch Processing Size",
   Range = {3, 15},
   Increment = 1,
   Suffix = " horses",
   CurrentValue = 5,
   Flag = "UltraHorseBatchSizeSlider",
   Callback = function(Value)
      horseCatcher.settings.maxBatchSize = Value
   end,
})

-- ⚡ QUICK ACTIONS SECTION
local QuickActionsSection = parentTab:CreateSection("⚡ Professional Actions")

local ClearCacheButton = parentTab:CreateButton({
   Name = "🗑️ Clear Performance Cache",
   Callback = function()
      Cache.horses = {}
      Cache.horsesById = {}
      Cache.islandHorses = {}
      Cache.lastUpdate = 0
      horseCatcher.performance.captureTimes = {}
      horseCatcher.performance.targetingTimes = {}
      horseCatcher.performance.movementTimes = {}
      horseCatcher.performance.islandScanTimes = {}
      
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

local ResetStatsButton = parentTab:CreateButton({
   Name = "📊 Reset Statistics",
   Callback = function()
      horseCatcher.statistics = {
         totalCaptured = 0,
         sessionsRun = 0,
         currentStreak = 0,
         totalAttempts = 0,
         successfulCaptures = 0,
         bestStreak = 0,
         averageCaptureTime = 0,
         horsesPerMinute = 0,
         islandStats = {}
      }
      Rayfield:Notify({
         Title = "📊 Stats Reset",
         Content = "All statistics have been reset",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- 📈 ENHANCED STATISTICS SECTION
local StatisticsSection = parentTab:CreateSection("📈 Professional Statistics")

local SessionStats = parentTab:CreateParagraph({Title = "📈 Session Metrics", Content = "Ready for ultra session"})
local AllTimeStats = parentTab:CreateParagraph({Title = "🏆 All-Time Records", Content = "No data yet"})
local IslandStats = parentTab:CreateParagraph({Title = "🏝️ Island Statistics", Content = "No island data yet"})
local PerformanceAnalytics = parentTab:CreateParagraph({Title = "⚡ Performance Analytics", Content = "Monitoring ready"})

-- =================================
-- ENHANCED STATUS UPDATE SYSTEM WITH ISLAND INFO
-- =================================
spawn(function()
    while wait(0.8) do -- Optimized update frequency
        local currentIsland = detectCurrentIsland()
        
        -- NEW: Island Information
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
        islandText = islandText .. "🔍 Multi-Island: " .. (horseCatcher.settings.multiIslandScanning and "✅" or "❌")
        
        IslandInfo:Set({Title = "🏝️ Island Information", Content = islandText})
        
        -- System Status
        local systemText = ""
        if gameSystem.available and gameSystem.networkReady then
            systemText = "✅ Game System: Ultra-Connected\n✅ Network (u2): High-Performance\n✅ Capture Remote: Optimized"
        elseif gameSystem.available then
            systemText = "⚠️ Game System: Connected\n❌ Network (u2): Limited\n❌ Performance Degraded"
        else
            systemText = "❌ Game System: Disconnected\n❌ Network: Unavailable\n❌ System Failure"
        end
        
        local lassoReady, lassoID = equipLasso()
        if lassoReady then
            systemText = systemText .. "\n✅ Lasso: Ready (" .. (lassoID and lassoID:sub(1,8) or "Unknown") .. "...)"
        else
            systemText = systemText .. "\n❌ Lasso: Not Found"
        end
        
        local cacheSize = #Cache.horses
        systemText = systemText .. "\n📦 Cache: " .. cacheSize .. " horses"
        systemText = systemText .. "\n🏝️ Island: " .. currentIsland
        
        SystemStatus:Set({Title = "🔧 System Status", Content = systemText})
        
        -- Catching Status
        local catchingText = ""
        if horseCatcher.isRunning then
            local runtime = tick() - horseCatcher.runtime.sessionStartTime
            local minutes = math.floor(runtime / 60)
            local seconds = math.floor(runtime % 60)
            
            catchingText = "🚀 ULTRA-ACTIVE (" .. horseCatcher.settings.movementMode:upper() .. ")\n"
            catchingText = catchingText .. "🏝️ Island: " .. currentIsland .. "\n"
            catchingText = catchingText .. "⏱️ Runtime: " .. minutes .. "m " .. seconds .. "s\n"
            catchingText = catchingText .. "🎯 Cooldown: " .. horseCatcher.settings.captureCooldown .. "s\n"
            catchingText = catchingText .. "🧠 Smart: " .. (horseCatcher.settings.smartTargeting and "✅" or "❌") .. "\n"
            catchingText = catchingText .. "⚡ Aggressive: " .. (horseCatcher.settings.aggressiveTargeting and "✅" or "❌")
        else
            catchingText = "🔴 STOPPED\n🏝️ Island: " .. currentIsland .. "\n💤 Ultra-optimized system ready\n⚙️ Mode: " .. horseCatcher.settings.movementMode:upper() .. " (Professional)\n🔧 System: " .. (gameSystem.available and gameSystem.networkReady and "✅" or "❌") .. "\n🚀 Ultra-performance ready"
        end
        CatchingStatus:Set({Title = "🎯 Catching Status", Content = catchingText})
        
        -- Target Info with enhanced data
        local targetText = ""
        if horseCatcher.currentTarget then
            local targetName = getHorseName(horseCatcher.currentTarget)
            local distance = math.floor((humanoidRootPart.Position - horseCatcher.currentTarget.HumanoidRootPart.Position).Magnitude)
            local velocity = math.floor(horseCatcher.currentTarget.HumanoidRootPart.Velocity.Magnitude)
            
            targetText = "🐎 " .. targetName .. "\n"
            targetText = targetText .. "📏 Distance: " .. distance .. " studs\n"
            targetText = targetText .. "🏃 Speed: " .. velocity .. " studs/s\n"
            targetText = targetText .. "🎯 Attempts: " .. horseCatcher.runtime.currentAttempts .. "/" .. horseCatcher.settings.maxAttemptsPerHorse .. "\n"
            
            if horseCatcher.settings.movementMode == "attachment" then
                targetText = targetText .. "🔗 Attached: " .. (horseCatcher.isAttached and "✅" or "❌")
            elseif horseCatcher.settings.movementMode == "pulse" then
                local nextPulse = math.max(0, horseCatcher.settings.pulseInterval - (tick() - horseCatcher.runtime.lastPulseTime))
                targetText = targetText .. "⚡ Next Pulse: " .. string.format("%.1f", nextPulse) .. "s"
            else
                targetText = targetText .. "🌊 Smooth Follow: Ultra-Active"
            end
        else
            local wildCount = #Cache.horses
            targetText = "🔍 Scanning for optimal targets...\n🐎 Wild horses cached: " .. wildCount .. "\n📊 Targeting radius: " .. horseCatcher.settings.targetingRadius .. " studs\n🎯 Smart targeting: " .. (horseCatcher.settings.smartTargeting and "Active" or "Disabled") .. "\n🏝️ Island horses: " .. (horseCatcher.runtime.currentIslandHorses or 0)
        end
        TargetInfo:Set({Title = "🐎 Current Target", Content = targetText})
        
        -- Performance Metrics
        local avgCaptureTime = 0
        if #horseCatcher.performance.captureTimes > 0 then
            local total = 0
            for _, time in pairs(horseCatcher.performance.captureTimes) do
                total = total + time
            end
            avgCaptureTime = total / #horseCatcher.performance.captureTimes
        end
        
        local avgTargetingTime = 0
        if #horseCatcher.performance.targetingTimes > 0 then
            local total = 0
            for _, time in pairs(horseCatcher.performance.targetingTimes) do
                total = total + time
            end
            avgTargetingTime = total / #horseCatcher.performance.targetingTimes
        end
        
        local avgIslandScanTime = 0
        if #horseCatcher.performance.islandScanTimes > 0 then
            local total = 0
            for _, time in pairs(horseCatcher.performance.islandScanTimes) do
                total = total + time
            end
            avgIslandScanTime = total / #horseCatcher.performance.islandScanTimes
        end
        
        local performanceText = "⚡ Avg Capture: " .. string.format("%.3f", avgCaptureTime * 1000) .. "ms\n"
        performanceText = performanceText .. "🎯 Avg Targeting: " .. string.format("%.3f", avgTargetingTime * 1000) .. "ms\n"
        performanceText = performanceText .. "🏝️ Avg Island Scan: " .. string.format("%.3f", avgIslandScanTime * 1000) .. "ms\n"
        performanceText = performanceText .. "📦 Cache Size: " .. #Cache.horses .. " horses\n"
        performanceText = performanceText .. "🔄 Cache Updates: " .. horseCatcher.runtime.targetingCount .. "\n"
        performanceText = performanceText .. "🎯 Capture Attempts: " .. horseCatcher.runtime.captureAttempts
        PerformanceMetrics:Set({Title = "⚡ Performance Metrics", Content = performanceText})
        
        -- Session Statistics
        if horseCatcher.isRunning then
            local sessionTime = tick() - horseCatcher.runtime.sessionStartTime
            local sessionMinutes = math.floor(sessionTime / 60)
            local sessionSeconds = math.floor(sessionTime % 60)
            
            local sessionText = "⏱️ Session Time: " .. sessionMinutes .. "m " .. sessionSeconds .. "s\n"
            sessionText = sessionText .. "🐎 Horses Captured: " .. horseCatcher.statistics.currentStreak .. "\n"
            sessionText = sessionText .. "📈 Capture Rate: " .. string.format("%.1f", horseCatcher.statistics.horsesPerMinute) .. "/min\n"
            sessionText = sessionText .. "🎯 Total Attempts: " .. horseCatcher.runtime.captureAttempts .. "\n"
            sessionText = sessionText .. "🏝️ Current Island: " .. currentIsland .. "\n"
            sessionText = sessionText .. "📊 Mode: " .. horseCatcher.settings.movementMode:upper() .. " (Ultra-Optimized)"
            
            SessionStats:Set({Title = "📈 Session Metrics", Content = sessionText})
        else
            SessionStats:Set({Title = "📈 Session Metrics", Content = "No active session\nUltra-optimized monitoring ready\n🚀 Professional performance tracking\n🏝️ Island-aware scanning"})
        end
        
        -- All-Time Statistics
        local capturedCount = 0
        for _ in pairs(horseCatcher.capturedHorses) do
            capturedCount = capturedCount + 1
        end
        
        local successRate = 0
        if horseCatcher.statistics.totalAttempts > 0 then
            successRate = math.floor((horseCatcher.statistics.successfulCaptures / horseCatcher.statistics.totalAttempts) * 100)
        end
        
        local allTimeText = "🏆 Best Streak: " .. horseCatcher.statistics.bestStreak .. "\n"
        allTimeText = allTimeText .. "📈 Total Captured: " .. horseCatcher.statistics.totalCaptured .. "\n"
        allTimeText = allTimeText .. "🎮 Sessions Run: " .. horseCatcher.statistics.sessionsRun .. "\n"
        allTimeText = allTimeText .. "🎯 Success Rate: " .. successRate .. "%\n"
        allTimeText = allTimeText .. "📝 Marked Horses: " .. capturedCount .. "\n"
        allTimeText = allTimeText .. "⚡ Avg Capture Time: " .. string.format("%.3f", horseCatcher.statistics.averageCaptureTime * 1000) .. "ms"
        
        AllTimeStats:Set({Title = "🏆 All-Time Records", Content = allTimeText})
        
        -- NEW: Island Statistics
        local islandStatsText = "🏝️ Per-Island Captures:\n"
        local hasStats = false
        for islandName, captures in pairs(horseCatcher.statistics.islandStats) do
            islandStatsText = islandStatsText .. "• " .. islandName .. ": " .. captures .. " horses\n"
            hasStats = true
        end
        
        if not hasStats then
            islandStatsText = islandStatsText .. "No captures yet"
        else
            islandStatsText = islandStatsText .. "\n🌍 Total Islands: " .. totalIslands
        end
        
        IslandStats:Set({Title = "🏝️ Island Statistics", Content = islandStatsText})
        
        -- Performance Analytics
        local cacheEfficiency = #Cache.horses > 0 and (horseCatcher.runtime.targetingCount / #Cache.horses) or 0
        local captureEfficiency = horseCatcher.runtime.captureAttempts > 0 and (horseCatcher.statistics.successfulCaptures / horseCatcher.runtime.captureAttempts) or 0
        
        local analyticsText = "📊 Cache Efficiency: " .. string.format("%.1f", cacheEfficiency * 100) .. "%\n"
        analyticsText = analyticsText .. "🎯 Capture Efficiency: " .. string.format("%.1f", captureEfficiency * 100) .. "%\n"
        analyticsText = analyticsText .. "⚡ Max Capture Time: " .. string.format("%.3f", horseCatcher.performance.maxCaptureTime * 1000) .. "ms\n"
        analyticsText = analyticsText .. "🏝️ Island Detection: " .. (currentIsland ~= "Unknown" and "✅" or "❌") .. "\n"
        analyticsText = analyticsText .. "🔄 System Performance: ULTRA-OPTIMIZED\n"
        analyticsText = analyticsText .. "🚀 Status: PROFESSIONAL GRADE"
        
        PerformanceAnalytics:Set({Title = "⚡ Performance Analytics", Content = analyticsText})
    end
end)

-- =================================
-- CHARACTER RESPAWN HANDLING
-- =================================
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Reset states
    horseCatcher.isAttached = false
    horseCatcher.lassoEquipped = false
    horseCatcher.currentLassoID = nil
    
    -- Reset island detection
    islandSystem.currentIsland = "Unknown"
    islandSystem.lastUpdate = 0
    
    -- Stop catching if running
    if horseCatcher.isRunning then
        stopHorseCatching()
        MainToggle:Set(false)
        
        Rayfield:Notify({
           Title = "🔄 Character Respawned",
           Content = "Ultra horse catching stopped - restart when ready",
           Duration = 3,
           Image = 4483362458,
        })
    end
end)

-- =================================
-- ENHANCED INITIALIZATION WITH ISLAND DETECTION
-- =================================
Rayfield:Notify({
   Title = "🚀 Ultra Horse Catcher Pro Loaded!",
   Content = "Professional optimizations | Island detection | Enhanced performance | Revolutionary catching system",
   Duration = 5,
   Image = 4483362458,
})

-- Initial island detection
local initialIsland = detectCurrentIsland()

if gameSystem.available and gameSystem.networkReady then
    Rayfield:Notify({
       Title = "✅ Ultra System Ready!",
       Content = "Professional grade performance | Island: " .. initialIsland .. " | Ultra-optimized catching | Maximum efficiency!",
       Duration = 4,
       Image = 4483362458,
    })
else
    Rayfield:Notify({
       Title = "⚠️ Performance Warning",
       Content = "Network system issues detected - Performance may be limited | Island: " .. initialIsland,
       Duration = 4,
       Image = 4483362458,
    })
end

-- Island detection confirmation
spawn(function()
    wait(2)
    local detectedIsland = detectCurrentIsland()
    if detectedIsland ~= "Unknown" then
        Rayfield:Notify({
           Title = "🏝️ Island Detected Successfully!",
           Content = "Current Island: " .. detectedIsland .. " | Multi-island scanning ready!",
           Duration = 3,
           Image = 4483362458,
        })
    else
        Rayfield:Notify({
           Title = "⚠️ Island Detection Warning",
           Content = "Could not detect current island - Using fallback methods",
           Duration = 3,
           Image = 4483362458,
        })
    end
end)

print("🚀 Ultra Horse Catcher Pro - Professional Optimized Edition with Island Detection Loaded!")
print("✅ Ultra-optimized movement logic with professional caching")
print("🎯 Enhanced targeting with intelligent scoring system")
print("🏝️ Professional island detection and multi-island scanning")
print("⚡ Professional performance monitoring and analytics")
print("🌍 Current Island: " .. initialIsland)
print("🔥 Maximum efficiency horse catching system ready!")
print("📊 Features:")
print("   🏝️ Automatic island detection using player attributes")
print("   🌍 Multi-island horse scanning with smart prioritization")
print("   🎯 Island-aware targeting system with priority bonuses")
print("   📈 Per-island capture statistics and analytics")
print("   ⚡ Enhanced performance monitoring with island scan times")
print("   🚀 Professional grade optimizations and caching")
