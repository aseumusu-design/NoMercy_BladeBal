-- ============================================================
-- NO MERCY — MINIMAL UI TEST (Delta mobile compatibility test)
-- File ini HANYA bikin UI window + 1 tab + 1 toggle.
-- Tujuan: pastikan UI infrastructure jalan di Delta executor.
-- Kalau ini muncul = masalahnya di feature logic (bukan UI).
-- Kalau ini GA muncul = masalahnya di UI infrastructure.
-- ============================================================

-- ===== STEP 1: Cari parent yang valid =====
local holder
if gethui then
    local ok, h = pcall(gethui)
    if ok and h then holder = h end
end
if not holder then
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core then holder = core end
end
if not holder then
    holder = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

print("[NM-TEST] Holder: " .. tostring(holder and holder.Name or "NIL"))

-- ===== STEP 2: Bikin ScreenGui =====
local gui = Instance.new("ScreenGui")
gui.Name = "NoMercyTest"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
-- Delta: coba set Parent dengan pcall
local okParent, errParent = pcall(function() gui.Parent = holder end)
if not okParent then
    print("[NM-TEST] CoreGui parent failed: " .. tostring(errParent) .. " — trying PlayerGui")
    gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end
print("[NM-TEST] ScreenGui parented to: " .. tostring(gui.Parent and gui.Parent.Name or "NIL"))

-- ===== STEP 3: Bikin Window (Frame) =====
local main = Instance.new("Frame")
main.Name = "MainWindow"
main.Size = UDim2.new(0, 450, 0, 350)
main.Position = UDim2.new(0.5, -225, 0.5, -175)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = main

-- ===== STEP 4: Title Bar =====
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "NO MERCY — TEST"
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -34, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- ===== STEP 5: Content area =====
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -38)
content.Position = UDim2.new(0, 0, 0, 38)
content.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
content.BorderSizePixel = 0
content.Parent = main

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -24, 0, 30)
label.Position = UDim2.new(0, 12, 0, 12)
label.BackgroundTransparency = 1
label.Text = "UI TEST BERHASIL — Delta mobile OK!"
label.TextColor3 = Color3.fromRGB(0, 200, 80)
label.Font = Enum.Font.GothamBold
label.TextSize = 14
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = content

-- Toggle test
local toggleRow = Instance.new("Frame")
toggleRow.Size = UDim2.new(1, -24, 0, 35)
toggleRow.Position = UDim2.new(0, 12, 0, 50)
toggleRow.BackgroundTransparency = 1
toggleRow.Parent = content

local toggleLabel = Instance.new("TextLabel")
toggleLabel.Size = UDim2.new(1, -55, 1, 0)
toggleLabel.BackgroundTransparency = 1
toggleLabel.Text = "Test Toggle"
toggleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
toggleLabel.Font = Enum.Font.Gotham
toggleLabel.TextSize = 13
toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel.Parent = toggleRow

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 44, 0, 24)
toggleBtn.Position = UDim2.new(1, -46, 0.5, -12)
toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
toggleBtn.Text = ""
toggleBtn.Parent = toggleRow

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 12)
toggleCorner.CornerParent = toggleBtn
toggleCorner.Parent = toggleBtn

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 18, 0, 18)
dot.Position = UDim2.new(0, 3, 0.5, -9)
dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
dot.Parent = toggleBtn

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = dot

local toggleState = false
toggleBtn.MouseButton1Click:Connect(function()
    toggleState = not toggleState
    toggleBtn.BackgroundColor3 = toggleState and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(45, 45, 45)
    if toggleState then
        dot.Position = UDim2.new(1, -21, 0.5, -9)
    else
        dot.Position = UDim2.new(0, 3, 0.5, -9)
    end
    print("[NM-TEST] Toggle: " .. tostring(toggleState))
end)

-- ===== STEP 6: Draggable (mobile support) =====
local UIS = game:GetService("UserInputService")
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

print("[NM-TEST] === UI TEST COMPLETE — window should be visible! ===")
print("[NM-TEST] If you see a dark window with 'NO MERCY — TEST' title, UI works!")
print("[NM-TEST] If you DON'T see it, the executor may be blocking UI creation.")
