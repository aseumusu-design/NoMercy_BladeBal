-- ============================================
-- A2 INTRO - WHITE & BLUE TEXT + PURPLE FIRE
-- StarterGui > ScreenGui > LocalScript
-- ============================================

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local SoundService = game:GetService("SoundService")

-- ============================================
-- CONFIG
-- ============================================
local CONFIG = {
	AudioId = "rbxassetid://119705891276529",
	LogoId = "rbxassetid://113381647185328",

	BgColor = Color3.fromRGB(5, 2, 10), -- Background gelap keunguan
	
	-- Warna Teks: Putih dengan gradasi biru menyala
	TextColor = Color3.fromRGB(240, 248, 255),     -- Putih kebiruan (AliceBlue)
	TextGlowColor = Color3.fromRGB(0, 150, 255),  -- Biru terang menyala
	
	FireColor = Color3.fromRGB(150, 0, 255),      -- Warna api ungu
	
	LogoShowDuration = 2.0,
	AutoCloseDelay = 5.0,
}

-- ============================================
-- SCREEN GUI (FULLSCREEN)
-- ============================================
local gui = Instance.new("ScreenGui")
gui.Name = "A2BlueWhiteIntro"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-- ============================================
-- BACKGROUND & PURPLE FIRE EFFECT
-- ============================================
local bg = Instance.new("Frame")
bg.Name = "BG"
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = CONFIG.BgColor
bg.BorderSizePixel = 0
bg.ZIndex = 1
bg.Parent = gui

-- Container Bara Api Ungu di Background
local fireContainer = Instance.new("Frame")
fireContainer.Name = "PurpleFireContainer"
fireContainer.Size = UDim2.new(1, 0, 1, 0)
fireContainer.BackgroundTransparency = 1
fireContainer.ZIndex = 2
fireContainer.Parent = bg

local function spawnFireParticle()
	local size = math.random(15, 35)
	local startX = math.random(0, 100) / 100
	local duration = math.random(15, 25) / 10
	
	local particle = Instance.new("Frame")
	particle.Size = UDim2.new(0, size, 0, size)
	particle.Position = UDim2.new(startX, 0, 1.1, 0)
	particle.BackgroundColor3 = CONFIG.FireColor
	particle.BackgroundTransparency = 0.4
	particle.BorderSizePixel = 0
	particle.ZIndex = 2
	particle.Parent = fireContainer
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = particle
	
	local grad = Instance.new("UIGradient")
	grad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	grad.Rotation = 90
	grad.Parent = particle

	local targetX = startX + (math.random(-20, 20) / 100)
	TweenService:Create(particle, TweenInfo.new(duration, Enum.EasingStyle.Sine), {
		Position = UDim2.new(targetX, 0, -0.2, 0),
		BackgroundTransparency = 1,
		Size = UDim2.new(0, size * 0.5, 0, size * 0.5)
	}):Play()

	game:GetService("Debris"):AddItem(particle, duration)
end

task.spawn(function()
	while bg.Parent do
		spawnFireParticle()
		task.wait(0.15)
	end
end)

-- ============================================
-- AUDIO
-- ============================================
local success, introSound = pcall(function()
	local sound = Instance.new("Sound")
	sound.Name = "A2IntroAudio"
	sound.SoundId = CONFIG.AudioId
	sound.Volume = 5
	sound.Looped = false
	sound.Parent = SoundService
	return sound
end)

-- ============================================
-- LOGO
-- ============================================
local logoContainer = Instance.new("Frame")
logoContainer.Name = "LogoContainer"
logoContainer.Size = UDim2.new(1, 0, 1, 0)
logoContainer.BackgroundTransparency = 1
logoContainer.ZIndex = 10
logoContainer.Parent = bg

local logo = Instance.new("ImageLabel")
logo.Name = "Logo"
logo.Size = UDim2.new(0, 80, 0, 80)
logo.Position = UDim2.new(0.5, 0, 0.4, 0)
logo.AnchorPoint = Vector2.new(0.5, 0.5)
logo.BackgroundTransparency = 1
logo.Image = CONFIG.LogoId
logo.ImageTransparency = 1
logo.Rotation = -30
logo.ZIndex = 10
logo.Parent = logoContainer

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(1, 0)
logoCorner.Parent = logo

local glowRing = Instance.new("Frame")
glowRing.Name = "GlowRing"
glowRing.Size = UDim2.new(0, 100, 0, 100)
glowRing.Position = UDim2.new(0.5, 0, 0.4, 0)
glowRing.AnchorPoint = Vector2.new(0.5, 0.5)
glowRing.BackgroundTransparency = 1
glowRing.BorderSizePixel = 0
glowRing.ZIndex = 9
glowRing.Parent = logoContainer

local ringCorner = Instance.new("UICorner")
ringCorner.CornerRadius = UDim.new(1, 0)
ringCorner.Parent = glowRing

local ringStroke = Instance.new("UIStroke")
ringStroke.Color = CONFIG.TextGlowColor
ringStroke.Thickness = 3
ringStroke.Transparency = 1
ringStroke.Parent = glowRing

