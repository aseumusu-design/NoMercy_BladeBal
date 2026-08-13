--[[
=========================================================================
    NO MERCY HUB  -  BLADE BALL EDITION
    Recovered & rebuilt from obfuscated loader (LuaObfuscator XOR loader)
    -> Engine: Auto Parry (Distance/Time), Anti-Curve, Auto Spam,
       Super Spam, Soccer Mode, God Mode, Auto Ability, Ability ESP,
       Sword Skin Changer, Fly, Speed/Jump, Custom Anim,
       Warp/Tween, Rejoin, Server Hop
    -> UI  : NO MERCY HUB style (dark theme, white stroke, logo bubble,
             sidebar tabs, switch toggles, steppers, draggable)
=========================================================================
]]

-- ==================== SERVICES ====================
local RunService        = game:GetService("RunService")
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")
local StatsService      = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService   = game:GetService("TeleportService")
local HttpService       = game:GetService("HttpService")
local ContentProvider   = game:GetService("ContentProvider")

local LocalPlayer = Players.LocalPlayer
local Player      = LocalPlayer

-- ==================== COLORS / THEME (NO MERCY) ====================
local THEME = {
    Bg       = Color3.fromRGB(8, 8, 12),
    BgLight  = Color3.fromRGB(18, 18, 24),
    Panel    = Color3.fromRGB(14, 14, 20),
    Accent   = Color3.fromRGB(255, 255, 255),
    Accent2  = Color3.fromRGB(120, 120, 255),
    Text     = Color3.fromRGB(255, 255, 255),
    TextDim  = Color3.fromRGB(160, 160, 175),
    Green    = Color3.fromRGB(40, 200, 90),
    Red      = Color3.fromRGB(230, 60, 70),
    Yellow   = Color3.fromRGB(255, 200, 60),
    White    = Color3.fromRGB(255, 255, 255),
    Stroke   = Color3.fromRGB(255, 255, 255),
}

local LOGO_ID = "126404877070566"

-- ==================== ANTI DUPLICATE ====================
if shared._NoMercyBB_Running then
    shared._NoMercyBB_Running = false
    if shared._NoMercyBB_Physics then shared._NoMercyBB_Physics:Disconnect(); shared._NoMercyBB_Physics = nil end
    if shared._NoMercyBB_Fly     then shared._NoMercyBB_Fly:Disconnect();     shared._NoMercyBB_Fly = nil end
    task.wait(0.1)
end
shared._NoMercyBB_Running = true

-- ==================== BAC BYPASS HOOKS ====================
local hookfunction = hookfunction or (getgenv and getgenv().hookfunction)
if hookfunction and getrenv then
    pcall(function()
        local _oldDebugInfo
        _oldDebugInfo = hookfunction(getrenv().debug.info, function(f, t)
            if type(f) == "function" then return "[C]"
            elseif f == 4 and t == "s" then return "ReplicatedStorage.Controllers.SwordsController " end
            return _oldDebugInfo(f, t)
        end)

        local _oldGetfenv
        _oldGetfenv = hookfunction(getrenv().getfenv, function(l)
            if l ~= nil and type(l) == "number" and l >= 1 and l <= 10 then return _oldGetfenv(10) end
            return _oldGetfenv(l)
        end)
    end)
end

-- ==================== CONFIG ====================
local Config = {
    AutoParry = false,
    ParryMode = "Distance",
    TargetTime = 0.3,
    DistanceTiming = 100,
    ParryCurveMode = "Front",
    TargetMode = "Nearest",
    AutoSpam = false,
    ManualSpam = false,
    ManualSpamSpeed = 0.015,
    SuperSpam = false,
    SuperSpamClicks = 1,
    AutoAbility = false,

    AbilityESP = false,
    SoccerMode = false,
    GodMode = false,
    CustomSpeed = nil,
    CustomJump = nil,
    FlyMode = false,
    FlySpeed = 50,
    CustomAnimID = "",

    SkinChangerEnabled = false,
    SwordAnimationsEnabled = true,
}

local Auto_Parry = {}
local lastParryTime = 0
local parryCooldown = 0.04
local lastHitTick = 0
local lastTargetChecked = nil
local Last_Parry = 0
local Cache_Update_Tick = 0
local Last_Positions_Cache = {}
local doubleClickTarget = nil

getgenv()._ZX_VelHistory = getgenv()._ZX_VelHistory or { ball = {}, player = {}, MAX_SAMPLES = 7 }
local _ZX_VelHistory = getgenv()._ZX_VelHistory

local function _ZX_pushVelSample(target, pos, vel)
    local history = target == "ball" and _ZX_VelHistory.ball or _ZX_VelHistory.player
    table.insert(history, 1, { pos = pos, vel = vel, t = tick() })
    while #history > _ZX_VelHistory.MAX_SAMPLES do table.remove(history, #history) end
end

-- ==================== UPVALUE EVENT RESOLVER ====================
ZX_Parry = { Remote = nil, Function = nil, KeyTable = nil, TransformFn = nil, NetModule = nil, RemoteId = nil, ParryHash = nil, Hooked = false }
task.spawn(function()
    pcall(function()
        local getupvals = debug.getupvalues or getupvalues
        local SC = ReplicatedStorage:WaitForChild("Controllers", 10):FindFirstChild("SwordsController \12")
        local PRY = SC and SC:WaitForChild("PRY", 10)
        if not PRY then return end
        ZX_Parry.Function = require(PRY)
        local ups = getupvals(ZX_Parry.Function)
        ZX_Parry.KeyTable = ups[3]
        ZX_Parry.TransformFn = ups[4]
        ZX_Parry.NetModule = ups[6]
        ZX_Parry.RemoteId = ups[7]
        ZX_Parry.ParryHash = ups[8]
        if ZX_Parry.KeyTable and ZX_Parry.TransformFn and ZX_Parry.NetModule and ZX_Parry.RemoteId then
            ZX_Parry.Remote = ZX_Parry.NetModule:RemoteEvent(ZX_Parry.RemoteId)
            ZX_Parry.Hooked = true
        end
    end)
end)

local cachedToken = nil
local lastTokenTick = 0
local function generateToken(currentKey)
    if not currentKey or not ZX_Parry.TransformFn then return nil end
    if tick() - lastTokenTick < 0.015 and cachedToken then return cachedToken end
    local tok, transformed = pcall(ZX_Parry.TransformFn, currentKey, "TIME")
    if not tok or not transformed then return nil end
    local serverTime = workspace:GetServerTimeNow() * 100
    local timeStr = tostring(math.floor(serverTime))
    local tokenChars = {}
    for i = 1, #timeStr do
        local ki = (i - 1) % #transformed + 1
        local xb = bit32.bxor((string.byte(timeStr, i) + i) % 256, string.byte(transformed, ki))
        tokenChars[i] = string.char(xb)
    end
    cachedToken = table.concat(tokenChars)
    lastTokenTick = tick()
    return cachedToken
end

function Auto_Parry.Get_Ball()
    local bc = workspace:FindFirstChild("Balls")
    if bc then
        for _, b in pairs(bc:GetChildren()) do
            if b:IsA("BasePart") and b:GetAttribute("realBall") then return b end
        end
    end
    return nil
end

