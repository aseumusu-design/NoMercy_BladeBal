--[[
  NO MERCY — "VIOLENCE DISTRICT"
  UI: Orion (MarV) — hide/show via bubble + konfirmasi tutup
  FULL MIGRATION from Zian Hub X v1.4.7
]]

-- ============================================================
--  ICONS & SERVICES
-- ============================================================
local ICON = {
    Info     = "rbxassetid://7733964719",
    Crosshair= "rbxassetid://7733765307",
    Swords   = "rbxassetid://7734056608",
    Globe    = "rbxassetid://7733954760",
    Axe      = "rbxassetid://7733674079",
    User     = "rbxassetid://7743875962",
    Eye      = "rbxassetid://7733774602",
    Zap      = "rbxassetid://7733771628",
    Settings = "rbxassetid://7734053495",
    Logo     = "rbxassetid://102609928046926",
    Banner   = "rbxassetid://138968189462646",
}

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Teams = game:GetService("Teams")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ============================================================
--  GLOBAL CONFIG (VD TABLE from Zian)
-- ============================================================
getgenv().VD = getgenv().VD or {
    AutoSkillcheck = false,
    AutoSkillcheckMode = "Normal",
    SURV_FleeKiller = false,
    SURV_FleeDistance = 40,
    SURV_AntiKnock = false,
    SURV_FirstPerson = false,
    InstantHealSelf = false,
    AutoHealAll = false,
    SURV_AutoVault = false,
    SURV_AutoPalletSlide = false,
    SURV_AutoDropPallet = false,
    SURV_AutoDropPalletDist = 20,
    SURV_AutoDropPalletMode = "Aggressive",
    SURV_AutoParry = false,
    SURV_ParryMode = "Legit",
    SURV_ParryAnimId = "rbxassetid://109133187196613",
    SURV_ParryRange = 12,
    SURV_ShowParryCircle = true,
    Parry_Keybind = "F3",
    AUTO_ToFAim = false,
    AUTO_ToFAimRange = 90,
    AUTO_ToFDotThreshold = 0.5,
    AUTO_ToFTargetMode = "Killer",
    AUTO_ToFAimPart = "HumanoidRootPart",
    AUTO_ToFPredict = true,
    AUTO_ToFBulletSpeed = 200,
    AUTO_Attack = false,
    AUTO_AttackRange = 12,
    KILLER_DestroyPallets = false,
    KILLER_AutoBreakGene = false,
    KILLER_BlockVaults = false,
    KILLER_AntiBlind = false,
    KILLER_DoubleTap = false,
    SPEAR_Aimbot = false,
    SPEAR_Gravity = 50,
    SPEAR_Speed = 100,
    KILLER_CustomMasked = "Richard",
    DRAWING_ESP = false,
    ESP_Skeleton = false,
    ESP_Offscreen = false,
    ESP_Velocity = false,
    MaxDistance = 2000,
    ESP_LowPerformance = false,
    Fullbright = false,
    NoFog = false,
    SURV_GenBoost = false,
    SURV_DraggableGenBypass = false,
    FLING_Enabled = false,
    FLING_Strength = 10000,
    Destroyed = false,
}

local VD = getgenv().VD

-- ============================================================
--  UTILITY
-- ============================================================
local function clamp(v, min, max) return math.max(min, math.min(max, v)) end

local function GetHolder()
    return (gethui and gethui()) or game:GetService("CoreGui")
end

local DrawingAvailable = (function()
    if isMobile then return false end
    local ok, result = pcall(function() return typeof(Drawing) == "table" and Drawing.new ~= nil end)
    return ok and result or false
end)()

local function SafeDrawing(typ)
    if not DrawingAvailable then return nil end
    local ok, res = pcall(function() return Drawing.new(typ) end)
    return ok and res or nil
end

local function SafeRemove(obj)
    if obj and obj.Remove then pcall(function() obj:Remove() end) end
end

local function VD_Notify(title, content, duration)
    pcall(function()
        OrionLib:MakeNotification({ Name = title, Content = content, Image = ICON.Logo, Time = duration or 2 })
    end)
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
--  TEAM HELPERS
-- ============================================================
local function GetRole()
    if not LocalPlayer.Team then return "Unknown" end
    local name = LocalPlayer.Team.Name
    if name == "Killer" then return "Killer" end
    if name == "Survivors" then return "Survivor" end
    return "Lobby"
end

local function IsKiller(player)
    return player and player.Team and player.Team.Name == "Killer"
end

local function IsSurvivor(player)
    return player and player.Team and player.Team.Name == "Survivors"
end

-- ============================================================
--  CONFIG SYSTEM
-- ============================================================
local ConfigFolderName = "NoMercyViolence"

pcall(function()
    if makefolder and isfolder and not isfolder(ConfigFolderName) then
        makefolder(ConfigFolderName)
    end
end)

getgenv().CurrentConfigName = "Default"

local function Ziaan_SaveConfig()
    pcall(function()
        if writefile then
            writefile(ConfigFolderName .. "/VD_State.json", HttpService:JSONEncode(VD))
        end
    end)
end

local function Ziaan_LoadConfig()
    pcall(function()
        if readfile and isfile and isfile(ConfigFolderName .. "/VD_State.json") then
            local data = HttpService:JSONDecode(readfile(ConfigFolderName .. "/VD_State.json"))
            for k, v in pairs(data) do VD[k] = v end
        end
    end)
end

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

    local tweenIn = TweenService:Create(img, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(150, 150) })
    local strokeIn = TweenService:Create(stroke, TweenInfo.new(0.4), { Transparency = 0 })
    local textIn = TweenService:Create(introText, TweenInfo.new(0.4), { TextTransparency = 0 })
    tweenIn:Play(); strokeIn:Play(); textIn:Play()
    tweenIn.Completed:Wait()

    local pulsing = true
    task.spawn(function()
        while pulsing do
            local t1 = TweenService:Create(stroke, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.8, Thickness = 6 })
            t1:Play(); t1.Completed:Wait()
            if not pulsing then break end
            local t2 = TweenService:Create(stroke, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0, Thickness = 2 })
            t2:Play(); t2.Completed:Wait()
        end
    end)

    task.wait(1.5); pulsing = false

    local tweenOut = TweenService:Create(img, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.fromOffset(0, 0) })
    local strokeOut = TweenService:Create(stroke, TweenInfo.new(0.3), { Transparency = 1 })
    local textOut = TweenService:Create(introText, TweenInfo.new(0.3), { TextTransparency = 1 })
    tweenOut:Play(); strokeOut:Play(); textOut:Play()
    tweenOut.Completed:Wait()
    gui:Destroy()
end

ShowWelcomeIntro()

-- ============================================================
--  ORION LIB & WINDOW
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

-- ============================================================
--  BUBBLE & CLOSE SYSTEM
-- ============================================================
local bubbleGui = nil

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
            t1:Play(); t1.Completed:Wait()
            if not bubblePulsing or not stroke or not stroke.Parent then break end
            local t2 = TweenService:Create(stroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0, Thickness = 2 })
            t2:Play(); t2.Completed:Wait()
        end
    end)

    btn.MouseButton1Click:Connect(function()
        bubblePulsing = false
        local main = FindMainWindow()
        if main then main.Visible = true end
        bubbleGui:Destroy()
        bubbleGui = nil
    end)

    bubbleGui = gui
end

local function closeUI()
    local main = FindMainWindow()
    if main then main.Visible = false end
    makeBubble()
end

local function showUI()
    local main = FindMainWindow()
    if main then main.Visible = true end
end

local function confirmClose(fromCloseBtn)
    if fromCloseBtn then showUI() end
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

    local function destroy() gui:Destroy() end
    local function cancel()
        destroy()
        if fromCloseBtn then showUI() end
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
    btnYa.MouseButton1Click:Connect(function() destroy(); closeUI() end)

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
        if i.UserInputType == Enum.UserInputType.MouseButton1 then cancel() end
    end)
end

onCloseRequest = function() confirmClose(true) end

print("[NO MERCY] Core UI loaded")


-- ============================================================
--  UNIFIED METAMETHOD HOOK (ToF + Veil + AntiBlind)
-- ============================================================
local IYAN_WorldReg
local IYAN_ToFFireRemote = nil
local oldNamecall = nil
local AntiBlindRemote = nil

pcall(function()
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    local i = r and r:FindFirstChild("Items")
    local fl = i and i:FindFirstChild("Flashlight")
    AntiBlindRemote = fl and fl:FindFirstChild("GotBlinded")
end)

local function setupHooks()
    if getgenv().NoMercy_HooksInstalled then return end
    getgenv().NoMercy_HooksInstalled = true
    task.spawn(function()
        pcall(function()
            local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
            local tofItems = Remotes and Remotes:FindFirstChild("Items")
            local tofFolder = tofItems and tofItems:FindFirstChild("Twist of Fate")
            IYAN_ToFFireRemote = tofFolder and tofFolder:FindFirstChild("Fire")
            local _tofDeferred = false

            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                local args = {...}

                -- Anti Blind
                if not checkcaller() and VD.KILLER_AntiBlind and AntiBlindRemote and self == AntiBlindRemote and method == "FireServer" and GetRole() == "Killer" then
                    return nil
                end

                -- Veil block
                if method == "FireServer" and not checkcaller() then
                    if self.Name == "Spearthrow" and VeilConfig.Enabled then
                        return nil
                    end
                end

                -- ToF redirect
                if _tofDeferred then
                    return oldNamecall(self, ...)
                elseif IYAN_ToFFireRemote and VD.AUTO_ToFAim
                and self == IYAN_ToFFireRemote
                and method == "FireServer"
                and not checkcaller() then

                    if typeof(args[1]) == "Instance" and typeof(args[2]) == "Vector3" then
                        local myChar = LocalPlayer.Character
                        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                        if myRoot then
                            local bestPart, bestDist = nil, (VD.AUTO_ToFAimRange or 90)
                            local targetMode = VD.AUTO_ToFTargetMode or "Killer"
                            local aimPartName = VD.AUTO_ToFAimPart or "HumanoidRootPart"

                            if targetMode == "SCP" then
                                if IYAN_WorldReg and IYAN_WorldReg.SCPZombie then
                                    for model, entry in pairs(IYAN_WorldReg.SCPZombie) do
                                        if model and model.Parent then
                                            local part
                                            if model:IsA("Model") then
                                                part = model:FindFirstChild(aimPartName) or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                                            elseif model:IsA("BasePart") then
                                                part = model
                                            end
                                            part = part or (entry and entry.part)
                                            if part then
                                                local d = (part.Position - myRoot.Position).Magnitude
                                                if d <= bestDist then
                                                    bestDist = d
                                                    bestPart = part
                                                end
                                            end
                                        end
                                    end
                                end
                            else
                                for _, plr in ipairs(Players:GetPlayers()) do
                                    if plr ~= LocalPlayer and plr.Character and plr.Team then
                                        local validTeam = (targetMode == "Killer" and plr.Team.Name == "Killer") or
                                                          (targetMode == "Survivor" and plr.Team.Name == "Survivors")
                                        if validTeam then
                                            local targetPart = plr.Character:FindFirstChild(aimPartName)
                                            local targetHum = plr.Character:FindFirstChildOfClass("Humanoid")
                                            if targetPart and targetHum and targetHum.Health > 0 then
                                                local d = (targetPart.Position - myRoot.Position).Magnitude
                                                if d <= bestDist then
                                                    bestDist = d
                                                    bestPart = targetPart
                                                end
                                            end
                                        end
                                    end
                                end
                            end

                            if bestPart then
                                local gunPart = args[1]
                                local gunPos
                                pcall(function() gunPos = gunPart.Position end)
                                gunPos = gunPos or myRoot.Position
                                local targetCenter = bestPart.Position
                                local targetPos = targetCenter
                                if VD.AUTO_ToFPredict then
                                    local rawVel = bestPart.AssemblyLinearVelocity
                                    local flatVel = Vector3.new(rawVel.X, 0, rawVel.Z)
                                    local bulletSpeed = VD.AUTO_ToFBulletSpeed or 200
                                    local travelTime = bestDist / bulletSpeed
                                    targetPos = targetCenter + (flatVel * travelTime)
                                end
                                local dir = targetPos - gunPos
                                local newDir = (dir.Magnitude > 0.01) and dir.Unit or args[2]
                                local camLook = Camera.CFrame.LookVector
                                local dotCheck = camLook:Dot(newDir)
                                if dotCheck < (VD.AUTO_ToFDotThreshold or 0.5) then return end
                                _tofDeferred = true
                                task.defer(function()
                                    pcall(function() IYAN_ToFFireRemote:FireServer(args[1], newDir) end)
                                    _tofDeferred = false
                                end)
                                return
                            end
                        end
                    end
                end
                return oldNamecall(self, ...)
            end)
        end)
    end)
