-- Horse Catcher Pro - Optimized Edition
-- by Iyxo - Zoptymalizowana wersja
-- Profesjonalne łapanie koni z monitorowaniem CaptureProgress

local parentTab, Rayfield, Window = ...

-- =================================
-- USŁUGI I PODSTAWOWE ZMIENNE
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
-- SYSTEM DETEKCJI WYSP
-- =================================
local islandSystem = {
    currentIsland = "Unknown",
    lastUpdate = 0,
    updateInterval = 5 -- Zwiększono z 3 do 5
}

local function detectCurrentIsland()
    local currentTime = tick()
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
    
    islandSystem.lastUpdate = currentTime
    return islandSystem.currentIsland
end

-- =================================
-- SYSTEM MONITOROWANIA POSTĘPU
-- =================================
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
-- SYSTEM NOCLIP DLA TRYBU SMOOTH
-- =================================
local noclipSystem = {
    active = false,
    originalCanCollide = {},
    connection = nil
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
    
    noclipSystem.connection = character.ChildAdded:Connect(function(child)
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
    
    if noclipSystem.connection then
        noclipSystem.connection:Disconnect()
        noclipSystem.connection = nil
    end
end

-- =================================
-- ZOPTYMALIZOWANY SYSTEM CACHE
-- =================================
local Cache = {
    horses = {},
    lastUpdate = 0,
    updateInterval = 2, -- Zwiększono z 1.5 do 2
    maxCacheSize = 200, -- Zmniejszono z 500 do 200
    islandHorses = {}
}

-- =================================
-- SYSTEM ŁAPANIA KONI
-- =================================
local horseCatcher = {
    isRunning = false,
    currentTarget = nil,
    currentTargetProgress = nil,
    isAttached = false,
    lassoEquipped = false,
    currentLassoID = nil,
    
    connections = {},
    capturedHorses = {},
    
    statistics = {
        totalCaptured = 0,
        currentStreak = 0,
        totalAttempts = 0,
        islandStats = {}
    },
    
    settings = {
        movementMode = "attachment",
        pulseInterval = 0.8,
        pulseDistance = 8,
        captureCooldown = 0.4,
        smartTargeting = true,
        
        progressMonitoring = true,
        abandonOnStuckProgress = true,
        maxStuckProgressTime = 15,
        
        safeDistance = 5,
        attachmentOffset = 4,
        targetingRadius = 300
    },
    
    runtime = {
        lastCaptureTime = 0,
        lastPulseTime = 0,
        sessionStartTime = 0,
        currentTargetStartTime = 0,
        lastProgressChange = 0,
        lastProgressValue = "0/0",
        progressStuckTime = 0,
        currentIslandHorses = 0
    }
}

-- Detekcja systemu gry
local gameSystem = {
    u1 = nil,
    u2 = nil, 
    u3 = nil,
    available = false,
    remoteEvent = nil
}

pcall(function()
    gameSystem.u1 = require(ReplicatedStorage.References)
    gameSystem.u2 = gameSystem.u1.Utilities
    gameSystem.u3 = require(gameSystem.u1.PlayerScripts.Priority.Data)
    gameSystem.available = true
    gameSystem.remoteEvent = ReplicatedStorage.Communication.Events['']
end)

-- =================================
-- FUNKCJE KONI
-- =================================
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
                    horseName = horse.Name:sub(2, 9)
                end
            end
        end
    end)
    
    return horseName
end

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

local function updateHorseCache()
    local currentTime = tick()
    if currentTime - Cache.lastUpdate < Cache.updateInterval then
        return Cache.horses
    end
    
    Cache.horses = {}
    Cache.islandHorses = {}
    local horseCount = 0
    local currentIsland = detectCurrentIsland()
    
    local function scanLocation(location, islandName)
        if not location then return end
        
        local children = location:GetChildren()
        local localHorseCount = 0
        
        for i = 1, #children do
            local child = children[i]
            
            if child.Name:find("{") and child:FindFirstChild("HumanoidRootPart") then
                local humanoid = child:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    if isWildHorse(child) and not horseCatcher.capturedHorses[child.Name] then
                        local distance = (humanoidRootPart.Position - child.HumanoidRootPart.Position).Magnitude
                        
                        if distance <= horseCatcher.settings.targetingRadius then
                            horseCount = horseCount + 1
                            localHorseCount = localHorseCount + 1
                            
                            Cache.horses[horseCount] = {
                                horse = child,
                                island = islandName,
                                distance = distance
                            }
                            
                            if horseCount >= Cache.maxCacheSize then
                                break
                            end
                        end
                    end
                end
            end
        end
        
        Cache.islandHorses[islandName] = localHorseCount
    end
    
    pcall(function()
        if Workspace.Islands then
            for _, island in pairs(Workspace.Islands:GetChildren()) do
                if island:IsA("Model") and island.Name ~= "Islands" then
                    scanLocation(island, island.Name)
                end
            end
            
            if Workspace.Islands:FindFirstChild("Mainland") then
                scanLocation(Workspace.Islands.Mainland, "Mainland")
            end
        end
    end)
    
    -- Sortowanie według odległości
    table.sort(Cache.horses, function(a, b)
        return a.distance < b.distance
    end)
    
    Cache.lastUpdate = currentTime
    horseCatcher.runtime.currentIslandHorses = Cache.islandHorses[currentIsland] or 0
    
    return Cache.horses
end

-- System lassa
local function equipLasso()
    if horseCatcher.lassoEquipped and horseCatcher.currentLassoID then
        return true, horseCatcher.currentLassoID
    end
    
    local success = false
    local toolID = nil
    
    if gameSystem.available then
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

local function findOptimalTarget()
    local horses = updateHorseCache()
    if #horses == 0 then return nil end
    
    local playerPos = humanoidRootPart.Position
    local currentIsland = detectCurrentIsland()
    
    -- Preferuj konie na aktualnej wyspie
    for i = 1, #horses do
        local horseData = horses[i]
        if horseData and horseData.horse and horseData.horse:FindFirstChild("HumanoidRootPart") then
            if horseData.island == currentIsland then
                return horseData.horse
            end
        end
    end
    
    -- Jeśli nie ma na aktualnej wyspie, weź najbliższego
    return horses[1] and horses[1].horse
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
        if gameSystem.available then
            gameSystem.u2.Network:FireServer("Equipment", horseCatcher.currentLassoID, "Activate", horse)
            success = true
        end
        
        horseCatcher.runtime.lastCaptureTime = currentTime
        horseCatcher.statistics.totalAttempts = horseCatcher.statistics.totalAttempts + 1
    end)
    
    return success
