-- Flaga kontrolująca działanie skryptu
_G.TrainingAutoFarmActive = false -- Domyślnie wyłączone
_G.SelectedOption = 1 -- Domyślna wartość dla dropdowna

-- Funkcja aktywująca się jako pierwszy
local function firstScript()
    if not _G.TrainingAutoFarmActive then return end -- Sprawdzenie, czy skrypt jest aktywny

    local args = {
        [1] = "SelectLayout",
        [2] = workspace.Islands:FindFirstChild("Training Island"):FindFirstChild("Outdoor Arena").DynamicArena,
        [3] = _G.SelectedOption -- Użycie wartości z dropdowna
    }

    local eventsFolder = game:GetService("ReplicatedStorage").Communication.Events
    for _, event in ipairs(eventsFolder:GetChildren()) do
        if event:IsA("RemoteEvent") then
            local success, err = pcall(function()
                event:FireServer(unpack(args))
            end)
            if not success then
                warn("Błąd przy wywoływaniu RemoteEvent: " .. event.Name .. " - " .. err)
            end
        end
    end
end

-- Kod aktywujący się jako drugi
local function secondScript()
    if not _G.TrainingAutoFarmActive then return end -- Sprawdzenie, czy skrypt jest aktywny

    local args = {
        [1] = "TriggerInteractable",
        [2] = workspace._LAYOUT.CheckpointActivity
    }

    local eventsFolder = game:GetService("ReplicatedStorage").Communication.Events
    for _, event in ipairs(eventsFolder:GetChildren()) do
        if event:IsA("RemoteEvent") then
            local success, err = pcall(function()
                event:FireServer(unpack(args))
            end)
            if not success then
                warn("Błąd przy wywoływaniu RemoteEvent: " .. event.Name .. " - " .. err)
            end
        end
    end
end

-- Kod aktywujący się jako ostatni
local function thirdScript()
    if not _G.TrainingAutoFarmActive then return end -- Sprawdzenie, czy skrypt jest aktywny

    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local checkpointMarker = game:GetService("Workspace"):WaitForChild("CheckpointMarker"):WaitForChild("Marker")
    local RunService = game:GetService("RunService")

    -- Funkcja do podążania za markerem z maksymalną szybkością
    local function followMarker()
        if _G.TrainingAutoFarmActive then
            local seat = character:FindFirstChildOfClass("Seat") or character:FindFirstChildOfClass("VehicleSeat")
            
            -- Ustawienie pozycji gracza bezpośrednio na obiekt
            if seat then
                seat.Parent:SetPrimaryPartCFrame(checkpointMarker.CFrame)
            else
                -- Manipulacja CFrame w celu "przyklejenia" gracza do obiektu
                rootPart.CFrame = checkpointMarker.CFrame
            end
        end
    end

    -- Używamy RunService.Heartbeat dla maksymalnej responsywności
    RunService.Heartbeat:Connect(function()
        if _G.TrainingAutoFarmActive then
            followMarker()
        end
    end)
end

-- Wykonaj skrypty w odpowiedniej kolejności
firstScript()
wait(1)
secondScript()
wait(1)
thirdScript()