function Auto_Parry.GetTargetPlayer()
    local alive = workspace:FindFirstChild("Alive")
    if not alive or not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return nil end

    if Config.TargetMode == "Double click" then
        return doubleClickTarget
    elseif Config.TargetMode == "Camera" then
        local cam = workspace.CurrentCamera
        if not cam then return nil end
        local minAngle, chosen = math.huge, nil
        for _, p in pairs(alive:GetChildren()) do
            if p ~= LocalPlayer.Character and p.PrimaryPart then
                local _, onScreen = cam:WorldToScreenPoint(p.PrimaryPart.Position)
                if onScreen then
                    local dot = cam.CFrame.LookVector:Dot((p.PrimaryPart.Position - cam.CFrame.Position).Unit)
                    if dot > 0 and (1 - dot) < minAngle then minAngle = 1 - dot; chosen = p end
                end
            end
        end
        return chosen
    elseif Config.TargetMode == "Nearest" then
        local minDist, chosen = math.huge, nil
        for _, p in pairs(alive:GetChildren()) do
            if p ~= LocalPlayer.Character and p.PrimaryPart then
                local d = (p.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude
                if d < minDist then minDist = d; chosen = p end
            end
        end
        return chosen
    elseif Config.TargetMode == "Farest" then
        local maxDist, chosen = -1, nil
        for _, p in pairs(alive:GetChildren()) do
            if p ~= LocalPlayer.Character and p.PrimaryPart then
                local d = (p.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude
                if d > maxDist then maxDist = d; chosen = p end
            end
        end
        return chosen
    end
    return nil
end

function Auto_Parry.Parry_Animation()
    if not Config.SwordAnimationsEnabled then return end
    pcall(function()
        local Parry_Animation = ReplicatedStorage.Shared.SwordAPI.Collection.Default:FindFirstChild("GrabParry")
        local Current_Sword = Player.Character:GetAttribute("CurrentlyEquippedSword")
        if not Current_Sword or not Parry_Animation then return end
        local Sword_Data = ReplicatedStorage.Shared.ReplicatedInstances.Swords.GetSword:Invoke(Current_Sword)
        if not Sword_Data or not Sword_Data["AnimationType"] then return end
        for _, object in pairs(ReplicatedStorage.Shared.SwordAPI.Collection:GetChildren()) do
            if object.Name == Sword_Data["AnimationType"] then
                local animType = object:FindFirstChild("GrabParry") and "GrabParry" or (object:FindFirstChild("Grab") and "Grab")
                if animType then Parry_Animation = object[animType] end
            end
        end
        local track = Player.Character.Humanoid.Animator:LoadAnimation(Parry_Animation)
        track:Play()
    end)
end

function Auto_Parry.CalculateParryCFrame()
    local cam = workspace.CurrentCamera
    local baseCF = cam and cam.CFrame or CFrame.new()
    local targetPlr = Auto_Parry.GetTargetPlayer()
    local lookDir = baseCF.LookVector
    if targetPlr and targetPlr.PrimaryPart and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
        lookDir = (targetPlr.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position).Unit
    end
    local mode = Config.ParryCurveMode
    if mode == "Random" then
        local modes = {"Front", "Back", "Left", "Right"}
        mode = modes[math.random(1, #modes)]
    end
    if mode == "Front" or mode == "Camera" then return CFrame.new(baseCF.Position, baseCF.Position + lookDir)
    elseif mode == "Back" or mode == "Backwards" then return CFrame.new(baseCF.Position, baseCF.Position - lookDir)
    elseif mode == "Left" then return CFrame.new(baseCF.Position, baseCF.Position + Vector3.new(-lookDir.Z, lookDir.Y, lookDir.X) + Vector3.new(0, 2, 0))
    elseif mode == "Right" then return CFrame.new(baseCF.Position, baseCF.Position + Vector3.new(lookDir.Z, lookDir.Y, -lookDir.X) + Vector3.new(0, 2, 0))
    elseif mode == "Straight" and targetPlr and targetPlr.PrimaryPart then return CFrame.new(LocalPlayer.Character.PrimaryPart.Position, targetPlr.PrimaryPart.Position)
    elseif mode == "Slowball" then return CFrame.new(baseCF.Position, baseCF.Position + Vector3.new(0, -1, 0) * 999)
    elseif mode == "Fastball" then return CFrame.new(baseCF.Position, baseCF.Position + lookDir * 10 + Vector3.new(0, 7, 0)) end
    return baseCF
end

function Auto_Parry.FireParryRemote()
    if tick() - lastParryTime < parryCooldown then return end
    if not ZX_Parry.Hooked or not ZX_Parry.Remote then return end
    local keyIndex = ZX_Parry.KeyTable and ZX_Parry.KeyTable[3]
    local currentKey = keyIndex and ZX_Parry.KeyTable[1][keyIndex]
    if not currentKey then return end
    local token = generateToken(currentKey)
    if not token then return end

    lastParryTime = tick()
    lastHitTick = tick()
    local pCF = Auto_Parry.CalculateParryCFrame()
    local alive = workspace:FindFirstChild("Alive")
    local cam = workspace.CurrentCamera

    if tick() - Cache_Update_Tick > 0.1 then
        table.clear(Last_Positions_Cache)
        if alive and cam then
            for _, character in ipairs(alive:GetChildren()) do
                local primary = character.PrimaryPart
                if primary then Last_Positions_Cache[character.Name] = cam:WorldToScreenPoint(primary.Position) end
            end
        end
        Cache_Update_Tick = tick()
    end
    if Config.SwordAnimationsEnabled and (tick() - Last_Parry > 0.5) then Auto_Parry.Parry_Animation() end
    Last_Parry = tick()
    pcall(function()
        ZX_Parry.Remote:FireServer(ZX_Parry.ParryHash, currentKey, token, 0.5, pCF, Last_Positions_Cache,
            {cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2}, false)
    end)
end

function Auto_Parry.Is_Curved()
    local Ball = Auto_Parry.Get_Ball()
    if not Ball then return false end
    local Zoomies = Ball:FindFirstChild("zoomies")
    local Velocity = Zoomies and Zoomies.VectorVelocity or Ball.AssemblyLinearVelocity
    if Velocity.Magnitude < 5 then return false end

    if #_ZX_VelHistory.ball >= 3 then
        local p1 = _ZX_VelHistory.ball[1].pos
        local p2 = _ZX_VelHistory.ball[2].pos
        local p3 = _ZX_VelHistory.ball[3].pos
        local deviation = math.acos(math.clamp((p1 - p2).Unit:Dot((p2 - p3).Unit), -1, 1))
        if deviation > 0.032 or Ball:FindFirstChild("AeroDynamicSlashVFX") then return true end
    end
    if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
        if (LocalPlayer.Character.PrimaryPart.Position - Ball.Position).Unit:Dot(Velocity.Unit) < 0.22 then return true end
    end
    return false
end

-- ==================== SKIN CHANGER BACKEND ====================
getgenv().skinChanger    = false
getgenv().swordModel     = ""
getgenv().swordAnimations = ""
getgenv().swordFX        = ""

task.spawn(function()
    local rs = ReplicatedStorage
    local swordInstancesInstance = rs:WaitForChild("Shared", 9e9):WaitForChild("ReplicatedInstances", 9e9):WaitForChild("Swords", 9e9)
    local swordInstances = require(swordInstancesInstance)

    local swordsController
    task.spawn(function()
        while task.wait() and not swordsController do
            local ok, conns = pcall(getconnections, rs.Remotes.FireSwordInfo.OnClientEvent)
            if ok and conns then
                for _, v in ipairs(conns) do
                    if v.Function and islclosure and islclosure(v.Function) then
                        local ok2, up = pcall(getupvalues, v.Function)
                        if ok2 and #up == 1 and type(up[1]) == "table" then
                            swordsController = up[1]
                            break
                        end
                    end
                end
            end
        end
    end)

    local function getSlashName(swordName)
        local ok, sln = pcall(function() return swordInstances:GetSword(swordName) end)
        return (ok and sln and sln.SlashName) or "SlashEffect"
    end

    local function refreshSlashName()
        local fxName = getgenv().swordFX ~= "" and getgenv().swordFX or getgenv().swordModel
        if fxName ~= "" then getgenv().slashName = getSlashName(fxName) else getgenv().slashName = "SlashEffect" end
    end

    local function setSword()
        if not getgenv().skinChanger then return end
        if not LocalPlayer.Character then return end
        pcall(function()
            local f = rawget(swordInstances, "EquipSwordTo")
            if type(f) == "function" then
                local ups = getupvalues(f)
                for i = 1, #ups do if type(ups[i]) == "boolean" then setupvalue(f, i, false) break end end
            end
        end)
        pcall(function() swordInstances:EquipSwordTo(LocalPlayer.Character, getgenv().swordModel) end)
        task.spawn(function()
            local attempts = 0
            while not swordsController and attempts < 20 do task.wait(0.5); attempts = attempts + 1 end
            if not swordsController then return end
            pcall(function()
                if swordsController.SetSword then
                    swordsController:SetSword(getgenv().swordAnimations ~= "" and getgenv().swordAnimations or getgenv().swordModel)
                end
            end)
            pcall(function()
                local targetSword = getgenv().swordFX ~= "" and getgenv().swordFX or getgenv().swordModel
                if rs.Remotes:FindFirstChild("FireSwordInfo") then rs.Remotes.FireSwordInfo:FireServer(targetSword) end
                if swordsController.currentSword ~= nil then swordsController.currentSword = targetSword end
                if swordsController.SwordFX ~= nil then swordsController.SwordFX = targetSword end
            end)
        end)
    end

    local hookedFuncs = {}
    task.spawn(function()
        while task.wait(1) do
            local ok, conns = pcall(getconnections, rs.Remotes.ParrySuccessAll.OnClientEvent)
            if ok and type(conns) == "table" then
                for _, v in ipairs(conns) do
                    local func = v.Function
                    if func and not hookedFuncs[func] then
                        if isourclosure and isourclosure(func) then
                            hookedFuncs[func] = true
                        else
                            hookedFuncs[func] = true
                            v:Disable()
                            local targetFunc = func
                            local ourFunc
                            ourFunc = function(...)
                                local args = { ... }
                                if tostring(args[4]) == LocalPlayer.Name and getgenv().skinChanger then
                                    local fxSword = getgenv().swordFX ~= "" and getgenv().swordFX or getgenv().swordModel
                                    refreshSlashName()
                                    args[1] = getgenv().slashName
                                    args[3] = fxSword
                                end
                                if setthreadidentity then pcall(setthreadidentity, 2) end
                                pcall(targetFunc, unpack(args))
                            end
                            hookedFuncs[ourFunc] = true
                            rs.Remotes.ParrySuccessAll.OnClientEvent:Connect(ourFunc)
                        end
                    end
                end
            end
        end
    end)

    getgenv().updateSword = function() refreshSlashName(); setSword() end

    task.spawn(function()
        while task.wait(1) do
            if getgenv().skinChanger and getgenv().swordModel ~= "" then
                local char = LocalPlayer.Character
                if char then
                    if LocalPlayer:GetAttribute("CurrentlyEquippedSword") ~= getgenv().swordModel then setSword() end
                    if not char:FindFirstChild(getgenv().swordModel) then setSword() end
                    for _, v in char:GetChildren() do
                        if v:IsA("Model") and v.Name ~= getgenv().swordModel then v:Destroy() end
                        task.wait()
                    end
                end
            end
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        if getgenv().skinChanger then
            getgenv().skinChanger = false; task.wait(1.5)
            getgenv().skinChanger = true;  task.wait(0.5)
            pcall(function() getgenv().updateSword() end)
        end
    end)
end)

-- ==================== UI ROOT ====================
local parentGui = (gethui and gethui()) or CoreGui or LocalPlayer:FindFirstChild("PlayerGui")
if not parentGui then parentGui = LocalPlayer:WaitForChild("PlayerGui") end
pcall(function()
    if parentGui:FindFirstChild("NoMercyBladeGui") then parentGui.NoMercyBladeGui:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NoMercyBladeGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = parentGui

-- ==================== NOTIFY (NoMercy style) ====================
local NotifyHolder = Instance.new("Frame", ScreenGui)
NotifyHolder.Size = UDim2.new(0, 250, 0, 460)
NotifyHolder.Position = UDim2.new(1, -264, 0, 30)
NotifyHolder.BackgroundTransparency = 1
local notifyList = Instance.new("UIListLayout", NotifyHolder)
notifyList.Padding = UDim.new(0, 6)
notifyList.SortOrder = Enum.SortOrder.LayoutOrder

local function Notify(text, duration, color)
    duration = duration or 3
    local card = Instance.new("Frame", NotifyHolder)
    card.Size = UDim2.new(1, 0, 0, 38)
    card.BackgroundColor3 = THEME.BgLight
    card.BackgroundTransparency = 0.1
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = color or THEME.White
    stroke.Thickness = 1.2
    stroke.Transparency = 0.2

    local bar = Instance.new("Frame", card)
    bar.Size = UDim2.new(0, 3, 1, -14)
    bar.Position = UDim2.new(0, 7, 0, 7)
    bar.BackgroundColor3 = color or THEME.White
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local txt = Instance.new("TextLabel", card)
    txt.Size = UDim2.new(1, -22, 1, 0)
    txt.Position = UDim2.new(0, 16, 0, 0)
    txt.Text = text
    txt.TextColor3 = THEME.Text
    txt.Font = Enum.Font.GothamSemibold
    txt.TextSize = 11
    txt.BackgroundTransparency = 1
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.TextWrapped = true

    card.BackgroundTransparency = 1; txt.TextTransparency = 1; stroke.Transparency = 1
    TweenService:Create(card,   TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(txt,    TweenInfo.new(0.2), {TextTransparency = 0}):Play()
    TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.2}):Play()

    task.delay(duration, function()
        local t1 = TweenService:Create(card, TweenInfo.new(0.25), {BackgroundTransparency = 1})
        TweenService:Create(txt,    TweenInfo.new(0.25), {TextTransparency = 1}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.25), {Transparency = 1}):Play()
        t1:Play()
        t1.Completed:Connect(function() card:Destroy() end)
    end)
end

-- ==================== DRAG HELPER ====================
local function makeDraggable(frame)
    local dragging, dragStart, startPos
    frame.Active = true
    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- ==================== LOGO BUBBLE ====================
local Bubble = Instance.new("ImageButton")
Bubble.Name = "Bubble"
Bubble.Size = UDim2.new(0, 62, 0, 62)
Bubble.Position = UDim2.new(0, 16, 0.28, 0)
Bubble.BackgroundColor3 = THEME.BgLight
Bubble.BackgroundTransparency = 0.15
Bubble.AutoButtonColor = false
Bubble.Image = "rbxassetid://" .. LOGO_ID
Bubble.ScaleType = Enum.ScaleType.Fit
Bubble.Visible = true
Bubble.Parent = ScreenGui
Instance.new("UICorner", Bubble).CornerRadius = UDim.new(1, 0)
local bs = Instance.new("UIStroke", Bubble)
bs.Color = THEME.White; bs.Thickness = 2.5
makeDraggable(Bubble)

local BubbleFallback = Instance.new("TextLabel", Bubble)
BubbleFallback.Size = UDim2.new(1, 0, 1, 0)
BubbleFallback.BackgroundTransparency = 1
BubbleFallback.Text = "NM"
BubbleFallback.Font = Enum.Font.GothamBlack
BubbleFallback.TextSize = 18
BubbleFallback.TextColor3 = THEME.White

task.spawn(function()
    local urls = {
        "rbxassetid://" .. LOGO_ID,
        "rbxthumb://type=Asset&id=" .. LOGO_ID .. "&w=150&h=150",
        "https://www.roblox.com/asset/?id=" .. LOGO_ID,
    }
    for _, u in ipairs(urls) do
        Bubble.Image = u
        pcall(function() ContentProvider:PreloadAsync({Bubble}) end)
        for _ = 1, 15 do
            if Bubble.IsLoaded then BubbleFallback.Visible = false return end
            task.wait(0.15)
        end
    end
end)

-- ==================== MAIN WINDOW ====================
local MainFrame = Instance.new("CanvasGroup")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 410)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -205)
MainFrame.BackgroundColor3 = THEME.Bg
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.GroupTransparency = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
local mfs = Instance.new("UIStroke", MainFrame)
mfs.Color = THEME.White; mfs.Thickness = 2; mfs.Transparency = 0.05
local grad = Instance.new("UIGradient", MainFrame)
grad.Color = ColorSequence.new(THEME.BgLight, THEME.Bg)
grad.Rotation = 90
makeDraggable(MainFrame)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 46)
Header.BackgroundColor3 = THEME.BgLight
Header.BorderSizePixel = 0
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)
local hstroke = Instance.new("UIStroke", Header)
hstroke.Color = THEME.White; hstroke.Thickness = 0.5; hstroke.Transparency = 0.7