end

-- Funkcje ruchu
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
        local sideOffset = horseRoot.CFrame.RightVector * horseCatcher.settings.pulseDistance
        local heightOffset = Vector3.new(0, 3, 0)
        
        local finalPos = prediction + sideOffset + heightOffset
        
        humanoidRootPart.CFrame = CFrame.lookAt(finalPos, horsePos)
        horseCatcher.runtime.lastPulseTime = currentTime
    end)
    
    return true
end

local function attachToHorse(horse)
    if not horse or not horse:FindFirstChild("HumanoidRootPart") then return false end
    
    pcall(function()
        -- Usuń poprzednie przyłączenia
        for _, attachment in pairs(humanoidRootPart:GetChildren()) do
            if attachment.Name == "HorseAttachment" and attachment:IsA("WeldConstraint") then
                attachment:Destroy()
            end
        end
        
        local horseRoot = horse.HumanoidRootPart
        local horsePos = horseRoot.Position
        local sideOffset = horseRoot.CFrame.RightVector * horseCatcher.settings.attachmentOffset
        local heightOffset = Vector3.new(0, 3.5, 0)
        
        humanoidRootPart.CFrame = CFrame.lookAt(horsePos + sideOffset + heightOffset, horsePos)
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
            if attachment.Name == "HorseAttachment" and attachment:IsA("WeldConstraint") then
                attachment:Destroy()
            end
        end
        horseCatcher.isAttached = false
    end)
end

local function isHorseCapturedOrComplete(horse)
    if not horse or not horse.Parent then
        return true, "Horse disappeared"
    end
    
    local captured = false
    local horseName = getHorseName(horse)
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
        
        local currentIsland = detectCurrentIsland()
        if not horseCatcher.statistics.islandStats[currentIsland] then
            horseCatcher.statistics.islandStats[currentIsland] = 0
        end
        horseCatcher.statistics.islandStats[currentIsland] = horseCatcher.statistics.islandStats[currentIsland] + 1
        
        Rayfield:Notify({
           Title = "🎉 " .. horseName .. " Złapany!",
           Content = "Wyspa: " .. currentIsland .. " | Powód: " .. reason .. " | Seria: " .. horseCatcher.statistics.currentStreak,
           Duration = 3,
           Image = 4483362458,
        })
    end
    
    return captured, reason
