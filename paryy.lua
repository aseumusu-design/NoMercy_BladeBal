--[[
    NO MERCY â€” VIOLENCE DISTRICT
    Safe Orion UI Edition

    Fitur yang disertakan:
    - Welcome intro dengan logo dan banner
    - UI Orion dengan branding NO MERCY
    - Bubble hide/show
    - Dialog konfirmasi close
    - Notification system
    - Pengaturan UI lokal
    - Export, import, save, load, dan reset config
    - Safe tools: server information, FPS counter, clock, dan UI diagnostics

    Catatan keamanan:
    Script ini hanya mengatur UI dan utilitas lokal. Script tidak menggunakan
    hookmetamethod, silent aim, auto-parry, generator bypass, remote abuse,
    teleport paksa, fling, kill-all, atau manipulasi pemain/gameplay.
]]

-- ============================================================
-- SERVICES
-- ============================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- BRANDING
-- ============================================================
local ICON = {
    Info      = "rbxassetid://7733964719",
    Settings  = "rbxassetid://7734053495",
    Logo      = "rbxassetid://102609928046926",
    Banner    = "rbxassetid://138968189462646",
    Monitor   = "rbxassetid://7733774602",
    Clipboard = "rbxassetid://7733954760",
}

local ORION_URL = "https://raw.githubusercontent.com/Marpiii/UiLib/refs/heads/main/source.lua"
local CONFIG_FOLDER = "NoMercyViolence"
local CONFIG_FILE = CONFIG_FOLDER .. "/SafeSettings.json"

local DEFAULTS = {
    Notifications = true,
    ShowWelcomeIntro = true,
    ShowBubbleOnClose = true,
    ShowFPS = false,
    ShowClock = false,
    CompactMode = false,
    Accent = "Grey",
}

local State = {}
for key, value in pairs(DEFAULTS) do
    State[key] = value
end

local Connections = {}
local RuntimeGuis = {}
local BubbleGui = nil
local MainWindowFrame = nil
local CloseDialogGui = nil
local FpsGui = nil
local ClockGui = nil
local OrionLib = nil
local Window = nil
local Notify = function() end
local IsShuttingDown = false

-- ============================================================
-- SAFE EXECUTOR FILE HELPERS
-- ============================================================
local function canUseFileApi()
    return type(isfile) == "function"
        and type(readfile) == "function"
        and type(writefile) == "function"
end

local function ensureConfigFolder()
    if type(makefolder) == "function" and type(isfolder) == "function" then
        pcall(function()
            if not isfolder(CONFIG_FOLDER) then
                makefolder(CONFIG_FOLDER)
            end
        end)
    end
end

local function saveConfigFile()
    if not canUseFileApi() then
        return false, "File API tidak tersedia pada executor ini."
    end

    ensureConfigFolder()
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(State)
    end)
    if not ok then
        return false, "Gagal membuat JSON config."
    end

    local written = pcall(function()
        writefile(CONFIG_FILE, encoded)
    end)
    if not written then
        return false, "Gagal menyimpan file config."
    end

    return true, CONFIG_FILE
end

local function loadConfigFile()
    if not canUseFileApi() or type(isfile) ~= "function" then
        return false, "File API tidak tersedia pada executor ini."
    end

    if not isfile(CONFIG_FILE) then
        return false, "Config belum pernah disimpan."
    end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(CONFIG_FILE))
    end)
    if not ok or type(data) ~= "table" then
        return false, "Format config tidak valid."
    end

    for key, defaultValue in pairs(DEFAULTS) do
        if data[key] ~= nil and type(data[key]) == type(defaultValue) then
            State[key] = data[key]
        end
    end

    return true, CONFIG_FILE
end

local function resetConfigState()
    for key, value in pairs(DEFAULTS) do
        State[key] = value
    end
end

