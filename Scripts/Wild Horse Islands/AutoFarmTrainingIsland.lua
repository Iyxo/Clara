-- Flaga kontrolująca działanie skryptu
_G.TrainingAutoFarmActive = true -- Używamy _G, aby można było ją zmieniać z innego skryptu

-- Kod aktywujący się jako pierwszy
local function firstScript()
    if not _G.TrainingAutoFarmActive then return end -- Sprawdzenie, czy skrypt jest aktywny

    local args = {
        [1] = "SelectLayout",
        [2] = workspace.Islands:FindFirstChild("Training Island"):FindFirstChild("Outdoor Arena").DynamicArena,
        [3] = 1
    }

    local eventsFolder = game:GetService("ReplicatedStorage").Communication.Events
    for _, event in ipairs(eventsFolder:GetChildren()) do
        if event:IsA("RemoteEvent") then
            pcall(function()
                event:FireServer(unpack(args))
            end)
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
            pcall(function()
                event:FireServer(unpack(args))
            end)
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
    
    -- Funkcja losująca małe przesunięcie pozycji
    local function randomOffset()
        local maxOffset = 0.2 -- Maksymalne przesunięcie dla drgania
        return Vector3.new(
            math.random() * maxOffset - (maxOffset / 2),
            math.random() * maxOffset - (maxOffset / 2),
            math.random() * maxOffset - (maxOffset / 2)
        )
    end

    -- Funkcja do podążania za markerem i drgania
    local function followMarker()
        if _G.TrainingAutoFarmActive then
            local seat = character:FindFirstChildOfClass("Seat") or character:FindFirstChildOfClass("VehicleSeat")
            local newPosition = checkpointMarker.Position + randomOffset() -- Dodajemy losowe przesunięcie

            -- Ustawienie pozycji gracza z losowym drganiem
            if seat then
                seat.Parent:SetPrimaryPartCFrame(CFrame.new(newPosition))
            else
                -- Manipulacja CFrame w celu "przyklejenia" gracza do obiektu z drganiem
                rootPart.CFrame = CFrame.new(newPosition)
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
