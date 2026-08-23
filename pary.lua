-- ============================================
-- A2 ROBLOX INTRO UI LIBRARY v2
-- by Kimi Chat | StarterGui > ScreenGui > LocalScript
-- Sequence: Roblox Logo (113381647185328) → A2 Glow White
-- ============================================

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- CONFIGURATION
-- ============================================
local CONFIG = {
	BackgroundColor = Color3.fromRGB(13, 13, 13),
	Text = "A2",
	Subtitle = "Loading Experience...",

	-- Roblox Logo
	RobloxLogoId = "rbxassetid://113381647185328",
	LogoDuration = 2.0,      -- berapa lama logo ditampilkan
	LogoFadeOut = 0.8,       -- durasi fade out logo

	-- A2 Text
	A2Color = Color3.fromRGB(255, 255, 255),      -- putih
	A2GlowColor = Color3.fromRGB(200, 220, 255),  -- glow biru-putih
	A2ShadowColor = Color3.fromRGB(100, 150, 255),-- shadow biru

	-- Colors
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

-- Background
local background = create("Frame", {
	Name = "Background",
	Parent = screenGui,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = CONFIG.BackgroundColor,
	BorderSizePixel = 0,
	ZIndex = 1,
})

-- Grid pattern
local gridPattern = create("Frame", {
	Name = "GridPattern",
	Parent = background,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	ZIndex = 2,
})

for i = 0, 20 do
	create("Frame", {
		Parent = gridPattern,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, i / 20, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.97,
		BorderSizePixel = 0,
	})
	create("Frame", {
		Parent = gridPattern,
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(i / 20, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.97,
		BorderSizePixel = 0,
	})
end

-- Animate grid
local gridOffset = 0
task.spawn(function()
	while background.Parent do
		gridOffset = (gridOffset + 1) % 40
		gridPattern.Position = UDim2.new(0, -gridOffset, 0, -gridOffset)
		task.wait(0.05)
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
-- ROBLOX LOGO (PHASE 1)
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

-- Logo glow ring
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

-- ============================================
-- A2 TEXT CONTAINER (PHASE 2)
-- ============================================
local a2Container = create("Frame", {
	Name = "A2Container",
	Parent = background,
	Size = UDim2.new(0, 500, 0, 250),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	ZIndex = 10,
	Visible = false,
})

-- Glow layers (multiple white glows for strong effect)
local glowLayers = {
	{ color = CONFIG.A2ShadowColor, offset = 12, transparency = 0.6, size = 140 },
	{ color = CONFIG.A2GlowColor,   offset = 8,  transparency = 0.4, size = 130 },
	{ color = Color3.fromRGB(255, 255, 255), offset = 4, transparency = 0.2, size = 125 },
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

-- Main A2 text (white)
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

-- Strong white glow using UIStroke
local a2Stroke = create("UIStroke", {
	Parent = a2Text,
	Color = Color3.fromRGB(255, 255, 255),
	Thickness = 4,
	Transparency = 1,
})

-- Outer glow frame
local a2GlowFrame = create("Frame", {
	Parent = a2Container,
	Name = "A2GlowFrame",
	Size = UDim2.new(1, 60, 1, 60),
	Position = UDim2.new(0, -30, 0, -30),
	BackgroundTransparency = 1,
	ZIndex = 9,
})

local a2GlowStroke = create("UIStroke", {
	Parent = a2GlowFrame,
	Color = Color3.fromRGB(255, 255, 255),
	Thickness = 20,
	Transparency = 1,
})

-- Subtitle
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
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
	})
	local v = create("Frame", {
		Parent = bracket,
		Size = UDim2.new(0, 3, 1, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
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
-- PARTICLE SYSTEM
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
-- GLITCH EFFECT
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
create("UIStroke", {Parent = replayBtn, Color = Color3.fromRGB(255, 255, 255), Thickness = 2})
create("UICorner", {Parent = replayBtn, CornerRadius = UDim.new(0, 8)})

replayBtn.MouseEnter:Connect(function()
	tween(replayBtn, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.3)
	tween(replayBtn, {TextColor3 = CONFIG.BackgroundColor}, 0.3)
end)
replayBtn.MouseLeave:Connect(function()
	tween(replayBtn, {BackgroundColor3 = CONFIG.BackgroundColor}, 0.3)
	tween(replayBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.3)
end)

-- ============================================
-- ANIMATION SEQUENCE
-- ============================================
local function playIntro()
	-- RESET
	robloxLogo.ImageTransparency = 1
	robloxLogo.Size = UDim2.new(0, 150, 0, 150)
	robloxLogo.Rotation = 0
	logoRing.Size = UDim2.new(0, 180, 0, 180)
	ringStroke.Transparency = 1

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

	-- ========== PHASE 1: ROBLOX LOGO ==========
	logoPhase.Visible = true

	-- Fade in logo
	tween(robloxLogo, {ImageTransparency = 0}, 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	-- Scale up ring
	tween(logoRing, {Size = UDim2.new(0, 260, 0, 260)}, 1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.2)
	tween(ringStroke, {Transparency = 0.7}, 1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.3)

	-- Pulse logo
	tween(robloxLogo, {Size = UDim2.new(0, 220, 0, 220)}, 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0.5)
	task.wait(1.5)
	if not robloxLogo.Parent then return end
	tween(robloxLogo, {Size = UDim2.new(0, 200, 0, 200)}, 1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	-- Wait then fade out
	task.wait(CONFIG.LogoDuration - 1.5)
	if not robloxLogo.Parent then return end

	-- Fade out logo
	tween(robloxLogo, {ImageTransparency = 1, Size = UDim2.new(0, 300, 0, 300), Rotation = 15}, CONFIG.LogoFadeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(logoRing, {Size = UDim2.new(0, 400, 0, 400)}, CONFIG.LogoFadeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(ringStroke, {Transparency = 1}, CONFIG.LogoFadeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	task.wait(CONFIG.LogoFadeOut + 0.2)
	logoPhase.Visible = false

	-- ========== PHASE 2: A2 GLOW WHITE ==========
	a2Container.Visible = true
	a2Container.Size = UDim2.new(0, 300, 0, 150)
	a2Container.Position = UDim2.new(0.5, 0, 0.5, 40)

	-- Entry bounce
	tween(a2Container, {
		Size = UDim2.new(0, 520, 0, 260),
		Position = UDim2.new(0.5, 0, 0.5, -10)
	}, 0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	-- Reveal glow layers
	for i, child in ipairs(a2Container:GetChildren()) do
		if child:IsA("TextLabel") and child.Name:find("Glow") then
			tween(child, {TextTransparency = 0.3}, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.2 + (i * 0.08))
		end
	end

	-- Reveal main text
	tween(a2Text, {TextTransparency = 0}, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.3)

	-- Reveal strokes (glow effect)
	tween(a2Stroke, {Transparency = 0.1}, 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.4)
	tween(a2GlowStroke, {Transparency = 0.6}, 1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.5)

	-- Bounce back
	tween(a2Container, {
		Size = UDim2.new(0, 500, 0, 250),
		Position = UDim2.new(0.5, 0, 0.5, 0)
	}, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.7)

	-- Typewriter subtitle
	task.delay(1.5, function()
		local text = CONFIG.Subtitle
		for i = 1, #text do
			if not subtitle.Parent then break end
			subtitle.Text = string.sub(text, 1, i)
			task.wait(0.08)
		end
	end)

	-- Pulse glow
	task.delay(2, function()
		while a2Text.Parent and a2Text.TextTransparency < 0.5 do
			tween(a2GlowStroke, {Transparency = 0.3}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			tween(a2Stroke, {Transparency = 0}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(1.2)
			if not a2Text.Parent then break end
			tween(a2GlowStroke, {Transparency = 0.7}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			tween(a2Stroke, {Transparency = 0.2}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(1.2)
		end
	end)

	-- Show replay
	task.delay(3.5, function()
		if replayBtn.Parent then
			replayBtn.Visible = true
			tween(replayBtn, {TextTransparency = 0}, 0.5)
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

print("[A2 Intro v2] Loaded! Sequence: Roblox Logo → A2 Glow White")
