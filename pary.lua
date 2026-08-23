--[[
=========================================================================
    NO MERCY HUB V3.6 – PART SELECTION + FOV SLIDER + CARRY AUTO‑SHOOT
    - Added body part selection (Head/Torso/Left Arm/Right Arm)
    - FOV radius now adjustable via slider
    - Laser disabled by default
    - Auto‑shoot when being carried by killer (toggle)
    - Prediction works with any part
=========================================================================
]]

local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local Workspace           = game:GetService("Workspace")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local CoreGui             = game:GetService("CoreGui")
local UserInputService    = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

-- ==================== THEME CONFIG ====================
local THEME = {
    Bg       = Color3.fromRGB(12, 12, 18),
    Dark     = Color3.fromRGB(18, 18, 26),
    Panel    = Color3.fromRGB(24, 24, 35),
    Accent   = Color3.fromRGB(138, 43, 226),
    Green    = Color3.fromRGB(46, 204, 113),
    Red      = Color3.fromRGB(231, 76, 60),
    White    = Color3.fromRGB(255, 255, 255),
    TextDim  = Color3.fromRGB(150, 150, 170),
}

local TARGET_COLORS = {
    Killer   = Color3.fromRGB(255, 60, 60),
    Survivor = Color3.fromRGB(52, 152, 219),
    Zombie   = Color3.fromRGB(46, 204, 113),
    All      = Color3.fromRGB(241, 196, 15),
}

-- ==================== STATE CONFIG ====================
local Config = {
    AimbotEnabled   = true,
    AimVersion      = "V1",            -- V1: free aim, V2: camera lock
    TargetType      = "Killer",
    SpecificName    = "",
    TargetPart      = "Head",          -- "Head", "Torso", "Left Arm", "Right Arm"
    MaxDistance     = 800,
    Prediction      = true,
    AutoShoot       = true,
    FireDelay       = 0.1,
    LaserEnabled    = false,           -- OFF by default
    FOVCircleOn     = true,
    FOVRadius       = 180,             -- will be updated by slider
    AutoShootCarried = true,           -- shoot killer when carried
}

local CurrentTarget = nil
local LastFireTime = 0

-- ==================== VISUAL: LASER TRACER ====================
local LaserPart = Instance.new("Part")
LaserPart.Name = "NM_LaserTracer"
LaserPart.Anchored = true
LaserPart.CanCollide = false
LaserPart.CanQuery = false
LaserPart.CanTouch = false
LaserPart.Material = Enum.Material.Neon
LaserPart.Transparency = 1
LaserPart.Parent = Workspace

-- ==================== VISUAL: SCREEN FOV CIRCLE ====================
local guiParent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
pcall(function() if guiParent:FindFirstChild("NoMercyHubV36") then guiParent.NoMercyHubV36:Destroy() end end)

local ScreenGui = Instance.new("ScreenGui", guiParent)
ScreenGui.Name = "NoMercyHubV36"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local FOVFrame = Instance.new("Frame", ScreenGui)
FOVFrame.Name = "FOVCircle"
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.Size = UDim2.new(0, Config.FOVRadius * 2, 0, Config.FOVRadius * 2)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = Config.FOVCircleOn

local UICornerFOV = Instance.new("UICorner", FOVFrame)
UICornerFOV.CornerRadius = UDim.new(1, 0)

local UIStrokeFOV = Instance.new("UIStroke", FOVFrame)
UIStrokeFOV.Color = Color3.fromRGB(255, 255, 255)
UIStrokeFOV.Thickness = 1.8
UIStrokeFOV.Transparency = 0.2

-- ==================== UTILS TARGET & COMBAT ====================
local function ClassifyTarget(char, plr)
    local n = (char and char.Name or ""):lower()
    local t = (plr and plr.Team and plr.Team.Name or ""):lower()
    if n:find("kill") or n:find("monster") or n:find("slasher") or n:find("murder") or t:find("kill") then 
        return "Killer" 
    end
    if n:find("zomb") or n:find("infect") then return "Zombie" end
    if plr then return "Survivor" end
    return "Killer"
end

local function IsAlive(char)
    if not char or not char.Parent then return false end
    local h = char:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0 and char:FindFirstChild("Head") ~= nil
end

local function MatchesFilter(p, char, kind)
    if Config.TargetType == "All" then return true end
    if Config.TargetType == "Survivor" and Config.SpecificName ~= "" then
        return p.Name:lower() == Config.SpecificName:lower()
    end
    return kind == Config.TargetType
end