end
setupHooks()

-- ============================================================
--  FIRST PERSON CAMERA
-- ============================================================
local _fpWasSet = false
local _fpOriginal = nil

local function RestoreFirstPersonCamera()
    if not _fpWasSet then return end
    _fpWasSet = false
    pcall(function()
        if _fpOriginal then
            LocalPlayer.CameraMode = _fpOriginal.CameraMode or Enum.CameraMode.Classic
            LocalPlayer.CameraMaxZoomDistance = _fpOriginal.CameraMaxZoomDistance or 128
            LocalPlayer.CameraMinZoomDistance = _fpOriginal.CameraMinZoomDistance or 0.5
        else
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMaxZoomDistance = 128
        end
    end)
    local char = LocalPlayer.Character
    if char then
        local head = char:FindFirstChild("Head")
        if head then head.LocalTransparencyModifier = 0 end
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Accessory") then
                local handle = obj:FindFirstChild("Handle")
                if handle then handle.LocalTransparencyModifier = 0 end
            end
        end
    end
    _fpOriginal = nil
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        if VD.SURV_FirstPerson then
            local isSurvivor = LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors"
            if isSurvivor then
                if not _fpWasSet then
                    _fpOriginal = {
                        CameraMode = LocalPlayer.CameraMode,
                        CameraMaxZoomDistance = LocalPlayer.CameraMaxZoomDistance,
                        CameraMinZoomDistance = LocalPlayer.CameraMinZoomDistance,
                    }
                end
                if LocalPlayer.CameraMode ~= Enum.CameraMode.LockFirstPerson then
                    LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
                end
                if LocalPlayer.CameraMaxZoomDistance ~= 0 then
                    LocalPlayer.CameraMaxZoomDistance = 0
                end
                local char = LocalPlayer.Character
                if char then
                    local head = char:FindFirstChild("Head")
                    if head then head.LocalTransparencyModifier = 1 end
                    for _, obj in ipairs(char:GetChildren()) do
                        if obj:IsA("Accessory") then
                            local handle = obj:FindFirstChild("Handle")
                            if handle then handle.LocalTransparencyModifier = 1 end
                        end
                    end
                end
                _fpWasSet = true
            elseif _fpWasSet then
                RestoreFirstPersonCamera()
            end
        elseif _fpWasSet then
            RestoreFirstPersonCamera()
        end
    end)
end)

-- ============================================================
--  PARRY SYSTEM
-- ============================================================
local VD_ParryRange = Instance.new("CylinderHandleAdornment")
VD_ParryRange.Name = "NoMercy_ParryRange"
VD_ParryRange.Radius = VD.SURV_ParryRange or 12
VD_ParryRange.InnerRadius = math.max(0.1, (VD.SURV_ParryRange or 12) - 0.15)
VD_ParryRange.Height = 0.01
VD_ParryRange.Color3 = Color3.fromRGB(80, 80, 80)
VD_ParryRange.AlwaysOnTop = false
VD_ParryRange.Adornee = Workspace:FindFirstChildOfClass("Terrain")
VD_ParryRange.Transparency = 1
VD_ParryRange.Parent = GetHolder()

local function VD_UpdateParryRange()
    if not VD.SURV_AutoParry or not VD.SURV_ShowParryCircle then
        VD_ParryRange.Transparency = 1
        return
    end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then VD_ParryRange.Transparency = 1 return end
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
    if char:FindFirstChild("Parrying Dagger") then return true end
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
                            if gradient then table.insert(ParryGradients, gradient) end
                        end
                    end
                    local icon = itemFrame:FindFirstChild("icon")
                    if icon then ParryIcon = icon end
                end
            end
        end
    end
    local mobScreen = playerGui:FindFirstChild("Survivor-mob")
    if mobScreen then
        local controls = mobScreen:FindFirstChild("Controls")
        if controls then
            for _, btn in ipairs(controls:GetChildren()) do
                if btn:IsA("ImageButton") and btn.Name == "Gui-mob" then
                    local bar = btn:FindFirstChild("Bar")
                    if bar then
                        local gradient = bar:FindFirstChild("UIGradient")
                        if gradient then table.insert(ParryGradients, gradient) end
                    end
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

task.spawn(function()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end
    playerGui.ChildAdded:Connect(function(child)
        if child.Name == "Survivor-mob" then
            local controls = child:WaitForChild("Controls", 5)
            if controls then
                for _, btn in ipairs(controls:GetChildren()) do
                    if btn:IsA("ImageButton") and btn.Name == "Gui-mob" then
                        local bar = btn:FindFirstChild("Bar")
                        if bar then
                            local gradient = bar:FindFirstChild("UIGradient")
                            if gradient then table.insert(ParryGradients, gradient) end
                        end
                    end
                end
                controls.ChildAdded:Connect(function(btn)
                    if btn:IsA("ImageButton") and btn.Name == "Gui-mob" then
                        local bar = btn:FindFirstChild("Bar")
                        if bar then
                            local gradient = bar:FindFirstChild("UIGradient")
                            if gradient then table.insert(ParryGradients, gradient) end
                        end
                    end
                end)
            end
        end
    end)
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
    if #ParrySystem.Gradients == 0 then GetParryUIElements() end
    for _, grad in ipairs(ParrySystem.Gradients) do
        if grad and grad.Parent and grad.Parent.Parent then
            local icon = grad.Parent.Parent:FindFirstChild("icon")
            if icon then icon.ImageColor3 = color end
            local gui = grad.Parent.Parent:FindFirstChild("Gui")
            if gui then gui.ImageColor3 = color end
        end
    end
    if ParryIcon then ParryIcon.ImageColor3 = color end
end

local function PlayCooldownTween(duration)
    if #ParrySystem.Gradients == 0 then GetParryUIElements() end
    for _, grad in ipairs(ParrySystem.Gradients) do
        if grad and grad.Parent then
            grad.Offset = Vector2.new(0, 0.75)
            local tween = TweenService:Create(grad, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Offset = Vector2.new(0, 0.25) })
            tween:Play()
            tween.Completed:Connect(function()
                if not ParrySystem.IsOnCooldown then SetIconsColor(Color3.fromRGB(255,255,255)) end
            end)
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
    if ParrySystem.CooldownThread then task.cancel(ParrySystem.CooldownThread) end
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
        if grad and grad.Parent then grad.Offset = Vector2.new(0, 0.25) end
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
        if step.duration == math.huge then break else task.wait(step.duration) end
    end
end

local function DoParry()
    if not CanParry() then return end
    ParrySystem.IsResolving = true
    SetIconsColor(Color3.fromRGB(77,77,77))
    local parryRemote = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Items"):FindFirstChild("Parrying Dagger"):FindFirstChild("parry")
    if parryRemote then pcall(function() parryRemote:FireServer() end) end
    FaceLookDirection()
    if Humanoid then Humanoid.AutoRotate = false end
    PlayParryAnimation()
    local rootPart = Root
    if rootPart then CollectionService:AddTag(rootPart, "doing action") end
    local slowRemote = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Mechanics"):FindFirstChild("Slow")
    if slowRemote then pcall(function() slowRemote:Fire(0, 1, 0) end) end
    task.spawn(applyWalkSpeedSequence)
    task.delay(2, function()
        if ParrySystem.IsResolving then
            ParrySystem.IsResolving = false
            StartCooldown(60)
            if rootPart then CollectionService:RemoveTag(rootPart, "doing action") end
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
                if success == true then StartCooldown(90) else StartCooldown(60) end
            end
            local rootPart = Root
            if rootPart then CollectionService:RemoveTag(rootPart, "doing action") end
        end)
    end)
end
ListenParryResult()

