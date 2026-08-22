--[[
    INVIS GHOST + REMOTE SCANNER (VERSION 2.0)
    - Fitur Invis, Ghost Speed, Noclip dari InvisGhostUI
    - Remote Scanner untuk mencari semua remote
    - Tombol Test Remote untuk mencoba mengirim remote dengan parameter umum
]]

local VERSION = 2.0

if _G.InvisGhostLoaded and _G.InvisGhostLoaded >= VERSION then
    return
end
_G.InvisGhostLoaded = VERSION

local Players = game:GetService("Players")
local CoreguiM = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local plr = Players.LocalPlayer

local SETTINGS_FOLDER = "FeInvisibleOld"
local SETTINGS_FILE = SETTINGS_FOLDER .. "/ghostspeed.txt"

local function saveSpeed(speed)
    if isfolder and makefolder and writefile then
        if not isfolder(SETTINGS_FOLDER) then
            makefolder(SETTINGS_FOLDER)
        end
        writefile(SETTINGS_FILE, tostring(speed))
    end
end

local function loadSpeed()
    if isfile and readfile and isfile(SETTINGS_FILE) then
        local val = tonumber(readfile(SETTINGS_FILE))
        if val then
            return val
        end
    end
    return 50
end

local invisOn = false
local ghostOn = false
local noclipOn = false
local ghostSpeed = loadSpeed()
local uiHidden = false
local FoundRemotes = {} -- daftar remote yang ditemukan

local sg = Instance.new("ScreenGui", CoreguiM)
sg.Name = "InvisGhostUI"
sg.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", sg)
mainFrame.Size = UDim2.new(0, 450, 0, 450) -- lebih besar untuk remote list
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Tombol-tombol dasar
local function makeButton(text, pos, parent)
    parent = parent or mainFrame
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0, 100, 0, 30)
    b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = text
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

-- Tombol atas
local invisBtn = makeButton("Invis 👻", UDim2.new(0, 10, 0, 10))
local ghostBtn = makeButton("Ghost ⚡", UDim2.new(0, 120, 0, 10))
local noclipBtn = makeButton("Noclip 🚪", UDim2.new(0, 230, 0, 10))
local unloadBtn = makeButton("Unload ❌", UDim2.new(0, 340, 0, 10))

-- Speed box
local speedBox = Instance.new("TextBox", mainFrame)
speedBox.Size = UDim2.new(0, 200, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 50)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.Text = tostring(ghostSpeed)
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 8)

-- Tombol Scan dan Copy All
local scanBtn = makeButton("Scan Remote 🔍", UDim2.new(0, 220, 0, 50))
local copyAllBtn = makeButton("Copy All 📋", UDim2.new(0, 330, 0, 50))

-- List remote (ScrollingFrame)
local remoteList = Instance.new("ScrollingFrame", mainFrame)
remoteList.Size = UDim2.new(0, 430, 0, 200)
remoteList.Position = UDim2.new(0, 10, 0, 90)
remoteList.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
remoteList.BorderSizePixel = 0
remoteList.CanvasSize = UDim2.new(0, 0, 0, 0)
remoteList.ScrollBarThickness = 6
Instance.new("UICorner", remoteList).CornerRadius = UDim.new(0, 6)

local listLayout = Instance.new("UIListLayout", remoteList)
listLayout.Padding = UDim.new(0, 4)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Status label
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(0, 430, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 300)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Belum scan"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Tombol Test Remote (akan muncul saat remote dipilih)
local testBtn = makeButton("Test Remote 🧪", UDim2.new(0, 10, 0, 320))
testBtn.Visible = false

-- Variabel remote yang dipilih untuk test
local selectedRemote = nil

-- ==================== FUNGSI SCAN REMOTE ====================

local function SearchInObject(obj, path, keywords)
    if not obj then return end
    local currentPath = path .. "." .. obj.Name

    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        local nameLower = string.lower(obj.Name)
        for _, kw in ipairs(keywords) do
            if nameLower:find(kw) then
                table.insert(FoundRemotes, {
                    Name = obj.Name,
                    Path = currentPath,
                    Type = obj.ClassName,
                    Object = obj,
                })
                break
            end
        end
    end

    for _, child in ipairs(obj:GetChildren()) do
        SearchInObject(child, currentPath, keywords)
    end
