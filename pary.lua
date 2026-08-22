--[[
=========================================================================
    NO MERCY HUB V3.5 + FE INVISIBLE FIX (REAL BODY STAYS, JUST HIDDEN)
    - Fix: Badan asli gak di-hide jauh, tetap di posisi kamu
    - Fix: Transparency = 1 di badan asli (orang lain lihat = hilang)
    - Fix: Clone lokal 50% transparan (kamu lihat = ghost)
    - Fix: WASD bebas gerak, gak jatuh, gak mati
=========================================================================
]]

local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local Workspace           = game:GetService("Workspace")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local CoreGui             = game:GetService("CoreGui")
local UserInputService    = game:GetService("UserInputService")
local TweenService        = game:GetService("TweenService")

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
    AimbotEnabled = true,
    AimVersion    = "V1",
    TargetType    = "Killer",
    SpecificName  = "",
    MaxDistance   = 800,
    Prediction    = true,
    AutoShoot     = true,
    FireDelay     = 0.1,
    LaserEnabled  = true,
    FOVCircleOn   = true,
    FOVRadius     = 180,
    GhostEnabled  = false,
    NoClipEnabled = false,
}

local CurrentTarget = nil
local LastFireTime = 0

-- ==================== GHOST STATE ====================
local GhostController = nil
local GhostClone = nil
local GhostMoveConn = nil
local GhostSyncConn = nil
local SavedTransparency = {}
local SavedHumanoidSpeed = 16

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
pcall(function() if guiParent:FindFirstChild("NoMercyHubV35") then guiParent.NoMercyHubV35:Destroy() end end)

local ScreenGui = Instance.new("ScreenGui", guiParent)
ScreenGui.Name = "NoMercyHubV35"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local FOVFrame = Instance.new("Frame", ScreenGui)
FOVFrame.Name = "FOVCircle"
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.Size = UDim2.new(0, Config.FOVRadius * 2, 0, Config.FOVRadius * 2)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = Config.FOVCircleOn

Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0)

local UIStrokeFOV = Instance.new("UIStroke", FOVFrame)
UIStrokeFOV.Color = Color3.fromRGB(255, 255, 255)
UIStrokeFOV.Thickness = 1.8
UIStrokeFOV.Transparency = 0.2

-- ==================== UTILS TARGET & COMBAT ====================
local function ClassifyTarget(char, plr)
    local n = (char and char.Name or ""):lower()
    local t = (plr and plr.Team and plr.Team.Name or ""):lower()
    if n:find("kill") or n:find("monster") or n:find("slasher") or n:find("murder") or t:find("kill") then return "Killer" end
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

local function FindBestTarget()
    local origin = Camera.CFrame.Position
    local best, bestScore = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsAlive(p.Character) then
            local kind = ClassifyTarget(p.Character, p)
            if MatchesFilter(p, p.Character, kind) then
                local head = p.Character:FindFirstChild("Head")
                if head then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if mouseDist <= Config.FOVRadius then
                            local dist = (head.Position - origin).Magnitude
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

local function GetPredictPos(char)
    local head = char:FindFirstChild("Head")
    if not head then return nil end
    if not Config.Prediction then return head.Position end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp.AssemblyLinearVelocity then
        local travelTime = (Camera.CFrame.Position - head.Position).Magnitude / 700
        return head.Position + hrp.AssemblyLinearVelocity * travelTime
    end
    return head.Position
end

local function GetFireOrigin()
    if Config.GhostEnabled and GhostController and GhostController.Parent then
        return GhostController.Position
    end
    local char = LocalPlayer.Character
    if not char then return Camera.CFrame.Position end
    local tof = char:FindFirstChild("Twist of Fate")
    local gun = tof and tof:FindFirstChild("Right Arm") and tof["Right Arm"]:FindFirstChild("EmperorGun")
    return (gun and gun.Position) or Camera.CFrame.Position
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
        local from = GetFireOrigin()
        local dir = (targetPos - from).Unit
        pcall(function() remote:FireServer(gun, Vector3.new(dir.X, dir.Y, dir.Z)) end)
    end
end

-- ==================== GHOST / INVISIBLE SYSTEM (REAL FIX) ====================
local function StopGhost()
    if not Config.GhostEnabled then return end
    Config.GhostEnabled = false
    
    if GhostMoveConn then GhostMoveConn:Disconnect() GhostMoveConn = nil end
    if GhostSyncConn then GhostSyncConn:Disconnect() GhostSyncConn = nil end
    
    -- Hapus controller & clone
    if GhostController then GhostController:Destroy() GhostController = nil end
    if GhostClone then GhostClone:Destroy() GhostClone = nil end
    
    -- Restore badan asli (transparansi balik normal)
    local char = LocalPlayer.Character
    if char then
        for obj, val in pairs(SavedTransparency) do
            if obj and obj.Parent then
                pcall(function() obj.Transparency = val end)
            end
        end
        SavedTransparency = {}
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = SavedHumanoidSpeed
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
        end
    end
    
    Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
