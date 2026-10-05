--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║                        REFLEX SCRIPT v5.0                             ║
    ║                   Geode Collector & Utility Hub                       ║
    ║                      Create by Reflex Script                          ║
    ╚══════════════════════════════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------
-- CONFIGURATION
--------------------------------------------------

local CONFIG = {
	-- GEODE ESP
	GEODE_ESP_ENABLED = true,
	HIGHLIGHT_NAME = "_ReflexGeodeHighlight",
	GEODE_RAINBOW = true,
	GEODE_RAINBOW_SPEED = 0.18,
	GEODE_TRACER_ENABLED = true,
	GEODE_TRACER_THICKNESS = 1.5,
	GEODE_BOX_ENABLED = false,
	GEODE_NAME_ENABLED = false,
	GEODE_DISTANCE_ENABLED = false,
	GEODE_MAX_DISTANCE = 5000,
	GEODE_FILL_TRANSPARENCY = 0.3,
	GEODE_OUTLINE_TRANSPARENCY = 0,
	GEODE_DEPTH_MODE = "AlwaysOnTop",

	-- PLAYER ESP
	PLAYER_ESP_ENABLED = false,
	PLAYER_HIGHLIGHT_ENABLED = true,
	PLAYER_TRACER_ENABLED = false,
	PLAYER_BOX_ENABLED = false,
	PLAYER_NAME_ENABLED = false,
	PLAYER_DISTANCE_ENABLED = false,
	PLAYER_HEALTH_ENABLED = false,
	PLAYER_SKELETON_ENABLED = false,
	PLAYER_SKELETON_THICKNESS = 1.5,
	PLAYER_RAINBOW = true,
	PLAYER_RAINBOW_SPEED = 0.18,
	PLAYER_MAX_DISTANCE = 5000,
	PLAYER_FILL_TRANSPARENCY = 0.4,
	PLAYER_OUTLINE_TRANSPARENCY = 0,
	PLAYER_TEAM_CHECK = false,
	PLAYER_TRACER_THICKNESS = 1.5,

	-- FLY
	FLY_ENABLED = false,
	FLY_SPEED = 50,
	FLY_VERTICAL_SPEED = 40,

	-- MOUVEMENT
	NOCLIP_ENABLED = false,
	INFINITE_JUMP = false,
	WALK_SPEED = 16,
	JUMP_POWER = 50,
	GRAVITY_ENABLED = false,
	GRAVITY = 196.2,
	HIP_HEIGHT_ENABLED = false,
	HIP_HEIGHT = 2,
	ANTI_AFK = false,

	-- COLLECTE
	AUTO_COLLECT_ENABLED = true,
	AUTO_TP_ENABLED = false,
	AUTO_TP_DELAY = 0.3,
	AUTO_TP_LOOP_DELAY = 3,
	COLLECT_ROTATION_SPEED = 6,
	COLLECT_RADIUS = 4,
	COLLECT_TIMEOUT = 15,
	COLLECT_HEIGHT = 3,

	-- TROLL
	SPAWN_GEODE_CLICK = false,
	SPAWN_GEODE_HEIGHT = 3,
	SPAWN_GEODE_COUNT = 1,
	SPAWN_GEODE_ANCHORED = true,

	-- THEME / GUI
	THEME = Color3.fromRGB(59, 224, 174),
	THEME_HEX = "#3BE0AE",
	BG_PRIMARY = Color3.fromRGB(14, 14, 18),
	BG_SECONDARY = Color3.fromRGB(22, 22, 28),
	BG_TERTIARY = Color3.fromRGB(30, 30, 38),
	BG_HOVER = Color3.fromRGB(38, 38, 46),
	TEXT_PRIMARY = Color3.fromRGB(240, 240, 245),
	TEXT_SECONDARY = Color3.fromRGB(160, 160, 175),
	TEXT_MUTED = Color3.fromRGB(100, 100, 115),
	BORDER_COLOR = Color3.fromRGB(40, 40, 48),
	PANEL_WIDTH = 780,
	PANEL_HEIGHT = 500,
	UI_SCALE = 1,
	UI_ORIENTATION = "Horizontal",
	BLUR_ENABLED = true,
	BLUR_INTENSITY = 14,
	NOTIFICATIONS_ENABLED = true,
	SNOW_ENABLED = true,
	SNOW_COUNT = 70,
	SNOW_SPEED = 1,
}

--------------------------------------------------
-- UTILITAIRES
--------------------------------------------------

local function hexToColor(hex)
	if typeof(hex) ~= "string" then return nil end
	hex = hex:gsub("#", "")
	if #hex == 3 then
		hex = hex:sub(1,1):rep(2) .. hex:sub(2,2):rep(2) .. hex:sub(3,3):rep(2)
	end
	if #hex ~= 6 then return nil end
	local r = tonumber(hex:sub(1, 2), 16)
	local g = tonumber(hex:sub(3, 4), 16)
	local b = tonumber(hex:sub(5, 6), 16)
	if not r or not g or not b then return nil end
	return Color3.fromRGB(r, g, b)
end

local function isValidHex(str)
	if typeof(str) ~= "string" then return false end
	local clean = str:gsub("#", "")
	if #clean ~= 3 and #clean ~= 6 then return false end
	return clean:match("^%x+$") ~= nil
end

--------------------------------------------------
-- DÉTECTION GEODE
--------------------------------------------------

local function containsGeode(value)
	if typeof(value) ~= "string" then return false end
	return string.find(string.lower(value), "geode", 1, true) ~= nil
end

local function isGeode(obj)
	if not obj or not obj.Parent then return false end
	if containsGeode(obj.Name) then return true end
	local ok, dn = pcall(function() return obj.DisplayName end)
	if ok and containsGeode(dn) then return true end
	local parent = obj.Parent
	for i = 1, 8 do
		if not parent then break end
		if parent == Workspace then break end
		if containsGeode(parent.Name) then return true end
		local ok2, dn2 = pcall(function() return parent.DisplayName end)
		if ok2 and containsGeode(dn2) then return true end
		parent = parent.Parent
	end
	local ok3, attrs = pcall(function() return obj:GetAttributes() end)
	if ok3 and attrs then
		for k, v in pairs(attrs) do
			if containsGeode(k) then return true end
			if typeof(v) == "string" and containsGeode(v) then return true end
		end
	end
	return false
end

local function getTargetPart(obj)
	if not obj or not obj.Parent then return nil end
	if obj:IsA("BasePart") then return obj end
	if obj:IsA("Model") then
		return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
	end
	return nil
end

--------------------------------------------------
-- STATE
--------------------------------------------------

local STATE = {
	geodes = {},
	geodeTracers = {},
	geodeBoxes = {},
	geodeNames = {},
	geodeDistances = {},

	playerHighlights = {},
	playerTracers = {},
	playerBoxes = {},
	playerNames = {},
	playerDistances = {},
	playerHealths = {},
	playerSkeletons = {},

	tabButtons = {},
	pages = {},
	themeUpdaters = {},

	open = false,
	snowflakes = {},
	collecting = false,
	tpActive = false,
	tpQueue = {},
}

--------------------------------------------------
-- FORWARD DECLARATIONS
--------------------------------------------------

local startFly, stopFly
local startNoclip, stopNoclip
local applyMovementSettings
local addPlayerVisuals, removePlayerVisuals, clearAllPlayerVisuals
local addGeodeVisuals, removeGeodeVisuals, clearAllGeodeVisuals
local spawnGeodeAtPlayer
local tpAllGeodes, tpToNearestGeode
local refreshTheme
local switchTab
local scanGeodes
local notify
local startSnow, stopSnow
local createSkeletonForPlayer, updateSkeletonForPlayer, removeSkeleton

--------------------------------------------------
-- BLUR
--------------------------------------------------

local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 0
blurEffect.Parent = Lighting

--------------------------------------------------
-- DRAG SYSTEM (v5.0)
--------------------------------------------------

local function makeDraggable(frame, handle)
	local dragging = false
	local dragStart
	local startPos
	local dragInput

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = Vector2.new(input.Position.X, input.Position.Y)
			local absPos = frame.AbsolutePosition
			startPos = Vector2.new(absPos.X, absPos.Y)

			local conn
			conn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if conn then conn:Disconnect() end
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local current = Vector2.new(input.Position.X, input.Position.Y)
			local delta = current - dragStart
			local newPos = startPos + delta
			frame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
		end
	end)
end

--------------------------------------------------
-- THEME SYSTEM
--------------------------------------------------

local function registerThemeUpdater(fn)
	table.insert(STATE.themeUpdaters, fn)
end

refreshTheme = function()
	for _, fn in ipairs(STATE.themeUpdaters) do
		pcall(fn)
	end
end

--------------------------------------------------
-- GUI ROOT
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "ReflexScript"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999999
gui.Parent = PlayerGui

--------------------------------------------------
-- SNOW BACKGROUND (fix smooth + spawn correct)
--------------------------------------------------

local snowContainer = Instance.new("Frame")
snowContainer.Name = "SnowContainer"
snowContainer.Size = UDim2.fromScale(1, 1)
snowContainer.BackgroundTransparency = 1
snowContainer.ZIndex = 1
snowContainer.Parent = gui

local SNOW_RESPAWN_Y = -0.15 -- spawn au-dessus de l'écran

local function buildSnowflake()
	local screenSize = Camera.ViewportSize
	local size = math.random(3, 10)
	local startX = math.random(0, math.floor(screenSize.X))

	local flake = Instance.new("Frame")
	flake.Size = UDim2.fromOffset(size, size)
	flake.Position = UDim2.new(0, startX, SNOW_RESPAWN_Y, 0)
	flake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	flake.BackgroundTransparency = math.random(25, 60) / 100
	flake.BorderSizePixel = 0
	flake.ZIndex = 1
	flake.Parent = snowContainer

	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(1, 0)
	fc.Parent = flake

	table.insert(STATE.snowflakes, {
		frame = flake,
		size = size,
		fallSpeed = math.random(40, 120) * (size / 6) * CONFIG.SNOW_SPEED,
		swayAmplitude = math.random(15, 45),
		swayFrequency = math.random(40, 120) / 100,
		swayPhase = math.random() * math.pi * 2,
		xPos = startX,
		yPos = -size - math.random(0, screenSize.Y * 0.5),
	})
end

startSnow = function()
	if #STATE.snowflakes > 0 then return end
	for i = 1, CONFIG.SNOW_COUNT do
		buildSnowflake()
	end
end

stopSnow = function()
	for _, data in ipairs(STATE.snowflakes) do
		if data.frame then data.frame:Destroy() end
	end
	STATE.snowflakes = {}
end

if CONFIG.SNOW_ENABLED then startSnow() end

-- Update snowflakes chaque frame
local snowTime = 0
RunService.RenderStepped:Connect(function(delta)
	if not CONFIG.SNOW_ENABLED then return end

	snowTime = snowTime + delta
	local screenSize = Camera.ViewportSize

	for _, data in ipairs(STATE.snowflakes) do
		if data.frame and data.frame.Parent then
			-- Position Y linéaire + vitesse
			data.yPos = data.yPos + data.fallSpeed * delta

			-- Sway horizontal sinusoïdal
			local sway = math.sin(snowTime * data.swayFrequency + data.swayPhase) * data.swayAmplitude
			local screenX = data.xPos + sway

			-- Respawn en haut si descend trop bas
			if data.yPos > screenSize.Y + 20 then
				data.yPos = -data.size - math.random(10, 100)
				data.xPos = math.random(0, math.floor(screenSize.X))
				data.swayPhase = math.random() * math.pi * 2
				data.frame.BackgroundTransparency = math.random(25, 60) / 100
			end

			data.frame.Position = UDim2.new(0, screenX, 0, data.yPos)
		end
	end
end)

--------------------------------------------------
-- NOTIFICATIONS
--------------------------------------------------

local notifContainer = Instance.new("Frame")
notifContainer.Name = "Notifications"
notifContainer.Size = UDim2.fromOffset(300, 400)
notifContainer.Position = UDim2.new(1, -320, 0, 20)
notifContainer.BackgroundTransparency = 1
notifContainer.ZIndex = 500
notifContainer.Parent = gui

local notifLayout = Instance.new("UIListLayout")
notifLayout.Padding = UDim.new(0, 6)
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifLayout.Parent = notifContainer

notify = function(text, color)
	if not CONFIG.NOTIFICATIONS_ENABLED then return end
	color = color or CONFIG.THEME

	local notif = Instance.new("Frame")
	notif.Size = UDim2.fromOffset(280, 46)
	notif.BackgroundColor3 = CONFIG.BG_SECONDARY
	notif.BorderSizePixel = 0
	notif.BackgroundTransparency = 0.05
	notif.ZIndex = 501
	notif.Parent = notifContainer

	local nc = Instance.new("UICorner")
	nc.CornerRadius = UDim.new(0, 10)
	nc.Parent = notif

	local nstroke = Instance.new("UIStroke")
	nstroke.Thickness = 1
	nstroke.Color = color
	nstroke.Transparency = 0.2
	nstroke.Parent = notif

	local accentBar = Instance.new("Frame")
	accentBar.Size = UDim2.new(0, 3, 1, -12)
	accentBar.Position = UDim2.new(0, 6, 0.5, 0)
	accentBar.AnchorPoint = Vector2.new(0, 0.5)
	accentBar.BackgroundColor3 = color
	accentBar.BorderSizePixel = 0
	accentBar.ZIndex = 502
	accentBar.Parent = notif

	local ac = Instance.new("UICorner")
	ac.CornerRadius = UDim.new(1, 0)
	ac.Parent = accentBar

	local nlbl = Instance.new("TextLabel")
	nlbl.Size = UDim2.new(1, -22, 1, 0)
	nlbl.Position = UDim2.new(0, 16, 0, 0)
	nlbl.BackgroundTransparency = 1
	nlbl.Font = Enum.Font.GothamBold
	nlbl.TextSize = 11
	nlbl.TextColor3 = CONFIG.TEXT_PRIMARY
	nlbl.Text = text
	nlbl.TextXAlignment = Enum.TextXAlignment.Left
	nlbl.TextTruncate = Enum.TextTruncate.AtEnd
	nlbl.ZIndex = 502
	nlbl.Parent = notif

	notif.Position = UDim2.new(1, 20, 0, 0)
	TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0)
	}):Play()

	task.delay(3, function()
		if notif.Parent then
			TweenService:Create(notif, TweenInfo.new(0.25), {
				Position = UDim2.new(1, 20, 0, 0),
				BackgroundTransparency = 1
			}):Play()
			task.wait(0.3)
			if notif.Parent then notif:Destroy() end
		end
	end)
