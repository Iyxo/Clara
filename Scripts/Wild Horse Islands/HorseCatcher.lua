-- Horse Catcher Pro - Ultra-Optimized with Auto Lasso Edition
-- by Iyxo - 2025-07-22 09:05:15
-- Revolutionary horse catching with Remote Event + Auto Lasso Throw methods

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
-- PROFESSIONAL CACHING SYSTEM
-- =================================
local Cache = {
    horses = {},
    horsesById = {},
    lastUpdate = 0,
    updateInterval = 1.5,
    maxCacheSize = 500
}

-- =================================
-- ULTRA-OPTIMIZED HORSE CATCHER SYSTEM
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
        autoLasso = nil
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
        autoLassoThrows = 0
    },
    
    -- Optimized settings
    settings = {
        -- Capture method selection
        captureMethod = "autolasso", -- "remoteevent" or "autolasso"
        
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
        
        -- Auto Lasso settings (optimized)
        autoLassoInterval = 0.3, -- Optimized interval to reduce lag
        autoLassoRange = 50, -- Reasonable range
        autoLassoMaxThrows = 5, -- Limit throws per target to prevent spam
        
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
        lastAutoLassoTime = 0,
        currentAttempts = 0,
        retryCount = 0,
        targetStuckTime = 0,
        lastTargetName = "",
        sessionStartTime = 0,
        lastSuccessfulCapture = 0,
        forceDetach = false,
        targetingCount = 0,
        captureAttempts = 0,
        autoLassoCount = 0,
        targetThrowCount = {} -- Track throws per target
    },
    
    -- Performance monitoring
    performance = {
        captureTimes = {},
        targetingTimes = {},
        movementTimes = {},
        autoLassoTimes = {},
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
-- ULTRA-OPTIMIZED HORSE FUNCTIONS
-- =================================

-- Professional horse name getter with caching
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

-- Ultra-fast wild horse checker with caching
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

-- Professional cache management
local function updateHorseCache()
    local currentTime = tick()
    if currentTime - Cache.lastUpdate < Cache.updateInterval then
        return Cache.horses
    end
    
    local startTime = tick()
    Cache.horses = {}
    local horseCount = 0
    
    local function scanLocation(location)
        if not location then return end
        
        local children = location:GetChildren()
        for i = 1, #children do
            local child = children[i]
            
            if child.Name:find("{") and child:FindFirstChild("HumanoidRootPart") then
                local humanoid = child:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 and not Players:GetPlayerFromCharacter(child) then
                    if isWildHorse(child) and not horseCatcher.capturedHorses[child.Name] then
                        horseCount = horseCount + 1
                        Cache.horses[horseCount] = child
                        
                        if horseCount >= Cache.maxCacheSize then
                            break
                        end
                    end
                end
            end
        end
    end
    
    pcall(function()
        if Workspace.Islands then
            if Workspace.Islands.Mainland then
                scanLocation(Workspace.Islands.Mainland)
            end
            scanLocation(Workspace.Islands)
        end
    end)
    
    Cache.lastUpdate = currentTime
    
    local scanTime = tick() - startTime
    table.insert(horseCatcher.performance.targetingTimes, scanTime)
    if #horseCatcher.performance.targetingTimes > 100 then
        table.remove(horseCatcher.performance.targetingTimes, 1)
    end
    
    horseCatcher.runtime.targetingCount = horseCatcher.runtime.targetingCount + 1
    
    return Cache.horses
end

-- Professional lasso detection
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
                    gameSystem.u2.Network:FireServer("Inventory", "Use", lastEquipped)
                    success = true
                    toolID = lastEquipped
                end)
            end
        end
    end
    
    if not success then
        toolID = "{60769f1f-cade-463b-ae32-adaacc91116f}"
        success = true
    end
    
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

-- =================================
-- AUTO LASSO SYSTEM - OPTIMIZED
-- =================================