-- ============================================
-- TEXT CONTAINER (WELCOME & A2 - PUTIH BIRU)
-- ============================================
local textContainer = Instance.new("Frame")
textContainer.Name = "TextContainer"
textContainer.Size = UDim2.new(1, 0, 0, 180)
textContainer.Position = UDim2.new(0.5, 0, 0.65, 0)
textContainer.AnchorPoint = Vector2.new(0.5, 0.5)
textContainer.BackgroundTransparency = 1
textContainer.ZIndex = 10
textContainer.Visible = false
textContainer.Parent = bg

-- Baris Atas: WELCOME (Putih dengan outline/stroke Biru)
local welcomeText = Instance.new("TextLabel")
welcomeText.Name = "WelcomeText"
welcomeText.Size = UDim2.new(1, 0, 0, 60)
welcomeText.Position = UDim2.new(0, 0, 0, 0)
welcomeText.BackgroundTransparency = 1
welcomeText.Text = ""
welcomeText.Font = Enum.Font.Arcade
welcomeText.TextSize = 56
welcomeText.TextColor3 = CONFIG.TextColor
welcomeText.TextTransparency = 1
welcomeText.ZIndex = 10
welcomeText.Parent = textContainer

local welcomeStroke = Instance.new("UIStroke")
welcomeStroke.Color = CONFIG.TextGlowColor
welcomeStroke.Thickness = 2
welcomeStroke.Transparency = 1
welcomeStroke.Parent = welcomeText

-- Baris Bawah: A2 (Warna Biru Menyala dengan outline Putih)
local a2Text = Instance.new("TextLabel")
a2Text.Name = "A2Text"
a2Text.Size = UDim2.new(1, 0, 0, 70)
a2Text.Position = UDim2.new(0, 0, 0, 65)
a2Text.BackgroundTransparency = 1
a2Text.Text = "A2"
a2Text.Font = Enum.Font.Arcade
a2Text.TextSize = 72
a2Text.TextColor3 = CONFIG.TextGlowColor
a2Text.TextTransparency = 1
a2Text.ZIndex = 10
a2Text.Parent = textContainer

local a2Stroke = Instance.new("UIStroke")
a2Stroke.Color = CONFIG.TextColor
a2Stroke.Thickness = 3
a2Stroke.Transparency = 1
a2Stroke.Parent = a2Text

-- ============================================
-- ANIMATION RUNNER
-- ============================================
task.spawn(function()
	-- 1. Animasi Logo Masuk
	TweenService:Create(logo, TweenInfo.new(1.0, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		ImageTransparency = 0,
		Size = UDim2.new(0, 180, 0, 180),
		Rotation = 0
	}):Play()

	TweenService:Create(glowRing, TweenInfo.new(1.0, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 220, 0, 220)
	}):Play()

	TweenService:Create(ringStroke, TweenInfo.new(0.8), {Transparency = 0.5}):Play()

	task.wait(CONFIG.LogoShowDuration)

	-- 2. Hilangkan Logo
	TweenService:Create(logo, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {ImageTransparency = 1, Size = UDim2.new(0, 140, 0, 140)}):Play()
	TweenService:Create(glowRing, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 140, 0, 140)}):Play()
	TweenService:Create(ringStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()

	-- 3. Putar Audio & Tampilkan Teks Bersamaan
	if success and introSound then
		pcall(function() introSound:Play() end)
	end
	
	textContainer.Visible = true
	welcomeText.TextTransparency = 0
	welcomeStroke.Transparency = 0.2

	-- Efek Ketik "WELCOME ┃" (Selow satu-satu: 0.18 detik per huruf)
	local targetMsg = "WELCOME"
	for i = 1, #targetMsg do
		welcomeText.Text = string.sub(targetMsg, 1, i) .. " ┃"
		task.wait(0.18)
	end
	welcomeText.Text = targetMsg

	-- Munculkan Teks "A2" di Bawahnya (Warna Biru)
	TweenService:Create(a2Text, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
	TweenService:Create(a2Stroke, TweenInfo.new(0.5), {Transparency = 0.1}):Play()

	-- 4. Auto Close Cepat di Akhir
	task.delay(CONFIG.AutoCloseDelay, function()
		TweenService:Create(bg, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()
		for _, v in ipairs(bg:GetDescendants()) do
			if v:IsA("TextLabel") then
				TweenService:Create(v, TweenInfo.new(0.6), {TextTransparency = 1}):Play()
			elseif v:IsA("ImageLabel") then
				TweenService:Create(v, TweenInfo.new(0.6), {ImageTransparency = 1}):Play()
			elseif v:IsA("UIStroke") then
				TweenService:Create(v, TweenInfo.new(0.6), {Transparency = 1}):Play()
			end
		end
		task.wait(0.7)
		gui:Destroy()
	end)
end)

print("[A2 Intro] White-Blue Text & Purple Fire Loaded!")
