--[[
  NO MERCY — VIOLENCE DISTRICT v2.0
  Full Migration: Zian Hub Features + Orion NO MERCY UI
  
  Structure:
  - All logic from Zian Hub ported
  - Orion library maintained
  - Config system preserved
  - Mobile-friendly
  - Full Generator system in Survivor tab
]]

local ICON = {
    Info      = "rbxassetid://7733964719",
    Crosshair = "rbxassetid://7733765307",
    Swords    = "rbxassetid://7734056608",
    Globe     = "rbxassetid://7733954760",
    Axe       = "rbxassetid://7733674079",
    User      = "rbxassetid://7743875962",
    Eye       = "rbxassetid://7733774602",
    Zap       = "rbxassetid://7733771628",
    Settings  = "rbxassetid://7734053495",
    Logo      = "rbxassetid://102609928046926",
    Banner    = "rbxassetid://138968189462646",
}

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================
--  GLOBAL CONFIG (From Zian Hub)
-- ============================================================
getgenv().VD = getgenv().VD or {
    -- Survivor
    AutoSkillcheck        = false,
    AutoSkillcheckMode    = "Normal",
    SURV_FleeKiller       = false,
    SURV_FleeDistance     = 40,
    SURV_AutoParry        = false,
    SURV_ParryMode        = "Legit",
    SURV_ParryAnimId      = "rbxassetid://109133187196613",
    SURV_ParryRange       = 12,
    SURV_ShowParryCircle  = true,
    Parry_Keybind         = "F3",
    SURV_AntiKnock        = false,
    SURV_FirstPerson      = false,
    AUTO_ToFAim           = false,
    AUTO_ToFAimRange      = 90,
    AUTO_ToFDotThreshold  = 0.5,
    AUTO_ToFTargetMode    = "Killer",
    AUTO_ToFAimPart       = "HumanoidRootPart",
    AUTO_ToFPredict       = true,
    AUTO_ToFBulletSpeed   = 200,
    -- Killer
    AUTO_Attack           = false,
    AUTO_AttackRange      = 12,
    KILLER_DestroyPallets = false,
    KILLER_AutoBreakGene  = false,
    KILLER_BlockVaults    = false,
    KILLER_AntiBlind      = false,
    KILLER_DoubleTap      = false,
    SPEAR_Aimbot          = false,
    SPEAR_Gravity         = 50,
    SPEAR_Speed           = 100,
    KILLER_CustomMasked   = "Richard",
    -- Visual
    DRAWING_ESP           = false,
    ESP_Skeleton          = false,
    ESP_Offscreen         = false,
    ESP_Velocity          = false,
    MaxDistance           = 2000,
    -- Misc
    InstantHealSelf       = false,
    AutoHealAll           = false,
    Destroyed             = false,
    SURV_GenBoost         = false,
    SURV_DraggableGenBypass = false,
    ESP_LowPerformance    = false,
    Fullbright            = false,
    NoFog                 = false,
    SURV_AutoDropPallet   = false,
    SURV_AutoDropPalletDist = 20,
    SURV_AutoDropPalletMode = "Aggressive",
    SURV_AutoVault        = false,
    SURV_AutoPalletSlide  = false,
    -- Player
    FLING_Enabled         = false,
    FLING_Strength        = 10000,
    TP_TargetPlayer       = "",
    -- Speed
    SpeedValue            = 16,
    -- Streamer
    StreamerMode          = false,
}

local VD = getgenv().VD

-- ============================================================
--  UTILITY FUNCTIONS
-- ============================================================
local function GetHolder()
    return (gethui and gethui()) or game:GetService("CoreGui")
end

local function isTeammate(player)
    return LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team
end

local function getPlayerColor(player)
    return isTeammate(player) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end

local function IsKiller(player)
    return player and player.Team and player.Team.Name == "Killer"
end

local function IsSurvivor(player)
    return player and player.Team and player.Team.Name == "Survivors"
end

local function GetRole()
    if not LocalPlayer.Team then return "Unknown" end
    local name = LocalPlayer.Team.Name
    if name == "Killer" then return "Killer" end
    if name == "Survivors" then return "Survivor" end
    return "Lobby"
end

local function clamp(v, min, max)
    return math.max(min, math.min(max, v))
end

-- ============================================================
--  CHARACTER REFS
-- ============================================================
local Character, Humanoid, Root

local function updateChar(char)
    Character = char or LocalPlayer.Character
    if Character then
        task.spawn(function()
            Humanoid = Character:WaitForChild("Humanoid", 5)
            Root = Character:WaitForChild("HumanoidRootPart", 5)
        end)
    else
        Humanoid, Root = nil, nil
    end
end
updateChar()
LocalPlayer.CharacterAdded:Connect(updateChar)
LocalPlayer.CharacterRemoving:Connect(function(char)
    if char == Character or char == LocalPlayer.Character then
        Character, Humanoid, Root = nil, nil, nil
    end
end)

-- ============================================================
--  WELCOME INTRO
-- ============================================================
local function ShowWelcomeIntro()
    local holder = GetHolder()
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "NoMercyWelcome"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.Parent = holder
    if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end

    local centerFrame = Instance.new("Frame")
    centerFrame.Size = UDim2.fromOffset(260, 260)
    centerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    centerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    centerFrame.BackgroundTransparency = 1
    centerFrame.ZIndex = 999
    centerFrame.Parent = gui

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.fromOffset(0, 0)
    img.Position = UDim2.new(0.5, 0, 0.4, 0)
    img.AnchorPoint = Vector2.new(0.5, 0.5)
    img.Image = ICON.Logo
    img.BackgroundTransparency = 1
    img.ZIndex = 999
    img.Parent = centerFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = img

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 4
    stroke.Transparency = 1
    stroke.Parent = img

    local introText = Instance.new("TextLabel")
    introText.Size = UDim2.new(1, 0, 0, 40)
    introText.Position = UDim2.new(0.5, 0, 0.75, 0)
    introText.AnchorPoint = Vector2.new(0.5, 0)
    introText.BackgroundTransparency = 1
    introText.Text = "WELCOME NO MERCY"
    introText.TextColor3 = Color3.fromRGB(255, 255, 255)
    introText.TextSize = 18
    introText.Font = Enum.Font.GothamBold
    introText.TextTransparency = 1
    introText.ZIndex = 999
    introText.Parent = centerFrame

    local tweenIn = TweenService:Create(img, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(150, 150)
    })
    local strokeIn = TweenService:Create(stroke, TweenInfo.new(0.4), { Transparency = 0 })
    local textIn = TweenService:Create(introText, TweenInfo.new(0.4), { TextTransparency = 0 })
    
    tweenIn:Play()
    strokeIn:Play()
    textIn:Play()
    tweenIn.Completed:Wait()

    local pulsing = true
    task.spawn(function()
        while pulsing do
            local t1 = TweenService:Create(stroke, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.8, Thickness = 6 })
            t1:Play()
            t1.Completed:Wait()
            if not pulsing then break end
            local t2 = TweenService:Create(stroke, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0, Thickness = 2 })
            t2:Play()
            t2.Completed:Wait()
        end
    end)

    task.wait(1.5)
    pulsing = false

    local tweenOut = TweenService:Create(img, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(0, 0)
    })
    local strokeOut = TweenService:Create(stroke, TweenInfo.new(0.3), { Transparency = 1 })
    local textOut = TweenService:Create(introText, TweenInfo.new(0.3), { TextTransparency = 1 })
    
    tweenOut:Play()
    strokeOut:Play()
    textOut:Play()
    tweenOut.Completed:Wait()

    gui:Destroy()
end

ShowWelcomeIntro()

-- ============================================================
--  LOAD ORION LIBRARY
-- ============================================================
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Marpiii/UiLib/refs/heads/main/source.lua"))()

local onCloseRequest

local Window = OrionLib:MakeWindow({
    Name = "NO MERCY — VIOLENCE DISTRICT",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "NoMercyViolence",
    IntroEnabled = false,
    Icon = ICON.Logo,
    CloseCallback = function()
        if onCloseRequest then onCloseRequest() end
    end,
})

-- ============================================================
--  BUBBLE TOGGLE SYSTEM
-- ============================================================
local bubbleGui = nil

local function FindMainWindow()
    local root = GetHolder()
    if not root then return nil end
    local marv = root:FindFirstChild("MarV")
    if not marv then return nil end

    for _, child in ipairs(marv:GetChildren()) do
        if child:IsA("Frame") and child.AbsoluteSize.X > 300 then
            return child
        end
    end
    return nil
end

local function makeBubble()
    if bubbleGui then bubbleGui:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "NoMercyBubble"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.Parent = GetHolder()
    if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end

    local btn = Instance.new("ImageButton")
    btn.Parent = gui
    btn.BackgroundColor3 = Color3.fromRGB(25, 30, 35)
    btn.Position = UDim2.new(0.02, 0, 0.2, 0)
    btn.Size = UDim2.fromOffset(48, 48)
    btn.Image = ICON.Logo
    btn.ScaleType = Enum.ScaleType.Fit
    btn.Active = true
    btn.Draggable = true
    btn.ZIndex = 10

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0
    stroke.Parent = btn

    local bubblePulsing = true
    task.spawn(function()
        while bubblePulsing and stroke and stroke.Parent do
            local t1 = TweenService:Create(stroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.8, Thickness = 4 })
            t1:Play()
            t1.Completed:Wait()
            if not bubblePulsing or not stroke or not stroke.Parent then break end
            local t2 = TweenService:Create(stroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0, Thickness = 2 })
            t2:Play()
            t2.Completed:Wait()
        end
    end)

    btn.MouseButton1Click:Connect(function()
        bubblePulsing = false
        local main = FindMainWindow()
        if main then
            main.Visible = true
        end
        bubbleGui:Destroy()
        bubbleGui = nil
    end)

    bubbleGui = gui
end

local function closeUI()
    local main = FindMainWindow()
    if main then
        main.Visible = false
    end
    makeBubble()
end

local function showUI()
    local main = FindMainWindow()
    if main then
        main.Visible = true
    end
end