end

-- =================================
-- GŁÓWNA LOGIKA
-- =================================
local function startHorseCatching()
    if horseCatcher.isRunning then return false end
    
    local lassoReady, lassoID = equipLasso()
    if not lassoReady then
        Rayfield:Notify({
           Title = "❌ Potrzebne lasso!",
           Content = "Nie znaleziono lassa w ekwipunku!",
           Duration = 4,
           Image = 4483362458,
        })
        return false
    end
    
    if not gameSystem.available then
        Rayfield:Notify({
           Title = "❌ Błąd systemu sieciowego!",
           Content = "Nie można uzyskać dostępu do systemu sieciowego gry!",
           Duration = 4,
           Image = 4483362458,
        })
        return false
    end
    
    horseCatcher.isRunning = true
    horseCatcher.runtime.sessionStartTime = tick()
    horseCatcher.statistics.currentStreak = 0
    horseCatcher.runtime.lastCaptureTime = 0
    horseCatcher.runtime.lastPulseTime = 0
    
    local currentIsland = detectCurrentIsland()
    
    -- Włącz noclip dla trybu smooth
    if horseCatcher.settings.movementMode == "smooth" then
        enableNoclip()
    end
    
    Rayfield:Notify({
       Title = "🚀 Łapanie koni rozpoczęte!",
       Content = "Wyspa: " .. currentIsland .. " | Tryb: " .. horseCatcher.settings.movementMode:upper() .. (horseCatcher.settings.movementMode == "smooth" and " (Noclip)" or ""),
       Duration = 3,
       Image = 4483362458,
    })
    
    -- Połączenie główne
    horseCatcher.connections.main = RunService.Heartbeat:Connect(function()
        if not horseCatcher.isRunning then return end
        
        -- Sprawdź aktualny cel
        if horseCatcher.currentTarget then
            local captured, reason = isHorseCapturedOrComplete(horseCatcher.currentTarget)
            if captured then
                if horseCatcher.settings.movementMode == "attachment" then
                    detachFromHorse()
                end
                horseCatcher.currentTarget = nil
                horseCatcher.currentTargetProgress = nil
                return
            end
            
            -- Sprawdź stuck progress
            if horseCatcher.settings.abandonOnStuckProgress then
                local progressData = getCaptureProgress(horseCatcher.currentTarget)
                if progressData.exists then
                    if progressData.text ~= horseCatcher.runtime.lastProgressValue then
                        horseCatcher.runtime.lastProgressChange = tick()
                        horseCatcher.runtime.lastProgressValue = progressData.text
                    else
                        horseCatcher.runtime.progressStuckTime = tick() - horseCatcher.runtime.lastProgressChange
                        
                        if horseCatcher.runtime.progressStuckTime > horseCatcher.settings.maxStuckProgressTime then
                            if horseCatcher.settings.movementMode == "attachment" then
                                detachFromHorse()
                            end
                            horseCatcher.currentTarget = nil
                            horseCatcher.currentTargetProgress = nil
                            return
                        end
                    end
                end
            end
        end
        
        -- Znajdź nowy cel jeśli potrzeba
        if not horseCatcher.currentTarget then
            if horseCatcher.settings.smartTargeting then
                horseCatcher.currentTarget = findOptimalTarget()
            else
                local horses = updateHorseCache()
                horseCatcher.currentTarget = horses[1] and horses[1].horse
            end
            
            if horseCatcher.currentTarget then
                horseCatcher.runtime.currentTargetStartTime = tick()
                horseCatcher.runtime.lastProgressChange = tick()
                horseCatcher.runtime.lastProgressValue = "0/0"
                horseCatcher.currentTargetProgress = getCaptureProgress(horseCatcher.currentTarget)
            end
        end
        
        -- Wykonaj ruch i łapanie
        if horseCatcher.currentTarget then
            if horseCatcher.settings.movementMode == "pulse" then
                pulseTeleportToHorse(horseCatcher.currentTarget)
            elseif horseCatcher.settings.movementMode == "attachment" then
                if not horseCatcher.isAttached then
                    attachToHorse(horseCatcher.currentTarget)
                end
            elseif horseCatcher.settings.movementMode == "smooth" then
                smoothFollow(horseCatcher.currentTarget)
            end
            
            captureHorse(horseCatcher.currentTarget)
        end
    end)
    
    return true