local function configText()
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode({
            Product = "NO MERCY â€” VIOLENCE DISTRICT",
            Version = "Safe Orion Edition",
            Settings = State,
        })
    end)
    return ok and encoded or ""
end

local function importConfigText(raw)
    if type(raw) ~= "string" or raw == "" then
        return false, "Teks config kosong."
    end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if not ok or type(data) ~= "table" then
        return false, "Teks config bukan JSON yang valid."
    end

    local source = data.Settings or data
    if type(source) ~= "table" then
        return false, "Bagian Settings tidak ditemukan."
    end

    local changed = false
    for key, defaultValue in pairs(DEFAULTS) do
        if source[key] ~= nil and type(source[key]) == type(defaultValue) then
            State[key] = source[key]
            changed = true
        end
    end

    return changed, changed and "Config berhasil diimpor." or "Tidak ada setting yang cocok."
end

-- ============================================================
-- GUI HELPERS
-- ============================================================
local function getGuiParent()
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then
            return hui
        end
    end

    local ok, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)
    if ok and coreGui then
        return coreGui
    end

    return LocalPlayer:WaitForChild("PlayerGui")
end

local function protectGui(gui)
    pcall(function()
        if syn and type(syn.protect_gui) == "function" then
            syn.protect_gui(gui)
        end
    end)
end

local function createConnection(connection)
    table.insert(Connections, connection)
    return connection
end

local function destroyRuntimeGui(gui)
    if gui and gui.Parent then
        pcall(function()
            gui:Destroy()
        end)
    end
end

local function tween(instance, duration, properties)
    local ok, result = pcall(function()
        local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local animation = TweenService:Create(instance, info, properties)
        animation:Play()
        return animation
    end)
    return ok and result or nil
end

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
local function notify(title, content, duration)
    if not State.Notifications then
        return
    end

    pcall(function()
        if OrionLib and OrionLib.MakeNotification then
            OrionLib:MakeNotification({
                Name = title,
                Content = content,
                Image = ICON.Logo,
                Time = duration or 3,
            })
        elseif Window and Window.Notify then
            Window:Notify({
                Title = title,
                Content = content,
                Duration = duration or 3,
                Icon = ICON.Logo,
            })
        else
            print("[NO MERCY] " .. tostring(title) .. ": " .. tostring(content))
        end
    end)
end
Notify = notify

-- ============================================================
-- WELCOME INTRO
-- ============================================================
local function showWelcomeIntro()
    if not State.ShowWelcomeIntro then
        return
    end

    local holder = getGuiParent()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NoMercyWelcome"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.Parent = holder
    protectGui(gui)
    table.insert(RuntimeGuis, gui)

    local root = Instance.new("Frame")
    root.Size = UDim2.fromOffset(320, 260)
    root.Position = UDim2.fromScale(0.5, 0.5)
    root.AnchorPoint = Vector2.new(0.5, 0.5)
    root.BackgroundTransparency = 1
    root.Parent = gui

    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.fromOffset(0, 0)
    logo.Position = UDim2.fromScale(0.5, 0.38)
    logo.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.BackgroundTransparency = 1
    logo.Image = ICON.Logo
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Parent = root

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = logo

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(220, 220, 220)
    stroke.Thickness = 3
    stroke.Transparency = 1
    stroke.Parent = logo

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 38)
    title.Position = UDim2.fromScale(0.5, 0.76)
    title.AnchorPoint = Vector2.new(0.5, 0)
    title.BackgroundTransparency = 1
    title.Text = "NO MERCY"
    title.TextColor3 = Color3.fromRGB(245, 245, 245)
    title.TextTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.Parent = root

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 24)
    subtitle.Position = UDim2.fromScale(0.5, 0.90)
    subtitle.AnchorPoint = Vector2.new(0.5, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "SAFE ORION EDITION"
    subtitle.TextColor3 = Color3.fromRGB(155, 155, 155)
    subtitle.TextTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 12
    subtitle.Parent = root

    local logoIn = tween(logo, 0.6, { Size = UDim2.fromOffset(138, 138) })
    tween(stroke, 0.45, { Transparency = 0 })
    tween(title, 0.45, { TextTransparency = 0 })
    tween(subtitle, 0.55, { TextTransparency = 0 })

    if logoIn then
        pcall(function()
            logoIn.Completed:Wait()
        end)
    end

    task.wait(1.1)
    tween(logo, 0.35, { Size = UDim2.fromOffset(0, 0) })
    tween(stroke, 0.3, { Transparency = 1 })
    tween(title, 0.3, { TextTransparency = 1 })
    tween(subtitle, 0.3, { TextTransparency = 1 })
    task.wait(0.4)
    destroyRuntimeGui(gui)
end

-- ============================================================
-- ORION LOADER
-- ============================================================
local function loadOrion()
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(ORION_URL))()
    end)
    if not ok or not result then
        error("Orion UI gagal dimuat. Pastikan executor mengizinkan HttpGet dan loadstring.")
    end
    return result
