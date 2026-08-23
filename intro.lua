-- ============================================
-- A2 ROBLOX INTRO UI LIBRARY v9 - 550x350 FRAME
-- by Kimi Chat | StarterGui > ScreenGui > LocalScript
-- Frame: 550px x 350px | Rounded | Gray Border
-- ============================================

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- CONFIGURATION
-- ============================================
local CONFIG = {
	BackgroundColor = Color3.fromRGB(5, 5, 15),
	Text = "A2",
	Subtitle = "Loading Experience...",

	-- Frame Size
	FrameWidth = 550,
	FrameHeight = 350,

	-- Roblox Logo
	RobloxLogoId = "rbxassetid://113381647185328",
	LogoDuration = 2.2,
	LogoFadeOut = 0.8,

	-- A2 Text (Putih + Glow)
	A2Color = Color3.fromRGB(255, 255, 255),
	A2GlowColor = Color3.fromRGB(200, 220, 255),
	A2ShadowColor = Color3.fromRGB(100, 150, 255),

	-- Auto close
	AutoCloseDelay = 5.5,
	CloseFadeDuration = 1.0,

	-- Cyberpunk Colors
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
-- BUILD UI
-- ============================================
local screenGui = create("ScreenGui", {
	Name = "A2IntroUI",
	Parent = playerGui,
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 999,
})

-- Dark overlay (game still visible behind)
local darkOverlay = create("Frame", {
	Name = "DarkOverlay",
	Parent = screenGui,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.4,
	BorderSizePixel = 0,
	ZIndex = 1,
})

-- MAIN INTRO FRAME: 550 x 350
local introFrame = create("Frame", {
	Name = "IntroFrame",
	Parent = screenGui,
	Size = UDim2.new(0, CONFIG.FrameWidth, 0, CONFIG.FrameHeight),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = CONFIG.BackgroundColor,
	BorderSizePixel = 0,
	ZIndex = 2,
})

-- Rounded corners
create("UICorner", {
	Parent = introFrame,
	CornerRadius = UDim.new(0, 16),
})

-- Gray border (like image 2)
local frameBorder = create("UIStroke", {
	Parent = introFrame,
	Color = Color3.fromRGB(80, 80, 80),
	Thickness = 4,
})

-- Inner neon glow stroke
local innerGlowStroke = create("UIStroke", {
	Parent = introFrame,
	Color = CONFIG.NeonCyan,
	Thickness = 1,
	Transparency = 0.7,
})

-- ============================================
-- CYBERPUNK BACKGROUND (INSIDE FRAME)
-- ============================================

-- Diagonal neon lines
local diagLines = create("Frame", {
	Name = "DiagLines",
	Parent = introFrame,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	ZIndex = 2,
})

for i = 1, 10 do
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

-- Horizontal scan bars
local scanBars = create("Frame", {
	Name = "ScanBars",
	Parent = introFrame,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	ZIndex = 2,
})

for i = 1, 6 do
	local bar = create("Frame", {
		Parent = scanBars,
		Name = "Bar" .. i,
		Size = UDim2.new(1, 0, 0, randomRange(1, 2)),
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

-- Vertical neon pillars
local pillars = create("Frame", {
	Name = "Pillars",
	Parent = introFrame,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	ZIndex = 2,
})

for i = 1, 5 do
	local pillar = create("Frame", {
		Parent = pillars,
		Name = "Pillar" .. i,
		Size = UDim2.new(0, randomRange(2, 3), randomRange(0.3, 0.6), 0),
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
	Parent = introFrame,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	ZIndex = 3,
})

local function spawnRainDrop()
	local drop = create("Frame", {
		Parent = digitalRain,
		Name = "RainDrop",
		Size = UDim2.new(0, 1, 0, randomRange(15, 50)),
		Position = UDim2.new(randomRange(0, 1), 0, -0.1, 0),
		BackgroundColor3 = math.random() > 0.5 and CONFIG.NeonCyan or CONFIG.NeonMagenta,
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		ZIndex = 3,
	})

	local duration = randomRange(1.5, 3)
	tween(drop, {
		Position = UDim2.new(drop.Position.X.Scale, 0, 1.1, 0),
		BackgroundTransparency = 1,
	}, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In)

	game:GetService("Debris"):AddItem(drop, duration)
end

task.spawn(function()
	while introFrame.Parent do
		spawnRainDrop()
		task.wait(randomRange(0.05, 0.2))
	end
end)

-- Corner neon glows (inside frame)
local cornerGlows = {}
local cornerPositions = {
	{UDim2.new(0, 0, 0, 0), UDim2.new(0, 80, 0, 2)},
	{UDim2.new(1, -80, 0, 0), UDim2.new(0, 80, 0, 2)},
	{UDim2.new(0, 0, 1, -2), UDim2.new(0, 80, 0, 2)},
	{UDim2.new(1, -80, 1, -2), UDim2.new(0, 80, 0, 2)},
	{UDim2.new(0, 0, 0, 0), UDim2.new(0, 2, 0, 60)},
	{UDim2.new(1, -2, 0, 0), UDim2.new(0, 2, 0, 60)},
	{UDim2.new(0, 0, 1, -60), UDim2.new(0, 2, 0, 60)},
	{UDim2.new(1, -2, 1, -60), UDim2.new(0, 2, 0, 60)},
}

for i, pos in ipairs(cornerPositions) do
	local glow = create("Frame", {
		Parent = introFrame,
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
	while introFrame.Parent do
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
	Parent = introFrame,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	ZIndex = 50,
})
for i = 0, 50 do
	create("Frame", {
		Parent = scanlines,
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 0, i * 7),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
	})
end

-- ============================================
-- ROBLOX LOGO PHASE (BULET - INSIDE FRAME)
-- ============================================
local logoPhase = create("Frame", {
	Name = "LogoPhase",
	Parent = introFrame,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	ZIndex = 100,
})

local robloxLogo = create("ImageLabel", {
	Name = "RobloxLogo",
	Parent = logoPhase,
	Size = UDim2.new(0, 120, 0, 120),
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
	Size = UDim2.new(0, 145, 0, 145),
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
	Size = UDim2.new(0, 132, 0, 132),
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
-- A2 TEXT CONTAINER (INSIDE 550x350 FRAME)
-- ============================================
local a2Container = create("Frame", {
	Name = "A2Container",
	Parent = introFrame,
	Size = UDim2.new(0, 400, 0, 160),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	ZIndex = 10,
	Visible = false,
})

local glowLayers = {
	{ color = CONFIG.A2ShadowColor, offset = 8, transparency = 0.7, size = 85 },
	{ color = CONFIG.A2GlowColor,   offset = 5,  transparency = 0.5, size = 82 },
	{ color = Color3.fromRGB(255, 255, 255), offset = 2, transparency = 0.3, size = 80 },
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
	TextSize = 78,
	TextColor3 = CONFIG.A2Color,
	TextTransparency = 1,
	ZIndex = 10,
})

local a2Stroke = create("UIStroke", {
	Parent = a2Text,
	Color = Color3.fromRGB(255, 255, 255),
	Thickness = 3,
	Transparency = 1,
})

local a2GlowFrame = create("Frame", {
	Parent = a2Container,
	Name = "A2GlowFrame",
	Size = UDim2.new(1, 50, 1, 50),
	Position = UDim2.new(0, -25, 0, -25),
	BackgroundTransparency = 1,
	ZIndex = 9,
})
local a2GlowStroke = create("UIStroke", {
	Parent = a2GlowFrame,
	Color = Color3.fromRGB(255, 255, 255),
	Thickness = 15,
	Transparency = 1,
})

local subtitle = create("TextLabel", {
	Parent = a2Container,
	Name = "Subtitle",
	Size = UDim2.new(1, 0, 0, 20),
	Position = UDim2.new(0, 0, 1, 8),
	BackgroundTransparency = 1,
	Text = "",
	Font = Enum.Font.Code,
	TextSize = 11,
	TextColor3 = CONFIG.TealColor,
	TextTransparency = 0,
	ZIndex = 10,
})

-- ============================================
-- CORNER BRACKETS (inside small frame)
-- ============================================
local function createBracket(position, anchor)
	local bracket = create("Frame", {
		Parent = introFrame,
		Size = UDim2.new(0, 20, 0, 20),
		Position = position,
		AnchorPoint = anchor,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 12,
	})
	local h = create("Frame", {
		Parent = bracket,
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = CONFIG.NeonCyan,
		BorderSizePixel = 0,
	})
	local v = create("Frame", {
		Parent = bracket,
		Size = UDim2.new(0, 2, 1, 0),
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

createBracket(UDim2.new(0, 12, 0, 12), Vector2.new(0, 0))
createBracket(UDim2.new(1, -12, 0, 12), Vector2.new(1, 0))
createBracket(UDim2.new(0, 12, 1, -12), Vector2.new(0, 1))
createBracket(UDim2.new(1, -12, 1, -12), Vector2.new(1, 1))

-- ============================================
-- FLOATING BLOCKS (inside frame)
-- ============================================
local blockColors = {CONFIG.RedColor, CONFIG.TealColor, CONFIG.BlueColor, CONFIG.OrangeColor}
local blockPositions = {
	UDim2.new(0.06, 0, 0.1, 0),
	UDim2.new(0.9, 0, 0.75, 0),
	UDim2.new(0.1, 0, 0.85, 0),
	UDim2.new(0.88, 0, 0.18, 0),
}
for i = 1, 4 do
	local block = create("Frame", {
		Parent = introFrame,
		Name = "Block" .. i,
		Size = UDim2.new(0, 14, 0, 14),
		Position = blockPositions[i],
		BackgroundColor3 = blockColors[i],
		BorderSizePixel = 0,
		ZIndex = 5,
	})
	create("UICorner", {Parent = block, CornerRadius = UDim.new(0, 3)})
	task.spawn(function()
		while block.Parent do
			tween(block, {Position = UDim2.new(blockPositions[i].X.Scale, blockPositions[i].X.Offset, blockPositions[i].Y.Scale, blockPositions[i].Y.Offset - 10)}, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(1.5)
			if not block.Parent then break end
			tween(block, {Position = blockPositions[i]}, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(1.5)
		end
	end)
end

-- ============================================
-- PARTICLE SYSTEM (inside frame)
-- ============================================
local particleColors = {Color3.fromRGB(255,255,255), CONFIG.A2GlowColor, CONFIG.TealColor, CONFIG.OrangeColor, CONFIG.BlueColor}
local function spawnParticle()
	local color = particleColors[math.random(1, #particleColors)]
	local size = randomRange(3, 7)
	local startX = randomRange(0, 1)
	local duration = randomRange(2, 4)
	local particle = create("Frame", {
		Parent = introFrame,
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
	while introFrame.Parent do
		spawnParticle()
		task.wait(randomRange(0.1, 0.4))
	end
end)

-- ============================================
-- GLITCH EFFECT (inside frame)
-- ============================================
local glitchFrame = create("Frame", {
	Name = "GlitchOverlay",
	Parent = introFrame,
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
-- REPLAY BUTTON (inside frame)
-- ============================================
local replayBtn = create("TextButton", {
	Parent = introFrame,
	Name = "ReplayButton",
	Size = UDim2.new(0, 90, 0, 28),
	Position = UDim2.new(0.5, 0, 1, -35),
	AnchorPoint = Vector2.new(0.5, 1),
	BackgroundColor3 = CONFIG.BackgroundColor,
	BackgroundTransparency = 0,
	Text = "▶ REPLAY",
	Font = Enum.Font.Code,
	TextSize = 10,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	ZIndex = 30,
	Visible = false,
	AutoButtonColor = true,
})
create("UIStroke", {Parent = replayBtn, Color = CONFIG.NeonCyan, Thickness = 2})
create("UICorner", {Parent = replayBtn, CornerRadius = UDim.new(0, 6)})

replayBtn.MouseEnter:Connect(function()
	tween(replayBtn, {BackgroundColor3 = CONFIG.NeonCyan}, 0.3)
	tween(replayBtn, {TextColor3 = CONFIG.BackgroundColor}, 0.3)
end)
replayBtn.MouseLeave:Connect(function()
	tween(replayBtn, {BackgroundColor3 = CONFIG.BackgroundColor}, 0.3)
	tween(replayBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.3)
end)

-- ============================================
-- AUTO CLOSE FUNCTION
-- ============================================
local function closeIntro()
	tween(introFrame, {BackgroundTransparency = 1}, CONFIG.CloseFadeDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(darkOverlay, {BackgroundTransparency = 1}, CONFIG.CloseFadeDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(frameBorder, {Transparency = 1}, CONFIG.CloseFadeDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(innerGlowStroke, {Transparency = 1}, CONFIG.CloseFadeDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	for _, child in ipairs(introFrame:GetDescendants()) do
		if child:IsA("Frame") and child ~= introFrame then
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
-- ANIMATION SEQUENCE (DURASI SAMA!)
-- ============================================
local function playIntro()
	-- RESET
	robloxLogo.ImageTransparency = 1
	robloxLogo.Size = UDim2.new(0, 100, 0, 100)
	robloxLogo.Rotation = 0

	logoRing.Size = UDim2.new(0, 125, 0, 125)
	ringStroke.Transparency = 1

	innerRing.Size = UDim2.new(0, 112, 0, 112)
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

	-- ========== PHASE 1: ROBLOX LOGO BULET ==========
	tween(robloxLogo, {ImageTransparency = 0}, 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	tween(logoRing, {Size = UDim2.new(0, 190, 0, 190)}, 1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.2)
	tween(ringStroke, {Transparency = 0.6}, 1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.3)

	tween(innerRing, {Size = UDim2.new(0, 165, 0, 165)}, 1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.3)
	tween(innerStroke, {Transparency = 0.5}, 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.4)

	tween(robloxLogo, {Size = UDim2.new(0, 140, 0, 140)}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0.5)
	task.wait(1.2)
	if not robloxLogo.Parent then return end
	tween(robloxLogo, {Size = UDim2.new(0, 128, 0, 128)}, 1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	task.wait(CONFIG.LogoDuration - 1.2)
	if not robloxLogo.Parent then return end

	tween(robloxLogo, {ImageTransparency = 1, Size = UDim2.new(0, 220, 0, 220), Rotation = 20}, CONFIG.LogoFadeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(logoRing, {Size = UDim2.new(0, 300, 0, 300)}, CONFIG.LogoFadeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(ringStroke, {Transparency = 1}, CONFIG.LogoFadeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(innerRing, {Size = UDim2.new(0, 260, 0, 260)}, CONFIG.LogoFadeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(innerStroke, {Transparency = 1}, CONFIG.LogoFadeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	task.wait(CONFIG.LogoFadeOut + 0.2)
	logoPhase.Visible = false

	-- ========== PHASE 2: A2 GLOW PUTIH ==========
	a2Container.Visible = true
	a2Container.Size = UDim2.new(0, 250, 0, 100)
	a2Container.Position = UDim2.new(0.5, 0, 0.5, 25)

	tween(a2Container, {
		Size = UDim2.new(0, 430, 0, 175),
		Position = UDim2.new(0.5, 0, 0.5, -6)
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
		Size = UDim2.new(0, 400, 0, 160),
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

	-- ========== AUTO CLOSE (DURASI SAMA) ==========
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

print("[A2 Intro v9] Frame 550x350 Loaded! Cyberpunk + Logo Bulet + A2 Glow + Auto Close")
