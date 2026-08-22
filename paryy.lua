--[[
=========================================================================
    REMOTE SCANNER + COPY (Mencari semua RemoteEvent/RemoteFunction)
    - Scan ReplicatedStorage, Workspace, Lighting, ServerScriptService, etc.
    - Tampilkan daftar di UI dengan tombol copy per remote
=========================================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local function getAllRemotes()
    local remotes = {}
    local function scan(obj, path)
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                table.insert(remotes, {
                    Name = child.Name,
                    Class = child.ClassName,
                    Path = path .. "." .. child.Name,
                    Ref = child
                })
            end
            if child:IsA("Instance") then
                scan(child, path .. "." .. child.Name)
            end
        end
    end
    scan(ReplicatedStorage, "ReplicatedStorage")
    scan(Workspace, "Workspace")
    scan(Lighting, "Lighting")
    scan(ServerScriptService, "ServerScriptService")
    scan(ServerStorage, "ServerStorage")
    -- CoreGui mungkin tidak perlu, tapi kita tambahkan
    scan(CoreGui, "CoreGui")
    return remotes
end

local function copyToClipboard(text)
    local clipboard = setclipboard or toclipboard or function() end
    if clipboard then
        clipboard(text)
        return true
    else
        return false
    end
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "RemoteScanner"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 400)
mainFrame.Position = UDim2.new(0.5, -250, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.9
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "🔍 Remote Scanner"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = mainFrame

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 2)
closeBtn.Text = "✕"
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.fromRGB(255,0,0)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = mainFrame
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Scrolling frame untuk daftar remote
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -80)
scroll.Position = UDim2.new(0, 5, 0, 35)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 5
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = scroll

-- Refresh button
local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0, 100, 0, 30)
refreshBtn.Position = UDim2.new(0.05, 0, 1, -38)
refreshBtn.Text = "Scan Ulang"
refreshBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
refreshBtn.TextColor3 = Color3.fromRGB(255,255,255)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 12
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 4)
refreshBtn.Parent = mainFrame

-- Copy All button
local copyAllBtn = Instance.new("TextButton")
copyAllBtn.Size = UDim2.new(0, 120, 0, 30)
copyAllBtn.Position = UDim2.new(0.45, 0, 1, -38)
copyAllBtn.Text = "Copy Semua"
copyAllBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
copyAllBtn.TextColor3 = Color3.fromRGB(255,255,255)
copyAllBtn.Font = Enum.Font.GothamBold
copyAllBtn.TextSize = 12
Instance.new("UICorner", copyAllBtn).CornerRadius = UDim.new(0, 4)
copyAllBtn.Parent = mainFrame

local function populateList()
    -- Clear previous
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local remotes = getAllRemotes()
    if #remotes == 0 then
        local noItem = Instance.new("TextLabel")
        noItem.Size = UDim2.new(1, 0, 0, 30)
        noItem.BackgroundTransparency = 1
        noItem.Text = "Tidak ada remote ditemukan."
        noItem.TextColor3 = Color3.fromRGB(200,200,200)
        noItem.Font = Enum.Font.Gotham
        noItem.TextSize = 12
        noItem.Parent = scroll
        return
    end

    for _, info in ipairs(remotes) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        btn.Text = info.Name .. "  (" .. info.Class .. ")  " .. info.Path
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 10
        btn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.Parent = scroll

        -- Tombol copy untuk remote ini
        local copyBtn = Instance.new("TextButton")
        copyBtn.Size = UDim2.new(0, 50, 0, 22)
        copyBtn.Position = UDim2.new(1, -55, 0.5, -11)
        copyBtn.Text = "Copy"
        copyBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 70)
        copyBtn.TextColor3 = Color3.fromRGB(255,255,255)
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.TextSize = 10
        Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 4)
        copyBtn.Parent = btn

        copyBtn.MouseButton1Click:Connect(function()
            local text = "local remote = game:GetService(\"ReplicatedStorage\")" -- default
            -- Kita coba buat string yang lebih akurat berdasarkan path
            local pathParts = {}
            for part in string.gmatch(info.Path, "[^%.]+") do
                table.insert(pathParts, part)
            end
            -- Buat script untuk mengakses remote
            local pathStr = ""
            for i, part in ipairs(pathParts) do
                if i == 1 then
                    pathStr = pathStr .. "game:GetService(\"" .. part .. "\")"
                else
                    pathStr = pathStr .. ":FindFirstChild(\"" .. part .. "\")"
                end
            end
            local scriptText = "local remote = " .. pathStr .. "\n-- Remote type: " .. info.Class
            if copyToClipboard(scriptText) then
                print("Copied: " .. scriptText)
            else
                print("Copy failed")
            end
        end)
    end
end

refreshBtn.MouseButton1Click:Connect(populateList)

copyAllBtn.MouseButton1Click:Connect(function()
    local remotes = getAllRemotes()
    local lines = {}
    for _, info in ipairs(remotes) do
        table.insert(lines, info.Path .. " (" .. info.Class .. ")")
    end
    local fullText = table.concat(lines, "\n")
    if copyToClipboard(fullText) then
        print("Semua remote dicopy!")
    else
        print("Copy semua gagal")
    end
end)

-- Initial populate
populateList()

print("✅ Remote Scanner loaded! UI muncul di layar.")