end

-- ============================================================
-- MAIN WINDOW DISCOVERY
-- ============================================================
local function findMainWindow()
    local holder = getGuiParent()
    local marv = holder:FindFirstChild("MarV")
    if not marv then
        return nil
    end

    for _, child in ipairs(marv:GetChildren()) do
        if child:IsA("Frame") and child.AbsoluteSize.X > 300 then
            return child
        end
    end

    return nil
end

local function hideMainWindow()
    MainWindowFrame = MainWindowFrame or findMainWindow()
    if MainWindowFrame then
        MainWindowFrame.Visible = false
    end
end

local function showMainWindow()
    MainWindowFrame = MainWindowFrame or findMainWindow()
    if MainWindowFrame then
        MainWindowFrame.Visible = true
    end
end

-- ============================================================
-- BUBBLE HIDE/SHOW
-- ============================================================
local function createBubble()
    if BubbleGui then
        destroyRuntimeGui(BubbleGui)
        BubbleGui = nil
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "NoMercyBubble"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.Parent = getGuiParent()
    protectGui(gui)
    BubbleGui = gui

    local button = Instance.new("ImageButton")
    button.Name = "OpenNoMercy"
    button.Size = UDim2.fromOffset(52, 52)
    button.Position = UDim2.new(0.02, 0, 0.22, 0)
    button.BackgroundColor3 = Color3.fromRGB(25, 30, 35)
    button.Image = ICON.Logo
    button.ScaleType = Enum.ScaleType.Fit
    button.Active = true
    button.Draggable = true
    button.ZIndex = 10
    button.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(215, 215, 215)
    stroke.Thickness = 2
    stroke.Parent = button

    task.spawn(function()
        while BubbleGui == gui and gui.Parent and stroke.Parent do
            local a = tween(stroke, 0.8, { Transparency = 0.75, Thickness = 4 })
            if a then pcall(function() a.Completed:Wait() end) end
            if BubbleGui ~= gui or not gui.Parent then break end
            local b = tween(stroke, 0.8, { Transparency = 0, Thickness = 2 })
            if b then pcall(function() b.Completed:Wait() end) end
        end
    end)

    createConnection(button.MouseButton1Click:Connect(function()
        showMainWindow()
        destroyRuntimeGui(gui)
        if BubbleGui == gui then
            BubbleGui = nil
        end
    end))
end