end

--------------------------------------------------
-- BOUTON FLOTTANT
--------------------------------------------------

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ReflexToggle"
toggleButton.Size = UDim2.fromOffset(72, 72)
toggleButton.Position = UDim2.new(0, 20, 0.5, -36)
toggleButton.BackgroundColor3 = CONFIG.BG_PRIMARY
toggleButton.BorderSizePixel = 0
toggleButton.Text = ""
toggleButton.AutoButtonColor = false
toggleButton.Active = true
toggleButton.ZIndex = 400
toggleButton.Parent = gui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleButton

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Thickness = 2
toggleStroke.Color = CONFIG.THEME
toggleStroke.Parent = toggleButton

local toggleInner = Instance.new("Frame")
toggleInner.Size = UDim2.new(1, -8, 1, -8)
toggleInner.Position = UDim2.new(0, 4, 0, 4)
toggleInner.BackgroundColor3 = CONFIG.THEME
toggleInner.BorderSizePixel = 0
toggleInner.ZIndex = 401
toggleInner.Parent = toggleButton

local toggleInnerCorner = Instance.new("UICorner")
toggleInnerCorner.CornerRadius = UDim.new(1, 0)
toggleInnerCorner.Parent = toggleInner

local toggleInnerGradient = Instance.new("UIGradient")
toggleInnerGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, CONFIG.THEME),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
})
toggleInnerGradient.Rotation = 135
toggleInnerGradient.Parent = toggleInner

local toggleText = Instance.new("TextLabel")
toggleText.BackgroundTransparency = 1
toggleText.Size = UDim2.fromScale(1, 1)
toggleText.Font = Enum.Font.GothamBlack
toggleText.TextSize = 17
toggleText.TextColor3 = Color3.new(1, 1, 1)
toggleText.Text = "R"
toggleText.ZIndex = 402
toggleText.Parent = toggleInner

registerThemeUpdater(function()
	toggleStroke.Color = CONFIG.THEME
	toggleInner.BackgroundColor3 = CONFIG.THEME
	toggleInnerGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, CONFIG.THEME),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
	})
end)

makeDraggable(toggleButton, toggleButton)

--------------------------------------------------
-- PANEL
--------------------------------------------------

local PANEL_W = CONFIG.PANEL_WIDTH
local PANEL_H = CONFIG.PANEL_HEIGHT

local panel = Instance.new("Frame")
panel.Name = "ReflexPanel"
panel.Size = UDim2.fromOffset(PANEL_W, PANEL_H)
panel.Position = UDim2.new(0, 100, 0, 100)
panel.BackgroundColor3 = CONFIG.BG_PRIMARY
panel.BorderSizePixel = 0
panel.Visible = false
panel.ClipsDescendants = true
panel.Active = true
panel.ZIndex = 400
panel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 16)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Thickness = 1.5
panelStroke.Color = CONFIG.BORDER_COLOR
panelStroke.Parent = panel

registerThemeUpdater(function()
	panelStroke.Color = CONFIG.BORDER_COLOR
end)

--------------------------------------------------
-- SIDEBAR
--------------------------------------------------

local SIDEBAR_W = 190

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.fromOffset(SIDEBAR_W, PANEL_H)
sidebar.Position = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundColor3 = CONFIG.BG_SECONDARY
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 401
sidebar.Parent = panel

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 16)
sidebarCorner.Parent = sidebar

local sidebarCover = Instance.new("Frame")
sidebarCover.Size = UDim2.new(0, 16, 1, 0)
sidebarCover.Position = UDim2.new(1, -16, 0, 0)
sidebarCover.BackgroundColor3 = CONFIG.BG_SECONDARY
sidebarCover.BorderSizePixel = 0
sidebarCover.ZIndex = 402
sidebarCover.Parent = sidebar

local sidebarStroke = Instance.new("UIStroke")
sidebarStroke.Thickness = 1
sidebarStroke.Color = CONFIG.BORDER_COLOR
sidebarStroke.Transparency = 0.5
sidebarStroke.Parent = sidebar

-- Logo
local logoFrame = Instance.new("Frame")
logoFrame.Name = "LogoFrame"
logoFrame.Size = UDim2.new(1, -20, 0, 68)
logoFrame.Position = UDim2.new(0, 10, 0, 12)
logoFrame.BackgroundTransparency = 1
logoFrame.Active = true
logoFrame.ZIndex = 403
logoFrame.Parent = sidebar

local logoIcon = Instance.new("Frame")
logoIcon.Size = UDim2.fromOffset(44, 44)
logoIcon.Position = UDim2.new(0, 4, 0.5, -22)
logoIcon.BackgroundColor3 = CONFIG.THEME
logoIcon.BorderSizePixel = 0
logoIcon.ZIndex = 404
logoIcon.Parent = logoFrame

local logoIconCorner = Instance.new("UICorner")
logoIconCorner.CornerRadius = UDim.new(0, 12)
logoIconCorner.Parent = logoIcon

local logoIconGradient = Instance.new("UIGradient")
logoIconGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, CONFIG.THEME),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
})
logoIconGradient.Rotation = 45
logoIconGradient.Parent = logoIcon

local logoLetter = Instance.new("TextLabel")
logoLetter.Size = UDim2.fromScale(1, 1)
logoLetter.BackgroundTransparency = 1
logoLetter.Font = Enum.Font.GothamBlack
logoLetter.TextSize = 24
logoLetter.TextColor3 = Color3.new(1, 1, 1)
logoLetter.Text = "R"
logoLetter.ZIndex = 405
logoLetter.Parent = logoIcon

local logoTitle = Instance.new("TextLabel")
logoTitle.Size = UDim2.new(0, 120, 0, 22)
logoTitle.Position = UDim2.new(0, 58, 0.5, -14)
logoTitle.BackgroundTransparency = 1
logoTitle.Font = Enum.Font.GothamBold
logoTitle.TextSize = 17
logoTitle.TextColor3 = CONFIG.TEXT_PRIMARY
logoTitle.Text = "REFLEX"
logoTitle.TextXAlignment = Enum.TextXAlignment.Left
logoTitle.ZIndex = 404
logoTitle.Parent = logoFrame

local logoSub = Instance.new("TextLabel")
logoSub.Size = UDim2.new(0, 120, 0, 14)
logoSub.Position = UDim2.new(0, 58, 0.5, 5)
logoSub.BackgroundTransparency = 1
logoSub.Font = Enum.Font.Gotham
logoSub.TextSize = 9
logoSub.TextColor3 = CONFIG.THEME
logoSub.Text = "v5.0 • Geode"
logoSub.TextXAlignment = Enum.TextXAlignment.Left
logoSub.ZIndex = 404
logoSub.Parent = logoFrame

registerThemeUpdater(function()
	logoIcon.BackgroundColor3 = CONFIG.THEME
	logoIconGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, CONFIG.THEME),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
	})
	logoSub.TextColor3 = CONFIG.THEME
end)

-- Separator
local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, -30, 0, 1)
sep.Position = UDim2.new(0, 15, 0, 86)
sep.BackgroundColor3 = CONFIG.BORDER_COLOR
sep.BorderSizePixel = 0
sep.ZIndex = 403
sep.Parent = sidebar

-- Nav
local navContainer = Instance.new("Frame")
navContainer.Name = "NavContainer"
navContainer.Size = UDim2.new(1, -20, 1, -180)
navContainer.Position = UDim2.new(0, 10, 0, 98)
navContainer.BackgroundTransparency = 1
navContainer.ZIndex = 403
navContainer.Parent = sidebar

local navLayout = Instance.new("UIListLayout")
navLayout.Padding = UDim.new(0, 4)
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Parent = navContainer

-- User footer
local userFrame = Instance.new("Frame")
userFrame.Size = UDim2.new(1, -20, 0, 56)
userFrame.Position = UDim2.new(0, 10, 1, -68)
userFrame.BackgroundColor3 = CONFIG.BG_TERTIARY
userFrame.BorderSizePixel = 0
userFrame.ZIndex = 403
userFrame.Parent = sidebar

local userCorner = Instance.new("UICorner")
userCorner.CornerRadius = UDim.new(0, 10)
userCorner.Parent = userFrame

local userAvatar = Instance.new("ImageLabel")
userAvatar.Size = UDim2.fromOffset(38, 38)
userAvatar.Position = UDim2.new(0, 9, 0.5, -19)
userAvatar.BackgroundColor3 = CONFIG.BG_SECONDARY
userAvatar.BorderSizePixel = 0
userAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=48&h=48"
userAvatar.ZIndex = 404
userAvatar.Parent = userFrame

local userAvatarCorner = Instance.new("UICorner")
userAvatarCorner.CornerRadius = UDim.new(1, 0)
userAvatarCorner.Parent = userAvatar

local userName = Instance.new("TextLabel")
userName.Size = UDim2.new(1, -58, 0, 14)
userName.Position = UDim2.new(0, 56, 0, 14)
userName.BackgroundTransparency = 1
userName.Font = Enum.Font.GothamBold
userName.TextSize = 11
userName.TextColor3 = CONFIG.TEXT_PRIMARY
userName.Text = LocalPlayer.DisplayName
userName.TextXAlignment = Enum.TextXAlignment.Left
userName.TextTruncate = Enum.TextTruncate.AtEnd
userName.ZIndex = 404
userName.Parent = userFrame

local userStatus = Instance.new("TextLabel")
userStatus.Size = UDim2.new(1, -58, 0, 12)
userStatus.Position = UDim2.new(0, 56, 0, 30)
userStatus.BackgroundTransparency = 1
userStatus.Font = Enum.Font.Gotham
userStatus.TextSize = 9
userStatus.TextColor3 = CONFIG.THEME
userStatus.Text = "En ligne"
userStatus.TextXAlignment = Enum.TextXAlignment.Left
userStatus.ZIndex = 404
userStatus.Parent = userFrame

registerThemeUpdater(function()
	userStatus.TextColor3 = CONFIG.THEME
end)

--------------------------------------------------
-- CONTENT AREA
--------------------------------------------------

local CONTENT_X = SIDEBAR_W
local HEADER_H = 64

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -CONTENT_X, 1, 0)
contentFrame.Position = UDim2.new(0, CONTENT_X, 0, 0)
contentFrame.BackgroundTransparency = 1
contentFrame.ZIndex = 401
contentFrame.Parent = panel

local contentHeader = Instance.new("Frame")
contentHeader.Name = "ContentHeader"
contentHeader.Size = UDim2.new(1, 0, 0, HEADER_H)
contentHeader.BackgroundColor3 = CONFIG.BG_SECONDARY
contentHeader.BackgroundTransparency = 0.4
contentHeader.BorderSizePixel = 0
contentHeader.Active = true
contentHeader.ZIndex = 402
contentHeader.Parent = contentFrame

local contentHeaderLine = Instance.new("Frame")
contentHeaderLine.Size = UDim2.new(1, 0, 0, 1)
contentHeaderLine.Position = UDim2.new(0, 0, 1, -1)
contentHeaderLine.BackgroundColor3 = CONFIG.BORDER_COLOR
contentHeaderLine.BorderSizePixel = 0
contentHeaderLine.ZIndex = 403
contentHeaderLine.Parent = contentHeader

local contentTitle = Instance.new("TextLabel")
contentTitle.Size = UDim2.new(1, -280, 1, -10)
contentTitle.Position = UDim2.new(0, 26, 0, 0)
contentTitle.BackgroundTransparency = 1
contentTitle.Font = Enum.Font.GothamBold
contentTitle.TextSize = 17
contentTitle.TextColor3 = CONFIG.TEXT_PRIMARY
contentTitle.Text = "Main"
contentTitle.TextXAlignment = Enum.TextXAlignment.Left
contentTitle.ZIndex = 403
contentTitle.Parent = contentHeader

local contentSub = Instance.new("TextLabel")
contentSub.Size = UDim2.new(1, -280, 0, 14)
contentSub.Position = UDim2.new(0, 26, 1, -24)
contentSub.BackgroundTransparency = 1
contentSub.Font = Enum.Font.Gotham
contentSub.TextSize = 10
contentSub.TextColor3 = CONFIG.TEXT_SECONDARY
contentSub.Text = ""
contentSub.TextXAlignment = Enum.TextXAlignment.Left
contentSub.ZIndex = 403
contentSub.Parent = contentHeader