local hIcon = Instance.new("ImageLabel", Header)
hIcon.Size = UDim2.new(0, 26, 0, 26)
hIcon.Position = UDim2.new(0, 12, 0.5, -13)
hIcon.BackgroundTransparency = 1
hIcon.Image = "rbxassetid://" .. LOGO_ID
hIcon.ScaleType = Enum.ScaleType.Fit

local hTitle = Instance.new("TextLabel", Header)
hTitle.Size = UDim2.new(1, -120, 0, 20)
hTitle.Position = UDim2.new(0, 46, 0, 5)
hTitle.BackgroundTransparency = 1
hTitle.Text = "NO MERCY HUB"
hTitle.TextXAlignment = Enum.TextXAlignment.Left
hTitle.Font = Enum.Font.GothamBlack
hTitle.TextSize = 16
hTitle.TextColor3 = THEME.Text

local hSub = Instance.new("TextLabel", Header)
hSub.Size = UDim2.new(1, -120, 0, 14)
hSub.Position = UDim2.new(0, 46, 0, 25)
hSub.BackgroundTransparency = 1
hSub.Text = "Blade Ball \u{2022} Parry \u{2022} Spam \u{2022} God \u{2022} Skin \u{2022} Fly"
hSub.TextXAlignment = Enum.TextXAlignment.Left
hSub.Font = Enum.Font.Gotham
hSub.TextSize = 10
hSub.TextColor3 = THEME.TextDim

