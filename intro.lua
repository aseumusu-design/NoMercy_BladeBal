-- ============================================
-- A2 ROBLOX INTRO UI - FULLSCREEN HP 100%
-- by Kimi Chat | StarterGui > ScreenGui > LocalScript
-- BENER-BENER FULLSCREEN. Nggak ada frame. Nggak ada border.
-- ============================================

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- CONFIG
-- ============================================
local CONFIG = {
	BackgroundColor = Color3.fromRGB(5, 5, 15),
	Text = "A2",
	Subtitle = "Loading Experience...",

	RobloxLogoId = "rbxassetid://113381647185328",
	LogoDuration = 2.2,
	LogoFadeOut = 0.8,

	A2Color = Color3.fromRGB(255, 255, 255),
	A2GlowColor = Color3.fromRGB(200, 220, 255),
	A2ShadowColor = Color3.fromRGB(100, 150, 255),

	AutoCloseDelay = 5.5,
	CloseFadeDuration = 1.0,

	NeonCyan = Color3.fromRGB(0, 255, 255),
	NeonMagenta = Color3.fromRGB(255, 0, 255),
	NeonPurple = Color3.fromRGB(150, 0, 255),
	TealColor = Color3.fromRGB(0, 212, 170),
	OrangeColor = Color3.fromRGB(255, 107, 0),
	RedColor = Color3.fromRGB(230, 57, 70),
	BlueColor = Color3.fromRGB(69, 123, 157),
}

-- ============================================
-- UTILITY
-- ============================================
local function create(className, props)
	local instance = Instance.new(className)
	for key, value in pairs(props) do
		instance[key] = value
	end
	return instance
end

local function tween(instance, properties, duration, easingStyle, easingDirection, delay)
	easingStyle = easingStyle or Enum.EasingStyle.Quad
	easingDirection = easingDirection or Enum.EasingDirection.Out
	delay = delay or 0
	local info = TweenInfo.new(duration, easingStyle, easingDirection, 0, false, delay)
	local tw = TweenService:Create(instance, info, properties)
	tw:Play()
	return tw
end

local function randomRange(min, max)
	return math.random() * (max - min) + min
end

-- ============================================
-- SCREEN GUI
-- ============================================
local screenGui = create("ScreenGui", {
	Name = "A2IntroUI",
	Parent = playerGui,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 999,
})

-- ============================================
-- BACKGROUND - FULLSCREEN 1,0,1,0
-- ============================================
local background = create("Frame", {
	Name = "Background",
	Parent = screenGui,
	Size = UDim2.new(1, 0, 1, 0),
	Position = UDim2.new(0, 0, 0, 0),
	AnchorPoint = Vector2.new(0, 0),
	BackgroundColor3 = CONFIG.BackgroundColor,
	BorderSizePixel = 0,
	ZIndex = 1,
})

-- ============================================
-- CYBERPUNK EFFECTS
-- ============================================

-- Diagonal lines
local diagLines = create("Frame", {
	Name = "DiagLines",
	Parent = background,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	ZIndex = 2,
})

