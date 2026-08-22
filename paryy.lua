--[[
=========================================================================
    NO MERCY HUB - HIDE BODY + FAKE CLONE (EXPERIMENTAL)
    - Menyembunyikan karakter asli di bawah map
    - Membuat clone yang bisa dikendalikan (berjalan, menembak)
    - Clone transparan agar terlihat seperti hantu
=========================================================================
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Config = {
    HideMode = false,
    Clone = nil,
    OriginalPos = nil,
    OriginalCFrame = nil,
    IsMoving = false,
}

-- ==================== FUNGSI UTAMA ====================

-- Menyembunyikan karakter asli di bawah map
local function HideOriginalCharacter()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Simpan posisi asli
    Config.OriginalPos = hrp.Position
    Config.OriginalCFrame = hrp.CFrame

    -- Teleport ke bawah map (y = -1000)
    local hiddenPos = CFrame.new(hrp.Position.X, -1000, hrp.Position.Z)
    hrp.CFrame = hiddenPos
    hrp.Anchored = true  -- Kunci agar tidak bergerak

    -- Buat semua part transparan dan non-collide
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
        end
    end

    -- Nonaktifkan Humanoid agar tidak jatuh
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = true
        hum.WalkSpeed = 0
        hum.JumpPower = 0
    end

    print("✅ Karakter asli disembunyikan di bawah map.")
end

-- Mengembalikan karakter asli
local function RestoreOriginalCharacter()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if Config.OriginalCFrame then
        hrp.CFrame = Config.OriginalCFrame
        hrp.Anchored = false
    end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0
            part.CanCollide = true
        end
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end

    print("✅ Karakter asli dikembalikan.")
end

-- Membuat clone karakter
local function CreateClone()
    local char = LocalPlayer.Character
    if not char then return end

    -- Clone model
    local clone = char:Clone()
    clone.Name = "FakeCharacter"
    clone.Parent = Workspace

    -- Posisikan clone di tempat karakter asli sebelumnya
    local hrp = clone:FindFirstChild("HumanoidRootPart")
    if hrp and Config.OriginalPos then
        hrp.CFrame = CFrame.new(Config.OriginalPos)
    end

    -- Beri Humanoid agar bisa bergerak
    local hum = clone:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end

    -- Set transparansi agar terlihat samar (opsional)
    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0.3
        end
    end

    Config.Clone = clone
    print("✅ Clone karakter dibuat.")
    return clone
end

-- Menghapus clone
local function RemoveClone()
    if Config.Clone then
        Config.Clone:Destroy()
        Config.Clone = nil
        print("✅ Clone dihapus.")
    end
end

-- ==================== KENDALIKAN CLONE ====================

-- Fungsi untuk menggerakkan clone mengikuti mouse/arah kamera
local function MoveClone(direction)
    if not Config.Clone then return end
    local hrp = Config.Clone:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = Config.Clone:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    -- Gerakkan clone dengan kecepatan tertentu
    local speed = 16
    local moveVector = direction * speed
    hrp.Velocity = Vector3.new(moveVector.X, hrp.Velocity.Y, moveVector.Z)

    -- Arahkan clone menghadap ke arah kamera
    local lookDir = Camera.CFrame.LookVector
    hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(lookDir.X, 0, lookDir.Z))
end

-- Fungsi untuk clone menembak (contoh, sesuaikan dengan game)
local function CloneFire()
    if not Config.Clone then return end
    -- Cari remote Fire (seperti di aimbot sebelumnya)
    local fireRemote = ReplicatedStorage:FindFirstChild("Remotes")
    if fireRemote then
        fireRemote = fireRemote:FindFirstChild("Items")
    end
    if fireRemote then
        fireRemote = fireRemote:FindFirstChild("Twist of Fate")
    end
    if fireRemote then
        fireRemote = fireRemote:FindFirstChild("Fire")
    end
    if not fireRemote then return end

    -- Ambil senjata dari clone
    local tool = Config.Clone:FindFirstChild("Twist of Fate")
    local gun = tool and tool:FindFirstChild("Right Arm") and tool["Right Arm"]:FindFirstChild("EmperorGun")
    if not gun then return end

    -- Arah tembak ke posisi target (misalnya ke tengah layar)
    local targetPos = Camera.CFrame.Position + Camera.CFrame.LookVector * 100
    local from = gun.Position
    local dir = (targetPos - from).Unit
    pcall(function()
        fireRemote:FireServer(gun, Vector3.new(dir.X, dir.Y, dir.Z))
    end)
end

-- ==================== INPUT HANDLING ====================

-- Deteksi tombol WASD untuk menggerakkan clone
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not Config.HideMode then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode.Name
        if key == "W" or key == "A" or key == "S" or key == "D" then
            Config.IsMoving = true
        end
        -- Tombol F untuk menembak
        if key == "F" then
            CloneFire()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed or not Config.HideMode then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode.Name
        if key == "W" or key == "A" or key == "S" or key == "D" then
            Config.IsMoving = false
        end
    end
end)

-- Loop untuk menggerakkan clone setiap frame
RunService.RenderStepped:Connect(function()
    if not Config.HideMode or not Config.Clone then return end

    local moveDir = Vector3.new(0, 0, 0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDir = moveDir + Camera.CFrame.LookVector * Vector3.new(1, 0, 1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDir = moveDir - Camera.CFrame.LookVector * Vector3.new(1, 0, 1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDir = moveDir - Camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDir = moveDir + Camera.CFrame.RightVector
    end
    if moveDir.Magnitude > 0 then
        MoveClone(moveDir.Unit)
    else
        -- Hentikan gerakan jika tidak ada tombol
        local hrp = Config.Clone:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
        end
    end
end)

-- ==================== GUI TOGGLE ====================

local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0, 200, 0, 50)
btn.Position = UDim2.new(0.5, -100, 0.5, -25)
btn.Text = "HIDE MODE OFF"
btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

btn.MouseButton1Click:Connect(function()
    Config.HideMode = not Config.HideMode
    if Config.HideMode then
        HideOriginalCharacter()
        CreateClone()
        btn.Text = "HIDE MODE ON"
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        RemoveClone()
        RestoreOriginalCharacter()
        btn.Text = "HIDE MODE OFF"
        btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end)

print("✅ SCRIPT HIDE BODY + FAKE CLONE LOADED!")
print("🔹 Aktifkan 'HIDE MODE' untuk menyembunyikan karakter asli dan membuat clone.")
print("🔹 Gunakan WASD untuk menggerakkan clone, F untuk menembak.")
