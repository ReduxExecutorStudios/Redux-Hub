-- ======================================================
-- Redux Hub - FULL UI FIXED
-- ======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local ESPEnabled = false
local FruitESP = {}
local ESPObjects = {}
local ESPConnections = {}
local Camera = workspace.CurrentCamera

local redzlib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/enzoplaaygamemg12/GUI123/refs/heads/main/RedzUiLib.lua"
))()

-- ======================================================
-- WINDOW
-- ======================================================
local Window = redzlib:MakeWindow({
    Title = "Redux Hub",
    SubTitle = "by Redux Studio V1.0"
})

-- ======================================================
-- SEA DETECTION
-- ======================================================
local PlaceId = game.PlaceId
local Sea = 1

if PlaceId == 4442272183 then
    Sea = 2
elseif PlaceId == 7449423635 then
    Sea = 3
end

-- ======================================================
-- DATA
-- ======================================================
local Islands = {
    [1] = {
        "Starter Island (Pirate)","Starter Island (Marine)","Middle Town",
        "Jungle","Pirate Village","Desert","Frozen Village",
        "Marineford","Skylands","Prison","Colosseum",
        "Magma Village","Underwater City","Fountain City"
    },
    [2] = {
        "Kingdom of Rose","Green Zone","Graveyard","Snow Mountain",
        "Hot and Cold","Cursed Ship","Ice Castle",
        "Forgotten Island","Dark Arena","Factory"
    },
    [3] = {
        "Port Town","Hydra Island","Great Tree","Floating Turtle",
        "Haunted Castle","Sea of Treats","Cake Land","Ice Cream Land",
        "Chocolate Land","Peanut Island","Candy Island",
        "Tiki Outpost","Submerged Island"
    }
}

-- ======================================================
-- ISLAND CFRAME (REAL TP)
-- ======================================================

local IslandCFrame = {
    [1] = {
        ["Starter Island (Pirate)"] = CFrame.new(1089, 16, 1424),
        ["Starter Island (Marine)"] = CFrame.new(-2573, 6, 2046),
        ["Middle Town"] = CFrame.new(-690, 15, 1582),
        ["Jungle"] = CFrame.new(-1612, 36, 150),
        ["Pirate Village"] = CFrame.new(-1180, 5, 3830),
        ["Desert"] = CFrame.new(1094, 6, 4219),
        ["Frozen Village"] = CFrame.new(1347, 105, -1320),
        ["Marineford"] = CFrame.new(-4500, 20, 4260),
        ["Skylands"] = CFrame.new(-4970, 717, -2620),
        ["Prison"] = CFrame.new(4875, 6, 735),
        ["Colosseum"] = CFrame.new(-1427, 7, -2792),
        ["Magma Village"] = CFrame.new(-5230, 8, 8500),
        ["Underwater City"] = CFrame.new(61163, 11, 1819),
        ["Fountain City"] = CFrame.new(5127, 38, 4105)
    },

    [2] = {
        ["Kingdom of Rose"] = CFrame.new(-388, 138, 1135),
        ["Green Zone"] = CFrame.new(-2448, 73, -3210),
        ["Graveyard"] = CFrame.new(-5400, 8, -715),
        ["Snow Mountain"] = CFrame.new(561, 401, -5297),
        ["Hot and Cold"] = CFrame.new(-6026, 15, -5071),
        ["Cursed Ship"] = CFrame.new(923, 125, 32885),
        ["Ice Castle"] = CFrame.new(5444, 30, -6230),
        ["Forgotten Island"] = CFrame.new(-3054, 238, -10175),
        ["Dark Arena"] = CFrame.new(3780, 60, -3490),
        ["Factory"] = CFrame.new(430, 210, -432)
    },

    [3] = {
        ["Port Town"] = CFrame.new(-290, 6, 5343),
        ["Hydra Island"] = CFrame.new(5228, 604, 345),
        ["Great Tree"] = CFrame.new(2681, 1682, -7190),
        ["Floating Turtle"] = CFrame.new(-1196, 332, -8862),
        ["Haunted Castle"] = CFrame.new(-9506, 142, 5535),
        ["Sea of Treats"] = CFrame.new(-2021, 36, -12028),
        ["Cake Land"] = CFrame.new(-1885, 19, -11666),
        ["Ice Cream Land"] = CFrame.new(-871, 66, -10900),
        ["Chocolate Land"] = CFrame.new(161, 27, -12258),
        ["Peanut Island"] = CFrame.new(-2137, 47, -10229),
        ["Candy Island"] = CFrame.new(-1014, 13, -14328),
        ["Tiki Outpost"] = CFrame.new(-16120, 15, -87),
        ["Submerged Island"] = CFrame.new(-3186, -40, -10035)
    }
}