-- ============================================================
-- CLOSE CONFIRMATION
-- ============================================================
local function closeDialog()
    if CloseDialogGui then
        destroyRuntimeGui(CloseDialogGui)
        CloseDialogGui = nil
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "NoMercyConfirm"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.Parent = getGuiParent()
    protectGui(gui)
    CloseDialogGui = gui

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.38
    overlay.ZIndex = 90
    overlay.Parent = gui

    local box = Instance.new("Frame")
    box.Size = UDim2.fromOffset(300, 160)
    box.Position = UDim2.fromScale(0.5, 0.5)
    box.AnchorPoint = Vector2.new(0.5, 0.5)
    box.BackgroundColor3 = Color3.fromRGB(28, 32, 38)
    box.BorderSizePixel = 0
    box.ZIndex = 100
    box.Parent = gui

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 12)
    boxCorner.Parent = box

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 30)
    title.Position = UDim2.fromOffset(20, 15)
    title.BackgroundTransparency = 1
    title.Text = "Tutup NO MERCY?"
    title.TextColor3 = Color3.fromRGB(240, 240, 240)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 101
    title.Parent = box

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -40, 0, 32)
    desc.Position = UDim2.fromOffset(20, 50)
    desc.BackgroundTransparency = 1
    desc.Text = "UI akan disembunyikan dan dapat dibuka melalui bubble."
    desc.TextWrapped = true
    desc.TextColor3 = Color3.fromRGB(160, 160, 160)
    desc.TextSize = 13
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.ZIndex = 101
    desc.Parent = box

    local yes = Instance.new("TextButton")
    yes.Size = UDim2.fromOffset(105, 36)
    yes.Position = UDim2.new(1, -225, 1, -50)
    yes.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    yes.BorderSizePixel = 0
    yes.Text = "Ya"
    yes.TextColor3 = Color3.new(1, 1, 1)
    yes.TextSize = 15
    yes.Font = Enum.Font.GothamBold
    yes.ZIndex = 101
    yes.Parent = box

    local yesCorner = Instance.new("UICorner")
    yesCorner.CornerRadius = UDim.new(0, 8)
    yesCorner.Parent = yes

    local no = Instance.new("TextButton")
    no.Size = UDim2.fromOffset(105, 36)
    no.Position = UDim2.new(1, -110, 1, -50)
    no.BackgroundColor3 = Color3.fromRGB(40, 45, 52)
    no.BorderSizePixel = 0
    no.Text = "Tidak"
    no.TextColor3 = Color3.fromRGB(240, 240, 240)
    no.TextSize = 15
    no.Font = Enum.Font.GothamBold
    no.ZIndex = 101
    no.Parent = box

    local noCorner = Instance.new("UICorner")
    noCorner.CornerRadius = UDim.new(0, 8)
    noCorner.Parent = no

    local function cancel()
        destroyRuntimeGui(gui)
        if CloseDialogGui == gui then
            CloseDialogGui = nil
        end
        showMainWindow()
    end

    createConnection(no.MouseButton1Click:Connect(cancel))
    createConnection(overlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            cancel()
        end
    end))

    createConnection(yes.MouseButton1Click:Connect(function()
        destroyRuntimeGui(gui)
        if CloseDialogGui == gui then
            CloseDialogGui = nil
        end
        hideMainWindow()
        if State.ShowBubbleOnClose then
            createBubble()
        end
    end))
end

-- ============================================================
-- SAFE LOCAL WIDGETS
-- ============================================================
local function destroyFpsGui()
    destroyRuntimeGui(FpsGui)
    FpsGui = nil
end

local function createFpsGui()
    if FpsGui then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "NoMercySafeOverlay"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = getGuiParent()
    protectGui(gui)
    FpsGui = gui

    local label = Instance.new("TextLabel")
    label.Name = "Status"
    label.Size = UDim2.fromOffset(180, 48)
    label.Position = UDim2.new(1, -190, 0, 12)
    label.BackgroundColor3 = Color3.fromRGB(20, 24, 28)
    label.BackgroundTransparency = 0.15
    label.TextColor3 = Color3.fromRGB(235, 235, 235)
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.Text = "NO MERCY"
    label.ZIndex = 10
    label.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = label

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.Parent = label

    local elapsed = 0
    local frames = 0
    createConnection(RunService.RenderStepped:Connect(function(dt)
        if not FpsGui or not FpsGui.Parent then return end
        elapsed += dt
        frames += 1
        if elapsed >= 0.5 then
            local fps = math.floor(frames / elapsed + 0.5)
            local ping = "N/A"
            pcall(function()
                local network = Stats.Network
                local serverStats = network:FindFirstChild("ServerStatsItem")
                local dataPing = serverStats and serverStats:FindFirstChild("Data Ping")
                if dataPing then
                    ping = tostring(math.floor(dataPing:GetValue())) .. " ms"
                end
            end)
            label.Text = "FPS: " .. tostring(fps) .. "\nPing: " .. ping
            elapsed = 0
            frames = 0
        end
    end))
