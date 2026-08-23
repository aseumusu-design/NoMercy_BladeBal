-- [[ PEPSI UI LIBRARY STYLE TEMPLATE ]] --
-- Terinspirasi dari struktur x2Swiftz/UI-Library di GitHub

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = {}

function Library:CreateWindow(config)
    local Window = {}
    config = config or {}
    local windowName = config.Name or "Pepsi's World"
    
    -- Membuat ScreenGui Utama
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PepsiLibrary"
    ScreenGui.Parent = CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 480, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame
    
    -- Topbar (Judul & Dragging)
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 8)
    TopCorner.Parent = TopBar
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = windowName
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar
    
    -- Container Tab
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, -20, 1, -50)
    TabContainer.Position = UDim2.new(0, 10, 0, 42)
    TabContainer.BackgroundTransparency = 1
    TabContainer.CanvasSize = UDim2.new(0, 0, 2, 0)
    TabContainer.ScrollBarThickness = 3
    TabContainer.Parent = MainFrame
    
    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 8)
    TabList.Parent = TabContainer
    
    -- Fungsi Membuat Tab ala Pepsi Library
    function Window:CreateTab(tabConfig)
        local Tab = {}
        local tabName = tabConfig.Name or "Tab"
        
        local SectionHeader = Instance.new("TextLabel")
        SectionHeader.Size = UDim2.new(1, 0, 0, 25)
        SectionHeader.BackgroundTransparency = 1
        SectionHeader.Text = "-- " .. tabName .. " --"
        SectionHeader.TextColor3 = Color3.fromRGB(150, 150, 160)
        SectionHeader.TextSize = 13
        SectionHeader.Font = Enum.Font.GothamBold
        SectionHeader.Parent = TabContainer
        
        function Tab:CreateSection(secConfig)
            local Section = {}
            
            -- Fungsi Toggle di dalam Section
            function Section:AddToggle(toggleConfig)
                local toggleName = toggleConfig.Name or "Toggle"
                local callback = toggleConfig.Callback or function() end
                local state = false
                
                local ToggleBtn = Instance.new("TextButton")
                ToggleBtn.Size = UDim2.new(1, 0, 0, 34)
                ToggleBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
                ToggleBtn.AutoButtonColor = false
                ToggleBtn.Text = ""
                ToggleBtn.Parent = TabContainer
                
                local TglCorner = Instance.new("UICorner")
                TglCorner.CornerRadius = UDim.new(0, 6)
                TglCorner.Parent = ToggleBtn
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -50, 1, 0)
                Label.Position = UDim2.new(0, 12, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = toggleName
                Label.TextColor3 = Color3.fromRGB(230, 230, 240)
                Label.TextSize = 12
                Label.Font = Enum.Font.GothamSemibold
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = ToggleBtn
                
                local Indicator = Instance.new("Frame")
                Indicator.Size = UDim2.new(0, 18, 0, 18)
                Indicator.Position = UDim2.new(1, -26, 0.5, -9)
                Indicator.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                Indicator.BorderSizePixel = 0
                Indicator.Parent = ToggleBtn
                
                local IndCorner = Instance.new("UICorner")
                IndCorner.CornerRadius = UDim.new(0, 4)
                IndCorner.Parent = Indicator
                
                ToggleBtn.MouseButton1Click:Connect(function()
                    state = not state
                    Indicator.BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 60)
                    pcall(callback, state)
                end)
            end
            
            return Section
        end
        
        return Tab
    end
    
    -- Fitur Dragging Window
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
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
-- CONTOH CARA PENGGUNAAN (PEPSI STYLE)
-- ==========================================
local PepsisWorld = Library:CreateWindow({ 
    Name = "Pepsi's World"
}) 

local GeneralTab = PepsisWorld:CreateTab({ 
    Name = "General"
}) 

local FarmingSection = GeneralTab:CreateSection({ 
    Name = "Farming"
}) 

FarmingSection:AddToggle({ 
    Name = "EXP Grinder", 
    Callback = function(state)
        print("EXP Grinder status:", state)
    end
})
