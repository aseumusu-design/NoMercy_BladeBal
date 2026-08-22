--[[
  NO MERCY — "VIOLENCE DISTRICT" [DELTA EDITION]
  UI: Orion (MarV) — Mobile Optimized
]]

-- ===================== EARLY NOTIFICATION =====================
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "NO MERCY", Text = "Loading script...", Duration = 3
    })
end)

-- ===================== COMPATIBILITY LAYER =====================
local function safeGetHui()
    local ok, result = pcall(function() return gethui() end)
    if ok and result then return result end
    local ok2, core = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and core then return core end
    return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local function safeProtect(gui)
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
end

-- ===================== SERVICES =====================
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ===================== ICONS =====================
local ICON = {
    Info="rbxassetid://7733964719", Crosshair="rbxassetid://7733765307",
    Swords="rbxassetid://7734056608", Globe="rbxassetid://7733954760",
    Axe="rbxassetid://7733674079", User="rbxassetid://7743875962",
    Eye="rbxassetid://7733774602", Zap="rbxassetid://7733771628",
    Settings="rbxassetid://7734053495", Logo="rbxassetid://102609928046926",
    Banner="rbxassetid://138968189462646",
}

-- ===================== GLOBAL CONFIG =====================
getgenv().VD = getgenv().VD or {
    AutoSkillcheck=false, AutoSkillcheckMode="Normal",
    SURV_FleeKiller=false, SURV_FleeDistance=40,
    SURV_AntiKnock=false, SURV_FirstPerson=false,
    InstantHealSelf=false, AutoHealAll=false,
    SURV_AutoVault=false, SURV_AutoPalletSlide=false,
    SURV_AutoDropPallet=false, SURV_AutoDropPalletDist=20, SURV_AutoDropPalletMode="Aggressive",
    SURV_AutoParry=false, SURV_ParryMode="Legit", SURV_ParryAnimId="rbxassetid://109133187196613",
    SURV_ParryRange=12, SURV_ShowParryCircle=true, Parry_Keybind="F3",
    AUTO_ToFAim=false, AUTO_ToFAimRange=90, AUTO_ToFDotThreshold=0.5,
    AUTO_ToFTargetMode="Killer", AUTO_ToFAimPart="HumanoidRootPart", AUTO_ToFPredict=true, AUTO_ToFBulletSpeed=200,
    AUTO_Attack=false, AUTO_AttackRange=12,
    KILLER_DestroyPallets=false, KILLER_AutoBreakGene=false, KILLER_BlockVaults=false,
    KILLER_AntiBlind=false, KILLER_DoubleTap=false,
    SPEAR_Aimbot=false, SPEAR_Gravity=50, SPEAR_Speed=100, KILLER_CustomMasked="Richard",
    DRAWING_ESP=false, ESP_Skeleton=false, ESP_Offscreen=false, ESP_Velocity=false,
    MaxDistance=2000, ESP_LowPerformance=false,
    Fullbright=false, NoFog=false,
    SURV_GenBoost=false, SURV_DraggableGenBypass=false,
    FLING_Enabled=false, FLING_Strength=10000, Destroyed=false,
}
local VD = getgenv().VD

-- ===================== CONFIG SYSTEM =====================
local ConfigFolder = "NoMercyViolence"
pcall(function() if makefolder and isfolder and not isfolder(ConfigFolder) then makefolder(ConfigFolder) end end)

local function SaveConfig()
    pcall(function() if writefile then writefile(ConfigFolder.."/State.json", HttpService:JSONEncode(VD)) end end)
end

local function LoadConfig()
    pcall(function()
        if readfile and isfile and isfile(ConfigFolder.."/State.json") then
            local data = HttpService:JSONDecode(readfile(ConfigFolder.."/State.json"))
            for k,v in pairs(data) do VD[k]=v end
        end
    end)
end
LoadConfig()

-- ===================== ORION LIB LOAD =====================
local OrionLib
pcall(function()
    local src = game:HttpGet("https://raw.githubusercontent.com/Marpiii/UiLib/refs/heads/main/source.lua")
    OrionLib = loadstring(src)()
end)

if not OrionLib then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title="NO MERCY ERROR", Text="OrionLib failed to load. Check internet.", Duration=10
        })
    end)
    warn("[NO MERCY] OrionLib load failed")
    return
end

-- ===================== WELCOME INTRO =====================
pcall(function()
    local holder = safeGetHui()
    local gui = Instance.new("ScreenGui")
    gui.Name="NoMercyWelcome"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true; gui.ZIndexBehavior=Enum.ZIndexBehavior.Global
    safeProtect(gui); gui.Parent=holder
    local cf = Instance.new("Frame")
    cf.Size=UDim2.fromOffset(260,260); cf.Position=UDim2.new(0.5,0,0.5,0); cf.AnchorPoint=Vector2.new(0.5,0.5)
    cf.BackgroundTransparency=1; cf.ZIndex=999; cf.Parent=gui
    local img = Instance.new("ImageLabel")
    img.Size=UDim2.fromOffset(0,0); img.Position=UDim2.new(0.5,0,0.4,0); img.AnchorPoint=Vector2.new(0.5,0.5)
    img.Image=ICON.Logo; img.BackgroundTransparency=1; img.ZIndex=999; img.Parent=cf
    Instance.new("UICorner").CornerRadius=UDim.new(1,0); img:FindFirstChildOfClass("UICorner").Parent=img
    local stroke = Instance.new("UIStroke")
    stroke.Color=Color3.fromRGB(255,255,255); stroke.Thickness=4; stroke.Transparency=1; stroke.Parent=img
    local txt = Instance.new("TextLabel")
    txt.Size=UDim2.new(1,0,0,40); txt.Position=UDim2.new(0.5,0,0.75,0); txt.AnchorPoint=Vector2.new(0.5,0)
    txt.BackgroundTransparency=1; txt.Text="WELCOME NO MERCY"; txt.TextColor3=Color3.fromRGB(255,255,255)
    txt.TextSize=18; txt.Font=Enum.Font.GothamBold; txt.TextTransparency=1; txt.ZIndex=999; txt.Parent=cf
    TweenService:Create(img, TweenInfo.new(0.6,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(150,150)}):Play()
    TweenService:Create(stroke, TweenInfo.new(0.4),{Transparency=0}):Play()
    TweenService:Create(txt, TweenInfo.new(0.4),{TextTransparency=0}):Play()
    task.wait(2)
    TweenService:Create(img, TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.fromOffset(0,0)}):Play()
    TweenService:Create(stroke, TweenInfo.new(0.3),{Transparency=1}):Play()
    TweenService:Create(txt, TweenInfo.new(0.3),{TextTransparency=1}):Play()
    task.wait(0.5)
    gui:Destroy()
end)

-- ===================== WINDOW & BUBBLE =====================
local onCloseRequest
local Window = OrionLib:MakeWindow({
    Name="NO MERCY — VIOLENCE DISTRICT", HidePremium=false,
    SaveConfig=true, ConfigFolder="NoMercyViolence",
    IntroEnabled=false, Icon=ICON.Logo,
    CloseCallback=function() if onCloseRequest then onCloseRequest() end end,
})

local function FindMain()
    local root = safeGetHui()
    local marv = root and root:FindFirstChild("MarV")
    if marv then for _,c in ipairs(marv:GetChildren()) do if c:IsA("Frame") and c.AbsoluteSize.X>300 then return c end end end
    return nil
end

local bubbleGui = nil
local function makeBubble()
    if bubbleGui then bubbleGui:Destroy() end
    local gui = Instance.new("ScreenGui")
    gui.Name="NoMercyBubble"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true; gui.ZIndexBehavior=Enum.ZIndexBehavior.Global
    safeProtect(gui); gui.Parent=safeGetHui()
    local btn = Instance.new("ImageButton")
    btn.Parent=gui; btn.BackgroundColor3=Color3.fromRGB(25,30,35); btn.Position=UDim2.new(0.02,0,0.2,0)
    btn.Size=UDim2.fromOffset(48,48); btn.Image=ICON.Logo; btn.ScaleType=Enum.ScaleType.Fit
    btn.Active=true; btn.Draggable=true; btn.ZIndex=10
    Instance.new("UICorner").CornerRadius=UDim.new(0,10); btn:FindFirstChildOfClass("UICorner").Parent=btn
    local stroke = Instance.new("UIStroke")
    stroke.Color=Color3.fromRGB(255,255,255); stroke.Thickness=2; stroke.Transparency=0; stroke.Parent=btn
    btn.MouseButton1Click:Connect(function()
        local main = FindMain()
        if main then main.Visible=true end
        bubbleGui:Destroy(); bubbleGui=nil
    end)
    bubbleGui = gui
end

local function closeUI()
    local main = FindMain()
    if main then main.Visible=false end
    makeBubble()
end

local function showUI()
    local main = FindMain()
    if main then main.Visible=true end
end

local function confirmClose(fromCloseBtn)
    if fromCloseBtn then showUI() end
    local gui = Instance.new("ScreenGui")
    gui.Name="NoMercyConfirm"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true; gui.ZIndexBehavior=Enum.ZIndexBehavior.Global
    safeProtect(gui); gui.Parent=safeGetHui()
    local fade = Instance.new("Frame")
    fade.Size=UDim2.new(1,0,1,0); fade.BackgroundColor3=Color3.fromRGB(0,0,0); fade.BackgroundTransparency=0.4; fade.ZIndex=99; fade.Parent=gui
    local box = Instance.new("Frame")
    box.Size=UDim2.fromOffset(280,150); box.Position=UDim2.new(0.5,0,0.5,0); box.AnchorPoint=Vector2.new(0.5,0.5)
    box.BackgroundColor3=Color3.fromRGB(28,32,38); box.BorderSizePixel=0; box.ZIndex=100; box.Parent=gui
    Instance.new("UICorner").CornerRadius=UDim.new(0,12); box:FindFirstChildOfClass("UICorner").Parent=box
    local title = Instance.new("TextLabel")
    title.Size=UDim2.new(1,-40,0,30); title.Position=UDim2.new(0,20,0,15); title.BackgroundTransparency=1
    title.Text="Tutup NO MERCY?"; title.TextColor3=Color3.fromRGB(240,240,240); title.TextSize=18
    title.Font=Enum.Font.GothamBold; title.TextXAlignment=Enum.TextXAlignment.Left; title.ZIndex=101; title.Parent=box
    local desc = Instance.new("TextLabel")
    desc.Size=UDim2.new(1,-40,0,30); desc.Position=UDim2.new(0,20,0,48); desc.BackgroundTransparency=1
    desc.Text="Klik bubble untuk buka lagi."; desc.TextColor3=Color3.fromRGB(150,150,150); desc.TextSize=14
    desc.Font=Enum.Font.Gotham; desc.TextXAlignment=Enum.TextXAlignment.Left; desc.ZIndex=101; desc.Parent=box
    local function cancel() gui:Destroy(); if fromCloseBtn then showUI() end end
    local btnY = Instance.new("TextButton")
    btnY.Size=UDim2.fromOffset(90,36); btnY.Position=UDim2.new(1,-200,1,-50); btnY.BackgroundColor3=Color3.fromRGB(60,60,60)
    btnY.BorderSizePixel=0; btnY.Text="Ya"; btnY.TextColor3=Color3.fromRGB(255,255,255); btnY.TextSize=15
    btnY.Font=Enum.Font.GothamBold; btnY.ZIndex=101; btnY.Parent=box
    Instance.new("UICorner").CornerRadius=UDim.new(0,8); btnY:FindFirstChildOfClass("UICorner").Parent=btnY
    btnY.MouseButton1Click:Connect(function() gui:Destroy(); closeUI() end)
    local btnN = Instance.new("TextButton")
    btnN.Size=UDim2.fromOffset(90,36); btnN.Position=UDim2.new(1,-100,1,-50); btnN.BackgroundColor3=Color3.fromRGB(40,45,52)
    btnN.BorderSizePixel=0; btnN.Text="Tidak"; btnN.TextColor3=Color3.fromRGB(240,240,240); btnN.TextSize=15
    btnN.Font=Enum.Font.GothamBold; btnN.ZIndex=101; btnN.Parent=box
    Instance.new("UICorner").CornerRadius=UDim.new(0,8); btnN:FindFirstChildOfClass("UICorner").Parent=btnN
    btnN.MouseButton1Click:Connect(cancel)
    fade.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then cancel() end end)
