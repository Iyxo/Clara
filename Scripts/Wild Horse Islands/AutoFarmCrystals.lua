local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local islandsFolder = game:GetService("Workspace").Islands["Unicorn Island"]
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local teleportActive = true -- Flaga do kontrolowania teleportacji
local teleportHeight = 5 -- Wysokość nad obiektem, na którą teleportujemy gracza

-- Funkcja nasłuchująca naciśnięcia klawisza "V" do przełączania teleportacji
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.V and not gameProcessedEvent then
        teleportActive = not teleportActive
        if teleportActive then
            print("Teleportacja włączona")
        else
            print("Teleportacja wyłączona")
        end
    end
end)

-- Funkcja sprawdzająca modele i teleportująca do "Meshes/Gems 2"
local function teleportToGems()
    if teleportActive then
        -- Przeglądaj każdy model w folderze "Unicorn Island"
        for _, model in pairs(islandsFolder:GetChildren()) do
            if model:IsA("Model") then
                -- Sprawdź, czy model ma "Meshes/Gems 2" w środku
                local gem = model:FindFirstChild("Meshes/Gems 2", true) -- Szukaj w głąb modelu
                if gem then
                    -- Oblicz nowe CFrame, które przesuwa gracza nad obiekt
                    local aboveGemCFrame = CFrame.new(gem.Position + Vector3.new(0, teleportHeight, 0))
                    rootPart.CFrame = aboveGemCFrame
                    print("Znaleziono i przeniesiono nad: " .. gem.Name)
                    break -- Zatrzymaj po znalezieniu pierwszego dopasowania
                end
            end
        end
    end
end

-- Użycie RunService do szybkiego sprawdzania i teleportacji
RunService.Heartbeat:Connect(function()
    teleportToGems()
end)
