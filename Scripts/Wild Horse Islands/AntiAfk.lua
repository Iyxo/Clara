-- AntiAfk - blokuje wyrzucanie z gry za bezczynność
-- Mozna uruchomic samodzielnie albo z Loader.lua (czyta _G.AntiAFKActive)

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

if _G.AntiAFKActive == nil then
    _G.AntiAFKActive = true
end

if _G.__AntiAfkInstalled then
    return
end
_G.__AntiAfkInstalled = true

local idleConnection
local disabledConnections = {}

local function disableExistingIdleSignals()
    local getCons = getconnections or get_signal_cons
    if not getCons then return false end

    local ok, conns = pcall(getCons, LocalPlayer.Idled)
    if not ok or not conns then return false end

    for _, c in ipairs(conns) do
        pcall(function()
            if c.Disable then
                c:Disable()
            elseif c.Disconnect then
                c:Disconnect()
            end
            table.insert(disabledConnections, c)
        end)
    end
    return true
end

local function attachVirtualUserFallback()
    idleConnection = LocalPlayer.Idled:Connect(function()
        if not _G.AntiAFKActive then return end
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

if not disableExistingIdleSignals() then
    attachVirtualUserFallback()
end

task.spawn(function()
    while _G.AntiAFKActive do
        task.wait(1)
    end

    _G.__AntiAfkInstalled = nil

    if idleConnection then
        idleConnection:Disconnect()
        idleConnection = nil
    end

    for _, c in ipairs(disabledConnections) do
        pcall(function()
            if c.Enable then c:Enable() end
        end)
    end
    disabledConnections = {}

    print("[AntiAFK] Wylaczone.")
end)

print("[AntiAFK] Aktywne.")