local HookDot = Instance.new("Frame", Header)
HookDot.Size = UDim2.new(0, 8, 0, 8)
HookDot.Position = UDim2.new(1, -78, 0.5, -4)
HookDot.BackgroundColor3 = THEME.Red
HookDot.BorderSizePixel = 0
Instance.new("UICorner", HookDot).CornerRadius = UDim.new(1, 0)

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 26, 0, 26)
MinBtn.Position = UDim2.new(1, -66, 0.5, -13)
MinBtn.BackgroundColor3 = THEME.BgLight
MinBtn.Text = "\u{2013}"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.TextColor3 = THEME.White
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)
local mbs = Instance.new("UIStroke", MinBtn); mbs.Color = THEME.White; mbs.Thickness = 0.5; mbs.Transparency = 0.5

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -37, 0.5, -15)
CloseBtn.BackgroundColor3 = THEME.Red
CloseBtn.Text = "\u{2715}"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = THEME.White
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 9)
local cbs = Instance.new("UIStroke", CloseBtn); cbs.Color = THEME.White; cbs.Thickness = 0.5; cbs.Transparency = 0.5

-- show / hide
local guiOpen, isTweening = true, false
local fadeInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function setGui(open)
    if isTweening then return end
    isTweening = true; guiOpen = open
    if open then
        MainFrame.Visible = true
        local t = TweenService:Create(MainFrame, fadeInfo, {GroupTransparency = 0})
        t:Play(); t.Completed:Connect(function() isTweening = false end)
    else
        local t = TweenService:Create(MainFrame, fadeInfo, {GroupTransparency = 1})
        t:Play(); t.Completed:Connect(function() if not guiOpen then MainFrame.Visible = false end isTweening = false end)
    end
end
Bubble.MouseButton1Click:Connect(function() setGui(not guiOpen) end)
MinBtn.MouseButton1Click:Connect(function() setGui(false) end)
CloseBtn.MouseButton1Click:Connect(function() setGui(false) end)

-- ==================== TAB SIDEBAR ====================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 135, 1, -56)
Sidebar.Position = UDim2.new(0, 10, 0, 54)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = MainFrame
local sideLay = Instance.new("UIListLayout", Sidebar)
sideLay.SortOrder = Enum.SortOrder.LayoutOrder
sideLay.Padding = UDim.new(0, 6)

local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -160, 1, -62)
PageContainer.Position = UDim2.new(0, 150, 0, 56)
PageContainer.BackgroundColor3 = THEME.Panel
PageContainer.BackgroundTransparency = 0.5
PageContainer.Parent = MainFrame
Instance.new("UICorner", PageContainer).CornerRadius = UDim.new(0, 12)
local pcs = Instance.new("UIStroke", PageContainer)
pcs.Color = THEME.White; pcs.Thickness = 0.5; pcs.Transparency = 0.8

local Pages = {}
local function CreateTab(name, icon)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 32)
    TabBtn.BackgroundColor3 = THEME.BgLight
    TabBtn.BackgroundTransparency = 0.5
    TabBtn.Text = "  " .. icon .. "  " .. name
    TabBtn.TextColor3 = THEME.TextDim
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize = 12
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.AutoButtonColor = false
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 9)
    local tbs = Instance.new("UIStroke", TabBtn)
    tbs.Color = THEME.White; tbs.Thickness = 0.3; tbs.Transparency = 0.9

    local PageScroll = Instance.new("ScrollingFrame")
    PageScroll.Size = UDim2.new(1, -16, 1, -16)
    PageScroll.Position = UDim2.new(0, 8, 0, 8)
    PageScroll.BackgroundTransparency = 1
    PageScroll.ScrollBarThickness = 3
    PageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    PageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    PageScroll.Visible = false
    PageScroll.Parent = PageContainer
    local pl = Instance.new("UIListLayout", PageScroll)
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    pl.Padding = UDim.new(0, 7)

    Pages[name] = { Button = TabBtn, Scroll = PageScroll }
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do
            p.Scroll.Visible = false
            p.Button.BackgroundTransparency = 0.5
            p.Button.TextColor3 = THEME.TextDim
        end
        PageScroll.Visible = true
        TabBtn.BackgroundTransparency = 0.2
        TabBtn.TextColor3 = THEME.White
    end)
    return PageScroll
end

