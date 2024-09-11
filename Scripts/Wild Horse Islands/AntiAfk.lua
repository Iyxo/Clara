local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

-- Flaga kontrolująca działanie skryptu
_G.AntiAFKActive = true -- Używamy _G, aby można było ją zmieniać z innego skryptu

-- Funkcja aktywująca VirtualUser w celu zapobiegania AFK
local function activateAntiAFK()
    if _G.AntiAFKActive then
        local GC = getconnections or get_signal_cons
        if GC then
            -- Jeśli getconnections jest dostępne, używamy go do wyłączenia sygnałów
            for _, v in pairs(GC(Players.LocalPlayer.Idled)) do
                if v["Disable"] then
                    v["Disable"](v)
                elseif v["Disconnect"] then
                    v["Disconnect"](v)
                end
            end
        else
            -- Inne podejście, używamy VirtualUser, jeśli getconnections nie jest dostępne
            Players.LocalPlayer.Idled:Connect(function()
                if _G.AntiAFKActive then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end
            end)
        end
    end
end

-- Wywołanie funkcji aktywującej
activateAntiAFK()

-- Monitorowanie zmiany flagi _G.AntiAFKActive
local function monitorAntiAFK()
    while true do
        wait(1) -- Sprawdzanie co sekundę
        if not _G.AntiAFKActive then
            -- Wyłączanie skryptu, jeśli flaga jest ustawiona na false
            print("Anti-AFK wyłączone.")
            break
        end
    end
end

-- Rozpoczęcie monitorowania
monitorAntiAFK()