local function TweenTo(cf)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local distance = (hrp.Position - cf.Position).Magnitude
    local time = math.clamp(distance / 300, 1, 6)

    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        { CFrame = cf }
    )

    tween:Play()
end

local function TeleportToIsland(islandName)
    local cf = IslandCFrame[Sea] and IslandCFrame[Sea][islandName]
    if cf then
        TweenTo(cf)
    else
        warn("CFrame não encontrado:", islandName)
    end
end

local Bosses = {
    [1] = {
        "Gorilla King","Vice Admiral","Warden","Chief Warden","Swan",
        "Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg"
    },
    [2] = {
        "Diamond","Jeremy","Fajita","Don Swan","Smoke Admiral",
        "Awakened Ice Admiral","Tide Keeper","Darkbeard"
    },
    [3] = {
        "Stone","Island Empress","Kilo Admiral","Captain Elephant",
        "Beautiful Pirate","Longma","Soul Reaper","Dough King",
        "Cake Prince","Rip Indra (True Form)","Tyrant"
    }
}

local Materials = {
    [1] = { "Scrap Metal","Leather","Angel Wings","Magma Ore","Fish Tail" },
    [2] = {
        "Scrap Metal","Leather","Fish Tail","Magma Ore",
        "Radioactive Material","Mystic Droplet","Dragon Scale"
    },
    [3] = {
        "Scrap Metal","Leather","Fish Tail","Magma Ore","Dragon Scale",
        "Mini Tusk","Vampire Fang","Conjured Cocoa","Gunpowder",
        "Sea Artifact","Ancient Core"
    }
}

local FlySpeed = 350
local TweenFlying = false

local function TweenFlyTo(cf)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local distance = (hrp.Position - cf.Position).Magnitude
    local time = distance / FlySpeed

    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        { CFrame = cf }
    )

    tween:Play()
end

local AutoTweenFruit = false

task.spawn(function()
    while task.wait(2) do
        if AutoTweenFruit then
            local fruit = FindFruit()
            if fruit and fruit:FindFirstChild("Handle") then
                TweenFlyTo(fruit.Handle.CFrame * CFrame.new(0, 6, 0))
            end
        end
    end
end)

local function ClearESP()
    for _, obj in pairs(ESPObjects) do
        if obj.Remove then
            obj:Remove()
        end
    end
    ESPObjects = {}

    for _, conn in pairs(ESPConnections) do
        conn:Disconnect()
    end
    ESPConnections = {}
end

local Camera = workspace.CurrentCamera

local function CreateFruitESP(tool)
    if FruitESP[tool] then return end
    if not tool:FindFirstChild("Handle") then return end

    local text = Drawing.new("Text")
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.Color = Color3.fromRGB(255, 255, 0)
    text.Text = tool.Name

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not ESPEnabled
        or not tool
        or not tool.Parent
        or tool.Parent ~= workspace
        or not tool:FindFirstChild("Handle") then

            if connection then connection:Disconnect() end
            text:Remove()
            FruitESP[tool] = nil
            return
        end

        local pos, visible = Camera:WorldToViewportPoint(tool.Handle.Position)
        text.Visible = visible

        if visible then
            text.Position = Vector2.new(pos.X, pos.Y)
        end
    end)

    FruitESP[tool] = {
        Text = text,
        Connection = connection
    }
end

local function FindFruit()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Tool") and v:FindFirstChild("Handle") then
            if string.find(v.Name, "Fruit") then
                return v
            end
        end
    end
end

workspace.DescendantAdded:Connect(function(obj)
    if ESPEnabled and obj:IsA("Tool") and obj:FindFirstChild("Handle") then
        if string.find(obj.Name, "Fruit") then
            CreateESP(obj.Handle, obj.Name, Color3.fromRGB(255, 255, 0))
        end
    end
end)