local VD_ATTACK_ANIMS = {
    ["rbxassetid://113255068724446"] = true, ["rbxassetid://74968262036854"] = true,
    ["rbxassetid://110355011987939"] = true, ["rbxassetid://139369275981139"] = true,
    ["rbxassetid://132817836308238"] = true, ["rbxassetid://129784271201071"] = true,
    ["rbxassetid://133963973694098"] = true, ["rbxassetid://117042998468241"] = true,
    ["rbxassetid://105374834496520"] = true, ["rbxassetid://111920872708571"] = true,
    ["rbxassetid://78432063483146"] = true, ["rbxassetid://118907603246885"] = true,
    ["rbxassetid://138720291317243"] = true, ["rbxassetid://115244153053858"] = true,
    ["rbxassetid://130593238885843"] = true, ["rbxassetid://122812055447896"] = true,
    ["rbxassetid://78935059863801"] = true, ["rbxassetid://135002183282873"] = true,
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
        if not parent then Attached[kChar] = nil end
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

print("[NO MERCY] Parry system loaded")


ilConfig.TargetPart == "Head" then
        return char:FindFirstChild("Head")
    elseif VeilConfig.TargetPart == "Root" then
        return char:FindFirstChild("HumanoidRootPart")
    else
        return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
    end
end

function veil_getClosestSurvivor()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local cam = workspace.CurrentCamera
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local bestDist = VeilConfig.FOV
    local bestTarget = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team and p.Team.Name == "Survivors" and p.Character then
            local char = p.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local part = veil_getTargetPart(char)
            if hum and hum.Health > 0 and part then
                local dist3D = (part.Position - myRoot.Position).Magnitude
                if dist3D <= VeilConfig.MaxDist then
                    local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist2D < bestDist then
                            bestDist = dist2D
                            bestTarget = { Player = p, Part = part }
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

function veil_fire()
    if VeilState.attackCooldown then return end
    VeilState.attackCooldown = true
    task.delay(2, function() VeilState.attackCooldown = false end)
    local myChar = LocalPlayer.Character
    local startPart = myChar and (myChar:FindFirstChild("Head") or myChar:FindFirstChild("HumanoidRootPart"))
    if not startPart then return end
    local startPos = startPart.Position
    local targetInfo = veil_getClosestSurvivor()
    local aimDir
    if targetInfo and targetInfo.Part then
        local targetPart = targetInfo.Part
        local targetPlayer = targetInfo.Player
        local targetPos = targetPart.Position
        local velocity = Veil_GetRealVelocity(targetPart, targetPlayer.Name)
        local horizontalVel = Vector3.new(velocity.X, 0, velocity.Z)
        local speed = horizontalVel.Magnitude
        local distance = (targetPos - startPos).Magnitude
        local timeToHit = distance / VeilConfig.SpearSpeed
        local horizontalPrediction = Vector3.zero
        if speed > 4 then
            local factor = VeilConfig.HorizontalPredictFactor
            horizontalPrediction = horizontalVel.Unit * factor
        end
        local predictedPos = targetPos + horizontalPrediction
        local distMult = math.clamp(distance / 100, 1, 2.5)
        local autoGravity = math.max(0, distance - 8)
        local gravity = VeilConfig.AutoPredict and autoGravity or VeilConfig.Gravity
        local drop = 0.5 * gravity * (timeToHit ^ 2) * distMult
        local finalPos = predictedPos + Vector3.new(0, drop, 0)
        aimDir = (finalPos - startPos).Unit
        VeilState.lastPredictedPos = finalPos
    else
        aimDir = workspace.CurrentCamera.CFrame.LookVector
        VeilState.lastPredictedPos = nil
    end
    pcall(function()
        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        if remotes then
            local killers = remotes:FindFirstChild("Killers")
            if killers then
                local veil = killers:FindFirstChild("Veil")
                if veil and veil:FindFirstChild("Spearthrow") then
                    veil.Spearthrow:FireServer(aimDir, VeilConfig.SpearSpeed, startPos)
                end
            end
        end
    end)
    if VeilDraw.FOVCircle then VeilDraw.FOVCircle.Color = Color3.fromRGB(180, 180, 180) end
    if not VeilState.passiveCooldown then
        VeilState.passiveCooldown = true
        task.delay(30, function()
            if VeilDraw.FOVCircle then VeilDraw.FOVCircle.Color = Color3.fromRGB(180, 180, 180) end
            VeilState.passiveCooldown = false
        end)
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    local isTouch = input.UserInputType == Enum.UserInputType.Touch
    if gp and not isTouch then return end
    local char = LocalPlayer.Character
    local isSpearMode = char and char:GetAttribute("spearmode") == true
    if not VeilConfig.Enabled then return end
    if not isSpearMode then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        VeilState.chargingSpear = true
    elseif isTouch then
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if pGui then
            local slasher = pGui:FindFirstChild("Slasher-mob")
            if slasher then
                local ctrl = slasher:FindFirstChild("Controls")
                if ctrl then
                    local attackBtn = ctrl:FindFirstChild("attack")
                    if attackBtn and attackBtn.Visible then
                        local pos = input.Position
                        local absPos = attackBtn.AbsolutePosition
                        local absSize = attackBtn.AbsoluteSize
                        if pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y then
                            VeilState.chargingSpear = true
                            VeilState.touchInput = input
                        end
                    end
                end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if VeilState.chargingSpear and (input == VeilState.touchInput or input.UserInputType == Enum.UserInputType.MouseButton1) then
        VeilState.chargingSpear = false
        if VeilState.touchInput == input then VeilState.touchInput = nil end
        veil_fire()
    end
end)

RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    local myChar = LocalPlayer.Character
    local isSpearMode = myChar and myChar:GetAttribute("spearmode") == true
    if VeilConfig.Enabled and VeilConfig.ShowFOV and isSpearMode and VeilDraw.FOVCircle then
        VeilDraw.FOVCircle.Visible = true
        VeilDraw.FOVCircle.Radius = VeilConfig.FOV
        VeilDraw.FOVCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    elseif VeilDraw.FOVCircle then
        VeilDraw.FOVCircle.Visible = false
    end
    if VeilState.chargingSpear and VeilConfig.Enabled and isSpearMode then
        local target = veil_getClosestSurvivor()
        if target and target.Part and target.Part.Parent then
            VeilDraw.Highlight.Parent = target.Part.Parent
        else
            VeilDraw.Highlight.Parent = nil
        end
    else
        VeilDraw.Highlight.Parent = nil
    end
    if VeilConfig.Enabled and isSpearMode and VeilState.lastPredictedPos and VeilDraw.Tracer then
        local screenPos, onScreen = cam:WorldToViewportPoint(VeilState.lastPredictedPos)
        local viewport = cam.ViewportSize
        local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
        if onScreen then
            VeilDraw.Tracer.Position = Vector2.new(screenPos.X, screenPos.Y)
        else
            local dx = screenPos.X - center.X
            local dy = screenPos.Y - center.Y
            if math.abs(dx) < 1 and math.abs(dy) < 1 then
                VeilDraw.Tracer.Position = center
            else
                local angle = math.atan2(dy, dx)
                local maxX = viewport.X / 2 - 10
                local maxY = viewport.Y / 2 - 10
                local scaleX = maxX / math.abs(dx)
                local scaleY = maxY / math.abs(dy)
                local scale = math.min(scaleX, scaleY)
                VeilDraw.Tracer.Position = Vector2.new(center.X + dx * scale, center.Y + dy * scale)
            end
        end
        VeilDraw.Tracer.Visible = true
    elseif VeilDraw.Tracer then
        VeilDraw.Tracer.Visible = false
    end
end)

print("[NO MERCY] Veil system loaded")


-- ============================================================
--  GEN BOOST SYSTEM
-- ============================================================
local DragConfigPath = ConfigFolderName .. "/drag.json"

local function loadBypassButtonPosition()
    local pos = nil
    pcall(function()
        if isfile and readfile and isfile(DragConfigPath) then
            local data = HttpService:JSONDecode(readfile(DragConfigPath))
            if data and data.XScale ~= nil then
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
                XScale = udim2Pos.X.Scale, XOffset = udim2Pos.X.Offset,
                YScale = udim2Pos.Y.Scale, YOffset = udim2Pos.Y.Offset,
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
    for _, c in ipairs(bypassButtonDragConns) do pcall(function() c:Disconnect() end) end
    bypassButtonDragConns = {}
end

local function makeButtonDraggable(button)
    disconnectDragConns()
    local dragging = false
    local dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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
                    if dragging then dragging = false; saveBypassButtonPosition(button.Position) end
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
        if dragging and input == dragInput then update(input) end
    end))
end

local function createBypassButton()
    if bypassButton and bypassButton.Parent then return end
    local guiParent = GetHolder()
    if not guiParent then return end
    if bypassButtonGui then bypassButtonGui:Destroy() end
    bypassButtonGui = Instance.new("ScreenGui")
    bypassButtonGui.Name = "NoMercy_GenBypassGui"
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
        if not char then bypassButton.ImageColor3 = Color3.new(1, 1, 1); return end
        local ci = char:FindFirstChild("CheckInterractable")
        if not ci then bypassButton.ImageColor3 = Color3.new(1, 1, 1); return end
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
        local char = LocalPlayer.Character
        if not char then return end
        local ci = char:FindFirstChild("CheckInterractable")
        if not ci then return end
        local repairing = ci:GetAttribute("isRepairing") or ci:GetAttribute("IsRepairing")
        if not repairing then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local genCache, lastCacheTime = {}, 0
        local function getGenerators()
            if tick() - lastCacheTime < 5 then return genCache end
            genCache, lastCacheTime = {}, tick()
            local folder = Workspace:FindFirstChild("Map") or Workspace
            for _, v in pairs(folder:GetDescendants()) do
                if v:IsA("Model") and v.Name == "Generator" then
                    local real = v:GetAttribute("RepairProgress") ~= nil or v:GetAttribute("kickcount") ~= nil or v:GetAttribute("ProgressRepair") ~= nil
                    if real then table.insert(genCache, v) end
                end
            end
            return genCache
        end

        local function getPoints(genModel)
            local pts = {}
            for _, obj in pairs(genModel:GetChildren()) do
                if obj.Name:find("GeneratorPoint") and obj:IsA("BasePart") then table.insert(pts, obj) end
            end
            return pts
        end

        local function waitRepairing(point, timeout)
            local start = tick()
            while tick() - start < timeout do
                if point:GetAttribute("IsRepairing") == true then return true end
                task.wait(0.05)
            end
            return false
        end

        local RepairEvent = nil
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes then
                local genFolder = remotes:FindFirstChild("Generator")
                if genFolder then RepairEvent = genFolder:FindFirstChild("RepairEvent") end
            end
        end)
        if not RepairEvent then return end

        local bestPoint, bestDist = nil, math.huge
        local bestGen = nil
        for _, gen in pairs(getGenerators()) do
            for _, pt in pairs(getPoints(gen)) do
                local d = (hrp.Position - pt.Position).Magnitude
                if d < bestDist then bestDist = d; bestPoint = pt; bestGen = gen end
            end
        end

        if bestPoint and bestGen then
            local allPoints = getPoints(bestGen)
            local targetPoints = {}
            for _, p in ipairs(allPoints) do if p ~= bestPoint then table.insert(targetPoints, p) end end
            if #targetPoints == 0 then return end
            local startCFrame = hrp.CFrame
            for i, point in ipairs(targetPoints) do
                if not point.Parent then continue end
                hrp.Anchored = true
                hrp.CFrame = point.CFrame
                task.wait(0.15)
                if RepairEvent then RepairEvent:FireServer(point, true) end
                local ok = waitRepairing(point, 0.8)
                if not ok then
                    if RepairEvent then RepairEvent:FireServer(point, false) end
                    task.wait(0.1)
                    hrp.CFrame = point.CFrame
                    task.wait(0.15)
                    if RepairEvent then RepairEvent:FireServer(point, true) end
                    ok = waitRepairing(point, 0.5)
                end
                hrp.Anchored = false
                task.wait(0.05)
            end
            pcall(function() hrp.Anchored = false; hrp.CFrame = startCFrame end)
            local lastPoint = targetPoints[#targetPoints]
            if lastPoint and RepairEvent then
                task.wait(0.1)
                RepairEvent:FireServer(lastPoint, false)
            end
        end
    end)
