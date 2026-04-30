-- AutoFarmCollectables - automatycznie zbiera collectables (rosliny, krzaki itd.)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

if _G.AutoFarmCollectablesActive == nil then
    _G.AutoFarmCollectablesActive = true
end

if _G.__AutoFarmCollectablesRunning then
    return
end
_G.__AutoFarmCollectablesRunning = true

local TARGET_NAMES = {
    ["Meshes/Bush (1)"] = true,
    ["Meshes/Cattail_Cattail"] = true,
    ["Meshes/Wheat Plane"] = true,
    ["Meshes/Cotton Plant_Stem"] = true,
    ["Primary"] = true,
    ["Meshes/Corn Stalk"] = true,
}

local function getRoot()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

local function pressE()
    VirtualInputManager:SendKeyEvent(true, "E", false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, "E", false, game)
end

local function findNextCollectable()
    local islands = Workspace:FindFirstChild("Islands")
    if not islands then return nil end

    for _, island in ipairs(islands:GetChildren()) do
        local collectables = island:FindFirstChild("Collectables")
        if collectables then
            for _, model in ipairs(collectables:GetChildren()) do
                if model:IsA("Model") then
                    for _, descendant in ipairs(model:GetDescendants()) do
                        if TARGET_NAMES[descendant.Name] and descendant:IsA("BasePart") then
                            return descendant
                        end
                    end
                end
            end
        end
    end
    return nil
end

task.spawn(function()
    while _G.AutoFarmCollectablesActive do
        local target = findNextCollectable()
        if target then
            local root = getRoot()
            if root then
                root.CFrame = target.CFrame
                task.wait(0.7)
                pressE()
                task.wait(0.3)
            end
        else
            task.wait(1)
        end
    end

    _G.__AutoFarmCollectablesRunning = nil
    print("[AutoFarmCollectables] Skrypt zatrzymany.")
end)

print("[AutoFarmCollectables] Aktywny.")