local function confirmClose(fromCloseBtn)
    if fromCloseBtn then
        showUI()
    end

    local holder = GetHolder()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NoMercyConfirm"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.Parent = holder
    if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end

    local fade = Instance.new("Frame")
    fade.Size = UDim2.new(1, 0, 1, 0)
    fade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    fade.BackgroundTransparency = 0.4
    fade.ZIndex = 99
    fade.Parent = gui

    local box = Instance.new("Frame")
    box.Size = UDim2.fromOffset(280, 150)
    box.Position = UDim2.new(0.5, 0, 0.5, 0)
    box.AnchorPoint = Vector2.new(0.5, 0.5)
    box.BackgroundColor3 = Color3.fromRGB(28, 32, 38)
    box.BorderSizePixel = 0
    box.ZIndex = 100
    box.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = box

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 30)
    title.Position = UDim2.new(0, 20, 0, 15)
    title.BackgroundTransparency = 1
    title.Text = "Tutup NO MERCY?"
    title.TextColor3 = Color3.fromRGB(240, 240, 240)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 101
    title.Parent = box

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -40, 0, 30)
    desc.Position = UDim2.new(0, 20, 0, 48)
    desc.BackgroundTransparency = 1
    desc.Text = "Klik bubble untuk buka lagi."
    desc.TextColor3 = Color3.fromRGB(150, 150, 150)
    desc.TextSize = 14
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.ZIndex = 101
    desc.Parent = box

    local function destroy()
        gui:Destroy()
    end

    local function cancel()
        destroy()
        if fromCloseBtn then
            showUI()
        end
    end

    local btnYa = Instance.new("TextButton")
    btnYa.Size = UDim2.fromOffset(90, 36)
    btnYa.Position = UDim2.new(1, -200, 1, -50)
    btnYa.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btnYa.BorderSizePixel = 0
    btnYa.Text = "Ya"
    btnYa.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnYa.TextSize = 15
    btnYa.Font = Enum.Font.GothamBold
    btnYa.ZIndex = 101
    btnYa.Parent = box
    local cYa = Instance.new("UICorner"); cYa.CornerRadius = UDim.new(0, 8); cYa.Parent = btnYa

    btnYa.MouseButton1Click:Connect(function()
        destroy()
        closeUI()
    end)

    local btnTidak = Instance.new("TextButton")
    btnTidak.Size = UDim2.fromOffset(90, 36)
    btnTidak.Position = UDim2.new(1, -100, 1, -50)
    btnTidak.BackgroundColor3 = Color3.fromRGB(40, 45, 52)
    btnTidak.BorderSizePixel = 0
    btnTidak.Text = "Tidak"
    btnTidak.TextColor3 = Color3.fromRGB(240, 240, 240)
    btnTidak.TextSize = 15
    btnTidak.Font = Enum.Font.GothamBold
    btnTidak.ZIndex = 101
    btnTidak.Parent = box
    local cT = Instance.new("UICorner"); cT.CornerRadius = UDim.new(0, 8); cT.Parent = btnTidak

    btnTidak.MouseButton1Click:Connect(cancel)
    fade.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            cancel()
        end
    end)
end

onCloseRequest = function()
    confirmClose(true)
end

-- ============================================================
--  TABS
-- ============================================================
local InfoTab      = Window:MakeTab({ Name = "Info", Icon = ICON.Info, PremiumOnly = false })
local AimbotTab    = Window:MakeTab({ Name = "Aimbot", Icon = ICON.Crosshair, PremiumOnly = false })
local ParryTab     = Window:MakeTab({ Name = "Parry", Icon = ICON.Swords, PremiumOnly = false })
local TeleportTab  = Window:MakeTab({ Name = "Teleport", Icon = ICON.Globe, PremiumOnly = false })
local KillerTab    = Window:MakeTab({ Name = "Killer", Icon = ICON.Axe, PremiumOnly = false })
local SurvivorTab  = Window:MakeTab({ Name = "Survivor", Icon = ICON.User, PremiumOnly = false })
local PlayerTab    = Window:MakeTab({ Name = "Player", Icon = ICON.User, PremiumOnly = false })
local VisualTab    = Window:MakeTab({ Name = "Visual", Icon = ICON.Eye, PremiumOnly = false })
local SpeedTab     = Window:MakeTab({ Name = "Speed", Icon = ICON.Zap, PremiumOnly = false })
local SettingsTab  = Window:MakeTab({ Name = "Settings", Icon = ICON.Settings, PremiumOnly = false })

-- ============================================================
--  CORE SYSTEMS FROM ZIAN (PT. 1: AUTO PARRY)
-- ============================================================
local VD_ParryRange = Instance.new("CylinderHandleAdornment")
VD_ParryRange.Name = "IYAN_ParryRange"
VD_ParryRange.Radius = VD.SURV_ParryRange or 12
VD_ParryRange.InnerRadius = math.max(0.1, (VD.SURV_ParryRange or 12) - 0.15)
VD_ParryRange.Height = 0.01
VD_ParryRange.Color3 = Color3.fromRGB(80, 80, 80)
VD_ParryRange.AlwaysOnTop = false
VD_ParryRange.Transparency = 1
VD_ParryRange.Parent = GetHolder()

local function VD_UpdateParryRange()
    if not VD.SURV_AutoParry or not VD.SURV_ShowParryCircle then
        VD_ParryRange.Transparency = 1
        return
    end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        VD_ParryRange.Transparency = 1
        return
    end

    local currentMaxDist = VD.SURV_ParryRange or 12
    VD_ParryRange.Transparency = 0.4
    VD_ParryRange.Radius = currentMaxDist
    VD_ParryRange.InnerRadius = math.max(0.1, currentMaxDist - 0.15)

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { char }
    params.FilterType = Enum.RaycastFilterType.Exclude

    local ray = Workspace:Raycast(root.Position, Vector3.new(0, -15, 0), params)
    local groundPos = ray and ray.Position or (root.Position - Vector3.new(0, 3, 0))
    VD_ParryRange.CFrame = CFrame.new(groundPos + Vector3.new(0, 0.05, 0)) * CFrame.Angles(math.pi / 2, 0, 0)
end

local function HasParryingDagger()
    local char = LocalPlayer.Character
    if not char then return false end
    local dagger = char:FindFirstChild("Parrying Dagger")
    if dagger then return true end
    for _, child in ipairs(char:GetDescendants()) do
        if child.Name == "Parrying Dagger" and (child:IsA("Tool") or child:IsA("Accessory") or child:IsA("Model")) then
            return true
        end
    end
    return false
end

local ParryGradients = {}
local ParryIcon = nil

local function GetParryUIElements()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end

    table.clear(ParryGradients)
    ParryIcon = nil

    for _, screenName in ipairs({"Survivor", "Survivor-con"}) do
        local screen = playerGui:FindFirstChild(screenName)
        if screen then
            local gen = screen:FindFirstChild("Gen")
            if gen then
                local itemFrame = gen:FindFirstChild("ItemFrame")
                if itemFrame then
                    local gui = itemFrame:FindFirstChild("Gui")
                    if gui then
                        local bar = gui:FindFirstChild("Bar")
                        if bar then
                            local gradient = bar:FindFirstChild("UIGradient")
                            if gradient then
                                table.insert(ParryGradients, gradient)
                            end
                        end
                    end
                    local icon = itemFrame:FindFirstChild("icon")
                    if icon then ParryIcon = icon end
                end
            end
        end
    end
end

task.spawn(function()
    local waited = 0
    while #ParryGradients == 0 and waited < 10 do
        task.wait(0.5)
        GetParryUIElements()
        waited = waited + 0.5
    end
end)

local ParrySystem = {
    CooldownToken = 0,
    IsOnCooldown = false,
    IsResolving = false,
    Gradients = ParryGradients,
    Icon = ParryIcon,
    CooldownThread = nil,
    LockConnection = nil,
    ParryTrack = nil,
}

local function SetIconsColor(color)
    if #ParrySystem.Gradients == 0 then
        GetParryUIElements()
    end
    for _, grad in ipairs(ParrySystem.Gradients) do
        if grad and grad.Parent and grad.Parent.Parent then
            local icon = grad.Parent.Parent:FindFirstChild("icon")
            if icon then
                icon.ImageColor3 = color
            end
            local gui = grad.Parent.Parent:FindFirstChild("Gui")
            if gui then
                gui.ImageColor3 = color
            end
        end
    end
    if ParryIcon then
        ParryIcon.ImageColor3 = color
    end
end

local function PlayCooldownTween(duration)
    if #ParrySystem.Gradients == 0 then
        GetParryUIElements()
    end
    for _, grad in ipairs(ParrySystem.Gradients) do
        if grad and grad.Parent then
            grad.Offset = Vector2.new(0, 0.75)
            local tween = TweenService:Create(grad, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                Offset = Vector2.new(0, 0.25)
            })
            tween:Play()
        end
    end
end

local function StartCooldown(duration)
    ParrySystem.CooldownToken = ParrySystem.CooldownToken + 1
    local token = ParrySystem.CooldownToken

    ParrySystem.IsResolving = false
    ParrySystem.IsOnCooldown = true
    SetIconsColor(Color3.fromRGB(77,77,77))
    PlayCooldownTween(duration)

    if ParrySystem.CooldownThread then
        task.cancel(ParrySystem.CooldownThread)
    end
    ParrySystem.CooldownThread = task.delay(duration, function()
        if ParrySystem.CooldownToken == token then
            ParrySystem.IsOnCooldown = false
            SetIconsColor(Color3.fromRGB(255,255,255))
            ParrySystem.CooldownThread = nil
        end
    end)
end

local function ResetCooldown()
    if ParrySystem.CooldownThread then
        task.cancel(ParrySystem.CooldownThread)
        ParrySystem.CooldownThread = nil
    end
    ParrySystem.IsOnCooldown = false
    ParrySystem.IsResolving = false
    SetIconsColor(Color3.fromRGB(255,255,255))
    for _, grad in ipairs(ParrySystem.Gradients) do
        if grad and grad.Parent then
            grad.Offset = Vector2.new(0, 0.25)
        end
    end
end

local function IsBusy()
    local char = LocalPlayer.Character
    if not char then return true end
    if LocalPlayer:GetAttribute("IsDead") then return true end
    if char:GetAttribute("IsCarried") then return true end
    if char:GetAttribute("IsHooked") then return true end
    if CollectionService:HasTag(char:FindFirstChild("HumanoidRootPart"), "doing action") then return true end

    local ci = char:FindFirstChild("CheckInterractable")
    if ci then
        local actions = {"isVaulting","isSliding","isDroppingPallet","isRepairing","isHealing","isUnhooking","isExiting"}
        for _, act in ipairs(actions) do
            if ci:GetAttribute(act) then return true end
        end
    end
    return false
end

local function IsLowHealth()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return true end
    return hum.Health < hum.MaxHealth * 0.5
end

local function CanParry()
    if not VD.SURV_AutoParry then return false end
    if not HasParryingDagger() then return false end
    if ParrySystem.IsOnCooldown then return false end
    if ParrySystem.IsResolving then return false end
    if IsBusy() then return false end
    if IsLowHealth() then return false end
    return true