local headerStatus = Instance.new("TextLabel")
headerStatus.Size = UDim2.new(0, 180, 1, 0)
headerStatus.Position = UDim2.new(1, -220, 0, 0)
headerStatus.BackgroundTransparency = 1
headerStatus.Font = Enum.Font.GothamBold
headerStatus.TextSize = 10
headerStatus.TextColor3 = CONFIG.THEME
headerStatus.Text = "Ready"
headerStatus.TextXAlignment = Enum.TextXAlignment.Right
headerStatus.ZIndex = 403
headerStatus.Parent = contentHeader

registerThemeUpdater(function()
	headerStatus.TextColor3 = CONFIG.THEME
end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(32, 32)
closeBtn.Position = UDim2.new(1, -46, 0.5, -16)
closeBtn.BackgroundColor3 = CONFIG.BG_TERTIARY
closeBtn.Text = "X"
closeBtn.TextColor3 = CONFIG.TEXT_PRIMARY
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 404
closeBtn.Parent = contentHeader

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

local closeStroke = Instance.new("UIStroke")
closeStroke.Thickness = 1
closeStroke.Color = CONFIG.BORDER_COLOR
closeStroke.Parent = closeBtn

closeBtn.MouseEnter:Connect(function()
	TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(200, 60, 60) }):Play()
end)

closeBtn.MouseLeave:Connect(function()
	TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = CONFIG.BG_TERTIARY }):Play()
end)

--------------------------------------------------
-- PAGES
--------------------------------------------------

local pagesFrame = Instance.new("Frame")
pagesFrame.Size = UDim2.new(1, 0, 1, -HEADER_H)
pagesFrame.Position = UDim2.new(0, 0, 0, HEADER_H)
pagesFrame.BackgroundTransparency = 1
pagesFrame.ZIndex = 402
pagesFrame.Parent = contentFrame

local function createPage(name)
	local page = Instance.new("ScrollingFrame")
	page.Name = name
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = CONFIG.THEME
	page.ScrollBarImageTransparency = 0.3
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.ZIndex = 403
	page.Parent = pagesFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = page

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 14)
	pad.PaddingLeft = UDim.new(0, 16)
	pad.PaddingRight = UDim.new(0, 16)
	pad.PaddingBottom = UDim.new(0, 14)
	pad.Parent = page

	registerThemeUpdater(function()
		page.ScrollBarImageColor3 = CONFIG.THEME
	end)

	STATE.pages[name] = page
	return page
end

--------------------------------------------------
-- UI HELPERS
--------------------------------------------------

local function createSection(parent, name)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 30)
	frame.BackgroundTransparency = 1
	frame.ZIndex = 404
	frame.Parent = parent

	local bar = Instance.new("Frame")
	bar.Size = UDim2.fromOffset(3, 14)
	bar.Position = UDim2.new(0, 2, 0.5, -7)
	bar.BackgroundColor3 = CONFIG.THEME
	bar.BorderSizePixel = 0
	bar.ZIndex = 405
	bar.Parent = frame

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(1, 0)
	barCorner.Parent = bar

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -16, 1, 0)
	lbl.Position = UDim2.new(0, 14, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 11
	lbl.TextColor3 = CONFIG.TEXT_SECONDARY
	lbl.Text = string.upper(name)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 405
	lbl.Parent = frame

	registerThemeUpdater(function()
		bar.BackgroundColor3 = CONFIG.THEME
	end)

	return frame
end

local function createToggle(parent, name, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 42)
	frame.BackgroundColor3 = CONFIG.BG_TERTIARY
	frame.BorderSizePixel = 0
	frame.ZIndex = 404
	frame.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Color = CONFIG.BORDER_COLOR
	stroke.Transparency = 0.6
	stroke.Parent = frame

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -80, 1, 0)
	lbl.Position = UDim2.new(0, 16, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 12
	lbl.TextColor3 = CONFIG.TEXT_PRIMARY
	lbl.Text = name
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 405
	lbl.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(48, 24)
	btn.Position = UDim2.new(1, -62, 0.5, -12)
	btn.BackgroundColor3 = default and CONFIG.THEME or Color3.fromRGB(46, 46, 56)
	btn.Text = ""
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.ZIndex = 405
	btn.Parent = frame

	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(1, 0)
	bc.Parent = btn

	local dot = Instance.new("Frame")
	dot.Size = UDim2.fromOffset(18, 18)
	dot.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
	dot.BackgroundColor3 = Color3.new(1, 1, 1)
	dot.BorderSizePixel = 0
	dot.ZIndex = 406
	dot.Parent = btn

	local dc = Instance.new("UICorner")
	dc.CornerRadius = UDim.new(1, 0)
	dc.Parent = dot

	local state = default

	local function update(animate)
		local ti = animate and TweenInfo.new(0.18, Enum.EasingStyle.Quad) or TweenInfo.new(0)
		TweenService:Create(btn, ti, {
			BackgroundColor3 = state and CONFIG.THEME or Color3.fromRGB(46, 46, 56)
		}):Play()
		TweenService:Create(dot, ti, {
			Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
		}):Play()
	end

	btn.MouseButton1Click:Connect(function()
		state = not state
		update(true)
		callback(state)
	end)

	registerThemeUpdater(function() update(false) end)

	return frame, {
		Set = function(v) state = v update(true) end,
		Get = function() return state end,
	}
end

local function createSlider(parent, name, min, max, default, callback, suffix)
	suffix = suffix or ""
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 58)
	frame.BackgroundColor3 = CONFIG.BG_TERTIARY
	frame.BorderSizePixel = 0
	frame.ZIndex = 404
	frame.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Color = CONFIG.BORDER_COLOR
	stroke.Transparency = 0.6
	stroke.Parent = frame

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -90, 0, 20)
	lbl.Position = UDim2.new(0, 16, 0, 8)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 12
	lbl.TextColor3 = CONFIG.TEXT_PRIMARY
	lbl.Text = name
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 405
	lbl.Parent = frame

	local valLbl = Instance.new("TextLabel")
	valLbl.Size = UDim2.new(0, 70, 0, 20)
	valLbl.Position = UDim2.new(1, -86, 0, 8)
	valLbl.BackgroundTransparency = 1
	valLbl.Font = Enum.Font.GothamBold
	valLbl.TextSize = 12
	valLbl.TextColor3 = CONFIG.THEME
	valLbl.Text = string.format("%.1f%s", default, suffix)
	valLbl.TextXAlignment = Enum.TextXAlignment.Right
	valLbl.ZIndex = 405
	valLbl.Parent = frame

	local barBg = Instance.new("Frame")
	barBg.Size = UDim2.new(1, -32, 0, 6)
	barBg.Position = UDim2.new(0, 16, 0, 40)
	barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	barBg.BorderSizePixel = 0
	barBg.ZIndex = 405
	barBg.Parent = frame

	local bgc = Instance.new("UICorner")
	bgc.CornerRadius = UDim.new(1, 0)
	bgc.Parent = barBg

	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	barFill.BackgroundColor3 = CONFIG.THEME
	barFill.BorderSizePixel = 0
	barFill.ZIndex = 406
	barFill.Parent = barBg

	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(1, 0)
	fc.Parent = barFill

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(14, 14)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
	knob.BackgroundColor3 = Color3.new(1, 1, 1)
	knob.BorderSizePixel = 0
	knob.ZIndex = 407
	knob.Parent = barBg

	local kc = Instance.new("UICorner")
	kc.CornerRadius = UDim.new(1, 0)
	kc.Parent = knob

	local kstroke = Instance.new("UIStroke")
	kstroke.Thickness = 2
	kstroke.Color = CONFIG.THEME
	kstroke.Parent = knob

	local dragging = false

	local function setValue(alpha, doCallback)
		alpha = math.clamp(alpha, 0, 1)
		local value = min + (max - min) * alpha
		barFill.Size = UDim2.new(alpha, 0, 1, 0)
		knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		valLbl.Text = string.format("%.1f%s", value, suffix)
		if doCallback ~= false then callback(value) end
	end

	barBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			local rel = (input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X
			setValue(rel)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local rel = (input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X
			setValue(rel)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	registerThemeUpdater(function()
		barFill.BackgroundColor3 = CONFIG.THEME
		kstroke.Color = CONFIG.THEME
		valLbl.TextColor3 = CONFIG.THEME
	end)

	return frame
end

local function createButton(parent, name, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 38)
	btn.BackgroundColor3 = CONFIG.BG_TERTIARY
	btn.Text = ""
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.ZIndex = 404
	btn.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Color = CONFIG.THEME
	stroke.Transparency = 0.7
	stroke.Parent = btn

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 12
	lbl.TextColor3 = CONFIG.TEXT_PRIMARY
	lbl.Text = name
	lbl.ZIndex = 405
	lbl.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = CONFIG.BG_HOVER }):Play()
		TweenService:Create(stroke, TweenInfo.new(0.15), { Transparency = 0.3 }):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = CONFIG.BG_TERTIARY }):Play()
		TweenService:Create(stroke, TweenInfo.new(0.15), { Transparency = 0.7 }):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		callback()
	end)

	registerThemeUpdater(function()
		stroke.Color = CONFIG.THEME
	end)

	return btn
end

local function createTextInput(parent, label, default, placeholder, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 42)
	frame.BackgroundColor3 = CONFIG.BG_TERTIARY
	frame.BorderSizePixel = 0
	frame.ZIndex = 404
	frame.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Color = CONFIG.BORDER_COLOR
	stroke.Transparency = 0.6
	stroke.Parent = frame

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0, 90, 1, 0)
	lbl.Position = UDim2.new(0, 16, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 12
	lbl.TextColor3 = CONFIG.TEXT_PRIMARY
	lbl.Text = label
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 405
	lbl.Parent = frame

	local input = Instance.new("TextBox")
	input.Size = UDim2.new(1, -120, 1, -10)
	input.Position = UDim2.new(0, 110, 0, 5)
	input.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
	input.BorderSizePixel = 0
	input.Font = Enum.Font.GothamBold
	input.TextSize = 12
	input.TextColor3 = CONFIG.TEXT_PRIMARY
	input.Text = default
	input.PlaceholderText = placeholder
	input.PlaceholderColor3 = CONFIG.TEXT_SECONDARY
	input.ClearTextOnFocus = false
	input.ZIndex = 405
	input.Parent = frame

	local ic = Instance.new("UICorner")
	ic.CornerRadius = UDim.new(0, 6)
	ic.Parent = input

	local istroke = Instance.new("UIStroke")
	istroke.Thickness = 1
	istroke.Color = CONFIG.BORDER_COLOR
	istroke.Transparency = 0.5
	istroke.Parent = input

	input.Focused:Connect(function()
		TweenService:Create(istroke, TweenInfo.new(0.15), {
			Color = CONFIG.THEME,
			Transparency = 0
		}):Play()
	end)

	input.FocusLost:Connect(function()
		TweenService:Create(istroke, TweenInfo.new(0.15), {
			Color = CONFIG.BORDER_COLOR,
			Transparency = 0.5
		}):Play()
		callback(input.Text)
	end)

	registerThemeUpdater(function()
		istroke.Color = CONFIG.BORDER_COLOR
	end)

	return frame, input
end

local function createDropdown(parent, label, options, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 42)
	frame.BackgroundColor3 = CONFIG.BG_TERTIARY
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	frame.ZIndex = 404
	frame.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Color = CONFIG.BORDER_COLOR
	stroke.Transparency = 0.6
	stroke.Parent = frame

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0, 90, 0, 42)
	lbl.Position = UDim2.new(0, 16, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 12
	lbl.TextColor3 = CONFIG.TEXT_PRIMARY
	lbl.Text = label
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 405
	lbl.Parent = frame

	local selectedLbl = Instance.new("TextLabel")
	selectedLbl.Size = UDim2.new(1, -176, 0, 42)
	selectedLbl.Position = UDim2.new(0, 110, 0, 0)
	selectedLbl.BackgroundTransparency = 1
	selectedLbl.Font = Enum.Font.GothamBold
	selectedLbl.TextSize = 12
	selectedLbl.TextColor3 = CONFIG.THEME
	selectedLbl.Text = default
	selectedLbl.TextXAlignment = Enum.TextXAlignment.Left
	selectedLbl.ZIndex = 405
	selectedLbl.Parent = frame

	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(0, 30, 0, 42)
	arrow.Position = UDim2.new(1, -36, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Font = Enum.Font.GothamBold
	arrow.TextSize = 10
	arrow.TextColor3 = CONFIG.TEXT_SECONDARY
	arrow.Text = "V"
	arrow.ZIndex = 405
	arrow.Parent = frame

	local clickArea = Instance.new("TextButton")
	clickArea.Size = UDim2.new(1, 0, 0, 42)
	clickArea.BackgroundTransparency = 1
	clickArea.Text = ""
	clickArea.ZIndex = 406
	clickArea.Parent = frame

	local open = false
	local listFrame

	clickArea.MouseButton1Click:Connect(function()
		open = not open
		if open then
			listFrame = Instance.new("Frame")
			listFrame.Size = UDim2.new(1, 0, 0, #options * 34)
			listFrame.Position = UDim2.new(0, 0, 0, 42)
			listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
			listFrame.BorderSizePixel = 0
			listFrame.ZIndex = 450
			listFrame.Parent = frame

			for i, opt in ipairs(options) do
				local optBtn = Instance.new("TextButton")
				optBtn.Size = UDim2.new(1, 0, 0, 34)
				optBtn.Position = UDim2.new(0, 0, 0, (i-1) * 34)
				optBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
				optBtn.Text = ""
				optBtn.BorderSizePixel = 0
				optBtn.AutoButtonColor = false
				optBtn.ZIndex = 451
				optBtn.Parent = listFrame

				local optLbl = Instance.new("TextLabel")
				optLbl.Size = UDim2.fromScale(1, 1)
				optLbl.BackgroundTransparency = 1
				optLbl.Font = Enum.Font.Gotham
				optLbl.TextSize = 12
				optLbl.TextColor3 = CONFIG.TEXT_PRIMARY
				optLbl.Text = opt
				optLbl.ZIndex = 452
				optLbl.Parent = optBtn

				optBtn.MouseEnter:Connect(function()
					optBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 52)
				end)
				optBtn.MouseLeave:Connect(function()
					optBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
				end)
				optBtn.MouseButton1Click:Connect(function()
					selectedLbl.Text = opt
					callback(opt)
					open = false
					TweenService:Create(frame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 42) }):Play()
					task.delay(0.2, function()
						if listFrame then listFrame:Destroy() listFrame = nil end
					end)
				end)
			end

			TweenService:Create(frame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 42 + #options * 34) }):Play()
		else
			TweenService:Create(frame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 42) }):Play()
			task.delay(0.2, function()
				if listFrame then listFrame:Destroy() listFrame = nil end
			end)
		end
	end)

	registerThemeUpdater(function()
		selectedLbl.TextColor3 = CONFIG.THEME
	end)

	return frame