end

onCloseRequest = function() confirmClose(true) end

print("[NO MERCY] Window created successfully")


-- ===================== CHARACTER & HELPERS =====================
local Character, Humanoid, Root
local function updateChar(char)
    Character = char or LocalPlayer.Character
    if Character then
        task.spawn(function()
            Humanoid = Character:WaitForChild("Humanoid", 5)
            Root = Character:WaitForChild("HumanoidRootPart", 5)
        end)
    else Humanoid, Root = nil, nil end
end
updateChar()
LocalPlayer.CharacterAdded:Connect(updateChar)

local function GetRole()
    if not LocalPlayer.Team then return "Unknown" end
    local n = LocalPlayer.Team.Name
    if n=="Killer" then return "Killer" elseif n=="Survivors" then return "Survivor" end
    return "Lobby"
end
local function IsKiller(p) return p and p.Team and p.Team.Name=="Killer" end
local function IsSurvivor(p) return p and p.Team and p.Team.Name=="Survivors" end

-- ===================== PARRY SYSTEM =====================
local ParryRange = Instance.new("CylinderHandleAdornment")
ParryRange.Name="NoMercy_ParryRange"; ParryRange.Radius=VD.SURV_ParryRange or 12
ParryRange.InnerRadius=math.max(0.1,(VD.SURV_ParryRange or 12)-0.15); ParryRange.Height=0.01
ParryRange.Color3=Color3.fromRGB(80,80,80); ParryRange.AlwaysOnTop=false
ParryRange.Adornee=Workspace:FindFirstChildOfClass("Terrain"); ParryRange.Transparency=1
ParryRange.Parent=safeGetHui()

local function UpdateParryRange()
    if not VD.SURV_AutoParry or not VD.SURV_ShowParryCircle then ParryRange.Transparency=1 return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then ParryRange.Transparency=1 return end
    local d = VD.SURV_ParryRange or 12
    ParryRange.Transparency=0.4; ParryRange.Radius=d; ParryRange.InnerRadius=math.max(0.1,d-0.15)
    local rp = RaycastParams.new(); rp.FilterDescendantsInstances={char}; rp.FilterType=Enum.RaycastFilterType.Exclude
    local ray = Workspace:Raycast(root.Position, Vector3.new(0,-15,0), rp)
    local gp = ray and ray.Position or (root.Position-Vector3.new(0,3,0))
    ParryRange.CFrame = CFrame.new(gp+Vector3.new(0,0.05,0))*CFrame.Angles(math.pi/2,0,0)
end

local function HasDagger()
    local c = LocalPlayer.Character
    if not c then return false end
    if c:FindFirstChild("Parrying Dagger") then return true end
    for _,ch in ipairs(c:GetDescendants()) do
        if ch.Name=="Parrying Dagger" and (ch:IsA("Tool") or ch:IsA("Accessory") or ch:IsA("Model")) then return true end
    end
    return false
end

local ParryGradients={}; local ParryIcon=nil
local function GetParryUI()
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not pg then return end
    table.clear(ParryGradients); ParryIcon=nil
    for _,sn in ipairs({"Survivor","Survivor-con"}) do
        local s = pg:FindFirstChild(sn)
        if s then
            local g = s:FindFirstChild("Gen")
            if g then
                local itf = g:FindFirstChild("ItemFrame")
                if itf then
                    local gui = itf:FindFirstChild("Gui")
                    if gui then
                        local bar = gui:FindFirstChild("Bar")
                        if bar then
                            local grad = bar:FindFirstChild("UIGradient")
                            if grad then table.insert(ParryGradients,grad) end
                        end
                    end
                    local ic = itf:FindFirstChild("icon")
                    if ic then ParryIcon=ic end
                end
            end
        end
    end
    local ms = pg:FindFirstChild("Survivor-mob")
    if ms then
        local ctrl = ms:FindFirstChild("Controls")
        if ctrl then
            for _,b in ipairs(ctrl:GetChildren()) do
                if b:IsA("ImageButton") and b.Name=="Gui-mob" then
                    local bar = b:FindFirstChild("Bar")
                    if bar then
                        local grad = bar:FindFirstChild("UIGradient")
                        if grad then table.insert(ParryGradients,grad) end
                    end
                end
            end
        end
    end
end

task.spawn(function()
    local w=0; while #ParryGradients==0 and w<10 do task.wait(0.5); GetParryUI(); w=w+0.5 end
end)

local ParrySys = {CooldownToken=0,IsOnCooldown=false,IsResolving=false,CooldownThread=nil,LockConnection=nil}
local function SetParryIconColor(col)
    if #ParryGradients==0 then GetParryUI() end
    for _,g in ipairs(ParryGradients) do
        if g and g.Parent and g.Parent.Parent then
            local ic = g.Parent.Parent:FindFirstChild("icon")
            if ic then ic.ImageColor3=col end
            local gui = g.Parent.Parent:FindFirstChild("Gui")
            if gui then gui.ImageColor3=col end
        end
    end
    if ParryIcon then ParryIcon.ImageColor3=col end
end

local function StartParryCooldown(dur)
    ParrySys.CooldownToken=ParrySys.CooldownToken+1; local token=ParrySys.CooldownToken
    ParrySys.IsResolving=false; ParrySys.IsOnCooldown=true; SetParryIconColor(Color3.fromRGB(77,77,77))
    for _,g in ipairs(ParryGradients) do
        if g and g.Parent then
            g.Offset=Vector2.new(0,0.75)
            local tw = TweenService:Create(g, TweenInfo.new(dur,Enum.EasingStyle.Linear), {Offset=Vector2.new(0,0.25)})
            tw:Play(); tw.Completed:Connect(function() if not ParrySys.IsOnCooldown then SetParryIconColor(Color3.fromRGB(255,255,255)) end end)
        end
    end
    if ParrySys.CooldownThread then task.cancel(ParrySys.CooldownThread) end
    ParrySys.CooldownThread = task.delay(dur, function()
        if ParrySys.CooldownToken==token then ParrySys.IsOnCooldown=false; SetParryIconColor(Color3.fromRGB(255,255,255)); ParrySys.CooldownThread=nil end
    end)
end

local function ResetParry()
    if ParrySys.CooldownThread then task.cancel(ParrySys.CooldownThread); ParrySys.CooldownThread=nil end
    ParrySys.IsOnCooldown=false; ParrySys.IsResolving=false; SetParryIconColor(Color3.fromRGB(255,255,255))
    for _,g in ipairs(ParryGradients) do if g and g.Parent then g.Offset=Vector2.new(0,0.25) end end
end

local function IsBusy()
    local c = LocalPlayer.Character
    if not c then return true end
    if LocalPlayer:GetAttribute("IsDead") then return true end
    if c:GetAttribute("IsCarried") then return true end
    if c:GetAttribute("IsHooked") then return true end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if hrp and CollectionService:HasTag(hrp,"doing action") then return true end
    local ci = c:FindFirstChild("CheckInterractable")
    if ci then
        for _,a in ipairs({"isVaulting","isSliding","isDroppingPallet","isRepairing","isHealing","isUnhooking","isExiting"}) do
            if ci:GetAttribute(a) then return true end
        end
    end
    return false
end

local function IsLowHealth()
    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not h then return true end
    return h.Health < h.MaxHealth*0.5
end

local function CanParry()
    if not VD.SURV_AutoParry then return false end
    if not HasDagger() then return false end
    if ParrySys.IsOnCooldown or ParrySys.IsResolving then return false end
    if IsBusy() then return false end
    if IsLowHealth() then return false end
    return true
end

local function FaceLook()
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local rp = Root
    if not rp or not rp.Parent then return end
    local lv = cam.CFrame.LookVector
    local flat = Vector3.new(lv.X,0,lv.Z)
    if flat.Magnitude<=0 then return end
    local tcf = CFrame.new(rp.Position, rp.Position+flat.Unit)
    local tw = TweenService:Create(rp, TweenInfo.new(0.2,Enum.EasingStyle.Linear), {CFrame=tcf})
    tw:Play(); tw.Completed:Connect(function()
        if Humanoid then Humanoid.AutoRotate=true end
        if ParrySys.LockConnection then ParrySys.LockConnection:Disconnect() end
        local st=tick()
        ParrySys.LockConnection = RunService.Heartbeat:Connect(function()
            if tick()-st>=0.8 then if ParrySys.LockConnection then ParrySys.LockConnection:Disconnect(); ParrySys.LockConnection=nil end return end
            if rp and rp.Parent then rp.CFrame=CFrame.new(rp.Position,rp.Position+flat.Unit)
            else if ParrySys.LockConnection then ParrySys.LockConnection:Disconnect(); ParrySys.LockConnection=nil end end
        end)
    end)
end

local function PlayParryAnim()
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if not h then return end
    local anim = h:FindFirstChildOfClass("Animator")
    if not anim then return end
    local a = Instance.new("Animation")
    a.AnimationId = VD.SURV_ParryAnimId or "rbxassetid://109133187196613"
    local t = anim:LoadAnimation(a)
    if t then t.Priority=Enum.AnimationPriority.Action; t:Play() end
end

local function WalkSpeedSeq()
    local h = Humanoid
    if not h then return end
    local seq = {{speed=0,dur=2},{speed=19,dur=2},{speed=18,dur=1},{speed=17,dur=math.huge}}
    for _,s in ipairs(seq) do if not h.Parent then break end h.WalkSpeed=s.speed if s.dur==math.huge then break else task.wait(s.dur) end end
end

local function DoParry()
    if not CanParry() then return end
    ParrySys.IsResolving=true; SetParryIconColor(Color3.fromRGB(77,77,77))
    local pr = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Items"):FindFirstChild("Parrying Dagger"):FindFirstChild("parry")
    if pr then pcall(function() pr:FireServer() end) end
    FaceLook(); if Humanoid then Humanoid.AutoRotate=false end; PlayParryAnim()
    local rp = Root
    if rp then CollectionService:AddTag(rp,"doing action") end
    local sr = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Mechanics"):FindFirstChild("Slow")
    if sr then pcall(function() sr:Fire(0,1,0) end) end
    task.spawn(WalkSpeedSeq)
    task.delay(2, function()
        if ParrySys.IsResolving then ParrySys.IsResolving=false; StartParryCooldown(60)
            if rp then CollectionService:RemoveTag(rp,"doing action") end
        end
    end)
end

pcall(function()
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    local df = r and r:FindFirstChild("Items"):FindFirstChild("Parrying Dagger")
    local pr = df and df:FindFirstChild("parryResult")
    if pr then
        pr.OnClientEvent:Connect(function(success,cooldown)
            if not ParrySys.IsResolving then return end
            ParrySys.IsResolving=false
            local d = tonumber(cooldown)
            if d and d>0 then StartParryCooldown(d) else if success==true then StartParryCooldown(90) else StartParryCooldown(60) end end
            local rp = Root
            if rp then CollectionService:RemoveTag(rp,"doing action") end
        end)
    end
end)

local ATTACK_ANIMS = {
    ["rbxassetid://113255068724446"]=true,["rbxassetid://74968262036854"]=true,["rbxassetid://110355011987939"]=true,
    ["rbxassetid://139369275981139"]=true,["rbxassetid://132817836308238"]=true,["rbxassetid://129784271201071"]=true,
    ["rbxassetid://133963973694098"]=true,["rbxassetid://117042998468241"]=true,["rbxassetid://105374834496520"]=true,
    ["rbxassetid://111920872708571"]=true,["rbxassetid://78432063483146"]=true,["rbxassetid://118907603246885"]=true,
    ["rbxassetid://138720291317243"]=true,["rbxassetid://115244153053858"]=true,["rbxassetid://130593238885843"]=true,
    ["rbxassetid://122812055447896"]=true,["rbxassetid://78935059863801"]=true,["rbxassetid://135002183282873"]=true,
    ["rbxassetid://121216847022485"]=true,
}