end

local function FaceLookDirection()
    local camera = Workspace.CurrentCamera
    if not camera then return end
    local rootPart = Root
    if not rootPart or not rootPart.Parent then return end

    local lookVec = camera.CFrame.LookVector
    local flat = Vector3.new(lookVec.X, 0, lookVec.Z)
    if flat.Magnitude <= 0 then return end

    local targetCF = CFrame.new(rootPart.Position, rootPart.Position + flat.Unit)
    local tween = TweenService:Create(rootPart, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { CFrame = targetCF })
    tween:Play()
    tween.Completed:Connect(function()
        if Humanoid then Humanoid.AutoRotate = true end
        if ParrySystem.LockConnection then ParrySystem.LockConnection:Disconnect() end
        local startTime = tick()
        ParrySystem.LockConnection = RunService.Heartbeat:Connect(function()
            if tick() - startTime >= 0.8 then
                if ParrySystem.LockConnection then
                    ParrySystem.LockConnection:Disconnect()
                    ParrySystem.LockConnection = nil
                end
                return
            end
            if rootPart and rootPart.Parent then
                rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + flat.Unit)
            else
                if ParrySystem.LockConnection then
                    ParrySystem.LockConnection:Disconnect()
                    ParrySystem.LockConnection = nil
                end
            end
        end)
    end)
end

local function PlayParryAnimation()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end

    local animId = VD.SURV_ParryAnimId or "rbxassetid://109133187196613"
    local anim = Instance.new("Animation")
    anim.AnimationId = animId
    local track = animator:LoadAnimation(anim)
    if track then
        track.Priority = Enum.AnimationPriority.Action
        track:Play()
        ParrySystem.ParryTrack = track
        task.delay(1.5, function()
            if track and track.IsPlaying then track:Stop() end
            ParrySystem.ParryTrack = nil
        end)
    end
end

local function applyWalkSpeedSequence()
    local hum = Humanoid
    if not hum then return end
    local sequence = {
        { speed = 0, duration = 2 },
        { speed = 19, duration = 2 },
        { speed = 18, duration = 1 },
        { speed = 17, duration = math.huge }
    }
    for _, step in ipairs(sequence) do
        if not hum.Parent then break end
        hum.WalkSpeed = step.speed
        if step.duration == math.huge then
            break
        else
            task.wait(step.duration)
        end
    end
end

local function DoParry()
    if not CanParry() then return end

    ParrySystem.IsResolving = true
    SetIconsColor(Color3.fromRGB(77,77,77))

    local parryRemote = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Items"):FindFirstChild("Parrying Dagger"):FindFirstChild("parry")
    if parryRemote then
        pcall(function() parryRemote:FireServer() end)
    end

    FaceLookDirection()
    if Humanoid then Humanoid.AutoRotate = false end
    PlayParryAnimation()

    local rootPart = Root
    if rootPart then
        CollectionService:AddTag(rootPart, "doing action")
    end

    local slowRemote = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Mechanics"):FindFirstChild("Slow")
    if slowRemote then
        pcall(function() slowRemote:Fire(0, 1, 0) end)
    end

    task.spawn(applyWalkSpeedSequence)

    task.delay(2, function()
        if ParrySystem.IsResolving then
            ParrySystem.IsResolving = false
            StartCooldown(60)
            if rootPart then
                CollectionService:RemoveTag(rootPart, "doing action")
            end
        end
    end)
end

local function ListenParryResult()
    task.spawn(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if not remotes then return end
        local daggerFolder = remotes:FindFirstChild("Items"):FindFirstChild("Parrying Dagger")
        if not daggerFolder then return end
        local parryResult = daggerFolder:FindFirstChild("parryResult")
        if not parryResult then return end

        parryResult.OnClientEvent:Connect(function(success, cooldown)
            if not ParrySystem.IsResolving then return end

            ParrySystem.IsResolving = false
            local duration = tonumber(cooldown)
            if duration and duration > 0 then
                StartCooldown(duration)
            else
                if success == true then
                    StartCooldown(90)
                else
                    StartCooldown(60)
                end
            end

            local rootPart = Root
            if rootPart then
                CollectionService:RemoveTag(rootPart, "doing action")
            end
        end)
    end)
end
ListenParryResult()

-- PARRY SENSOR
local VD_ATTACK_ANIMS = {
    ["rbxassetid://113255068724446"] = true,
    ["rbxassetid://74968262036854"] = true,
    ["rbxassetid://110355011987939"] = true,
    ["rbxassetid://139369275981139"] = true,
    ["rbxassetid://132817836308238"] = true,
    ["rbxassetid://129784271201071"] = true,
    ["rbxassetid://133963973694098"] = true,
    ["rbxassetid://117042998468241"] = true,
    ["rbxassetid://105374834496520"] = true,
    ["rbxassetid://111920872708571"] = true,
    ["rbxassetid://78432063483146"] = true,
    ["rbxassetid://118907603246885"] = true,
    ["rbxassetid://138720291317243"] = true,
    ["rbxassetid://115244153053858"] = true,
    ["rbxassetid://130593238885843"] = true,
    ["rbxassetid://122812055447896"] = true,
    ["rbxassetid://78935059863801"] = true,
    ["rbxassetid://135002183282873"] = true,
    ["rbxassetid://121216847022485"] = true,
}

local Attached = {}
local function AttachParrySensor(kChar)
    if not kChar or Attached[kChar] then return end
    Attached[kChar] = true
    local humanoid = kChar:FindFirstChild("Humanoid")
    if not humanoid then
        humanoid = kChar:WaitForChild("Humanoid", 5)
        if not humanoid then return end
    end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = humanoid:WaitForChild("Animator", 5)
        if not animator then return end
    end

    humanoid.ChildAdded:Connect(function(child)
        if child:IsA("Animator") then
            Attached[kChar] = nil
            AttachParrySensor(kChar)
        end
    end)

    kChar.AncestryChanged:Connect(function(_, parent)
        if not parent then
            Attached[kChar] = nil
        end
    end)

    animator.AnimationPlayed:Connect(function(track)
        local animId = track.Animation and track.Animation.AnimationId or ""
        if not VD_ATTACK_ANIMS[animId] then return end

        if not VD.SURV_AutoParry then return end
        if not HasParryingDagger() then return end
        if ParrySystem.IsOnCooldown or ParrySystem.IsResolving then return end

        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        local kHRP = kChar:FindFirstChild("HumanoidRootPart")
        if not myHRP or not kHRP then return end

        local delta = myHRP.Position - kHRP.Position
        local startDistance = delta.Magnitude

        local mode = VD.SURV_ParryMode or "Legit"
        local range = VD.SURV_ParryRange or 12

        if mode == "Aggressive" then
            local aggressiveRadius = range
            local detectionRadius = aggressiveRadius + 3
            if startDistance > detectionRadius then return end
            if startDistance <= aggressiveRadius then
                DoParry()
            else
                local tracker
                local startTime = os.clock()
                tracker = RunService.Heartbeat:Connect(function()
                    if os.clock() - startTime >= 1.5 or ParrySystem.IsOnCooldown or ParrySystem.IsResolving or not myHRP or not kHRP then
                        if tracker then tracker:Disconnect() end
                        return
                    end
                    local currentDist = (myHRP.Position - kHRP.Position).Magnitude
                    if currentDist <= aggressiveRadius then
                        DoParry()
                        if tracker then tracker:Disconnect() end
                    end
                end)
            end
        else
            if startDistance > range then return end
            local myPosFlat = Vector3.new(myHRP.Position.X, 0, myHRP.Position.Z)
            local kPosFlat = Vector3.new(kHRP.Position.X, 0, kHRP.Position.Z)
            local flatDelta = myPosFlat - kPosFlat
            if flatDelta.Magnitude > 0 then
                local flatDirection = flatDelta.Unit
                local kLookFlat = Vector3.new(kHRP.CFrame.LookVector.X, 0, kHRP.CFrame.LookVector.Z).Unit
                local isFacing = kLookFlat:Dot(flatDirection)
                if isFacing < 0.6 then return end
            end
            DoParry()
        end
    end)
end

local function TryAttach(p)
    if p ~= LocalPlayer and p.Team and p.Team.Name == "Killer" and p.Character then
        AttachParrySensor(p.Character)
    end
end

local function SetupPlayer(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function() TryAttach(p) end)
    p:GetPropertyChangedSignal("Team"):Connect(function() TryAttach(p) end)
    if p.Character then TryAttach(p) end
end

for _, p in pairs(Players:GetPlayers()) do SetupPlayer(p) end
Players.PlayerAdded:Connect(SetupPlayer)

task.spawn(function()
    while true do
        task.wait(5)
        for _, p in pairs(Players:GetPlayers()) do TryAttach(p) end
    end
end)

RunService.RenderStepped:Connect(function()
    VD_UpdateParryRange()
end)

-- ============================================================
--  TELEPORT SYSTEM
-- ============================================================
local IYAN_Cache = {
    Generators  = {},
    Gates       = {},
    Hooks       = {},
    Pallets     = {},
    Windows     = {},
    ClosestHook = nil,
    ExitPos     = nil
}

local originalCanCollide = {}

local function IYAN_ScanMap()
    local map = Workspace:FindFirstChild("Map")
    if not map then
        IYAN_Cache = {
            Generators = {}, Gates = {}, Hooks = {}, Pallets = {}, Windows = {}, ClosestHook = nil, ExitPos = nil
        }
        return
    end

    local newGens, newGates, newHooks, newPallets, newWindows = {}, {}, {}, {}, {}
    local exitPos = nil

    local finish = map:FindFirstChild("Finishline") or map:FindFirstChild("FinishLine") or map:FindFirstChild("Fininshline")
    if finish then
        local fp = finish:IsA("BasePart") and finish or (finish:IsA("Model") and finish:FindFirstChildWhichIsA("BasePart"))
        if fp then exitPos = fp.Position end
    end

    for _, obj in ipairs(map:GetDescendants()) do
        if obj:IsA("Model") then
            local part = obj:FindFirstChild("HitBox", true) or obj:FindFirstChild("GeneratorPoint", true) or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
            if part then
                local n = obj.Name
                if n == "Generator" then
                    table.insert(newGens, { model = obj, part = part })
                elseif n == "Gate" or n == "ExitGate" or obj:FindFirstChild("ExitLever") then
                    table.insert(newGates, { model = obj, part = part })
                elseif n == "Hook" then
                    table.insert(newHooks, { model = obj, part = part })
                elseif n == "Palletwrong" or n:lower():find("pallet") then
                    table.insert(newPallets, { model = obj, part = part })
                elseif n == "Window" then
                    table.insert(newWindows, { model = obj, part = part })
                end
            end
        end
    end

    IYAN_Cache.Generators = newGens
    IYAN_Cache.Gates      = newGates
    IYAN_Cache.Hooks      = newHooks
    IYAN_Cache.Pallets    = newPallets
    IYAN_Cache.Windows    = newWindows
    IYAN_Cache.ExitPos    = exitPos

    local root = Root
    if root and #IYAN_Cache.Hooks > 0 then
        local closest, closestDist = nil, math.huge
        for _, hook in ipairs(IYAN_Cache.Hooks) do
            if hook.part then
                local d = (hook.part.Position - root.Position).Magnitude
                if d < closestDist then
                    closestDist = d; closest = hook
                end
            end
        end
        IYAN_Cache.ClosestHook = closest
    end