end

--------------------------------------------------
-- PAGE: MAIN
--------------------------------------------------

local mainPage = createPage("Main")

createSection(mainPage, "Vol / Fly")
createToggle(mainPage, "Fly", CONFIG.FLY_ENABLED, function(state)
	CONFIG.FLY_ENABLED = state
	if state then startFly() else stopFly() end
end)
createSlider(mainPage, "Vitesse Fly", 10, 500, CONFIG.FLY_SPEED, function(v)
	CONFIG.FLY_SPEED = v
end)
createSlider(mainPage, "Vitesse Verticale", 10, 300, CONFIG.FLY_VERTICAL_SPEED, function(v)
	CONFIG.FLY_VERTICAL_SPEED = v
end)

createSection(mainPage, "Déplacement")
createToggle(mainPage, "Noclip", CONFIG.NOCLIP_ENABLED, function(state)
	CONFIG.NOCLIP_ENABLED = state
	if state then startNoclip() else stopNoclip() end
end)
createToggle(mainPage, "Infinite Jump", CONFIG.INFINITE_JUMP, function(state)
	CONFIG.INFINITE_JUMP = state
end)
createToggle(mainPage, "Hip Height Custom", CONFIG.HIP_HEIGHT_ENABLED, function(state)
	CONFIG.HIP_HEIGHT_ENABLED = state
	local char = LocalPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.HipHeight = state and CONFIG.HIP_HEIGHT or 2 end
	end
end)
createToggle(mainPage, "Anti AFK", CONFIG.ANTI_AFK, function(state)
	CONFIG.ANTI_AFK = state
end)
createSlider(mainPage, "WalkSpeed", 1, 500, CONFIG.WALK_SPEED, function(v)
	CONFIG.WALK_SPEED = v
	applyMovementSettings()
end)
createSlider(mainPage, "JumpPower", 1, 500, CONFIG.JUMP_POWER, function(v)
	CONFIG.JUMP_POWER = v
	applyMovementSettings()
end)
createSlider(mainPage, "Hip Height", 0, 10, CONFIG.HIP_HEIGHT, function(v)
	CONFIG.HIP_HEIGHT = v
	if CONFIG.HIP_HEIGHT_ENABLED then
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum.HipHeight = v end
		end
	end
end)
createToggle(mainPage, "Gravité Custom", CONFIG.GRAVITY_ENABLED, function(state)
	CONFIG.GRAVITY_ENABLED = state
	Workspace.Gravity = state and CONFIG.GRAVITY or 196.2
end)
createSlider(mainPage, "Gravité", 10, 500, CONFIG.GRAVITY, function(v)
	CONFIG.GRAVITY = v
	if CONFIG.GRAVITY_ENABLED then Workspace.Gravity = v end
end)

createSection(mainPage, "TP / Collecte")
createButton(mainPage, "TP to Nearest Geode", function()
	tpToNearestGeode()
end)
createButton(mainPage, "TP ALL Geodes + Collect", function()
	tpAllGeodes()
end)
createToggle(mainPage, "Auto Collect", CONFIG.AUTO_COLLECT_ENABLED, function(state)
	CONFIG.AUTO_COLLECT_ENABLED = state
end)
createToggle(mainPage, "Auto TP Loop", CONFIG.AUTO_TP_ENABLED, function(state)
	CONFIG.AUTO_TP_ENABLED = state
end)
createSlider(mainPage, "Vitesse Rotation", 1, 20, CONFIG.COLLECT_ROTATION_SPEED, function(v)
	CONFIG.COLLECT_ROTATION_SPEED = v
end)
createSlider(mainPage, "Rayon Rotation", 2, 15, CONFIG.COLLECT_RADIUS, function(v)
	CONFIG.COLLECT_RADIUS = v
end)
createSlider(mainPage, "Hauteur Collecte", 1, 8, CONFIG.COLLECT_HEIGHT, function(v)
	CONFIG.COLLECT_HEIGHT = v
end)
createSlider(mainPage, "Timeout (sec)", 5, 60, CONFIG.COLLECT_TIMEOUT, function(v)
	CONFIG.COLLECT_TIMEOUT = v
end)
createSlider(mainPage, "Delay entre TP", 0.1, 3, CONFIG.AUTO_TP_DELAY, function(v)
	CONFIG.AUTO_TP_DELAY = v
end)
createSlider(mainPage, "Delay Auto-TP Loop", 1, 15, CONFIG.AUTO_TP_LOOP_DELAY, function(v)
	CONFIG.AUTO_TP_LOOP_DELAY = v
end)

--------------------------------------------------
-- PAGE: VISUAL
--------------------------------------------------

local visualPage = createPage("Visual")

createSection(visualPage, "ESP Geode")
createToggle(visualPage, "ESP Geode", CONFIG.GEODE_ESP_ENABLED, function(state)
	CONFIG.GEODE_ESP_ENABLED = state
	if state then scanGeodes() else clearAllGeodeVisuals() end
end)
createToggle(visualPage, "Tracer Geode", CONFIG.GEODE_TRACER_ENABLED, function(state)
	CONFIG.GEODE_TRACER_ENABLED = state
end)
createToggle(visualPage, "Box Geode", CONFIG.GEODE_BOX_ENABLED, function(state)
	CONFIG.GEODE_BOX_ENABLED = state
end)
createToggle(visualPage, "Name Geode", CONFIG.GEODE_NAME_ENABLED, function(state)
	CONFIG.GEODE_NAME_ENABLED = state
end)
createToggle(visualPage, "Distance Geode", CONFIG.GEODE_DISTANCE_ENABLED, function(state)
	CONFIG.GEODE_DISTANCE_ENABLED = state
end)
createToggle(visualPage, "Rainbow Geode", CONFIG.GEODE_RAINBOW, function(state)
	CONFIG.GEODE_RAINBOW = state
end)
createSlider(visualPage, "Vitesse Rainbow Geode", 0.05, 1.5, CONFIG.GEODE_RAINBOW_SPEED, function(v)
	CONFIG.GEODE_RAINBOW_SPEED = v
end)
createSlider(visualPage, "Épaisseur Tracer Geode", 1, 6, CONFIG.GEODE_TRACER_THICKNESS, function(v)
	CONFIG.GEODE_TRACER_THICKNESS = v
	for _, line in pairs(STATE.geodeTracers) do
		pcall(function() line.Thickness = v end)
	end
end)
createSlider(visualPage, "Distance Max Geode", 100, 10000, CONFIG.GEODE_MAX_DISTANCE, function(v)
	CONFIG.GEODE_MAX_DISTANCE = v
end)
createSlider(visualPage, "Fill Geode", 0, 1, CONFIG.GEODE_FILL_TRANSPARENCY, function(v)
	CONFIG.GEODE_FILL_TRANSPARENCY = v
	for _, h in pairs(STATE.geodes) do
		pcall(function() h.FillTransparency = v end)
	end
end)
createSlider(visualPage, "Outline Geode", 0, 1, CONFIG.GEODE_OUTLINE_TRANSPARENCY, function(v)
	CONFIG.GEODE_OUTLINE_TRANSPARENCY = v
	for _, h in pairs(STATE.geodes) do
		pcall(function() h.OutlineTransparency = v end)
	end
end)
createDropdown(visualPage, "Depth Mode Geode", {"AlwaysOnTop", "Occluded", "Normal"}, CONFIG.GEODE_DEPTH_MODE, function(v)
	CONFIG.GEODE_DEPTH_MODE = v
	for _, h in pairs(STATE.geodes) do
		pcall(function()
			if v == "AlwaysOnTop" then h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			elseif v == "Occluded" then h.DepthMode = Enum.HighlightDepthMode.Occluded
			else h.DepthMode = Enum.HighlightDepthMode.Normal end
		end)
	end
end)

createSection(visualPage, "ESP Joueur")
createToggle(visualPage, "ESP Joueur", CONFIG.PLAYER_ESP_ENABLED, function(state)
	CONFIG.PLAYER_ESP_ENABLED = state
	if state then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then addPlayerVisuals(plr) end
		end
	else
		clearAllPlayerVisuals()
	end
end)
createToggle(visualPage, "Highlight Joueur", CONFIG.PLAYER_HIGHLIGHT_ENABLED, function(state)
	CONFIG.PLAYER_HIGHLIGHT_ENABLED = state
	if CONFIG.PLAYER_ESP_ENABLED then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then addPlayerVisuals(plr) end
		end
	end
end)
createToggle(visualPage, "Skeleton Joueur", CONFIG.PLAYER_SKELETON_ENABLED, function(state)
	CONFIG.PLAYER_SKELETON_ENABLED = state
	if not state then
		for plr in pairs(STATE.playerSkeletons) do
			removeSkeleton(plr)
		end
	end
end)
createToggle(visualPage, "Box Joueur", CONFIG.PLAYER_BOX_ENABLED, function(state)
	CONFIG.PLAYER_BOX_ENABLED = state
end)
createToggle(visualPage, "Name Joueur", CONFIG.PLAYER_NAME_ENABLED, function(state)
	CONFIG.PLAYER_NAME_ENABLED = state
end)
createToggle(visualPage, "Distance Joueur", CONFIG.PLAYER_DISTANCE_ENABLED, function(state)
	CONFIG.PLAYER_DISTANCE_ENABLED = state
end)
createToggle(visualPage, "Santé Joueur", CONFIG.PLAYER_HEALTH_ENABLED, function(state)
	CONFIG.PLAYER_HEALTH_ENABLED = state
end)
createToggle(visualPage, "Tracer Joueur", CONFIG.PLAYER_TRACER_ENABLED, function(state)
	CONFIG.PLAYER_TRACER_ENABLED = state
end)
createToggle(visualPage, "Rainbow Joueur", CONFIG.PLAYER_RAINBOW, function(state)
	CONFIG.PLAYER_RAINBOW = state
end)
createToggle(visualPage, "Team Check", CONFIG.PLAYER_TEAM_CHECK, function(state)
	CONFIG.PLAYER_TEAM_CHECK = state
end)
createSlider(visualPage, "Vitesse Rainbow Joueur", 0.05, 1.5, CONFIG.PLAYER_RAINBOW_SPEED, function(v)
	CONFIG.PLAYER_RAINBOW_SPEED = v
end)
createSlider(visualPage, "Épaisseur Skeleton", 1, 6, CONFIG.PLAYER_SKELETON_THICKNESS, function(v)
	CONFIG.PLAYER_SKELETON_THICKNESS = v
end)
createSlider(visualPage, "Épaisseur Tracer Joueur", 1, 6, CONFIG.PLAYER_TRACER_THICKNESS, function(v)
	CONFIG.PLAYER_TRACER_THICKNESS = v
	for _, line in pairs(STATE.playerTracers) do
		pcall(function() line.Thickness = v end)
	end
end)
createSlider(visualPage, "Distance Max Joueur", 100, 10000, CONFIG.PLAYER_MAX_DISTANCE, function(v)
	CONFIG.PLAYER_MAX_DISTANCE = v
end)
createSlider(visualPage, "Fill Joueur", 0, 1, CONFIG.PLAYER_FILL_TRANSPARENCY, function(v)
	CONFIG.PLAYER_FILL_TRANSPARENCY = v
	for _, h in pairs(STATE.playerHighlights) do
		pcall(function() h.FillTransparency = v end)
	end
end)
createSlider(visualPage, "Outline Joueur", 0, 1, CONFIG.PLAYER_OUTLINE_TRANSPARENCY, function(v)
	CONFIG.PLAYER_OUTLINE_TRANSPARENCY = v
	for _, h in pairs(STATE.playerHighlights) do
		pcall(function() h.OutlineTransparency = v end)
	end
end)

--------------------------------------------------
-- PAGE: TROLL
--------------------------------------------------

local trollPage = createPage("Troll")

local warnBanner = Instance.new("Frame")
warnBanner.Size = UDim2.new(1, 0, 0, 48)
warnBanner.BackgroundColor3 = CONFIG.BG_TERTIARY
warnBanner.BorderSizePixel = 0
warnBanner.ZIndex = 404
warnBanner.Parent = trollPage