end

local function stopHorseCatching()
    horseCatcher.isRunning = false
    
    -- Wyłącz noclip
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
    
    Rayfield:Notify({
       Title = "🏁 Sesja zakończona",
       Content = "Złapano: " .. horseCatcher.statistics.currentStreak .. " | Czas: " .. minutes .. "m " .. seconds .. "s",
       Duration = 5,
       Image = 4483362458,
    })
    
    horseCatcher.statistics.currentStreak = 0
end

-- =================================
-- INTERFEJS UŻYTKOWNIKA
-- =================================

-- Sekcja kontroli CaptureProgress
local CaptureProgressSection = parentTab:CreateSection("🎯 System CaptureProgress")

local ProgressMonitoringToggle = parentTab:CreateToggle({
   Name = "📊 Monitorowanie CaptureProgress",
   CurrentValue = true,
   Flag = "ProgressMonitoringToggle",
   Callback = function(Value)
      horseCatcher.settings.progressMonitoring = Value
   end,
})

local AbandonStuckToggle = parentTab:CreateToggle({
   Name = "⏭️ Porzuć przy zatrzymanym postępie",
   CurrentValue = true,
   Flag = "AbandonStuckProgressToggle",
   Callback = function(Value)
      horseCatcher.settings.abandonOnStuckProgress = Value
   end,
})

local MaxStuckProgressSlider = parentTab:CreateSlider({
   Name = "⏳ Maks. czas zatrzymanego postępu",
   Range = {5, 30},
   Increment = 1,
   Suffix = "s",
   CurrentValue = 15,
   Flag = "MaxStuckProgressSlider",
   Callback = function(Value)
      horseCatcher.settings.maxStuckProgressTime = Value
   end,
})

-- Główna sekcja kontroli
local MainControlSection = parentTab:CreateSection("🎯 Główna kontrola")