local function EnableFruitESP()
    -- frutas já carregadas
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Tool")
        and v:FindFirstChild("Handle")
        and string.find(v.Name, "Fruit") then
            CreateFruitESP(v)
        end
    end

    -- frutas que entrarem depois
    workspace.DescendantAdded:Connect(function(obj)
        if ESPEnabled
        and obj:IsA("Tool")
        and obj:FindFirstChild("Handle")
        and string.find(obj.Name, "Fruit") then
            CreateFruitESP(obj)
        end
    end)
end

local function DisableFruitESP()
    for tool, data in pairs(FruitESP) do
        if data.Connection then
            data.Connection:Disconnect()
        end
        if data.Text then
            data.Text:Remove()
        end
        FruitESP[tool] = nil
    end
end


-- ======================================================
-- HOME (STATUS REAL FUNCIONANDO)
-- ======================================================
local Home = Window:MakeTab({ "Home", "home" })

Home:AddSection("Discord Server")
Home:AddDiscordInvite({
    Name = "Redux Studio",
    Invite = "https://discord.gg/HkB97N772p"
})

Home:AddSection("States Script")

local pTimeZone = Home:AddParagraph({ "Time Zone", "Loading..." })
local pScript = Home:AddParagraph({ "Time Script", "00:00:00" })
local pServer = Home:AddParagraph({ "Time Server", "00:00:00" })

local pMoon = Home:AddParagraph({ "Full Moon", "0/5" })
local pEyes = Home:AddParagraph({ "Tyrant Eyes", "0/4" })

local pMirage = Home:AddParagraph({ "Mirage Island Spawn", "Loading..." })
local pKitsune = Home:AddParagraph({ "Kitsune Island Spawn", "Loading..." })
local pPre = Home:AddParagraph({ "Pre-historic Island Spawn", "Loading..." })
local pFrozen = Home:AddParagraph({ "Frozen Island Spawn", "Loading..." })
local pSword = Home:AddParagraph({ "Sword Dealer Legendy Spawn", "Loading..." })
local pFruit = Home:AddParagraph({ "Fruit Spawn", "Loading..." })
local pBerry = Home:AddParagraph({ "Berry Spawn", "Loading..." })
local pBarista = Home:AddParagraph({ "Barista Color Haki", "Loading..." })
local pRip = Home:AddParagraph({ "Rip Indra Spawn", "Loading..." })

-- ======================================================
-- FULL MOON SYSTEM
-- ======================================================

local MoonCycle = 20 * 60
local FullMoonPhase = 5

local function UpdateMoon()
    local serverTime = workspace.DistributedGameTime
    local phase = math.floor((serverTime % MoonCycle) / (MoonCycle / FullMoonPhase)) + 1
    
    phase = math.clamp(phase, 1, 5)

    if phase == FullMoonPhase then
        pMoon:Set("5/5 (Full Moon) 🌕")
    else
        pMoon:Set(phase .. "/5")
    end
end

-- ======================================================
-- TYRANT EYES
-- ======================================================

local function UpdateTyrantEyes()
    if Sea ~= 3 then
        pEyes:Set("0/4")
        return
    end

    local eyes = 0
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and string.find(v.Name:lower(), "eye") then
            eyes += 1
        end
    end

    pEyes:Set(math.clamp(eyes, 0, 4) .. "/4")
end

-- ======================================================
-- EXTRA STATUS
-- ======================================================

local function UpdateMirage()
    pMirage:Set(workspace:FindFirstChild("Mirage Island", true) and "✅ Spawned" or "❌ Not Spawned")
end

local function UpdateKitsune()
    pKitsune:Set(workspace:FindFirstChild("Kitsune Island", true) and "✅ Spawned" or "❌ Not Spawned")
end

local function UpdateRipIndra()
    pRip:Set(workspace:FindFirstChild("rip_indra", true) and "✅ Spawned" or "❌ Not Spawned")
end

local function UpdateFruit()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Tool")
        and v:FindFirstChild("Handle")
        and string.find(v.Name, "Fruit") then
            pFruit:Set("✅ Fruit Spawned: " .. v.Name)
            return
        end
    end
    pFruit:Set("❌ No Fruit Nearby")