local CombatPage   = CreateTab("Combat",   "\u{1F6E1}")
local ParryPage    = CreateTab("Parry Cfg","\u{2699}")
local SpamPage     = CreateTab("Spam",     "\u{26A1}")
local VisualPage   = CreateTab("Visuals",  "\u{1F441}")
local PlayerPage   = CreateTab("Player",   "\u{1F464}")
local TeleportPage = CreateTab("Teleport", "\u{1F680}")
local ServerPage   = CreateTab("Server",   "\u{1F310}")

-- ==================== UI HELPERS ====================
local function AddToggle(parent, text, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 34)
    holder.BackgroundColor3 = THEME.BgLight
    holder.BackgroundTransparency = 0.2
    holder.Parent = parent
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 7)

    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(1, -52, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 11
    lbl.TextColor3 = THEME.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local dot = Instance.new("Frame", holder)
    dot.Size = UDim2.new(0, 34, 0, 18)
    dot.Position = UDim2.new(1, -42, 0.5, -9)
    dot.BackgroundColor3 = default and THEME.Green or Color3.fromRGB(60, 60, 75)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", dot)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = THEME.Text
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default
    holder.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            state = not state
            dot.BackgroundColor3 = state and THEME.Green or Color3.fromRGB(60, 60, 75)
            TweenService:Create(knob, TweenInfo.new(0.15), {
                Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            }):Play()
            callback(state)
        end
    end)
    return holder
end

local function AddButton(parent, text, callback, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = color or THEME.BgLight
    btn.BackgroundTransparency = 0.2
    btn.Text = "  " .. text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.TextColor3 = THEME.Text
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    local st = Instance.new("UIStroke", btn); st.Color = THEME.White; st.Thickness = 0.4; st.Transparency = 0.85
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

local function AddLabel(parent, text, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 18)
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 11
    l.TextColor3 = color or THEME.TextDim
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

-- Input box: label di atas, TextBox di bawah
local function AddInput(parent, labelText, placeholder, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 48)
    holder.BackgroundColor3 = THEME.BgLight
    holder.BackgroundTransparency = 0.2
    holder.Parent = parent
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 7)

    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(1, -16, 0, 14)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 10
    lbl.TextColor3 = THEME.TextDim
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", holder)
    box.Size = UDim2.new(1, -20, 0, 22)
    box.Position = UDim2.new(0, 10, 0, 20)
    box.BackgroundColor3 = THEME.Bg
    box.Text = default or ""
    box.PlaceholderText = placeholder or ""
    box.PlaceholderColor3 = Color3.fromRGB(90, 90, 105)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 11
    box.TextColor3 = THEME.Accent2
    box.ClearTextOnFocus = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
    local bst = Instance.new("UIStroke", box); bst.Color = THEME.White; bst.Thickness = 0.4; bst.Transparency = 0.85

    box.FocusLost:Connect(function() callback(box.Text, box) end)
    return box
end

-- Cycle selector: label + value + tombol ganti
local function AddCycle(parent, labelText, list, getValue, setValue)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 44)
    holder.BackgroundColor3 = THEME.BgLight
    holder.BackgroundTransparency = 0.2
    holder.Parent = parent
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 7)

    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(1, -16, 0, 14)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 10
    lbl.TextColor3 = THEME.TextDim
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local val = Instance.new("TextLabel", holder)
    val.Size = UDim2.new(1, -78, 0, 20)
    val.Position = UDim2.new(0, 10, 0, 20)
    val.BackgroundColor3 = THEME.Bg
    val.Font = Enum.Font.GothamBold
    val.TextSize = 11
    val.TextColor3 = THEME.Accent2
    Instance.new("UICorner", val).CornerRadius = UDim.new(0, 5)

    local nxt = Instance.new("TextButton", holder)
    nxt.Size = UDim2.new(0, 58, 0, 20)
    nxt.Position = UDim2.new(1, -68, 0, 20)
    nxt.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    nxt.Text = "CHANGE"
    nxt.Font = Enum.Font.GothamBold
    nxt.TextSize = 9
    nxt.TextColor3 = THEME.Text
    Instance.new("UICorner", nxt).CornerRadius = UDim.new(0, 5)

    local function refresh() val.Text = "  " .. tostring(getValue()) end
    refresh()
    nxt.MouseButton1Click:Connect(function()
        local idx = table.find(list, getValue()) or 1
        setValue(list[idx + 1 > #list and 1 or idx + 1])
        refresh()
    end)
    return holder, refresh
end

-- Stepper numeric
local function AddStepper(parent, labelText, getValue, setValue, minV, maxV, step, fmt)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 44)
    holder.BackgroundColor3 = THEME.BgLight
    holder.BackgroundTransparency = 0.2
    holder.Parent = parent
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 7)

    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(1, -16, 0, 16)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 10
    lbl.TextColor3 = THEME.TextDim
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = labelText

    local val = Instance.new("TextLabel", holder)
    val.Size = UDim2.new(1, -90, 0, 20)
    val.Position = UDim2.new(0, 42, 0, 20)
    val.BackgroundColor3 = THEME.Bg
    val.Font = Enum.Font.GothamBold
    val.TextSize = 12
    val.TextColor3 = THEME.Accent2
    Instance.new("UICorner", val).CornerRadius = UDim.new(0, 5)

    local mn = Instance.new("TextButton", holder)
    mn.Size = UDim2.new(0, 28, 0, 20)
    mn.Position = UDim2.new(0, 10, 0, 20)
    mn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    mn.Text = "\u{2212}"
    mn.Font = Enum.Font.GothamBold
    mn.TextSize = 14
    mn.TextColor3 = THEME.Text
    Instance.new("UICorner", mn).CornerRadius = UDim.new(0, 5)

    local pl = Instance.new("TextButton", holder)
    pl.Size = UDim2.new(0, 28, 0, 20)
    pl.Position = UDim2.new(1, -38, 0, 20)
    pl.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    pl.Text = "+"
    pl.Font = Enum.Font.GothamBold
    pl.TextSize = 14
    pl.TextColor3 = THEME.Text
    Instance.new("UICorner", pl).CornerRadius = UDim.new(0, 5)

    local function refresh() val.Text = fmt and fmt(getValue()) or tostring(getValue()) end
    refresh()
    mn.MouseButton1Click:Connect(function()
        local v = getValue() - step; if v < minV then v = minV end
        setValue(v); refresh()
    end)
    pl.MouseButton1Click:Connect(function()
        local v = getValue() + step; if v > maxV then v = maxV end
        setValue(v); refresh()
    end)
    return holder, refresh
end

-- ==================== TAB: COMBAT ====================
AddLabel(CombatPage, "\u{2014}\u{2014} CORE PARRY \u{2014}\u{2014}", THEME.White)
AddToggle(CombatPage, "Auto Parry System", false, function(v)
    Config.AutoParry = v
    Notify("Auto Parry: " .. (v and "ON" or "OFF"), 2, v and THEME.Green or THEME.Red)
end)
AddToggle(CombatPage, "Soccer Mode (no lock target)", false, function(v) Config.SoccerMode = v end)
AddToggle(CombatPage, "God Mode (18 studs orbit)", false, function(v)
    Config.GodMode = v
    Notify("God Mode: " .. (v and "ON" or "OFF"), 2, v and THEME.Green or THEME.Red)
end)
AddToggle(CombatPage, "Smart Auto Ability", false, function(v) Config.AutoAbility = v end)
AddToggle(CombatPage, "Parry Animation Track", true, function(v) Config.SwordAnimationsEnabled = v end)
AddToggle(CombatPage, "Auto Spam Clash", false, function(v) Config.AutoSpam = v end)

local StatusLabel = AddLabel(CombatPage, "Remote status: checking...", THEME.Yellow)