local MainToggle = parentTab:CreateToggle({
   Name = "🚀 Ultra łapanie koni",
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

-- Ustawienia ruchu
local MovementSettingsSection = parentTab:CreateSection("📍 Ruch i optymalizacja")

local MovementDropdown = parentTab:CreateDropdown({
   Name = "📍 Tryb ruchu",
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
         Title = "📍 Tryb zaktualizowany",
         Content = "Teraz używa: " .. Option[1]:upper() .. (Option[1] == "smooth" and " (Noclip)" or ""),
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

local SmartTargetingToggle = parentTab:CreateToggle({
   Name = "🧠 Inteligentne celowanie",
   CurrentValue = true,
   Flag = "UltraHorseSmartTargetingToggle",
   Callback = function(Value)
      horseCatcher.settings.smartTargeting = Value
   end,
})

-- Status
local LiveStatusSection = parentTab:CreateSection("📊 Status")
local IslandInfo = parentTab:CreateParagraph({Title = "🏝️ Informacje o wyspie", Content = "Wykrywanie aktualnej wyspy..."})
local TargetInfo = parentTab:CreateParagraph({Title = "🐎 Aktualny cel", Content = "Nie wybrano celu"})

-- Szybkie akcje
local QuickActionsSection = parentTab:CreateSection("⚡ Szybkie akcje")

local ClearCacheButton = parentTab:CreateButton({
   Name = "🗑️ Wyczyść cache",
   Callback = function()
      Cache.horses = {}
      Cache.islandHorses = {}
      Cache.lastUpdate = 0
      horseCatcher.capturedHorses = {}
      
      Rayfield:Notify({
         Title = "🗑️ Cache wyczyszczony",
         Content = "Cache wydajności zoptymalizowany",
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

-- Statystyki
local StatisticsSection = parentTab:CreateSection("📈 Statystyki")
local SessionStats = parentTab:CreateParagraph({Title = "📈 Metryki sesji", Content = "Gotowy na sesję"})

-- =================================
-- SYSTEM AKTUALIZACJI STATUSU
-- =================================
spawn(function()
    while wait(2) do -- Zwiększono z 1 do 2 sekund
        local currentIsland = detectCurrentIsland()
        
        -- Informacje o wyspie
        local islandText = "🏝️ Aktualna wyspa: " .. currentIsland .. "\n"
        islandText = islandText .. "🐎 Konie na wyspie: " .. (horseCatcher.runtime.currentIslandHorses or 0) .. "\n"
        
        local totalHorses = 0
        for islandName, horseCount in pairs(Cache.islandHorses) do
            totalHorses = totalHorses + horseCount
        end
        
        islandText = islandText .. "📊 Łączne konie: " .. totalHorses
        
        IslandInfo:Set({Title = "🏝️ Informacje o wyspie", Content = islandText})
        
        -- Informacje o celu
        local targetText = ""
        if horseCatcher.currentTarget then
            local targetName = getHorseName(horseCatcher.currentTarget)
            local distance = math.floor((humanoidRootPart.Position - horseCatcher.currentTarget.HumanoidRootPart.Position).Magnitude)
            
            targetText = "🐎 " .. targetName .. "\n"
            targetText = targetText .. "📏 Odległość: " .. distance .. " studs\n"
            
            if horseCatcher.currentTargetProgress and horseCatcher.currentTargetProgress.exists then
                targetText = targetText .. "📊 Postęp: " .. horseCatcher.currentTargetProgress.text
            else
                targetText = targetText .. "📊 Postęp: Brak danych"
            end
        else
            targetText = "🔍 Skanowanie celów...\n🐎 Dzikie konie: " .. #Cache.horses
        end
        TargetInfo:Set({Title = "🐎 Aktualny cel", Content = targetText})
        
        -- Statystyki sesji
        if horseCatcher.isRunning then
            local sessionTime = tick() - horseCatcher.runtime.sessionStartTime
            local sessionMinutes = math.floor(sessionTime / 60)
            local sessionSeconds = math.floor(sessionTime % 60)
            
            local sessionText = "⏱️ Czas sesji: " .. sessionMinutes .. "m " .. sessionSeconds .. "s\n"
            sessionText = sessionText .. "🐎 Złapane konie: " .. horseCatcher.statistics.currentStreak .. "\n"
            sessionText = sessionText .. "🏝️ Aktualna wyspa: " .. currentIsland
            
            SessionStats:Set({Title = "📈 Metryki sesji", Content = sessionText})
        else
            SessionStats:Set({Title = "📈 Metryki sesji", Content = "Brak aktywnej sesji\nMonitorowanie CaptureProgress gotowe"})
        end
    end
end)

-- Obsługa respawnu postaci
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    horseCatcher.isAttached = false
    horseCatcher.lassoEquipped = false
    horseCatcher.currentLassoID = nil
    
    disableNoclip()
    
    islandSystem.currentIsland = "Unknown"
    islandSystem.lastUpdate = 0
    
    if horseCatcher.isRunning then
        stopHorseCatching()
        MainToggle:Set(false)
        
        Rayfield:Notify({
           Title = "🔄 Postać odrodziona",
           Content = "Łapanie koni zatrzymane - uruchom ponownie gdy będziesz gotowy",
           Duration = 3,
           Image = 4483362458,
        })
    end
end)

-- =================================
-- INICJALIZACJA
-- =================================
Rayfield:Notify({
   Title = "🚀 Ultra Horse Catcher Pro załadowany!",
   Content = "Monitorowanie CaptureProgress | Auto-lasso | Tryb noclip smooth | Uproszczony interfejs",
   Duration = 5,
   Image = 4483362458,
})

local initialIsland = detectCurrentIsland()

if gameSystem.available then
    Rayfield:Notify({
       Title = "✅ System gotowy!",
       Content = "Wyspa: " .. initialIsland .. " | Śledzenie CaptureProgress | Ochrona auto-lasso | Tryb noclip smooth!",
       Duration = 4,
       Image = 4483362458,
    })
else
    Rayfield:Notify({
       Title = "⚠️ Ostrzeżenie o wydajności",
       Content = "Wykryto problemy z systemem sieciowym | Wyspa: " .. initialIsland,
       Duration = 4,
       Image = 4483362458,
    })
end