-- Get the specified target part
local function GetTargetPart(char)
    if not char then return nil end
    local partName = Config.TargetPart
    if partName == "Head" then
        return char:FindFirstChild("Head")
    elseif partName == "Torso" then
        return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    elseif partName == "Left Arm" then
        return char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm")
    elseif partName == "Right Arm" then
        return char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm")
    else
        return char:FindFirstChild("Head")  -- fallback
    end
end

-- Detect if LocalPlayer is being carried by a killer
local function IsBeingCarried()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    -- Check all constraints attached to the character
    for _, constraint in ipairs(char:GetDescendants()) do
        if constraint:IsA("Weld") or constraint:IsA("Motor6D") then
            local part0 = constraint.Part0
            local part1 = constraint.Part1
            if part0 and part1 then
                local p0Parent = part0:FindFirstAncestorOfClass("Model")
                local p1Parent = part1:FindFirstAncestorOfClass("Model")
                if p0Parent and p1Parent and p0Parent ~= p1Parent then
                    -- Check if one of the parents is a Player character
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            if p0Parent == player.Character or p1Parent == player.Character then
                                -- Check if the other parent is our character
                                if (p0Parent == char or p1Parent == char) then
                                    return player
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function FindBestTarget()
    local origin = Camera.CFrame.Position
    local best, bestScore = nil, math.huge
    
    -- If being carried and auto-shoot carried is enabled, force target to carrier
    if Config.AutoShootCarried then
        local carrier = IsBeingCarried()
        if carrier and IsAlive(carrier.Character) then
            local kind = ClassifyTarget(carrier.Character, carrier)
            -- Allow any kind, but we'll treat as Killer for color
            return { player = carrier, char = carrier.Character, kind = "Killer", name = carrier.Name }
        end
    end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsAlive(p.Character) then
            local kind = ClassifyTarget(p.Character, p)
            if MatchesFilter(p, p.Character, kind) then
                local part = GetTargetPart(p.Character)
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if mouseDist <= Config.FOVRadius then
                            local dist = (part.Position - origin).Magnitude
                            if dist <= Config.MaxDistance and dist < bestScore then
                                best = { player = p, char = p.Character, kind = kind, name = p.Name }
                                bestScore = dist
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local function GetTargetPosition(char)
    local part = GetTargetPart(char)
    if not part then return nil end
    if not Config.Prediction then return part.Position end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp.AssemblyLinearVelocity then
        local travelTime = (Camera.CFrame.Position - part.Position).Magnitude / 700
        return part.Position + hrp.AssemblyLinearVelocity * travelTime
    end
    return part.Position
end

local function FireWeapon(targetPos)
    local now = tick()
    if now - LastFireTime < Config.FireDelay then return end
    LastFireTime = now

    local char = LocalPlayer.Character
    if not char then return end
    local tof = char:FindFirstChild("Twist of Fate")
    local gun = tof and tof:FindFirstChild("Right Arm") and tof["Right Arm"]:FindFirstChild("EmperorGun")
    local remote = ReplicatedStorage:FindFirstChild("Remotes")
    remote = remote and remote:FindFirstChild("Items")
    remote = remote and remote:FindFirstChild("Twist of Fate")
    remote = remote and remote:FindFirstChild("Fire")

    if gun and remote then
        local from = gun:IsA("BasePart") and gun.Position or Camera.CFrame.Position
        local dir = (targetPos - from).Unit
        pcall(function() remote:FireServer(gun, Vector3.new(dir.X, dir.Y, dir.Z)) end)
    end
end

-- ==================== MAIN AIMBOT LOOP ====================
RunService.RenderStepped:Connect(function()
    FOVFrame.Visible = Config.FOVCircleOn
    FOVFrame.Size = UDim2.new(0, Config.FOVRadius * 2, 0, Config.FOVRadius * 2)

    if not Config.AimbotEnabled then
        LaserPart.Transparency = 1
        return
    end

    if not (CurrentTarget and IsAlive(CurrentTarget.char) and MatchesFilter(CurrentTarget.player, CurrentTarget.char, CurrentTarget.kind)) then
        CurrentTarget = FindBestTarget()
    end

    if CurrentTarget then
        local pos = GetTargetPosition(CurrentTarget.char)
        if pos then
            if Config.LaserEnabled then
                local gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Twist of Fate")
                gun = gun and gun:FindFirstChild("Right Arm") and gun["Right Arm"]:FindFirstChild("EmperorGun")
                local from = (gun and gun.Position) or Camera.CFrame.Position
                
                LaserPart.Transparency = 0.25
                LaserPart.Color = TARGET_COLORS[CurrentTarget.kind] or THEME.White
                LaserPart.CFrame = CFrame.lookAt(from, pos) * CFrame.new(0, 0, -(pos - from).Magnitude / 2)
                LaserPart.Size = Vector3.new(0.08, 0.08, (pos - from).Magnitude)
            else
                LaserPart.Transparency = 1
            end

            if Config.AimVersion == "V2" then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, pos)
            end

            if Config.AutoShoot then
                FireWeapon(pos)
            end
        end
    else
        LaserPart.Transparency = 1
    end
