-- Flaga kontrolująca działanie skryptu
_G.TrainingAutoFarmActive = true

-- Funkcja przyjmująca dynamiczną wartość layoutu
return function(layoutValue)
    -- Kod aktywujący się jako pierwszy
    local function firstScript()
        if not _G.TrainingAutoFarmActive then return end -- Sprawdzenie, czy skrypt jest aktywny

        local args = {
            [1] = "SelectLayout",
            [2] = workspace.Islands:FindFirstChild("Training Island"):FindFirstChild("Outdoor Arena").DynamicArena,
            [3] = _G.SelectedTrainingOption -- Użyj wartości wybranej z Dropdown
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

    -- Inne skrypty jak wcześniej
    local function secondScript()
        if not _G.TrainingAutoFarmActive then return end
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

    local function thirdScript()
        if not _G.TrainingAutoFarmActive then return end
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")
        local checkpointMarker = game:GetService("Workspace"):WaitForChild("CheckpointMarker"):WaitForChild("Marker")
        local RunService = game:GetService("RunService")

        local function followMarker()
            if _G.TrainingAutoFarmActive then
                local seat = character:FindFirstChildOfClass("Seat") or character:FindFirstChildOfClass("VehicleSeat")
                if seat then
                    seat.Parent:SetPrimaryPartCFrame(checkpointMarker.CFrame)
                else
                    rootPart.CFrame = checkpointMarker.CFrame
                end
            end
        end

        RunService.Heartbeat:Connect(function()
            if _G.TrainingAutoFarmActive then
                followMarker()
            end
        end)
    end

    firstScript()
    wait(1)
    secondScript()
    wait(1)
    thirdScript()
end