-- ==================== TAB: PARRY CONFIG ====================
AddLabel(ParryPage, "\u{2014}\u{2014} TIMING MODE \u{2014}\u{2014}", THEME.White)
AddCycle(ParryPage, "Parry Mode", {"Distance", "Time"},
    function() return Config.ParryMode end,
    function(v) Config.ParryMode = v; Notify("Parry Mode: " .. v, 2) end)

AddStepper(ParryPage, "Distance Timing (5 - 300)",
    function() return Config.DistanceTiming end,
    function(v) Config.DistanceTiming = v end,
    5, 300, 5)

AddStepper(ParryPage, "Pre-Hit Time (Time mode)",
    function() return Config.TargetTime end,
    function(v) Config.TargetTime = math.floor(v * 100 + 0.5) / 100 end,
    0.05, 1.5, 0.05,
    function(v) return string.format("%.2f s", v) end)

AddLabel(ParryPage, "\u{2014}\u{2014} CURVE & TARGET \u{2014}\u{2014}", THEME.White)
AddCycle(ParryPage, "Curve Vector Direction",
    {"Front", "Back", "Left", "Right", "Random", "Straight", "Slowball", "Fastball"},
    function() return Config.ParryCurveMode end,
    function(v) Config.ParryCurveMode = v end)

AddCycle(ParryPage, "Lock Target Profile",
    {"Camera", "Double click", "Nearest", "Farest"},
    function() return Config.TargetMode end,
    function(v) Config.TargetMode = v end)

-- ==================== TAB: SPAM ====================
AddLabel(SpamPage, "\u{2014}\u{2014} MANUAL SPAM \u{2014}\u{2014}", THEME.White)
local manualToggleRef
AddToggle(SpamPage, "Manual Spam", false, function(v)
    Config.ManualSpam = v
    if manualToggleRef then manualToggleRef() end
end)
AddStepper(SpamPage, "Manual Spam Delay (s)",
    function() return Config.ManualSpamSpeed end,
    function(v) Config.ManualSpamSpeed = math.floor(v * 1000 + 0.5) / 1000 end,
    0.005, 0.2, 0.005,
    function(v) return string.format("%.3f", v) end)

AddLabel(SpamPage, "\u{2014}\u{2014} SUPER SPAM \u{2014}\u{2014}", THEME.White)
AddToggle(SpamPage, "Super Spam", false, function(v) Config.SuperSpam = v end)
AddStepper(SpamPage, "Super Spam Clicks per tick",
    function() return Config.SuperSpamClicks end,
    function(v) Config.SuperSpamClicks = math.floor(v) end,
    1, 20, 1)

AddButton(SpamPage, "\u{1F4CC}  Show / Hide Spam Keypad", function()
    if shared._NoMercyBB_Keypad then
        shared._NoMercyBB_Keypad.Visible = not shared._NoMercyBB_Keypad.Visible
    end
end)

-- ==================== TAB: VISUALS ====================
AddLabel(VisualPage, "\u{2014}\u{2014} ESP \u{2014}\u{2014}", THEME.White)
AddToggle(VisualPage, "Player Ability ESP", false, function(v) Config.AbilityESP = v end)

AddLabel(VisualPage, "\u{2014}\u{2014} SWORD SKIN CHANGER \u{2014}\u{2014}", THEME.White)
AddToggle(VisualPage, "Enable Skin Changer", false, function(v)
    getgenv().skinChanger = v
    Config.SkinChangerEnabled = v
    pcall(function() getgenv().updateSword() end)
    Notify("Skin Changer: " .. (v and "ON" or "OFF"), 2, v and THEME.Green or THEME.Red)
end)
AddInput(VisualPage, "Sword Model Name", "e.g. Ghost", "", function(txt)
    getgenv().swordModel = txt
    pcall(function() getgenv().updateSword() end)
    Notify("Sword Model: " .. (txt ~= "" and txt or "cleared"), 2)
end)
AddInput(VisualPage, "Custom Animation Name (optional)", "leave empty = default", "", function(txt)
    getgenv().swordAnimations = txt
    pcall(function() getgenv().updateSword() end)
end)
AddInput(VisualPage, "Custom FX Name (optional)", "leave empty = default", "", function(txt)
    getgenv().swordFX = txt
    pcall(function() getgenv().updateSword() end)
end)
AddButton(VisualPage, "\u{1F504}  Re-apply Sword Skin", function()
    pcall(function() getgenv().updateSword() end)
    Notify("Sword skin re-applied", 2)
end)

-- ==================== TAB: PLAYER ====================
AddLabel(PlayerPage, "\u{2014}\u{2014} MOVEMENT \u{2014}\u{2014}", THEME.White)
AddToggle(PlayerPage, "Fly Mode (WASD + Space/Shift)", false, function(v)
    Config.FlyMode = v
    Notify("Fly: " .. (v and "ON" or "OFF"), 2, v and THEME.Green or THEME.Red)
end)
AddStepper(PlayerPage, "Fly Speed",
    function() return Config.FlySpeed end,
    function(v) Config.FlySpeed = v end,
    10, 500, 10)

AddStepper(PlayerPage, "WalkSpeed (16 = default)",
    function() return Config.CustomSpeed or 16 end,
    function(v) Config.CustomSpeed = v end,
    16, 300, 2)
AddButton(PlayerPage, "\u{267B}  Reset WalkSpeed", function()
    Config.CustomSpeed = nil
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16 end
    Notify("WalkSpeed reset", 2)
end)

AddStepper(PlayerPage, "JumpPower (50 = default)",
    function() return Config.CustomJump or 50 end,
    function(v) Config.CustomJump = v end,
    50, 400, 10)
AddButton(PlayerPage, "\u{267B}  Reset JumpPower", function()
    Config.CustomJump = nil
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = 50 end
    Notify("JumpPower reset", 2)
end)

AddLabel(PlayerPage, "\u{2014}\u{2014} ANIMATION \u{2014}\u{2014}", THEME.White)
AddInput(PlayerPage, "Roblox Animation ID", "paste anim id", "", function(txt)
    Config.CustomAnimID = txt
end)

-- ==================== TELEPORT & SERVER UTILITIES ====================
local function targetDistanceSolver(mode)
    local alive = workspace:FindFirstChild("Alive")
    if not alive or not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return nil end
    local myPos = LocalPlayer.Character.PrimaryPart.Position
    local chosen, pivotDist = nil, (mode == "Nearest" and math.huge or -1)
    for _, p in pairs(alive:GetChildren()) do
        if p ~= LocalPlayer.Character and p:IsA("Model") and p.PrimaryPart then
            local d = (p.PrimaryPart.Position - myPos).Magnitude
            if mode == "Nearest" then
                if d < pivotDist then pivotDist = d; chosen = p end
            else
                if d > pivotDist then pivotDist = d; chosen = p end
            end
        end
    end
    return chosen
end

local function executeWarp(target)
    if target and target.PrimaryPart and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
        LocalPlayer.Character.PrimaryPart.CFrame = target.PrimaryPart.CFrame * CFrame.new(0, 0, 4)
        Notify("Warped to: " .. target.Name, 2.5, THEME.Green)
    else
        Notify("Target player not found!", 2.5, THEME.Red)
    end
end

local function executeTween(target)
    if target and target.PrimaryPart and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
        local hrp = LocalPlayer.Character.PrimaryPart
        local dist = (target.PrimaryPart.Position - hrp.Position).Magnitude
        local duration = dist / 130
        TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {CFrame = target.PrimaryPart.CFrame * CFrame.new(0, 0, 4)}):Play()
        Notify("Tweening to: " .. target.Name, 2.5, THEME.Green)
    else
        Notify("Target player not found!", 2.5, THEME.Red)
    end