end)

-- ==================== MODULAR UI INTERFACE ====================
local Bubble = Instance.new("ImageButton", ScreenGui)
Bubble.Size = UDim2.new(0, 55, 0, 55)
Bubble.Position = UDim2.new(0, 15, 0.25, 0)
Bubble.BackgroundColor3 = THEME.Dark
Bubble.Image = "rbxassetid://126404877070566"
Bubble.Active = true
Bubble.Draggable = true
Instance.new("UICorner", Bubble).CornerRadius = UDim.new(1, 0)

local Window = Instance.new("Frame", ScreenGui)
Window.Size = UDim2.new(0, 500, 0, 420)   -- increased height for new controls
Window.Position = UDim2.new(0.5, -250, 0.5, -210)
Window.BackgroundColor3 = THEME.Bg
Window.Active = true
Window.Draggable = true
Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 12)

Bubble.MouseButton1Click:Connect(function() Window.Visible = not Window.Visible end)

local Header = Instance.new("Frame", Window)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = THEME.Dark
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "NO MERCY HUB V3.6 – PART SELECTION"
Title.TextColor3 = THEME.White
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -13)
CloseBtn.BackgroundColor3 = THEME.Red
CloseBtn.Text = "X"
CloseBtn.TextColor3 = THEME.White
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() Window.Visible = false end)

local Sidebar = Instance.new("ScrollingFrame", Window)
Sidebar.Size = UDim2.new(0, 130, 1, -50)
Sidebar.Position = UDim2.new(0, 10, 0, 45)
Sidebar.BackgroundTransparency = 1
Sidebar.ScrollBarThickness = 2
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
local sideLayout = Instance.new("UIListLayout", Sidebar)
sideLayout.Padding = UDim.new(0, 5)

local Container = Instance.new("Frame", Window)
Container.Size = UDim2.new(1, -150, 1, -50)
Container.Position = UDim2.new(0, 145, 0, 45)
Container.BackgroundColor3 = THEME.Panel
Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)

local Tabs = {}
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(1, 0, 0, 32)
    TabBtn.BackgroundColor3 = THEME.Dark
    TabBtn.Text = "  " .. name
    TabBtn.TextColor3 = THEME.TextDim
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize, TabBtn.TextXAlignment = 11, Enum.TextXAlignment.Left
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame", Container)
    Page.Size = UDim2.new(1, -10, 1, -10)
    Page.Position = UDim2.new(0, 5, 0, 5)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = false
    
    local pageLayout = Instance.new("UIListLayout", Page)
    pageLayout.Padding = UDim.new(0, 8)

    Tabs[name] = { Btn = TabBtn, Page = Page }
    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Page.Visible = false t.Btn.TextColor3 = THEME.TextDim end
        Page.Visible = true
        TabBtn.TextColor3 = THEME.White
    end)
    return Page
end

local AimTab = CreateTab("Aimbot Setup")
local VisualTab = CreateTab("Visuals & Laser")

Tabs["Aimbot Setup"].Page.Visible = true
Tabs["Aimbot Setup"].Btn.TextColor3 = THEME.White

-- ==================== HELPER UI ELEMENTS ====================
local function AddToggle(parent, text, default, callback)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 32)
    holder.BackgroundColor3 = THEME.Dark
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(1, -45, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextColor3 = THEME.White
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local dot = Instance.new("Frame", holder)
    dot.Size = UDim2.new(0, 28, 0, 14)
    dot.Position = UDim2.new(1, -36, 0.5, -7)
    dot.BackgroundColor3 = default and THEME.Green or Color3.fromRGB(60, 60, 75)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local state = default
    holder.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            state = not state
            dot.BackgroundColor3 = state and THEME.Green or Color3.fromRGB(60, 60, 75)
            callback(state)
        end
    end)
end

local function AddLabel(parent, text, color)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or THEME.TextDim
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

-- ==================== AIMBOT TAB CONTENT ====================
AddToggle(AimTab, "Enable Aim Lock", Config.AimbotEnabled, function(v) Config.AimbotEnabled = v end)
AddToggle(AimTab, "Auto Shoot Target", Config.AutoShoot, function(v) Config.AutoShoot = v end)
AddToggle(AimTab, "Auto Shoot When Carried", Config.AutoShootCarried, function(v) Config.AutoShootCarried = v end)