end

local function IYAN_TeleportToPosition(pos)
    if not pos then return false end
    local root = Root
    if not root then return false end
    if LocalPlayer.Character then
        root.Anchored = true
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                if originalCanCollide[part] == nil then originalCanCollide[part] = part.CanCollide end
                part.CanCollide = false
            end
        end
    end
    root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    task.delay(0.3, function()
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    pcall(function()
                        part.CanCollide = (originalCanCollide[part] ~= nil) and originalCanCollide[part] or true
                    end)
                end
            end
            root.Anchored = false
        end
        originalCanCollide = {}
    end)
    return true
end

local function IYAN_TeleportToGenerator(index)
    if not IYAN_Cache or not IYAN_Cache.Generators or #IYAN_Cache.Generators == 0 then return false end
    local sorted = {}
    for _, gen in ipairs(IYAN_Cache.Generators) do
        table.insert(sorted, {gen = gen, dist = (Root and (gen.part.Position - Root.Position).Magnitude) or math.huge})
    end
    table.sort(sorted, function(a, b) return a.dist < b.dist end)
    local target = sorted[index or 1]
    if not target then return false end
    return IYAN_TeleportToPosition(target.gen.part.Position)
end

local function IYAN_TeleportToGate()
    if not IYAN_Cache or not IYAN_Cache.Gates or #IYAN_Cache.Gates == 0 then return false end
    local closest, closestDist = nil, math.huge
    for _, gate in ipairs(IYAN_Cache.Gates) do
        local dist = (Root and (gate.part.Position - Root.Position).Magnitude) or math.huge
        if dist < closestDist then
            closestDist = dist
            closest = gate
        end
    end
    if not closest then return false end
    return IYAN_TeleportToPosition(closest.part.Position)
end

local function IYAN_TeleportToHook()
    if not IYAN_Cache or not IYAN_Cache.ClosestHook then return false end
    return IYAN_TeleportToPosition(IYAN_Cache.ClosestHook.part.Position)
end

task.spawn(function()
    while not VD.Destroyed do
        pcall(IYAN_ScanMap)
        task.wait(0.5)
    end
end)

-- ============================================================
--  FLING SYSTEM
-- ============================================================
local function IYAN_FlingNearest()
    if not VD.FLING_Enabled then return end
    local root = Root
    if not root then return end
    local closest, closestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local tr = player.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                local dist = (tr.Position - root.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist; closest = player
                end
            end
        end
    end
    if closest and closest.Character then
        local tr = closest.Character:FindFirstChild("HumanoidRootPart")
        if tr then
            local originalPos = root.CFrame
            for _ = 1, 10 do
                root.CFrame      = tr.CFrame
                root.Velocity    = Vector3.new(VD.FLING_Strength, VD.FLING_Strength / 2, VD.FLING_Strength)
                root.RotVelocity = Vector3.new(9999, 9999, 9999)
                task.wait()
            end
            root.CFrame      = originalPos
            root.Velocity    = Vector3.zero
            root.RotVelocity = Vector3.zero
        end
    end
end

local function IYAN_FlingAll()
    if not VD.FLING_Enabled then return end
    local root = Root
    if not root then return end
    local originalPos = root.CFrame
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local tr = player.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                for _ = 1, 5 do
                    root.CFrame      = tr.CFrame
                    root.Velocity    = Vector3.new(VD.FLING_Strength, VD.FLING_Strength / 2, VD.FLING_Strength)
                    root.RotVelocity = Vector3.new(9999, 9999, 9999)
                    task.wait()
                end
            end
        end
    end
    root.CFrame      = originalPos
    root.Velocity    = Vector3.zero
    root.RotVelocity = Vector3.zero
end

-- ============================================================
--  KILLER AUTO ATTACK & FUNCTIONS
-- ============================================================
local LastDoubleTapTime = 0
local IsBreakingPallet = false

local function IYAN_AutoAttack()
    if not VD.AUTO_Attack or GetRole() ~= "Killer" then return end
    local root = Root
    if not root then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsSurvivor(player) and player.Character then
            local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local tHum = player.Character:FindFirstChildOfClass("Humanoid")

            if tRoot and tHum and tHum.MaxHealth > 0 then
                local pct = tHum.Health / tHum.MaxHealth
                if pct > 0.25 and (tRoot.Position - root.Position).Magnitude <= VD.AUTO_AttackRange then
                    pcall(function()
                        local r = ReplicatedStorage:FindFirstChild("Remotes")
                        local a = r and r:FindFirstChild("Attacks")
                        local b = a and a:FindFirstChild("BasicAttack")
                        if b then b:FireServer(false) end
                    end)
                    break
                end
            end
        end
    end
end

local function IYAN_DoubleTap()
    if not VD.KILLER_DoubleTap or GetRole() ~= "Killer" then return end
    if tick() - LastDoubleTapTime < 0.5 then return end
    pcall(function()
        local r  = ReplicatedStorage:FindFirstChild("Remotes")
        local a  = r and r:FindFirstChild("Attacks")
        local ba = a and a:FindFirstChild("BasicAttack")
        if ba then
            ba:FireServer(false)
            task.wait(0.05)
            ba:FireServer(false)
            LastDoubleTapTime = tick()
        end
    end)
end

local function IYAN_DestroyAllPallets()
    if not VD.KILLER_DestroyPallets or GetRole() ~= "Killer" then return end
    if IsBreakingPallet then return end

    local char = LocalPlayer.Character
    local root = Root
    if not char or not root then return end

    local stunned = char:GetAttribute("IsStunned") or char:GetAttribute("isStunned")
    local immobile = char:GetAttribute("Immobile") or char:GetAttribute("immobile")
    local carrying = char:GetAttribute("IsCarrying") or char:GetAttribute("isCarrying")
    local pursuit = char:GetAttribute("Pursuit") or char:GetAttribute("pursuit")
    local ci = char:FindFirstChild("CheckInterractable")
    local action = ci and (ci:GetAttribute("action") or ci:GetAttribute("Action"))

    if stunned or immobile or carrying or pursuit or action then return end

    local pts = CollectionService:GetTagged("PalletPointSlide")
    local nearest, minDist = nil, 6
    for _, p in ipairs(pts) do
        if p:IsA("BasePart") and not CollectionService:HasTag(p, "doing action") then
            local d = (p.Position - root.Position).Magnitude
            if d < minDist then
                minDist = d
                nearest = p
            end
        end
    end

    if nearest then
        IsBreakingPallet = true
        task.spawn(function()
            pcall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                local p = r and r:FindFirstChild("Pallet")
                local j = p and p:FindFirstChild("Jason")
                if j then
                    local dg = j:FindFirstChild("Destroy-Global")
                    local commit = j:FindFirstChild("PalletBreakCommit")
                    if dg and dg:IsA("RemoteEvent") then dg:FireServer(nearest) end
                    if commit and commit:IsA("RemoteEvent") then commit:FireServer(nearest) end
                end
            end)
            task.wait(0.2)
            local startTime = os.clock()
            while char and char.Parent and (char:GetAttribute("Immobile") or char:GetAttribute("immobile")) do
                if os.clock() - startTime > 3 then break end
                task.wait(0.1)
            end
            IsBreakingPallet = false
        end)
    end
end

getgenv().IYAN_IsBreakingGenerator = false
local function IYAN_AutoBreakGene()
    if not VD.KILLER_AutoBreakGene or GetRole() ~= "Killer" then return end
    if getgenv().IYAN_IsBreakingGenerator then return end

    local char = LocalPlayer.Character
    local root = Root
    if not char or not root then return end

    local stunned = char:GetAttribute("IsStunned") or char:GetAttribute("isStunned")
    local immobile = char:GetAttribute("Immobile") or char:GetAttribute("immobile")
    local carrying = char:GetAttribute("IsCarrying") or char:GetAttribute("isCarrying")
    local pursuit = char:GetAttribute("Pursuit") or char:GetAttribute("pursuit")
    local ci = char:FindFirstChild("CheckInterractable")
    local action = ci and (ci:GetAttribute("action") or ci:GetAttribute("Action"))

    if stunned or immobile or carrying or pursuit or action then return end

    local pts = CollectionService:GetTagged("GeneratorPoint")
    local nearest, minDist = nil, 6
    for _, p in ipairs(pts) do
        if p:IsA("BasePart") and not CollectionService:HasTag(p, "doing action") then
            local genModel = p.Parent
            if genModel then
                local progress = genModel:GetAttribute("RepairProgress") or genModel:GetAttribute("repairProgress") or 0
                local kickcount = genModel:GetAttribute("kickcount") or genModel:GetAttribute("KickCount") or 0
                if progress > 0 and progress < 100 and kickcount <= 7 then
                    local d = (p.Position - root.Position).Magnitude
                    if d < minDist then
                        minDist = d
                        nearest = p
                    end
                end
            end
        end
    end

    if nearest then
        getgenv().IYAN_IsBreakingGenerator = true
        task.spawn(function()
            pcall(function()
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                local g = r and r:FindFirstChild("Generator")
                if g then
                    local event = g:FindFirstChild("BreakGenEvent")
                    local commit = g:FindFirstChild("BreakGenCommit")
                    if event and event:IsA("RemoteEvent") then event:FireServer(nearest) end
                    if commit and commit:IsA("RemoteEvent") then commit:FireServer(nearest) end
                end
            end)
            task.wait(0.2)
            local startTime = os.clock()
            while char and char.Parent and (char:GetAttribute("Immobile") or char:GetAttribute("immobile")) do
                if os.clock() - startTime > 3 then break end
                task.wait(0.1)
            end
            task.wait(0.3)
            getgenv().IYAN_IsBreakingGenerator = false
        end)
    end
end