end

local function StartGhost()
    if Config.GhostEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    
    Config.GhostEnabled = true
    SavedHumanoidSpeed = hum.WalkSpeed
    
    -- ===== 1. HIDE BADAN ASLI (Transparency = 1, tapi tetap di posisi) =====
    SavedTransparency = {}
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            SavedTransparency[obj] = obj.Transparency
            obj.Transparency = 1        -- Hilang total (orang lain gak lihat)
            obj.CastShadow = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            SavedTransparency[obj] = obj.Transparency
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            SavedTransparency[obj] = obj.Enabled
            obj.Enabled = false
        end
    end
    
    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    hum.WalkSpeed = 0   -- Matiin gerakan humanoid (kita pake CFrame)
    
    -- ===== 2. BUAT CONTROLLER (Part lokal yang kita gerakin) =====
    GhostController = Instance.new("Part")
    GhostController.Name = "GhostController"
    GhostController.Size = Vector3.new(2, 2, 1)
    GhostController.Transparency = 1
    GhostController.CanCollide = false
    GhostController.Anchored = true
    GhostController.CFrame = hrp.CFrame
    GhostController.Parent = Workspace
    
    -- ===== 3. BUAT CLONE (Ini yang kamu lihat, transparan 50%) =====
    task.wait(0.1)
    local arch = char.Archivable
    char.Archivable = true
    GhostClone = char:Clone()
    char.Archivable = arch
    
    if GhostClone then
        GhostClone.Name = "GhostClone"
        
        -- Bersihin clone
        for _, obj in ipairs(GhostClone:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("Humanoid") then
                obj:Destroy()
            elseif obj:IsA("BasePart") or obj:IsA("MeshPart") then
                obj.Transparency = 0.5      -- Kamu lihat ghost 50%
                obj.CanCollide = false
                obj.Anchored = false
                obj.Massless = true
                obj.CastShadow = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 0.5
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                obj.Enabled = false
            end
        end
        
        -- Setup PrimaryPart biar bisa PivotTo
        local cHRP = GhostClone:FindFirstChild("HumanoidRootPart")
        if cHRP then
            GhostClone.PrimaryPart = cHRP
        end
        GhostClone.Parent = Workspace
    end
    
    -- Kamera ikut controller
    Camera.CameraSubject = GhostController
    
    -- ===== 4. MOVEMENT LOOP (WASD + Space + Shift) =====
    GhostMoveConn = RunService.RenderStepped:Connect(function(dt)
        if not GhostController or not GhostController.Parent then return end
        
        local camCF = Camera.CFrame
        local moveDir = Vector3.new()
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end
        
        local speed = 90
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then speed = 140 end
        
        if moveDir.Magnitude > 0 then
            GhostController.CFrame += moveDir.Unit * speed * dt
        end
    end)
    
    -- ===== 5. SYNC LOOP: Badan asli & Clone ikut Controller =====
    GhostSyncConn = RunService.Heartbeat:Connect(function()
        if not Config.GhostEnabled or not GhostController or not GhostController.Parent then return end
        
        -- Sync badan asli ke controller (biar server lihat posisi bener & tool jalan)
        if hrp and hrp.Parent then
            hrp.CFrame = GhostController.CFrame
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
        end
        
        -- Sync clone ke controller (biar kamu lihat diri sendiri)
        if GhostClone and GhostClone.Parent then
            pcall(function()
                if GhostClone.PrimaryPart then
                    GhostClone:PivotTo(GhostController.CFrame)
                else
                    local cHRP = GhostClone:FindFirstChild("HumanoidRootPart")
                    if cHRP then cHRP.CFrame = GhostController.CFrame end
                end
            end)
        end
    end)
end

-- ==================== NOCLIP SYSTEM ====================
local NoclipConnection = nil

local function SetCharacterCollision(on)
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            part.CanCollide = on
        end
    end
end

local function StartNoclip()
    if Config.NoClipEnabled then return end
    Config.NoClipEnabled = true
    if NoclipConnection then NoclipConnection:Disconnect() end
    NoclipConnection = RunService.Stepped:Connect(function()
        SetCharacterCollision(false)
    end)
end

local function StopNoclip()
    if not Config.NoClipEnabled then return end
    Config.NoClipEnabled = false
    if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
    SetCharacterCollision(true)
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
        local pos = GetPredictPos(CurrentTarget.char)
        if pos then
            if Config.LaserEnabled then
                local from = GetFireOrigin()
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
Window.Size = UDim2.new(0, 500, 0, 380)
Window.Position = UDim2.new(0.5, -250, 0.5, -190)
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
Title.Text = "NO MERCY HUB V3.5 — FE INVISIBLE FIX"
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
local GhostTab = CreateTab("FE Invisible")
local NoclipTab = CreateTab("NoClip")

Tabs["Aimbot Setup"].Page.Visible = true
Tabs["Aimbot Setup"].Btn.TextColor3 = THEME.White

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

-- ==================== AIMBOT TAB CONTENT ====================
AddToggle(AimTab, "Enable Aim Lock", Config.AimbotEnabled, function(v) Config.AimbotEnabled = v end)
AddToggle(AimTab, "Auto Shoot Target", Config.AutoShoot, function(v) Config.AutoShoot = v end)

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
    btnV1.BackgroundColor3 = THEME.Green; btnV1.TextColor3 = THEME.White
    btnV2.BackgroundColor3 = THEME.Panel; btnV2.TextColor3 = THEME.TextDim
end)