-- Version selector
local verFrame = Instance.new("Frame", AimTab)
verFrame.Size = UDim2.new(1, 0, 0, 50)
verFrame.BackgroundColor3 = THEME.Dark
Instance.new("UICorner", verFrame).CornerRadius = UDim.new(0, 6)

local verLbl = Instance.new("TextLabel", verFrame)
verLbl.Size = UDim2.new(1, -10, 0, 16)
verLbl.Position = UDim2.new(0, 8, 0, 2)
verLbl.BackgroundTransparency = 1
verLbl.Text = "Mode Aimbot (Klik V1 / V2):"
verLbl.TextColor3 = THEME.TextDim
verLbl.Font = Enum.Font.GothamMedium
verLbl.TextSize = 10
verLbl.TextXAlignment = Enum.TextXAlignment.Left

local btnV1 = Instance.new("TextButton", verFrame)
btnV1.Size = UDim2.new(0.48, 0, 0, 24)
btnV1.Position = UDim2.new(0, 5, 0, 22)
btnV1.BackgroundColor3 = THEME.Green
btnV1.Text = "V1 (Free Coord)"
btnV1.TextColor3 = THEME.White
btnV1.Font = Enum.Font.GothamBold
btnV1.TextSize = 10
Instance.new("UICorner", btnV1).CornerRadius = UDim.new(0, 4)

local btnV2 = Instance.new("TextButton", verFrame)
btnV2.Size = UDim2.new(0.48, 0, 0, 24)
btnV2.Position = UDim2.new(0.52, -2, 0, 22)
btnV2.BackgroundColor3 = THEME.Panel
btnV2.Text = "V2 (Cam Lock)"
btnV2.TextColor3 = THEME.TextDim
btnV2.Font = Enum.Font.GothamBold
btnV2.TextSize = 10
Instance.new("UICorner", btnV2).CornerRadius = UDim.new(0, 4)

btnV1.MouseButton1Click:Connect(function()
    Config.AimVersion = "V1"
    btnV1.BackgroundColor3 = THEME.Green
    btnV1.TextColor3 = THEME.White
    btnV2.BackgroundColor3 = THEME.Panel
    btnV2.TextColor3 = THEME.TextDim
end)

btnV2.MouseButton1Click:Connect(function()
    Config.AimVersion = "V2"
    btnV2.BackgroundColor3 = THEME.Green
    btnV2.TextColor3 = THEME.White
    btnV1.BackgroundColor3 = THEME.Panel
    btnV1.TextColor3 = THEME.TextDim
end)

-- Target Part Selection
AddLabel(AimTab, "Target Body Part:", THEME.Accent)
local partContainer = Instance.new("Frame", AimTab)
partContainer.Size = UDim2.new(1, 0, 0, 28)
partContainer.BackgroundTransparency = 1
local pcLayout = Instance.new("UIListLayout", partContainer)
pcLayout.FillDirection = Enum.FillDirection.Horizontal
pcLayout.Padding = UDim.new(0, 5)