local Attached = {}
local function AttachParrySensor(kChar)
    if not kChar or Attached[kChar] then return end
    Attached[kChar]=true
    local hum = kChar:FindFirstChild("Humanoid") or kChar:WaitForChild("Humanoid",5)
    if not hum then return end
    local anim = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator",5)
    if not anim then return end
    hum.ChildAdded:Connect(function(c) if c:IsA("Animator") then Attached[kChar]=nil; AttachParrySensor(kChar) end end)
    kChar.AncestryChanged:Connect(function(_,p) if not p then Attached[kChar]=nil end end)
    anim.AnimationPlayed:Connect(function(track)
        local aid = track.Animation and track.Animation.AnimationId or ""
        if not ATTACK_ANIMS[aid] then return end
        if not VD.SURV_AutoParry or not HasDagger() or ParrySys.IsOnCooldown or ParrySys.IsResolving then return end
        local mc = LocalPlayer.Character
        if not mc then return end
        local mhrp = mc:FindFirstChild("HumanoidRootPart")
        local khrp = kChar:FindFirstChild("HumanoidRootPart")
        if not mhrp or not khrp then return end
        local dist = (mhrp.Position-khrp.Position).Magnitude
        local mode = VD.SURV_ParryMode or "Legit"
        local range = VD.SURV_ParryRange or 12
        if mode=="Aggressive" then
            local ar = range; local dr = ar+3
            if dist>dr then return end
            if dist<=ar then DoParry() else
                local tracker; local st=os.clock()
                tracker = RunService.Heartbeat:Connect(function()
                    if os.clock()-st>=1.5 or ParrySys.IsOnCooldown or ParrySys.IsResolving or not mhrp or not khrp then
                        if tracker then tracker:Disconnect() end return
                    end
                    if (mhrp.Position-khrp.Position).Magnitude<=ar then DoParry(); if tracker then tracker:Disconnect() end end
                end)
            end
        else
            if dist>range then return end
            local mpf = Vector3.new(mhrp.Position.X,0,mhrp.Position.Z)
            local kpf = Vector3.new(khrp.Position.X,0,khrp.Position.Z)
            local fd = mpf-kpf
            if fd.Magnitude>0 then
                local fdir = fd.Unit
                local kl = Vector3.new(khrp.CFrame.LookVector.X,0,khrp.CFrame.LookVector.Z).Unit
                if kl:Dot(fdir)<0.6 then return end
            end
            DoParry()
        end
    end)
end

local function TryAttach(p)
    if p~=LocalPlayer and p.Team and p.Team.Name=="Killer" and p.Character then AttachParrySensor(p.Character) end
end

local function SetupParryPlayer(p)
    if p==LocalPlayer then return end
    p.CharacterAdded:Connect(function() TryAttach(p) end)
    p:GetPropertyChangedSignal("Team"):Connect(function() TryAttach(p) end)
    if p.Character then TryAttach(p) end
end

for _,p in ipairs(Players:GetPlayers()) do SetupParryPlayer(p) end
Players.PlayerAdded:Connect(SetupParryPlayer)

task.spawn(function() while true do task.wait(5); for _,p in ipairs(Players:GetPlayers()) do TryAttach(p) end end end)
RunService.RenderStepped:Connect(UpdateParryRange)

print("[NO MERCY] Parry loaded")


-- ===================== AUTO SKILLCHECK =====================
local PG = LocalPlayer:WaitForChild("PlayerGui")
local AS = {LastGoal=nil,Clicked=false,LastLine=nil,LastTick=nil,Active=false,PLastGoal=nil,PClicked=false,PLastLine=nil,PLastTick=nil,PActive=false,ILastTick=0,ILastGoal=0,ILastInst=nil,ICurID=0,IClicked=false,IForce=false,IConn=nil}

local function PressSkill()
    if isMobile then
        local btn = PG:FindFirstChild("check",true)
        if btn and btn:IsA("GuiObject") then
            local p=btn.AbsolutePosition; local s=btn.AbsoluteSize; local i=game:GetService("GuiService"):GetGuiInset()
            local x=p.X+s.X/2+i.X; local y=p.Y+s.Y/2+i.Y
            pcall(function() game:GetService("VirtualInputManager"):SendTouchEvent(8822,Enum.UserInputState.Begin.Value,x,y) end)
            task.wait(0.01)
            pcall(function() game:GetService("VirtualInputManager"):SendTouchEvent(8822,Enum.UserInputState.End.Value,x,y) end)
        end
    else
        pcall(function() game:GetService("VirtualInputManager"):SendKeyEvent(true,Enum.KeyCode.Space,false,game) end)
        task.wait(0.01)
        pcall(function() game:GetService("VirtualInputManager"):SendKeyEvent(false,Enum.KeyCode.Space,false,game) end)
    end
end

local function GetSkill()
    for _,gn in ipairs({"SkillCheckPromptGui","SkillCheckPromptGui-con"}) do
        local g = PG:FindFirstChild(gn,true)
        if g then
            local c = g:FindFirstChild("Check",true)
            if c and c.Visible then
                local l = c:FindFirstChild("Line",true); local gl = c:FindFirstChild("Goal",true)
                if l and gl then return l,gl end
            end
        end
    end
end

local function AngDelta(f,t) local d=t-f; if d>180 then d=d-360 end; if d<-180 then d=d+360 end; return d end
local function Crossed(prev,lr,sp,ep)
    local function inZone(r) if sp>ep then return r>=sp or r<=ep end; return r>=sp and r<=ep end
    if inZone(lr) then return true end; if prev==nil then return false end
    local d=AngDelta(prev,lr); local s=math.abs(math.floor(d)); if s<2 then return false end
    local ss=d/s; for i=1,s do if inZone((prev+ss*i)%360) then return true end end; return false
end

local function NormalSkill()
    local line,goal = GetSkill()
    if not (line and goal) then AS.LastGoal=nil; AS.Clicked=false; AS.LastLine=nil; AS.LastTick=nil; AS.Active=false; return end
    local lr=line.Rotation%360; local gr=goal.Rotation%360; local now=os.clock()
    if not AS.Active then AS.Active=true; AS.Clicked=false; AS.LastGoal=gr; AS.LastLine=lr; AS.LastTick=now; return end
    if AS.LastGoal and math.abs(AngDelta(AS.LastGoal,gr))>5 then AS.Clicked=false; AS.LastLine=nil; AS.LastTick=nil end
    AS.LastGoal=gr
    if AS.Clicked then AS.LastLine=lr; AS.LastTick=now; return end
    if AS.LastLine and AS.LastTick then
        local dt=now-AS.LastTick; if dt>0 then
            local spd=AngDelta(AS.LastLine,lr)/dt; local pred=(lr+spd*dt*0)%360
            if Crossed(AS.LastLine,pred,(gr+104)%360,(gr+109)%360) then AS.Clicked=true; task.spawn(function() task.wait(0.03); PressSkill() end) end
        end
    end
    AS.LastLine=lr; AS.LastTick=now
end

local function PerfectSkill()
    local line,goal = GetSkill()
    if not (line and goal) then AS.PLastGoal=nil; AS.PClicked=false; AS.PLastLine=nil; AS.PLastTick=nil; AS.PActive=false; return end
    local lr=line.Rotation%360; local gr=goal.Rotation%360; local now=os.clock()
    if not AS.PActive then AS.PActive=true; AS.PClicked=false; AS.PLastGoal=gr; AS.PLastLine=lr; AS.PLastTick=now; return end
    if AS.PLastGoal and math.abs(AngDelta(AS.PLastGoal,gr))>5 then AS.PClicked=false; AS.PLastLine=nil; AS.PLastTick=nil end
    AS.PLastGoal=gr
    if AS.PClicked then AS.PLastLine=lr; AS.PLastTick=now; return end
    if AS.PLastLine and AS.PLastTick then
        local dt=now-AS.PLastTick; if dt>0 then
            local spd=AngDelta(AS.PLastLine,lr)/dt; local pred=(lr+spd*dt*0)%360
            if Crossed(AS.PLastLine,pred,(gr+104)%360,(gr+108)%360) then AS.PClicked=true; PressSkill() end
        end
    end
    AS.PLastLine=lr; AS.PLastTick=now
end

local function InstantSkill()
    local line,goal = GetSkill()
    if not (line and goal) then AS.IClicked=false; AS.ILastGoal=0; AS.ILastInst=nil; AS.ICurID=0
        if AS.IConn then AS.IConn:Disconnect(); AS.IConn=nil end; return
    end
    local gr=goal.Rotation%360; local pr=(gr+106)%360
    if not AS.IForce then AS.IForce=true; pcall(function() line.Rotation=pr end); AS.IForce=false end
    local diff=math.abs(gr-AS.ILastGoal); if diff>180 then diff=360-diff end
    local isNew = diff>0.5 or AS.ILastInst~=goal
    if isNew then
        AS.IClicked=false; AS.ICurID=AS.ICurID+1; local id=AS.ICurID
        if AS.IConn then AS.IConn:Disconnect() end
        AS.IConn = line:GetPropertyChangedSignal("Rotation"):Connect(function()
            if AS.IForce then return end; AS.IForce=true
            pcall(function() local _,cg=GetSkill(); if cg then line.Rotation=(cg.Rotation%360+106)%360 end end)
            AS.IForce=false
        end)
        if not AS.IClicked then AS.IClicked=true; task.spawn(function() task.wait(0.05); if AS.ICurID==id then local cl,cg=GetSkill(); if cl and cg and tick()-AS.ILastTick>0.03 then AS.ILastTick=tick(); PressSkill() end end end) end
    end
    AS.ILastGoal=gr; AS.ILastInst=goal
end

RunService.RenderStepped:Connect(function()
    if not VD.AutoSkillcheck then return end
    if VD.AutoSkillcheckMode=="Perfect" then PerfectSkill() elseif VD.AutoSkillcheckMode=="Instant" then InstantSkill() else NormalSkill() end
end)

-- ===================== HEAL SYSTEM =====================
local IHConn=nil; local AHConn=nil
local function doSelfHeal()
    local c=LocalPlayer.Character; if not c then return end
    local r = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Healing") and ReplicatedStorage.Remotes.Healing:FindFirstChild("SkillCheckResultEvent")
    if r then pcall(function() r:FireServer("success",100,c) end) end
end
local function doSelfHealT()
    local c=LocalPlayer.Character; if not c then return end
    local r = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Healing") and ReplicatedStorage.Remotes.Healing:FindFirstChild("HealEvent")
    local hrp=c:FindFirstChild("HumanoidRootPart")
    if r and hrp then pcall(function() r:FireServer(hrp,true) end) end
end
local function doSelfHealF()
    local c=LocalPlayer.Character; if not c then return end
    local r = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Healing") and ReplicatedStorage.Remotes.Healing:FindFirstChild("HealEvent")
    local hrp=c:FindFirstChild("HumanoidRootPart")
    if r and hrp then pcall(function() r:FireServer(hrp,false) end) end
end
local function doOtherHealSC(tp)
    if not tp or not tp.Character then return end
    local r = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Healing") and ReplicatedStorage.Remotes.Healing:FindFirstChild("SkillCheckResultEvent")
    if r then pcall(function() r:FireServer("success",100,tp.Character) end) end
end
local function doOtherHealT(tp)
    if not tp or not tp.Character then return end
    local hrp=tp.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local r = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Healing") and ReplicatedStorage.Remotes.Healing:FindFirstChild("HealEvent")
    if r then pcall(function() r:FireServer(hrp,true) end) end
end
local function doOtherHealF(tp)
    if not tp or not tp.Character then return end
    local hrp=tp.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local r = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Healing") and ReplicatedStorage.Remotes.Healing:FindFirstChild("HealEvent")
    if r then pcall(function() r:FireServer(hrp,false) end) end
end

local function setInstantHeal(v)
    VD.InstantHealSelf=v
    if v then
        local sct=0; local htt=0; local hft=0; local hta=false
        if IHConn then IHConn:Disconnect() end
        IHConn = RunService.Heartbeat:Connect(function(dt)
            if not VD.InstantHealSelf then return end
            local c=LocalPlayer.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
            if not h or h.Health>=h.MaxHealth*0.9 then return end
            sct=sct+dt; if sct>=0.05 then sct=0; doSelfHeal() end
            htt=htt+dt; if htt>=0.06 and not hta then htt=0; hta=true; doSelfHealT() end
            hft=hft+dt; if hft>=0.09 and hta then hft=0; hta=false; doSelfHealF(); htt=-0.10 end
        end)
    else if IHConn then IHConn:Disconnect(); IHConn=nil end end
end