for i = 1, 15 do
	local line = create("Frame", {
		Parent = diagLines,
		Name = "Diag" .. i,
		Size = UDim2.new(0, 2, 1.5, 0),
		Position = UDim2.new(randomRange(-0.2, 1.2), 0, -0.25, 0),
		BackgroundColor3 = i % 2 == 0 and CONFIG.NeonCyan or CONFIG.NeonMagenta,
		BackgroundTransparency = 0.92,
		BorderSizePixel = 0,
		Rotation = 35,
		ZIndex = 2,
	})

	task.spawn(function()
		while line.Parent do
			local targetX = randomRange(-0.3, 1.3)
			tween(line, {Position = UDim2.new(targetX, 0, -0.25, 0)}, randomRange(6, 12), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
			task.wait(randomRange(6, 12))
		end
	end)
end

-- Scan bars
local scanBars = create("Frame", {
	Name = "ScanBars",
	Parent = background,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	ZIndex = 2,
})

for i = 1, 10 do
	local bar = create("Frame", {
		Parent = scanBars,
		Name = "Bar" .. i,
		Size = UDim2.new(1, 0, 0, randomRange(1, 3)),
		Position = UDim2.new(0, 0, randomRange(0, 1), 0),
		BackgroundColor3 = i % 3 == 0 and CONFIG.NeonPurple or (i % 2 == 0 and CONFIG.NeonCyan or CONFIG.NeonMagenta),
		BackgroundTransparency = 0.95,
		BorderSizePixel = 0,
		ZIndex = 2,
	})

	task.spawn(function()
		while bar.Parent do
			tween(bar, {BackgroundTransparency = 0.85}, randomRange(1, 2), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(randomRange(1, 2))
			if not bar.Parent then break end
			tween(bar, {BackgroundTransparency = 0.96}, randomRange(1, 2), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(randomRange(1, 2))
		end
	end)
end

-- Pillars
local pillars = create("Frame", {
	Name = "Pillars",
	Parent = background,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	ZIndex = 2,
})

for i = 1, 8 do
	local pillar = create("Frame", {
		Parent = pillars,
		Name = "Pillar" .. i,
		Size = UDim2.new(0, randomRange(2, 4), randomRange(0.3, 0.7), 0),
		Position = UDim2.new(randomRange(0.1, 0.9), 0, randomRange(0, 0.5), 0),
		BackgroundColor3 = i % 2 == 0 and CONFIG.NeonCyan or CONFIG.NeonMagenta,
		BackgroundTransparency = 0.94,
		BorderSizePixel = 0,
		ZIndex = 2,
	})

	task.spawn(function()
		while pillar.Parent do
			tween(pillar, {BackgroundTransparency = 0.82, Size = UDim2.new(pillar.Size.X.Scale, pillar.Size.X.Offset, pillar.Size.Y.Scale + 0.1, 0)}, randomRange(2, 4), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(randomRange(2, 4))
			if not pillar.Parent then break end
			tween(pillar, {BackgroundTransparency = 0.95, Size = UDim2.new(pillar.Size.X.Scale, pillar.Size.X.Offset, pillar.Size.Y.Scale - 0.1, 0)}, randomRange(2, 4), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(randomRange(2, 4))
		end
	end)
end

-- Digital rain
local digitalRain = create("Frame", {
	Name = "DigitalRain",
	Parent = background,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	ZIndex = 3,
})

local function spawnRainDrop()
	local drop = create("Frame", {
		Parent = digitalRain,
		Name = "RainDrop",
		Size = UDim2.new(0, 1, 0, randomRange(20, 80)),
		Position = UDim2.new(randomRange(0, 1), 0, -0.1, 0),
		BackgroundColor3 = math.random() > 0.5 and CONFIG.NeonCyan or CONFIG.NeonMagenta,
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		ZIndex = 3,
	})

	local duration = randomRange(1.5, 3.5)
	tween(drop, {
		Position = UDim2.new(drop.Position.X.Scale, 0, 1.1, 0),
		BackgroundTransparency = 1,
	}, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In)

	game:GetService("Debris"):AddItem(drop, duration)
end

task.spawn(function()
	while background.Parent do
		spawnRainDrop()
		task.wait(randomRange(0.05, 0.2))
	end
end)

-- Corner glows
local cornerGlows = {}
local cornerPositions = {
	{UDim2.new(0, 0, 0, 0), UDim2.new(0, 150, 0, 2)},
	{UDim2.new(1, -150, 0, 0), UDim2.new(0, 150, 0, 2)},
	{UDim2.new(0, 0, 1, -2), UDim2.new(0, 150, 0, 2)},
	{UDim2.new(1, -150, 1, -2), UDim2.new(0, 150, 0, 2)},
	{UDim2.new(0, 0, 0, 0), UDim2.new(0, 2, 0, 100)},
	{UDim2.new(1, -2, 0, 0), UDim2.new(0, 2, 0, 100)},
	{UDim2.new(0, 0, 1, -100), UDim2.new(0, 2, 0, 100)},
	{UDim2.new(1, -2, 1, -100), UDim2.new(0, 2, 0, 100)},
}

for i, pos in ipairs(cornerPositions) do
	local glow = create("Frame", {
		Parent = background,
		Name = "CornerGlow" .. i,
		Position = pos[1],
		Size = pos[2],
		BackgroundColor3 = i % 2 == 0 and CONFIG.NeonCyan or CONFIG.NeonMagenta,
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
		ZIndex = 4,
	})
	table.insert(cornerGlows, glow)
end

task.spawn(function()
	while background.Parent do
		for _, glow in ipairs(cornerGlows) do
			tween(glow, {BackgroundTransparency = 0.7}, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		end
		task.wait(1.5)
		for _, glow in ipairs(cornerGlows) do
			tween(glow, {BackgroundTransparency = 0.9}, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		end
		task.wait(1.5)
	end
end)

-- Scanlines
local scanlines = create("Frame", {
	Name = "Scanlines",
	Parent = background,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	ZIndex = 50,
})
for i = 0, 100 do
	create("Frame", {
		Parent = scanlines,
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 0, i * 4),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
	})
end

-- ============================================
-- ROBLOX LOGO (BULET)
-- ============================================
local logoPhase = create("Frame", {
	Name = "LogoPhase",
	Parent = background,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	ZIndex = 100,
})

local robloxLogo = create("ImageLabel", {
	Name = "RobloxLogo",
	Parent = logoPhase,
	Size = UDim2.new(0, 200, 0, 200),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Image = CONFIG.RobloxLogoId,
	ImageTransparency = 1,
	ZIndex = 100,
})

create("UICorner", {Parent = robloxLogo, CornerRadius = UDim.new(1, 0)})

local logoRing = create("Frame", {
	Name = "LogoRing",
	Parent = logoPhase,
	Size = UDim2.new(0, 240, 0, 240),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 99,
})
create("UICorner", {Parent = logoRing, CornerRadius = UDim.new(1, 0)})
local ringStroke = create("UIStroke", {
	Parent = logoRing,
	Color = Color3.fromRGB(255, 255, 255),
	Thickness = 3,
	Transparency = 1,
})

local innerRing = create("Frame", {
	Name = "InnerRing",
	Parent = logoPhase,
	Size = UDim2.new(0, 220, 0, 220),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 98,
})
create("UICorner", {Parent = innerRing, CornerRadius = UDim.new(1, 0)})
local innerStroke = create("UIStroke", {
	Parent = innerRing,
	Color = CONFIG.NeonCyan,
	Thickness = 2,
	Transparency = 1,
})

-- ============================================
-- A2 TEXT - LEBAR
-- ============================================
local a2Container = create("Frame", {
	Name = "A2Container",
	Parent = background,
	Size = UDim2.new(0, 700, 0, 250),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	ZIndex = 10,
	Visible = false,
})

local glowLayers = {
	{ color = CONFIG.A2ShadowColor, offset = 14, transparency = 0.7, size = 145 },
	{ color = CONFIG.A2GlowColor,   offset = 10, transparency = 0.5, size = 135 },
	{ color = Color3.fromRGB(255, 255, 255), offset = 5, transparency = 0.3, size = 128 },
}
for i, layer in ipairs(glowLayers) do
	local glow = create("TextLabel", {
		Parent = a2Container,
		Name = "Glow" .. i,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, layer.offset, 0, layer.offset),
		BackgroundTransparency = 1,
		Text = CONFIG.Text,
		Font = Enum.Font.Arcade,
		TextSize = layer.size,
		TextColor3 = layer.color,
		TextTransparency = 1,
		ZIndex = 10 - i,
	})
end

local a2Text = create("TextLabel", {
	Parent = a2Container,
	Name = "A2Text",
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Text = CONFIG.Text,
	Font = Enum.Font.Arcade,
	TextSize = 120,
	TextColor3 = CONFIG.A2Color,
	TextTransparency = 1,
	ZIndex = 10,
})

local a2Stroke = create("UIStroke", {
	Parent = a2Text,
	Color = Color3.fromRGB(255, 255, 255),
	Thickness = 5,
	Transparency = 1,
})

local a2GlowFrame = create("Frame", {
	Parent = a2Container,
	Name = "A2GlowFrame",
	Size = UDim2.new(1, 120, 1, 80),
	Position = UDim2.new(0, -60, 0, -40),
	BackgroundTransparency = 1,
	ZIndex = 9,
})
local a2GlowStroke = create("UIStroke", {
	Parent = a2GlowFrame,
	Color = Color3.fromRGB(255, 255, 255),
	Thickness = 25,
	Transparency = 1,
})

local subtitle = create("TextLabel", {
	Parent = a2Container,
	Name = "Subtitle",
	Size = UDim2.new(1, 0, 0, 30),
	Position = UDim2.new(0, 0, 1, 15),
	BackgroundTransparency = 1,
	Text = "",
	Font = Enum.Font.Code,
	TextSize = 14,
	TextColor3 = CONFIG.TealColor,
	TextTransparency = 0,
	ZIndex = 10,
})

-- ============================================
-- CORNER BRACKETS
-- ============================================
local function createBracket(position, anchor)
	local bracket = create("Frame", {
		Parent = background,
		Size = UDim2.new(0, 30, 0, 30),
		Position = position,
		AnchorPoint = anchor,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 12,
	})
	local h = create("Frame", {
		Parent = bracket,
		Size = UDim2.new(1, 0, 0, 3),
		BackgroundColor3 = CONFIG.NeonCyan,
		BorderSizePixel = 0,
	})
	local v = create("Frame", {
		Parent = bracket,
		Size = UDim2.new(0, 3, 1, 0),
		BackgroundColor3 = CONFIG.NeonCyan,
		BorderSizePixel = 0,
	})
	if position.X.Scale > 0.5 then
		h.Position = UDim2.new(0, 0, 0, 0); h.AnchorPoint = Vector2.new(1, 0)
		v.Position = UDim2.new(1, 0, 0, 0); v.AnchorPoint = Vector2.new(1, 0)
	end
	if position.Y.Scale > 0.5 then
		h.Position = UDim2.new(0, 0, 1, 0); h.AnchorPoint = Vector2.new(0, 1)
		v.Position = UDim2.new(0, 0, 1, 0); v.AnchorPoint = Vector2.new(0, 1)
		if position.X.Scale > 0.5 then
			h.AnchorPoint = Vector2.new(1, 1)
			v.AnchorPoint = Vector2.new(1, 1)
		end
	end
	return bracket
end

createBracket(UDim2.new(0, 20, 0, 20), Vector2.new(0, 0))
createBracket(UDim2.new(1, -20, 0, 20), Vector2.new(1, 0))
createBracket(UDim2.new(0, 20, 1, -20), Vector2.new(0, 1))
createBracket(UDim2.new(1, -20, 1, -20), Vector2.new(1, 1))

-- ============================================
-- FLOATING BLOCKS
-- ============================================
local blockColors = {CONFIG.RedColor, CONFIG.TealColor, CONFIG.BlueColor, CONFIG.OrangeColor}
local blockPositions = {
	UDim2.new(0.1, 0, 0.15, 0),
	UDim2.new(0.88, 0, 0.7, 0),
	UDim2.new(0.15, 0, 0.8, 0),
	UDim2.new(0.82, 0, 0.25, 0),
}
for i = 1, 4 do
	local block = create("Frame", {
		Parent = background,
		Name = "Block" .. i,
		Size = UDim2.new(0, 20, 0, 20),
		Position = blockPositions[i],
		BackgroundColor3 = blockColors[i],
		BorderSizePixel = 0,
		ZIndex = 5,
	})
	create("UICorner", {Parent = block, CornerRadius = UDim.new(0, 3)})
	task.spawn(function()
		while block.Parent do
			tween(block, {Position = UDim2.new(blockPositions[i].X.Scale, blockPositions[i].X.Offset, blockPositions[i].Y.Scale, blockPositions[i].Y.Offset - 15)}, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(1.5)
			if not block.Parent then break end
			tween(block, {Position = blockPositions[i]}, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(1.5)
		end
	end)
end

-- ============================================
-- PARTICLES
-- ============================================
local particleColors = {Color3.fromRGB(255,255,255), CONFIG.A2GlowColor, CONFIG.TealColor, CONFIG.OrangeColor, CONFIG.BlueColor}
local function spawnParticle()
	local color = particleColors[math.random(1, #particleColors)]
	local size = randomRange(4, 10)
	local startX = randomRange(0, 1)
	local duration = randomRange(3, 8)
	local particle = create("Frame", {
		Parent = background,
		Name = "Particle",
		Size = UDim2.new(0, size, 0, size),
		Position = UDim2.new(startX, 0, 1, 0),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		BackgroundTransparency = 0,
		ZIndex = 3,
	})
	create("UICorner", {Parent = particle, CornerRadius = UDim.new(0, math.random() > 0.5 and size/2 or 2)})
	tween(particle, {
		Position = UDim2.new(startX + randomRange(-0.1, 0.1), 0, -0.1, 0),
		BackgroundTransparency = 1,
		Rotation = randomRange(0, 360),
	}, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	game:GetService("Debris"):AddItem(particle, duration)
end

task.spawn(function()
	while background.Parent do
		spawnParticle()
		task.wait(randomRange(0.1, 0.4))
	end
end)

-- ============================================
-- GLITCH
-- ============================================
local glitchFrame = create("Frame", {
	Name = "GlitchOverlay",
	Parent = background,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	ZIndex = 20,
})

task.spawn(function()
	while glitchFrame.Parent do
		task.wait(randomRange(2, 5))
		if not glitchFrame.Parent then break end
		glitchFrame.BackgroundColor3 = CONFIG.OrangeColor
		glitchFrame.BackgroundTransparency = 0.9
		task.wait(0.05)
		glitchFrame.BackgroundTransparency = 1
		task.wait(0.05)
		glitchFrame.BackgroundColor3 = CONFIG.TealColor
		glitchFrame.BackgroundTransparency = 0.85
		task.wait(0.05)
		glitchFrame.BackgroundTransparency = 1
		task.wait(0.05)
		glitchFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		glitchFrame.BackgroundTransparency = 0.9
		task.wait(0.05)
		glitchFrame.BackgroundTransparency = 1
	end
end)

-- ============================================
-- REPLAY BUTTON
-- ============================================
local replayBtn = create("TextButton", {
	Parent = background,
	Name = "ReplayButton",
	Size = UDim2.new(0, 120, 0, 36),
	Position = UDim2.new(0.5, 0, 1, -50),
	AnchorPoint = Vector2.new(0.5, 1),
	BackgroundColor3 = CONFIG.BackgroundColor,
	BackgroundTransparency = 0,
	Text = "▶ REPLAY",
	Font = Enum.Font.Code,
	TextSize = 12,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	ZIndex = 30,
	Visible = false,
	AutoButtonColor = true,
})
create("UIStroke", {Parent = replayBtn, Color = CONFIG.NeonCyan, Thickness = 2})
create("UICorner", {Parent = replayBtn, CornerRadius = UDim.new(0, 8)})

replayBtn.MouseEnter:Connect(function()
	tween(replayBtn, {BackgroundColor3 = CONFIG.NeonCyan}, 0.3)
	tween(replayBtn, {TextColor3 = CONFIG.BackgroundColor}, 0.3)
end)
replayBtn.MouseLeave:Connect(function()
	tween(replayBtn, {BackgroundColor3 = CONFIG.BackgroundColor}, 0.3)
	tween(replayBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.3)
end)

-- ============================================
-- AUTO CLOSE
-- ============================================
local function closeIntro()
	tween(background, {BackgroundTransparency = 1}, CONFIG.CloseFadeDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	for _, child in ipairs(background:GetDescendants()) do
		if child:IsA("Frame") and child ~= background then
			tween(child, {BackgroundTransparency = 1}, CONFIG.CloseFadeDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		elseif child:IsA("TextLabel") or child:IsA("TextButton") then
			tween(child, {TextTransparency = 1}, CONFIG.CloseFadeDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		elseif child:IsA("ImageLabel") then
			tween(child, {ImageTransparency = 1}, CONFIG.CloseFadeDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		elseif child:IsA("UIStroke") then
			tween(child, {Transparency = 1}, CONFIG.CloseFadeDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		end
	end

	task.delay(CONFIG.CloseFadeDuration + 0.2, function()
		if screenGui.Parent then
			screenGui:Destroy()
			print("[A2 Intro] Intro selesai & dihapus!")
		end
	end)
end

-- ============================================
-- ANIMATION
-- ============================================
local function playIntro()
	robloxLogo.ImageTransparency = 1
	robloxLogo.Size = UDim2.new(0, 150, 0, 150)
	robloxLogo.Rotation = 0

	logoRing.Size = UDim2.new(0, 190, 0, 190)
	ringStroke.Transparency = 1

	innerRing.Size = UDim2.new(0, 170, 0, 170)
	innerStroke.Transparency = 1

	logoPhase.Visible = true
	a2Container.Visible = false
	a2Text.TextTransparency = 1
	a2Stroke.Transparency = 1
	a2GlowStroke.Transparency = 1

	for _, child in ipairs(a2Container:GetChildren()) do
		if child:IsA("TextLabel") and child.Name:find("Glow") then
			child.TextTransparency = 1
		end
	end
	subtitle.Text = ""
	replayBtn.Visible = false

	-- PHASE 1: LOGO
	tween(robloxLogo, {ImageTransparency = 0}, 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	tween(logoRing, {Size = UDim2.new(0, 280, 0, 280)}, 1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.2)
	tween(ringStroke, {Transparency = 0.6}, 1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.3)

	tween(innerRing, {Size = UDim2.new(0, 240, 0, 240)}, 1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.3)
	tween(innerStroke, {Transparency = 0.5}, 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.4)

	tween(robloxLogo, {Size = UDim2.new(0, 210, 0, 210)}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0.5)
	task.wait(1.2)
	if not robloxLogo.Parent then return end
	tween(robloxLogo, {Size = UDim2.new(0, 190, 0, 190)}, 1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	task.wait(CONFIG.LogoDuration - 1.2)
	if not robloxLogo.Parent then return end

	tween(robloxLogo, {ImageTransparency = 1, Size = UDim2.new(0, 320, 0, 320), Rotation = 20}, CONFIG.LogoFadeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(logoRing, {Size = UDim2.new(0, 450, 0, 450)}, CONFIG.LogoFadeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(ringStroke, {Transparency = 1}, CONFIG.LogoFadeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(innerRing, {Size = UDim2.new(0, 380, 0, 380)}, CONFIG.LogoFadeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(innerStroke, {Transparency = 1}, CONFIG.LogoFadeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	task.wait(CONFIG.LogoFadeOut + 0.2)
	logoPhase.Visible = false

	-- PHASE 2: A2
	a2Container.Visible = true
	a2Container.Size = UDim2.new(0, 420, 0, 150)
	a2Container.Position = UDim2.new(0.5, 0, 0.5, 40)

	tween(a2Container, {
		Size = UDim2.new(0, 740, 0, 260),
		Position = UDim2.new(0.5, 0, 0.5, -10)
	}, 0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	for i, child in ipairs(a2Container:GetChildren()) do
		if child:IsA("TextLabel") and child.Name:find("Glow") then
			tween(child, {TextTransparency = 0.35}, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.2 + (i * 0.08))
		end
	end

	tween(a2Text, {TextTransparency = 0}, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.3)

	tween(a2Stroke, {Transparency = 0.05}, 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.4)
	tween(a2GlowStroke, {Transparency = 0.55}, 1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.5)

	tween(a2Container, {
		Size = UDim2.new(0, 700, 0, 250),
		Position = UDim2.new(0.5, 0, 0.5, 0)
	}, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.7)

	task.delay(1.5, function()
		local text = CONFIG.Subtitle
		for i = 1, #text do
			if not subtitle.Parent then break end
			subtitle.Text = string.sub(text, 1, i)
			task.wait(0.08)
		end
	end)

	task.delay(2, function()
		while a2Text.Parent and a2Text.TextTransparency < 0.5 do
			tween(a2GlowStroke, {Transparency = 0.25}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			tween(a2Stroke, {Transparency = 0}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(1.2)
			if not a2Text.Parent then break end
			tween(a2GlowStroke, {Transparency = 0.65}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			tween(a2Stroke, {Transparency = 0.15}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(1.2)
		end
	end)

	task.delay(3.5, function()
		if replayBtn.Parent then
			replayBtn.Visible = true
			tween(replayBtn, {TextTransparency = 0}, 0.5)
		end
	end)

	-- AUTO CLOSE
	task.delay(CONFIG.AutoCloseDelay, function()
		if screenGui.Parent then
			closeIntro()
		end
	end)
end

-- ============================================
-- START
-- ============================================
playIntro()

replayBtn.MouseButton1Click:Connect(function()
	replayBtn.Visible = false
	playIntro()
end)

print("[A2 Intro] FULLSCREEN 100% HP Loaded! Nggak ada frame. Nggak ada border. PENUH!")
