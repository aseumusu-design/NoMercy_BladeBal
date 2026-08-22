-- PASTE DI ROBLOX STUDIO COMMAND BAR
-- Bukan F9 Developer Console

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")

-- Hapus versi lama kalau ada
local oldEvent = ReplicatedStorage:FindFirstChild("ToggleInvisible")
if oldEvent then
	oldEvent:Destroy()
end

local oldServer = ServerScriptService:FindFirstChild("InvisibleServer")
if oldServer then
	oldServer:Destroy()
end

local starterScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local oldClient = starterScripts:FindFirstChild("InvisibleClient")
if oldClient then
	oldClient:Destroy()
end

-- RemoteEvent
local remote = Instance.new("RemoteEvent")
remote.Name = "ToggleInvisible"
remote.Parent = ReplicatedStorage

-- Server Script
local serverScript = Instance.new("Script")
serverScript.Name = "InvisibleServer"
serverScript.Source = [=[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local toggleEvent = ReplicatedStorage:WaitForChild("ToggleInvisible")

local invisibleStates = {}
local lastToggle = {}

local function applyState(player)
	local character = player.Character

	if character then
		character:SetAttribute(
			"InvisibleToOthers",
			invisibleStates[player] == true
		)
	end
end

Players.PlayerAdded:Connect(function(player)
	invisibleStates[player] = false

	player.CharacterAdded:Connect(function()
		task.wait(0.2)
		applyState(player)
	end)
end)

toggleEvent.OnServerEvent:Connect(function(player, requestedState)
	if typeof(requestedState) ~= "boolean" then
		return
	end

	local currentTime = os.clock()

	if lastToggle[player] then
		if currentTime - lastToggle[player] < 0.25 then
			return
		end
	end

	lastToggle[player] = currentTime
	invisibleStates[player] = requestedState

	applyState(player)
end)

Players.PlayerRemoving:Connect(function(player)
	invisibleStates[player] = nil
	lastToggle[player] = nil
end)
]=]
serverScript.Parent = ServerScriptService

-- Client LocalScript
local clientScript = Instance.new("LocalScript")
clientScript.Name = "InvisibleClient"
clientScript.Source = [=[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local toggleEvent = ReplicatedStorage:WaitForChild("ToggleInvisible")

local invisibleEnabled = false
local playerConnections = {}

local function setPartVisibility(object, hidden)
	if object:IsA("BasePart") then
		object.LocalTransparencyModifier = hidden and 1 or 0
	end
end

local function updateCharacterVisibility(character, hidden)
	if not character then
		return
	end

	for _, object in ipairs(character:GetDescendants()) do
		setPartVisibility(object, hidden)
	end
end

local function watchCharacter(player, character)
	if not character then
		return
	end

	-- Pemilik karakter tetap bisa melihat dirinya sendiri
	if player == localPlayer then
		updateCharacterVisibility(character, false)
		return
	end

	local function refresh()
		local shouldHide =
			character:GetAttribute("InvisibleToOthers") == true

		updateCharacterVisibility(character, shouldHide)
	end

	refresh()

	local attributeConnection =
		character:GetAttributeChangedSignal("InvisibleToOthers"):Connect(refresh)

	local descendantConnection =
		character.DescendantAdded:Connect(function(object)
			local shouldHide =
				character:GetAttribute("InvisibleToOthers") == true

			setPartVisibility(object, shouldHide)
		end)

	if not playerConnections[player] then
		playerConnections[player] = {}
	end

	table.insert(playerConnections[player], attributeConnection)
	table.insert(playerConnections[player], descendantConnection)
end

local function watchPlayer(player)
	if player == localPlayer then
		return
	end

	if playerConnections[player] then
		for _, connection in ipairs(playerConnections[player]) do
			connection:Disconnect()
		end
	end

	playerConnections[player] = {}

	player.CharacterAdded:Connect(function(character)
		task.wait(0.2)
		watchCharacter(player, character)
	end)

	if player.Character then
		watchCharacter(player, player.Character)
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	watchPlayer(player)
end

Players.PlayerAdded:Connect(watchPlayer)

Players.PlayerRemoving:Connect(function(player)
	if playerConnections[player] then
		for _, connection in ipairs(playerConnections[player]) do
			connection:Disconnect()
		end

		playerConnections[player] = nil
	end
end)

-- UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InvisibleUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Name = "InvisibleButton"
button.Size = UDim2.fromOffset(190, 50)
button.Position = UDim2.new(0, 20, 1, -75)
button.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 17
button.Font = Enum.Font.GothamBold
button.Text = "Invisible: OFF"
button.AutoButtonColor = true
button.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = button

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(130, 130, 140)
stroke.Parent = button

local function updateButton()
	if invisibleEnabled then
		button.Text = "Invisible: ON"
		button.BackgroundColor3 = Color3.fromRGB(35, 150, 85)
	else
		button.Text = "Invisible: OFF"
		button.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
	end
end

button.Activated:Connect(function()
	invisibleEnabled = not invisibleEnabled

	updateButton()
	toggleEvent:FireServer(invisibleEnabled)

	-- Pastikan karakter sendiri tetap terlihat
	if localPlayer.Character then
		updateCharacterVisibility(localPlayer.Character, false)
	end
end)

localPlayer.CharacterAdded:Connect(function(character)
	task.wait(0.3)
	updateCharacterVisibility(character, false)
end)

updateButton()
]=]
clientScript.Parent = starterScripts

print("Invisible system berhasil dibuat. Tekan Play untuk mencoba.")
