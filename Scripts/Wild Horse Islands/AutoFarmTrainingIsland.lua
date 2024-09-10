-- Kod aktywujący się jako pierwszy
local function firstScript()
    local args = {
        [1] = "SelectLayout",
        [2] = workspace.Islands:FindFirstChild("Training Island"):FindFirstChild("Outdoor Arena").DynamicArena,
        [3] = 5
    }

    -- Pobieramy folder 'Events' w 'ReplicatedStorage'
    local eventsFolder = game:GetService("ReplicatedStorage").Communication.Events

    -- Iterujemy przez wszystkie RemoteEvent w folderze 'Events'
    for _, event in ipairs(eventsFolder:GetChildren()) do
        if event:IsA("RemoteEvent") then
            print("Wywołuję RemoteEvent: " .. event.Name)
            
            -- Próbujemy wywołać RemoteEvent z nowymi argumentami
            local success, err = pcall(function()
                event:FireServer(unpack(args))
            end)
            
            -- Sprawdzamy, czy udało się wywołać RemoteEvent
            if success then
                print("Sukces dla RemoteEvent: " .. event.Name)
            else
                warn("Błąd przy wywoływaniu RemoteEvent: " .. event.Name .. " - " .. err)
            end
        end
    end
end

-- Kod aktywujący się jako drugi
local function secondScript()
    local args = {
        [1] = "TriggerInteractable",
        [2] = workspace._LAYOUT.CheckpointActivity
    }

    -- Pobieramy folder 'Events' w 'ReplicatedStorage'
    local eventsFolder = game:GetService("ReplicatedStorage").Communication.Events

    -- Iterujemy przez wszystkie RemoteEvent w folderze 'Events'
    for _, event in ipairs(eventsFolder:GetChildren()) do
        if event:IsA("RemoteEvent") then
            print("Wywołuję RemoteEvent: " .. event.Name)
            
            -- Próbujemy wywołać RemoteEvent
            local success, err = pcall(function()
                event:FireServer(unpack(args))
            end)
            
            -- Sprawdzamy, czy udało się wywołać RemoteEvent
            if success then
                print("Sukces dla RemoteEvent: " .. event.Name)
            else
                warn("Błąd przy wywoływaniu RemoteEvent: " .. event.Name .. " - " .. err)
            end
        end
    end
end

-- Kod aktywujący się jako ostatni
local function thirdScript()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local checkpointMarker = game:GetService("Workspace"):WaitForChild("CheckpointMarker"):WaitForChild("Marker")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    local teleportActive = true -- Flaga do kontrolowania teleportacji

    -- Funkcja nasłuchująca naciśnięcia klawisza "V"
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if input.KeyCode == Enum.KeyCode.V and not gameProcessedEvent then
            teleportActive = not teleportActive -- Przełączanie włącz/wyłącz teleportacji
            if teleportActive then
                print("Teleportacja włączona")
            else
                print("Teleportacja wyłączona")
            end
        end
    end)

    -- Funkcja teleportacji
    local function teleport()
        if teleportActive then
            local seat = character:FindFirstChildOfClass("Seat") or character:FindFirstChildOfClass("VehicleSeat")
            
            if seat then
                -- Teleportuj obiekt (np. samochód, koń) razem z graczem
                seat.Parent:SetPrimaryPartCFrame(checkpointMarker.CFrame)
            else
                -- Jeśli gracz nie siedzi, teleportuj samego gracza
                rootPart.CFrame = checkpointMarker.CFrame
            end
        end
    end

    -- Użycie RunService do szybkiego wykonywania kodu
    RunService.Heartbeat:Connect(function()
        teleport() -- Teleportacja w każdej klatce
    end)
end

-- Wykonaj skrypty w odpowiedniej kolejności
firstScript()
wait(2) -- Opcjonalne opóźnienie, jeśli potrzebne
secondScript()
wait(2) -- Opcjonalne opóźnienie, jeśli potrzebne
thirdScript()
