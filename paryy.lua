-- [[ CUSTOM ARTHEIRS-STYLE UI LIBRARY ]] --
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Library = {}

-- 1. Intro Animasi ala Panel Modern
function Library.ShowIntro(titleText)
    local IntroGui = Instance.new("ScreenGui")
    IntroGui.Name = "ArtheirsIntro"
    IntroGui.Parent = CoreGui
    
    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(0, 0, 0, 0)
    Box.Position = UDim2.new(0.5, 0, 0.5, 0)
    Box.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
    Box.BorderSizePixel = 0
    Box.Parent = IntroGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Box
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(110, 80, 200)
    Stroke.Thickness = 2
    Stroke.Parent = Box
    
    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, 0, 1, 0)
    Text.BackgroundTransparency = 1
    Text.Text = titleText or "LOADING ARTHEIRS..."
    Text.TextColor3 = Color3.fromRGB(255, 255, 255)
    Text.TextSize = 14
    Text.Font = Enum.Font.GothamBold
    Text.TextTransparency = 1
    Text.Parent = Box
    
    Box.Visible = true
    TweenService:Create(Box, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 240, 0, 70),
        Position = UDim2.new(0.5, -120, 0.5, -35)
    }):Play()
    
    task.wait(0.3)
    TweenService:Create(Text, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    
    task.wait(2)
    
    TweenService:Create(Text, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    
    task.wait(0.5)
    IntroGui:Destroy()
end

-- 2. Fungsi Utama Membuat Window Dashboard
function Library:CreateWindow(hubName, gameSubTitle)
    local Window = {}
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ArtheirsHub"
    ScreenGui.Parent = CoreGui
    
    -- Main Container (Frame Utama)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 620, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -310, 0.5, -190)
    MainFrame.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(35, 38, 48)
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame
    
    -- === SIDEBAR KIRI ===
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 170, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 23, 31)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SideCorner = Instance.new("UICorner")
    SideCorner.CornerRadius = UDim.new(0, 10)
    SideCorner.Parent = Sidebar
    
    -- Kotak Logo di Sidebar Atas
    local LogoContainer = Instance.new("Frame")
    LogoContainer.Size = UDim2.new(1, -20, 0, 50)
    LogoContainer.Position = UDim2.new(0, 10, 0, 12)
    LogoContainer.BackgroundColor3 = Color3.fromRGB(26, 30, 41)
    LogoContainer.BorderSizePixel = 0
    LogoContainer.Parent = Sidebar
    
    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(0, 8)
    LogoCorner.Parent = LogoContainer
    
    local LogoText = Instance.new("TextLabel")
    LogoText.Size = UDim2.new(1, -10, 1, 0)
    LogoText.Position = UDim2.new(0, 10, 0, 0)
    LogoText.BackgroundTransparency = 1
    LogoText.Text = hubName or "Artheirs"
    LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoText.TextSize = 14
    LogoText.Font = Enum.Font.GothamBold
    LogoText.TextXAlignment = Enum.TextXAlignment.Left
    LogoText.Parent = LogoContainer
    
    local SubText = Instance.new("TextLabel")
    SubText.Size = UDim2.new(1, -10, 0, 15)
    SubText.Position = UDim2.new(0, 10, 0, 26)
    SubText.BackgroundTransparency = 1
    SubText.Text = gameSubTitle or "Violence District"
    SubText.TextColor3 = Color3.fromRGB(140, 145, 160)
    SubText.TextSize = 10
    SubText.Font = Enum.Font.Gotham
    SubText.TextXAlignment = Enum.TextXAlignment.Left
    SubText.Parent = LogoContainer
    
    -- Tempat Menu Tab di Sidebar
    local MenuHolder = Instance.new("ScrollingFrame")
    MenuHolder.Size = UDim2.new(1, -16, 1, -140)
    MenuHolder.Position = UDim2.new(0, 8, 0, 75)
    MenuHolder.BackgroundTransparency = 1
    MenuHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    MenuHolder.ScrollBarThickness = 0
    MenuHolder.Parent = Sidebar
    
    local MenuLayout = Instance.new("UIListLayout")
    MenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
    MenuLayout.Padding = UDim.new(0, 4)
    MenuLayout.Parent = MenuHolder
    
    -- Profil Akun di Bawah Sidebar
    local ProfileBox = Instance.new("Frame")
    ProfileBox.Size = UDim2.new(1, -20, 0, 45)
    ProfileBox.Position = UDim2.new(0, 10, 1, -55)
    ProfileBox.BackgroundColor3 = Color3.fromRGB(26, 30, 41)
    ProfileBox.BorderSizePixel = 0
    ProfileBox.Parent = Sidebar
    
    local ProfCorner = Instance.new("UICorner")
    ProfCorner.CornerRadius = UDim.new(0, 8)
    ProfCorner.Parent = ProfileBox
    
    local ProfName = Instance.new("TextLabel")
    ProfName.Size = UDim2.new(1, -15, 1, 0)
    ProfName.Position = UDim2.new(0, 12, 0, 0)
    ProfName.BackgroundTransparency = 1
    ProfName.Text = LocalPlayer.Name
    ProfName.TextColor3 = Color3.fromRGB(220, 225, 235)
    ProfName.TextSize = 12
    ProfName.Font = Enum.Font.GothamBold
    ProfName.TextXAlignment = Enum.TextXAlignment.Left
    ProfName.Parent = ProfileBox
    
    -- === CONTENT KANAN (HALAMAN UTAMA) ===
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -185, 1, -15)
    ContentContainer.Position = UDim2.new(0, 178, 0, 10)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame
    
    local firstTab = true
    
    function Window:AddTab(tabName, iconAsset)
        local Tab = {}
        
        -- Tombol Menu di Sidebar Kiri
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3 = Color3.fromRGB(20, 23, 31)
        TabBtn.Text = "    " .. tabName
        TabBtn.TextColor3 = Color3.fromRGB(150, 155, 170)
        TabBtn.TextSize = 12
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Parent = MenuHolder
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = TabBtn
        
        -- Halaman Konten
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.CanvasSize = UDim2.new(0, 0, 2, 0)
        Page.ScrollBarThickness = 3
        Page.Visible = false
        Page.Parent = ContentContainer
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = Page
        
        local function selectThisTab()
            for _, p in ipairs(ContentContainer:GetChildren()) do
                p.Visible = false
            end
            for _, b in ipairs(MenuHolder:GetChildren()) do
                if b:IsA("TextButton") then
                    TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 23, 31), TextColor3 = Color3.fromRGB(150, 155, 170)}):Play()
                end
            end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 40, 55), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end
        
        TabBtn.MouseButton1Click:Connect(selectThisTab)
        
        if firstTab then
            firstTab = false
            selectThisTab()
        end
        
        -- Fungsi Tambah Tombol di Tab
        function Tab:AddButton(btnText, callback)
            callback = callback or function() end
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -10, 0, 36)
            Button.BackgroundColor3 = Color3.fromRGB(24, 27, 36)
            Button.Text = "  " .. btnText
            Button.TextColor3 = Color3.fromRGB(230, 235, 245)
            Button.TextSize = 12
            Button.Font = Enum.Font.GothamSemibold
            Button.TextXAlignment = Enum.TextXAlignment.Left
            Button.Parent = Page
            
            local BC = Instance.new("UICorner")
            BC.CornerRadius = UDim.new(0, 6)
            BC.Parent = Button
            
            Button.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
        end
        
        -- Fungsi Tambah Toggle di Tab
        function Tab:AddToggle(toggleText, defaultState, callback)
            local state = defaultState or false
            callback = callback or function() end
            
            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Size = UDim2.new(1, -10, 0, 36)
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 27, 36)
            ToggleBtn.Text = ""
            ToggleBtn.AutoButtonColor = false
            ToggleBtn.Parent = Page
            
            local TC = Instance.new("UICorner")
            TC.CornerRadius = UDim.new(0, 6)
            TC.Parent = ToggleBtn
            
            local Txt = Instance.new("TextLabel")
            Txt.Size = UDim2.new(1, -50, 1, 0)
            Txt.Position = UDim2.new(0, 12, 0, 0)
            Txt.BackgroundTransparency = 1
            Txt.Text = toggleText
            Txt.TextColor3 = Color3.fromRGB(230, 235, 245)
            Txt.TextSize = 12
            Txt.Font = Enum.Font.GothamSemibold
            Txt.TextXAlignment = Enum.TextXAlignment.Left
            Txt.Parent = ToggleBtn
            
            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 20, 0, 20)
            Switch.Position = UDim2.new(1, -28, 0.5, -10)
            Switch.BackgroundColor3 = state and Color3.fromRGB(110, 80, 200) or Color3.fromRGB(45, 50, 65)
            Switch.BorderSizePixel = 0
            Switch.Parent = ToggleBtn
            
            local SC = Instance.new("UICorner")
            SC.CornerRadius = UDim.new(0, 4)
            SC.Parent = Switch
            
            ToggleBtn.MouseButton1Click:Connect(function()
                state = not state
                local targetColor = state and Color3.fromRGB(110, 80, 200) or Color3.fromRGB(45, 50, 65)
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
                pcall(callback, state)
            end)
        end
        
        return Tab
    end
    
    -- Fitur Dragging Mouse / Touch HP (Supaya bisa digeser-geser layarnya)
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return Window
end

-- ==========================================
-- CONTOH CARA MENJALANKANNYA
-- ==========================================
Library.ShowIntro("ARTHEIRS HUB")
task.wait(2.5)

local Window = Library:CreateWindow("Artheirs", "Violence District")

-- Membuat Tab Menu Sesuai Keinginanmu
local TabDashboard = Window:AddTab("Dashboard")
local TabSurvivor = Window:AddTab("Survivor")
local TabCombat = Window:AddTab("Combat")
local TabMisc = Window:AddTab("Misc")

-- Isi Menu di dalam Tab Dashboard
TabDashboard:AddButton("Informasi Player", function()
    print("Tombol Dashboard diklik!")
end)

-- Isi Menu di dalam Tab Combat
TabCombat:AddToggle("Auto Attack", false, function(state)
    print("Auto Attack:", state)
end)