end

local function updateFpsGui()
    if State.ShowFPS or State.ShowClock then
        createFpsGui()
    else
        destroyFpsGui()
    end
end

local function applyWidgetState()
    updateFpsGui()
    if MainWindowFrame then
        MainWindowFrame.Size = State.CompactMode and UDim2.new(0, 360, 0, 420)
            or UDim2.new(0, 430, 0, 520)
    end
end

-- ============================================================
-- MAIN INITIALIZATION
-- ============================================================
local function initialize()
    local loaded, loadMessage = loadConfigFile()
    if loaded then
        print("[NO MERCY] Config dimuat: " .. tostring(loadMessage))
    end

    showWelcomeIntro()
    OrionLib = loadOrion()

    Window = OrionLib:MakeWindow({
        Name = "NO MERCY â€” VIOLENCE DISTRICT",
        HidePremium = false,
        SaveConfig = true,
        ConfigFolder = CONFIG_FOLDER,
        IntroEnabled = false,
        Icon = ICON.Logo,
        CloseCallback = function()
            closeDialog()
        end,
    })

    task.wait(0.25)
    MainWindowFrame = findMainWindow()

    local InfoTab = Window:MakeTab({
        Name = "Info",
        Icon = ICON.Info,
        PremiumOnly = false,
    })

    local ToolsTab = Window:MakeTab({
        Name = "Safe Tools",
        Icon = ICON.Monitor,
        PremiumOnly = false,
    })

    local SettingsTab = Window:MakeTab({
        Name = "Pengaturan",
        Icon = ICON.Settings,
        PremiumOnly = false,
    })

    -- --------------------------------------------------------
    -- INFO TAB
    -- --------------------------------------------------------
    local About = InfoTab:AddSection({ Name = "Tentang NO MERCY" })
    About:AddLabel("NO MERCY â€” Violence District")
    About:AddLabel("Safe Orion Edition")
    About:AddLabel("UI dan utilitas lokal tanpa manipulasi gameplay.")
    About:AddButton({
        Name = "Copy Safe Edition Info",
        Callback = function()
            local text = "NO MERCY â€” VIOLENCE DISTRICT | Safe Orion Edition"
            if type(setclipboard) == "function" then
                pcall(function() setclipboard(text) end)
                notify("NO MERCY", "Info berhasil disalin.", 3)
            else
                notify("NO MERCY", text, 4)
            end
        end,
    })

    local Branding = InfoTab:AddSection({ Name = "Branding" })
    Branding:AddLabel("Logo, banner, welcome intro, dan bubble dipertahankan.")
    Branding:AddButton({
        Name = "Tampilkan Welcome Intro",
        Callback = function()
            task.spawn(showWelcomeIntro)
        end,
    })

    task.spawn(function()
        task.wait(0.4)
        local main = findMainWindow()
        if not main then return end

        for _, child in ipairs(main:GetDescendants()) do
            if child:IsA("TextLabel") and child.Text == "Tentang NO MERCY" then
                local container = child.Parent and child.Parent.Parent
                if container and container:IsA("ScrollingFrame") then
                    local banner = Instance.new("ImageLabel")
                    banner.Name = "NoMercyBanner"
                    banner.Size = UDim2.new(1, -10, 0, 110)
                    banner.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
                    banner.BackgroundTransparency = 0
                    banner.Image = ICON.Banner
                    banner.ScaleType = Enum.ScaleType.Fit
                    banner.LayoutOrder = -999
                    banner.Parent = container

                    local bannerCorner = Instance.new("UICorner")
                    bannerCorner.CornerRadius = UDim.new(0, 8)
                    bannerCorner.Parent = banner
                    break
                end
            end
        end
    end)

    -- --------------------------------------------------------
    -- SAFE TOOLS TAB
    -- --------------------------------------------------------
    local RuntimeSection = ToolsTab:AddSection({ Name = "Local Diagnostics" })
    RuntimeSection:AddToggle({
        Name = "Show FPS / Ping",
        Default = State.ShowFPS,
        Callback = function(value)
            State.ShowFPS = value == true
            updateFpsGui()
        end,
    })

    RuntimeSection:AddToggle({
        Name = "Show Clock",
        Default = State.ShowClock,
        Callback = function(value)
            State.ShowClock = value == true
            updateFpsGui()
        end,
    })

    RuntimeSection:AddButton({
        Name = "Print Local Diagnostics",
        Callback = function()
            local placeId = tostring(game.PlaceId)
            local jobId = tostring(game.JobId)
            print("[NO MERCY] PlaceId: " .. placeId)
            print("[NO MERCY] JobId: " .. jobId)
            print("[NO MERCY] LocalPlayer: " .. tostring(LocalPlayer.Name))
            notify("Diagnostics", "Informasi lokal dicetak ke console.", 3)
        end,
    })

    RuntimeSection:AddButton({
        Name = "Copy Place ID",
        Callback = function()
            local text = tostring(game.PlaceId)
            if type(setclipboard) == "function" then
                pcall(function() setclipboard(text) end)
                notify("Diagnostics", "Place ID berhasil disalin.", 3)
            else
                notify("Diagnostics", "Place ID: " .. text, 4)
            end
        end,
    })

    local AppearanceSection = ToolsTab:AddSection({ Name = "Appearance" })
    AppearanceSection:AddToggle({
        Name = "Compact Mode",
        Default = State.CompactMode,
        Callback = function(value)
            State.CompactMode = value == true
            applyWidgetState()
        end,
    })

    AppearanceSection:AddDropdown({
        Name = "Accent Preset",
        Options = { "Grey", "Blue", "Purple", "Red" },
        Default = State.Accent,
        Callback = function(value)
            State.Accent = value
            notify("Appearance", "Preset " .. tostring(value) .. " dipilih.", 2)
        end,
    })

    -- --------------------------------------------------------
    -- SETTINGS TAB
    -- --------------------------------------------------------
    local GeneralSection = SettingsTab:AddSection({ Name = "General" })
    GeneralSection:AddToggle({
        Name = "Notifications",
        Default = State.Notifications,
        Callback = function(value)
            State.Notifications = value == true
            if State.Notifications then
                notify("NO MERCY", "Notifications diaktifkan.", 2)
            end
        end,
    })

    GeneralSection:AddToggle({
        Name = "Welcome Intro Saat Start",
        Default = State.ShowWelcomeIntro,
        Callback = function(value)
            State.ShowWelcomeIntro = value == true
        end,
    })

    GeneralSection:AddToggle({
        Name = "Bubble Saat UI Ditutup",
        Default = State.ShowBubbleOnClose,
        Callback = function(value)
            State.ShowBubbleOnClose = value == true
        end,
    })

    local ConfigSection = SettingsTab:AddSection({ Name = "Config Save / Load" })
    ConfigSection:AddButton({
        Name = "Save Config",
        Callback = function()
            local ok, message = saveConfigFile()
            if ok then
                notify("Config", "Config berhasil disimpan.", 3)
            else
                notify("Config", message, 4)
            end
        end,
    })

    ConfigSection:AddButton({
        Name = "Load Config",
        Callback = function()
            local ok, message = loadConfigFile()
            if ok then
                notify("Config", "Config berhasil dimuat. Jalankan ulang UI untuk menerapkan semua nilai.", 4)
            else
                notify("Config", message, 4)
            end
        end,
    })

    ConfigSection:AddButton({
        Name = "Export Config",
        Callback = function()
            local raw = configText()
            if type(setclipboard) == "function" then
                pcall(function() setclipboard(raw) end)
                notify("Config", "Config JSON disalin ke clipboard.", 3)
            else
                print(raw)
                notify("Config", "Clipboard tidak tersedia; JSON dicetak ke console.", 4)
            end
        end,
    })

    ConfigSection:AddButton({
        Name = "Import Config dari Clipboard",
        Callback = function()
            if type(getclipboard) ~= "function" then
                notify("Config", "getclipboard tidak tersedia pada executor ini.", 4)
                return
            end

            local okRead, raw = pcall(getclipboard)
            if not okRead then
                notify("Config", "Clipboard tidak dapat dibaca.", 4)
                return
            end

            local okImport, message = importConfigText(raw)
            notify("Config", message, 4)
            if okImport then
                saveConfigFile()
            end
        end,
    })

    ConfigSection:AddButton({
        Name = "Reset Config",
        Callback = function()
            resetConfigState()
            saveConfigFile()
            notify("Config", "Config direset ke nilai default. Jalankan ulang untuk menerapkan penuh.", 4)
        end,
    })

    local AboutSection = SettingsTab:AddSection({ Name = "Informasi Keamanan" })
    AboutSection:AddLabel("Versi ini tidak mengubah remote, target, movement, atau state pemain lain.")
    AboutSection:AddLabel("Semua setting yang disimpan hanya berisi preferensi UI lokal.")

    -- Orion internal config remains enabled as an additional UI preference layer.
    pcall(function()
        if OrionLib.LoadConfiguration then
            OrionLib:LoadConfiguration()
        end
    end)

    applyWidgetState()
    notify("NO MERCY", "Safe Orion Edition berhasil dimuat.", 4)
