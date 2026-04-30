-- AutoFarmAnimal - teleportuje gracza po kolei do zwierzat na wszystkich wyspach

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

if _G.AutoFarmAnimalActive == nil then
    _G.AutoFarmAnimalActive = true
end

if _G.__AutoFarmAnimalRunning then
    return
end
_G.__AutoFarmAnimalRunning = true

local function getRoot()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

local function teleportTo(part)
    local root = getRoot()
    if root and part and part.Parent then
        root.CFrame = part.CFrame
    end
end

local function findAnimalRoots()
    local results = {}
    local islands = Workspace:FindFirstChild("Islands")
    if not islands then return results end

    for _, island in ipairs(islands:GetChildren()) do
        local nodes = island:FindFirstChild("Nodes")
        local animals = nodes and nodes:FindFirstChild("Animals")
        if animals then
            for _, animal in ipairs(animals:GetChildren()) do
                local hrp = animal:FindFirstChild("HumanoidRootPart")
                if hrp then
                    table.insert(results, hrp)
                end
            end
        end
    end
    return results
end

local function followUntilGone(target)
    local stepConn
    stepConn = RunService.Heartbeat:Connect(function()
        if not _G.AutoFarmAnimalActive or not target or not target.Parent then
            stepConn:Disconnect()
            return
        end
        local root = getRoot()
        if root then
            root.CFrame = target.CFrame * CFrame.new(0, 1.6, 0.4)
        end
    end)

    while _G.AutoFarmAnimalActive and target and target.Parent do
        task.wait(0.5)
    end

    if stepConn.Connected then
        stepConn:Disconnect()
    end
end

task.spawn(function()
    while _G.AutoFarmAnimalActive do
        local targets = findAnimalRoots()
        local target = targets[1]

        if target then
            teleportTo(target)
            followUntilGone(target)
        else
            print("[AutoFarmAnimal] Brak zwierzat. Czekam...")
            local waited = 0
            while _G.AutoFarmAnimalActive and waited < 5 do
                task.wait(1)
                waited = waited + 1
                if #findAnimalRoots() > 0 then break end
            end
        end
    end

    _G.__AutoFarmAnimalRunning = nil
    print("[AutoFarmAnimal] Skrypt zatrzymany.")
end)

print("[AutoFarmAnimal] Aktywny.")