end

local function RejoinServer()
    Notify("Rejoining server...", 3, THEME.Yellow)
    task.wait(0.5)
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
end

local function ServerHop()
    Notify("Finding new public server...", 4, THEME.Yellow)
    pcall(function()
        local sfUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local req = HttpService:JSONDecode(game:HttpGet(sfUrl))
        for _, server in ipairs(req.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end)
end

local function PlayCustomAnimation(id)
    if not id or id == "" then Notify("Animation ID empty!", 2.5, THEME.Red) return end
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Animator then
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://" .. tostring(id)
            local track = hum.Animator:LoadAnimation(anim)
            track:Play()
            Notify("Playing anim: " .. id, 2.5, THEME.Green)
            task.delay(1, function() pcall(function() anim:Destroy() end) end)
        else
            Notify("Humanoid not found!", 2.5, THEME.Red)
        end
    end)
end

AddButton(PlayerPage, "\u{1F3AD}  Play Custom Animation", function()
    PlayCustomAnimation(Config.CustomAnimID)
end)

-- ==================== TAB: TELEPORT ====================
AddLabel(TeleportPage, "\u{2014}\u{2014} INSTANT WARP \u{2014}\u{2014}", THEME.White)
AddButton(TeleportPage, "\u{1F4A5}  Warp to Nearest Player", function()
    executeWarp(targetDistanceSolver("Nearest"))
end)
AddButton(TeleportPage, "\u{1F4A5}  Warp to Farthest Player", function()
    executeWarp(targetDistanceSolver("Farest"))
end)
AddLabel(TeleportPage, "\u{2014}\u{2014} SMOOTH TWEEN \u{2014}\u{2014}", THEME.White)
AddButton(TeleportPage, "\u{1F680}  Tween to Nearest Player", function()
    executeTween(targetDistanceSolver("Nearest"))
end)
AddButton(TeleportPage, "\u{1F680}  Tween to Farthest Player", function()
    executeTween(targetDistanceSolver("Farest"))
end)

-- ==================== TAB: SERVER ====================
AddLabel(ServerPage, "\u{2014}\u{2014} SERVER TOOLS \u{2014}\u{2014}", THEME.White)
AddButton(ServerPage, "\u{1F504}  Rejoin Same Server", function() RejoinServer() end)
AddButton(ServerPage, "\u{1F310}  Server Hop (find new)", function() ServerHop() end)
AddLabel(ServerPage, "\u{2014}\u{2014} SESSION \u{2014}\u{2014}", THEME.White)
AddButton(ServerPage, "\u{1F5D1}  Unload Hub (stop all)", function()
    shared._NoMercyBB_Running = false
    if shared._NoMercyBB_Physics then shared._NoMercyBB_Physics:Disconnect() end
    if shared._NoMercyBB_Fly then shared._NoMercyBB_Fly:Disconnect() end
    Notify("Hub unloaded", 2, THEME.Red)
    task.delay(0.6, function() ScreenGui:Destroy() end)
end, Color3.fromRGB(60, 20, 24))

-- Buka tab pertama
Pages["Combat"].Button:Activate()
Pages["Combat"].Scroll.Visible = true
Pages["Combat"].Button.BackgroundTransparency = 0.2
Pages["Combat"].Button.TextColor3 = THEME.White

-- ==================== FLOATING SPAM KEYPAD ====================
local Keypad = Instance.new("Frame")
Keypad.Name = "SpamKeypad"
Keypad.Size = UDim2.new(0, 118, 0, 112)
Keypad.Position = UDim2.new(0.84, 0, 0.5, -56)
Keypad.BackgroundColor3 = THEME.Bg
Keypad.BackgroundTransparency = 0.05
Keypad.Visible = false
Keypad.Parent = ScreenGui
Instance.new("UICorner", Keypad).CornerRadius = UDim.new(0, 12)
local kps = Instance.new("UIStroke", Keypad); kps.Color = THEME.White; kps.Thickness = 1.5; kps.Transparency = 0.15
makeDraggable(Keypad)
shared._NoMercyBB_Keypad = Keypad

local kpTitle = Instance.new("TextLabel", Keypad)
kpTitle.Size = UDim2.new(1, 0, 0, 18)
kpTitle.Position = UDim2.new(0, 0, 0, 4)
kpTitle.BackgroundTransparency = 1
kpTitle.Text = "SPAM KEYPAD"
kpTitle.Font = Enum.Font.GothamBlack
kpTitle.TextSize = 9
kpTitle.TextColor3 = THEME.TextDim

local kpSpam = Instance.new("TextButton", Keypad)
kpSpam.Size = UDim2.new(1, -16, 0, 36)
kpSpam.Position = UDim2.new(0, 8, 0, 24)
kpSpam.BackgroundColor3 = THEME.BgLight
kpSpam.Text = "SPAM  OFF"
kpSpam.Font = Enum.Font.GothamBold
kpSpam.TextSize = 11
kpSpam.TextColor3 = THEME.Red
kpSpam.AutoButtonColor = false
Instance.new("UICorner", kpSpam).CornerRadius = UDim.new(0, 8)
local kpSpamStroke = Instance.new("UIStroke", kpSpam); kpSpamStroke.Color = THEME.Red; kpSpamStroke.Thickness = 1.2

local kpSuper = Instance.new("TextButton", Keypad)
kpSuper.Size = UDim2.new(1, -16, 0, 36)
kpSuper.Position = UDim2.new(0, 8, 0, 66)
kpSuper.BackgroundColor3 = THEME.BgLight
kpSuper.Text = "SUPER  OFF"
kpSuper.Font = Enum.Font.GothamBold
kpSuper.TextSize = 11
kpSuper.TextColor3 = THEME.Red
kpSuper.AutoButtonColor = false
Instance.new("UICorner", kpSuper).CornerRadius = UDim.new(0, 8)
local kpSuperStroke = Instance.new("UIStroke", kpSuper); kpSuperStroke.Color = THEME.Red; kpSuperStroke.Thickness = 1.2

local function refreshKeypad()
    kpSpam.Text = "SPAM  " .. (Config.ManualSpam and "ON" or "OFF")
    kpSpam.TextColor3 = Config.ManualSpam and THEME.Green or THEME.Red
    kpSpamStroke.Color = Config.ManualSpam and THEME.Green or THEME.Red
    kpSuper.Text = "SUPER  " .. (Config.SuperSpam and "ON" or "OFF")
    kpSuper.TextColor3 = Config.SuperSpam and THEME.Green or THEME.Red
    kpSuperStroke.Color = Config.SuperSpam and THEME.Green or THEME.Red
end
manualToggleRef = refreshKeypad

kpSpam.MouseButton1Click:Connect(function() Config.ManualSpam = not Config.ManualSpam; refreshKeypad() end)
kpSuper.MouseButton1Click:Connect(function() Config.SuperSpam = not Config.SuperSpam; refreshKeypad() end)
refreshKeypad()