end

-- ============================================================
-- CLOCK UPDATE
-- ============================================================
createConnection(RunService.RenderStepped:Connect(function()
    if not FpsGui or not FpsGui.Parent then return end
    local label = FpsGui:FindFirstChild("Status")
    if not label then return end

    if State.ShowClock then
        local now = os.date("%H:%M:%S")
        local base = string.gsub(label.Text or "", "\nTime:.*$", "")
        if State.ShowFPS then
            label.Text = base .. "\nTime: " .. now
        else
            label.Text = "Time: " .. now
        end
    elseif State.ShowFPS then
        label.Text = string.gsub(label.Text or "", "\nTime:.*$", "")
    end
end))

-- ============================================================
-- CLEANUP
-- ============================================================
local function cleanup()
    if IsShuttingDown then return end
    IsShuttingDown = true

    if BubbleGui then
        destroyRuntimeGui(BubbleGui)
        BubbleGui = nil
    end
    if CloseDialogGui then
        destroyRuntimeGui(CloseDialogGui)
        CloseDialogGui = nil
    end
    destroyFpsGui()

    for _, connection in ipairs(Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(Connections)

    for _, gui in ipairs(RuntimeGuis) do
        destroyRuntimeGui(gui)
    end
    table.clear(RuntimeGuis)
end

-- Expose only safe local controls for optional external cleanup.
getgenv().NO_MERCY_SAFE_CLEANUP = cleanup
getgenv().NO_MERCY_SAFE_STATE = State

-- ============================================================
-- START
-- ============================================================
local ok, errorMessage = pcall(initialize)
if not ok then
    cleanup()
    warn("[NO MERCY] Gagal memuat Safe Orion Edition: " .. tostring(errorMessage))
end