local wc = Instance.new("UICorner")
wc.CornerRadius = UDim.new(0, 8)
wc.Parent = warnBanner

local wstroke = Instance.new("UIStroke")
wstroke.Thickness = 1
wstroke.Color = CONFIG.THEME
wstroke.Transparency = 0.4
wstroke.Parent = warnBanner

local wlbl = Instance.new("TextLabel")
wlbl.Size = UDim2.fromScale(1, 1)
wlbl.BackgroundTransparency = 1
wlbl.Font = Enum.Font.GothamBold
wlbl.TextSize = 12
wlbl.TextColor3 = CONFIG.TEXT_PRIMARY
wlbl.Text = "ATTENTION - CLIENT UNIQUEMENT"
wlbl.ZIndex = 405
wlbl.Parent = warnBanner

registerThemeUpdater(function()
	wstroke.Color = CONFIG.THEME
end)

createSection(trollPage, "Spawn Geode")
createToggle(trollPage, "Spawn au clic", CONFIG.SPAWN_GEODE_CLICK, function(state)
	CONFIG.SPAWN_GEODE_CLICK = state
end)
createToggle(trollPage, "Géodes Ancored", CONFIG.SPAWN_GEODE_ANCHORED, function(state)
	CONFIG.SPAWN_GEODE_ANCHORED = state
end)
createButton(trollPage, "Spawn 1 Geode au pied", function()
	spawnGeodeAtPlayer()
end)
createButton(trollPage, "Spawn 5 Geodes en cercle", function()
	for i = 1, 5 do
		task.spawn(function()
			task.wait(i * 0.1)
			spawnGeodeAtPlayer(i)
		end)
	end
end)
createSlider(trollPage, "Hauteur Spawn", 0, 15, CONFIG.SPAWN_GEODE_HEIGHT, function(v)
	CONFIG.SPAWN_GEODE_HEIGHT = v
end)
createSlider(trollPage, "Nombre par clic", 1, 10, CONFIG.SPAWN_GEODE_COUNT, function(v)
	CONFIG.SPAWN_GEODE_COUNT = math.floor(v)
end)

createSection(trollPage, "Actions Troll")
createButton(trollPage, "Kill All Players", function()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.Health = 0 end
		end
	end
	notify("Kill All execute", CONFIG.THEME)
end)
createButton(trollPage, "Freeze All Players", function()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			if hrp then hrp.Anchored = true end
		end
	end
	notify("Freeze All execute", CONFIG.THEME)
end)
createButton(trollPage, "Unfreeze All", function()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			if hrp then hrp.Anchored = false end
		end
	end
	notify("Unfreeze All execute", CONFIG.THEME)
end)
createButton(trollPage, "Fling All Players", function()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.Velocity = Vector3.new(math.random(-500,500), 500, math.random(-500,500))
			end
		end
	end
	notify("Fling All execute", CONFIG.THEME)
end)
createButton(trollPage, "Respawn Local Player", function()
	local char = LocalPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.Health = 0 end
	end
	notify("Respawn en cours", CONFIG.THEME)
end)

--------------------------------------------------
-- PAGE: PARAMÈTRES
--------------------------------------------------

local settingsPage = createPage("Paramètres")

createSection(settingsPage, "Apparence")
createTextInput(settingsPage, "Code Thème", CONFIG.THEME_HEX, "#3BE0AE",
	function(text)
		if isValidHex(text) then
			local col = hexToColor(text)
			if col then
				CONFIG.THEME = col
				CONFIG.THEME_HEX = text
				refreshTheme()
				notify("Thème: " .. text, CONFIG.THEME)
			else
				notify("Code hex invalide", CONFIG.TEXT_SECONDARY)
			end
		else
			notify("Code hex invalide", CONFIG.TEXT_SECONDARY)
		end
	end
)

createSlider(settingsPage, "Transparence UI", 0, 90, 0, function(v)
	local alpha = v / 100
	panel.BackgroundTransparency = alpha * 0.6
	sidebar.BackgroundTransparency = alpha * 0.6
	contentHeader.BackgroundTransparency = 0.4 + alpha * 0.4
end)

createSlider(settingsPage, "Taille UI", 70, 130, 100, function(v)
	CONFIG.UI_SCALE = v / 100
	local w = PANEL_W * CONFIG.UI_SCALE
	local h = PANEL_H * CONFIG.UI_SCALE
	panel.Size = UDim2.fromOffset(w, h)
end)

createSlider(settingsPage, "Épaisseur Bordure", 0, 5, 1.5, function(v)
	panelStroke.Thickness = v
end)

createToggle(settingsPage, "Blur arrière-plan", CONFIG.BLUR_ENABLED, function(state)
	CONFIG.BLUR_ENABLED = state
	if state and panel.Visible then
		TweenService:Create(blurEffect, TweenInfo.new(0.25), { Size = CONFIG.BLUR_INTENSITY }):Play()
	else
		TweenService:Create(blurEffect, TweenInfo.new(0.25), { Size = 0 }):Play()
	end
end)

createSlider(settingsPage, "Intensité Blur", 0, 30, CONFIG.BLUR_INTENSITY, function(v)
	CONFIG.BLUR_INTENSITY = v
	if CONFIG.BLUR_ENABLED and panel.Visible then
		blurEffect.Size = v
	end
end)

createToggle(settingsPage, "Notifications", CONFIG.NOTIFICATIONS_ENABLED, function(state)
	CONFIG.NOTIFICATIONS_ENABLED = state
end)

createSection(settingsPage, "Neige")
createToggle(settingsPage, "Neige en fond", CONFIG.SNOW_ENABLED, function(state)
	CONFIG.SNOW_ENABLED = state
	if state then startSnow() else stopSnow() end
end)
createSlider(settingsPage, "Quantité Neige", 10, 250, CONFIG.SNOW_COUNT, function(v)
	CONFIG.SNOW_COUNT = math.floor(v)
	if CONFIG.SNOW_ENABLED then
		stopSnow()
		startSnow()
	end
end)
createSlider(settingsPage, "Vitesse Neige", 0.2, 3, CONFIG.SNOW_SPEED, function(v)
	CONFIG.SNOW_SPEED = v
	-- Recalcule les vitesses
	for _, data in ipairs(STATE.snowflakes) do
		local sizeFactor = data.size / 6
		data.fallSpeed = math.random(40, 120) * sizeFactor * v
	end
end)

createSection(settingsPage, "Interface")
createDropdown(settingsPage, "Orientation", {"Horizontal", "Vertical"}, CONFIG.UI_ORIENTATION, function(v)
	CONFIG.UI_ORIENTATION = v
	if v == "Vertical" then
		sidebar.Size = UDim2.new(1, 0, 0, 68)
		contentFrame.Position = UDim2.new(0, 0, 0, 68)
		contentFrame.Size = UDim2.new(1, 0, 1, -68)
		navContainer.Size = UDim2.new(1, -20, 0, 46)
		navContainer.Position = UDim2.new(0, 10, 0, 11)
		navLayout.FillDirection = Enum.FillDirection.Horizontal
		navLayout.Padding = UDim.new(0, 6)
		logoFrame.Visible = false
		sep.Visible = false
		userFrame.Visible = false
	else
		sidebar.Size = UDim2.fromOffset(SIDEBAR_W, PANEL_H)
		contentFrame.Position = UDim2.new(0, SIDEBAR_W, 0, 0)
		contentFrame.Size = UDim2.new(1, -SIDEBAR_W, 1, 0)
		navContainer.Size = UDim2.new(1, -20, 1, -180)
		navContainer.Position = UDim2.new(0, 10, 0, 98)
		navLayout.FillDirection = Enum.FillDirection.Vertical
		navLayout.Padding = UDim.new(0, 4)
		logoFrame.Visible = true
		sep.Visible = true
		userFrame.Visible = true
	end
end)

createToggle(settingsPage, "Compteur FPS", false, function(state)
	local old = gui:FindFirstChild("FPSLabel")
	if old then old:Destroy() end
	if state then
		local fpsLbl = Instance.new("TextLabel")
		fpsLbl.Name = "FPSLabel"
		fpsLbl.Size = UDim2.fromOffset(80, 22)
		fpsLbl.Position = UDim2.new(0, 10, 1, -32)
		fpsLbl.BackgroundColor3 = CONFIG.BG_TERTIARY
		fpsLbl.BorderSizePixel = 0
		fpsLbl.Font = Enum.Font.GothamBold
		fpsLbl.TextSize = 11
		fpsLbl.TextColor3 = CONFIG.TEXT_PRIMARY
		fpsLbl.Text = "FPS: 60"
		fpsLbl.ZIndex = 400
		fpsLbl.Parent = gui

		local fCorner = Instance.new("UICorner")
		fCorner.CornerRadius = UDim.new(0, 6)
		fCorner.Parent = fpsLbl

		local frames = 0
		local lastTime = tick()
		local conn
		conn = RunService.RenderStepped:Connect(function()
			frames += 1
			local now = tick()
			if now - lastTime >= 1 then
				fpsLbl.Text = "FPS: " .. frames
				frames = 0
				lastTime = now
			end
		end)
		fpsLbl.Destroying:Connect(function() conn:Disconnect() end)
	end
end)

createSection(settingsPage, "Crédits")

local creditFrame = Instance.new("Frame")
creditFrame.Size = UDim2.new(1, 0, 0, 140)
creditFrame.BackgroundColor3 = CONFIG.BG_TERTIARY
creditFrame.BorderSizePixel = 0
creditFrame.ClipsDescendants = true
creditFrame.ZIndex = 404
creditFrame.Parent = settingsPage

local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(0, 10)
cc.Parent = creditFrame

local creditStroke = Instance.new("UIStroke")
creditStroke.Thickness = 1
creditStroke.Color = CONFIG.THEME
creditStroke.Transparency = 0.4
creditStroke.Parent = creditFrame

local creditFor = Instance.new("TextLabel")
creditFor.Size = UDim2.new(1, -20, 0, 16)
creditFor.Position = UDim2.new(0, 12, 0, 8)
creditFor.BackgroundTransparency = 1
creditFor.Font = Enum.Font.GothamBold
creditFor.TextSize = 10
creditFor.TextColor3 = CONFIG.THEME
creditFor.Text = "FOR"
creditFor.TextXAlignment = Enum.TextXAlignment.Left
creditFor.ZIndex = 405
creditFor.Parent = creditFrame

local gameIcon = Instance.new("ImageLabel")
gameIcon.Size = UDim2.new(1, -20, 0, 68)
gameIcon.Position = UDim2.new(0, 10, 0, 26)
gameIcon.BackgroundColor3 = CONFIG.BG_SECONDARY
gameIcon.BorderSizePixel = 0
gameIcon.Image = ""
gameIcon.ScaleType = Enum.ScaleType.Crop
gameIcon.ZIndex = 405
gameIcon.Parent = creditFrame

local gic = Instance.new("UICorner")
gic.CornerRadius = UDim.new(0, 8)
gic.Parent = gameIcon

pcall(function()
	local info = MarketplaceService:GetProductInfo(game.PlaceId)
	if info and info.IconImageAssetId and info.IconImageAssetId ~= 0 then
		gameIcon.Image = "rbxthumb://type=Asset&id=" .. info.IconImageAssetId .. "&w=420&h=420"
	end
end)

if gameIcon.Image == "" then
	local placeholder = Instance.new("TextLabel")
	placeholder.Size = UDim2.fromScale(1, 1)
	placeholder.BackgroundTransparency = 1
	placeholder.Font = Enum.Font.Gotham
	placeholder.TextSize = 11
	placeholder.TextColor3 = CONFIG.TEXT_SECONDARY
	placeholder.Text = "Reflex Script"
	placeholder.ZIndex = 406
	placeholder.Parent = gameIcon
end

local creditCreated = Instance.new("TextLabel")
creditCreated.Size = UDim2.new(1, -20, 0, 18)
creditCreated.Position = UDim2.new(0, 12, 1, -24)
creditCreated.BackgroundTransparency = 1
creditCreated.Font = Enum.Font.GothamBold
creditCreated.TextSize = 12
creditCreated.TextColor3 = CONFIG.TEXT_PRIMARY
creditCreated.Text = "Create by Reflex Script"
creditCreated.TextXAlignment = Enum.TextXAlignment.Left
creditCreated.ZIndex = 405
creditCreated.Parent = creditFrame

task.spawn(function()
	while creditCreated.Parent do
		task.wait(0.05)
		local hue = (tick() * 0.15) % 1
		creditCreated.TextColor3 = Color3.fromHSV(hue, 0.7, 1)
	end
end)

registerThemeUpdater(function()
	creditFor.TextColor3 = CONFIG.THEME
	creditStroke.Color = CONFIG.THEME
end)

--------------------------------------------------
-- NAVIGATION
--------------------------------------------------

local tabOrder = {
	{name = "Main", subtitle = "Déplacement et utilitaires"},
	{name = "Visual", subtitle = "ESP Geode et Joueur"},
	{name = "Troll", subtitle = "Actions troll"},
	{name = "Paramètres", subtitle = "Personnalisation"},
}