local partNames = {"Head", "Torso", "Left Arm", "Right Arm"}
for _, pName in ipairs(partNames) do
    local pBtn = Instance.new("TextButton", partContainer)
    pBtn.Size = UDim2.new(0.24, 0, 1, 0)
    pBtn.BackgroundColor3 = (Config.TargetPart == pName) and THEME.Accent or THEME.Dark
    pBtn.Text = pName
    pBtn.TextColor3 = THEME.White
    pBtn.Font = Enum.Font.GothamBold
    pBtn.TextSize = 9
    Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)
    
    pBtn.MouseButton1Click:Connect(function()
        Config.TargetPart = pName
        CurrentTarget = nil
        for _, child in ipairs(partContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = (child.Text == pName) and THEME.Accent or THEME.Dark
            end
        end
    end)
end

-- Target Category Selection
AddLabel(AimTab, "Target Category:", THEME.Accent)
local typesContainer = Instance.new("Frame", AimTab)
typesContainer.Size = UDim2.new(1, 0, 0, 28)
typesContainer.BackgroundTransparency = 1
local tcLayout = Instance.new("UIListLayout", typesContainer)
tcLayout.FillDirection = Enum.FillDirection.Horizontal
tcLayout.Padding = UDim.new(0, 5)

local survivorDropdown = Instance.new("ScrollingFrame", AimTab)
survivorDropdown.Size = UDim2.new(1, 0, 0, 90)
survivorDropdown.BackgroundColor3 = THEME.Dark
survivorDropdown.ScrollBarThickness = 3
survivorDropdown.AutomaticCanvasSize = Enum.AutomaticSize.Y
survivorDropdown.Visible = false
Instance.new("UICorner", survivorDropdown).CornerRadius = UDim.new(0, 6)
local sdl = Instance.new("UIListLayout", survivorDropdown)
sdl.Padding = UDim.new(0, 3)

local function RefreshSurvivors()
    for _, c in ipairs(survivorDropdown:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local sBtn = Instance.new("TextButton", survivorDropdown)
            sBtn.Size = UDim2.new(1, -4, 0, 24)
            sBtn.BackgroundColor3 = THEME.Panel
            sBtn.Text = "  " .. p.Name
            sBtn.TextColor3 = THEME.White
            sBtn.TextSize = 10
            sBtn.Font = Enum.Font.Gotham
            sBtn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", sBtn).CornerRadius = UDim.new(0, 4)
            sBtn.MouseButton1Click:Connect(function()
                Config.SpecificName = p.Name
                CurrentTarget = nil
                survivorDropdown.Visible = false
            end)
        end
    end
end

for _, tName in ipairs({"Killer", "Survivor", "Zombie"}) do
    local tBtn = Instance.new("TextButton", typesContainer)
    tBtn.Size = UDim2.new(0.32, 0, 1, 0)
    tBtn.BackgroundColor3 = (Config.TargetType == tName) and THEME.Accent or THEME.Dark
    tBtn.Text = tName
    tBtn.TextColor3 = THEME.White
    tBtn.Font = Enum.Font.GothamBold
    tBtn.TextSize = 10
    Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 6)
    
    tBtn.MouseButton1Click:Connect(function()
        Config.TargetType = tName
        CurrentTarget = nil
        survivorDropdown.Visible = (tName == "Survivor")
        if tName == "Survivor" then RefreshSurvivors() end
        for _, child in ipairs(typesContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = (child.Text == tName) and THEME.Accent or THEME.Dark
            end
        end
    end)
end

-- ==================== VISUAL TAB CONTENT ====================
AddToggle(VisualTab, "Laser Tracer ON/OFF", Config.LaserEnabled, function(v) Config.LaserEnabled = v end)
AddToggle(VisualTab, "FOV Circle ON/OFF", Config.FOVCircleOn, function(v) Config.FOVCircleOn = v end)

-- FOV Radius Slider
AddLabel(VisualTab, "FOV Radius: " .. Config.FOVRadius, THEME.Accent)
local sliderFrame = Instance.new("Frame", VisualTab)
sliderFrame.Size = UDim2.new(1, 0, 0, 30)
sliderFrame.BackgroundColor3 = THEME.Dark
Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 6)

local slider = Instance.new("Frame", sliderFrame)
slider.Size = UDim2.new(0.9, 0, 0, 6)
slider.Position = UDim2.new(0.05, 0, 0.5, -3)
slider.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
Instance.new("UICorner", slider).CornerRadius = UDim.new(1, 0)

local fill = Instance.new("Frame", slider)
fill.Size = UDim2.new((Config.FOVRadius - 50) / 250, 0, 1, 0)  -- range 50-300
fill.BackgroundColor3 = THEME.Accent
Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

local dragBtn = Instance.new("TextButton", slider)
dragBtn.Size = UDim2.new(0, 18, 0, 18)
dragBtn.Position = UDim2.new((Config.FOVRadius - 50) / 250, -9, 0.5, -9)
dragBtn.BackgroundColor3 = THEME.White
dragBtn.Text = ""
Instance.new("UICorner", dragBtn).CornerRadius = UDim.new(1, 0)

local fovValue = Instance.new("TextLabel", sliderFrame)
fovValue.Size = UDim2.new(0.1, 0, 1, 0)
fovValue.Position = UDim2.new(0.88, 0, 0, 0)
fovValue.BackgroundTransparency = 1
fovValue.Text = tostring(Config.FOVRadius)
fovValue.TextColor3 = THEME.White
fovValue.Font = Enum.Font.GothamBold
fovValue.TextSize = 12

local dragging = false
dragBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
end)
dragBtn.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

UserInputService.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local absPos = slider.AbsolutePosition
        local width = slider.AbsoluteSize.X
        local mouseX = inp.Position.X
        local percent = math.clamp((mouseX - absPos.X) / width, 0, 1)
        local newRadius = math.floor(50 + percent * 250)  -- 50 to 300
        Config.FOVRadius = newRadius
        fovValue.Text = tostring(newRadius)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        dragBtn.Position = UDim2.new(percent, -9, 0.5, -9)
    end
end)

print("✅ NO MERCY HUB V3.6 Loaded Successfully!")
