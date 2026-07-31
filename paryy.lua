-- ========================================================
-- MOBILE AUTO PARRY HUB (READY FOR RAW HOSTING)
-- ========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Animation IDs Attack & Lunge (Killer)
local ATTACK_ANIMATIONS = {
    ["118907603246885"] = true, ["78432063483146"]  = true,
    ["110355011987939"] = true, ["139369275981139"] = true,
    ["117042998468241"] = true, ["133963973694098"] = true,
    ["129784271201071"] = true, ["132817836308238"] = true,
    ["135002183282873"] = true, ["121216847022485"] = true,
    ["113255068724446"] = true, ["74968262036854"]  = true,
    ["105374834496520"] = true, ["111920872708571"] = true,
    ["122812055447896"] = true, ["78935059863801"]  = true,
    ["95934119190788"]  = true, ["129918027564423"] = true,
    ["82669595311998"]  = true
}

local isON = false
local distance = 12
local lastParry = 0

-- Hapus UI lama jika re-execute
local targetParent = CoreGui
if not pcall(function() local a = CoreGui.Name end) then
    targetParent = LocalPlayer:WaitForChild("PlayerGui")
end

if targetParent:FindFirstChild("MobileParryHub") then 
    targetParent.MobileParryHub:Destroy() 
end

-- ========================================================
-- BUILD MOBILE UI (SUPER CLEAN & DRAGGABLE)
-- ========================================================
local sg = Instance.new("ScreenGui")
sg.Name = "MobileParryHub"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = targetParent

-- Frame Utama
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 150, 0, 90)
mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = sg

local frameCorner = Instance.new("UICorner", mainFrame)
frameCorner.CornerRadius = UDim.new(0, 10)

local frameStroke = Instance.new("UIStroke", mainFrame)
frameStroke.Color = Color3.fromRGB(50, 50, 60)
frameStroke.Thickness = 1.5

-- Title Bar (Bisa Geser UI)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.Text = "PARRY HUB v1.0"
title.TextColor3 = Color3.fromRGB(200, 200, 200)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 13
title.Parent = mainFrame

-- Tombol Toggle ON/OFF
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 32)
toggleBtn.Position = UDim2.new(0.05, 0, 0.32, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
toggleBtn.Text = "PARRY: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 14
toggleBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner", toggleBtn)
btnCorner.CornerRadius = UDim.new(0, 6)

-- Control Radius (- / +)
local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0.42, 0, 0, 22)
minusBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
minusBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
minusBtn.Text = "- Rad"
minusBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minusBtn.Font = Enum.Font.SourceSansBold
minusBtn.TextSize = 12
minusBtn.Parent = mainFrame
Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 4)

local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0.42, 0, 0, 22)
plusBtn.Position = UDim2.new(0.53, 0, 0.7, 0)
plusBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
plusBtn.Text = "+ Rad"
plusBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
plusBtn.Font = Enum.Font.SourceSansBold
plusBtn.TextSize = 12
plusBtn.Parent = mainFrame
Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 4)

-- ========================================================
-- LINGKARAN ESP AREA DI KAKI
-- ========================================================
local circle = Instance.new("Part", workspace)
circle.Name = "ParryCircleVisualizer"
circle.Shape = Enum.PartType.Cylinder
circle.Material = Enum.Material.Forcefield
circle.Color = Color3.fromRGB(255, 40, 40)
circle.Transparency = 1
circle.Anchored = true
circle.CanCollide = false
circle.CastShadow = false
circle.Size = Vector3.new(0.1, distance * 2, distance * 2)

local function updateCircle()
    circle.Size = Vector3.new(0.1, distance * 2, distance * 2)
end

-- ========================================================
-- SYSTEM EVENTS (CLICK / TOUCH)
-- ========================================================
toggleBtn.MouseButton1Click:Connect(function()
    isON = not isON
    if isON then
        toggleBtn.Text = "PARRY: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 60)
        circle.Color = Color3.fromRGB(0, 255, 100)
    else
        toggleBtn.Text = "PARRY: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        circle.Color = Color3.fromRGB(255, 40, 40)
    end
end)

minusBtn.MouseButton1Click:Connect(function()
    if distance > 6 then
        distance = distance - 2
        updateCircle()
    end
end)

plusBtn.MouseButton1Click:Connect(function()
    if distance < 35 then
        distance = distance + 2
        updateCircle()
    end
end)

-- Feature: Bikin Window UI Bisa Digeser di Layar HP
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ========================================================
-- ENGINE AUTO PARRY DETECTOR
-- ========================================================
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then 
        circle.Transparency = 1
        return 
    end

    local hrp = char.HumanoidRootPart
    circle.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 2.8, 0)) * CFrame.Angles(0, 0, math.rad(90))
    circle.Transparency = isON and 0.4 or 0.8

    if not isON then return end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local eHrp = p.Character.HumanoidRootPart
            if (hrp.Position - eHrp.Position).Magnitude <= distance then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local anim = hum and hum:FindFirstChildOfClass("Animator")
                if anim then
                    for _, track in ipairs(anim:GetPlayingAnimationTracks()) do
                        local id = tostring(track.Animation.AnimationId):match("%d+")
                        if ATTACK_ANIMATIONS[id] and (tick() - lastParry > 0.22) then
                            lastParry = tick()
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                            task.wait(0.03)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                        end
                    end
                end
            end
        end
    end
end)
