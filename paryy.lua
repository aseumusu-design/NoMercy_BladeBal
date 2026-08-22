--[[
=========================================================================
    NO MERCY HUB - SERVER-SIDE INVISIBLE (AUTO FIND REMOTE)
    - Mencari remote yang berpotensi untuk invisibility
    - Jika ditemukan, kirim permintaan ke server
    - Jika tidak, fallback ke client-side (hanya untukmu)
=========================================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Config = {
    Invisible = false,
    RemoteFound = false,
    RemoteObject = nil,
}

-- Cari remote yang mungkin untuk invisibility
local function FindInvisibleRemote()
    local remoteNames = {
        "Invisible", "Invisibility", "SetInvisible", "ToggleInvisible",
        "SetTransparency", "Transparency", "SetCharacterTransparency",
        "MakeInvisible", "Hide", "Ghost", "Stealth"
    }
    
    local function searchIn(obj)
        for _, name in ipairs(remoteNames) do
            local found = obj:FindFirstChild(name)
            if found and (found:IsA("RemoteEvent") or found:IsA("RemoteFunction")) then
                return found
            end
        end
        -- Cari di semua anak
        for _, child in ipairs(obj:GetChildren()) do
            local found = searchIn(child)
            if found then return found end
        end
        return nil
    end
    
    return searchIn(ReplicatedStorage) or searchIn(game:GetService("ReplicatedFirst"))
end

-- Fungsi untuk mengirim remote
local function SendInvisibleRemote(state)
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

-- Client-side fallback (hanya untukmu)
local function ApplyClientInvisible(state)
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = state and 1 or 0
        end
    end
end

-- Cari remote saat script dijalankan
local remote = FindInvisibleRemote()
if remote then
    Config.RemoteFound = true
    Config.RemoteObject = remote
    print("✅ Remote invisibility ditemukan: " .. remote.Name)
else
    print("⚠️ Remote invisibility tidak ditemukan. Gunakan client-side.")
end

-- Toggle invisible
local function ToggleInvisible()
    Config.Invisible = not Config.Invisible
    local state = Config.Invisible
    
    if Config.RemoteFound then
        local success = SendInvisibleRemote(state)
        if success then
            print("✅ Invisible server-side berhasil dikirim.")
            return
        else
            print("⚠️ Gagal mengirim remote, fallback ke client-side.")
        end
    end
    
    -- Fallback client-side
    ApplyClientInvisible(state)
    print("Invisible client-side: " .. tostring(state))
end

-- Buat GUI sederhana untuk toggle
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0, 150, 0, 40)
btn.Position = UDim2.new(0.5, -75, 0.5, -20)
btn.Text = "INVISIBLE OFF"
btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

btn.MouseButton1Click:Connect(function()
    ToggleInvisible()
    btn.Text = Config.Invisible and "INVISIBLE ON" or "INVISIBLE OFF"
    btn.BackgroundColor3 = Config.Invisible and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

print("✅ Script Invisible siap digunakan. Klik tombol untuk toggle.")