getgenv().IYAN_LastVaultBlockTime = 0
local function IYAN_BlockAllVaults()
    if not VD.KILLER_BlockVaults or GetRole() ~= "Killer" then return end
    local now = tick()
    if now - getgenv().IYAN_LastVaultBlockTime < 1.5 then return end
    getgenv().IYAN_LastVaultBlockTime = now

    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local vaultEvent = remotes and remotes:FindFirstChild("Window") and remotes.Window:FindFirstChild("VaultEvent")
        if not vaultEvent then return end

        local map = Workspace:FindFirstChild("Map")
        local vaultsFolder = map and map:FindFirstChild("Vaults")

        if vaultsFolder then
            for _, vault in ipairs(vaultsFolder:GetChildren()) do
                for _, part in ipairs(vault:GetChildren()) do
                    if part:IsA("BasePart") then
                        pcall(function() vaultEvent:FireServer(part, true) end)
                    end
                end
            end
        else
            for _, win in ipairs(IYAN_Cache.Windows or {}) do
                local window = win.model
                if window and window.Parent then
                    for _, child in ipairs(window:GetDescendants()) do
                        if child:IsA("BasePart") then
                            pcall(function() vaultEvent:FireServer(child, true) end)
                        end
                    end
                end
            end
        end
    end)
end

local function IYAN_ApplyCustomMasked(maskName)
    local selectedMask = maskName or VD.KILLER_CustomMasked or "Richard"
    if type(selectedMask) == "table" then
        selectedMask = selectedMask[1]
    end
    if type(selectedMask) ~= "string" or selectedMask == "" then
        selectedMask = "Richard"
    end

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local killers = remotes and remotes:FindFirstChild("Killers")
    local masked = killers and killers:FindFirstChild("Masked")
    local activatePower = masked and masked:FindFirstChild("Activatepower")

    if activatePower and activatePower:IsA("RemoteEvent") then
        activatePower:FireServer(selectedMask)
        return true
    end
    return false
end

-- ============================================================
--  SURVIVOR SYSTEMS
-- ============================================================
RunService.Heartbeat:Connect(function()
    if VD.SURV_FleeKiller then
        pcall(function()
            local root = Root
            if not root then return end
            if GetRole() == "Killer" then return end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and IsKiller(player) then
                    local killerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if killerRoot and (killerRoot.Position - root.Position).Magnitude <= (VD.SURV_FleeDistance or 40) then
                        local direction = (root.Position - killerRoot.Position).Unit
                        root.CFrame = CFrame.new(root.Position + direction * ((VD.SURV_FleeDistance or 40) + 15), root.Position + direction * 100)
                        break
                    end
                end
            end
        end)
    end
end)

-- Auto Drop Pallet
local _usedPallets = {}
local _lastPalletDrop = 0
local _lastPalletScan = 0

RunService.Heartbeat:Connect(function()
    if not VD.SURV_AutoDropPallet or GetRole() ~= "Survivor" then return end
    if tick() - _lastPalletScan < 0.2 or tick() - _lastPalletDrop < 2.5 then return end
    _lastPalletScan = tick()

    pcall(function()
        local char = LocalPlayer.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not myRoot or not hum or hum.Health <= 0 then return end

        if VD.SURV_AutoDropPalletMode == "Safe" then
            local isCarried = char:GetAttribute("IsCarried") or char:GetAttribute("isCarried")
            if isCarried then return end
        end

        local killerRoot = nil
        local triggerDist = VD.SURV_AutoDropPalletDist or 20
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and IsKiller(plr) and plr.Character then
                local kr = plr.Character:FindFirstChild("HumanoidRootPart")
                if kr then
                    local dist = (kr.Position - myRoot.Position).Magnitude
                    if dist < triggerDist then
                        killerRoot = kr
                        break
                    end
                end
            end
        end
        if not killerRoot then return end

        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local palletFold = remotes and remotes:FindFirstChild("Pallet")
        local dropEvent = palletFold and palletFold:FindFirstChild("PalletDropEvent")
        if not dropEvent then return end

        local bestPallet, bestDist = nil, 8
        for _, pal in ipairs(IYAN_Cache.Pallets) do
            local palModel = pal.model
            if not palModel then continue end
            if _usedPallets[palModel] then continue end
            local refPart = pal.part or palModel:FindFirstChild("PalletPoint") or palModel:FindFirstChild("PalletPointSlide")
            if not refPart then continue end
            local ok, pos = pcall(function() return refPart.Position end)
            if not ok or not pos then continue end
            local d = (myRoot.Position - pos).Magnitude
            if d < bestDist then
                bestDist = d
                bestPallet = palModel
            end
        end

        if bestPallet then
            local fireTarget = bestPallet:FindFirstChild("PalletPointSlide") or bestPallet:FindFirstChild("PalletPoint")
            if fireTarget then
                pcall(function() dropEvent:FireServer(fireTarget) end)
                _usedPallets[bestPallet] = true
                _lastPalletDrop = tick()
                task.delay(3, function()
                    _usedPallets[bestPallet] = nil
                end)
            end
        end
    end)
end)

-- Auto Vault & Auto Pallet Slide
local _vaultedWindows = {}
local _lastVaultScan = 0
local _lastPalletSlideScan = 0
local _slidedPallets = {}

RunService.Heartbeat:Connect(function()
    -- AUTO VAULT
    if VD.SURV_AutoVault and GetRole() == "Survivor" and tick() - _lastVaultScan > 0.15 then
        _lastVaultScan = tick()
        pcall(function()
            local char = LocalPlayer.Character
            local myRoot = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not myRoot or not hum or hum.Health <= 0 then return end

            local vel = myRoot.AssemblyLinearVelocity
            if vel.Magnitude < 1 then return end

            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local winFolder = remotes and remotes:FindFirstChild("Window")
            local vaultEv = winFolder and winFolder:FindFirstChild("VaultCommit")
            if not vaultEv then return end

            local windowGroups = {}
            for _, win in ipairs(IYAN_Cache.Windows or {}) do
                local part = win.part or win.model
                if part then
                    local rootWindow = part.Parent
                    if rootWindow then
                        windowGroups[rootWindow] = windowGroups[rootWindow] or {}
                        local exists = false
                        for _, p in ipairs(windowGroups[rootWindow]) do
                            if p == part then exists = true; break end
                        end
                        if not exists then table.insert(windowGroups[rootWindow], part) end
                    end
                end
            end

            for rootWindow, parts in pairs(windowGroups) do
                local function getVTPosition(vt)
                    if vt:IsA("BasePart") then return vt.Position end
                    if vt:IsA("Model") then
                        if vt.PrimaryPart then return vt.PrimaryPart.Position end
                        local bp = vt:FindFirstChildWhichIsA("BasePart", true)
                        if bp then return bp.Position end
                    end
                    return nil
                end

                local allVTs = {}
                for _, child in ipairs(rootWindow:GetChildren()) do
                    if child.Name == "VaultTrigger" then table.insert(allVTs, child) end
                end
                if #allVTs == 0 then continue end

                local nearestVT, nearestVTDist = nil, math.huge
                for _, vt in ipairs(allVTs) do
                    local pos = getVTPosition(vt)
                    if pos then
                        local d = (myRoot.Position - pos).Magnitude
                        if d < nearestVTDist then
                            nearestVTDist = d
                            nearestVT = vt
                        end
                    end
                end
                if not nearestVT or nearestVTDist > 6.0 then continue end

                local lastUsed = _vaultedWindows[rootWindow] or 0
                if tick() - lastUsed < 3.0 then continue end

                local finalTarget = nearestVT
                local remotes2 = ReplicatedStorage:FindFirstChild("Remotes")
                local winFold = remotes2 and remotes2:FindFirstChild("Window")
                if winFold and finalTarget then
                    local vaultEvent = winFold:FindFirstChild("VaultEvent")
                    local vaultBindable = winFold:FindFirstChild("Vaultbindable")
                    local fastvault = winFold:FindFirstChild("fastvault")
                    local vaultComplete1 = winFold:FindFirstChild("VaultCompleteEventpart1")
                    local vaultComplete = winFold:FindFirstChild("VaultCompleteEvent")
                    if vaultEvent then pcall(function() vaultEvent:FireServer(finalTarget, true) end) end
                    if vaultBindable then pcall(function() vaultBindable:Fire(finalTarget, true) end) end
                    if fastvault then pcall(function() fastvault:FireServer(LocalPlayer) end) end
                    if vaultComplete1 then pcall(function() vaultComplete1:FireServer() end) end
                    if vaultComplete then pcall(function() vaultComplete:FireServer(finalTarget, false) end) end
                end

                _vaultedWindows[rootWindow] = tick()
                break
            end
        end)
    end

    -- AUTO PALLET SLIDE
    if VD.SURV_AutoPalletSlide and GetRole() == "Survivor" and tick() - _lastPalletSlideScan > 0.15 then
        _lastPalletSlideScan = tick()
        pcall(function()
            local char = LocalPlayer.Character
            local myRoot = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not myRoot or not hum or hum.Health <= 0 then return end

            local vel = myRoot.AssemblyLinearVelocity
            if vel.Magnitude < 1 then return end

            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local palletFold = remotes and remotes:FindFirstChild("Pallet")
            local palletSlideEvent = palletFold and palletFold:FindFirstChild("PalletSlideEvent")
            local slidebindable = palletFold and palletFold:FindFirstChild("Slidebindable")
            if not palletSlideEvent then return end

            local tagged = CollectionService:GetTagged("PalletPointSlide")
            local bestPart, bestDist = nil, 6.0
            for _, part in ipairs(tagged) do
                if not part:IsA("BasePart") then continue end
                if part:IsDescendantOf(char) then continue end
                if _slidedPallets[part] then continue end
                local palletModel = part.Parent
                local ok, destroyed = pcall(function() return palletModel:GetAttribute("Destroyed") end)
                if ok and destroyed == true then continue end
                local d = (part.Position - myRoot.Position).Magnitude
                if d < bestDist then
                    bestDist = d
                    bestPart = part
                end
            end

            if not bestPart then
                for _, pal in ipairs(IYAN_Cache.Pallets or {}) do
                    local palModel = pal.model
                    if not palModel then continue end
                    if _slidedPallets[palModel] then continue end
                    local slide = palModel:FindFirstChild("PalletPointSlide") or palModel:FindFirstChild("PalletPointSlide", true)
                    if not slide then continue end
                    local ok2, destroyed2 = pcall(function() return palModel:GetAttribute("Destroyed") end)
                    if ok2 and destroyed2 == true then continue end
                    local d = (slide.Position - myRoot.Position).Magnitude
                    if d < bestDist then
                        bestDist = d
                        bestPart = slide
                    end
                end
            end

            if bestPart then
                local isSprinting = LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Sprinting") or false
                pcall(function() palletSlideEvent:FireServer(bestPart, isSprinting) end)
                if slidebindable then pcall(function() slidebindable:Fire(bestPart, isSprinting) end) end
                _slidedPallets[bestPart] = true
                _lastPalletSlideScan = tick() + 3.8
                task.delay(3.0, function() _slidedPallets[bestPart] = nil end)
            end
        end)
    end
end)

