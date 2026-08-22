--[[
=========================================================================
    VIOLENT DISTRICT - REMOTE TESTER (INVISIBILITY)
    Menguji remote yang berpotensi untuk mengubah transparansi karakter
    Daftar remote dari hasil scan (RemoveCharacterEvent.txt)
=========================================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Daftar remote yang mungkin untuk invisibility / karakter
local REMOTE_CANDIDATES = {
    "UpdateCharacterLook",
    "ReplicateCharacterLook",
    "loadcharevent",
    "RemoveCharacterEvent",
    "AddCharacterLoadedEvent",
    "Teleportcharacter",
    "Highlightremote",
    "AnimationHandler",
    "PlayAnimation",
    "PlayerActionEvent",
    "Loadedevent",
    "TweenSettingsEvent",
}

-- ==================== FUNGSI PENCARIAN REMOTE ====================

local function FindRemote(name)
    -- Cari di ReplicatedStorage
    local remote = ReplicatedStorage:FindFirstChild(name)
    if remote then return remote end
    -- Cari di seluruh anak ReplicatedStorage
    for _, child in ipairs(ReplicatedStorage:GetChildren()) do
        local found = child:FindFirstChild(name)
        if found then return found end
    end
    -- Cari di Workspace (mungkin ada)
    remote = Workspace:FindFirstChild(name)
    if remote then return remote end
    return nil
end

-- ==================== UI ====================

local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "RemoteTester"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 400)
    frame.Position = UDim2.new(0.5, -250, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    title.Text = "🧪 REMOTE TESTER - INVISIBILITY"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)
    title.Parent = frame

    -- Scrolling frame untuk daftar remote
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(0.9, 0, 0.7)
    listFrame.Position = UDim2.new(0.05, 0, 0.12, 0)
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

    -- Status label
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0.9, 0, 0, 25)
    status.Position = UDim2.new(0.05, 0, 0.85, 0)
    status.BackgroundTransparency = 1
    status.Text = "Status: Klik tombol untuk mengirim percobaan"
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = frame

    -- Tombol "Test All" (kirim transparansi 1 ke semua remote)
    local testAllBtn = Instance.new("TextButton")
    testAllBtn.Size = UDim2.new(0.45, 0, 0, 30)
    testAllBtn.Position = UDim2.new(0.05, 0, 0.92, 0)
    testAllBtn.Text = "🔬 TEST ALL (Transparansi 1)"
    testAllBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
    testAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    testAllBtn.Font = Enum.Font.GothamBold
    testAllBtn.TextSize = 12
    Instance.new("UICorner", testAllBtn).CornerRadius = UDim.new(0, 6)
    testAllBtn.Parent = frame

    -- Tombol reset (kembalikan ke normal)
    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(0.4, 0, 0, 30)
    resetBtn.Position = UDim2.new(0.55, 0, 0.92, 0)
    resetBtn.Text = "🔄 Reset Karakter"
    resetBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextSize = 12
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 6)
    resetBtn.Parent = frame

    -- Fungsi untuk menambahkan remote ke daftar
    local function AddRemoteToList(name, remoteObj)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        btn.Text = name .. " (" .. (remoteObj and remoteObj.ClassName or "NOT FOUND") .. ")"
        btn.TextColor3 = remoteObj and Color3.fromRGB(200, 255, 200) or Color3.fromRGB(255, 100, 100)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.Parent = listFrame

        -- Simpan data remote di atribut button
        btn.Attribute("remoteName", name)
        btn.Attribute("remoteObj", remoteObj)

        -- Tooltip path (jika ditemukan)
        if remoteObj then
            local pathLabel = Instance.new("TextLabel")
            pathLabel.Size = UDim2.new(1, 0, 0, 14)
            pathLabel.Position = UDim2.new(0, 5, 0, 30)
            pathLabel.BackgroundTransparency = 1
            pathLabel.Text = "📂 " .. remoteObj:GetFullName()
            pathLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
            pathLabel.Font = Enum.Font.Gotham
            pathLabel.TextSize = 9
            pathLabel.TextXAlignment = Enum.TextXAlignment.Left
            pathLabel.Parent = btn
        else
            local warnLabel = Instance.new("TextLabel")
            warnLabel.Size = UDim2.new(1, 0, 0, 14)
            warnLabel.Position = UDim2.new(0, 5, 0, 30)
            warnLabel.BackgroundTransparency = 1
            warnLabel.Text = "⚠️ Remote tidak ditemukan"
            warnLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
            warnLabel.Font = Enum.Font.Gotham
            warnLabel.TextSize = 9
            warnLabel.Parent = btn
        end

        -- Tombol untuk test remote tertentu
        local testBtn = Instance.new("TextButton")
        testBtn.Size = UDim2.new(0.2, 0, 0, 22)
        testBtn.Position = UDim2.new(0.8, 0, 0.5, -11)
        testBtn.Text = "Test"
        testBtn.BackgroundColor3 = remoteObj and Color3.fromRGB(60, 150, 60) or Color3.fromRGB(100, 100, 100)
        testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        testBtn.Font = Enum.Font.GothamBold
        testBtn.TextSize = 10
        Instance.new("UICorner", testBtn).CornerRadius = UDim.new(0, 4)
        testBtn.Parent = btn

        testBtn.MouseButton1Click:Connect(function()
            if not remoteObj then
                status.Text = "❌ Remote tidak ditemukan: " .. name
                status.TextColor3 = Color3.fromRGB(255, 0, 0)
                return
            end

            -- Kirim percobaan (transparansi 1 untuk karakter)
            local char = LocalPlayer.Character
            if not char then return end

            -- Coba berbagai parameter
            local testData = {
                -- Format yang mungkin
                { Transparency = 1 },
                { transparency = 1 },
                { Transparent = true },
                { visible = false },
                { alpha = 0 },
                { opacity = 0 },
                { body = { Transparency = 1 } },
                { parts = { Head = 1, Torso = 1 } },
                { value = 1 },
                { state = "invisible" },
                { enabled = false },
                { data = { transparency = 1 } },
            }

            local success = false
            for _, params in ipairs(testData) do
                pcall(function()
                    if remoteObj:IsA("RemoteEvent") then
                        remoteObj:FireServer(params)
                    elseif remoteObj:IsA("RemoteFunction") then
                        remoteObj:InvokeServer(params)
                    end
                    success = true
                end)
                if success then break end
            end

            if success then
                status.Text = "✅ Berhasil mengirim ke " .. name
                status.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                status.Text = "❌ Gagal mengirim ke " .. name
                status.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
            task.wait(2)
            status.Text = "Status: Siap"
            status.TextColor3 = Color3.fromRGB(200, 200, 200)
        end)

        return btn
    end

    -- ==================== POPULATE LIST ====================

    local function PopulateList()
        -- Hapus semua anak (kecuali UIListLayout)
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("TextLabel") then
                child:Destroy()
            end
        end

        local foundCount = 0
        for _, name in ipairs(REMOTE_CANDIDATES) do
            local remote = FindRemote(name)
            if remote then foundCount = foundCount + 1 end
            AddRemoteToList(name, remote)
        end

        -- Update canvas
        listFrame.CanvasSize = UDim2.new(0, 0, 0, #REMOTE_CANDIDATES * 40 + 10)
        status.Text = "Status: " .. foundCount .. "/" .. #REMOTE_CANDIDATES .. " remote ditemukan"
    end

    -- ==================== EVENT HANDLER ====================

    -- Test All
    testAllBtn.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end

        -- Kirim transparansi 1 ke semua remote yang ditemukan
        local successCount = 0
        for _, name in ipairs(REMOTE_CANDIDATES) do
            local remote = FindRemote(name)
            if remote then
                local params = { Transparency = 1 }
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(params)
                    elseif remote:IsA("RemoteFunction") then
                        remote:InvokeServer(params)
                    end
                    successCount = successCount + 1
                end)
            end
        end
        status.Text = "✅ Mengirim ke " .. successCount .. " remote"
        status.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.wait(2)
        status.Text = "Status: Siap"
        status.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)

    -- Reset karakter (teleport ke spawn atau refresh)
    resetBtn.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if char then
            char:BreakJoints()
        end
        -- Atau coba teleport ke spawn
        local spawn = Workspace:FindFirstChild("SpawnLocation")
        if spawn then
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = spawn.CFrame
            end
        end
        status.Text = "🔄 Karakter di-reset"
        status.TextColor3 = Color3.fromRGB(255, 200, 0)
        task.wait(1.5)
        status.Text = "Status: Siap"
        status.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)

    PopulateList()
    return gui
end

-- ==================== EKSEKUSI ====================

pcall(function()
    local old = LocalPlayer.PlayerGui:FindFirstChild("RemoteTester")
    if old then old:Destroy() end
end)

CreateUI()
print("✅ Remote Tester loaded. Klik 'Test' pada remote untuk mengirim percobaan.")