end

local function destroyBypassButton()
    bypassGuardianActive = false
    disconnectDragConns()
    if bypassButtonGui then bypassButtonGui:Destroy(); bypassButtonGui = nil end
    bypassButton = nil
    if bypassButtonCheck then bypassButtonCheck:Disconnect(); bypassButtonCheck = nil end
end

local function startBypassButtonGuardian()
    if bypassGuardianActive then return end
    bypassGuardianActive = true
    task.spawn(function()
        while bypassGuardianActive and VD.SURV_GenBoost and not VD.Destroyed do
            if not (bypassButtonGui and bypassButtonGui.Parent) then pcall(createBypassButton) end
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
--  MAP CACHE & TELEPORT
-- ============================================================
local IYAN_Cache = {
    Generators = {}, Gates = {}, Hooks = {}, Pallets = {}, Windows = {},
    ClosestHook = nil, ExitPos = nil, ExitPart = nil
}

local originalCanCollide = {}

local function IYAN_ScanMap()
    local map = Workspace:FindFirstChild("Map")
    if not map then
        IYAN_Cache = { Generators = {}, Gates = {}, Hooks = {}, Pallets = {}, Windows = {}, ClosestHook = nil, ExitPos = nil, ExitPart = nil }
        return
    end
    local newGens, newGates, newHooks, newPallets, newWindows = {}, {}, {}, {}, {}
    local exitPos, exitPart = nil, nil

    if map:FindFirstChild("churchbell") then
        exitPart = map:FindFirstChild("churchbell")
        if exitPart:IsA("Model") then exitPart = exitPart.PrimaryPart or exitPart:FindFirstChildWhichIsA("BasePart") end
        if exitPart then exitPos = exitPart.Position else exitPos = Vector3.new(760.98, -20.14, -78.48) end
    end

    local finish = map:FindFirstChild("Finishline") or map:FindFirstChild("FinishLine") or map:FindFirstChild("Fininshline")
    if finish then
        local fp = finish:IsA("BasePart") and finish or (finish:IsA("Model") and finish:FindFirstChildWhichIsA("BasePart"))
        if fp then exitPos = fp.Position; exitPart = fp end
    end

    for _, obj in ipairs(map:GetDescendants()) do
        if obj:IsA("Model") then
            local part = obj:FindFirstChild("HitBox", true) or obj:FindFirstChild("GeneratorPoint", true) or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
            if part then
                local n = obj.Name
                if n == "Generator" then table.insert(newGens, { model = obj, part = part })
                elseif n == "Gate" or n == "ExitGate" or obj:FindFirstChild("ExitLever") then table.insert(newGates, { model = obj, part = part })
                elseif n == "Hook" then table.insert(newHooks, { model = obj, part = part })
                elseif n == "Palletwrong" or n:lower():find("pallet") then table.insert(newPallets, { model = obj, part = part })
                elseif n == "Window" then table.insert(newWindows, { model = obj, part = part })
                end
            end
        elseif obj:IsA("BasePart") then
            if not exitPos and obj.Name:lower():find("finish") then exitPos = obj.Position; exitPart = obj end
            if obj.Name == "VaultTrigger" then table.insert(newWindows, { model = obj.Parent, part = obj }) end
            if obj.Name == "VaultPoint" and obj.Parent and obj.Parent.Name == "VaultTrigger" then table.insert(newWindows, { model = obj.Parent, part = obj }) end
            if obj.Name == "PalletPoint" or obj.Name == "PalletPointSlide" then table.insert(newPallets, { model = obj.Parent, part = obj }) end
        end
    end

    IYAN_Cache.Generators = newGens
    IYAN_Cache.Gates = newGates
    IYAN_Cache.Hooks = newHooks
    IYAN_Cache.Pallets = newPallets
    IYAN_Cache.Windows = newWindows
    IYAN_Cache.ExitPos = exitPos
    IYAN_Cache.ExitPart = exitPart

    local root = Root
    if root and #IYAN_Cache.Hooks > 0 then
        local closest, closestDist = nil, math.huge
        for _, hook in ipairs(IYAN_Cache.Hooks) do
            if hook.part then
                local d = (hook.part.Position - root.Position).Magnitude
                if d < closestDist then closestDist = d; closest = hook end
            end
        end
        IYAN_Cache.ClosestHook = closest
    end
end

function IYAN_TeleportToGenerator(index)
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

function IYAN_TeleportToGate()
    if not IYAN_Cache or not IYAN_Cache.Gates or #IYAN_Cache.Gates == 0 then return false end
    local closest, closestDist = nil, math.huge
    for _, gate in ipairs(IYAN_Cache.Gates) do
        local dist = (Root and (gate.part.Position - Root.Position).Magnitude) or math.huge
        if dist < closestDist then closestDist = dist; closest = gate end
    end
    if not closest then return false end
    return IYAN_TeleportToPosition(closest.part.Position)
end

function IYAN_TeleportToHook()
    if not IYAN_Cache or not IYAN_Cache.ClosestHook then return false end
    return IYAN_TeleportToPosition(IYAN_Cache.ClosestHook.part.Position)
end

function IYAN_TeleportToPosition(pos)
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
                    pcall(function() part.CanCollide = (originalCanCollide[part] ~= nil) and originalCanCollide[part] or true end)
                end
            end
            root.Anchored = false
        end
        originalCanCollide = {}
    end)
    return true
end

local function IYAN_ApplyCustomMasked(maskName)
    local selectedMask = maskName or VD.KILLER_CustomMasked or "Richard"
    if type(selectedMask) == "table" then selectedMask = selectedMask[1] end
    if type(selectedMask) ~= "string" or selectedMask == "" then selectedMask = "Richard" end
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
--  KILLER AUTO FEATURES
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
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        local a = r and r:FindFirstChild("Attacks")
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
            if d < minDist then minDist = d; nearest = p end
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
function IYAN_AutoBreakGene()
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
                    if d < minDist then minDist = d; nearest = p end
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
function IYAN_BlockAllVaults()
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
                    if part:IsA("BasePart") then pcall(function() vaultEvent:FireServer(part, true) end) end
                end
            end
        else
            for _, win in ipairs(IYAN_Cache.Windows or {}) do
                local window = win.model
                if window and window.Parent then
                    for _, child in ipairs(window:GetDescendants()) do
                        if child:IsA("BasePart") then pcall(function() vaultEvent:FireServer(child, true) end) end
                    end
                end
            end
        end
    end)
end

-- Flee Killer
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

-- Heartbeat Loop
RunService.Heartbeat:Connect(function()
    if VD.Destroyed then return end
    pcall(IYAN_AutoAttack)
    pcall(IYAN_DestroyAllPallets)
    pcall(IYAN_AutoBreakGene)
    pcall(IYAN_BlockAllVaults)
    pcall(IYAN_DoubleTap)
end)

-- Map Scan Loop
task.spawn(function()
    while not VD.Destroyed do
        pcall(IYAN_ScanMap)
        task.wait(0.5)
    end
end)

print("[NO MERCY] Game systems loaded")


-- ============================================================
--  DRAWING ESP (PC Only)
-- ============================================================
local DrawingESP = { cache = {}, velocityData = {} }
local Perf = { DrawingESPInterval = 0.1, NextDrawingESP = 0 }

local function DrawingESP_create()
    local box = SafeDrawing("Square")
    if box then box.Filled = false; box.Thickness = 1; box.Visible = false end
    local healthBg = SafeDrawing("Square")
    if healthBg then healthBg.Filled = true; healthBg.Color = Color3.fromRGB(25, 25, 25); healthBg.Visible = false end
    local healthBar = SafeDrawing("Square")
    if healthBar then healthBar.Filled = true; healthBar.Visible = false end
    local name = SafeDrawing("Text")
    if name then name.Size = 14; name.Font = Drawing.Fonts.UI; name.Center = true; name.Outline = true; name.Visible = false end
    local dist = SafeDrawing("Text")
    if dist then dist.Size = 12; dist.Font = Drawing.Fonts.Monospace; dist.Center = true; dist.Outline = true; dist.Color = Color3.fromRGB(180, 180, 180); dist.Visible = false end
    local skel = {}
    for i = 1, 7 do
        local l = SafeDrawing("Line")
        if l then l.Thickness = 1; l.Visible = false end
        skel[i] = l
    end
    local offscreen = SafeDrawing("Triangle")
    if offscreen then offscreen.Filled = true; offscreen.Visible = false end
    local velLine = SafeDrawing("Line")
    if velLine then velLine.Thickness = 2; velLine.Color = Color3.fromRGB(0, 255, 255); velLine.Visible = false end
    local velArrow = SafeDrawing("Triangle")
    if velArrow then velArrow.Filled = true; velArrow.Color = Color3.fromRGB(0, 255, 255); velArrow.Visible = false end
    return { Box = box, HealthBg = healthBg, HealthBar = healthBar, Name = name, Dist = dist, Skel = skel, Offscreen = offscreen, VelLine = velLine, VelArrow = velArrow }
end

local function DrawingESP_hideAll(esp)
    if not esp then return end
    if esp.Box then esp.Box.Visible = false end
    if esp.HealthBg then esp.HealthBg.Visible = false end
    if esp.HealthBar then esp.HealthBar.Visible = false end
    if esp.Name then esp.Name.Visible = false end
    if esp.Dist then esp.Dist.Visible = false end
    if esp.Offscreen then esp.Offscreen.Visible = false end
    if esp.VelLine then esp.VelLine.Visible = false end
    if esp.VelArrow then esp.VelArrow.Visible = false end
    for _, l in ipairs(esp.Skel) do if l then l.Visible = false end end
end