local function setAutoHealAll(v)
    VD.AutoHealAll=v
    if v then
        local timers={}
        if AHConn then AHConn:Disconnect() end
        AHConn = RunService.Heartbeat:Connect(function(dt)
            if not VD.AutoHealAll then return end
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LocalPlayer and p.Character then
                    local hrp=p.Character:FindFirstChild("HumanoidRootPart")
                    local h=p.Character:FindFirstChildOfClass("Humanoid")
                    if h and h.Health>0 and h.Health<h.MaxHealth*0.9 then
                        if not timers[p] then timers[p]={sc=0,t=0,f=0,active=false} end
                        local tm=timers[p]; tm.sc=tm.sc+dt; if tm.sc>=0.05 then tm.sc=0; doOtherHealSC(p) end
                        tm.t=tm.t+dt; if tm.t>=0.09 and not tm.active then tm.t=0; tm.active=true; doOtherHealT(p) end
                        tm.f=tm.f+dt; if tm.f>=0.07 and tm.active then tm.f=0; tm.active=false; doOtherHealF(p); tm.t=-0.10 end
                    else timers[p]=nil end
                end
            end
        end)
    else if AHConn then AHConn:Disconnect(); AHConn=nil end end
end

-- ===================== VEIL SILENT AIM =====================
VeilConfig = {Enabled=false,ShowFOV=true,FOV=150,SpearSpeed=165,Gravity=workspace.Gravity*0.5,MaxDist=200,AutoPredict=false,TargetPart="Torso",HorizontalPredictFactor=2.8}
VeilState = {chargingSpear=false,touchInput=nil,attackCooldown=false,passiveCooldown=false,lastPredictedPos=nil}
VeilVelocityCache = {}
VeilDraw = {FOVCircle=SafeDrawing("Circle"),Highlight=Instance.new("Highlight"),Tracer=SafeDrawing("Circle")}
if VeilDraw.FOVCircle then VeilDraw.FOVCircle.Color=Color3.fromRGB(180,180,180); VeilDraw.FOVCircle.Thickness=1.5; VeilDraw.FOVCircle.Filled=false; VeilDraw.FOVCircle.Visible=false end
VeilDraw.Highlight.Name="VD_VeilTarget"; VeilDraw.Highlight.FillColor=Color3.fromRGB(255,0,0); VeilDraw.Highlight.OutlineColor=Color3.fromRGB(255,255,255); VeilDraw.Highlight.FillTransparency=0.5; VeilDraw.Highlight.OutlineTransparency=0
if VeilDraw.Tracer then VeilDraw.Tracer.Thickness=2; VeilDraw.Tracer.Radius=5; VeilDraw.Tracer.Color=Color3.fromRGB(180,180,180); VeilDraw.Tracer.Filled=true; VeilDraw.Tracer.Visible=false end

function VeilGetVel(part,pn)
    if not part then return Vector3.zero end
    local cp=part.Position; local ct=tick()
    if not VeilVelocityCache[pn] then VeilVelocityCache[pn]={lastPos=cp,lastTime=ct,velocity=Vector3.zero}; return Vector3.zero end
    local c=VeilVelocityCache[pn]; local dt=ct-c.lastTime
    if dt>0.01 then local rv=(cp-c.lastPos)/dt; if rv.Magnitude<100 then c.velocity=c.velocity:Lerp(rv,0.4) end end
    c.lastPos=cp; c.lastTime=ct; return c.velocity
end

function VeilGetPart(char)
    if VeilConfig.TargetPart=="Head" then return char:FindFirstChild("Head")
    elseif VeilConfig.TargetPart=="Root" then return char:FindFirstChild("HumanoidRootPart")
    else return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart") end
end

function VeilGetClosest()
    local mc=LocalPlayer.Character; local mr=mc and mc:FindFirstChild("HumanoidRootPart")
    if not mr then return nil end
    local cam=workspace.CurrentCamera; local c=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
    local bd=VeilConfig.FOV; local bt=nil
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Team and p.Team.Name=="Survivors" and p.Character then
            local ch=p.Character; local h=ch:FindFirstChildOfClass("Humanoid"); local pt=VeilGetPart(ch)
            if h and h.Health>0 and pt then
                local d3=(pt.Position-mr.Position).Magnitude
                if d3<=VeilConfig.MaxDist then
                    local sp,on=cam:WorldToViewportPoint(pt.Position)
                    if on then local d2=(Vector2.new(sp.X,sp.Y)-c).Magnitude; if d2<bd then bd=d2; bt={Player=p,Part=pt} end end
                end
            end
        end
    end
    return bt
end

function VeilFire()
    if VeilState.attackCooldown then return end
    VeilState.attackCooldown=true; task.delay(2,function() VeilState.attackCooldown=false end)
    local mc=LocalPlayer.Character; local sp=mc and (mc:FindFirstChild("Head") or mc:FindFirstChild("HumanoidRootPart"))
    if not sp then return end
    local startPos=sp.Position; local ti=VeilGetClosest(); local aimDir
    if ti and ti.Part then
        local tp=ti.Part; local pp=ti.Player; local tpos=tp.Position
        local vel=VeilGetVel(tp,pp.Name); local hv=Vector3.new(vel.X,0,vel.Z); local speed=hv.Magnitude
        local dist=(tpos-startPos).Magnitude; local tth=dist/VeilConfig.SpearSpeed
        local hp=Vector3.zero; if speed>4 then hp=hv.Unit*VeilConfig.HorizontalPredictFactor end
        local pred=tpos+hp; local dm=math.clamp(dist/100,1,2.5); local ag=math.max(0,dist-8)
        local grav=VeilConfig.AutoPredict and ag or VeilConfig.Gravity
        local drop=0.5*grav*(tth^2)*dm; local fp=pred+Vector3.new(0,drop,0)
        aimDir=(fp-startPos).Unit; VeilState.lastPredictedPos=fp
    else aimDir=workspace.CurrentCamera.CFrame.LookVector; VeilState.lastPredictedPos=nil end
    pcall(function()
        local r=game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        if r then local k=r:FindFirstChild("Killers"); if k then local v=k:FindFirstChild("Veil"); if v and v:FindFirstChild("Spearthrow") then v.Spearthrow:FireServer(aimDir,VeilConfig.SpearSpeed,startPos) end end end
    end)
    if VeilDraw.FOVCircle then VeilDraw.FOVCircle.Color=Color3.fromRGB(180,180,180) end
    if not VeilState.passiveCooldown then VeilState.passiveCooldown=true; task.delay(30,function() if VeilDraw.FOVCircle then VeilDraw.FOVCircle.Color=Color3.fromRGB(180,180,180) end; VeilState.passiveCooldown=false end) end
end

UserInputService.InputBegan:Connect(function(input,gp)
    local isTouch=input.UserInputType==Enum.UserInputType.Touch
    if gp and not isTouch then return end
    local c=LocalPlayer.Character; local isSpear=c and c:GetAttribute("spearmode")==true
    if not VeilConfig.Enabled or not isSpear then return end
    if input.UserInputType==Enum.UserInputType.MouseButton1 then VeilState.chargingSpear=true
    elseif isTouch then
        local pg=LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            local sl=pg:FindFirstChild("Slasher-mob")
            if sl then
                local ctrl=sl:FindFirstChild("Controls")
                if ctrl then
                    local ab=ctrl:FindFirstChild("attack")
                    if ab and ab.Visible then
                        local pos=input.Position; local ap=ab.AbsolutePosition; local as=ab.AbsoluteSize
                        if pos.X>=ap.X and pos.X<=ap.X+as.X and pos.Y>=ap.Y and pos.Y<=ap.Y+as.Y then
                            VeilState.chargingSpear=true; VeilState.touchInput=input
                        end
                    end
                end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input,gp)
    if VeilState.chargingSpear and (input==VeilState.touchInput or input.UserInputType==Enum.UserInputType.MouseButton1) then
        VeilState.chargingSpear=false; if VeilState.touchInput==input then VeilState.touchInput=nil end; VeilFire()
    end
end)

RunService.RenderStepped:Connect(function()
    local cam=workspace.CurrentCamera; local mc=LocalPlayer.Character; local isSpear=mc and mc:GetAttribute("spearmode")==true
    if VeilConfig.Enabled and VeilConfig.ShowFOV and isSpear and VeilDraw.FOVCircle then
        VeilDraw.FOVCircle.Visible=true; VeilDraw.FOVCircle.Radius=VeilConfig.FOV; VeilDraw.FOVCircle.Position=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
    elseif VeilDraw.FOVCircle then VeilDraw.FOVCircle.Visible=false end
    if VeilState.chargingSpear and VeilConfig.Enabled and isSpear then
        local t=VeilGetClosest(); if t and t.Part and t.Part.Parent then VeilDraw.Highlight.Parent=t.Part.Parent else VeilDraw.Highlight.Parent=nil end
    else VeilDraw.Highlight.Parent=nil end
    if VeilConfig.Enabled and isSpear and VeilState.lastPredictedPos and VeilDraw.Tracer then
        local sp,on=cam:WorldToViewportPoint(VeilState.lastPredictedPos); local vp=cam.ViewportSize; local c=Vector2.new(vp.X/2,vp.Y/2)
        if on then VeilDraw.Tracer.Position=Vector2.new(sp.X,sp.Y)
        else
            local dx=sp.X-c.X; local dy=sp.Y-c.Y
            if math.abs(dx)<1 and math.abs(dy)<1 then VeilDraw.Tracer.Position=c
            else
                local a=math.atan2(dy,dx); local mx=vp.X/2-10; local my=vp.Y/2-10
                local sx=mx/math.abs(dx); local sy=my/math.abs(dy); local sc=math.min(sx,sy)
                VeilDraw.Tracer.Position=Vector2.new(c.X+dx*sc,c.Y+dy*sc)
            end
        end
        VeilDraw.Tracer.Visible=true
    elseif VeilDraw.Tracer then VeilDraw.Tracer.Visible=false end
end)

print("[NO MERCY] Veil loaded")


-- ===================== KILLER FEATURES =====================
local LDT=0; local IBP=false; local IBG=false; local LVB=0

local function AutoAttack()
    if not VD.AUTO_Attack or GetRole()~="Killer" then return end
    local r=Root; if not r then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and IsSurvivor(p) and p.Character then
            local tr=p.Character:FindFirstChild("HumanoidRootPart")
            local th=p.Character:FindFirstChildOfClass("Humanoid")
            if tr and th and th.MaxHealth>0 then
                local pct=th.Health/th.MaxHealth
                if pct>0.25 and (tr.Position-r.Position).Magnitude<=VD.AUTO_AttackRange then
                    pcall(function()
                        local re=ReplicatedStorage:FindFirstChild("Remotes")
                        local a=re and re:FindFirstChild("Attacks")
                        local b=a and a:FindFirstChild("BasicAttack")
                        if b then b:FireServer(false) end
                    end)
                    break
                end
            end
        end
    end
end

local function DoubleTap()
    if not VD.KILLER_DoubleTap or GetRole()~="Killer" then return end
    if tick()-LDT<0.5 then return end
    pcall(function()
        local r=ReplicatedStorage:FindFirstChild("Remotes")
        local a=r and r:FindFirstChild("Attacks")
        local b=a and a:FindFirstChild("BasicAttack")
        if b then b:FireServer(false); task.wait(0.05); b:FireServer(false); LDT=tick() end
    end)
end

local function DestroyPallets()
    if not VD.KILLER_DestroyPallets or GetRole()~="Killer" then return end
    if IBP then return end
    local c=LocalPlayer.Character; local r=Root
    if not c or not r then return end
    local st=c:GetAttribute("IsStunned") or c:GetAttribute("isStunned")
    local im=c:GetAttribute("Immobile") or c:GetAttribute("immobile")
    local ca=c:GetAttribute("IsCarrying") or c:GetAttribute("isCarrying")
    local pu=c:GetAttribute("Pursuit") or c:GetAttribute("pursuit")
    local ci=c:FindFirstChild("CheckInterractable")
    local ac=ci and (ci:GetAttribute("action") or ci:GetAttribute("Action"))
    if st or im or ca or pu or ac then return end
    local pts=CollectionService:GetTagged("PalletPointSlide")
    local n,md=nil,6
    for _,p in ipairs(pts) do
        if p:IsA("BasePart") and not CollectionService:HasTag(p,"doing action") then
            local d=(p.Position-r.Position).Magnitude
            if d<md then md=d; n=p end
        end
    end
    if n then
        IBP=true
        task.spawn(function()
            pcall(function()
                local r=ReplicatedStorage:FindFirstChild("Remotes")
                local p=r and r:FindFirstChild("Pallet")
                local j=p and p:FindFirstChild("Jason")
                if j then
                    local dg=j:FindFirstChild("Destroy-Global")
                    local cm=j:FindFirstChild("PalletBreakCommit")
                    if dg and dg:IsA("RemoteEvent") then dg:FireServer(n) end
                    if cm and cm:IsA("RemoteEvent") then cm:FireServer(n) end
                end
            end)
            task.wait(0.2)
            local st=os.clock()
            while c and c.Parent and (c:GetAttribute("Immobile") or c:GetAttribute("immobile")) do
                if os.clock()-st>3 then break end; task.wait(0.1)
            end
            IBP=false
        end)
    end
