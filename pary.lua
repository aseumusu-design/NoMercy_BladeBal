-- [[ GUI SHORTCUT SKILL HIDDEN ]]
-- Buat jendela kecil berisi tombol skill, klik langsung pakai.

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

-- Hapus GUI lama biar ga dobel
local old = pg:FindFirstChild("SkillShortcuts")
if old then old:Destroy() end

-- Ambil folder skill Hidden
local folder = RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("Killers") and RS.Remotes.Killers:FindFirstChild("Hidden")
if not folder then
    warn("❌ Folder Hidden tidak ditemukan! Pastikan kamu pakai Killer Hidden.")
    return
end

-- Kumpulkan semua RemoteEvent (skill)
local remotes = {}
for _, obj in ipairs(folder:GetDescendants()) do
    if obj:IsA("RemoteEvent") then
        table.insert(remotes, obj)
    end
end

if #remotes == 0 then
    warn("❌ Tidak ada RemoteEvent di folder Hidden.")
    return
end

-- Buat ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "SkillShortcuts"
gui.ResetOnSpawn = false
gui.Parent = pg

-- Frame utama (bisa digeser)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 30 + #remotes * 32)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true

-- Judul
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 24)
title.Position = UDim2.new(0, 5, 0, 2)
title.BackgroundTransparency = 1
title.Text = "🎯 Skill Hidden"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Tombol close (X)
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 22, 0, 22)
close.Position = UDim2.new(1, -26, 0, 2)
close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 12
close.Font = Enum.Font.GothamBold
close.Parent = frame
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Buat tombol untuk tiap skill
local y = 28
for _, remote in ipairs(remotes) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 26)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btn.Text = remote.Name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    
    -- Efek hover
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    end)
    
    -- Saat diklik → pakai skill
    btn.MouseButton1Click:Connect(function()
        pcall(function()
            remote:FireServer()
            print("✅ Skill " .. remote.Name .. " terpakai!")
        end)
    end)
    
    y = y + 30
end

print("🎉 GUI shortcut skill sudah dibuat! Klik tombol untuk memakai skill.")