end

local function UpdateBerry()
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Part") and string.find(v.Name:lower(), "berry") then
            pBerry:Set("✅ Spawned")
            return
        end
    end
    pBerry:Set("❌ Not Spawned")
end

local function UpdateSwordDealer()
    pSword:Set(workspace:FindFirstChild("Legendary Sword Dealer", true) and "✅ Spawned" or "❌ Not Spawned")
end

local function UpdateBarista()
    pBarista:Set(workspace:FindFirstChild("Barista", true) and "✅ Spawned" or "❌ Not Spawned")
end

-- ======================================================
-- FROZEN ISLAND
-- ======================================================

local function UpdateFrozen()
    local found =
        workspace:FindFirstChild("Frozen Island", true) or
        workspace:FindFirstChild("FrozenIsland", true) or
        workspace:FindFirstChild("Ice Island", true)

    if found then
        pFrozen:Set("✅ Spawned")
    else
        pFrozen:Set("❌ Not Spawned")
    end
end

-- ======================================================
-- PRE-HISTORIC ISLAND
-- ======================================================

local function UpdatePreHistoric()
    local found =
        workspace:FindFirstChild("Prehistoric Island", true) or
        workspace:FindFirstChild("Pre-Historic Island", true) or
        workspace:FindFirstChild("Prehistoric", true)

    if found then
        pPre:Set("✅ Spawned")
    else
        pPre:Set("❌ Not Spawned")
    end
end


local scriptStart = tick()

task.spawn(function()
    while task.wait(1) do
        pTimeZone:Set(os.date("%d/%m/%Y %H:%M:%S"))

        local t = math.floor(tick() - scriptStart)
        pScript:Set(string.format("%02d:%02d:%02d",
            math.floor(t/3600),
            math.floor(t/60)%60,
            t%60
        ))

        local s = math.floor(workspace.DistributedGameTime)
        pServer:Set(string.format("%02d:%02d:%02d",
            math.floor(s/3600),
            math.floor(s/60)%60,
            s%60
        ))
        UpdateMoon()
        UpdateTyrantEyes()
        UpdateMirage()
        UpdateKitsune()
        UpdateRipIndra()
        UpdateFruit()
        UpdateBerry()
        UpdateSwordDealer()
        UpdateBarista()
        UpdateFrozen()
        UpdatePreHistoric()
    end
end)

local Camera = workspace.CurrentCamera

local function CreateESP(part, text, color)
    local label = Drawing.new("Text")
    label.Size = 14
    label.Center = true
    label.Outline = true
    label.Color = color

    RunService.RenderStepped:Connect(function()
        if part and part.Parent then
            local pos, visible = Camera:WorldToViewportPoint(part.Position)
            label.Visible = visible
            if visible then
                label.Position = Vector2.new(pos.X, pos.Y)
                label.Text = text
            end
        else
            label:Remove()
        end
    end)
end

local function FindFruit()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Tool") and v:FindFirstChild("Handle") then
            if string.find(v.Name, "Fruit") then
                return v
            end
        end
    end
end


local function EnableFruitESP()
    ClearESP()

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Tool") and v:FindFirstChild("Handle") then
            if string.find(v.Name, "Fruit") then
                CreateESP(v.Handle, v.Name, Color3.fromRGB(255, 255, 0))
            end
        end
    end
end

workspace.DescendantAdded:Connect(function(obj)
    if not ESPEnabled then return end

    if obj:IsA("Tool")
    and obj:FindFirstChild("Handle")
    and string.find(obj.Name, "Fruit") then
        CreateESP(obj.Handle, obj.Name, Color3.fromRGB(255, 255, 0))
    end
end)

-- ======================================================
-- MAIN (AGORA 100% COMPLETO)
-- ======================================================
local Main = Window:MakeTab({ "Main", "menu" })

Main:AddDropdown({ "Farm Weapon", { "Melee","Sword","Gun","BloxFruits" }, "Melee" })
Main:AddDropdown({ "Farm Attack", { "Normal","FastAttack","⚠️SuperFastAttack" }, "Normal" })

Main:AddSection("Farm Normal")
Main:AddToggle({ "Auto Farm Level", false })
Main:AddToggle({ "Auto Farm Nearest", false })
Main:AddDropdown({ "Select Island Nearest", Islands[Sea], Islands[Sea][1] })