btnV2.MouseButton1Click:Connect(function()
    Config.AimVersion = "V2"
    btnV2.BackgroundColor3 = THEME.Green; btnV2.TextColor3 = THEME.White
    btnV1.BackgroundColor3 = THEME.Panel; btnV1.TextColor3 = THEME.TextDim
end)

local targetTypeLbl = Instance.new("TextLabel", AimTab)
targetTypeLbl.Size = UDim2.new(1, 0, 0, 18)
targetTypeLbl.BackgroundTransparency = 1
targetTypeLbl.Text = "Pilih Target Kategori:"
targetTypeLbl.TextColor3 = THEME.TextDim
targetTypeLbl.Font = Enum.Font.GothamMedium
targetTypeLbl.TextSize = 10
targetTypeLbl.TextXAlignment = Enum.TextXAlignment.Left

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

-- ==================== FE INVISIBLE TAB CONTENT ====================
AddToggle(GhostTab, "FE Invisible (Others Cant See)", false, function(v)
    if v then StartGhost() else StopGhost() end
end)

local ghostHint = Instance.new("TextLabel", GhostTab)
ghostHint.Size = UDim2.new(1, 0, 0, 80)
ghostHint.BackgroundTransparency = 1
ghostHint.Text = "Real body stays at your position but hidden (Transparency=1).\nYou see a ghost clone (50% visible).\nWASD = Move | Space = Up | Shift = Down | Ctrl = Turbo\nNO DEATH. NO FALL. FREE MOVEMENT."
ghostHint.TextColor3 = THEME.TextDim
ghostHint.TextSize = 10
ghostHint.Font = Enum.Font.Gotham
ghostHint.TextWrapped = true
ghostHint.TextXAlignment = Enum.TextXAlignment.Left

-- ==================== NOCLIP TAB CONTENT ====================
AddToggle(NoclipTab, "NoClip (Walk Thru Walls)", false, function(v)
    if v then StartNoclip() else StopNoclip() end
end)

local noclipHint = Instance.new("TextLabel", NoclipTab)
noclipHint.Size = UDim2.new(1, 0, 0, 30)
noclipHint.BackgroundTransparency = 1
noclipHint.Text = "Disables collision on all character parts.\nWorks in both visible and ghost mode."
noclipHint.TextColor3 = THEME.TextDim
noclipHint.TextSize = 10
noclipHint.Font = Enum.Font.Gotham
noclipHint.TextWrapped = true
noclipHint.TextXAlignment = Enum.TextXAlignment.Left

-- ==================== CHARACTER EVENTS ====================
LocalPlayer.CharacterRemoving:Connect(function()
    if Config.GhostEnabled then
        Config.GhostEnabled = false
        if GhostMoveConn then GhostMoveConn:Disconnect() GhostMoveConn = nil end
        if GhostSyncConn then GhostSyncConn:Disconnect() GhostSyncConn = nil end
        if GhostController then GhostController:Destroy() GhostController = nil end
        if GhostClone then GhostClone:Destroy() GhostClone = nil end
        SavedTransparency = {}
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.7)
    if Config.NoClipEnabled then
        StartNoclip()
    end
    -- Kalau mati terus respawn sementara invisible aktif, auto-nyalain lagi
    if Config.GhostEnabled then
        task.wait(0.5)
        StartGhost()
    end
end)

print("✅ NO MERCY HUB V3.5 — FE Invisible Fix Loaded!")