switchTab = function(tabName, subtitle)
	for name, page in pairs(STATE.pages) do
		page.Visible = (name == tabName)
	end
	for name, data in pairs(STATE.tabButtons) do
		local active = (name == tabName)
		TweenService:Create(data.bg, TweenInfo.new(0.2), {
			BackgroundColor3 = active and CONFIG.THEME:Lerp(CONFIG.BG_TERTIARY, 0.7) or CONFIG.BG_TERTIARY,
			BackgroundTransparency = active and 0 or 1
		}):Play()
		TweenService:Create(data.lbl, TweenInfo.new(0.15), {
			TextColor3 = active and CONFIG.TEXT_PRIMARY or CONFIG.TEXT_SECONDARY
		}):Play()
		TweenService:Create(data.bar, TweenInfo.new(0.2), {
			Size = active and UDim2.new(0, 3, 0.6, 0) or UDim2.new(0, 3, 0, 0)
		}):Play()
	end
	contentTitle.Text = tabName
	contentSub.Text = subtitle or ""
end

for i, tabInfo in ipairs(tabOrder) do
	local tabBtn = Instance.new("TextButton")
	tabBtn.Name = "Tab_" .. tabInfo.name
	tabBtn.Size = UDim2.new(1, 0, 0, 44)
	tabBtn.BackgroundTransparency = 1
	tabBtn.Text = ""
	tabBtn.BorderSizePixel = 0
	tabBtn.AutoButtonColor = false
	tabBtn.ZIndex = 404
	tabBtn.Parent = navContainer

	local bg = Instance.new("Frame")
	bg.Name = "BG"
	bg.Size = UDim2.fromScale(1, 1)
	bg.BackgroundColor3 = CONFIG.BG_TERTIARY
	bg.BackgroundTransparency = 1
	bg.BorderSizePixel = 0
	bg.ZIndex = 405
	bg.Parent = tabBtn

	local bgc = Instance.new("UICorner")
	bgc.CornerRadius = UDim.new(0, 8)
	bgc.Parent = bg

	local activeBar = Instance.new("Frame")
	activeBar.Name = "ActiveBar"
	activeBar.Size = UDim2.new(0, 3, 0, 0)
	activeBar.Position = UDim2.new(0, 0, 0.5, 0)
	activeBar.AnchorPoint = Vector2.new(0, 0.5)
	activeBar.BackgroundColor3 = CONFIG.THEME
	activeBar.BorderSizePixel = 0
	activeBar.ZIndex = 406
	activeBar.Parent = bg

	local abc = Instance.new("UICorner")
	abc.CornerRadius = UDim.new(1, 0)
	abc.Parent = activeBar

	local lbl = Instance.new("TextLabel")
	lbl.Name = "Label"
	lbl.Size = UDim2.new(1, -36, 1, 0)
	lbl.Position = UDim2.new(0, 20, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 12
	lbl.TextColor3 = CONFIG.TEXT_SECONDARY
	lbl.Text = tabInfo.name
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 407
	lbl.Parent = bg

	tabBtn.MouseButton1Click:Connect(function()
		switchTab(tabInfo.name, tabInfo.subtitle)
	end)

	STATE.tabButtons[tabInfo.name] = {
		bg = bg,
		lbl = lbl,
		bar = activeBar,
	}

	registerThemeUpdater(function()
		activeBar.BackgroundColor3 = CONFIG.THEME
		if STATE.pages[tabInfo.name] and STATE.pages[tabInfo.name].Visible then
			bg.BackgroundColor3 = CONFIG.THEME:Lerp(CONFIG.BG_TERTIARY, 0.7)
		end
	end)
end

switchTab("Main", "Déplacement et utilitaires")

--------------------------------------------------
-- DRAG HANDLES
--------------------------------------------------

makeDraggable(panel, contentHeader)
makeDraggable(panel, logoFrame)
makeDraggable(panel, logoIcon)
makeDraggable(panel, logoTitle)
makeDraggable(panel, logoSub)
makeDraggable(panel, sidebar)

--------------------------------------------------
-- FLY SYSTEM
--------------------------------------------------

local flyBodyVelocity, flyBodyGyro

startFly = function()
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	stopFly()
	flyBodyVelocity = Instance.new("BodyVelocity")
	flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	flyBodyVelocity.Velocity = Vector3.zero
	flyBodyVelocity.Parent = hrp
	flyBodyGyro = Instance.new("BodyGyro")
	flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	flyBodyGyro.P = 10000
	flyBodyGyro.CFrame = hrp.CFrame
	flyBodyGyro.Parent = hrp
end

stopFly = function()
	if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
	if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
end

RunService.RenderStepped:Connect(function()
	if not CONFIG.FLY_ENABLED or not flyBodyVelocity then return end
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local cam = Workspace.CurrentCamera

	local move = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end

	local horizontal = Vector3.new(move.X, 0, move.Z)
	if horizontal.Magnitude > 0 then
		horizontal = horizontal.Unit * CONFIG.FLY_SPEED
	end

	local vertical = 0
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical = CONFIG.FLY_VERTICAL_SPEED end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vertical = -CONFIG.FLY_VERTICAL_SPEED end

	flyBodyVelocity.Velocity = Vector3.new(horizontal.X, vertical, horizontal.Z)
	flyBodyGyro.CFrame = cam.CFrame
end)

--------------------------------------------------
-- NOCLIP
--------------------------------------------------

local noclipConnection = nil
local originalCollideStates = {}

startNoclip = function()
	if noclipConnection then return end
	noclipConnection = RunService.Stepped:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				if originalCollideStates[part] == nil then
					originalCollideStates[part] = true
				end
				part.CanCollide = false
			end
		end
	end)
end

stopNoclip = function()
	if noclipConnection then
		noclipConnection:Disconnect()
		noclipConnection = nil
	end
	local char = LocalPlayer.Character
	if char then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and originalCollideStates[part] ~= nil then
				part.CanCollide = originalCollideStates[part]
			end
		end
	end
	originalCollideStates = {}
end

--------------------------------------------------
-- INFINITE JUMP / MOVEMENT
--------------------------------------------------

UserInputService.JumpRequest:Connect(function()
	if CONFIG.INFINITE_JUMP then
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
		end
	end
end)

applyMovementSettings = function()
	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = CONFIG.WALK_SPEED
		hum.JumpPower = CONFIG.JUMP_POWER
		hum.UseJumpPower = true
		if CONFIG.HIP_HEIGHT_ENABLED then hum.HipHeight = CONFIG.HIP_HEIGHT end
	end
end

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1)
	applyMovementSettings()
	if CONFIG.NOCLIP_ENABLED then startNoclip() end
	if CONFIG.FLY_ENABLED then task.wait(0.5) startFly() end
end)

LocalPlayer.Idled:Connect(function()
	if CONFIG.ANTI_AFK then
		local vu = game:GetService("VirtualUser")
		vu:CaptureController()
		vu:ClickButton2(Vector2.new())
	end
end)

--------------------------------------------------
-- GEODE VISUALS
--------------------------------------------------

addGeodeVisuals = function(obj)
	if not CONFIG.GEODE_ESP_ENABLED then return end
	if not obj:IsA("BasePart") and not obj:IsA("Model") then return end
	if obj:FindFirstChild(CONFIG.HIGHLIGHT_NAME) then return end

	local h = Instance.new("Highlight")
	h.Name = CONFIG.HIGHLIGHT_NAME
	h.Adornee = obj
	if CONFIG.GEODE_DEPTH_MODE == "AlwaysOnTop" then
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	elseif CONFIG.GEODE_DEPTH_MODE == "Occluded" then
		h.DepthMode = Enum.HighlightDepthMode.Occluded
	else
		h.DepthMode = Enum.HighlightDepthMode.Normal
	end
	h.FillTransparency = CONFIG.GEODE_FILL_TRANSPARENCY
	h.OutlineTransparency = CONFIG.GEODE_OUTLINE_TRANSPARENCY
	h.Parent = obj

	STATE.geodes[obj] = h
end

removeGeodeVisuals = function(obj)
	local h = STATE.geodes[obj]
	if h then h:Destroy() end
	STATE.geodes[obj] = nil

	local l = STATE.geodeTracers[obj]
	if l then pcall(function() l:Remove() end) end
	STATE.geodeTracers[obj] = nil

	local b = STATE.geodeBoxes[obj]
	if b then pcall(function() b:Remove() end) end
	STATE.geodeBoxes[obj] = nil

	local n = STATE.geodeNames[obj]
	if n then pcall(function() n:Remove() end) end
	STATE.geodeNames[obj] = nil

	local d = STATE.geodeDistances[obj]
	if d then pcall(function() d:Remove() end) end
	STATE.geodeDistances[obj] = nil
end

clearAllGeodeVisuals = function()
	for obj in pairs(STATE.geodes) do
		removeGeodeVisuals(obj)
	end
	for obj in pairs(STATE.geodeTracers) do
		removeGeodeVisuals(obj)
	end
	STATE.geodes = {}
end

scanGeodes = function()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if isGeode(obj) then addGeodeVisuals(obj) end
	end
end

scanGeodes()

Workspace.DescendantAdded:Connect(function(obj)
	task.defer(function()
		if CONFIG.GEODE_ESP_ENABLED and isGeode(obj) then
			addGeodeVisuals(obj)
		end
	end)
end)

Workspace.DescendantRemoving:Connect(function(obj)
	if STATE.geodes[obj] then removeGeodeVisuals(obj) end
end)

--------------------------------------------------
-- PLAYER VISUALS
--------------------------------------------------

addPlayerVisuals = function(plr)
	if not CONFIG.PLAYER_ESP_ENABLED then return end
	if plr == LocalPlayer then return end
	if not plr.Character then return end
	if CONFIG.PLAYER_TEAM_CHECK and plr.Team == LocalPlayer.Team then return end

	if CONFIG.PLAYER_HIGHLIGHT_ENABLED and not STATE.playerHighlights[plr] then
		local h = Instance.new("Highlight")
		h.Name = "_ReflexPlayerHighlight"
		h.Adornee = plr.Character
		h.FillTransparency = CONFIG.PLAYER_FILL_TRANSPARENCY
		h.OutlineTransparency = CONFIG.PLAYER_OUTLINE_TRANSPARENCY
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.Parent = plr.Character
		STATE.playerHighlights[plr] = h
	end
end

removePlayerVisuals = function(plr)
	local h = STATE.playerHighlights[plr]
	if h then h:Destroy() end
	STATE.playerHighlights[plr] = nil

	local l = STATE.playerTracers[plr]
	if l then pcall(function() l:Remove() end) end
	STATE.playerTracers[plr] = nil

	local b = STATE.playerBoxes[plr]
	if b then pcall(function() b:Remove() end) end
	STATE.playerBoxes[plr] = nil

	local n = STATE.playerNames[plr]
	if n then pcall(function() n:Remove() end) end
	STATE.playerNames[plr] = nil

	local d = STATE.playerDistances[plr]
	if d then pcall(function() d:Remove() end) end
	STATE.playerDistances[plr] = nil

	local hp = STATE.playerHealths[plr]
	if hp then pcall(function() hp:Remove() end) end
	STATE.playerHealths[plr] = nil

	removeSkeleton(plr)
end

clearAllPlayerVisuals = function()
	local allPlrs = {}
	for plr in pairs(STATE.playerHighlights) do allPlrs[plr] = true end
	for plr in pairs(STATE.playerTracers) do allPlrs[plr] = true end
	for plr in pairs(STATE.playerSkeletons) do allPlrs[plr] = true end
	for plr in pairs(allPlrs) do
		removePlayerVisuals(plr)
	end
	STATE.playerHighlights = {}
end

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(0.5)
		if CONFIG.PLAYER_ESP_ENABLED then addPlayerVisuals(plr) end
	end)
end)

Players.PlayerRemoving:Connect(function(plr)
	removePlayerVisuals(plr)
end)

for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= LocalPlayer then
		plr.CharacterAdded:Connect(function()
			task.wait(0.5)
			if CONFIG.PLAYER_ESP_ENABLED then addPlayerVisuals(plr) end
		end)
	end
end

--------------------------------------------------
-- SKELETON ESP
--------------------------------------------------

local SKELETON_BONES = {
	{"Head", "UpperTorso"},
	{"UpperTorso", "LowerTorso"},
	{"UpperTorso", "LeftUpperArm"},
	{"LeftUpperArm", "LeftLowerArm"},
	{"LeftLowerArm", "LeftHand"},
	{"UpperTorso", "RightUpperArm"},
	{"RightUpperArm", "RightLowerArm"},
	{"RightLowerArm", "RightHand"},
	{"LowerTorso", "LeftUpperLeg"},
	{"LeftUpperLeg", "LeftLowerLeg"},
	{"LeftLowerLeg", "LeftFoot"},
	{"LowerTorso", "RightUpperLeg"},
	{"RightUpperLeg", "RightLowerLeg"},
	{"RightLowerLeg", "RightFoot"},
}

createSkeletonForPlayer = function(plr)
	if STATE.playerSkeletons[plr] then return end
	if not Drawing then return end
	local lines = {}
	for i = 1, #SKELETON_BONES do
		local line = Drawing.new("Line")
		line.Thickness = CONFIG.PLAYER_SKELETON_THICKNESS
		line.Transparency = 1
		line.Visible = false
		table.insert(lines, line)
	end
	STATE.playerSkeletons[plr] = lines
end

removeSkeleton = function(plr)
	local lines = STATE.playerSkeletons[plr]
	if lines then
		for _, line in ipairs(lines) do
			pcall(function() line:Remove() end)
		end
		STATE.playerSkeletons[plr] = nil
	end
end

