--[[
=========================================================================
    REMOTE SCANNER - CHARACTER & BODY PARTS
    Mencari semua RemoteEvent/RemoteFunction yang berhubungan dengan:
    - Karakter (Character, Humanoid, Body, Part, etc.)
    - Transparansi / Invisibility
    - Semua part tubuh (Head, Torso, Arms, Legs, etc.)
    Menampilkan daftar di UI dan tombol Copy All
=========================================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ==================== KONFIGURASI KATA KUNCI ====================
local KEYWORDS = {
    -- Karakter & tubuh
    "character", "body", "humanoid", "part", "limb", "torso", "head", "arm", "leg",
    "transparency", "invisible", "ghost", "stealth", "hide", "cloak", "vanish",
    "appearance", "avatar", "skin", "mesh", "animation", "ragdoll",
    -- Remote umum
    "remote", "event", "function", "fire", "invoke",
}

-- ==================== FUNGSI PENCARIAN ====================

local FoundRemotes = {} -- {Name, Path, Type}

local function SearchInObject(obj, path)
    if not obj then return end
    local currentPath = path .. "." .. obj.Name

    -- Cek apakah ini remote
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        local nameLower = string.lower(obj.Name)
        for _, kw in ipairs(KEYWORDS) do
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

    -- Lanjutkan pencarian ke anak-anak
    for _, child in ipairs(obj:GetChildren()) do
        SearchInObject(child, currentPath)
    end
end

-- ==================== MULAI SCAN ====================

local function StartScan()
    FoundRemotes = {}
    local startTime = tick()

    -- Scan di ReplicatedStorage
    SearchInObject(ReplicatedStorage, "ReplicatedStorage")
    -- Scan di Workspace (mungkin ada remote di model karakter)
    SearchInObject(Workspace, "Workspace")
    -- Scan di Players (untuk remote per-player)
    SearchInObject(Players, "Players")
    -- Scan di game (root)
    SearchInObject(game, "game")

    local elapsed = tick() - startTime
    print(string.format("✅ Scan selesai dalam %.2f detik. Ditemukan %d remote.", elapsed, #FoundRemotes))
    return FoundRemotes
end

-- ==================== UI ====================

local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "RemoteScanner"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Frame utama
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 600, 0, 500)
    frame.Position = UDim2.new(0.5, -300, 0.5, -250)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    frame.Parent = gui

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    title.Text = "🔍 REMOTE SCANNER - CHARACTER BODY"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)
    title.Parent = frame

    -- Tombol Scan
    local scanBtn = Instance.new("TextButton")
    scanBtn.Size = UDim2.new(0.3, 0, 0, 35)
    scanBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
    scanBtn.Text = "🔄 SCAN REMOTES"
    scanBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
    scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    scanBtn.Font = Enum.Font.GothamBold
    scanBtn.TextSize = 13
    Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0, 6)
    scanBtn.Parent = frame

    -- Tombol Copy All
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0.3, 0, 0, 35)
    copyBtn.Position = UDim2.new(0.4, 0, 0.1, 0)
    copyBtn.Text = "📋 COPY ALL"
    copyBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 13
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)
    copyBtn.Parent = frame

    -- Status label
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0.6, 0, 0, 25)
    status.Position = UDim2.new(0.05, 0, 0.18, 0)
    status.BackgroundTransparency = 1
    status.Text = "Status: Belum scan"
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = frame

    -- ScrollingFrame untuk daftar remote
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(0.9, 0, 0.7)
    listFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
    listFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    listFrame.BorderSizePixel = 0
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.ScrollBarThickness = 6
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 6)
    listFrame.Parent = frame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = listFrame
    listLayout.Padding = UDim.new(0, 4)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Fungsi update list
    local function UpdateList(remotes)
        -- Hapus semua anak di listFrame (selain UIListLayout)
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("TextLabel") then
                child:Destroy()
            end
        end

        if #remotes == 0 then
            local empty = Instance.new("TextLabel")
            empty.Size = UDim2.new(1, 0, 0, 30)
            empty.BackgroundTransparency = 1
            empty.Text = "Tidak ada remote ditemukan."
            empty.TextColor3 = Color3.fromRGB(200, 200, 200)
            empty.Font = Enum.Font.Gotham
            empty.TextSize = 12
            empty.Parent = listFrame
            status.Text = "Status: Tidak ditemukan"
            return
        end

        -- Tampilkan setiap remote sebagai tombol (bisa diklik untuk info)
        for _, data in ipairs(remotes) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            btn.Text = data.Name .. "  (" .. data.Type .. ")"
            btn.TextColor3 = Color3.fromRGB(220, 220, 255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 11
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            btn.Parent = listFrame

            -- Tooltip path
            local pathLabel = Instance.new("TextLabel")
            pathLabel.Size = UDim2.new(1, 0, 0, 14)
            pathLabel.Position = UDim2.new(0, 5, 0, 28)
            pathLabel.BackgroundTransparency = 1
            pathLabel.Text = "📂 " .. data.Path
            pathLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
            pathLabel.Font = Enum.Font.Gotham
            pathLabel.TextSize = 9
            pathLabel.TextXAlignment = Enum.TextXAlignment.Left
            pathLabel.Parent = btn

            -- Klik untuk menyalin nama remote ke clipboard
            btn.MouseButton1Click:Connect(function()
                local success, err = pcall(function()
                    setclipboard(data.Name)
                end)
                if success then
                    status.Text = "✅ Disalin: " .. data.Name
                    status.TextColor3 = Color3.fromRGB(0, 255, 0)
                else
                    status.Text = "❌ Gagal menyalin (clipboard tidak didukung)"
                    status.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
                task.wait(2)
                status.Text = "Status: " .. #remotes .. " remote ditemukan"
                status.TextColor3 = Color3.fromRGB(200, 200, 200)
            end)
        end

        -- Update canvas size
        listFrame.CanvasSize = UDim2.new(0, 0, 0, #remotes * 35 + 10)
        status.Text = "Status: " .. #remotes .. " remote ditemukan"
    end

    -- ==================== EVENT HANDLER ====================

    -- Tombol Scan
    scanBtn.MouseButton1Click:Connect(function()
        status.Text = "🔄 Scanning... Mohon tunggu"
        status.TextColor3 = Color3.fromRGB(255, 200, 0)
        local remotes = StartScan()
        UpdateList(remotes)
    end)

    -- Tombol Copy All (copy semua nama remote ke clipboard, dipisahkan newline)
    copyBtn.MouseButton1Click:Connect(function()
        if #FoundRemotes == 0 then
            status.Text = "⚠️ Belum ada remote. Scan dulu!"
            status.TextColor3 = Color3.fromRGB(255, 200, 0)
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
            status.Text = "✅ Berhasil menyalin " .. #FoundRemotes .. " nama remote!"
            status.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            status.Text = "❌ Gagal menyalin (clipboard tidak didukung)"
            status.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
        task.wait(2)
        status.Text = "Status: " .. #FoundRemotes .. " remote ditemukan"
        status.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)

    -- Jalankan scan otomatis pertama kali
    task.wait(0.5)
    scanBtn.MouseButton1Click:Fire()

    return gui
end

-- ==================== EKSEKUSI ====================

-- Hapus GUI lama jika ada
pcall(function()
    local old = LocalPlayer.PlayerGui:FindFirstChild("RemoteScanner")
    if old then old:Destroy() end
end)

CreateUI()
print("✅ Remote Scanner Character Body loaded. Klik tombol 'SCAN REMOTES' untuk mencari.")
