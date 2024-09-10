-- Flaga kontrolująca działanie skryptu
_G.AutoFarmCrystalActive = true -- Używamy _G, aby można było ją zmieniać z innego skryptu

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local islandsFolder = game:GetService("Workspace").Islands["Unicorn Island"]
local RunService = game:GetService("RunService")

local teleportHeight = 5 -- Wysokość nad obiektem, na którą teleportujemy gracza

-- Funkcja sprawdzająca modele i teleportująca do "Meshes/Gems 2"
local function teleportToGems()
    if _G.AutoFarmCrystalActive then -- Sprawdzenie, czy skrypt jest aktywny
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