local function DrawingESP_render(esp, player, char, cam, screenSize, screenCenter)
    if not esp or not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not head then DrawingESP_hideAll(esp); return end
    local myRoot = Root
    local dist = myRoot and (root.Position - myRoot.Position).Magnitude or 0
    if dist > VD.MaxDistance then DrawingESP_hideAll(esp); return end
    local isKillerPlayer = IsKiller(player)
    local visible = true
    local col = isKillerPlayer and Color3.fromRGB(255, 120, 120) or Color3.fromRGB(120, 255, 170)
    local skelCol = Color3.fromRGB(150, 255, 150)
    local headPos = head.Position + Vector3.new(0, 0.5, 0)
    local feetPos = root.Position - Vector3.new(0, 3, 0)
    local rs = cam:WorldToViewportPoint(root.Position)
    local hs = cam:WorldToViewportPoint(headPos)
    local fs = cam:WorldToViewportPoint(feetPos)
    local onScreen = rs.Z > 0 and rs.X > 0 and rs.X < screenSize.X and rs.Y > 0 and rs.Y < screenSize.Y
    if not onScreen then
        DrawingESP_hideAll(esp)
        if VD.ESP_Offscreen and not VD.ESP_LowPerformance and esp.Offscreen then
            local dx = rs.X - screenCenter.X; local dy = rs.Y - screenCenter.Y
            local angle = math.atan2(dy, dx)
            local edge = 50
            local aX = math.clamp(screenCenter.X + math.cos(angle) * (screenSize.X / 2 - edge), edge, screenSize.X - edge)
            local aY = math.clamp(screenCenter.Y + math.sin(angle) * (screenSize.Y / 2 - edge), edge, screenSize.Y - edge)
            local fwd = Vector2.new(math.cos(angle), math.sin(angle))
            local right = Vector2.new(-fwd.Y, fwd.X)
            local pos = Vector2.new(aX, aY); local sz = 12
            esp.Offscreen.PointA = pos + fwd * sz
            esp.Offscreen.PointB = pos - fwd * sz / 2 - right * sz / 2
            esp.Offscreen.PointC = pos - fwd * sz / 2 + right * sz / 2
            esp.Offscreen.Color = col; esp.Offscreen.Visible = true
        end
        return
    end
    if esp.Offscreen then esp.Offscreen.Visible = false end
    local boxTop = hs.Y; local boxBottom = fs.Y
    local boxHeight = math.abs(boxBottom - boxTop)
    local boxWidth = boxHeight * 0.6
    local cx = rs.X
    if esp.Box then
        esp.Box.Position = Vector2.new(cx - boxWidth / 2, boxTop)
        esp.Box.Size = Vector2.new(boxWidth, boxHeight)
        esp.Box.Color = col; esp.Box.Visible = true
    end
    if hum and hum.MaxHealth > 0 and esp.HealthBg and esp.HealthBar then
        local healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local barWidth = boxWidth * 0.8; local barHeight = 4
        local barX = cx - barWidth / 2; local barY = boxBottom + 2
        esp.HealthBg.Position = Vector2.new(barX, barY)
        esp.HealthBg.Size = Vector2.new(barWidth, barHeight); esp.HealthBg.Visible = true
        esp.HealthBar.Position = Vector2.new(barX, barY)
        esp.HealthBar.Size = Vector2.new(barWidth * healthPct, barHeight)
        esp.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPct), 255 * healthPct, 0)
        esp.HealthBar.Visible = true
    else
        if esp.HealthBg then esp.HealthBg.Visible = false end
        if esp.HealthBar then esp.HealthBar.Visible = false end
    end
    if esp.Name then
        esp.Name.Text = player.Name
        esp.Name.Position = Vector2.new(cx, boxTop - 18)
        esp.Name.Color = col; esp.Name.Visible = true
    end
    if esp.Dist then
        esp.Dist.Text = math.floor(dist) .. "m"
        esp.Dist.Position = Vector2.new(cx, boxBottom + 2 + (hum and hum.MaxHealth > 0 and 6 or 2))
        esp.Dist.Visible = true
    end
    if VD.ESP_Skeleton and not VD.ESP_LowPerformance and hum then
        local bones = (char:FindFirstChild("Torso") and {
            {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"UpperTorso", "RightUpperArm"},
            {"LowerTorso", "LeftUpperLeg"}, {"LowerTorso", "RightUpperLeg"}, {"LeftUpperArm", "LeftLowerArm"}, {"RightUpperArm", "RightLowerArm"},
            {"LeftUpperLeg", "LeftLowerLeg"}, {"RightUpperLeg", "RightLowerLeg"},
        }) or { {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"} }
        local maxLines = math.min(#bones, #esp.Skel)
        for i = 1, maxLines do
            local b = bones[i]
            if esp.Skel[i] then
                local p1 = char:FindFirstChild(b[1]); local p2 = char:FindFirstChild(b[2])
                if p1 and p2 then
                    local s1 = cam:WorldToViewportPoint(p1.Position); local s2 = cam:WorldToViewportPoint(p2.Position)
                    if s1.Z > 0 and s2.Z > 0 then
                        esp.Skel[i].From = Vector2.new(s1.X, s1.Y); esp.Skel[i].To = Vector2.new(s2.X, s2.Y)
                        esp.Skel[i].Color = skelCol; esp.Skel[i].Visible = true
                    else esp.Skel[i].Visible = false end
                else esp.Skel[i].Visible = false end
            end
        end
        for i = maxLines + 1, #esp.Skel do if esp.Skel[i] then esp.Skel[i].Visible = false end end
    else
        for _, l in ipairs(esp.Skel) do if l then l.Visible = false end end
    end
    if VD.ESP_Velocity and not VD.ESP_LowPerformance then
        local vd = DrawingESP.velocityData[player]
        if not vd then vd = { pos = root.Position, vel = Vector3.zero, time = tick() }; DrawingESP.velocityData[player] = vd end
        local now = tick(); local dt = now - vd.time
        if dt > 0.03 then
            local rawVel = (root.Position - vd.pos) / dt
            vd.vel = vd.vel * 0.7 + rawVel * 0.3
            vd.pos = root.Position; vd.time = now
        end
        local velFlat = Vector3.new(vd.vel.X, 0, vd.vel.Z)
        local velMag = velFlat.Magnitude
        if velMag > 2 then
            local futurePos = root.Position + velFlat.Unit * math.clamp(velMag * 0.4, 5, 20)
            local futureScreen = cam:WorldToViewportPoint(futurePos)
            if futureScreen.Z > 0 then
                if esp.VelLine then
                    esp.VelLine.From = Vector2.new(rs.X, rs.Y); esp.VelLine.To = Vector2.new(futureScreen.X, futureScreen.Y); esp.VelLine.Visible = true
                end
                local dx = futureScreen.X - rs.X; local dy = futureScreen.Y - rs.Y; local len = math.sqrt(dx * dx + dy * dy)
                if len > 5 and esp.VelArrow then
                    local fx, fy = dx / len, dy / len
                    esp.VelArrow.PointA = Vector2.new(futureScreen.X, futureScreen.Y)
                    esp.VelArrow.PointB = Vector2.new(futureScreen.X - fx * 10 + fy * 5, futureScreen.Y - fy * 10 - fx * 5)
                    esp.VelArrow.PointC = Vector2.new(futureScreen.X - fx * 10 - fy * 5, futureScreen.Y - fy * 10 + fx * 5)
                    esp.VelArrow.Visible = true
                elseif esp.VelArrow then esp.VelArrow.Visible = false end
            else
                if esp.VelLine then esp.VelLine.Visible = false end
                if esp.VelArrow then esp.VelArrow.Visible = false end
            end
        else
            if esp.VelLine then esp.VelLine.Visible = false end
            if esp.VelArrow then esp.VelArrow.Visible = false end
        end
    else
        if esp.VelLine then esp.VelLine.Visible = false end
        if esp.VelArrow then esp.VelArrow.Visible = false end
    end
end

local function OnRenderStep()
    if VD.Destroyed then
        if DrawingAvailable then
            for _, esp in pairs(DrawingESP.cache) do
                if esp then
                    SafeRemove(esp.Box); SafeRemove(esp.HealthBg); SafeRemove(esp.HealthBar)
                    SafeRemove(esp.Name); SafeRemove(esp.Dist); SafeRemove(esp.Offscreen)
                    SafeRemove(esp.VelLine); SafeRemove(esp.VelArrow)
                    for _, l in ipairs(esp.Skel) do SafeRemove(l) end
                end
            end
            DrawingESP.cache = {}
        end
        return
    end
    Camera = Workspace.CurrentCamera or Camera
    local cam = Camera
    if not cam then return end
    local screenSize = cam.ViewportSize
    local screenCenter = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    local now = tick()
    local canUpdateESP = now >= Perf.NextDrawingESP
    if canUpdateESP then Perf.NextDrawingESP = now + Perf.DrawingESPInterval end
    if DrawingAvailable then
        if VD.DRAWING_ESP then
            if canUpdateESP then
                local validPlayers = {}
                for _, p in ipairs(Players:GetPlayers()) do validPlayers[p] = true end
                for player, esp in pairs(DrawingESP.cache) do
                    if not validPlayers[player] then
                        if esp then
                            SafeRemove(esp.Box); SafeRemove(esp.HealthBg); SafeRemove(esp.HealthBar)
                            SafeRemove(esp.Name); SafeRemove(esp.Dist); SafeRemove(esp.Offscreen)
                            SafeRemove(esp.VelLine); SafeRemove(esp.VelArrow)
                            for _, l in ipairs(esp.Skel) do SafeRemove(l) end
                        end
                        DrawingESP.cache[player] = nil; DrawingESP.velocityData[player] = nil
                    end
                end
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        if not DrawingESP.cache[player] then DrawingESP.cache[player] = DrawingESP_create() end
                        DrawingESP_render(DrawingESP.cache[player], player, player.Character, cam, screenSize, screenCenter)
                    end
                end
            end
        else
            for _, esp in pairs(DrawingESP.cache) do
                if esp then
                    SafeRemove(esp.Box); SafeRemove(esp.HealthBg); SafeRemove(esp.HealthBar)
                    SafeRemove(esp.Name); SafeRemove(esp.Dist); SafeRemove(esp.Offscreen)
                    SafeRemove(esp.VelLine); SafeRemove(esp.VelArrow)
                    for _, l in ipairs(esp.Skel) do SafeRemove(l) end
                end
            end
            DrawingESP.cache = {}
        end
    end
end

if DrawingAvailable then
    RunService.RenderStepped:Connect(OnRenderStep)
end

-- ============================================================
--  AUTO DROP PALLET
-- ============================================================
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
                    if dist < triggerDist then killerRoot = kr; break end
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
            if d < bestDist then bestDist = d; bestPallet = palModel end
        end
        if bestPallet then
            local fireTarget = bestPallet:FindFirstChild("PalletPointSlide") or bestPallet:FindFirstChild("PalletPoint")
            if fireTarget then
                pcall(function() dropEvent:FireServer(fireTarget) end)
                _usedPallets[bestPallet] = true
                _lastPalletDrop = tick()
                task.delay(3, function() _usedPallets[bestPallet] = nil end)
            end
        end
    end)
end)

-- ============================================================
--  AUTO VAULT & AUTO PALLET SLIDE
-- ============================================================
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
                    if part.Name == "VaultPoint" and part.Parent and part.Parent.Name == "VaultTrigger" then rootWindow = part.Parent.Parent
                    elseif part.Name == "VaultTrigger" and part.Parent then rootWindow = part.Parent end
                    if rootWindow then
                        windowGroups[rootWindow] = windowGroups[rootWindow] or {}
                        local exists = false
                        for _, p in ipairs(windowGroups[rootWindow]) do if p == part then exists = true; break end end
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
                for _, child in ipairs(rootWindow:GetChildren()) do if child.Name == "VaultTrigger" then table.insert(allVTs, child) end end
                if #allVTs == 0 then continue end
                local nearestVT, nearestVTDist = nil, math.huge
                for _, vt in ipairs(allVTs) do
                    local pos = getVTPosition(vt)
                    if pos then
                        local d = (myRoot.Position - pos).Magnitude
                        if d < nearestVTDist then nearestVTDist = d; nearestVT = vt end
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
                if d < bestDist then bestDist = d; bestPart = part end
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
                    if d < bestDist then bestDist = d; bestPart = slide end
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
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
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

print("[NO MERCY] Subsystems loaded")


-- ============================================================
--  ORION UI TABS
-- ============================================================
local InfoTab     = Window:MakeTab({ Name = "Info", Icon = ICON.Info, PremiumOnly = false })
local AimbotTab   = Window:MakeTab({ Name = "Aimbot", Icon = ICON.Crosshair, PremiumOnly = false })
local ParryTab    = Window:MakeTab({ Name = "Parry", Icon = ICON.Swords, PremiumOnly = false })
local TeleportTab = Window:MakeTab({ Name = "Teleport", Icon = ICON.Globe, PremiumOnly = false })
local KillerTab   = Window:MakeTab({ Name = "Killer", Icon = ICON.Axe, PremiumOnly = false })
local SurvivorTab = Window:MakeTab({ Name = "Survivor", Icon = ICON.User, PremiumOnly = false })
local PlayerTab   = Window:MakeTab({ Name = "Player", Icon = ICON.User, PremiumOnly = false })
local VisualTab   = Window:MakeTab({ Name = "Visual", Icon = ICON.Eye, PremiumOnly = false })
local SpeedTab    = Window:MakeTab({ Name = "Speed", Icon = ICON.Zap, PremiumOnly = false })
local SettingsTab = Window:MakeTab({ Name = "Settings", Icon = ICON.Settings, PremiumOnly = false })

-- ============================================================
--  INFO TAB
-- ============================================================
local InfoSec = InfoTab:AddSection({ Name = "Tentang" })
InfoSec:AddLabel("NO MERCY — Violence District")
InfoSec:AddLabel("Game: Bola Pedang (Blade Ball)")
InfoSec:AddButton({
    Name = "Copy Link Discord",
    Callback = function()
        if setclipboard then setclipboard("https://discord.gg/pbg6g79Hp") end
        VD_Notify("NO MERCY", "Link Discord di-copy!", 3)
    end,
})

task.spawn(function()
    task.wait(0.3)
    local main = FindMainWindow()
    if not main then return end
    for _, v in ipairs(main:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text == "Tentang" then
            local container = v.Parent.Parent
            if container and container:IsA("ScrollingFrame") then
                for _, child in ipairs(container:GetChildren()) do if child.Name == "AbsoluteTopBanner" then child:Destroy() end end
                local bannerFrame = Instance.new("Frame")
                bannerFrame.Name = "AbsoluteTopBanner"
                bannerFrame.Size = UDim2.new(1, -10, 0, 115)
                bannerFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
                bannerFrame.BorderSizePixel = 0
                bannerFrame.LayoutOrder = -999
                bannerFrame.Parent = container
                local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 8); corner.Parent = bannerFrame
                local bannerImg = Instance.new("ImageLabel")
                bannerImg.Size = UDim2.new(1, 0, 1, 0)
                bannerImg.Image = ICON.Banner
                bannerImg.BackgroundTransparency = 1
                bannerImg.ScaleType = Enum.ScaleType.Fit
                bannerImg.Parent = bannerFrame
                local imgCorner = Instance.new("UICorner"); imgCorner.CornerRadius = UDim.new(0, 8); imgCorner.Parent = bannerImg
                break
            end
        end
    end
end)

-- ============================================================
--  AIMBOT TAB
-- ============================================================
local AimMain = AimbotTab:AddSection({ Name = "Main" })
AimMain:AddToggle({
    Name = "Enable Aimbot", Default = VD.AIM_Enabled or false,
    Callback = function(v) VD.AIM_Enabled = v end,
})
AimMain:AddToggle({
    Name = "Silent Aim Veil", Default = VD.SPEAR_Aimbot or false,
    Callback = function(v) VD.SPEAR_Aimbot = v; VeilConfig.Enabled = v end,
})

local AimTarget = AimbotTab:AddSection({ Name = "Target" })
AimTarget:AddDropdown({
    Name = "ToF Target Mode", Default = VD.AUTO_ToFTargetMode or "Killer",
    Options = { "Killer", "Survivor", "SCP" },
    Callback = function(v) VD.AUTO_ToFTargetMode = v end,
})
AimTarget:AddDropdown({
    Name = "ToF Aim Part", Default = VD.AUTO_ToFAimPart or "HumanoidRootPart",
    Options = { "HumanoidRootPart", "Head", "Torso" },
    Callback = function(v) VD.AUTO_ToFAimPart = v end,
})

local AimFOV = AimbotTab:AddSection({ Name = "FOV" })
AimFOV:AddSlider({
    Name = "FOV Radius", Min = 50, Max = 500, Default = VeilConfig.FOV or 150, Increment = 10,
    Callback = function(v) VeilConfig.FOV = v end,
})
AimFOV:AddToggle({
    Name = "Show FOV Circle", Default = VeilConfig.ShowFOV,
    Callback = function(v) VeilConfig.ShowFOV = v end,
})

local AimPred = AimbotTab:AddSection({ Name = "Prediction" })
AimPred:AddToggle({
    Name = "ToF Prediction", Default = VD.AUTO_ToFPredict,
    Callback = function(v) VD.AUTO_ToFPredict = v end,
})
AimPred:AddSlider({
    Name = "ToF Bullet Speed", Min = 50, Max = 1000, Default = VD.AUTO_ToFBulletSpeed or 200, Increment = 10,
    Callback = function(v) VD.AUTO_ToFBulletSpeed = v end,
})
AimPred:AddSlider({
    Name = "Spear Speed", Min = 50, Max = 300, Default = VeilConfig.SpearSpeed or 165, Increment = 5,
    Callback = function(v) VeilConfig.SpearSpeed = v end,
})
AimPred:AddSlider({
    Name = "Gravity", Min = 0, Max = 300, Default = VeilConfig.Gravity or math.floor(workspace.Gravity * 0.5), Increment = 5,
    Callback = function(v) VeilConfig.Gravity = v end,
})
AimPred:AddSlider({
    Name = "Horizontal Vector", Min = 0, Max = 10, Default = VeilConfig.HorizontalPredictFactor or 2.8, Increment = 0.1,
    Callback = function(v) VeilConfig.HorizontalPredictFactor = v end,
})
AimPred:AddSlider({
    Name = "Aim Strictness (Dot)", Min = -1, Max = 1, Default = VD.AUTO_ToFDotThreshold or 0.5, Increment = 0.05,
    Callback = function(v) VD.AUTO_ToFDotThreshold = v end,
})
AimPred:AddSlider({
    Name = "ToF Aim Range (studs)", Min = 10, Max = 300, Default = VD.AUTO_ToFAimRange or 90, Increment = 5,
    Callback = function(v) VD.AUTO_ToFAimRange = v end,
})

-- ============================================================
--  PARRY TAB
-- ============================================================
local ParryMain = ParryTab:AddSection({ Name = "Auto Parry" })
ParryMain:AddToggle({
    Name = "Enable Auto Parry", Default = VD.SURV_AutoParry,
    Callback = function(v)
        VD.SURV_AutoParry = v
        if not v then VD_ParryRange.Transparency = 1; ResetCooldown() end
    end,
})
ParryMain:AddDropdown({
    Name = "Parry Mode", Default = VD.SURV_ParryMode or "Legit",
    Options = { "Legit", "Aggressive" },
    Callback = function(v) VD.SURV_ParryMode = v end,
})
ParryMain:AddDropdown({
    Name = "Parry Animation", Default = "Default",
    Options = { "Default", "Shield", "Robot", "Katana", "Fish", "Watcher" },
    Callback = function(v)
        local animMap = {
            Default = "rbxassetid://109133187196613", Shield = "rbxassetid://75939529748815",
            Robot = "rbxassetid://126894569253341", Katana = "rbxassetid://127096285501517",
            Fish = "rbxassetid://123307242865945", Watcher = "rbxassetid://81793464499285",
        }
        VD.SURV_ParryAnimId = animMap[v] or animMap.Default
    end,
})
ParryMain:AddSlider({
    Name = "Parry Range", Min = 2, Max = 20, Default = VD.SURV_ParryRange or 12, Increment = 0.5,
    Callback = function(v)
        VD.SURV_ParryRange = v
        VD_ParryRange.Radius = v
        VD_ParryRange.InnerRadius = math.max(0.1, v - 0.15)
    end,
})
ParryMain:AddToggle({
    Name = "Show Parry Range Circle", Default = VD.SURV_ShowParryCircle,
    Callback = function(v)
        VD.SURV_ShowParryCircle = v
        if not v then VD_ParryRange.Transparency = 1 end
    end,
})

-- ============================================================
--  TELEPORT TAB
-- ============================================================
local TelePlayer = TeleportTab:AddSection({ Name = "Player" })
local tpPlayerNames = {}
local function refreshTPNames()
    tpPlayerNames = {}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(tpPlayerNames, p.Name) end end
    table.sort(tpPlayerNames)
end
refreshTPNames()

local tpDropdown = TelePlayer:AddDropdown({
    Name = "Select Player", Default = "", Options = tpPlayerNames,
    Callback = function(v) VD.TP_TargetPlayer = v end,
})
TelePlayer:AddButton({
    Name = "Refresh Players",
    Callback = function()
        refreshTPNames()
        pcall(function() tpDropdown:Refresh(tpPlayerNames) end)
    end,
})
TelePlayer:AddButton({
    Name = "Teleport to Player",
    Callback = function()
        pcall(function()
            local targetName = VD.TP_TargetPlayer
            if not targetName or targetName == "" then return end
            local player = Players:FindFirstChild(targetName)
            local root = Root
            local targetRoot = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root and targetRoot then root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3) end
        end)
    end,
})