end

local function ScanRemotes()
    FoundRemotes = {}
    local keywords = {
        "character", "body", "humanoid", "part", "limb", "torso", "head", "arm", "leg",
        "transparency", "invisible", "ghost", "stealth", "hide", "cloak", "vanish",
        "appearance", "avatar", "skin", "mesh", "animation", "ragdoll",
        "remote", "event", "function", "fire", "invoke",
    }
    SearchInObject(ReplicatedStorage, "ReplicatedStorage", keywords)
    SearchInObject(Workspace, "Workspace", keywords)
    SearchInObject(Players, "Players", keywords)
    SearchInObject(game, "game", keywords)
    return FoundRemotes
end

-- ==================== UPDATE UI LIST ====================

local function UpdateRemoteList(remotes)
    -- Hapus semua anak di remoteList (selain UIListLayout)
    for _, child in ipairs(remoteList:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    if #remotes == 0 then
        local empty = Instance.new("TextLabel", remoteList)
        empty.Size = UDim2.new(1, 0, 0, 30)
        empty.BackgroundTransparency = 1
        empty.Text = "Tidak ada remote ditemukan."
        empty.TextColor3 = Color3.fromRGB(200, 200, 200)
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 12
        statusLabel.Text = "Status: Tidak ditemukan"
        return
    end

    for _, data in ipairs(remotes) do
        local btn = Instance.new("TextButton", remoteList)
        btn.Size = UDim2.new(1, 0, 0, 24)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        btn.Text = data.Name .. "  (" .. data.Type .. ")"
        btn.TextColor3 = Color3.fromRGB(220, 220, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 10
        btn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.Parent = remoteList

        -- Klik untuk menyalin nama dan menampilkan test button
        btn.MouseButton1Click:Connect(function()
            selectedRemote = data
            testBtn.Visible = true
            testBtn.Text = "Test: " .. data.Name
            statusLabel.Text = "Remote dipilih: " .. data.Name
            -- Copy nama ke clipboard
            pcall(function()
                setclipboard(data.Name)
                statusLabel.Text = statusLabel.Text .. " (disalin ke clipboard)"
            end)
        end)
    end

    remoteList.CanvasSize = UDim2.new(0, 0, 0, #remotes * 28 + 10)
    statusLabel.Text = "Status: " .. #remotes .. " remote ditemukan"
end

-- ==================== FUNGSI TEST REMOTE ====================

local function TestRemote(remoteData)
    if not remoteData then return end
    local obj = remoteData.Object
    if not obj then return end

    -- Beberapa kemungkinan parameter yang umum
    local testParams = {
        { true },
        { false },
        { 0 },
        { 1 },
        { 0.5 },
        { "invisible" },
        { "visible" },
        { plr.Name },
        { plr.Character },
        { plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") },
        { true, 0.5 }, -- boolean + number
        { false, 0 },
        { plr, true },
        { plr, false },
    }

    local function trySend(params)
        local success, err = pcall(function()
            if obj:IsA("RemoteEvent") then
                obj:FireServer(unpack(params))
            elseif obj:IsA("RemoteFunction") then
                obj:InvokeServer(unpack(params))
            end
        end)
        return success, err
    end

    -- Coba semua kombinasi parameter
    for i, params in ipairs(testParams) do
        local success, err = trySend(params)
        if success then
            statusLabel.Text = "✅ Remote '" .. remoteData.Name .. "' berhasil dikirim (params: " .. table.concat(params, ", ") .. ")"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            showNotice("Remote test success!")
            return
        end
    end

    -- Jika semua gagal
    statusLabel.Text = "❌ Semua percobaan remote gagal. Coba manual."
    statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    showNotice("Remote test failed.")
end

-- ==================== FUNGSI UTAMA (Invis, Ghost, Noclip) ====================

local function showNotice(txt)
    pcall(function()
        if CoreguiM:FindFirstChild("InvisGhostNotice") then
            CoreguiM.InvisGhostNotice:Destroy()
        end
    end)
    local g = Instance.new("ScreenGui", CoreguiM)
    g.Name = "InvisGhostNotice"
    g.ResetOnSpawn = false
    local lbl = Instance.new("TextLabel", g)
    lbl.Size = UDim2.new(0, 300, 0, 40)
    lbl.Position = UDim2.new(0.5, -150, 0, 20)
    lbl.BackgroundTransparency = 0.15
    lbl.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Text = txt
    lbl.TextSize = 18
    lbl.Font = Enum.Font.SourceSansSemibold
    lbl.ZIndex = 9999
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 8)
    task.spawn(function()
        task.wait(2)
        pcall(function() g:Destroy() end)
    end)
end

local function setTransparency(char, val)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            p.Transparency = val
        end
    end
end

local function toggleInvis()
    invisOn = not invisOn
    local char = plr.Character
    if char then
        if invisOn then
            setTransparency(char, 0.5)
            local savedpos = char.HumanoidRootPart.CFrame
            task.wait()
            char:MoveTo(Vector3.new(-25.95, 84, 3537.55))
            task.wait(0.15)
            local Seat = Instance.new("Seat", Workspace)
            Seat.Anchored = false
            Seat.CanCollide = false
            Seat.Name = "invischair"
            Seat.Transparency = 1
            Seat.Position = Vector3.new(-25.95, 84, 3537.55)
            local Weld = Instance.new("Weld", Seat)
            Weld.Part0 = Seat
            Weld.Part1 = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            Seat.CFrame = savedpos
            showNotice("Invisibility Enabled")
        else
            setTransparency(char, 0)
            if Workspace:FindFirstChild("invischair") then
                Workspace.invischair:Destroy()
            end
            showNotice("Invisibility Disabled")
        end
    end
end

local ghostEnforceConn
local function toggleGhost()
    ghostOn = not ghostOn
    local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if ghostOn then
            hum.WalkSpeed = ghostSpeed
            if ghostEnforceConn then
                pcall(function() ghostEnforceConn:Disconnect() end)
                ghostEnforceConn = nil
            end
            ghostEnforceConn = RunService.Stepped:Connect(function()
                if hum and hum.WalkSpeed ~= ghostSpeed then
                    pcall(function() hum.WalkSpeed = ghostSpeed end)
                end
            end)
            showNotice("Ghost Enabled: " .. tostring(ghostSpeed))
        else
            if ghostEnforceConn then
                pcall(function() ghostEnforceConn:Disconnect() end)
                ghostEnforceConn = nil
            end
            hum.WalkSpeed = 16
            showNotice("Ghost Disabled")
        end
    else
        if ghostOn then
            showNotice("Ghost Enabled: " .. tostring(ghostSpeed))
        else
            showNotice("Ghost Disabled")
        end
    end
end

local noclipConn
local function toggleNoclip()
    noclipOn = not noclipOn
    if noclipOn then
        noclipConn = RunService.Stepped:Connect(function()
            local char = plr.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        showNotice("Noclip Enabled")
    else
        if noclipConn then
            pcall(function() noclipConn:Disconnect() end)
            noclipConn = nil
        end
        showNotice("Noclip Disabled")
    end
end

local keybindConn
local function unload()
    if sg then
        pcall(function() sg:Destroy() end)
        sg = nil
    end
    _G.InvisGhostLoaded = nil
    if noclipConn then
        pcall(function() noclipConn:Disconnect() end)
        noclipConn = nil
    end
    if keybindConn then
        pcall(function() keybindConn:Disconnect() end)
        keybindConn = nil
    end
    if ghostEnforceConn then
        pcall(function() ghostEnforceConn:Disconnect() end)
        ghostEnforceConn = nil
    end
    local char = plr.Character
    if char then
        pcall(function()
            setTransparency(char, 0)
            if Workspace:FindFirstChild("invischair") then
                Workspace.invischair:Destroy()
            end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                if hum.JumpPower then
                    hum.JumpPower = 50
                end
            end
        end)
    end
    invisOn = false
    ghostOn = false
    noclipOn = false
    uiHidden = false
    showNotice("Invis Ghost Unloaded")
end

local function confirmUnload()
    if CoreguiM:FindFirstChild("UnloadConfirmUI") then
        CoreguiM.UnloadConfirmUI:Destroy()
    end
    local confirmGui = Instance.new("ScreenGui", CoreguiM)
    confirmGui.Name = "UnloadConfirmUI"
    confirmGui.ResetOnSpawn = false
    local frame = Instance.new("Frame", confirmGui)
    frame.Size = UDim2.new(0, 250, 0, 120)
    frame.Position = UDim2.new(0.5, -125, 0.5, -60)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 40)
    label.BackgroundTransparency = 1
    label.Text = "Are you sure to unload?"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 20
    local yesBtn = Instance.new("TextButton", frame)
    yesBtn.Size = UDim2.new(0.5, -5, 0, 40)
    yesBtn.Position = UDim2.new(0, 5, 1, -45)
    yesBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
    yesBtn.Text = "Yes"
    yesBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", yesBtn).CornerRadius = UDim.new(0, 8)
    local noBtn = Instance.new("TextButton", frame)
    noBtn.Size = UDim2.new(0.5, -5, 0, 40)
    noBtn.Position = UDim2.new(0.5, 0, 1, -45)
    noBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
    noBtn.Text = "No"
    noBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", noBtn).CornerRadius = UDim.new(0, 8)
    yesBtn.MouseButton1Click:Connect(function()
        pcall(function() confirmGui:Destroy() end)
        unload()
    end)
    noBtn.MouseButton1Click:Connect(function()
        pcall(function() confirmGui:Destroy() end)
    end)
end

-- ==================== EVENT BINDING ====================

invisBtn.MouseButton1Click:Connect(toggleInvis)
ghostBtn.MouseButton1Click:Connect(toggleGhost)
noclipBtn.MouseButton1Click:Connect(toggleNoclip)
unloadBtn.MouseButton1Click:Connect(confirmUnload)

speedBox.FocusLost:Connect(function(enter)
    if enter then
        local val = tonumber(speedBox.Text)
        if val and val > 0 then
            ghostSpeed = val
            saveSpeed(ghostSpeed)
            local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if ghostOn then
                    hum.WalkSpeed = ghostSpeed
                else
                    hum.WalkSpeed = 16
                end
            end
        else
            speedBox.Text = tostring(ghostSpeed)
        end
    end
end)

-- Scan remote
scanBtn.MouseButton1Click:Connect(function()
    statusLabel.Text = "🔄 Scanning remote..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    local remotes = ScanRemotes()
    UpdateRemoteList(remotes)
    statusLabel.Text = "✅ Scan selesai. " .. #remotes .. " remote ditemukan."
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
end)

-- Copy all remote names
copyAllBtn.MouseButton1Click:Connect(function()
    if #FoundRemotes == 0 then
        statusLabel.Text = "⚠️ Belum ada remote. Scan dulu!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        return
    end
    local names = {}
    for _, data in ipairs(FoundRemotes) do
        table.insert(names, data.Name)
    end
    local text = table.concat(names, "\n")
    local success, err = pcall(function()
        setclipboard(text)
    end)
    if success then
        statusLabel.Text = "✅ Berhasil menyalin " .. #FoundRemotes .. " nama remote!"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        statusLabel.Text = "❌ Gagal menyalin (clipboard tidak didukung)"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
    task.wait(2)
    statusLabel.Text = "Status: " .. #FoundRemotes .. " remote ditemukan"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

-- Test remote
testBtn.MouseButton1Click:Connect(function()
    if selectedRemote then
        TestRemote(selectedRemote)
    else
        statusLabel.Text = "⚠️ Pilih remote dari daftar terlebih dahulu."
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    end
end)

-- Keybinds
keybindConn = UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Z then
        toggleInvis()
    elseif input.KeyCode == Enum.KeyCode.B then
        toggleGhost()
    elseif input.KeyCode == Enum.KeyCode.N then
        toggleNoclip()
    elseif input.KeyCode == Enum.KeyCode.K then
        uiHidden = not uiHidden
        mainFrame.Visible = not uiHidden
    end
end)

-- Scan otomatis pertama kali
task.wait(0.5)
scanBtn.MouseButton1Click:Fire()

print("✅ Invis Ghost + Remote Scanner loaded. (V" .. VERSION .. ")")
print("🔹 Z = Invis, B = Ghost, N = Noclip, K = Toggle UI")