-- Find nearest horse for Auto Lasso (optimized)
local function findNearestHorseForAutoLasso()
    local nearestHorse = nil
    local shortestDistance = math.huge
    local playerPos = humanoidRootPart.Position
    
    -- Use cached horses for performance
    local horses = Cache.horses
    for i = 1, math.min(#horses, 10) do -- Limit to first 10 for performance
        local horse = horses[i]
        if horse and horse:FindFirstChild("HumanoidRootPart") then
            local distance = (playerPos - horse.HumanoidRootPart.Position).Magnitude
            
            -- Check range and throw limits
            if distance <= horseCatcher.settings.autoLassoRange and distance < shortestDistance then
                local throwCount = horseCatcher.runtime.targetThrowCount[horse.Name] or 0
                if throwCount < horseCatcher.settings.autoLassoMaxThrows then
                    shortestDistance = distance
                    nearestHorse = horse
                end
            end
        end
    end
    
    return nearestHorse
end

-- OPTIMIZED Auto Lasso Throw function
local function autoLassoThrow()
    if horseCatcher.settings.captureMethod ~= "autolasso" then return end
    
    local currentTime = tick()
    if currentTime - horseCatcher.runtime.lastAutoLassoTime < horseCatcher.settings.autoLassoInterval then
        return
    end
    
    local startTime = tick()
    local nearestHorse = findNearestHorseForAutoLasso()
    
    if nearestHorse and gameSystem.available and gameSystem.networkReady then
        pcall(function()
            local currentEquipment = horseCatcher.currentLassoID
            if currentEquipment then
                -- Fire the lasso
                gameSystem.u2.Network:FireServer("Equipment", currentEquipment, "Activate", nearestHorse)
                
                -- Track throws per target
                horseCatcher.runtime.targetThrowCount[nearestHorse.Name] = (horseCatcher.runtime.targetThrowCount[nearestHorse.Name] or 0) + 1
                
                horseCatcher.runtime.lastAutoLassoTime = currentTime
                horseCatcher.runtime.autoLassoCount = horseCatcher.runtime.autoLassoCount + 1
                horseCatcher.statistics.autoLassoThrows = horseCatcher.statistics.autoLassoThrows + 1
            end
        end)
    end
    
    -- Performance tracking
    local autoLassoTime = tick() - startTime
    table.insert(horseCatcher.performance.autoLassoTimes, autoLassoTime)
    if #horseCatcher.performance.autoLassoTimes > 100 then
        table.remove(horseCatcher.performance.autoLassoTimes, 1)
    end
end

-- =================================
-- ORIGINAL CAPTURE METHODS
-- =================================

-- Ultra-optimized horse finding with intelligent scoring
local function findOptimalTarget()
    local horses = updateHorseCache()
    if #horses == 0 then return nil end
    
    local playerPos = humanoidRootPart.Position
    local candidates = {}
    
    for i = 1, math.min(#horses, horseCatcher.settings.maxBatchSize * 2) do
        local horse = horses[i]
        if horse and horse:FindFirstChild("HumanoidRootPart") then
            local horsePos = horse.HumanoidRootPart.Position
            local distance = (playerPos - horsePos).Magnitude
            local velocity = horse.HumanoidRootPart.Velocity.Magnitude
            
            if distance > horseCatcher.settings.targetingRadius then
                continue
            end
            
            local score = 1000
            
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
                velocity = velocity
            })
        end
    end
    
    if #candidates > 0 then
        table.sort(candidates, function(a, b) return a.score > b.score end)
        return candidates[1].horse
    end
    
    return nil
end