local TeleObj = TeleportTab:AddSection({ Name = "Objectives" })
TeleObj:AddButton({
    Name = "TP to Generator (Nearest)",
    Callback = function() pcall(function() IYAN_TeleportToGenerator(1) end) end,
})
TeleObj:AddButton({
    Name = "TP to Gate",
    Callback = function() pcall(IYAN_TeleportToGate) end,
})
TeleObj:AddButton({
    Name = "TP to Hook",
    Callback = function() pcall(IYAN_TeleportToHook) end,
})

-- ============================================================
--  KILLER TAB
-- ============================================================
local KillerGen = KillerTab:AddSection({ Name = "General" })
KillerGen:AddToggle({
    Name = "Auto Attack", Default = VD.AUTO_Attack,
    Callback = function(v) VD.AUTO_Attack = v end,
})
KillerGen:AddSlider({
    Name = "Attack Range", Min = 5, Max = 20, Default = VD.AUTO_AttackRange or 12, Increment = 1,
    Callback = function(v) VD.AUTO_AttackRange = v end,
})
KillerGen:AddToggle({
    Name = "Double Tap", Default = VD.KILLER_DoubleTap,
    Callback = function(v) VD.KILLER_DoubleTap = v end,
})
KillerGen:AddToggle({
    Name = "Auto Kick Pallet", Default = VD.KILLER_DestroyPallets,
    Callback = function(v) VD.KILLER_DestroyPallets = v end,
})
KillerGen:AddToggle({
    Name = "Auto Kick Generator", Default = VD.KILLER_AutoBreakGene,
    Callback = function(v) VD.KILLER_AutoBreakGene = v end,
})
KillerGen:AddToggle({
    Name = "Block All Vaults", Default = VD.KILLER_BlockVaults,
    Callback = function(v) VD.KILLER_BlockVaults = v end,
})
KillerGen:AddToggle({
    Name = "Anti Blind (Flashlight)", Default = VD.KILLER_AntiBlind,
    Callback = function(v) VD.KILLER_AntiBlind = v end,
})