end

local function BreakGen()
    if not VD.KILLER_AutoBreakGene or GetRole()~="Killer" then return end
    if IBG then return end
    local c=LocalPlayer.Character; local r=Root
    if not c or not r then return end
    local st=c:GetAttribute("IsStunned") or c:GetAttribute("isStunned")
    local im=c:GetAttribute("Immobile") or c:GetAttribute("immobile")
    local ca=c:GetAttribute("IsCarrying") or c:GetAttribute("isCarrying")
    local pu=c:GetAttribute("Pursuit") or c:GetAttribute("pursuit")
    local ci=c:FindFirstChild("CheckInterractable")
    local ac=ci and (ci:GetAttribute("action") or ci:GetAttribute("Action"))
    if st or im or ca or pu or ac then return end
    local pts=CollectionService:GetTagged("GeneratorPoint")
    local n,md=nil,6
    for _,p in ipairs(pts) do
        if p:IsA("BasePart") and not CollectionService:HasTag(p,"doing action") then
            local gm=p.Parent
            if gm then
                local pr=gm:GetAttribute("RepairProgress") or gm:GetAttribute("repairProgress") or 0
                local kc=gm:GetAttribute("kickcount") or gm:GetAttribute("KickCount") or 0
                if pr>0 and pr<100 and kc<=7 then
                    local d=(p.Position-r.Position).Magnitude
                    if d<md then md=d; n=p end
                end
            end
        end
    end
    if n then
        IBG=true
        task.spawn(function()
            pcall(function()
                local r=ReplicatedStorage:FindFirstChild("Remotes")
                local g=r and r:FindFirstChild("Generator")
                if g then
                    local ev=g:FindFirstChild("BreakGenEvent")
                    local cm=g:FindFirstChild("BreakGenCommit")
                    if ev and ev:IsA("RemoteEvent") then ev:FireServer(n) end
                    if cm and cm:IsA("RemoteEvent") then cm:FireServer(n) end
                end
            end)
            task.wait(0.2)
            local st=os.clock()
            while c and c.Parent and (c:GetAttribute("Immobile") or c:GetAttribute("immobile")) do
                if os.clock()-st>3 then break end; task.wait(0.1)
            end
            task.wait(0.3); IBG=false
        end)
    end
end

local function BlockVaults()
    if not VD.KILLER_BlockVaults or GetRole()~="Killer" then return end
    if tick()-LVB<1.5 then return end; LVB=tick()
    pcall(function()
        local r=ReplicatedStorage:FindFirstChild("Remotes")
        local ve=r and r:FindFirstChild("Window") and r.Window:FindFirstChild("VaultEvent")
        if not ve then return end
        local m=Workspace:FindFirstChild("Map")
        local vf=m and m:FindFirstChild("Vaults")
        if vf then
            for _,v in ipairs(vf:GetChildren()) do
                for _,pt in ipairs(v:GetChildren()) do
                    if pt:IsA("BasePart") then pcall(function() ve:FireServer(pt,true) end) end
                end
            end
        else
            for _,w in ipairs(Cache.Windows or {}) do
                local wm=w.model
                if wm and wm.Parent then
                    for _,ch in ipairs(wm:GetDescendants()) do
                        if ch:IsA("BasePart") then pcall(function() ve:FireServer(ch,true) end) end
                    end
                end
            end
        end
    end)
end

-- Heartbeat loop
RunService.Heartbeat:Connect(function()
    if VD.Destroyed then return end
    pcall(AutoAttack); pcall(DestroyPallets); pcall(BreakGen); pcall(BlockVaults); pcall(DoubleTap)
end)

-- Flee Killer
RunService.Heartbeat:Connect(function()
    if VD.SURV_FleeKiller then
        pcall(function()
            local r=Root; if not r then return end; if GetRole()=="Killer" then return end
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LocalPlayer and IsKiller(p) then
                    local kr=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    if kr and (kr.Position-r.Position).Magnitude<=(VD.SURV_FleeDistance or 40) then
                        local dir=(r.Position-kr.Position).Unit
                        r.CFrame=CFrame.new(r.Position+dir*((VD.SURV_FleeDistance or 40)+15), r.Position+dir*100)
                        break
                    end
                end
            end
        end)
    end
end)

-- Map scan loop
task.spawn(function() while not VD.Destroyed do pcall(ScanMap); task.wait(0.5) end end)

print("[NO MERCY] Killer & Map systems loaded")


-- ===================== DRAWING ESP =====================
local DESP = {cache={}, velData={}}
local Perf = {NextESP=0, Interval=0.1}

local function DESP_create()
    local b=SafeDrawing("Square"); if b then b.Filled=false; b.Thickness=1; b.Visible=false end
    local hb=SafeDrawing("Square"); if hb then hb.Filled=true; hb.Color=Color3.fromRGB(25,25,25); hb.Visible=false end
    local h=SafeDrawing("Square"); if h then h.Filled=true; h.Visible=false end
    local n=SafeDrawing("Text"); if n then n.Size=14; n.Font=Drawing.Fonts.UI; n.Center=true; n.Outline=true; n.Visible=false end
    local d=SafeDrawing("Text"); if d then d.Size=12; d.Font=Drawing.Fonts.Monospace; d.Center=true; d.Outline=true; d.Color=Color3.fromRGB(180,180,180); d.Visible=false end
    local sk={}; for i=1,7 do local l=SafeDrawing("Line"); if l then l.Thickness=1; l.Visible=false end; sk[i]=l end
    local os=SafeDrawing("Triangle"); if os then os.Filled=true; os.Visible=false end
    local vl=SafeDrawing("Line"); if vl then vl.Thickness=2; vl.Color=Color3.fromRGB(0,255,255); vl.Visible=false end
    local va=SafeDrawing("Triangle"); if va then va.Filled=true; va.Color=Color3.fromRGB(0,255,255); va.Visible=false end
    return {Box=b,HB=hb,H=h,Name=n,Dist=d,Skel=sk,Off=os,VL=vl,VA=va}
end

local function DESP_hide(e)
    if not e then return end
    if e.Box then e.Box.Visible=false end; if e.HB then e.HB.Visible=false end; if e.H then e.H.Visible=false end
    if e.Name then e.Name.Visible=false end; if e.Dist then e.Dist.Visible=false end; if e.Off then e.Off.Visible=false end
    if e.VL then e.VL.Visible=false end; if e.VA then e.VA.Visible=false end
    for _,l in ipairs(e.Skel) do if l then l.Visible=false end end
end