updateSkeletonForPlayer = function(plr, color)
	local lines = STATE.playerSkeletons[plr]
	if not lines then return end
	local char = plr.Character
	if not char then
		for _, line in ipairs(lines) do line.Visible = false end
		return
	end

	for i, bone in ipairs(SKELETON_BONES) do
		local part1 = char:FindFirstChild(bone[1])
		local part2 = char:FindFirstChild(bone[2])
		local line = lines[i]
		if not line then continue end

		if part1 and part2 then
			local sp1, on1 = Camera:WorldToViewportPoint(part1.Position)
			local sp2, on2 = Camera:WorldToViewportPoint(part2.Position)
			if on1 and on2 then
				line.From = Vector2.new(sp1.X, sp1.Y)
				line.To = Vector2.new(sp2.X, sp2.Y)
				line.Color = color
				line.Thickness = CONFIG.PLAYER_SKELETON_THICKNESS
				line.Visible = true
			else
				line.Visible = false
			end
		else
			line.Visible = false
		end
	end
end

--------------------------------------------------
-- COLLECTE / TP
--------------------------------------------------

local function isGeodeStillVisible(geodeObj)
	return geodeObj ~= nil and geodeObj.Parent ~= nil and STATE.geodes[geodeObj] ~= nil
end

local function collectByRotation(geodeObj)
	if STATE.collecting then return end
	if not geodeObj or not geodeObj.Parent then return end

	STATE.collecting = true
	headerStatus.Text = "Collecte"
	headerStatus.TextColor3 = CONFIG.THEME

	local function cleanup()
		STATE.collecting = false
		headerStatus.Text = "Ready"
		headerStatus.TextColor3 = CONFIG.THEME
	end

	local char = LocalPlayer.Character
	if not char then cleanup() return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then cleanup() return end

	local targetPart = getTargetPart(geodeObj)
	if not targetPart then cleanup() return end

	local basePos = targetPart.Position
	local standPos = basePos + Vector3.new(0, CONFIG.COLLECT_HEIGHT, 0)

	if not CONFIG.NOCLIP_ENABLED then startNoclip() end

	hrp.CFrame = CFrame.new(standPos, Vector3.new(basePos.X, standPos.Y, basePos.Z))
	task.wait(0.15)

	local startTime = tick()
	local angle = 0

	while isGeodeStillVisible(geodeObj) and (tick() - startTime) < CONFIG.COLLECT_TIMEOUT do
		local curHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not curHrp then break end

		local curTarget = getTargetPart(geodeObj)
		if not curTarget then break end

		local delta = CONFIG.COLLECT_ROTATION_SPEED * 0.03
		angle = angle + delta

		local offset = Vector3.new(
			math.cos(angle) * CONFIG.COLLECT_RADIUS,
			CONFIG.COLLECT_HEIGHT,
			math.sin(angle) * CONFIG.COLLECT_RADIUS
		)
		local newPos = curTarget.Position + offset
		curHrp.CFrame = CFrame.new(newPos, Vector3.new(curTarget.Position.X, newPos.Y, curTarget.Position.Z))

		RunService.RenderStepped:Wait()
	end

	cleanup()
end

--------------------------------------------------
-- TP TO NEAREST / TP ALL
--------------------------------------------------

tpToNearestGeode = function()
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		notify("Pas de personnage", CONFIG.TEXT_SECONDARY)
		return
	end

	local nearest, nearestDist
	for obj in pairs(STATE.geodes) do
		if obj and obj.Parent then
			local tp = getTargetPart(obj)
			if tp then
				local dist = (tp.Position - hrp.Position).Magnitude
				if not nearestDist or dist < nearestDist then
					nearestDist = dist
					nearest = obj
				end
			end
		end
	end

	if not nearest then
		notify("Aucune géode trouvée", CONFIG.TEXT_SECONDARY)
		return
	end

	local targetPart = getTargetPart(nearest)
	if not targetPart then return end

	if not CONFIG.NOCLIP_ENABLED then
		CONFIG.NOCLIP_ENABLED = true
		startNoclip()
	end

	local basePos = targetPart.Position
	local standPos = basePos + Vector3.new(0, CONFIG.COLLECT_HEIGHT, 0)
	hrp.CFrame = CFrame.new(standPos, Vector3.new(basePos.X, standPos.Y, basePos.Z))

	notify(string.format("TP Nearest (%.0f studs)", nearestDist), CONFIG.THEME)

	if CONFIG.AUTO_COLLECT_ENABLED then
		task.spawn(function()
			collectByRotation(nearest)
		end)
	end
end

local function runTpQueue()
	if STATE.tpActive then return end
	STATE.tpActive = true

	headerStatus.Text = "TP en cours"
	headerStatus.TextColor3 = CONFIG.THEME

	for i = 1, #STATE.tpQueue do
		local obj = STATE.tpQueue[i]
		if not obj or not obj.Parent then continue end

		local targetPart = getTargetPart(obj)
		if not targetPart then continue end

		local char = LocalPlayer.Character
		if not char then break end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then break end

		if not CONFIG.NOCLIP_ENABLED then startNoclip() end

		local basePos = targetPart.Position
		local standPos = basePos + Vector3.new(0, CONFIG.COLLECT_HEIGHT, 0)
		hrp.CFrame = CFrame.new(standPos, Vector3.new(basePos.X, standPos.Y, basePos.Z))

		task.wait(0.2)

		if CONFIG.AUTO_COLLECT_ENABLED then
			collectByRotation(obj)
		else
			task.wait(CONFIG.AUTO_TP_DELAY)
		end
	end

	STATE.tpQueue = {}
	STATE.tpActive = false
	headerStatus.Text = "Ready"
	headerStatus.TextColor3 = CONFIG.THEME
	notify("TP ALL terminé", CONFIG.THEME)
end

tpAllGeodes = function()
	if STATE.tpActive then return end
	STATE.tpQueue = {}

	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local origin = hrp and hrp.Position or Vector3.zero

	local tempList = {}
	for obj in pairs(STATE.geodes) do
		local tp = getTargetPart(obj)
		if tp then
			table.insert(tempList, {
				obj = obj,
				dist = (tp.Position - origin).Magnitude
			})
		end
	end

	table.sort(tempList, function(a, b) return a.dist < b.dist end)
	for _, e in ipairs(tempList) do
		table.insert(STATE.tpQueue, e.obj)
	end

	if #STATE.tpQueue == 0 then
		notify("Aucune géode trouvée", CONFIG.TEXT_SECONDARY)
		return
	end

	notify("TP ALL: " .. #STATE.tpQueue .. " géodes", CONFIG.THEME)
	task.spawn(runTpQueue)
end

task.spawn(function()
	while true do
		task.wait(CONFIG.AUTO_TP_LOOP_DELAY)
		if CONFIG.AUTO_TP_ENABLED and not STATE.tpActive then
			tpAllGeodes()
		end
	end
end)

--------------------------------------------------
-- SPAWN GEODE
--------------------------------------------------

spawnGeodeAtPlayer = function(offsetIndex)
	offsetIndex = offsetIndex or 0

	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local template
	for obj in pairs(STATE.geodes) do
		if obj and obj.Parent then
			template = obj
			break
		end
	end

	if not template then
		local part = Instance.new("Part")
		part.Name = "Geode_Spawned"
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.new(4, 4, 4)
		part.Material = Enum.Material.Neon
		part.Color = CONFIG.THEME
		part.Anchored = CONFIG.SPAWN_GEODE_ANCHORED
		part.CanCollide = false
		part.CFrame = hrp.CFrame * CFrame.new(0, -CONFIG.SPAWN_GEODE_HEIGHT, -5)
		part.Parent = Workspace
		return
	end

	for i = 1, CONFIG.SPAWN_GEODE_COUNT do
		local ok, clone = pcall(function() return template:Clone() end)
		if not ok or not clone then continue end

		clone.Name = "Geode_Spawned_" .. tostring(math.random(1, 999999))

		local angle = (offsetIndex + i - 1) * (math.pi / 2.5)
		local radius = 5
		local offsetX = math.cos(angle) * radius
		local offsetZ = math.sin(angle) * radius

		local spawnPos = hrp.CFrame * CFrame.new(offsetX, -CONFIG.SPAWN_GEODE_HEIGHT, offsetZ)

		if clone:IsA("BasePart") then
			clone.Anchored = CONFIG.SPAWN_GEODE_ANCHORED
			clone.CanCollide = false
			clone.CFrame = spawnPos
		elseif clone:IsA("Model") then
			clone:PivotTo(spawnPos)
		end

		clone.Parent = Workspace

		task.wait(0.05)
		if CONFIG.GEODE_ESP_ENABLED then addGeodeVisuals(clone) end
	end
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if not CONFIG.SPAWN_GEODE_CLICK then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

	local mouseLoc = UserInputService:GetMouseLocation()
	local guiObjs = PlayerGui:GetGuiObjectsAtPosition(mouseLoc.X, mouseLoc.Y)
	for _, obj in ipairs(guiObjs) do
		if obj:IsDescendantOf(gui) then return end
	end

	spawnGeodeAtPlayer()
end)

--------------------------------------------------
-- OPEN / CLOSE
--------------------------------------------------

local function openPanel()
	if STATE.open then return end
	STATE.open = true
	panel.Visible = true
	toggleText.Text = "X"

	local viewportSize = Camera.ViewportSize
	local w = PANEL_W * CONFIG.UI_SCALE
	local h = PANEL_H * CONFIG.UI_SCALE
	local cx = (viewportSize.X - w) / 2
	local cy = (viewportSize.Y - h) / 2

	panel.Size = UDim2.fromOffset(w * 0.94, h * 0.94)
	panel.Position = UDim2.new(0, cx + w * 0.03, 0, cy + h * 0.03)

	TweenService:Create(panel, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(w, h),
		Position = UDim2.new(0, cx, 0, cy)
	}):Play()

	if CONFIG.BLUR_ENABLED then
		TweenService:Create(blurEffect, TweenInfo.new(0.25), { Size = CONFIG.BLUR_INTENSITY }):Play()
	end
end

local function closePanel()
	if not STATE.open then return end
	STATE.open = false
	panel.Visible = false
	toggleText.Text = "R"
	if CONFIG.BLUR_ENABLED then
		TweenService:Create(blurEffect, TweenInfo.new(0.25), { Size = 0 }):Play()
	end
end

toggleButton.MouseButton1Click:Connect(function()
	if STATE.open then closePanel() else openPanel() end
end)

closeBtn.MouseButton1Click:Connect(closePanel)

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		if STATE.open then closePanel() else openPanel() end
	end
end)

--------------------------------------------------
-- RENDER LOOP: GEODE
--------------------------------------------------

local geodeRainbowTime = 0

RunService.RenderStepped:Connect(function(delta)
	if not CONFIG.GEODE_ESP_ENABLED then return end

	geodeRainbowTime += delta
	local rainbow
	if CONFIG.GEODE_RAINBOW then
		rainbow = Color3.fromHSV((geodeRainbowTime * CONFIG.GEODE_RAINBOW_SPEED) % 1, 0.85, 1)
	else
		rainbow = CONFIG.THEME
	end

	for obj, h in pairs(STATE.geodes) do
		if not obj.Parent or not h.Parent then
			removeGeodeVisuals(obj)
			continue
		end
		h.FillColor = rainbow
		h.OutlineColor = rainbow
	end

	if not Drawing then return end

	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local playerPos = hrp and hrp.Position

	local startPos = Vector2.new(
		toggleButton.AbsolutePosition.X + toggleButton.AbsoluteSize.X / 2,
		toggleButton.AbsolutePosition.Y + toggleButton.AbsoluteSize.Y / 2
	)

	for obj in pairs(STATE.geodes) do
		if not obj.Parent then
			removeGeodeVisuals(obj)
			continue
		end

		local targetPart = getTargetPart(obj)
		if not targetPart then continue end

		local sp, onScreen = Camera:WorldToViewportPoint(targetPart.Position)

		local tooFar = false
		if playerPos then
			local d = (targetPart.Position - playerPos).Magnitude
			if d > CONFIG.GEODE_MAX_DISTANCE then tooFar = true end
		end

		-- Tracer
		if CONFIG.GEODE_TRACER_ENABLED then
			local line = STATE.geodeTracers[obj]
			if not line then
				line = Drawing.new("Line")
				line.Thickness = CONFIG.GEODE_TRACER_THICKNESS
				line.Transparency = 0.5
				STATE.geodeTracers[obj] = line
			end
			if onScreen and not tooFar then
				line.From = startPos
				line.To = Vector2.new(sp.X, sp.Y)
				line.Color = rainbow
				line.Thickness = CONFIG.GEODE_TRACER_THICKNESS
				line.Visible = true
			else
				line.Visible = false
			end
		elseif STATE.geodeTracers[obj] then
			STATE.geodeTracers[obj].Visible = false
		end

		-- Box
		if CONFIG.GEODE_BOX_ENABLED and onScreen and not tooFar then
			local box = STATE.geodeBoxes[obj]
			if not box then
				box = Drawing.new("Square")
				box.Thickness = 1
				box.Filled = false
				box.Transparency = 0.8
				STATE.geodeBoxes[obj] = box
			end

			local cf, size
			if obj:IsA("BasePart") then
				cf = obj.CFrame size = obj.Size
			elseif obj:IsA("Model") then
				local ok, mcf, msize = pcall(function() return obj:GetBoundingBox() end)
				if ok then cf = mcf size = msize end
			end

			if cf and size then
				local corners = {
					cf * Vector3.new(size.X/2, size.Y/2, size.Z/2),
					cf * Vector3.new(-size.X/2, size.Y/2, size.Z/2),
					cf * Vector3.new(size.X/2, -size.Y/2, size.Z/2),
					cf * Vector3.new(-size.X/2, -size.Y/2, size.Z/2),
					cf * Vector3.new(size.X/2, size.Y/2, -size.Z/2),
					cf * Vector3.new(-size.X/2, size.Y/2, -size.Z/2),
					cf * Vector3.new(size.X/2, -size.Y/2, -size.Z/2),
					cf * Vector3.new(-size.X/2, -size.Y/2, -size.Z/2),
				}
				local minX, minY = math.huge, math.huge
				local maxX, maxY = -math.huge, -math.huge
				local any = false
				for _, c in ipairs(corners) do
					local csp, cos = Camera:WorldToViewportPoint(c)
					if cos then
						any = true
						minX = math.min(minX, csp.X)
						minY = math.min(minY, csp.Y)
						maxX = math.max(maxX, csp.X)
						maxY = math.max(maxY, csp.Y)
					end
				end
				if any then
					box.Size = Vector2.new(maxX - minX, maxY - minY)
					box.Position = Vector2.new(minX, minY)
					box.Color = rainbow
					box.Visible = true
				else
					box.Visible = false
				end
			end
		elseif STATE.geodeBoxes[obj] then
			STATE.geodeBoxes[obj].Visible = false
		end

		-- Name
		if CONFIG.GEODE_NAME_ENABLED and onScreen and not tooFar then
			local nt = STATE.geodeNames[obj]
			if not nt then
				nt = Drawing.new("Text")
				nt.Size = 14
				nt.Center = true
				nt.Outline = true
				nt.OutlineColor = Color3.new(0, 0, 0)
				STATE.geodeNames[obj] = nt
			end
			nt.Position = Vector2.new(sp.X, sp.Y - 22)
			nt.Text = obj.Name
			nt.Color = rainbow
			nt.Visible = true
		elseif STATE.geodeNames[obj] then
			STATE.geodeNames[obj].Visible = false
		end

		-- Distance
		if CONFIG.GEODE_DISTANCE_ENABLED and onScreen and playerPos and not tooFar then
			local dt = STATE.geodeDistances[obj]
			if not dt then
				dt = Drawing.new("Text")
				dt.Size = 12
				dt.Center = true
				dt.Outline = true
				dt.OutlineColor = Color3.new(0, 0, 0)
				STATE.geodeDistances[obj] = dt
			end
			local d = (targetPart.Position - playerPos).Magnitude
			dt.Position = Vector2.new(sp.X, sp.Y + 6)
			dt.Text = string.format("[%d]", math.floor(d))
			dt.Color = rainbow
			dt.Visible = true
		elseif STATE.geodeDistances[obj] then
			STATE.geodeDistances[obj].Visible = false
		end
	end
end)