local KillerSilent = KillerTab:AddSection({ Name = "Silent Aim" })
KillerSilent:AddToggle({
    Name = "Silent Aim Veil", Default = VeilConfig.Enabled,
    Callback = function(v) VeilConfig.Enabled = v; VD.SPEAR_Aimbot = v end,
})
KillerSilent:AddToggle({
    Name = "Show FOV", Default = VeilConfig.ShowFOV,
    Callback = function(v) VeilConfig.ShowFOV = v end,
})
KillerSilent:AddSlider({
    Name = "FOV Radius", Min = 50, Max = 500, Default = VeilConfig.FOV or 150, Increment = 10,
    Callback = function(v) VeilConfig.FOV = v end,
})
KillerSilent:AddToggle({
    Name = "Auto Predict", Default = VeilConfig.AutoPredict,
    Callback = function(v) VeilConfig.AutoPredict = v end,
})
KillerSilent:AddSlider({
    Name = "Spear Speed", Min = 50, Max = 300, Default = VeilConfig.SpearSpeed or 165, Increment = 5,
    Callback = function(v) VeilConfig.SpearSpeed = v end,
})
KillerSilent:AddSlider({
    Name = "Gravity", Min = 0, Max = 300, Default = VeilConfig.Gravity or math.floor(workspace.Gravity * 0.5), Increment = 5,
    Callback = function(v) VeilConfig.Gravity = v end,
})
KillerSilent:AddSlider({
    Name = "Horizontal Prediction", Min = 0, Max = 10, Default = VeilConfig.HorizontalPredictFactor or 2.8, Increment = 0.1,
    Callback = function(v) VeilConfig.HorizontalPredictFactor = v end,
})
KillerSilent:AddDropdown({
    Name = "Target Part", Default = VeilConfig.TargetPart or "Torso",
    Options = { "Torso", "Head", "Root" },
    Callback = function(v) VeilConfig.TargetPart = v end,
})