local function DESP_render(e,p,char,cam,ss,sc)
    if not e or not char then return end
    local root=char:FindFirstChild("HumanoidRootPart"); local head=char:FindFirstChild("Head"); local hum=char:FindFirstChildOfClass("Humanoid")
    if not root or not head then DESP_hide(e); return end
    local mr=Root; local dist=mr and (root.Position-mr.Position).Magnitude or 0
    if dist>VD.MaxDistance then DESP_hide(e); return end
    local isK=IsKiller(p); local col=isK and Color3.fromRGB(255,120,120) or Color3.fromRGB(120,255,170)
    local scol=Color3.fromRGB(150,255,150)
    local hp=head.Position+Vector3.new(0,0.5,0); local fp=root.Position-Vector3.new(0,3,0)
    local rs=cam:WorldToViewportPoint(root.Position); local hs=cam:WorldToViewportPoint(hp); local fs=cam:WorldToViewportPoint(fp)
    local on=rs.Z>0 and rs.X>0 and rs.X<ss.X and rs.Y>0 and rs.Y<ss.Y
    if not on then DESP_hide(e); if VD.ESP_Offscreen and not VD.ESP_LowPerformance and e.Off then
        local dx=rs.X-sc.X; local dy=rs.Y-sc.Y; local a=math.atan2(dy,dx); local edge=50
        local ax=math.clamp(sc.X+math.cos(a)*(ss.X/2-edge),edge,ss.X-edge); local ay=math.clamp(sc.Y+math.sin(a)*(ss.Y/2-edge),edge,ss.Y-edge)
        local fwd=Vector2.new(math.cos(a),math.sin(a)); local rt=Vector2.new(-fwd.Y,fwd.X); local pos=Vector2.new(ax,ay); local sz=12
        e.Off.PointA=pos+fwd*sz; e.Off.PointB=pos-fwd*sz/2-rt*sz/2; e.Off.PointC=pos-fwd*sz/2+rt*sz/2; e.Off.Color=col; e.Off.Visible=true
    end; return end
    if e.Off then e.Off.Visible=false end
    local bt=hs.Y; local bb=fs.Y; local bh=math.abs(bb-bt); local bw=bh*0.6; local cx=rs.X
    if e.Box then e.Box.Position=Vector2.new(cx-bw/2,bt); e.Box.Size=Vector2.new(bw,bh); e.Box.Color=col; e.Box.Visible=true end
    if hum and hum.MaxHealth>0 and e.HB and e.H then
        local pct=math.clamp(hum.Health/hum.MaxHealth,0,1); local bw2=bw*0.8; local bh2=4; local bx=cx-bw2/2; local by=bb+2
        e.HB.Position=Vector2.new(bx,by); e.HB.Size=Vector2.new(bw2,bh2); e.HB.Visible=true
        e.H.Position=Vector2.new(bx,by); e.H.Size=Vector2.new(bw2*pct,bh2); e.H.Color=Color3.fromRGB(255*(1-pct),255*pct,0); e.H.Visible=true
    else if e.HB then e.HB.Visible=false end; if e.H then e.H.Visible=false end end
    if e.Name then e.Name.Text=p.Name; e.Name.Position=Vector2.new(cx,bt-18); e.Name.Color=col; e.Name.Visible=true end
    if e.Dist then e.Dist.Text=math.floor(dist).."m"; e.Dist.Position=Vector2.new(cx,bb+2+(hum and hum.MaxHealth>0 and 6 or 2)); e.Dist.Visible=true end
    if VD.ESP_Skeleton and not VD.ESP_LowPerformance and hum then
        local bones=(char:FindFirstChild("Torso") and {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"UpperTorso","RightUpperArm"},{"LowerTorso","LeftUpperLeg"},{"LowerTorso","RightUpperLeg"},{"LeftUpperArm","LeftLowerArm"},{"RightUpperArm","RightLowerArm"},{"LeftUpperLeg","LeftLowerLeg"},{"RightUpperLeg","RightLowerLeg"}}) or {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
        local ml=math.min(#bones,#e.Skel)
        for i=1,ml do
            local b=bones[i]; if e.Skel[i] then
                local p1=char:FindFirstChild(b[1]); local p2=char:FindFirstChild(b[2])
                if p1 and p2 then
                    local s1=cam:WorldToViewportPoint(p1.Position); local s2=cam:WorldToViewportPoint(p2.Position)
                    if s1.Z>0 and s2.Z>0 then e.Skel[i].From=Vector2.new(s1.X,s1.Y); e.Skel[i].To=Vector2.new(s2.X,s2.Y); e.Skel[i].Color=scol; e.Skel[i].Visible=true else e.Skel[i].Visible=false end
                else e.Skel[i].Visible=false end
            end
        end
        for i=ml+1,#e.Skel do if e.Skel[i] then e.Skel[i].Visible=false end end
    else for _,l in ipairs(e.Skel) do if l then l.Visible=false end end end
    if VD.ESP_Velocity and not VD.ESP_LowPerformance then
        local vd=DESP.velData[p]; if not vd then vd={pos=root.Position,vel=Vector3.zero,time=tick()}; DESP.velData[p]=vd end
        local now=tick(); local dt=now-vd.time
        if dt>0.03 then local rv=(root.Position-vd.pos)/dt; if rv.Magnitude<100 then vd.vel=vd.vel*0.7+rv*0.3 end; vd.pos=root.Position; vd.time=now end
        local vf=Vector3.new(vd.vel.X,0,vd.vel.Z); local vm=vf.Magnitude
        if vm>2 then
            local fp=root.Position+vf.Unit*math.clamp(vm*0.4,5,20); local fsp,on2=cam:WorldToViewportPoint(fp)
            if on2 then if e.VL then e.VL.From=Vector2.new(rs.X,rs.Y); e.VL.To=Vector2.new(fsp.X,fsp.Y); e.VL.Visible=true end
                local dx=fsp.X-rs.X; local dy=fsp.Y-rs.Y; local len=math.sqrt(dx*dx+dy*dy)
                if len>5 and e.VA then local fx,fy=dx/len,dy/len; e.VA.PointA=Vector2.new(fsp.X,fsp.Y); e.VA.PointB=Vector2.new(fsp.X-fx*10+fy*5,fsp.Y-fy*10-fx*5); e.VA.PointC=Vector2.new(fsp.X-fx*10-fy*5,fsp.Y-fy*10+fx*5); e.VA.Visible=true elseif e.VA then e.VA.Visible=false end
            else if e.VL then e.VL.Visible=false end; if e.VA then e.VA.Visible=false end end
        else if e.VL then e.VL.Visible=false end; if e.VA then e.VA.Visible=false end end
    else if e.VL then e.VL.Visible=false end; if e.VA then e.VA.Visible=false end end
end

local function OnRender()
    if VD.Destroyed then
        if DrawingAvailable then
            for _,e in pairs(DESP.cache) do if e then SafeRemove(e.Box); SafeRemove(e.HB); SafeRemove(e.H); SafeRemove(e.Name); SafeRemove(e.Dist); SafeRemove(e.Off); SafeRemove(e.VL); SafeRemove(e.VA); for _,l in ipairs(e.Skel) do SafeRemove(l) end end end
            DESP.cache={}
        end; return
    end
    Camera=Workspace.CurrentCamera or Camera; local cam=Camera; if not cam then return end
    local ss=cam.ViewportSize; local sc=Vector2.new(ss.X/2,ss.Y/2); local now=tick()
    local canUpdate=now>=Perf.NextESP; if canUpdate then Perf.NextESP=now+Perf.Interval end
    if DrawingAvailable then
        if VD.DRAWING_ESP then
            if canUpdate then
                local vp={}; for _,p in ipairs(Players:GetPlayers()) do vp[p]=true end
                for p,e in pairs(DESP.cache) do if not vp[p] then if e then SafeRemove(e.Box); SafeRemove(e.HB); SafeRemove(e.H); SafeRemove(e.Name); SafeRemove(e.Dist); SafeRemove(e.Off); SafeRemove(e.VL); SafeRemove(e.VA); for _,l in ipairs(e.Skel) do SafeRemove(l) end end; DESP.cache[p]=nil; DESP.velData[p]=nil end end
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        if not DESP.cache[p] then DESP.cache[p]=DESP_create() end
                        DESP_render(DESP.cache[p],p,p.Character,cam,ss,sc)
                    end
                end
            end
        else
            for _,e in pairs(DESP.cache) do if e then SafeRemove(e.Box); SafeRemove(e.HB); SafeRemove(e.H); SafeRemove(e.Name); SafeRemove(e.Dist); SafeRemove(e.Off); SafeRemove(e.VL); SafeRemove(e.VA); for _,l in ipairs(e.Skel) do SafeRemove(l) end end end
            DESP.cache={}
        end
    end
end

if DrawingAvailable then RunService.RenderStepped:Connect(OnRender) end

-- ===================== AUTO DROP PALLET =====================
local usedPallets={}; local lastDrop=0; local lastPScan=0
RunService.Heartbeat:Connect(function()
    if not VD.SURV_AutoDropPallet or GetRole()~="Survivor" then return end
    if tick()-lastPScan<0.2 or tick()-lastDrop<2.5 then return end; lastPScan=tick()
    pcall(function()
        local c=LocalPlayer.Character; local mhrp=c and c:FindFirstChild("HumanoidRootPart")
        local h=c and c:FindFirstChildOfClass("Humanoid")
        if not mhrp or not h or h.Health<=0 then return end
        if VD.SURV_AutoDropPalletMode=="Safe" then
            local ic=c:GetAttribute("IsCarried") or c:GetAttribute("isCarried"); if ic then return end
        end
        local kr=nil; local td=VD.SURV_AutoDropPalletDist or 20
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl~=LocalPlayer and IsKiller(pl) and pl.Character then
                local krr=pl.Character:FindFirstChild("HumanoidRootPart")
                if krr and (krr.Position-mhrp.Position).Magnitude<td then kr=krr; break end
            end
        end
        if not kr then return end
        local r=ReplicatedStorage:FindFirstChild("Remotes"); local pf=r and r:FindFirstChild("Pallet"); local de=pf and pf:FindFirstChild("PalletDropEvent")
        if not de then return end
        local bp,bd=nil,8
        for _,pal in ipairs(Cache.Pallets) do
            local pm=pal.model; if not pm then continue end; if usedPallets[pm] then continue end
            local rp=pal.part or pm:FindFirstChild("PalletPoint") or pm:FindFirstChild("PalletPointSlide")
            if not rp then continue end
            local ok,pos=pcall(function() return rp.Position end); if not ok or not pos then continue end
            local d=(mhrp.Position-pos).Magnitude; if d<bd then bd=d; bp=pm end
        end
        if bp then
            local ft=bp:FindFirstChild("PalletPointSlide") or bp:FindFirstChild("PalletPoint")
            if ft then pcall(function() de:FireServer(ft) end); usedPallets[bp]=true; lastDrop=tick(); task.delay(3,function() usedPallets[bp]=nil end) end
        end
    end)
end)

-- ===================== AUTO VAULT & PALLET SLIDE =====================
local vWins={}; local lastVScan=0; local lastPSScan=0; local sPallets={}
RunService.Heartbeat:Connect(function()
    -- Auto Vault
    if VD.SURV_AutoVault and GetRole()=="Survivor" and tick()-lastVScan>0.15 then
        lastVScan=tick()
        pcall(function()
            local c=LocalPlayer.Character; local mhrp=c and c:FindFirstChild("HumanoidRootPart")
            local h=c and c:FindFirstChildOfClass("Humanoid")
            if not mhrp or not h or h.Health<=0 then return end
            local vel=mhrp.AssemblyLinearVelocity; if vel.Magnitude<1 then return end
            local r=ReplicatedStorage:FindFirstChild("Remotes"); local wf=r and r:FindFirstChild("Window"); local vc=wf and wf:FindFirstChild("VaultCommit")
            if not vc then return end
            local wgs={}
            for _,w in ipairs(Cache.Windows or {}) do
                local pt=w.part or w.model; if pt then
                    local rw=pt.Parent; if pt.Name=="VaultPoint" and pt.Parent and pt.Parent.Name=="VaultTrigger" then rw=pt.Parent.Parent elseif pt.Name=="VaultTrigger" and pt.Parent then rw=pt.Parent end
                    if rw then wgs[rw]=wgs[rw] or {}; local ex=false; for _,p in ipairs(wgs[rw]) do if p==pt then ex=true; break end end; if not ex then table.insert(wgs[rw],pt) end end
                end
            end
            for rw,pts in pairs(wgs) do
                local function gvp(vt) if vt:IsA("BasePart") then return vt.Position end; if vt:IsA("Model") then if vt.PrimaryPart then return vt.PrimaryPart.Position end; local bp=vt:FindFirstChildWhichIsA("BasePart",true); if bp then return bp.Position end end; return nil end
                local avts={}; for _,ch in ipairs(rw:GetChildren()) do if ch.Name=="VaultTrigger" then table.insert(avts,ch) end end; if #avts==0 then continue end
                local nvt,nvd=nil,math.huge; for _,vt in ipairs(avts) do local pos=gvp(vt); if pos then local d=(mhrp.Position-pos).Magnitude; if d<nvd then nvd=d; nvt=vt end end end
                if not nvt or nvd>6 then continue end
                local lu=vWins[rw] or 0; if tick()-lu<3 then continue end
                local ft=nvt
                local r2=ReplicatedStorage:FindFirstChild("Remotes"); local w2=r2 and r2:FindFirstChild("Window")
                if w2 and ft then
                    local ve=w2:FindFirstChild("VaultEvent"); local vb=w2:FindFirstChild("Vaultbindable"); local fv=w2:FindFirstChild("fastvault"); local vc1=w2:FindFirstChild("VaultCompleteEventpart1"); local vce=w2:FindFirstChild("VaultCompleteEvent")
                    if ve then pcall(function() ve:FireServer(ft,true) end) end; if vb then pcall(function() vb:Fire(ft,true) end) end; if fv then pcall(function() fv:FireServer(LocalPlayer) end) end; if vc1 then pcall(function() vc1:FireServer() end) end; if vce then pcall(function() vce:FireServer(ft,false) end) end
                end
                vWins[rw]=tick(); break
            end
        end)
    end
    -- Auto Pallet Slide
    if VD.SURV_AutoPalletSlide and GetRole()=="Survivor" and tick()-lastPSScan>0.15 then
        lastPSScan=tick()
        pcall(function()
            local c=LocalPlayer.Character; local mhrp=c and c:FindFirstChild("HumanoidRootPart")
            local h=c and c:FindFirstChildOfClass("Humanoid")
            if not mhrp or not h or h.Health<=0 then return end
            local vel=mhrp.AssemblyLinearVelocity; if vel.Magnitude<1 then return end
            local r=ReplicatedStorage:FindFirstChild("Remotes"); local pf=r and r:FindFirstChild("Pallet")
            local pse=pf and pf:FindFirstChild("PalletSlideEvent"); local sb=pf and pf:FindFirstChild("Slidebindable")
            if not pse then return end
            local bp,bd=nil,6
            local tagged=CollectionService:GetTagged("PalletPointSlide")
            for _,pt in ipairs(tagged) do
                if not pt:IsA("BasePart") then continue end; if pt:IsDescendantOf(c) then continue end; if sPallets[pt] then continue end
                local pm=pt.Parent; local ok,dest=pcall(function() return pm:GetAttribute("Destroyed") end)
                if ok and dest==true then continue end
                local d=(pt.Position-mhrp.Position).Magnitude; if d<bd then bd=d; bp=pt end
            end
            if not bp then
                for _,pal in ipairs(Cache.Pallets or {}) do
                    local pm=pal.model; if not pm then continue end; if sPallets[pm] then continue end
                    local s=pm:FindFirstChild("PalletPointSlide") or pm:FindFirstChild("PalletPointSlide",true)
                    if not s then continue end; local ok2,dest2=pcall(function() return pm:GetAttribute("Destroyed") end)
                    if ok2 and dest2==true then continue end; local d=(s.Position-mhrp.Position).Magnitude; if d<bd then bd=d; bp=s end
                end
            end
            if bp then
                local isSprint=c and c:GetAttribute("Sprinting") or false
                pcall(function() pse:FireServer(bp,isSprint) end)
                if sb then pcall(function() sb:Fire(bp,isSprint) end) end
                sPallets[bp]=true; lastPSScan=tick()+3.8; task.delay(3,function() sPallets[bp]=nil end)
            end
        end)
    end
end)

-- ===================== LIGHTING =====================
local defLight={Brightness=Lighting.Brightness,Ambient=Lighting.Ambient,OutdoorAmbient=Lighting.OutdoorAmbient,FogEnd=Lighting.FogEnd,FogStart=Lighting.FogStart}
local function applyFB(s) if s then Lighting.Brightness=1; Lighting.Ambient=Color3.new(1,1,1); Lighting.OutdoorAmbient=Color3.new(1,1,1) else Lighting.Brightness=defLight.Brightness; Lighting.Ambient=defLight.Ambient; Lighting.OutdoorAmbient=defLight.OutdoorAmbient end end
local function applyNF(s) if s then Lighting.FogEnd=9999; Lighting.FogStart=0 else Lighting.FogEnd=defLight.FogEnd; Lighting.FogStart=defLight.FogStart end end

print("[NO MERCY] ESP & Auto features loaded")


-- ===================== UI TABS =====================
local InfoTab     = Window:MakeTab({Name="Info", Icon=ICON.Info, PremiumOnly=false})
local AimbotTab   = Window:MakeTab({Name="Aimbot", Icon=ICON.Crosshair, PremiumOnly=false})
local ParryTab    = Window:MakeTab({Name="Parry", Icon=ICON.Swords, PremiumOnly=false})
local TeleportTab = Window:MakeTab({Name="Teleport", Icon=ICON.Globe, PremiumOnly=false})
local KillerTab   = Window:MakeTab({Name="Killer", Icon=ICON.Axe, PremiumOnly=false})
local SurvivorTab = Window:MakeTab({Name="Survivor", Icon=ICON.User, PremiumOnly=false})
local PlayerTab   = Window:MakeTab({Name="Player", Icon=ICON.User, PremiumOnly=false})
local VisualTab   = Window:MakeTab({Name="Visual", Icon=ICON.Eye, PremiumOnly=false})
local SpeedTab    = Window:MakeTab({Name="Speed", Icon=ICON.Zap, PremiumOnly=false})
local SettingsTab = Window:MakeTab({Name="Settings", Icon=ICON.Settings, PremiumOnly=false})

-- INFO
local InfoSec=InfoTab:AddSection({Name="Tentang"})
InfoSec:AddLabel("NO MERCY — Violence District")
InfoSec:AddLabel("Game: Bola Pedang (Blade Ball)")
InfoSec:AddButton({Name="Copy Link Discord", Callback=function() if setclipboard then setclipboard("https://discord.gg/pbg6g79Hp") end; VD_Notify("NO MERCY","Link Discord di-copy!",3) end})

task.spawn(function()
    task.wait(0.3)
    local main=FindMain(); if not main then return end
    for _,v in ipairs(main:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text=="Tentang" then
            local container=v.Parent.Parent
            if container and container:IsA("ScrollingFrame") then
                for _,ch in ipairs(container:GetChildren()) do if ch.Name=="AbsoluteTopBanner" then ch:Destroy() end end
                local bf=Instance.new("Frame"); bf.Name="AbsoluteTopBanner"; bf.Size=UDim2.new(1,-10,0,115); bf.BackgroundColor3=Color3.fromRGB(15,15,20); bf.BorderSizePixel=0; bf.LayoutOrder=-999; bf.Parent=container
                Instance.new("UICorner").CornerRadius=UDim.new(0,8); bf:FindFirstChildOfClass("UICorner").Parent=bf
                local bi=Instance.new("ImageLabel"); bi.Size=UDim2.new(1,0,1,0); bi.Image=ICON.Banner; bi.BackgroundTransparency=1; bi.ScaleType=Enum.ScaleType.Fit; bi.Parent=bf
                Instance.new("UICorner").CornerRadius=UDim.new(0,8); bi:FindFirstChildOfClass("UICorner").Parent=bi
                break
            end
        end
    end
end)

-- AIMBOT
local AimMain=AimbotTab:AddSection({Name="Main"})
AimMain:AddToggle({Name="Enable Aimbot",Default=VD.AIM_Enabled or false,Callback=function(v) VD.AIM_Enabled=v end})
AimMain:AddToggle({Name="Silent Aim Veil",Default=VD.SPEAR_Aimbot or false,Callback=function(v) VD.SPEAR_Aimbot=v; VeilConfig.Enabled=v end})
local AimTarget=AimbotTab:AddSection({Name="Target"})
AimTarget:AddDropdown({Name="ToF Target Mode",Default=VD.AUTO_ToFTargetMode or "Killer",Options={"Killer","Survivor","SCP"},Callback=function(v) VD.AUTO_ToFTargetMode=v end})
AimTarget:AddDropdown({Name="ToF Aim Part",Default=VD.AUTO_ToFAimPart or "HumanoidRootPart",Options={"HumanoidRootPart","Head","Torso"},Callback=function(v) VD.AUTO_ToFAimPart=v end})
local AimFOV=AimbotTab:AddSection({Name="FOV"})
AimFOV:AddSlider({Name="FOV Radius",Min=50,Max=500,Default=VeilConfig.FOV or 150,Increment=10,Callback=function(v) VeilConfig.FOV=v end})
AimFOV:AddToggle({Name="Show FOV Circle",Default=VeilConfig.ShowFOV,Callback=function(v) VeilConfig.ShowFOV=v end})
local AimPred=AimbotTab:AddSection({Name="Prediction"})
AimPred:AddToggle({Name="ToF Prediction",Default=VD.AUTO_ToFPredict,Callback=function(v) VD.AUTO_ToFPredict=v end})
AimPred:AddSlider({Name="ToF Bullet Speed",Min=50,Max=1000,Default=VD.AUTO_ToFBulletSpeed or 200,Increment=10,Callback=function(v) VD.AUTO_ToFBulletSpeed=v end})
AimPred:AddSlider({Name="Spear Speed",Min=50,Max=300,Default=VeilConfig.SpearSpeed or 165,Increment=5,Callback=function(v) VeilConfig.SpearSpeed=v end})
AimPred:AddSlider({Name="Gravity",Min=0,Max=300,Default=VeilConfig.Gravity or math.floor(workspace.Gravity*0.5),Increment=5,Callback=function(v) VeilConfig.Gravity=v end})
AimPred:AddSlider({Name="Horizontal Vector",Min=0,Max=10,Default=VeilConfig.HorizontalPredictFactor or 2.8,Increment=0.1,Callback=function(v) VeilConfig.HorizontalPredictFactor=v end})
AimPred:AddSlider({Name="Aim Strictness (Dot)",Min=-1,Max=1,Default=VD.AUTO_ToFDotThreshold or 0.5,Increment=0.05,Callback=function(v) VD.AUTO_ToFDotThreshold=v end})
AimPred:AddSlider({Name="ToF Aim Range (studs)",Min=10,Max=300,Default=VD.AUTO_ToFAimRange or 90,Increment=5,Callback=function(v) VD.AUTO_ToFAimRange=v end})

-- PARRY
local ParryMain=ParryTab:AddSection({Name="Auto Parry"})
ParryMain:AddToggle({Name="Enable Auto Parry",Default=VD.SURV_AutoParry,Callback=function(v) VD.SURV_AutoParry=v; if not v then ParryRange.Transparency=1; ResetParry() end end})
ParryMain:AddDropdown({Name="Parry Mode",Default=VD.SURV_ParryMode or "Legit",Options={"Legit","Aggressive"},Callback=function(v) VD.SURV_ParryMode=v end})
ParryMain:AddDropdown({Name="Parry Animation",Default="Default",Options={"Default","Shield","Robot","Katana","Fish","Watcher"},Callback=function(v)
    local am={Default="rbxassetid://109133187196613",Shield="rbxassetid://75939529748815",Robot="rbxassetid://126894569253341",Katana="rbxassetid://127096285501517",Fish="rbxassetid://123307242865945",Watcher="rbxassetid://81793464499285"}
    VD.SURV_ParryAnimId=am[v] or am.Default
end})
ParryMain:AddSlider({Name="Parry Range",Min=2,Max=20,Default=VD.SURV_ParryRange or 12,Increment=0.5,Callback=function(v) VD.SURV_ParryRange=v; ParryRange.Radius=v; ParryRange.InnerRadius=math.max(0.1,v-0.15) end})
ParryMain:AddToggle({Name="Show Parry Range Circle",Default=VD.SURV_ShowParryCircle,Callback=function(v) VD.SURV_ShowParryCircle=v; if not v then ParryRange.Transparency=1 end end})

-- TELEPORT
local TelePlayer=TeleportTab:AddSection({Name="Player"})
local tpNames={}
local function refreshTP() tpNames={}; for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(tpNames,p.Name) end end; table.sort(tpNames) end
refreshTP()
local tpDD=TelePlayer:AddDropdown({Name="Select Player",Default="",Options=tpNames,Callback=function(v) VD.TP_TargetPlayer=v end})
TelePlayer:AddButton({Name="Refresh Players",Callback=function() refreshTP(); pcall(function() tpDD:Refresh(tpNames) end) end})
TelePlayer:AddButton({Name="Teleport to Player",Callback=function() pcall(function() local tn=VD.TP_TargetPlayer; if not tn or tn=="" then return end; local tp=Players:FindFirstChild(tn); local r=Root; local tr=tp and tp.Character and tp.Character:FindFirstChild("HumanoidRootPart"); if r and tr then r.CFrame=tr.CFrame*CFrame.new(0,0,3) end end) end})
local TeleObj=TeleportTab:AddSection({Name="Objectives"})
TeleObj:AddButton({Name="TP to Generator (Nearest)",Callback=function() pcall(function() IYAN_TeleportToGen(1) end) end})
TeleObj:AddButton({Name="TP to Gate",Callback=function() pcall(IYAN_TeleportToGate) end})
TeleObj:AddButton({Name="TP to Hook",Callback=function() pcall(IYAN_TeleportToHook) end})

-- KILLER
local KillerGen=KillerTab:AddSection({Name="General"})
KillerGen:AddToggle({Name="Auto Attack",Default=VD.AUTO_Attack,Callback=function(v) VD.AUTO_Attack=v end})
KillerGen:AddSlider({Name="Attack Range",Min=5,Max=20,Default=VD.AUTO_AttackRange or 12,Increment=1,Callback=function(v) VD.AUTO_AttackRange=v end})
KillerGen:AddToggle({Name="Double Tap",Default=VD.KILLER_DoubleTap,Callback=function(v) VD.KILLER_DoubleTap=v end})
KillerGen:AddToggle({Name="Auto Kick Pallet",Default=VD.KILLER_DestroyPallets,Callback=function(v) VD.KILLER_DestroyPallets=v end})
KillerGen:AddToggle({Name="Auto Kick Generator",Default=VD.KILLER_AutoBreakGene,Callback=function(v) VD.KILLER_AutoBreakGene=v end})
KillerGen:AddToggle({Name="Block All Vaults",Default=VD.KILLER_BlockVaults,Callback=function(v) VD.KILLER_BlockVaults=v end})
KillerGen:AddToggle({Name="Anti Blind (Flashlight)",Default=VD.KILLER_AntiBlind,Callback=function(v) VD.KILLER_AntiBlind=v end})
local KillerSilent=KillerTab:AddSection({Name="Silent Aim"})
KillerSilent:AddToggle({Name="Silent Aim Veil",Default=VeilConfig.Enabled,Callback=function(v) VeilConfig.Enabled=v; VD.SPEAR_Aimbot=v end})
KillerSilent:AddToggle({Name="Show FOV",Default=VeilConfig.ShowFOV,Callback=function(v) VeilConfig.ShowFOV=v end})
KillerSilent:AddSlider({Name="FOV Radius",Min=50,Max=500,Default=VeilConfig.FOV or 150,Increment=10,Callback=function(v) VeilConfig.FOV=v end})
KillerSilent:AddToggle({Name="Auto Predict",Default=VeilConfig.AutoPredict,Callback=function(v) VeilConfig.AutoPredict=v end})
KillerSilent:AddSlider({Name="Spear Speed",Min=50,Max=300,Default=VeilConfig.SpearSpeed or 165,Increment=5,Callback=function(v) VeilConfig.SpearSpeed=v end})
KillerSilent:AddSlider({Name="Gravity",Min=0,Max=300,Default=VeilConfig.Gravity or math.floor(workspace.Gravity*0.5),Increment=5,Callback=function(v) VeilConfig.Gravity=v end})
KillerSilent:AddSlider({Name="Horizontal Prediction",Min=0,Max=10,Default=VeilConfig.HorizontalPredictFactor or 2.8,Increment=0.1,Callback=function(v) VeilConfig.HorizontalPredictFactor=v end})
KillerSilent:AddDropdown({Name="Target Part",Default=VeilConfig.TargetPart or "Torso",Options={"Torso","Head","Root"},Callback=function(v) VeilConfig.TargetPart=v end})
local KillerCust=KillerTab:AddSection({Name="Customization"})
local cmm={"Richard","Tony","Brandon","Jake","Richter","Graham","Alex"}
KillerCust:AddDropdown({Name="Custom Masked",Default=VD.KILLER_CustomMasked or "Richard",Options=cmm,Callback=function(v) VD.KILLER_CustomMasked=v end})
KillerCust:AddButton({Name="Apply",Callback=function() pcall(ApplyMasked,VD.KILLER_CustomMasked) end})
KillerCust:AddButton({Name="Random",Callback=function() local m=cmm[math.random(1,#cmm)]; VD.KILLER_CustomMasked=m; pcall(ApplyMasked,m) end})

-- SURVIVOR
local GenSec=SurvivorTab:AddSection({Name="Generator"})
GenSec:AddToggle({Name="Gen Boost (BEST)",Default=VD.SURV_GenBoost,Callback=function(v) VD.SURV_GenBoost=v; if v then startGenBoost() else stopGenBoost() end end})
GenSec:AddToggle({Name="Draggable Mode (Bypass Button)",Default=VD.SURV_DraggableGenBypass,Callback=function(v) VD.SURV_DraggableGenBypass=v end})
GenSec:AddToggle({Name="Auto Skillcheck",Default=VD.AutoSkillcheck,Callback=function(v) VD.AutoSkillcheck=v; if not v then if AS.IConn then AS.IConn:Disconnect(); AS.IConn=nil end; AS.IClicked=false; AS.Active=false; AS.PActive=false end end})
GenSec:AddDropdown({Name="Skillcheck Mode",Default=VD.AutoSkillcheckMode or "Normal",Options={"Normal","Perfect","Instant"},Callback=function(v) VD.AutoSkillcheckMode=v end})
GenSec:AddToggle({Name="Auto Drop Pallet",Default=VD.SURV_AutoDropPallet,Callback=function(v) VD.SURV_AutoDropPallet=v; VD_Notify("Auto Drop Pallet",v and "Enabled" or "Disabled",2) end})
GenSec:AddSlider({Name="Pallet Trigger Range",Min=5,Max=50,Default=VD.SURV_AutoDropPalletDist or 20,Increment=1,Callback=function(v) VD.SURV_AutoDropPalletDist=v end})
GenSec:AddDropdown({Name="Pallet Mode",Default=VD.SURV_AutoDropPalletMode or "Aggressive",Options={"Aggressive","Safe"},Callback=function(v) VD.SURV_AutoDropPalletMode=v end})
GenSec:AddToggle({Name="Auto Vault",Default=VD.SURV_AutoVault,Callback=function(v) VD.SURV_AutoVault=v end})
GenSec:AddToggle({Name="Auto Pallet (Slide)",Default=VD.SURV_AutoPalletSlide,Callback=function(v) VD.SURV_AutoPalletSlide=v end})
GenSec:AddToggle({Name="Flee Killer",Default=VD.SURV_FleeKiller,Callback=function(v) VD.SURV_FleeKiller=v end})
GenSec:AddSlider({Name="Flee Distance",Min=15,Max=80,Default=VD.SURV_FleeDistance or 40,Increment=1,Callback=function(v) VD.SURV_FleeDistance=v end})
GenSec:AddToggle({Name="Anti Knock",Default=VD.SURV_AntiKnock,Callback=function(v) VD.SURV_AntiKnock=v end})
GenSec:AddToggle({Name="First Person Camera",Default=VD.SURV_FirstPerson,Callback=function(v) VD.SURV_FirstPerson=v end})

-- PLAYER
local PlayerTele=PlayerTab:AddSection({Name="Teleport"})
local tpDD2=PlayerTele:AddDropdown({Name="Select Player",Default="",Options=tpNames,Callback=function(v) VD.TP_TargetPlayer=v end})
PlayerTele:AddButton({Name="Refresh Players",Callback=function() refreshTP(); pcall(function() tpDD2:Refresh(tpNames) end) end})
PlayerTele:AddButton({Name="Teleport to Player",Callback=function() pcall(function() local tn=VD.TP_TargetPlayer; if not tn or tn=="" then return end; local tp=Players:FindFirstChild(tn); local r=Root; local tr=tp and tp.Character and tp.Character:FindFirstChild("HumanoidRootPart"); if r and tr then r.CFrame=tr.CFrame*CFrame.new(0,0,3) end end) end})
PlayerTele:AddButton({Name="TP to Generator",Callback=function() pcall(function() IYAN_TeleportToGen(1) end) end})
PlayerTele:AddButton({Name="TP to Gate",Callback=function() pcall(IYAN_TeleportToGate) end})
PlayerTele:AddButton({Name="TP to Hook",Callback=function() pcall(IYAN_TeleportToHook) end})
local PlayerFling=PlayerTab:AddSection({Name="Fling"})
PlayerFling:AddToggle({Name="Enable Fling",Default=VD.FLING_Enabled,Callback=function(v) VD.FLING_Enabled=v end})
PlayerFling:AddSlider({Name="Fling Strength",Min=1000,Max=50000,Default=VD.FLING_Strength or 10000,Increment=500,Callback=function(v) VD.FLING_Strength=v end})
local PlayerFun=PlayerTab:AddSection({Name="Fun"})
local sl,sg,ss="0","0","0"
PlayerFun:AddTextbox({Name="Set Level",Default="0",TextDisappear=false,Callback=function(v) sl=v end})
PlayerFun:AddTextbox({Name="Set Gears",Default="0",TextDisappear=false,Callback=function(v) sg=v end})
PlayerFun:AddTextbox({Name="Set Screws",Default="0",TextDisappear=false,Callback=function(v) ss=v end})
PlayerFun:AddButton({Name="Apply Spoof",Callback=function() pcall(function() LocalPlayer:SetAttribute("Level",tonumber(sl) or 0); LocalPlayer:SetAttribute("Gears",tonumber(sg) or 0); LocalPlayer:SetAttribute("Screws",tonumber(ss) or 0) end) end})

-- VISUAL
local VisualESP=VisualTab:AddSection({Name="ESP"})
VisualESP:AddToggle({Name="Master Drawing ESP",Default=VD.DRAWING_ESP,Callback=function(v) VD.DRAWING_ESP=v end})
VisualESP:AddToggle({Name="ESP Skeleton",Default=VD.ESP_Skeleton,Callback=function(v) if VD.ESP_LowPerformance and v then VD_Notify("ESP","Skeleton disabled in Low Performance",2); return end; VD.ESP_Skeleton=v end})
VisualESP:AddToggle({Name="ESP Velocity Arrows",Default=VD.ESP_Velocity,Callback=function(v) if VD.ESP_LowPerformance and v then VD_Notify("ESP","Velocity disabled in Low Performance",2); return end; VD.ESP_Velocity=v end})
VisualESP:AddToggle({Name="ESP Offscreen Arrows",Default=VD.ESP_Offscreen,Callback=function(v) if VD.ESP_LowPerformance and v then VD_Notify("ESP","Offscreen disabled in Low Performance",2); return end; VD.ESP_Offscreen=v end})
VisualESP:AddSlider({Name="Max ESP Distance",Min=500,Max=5000,Default=VD.MaxDistance or 2000,Increment=100,Callback=function(v) VD.MaxDistance=v end})
VisualESP:AddToggle({Name="Low Performance Mode",Default=VD.ESP_LowPerformance,Callback=function(v) VD.ESP_LowPerformance=v; if v then VD.ESP_Skeleton=false; VD.ESP_Velocity=false; VD.ESP_Offscreen=false end end})
local VisualLight=VisualTab:AddSection({Name="Lighting"})
VisualLight:AddToggle({Name="Fullbright",Default=VD.Fullbright,Callback=function(v) VD.Fullbright=v; applyFB(v) end})
VisualLight:AddToggle({Name="No Fog",Default=VD.NoFog,Callback=function(v) VD.NoFog=v; applyNF(v) end})
local VisualColor=VisualTab:AddSection({Name="ESP Colors"})
VisualColor:AddColorpicker({Name="Survivor Color",Default=Color3.fromRGB(0,255,0),Callback=function(v) end})
VisualColor:AddColorpicker({Name="Killer Color",Default=Color3.fromRGB(255,0,0),Callback=function(v) end})
VisualColor:AddColorpicker({Name="Generator Color",Default=Color3.fromRGB(0,170,255),Callback=function(v) end})
VisualColor:AddColorpicker({Name="Hook Color",Default=Color3.fromRGB(255,0,0),Callback=function(v) end})
VisualColor:AddColorpicker({Name="Gate Color",Default=Color3.fromRGB(255,225,0),Callback=function(v) end})
VisualColor:AddColorpicker({Name="FOV Circle Color",Default=Color3.fromRGB(180,180,180),Callback=function(v) if VeilDraw.FOVCircle then VeilDraw.FOVCircle.Color=v end end})

-- SPEED
local SpeedSec=SpeedTab:AddSection({Name="Speed"})
SpeedSec:AddSlider({Name="WalkSpeed",Min=16,Max=200,Default=16,Increment=1,ValueName="speed",Callback=function(v) local c=game.Players.LocalPlayer.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed=v end end})

-- SETTINGS
local SettingsSec=SettingsTab:AddSection({Name="Config"})
SettingsSec:AddButton({Name="Save Config",Callback=function() SaveConfig(); VD_Notify("Settings","Config saved!",3) end})
SettingsSec:AddButton({Name="Load Config",Callback=function() LoadConfig(); VD_Notify("Settings","Config loaded!",3) end})
SettingsSec:AddButton({Name="Reset Config",Callback=function()
    for k,v in pairs({AutoSkillcheck=false,AutoSkillcheckMode="Normal",SURV_FleeKiller=false,SURV_FleeDistance=40,SURV_AntiKnock=false,SURV_FirstPerson=false,InstantHealSelf=false,AutoHealAll=false,SURV_AutoVault=false,SURV_AutoPalletSlide=false,SURV_AutoDropPallet=false,SURV_AutoDropPalletDist=20,SURV_AutoDropPalletMode="Aggressive",SURV_AutoParry=false,SURV_ParryMode="Legit",SURV_ParryAnimId="rbxassetid://109133187196613",SURV_ParryRange=12,SURV_ShowParryCircle=true,Parry_Keybind="F3",AUTO_ToFAim=false,AUTO_ToFAimRange=90,AUTO_ToFDotThreshold=0.5,AUTO_ToFTargetMode="Killer",AUTO_ToFAimPart="HumanoidRootPart",AUTO_ToFPredict=true,AUTO_ToFBulletSpeed=200,AUTO_Attack=false,AUTO_AttackRange=12,KILLER_DestroyPallets=false,KILLER_AutoBreakGene=false,KILLER_BlockVaults=false,KILLER_AntiBlind=false,KILLER_DoubleTap=false,SPEAR_Aimbot=false,SPEAR_Gravity=50,SPEAR_Speed=100,KILLER_CustomMasked="Richard",DRAWING_ESP=false,ESP_Skeleton=false,ESP_Offscreen=false,ESP_Velocity=false,MaxDistance=2000,ESP_LowPerformance=false,Fullbright=false,NoFog=false,SURV_GenBoost=false,SURV_DraggableGenBypass=false,FLING_Enabled=false,FLING_Strength=10000}) do VD[k]=v end
    VD_Notify("Settings","Config reset to default!",3)
end})
SettingsSec:AddButton({Name="Export Config (Copy)",Callback=function() pcall(function() local ex={}; for k,v in pairs(VD) do if type(v)~="function" and type(v)~="table" then ex[k]=v end end; local j=HttpService:JSONEncode(ex); if setclipboard then setclipboard(j) end; VD_Notify("Settings","Config copied!",3) end) end})
SettingsSec:AddButton({Name="Import Config (Paste)",Callback=function() pcall(function() local j=getclipboard and getclipboard() or ""; if j=="" then VD_Notify("Settings","Clipboard empty!",3); return end; local d=HttpService:JSONDecode(j); for k,v in pairs(d) do VD[k]=v end; VD_Notify("Settings","Config imported! Restart to apply all.",4) end) end})
SettingsSec:AddButton({Name="Tutup UI (Close)",Callback=function() confirmClose() end})

-- ===================== INIT =====================
task.spawn(function()
    task.wait(1)
    if VD.SURV_GenBoost then startGenBoost() end
    if VD.Fullbright then applyFB(true) end
    if VD.NoFog then applyNF(true) end
end)

task.spawn(function()
    while not VD.Destroyed do
        refreshTP()
        pcall(function() if tpDD and tpDD.Refresh then tpDD:Refresh(tpNames) end; if tpDD2 and tpDD2.Refresh then tpDD2:Refresh(tpNames) end end)
        task.wait(5)
    end
end)

task.spawn(function()
    while not VD.Destroyed do task.wait(10); SaveConfig() end
end)

OrionLib:MakeNotification({Name="NO MERCY",Content="Violence District dimuat!",Image=ICON.Logo,Time=4})
print("[NO MERCY] Violence District loaded successfully!")
