# Clara - Wild Horse Islands (Roblox)

Zestaw skryptow do gry **Wild Horse Islands** w Robloxie, uruchamianych w executorze (Synapse / Solara / Wave / Krampus / itp.).

## Co tu jest

```
Clara-main/
├── Loader.lua                      <- GLOWNY plik (uruchamiasz go)
├── Clara.lua                       <- stara biblioteka UI (nie jest juz uzywana)
├── Example.lua                     <- przyklad uzycia Clara UI (referencja)
└── Scripts/Wild Horse Islands/
    ├── AntiAfk.lua                 <- blokuje wyrzucenie za AFK
    ├── AutoFarmAnimal.lua          <- automatyczna farma zwierzat
    ├── AutoFarmCollectables.lua    <- zbieranie roslin/krzakow
    ├── AutoFarmCrystals.lua        <- farma krysztalow na Unicorn Island
    ├── AutoFarmTrainingIsland.lua  <- farma na Training Island
    ├── HorseCatcher.lua            <- lapanie koni (Rayfield UI)
    ├── HorseManipulator.lua        <- manipulacja statystyk koni
    └── ButtonGameClicker.lua       <- auto-klikacz Button Game
```

## Jak uruchomic (najszybciej)

1. Wgraj caly folder na swoj GitHub (lub fork tego repo).
2. W pliku `Loader.lua` ustaw `CONFIG.BASE_URL` na raw URL do folderu `Scripts/Wild Horse Islands` w twoim repo, np.:
   ```lua
   BASE_URL = "https://raw.githubusercontent.com/TWOJ_NICK/Clara-main/main/Scripts/Wild%20Horse%20Islands"
   ```
   (spacje musza byc zakodowane jako `%20`)
3. W executorze wklej i wykonaj:
   ```lua
   loadstring(game:HttpGet("https://raw.githubusercontent.com/TWOJ_NICK/Clara-main/main/Loader.lua"))()
   ```
4. Otworzy sie menu Rayfield z zakladkami: **Auto Farm**, **Horse Catcher**, **Horse Manipulator**, **Button Game**, **Player**, **Settings**. Domyslnie menu chowa sie/pokazuje klawiszem **K**.

## Jak uruchomic bez GitHuba (lokalnie)

Jezeli twoj executor obsluguje `readfile`/`loadfile`, mozesz wrzucic folder do `workspace` executora i odpalic recznie:

```lua
loadfile("Clara-main/Scripts/Wild Horse Islands/AntiAfk.lua")()
loadfile("Clara-main/Scripts/Wild Horse Islands/AutoFarmAnimal.lua")()
-- itd.
```

Skrypty same zarzadzaja flagami `_G.*Active` i mozna je wylaczyc ustawiajac flage na `false`:

```lua
_G.AntiAFKActive = false
_G.AutoFarmAnimalActive = false
_G.AutoFarmCollectablesActive = false
_G.AutoFarmCrystalActive = false
_G.TrainingAutoFarmActive = false
```

## Co robi ktora zakladka

### Auto Farm
Toggle dla kazdej z malych farm:
- **Anti AFK** - nie zostaniesz wyrzucony za bezczynnosc
- **Auto Farm Animals** - teleport do zwierzat na wszystkich wyspach
- **Auto Farm Collectables** - zbiera rosliny (krzaki, kukurydza, bawelna, trzcina)
- **Auto Farm Crystals** - teleport nad krysztaly na Unicorn Island
- **Auto Farm Training Island** - automatyczne ukonczenie Training Island

### Horse Catcher
Pelny system lapania koni (CaptureProgress monitor, smart targeting, attachment vs smooth movement, noclip, cooldown).

### Horse Manipulator
Modyfikacja atrybutow zlapanych koni + auto-teleport.

### Button Game
Automatyczne klikanie w Button Game (mini-gra w WHI).

### Player
- Slider WalkSpeed (16-200)
- Slider JumpPower (50-500)
- Reset Character
- Wartosci sa zapamietane przez `Rayfield.Flags` i przywracane po respawnie.

### Settings
- Destroy UI - zamyka menu
- Wersja

## Wymagania

- Executor obslugujacy `loadstring`, `game:HttpGet`, `getconnections` (opcjonalne dla AntiAFK), `VirtualInputManager`.
- Internet (do pobrania Rayfield i skryptow z GitHuba).

## Problemy?

- **Menu sie nie pokazuje** - wcisnij **K** (domyslny skrot Rayfielda) lub sprawdz konsole executora czy nie ma bledow.
- **"Nie pobrano X.lua"** - zly `BASE_URL` w `Loader.lua` albo problemy z internetem. Sprawdz w przegladarce, czy URL otwiera surowy plik Lua.
- **Skrypt sie nie zatrzymuje** - przelacz toggle off, daj chwile na cleanup. Jezeli nadal dziala, otworz nowa instancje gry.
- **Postac sie respawnuje** - WalkSpeed/JumpPower sa wznawiane automatycznie z config Rayfielda.

## Zaslugi

- Clara UI Library: AZYsGithub
- Horse Catcher / Manipulator / Button Game Clicker: Iyxo (2025-07)
- Pozostale skrypty: ten zestaw