local KillerCust = KillerTab:AddSection({ Name = "Customization" })
local customMaskedMasks = {"Richard", "Tony", "Brandon", "Jake", "Richter", "Graham", "Alex"}
KillerCust:AddDropdown({
    Name = "Custom Masked", Default = VD.KILLER_CustomMasked or "Richard",
    Options = customMaskedMasks,
    Callback = function(v) VD.KILLER_CustomMasked = v end,
})
KillerCust:AddButton({
    Name = "Apply",
    Callback = function() pcall(IYAN_ApplyCustomMasked, VD.KILLER_CustomMasked) end,
})
KillerCust:AddButton({
    Name = "Random",
    Callback = function()
        local mask = customMaskedMasks[math.random(1, #customMaskedMasks)]
        VD.KILLER_CustomMasked = mask
        pcall(IYAN_ApplyCustomMasked, mask)
    end,
})

-- ============================================================
--  SURVIVOR TAB — GENERATOR ONLY
-- ============================================================
local GenSec = SurvivorTab:AddSection({ Name = "Generator" })
GenSec:AddToggle({
    Name = "Gen Boost (BEST)", Default = VD.SURV_GenBoost,
    Callback = function(v)
        VD.SURV_GenBoost = v
        if v then startGenBoost() else stopGenBoost() end
    end,
})
GenSec:AddToggle({
    Name = "Draggable Mode (Bypass Button)", Default = VD.SURV_DraggableGenBypass,
    Callback = function(v) VD.SURV_DraggableGenBypass = v end,
})
GenSec:AddToggle({
    Name = "Auto Skillcheck", Default = VD.AutoSkillcheck,
    Callback = function(v)
        VD.AutoSkillcheck = v
        if not v then
            if AutoSkill.InstantRotationConnection then AutoSkill.InstantRotationConnection:Disconnect(); AutoSkill.InstantRotationConnection = nil end
            AutoSkill.InstantHasClicked = false; AutoSkill.WasActive = false; AutoSkill.PerfectWasActive = false
        end
    end,
})
GenSec:AddDropdown({
    Name = "Skillcheck Mode", Default = VD.AutoSkillcheckMode or "Normal",
    Options = { "Normal", "Perfect", "Instant" },
    Callback = function(v) VD.AutoSkillcheckMode = v end,
})
GenSec:AddToggle({
    Name = "Auto Drop Pallet", Default = VD.SURV_AutoDropPallet,
    Callback = function(v)
        VD.SURV_AutoDropPallet = v
        VD_Notify("Auto Drop Pallet", v and "Enabled" or "Disabled", 2)
    end,
})
GenSec:AddSlider({
    Name = "Pallet Trigger Range", Min = 5, Max = 50, Default = VD.SURV_AutoDropPalletDist or 20, Increment = 1,
    Callback = function(v) VD.SURV_AutoDropPalletDist = v end,
})
GenSec:AddDropdown({
    Name = "Pallet Mode", Default = VD.SURV_AutoDropPalletMode or "Aggressive",
    Options = { "Aggressive", "Safe" },
    Callback = function(v) VD.SURV_AutoDropPalletMode = v end,
})
GenSec:AddToggle({
    Name = "Auto Vault", Default = VD.SURV_AutoVault,
    Callback = function(v) VD.SURV_AutoVault = v end,
})
GenSec:AddToggle({
    Name = "Auto Pallet (Slide)", Default = VD.SURV_AutoPalletSlide,
    Callback = function(v) VD.SURV_AutoPalletSlide = v end,
})
GenSec:AddToggle({
    Name = "Flee Killer", Default = VD.SURV_FleeKiller,
    Callback = function(v) VD.SURV_FleeKiller = v end,
})
GenSec:AddSlider({
    Name = "Flee Distance", Min = 15, Max = 80, Default = VD.SURV_FleeDistance or 40, Increment = 1,
    Callback = function(v) VD.SURV_FleeDistance = v end,
})
GenSec:AddToggle({
    Name = "Anti Knock", Default = VD.SURV_AntiKnock,
    Callback = function(v)
        VD.SURV_AntiKnock = v
        -- handled by anti-knock connection in player section
    end,
})
GenSec:AddToggle({
    Name = "First Person Camera", Default = VD.SURV_FirstPerson,
    Callback = function(v)
        VD.SURV_FirstPerson = v
        if not v then pcall(RestoreFirstPersonCamera) end
    end,
})

-- ============================================================
--  PLAYER TAB
-- ============================================================
local PlayerTele = PlayerTab:AddSection({ Name = "Teleport" })
local tpDropdown2 = PlayerTele:AddDropdown({
    Name = "Select Player", Default = "", Options = tpPlayerNames,
    Callback = function(v) VD.TP_TargetPlayer = v end,
})
PlayerTele:AddButton({
    Name = "Refresh Players",
    Callback = function()
        refreshTPNames()
        pcall(function() tpDropdown2:Refresh(tpPlayerNames) end)
    end,
})
PlayerTele:AddButton({
    Name = "Teleport to Player",
    Callback = function()
        pcall(function()
            local targetName = VD.TP_TargetPlayer
            if not targetName or targetName == "" then return end
            local player = Players:FindFirstChild(targetName)
            local root = Root
            local targetRoot = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root and targetRoot then root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3) end
        end)
    end,
})
PlayerTele:AddButton({
    Name = "TP to Generator",
    Callback = function() pcall(function() IYAN_TeleportToGenerator(1) end) end,
})
PlayerTele:AddButton({
    Name = "TP to Gate",
    Callback = function() pcall(IYAN_TeleportToGate) end,
})
PlayerTele:AddButton({
    Name = "TP to Hook",
    Callback = function() pcall(IYAN_TeleportToHook) end,
})

local PlayerFling = PlayerTab:AddSection({ Name = "Fling" })
PlayerFling:AddToggle({
    Name = "Enable Fling", Default = VD.FLING_Enabled,
    Callback = function(v) VD.FLING_Enabled = v end,
})
PlayerFling:AddSlider({
    Name = "Fling Strength", Min = 1000, Max = 50000, Default = VD.FLING_Strength or 10000, Increment = 500,
    Callback = function(v) VD.FLING_Strength = v end,
})
PlayerFling:AddButton({
    Name = "Fling Nearest",
    Callback = function() pcall(IYAN_FlingNearest) end,
})
PlayerFling:AddButton({
    Name = "Fling All",
    Callback = function() pcall(IYAN_FlingAll) end,
})

local PlayerFun = PlayerTab:AddSection({ Name = "Fun" })
local spoofLevel, spoofGears, spoofScrews = "0", "0", "0"
PlayerFun:AddTextbox({
    Name = "Set Level", Default = "0", TextDisappear = false,
    Callback = function(v) spoofLevel = v end,
})
PlayerFun:AddTextbox({
    Name = "Set Gears", Default = "0", TextDisappear = false,
    Callback = function(v) spoofGears = v end,
})
PlayerFun:AddTextbox({
    Name = "Set Screws", Default = "0", TextDisappear = false,
    Callback = function(v) spoofScrews = v end,
})
PlayerFun:AddButton({
    Name = "Apply Spoof",
    Callback = function()
        pcall(function()
            LocalPlayer:SetAttribute("Level", tonumber(spoofLevel) or 0)
            LocalPlayer:SetAttribute("Gears", tonumber(spoofGears) or 0)
            LocalPlayer:SetAttribute("Screws", tonumber(spoofScrews) or 0)
        end)
    end,
})

local PlayerStream = PlayerTab:AddSection({ Name = "Streamer" })
local FakeNameConnection = nil
local function enableFakeName(enabled)
    if FakeNameConnection then pcall(function() FakeNameConnection:Disconnect() end); FakeNameConnection = nil end
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end
    local function shouldHide(obj)
        local ok, isText = pcall(function() return obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") end)
        if not ok or not isText then return false end
        local text = ""
        pcall(function() text = tostring(obj.Text or "") end)
        return text == LocalPlayer.Name or text == LocalPlayer.DisplayName or text:find(LocalPlayer.Name, 1, true) ~= nil
    end
    local function process(object)
        if shouldHide(object) then object.Visible = not enabled end
    end
    for _, descendant in ipairs(playerGui:GetDescendants()) do process(descendant) end
    if enabled then FakeNameConnection = playerGui.DescendantAdded:Connect(function(obj) task.defer(process, obj) end) end
end
PlayerStream:AddToggle({
    Name = "Hide Name", Default = false,
    Callback = function(v) pcall(enableFakeName, v) end,
})

-- ============================================================
--  VISUAL TAB
-- ============================================================
local VisualESP = VisualTab:AddSection({ Name = "ESP" })
VisualESP:AddToggle({
    Name = "Master Drawing ESP", Default = VD.DRAWING_ESP,
    Callback = function(v) VD.DRAWING_ESP = v end,
})
VisualESP:AddToggle({
    Name = "ESP Skeleton", Default = VD.ESP_Skeleton,
    Callback = function(v)
        if VD.ESP_LowPerformance and v then VD_Notify("ESP", "Skeleton disabled in Low Performance", 2); return end
        VD.ESP_Skeleton = v
    end,
})
VisualESP:AddToggle({
    Name = "ESP Velocity Arrows", Default = VD.ESP_Velocity,
    Callback = function(v)
        if VD.ESP_LowPerformance and v then VD_Notify("ESP", "Velocity disabled in Low Performance", 2); return end
        VD.ESP_Velocity = v
    end,
})
VisualESP:AddToggle({
    Name = "ESP Offscreen Arrows", Default = VD.ESP_Offscreen,
    Callback = function(v)
        if VD.ESP_LowPerformance and v then VD_Notify("ESP", "Offscreen disabled in Low Performance", 2); return end
        VD.ESP_Offscreen = v
    end,
})
VisualESP:AddSlider({
    Name = "Max ESP Distance", Min = 500, Max = 5000, Default = VD.MaxDistance or 2000, Increment = 100,
    Callback = function(v) VD.MaxDistance = v end,
})
VisualESP:AddToggle({
    Name = "Low Performance Mode", Default = VD.ESP_LowPerformance,
    Callback = function(v)
        VD.ESP_LowPerformance = v
        if v then VD.ESP_Skeleton = false; VD.ESP_Velocity = false; VD.ESP_Offscreen = false end
    end,
})

local VisualLight = VisualTab:AddSection({ Name = "Lighting" })
VisualLight:AddToggle({
    Name = "Fullbright", Default = VD.Fullbright,
    Callback = function(v) VD.Fullbright = v; applyFullbright(v) end,
})
VisualLight:AddToggle({
    Name = "No Fog", Default = VD.NoFog,
    Callback = function(v) VD.NoFog = v; applyNoFog(v) end,
})

local VisualColor = VisualTab:AddSection({ Name = "ESP Colors" })
VisualColor:AddColorpicker({
    Name = "Survivor Color", Default = Color3.fromRGB(0, 255, 0),
    Callback = function(v) end,
})
VisualColor:AddColorpicker({
    Name = "Killer Color", Default = Color3.fromRGB(255, 0, 0),
    Callback = function(v) end,
})
VisualColor:AddColorpicker({
    Name = "Generator Color", Default = Color3.fromRGB(0, 170, 255),
    Callback = function(v) end,
})
VisualColor:AddColorpicker({
    Name = "Hook Color", Default = Color3.fromRGB(255, 0, 0),
    Callback = function(v) end,
})
VisualColor:AddColorpicker({
    Name = "Gate Color", Default = Color3.fromRGB(255, 225, 0),
    Callback = function(v) end,
})
VisualColor:AddColorpicker({
    Name = "FOV Circle Color", Default = Color3.fromRGB(180, 180, 180),
    Callback = function(v)
        if VeilDraw.FOVCircle then VeilDraw.FOVCircle.Color = v end
    end,
})

-- ============================================================
--  SPEED TAB
-- ============================================================
local SpeedSec = SpeedTab:AddSection({ Name = "Speed" })
SpeedSec:AddSlider({
    Name = "WalkSpeed", Min = 16, Max = 200, Default = 16, Increment = 1, ValueName = "speed",
    Callback = function(v)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = v end
    end,
})

-- ============================================================
--  SETTINGS TAB
-- ============================================================
local SettingsSec = SettingsTab:AddSection({ Name = "Config" })
SettingsSec:AddButton({
    Name = "Save Config",
    Callback = function()
        Ziaan_SaveConfig()
        VD_Notify("Settings", "Config saved!", 3)
    end,
})
SettingsSec:AddButton({
    Name = "Load Config",
    Callback = function()
        Ziaan_LoadConfig()
        VD_Notify("Settings", "Config loaded!", 3)
    end,
})
SettingsSec:AddButton({
    Name = "Reset Config",
    Callback = function()
        for k, v in pairs({
            AutoSkillcheck = false, AutoSkillcheckMode = "Normal", SURV_FleeKiller = false, SURV_FleeDistance = 40,
            SURV_AntiKnock = false, SURV_FirstPerson = false, InstantHealSelf = false, AutoHealAll = false,
            SURV_AutoVault = false, SURV_AutoPalletSlide = false, SURV_AutoDropPallet = false,
            SURV_AutoDropPalletDist = 20, SURV_AutoDropPalletMode = "Aggressive",
            SURV_AutoParry = false, SURV_ParryMode = "Legit", SURV_ParryAnimId = "rbxassetid://109133187196613",
            SURV_ParryRange = 12, SURV_ShowParryCircle = true, Parry_Keybind = "F3",
            AUTO_ToFAim = false, AUTO_ToFAimRange = 90, AUTO_ToFDotThreshold = 0.5,
            AUTO_ToFTargetMode = "Killer", AUTO_ToFAimPart = "HumanoidRootPart",
            AUTO_ToFPredict = true, AUTO_ToFBulletSpeed = 200,
            AUTO_Attack = false, AUTO_AttackRange = 12, KILLER_DestroyPallets = false,
            KILLER_AutoBreakGene = false, KILLER_BlockVaults = false, KILLER_AntiBlind = false,
            KILLER_DoubleTap = false, SPEAR_Aimbot = false, SPEAR_Gravity = 50, SPEAR_Speed = 100,
            KILLER_CustomMasked = "Richard", DRAWING_ESP = false, ESP_Skeleton = false,
            ESP_Offscreen = false, ESP_Velocity = false, MaxDistance = 2000, ESP_LowPerformance = false,
            Fullbright = false, NoFog = false, SURV_GenBoost = false, SURV_DraggableGenBypass = false,
            FLING_Enabled = false, FLING_Strength = 10000,
        }) do VD[k] = v end
        VD_Notify("Settings", "Config reset to default!", 3)
    end,
})
SettingsSec:AddButton({
    Name = "Export Config (Copy)",
    Callback = function()
        pcall(function()
            local export = {}
            for k, v in pairs(VD) do if type(v) ~= "function" and type(v) ~= "table" then export[k] = v end end
            local json = HttpService:JSONEncode(export)
            if setclipboard then setclipboard(json) end
            VD_Notify("Settings", "Config copied to clipboard!", 3)
        end)
    end,
})
SettingsSec:AddButton({
    Name = "Import Config (Paste)",
    Callback = function()
        pcall(function()
            local json = getclipboard and getclipboard() or ""
            if json == "" then VD_Notify("Settings", "Clipboard empty!", 3); return end
            local data = HttpService:JSONDecode(json)
            for k, v in pairs(data) do VD[k] = v end
            VD_Notify("Settings", "Config imported! Restart script to apply all.", 4)
        end)
    end,
})
SettingsSec:AddButton({
    Name = "Tutup UI (Close)",
    Callback = function() confirmClose() end,
})

-- ============================================================
--  AUTO SAVE / LOAD & FINAL INIT
-- ============================================================
Ziaan_LoadConfig()

-- Apply loaded states
task.spawn(function()
    task.wait(1)
    if VD.SURV_GenBoost then startGenBoost() end
    if VD.Fullbright then applyFullbright(true) end
    if VD.NoFog then applyNoFog(true) end
    if VD.SURV_AntiKnock then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function()
                    if antiKnockConnection then antiKnockConnection:Disconnect() end
                    antiKnockConnection = hum.HealthChanged:Connect(function() hum.Health = 100 end)
                end)
            end
        end
    end
end)

-- Player refresh for teleport
task.spawn(function()
    while not VD.Destroyed do
        refreshTPNames()
        pcall(function()
            if tpDropdown and tpDropdown.Refresh then tpDropdown:Refresh(tpPlayerNames) end
            if tpDropdown2 and tpDropdown2.Refresh then tpDropdown2:Refresh(tpPlayerNames) end
        end)
        task.wait(5)
    end
end)

-- Auto Save on change
task.spawn(function()
    while not VD.Destroyed do
        task.wait(10)
        Ziaan_SaveConfig()
    end
end)

OrionLib:MakeNotification({ Name = "NO MERCY", Content = "Violence District dimuat!", Image = ICON.Logo, Time = 4 })
print("[NO MERCY] Violence District loaded successfully!")