--------------------------------------------------
-- RENDER LOOP: PLAYER
--------------------------------------------------

local playerRainbowTime = 0

RunService.RenderStepped:Connect(function(delta)
	if not CONFIG.PLAYER_ESP_ENABLED then return end

	playerRainbowTime += delta
	local rainbow
	if CONFIG.PLAYER_RAINBOW then
		rainbow = Color3.fromHSV((playerRainbowTime * CONFIG.PLAYER_RAINBOW_SPEED) % 1, 0.85, 1)
	else
		rainbow = CONFIG.THEME
	end

	-- Mise à jour des Highlights
	if CONFIG.PLAYER_HIGHLIGHT_ENABLED then
		for plr, h in pairs(STATE.playerHighlights) do
			if not plr.Character or not h.Parent then
				if h then h:Destroy() end
				STATE.playerHighlights[plr] = nil
				continue
			end
			if h.Adornee ~= plr.Character then
				h.Adornee = plr.Character
			end
			h.FillColor = rainbow
			h.OutlineColor = rainbow
		end

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				if CONFIG.PLAYER_TEAM_CHECK and plr.Team == LocalPlayer.Team then continue end
				if not STATE.playerHighlights[plr] then
					addPlayerVisuals(plr)
				end
			end
		end
	end

	if not Drawing then return end

	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local playerPos = hrp and hrp.Position

	local startPos = Vector2.new(
		toggleButton.AbsolutePosition.X + toggleButton.AbsoluteSize.X / 2,
		toggleButton.AbsolutePosition.Y + toggleButton.AbsoluteSize.Y / 2
	)

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == LocalPlayer then continue end

		-- Team check
		if CONFIG.PLAYER_TEAM_CHECK and plr.Team == LocalPlayer.Team then
			if STATE.playerTracers[plr] then STATE.playerTracers[plr].Visible = false end
			if STATE.playerBoxes[plr] then STATE.playerBoxes[plr].Visible = false end
			if STATE.playerNames[plr] then STATE.playerNames[plr].Visible = false end
			if STATE.playerDistances[plr] then STATE.playerDistances[plr].Visible = false end
			if STATE.playerHealths[plr] then STATE.playerHealths[plr].Visible = false end
			if STATE.playerSkeletons[plr] then
				for _, line in ipairs(STATE.playerSkeletons[plr]) do
					line.Visible = false
				end
			end
			continue
		end

		local char = plr.Character
		if not char then
			if STATE.playerTracers[plr] then STATE.playerTracers[plr].Visible = false end
			if STATE.playerBoxes[plr] then STATE.playerBoxes[plr].Visible = false end
			if STATE.playerNames[plr] then STATE.playerNames[plr].Visible = false end
			if STATE.playerDistances[plr] then STATE.playerDistances[plr].Visible = false end
			if STATE.playerHealths[plr] then STATE.playerHealths[plr].Visible = false end
			if STATE.playerSkeletons[plr] then
				for _, line in ipairs(STATE.playerSkeletons[plr]) do
					line.Visible = false
				end
			end
			continue
		end

		local pHrp = char:FindFirstChild("HumanoidRootPart")
		if not pHrp then continue end

		local sp, onScreen = Camera:WorldToViewportPoint(pHrp.Position)

		local tooFar = false
		if playerPos then
			local d = (pHrp.Position - playerPos).Magnitude
			if d > CONFIG.PLAYER_MAX_DISTANCE then tooFar = true end
		end

		if tooFar then
			if STATE.playerTracers[plr] then STATE.playerTracers[plr].Visible = false end
			if STATE.playerBoxes[plr] then STATE.playerBoxes[plr].Visible = false end
			if STATE.playerNames[plr] then STATE.playerNames[plr].Visible = false end
			if STATE.playerDistances[plr] then STATE.playerDistances[plr].Visible = false end
			if STATE.playerHealths[plr] then STATE.playerHealths[plr].Visible = false end
			if STATE.playerSkeletons[plr] then
				for _, line in ipairs(STATE.playerSkeletons[plr]) do
					line.Visible = false
				end
			end
			continue
		end

		-- Tracer
		if CONFIG.PLAYER_TRACER_ENABLED then
			local line = STATE.playerTracers[plr]
			if not line then
				line = Drawing.new("Line")
				line.Thickness = CONFIG.PLAYER_TRACER_THICKNESS
				line.Transparency = 0.5
				STATE.playerTracers[plr] = line
			end
			if onScreen then
				line.From = startPos
				line.To = Vector2.new(sp.X, sp.Y)
				line.Color = rainbow
				line.Thickness = CONFIG.PLAYER_TRACER_THICKNESS
				line.Visible = true
			else
				line.Visible = false
			end
		elseif STATE.playerTracers[plr] then
			STATE.playerTracers[plr].Visible = false
		end

		-- Box
		if CONFIG.PLAYER_BOX_ENABLED and onScreen then
			local box = STATE.playerBoxes[plr]
			if not box then
				box = Drawing.new("Square")
				box.Thickness = 1
				box.Filled = false
				box.Transparency = 0.8
				STATE.playerBoxes[plr] = box
			end

			local ok, mcf, msize = pcall(function() return char:GetBoundingBox() end)
			if ok and mcf and msize then
				local corners = {
					mcf * Vector3.new(msize.X/2, msize.Y/2, msize.Z/2),
					mcf * Vector3.new(-msize.X/2, msize.Y/2, msize.Z/2),
					mcf * Vector3.new(msize.X/2, -msize.Y/2, msize.Z/2),
					mcf * Vector3.new(-msize.X/2, -msize.Y/2, msize.Z/2),
					mcf * Vector3.new(msize.X/2, msize.Y/2, -msize.Z/2),
					mcf * Vector3.new(-msize.X/2, msize.Y/2, -msize.Z/2),
					mcf * Vector3.new(msize.X/2, -msize.Y/2, -msize.Z/2),
					mcf * Vector3.new(-msize.X/2, -msize.Y/2, -msize.Z/2),
				}
				local minX, minY = math.huge, math.huge
				local maxX, maxY = -math.huge, -math.huge
				local any = false
				for _, c in ipairs(corners) do
					local csp, cos = Camera:WorldToViewportPoint(c)
					if cos then
						any = true
						minX = math.min(minX, csp.X)
						minY = math.min(minY, csp.Y)
						maxX = math.max(maxX, csp.X)
						maxY = math.max(maxY, csp.Y)
					end
				end
				if any then
					box.Size = Vector2.new(maxX - minX, maxY - minY)
					box.Position = Vector2.new(minX, minY)
					box.Color = rainbow
					box.Visible = true
				else
					box.Visible = false
				end
			end
		elseif STATE.playerBoxes[plr] then
			STATE.playerBoxes[plr].Visible = false
		end

		-- Name
		if CONFIG.PLAYER_NAME_ENABLED and onScreen then
			local nt = STATE.playerNames[plr]
			if not nt then
				nt = Drawing.new("Text")
				nt.Size = 14
				nt.Center = true
				nt.Outline = true
				nt.OutlineColor = Color3.new(0, 0, 0)
				STATE.playerNames[plr] = nt
			end
			nt.Position = Vector2.new(sp.X, sp.Y - 32)
			nt.Text = plr.Name
			nt.Color = rainbow
			nt.Visible = true
		elseif STATE.playerNames[plr] then
			STATE.playerNames[plr].Visible = false
		end

		-- Distance
		if CONFIG.PLAYER_DISTANCE_ENABLED and onScreen and playerPos then
			local dt = STATE.playerDistances[plr]
			if not dt then
				dt = Drawing.new("Text")
				dt.Size = 12
				dt.Center = true
				dt.Outline = true
				dt.OutlineColor = Color3.new(0, 0, 0)
				STATE.playerDistances[plr] = dt
			end
			local d = (pHrp.Position - playerPos).Magnitude
			dt.Position = Vector2.new(sp.X, sp.Y + 6)
			dt.Text = string.format("[%d]", math.floor(d))
			dt.Color = rainbow
			dt.Visible = true
		elseif STATE.playerDistances[plr] then
			STATE.playerDistances[plr].Visible = false
		end

		-- Health
		if CONFIG.PLAYER_HEALTH_ENABLED and onScreen then
			local hl = STATE.playerHealths[plr]
			if not hl then
				hl = Drawing.new("Text")
				hl.Size = 12
				hl.Center = true
				hl.Outline = true
				hl.OutlineColor = Color3.new(0, 0, 0)
				STATE.playerHealths[plr] = hl
			end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hl.Position = Vector2.new(sp.X, sp.Y + 22)
				hl.Text = string.format("%d HP", math.floor(hum.Health))
				local hpRatio = hum.Health / math.max(hum.MaxHealth, 1)
				hl.Color = Color3.fromRGB(
					math.floor(255 * (1 - hpRatio)),
					math.floor(255 * hpRatio),
					80
				)
				hl.Visible = true
			else
				hl.Visible = false
			end
		elseif STATE.playerHealths[plr] then
			STATE.playerHealths[plr].Visible = false
		end

		-- Skeleton
		if CONFIG.PLAYER_SKELETON_ENABLED and onScreen then
			if not STATE.playerSkeletons[plr] then
				createSkeletonForPlayer(plr)
			end
			updateSkeletonForPlayer(plr, rainbow)
		elseif STATE.playerSkeletons[plr] then
			for _, line in ipairs(STATE.playerSkeletons[plr]) do
				line.Visible = false
			end
		end
	end
end)

--------------------------------------------------
-- CLEANUP
--------------------------------------------------

gui.Destroying:Connect(function()
	if noclipConnection then noclipConnection:Disconnect() end
	stopFly()
	stopSnow()
	for _, l in pairs(STATE.geodeTracers) do pcall(function() l:Remove() end) end
	for _, b in pairs(STATE.geodeBoxes) do pcall(function() b:Remove() end) end
	for _, t in pairs(STATE.geodeNames) do pcall(function() t:Remove() end) end
	for _, t in pairs(STATE.geodeDistances) do pcall(function() t:Remove() end) end
	for _, l in pairs(STATE.playerTracers) do pcall(function() l:Remove() end) end
	for _, b in pairs(STATE.playerBoxes) do pcall(function() b:Remove() end) end
	for _, t in pairs(STATE.playerNames) do pcall(function() t:Remove() end) end
	for _, t in pairs(STATE.playerDistances) do pcall(function() t:Remove() end) end
	for _, t in pairs(STATE.playerHealths) do pcall(function() t:Remove() end) end
	for _, lines in pairs(STATE.playerSkeletons) do
		for _, line in ipairs(lines) do pcall(function() line:Remove() end) end
	end
end)

--------------------------------------------------
-- INIT
--------------------------------------------------

print("========================================")
print("   REFLEX SCRIPT v5.0 — Loaded")
print("   Theme: " .. CONFIG.THEME_HEX)
print("   RightShift pour toggle le menu")
print("========================================")