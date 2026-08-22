--[[
=========================================================================
    NO MERCY HUB - INVISIBLE TOTAL (SERVER-SIDE + CLIENT-SIDE FALLBACK)
    - Mencari remote invisibility di ReplicatedStorage
    - Jika ditemukan, kirim ke server (semua pemain melihatmu invisible)
    - Jika tidak, fallback ke client-side (hanya kamu yang melihat efek)
    - Client-side: tubuh ditutupi balok transparan (efek "menghilang")
=========================================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Config = {
    Invisible = false,
    RemoteFound = false,
    RemoteObject = nil,
    Block = nil,
}

-- ==================== CARI REMOTE ====================

local function FindRemoteInObject(obj, keywords)
    for _, child in ipairs(obj:GetChildren()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            for _, kw in ipairs(keywords) do
                if string.lower(child.Name):find(kw) then
                    return child
                end
            end
        end
        local found = FindRemoteInObject(child, keywords)
        if found then return found end
    end
    return nil
end

local function FindInvisibleRemote()
    local keywords = {
        "invis", "ghost", "stealth", "hide", "transparent",
        "camouflage", "cloak", "vanish", "disappear"
    }
    return FindRemoteInObject(ReplicatedStorage, keywords)
end

-- ==================== FUNGSI UTAMA ====================

-- Client-side fallback: buat balok penutup tubuh
local function CreateBlock()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Hapus block sebelumnya jika ada
    if Config.Block then
        Config.Block:Destroy()
        Config.Block = nil
    end

    -- Buat balok besar yang menutupi seluruh tubuh
    local block = Instance.new("Part")
    block.Name = "InvisibleBlock"
    block.Size = Vector3.new(6, 6, 6)
    block.Shape = Enum.PartType.Block
    block.Anchored = true
    block.CanCollide = false
    block.Transparency = 1
    block.Material = Enum.Material.SmoothPlastic
    block.Parent = Workspace

    -- Warna mengikuti warna tubuh (atau putih)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.RigType == Enum.HumanoidRigType.R6 then
        block.Size = Vector3.new(4, 4, 4)
    else
        block.Size = Vector3.new(6, 6, 6)
    end

    Config.Block = block
    print("✅ Balok penutup dibuat.")
end

local function UpdateBlockPosition()
    if not Config.Block then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    Config.Block.CFrame = CFrame.new(hrp.Position)
end

local function DestroyBlock()
    if Config.Block then
        Config.Block:Destroy()
        Config.Block = nil
    end
end

-- Kirim remote ke server
local function SendRemote(state)
    if not Config.RemoteObject then return false end
    local success = pcall(function()
        if Config.RemoteObject:IsA("RemoteEvent") then
            Config.RemoteObject:FireServer(state)
        elseif Config.RemoteObject:IsA("RemoteFunction") then
            Config.RemoteObject:InvokeServer(state)
        end
    end)
    return success
end

-- Toggle invisible
local function ToggleInvisible()
    Config.Invisible = not Config.Invisible
    local state = Config.Invisible

    if Config.RemoteFound then
        local success = SendRemote(state)
        if success then
            print("✅ Invisible server-side berhasil dikirim.")
            -- Jika berhasil, kita juga bisa kasih efek client-side (block) untuk sendiri
            if state then
                CreateBlock()
                UpdateBlockPosition()
            else
                DestroyBlock()
            end
            return
        else
            print("⚠️ Gagal mengirim remote, fallback ke client-side.")
        end
    end

    -- Fallback client-side
    if state then
        CreateBlock()
        UpdateBlockPosition()
        -- Set transparansi block menjadi 1 (hilang), tapi tubuh asli tetap ada di dalam
        if Config.Block then
            Config.Block.Transparency = 1
        end
        -- Buat tubuh asli transparan juga (supaya tidak terlihat dari dalam)
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                end
            end
        end
    else
        DestroyBlock()
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                end
            end
        end
    end
    print("Invisible client-side: " .. tostring(state))
end

-- ==================== LOOP UPDATE POSISI BLOCK ====================

RunService.RenderStepped:Connect(function()
    if Config.Invisible and Config.Block then
        UpdateBlockPosition()
    end
end)

-- ==================== GUI ====================

local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))

-- Frame utama
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 180)
frame.Position = UDim2.new(0.5, -150, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
frame.Active = true
frame.Draggable = true

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "🔍 Invisibility Controller"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

-- Toggle button
local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0.9, 0, 0, 40)
btn.Position = UDim2.new(0.05, 0, 0.22, 0)
btn.Text = "INVISIBLE OFF"
btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

-- Status remote
local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(0.9, 0, 0, 25)
statusLabel.Position = UDim2.new(0.05, 0, 0.48, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status Remote: Mencari..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Input manual remote name
local inputBox = Instance.new("TextBox", frame)
inputBox.Size = UDim2.new(0.6, 0, 0, 30)
inputBox.Position = UDim2.new(0.05, 0, 0.62, 0)
inputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
inputBox.Text = "Ketik nama remote"
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 11
Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 4)
inputBox.ClearTextOnFocus = true

local setBtn = Instance.new("TextButton", frame)
setBtn.Size = UDim2.new(0.25, 0, 0, 30)
setBtn.Position = UDim2.new(0.7, 0, 0.62, 0)
setBtn.Text = "Set Remote"
setBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
setBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
setBtn.Font = Enum.Font.GothamBold
setBtn.TextSize = 10
Instance.new("UICorner", setBtn).CornerRadius = UDim.new(0, 4)

-- ==================== LOGIKA GUI ====================

-- Cari remote otomatis
local remote = FindInvisibleRemote()
if remote then
    Config.RemoteFound = true
    Config.RemoteObject = remote
    statusLabel.Text = "✅ Remote ditemukan: " .. remote.Name
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    print("✅ Remote invisibility ditemukan: " .. remote.Name)
else
    statusLabel.Text = "⚠️ Remote tidak ditemukan. Gunakan client-side."
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    print("⚠️ Remote tidak ditemukan.")
end

-- Toggle button
btn.MouseButton1Click:Connect(function()
    ToggleInvisible()
    if Config.Invisible then
        btn.Text = "INVISIBLE ON"
        btn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    else
        btn.Text = "INVISIBLE OFF"
        btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    end
end)

-- Set remote manual
setBtn.MouseButton1Click:Connect(function()
    local name = inputBox.Text
    if name and name ~= "" then
        local obj = ReplicatedStorage:FindFirstChild(name)
        if obj and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
            Config.RemoteFound = true
            Config.RemoteObject = obj
            statusLabel.Text = "✅ Remote manual: " .. name
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            print("✅ Remote manual diset: " .. name)
        else
            statusLabel.Text = "❌ Remote tidak ditemukan: " .. name
            statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    end
end)

-- ==================== INFO ====================

print("✅ SCRIPT INVISIBLE TOTAL LOADED!")
print("🔹 Klik 'INVISIBLE OFF' untuk toggle.")
print("🔹 Jika remote ditemukan, invisible server-side (semua pemain melihat).")
print("🔹 Jika tidak, hanya client-side (hanya kamu yang melihat efek balok).")
print("🔹 Kamu juga bisa ketik nama remote manual lalu klik 'Set Remote'.")