-- ================= SEA 3 =================
Main:AddSection("Farming ( Sea 3 )")
Main:AddToggle({ "Auto Pirate Raid", false })
Main:AddToggle({ "Auto Rip Indra", false })
Main:AddToggle({ "Auto Tyrant Spawn", false })
Main:AddToggle({ "Auto Soul Reaper", false })
Main:AddToggle({ "Auto Big Mom", false })
Main:AddToggle({ "Auto Farm Bone", false })
Main:AddToggle({ "Auto Haki V2", false })
Main:AddToggle({ "Auto Unlock Temple", false })
Main:AddToggle({ "Auto God Human", false })
Main:AddToggle({ "Auto Dragon Talon", false })
Main:AddToggle({ "Auto Electric Claw", false })
Main:AddToggle({ "Auto Cake Prince", false })
Main:AddToggle({ "Auto Dough King (Fully)", false })

-- ================= SEA 2 =================
Main:AddSection("Farming ( Sea 2 )")
Main:AddToggle({ "Auto Sea 3", false })
Main:AddToggle({ "Auto Factory", false })
Main:AddToggle({ "Auto Raid Law", false })
Main:AddToggle({ "Auto Buy Chip Raid Law", false })
Main:AddToggle({ "Auto Start Raid Law", false })
Main:AddToggle({ "Auto DarkBeard", false })
Main:AddToggle({ "Auto Sharkman Karate V2", false })
Main:AddToggle({ "Auto Death Step", false })

-- ================= SEA 1 =================
Main:AddSection("Farming ( Sea 1 )")
Main:AddToggle({ "Auto Sea 2", false })
Main:AddToggle({ "Auto Saber", false })
Main:AddToggle({ "Auto GrayBeard", false })
Main:AddToggle({ "Auto DarkBlade V2", false })

-- ================= EXTRAS =================
Main:AddSection("Extras 🎉")
Main:AddToggle({ "Auto Collect Berry", false })
Main:AddToggle({ "Auto Barista", false })

Main:AddDropdown({
    "Color Haki",
    {
        "Pure Red","Winter Sky","Snow White","Ruby",
        "Ocean Blue","Midnight Blue","Pink",
        "Dragon Red","Green","Yellow"
    },
    "Pure Red"
})

Main:AddButton({ "Buy Haki Color" })
Main:AddToggle({ "Auto Farm Observation Haki", false })

-- ================= BOSS =================
Main:AddSection("Farming Boss")
Main:AddDropdown({ "Boss Selection", Bosses[Sea], Bosses[Sea][1] })
Main:AddToggle({ "Auto Farm Boss", false })
Main:AddToggle({ "Auto Farm All Boss", false })
Main:AddToggle({ "Auto Farm Raid Boss", false })

-- ================= MATERIAL =================
Main:AddSection("Farming Material")
Main:AddDropdown({ "Material Selection", Materials[Sea], Materials[Sea][1] })
Main:AddToggle({ "Auto Farm Material", false })

-- ================ FARM MASTERY ====================
Main:AddSection("Farming Mastery")

Main:AddDropdown({
    "Selection Weapon",
    { "Gun", "BloxFruit" },
    "Gun"
})

Main:AddDropdown({
    "Select Skill",
    { "Z", "X", "C", "V", "F" }
})

Main:AddSlider({
    "Health Kill Mob",
    Min = 1,
    Max = 100,
    Default = 30
})

Main:AddDropdown({
    "Selection Island",
    Islands[Sea],
    Islands[Sea][1]
})

Main:AddToggle({ "Auto Farm Mastery", false })

-- ======================================================
-- SETTINGS (JÁ CORRETO)
-- ======================================================
local Settings = Window:MakeTab({ "Settings", "settings" })

Settings:AddSection("Farming Settings")
Settings:AddToggle({ "Auto Click", true })
Settings:AddToggle({ "Bring Mob", true })
Settings:AddDropdown({ "Bring Distance", { "200","300","400","500" }, "300" })
Settings:AddToggle({ "Auto Set Spawn Point", false })
Settings:AddToggle({ "Auto Buso Haki", true })
Settings:AddToggle({ "Auto Observation", false })
Settings:AddToggle({ "Auto Turn V3", false })
Settings:AddToggle({ "Auto Turn V4", false })