-- ==================== ABILITY ESP ====================
local function createBillboardGui(p)
    if p == LocalPlayer then return end
    task.spawn(function()
        local character = p.Character or p.CharacterAdded:Wait()
        local head = character:WaitForChild("Head", 10)
        if not head then return end
        if head:FindFirstChild("NoMercy_AbilityESP") then head.NoMercy_AbilityESP:Destroy() end

        local bg = Instance.new("BillboardGui", head)
        bg.Name = "NoMercy_AbilityESP"
        bg.Adornee = head
        bg.Size = UDim2.new(0, 210, 0, 40)
        bg.StudsOffset = Vector3.new(0, 3, 0)
        bg.AlwaysOnTop = true

        local tl = Instance.new("TextLabel", bg)
        tl.Size = UDim2.new(1, 0, 1, 0)
        tl.TextColor3 = THEME.White
        tl.TextSize = 13
        tl.TextStrokeTransparency = 0
        tl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        tl.Font = Enum.Font.GothamBold
        tl.BackgroundTransparency = 1

        local conn
        conn = RunService.Heartbeat:Connect(function()
            if not shared._NoMercyBB_Running then conn:Disconnect() return end
            if not character or not character.Parent or not bg or not bg.Parent then conn:Disconnect() return end
            if Config.AbilityESP then
                bg.Enabled = true
                local currentAbil = p:GetAttribute("EquippedAbility") or p:GetAttribute("Ability") or "None"
                tl.Text = p.DisplayName .. "  [" .. tostring(currentAbil) .. "]"
            else
                bg.Enabled = false
            end
        end)
    end)
end
for _, p in pairs(Players:GetPlayers()) do
    p.CharacterAdded:Connect(function() createBillboardGui(p) end)
    if p.Character then createBillboardGui(p) end
end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() createBillboardGui(p) end) end)

-- ==================== FLY ENGINE ====================
shared._NoMercyBB_Fly = RunService.Heartbeat:Connect(function()
    if not shared._NoMercyBB_Running or not Config.FlyMode then return end
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local cam = workspace.CurrentCamera
        if hrp and hum and cam then
            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            if moveDir.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (moveDir.Unit * (Config.FlySpeed * RunService.Heartbeat:Wait()))
            end
        end
    end)
end)

-- ==================== HUMANOID ENFORCER ====================
task.spawn(function()
    while shared._NoMercyBB_Running do
        task.wait(0.1)
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                if Config.CustomSpeed then hum.WalkSpeed = Config.CustomSpeed end
                if Config.CustomJump then
                    hum.JumpPower = Config.CustomJump
                    hum.UseJumpPower = true
                end
            end
        end)
    end
end)

-- ==================== CORE PHYSICS LOOP (AUTO PARRY) ====================
shared._NoMercyBB_Physics = RunService.Heartbeat:Connect(function()
    if not shared._NoMercyBB_Running then return end
    local Ball = Auto_Parry.Get_Ball()
    if not Ball or not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return end

    local hrp = LocalPlayer.Character.HumanoidRootPart
    local Zoomies = Ball:FindFirstChild("zoomies")
    local Velocity = Zoomies and Zoomies.VectorVelocity or Ball.AssemblyLinearVelocity
    local Speed = Velocity.Magnitude

    local ballTargetStr = tostring(Ball:GetAttribute("target"))
    local isTargetingMe = (ballTargetStr == LocalPlayer.Name or ballTargetStr == tostring(LocalPlayer))
    if Config.SoccerMode then isTargetingMe = true end

    local ballPos, playerPos = Ball.Position, hrp.Position
    local Distance = (playerPos - ballPos).Magnitude

    _ZX_pushVelSample("ball", ballPos, Velocity)
    _ZX_pushVelSample("player", playerPos, hrp.AssemblyLinearVelocity)

    local isCurving = Auto_Parry.Is_Curved()
    local allowedToHit = isTargetingMe and (lastTargetChecked ~= ballTargetStr or tick() - lastHitTick >= 0.75)
    if isTargetingMe then lastTargetChecked = ballTargetStr else lastTargetChecked = nil end

    if Config.AutoParry and allowedToHit and isTargetingMe then
        if Config.ParryMode == "Distance" then
            local baseThreshold = 11.5 + (Speed * 0.16)
            if isCurving then baseThreshold = baseThreshold + 8.5 end
            local adjustedThreshold = baseThreshold * (100 / math.clamp(Config.DistanceTiming, 5, 300))
            if Distance <= adjustedThreshold then Auto_Parry.FireParryRemote() end

        elseif Config.ParryMode == "Time" then
            local pingSeconds = 0
            pcall(function()
                pingSeconds = (StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()) / 1000
            end)
            local reachTime = Distance / math.max(Speed, 1) - pingSeconds
            local triggerTime = Config.TargetTime

            local predictedPos = ballPos + Velocity * math.clamp(reachTime, 0, 1.5)
            local devError = (predictedPos - playerPos).Magnitude

            local ballDirection = Velocity.Unit
            local toPlayerDirection = (playerPos - ballPos).Unit
            local dotProduct = ballDirection:Dot(toPlayerDirection)

            if isCurving or devError > 14 then
                local curveSafetyDistance = math.clamp(Speed * 0.36, 18, 68)
                if Distance <= curveSafetyDistance and dotProduct > -0.25 then
                    Auto_Parry.FireParryRemote()
                end
            else
                if dotProduct > 0.12 and reachTime <= triggerTime then
                    Auto_Parry.FireParryRemote()
                end
            end
        end
    end

    if Config.AutoSpam and isTargetingMe then
        local targetPlr = Auto_Parry.GetTargetPlayer()
        local isSpamZone = targetPlr and targetPlr.PrimaryPart and (playerPos - targetPlr.PrimaryPart.Position).Magnitude <= 40
        local dynamicSpamDist = math.clamp(Speed * 0.08, 16, 45)
        if (Distance <= dynamicSpamDist) or (isSpamZone and Distance <= 22) then
            for _ = 1, 4 do task.spawn(Auto_Parry.FireParryRemote) end
        end
    end
end)

-- ==================== GOD MODE THREAD ====================
task.spawn(function()
    while shared._NoMercyBB_Running do
        RunService.Heartbeat:Wait()
        if Config.GodMode then
            pcall(function()
                local ball = Auto_Parry.Get_Ball()
                if ball and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                    local sideVector = ball.CFrame.RightVector * 18
                    LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(ball.Position + sideVector, ball.Position)
                    LocalPlayer.Character.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end)
        else
            task.wait(0.1)
        end
    end
end)

-- ==================== MANUAL SPAM THREAD ====================
task.spawn(function()
    while shared._NoMercyBB_Running do
        if Config.ManualSpam then
            Auto_Parry.FireParryRemote()
            task.wait(math.clamp(Config.ManualSpamSpeed, 0.001, 1))
        else
            task.wait(0.05)
        end
    end
end)

-- ==================== SUPER SPAM THREAD ====================
task.spawn(function()
    while shared._NoMercyBB_Running do
        if Config.SuperSpam then
            local clicks = math.max(1, math.floor(Config.SuperSpamClicks))
            for _ = 1, clicks do task.spawn(Auto_Parry.FireParryRemote) end
            task.wait(0.01)
        else
            task.wait(0.05)
        end
    end
end)

-- ==================== REMOTE STATUS INDICATOR ====================
task.spawn(function()
    while shared._NoMercyBB_Running do
        if ZX_Parry.Hooked then
            HookDot.BackgroundColor3 = THEME.Green
            StatusLabel.Text = "Remote status: HOOKED \u{2713}  (parry ready)"
            StatusLabel.TextColor3 = THEME.Green
        else
            HookDot.BackgroundColor3 = THEME.Red
            StatusLabel.Text = "Remote status: waiting for SwordsController..."
            StatusLabel.TextColor3 = THEME.Yellow
        end
        task.wait(1)
    end
end)

Notify("NO MERCY HUB \u{2022} Blade Ball loaded", 4, THEME.Green)
Notify("Tap logo bubble to hide / show menu", 5)