-- ============================================================
--  GENERATOR BOOST SYSTEM  
-- ============================================================
local DragConfigPath = ".Yeron.vd.drag.json"

local function loadBypassButtonPosition()
    local pos = nil
    pcall(function()
        if isfile and readfile and isfile(DragConfigPath) then
            local raw = readfile(DragConfigPath)
            local data = HttpService:JSONDecode(raw)
            if data and data.XScale ~= nil and data.XOffset ~= nil and data.YScale ~= nil and data.YOffset ~= nil then
                pos = UDim2.new(data.XScale, data.XOffset, data.YScale, data.YOffset)
            end
        end
    end)
    return pos
end

local function saveBypassButtonPosition(udim2Pos)
    pcall(function()
        if writefile then
            writefile(DragConfigPath, HttpService:JSONEncode({
                XScale  = udim2Pos.X.Scale,
                XOffset = udim2Pos.X.Offset,
                YScale  = udim2Pos.Y.Scale,
                YOffset = udim2Pos.Y.Offset,
            }))
        end
    end)
end

local bypassButton = nil
local bypassButtonCheck = nil
local bypassButtonGui = nil
local bypassButtonDragConns = {}
local bypassGuardianActive = false

local function disconnectDragConns()
    for _, c in ipairs(bypassButtonDragConns) do
        pcall(function() c:Disconnect() end)
    end
    bypassButtonDragConns = {}
end

local function makeButtonDraggable(button)
    disconnectDragConns()

    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        button.Position = newPos
    end

    table.insert(bypassButtonDragConns, button.InputBegan:Connect(function(input)
        if not VD.SURV_DraggableGenBypass then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if dragging then
                        dragging = false
                        saveBypassButtonPosition(button.Position)
                    end
                    if conn then conn:Disconnect() end
                end
            end)
        end
    end))

    table.insert(bypassButtonDragConns, button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end))

    table.insert(bypassButtonDragConns, UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end))
end