-- Remote Event capture function
local function captureHorseRemoteEvent(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") or not horseCatcher.currentLassoID then
        return false
    end
    
    local currentTime = tick()
    if currentTime - horseCatcher.runtime.lastCaptureTime < horseCatcher.settings.captureCooldown then
        return false
    end
    
    local startTime = tick()
    local success = false
    
    pcall(function()
        if gameSystem.available and gameSystem.networkReady then
            gameSystem.u2.Network:FireServer("Equipment", horseCatcher.currentLassoID, "Activate", horse)
            success = true
        end
        
        horseCatcher.runtime.lastCaptureTime = currentTime
        horseCatcher.runtime.currentAttempts = horseCatcher.runtime.currentAttempts + 1
        horseCatcher.runtime.captureAttempts = horseCatcher.runtime.captureAttempts + 1
        horseCatcher.statistics.totalAttempts = horseCatcher.statistics.totalAttempts + 1
    end)
    
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

-- Professional movement functions
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
        
        local prediction = horsePos + (horseVelocity * 0.3)
        local direction = (prediction - currentPos).Unit
        local distance = (prediction - currentPos).Magnitude
        
        if distance > horseCatcher.settings.safeDistance + 1 then
            local targetPos = prediction - direction * horseCatcher.settings.safeDistance
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
        
        -- Clear throw count for this horse
        horseCatcher.runtime.targetThrowCount[horse.Name] = nil
        
        if horseCatcher.statistics.currentStreak > horseCatcher.statistics.bestStreak then
            horseCatcher.statistics.bestStreak = horseCatcher.statistics.currentStreak
        end
        
        local sessionTime = tick() - horseCatcher.runtime.sessionStartTime
        horseCatcher.statistics.horsesPerMinute = (horseCatcher.statistics.currentStreak / (sessionTime / 60))
        
        Rayfield:Notify({
           Title = "🎉 " .. horseName .. " Captured!",
           Content = "Method: " .. horseCatcher.settings.captureMethod:upper() .. " | Streak: " .. horseCatcher.statistics.currentStreak,
           Duration = 2.5,
           Image = 4483362458,
        })
    end
    
    return captured
end

local function cleanupSystem()
    local currentTime = tick()
    if currentTime - horseCatcher.runtime.lastCleanupTime < 15 then
        return
    end
    
    if #Cache.horses > Cache.maxCacheSize * 0.8 then
        for i = Cache.maxCacheSize * 0.6, #Cache.horses do
            Cache.horses[i] = nil
        end
    end
    
    if #horseCatcher.performance.captureTimes > 1000 then
        for i = 1, 500 do
            table.remove(horseCatcher.performance.captureTimes, 1)
        end
    end
    
    -- Clean up throw counts for non-existent horses
    local cleanedThrows = {}
    for horseName, count in pairs(horseCatcher.runtime.targetThrowCount) do
        local horseExists = false
        for _, horse in pairs(Cache.horses) do
            if horse.Name == horseName then
                horseExists = true
                break
            end
        end
        if horseExists then
            cleanedThrows[horseName] = count
        end
    end
    horseCatcher.runtime.targetThrowCount = cleanedThrows
    
    horseCatcher.runtime.lastCleanupTime = currentTime
end

-- =================================
-- MAIN LOGIC WITH DUAL METHODS
-- =================================
local function startHorseCatching()
    if horseCatcher.isRunning then return false end
    
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
    horseCatcher.runtime.autoLassoCount = 0
    horseCatcher.runtime.lastAutoLassoTime = 0
    horseCatcher.runtime.targetThrowCount = {}
    
    local methodText = horseCatcher.settings.captureMethod == "autolasso" and "Auto Lasso Throw" or "Remote Event"
    local movementText = horseCatcher.settings.movementMode == "pulse" and "Pulse TP" or 
                        horseCatcher.settings.movementMode == "attachment" and "Attachment" or "Smooth"
    
    Rayfield:Notify({
       Title = "🚀 Ultra Horse Catching Started!",
       Content = "Method: " .. methodText .. " | Movement: " .. movementText,
       Duration = 3,
       Image = 4483362458,
    })
    
    -- AUTO LASSO CONNECTION (separate from main logic)
    if horseCatcher.settings.captureMethod == "autolasso" then
        horseCatcher.connections.autoLasso = RunService.Heartbeat:Connect(function()
            if not horseCatcher.isRunning then return end
            autoLassoThrow()
        end)
    end
    
    -- MAIN CAPTURE CONNECTION (for Remote Event method)
    if horseCatcher.settings.captureMethod == "remoteevent" then
        horseCatcher.connections.capture = RunService.Heartbeat:Connect(function()
            if not horseCatcher.isRunning then return end
            
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
            
            if not horseCatcher.currentTarget then
                if horseCatcher.settings.smartTargeting then
                    horseCatcher.currentTarget = findOptimalTarget()
                else
                    local horses = updateHorseCache()
                    horseCatcher.currentTarget = horses[1]
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
                if horseCatcher.runtime.lastTargetName == horseCatcher.currentTarget.Name then
                    horseCatcher.runtime.targetStuckTime = horseCatcher.runtime.targetStuckTime + 1
                else
                    horseCatcher.runtime.targetStuckTime = 0
                    horseCatcher.runtime.lastTargetName = horseCatcher.currentTarget.Name
                end
                
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
                captureHorseRemoteEvent(horseCatcher.currentTarget)
                
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
    end
    
    -- CLEANUP CONNECTION
    horseCatcher.connections.cleanup = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        cleanupSystem()
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
    
    local methodText = horseCatcher.settings.captureMethod == "autolasso" and "Auto Lasso" or "Remote Event"
    
    Rayfield:Notify({
       Title = "🏁 Session Ended - " .. methodText,
       Content = "Captured: " .. horseCatcher.statistics.currentStreak .. " | Auto Throws: " .. horseCatcher.statistics.autoLassoThrows .. " | Time: " .. minutes .. "m " .. seconds .. "s",
       Duration = 5,
       Image = 4483362458,
    })
    
    horseCatcher.statistics.currentStreak = 0
end

-- =================================
-- ENHANCED UI WITH CAPTURE METHOD SELECTION
-- =================================

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

-- 🎪 CAPTURE METHOD SECTION
local CaptureMethodSection = parentTab:CreateSection("🎪 Capture Method")

local CaptureMethodDropdown = parentTab:CreateDropdown({
   Name = "🎯 Capture Method",
   Options = {"autolasso", "remoteevent"},
   CurrentOption = {"autolasso"},
   MultipleOptions = false,
   Flag = "CaptureMethodDropdown",
   Callback = function(Option)
      horseCatcher.settings.captureMethod = Option[1]
      
      local methodText = Option[1] == "autolasso" and "Auto Lasso Throw (Optimized)" or "Remote Event (Classic)"
      Rayfield:Notify({
         Title = "🎯 Method Changed",
         Content = "Now using: " .. methodText,
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

-- Auto Lasso Settings (only show when autolasso is selected)
local AutoLassoIntervalSlider = parentTab:CreateSlider({
   Name = "⚡ Auto Lasso Interval",
   Range = {0.2, 1},
   Increment = 0.05,
   Suffix = "s",
   CurrentValue = 0.3,
   Flag = "AutoLassoIntervalSlider",
   Callback = function(Value)
      horseCatcher.settings.autoLassoInterval = Value
   end,
})

local AutoLassoRangeSlider = parentTab:CreateSlider({
   Name = "📏 Auto Lasso Range", 
   Range = {20, 100},
   Increment = 5,
   Suffix = " studs",
   CurrentValue = 50,
   Flag = "AutoLassoRangeSlider",
   Callback = function(Value)
      horseCatcher.settings.autoLassoRange = Value
   end,
})

local AutoLassoMaxThrowsSlider = parentTab:CreateSlider({
   Name = "🎯 Max Throws per Horse",
   Range = {3, 15},
   Increment = 1,
   Suffix = " throws",
   CurrentValue = 5,
   Flag = "AutoLassoMaxThrowsSlider",
   Callback = function(Value)
      horseCatcher.settings.autoLassoMaxThrows = Value
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
         Content = "Now using: " .. Option[1]:upper() .. " mode",
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

-- 📊 ENHANCED STATUS SECTION
local EnhancedStatusSection = parentTab:CreateSection("📊 Enhanced Status")

local SystemStatus = parentTab:CreateParagraph({Title = "🔧 System Status", Content = "Ultra-optimized system ready"})
local CatchingStatus = parentTab:CreateParagraph({Title = "🎯 Catching Status", Content = "Ready for dual methods"})
local TargetInfo = parentTab:CreateParagraph({Title = "🐎 Target Information", Content = "No target selected"})
local MethodMetrics = parentTab:CreateParagraph({Title = "🎪 Method Metrics", Content = "Monitoring ready"})

-- ⚡ QUICK ACTIONS SECTION
local QuickActionsSection = parentTab:CreateSection("⚡ Professional Actions")

local ClearCacheButton = parentTab:CreateButton({
   Name = "🗑️ Clear Performance Cache",
   Callback = function()
      Cache.horses = {}
      Cache.horsesById = {}
      Cache.lastUpdate = 0
      horseCatcher.performance.captureTimes = {}
      horseCatcher.performance.targetingTimes = {}
      horseCatcher.performance.movementTimes = {}
      horseCatcher.performance.autoLassoTimes = {}
      horseCatcher.runtime.targetThrowCount = {}
      
      Rayfield:Notify({
         Title = "🗑️ Cache Cleared",
         Content = "Performance cache and throw counts reset",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local ResetCapturedButton = parentTab:CreateButton({
   Name = "🔄 Reset Captured List",
   Callback = function()
      horseCatcher.capturedHorses = {}
      horseCatcher.runtime.targetThrowCount = {}
      Rayfield:Notify({
         Title = "✅ List Reset",
         Content = "Captured horses and throw counts cleared",
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
         autoLassoThrows = 0
      }
      Rayfield:Notify({
         Title = "📊 Stats Reset",
         Content = "All statistics have been reset",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- 📈 STATISTICS SECTION
local StatisticsSection = parentTab:CreateSection("📈 Professional Statistics")

local SessionStats = parentTab:CreateParagraph({Title = "📈 Session Metrics", Content = "Ready for enhanced session"})
local AllTimeStats = parentTab:CreateParagraph({Title = "🏆 All-Time Records", Content = "No data yet"})
local MethodAnalytics = parentTab:CreateParagraph({Title = "🎪 Method Analytics", Content = "Dual method tracking ready"})

-- =================================
-- ENHANCED STATUS UPDATE SYSTEM
-- =================================
spawn(function()
    while wait(0.8) do
        -- System Status
        local systemText = ""
        if gameSystem.available and gameSystem.networkReady then
            systemText = "✅ Game System: Ultra-Connected\n✅ Network (u2): High-Performance\n✅ Dual Methods: Ready"
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
        
        SystemStatus:Set({Title = "🔧 System Status", Content = systemText})
        
        -- Enhanced Catching Status
        local catchingText = ""
        if horseCatcher.isRunning then
            local runtime = tick() - horseCatcher.runtime.sessionStartTime
            local minutes = math.floor(runtime / 60)
            local seconds = math.floor(runtime % 60)
            
            local methodText = horseCatcher.settings.captureMethod == "autolasso" and "AUTO LASSO" or "REMOTE EVENT"
            
            catchingText = "🚀 ULTRA-ACTIVE (" .. methodText .. ")\n"
            catchingText = catchingText .. "⏱️ Runtime: " .. minutes .. "m " .. seconds .. "s\n"
            catchingText = catchingText .. "📍 Movement: " .. horseCatcher.settings.movementMode:upper() .. "\n"
            catchingText = catchingText .. "🧠 Smart: " .. (horseCatcher.settings.smartTargeting and "✅" or "❌") .. "\n"
            
            if horseCatcher.settings.captureMethod == "autolasso" then
                catchingText = catchingText .. "⚡ Auto Throws: " .. horseCatcher.runtime.autoLassoCount
            else
                catchingText = catchingText .. "🎯 Capture Attempts: " .. horseCatcher.runtime.captureAttempts
            end
        else
            catchingText = "🔴 STOPPED\n💤 Dual method system ready\n🎪 Method: " .. horseCatcher.settings.captureMethod:upper() .. "\n⚙️ Movement: " .. horseCatcher.settings.movementMode:upper() .. "\n🚀 Ultra-performance ready"
        end
        CatchingStatus:Set({Title = "🎯 Catching Status", Content = catchingText})
        
        -- Enhanced Target Info
        local targetText = ""
        if horseCatcher.settings.captureMethod == "autolasso" then
            local nearestHorse = findNearestHorseForAutoLasso()
            if nearestHorse then
                local targetName = getHorseName(nearestHorse)
                local distance = math.floor((humanoidRootPart.Position - nearestHorse.HumanoidRootPart.Position).Magnitude)
                local throwCount = horseCatcher.runtime.targetThrowCount[nearestHorse.Name] or 0
                
                targetText = "🎯 AUTO LASSO TARGET\n"
                targetText = targetText .. "🐎 " .. targetName .. "\n"
                targetText = targetText .. "📏 Distance: " .. distance .. " studs\n"
                targetText = targetText .. "🎪 Throws: " .. throwCount .. "/" .. horseCatcher.settings.autoLassoMaxThrows .. "\n"
                targetText = targetText .. "⚡ Next Throw: " .. string.format("%.1f", math.max(0, horseCatcher.settings.autoLassoInterval - (tick() - horseCatcher.runtime.lastAutoLassoTime))) .. "s"
            else
                targetText = "🔍 AUTO LASSO SCANNING\n🐎 No targets in range\n📏 Range: " .. horseCatcher.settings.autoLassoRange .. " studs\n⚡ Interval: " .. horseCatcher.settings.autoLassoInterval .. "s"
            end
        else
            if horseCatcher.currentTarget then
                local targetName = getHorseName(horseCatcher.currentTarget)
                local distance = math.floor((humanoidRootPart.Position - horseCatcher.currentTarget.HumanoidRootPart.Position).Magnitude)
                local velocity = math.floor(horseCatcher.currentTarget.HumanoidRootPart.Velocity.Magnitude)
                
                targetText = "🎯 REMOTE EVENT TARGET\n"
                targetText = targetText .. "🐎 " .. targetName .. "\n"
                targetText = targetText .. "📏 Distance: " .. distance .. " studs\n"
                targetText = targetText .. "🏃 Speed: " .. velocity .. " studs/s\n"
                targetText = targetText .. "🎯 Attempts: " .. horseCatcher.runtime.currentAttempts .. "/" .. horseCatcher.settings.maxAttemptsPerHorse
            else
                local wildCount = #Cache.horses
                targetText = "🔍 REMOTE EVENT SCANNING\n🐎 Wild horses found: " .. wildCount .. "\n📊 Targeting radius: " .. horseCatcher.settings.targetingRadius .. " studs\n🧠 Smart targeting: " .. (horseCatcher.settings.smartTargeting and "Active" or "Disabled")
            end
        end
        TargetInfo:Set({Title = "🐎 Target Information", Content = targetText})
        
        -- Method Metrics
        local avgAutoLassoTime = 0
        if #horseCatcher.performance.autoLassoTimes > 0 then
            local total = 0
            for _, time in pairs(horseCatcher.performance.autoLassoTimes) do
                total = total + time
            end
            avgAutoLassoTime = total / #horseCatcher.performance.autoLassoTimes
        end
        
        local metricsText = "🎪 Current Method: " .. horseCatcher.settings.captureMethod:upper() .. "\n"
        
        if horseCatcher.settings.captureMethod == "autolasso" then
            metricsText = metricsText .. "⚡ Auto Throws: " .. horseCatcher.statistics.autoLassoThrows .. "\n"
            metricsText = metricsText .. "📊 Avg Throw Time: " .. string.format("%.3f", avgAutoLassoTime * 1000) .. "ms\n"
            metricsText = metricsText .. "🎯 Interval: " .. horseCatcher.settings.autoLassoInterval .. "s\n"
            metricsText = metricsText .. "📏 Range: " .. horseCatcher.settings.autoLassoRange .. " studs"
        else
            local avgCaptureTime = 0
            if #horseCatcher.performance.captureTimes > 0 then
                local total = 0
                for _, time in pairs(horseCatcher.performance.captureTimes) do
                    total = total + time
                end
                avgCaptureTime = total / #horseCatcher.performance.captureTimes
            end
            
            metricsText = metricsText .. "🎯 Remote Attempts: " .. horseCatcher.statistics.totalAttempts .. "\n"
            metricsText = metricsText .. "📊 Avg Capture Time: " .. string.format("%.3f", avgCaptureTime * 1000) .. "ms\n"
            metricsText = metricsText .. "⏱️ Cooldown: " .. horseCatcher.settings.captureCooldown .. "s\n"
            metricsText = metricsText .. "📏 Radius: " .. horseCatcher.settings.targetingRadius .. " studs"
        end
        
        MethodMetrics:Set({Title = "🎪 Method Metrics", Content = metricsText})
        
        -- Enhanced Session Stats
        if horseCatcher.isRunning then
            local sessionTime = tick() - horseCatcher.runtime.sessionStartTime
            local sessionMinutes = math.floor(sessionTime / 60)
            local sessionSeconds = math.floor(sessionTime % 60)
            
            local sessionText = "⏱️ Session Time: " .. sessionMinutes .. "m " .. sessionSeconds .. "s\n"
            sessionText = sessionText .. "🐎 Horses Captured: " .. horseCatcher.statistics.currentStreak .. "\n"
            sessionText = sessionText .. "📈 Capture Rate: " .. string.format("%.1f", horseCatcher.statistics.horsesPerMinute) .. "/min\n"
            sessionText = sessionText .. "🎪 Method: " .. horseCatcher.settings.captureMethod:upper() .. "\n"
            
            if horseCatcher.settings.captureMethod == "autolasso" then
                sessionText = sessionText .. "⚡ Auto Throws: " .. horseCatcher.runtime.autoLassoCount
            else
                sessionText = sessionText .. "🎯 Attempts: " .. horseCatcher.runtime.captureAttempts
            end
            
            SessionStats:Set({Title = "📈 Session Metrics", Content = sessionText})
        else
            SessionStats:Set({Title = "📈 Session Metrics", Content = "No active session\nDual method monitoring ready\n🎪 Auto Lasso + Remote Event\n🚀 Ultra-performance tracking"})
        end
        
        -- Enhanced All-Time Stats
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
        allTimeText = allTimeText .. "⚡ Auto Lasso Throws: " .. horseCatcher.statistics.autoLassoThrows .. "\n"
        allTimeText = allTimeText .. "📝 Marked Horses: " .. capturedCount
        
        AllTimeStats:Set({Title = "🏆 All-Time Records", Content = allTimeText})
        
        -- Method Analytics
        local analyticsText = "🎪 DUAL METHOD SYSTEM\n"
        analyticsText = analyticsText .. "⚡ Auto Lasso: Optimized for speed\n"
        analyticsText = analyticsText .. "🎯 Remote Event: Precision targeting\n"
        analyticsText = analyticsText .. "🔄 Cache Efficiency: " .. string.format("%.1f", (#Cache.horses / math.max(horseCatcher.runtime.targetingCount, 1)) * 100) .. "%\n"
        analyticsText = analyticsText .. "🚀 System Status: DUAL-OPTIMIZED"
        
        MethodAnalytics:Set({Title = "🎪 Method Analytics", Content = analyticsText})
    end
end)

-- =================================
-- CHARACTER RESPAWN HANDLING
-- =================================
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    horseCatcher.isAttached = false
    horseCatcher.lassoEquipped = false
    horseCatcher.currentLassoID = nil
    
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
-- ENHANCED INITIALIZATION
-- =================================
Rayfield:Notify({
   Title = "🚀 Ultra Horse Catcher with Dual Methods!",
   Content = "Auto Lasso Throw + Remote Event | Professional optimizations | Revolutionary system",
   Duration = 6,
   Image = 4483362458,
})

if gameSystem.available and gameSystem.networkReady then
    Rayfield:Notify({
       Title = "✅ Dual System Ready!",
       Content = "Auto Lasso (optimized) + Remote Event (classic) | Maximum efficiency!",
       Duration = 4,
       Image = 4483362458,
    })
else
    Rayfield:Notify({
       Title = "⚠️ Performance Warning",
       Content = "Network system issues detected - Performance may be limited",
       Duration = 4,
       Image = 4483362458,
    })
end

print("🚀 Ultra Horse Catcher Pro - Dual Method Edition Loaded!")
print("🎪 Features: Auto Lasso Throw (optimized) + Remote Event (classic)")
print("⚡ Auto Lasso: Optimized intervals, throw limits, no lag")
print("🎯 Remote Event: Original precision targeting system")
print("🔥 Dual method system ready for maximum efficiency!")
