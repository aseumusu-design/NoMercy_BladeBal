local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SP = game:GetService("StarterPlayer")
local SPS = SP:WaitForChild("StarterPlayerScripts")

-- Bersihkan versi lama
for _, obj in ipairs({
	RS:FindFirstChild("ToggleInvisible"),
	SSS:FindFirstChild("InvisibleServer"),
	SPS:FindFirstChild("InvisibleClient")
}) do
	if obj then
		obj:Destroy()
	end
end

-- RemoteEvent
local remote = Instance.new("RemoteEvent")
remote.Name = "ToggleInvisible"
remote.Parent = RS

-- SERVER SCRIPT
local server = Instance.new("Script")
server.Name = "InvisibleServer"
server.Source = [==[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage:WaitForChild("ToggleInvisible")
local states = {}
local cooldown = {}

local function updateCharacter(player)
	if player.Character then
		player.Character:SetAttribute(
			"InvisibleToOthers",
			states[player] == true
		)
	end
end

Players.PlayerAdded:Connect(function(player)
	states[player] = false

	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		updateCharacter(player)
	end)
end)

remote.OnServerEvent:Connect(function(player, state)
	if typeof(state) ~= "boolean" then
		return
	end

	local now = os.clock()

	if cooldown[player] and now - cooldown[player] < 0.3 then
		return
	end

	cooldown[player] = now
	states[player] = state
	updateCharacter(player)
end)

Players.PlayerRemoving:Connect(function(player)
	states[player] = nil
	cooldown[player] = nil
end)
]==]
server.Parent = SSS

-- CLIENT SCRIPT + UI
local client = Instance.new("LocalScript")
client.Name = "InvisibleClient"
client.Source = [==[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("ToggleInvisible")

local enabled = false

local function setHidden(character, hidden)
	if not character then
		return
	end

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			object.LocalTransparencyModifier = hidden and 1 or 0
		end
	end
end

local function watchCharacter(otherPlayer, character)
	if not character then
		return
	end

	if otherPlayer == player then
		setHidden(character, false)
		return
	end

	local function refresh()
		local invisible =
			character:GetAttribute("InvisibleToOthers") == true

		setHidden(character, invisible)
	end

	refresh()

	character:GetAttributeChangedSignal(
		"InvisibleToOthers"
	):Connect(refresh)

	character.DescendantAdded:Connect(function(object)
		local invisible =
			character:GetAttribute("InvisibleToOthers") == true

		if object:IsA("BasePart") then
			object.LocalTransparencyModifier = invisible and 1 or 0
		end
	end)
end

local function watchPlayer(otherPlayer)
	if otherPlayer == player then
		return
	end

	otherPlayer.CharacterAdded:Connect(function(character)
		task.wait(0.2)
		watchCharacter(otherPlayer, character)
	end)

	if otherPlayer.Character then
		watchCharacter(otherPlayer, otherPlayer.Character)
	end
end

for _, otherPlayer in ipairs(Players:GetPlayers()) do
	watchPlayer(otherPlayer)
end

Players.PlayerAdded:Connect(watchPlayer)

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "InvisibleUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Name = "ToggleButton"
button.Size = UDim2.fromOffset(200, 55)
button.Position = UDim2.new(0, 20, 1, -80)
button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 18
button.Font = Enum.Font.GothamBold
button.Text = "INVISIBLE: OFF"
button.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = button

local function updateButton()
	if enabled then
		button.Text = "INVISIBLE: ON"
		button.BackgroundColor3 = Color3.fromRGB(35, 160, 85)
	else
		button.Text = "INVISIBLE: OFF"
		button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	end
end

button.Activated:Connect(function()
	enabled = not enabled

	updateButton()
	remote:FireServer(enabled)

	-- Karakter sendiri tetap terlihat
	if player.Character then
		setHidden(player.Character, false)
	end
end)

player.CharacterAdded:Connect(function(character)
	task.wait(0.3)
	setHidden(character, false)
end)

updateButton()
]==]
client.Parent = SPS

print("SELESAI: Invisible UI sudah dibuat. Tekan PLAY untuk mencoba.")