local function createBypassButton()
    if bypassButton and bypassButton.Parent then return end

    local guiParent = GetHolder()
    if not guiParent then return end

    if bypassButtonGui then bypassButtonGui:Destroy() end

    bypassButtonGui = Instance.new("ScreenGui")
    bypassButtonGui.Name = "ZiaanHub_GenBypassGui"
    bypassButtonGui.ResetOnSpawn = false
    bypassButtonGui.IgnoreGuiInset = true
    bypassButtonGui.DisplayOrder = 999
    pcall(function() bypassButtonGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling end)
    bypassButtonGui.Parent = guiParent

    bypassButton = Instance.new("ImageButton")
    bypassButton.Name = "GenBypassButton"
    bypassButton.Size = UDim2.new(0, 101, 0, 101)
    bypassButton.AnchorPoint = Vector2.new(1, 0)

    local savedPos = loadBypassButtonPosition()
    bypassButton.Position = savedPos or UDim2.new(1, -99, 0, 335)

    bypassButton.BackgroundTransparency = 1
    bypassButton.Image = "rbxassetid://73955247819019"
    bypassButton.ScaleType = Enum.ScaleType.Fit
    bypassButton.BorderSizePixel = 0
    bypassButton.AutoButtonColor = false
    bypassButton.Active = true
    bypassButton.Selectable = false
    bypassButton.ZIndex = 2
    bypassButton.Parent = bypassButtonGui

    Instance.new("UICorner", bypassButton).CornerRadius = UDim.new(0.5, 0)

    makeButtonDraggable(bypassButton)

    local function updateButtonColor()
        if not bypassButton then return end
        local char = LocalPlayer.Character
        if not char then
            bypassButton.ImageColor3 = Color3.new(1, 1, 1)
            return
        end
        local ci = char:FindFirstChild("CheckInterractable")
        if not ci then
            bypassButton.ImageColor3 = Color3.new(1, 1, 1)
            return
        end
        local repairing = ci:GetAttribute("isRepairing") or ci:GetAttribute("IsRepairing")
        bypassButton.ImageColor3 = repairing and Color3.fromRGB(255, 140, 0) or Color3.new(1, 1, 1)
    end

    local function bindCheck(character)
        if not character then return end
        local ci = character:WaitForChild("CheckInterractable")
        if ci then
            if bypassButtonCheck then bypassButtonCheck:Disconnect() end
            bypassButtonCheck = ci:GetAttributeChangedSignal("isRepairing"):Connect(updateButtonColor)
            ci:GetAttributeChangedSignal("IsRepairing"):Connect(updateButtonColor)
            updateButtonColor()
        end
    end

    if LocalPlayer.Character then bindCheck(LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(bindCheck)

    bypassButton.MouseButton1Click:Connect(function()
        if VD.SURV_DraggableGenBypass then return end
        print("[GenBypass] Button clicked")
        local char = LocalPlayer.Character
        if not char then return end
        local ci = char:FindFirstChild("CheckInterractable")
        if not ci then return end
        local repairing = ci:GetAttribute("isRepairing") or ci:GetAttribute("IsRepairing")
        if not repairing then
            print("[GenBypass] Not repairing, skip")
            return
        end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local genCache, lastCacheTime = {}, 0
        local function getGenerators()
            if tick() - lastCacheTime < 5 then return genCache end
            genCache, lastCacheTime = {}, tick()
            local folder = Workspace:FindFirstChild("Map") or Workspace
            for _, v in pairs(folder:GetDescendants()) do
                if v:IsA("Model") and v.Name == "Generator" then
                    local real = v:GetAttribute("RepairProgress") ~= nil
                        or v:GetAttribute("kickcount") ~= nil
                        or v:GetAttribute("ProgressRepair") ~= nil
                    if real then
                        table.insert(genCache, v)
                    end
                end
            end
            return genCache
        end

        local function getPoints(genModel)
            local pts = {}
            for _, obj in pairs(genModel:GetChildren()) do
                if obj.Name:find("GeneratorPoint") and obj:IsA("BasePart") then
                    table.insert(pts, obj)
                end
            end
            return pts
        end

        local function waitRepairing(point, timeout)
            local start = tick()
            while tick() - start < timeout do
                if point:GetAttribute("IsRepairing") == true then
                    return true
                end
                task.wait(0.05)
            end
            return false
        end

        local RepairEvent = nil
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes then
                local genFolder = remotes:FindFirstChild("Generator")
                if genFolder then
                    RepairEvent = genFolder:FindFirstChild("RepairEvent")
                end
            end
        end)
        if not RepairEvent then
            print("[GenBypass] RepairEvent not found!")
            return
        end

        local bestPoint, bestDist = nil, math.huge
        local bestGen = nil
        for _, gen in pairs(getGenerators()) do
            for _, pt in pairs(getPoints(gen)) do
                local d = (hrp.Position - pt.Position).Magnitude
                if d < bestDist then
                    bestDist = d
                    bestPoint = pt
                    bestGen = gen
                end
            end
        end

        if bestPoint and bestGen then
            print("[GenBypass] Processing generator...")
            local allPoints = getPoints(bestGen)
            local targetPoints = {}
            for _, p in ipairs(allPoints) do
                if p ~= bestPoint then table.insert(targetPoints, p) end
            end
            if #targetPoints == 0 then
                print("[GenBypass] No other points, cancel")
                return
            end
            local startCFrame = hrp.CFrame
            print("[GenBypass] Processing " .. #targetPoints .. " points")
            for i, point in ipairs(targetPoints) do
                if not point.Parent then continue end
                hrp.Anchored = true
                hrp.CFrame = point.CFrame
                task.wait(0.15)
                if RepairEvent then
                    RepairEvent:FireServer(point, true)
                end
                local ok = waitRepairing(point, 0.8)
                if not ok then
                    if RepairEvent then RepairEvent:FireServer(point, false) end
                    task.wait(0.1)
                    hrp.CFrame = point.CFrame
                    task.wait(0.15)
                    if RepairEvent then RepairEvent:FireServer(point, true) end
                    ok = waitRepairing(point, 0.5)
                else
                end
                hrp.Anchored = false
                task.wait(0.05)
            end
            pcall(function()
                hrp.Anchored = false
                hrp.CFrame = startCFrame
            end)
            local lastPoint = targetPoints[#targetPoints]
            if lastPoint and RepairEvent then
                task.wait(0.1)
                RepairEvent:FireServer(lastPoint, false)
            end
            print("[GenBypass] Done")
        else
            print("[GenBypass] No generator found")
        end
    end)
end

local function destroyBypassButton()
    bypassGuardianActive = false
    disconnectDragConns()
    if bypassButtonGui then
        bypassButtonGui:Destroy()
        bypassButtonGui = nil
    end
    bypassButton = nil
    if bypassButtonCheck then
        bypassButtonCheck:Disconnect()
        bypassButtonCheck = nil
    end
end

local function startBypassButtonGuardian()
    if bypassGuardianActive then return end
    bypassGuardianActive = true
    task.spawn(function()
        while bypassGuardianActive and VD.SURV_GenBoost and not VD.Destroyed do
            if not (bypassButtonGui and bypassButtonGui.Parent) then
                pcall(createBypassButton)
            end
            task.wait(1)
        end
    end)
end

local function startGenBoost()
    if not VD.SURV_GenBoost then return end
    createBypassButton()
    startBypassButtonGuardian()
end

local function stopGenBoost()
    destroyBypassButton()
end

-- ============================================================
--  LIGHTING
-- ============================================================
local defaultLighting = {
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
}

local function applyFullbright(state)
    if state then
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
    else
        Lighting.Brightness = defaultLighting.Brightness
        Lighting.Ambient = defaultLighting.Ambient
        Lighting.OutdoorAmbient = defaultLighting.OutdoorAmbient
    end
end

local function applyNoFog(state)
    if state then
        Lighting.FogEnd = 9999
        Lighting.FogStart = 0
    else
        Lighting.FogEnd = defaultLighting.FogEnd
        Lighting.FogStart = defaultLighting.FogStart
    end
end

-- ============================================================
--  MAIN HEARTBEAT LOOP
-- ============================================================
RunService.Heartbeat:Connect(function()
    if VD.Destroyed then return end
    pcall(IYAN_AutoAttack)
    pcall(IYAN_DestroyAllPallets)
    pcall(IYAN_AutoBreakGene)
    pcall(IYAN_BlockAllVaults)
    pcall(IYAN_DoubleTap)
end)

-- ============================================================
--  INFO TAB
-- ============================================================
local InfoSec = InfoTab:AddSection({ Name = "About" })

InfoSec:AddLabel("NO MERCY — Violence District v2.0")
InfoSec:AddLabel("Full Feature Implementation")
InfoSec:AddButton({
    Name = "Copy Discord Link",
    Callback = function()
        if setclipboard then setclipboard("https://discord.gg/pbg6g79Hp") end
        OrionLib:MakeNotification({ Name = "NO MERCY", Content = "Discord link copied!", Image = ICON.Logo, Time = 3 })
    end,
})

task.spawn(function()
    task.wait(0.3)
    local main = FindMainWindow()
    if not main then return end

    for _, v in ipairs(main:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text == "About" then
            local container = v.Parent.Parent
            if container and container:IsA("ScrollingFrame") then
                for _, child in ipairs(container:GetChildren()) do
                    if child.Name == "AbsoluteTopBanner" then
                        child:Destroy()
                    end
                end

                local bannerFrame = Instance.new("Frame")
                bannerFrame.Name = "AbsoluteTopBanner"
                bannerFrame.Size = UDim2.new(1, -10, 0, 115)
                bannerFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
                bannerFrame.BorderSizePixel = 0
                bannerFrame.LayoutOrder = -999
                bannerFrame.Parent = container

                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 8)
                corner.Parent = bannerFrame

                local bannerImg = Instance.new("ImageLabel")
                bannerImg.Size = UDim2.new(1, 0, 1, 0)
                bannerImg.Image = ICON.Banner
                bannerImg.BackgroundTransparency = 1
                bannerImg.ScaleType = Enum.ScaleType.Fit
                bannerImg.Parent = bannerFrame

                local imgCorner = Instance.new("UICorner")
                imgCorner.CornerRadius = UDim.new(0, 8)
                imgCorner.Parent = bannerImg
                break
            end
        end
    end
end)

-- ============================================================
--  AIMBOT TAB (Placeholder for future expansion)
-- ============================================================
local AimbotSec = AimbotTab:AddSection({ Name = "Aimbot Settings" })
AimbotSec:AddToggle({ Name = "Enable Aimbot", Flag = "Aimbot_Enable", Default = false, Callback = function(v) VD.AIM_Enabled = v end })

-- ============================================================
--  PARRY TAB
-- ============================================================
local ParrySec = ParryTab:AddSection({ Name = "Auto Parry" })
ParrySec:AddToggle({
    Name = "Enable Auto Parry",
    Flag = "Parry_Enable",
    Default = VD.SURV_AutoParry,
    Callback = function(v)
        VD.SURV_AutoParry = v
        if not v then
            VD_ParryRange.Transparency = 1
            ResetCooldown()
        end
    end
})

ParrySec:AddDropdown({
    Name = "Parry Mode",
    Flag = "Parry_Mode",
    Default = VD.SURV_ParryMode or "Legit",
    Options = { "Legit", "Aggressive" },
    Callback = function(value)
        VD.SURV_ParryMode = value
    end,
})

ParrySec:AddDropdown({
    Name = "Parry Animation",
    Flag = "Parry_Anim",
    Default = "Default",
    Options = {
        "Default",
        "Shield",
        "Robot",
        "Katana",
        "Fish",
        "Watcher"
    },
    Callback = function(v)
        local animMap = {
            Default = "rbxassetid://109133187196613",
            Shield  = "rbxassetid://75939529748815",
            Robot   = "rbxassetid://126894569253341",
            Katana  = "rbxassetid://127096285501517",
            Fish    = "rbxassetid://123307242865945",
            Watcher = "rbxassetid://81793464499285",
        }
        VD.SURV_ParryAnimId = animMap[v] or animMap.Default
    end,
})

ParrySec:AddSlider({
    Name = "Parry Range",
    Flag = "Parry_Range",
    Min = 2,
    Max = 20,
    Default = VD.SURV_ParryRange or 12,
    Increment = 0.5,
    Callback = function(v)
        VD.SURV_ParryRange = v
        VD_ParryRange.Radius = v
        VD_ParryRange.InnerRadius = math.max(0.1, v - 0.15)
    end
})

ParrySec:AddToggle({
    Name = "Show Parry Range Circle",
    Flag = "Parry_Circle",
    Default = VD.SURV_ShowParryCircle,
    Callback = function(v)
        VD.SURV_ShowParryCircle = v
        if not v then VD_ParryRange.Transparency = 1 end
    end
})

-- ============================================================
--  TELEPORT TAB
-- ============================================================
local TeleSec = TeleportTab:AddSection({ Name = "Teleport" })

local playerNames = {}
local function UpdatePlayerList()
    playerNames = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(playerNames, p.Name) end
    end
end
UpdatePlayerList()
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

local playerDropdown = nil
playerDropdown = TeleSec:AddDropdown({
    Name = "Select Player",
    Flag = "TP_Player_Select",
    Default = "",
    Options = playerNames,
    Callback = function(value)
        VD.TP_TargetPlayer = value
    end,
})

TeleSec:AddButton({
    Name = "Refresh Players",
    Callback = function()
        UpdatePlayerList()
        if playerDropdown then
            pcall(function() playerDropdown:Refresh(playerNames) end)
        end
    end,
})

TeleSec:AddButton({
    Name = "Teleport to Selected Player",
    Callback = function()
        if VD.TP_TargetPlayer == "" then
            OrionLib:MakeNotification({ Name = "NO MERCY", Content = "Select a player first!", Image = ICON.Logo, Time = 2 })
            return
        end
        local target = Players:FindFirstChild(VD.TP_TargetPlayer)
        if target and target.Character then
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot and Root then
                Root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
                OrionLib:MakeNotification({ Name = "NO MERCY", Content = "Teleported!", Image = ICON.Logo, Time = 2 })
            end
        end
    end,
})

TeleSec:AddButton({
    Name = "TP to Generator",
    Callback = function()
        if IYAN_TeleportToGenerator(1) then
            OrionLib:MakeNotification({ Name = "NO MERCY", Content = "Teleported to Generator!", Image = ICON.Logo, Time = 2 })
        end
    end,
})

TeleSec:AddButton({
    Name = "TP to Gate",
    Callback = function()
        if IYAN_TeleportToGate() then
            OrionLib:MakeNotification({ Name = "NO MERCY", Content = "Teleported to Gate!", Image = ICON.Logo, Time = 2 })
        end
    end,
})

TeleSec:AddButton({
    Name = "TP to Hook",
    Callback = function()
        if IYAN_TeleportToHook() then
            OrionLib:MakeNotification({ Name = "NO MERCY", Content = "Teleported to Hook!", Image = ICON.Logo, Time = 2 })
        end
    end,
})

-- ============================================================
--  KILLER TAB
-- ============================================================
local KillerSec = KillerTab:AddSection({ Name = "General" })

KillerSec:AddToggle({
    Name = "Auto Attack",
    Flag = "Killer_AutoAttack",
    Default = VD.AUTO_Attack,
    Callback = function(v) VD.AUTO_Attack = v end
})

KillerSec:AddSlider({
    Name = "Attack Range",
    Flag = "Killer_AttackRange",
    Min = 5,
    Max = 20,
    Default = VD.AUTO_AttackRange,
    Increment = 0.5,
    Callback = function(v) VD.AUTO_AttackRange = v end
})

KillerSec:AddToggle({
    Name = "Double Tap",
    Flag = "Killer_DoubleTap",
    Default = VD.KILLER_DoubleTap,
    Callback = function(v) VD.KILLER_DoubleTap = v end
})

KillerSec:AddToggle({
    Name = "Auto Destroy Pallets",
    Flag = "Killer_DestroyPallets",
    Default = VD.KILLER_DestroyPallets,
    Callback = function(v) VD.KILLER_DestroyPallets = v end
})

KillerSec:AddToggle({
    Name = "Auto Break Generators",
    Flag = "Killer_AutoBreakGene",
    Default = VD.KILLER_AutoBreakGene,
    Callback = function(v) VD.KILLER_AutoBreakGene = v end
})

KillerSec:AddToggle({
    Name = "Block All Vaults",
    Flag = "Killer_BlockVaults",
    Default = VD.KILLER_BlockVaults,
    Callback = function(v) VD.KILLER_BlockVaults = v end
})

local KillerSec2 = KillerTab:AddSection({ Name = "Silent Aim" })

KillerSec2:AddToggle({
    Name = "Silent Aim Veil",
    Flag = "Killer_SilentAimVeil",
    Default = VD.SPEAR_Aimbot,
    Callback = function(v) VD.SPEAR_Aimbot = v end
})

KillerSec2:AddSlider({
    Name = "Spear Speed",
    Flag = "Killer_SpearSpeed",
    Min = 50,
    Max = 300,
    Default = VD.SPEAR_Speed,
    Increment = 5,
    Callback = function(v) VD.SPEAR_Speed = v end
})

KillerSec2:AddSlider({
    Name = "Gravity",
    Flag = "Killer_Gravity",
    Min = 0,
    Max = 300,
    Default = VD.SPEAR_Gravity,
    Increment = 5,
    Callback = function(v) VD.SPEAR_Gravity = v end
})

local KillerSec3 = KillerTab:AddSection({ Name = "Customization" })

local maskOptions = {"Richard", "Tony", "Brandon", "Jake", "Richter", "Graham", "Alex"}
KillerSec3:AddDropdown({
    Name = "Custom Masked",
    Flag = "Killer_CustomMasked",
    Default = VD.KILLER_CustomMasked,
    Options = maskOptions,
    Callback = function(v) VD.KILLER_CustomMasked = v end,
})

KillerSec3:AddButton({
    Name = "Apply Masked",
    Callback = function()
        if IYAN_ApplyCustomMasked(VD.KILLER_CustomMasked) then
            OrionLib:MakeNotification({ Name = "NO MERCY", Content = "Masked applied!", Image = ICON.Logo, Time = 2 })
        end
    end,
})

KillerSec3:AddButton({
    Name = "Random Masked",
    Callback = function()
        local mask = maskOptions[math.random(1, #maskOptions)]
        VD.KILLER_CustomMasked = mask
        if IYAN_ApplyCustomMasked(mask) then
            OrionLib:MakeNotification({ Name = "NO MERCY", Content = "Masked changed to " .. mask .. "!", Image = ICON.Logo, Time = 2 })
        end
    end,
})

-- ============================================================
--  SURVIVOR TAB (GENERATOR ONLY)
-- ============================================================
local SurvivorGenSec = SurvivorTab:AddSection({ Name = "Generator Boost" })

SurvivorGenSec:AddToggle({
    Name = "Gen Boost (BEST)",
    Flag = "Survivor_GenBoost",
    Default = VD.SURV_GenBoost,
    Callback = function(v)
        VD.SURV_GenBoost = v
        if v then
            startGenBoost()
        else
            stopGenBoost()
        end
    end
})

SurvivorGenSec:AddToggle({
    Name = "Draggable Gen Bypass Button",
    Flag = "Survivor_DraggableGenBypass",
    Default = VD.SURV_DraggableGenBypass,
    Callback = function(v)
        VD.SURV_DraggableGenBypass = v
    end
})

local SurvivorGenSec2 = SurvivorTab:AddSection({ Name = "Auto Drop Pallet" })

SurvivorGenSec2:AddToggle({
    Name = "Auto Drop Pallet",
    Flag = "Survivor_AutoDropPallet",
    Default = VD.SURV_AutoDropPallet,
    Callback = function(v)
        VD.SURV_AutoDropPallet = v
        if v then
            OrionLib:MakeNotification({ Name = "NO MERCY", Content = "Auto Drop Pallet Enabled", Image = ICON.Logo, Time = 2 })
        end
    end
})

SurvivorGenSec2:AddSlider({
    Name = "Trigger Distance",
    Flag = "Survivor_DropPalletDist",
    Min = 5,
    Max = 50,
    Default = VD.SURV_AutoDropPalletDist,
    Increment = 1,
    Callback = function(v) VD.SURV_AutoDropPalletDist = v end
})

SurvivorGenSec2:AddDropdown({
    Name = "Drop Mode",
    Flag = "Survivor_DropPalletMode",
    Default = VD.SURV_AutoDropPalletMode,
    Options = { "Aggressive", "Safe" },
    Callback = function(v) VD.SURV_AutoDropPalletMode = v end,
})

local SurvivorGenSec3 = SurvivorTab:AddSection({ Name = "Auto Movement" })

SurvivorGenSec3:AddToggle({
    Name = "Auto Vault",
    Flag = "Survivor_AutoVault",
    Default = VD.SURV_AutoVault,
    Callback = function(v) VD.SURV_AutoVault = v end
})

SurvivorGenSec3:AddToggle({
    Name = "Auto Pallet Slide",
    Flag = "Survivor_AutoPalletSlide",
    Default = VD.SURV_AutoPalletSlide,
    Callback = function(v) VD.SURV_AutoPalletSlide = v end
})

local SurvivorGenSec4 = SurvivorTab:AddSection({ Name = "Other" })

SurvivorGenSec4:AddToggle({
    Name = "Flee Killer",
    Flag = "Survivor_FleeKiller",
    Default = VD.SURV_FleeKiller,
    Callback = function(v) VD.SURV_FleeKiller = v end
})

SurvivorGenSec4:AddSlider({
    Name = "Flee Distance",
    Flag = "Survivor_FleeDistance",
    Min = 15,
    Max = 80,
    Default = VD.SURV_FleeDistance,
    Increment = 1,
    Callback = function(v) VD.SURV_FleeDistance = v end
})

-- ============================================================
--  PLAYER TAB
-- ============================================================
local PlayerTeleportSec = PlayerTab:AddSection({ Name = "Teleport" })

local playerNames2 = {}
local function UpdatePlayerList2()
    playerNames2 = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(playerNames2, p.Name) end
    end
end
UpdatePlayerList2()
Players.PlayerAdded:Connect(UpdatePlayerList2)
Players.PlayerRemoving:Connect(UpdatePlayerList2)

local playerDropdown2 = nil
playerDropdown2 = PlayerTeleportSec:AddDropdown({
    Name = "Select Player",
    Flag = "PlayerTab_TP_Player",
    Default = "",
    Options = playerNames2,
    Callback = function(value)
        VD.TP_TargetPlayer = value
    end,
})

PlayerTeleportSec:AddButton({
    Name = "TP to Player",
    Callback = function()
        if VD.TP_TargetPlayer == "" then
            OrionLib:MakeNotification({ Name = "NO MERCY", Content = "Select a player!", Image = ICON.Logo, Time = 2 })
            return
        end
        local target = Players:FindFirstChild(VD.TP_TargetPlayer)
        if target and target.Character then
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot and Root then
                Root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
            end
        end
    end,
})

local PlayerFlingdSec = PlayerTab:AddSection({ Name = "Fling" })

PlayerFlingdSec:AddToggle({
    Name = "Enable Fling",
    Flag = "Player_FlingEnable",
    Default = VD.FLING_Enabled,
    Callback = function(v) VD.FLING_Enabled = v end
})

PlayerFlingdSec:AddSlider({
    Name = "Fling Strength",
    Flag = "Player_FlingStrength",
    Min = 1000,
    Max = 50000,
    Default = VD.FLING_Strength,
    Increment = 1000,
    Callback = function(v) VD.FLING_Strength = v end
})

PlayerFlingdSec:AddButton({
    Name = "Fling Nearest",
    Callback = function()
        pcall(IYAN_FlingNearest)
    end,
})

PlayerFlingdSec:AddButton({
    Name = "Fling All",
    Callback = function()
        pcall(IYAN_FlingAll)
    end,
})

local PlayerFunSec = PlayerTab:AddSection({ Name = "Fun" })

local spoofLevel, spoofGears, spoofScrews = "0", "0", "0"

PlayerFunSec:AddTextbox({
    Name = "Set Level",
    Default = "0",
    TextDisappear = false,
    Callback = function(value)
        spoofLevel = value
    end,
})

PlayerFunSec:AddTextbox({
    Name = "Set Gears",
    Default = "0",
    TextDisappear = false,
    Callback = function(value)
        spoofGears = value
    end,
})

PlayerFunSec:AddTextbox({
    Name = "Set Screws",
    Default = "0",
    TextDisappear = false,
    Callback = function(value)
        spoofScrews = value
    end,
})

PlayerFunSec:AddButton({
    Name = "Apply Spoof",
    Callback = function()
        local p = LocalPlayer
        if p then
            p:SetAttribute("Level", tonumber(spoofLevel) or 0)
            p:SetAttribute("Gears", tonumber(spoofGears) or 0)
            p:SetAttribute("Screws", tonumber(spoofScrews) or 0)
            OrionLib:MakeNotification({ Name = "NO MERCY", Content = "Spoof applied!", Image = ICON.Logo, Time = 2 })
        end
    end,
})

local PlayerStreamerSec = PlayerTab:AddSection({ Name = "Streamer Mode" })

local FakeNameConnection = nil
local function enableFakeName(enabled)
    if FakeNameConnection then
        pcall(function() FakeNameConnection:Disconnect() end)
        FakeNameConnection = nil
    end
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then
        return
    end
    local function process(object)
        if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
            local text = ""
            pcall(function() text = tostring(object.Text or "") end)
            if text == LocalPlayer.Name or text == LocalPlayer.DisplayName or text:find(LocalPlayer.Name, 1, true) ~= nil then
                object.Visible = not enabled
            end
        end
    end
    for _, descendant in ipairs(playerGui:GetDescendants()) do
        process(descendant)
    end
    if enabled then
        FakeNameConnection = playerGui.DescendantAdded:Connect(function(object)
            task.defer(process, object)
        end)
    end
end

PlayerStreamerSec:AddToggle({
    Name = "Hide Name",
    Flag = "Player_HideName",
    Default = VD.StreamerMode,
    Callback = function(v)
        VD.StreamerMode = v
        pcall(enableFakeName, v)
    end
})

-- ============================================================
--  VISUAL TAB
-- ============================================================
local VisualESPSec = VisualTab:AddSection({ Name = "Drawing ESP" })

VisualESPSec:AddToggle({
    Name = "Enable Drawing ESP",
    Flag = "Visual_DrawingESP",
    Default = VD.DRAWING_ESP,
    Callback = function(v) VD.DRAWING_ESP = v end
})

VisualESPSec:AddSlider({
    Name = "Max ESP Distance",
    Flag = "Visual_MaxDistance",
    Min = 500,
    Max = 5000,
    Default = VD.MaxDistance,
    Increment = 250,
    Callback = function(v) VD.MaxDistance = v end
})

VisualESPSec:AddToggle({
    Name = "ESP Skeleton",
    Flag = "Visual_ESPSkeleton",
    Default = VD.ESP_Skeleton,
    Callback = function(v) VD.ESP_Skeleton = v end
})

VisualESPSec:AddToggle({
    Name = "ESP Velocity Arrows",
    Flag = "Visual_ESPVelocity",
    Default = VD.ESP_Velocity,
    Callback = function(v) VD.ESP_Velocity = v end
})

VisualESPSec:AddToggle({
    Name = "ESP Offscreen Arrows",
    Flag = "Visual_ESPOffscreen",
    Default = VD.ESP_Offscreen,
    Callback = function(v) VD.ESP_Offscreen = v end
})

local VisualLightingSec = VisualTab:AddSection({ Name = "Lighting" })

VisualLightingSec:AddToggle({
    Name = "Fullbright",
    Flag = "Visual_Fullbright",
    Default = VD.Fullbright,
    Callback = function(v)
        VD.Fullbright = v
        applyFullbright(v)
    end
})

VisualLightingSec:AddToggle({
    Name = "No Fog",
    Flag = "Visual_NoFog",
    Default = VD.NoFog,
    Callback = function(v)
        VD.NoFog = v
        applyNoFog(v)
    end
})

-- ============================================================
--  SPEED TAB
-- ============================================================
local SpeedSec = SpeedTab:AddSection({ Name = "Movement" })

SpeedSec:AddSlider({
    Name = "Walk Speed",
    Flag = "Speed_WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Increment = 1,
    Callback = function(v)
        VD.SpeedValue = v
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = v
        end
    end,
})

-- ============================================================
--  SETTINGS TAB
-- ============================================================
local SettingsSec = SettingsTab:AddSection({ Name = "Main" })

SettingsSec:AddButton({
    Name = "Close UI",
    Callback = function()
        confirmClose()
    end,
})

local function VD_Notify(title, content, duration)
    OrionLib:MakeNotification({ Name = title, Content = content, Image = ICON.Logo, Time = duration or 2 })
end

OrionLib:MakeNotification({ Name = "NO MERCY", Content = "Violence District v2.0 loaded!", Image = ICON.Logo, Time = 4 })

print("[NO MERCY] Violence District v2.0 - Full Migration Complete!")
