--[[
=========================================================================
    NO MERCY HUB - HIDE BODY + FAKE CLONE (BERJALAN & TEMBAK)
    - Karakter asli disembunyikan di bawah map
    - Clone berjalan normal (WASD), melompat (Space), menembak (Klik Kiri)
    - Kamera mengikuti clone
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

-- ==================== KAMERA ====================

local function SetCameraToClone(clone)
    if not clone then return end
    local hum = clone:FindFirstChildOfClass("Humanoid")
    if hum then
        Camera.CameraSubject = hum
    else
        local hrp = clone:FindFirstChild("HumanoidRootPart")
        if hrp then
            Camera.CameraSubject = hrp
        end
    end
    print("📷 Kamera beralih ke clone.")
end

local function ResetCamera()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            Camera.CameraSubject = hum
        end
    end
    print("📷 Kamera kembali ke karakter asli.")
end

-- ==================== FUNGSI UTAMA ====================

local function HideOriginalCharacter()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    Config.OriginalPos = hrp.Position
    Config.OriginalCFrame = hrp.CFrame

    local hiddenPos = CFrame.new(hrp.Position.X, -1000, hrp.Position.Z)
    hrp.CFrame = hiddenPos
    hrp.Anchored = true

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
        end
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = true
        hum.WalkSpeed = 0
        hum.JumpPower = 0
    end

    print("✅ Karakter asli disembunyikan.")
end

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

local function CreateClone()
    local char = LocalPlayer.Character
    if not char then return end

    local clone = char:Clone()
    clone.Name = "FakeCharacter"
    clone.Parent = Workspace

    -- Posisikan clone di tempat karakter asli sebelumnya
    local hrp = clone:FindFirstChild("HumanoidRootPart")
    if hrp and Config.OriginalPos then
        hrp.CFrame = CFrame.new(Config.OriginalPos)
    end

    -- Aktifkan Humanoid clone
    local hum = clone:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end

    -- Set transparansi clone (opsional)
    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0.3
        end
    end

    Config.Clone = clone
    SetCameraToClone(clone)

    print("✅ Clone dibuat.")
    return clone
end

local function RemoveClone()
    if Config.Clone then
        Config.Clone:Destroy()
        Config.Clone = nil
        ResetCamera()
        print("✅ Clone dihapus.")
    end
end

-- ==================== KENDALIKAN CLONE ====================

-- Fungsi untuk menggerakkan clone menggunakan Humanoid:MoveTo()
local function MoveClone(direction)
    if not Config.Clone then return end
    local hum = Config.Clone:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local hrp = Config.Clone:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if direction.Magnitude > 0 then
        local targetPos = hrp.Position + direction * 2
        hum:MoveTo(targetPos)
        -- Arahkan menghadap ke arah kamera
        local lookDir = Camera.CFrame.LookVector
        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(lookDir.X, 0, lookDir.Z))
    else
        hum:MoveTo(hrp.Position) -- berhenti
    end
end

-- Clone menembak (remote Fire)
local function CloneFire()
    if not Config.Clone then return end
    -- Cari remote Fire
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
    if not fireRemote then
        print("⚠️ Remote Fire tidak ditemukan.")
        return
    end

    local tool = Config.Clone:FindFirstChild("Twist of Fate")
    local gun = tool and tool:FindFirstChild("Right Arm") and tool["Right Arm"]:FindFirstChild("EmperorGun")
    if not gun then
        print("⚠️ Clone tidak memiliki senjata.")
        return
    end

    -- Target: ke arah kamera
    local targetPos = Camera.CFrame.Position + Camera.CFrame.LookVector * 100
    local from = gun.Position
    local dir = (targetPos - from).Unit
    pcall(function()
        fireRemote:FireServer(gun, Vector3.new(dir.X, dir.Y, dir.Z))
        print("🔫 Clone menembak!")
    end)
end

-- ==================== INPUT HANDLING ====================

-- Gerakan WASD
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not Config.HideMode then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode.Name
        if key == "W" or key == "A" or key == "S" or key == "D" then
            Config.IsMoving = true
        end
        if key == "F" then
            CloneFire()
        end
        -- Lompat dengan Space
        if key == "Space" then
            local hum = Config.Clone and Config.Clone:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Jump = true
            end
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

-- Klik kiri mouse untuk menembak
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not Config.HideMode then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        CloneFire()
    end
end)

-- Loop gerakan clone
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
    -- Normalisasi dan panggil MoveClone
    if moveDir.Magnitude > 0 then
        MoveClone(moveDir.Unit)
    else
        MoveClone(Vector3.new(0,0,0))
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

print("✅ HIDE BODY + FAKE CLONE (BERJALAN & TEMBAK) LOADED!")
print("🔹 Aktifkan HIDE MODE, WASD jalan, Space lompat, Klik Kiri atau F tembak.")