Settings:AddSection("Extras 🎉")
Settings:AddToggle({ "Auto Speed", true })
Settings:AddSlider({ "Speed", Min = 20, Max = 100, Default = 20 })
Settings:AddToggle({ "Auto Set Jump", true })
Settings:AddSlider({ "Jump", Min = 50, Max = 200, Default = 50 })

local AntiAFKEnabled = false
Settings:AddToggle({ "Anti AFK", false, function(state)
    AntiAFKEnabled = state
    if state then
        spawn(function()
            while AntiAFKEnabled do
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                task.wait(60)
            end
        end)
    end
end })

Settings:AddSection("Visual")
Settings:AddToggle({ "Disable Game Notify", false })
Settings:AddToggle({ "No Fog", false, function(state)
    local lighting = game:GetService("Lighting")
    if state then
        lighting.FogStart = 0
        lighting.FogEnd = 999999
    else
        lighting.FogStart = 0
        lighting.FogEnd = 500
    end
end })

local NoClipEnabled = false
Settings:AddToggle({ "No Clip", false, function(state)
    NoClipEnabled = state
    if state then
        spawn(function()
            while NoClipEnabled do
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end })

-- ======================================================
-- EXTRA TABS (SOON COMING)
-- ======================================================

local Fishing = Window:MakeTab({ "Fishing", "fish" })
Fishing:AddParagraph({ "Fishing", "SOON COMING" })

local ItemQuest = Window:MakeTab({ "Item / Quest", "sword" })
ItemQuest:AddParagraph({ "Item / Quest", "SOON COMING" })

local Race = Window:MakeTab({ "Race", "users" })
Race:AddParagraph({ "Race", "SOON COMING" })

local Vulcano = Window:MakeTab({ "Vulcano Island", "flame" })
Vulcano:AddParagraph({ "Vulcano Island", "SOON COMING" })

local SeaEvent = Window:MakeTab({ "Sea Event", "waves" })
SeaEvent:AddParagraph({ "Sea Event", "SOON COMING" })

local FruitRaid = Window:MakeTab({ "Fruit / Raid", "apple" })
FruitRaid:AddParagraph({ "Fruit / Raid", "SOON COMING" })

local Esp = Window:MakeTab({ "ESP", "eye" })
Esp:AddToggle({
    "Fruit ESP",
    false,
    function(state)
        ESPEnabled = state

        if state then
            EnableFruitESP()
        else
            DisableFruitESP()
        end
    end
})


local LocalPlayerTab = Window:MakeTab({ "Local Player", "users" })
LocalPlayerTab:AddParagraph({ "Local Player", "SOON COMING" })

local Teleport = Window:MakeTab({ "Teleport", "mouse" })
Teleport:AddButton({
    "Teleport Sea 1",
    function()
        game:GetService("TeleportService"):Teleport(2753915549, LocalPlayer)
    end
})

Teleport:AddButton({
    "Teleport Sea 2",
    function()
        game:GetService("TeleportService"):Teleport(4442272183, LocalPlayer)
    end
})

Teleport:AddButton({
    "Teleport Sea 3",
    function()
        game:GetService("TeleportService"):Teleport(7449423635, LocalPlayer)
    end
})

local selectedIsland = Islands[Sea][1]

Teleport:AddDropdown({
    "Select Island",
    Islands[Sea],
    Islands[Sea][1],
    function(value)
        selectedIsland = value
    end
})

Teleport:AddToggle({
    "Teleport for Island",
    false,
    function(state)
        if state then
            TeleportToIsland(selectedIsland)
        end
    end
})



local Shopping = Window:MakeTab({ "Shopping", "shopping-bag" })
Shopping:AddParagraph({ "Shopping", "SOON COMING" })

local Misc = Window:MakeTab({ "Misc", "calendar-search" })
Misc:AddParagraph({ "Misc", "SOON COMING" })

-- ======================================================
-- FINAL NOTIFICATION
-- ======================================================
redzlib:Notify({
    Text = "Redux Hub carregado com sucesso",
    Type = "success",
    Time = 4
})
