--// Blocky Chams + Name ESP + Crosshair Camera Lock + UI

--// LocalScript inside StarterPlayerScripts

local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local UserInputService = game:GetService("UserInputService")

local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local Camera = workspace.CurrentCamera

--// ESP Settings

local ESP_ENABLED = true
local CHAMS_ENABLED = true
local NAME_ESP_ENABLED = true
getgenv().WeakESPStyle = getgenv().WeakESPStyle or "Chams" -- Chams / Box / Corner Box

local VISIBLE_COLOR = Color3.fromRGB(255, 255, 255)

local CHAM_TRANSPARENCY = 0.45

local CHAM_SIZE = Vector3.new(0.15, 0.15, 0.15)

local NAME_SIZE = 11

local NAME_FONT = Enum.Font.GothamMedium

local CHAM_COLOR_VISIBLE = true

--// Aim Assist Settings

local LOCK_KEY = Enum.KeyCode.Q

local LOCK_ENABLED = false
getgenv().GohthAimlockEnabled = false

local TARGET = nil

local LOCK_FOV = 250

local SHOW_FOV = true

local LOCK_PART = "Head"

local LOCK_VISIBLE_CHECK = false

local LOCK_TEAM_CHECK = false

--// Triggerbot Settings
local TRIGGERBOT_ENABLED = false
local TRIGGERBOT_INTERVAL = 0.08
local TRIGGERBOT_ONSCREEN_ONLY = true
local triggerbotLastShot = 0

--// Aim Assist Smoothness Settings

local SMOOTHNESS_ENABLED = true

-- Kept as existing locals so the rest of the script stays register-friendly.
-- SMOOTHNESS_VALUE is now the main/far tracking speed.
local SMOOTHNESS_VALUE = 10
local SMOOTHNESS_TYPE = "Balanced"
local SMOOTH_DAMP_SPEED = 4

local SMOOTHNESS_MIN = 1
local SMOOTHNESS_MAX = 30

local DAMP_SPEED_MIN = 0.5
local DAMP_SPEED_MAX = 15

-- Extra settings live in one getgenv table to avoid adding a pile of top-level locals.
getgenv().GohthAimSmooth = getgenv().GohthAimSmooth or {
    Dynamic = true,
    Micro = true,
    NearSpeed = 4,
    Curve = 1.0,
}

--// FOV Circle

local fovCircle = nil

local FOV_MIN = 25

local FOV_MAX = 500

local FOV_COLOR = Color3.fromRGB(240, 103, 156)

local FOV_TRANSPARENCY = 0.92

local FOV_THICKNESS = 2

local FOV_CIRCLE_ENABLED = true

--// Target Line
getgenv().GohthTargetLineEnabled = getgenv().GohthTargetLineEnabled or false
getgenv().GohthTargetLineThickness = getgenv().GohthTargetLineThickness or 2
getgenv().GohthTargetLineColor = getgenv().GohthTargetLineColor or FOV_COLOR

--// UI Visibility Control

local UI_VISIBLE = false

local UI_OPACITY = 1

--// Font Settings

local FONT = Enum.Font.SourceSans

local UI_FONT_SIZE = 14

local UI


--// Create Notification Function

local function createNotification()
    task.spawn(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        local old = playerGui:FindFirstChild("NotificationGui")
        if old then old:Destroy() end

        local notificationGui = Instance.new("ScreenGui")
        notificationGui.Name = "NotificationGui"
        notificationGui.ResetOnSpawn = false
        notificationGui.IgnoreGuiInset = true
        notificationGui.DisplayOrder = 999
        notificationGui.Parent = playerGui

        local theme = getgenv().Library and getgenv().Library.Theme
        local accent = (theme and theme["Accent"]) or UI.Accent
        local background = (theme and theme["Background"]) or Color3.fromRGB(21, 21, 21)
        local outline = (theme and theme["Outline"]) or Color3.fromRGB(45, 45, 45)
        local normalText = (theme and theme["Text"]) or Color3.fromRGB(225, 225, 225)

        local notification = Instance.new("Frame")
        notification.Name = "WeakLolNotification"
        notification.AnchorPoint = Vector2.new(1, 0)
        notification.Size = UDim2.fromOffset(300, 34)
        notification.Position = UDim2.new(1, 310, 0, 10)
        notification.BackgroundColor3 = background
        notification.BackgroundTransparency = 0
        notification.BorderSizePixel = 1
        notification.BorderColor3 = Color3.fromRGB(0, 0, 0)
        notification.ZIndex = 10
        notification.Parent = notificationGui

        local stroke = Instance.new("UIStroke")
        stroke.Color = outline
        stroke.Thickness = 1
        stroke.Transparency = 0
        stroke.Parent = notification

        local accentLine = Instance.new("Frame")
        accentLine.Size = UDim2.new(0, 2, 1, 0)
        accentLine.BackgroundColor3 = accent
        accentLine.BorderSizePixel = 0
        accentLine.ZIndex = 11
        accentLine.Parent = notification

        local icon = Instance.new("TextLabel")
        icon.BackgroundTransparency = 1
        icon.Position = UDim2.fromOffset(9, 0)
        icon.Size = UDim2.fromOffset(18, 34)
        icon.Text = "✧"
        icon.TextColor3 = accent
        icon.TextSize = 13
        icon.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        icon.ZIndex = 11
        icon.Parent = notification

        local message = Instance.new("TextLabel")
        message.BackgroundTransparency = 1
        message.Position = UDim2.fromOffset(31, 0)
        message.Size = UDim2.new(1, -39, 1, 0)
        message.RichText = true
        message.Text = string.format(
            '<font color="rgb(%d,%d,%d)">gohth.cc (fg cheat)</font>  |  All systems ready',
            math.floor(accent.R * 255),
            math.floor(accent.G * 255),
            math.floor(accent.B * 255)
        )
        message.TextColor3 = normalText
        message.TextSize = 12
        message.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        message.TextXAlignment = Enum.TextXAlignment.Left
        message.TextYAlignment = Enum.TextYAlignment.Center
        message.ZIndex = 11
        message.Parent = notification

        local progress = Instance.new("Frame")
        progress.AnchorPoint = Vector2.new(0, 1)
        progress.Position = UDim2.new(0, 0, 1, 0)
        progress.Size = UDim2.new(1, 0, 0, 1)
        progress.BackgroundColor3 = accent
        progress.BorderSizePixel = 0
        progress.ZIndex = 12
        progress.Parent = notification

        TweenService:Create(
            notification,
            TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Position = UDim2.new(1, -10, 0, 10)}
        ):Play()

        TweenService:Create(
            progress,
            TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
            {Size = UDim2.new(0, 0, 0, 1)}
        ):Play()

        task.wait(3)

        if not notification.Parent then return end

        local slideOut = TweenService:Create(
            notification,
            TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(1, 310, 0, 10)}
        )
        slideOut:Play()
        slideOut.Completed:Once(function()
            if notificationGui then notificationGui:Destroy() end
        end)
    end)
end

--// FOV Circle Functions

local function createFOVCircle()
    if fovCircle then
        fovCircle:Destroy()
        fovCircle = nil
    end

    if not SHOW_FOV or not FOV_CIRCLE_ENABLED then
        return
    end

    local gui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ESPControlUI")
    if not gui then
        gui = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Main transparent holder.
    local holder = Instance.new("Frame")
    holder.Name = "FOVCircle"
    holder.AnchorPoint = Vector2.new(0.5, 0.5)
    holder.Size = UDim2.fromOffset(LOCK_FOV * 2, LOCK_FOV * 2)
    holder.Position = UDim2.fromScale(0.5, 0.5)
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.ZIndex = 0
    holder.Parent = gui

    -- Outer ring: crisp and clean instead of a filled semi-transparent circle.
    local outer = Instance.new("Frame")
    outer.Name = "OuterRing"
    outer.Size = UDim2.fromScale(1, 1)
    outer.BackgroundTransparency = 1
    outer.BorderSizePixel = 0
    outer.Parent = holder

    local outerCorner = Instance.new("UICorner")
    outerCorner.CornerRadius = UDim.new(1, 0)
    outerCorner.Parent = outer

    local outerStroke = Instance.new("UIStroke")
    outerStroke.Color = FOV_COLOR
    outerStroke.Thickness = math.max(1, FOV_THICKNESS)
    outerStroke.Transparency = 0.08
    outerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    outerStroke.Parent = outer

    -- Four small cardinal ticks make the FOV feel more like a reticle.
    local function makeTick(name, position, size)
        local tick = Instance.new("Frame")
        tick.Name = name
        tick.AnchorPoint = Vector2.new(0.5, 0.5)
        tick.Position = position
        tick.Size = size
        tick.BackgroundColor3 = FOV_COLOR
        tick.BackgroundTransparency = 0.05
        tick.BorderSizePixel = 0
        tick.ZIndex = 1
        tick.Parent = holder
        return tick
    end

    makeTick("TopTick", UDim2.new(0.5, 0, 0, 0), UDim2.fromOffset(18, 2))
    makeTick("BottomTick", UDim2.new(0.5, 0, 1, 0), UDim2.fromOffset(18, 2))
    makeTick("LeftTick", UDim2.new(0, 0, 0.5, 0), UDim2.fromOffset(2, 18))
    makeTick("RightTick", UDim2.new(1, 0, 0.5, 0), UDim2.fromOffset(2, 18))

    -- Tiny center dot/crosshair.
    local centerDot = Instance.new("Frame")
    centerDot.Name = "CenterDot"
    centerDot.AnchorPoint = Vector2.new(0.5, 0.5)
    centerDot.Position = UDim2.fromScale(0.5, 0.5)
    centerDot.Size = UDim2.fromOffset(4, 4)
    centerDot.BackgroundColor3 = FOV_COLOR
    centerDot.BackgroundTransparency = 0.05
    centerDot.BorderSizePixel = 0
    centerDot.ZIndex = 2
    centerDot.Parent = holder

    local centerCorner = Instance.new("UICorner")
    centerCorner.CornerRadius = UDim.new(1, 0)
    centerCorner.Parent = centerDot

    fovCircle = holder
end

local function updateFOVCircle()

    if fovCircle then

        fovCircle:Destroy()

        fovCircle = nil

    end

    createFOVCircle()

end

--// Check if player is behind a wall

local function isBehindWall(character)

    local head = character:FindFirstChild("Head")

    if not head then return false end

    local origin = Camera.CFrame.Position

    local direction = head.Position - origin

    local params = RaycastParams.new()

    params.FilterType = Enum.RaycastFilterType.Exclude

    params.FilterDescendantsInstances = {

        LocalPlayer.Character,

        character

    }

    return workspace:Raycast(origin, direction, params) ~= nil

end

--// Add cham to body part

local function addCham(part)

    if not part:IsA("BasePart") then return end

    if part.Name == "HumanoidRootPart" then return end

    local cham = Instance.new("BoxHandleAdornment")

    cham.Name = "BlockyCham"

    cham.Adornee = part

    cham.AlwaysOnTop = true

    cham.ZIndex = 5

    cham.Color3 = VISIBLE_COLOR

    cham.Transparency = CHAM_TRANSPARENCY

    cham.Size = part.Size + CHAM_SIZE

    cham.Visible = ESP_ENABLED and CHAMS_ENABLED
    cham.Parent = part

end

--// Add name above head

local function addNameESP(character, player)

    local head = character:FindFirstChild("Head")

    if not head then return end

    local oldName = head:FindFirstChild("NameESP")

    if oldName then oldName:Destroy() end

    local nameGui = Instance.new("BillboardGui")

    nameGui.Name = "NameESP"

    nameGui.Adornee = head

    nameGui.Size = UDim2.fromOffset(100, 16)

    nameGui.StudsOffset = Vector3.new(0, 2.8, 0)

    nameGui.AlwaysOnTop = true

    nameGui.Enabled = ESP_ENABLED and NAME_ESP_ENABLED and NAME_ESP_ENABLED
    nameGui.Parent = head

    local nameLabel = Instance.new("TextLabel")

    nameLabel.BackgroundTransparency = 1

    nameLabel.Size = UDim2.fromScale(1, 1)

    nameLabel.Text = player.DisplayName

    nameLabel.TextColor3 = VISIBLE_COLOR

    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

    nameLabel.TextStrokeTransparency = 0.35

    nameLabel.Font = NAME_FONT

    nameLabel.TextSize = NAME_SIZE

    nameLabel.Parent = nameGui

end

--// Setup character

local function addCharacterChams(character, player)

    for _, object in ipairs(character:GetDescendants()) do

        if object:IsA("BoxHandleAdornment") and object.Name == "BlockyCham" then

            object:Destroy()

        end

    end

    for _, object in ipairs(character:GetDescendants()) do

        addCham(object)

    end

    addNameESP(character, player)

    character.DescendantAdded:Connect(function(object)

        task.wait()

        addCham(object)

    end)

end

--// Setup player

local function setupPlayer(player)

    if player == LocalPlayer then return end

    player.CharacterAdded:Connect(function(character)

        character:WaitForChild("Humanoid")

        character:WaitForChild("Head")

        task.wait(0.2)

        addCharacterChams(character, player)

    end)

    if player.Character then

        addCharacterChams(player.Character, player)

    end

end

--// Get valid lock part from character

local function getLockPart(character)

    if not character then return nil end

    local part = nil

    if LOCK_PART == "Torso" then

        part = character:FindFirstChild("UpperTorso")

        if not part then

            part = character:FindFirstChild("LowerTorso")

        end

        if not part then

            part = character:FindFirstChild("Torso")

        end

    else

        part = character:FindFirstChild(LOCK_PART)

    end

    if not part or not part:IsA("BasePart") then

        part = character:FindFirstChild("Head")

        if part and part:IsA("BasePart") then

            return part

        end

        part = character:FindFirstChild("HumanoidRootPart")

        if part and part:IsA("BasePart") then

            return part

        end

        part = character:FindFirstChild("UpperTorso")

        if part and part:IsA("BasePart") then

            return part

        end

        part = character:FindFirstChild("Torso")

        if part and part:IsA("BasePart") then

            return part

        end

        for _, child in ipairs(character:GetChildren()) do

            if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then

                return child

            end

        end

        return character:FindFirstChild("HumanoidRootPart")

    end

    return part

end

--// Find player closest to crosshair

local function getPlayerUnderCrosshair()

    local closestPlayer = nil

    local closestDistance = LOCK_FOV

    local viewportSize = Camera.ViewportSize

    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer then

            -- Team check

            if LOCK_TEAM_CHECK and player.Team == LocalPlayer.Team then

                continue

            end

            local character = player.Character

            local humanoid = character and character:FindFirstChildOfClass("Humanoid")

            local lockPart = character and getLockPart(character)

            if character and humanoid and lockPart and humanoid.Health > 0 then

                -- Visibility check

                if LOCK_VISIBLE_CHECK and isBehindWall(character) then

                    continue

                end

                local screenPosition, onScreen = Camera:WorldToViewportPoint(lockPart.Position)

                if onScreen and screenPosition.Z > 0 then

                    local partPosition = Vector2.new(screenPosition.X, screenPosition.Y)

                    local distanceFromCrosshair = (partPosition - screenCenter).Magnitude

                    if distanceFromCrosshair < closestDistance then

                        closestDistance = distanceFromCrosshair

                        closestPlayer = player

                    end

                end

            end

        end

    end

    return closestPlayer

end

----------------------------------------------------------------

--// UI - Clean Minimal Design

----------------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "ESPControlUI"

ScreenGui.ResetOnSpawn = false

ScreenGui.IgnoreGuiInset = true

ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling


ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

--// Cursor -> Aim Assist target line
task.spawn(function()
    local line = Instance.new("Frame")
    line.Name = "AimAssistTargetLine"
    -- Rotation happens around the GUI object's center, so use a centered
    -- anchor and position the line at the midpoint between cursor + target.
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = getgenv().GohthTargetLineColor
    line.BorderSizePixel = 0
    line.Size = UDim2.fromOffset(0, getgenv().GohthTargetLineThickness)
    line.Visible = false
    line.ZIndex = 80
    line.Parent = ScreenGui

    getgenv().GohthTargetLineObject = line

    RunService.RenderStepped:Connect(function()
        if not getgenv().GohthTargetLineEnabled or not LOCK_ENABLED or not TARGET then
            line.Visible = false
            return
        end

        local character = TARGET.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local head = character and character:FindFirstChild("Head")

        -- Always end the target line at the exact center of the target's Head.
        if not character or not humanoid or humanoid.Health <= 0 or not head then
            line.Visible = false
            return
        end

        -- Keep BOTH endpoints in viewport coordinates.
        -- ScreenGui.IgnoreGuiInset is true, so do not add Roblox's topbar inset.
        local point, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen or point.Z <= 0 then
            line.Visible = false
            return
        end

        -- Use the real hardware cursor position directly.
        -- This ScreenGui ignores the GUI inset, so subtracting the inset here
        -- moves the line away from the cursor.
        local mousePos = UserInputService:GetMouseLocation()

        local from = Vector2.new(mousePos.X, mousePos.Y)
        local to = Vector2.new(point.X, point.Y)

        local delta = to - from
        local length = delta.Magnitude

        if length <= 1 then
            line.Visible = false
            return
        end

        local midpoint = (from + to) * 0.5

        line.BackgroundColor3 = getgenv().GohthTargetLineColor
        line.Position = UDim2.fromOffset(midpoint.X, midpoint.Y)
        line.Size = UDim2.fromOffset(length, getgenv().GohthTargetLineThickness)
        line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
        line.Visible = true
    end)
end)

--// Screen-space Box ESP / Corner Box ESP
-- Isolated in its own function scope so these helpers do not consume
-- registers from the huge main script chunk.
;(function()
    local BoxESP = getgenv().WeakBoxESP or {Objects = {}}
    getgenv().WeakBoxESP = BoxESP

function BoxESP.newLine(parent)
    local line = Instance.new("Frame")
    line.Name = "ESPLine"
    line.BorderSizePixel = 0
    line.BackgroundColor3 = VISIBLE_COLOR
    line.Visible = false
    line.ZIndex = 50
    line.Parent = parent
    return line
end

function BoxESP.get(player)
    local existing = BoxESP.Objects[player]
    if existing then
        return existing
    end

    local holder = Instance.new("Frame")
    holder.Name = "BoxESP_" .. tostring(player.UserId)
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.Size = UDim2.fromScale(1, 1)
    holder.Position = UDim2.fromScale(0, 0)
    holder.ZIndex = 49
    holder.Parent = ScreenGui

    local obj = {
        Holder = holder,
        Full = {},
        Corners = {}
    }

    for i = 1, 4 do
        obj.Full[i] = BoxESP.newLine(holder)
    end

    for i = 1, 8 do
        obj.Corners[i] = BoxESP.newLine(holder)
    end

    BoxESP.Objects[player] = obj
    return obj
end

function BoxESP.hide(obj)
    if not obj then return end

    for _, line in ipairs(obj.Full) do
        line.Visible = false
    end

    for _, line in ipairs(obj.Corners) do
        line.Visible = false
    end
end

function BoxESP.setLine(line, x, y, width, height, color)
    line.Position = UDim2.fromOffset(math.floor(x), math.floor(y))
    line.Size = UDim2.fromOffset(
        math.max(1, math.floor(width)),
        math.max(1, math.floor(height))
    )
    line.BackgroundColor3 = color
    line.Visible = true
end

function BoxESP.bounds(character)
    if not character then return nil end

    local ok, cf, size = pcall(function()
        local boxCF, boxSize = character:GetBoundingBox()
        return boxCF, boxSize
    end)

    if not ok or not cf or not size then
        return nil
    end

    local half = size * 0.5
    local corners = {
        Vector3.new(-half.X, -half.Y, -half.Z),
        Vector3.new(-half.X, -half.Y,  half.Z),
        Vector3.new(-half.X,  half.Y, -half.Z),
        Vector3.new(-half.X,  half.Y,  half.Z),
        Vector3.new( half.X, -half.Y, -half.Z),
        Vector3.new( half.X, -half.Y,  half.Z),
        Vector3.new( half.X,  half.Y, -half.Z),
        Vector3.new( half.X,  half.Y,  half.Z),
    }

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyInFront = false

    for _, offset in ipairs(corners) do
        local worldPos = cf:PointToWorldSpace(offset)
        local point = Camera:WorldToViewportPoint(worldPos)

        if point.Z > 0 then
            anyInFront = true
            minX = math.min(minX, point.X)
            minY = math.min(minY, point.Y)
            maxX = math.max(maxX, point.X)
            maxY = math.max(maxY, point.Y)
        end
    end

    if not anyInFront or minX == math.huge then
        return nil
    end

    return minX - 2, minY - 2, maxX + 2, maxY + 2
end

function BoxESP.update(player, character, color)
    local obj = BoxESP.get(player)

    if not ESP_ENABLED
        or not CHAMS_ENABLED
        or (getgenv().WeakESPStyle ~= "Box" and getgenv().WeakESPStyle ~= "Corner Box") then
        BoxESP.hide(obj)
        return
    end

    local minX, minY, maxX, maxY = BoxESP.bounds(character)
    if not minX then
        BoxESP.hide(obj)
        return
    end

    local width = maxX - minX
    local height = maxY - minY

    if width <= 2 or height <= 2 then
        BoxESP.hide(obj)
        return
    end

    BoxESP.hide(obj)

    local thickness = 1

    if getgenv().WeakESPStyle == "Box" then
        BoxESP.setLine(obj.Full[1], minX, minY, width, thickness, color)
        BoxESP.setLine(obj.Full[2], minX, maxY - thickness, width, thickness, color)
        BoxESP.setLine(obj.Full[3], minX, minY, thickness, height, color)
        BoxESP.setLine(obj.Full[4], maxX - thickness, minY, thickness, height, color)
    else
        local cornerW = math.max(5, width * 0.25)
        local cornerH = math.max(5, height * 0.20)

        BoxESP.setLine(obj.Corners[1], minX, minY, cornerW, thickness, color)
        BoxESP.setLine(obj.Corners[2], minX, minY, thickness, cornerH, color)

        BoxESP.setLine(obj.Corners[3], maxX - cornerW, minY, cornerW, thickness, color)
        BoxESP.setLine(obj.Corners[4], maxX - thickness, minY, thickness, cornerH, color)

        BoxESP.setLine(obj.Corners[5], minX, maxY - thickness, cornerW, thickness, color)
        BoxESP.setLine(obj.Corners[6], minX, maxY - cornerH, thickness, cornerH, color)

        BoxESP.setLine(obj.Corners[7], maxX - cornerW, maxY - thickness, cornerW, thickness, color)
        BoxESP.setLine(obj.Corners[8], maxX - thickness, maxY - cornerH, thickness, cornerH, color)
    end
end

Players.PlayerRemoving:Connect(function(player)
    local obj = BoxESP.Objects[player]

    if obj then
        if obj.Holder then
            obj.Holder:Destroy()
        end

        BoxESP.Objects[player] = nil
    end
end)
end)()

--// Color Palette

UI = {
    BG = Color3.fromRGB(20, 20, 20),
    Surface = Color3.fromRGB(23, 23, 23),
    Surface2 = Color3.fromRGB(27, 27, 27),
    Surface3 = Color3.fromRGB(31, 31, 31),
    Border = Color3.fromRGB(5, 5, 5),
    BorderLight = Color3.fromRGB(50, 50, 50),
    Accent = Color3.fromRGB(67, 128, 214),
    AccentDark = Color3.fromRGB(31, 72, 132),
    AccentSoft = Color3.fromRGB(100, 160, 235),
    AccentMuted = Color3.fromRGB(45, 75, 110),
    Text = Color3.fromRGB(220, 220, 220),
    TextMuted = Color3.fromRGB(190, 190, 190),
    TextDim = Color3.fromRGB(125, 125, 125),
    Green = Color3.fromRGB(110, 200, 120),
    Red = Color3.fromRGB(220, 60, 70),
    Orange = Color3.fromRGB(220, 160, 80),
}

--// Startup notification is shown after the message (6) theme is initialized.

--// Helper Functions

local function createLabel(parent, text, pos, size, fontSize, color, alignX, alignY)

    local label = Instance.new("TextLabel")

    label.BackgroundTransparency = 1

    label.Position = pos

    label.Size = size

    label.Text = text

    label.TextColor3 = color or UI.Text

    label.Font = FONT

    label.TextSize = fontSize or UI_FONT_SIZE

    label.TextXAlignment = alignX or Enum.TextXAlignment.Left

    label.TextYAlignment = alignY or Enum.TextYAlignment.Center

    label.Parent = parent

    return label

end

local function createCorner(obj, radius)
    -- Classic square UI: intentionally no rounded corners.
    return nil
end

--// Create Toggle - classic checkbox style

local function createToggle(parent, pos, labelText, defaultValue, callback)
    local container = Instance.new("TextButton")
    container.BackgroundTransparency = 1
    container.Position = pos
    container.Size = UDim2.new(1, -12, 0, 20)
    container.Text = ""
    container.AutoButtonColor = false
    container.Parent = parent

    local box = Instance.new("Frame")
    box.Name = "CheckBox"
    box.Size = UDim2.fromOffset(13, 13)
    box.Position = UDim2.fromOffset(0, 3)
    box.BackgroundColor3 = defaultValue and UI.Accent or Color3.fromRGB(28, 28, 28)
    box.BorderSizePixel = 1
    box.BorderColor3 = Color3.fromRGB(4, 4, 4)
    box.Parent = container

    local inner = Instance.new("Frame")
    inner.Size = UDim2.new(1, -4, 1, -4)
    inner.Position = UDim2.fromOffset(2, 2)
    inner.BackgroundColor3 = defaultValue and Color3.fromRGB(83, 145, 225) or Color3.fromRGB(38, 38, 38)
    inner.BorderSizePixel = 0
    inner.Parent = box

    local label = createLabel(container, labelText, UDim2.fromOffset(19, 0), UDim2.new(1, -19, 1, 0), 13, UI.Text)

    local checked = defaultValue
    container.MouseButton1Click:Connect(function()
        checked = not checked
        box.BackgroundColor3 = checked and UI.Accent or Color3.fromRGB(28, 28, 28)
        inner.BackgroundColor3 = checked and Color3.fromRGB(83, 145, 225) or Color3.fromRGB(38, 38, 38)
        if callback then callback(checked) end
    end)

    return container, container
end

--// Create Color Button

local function createColorButton(parent, pos, labelText, defaultColor, callback)

    local container = Instance.new("Frame")

    container.BackgroundTransparency = 1

    container.Position = pos

    container.Size = UDim2.new(1, -24, 0, 32)

    container.Parent = parent

    local label = createLabel(container, labelText, UDim2.fromOffset(0, 0), UDim2.new(1, -60, 1, 0), 13, UI.TextMuted)

    local colorBtn = Instance.new("TextButton")

    colorBtn.Size = UDim2.fromOffset(27, 19)

    colorBtn.Position = UDim2.new(1, -30, 0.5, -9)

    colorBtn.BackgroundColor3 = defaultColor

    colorBtn.BorderSizePixel = 1

    colorBtn.BorderColor3 = Color3.fromRGB(3, 3, 3)

    colorBtn.Text = ""

    colorBtn.AutoButtonColor = false

    colorBtn.Parent = container

    createCorner(colorBtn, 3)

    local currentColor = defaultColor

    local colorIndex = 1

    local colors = {

        Color3.fromRGB(255, 255, 255),

        Color3.fromRGB(255, 100, 100),

        Color3.fromRGB(100, 255, 100),

        Color3.fromRGB(100, 100, 255),

        Color3.fromRGB(255, 255, 100),

        Color3.fromRGB(255, 100, 255),

        Color3.fromRGB(100, 255, 255),

        Color3.fromRGB(255, 180, 50),

        Color3.fromRGB(200, 100, 255),

        Color3.fromRGB(240, 103, 156),

    }

    colorBtn.MouseButton1Click:Connect(function()

        colorIndex = colorIndex % #colors + 1

        currentColor = colors[colorIndex]

        colorBtn.BackgroundColor3 = currentColor

        if callback then callback(currentColor) end

    end)

    return container, colorBtn

end

--// Create Dropdown

local function createDropdown(parent, pos, labelText, options, defaultIndex, callback)

    local container = Instance.new("Frame")

    container.BackgroundTransparency = 1

    container.Position = pos

    container.Size = UDim2.new(1, -24, 0, 32)

    container.Parent = parent

    local label = createLabel(container, labelText, UDim2.fromOffset(0, 0), UDim2.new(0.5, -10, 1, 0), 13, UI.TextMuted)

    local dropdown = Instance.new("TextButton")

    dropdown.Size = UDim2.new(0.5, -10, 1, 0)

    dropdown.Position = UDim2.new(0.5, 10, 0, 0)

    dropdown.BackgroundColor3 = UI.Surface3

    dropdown.BorderSizePixel = 1

    dropdown.BorderColor3 = UI.Border

    dropdown.Text = options[defaultIndex or 1]

    dropdown.TextColor3 = UI.Text

    dropdown.Font = FONT

    dropdown.TextSize = 12

    dropdown.AutoButtonColor = false

    dropdown.Parent = container

    createCorner(dropdown, 3)

    local currentIndex = defaultIndex or 1

    dropdown.MouseButton1Click:Connect(function()

        currentIndex = currentIndex % #options + 1

        dropdown.Text = options[currentIndex]

        if callback then callback(options[currentIndex], currentIndex) end

    end)

    return container, dropdown

end

--// Create Slider

local function createSlider(parent, pos, labelText, minVal, maxVal, defaultValue, callback, format)

    local container = Instance.new("Frame")

    container.BackgroundTransparency = 1

    container.Position = pos

    container.Size = UDim2.new(1, -24, 0, 52)

    container.Parent = parent

    local label = createLabel(container, labelText, UDim2.fromOffset(0, 0), UDim2.new(1, -60, 0, 20), 12, UI.TextMuted)

    local valueLabel = createLabel(container, format and format(defaultValue) or tostring(defaultValue), UDim2.new(1, -50, 0, 0), UDim2.fromOffset(40, 20), 13, UI.Accent)

    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    valueLabel.Font = FONT

    local sliderContainer = Instance.new("Frame")

    sliderContainer.Position = UDim2.fromOffset(0, 22)

    sliderContainer.Size = UDim2.new(1, 0, 0, 20)

    sliderContainer.BackgroundTransparency = 1

    sliderContainer.Parent = container

    local sliderBar = Instance.new("Frame")

    sliderBar.Size = UDim2.fromScale(1, 1)

    sliderBar.BackgroundColor3 = UI.Surface3

    sliderBar.BorderSizePixel = 1

    sliderBar.BorderColor3 = UI.Border

    sliderBar.Parent = sliderContainer

    createCorner(sliderBar, 3)

    local sliderFill = Instance.new("Frame")

    local percent = (defaultValue - minVal) / (maxVal - minVal)

    sliderFill.Size = UDim2.new(math.clamp(percent, 0, 1), 0, 1, 0)

    sliderFill.BackgroundColor3 = UI.Accent

    sliderFill.BorderSizePixel = 0

    sliderFill.Parent = sliderBar

    createCorner(sliderFill, 3)

    local sliderHandle = Instance.new("Frame")

    sliderHandle.Size = UDim2.fromOffset(8, 20)

    sliderHandle.Position = UDim2.new(math.clamp(percent, 0, 1), -4, 0.5, -10)

    sliderHandle.BackgroundColor3 = UI.Accent

    sliderHandle.BorderSizePixel = 1

    sliderHandle.BorderColor3 = UI.BorderLight

    sliderHandle.Parent = sliderContainer

    createCorner(sliderHandle, 3)

    local dragging = false

    local dragConn, releaseConn

    local function updateValue(mouseX)

        local absPos = sliderContainer.AbsolutePosition.X

        local width = sliderContainer.AbsoluteSize.X

        if width <= 0 then return end

        local pct = math.clamp((mouseX - absPos) / width, 0, 1)

        local val = minVal + (maxVal - minVal) * pct

        val = math.clamp(val, minVal, maxVal)

        local newPct = (val - minVal) / (maxVal - minVal)

        sliderFill.Size = UDim2.new(newPct, 0, 1, 0)

        sliderHandle.Position = UDim2.new(newPct, -4, 0.5, -10)

        valueLabel.Text = format and format(val) or tostring(val)

        if callback then callback(val) end

    end

    sliderHandle.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1 then

            dragging = true

            updateValue(input.Position.X)

            if dragConn then dragConn:Disconnect() end

            dragConn = UserInputService.InputChanged:Connect(function(input)

                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

                    updateValue(input.Position.X)

                end

            end)

            if releaseConn then releaseConn:Disconnect() end

            releaseConn = UserInputService.InputEnded:Connect(function(input)

                if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then

                    dragging = false

                    if dragConn then dragConn:Disconnect(); dragConn = nil end

                    if releaseConn then releaseConn:Disconnect(); releaseConn = nil end

                end

            end)

        end

    end)

    sliderBar.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1 then

            updateValue(input.Position.X)

            dragging = true

            if dragConn then dragConn:Disconnect() end

            dragConn = UserInputService.InputChanged:Connect(function(input)

                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

                    updateValue(input.Position.X)

                end

            end)

            if releaseConn then releaseConn:Disconnect() end

            releaseConn = UserInputService.InputEnded:Connect(function(input)

                if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then

                    dragging = false

                    if dragConn then dragConn:Disconnect(); dragConn = nil end

                    if releaseConn then releaseConn:Disconnect(); releaseConn = nil end

                end

            end)

        end

    end)

    return container, sliderHandle, valueLabel

end

--// Main Window

local Main = Instance.new("Frame")

Main.Name = "MainFrame"

Main.Size = UDim2.fromOffset(540, 665)

Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)

Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

Main.BorderSizePixel = 0

Main.Parent = ScreenGui
Main.Visible = false

createCorner(Main, 3)

local MainStroke = Instance.new("UIStroke")

MainStroke.Color = Color3.fromRGB(0, 0, 0)

MainStroke.Thickness = 1

MainStroke.Transparency = 0

MainStroke.Parent = Main

local ClassicBlueStroke = Instance.new("UIStroke")
ClassicBlueStroke.Color = UI.Accent
ClassicBlueStroke.Thickness = 1
ClassicBlueStroke.Transparency = 0
ClassicBlueStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ClassicBlueStroke.Parent = Main


do
    --// Window resize support (UI only)
    -- Drag any corner to scale the whole menu smaller/larger while preserving layout.
    local WindowScale = Instance.new("UIScale")
    WindowScale.Name = "WindowScale"
    WindowScale.Scale = 1
    WindowScale.Parent = Main

    local RESIZE_MIN_SCALE = 0.55
    local RESIZE_MAX_SCALE = 1.60
    local RESIZE_HANDLE_SIZE = 18

    local function makeResizeHandle(name, anchorPoint, position)
        local handle = Instance.new("TextButton")
        handle.Name = name
        handle.AnchorPoint = anchorPoint
        handle.Position = position
        handle.Size = UDim2.fromOffset(RESIZE_HANDLE_SIZE, RESIZE_HANDLE_SIZE)
        handle.BackgroundTransparency = 1
        handle.BorderSizePixel = 0
        handle.Text = ""
        handle.AutoButtonColor = false
        handle.ZIndex = 1000
        handle.Parent = Main
        return handle
    end

    local ResizeTL = makeResizeHandle("ResizeTopLeft", Vector2.new(0, 0), UDim2.fromScale(0, 0))
    local ResizeTR = makeResizeHandle("ResizeTopRight", Vector2.new(1, 0), UDim2.fromScale(1, 0))
    local ResizeBL = makeResizeHandle("ResizeBottomLeft", Vector2.new(0, 1), UDim2.fromScale(0, 1))
    local ResizeBR = makeResizeHandle("ResizeBottomRight", Vector2.new(1, 1), UDim2.fromScale(1, 1))

    local resizing = false
    local resizeStartMouse = nil
    local resizeStartScale = 1
    local resizeDirection = 1

    local function beginResize(input, direction)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        resizing = true
        resizeStartMouse = input.Position
        resizeStartScale = WindowScale.Scale
        resizeDirection = direction
    end

    ResizeTL.InputBegan:Connect(function(input) beginResize(input, -1) end)
    ResizeTR.InputBegan:Connect(function(input) beginResize(input, 1) end)
    ResizeBL.InputBegan:Connect(function(input) beginResize(input, -1) end)
    ResizeBR.InputBegan:Connect(function(input) beginResize(input, 1) end)

    UserInputService.InputChanged:Connect(function(input)
        if not resizing or input.UserInputType ~= Enum.UserInputType.MouseMovement or not resizeStartMouse then
            return
        end

        local delta = input.Position - resizeStartMouse
        local dominant = math.abs(delta.X) > math.abs(delta.Y) and delta.X or delta.Y
        local scaleDelta = (dominant / 420) * resizeDirection

        WindowScale.Scale = math.clamp(
            resizeStartScale + scaleDelta,
            RESIZE_MIN_SCALE,
            RESIZE_MAX_SCALE
        )
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
            resizeStartMouse = nil
        end
    end)
end

--// Left Sidebar

local Sidebar = Instance.new("Frame")

Sidebar.Name = "Sidebar"

Sidebar.Size = UDim2.fromOffset(1, 1)

Sidebar.BackgroundTransparency = 1
Sidebar.ClipsDescendants = true

Sidebar.BorderSizePixel = 0

Sidebar.ZIndex = 1

Sidebar.Parent = Main

createCorner(Sidebar, 3)

local SidebarFix = Instance.new("Frame")

SidebarFix.Size = UDim2.fromOffset(20, 540)

SidebarFix.Position = UDim2.new(1, -20, 0, 0)

SidebarFix.BackgroundColor3 = UI.Surface

SidebarFix.BorderSizePixel = 0

SidebarFix.ZIndex = 2

SidebarFix.Parent = Sidebar
SidebarFix.Visible = false

local Brand = createLabel(Sidebar, "gohth.cc (fg cheat)", UDim2.fromOffset(18, 15), UDim2.new(1, -36, 0, 24), 19, UI.Text)

Brand.Font = FONT
Brand.Visible = false

Brand.ZIndex = 3

local BrandAccent = Instance.new("Frame")

BrandAccent.Size = UDim2.fromOffset(26, 2)

BrandAccent.Position = UDim2.fromOffset(18, 42)

BrandAccent.BackgroundColor3 = UI.Accent

BrandAccent.BorderSizePixel = 0

BrandAccent.ZIndex = 3

BrandAccent.Parent = Sidebar
BrandAccent.Visible = false

createCorner(BrandAccent, 3)

local BrandSub = createLabel(Sidebar, "CONTROL PANEL", UDim2.fromOffset(18, 50), UDim2.new(1, -36, 0, 18), 9, UI.TextDim)

BrandSub.ZIndex = 3
BrandSub.Visible = false

local SideDivider = Instance.new("Frame")

SideDivider.Position = UDim2.new(1, -1, 0, 0)

SideDivider.Size = UDim2.new(0, 1, 1, 0)

SideDivider.BackgroundColor3 = UI.Border

SideDivider.BackgroundTransparency = 0.25

SideDivider.BorderSizePixel = 0

SideDivider.ZIndex = 3

SideDivider.Parent = Sidebar
SideDivider.Visible = false

local TabsLabel = createLabel(Sidebar, "FEATURES", UDim2.fromOffset(18, 91), UDim2.new(1, -36, 0, 18), 9, UI.TextDim)

TabsLabel.ZIndex = 3
TabsLabel.Visible = false

local TabBar = Instance.new("Frame")

TabBar.Name = "SideTabs"

TabBar.Position = UDim2.fromOffset(10, 34)

TabBar.Size = UDim2.new(1, -20, 0, 24)

TabBar.BackgroundTransparency = 1

TabBar.ZIndex = 3

TabBar.Parent = Main

local function createTab(name, x, icon)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Tab"
    btn.Position = UDim2.fromOffset(x, 0)
    btn.Size = UDim2.fromOffset(name == "Settings" and 74 or (name == "Visuals" and 66 or (name == "Speed" and 60 or 60)), 24)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(5, 5, 5)
    btn.Text = name
    btn.TextColor3 = UI.TextMuted
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.ZIndex = 4
    btn.Parent = TabBar

    local ind = Instance.new("Frame")
    ind.Name = "Indicator"
    ind.Size = UDim2.new(1, -2, 0, 1)
    ind.Position = UDim2.new(0, 1, 1, -1)
    ind.BackgroundColor3 = UI.Accent
    ind.Visible = false
    ind.BorderSizePixel = 0
    ind.ZIndex = 5
    ind.Parent = btn

    btn.MouseEnter:Connect(function()
        if not ind.Visible then
            btn.BackgroundColor3 = Color3.fromRGB(29, 29, 29)
        end
    end)

    btn.MouseLeave:Connect(function()
        if not ind.Visible then
            btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
        end
    end)

    return btn, ind
end

local ESPTab, ESPInd = createTab("Aim Assist", 0, "")

local AimlockTab, AimlockInd = createTab("Visuals", 60, "")

UI.MiscTab, UI.MiscInd = createTab("Misc", 126, "")

local SettingsTab, SettingsInd = createTab("Settings", 186, "")

local HintCard = Instance.new("Frame")

HintCard.Position = UDim2.new(0, 12, 1, -83)

HintCard.Size = UDim2.new(1, -24, 0, 66)

HintCard.BackgroundColor3 = UI.Surface2

HintCard.BorderSizePixel = 0

HintCard.ZIndex = 3

HintCard.Parent = Sidebar
HintCard.Visible = false

createCorner(HintCard, 3)

local HintStroke = Instance.new("UIStroke")

HintStroke.Color = UI.Border

HintStroke.Transparency = 0.2

HintStroke.Parent = HintCard

local HintTitle = createLabel(HintCard, "INSERT", UDim2.fromOffset(10, 8), UDim2.new(1, -20, 0, 18), 10, UI.Accent)

HintTitle.ZIndex = 4

local HintText = createLabel(HintCard, "Show / hide menu", UDim2.fromOffset(10, 27), UDim2.new(1, -20, 0, 26), 10, UI.TextMuted)

HintText.ZIndex = 4

--// Top Header / Content Area

local TitleBar = Instance.new("Frame")

TitleBar.Name = "TitleBar"

TitleBar.Position = UDim2.fromOffset(0, 0)

TitleBar.Size = UDim2.new(1, 0, 0, 34)

TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

TitleBar.BorderSizePixel = 0

TitleBar.ZIndex = 2

TitleBar.Parent = Main

local Title = createLabel(TitleBar, "✧  gohth.cc (fg cheat)", UDim2.fromOffset(10, 4), UDim2.new(1, -20, 0, 24), 15, UI.Accent)

Title.ZIndex = 3

local Subtitle = createLabel(TitleBar, "", UDim2.fromOffset(0, 0), UDim2.fromOffset(0, 0), 10, UI.TextMuted)

Subtitle.ZIndex = 3

local HeaderDivider = Instance.new("Frame")

HeaderDivider.Position = UDim2.new(0, 0, 1, -1)

HeaderDivider.Size = UDim2.new(1, 0, 0, 1)

HeaderDivider.BackgroundColor3 = Color3.fromRGB(3, 3, 3)

HeaderDivider.BackgroundTransparency = 0.25

HeaderDivider.BorderSizePixel = 0

HeaderDivider.ZIndex = 3

HeaderDivider.Parent = TitleBar

--// Content

local Content = Instance.new("Frame")

Content.Position = UDim2.fromOffset(10, 62)

Content.Size = UDim2.new(1, -20, 1, -72)

Content.BackgroundColor3 = Color3.fromRGB(23, 23, 23)

Content.BorderSizePixel = 1

Content.ZIndex = 1

Content.Parent = Main

--// Forward declarations used by UI callbacks
local settingESP
local settingFOV
local updateUI

--// ESP Page

local ESPPage = Instance.new("Frame")

ESPPage.Size = UDim2.fromScale(1, 1)

ESPPage.BackgroundTransparency = 1

ESPPage.ZIndex = 2

ESPPage.Parent = Content

local ESPPanel = Instance.new("Frame")

ESPPanel.BackgroundColor3 = Color3.fromRGB(23, 23, 23)

ESPPanel.BorderSizePixel = 1

ESPPanel.BorderColor3 = Color3.fromRGB(4, 4, 4)

ESPPanel.Position = UDim2.fromOffset(8, 8)

ESPPanel.Size = UDim2.fromOffset(324, 124)

ESPPanel.ZIndex = 3

ESPPanel.Parent = ESPPage

createCorner(ESPPanel, 3)

local panelTitle = createLabel(ESPPanel, "Player ESP", UDim2.fromOffset(8, 3), UDim2.new(1, -16, 0, 18), 14, UI.Text)

panelTitle.Font = FONT

local panelDiv = Instance.new("Frame")

panelDiv.BackgroundColor3 = UI.Border

panelDiv.BorderSizePixel = 0

panelDiv.Position = UDim2.fromOffset(0, 22)

panelDiv.Size = UDim2.new(1, 0, 0, 1)

panelDiv.Parent = ESPPanel

-- ESP Toggle

local espToggleContainer, espToggle = createToggle(ESPPanel, UDim2.fromOffset(8, 24), "Enable ESP", true, function(val)

    ESP_ENABLED = val

    settingESP.Text = val and "ENABLED" or "DISABLED"

    settingESP.TextColor3 = val and UI.Green or UI.Red

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            for _, object in ipairs(character:GetDescendants()) do
                if object:IsA("BoxHandleAdornment") and object.Name == "BlockyCham" then
                    object.Visible = ESP_ENABLED and CHAMS_ENABLED and CHAMS_ENABLED
                end
            end
            local head = character:FindFirstChild("Head")
            local nameGui = head and head:FindFirstChild("NameESP")
            if nameGui then
                nameGui.Enabled = ESP_ENABLED and NAME_ESP_ENABLED and NAME_ESP_ENABLED
            end
        end
    end

end)

-- Chams ESP Toggle

local chamsToggleContainer, chamsToggle = createToggle(ESPPanel, UDim2.fromOffset(8, 46), "Chams ESP", true, function(val)

    CHAMS_ENABLED = val

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, object in ipairs(player.Character:GetDescendants()) do
                if object:IsA("BoxHandleAdornment") and object.Name == "BlockyCham" then
                    object.Visible = ESP_ENABLED and CHAMS_ENABLED and CHAMS_ENABLED
                end
            end
        end
    end

end)

-- Name ESP Toggle

local nameToggleContainer, nameToggle = createToggle(ESPPanel, UDim2.fromOffset(8, 68), "Name ESP", true, function(val)

    NAME_ESP_ENABLED = val

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local nameGui = head and head:FindFirstChild("NameESP")
            if nameGui then
                nameGui.Enabled = ESP_ENABLED and NAME_ESP_ENABLED and NAME_ESP_ENABLED
            end
        end
    end

end)

-- Visible Color

local visColorContainer, visColorBtn = createColorButton(ESPPanel, UDim2.fromOffset(8, 90), "Visible Color", VISIBLE_COLOR, function(color)

    VISIBLE_COLOR = color

    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer then

            local character = player.Character

            if character then

                for _, object in ipairs(character:GetDescendants()) do

                    if object:IsA("BoxHandleAdornment") and object.Name == "BlockyCham" then

                        local hidden = isBehindWall(character)

                        if not hidden then

                            object.Color3 = color

                        end

                    end

                end

            end

        end

    end

end)

-- Chams Info

local chamsInfo = createLabel(ESPPanel, "Chams: Blocky + Name ESP", UDim2.fromOffset(8, 136), UDim2.new(1, -16, 0, 20), 14, UI.Text)

chamsInfo.TextXAlignment = Enum.TextXAlignment.Left

chamsInfo.Font = FONT

local espTotalHeight = 44 + 32 + 32 + 32 + 32 + 32 + 28 + 10

ESPPanel.Size = UDim2.fromOffset(324, 160)

--// Aimlock Page

local AimlockPage = Instance.new("Frame")

AimlockPage.Size = UDim2.fromScale(1, 1)

AimlockPage.BackgroundTransparency = 1

AimlockPage.ZIndex = 2

AimlockPage.Visible = false

AimlockPage.Parent = Content

local AimlockPanel = Instance.new("Frame")

AimlockPanel.BackgroundColor3 = Color3.fromRGB(23, 23, 23)

AimlockPanel.BorderSizePixel = 1

AimlockPanel.BorderColor3 = Color3.fromRGB(4, 4, 4)

AimlockPanel.Position = UDim2.fromOffset(8, 8)

AimlockPanel.Size = UDim2.new(1, -16, 0, 0)

AimlockPanel.ZIndex = 3

AimlockPanel.Parent = AimlockPage

createCorner(AimlockPanel, 3)

local aimlockTitle = createLabel(AimlockPanel, "Visuals", UDim2.fromOffset(14, 10), UDim2.new(1, -28, 0, 24), 14, UI.Text)

aimlockTitle.Font = FONT

local aimlockDiv = Instance.new("Frame")

aimlockDiv.BackgroundColor3 = UI.Border

aimlockDiv.BorderSizePixel = 0

aimlockDiv.Position = UDim2.fromOffset(0, 38)

aimlockDiv.Size = UDim2.new(1, 0, 0, 1)

aimlockDiv.Parent = AimlockPanel

-- Aimlock Toggle

local aimToggleContainer, aimToggle = createToggle(AimlockPanel, UDim2.fromOffset(12, 44), "Enable Aim Assist", false, function(val)

    LOCK_ENABLED = val

    if val then

        TARGET = getPlayerUnderCrosshair()

    else

        TARGET = nil

        Camera.CameraType = Enum.CameraType.Custom

    end

    updateUI()

end)

-- Lock Key

local keyLabel = createLabel(AimlockPanel, "Lock Key", UDim2.fromOffset(12, 80), UDim2.new(0.5, -10, 0, 28), 12, UI.TextMuted)

keyLabel.Font = FONT

local keyBtn = Instance.new("TextButton")

keyBtn.Size = UDim2.fromOffset(80, 28)

keyBtn.Position = UDim2.new(0.5, 10, 0, 78)

keyBtn.BackgroundColor3 = UI.Surface3

keyBtn.BorderSizePixel = 1

keyBtn.BorderColor3 = UI.Border

keyBtn.Text = "Q"

keyBtn.TextColor3 = UI.Accent

keyBtn.Font = FONT

keyBtn.TextSize = 14

keyBtn.AutoButtonColor = false

keyBtn.Parent = AimlockPanel

createCorner(keyBtn, 3)

-- Lock Part Dropdown

local partOptions = {"Head", "HumanoidRootPart", "Torso"}

local partDropdownContainer, partDropdown = createDropdown(AimlockPanel, UDim2.fromOffset(12, 116), "Lock Part", partOptions, 1, function(value, index)

    LOCK_PART = value

    if LOCK_ENABLED and TARGET then

        TARGET = getPlayerUnderCrosshair()

    end

end)

-- Visibility Check Toggle

local visCheckContainer, visCheckToggle = createToggle(AimlockPanel, UDim2.fromOffset(12, 152), "Visible Check", false, function(val)

    LOCK_VISIBLE_CHECK = val

end)

-- Team Check Toggle

local teamCheckContainer, teamCheckToggle = createToggle(AimlockPanel, UDim2.fromOffset(12, 188), "Ignore Team", false, function(val)

    LOCK_TEAM_CHECK = val

end)

-- FOV Slider

local fovLabel = createLabel(AimlockPanel, "FOV Size", UDim2.fromOffset(12, 228), UDim2.new(0.5, -10, 0, 20), 12, UI.TextMuted)

fovLabel.Font = FONT

local fovSliderContainer = Instance.new("Frame")

fovSliderContainer.BackgroundTransparency = 1

fovSliderContainer.Position = UDim2.fromOffset(12, 250)

fovSliderContainer.Size = UDim2.new(1, -24, 0, 22)

fovSliderContainer.Parent = AimlockPanel

local fovSliderBar = Instance.new("Frame")

fovSliderBar.Size = UDim2.fromScale(1, 1)

fovSliderBar.BackgroundColor3 = UI.Surface3

fovSliderBar.BorderSizePixel = 1

fovSliderBar.BorderColor3 = UI.Border

fovSliderBar.Parent = fovSliderContainer

createCorner(fovSliderBar, 3)

local fovSliderFill = Instance.new("Frame")

local fovPct = (LOCK_FOV - FOV_MIN) / (FOV_MAX - FOV_MIN)

fovSliderFill.Size = UDim2.new(fovPct, 0, 1, 0)

fovSliderFill.BackgroundColor3 = UI.Accent

fovSliderFill.BorderSizePixel = 0

fovSliderFill.Parent = fovSliderBar

createCorner(fovSliderFill, 3)

local fovSliderHandle = Instance.new("Frame")

fovSliderHandle.Size = UDim2.fromOffset(14, 28)

fovSliderHandle.Position = UDim2.new(fovPct, -7, 0.5, -14)

fovSliderHandle.BackgroundColor3 = UI.Accent

fovSliderHandle.BorderSizePixel = 1

fovSliderHandle.BorderColor3 = UI.BorderLight

fovSliderHandle.Parent = fovSliderContainer

createCorner(fovSliderHandle, 3)

local fovVal = createLabel(AimlockPanel, tostring(LOCK_FOV), UDim2.new(0.5, 10, 0, 228), UDim2.new(0.5, -10, 0, 20), 13, UI.Accent)

fovVal.TextXAlignment = Enum.TextXAlignment.Right

fovVal.Font = FONT

-- FOV slider dragging

local fovDragging = false

local fovDragConn, fovReleaseConn

local function updateFOV(mouseX)

    local pos = fovSliderContainer.AbsolutePosition.X

    local width = fovSliderContainer.AbsoluteSize.X

    if width <= 0 then return end

    local pct = math.clamp((mouseX - pos) / width, 0, 1)

    local newFOV = math.floor(FOV_MIN + (FOV_MAX - FOV_MIN) * pct)

    newFOV = math.floor(newFOV / 5) * 5

    newFOV = math.clamp(newFOV, FOV_MIN, FOV_MAX)

    LOCK_FOV = newFOV

    local newPct = (LOCK_FOV - FOV_MIN) / (FOV_MAX - FOV_MIN)

    fovSliderFill.Size = UDim2.new(newPct, 0, 1, 0)

    fovSliderHandle.Position = UDim2.new(newPct, -7, 0.5, -14)

    fovVal.Text = tostring(LOCK_FOV)

    updateFOVCircle()

end

fovSliderHandle.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then

        fovDragging = true

        updateFOV(input.Position.X)

        if fovDragConn then fovDragConn:Disconnect() end

        fovDragConn = UserInputService.InputChanged:Connect(function(input)

            if fovDragging and input.UserInputType == Enum.UserInputType.MouseMovement then

                updateFOV(input.Position.X)

            end

        end)

        if fovReleaseConn then fovReleaseConn:Disconnect() end

        fovReleaseConn = UserInputService.InputEnded:Connect(function(input)

            if input.UserInputType == Enum.UserInputType.MouseButton1 and fovDragging then

                fovDragging = false

                if fovDragConn then fovDragConn:Disconnect(); fovDragConn = nil end

                if fovReleaseConn then fovReleaseConn:Disconnect(); fovReleaseConn = nil end

            end

        end)

    end

end)

fovSliderBar.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then

        updateFOV(input.Position.X)

        fovDragging = true

        if fovDragConn then fovDragConn:Disconnect() end

        fovDragConn = UserInputService.InputChanged:Connect(function(input)

            if fovDragging and input.UserInputType == Enum.UserInputType.MouseMovement then

                updateFOV(input.Position.X)

            end

        end)

        if fovReleaseConn then fovReleaseConn:Disconnect() end

        fovReleaseConn = UserInputService.InputEnded:Connect(function(input)

            if input.UserInputType == Enum.UserInputType.MouseButton1 and fovDragging then

                fovDragging = false

                if fovDragConn then fovDragConn:Disconnect(); fovDragConn = nil end

                if fovReleaseConn then fovReleaseConn:Disconnect(); fovReleaseConn = nil end

            end

        end)

    end

end)

-- FOV Circle Toggle

local fovToggleContainer, fovToggle = createToggle(AimlockPanel, UDim2.fromOffset(12, 288), "Show FOV Circle", true, function(val)

    SHOW_FOV = val

    settingFOV.Text = val and "ON" or "OFF"

    settingFOV.TextColor3 = val and UI.Green or UI.Red

    updateFOVCircle()

end)

-- Smoothness Toggle

local smoothToggleContainer, smoothToggle = createToggle(AimlockPanel, UDim2.fromOffset(12, 324), "Smooth Aim", true, function(val)

    SMOOTHNESS_ENABLED = val

end)

-- Smoothness Slider

local smoothLabel = createLabel(AimlockPanel, "Smoothness", UDim2.fromOffset(12, 364), UDim2.new(0.5, -10, 0, 20), 12, UI.TextMuted)

smoothLabel.Font = FONT

local smoothSliderContainer = Instance.new("Frame")

smoothSliderContainer.BackgroundTransparency = 1

smoothSliderContainer.Position = UDim2.fromOffset(12, 386)

smoothSliderContainer.Size = UDim2.new(1, -24, 0, 22)

smoothSliderContainer.Parent = AimlockPanel

local smoothSliderBar = Instance.new("Frame")

smoothSliderBar.Size = UDim2.fromScale(1, 1)

smoothSliderBar.BackgroundColor3 = UI.Surface3

smoothSliderBar.BorderSizePixel = 1

smoothSliderBar.BorderColor3 = UI.Border

smoothSliderBar.Parent = smoothSliderContainer

createCorner(smoothSliderBar, 3)

local smoothSliderFill = Instance.new("Frame")

smoothSliderFill.Size = UDim2.new(SMOOTHNESS_VALUE, 0, 1, 0)

smoothSliderFill.BackgroundColor3 = UI.Accent

smoothSliderFill.BorderSizePixel = 0

smoothSliderFill.Parent = smoothSliderBar

createCorner(smoothSliderFill, 3)

local smoothSliderHandle = Instance.new("Frame")

smoothSliderHandle.Size = UDim2.fromOffset(14, 28)

smoothSliderHandle.Position = UDim2.new(SMOOTHNESS_VALUE, -7, 0.5, -14)

smoothSliderHandle.BackgroundColor3 = UI.Accent

smoothSliderHandle.BorderSizePixel = 1

smoothSliderHandle.BorderColor3 = UI.BorderLight

smoothSliderHandle.Parent = smoothSliderContainer

createCorner(smoothSliderHandle, 3)

local smoothVal = createLabel(AimlockPanel, string.format("%.2f", SMOOTHNESS_VALUE), UDim2.new(0.5, 10, 0, 364), UDim2.new(0.5, -10, 0, 20), 13, UI.Accent)

smoothVal.TextXAlignment = Enum.TextXAlignment.Right

smoothVal.Font = FONT

-- Smooth slider dragging

local smoothDragging = false

local smoothDragConn, smoothReleaseConn

local function updateSmoothness(mouseX)

    local pos = smoothSliderContainer.AbsolutePosition.X

    local width = smoothSliderContainer.AbsoluteSize.X

    if width <= 0 then return end

    local pct = math.clamp((mouseX - pos) / width, 0, 1)

    SMOOTHNESS_VALUE = pct

    smoothSliderFill.Size = UDim2.new(pct, 0, 1, 0)

    smoothSliderHandle.Position = UDim2.new(pct, -7, 0.5, -14)

    smoothVal.Text = string.format("%.2f", pct)

end

smoothSliderHandle.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then

        smoothDragging = true

        updateSmoothness(input.Position.X)

        if smoothDragConn then smoothDragConn:Disconnect() end

        smoothDragConn = UserInputService.InputChanged:Connect(function(input)

            if smoothDragging and input.UserInputType == Enum.UserInputType.MouseMovement then

                updateSmoothness(input.Position.X)

            end

        end)

        if smoothReleaseConn then smoothReleaseConn:Disconnect() end

        smoothReleaseConn = UserInputService.InputEnded:Connect(function(input)

            if input.UserInputType == Enum.UserInputType.MouseButton1 and smoothDragging then

                smoothDragging = false

                if smoothDragConn then smoothDragConn:Disconnect(); smoothDragConn = nil end

                if smoothReleaseConn then smoothReleaseConn:Disconnect(); smoothReleaseConn = nil end

            end

        end)

    end

end)

smoothSliderBar.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then

        updateSmoothness(input.Position.X)

        smoothDragging = true

        if smoothDragConn then smoothDragConn:Disconnect() end

        smoothDragConn = UserInputService.InputChanged:Connect(function(input)

            if smoothDragging and input.UserInputType == Enum.UserInputType.MouseMovement then

                updateSmoothness(input.Position.X)

            end

        end)

        if smoothReleaseConn then smoothReleaseConn:Disconnect() end

        smoothReleaseConn = UserInputService.InputEnded:Connect(function(input)

            if input.UserInputType == Enum.UserInputType.MouseButton1 and smoothDragging then

                smoothDragging = false

                if smoothDragConn then smoothDragConn:Disconnect(); smoothDragConn = nil end

                if smoothReleaseConn then smoothReleaseConn:Disconnect(); smoothReleaseConn = nil end

            end

        end)

    end

end)

-- Aimlock Status

local statusLabel = createLabel(AimlockPanel, "Status", UDim2.fromOffset(12, 424), UDim2.new(0.5, -10, 0, 28), 12, UI.TextMuted)

statusLabel.Font = FONT

local lockStatus = createLabel(AimlockPanel, "OFF", UDim2.new(0.5, 10, 0, 424), UDim2.new(0.5, -10, 0, 28), 14, UI.Red)

lockStatus.TextXAlignment = Enum.TextXAlignment.Right

lockStatus.Font = FONT

local targetLabel = createLabel(AimlockPanel, "Target", UDim2.fromOffset(12, 456), UDim2.new(0.5, -10, 0, 28), 12, UI.TextMuted)

targetLabel.Font = FONT

local targetVal = createLabel(AimlockPanel, "NONE", UDim2.new(0.5, 10, 0, 456), UDim2.new(0.5, -10, 0, 28), 13, UI.TextDim)

targetVal.TextXAlignment = Enum.TextXAlignment.Right

targetVal.Font = FONT

local aimlockTotalHeight = 44 + 32 + 32 + 32 + 32 + 32 + 44 + 32 + 32 + 44 + 32 + 32 + 32 + 10

AimlockPanel.Size = UDim2.new(1, -16, 0, aimlockTotalHeight)


--// Settings Page

local SettingsPage = Instance.new("Frame")

SettingsPage.Size = UDim2.fromScale(1, 1)

SettingsPage.BackgroundTransparency = 1

SettingsPage.ZIndex = 2

SettingsPage.Visible = false

SettingsPage.Parent = Content

local SettingsPanel = Instance.new("Frame")

SettingsPanel.BackgroundColor3 = Color3.fromRGB(23, 23, 23)

SettingsPanel.BorderSizePixel = 1

SettingsPanel.BorderColor3 = Color3.fromRGB(4, 4, 4)

SettingsPanel.Position = UDim2.fromOffset(8, 8)

SettingsPanel.Size = UDim2.new(1, -16, 0, 0)

SettingsPanel.ZIndex = 3

SettingsPanel.Parent = SettingsPage

createCorner(SettingsPanel, 3)

local settingsTitle = createLabel(SettingsPanel, "Settings", UDim2.fromOffset(14, 10), UDim2.new(1, -28, 0, 24), 14, UI.Text)

settingsTitle.Font = FONT

local settingsDiv = Instance.new("Frame")

settingsDiv.BackgroundColor3 = UI.Border

settingsDiv.BorderSizePixel = 0

settingsDiv.Position = UDim2.fromOffset(0, 38)

settingsDiv.Size = UDim2.new(1, 0, 0, 1)

settingsDiv.Parent = SettingsPanel

-- Smooth Type Dropdown

local typeOptions = {"LERP", "SMOOTHDAMP"}

local typeDropdownContainer, typeDropdown = createDropdown(SettingsPanel, UDim2.fromOffset(12, 44), "Smooth Type", typeOptions, 1, function(value, index)

    SMOOTHNESS_TYPE = value

end)

-- Damp Speed Slider

local dampLabel = createLabel(SettingsPanel, "Damp Speed", UDim2.fromOffset(12, 84), UDim2.new(0.5, -10, 0, 20), 12, UI.TextMuted)

dampLabel.Font = FONT

local dampSliderContainer = Instance.new("Frame")

dampSliderContainer.BackgroundTransparency = 1

dampSliderContainer.Position = UDim2.fromOffset(12, 106)

dampSliderContainer.Size = UDim2.new(1, -24, 0, 22)

dampSliderContainer.Parent = SettingsPanel

local dampSliderBar = Instance.new("Frame")

dampSliderBar.Size = UDim2.fromScale(1, 1)

dampSliderBar.BackgroundColor3 = UI.Surface3

dampSliderBar.BorderSizePixel = 1

dampSliderBar.BorderColor3 = UI.Border

dampSliderBar.Parent = dampSliderContainer

createCorner(dampSliderBar, 3)

local dampSliderFill = Instance.new("Frame")

local dampPct = (SMOOTH_DAMP_SPEED - 1) / 19

dampSliderFill.Size = UDim2.new(dampPct, 0, 1, 0)

dampSliderFill.BackgroundColor3 = UI.Accent

dampSliderFill.BorderSizePixel = 0

dampSliderFill.Parent = dampSliderBar

createCorner(dampSliderFill, 3)

local dampSliderHandle = Instance.new("Frame")

dampSliderHandle.Size = UDim2.fromOffset(14, 28)

dampSliderHandle.Position = UDim2.new(dampPct, -7, 0.5, -14)

dampSliderHandle.BackgroundColor3 = UI.Accent

dampSliderHandle.BorderSizePixel = 1

dampSliderHandle.BorderColor3 = UI.BorderLight

dampSliderHandle.Parent = dampSliderContainer

createCorner(dampSliderHandle, 3)

local dampVal = createLabel(SettingsPanel, tostring(SMOOTH_DAMP_SPEED), UDim2.new(0.5, 10, 0, 84), UDim2.new(0.5, -10, 0, 20), 13, UI.Accent)

dampVal.TextXAlignment = Enum.TextXAlignment.Right

dampVal.Font = FONT

-- Damp slider dragging

local dampDragging = false

local dampDragConn, dampReleaseConn

local function updateDamp(mouseX)

    local pos = dampSliderContainer.AbsolutePosition.X

    local width = dampSliderContainer.AbsoluteSize.X

    if width <= 0 then return end

    local pct = math.clamp((mouseX - pos) / width, 0, 1)

    local val = math.round(1 + pct * 19)

    val = math.clamp(val, 1, 20)

    SMOOTH_DAMP_SPEED = val

    local newPct = (val - 1) / 19

    dampSliderFill.Size = UDim2.new(newPct, 0, 1, 0)

    dampSliderHandle.Position = UDim2.new(newPct, -7, 0.5, -14)

    dampVal.Text = tostring(val)

end

dampSliderHandle.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then

        dampDragging = true

        updateDamp(input.Position.X)

        if dampDragConn then dampDragConn:Disconnect() end

        dampDragConn = UserInputService.InputChanged:Connect(function(input)

            if dampDragging and input.UserInputType == Enum.UserInputType.MouseMovement then

                updateDamp(input.Position.X)

            end

        end)

        if dampReleaseConn then dampReleaseConn:Disconnect() end

        dampReleaseConn = UserInputService.InputEnded:Connect(function(input)

            if input.UserInputType == Enum.UserInputType.MouseButton1 and dampDragging then

                dampDragging = false

                if dampDragConn then dampDragConn:Disconnect(); dampDragConn = nil end

                if dampReleaseConn then dampReleaseConn:Disconnect(); dampReleaseConn = nil end

            end

        end)

    end

end)

dampSliderBar.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then

        updateDamp(input.Position.X)

        dampDragging = true

        if dampDragConn then dampDragConn:Disconnect() end

        dampDragConn = UserInputService.InputChanged:Connect(function(input)

            if dampDragging and input.UserInputType == Enum.UserInputType.MouseMovement then

                updateDamp(input.Position.X)

            end

        end)

        if dampReleaseConn then dampReleaseConn:Disconnect() end

        dampReleaseConn = UserInputService.InputEnded:Connect(function(input)

            if input.UserInputType == Enum.UserInputType.MouseButton1 and dampDragging then

                dampDragging = false

                if dampDragConn then dampDragConn:Disconnect(); dampDragConn = nil end

                if dampReleaseConn then dampReleaseConn:Disconnect(); dampReleaseConn = nil end

            end

        end)

    end

end)

-- FOV Color Picker

local fovColorContainer, fovColorBtn = createColorButton(SettingsPanel, UDim2.fromOffset(12, 144), "FOV Color", FOV_COLOR, function(color)

    FOV_COLOR = color

    updateFOVCircle()

end)

-- FOV Thickness Slider

local thicknessLabel = createLabel(SettingsPanel, "FOV Thickness", UDim2.fromOffset(12, 184), UDim2.new(0.5, -10, 0, 20), 12, UI.TextMuted)

thicknessLabel.Font = FONT

local thicknessSliderContainer = Instance.new("Frame")

thicknessSliderContainer.BackgroundTransparency = 1

thicknessSliderContainer.Position = UDim2.fromOffset(12, 206)

thicknessSliderContainer.Size = UDim2.new(1, -24, 0, 22)

thicknessSliderContainer.Parent = SettingsPanel

local thicknessSliderBar = Instance.new("Frame")

thicknessSliderBar.Size = UDim2.fromScale(1, 1)

thicknessSliderBar.BackgroundColor3 = UI.Surface3

thicknessSliderBar.BorderSizePixel = 1

thicknessSliderBar.BorderColor3 = UI.Border

thicknessSliderBar.Parent = thicknessSliderContainer

createCorner(thicknessSliderBar, 3)

local thicknessSliderFill = Instance.new("Frame")

local thickPct = (FOV_THICKNESS - 1) / 9

thicknessSliderFill.Size = UDim2.new(thickPct, 0, 1, 0)

thicknessSliderFill.BackgroundColor3 = UI.Accent

thicknessSliderFill.BorderSizePixel = 0

thicknessSliderFill.Parent = thicknessSliderBar

createCorner(thicknessSliderFill, 3)

local thicknessSliderHandle = Instance.new("Frame")

thicknessSliderHandle.Size = UDim2.fromOffset(14, 28)

thicknessSliderHandle.Position = UDim2.new(thickPct, -7, 0.5, -14)

thicknessSliderHandle.BackgroundColor3 = UI.Accent

thicknessSliderHandle.BorderSizePixel = 1

thicknessSliderHandle.BorderColor3 = UI.BorderLight

thicknessSliderHandle.Parent = thicknessSliderContainer

createCorner(thicknessSliderHandle, 3)

local thickVal = createLabel(SettingsPanel, tostring(FOV_THICKNESS), UDim2.new(0.5, 10, 0, 184), UDim2.new(0.5, -10, 0, 20), 13, UI.Accent)

thickVal.TextXAlignment = Enum.TextXAlignment.Right

thickVal.Font = FONT

local thickDragging = false

local thickDragConn, thickReleaseConn

local function updateThickness(mouseX)

    local pos = thicknessSliderContainer.AbsolutePosition.X

    local width = thicknessSliderContainer.AbsoluteSize.X

    if width <= 0 then return end

    local pct = math.clamp((mouseX - pos) / width, 0, 1)

    local val = math.round(1 + pct * 9)

    val = math.clamp(val, 1, 10)

    FOV_THICKNESS = val

    local newPct = (val - 1) / 9

    thicknessSliderFill.Size = UDim2.new(newPct, 0, 1, 0)

    thicknessSliderHandle.Position = UDim2.new(newPct, -7, 0.5, -14)

    thickVal.Text = tostring(val)

    updateFOVCircle()

end

thicknessSliderHandle.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then

        thickDragging = true

        updateThickness(input.Position.X)

        if thickDragConn then thickDragConn:Disconnect() end

        thickDragConn = UserInputService.InputChanged:Connect(function(input)

            if thickDragging and input.UserInputType == Enum.UserInputType.MouseMovement then

                updateThickness(input.Position.X)

            end

        end)

        if thickReleaseConn then thickReleaseConn:Disconnect() end

        thickReleaseConn = UserInputService.InputEnded:Connect(function(input)

            if input.UserInputType == Enum.UserInputType.MouseButton1 and thickDragging then

                thickDragging = false

                if thickDragConn then thickDragConn:Disconnect(); thickDragConn = nil end

                if thickReleaseConn then thickReleaseConn:Disconnect(); thickReleaseConn = nil end

            end

        end)

    end

end)

thicknessSliderBar.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then

        updateThickness(input.Position.X)

        thickDragging = true

        if thickDragConn then thickDragConn:Disconnect() end

        thickDragConn = UserInputService.InputChanged:Connect(function(input)

            if thickDragging and input.UserInputType == Enum.UserInputType.MouseMovement then

                updateThickness(input.Position.X)

            end

        end)

        if thickReleaseConn then thickReleaseConn:Disconnect() end

        thickReleaseConn = UserInputService.InputEnded:Connect(function(input)

            if input.UserInputType == Enum.UserInputType.MouseButton1 and thickDragging then

                thickDragging = false

                if thickDragConn then thickDragConn:Disconnect(); thickDragConn = nil end

                if thickReleaseConn then thickReleaseConn:Disconnect(); thickReleaseConn = nil end

            end

        end)

    end

end)

-- ESP Status

local espStatusLabel = createLabel(SettingsPanel, "ESP Status", UDim2.fromOffset(12, 248), UDim2.new(0.5, -10, 0, 28), 12, UI.TextMuted)

espStatusLabel.Font = FONT

settingESP = createLabel(SettingsPanel, "ENABLED", UDim2.new(0.5, 10, 0, 248), UDim2.new(0.5, -10, 0, 28), 13, UI.Green)

settingESP.TextXAlignment = Enum.TextXAlignment.Right

settingESP.Font = FONT

-- FOV Circle Status

local fovStatusLabel = createLabel(SettingsPanel, "FOV Circle", UDim2.fromOffset(12, 280), UDim2.new(0.5, -10, 0, 28), 12, UI.TextMuted)

fovStatusLabel.Font = FONT

settingFOV = createLabel(SettingsPanel, "ON", UDim2.new(0.5, 10, 0, 280), UDim2.new(0.5, -10, 0, 28), 13, UI.Green)

settingFOV.TextXAlignment = Enum.TextXAlignment.Right

settingFOV.Font = FONT


--// Custom Theme Colors (UI only)
do
    local themeTitle = createLabel(
        SettingsPanel,
        "Theme Colors",
        UDim2.fromOffset(12, 316),
        UDim2.new(1, -24, 0, 20),
        13,
        UI.Text
    )
    themeTitle.Font = FONT

    local function replaceColor(root, oldColor, newColor)
        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("GuiObject") then
                if obj.BackgroundColor3 == oldColor then
                    obj.BackgroundColor3 = newColor
                end
                if obj.BorderColor3 == oldColor then
                    obj.BorderColor3 = newColor
                end
            end

            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if obj.TextColor3 == oldColor then
                    obj.TextColor3 = newColor
                end
            end

            if obj:IsA("UIStroke") and obj.Color == oldColor then
                obj.Color = newColor
            end
        end
    end

    createColorButton(
        SettingsPanel,
        UDim2.fromOffset(12, 340),
        "Accent Color",
        UI.Accent,
        function(color)
            local old = UI.Accent
            UI.Accent = color
            replaceColor(Main, old, color)

            -- Keep related accent shades visually coordinated.
            UI.AccentSoft = color:Lerp(Color3.new(1, 1, 1), 0.25)
            UI.AccentDark = color:Lerp(Color3.new(0, 0, 0), 0.30)

            ClassicBlueStroke.Color = color
        end
    )

    createColorButton(
        SettingsPanel,
        UDim2.fromOffset(12, 372),
        "Background Color",
        UI.BG,
        function(color)
            local oldBG = UI.BG
            local oldSurface = UI.Surface
            local oldSurface2 = UI.Surface2
            local oldSurface3 = UI.Surface3

            UI.BG = color
            UI.Surface = color:Lerp(Color3.new(1, 1, 1), 0.035)
            UI.Surface2 = color:Lerp(Color3.new(1, 1, 1), 0.075)
            UI.Surface3 = color:Lerp(Color3.new(1, 1, 1), 0.12)

            replaceColor(Main, oldBG, UI.BG)
            replaceColor(Main, oldSurface, UI.Surface)
            replaceColor(Main, oldSurface2, UI.Surface2)
            replaceColor(Main, oldSurface3, UI.Surface3)

            Main.BackgroundColor3 = UI.BG
            TitleBar.BackgroundColor3 = UI.BG
            Content.BackgroundColor3 = UI.Surface
            ESPPanel.BackgroundColor3 = UI.Surface
            AimlockPanel.BackgroundColor3 = UI.Surface
            SettingsPanel.BackgroundColor3 = UI.Surface
        end
    )

    createColorButton(
        SettingsPanel,
        UDim2.fromOffset(12, 404),
        "Text Color",
        UI.Text,
        function(color)
            local oldText = UI.Text
            local oldMuted = UI.TextMuted
            local oldDim = UI.TextDim

            UI.Text = color
            UI.TextMuted = color:Lerp(UI.BG, 0.25)
            UI.TextDim = color:Lerp(UI.BG, 0.48)

            replaceColor(Main, oldText, UI.Text)
            replaceColor(Main, oldMuted, UI.TextMuted)
            replaceColor(Main, oldDim, UI.TextDim)
        end
    )

    local resetTheme = Instance.new("TextButton")
    resetTheme.Position = UDim2.fromOffset(12, 442)
    resetTheme.Size = UDim2.new(1, -24, 0, 26)
    resetTheme.BackgroundColor3 = UI.Surface3
    resetTheme.BorderSizePixel = 1
    resetTheme.BorderColor3 = UI.Border
    resetTheme.Text = "Reset Theme"
    resetTheme.TextColor3 = UI.Text
    resetTheme.Font = FONT
    resetTheme.TextSize = 13
    resetTheme.AutoButtonColor = false
    resetTheme.Parent = SettingsPanel

    resetTheme.MouseButton1Click:Connect(function()
        local oldAccent = UI.Accent
        local oldBG = UI.BG
        local oldSurface = UI.Surface
        local oldSurface2 = UI.Surface2
        local oldSurface3 = UI.Surface3
        local oldText = UI.Text
        local oldMuted = UI.TextMuted
        local oldDim = UI.TextDim

        UI.BG = Color3.fromRGB(20, 20, 20)
        UI.Surface = Color3.fromRGB(23, 23, 23)
        UI.Surface2 = Color3.fromRGB(27, 27, 27)
        UI.Surface3 = Color3.fromRGB(31, 31, 31)
        UI.Accent = Color3.fromRGB(67, 128, 214)
        UI.AccentDark = Color3.fromRGB(31, 72, 132)
        UI.AccentSoft = Color3.fromRGB(100, 160, 235)
        UI.Text = Color3.fromRGB(220, 220, 220)
        UI.TextMuted = Color3.fromRGB(190, 190, 190)
        UI.TextDim = Color3.fromRGB(125, 125, 125)

        replaceColor(Main, oldAccent, UI.Accent)
        replaceColor(Main, oldBG, UI.BG)
        replaceColor(Main, oldSurface, UI.Surface)
        replaceColor(Main, oldSurface2, UI.Surface2)
        replaceColor(Main, oldSurface3, UI.Surface3)
        replaceColor(Main, oldText, UI.Text)
        replaceColor(Main, oldMuted, UI.TextMuted)
        replaceColor(Main, oldDim, UI.TextDim)

        Main.BackgroundColor3 = UI.BG
        TitleBar.BackgroundColor3 = UI.BG
        Content.BackgroundColor3 = UI.Surface
        ESPPanel.BackgroundColor3 = UI.Surface
        AimlockPanel.BackgroundColor3 = UI.Surface
        SettingsPanel.BackgroundColor3 = UI.Surface
        ClassicBlueStroke.Color = UI.Accent
    end)
end


--// Top Status Bar (UI only)
task.spawn(function()
    local statusGui = Instance.new("ScreenGui")
    statusGui.Name = "WeakLolTopStatus"
    statusGui.ResetOnSpawn = false
    statusGui.IgnoreGuiInset = true
    statusGui.DisplayOrder = 998
    statusGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local statusFrame = Instance.new("Frame")
    statusFrame.Name = "StatusFrame"
    statusFrame.AnchorPoint = Vector2.new(0.5, 0)
    statusFrame.Position = UDim2.new(0.5, 0, 0, 6)
    statusFrame.Size = UDim2.fromOffset(430, 25)
    statusFrame.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
    statusFrame.BackgroundTransparency = 0
    statusFrame.BorderSizePixel = 1
    statusFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    statusFrame.Parent = statusGui

    local statusStroke = Instance.new("UIStroke")
    statusStroke.Color = Color3.fromRGB(45, 45, 45)
    statusStroke.Thickness = 1
    statusStroke.Transparency = 0
    statusStroke.Parent = statusFrame

    local statusText = Instance.new("TextLabel")
    statusText.BackgroundTransparency = 1
    statusText.Position = UDim2.fromOffset(8, 0)
    statusText.Size = UDim2.new(1, -16, 1, 0)
    statusText.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    statusText.TextSize = 13
    statusText.TextColor3 = UI.Text
    statusText.TextXAlignment = Enum.TextXAlignment.Center
    statusText.TextYAlignment = Enum.TextYAlignment.Center
    statusText.RichText = true
    statusText.Parent = statusFrame

    local enabled = true
    getgenv().GohthTopStatusEnabled = true
    getgenv().GohthTopStatusGui = statusGui

    local fps = 0
    local frames = 0
    local elapsed = 0

    local function getPing()
        local ping = 0
        pcall(function()
            local stats = game:GetService("Stats")
            local network = stats.Network
            local serverStats = network and network.ServerStatsItem
            local dataPing = serverStats and serverStats:FindFirstChild("Data Ping")
            if dataPing then
                ping = math.floor(dataPing:GetValue() + 0.5)
            end
        end)
        return ping
    end

    local function refreshText()
        local accent = UI.Accent
        local activeLibrary = getgenv().Library
        if activeLibrary and activeLibrary.Theme and activeLibrary.Theme["Accent"] then
            accent = activeLibrary.Theme["Accent"]
        end

        local accentR = math.floor(accent.R * 255)
        local accentG = math.floor(accent.G * 255)
        local accentB = math.floor(accent.B * 255)
        local currentTime = os.date("%I:%M:%S %p")
        local currentPing = getPing()

        statusText.Text = string.format(
            '<font color="rgb(%d,%d,%d)">✧  gohth.cc (fg cheat)</font>  |  %s  |  %d fps  |  %d ms  |  %s',
            accentR,
            accentG,
            accentB,
            LocalPlayer.Name,
            fps,
            currentPing,
            currentTime
        )
    end

    createToggle(
        SettingsPanel,
        UDim2.fromOffset(12, 476),
        "Top Status Bar",
        true,
        function(value)
            enabled = value == true
            getgenv().GohthTopStatusEnabled = enabled
            statusGui.Enabled = enabled
        end
    )

    RunService.RenderStepped:Connect(function(dt)
        enabled = getgenv().GohthTopStatusEnabled ~= false
        statusGui.Enabled = enabled

        if not enabled then
            return
        end

        frames += 1
        elapsed += dt

        if elapsed >= 0.35 then
            fps = math.floor((frames / elapsed) + 0.5)
            frames = 0
            elapsed = 0
            refreshText()
        end

        -- Keep it matched to the active message (6) menu theme.
        local activeLibrary = getgenv().Library
        if activeLibrary and activeLibrary.Theme then
            local theme = activeLibrary.Theme
            statusFrame.BackgroundColor3 = theme["Background"] or Color3.fromRGB(21, 21, 21)
            statusFrame.BorderColor3 = theme["Border"] or Color3.fromRGB(0, 0, 0)
            statusStroke.Color = theme["Outline"] or Color3.fromRGB(45, 45, 45)
            statusText.TextColor3 = theme["Text"] or Color3.fromRGB(255, 255, 255)
        else
            statusFrame.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
            statusFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            statusStroke.Color = Color3.fromRGB(45, 45, 45)
            statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)

    refreshText()
end)
local settingsTotalHeight = 540

SettingsPanel.Size = UDim2.new(1, -16, 0, settingsTotalHeight)


--// Fragment-style layout pass (UI only)
task.spawn(function()
    -- General dark/flat styling.
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Content.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    Content.BorderColor3 = Color3.fromRGB(5, 5, 5)

    -- Aimbot page = existing Aimlock features.
    AimlockPanel.Position = UDim2.fromOffset(10, 10)
    AimlockPanel.Size = UDim2.fromOffset(238, 265)
    AimlockPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    AimlockPanel.BorderColor3 = Color3.fromRGB(5, 5, 5)
    aimlockTitle.Text = "Aimbot"
    aimlockTitle.Position = UDim2.fromOffset(5, 3)
    aimlockTitle.Size = UDim2.new(1, -10, 0, 18)
    aimlockDiv.Position = UDim2.fromOffset(0, 24)
    aimlockDiv.BackgroundColor3 = UI.Accent

    -- Compact and align the existing aimbot controls.
    aimToggleContainer.Position = UDim2.fromOffset(8, 28)
    keyLabel.Position = UDim2.fromOffset(8, 56)
    keyBtn.Position = UDim2.new(1, -58, 0, 54)
    keyBtn.Size = UDim2.fromOffset(48, 20)

    partDropdownContainer.Position = UDim2.fromOffset(8, 82)
    visCheckContainer.Position = UDim2.fromOffset(8, 112)
    teamCheckContainer.Position = UDim2.fromOffset(8, 138)

    fovLabel.Position = UDim2.fromOffset(8, 168)
    fovSliderContainer.Position = UDim2.fromOffset(8, 188)
    fovSliderContainer.Size = UDim2.new(1, -16, 0, 20)
    fovVal.Position = UDim2.new(1, -58, 0, 166)
    fovVal.Size = UDim2.fromOffset(48, 18)

    -- Smoothness panel on the right.
    local smoothPanel = Instance.new("Frame")
    smoothPanel.Name = "SmoothnessPanel"
    smoothPanel.Position = UDim2.fromOffset(258, 10)
    smoothPanel.Size = UDim2.fromOffset(252, 265)
    smoothPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    smoothPanel.BorderSizePixel = 1
    smoothPanel.BorderColor3 = Color3.fromRGB(5, 5, 5)
    smoothPanel.Parent = AimlockPage

    local smoothTitle = createLabel(smoothPanel, "Smoothness", UDim2.fromOffset(5, 3), UDim2.new(1, -10, 0, 18), 14, UI.Text)
    local smoothAccent = Instance.new("Frame")
    smoothAccent.Position = UDim2.fromOffset(0, 24)
    smoothAccent.Size = UDim2.new(1, 0, 0, 1)
    smoothAccent.BackgroundColor3 = UI.Accent
    smoothAccent.BorderSizePixel = 0
    smoothAccent.Parent = smoothPanel

    smoothToggleContainer.Parent = smoothPanel
    smoothToggleContainer.Position = UDim2.fromOffset(8, 32)

    smoothLabel.Parent = smoothPanel
    smoothLabel.Position = UDim2.fromOffset(8, 62)

    smoothSliderContainer.Parent = smoothPanel
    smoothSliderContainer.Position = UDim2.fromOffset(8, 82)
    smoothSliderContainer.Size = UDim2.new(1, -16, 0, 20)

    smoothVal.Parent = smoothPanel
    smoothVal.Position = UDim2.new(1, -58, 0, 60)
    smoothVal.Size = UDim2.fromOffset(48, 18)

    -- Put secondary aim-related controls into lower panels.
    local hitPanel = Instance.new("Frame")
    hitPanel.Position = UDim2.fromOffset(10, 285)
    hitPanel.Size = UDim2.fromOffset(238, 205)
    hitPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    hitPanel.BorderSizePixel = 1
    hitPanel.BorderColor3 = Color3.fromRGB(5, 5, 5)
    hitPanel.Parent = AimlockPage

    createLabel(hitPanel, "Hitparts", UDim2.fromOffset(5, 3), UDim2.new(1, -10, 0, 18), 14, UI.Text)
    local hpAccent = Instance.new("Frame")
    hpAccent.Position = UDim2.fromOffset(0, 24)
    hpAccent.Size = UDim2.new(1, 0, 0, 1)
    hpAccent.BackgroundColor3 = UI.Accent
    hpAccent.BorderSizePixel = 0
    hpAccent.Parent = hitPanel

    fovToggleContainer.Parent = hitPanel
    fovToggleContainer.Position = UDim2.fromOffset(8, 34)
    statusLabel.Parent = hitPanel
    statusLabel.Position = UDim2.fromOffset(8, 68)
    lockStatus.Parent = hitPanel
    lockStatus.Position = UDim2.new(1, -70, 0, 68)
    targetLabel.Parent = hitPanel
    targetLabel.Position = UDim2.fromOffset(8, 96)
    targetVal.Parent = hitPanel
    targetVal.Position = UDim2.new(1, -120, 0, 96)
    targetVal.Size = UDim2.fromOffset(108, 24)

    local hacksPanel = Instance.new("Frame")
    hacksPanel.Position = UDim2.fromOffset(258, 285)
    hacksPanel.Size = UDim2.fromOffset(252, 205)
    hacksPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    hacksPanel.BorderSizePixel = 1
    hacksPanel.BorderColor3 = Color3.fromRGB(5, 5, 5)
    hacksPanel.Parent = AimlockPage

    createLabel(hacksPanel, "Hacks", UDim2.fromOffset(5, 3), UDim2.new(1, -10, 0, 18), 14, UI.Text)
    local hacksAccent = Instance.new("Frame")
    hacksAccent.Position = UDim2.fromOffset(0, 24)
    hacksAccent.Size = UDim2.new(1, 0, 0, 1)
    hacksAccent.BackgroundColor3 = UI.Accent
    hacksAccent.BorderSizePixel = 0
    hacksAccent.Parent = hacksPanel

    local note = createLabel(hacksPanel, "Existing features preserved", UDim2.fromOffset(8, 36), UDim2.new(1, -16, 0, 20), 13, UI.TextMuted)
    note.TextXAlignment = Enum.TextXAlignment.Center

    -- Visuals page keeps every ESP feature, but uses the same boxed style.
    ESPPanel.Position = UDim2.fromOffset(10, 10)
    ESPPanel.Size = UDim2.fromOffset(238, 205)
    ESPPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ESPPanel.BorderColor3 = Color3.fromRGB(5, 5, 5)
    panelTitle.Position = UDim2.fromOffset(5, 3)
    panelTitle.Size = UDim2.new(1, -10, 0, 18)
    panelDiv.Position = UDim2.fromOffset(0, 24)
    panelDiv.BackgroundColor3 = UI.Accent

    espToggleContainer.Position = UDim2.fromOffset(8, 30)
    chamsToggleContainer.Position = UDim2.fromOffset(8, 56)
    nameToggleContainer.Position = UDim2.fromOffset(8, 82)
    visColorContainer.Position = UDim2.fromOffset(8, 108)
    hidColorContainer.Position = UDim2.fromOffset(8, 136)
    chamsInfo.Position = UDim2.fromOffset(8, 166)

    local visualInfo = Instance.new("Frame")
    visualInfo.Position = UDim2.fromOffset(258, 10)
    visualInfo.Size = UDim2.fromOffset(252, 205)
    visualInfo.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    visualInfo.BorderSizePixel = 1
    visualInfo.BorderColor3 = Color3.fromRGB(5, 5, 5)
    visualInfo.Parent = ESPPage
    createLabel(visualInfo, "Visuals", UDim2.fromOffset(5, 3), UDim2.new(1, -10, 0, 18), 14, UI.Text)
    local viAccent = Instance.new("Frame")
    viAccent.Position = UDim2.fromOffset(0, 24)
    viAccent.Size = UDim2.new(1, 0, 0, 1)
    viAccent.BackgroundColor3 = UI.Accent
    viAccent.BorderSizePixel = 0
    viAccent.Parent = visualInfo
    local viText = createLabel(visualInfo, "ESP / colors / FOV visuals", UDim2.fromOffset(8, 36), UDim2.new(1, -16, 0, 20), 13, UI.TextMuted)
    viText.TextXAlignment = Enum.TextXAlignment.Center

    -- Settings keeps all theme, notification, status-bar, FOV and smooth settings.
    SettingsPanel.Position = UDim2.fromOffset(10, 10)
    SettingsPanel.Size = UDim2.new(1, -20, 0, settingsTotalHeight)
    SettingsPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SettingsPanel.BorderColor3 = Color3.fromRGB(5, 5, 5)
    settingsTitle.Position = UDim2.fromOffset(5, 3)
    settingsTitle.Size = UDim2.new(1, -10, 0, 18)
    settingsDiv.Position = UDim2.fromOffset(0, 24)
    settingsDiv.BackgroundColor3 = UI.Accent

    -- Footer like the reference.
    local footer = Instance.new("Frame")
    footer.Position = UDim2.new(0, 10, 1, -30)
    footer.Size = UDim2.new(1, -20, 0, 22)
    footer.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    footer.BorderSizePixel = 1
    footer.BorderColor3 = Color3.fromRGB(5, 5, 5)
    footer.Parent = Main

    local footerLeft = createLabel(footer, "gohth.cc (fg cheat)", UDim2.fromOffset(8, 0), UDim2.new(0.5, -8, 1, 0), 12, UI.Accent)
    local footerRight = createLabel(footer, "[ roblox ]", UDim2.new(0.5, 0, 0, 0), UDim2.new(0.5, -8, 1, 0), 12, UI.Accent)
    footerRight.TextXAlignment = Enum.TextXAlignment.Right
end)

-- Tab switching

local function setPage(page)

    -- Aimbot uses the existing Aimlock page.
    AimlockPage.Visible = page == "Aimbot"

    -- Visuals uses the existing ESP page.
    ESPPage.Visible = page == "Visuals"

    -- Misc and Settings both keep access to the existing Settings feature page.
    SettingsPage.Visible = page == "Misc" or page == "Settings"

    local tabs = {
        {ESPTab, ESPInd, "Aimbot"},
        {AimlockTab, AimlockInd, "Visuals"},
        {UI.MiscTab, UI.MiscInd, "Misc"},
        {SettingsTab, SettingsInd, "Settings"},
    }

    for _, item in ipairs(tabs) do
        local btn, ind, tabName = item[1], item[2], item[3]
        local selected = page == tabName

        ind.Visible = selected
        btn.TextColor3 = selected and UI.Text or UI.TextMuted
        btn.BackgroundTransparency = 0
        btn.BackgroundColor3 = selected and Color3.fromRGB(29, 29, 29) or Color3.fromRGB(22, 22, 22)
    end

    Title.Text = "✧  gohth.cc (fg cheat)"
    Subtitle.Text = ""
end

ESPTab.MouseButton1Click:Connect(function() setPage("Aimbot") end)
AimlockTab.MouseButton1Click:Connect(function() setPage("Visuals") end)
UI.MiscTab.MouseButton1Click:Connect(function() setPage("Misc") end)
SettingsTab.MouseButton1Click:Connect(function() setPage("Settings") end)

setPage("Aimbot")


task.spawn(function()
    ----------------------------------------------------------------
    --// MESSAGE (6) MENU SWAP
    --// The original gohth.cc (fg cheat) controls remain alive for feature logic,
    --// but the visible menu is replaced by the message (6) library.
    ----------------------------------------------------------------

    --[[
        Made by samet

        example/documentation is at the bottom
        date: 2/22/2026 4:50 PM

        If you have any issues or bugs, please let me know in the ticket or dms.
    ]]

    -- Bad executor support (atleast by a bit)
    cloneref = cloneref or function(Object) return Object end 

    --#region Services
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local HttpService = game:GetService("HttpService")
    local TweenService = game:GetService("TweenService")
    local GuiService = game:GetService("GuiService")
    local CoreGui = cloneref(game:GetService("CoreGui"))
    --#endregion

    gethui = gethui or function() return CoreGui end

    --#region Variables 
    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera
    local GuiInset = GuiService:GetGuiInset().Y
    local Mouse = cloneref(LocalPlayer:GetMouse())
    --#endregion

    local Library = { 
        Flags = { },
        MenuKeybind = tostring(Enum.KeyCode.Insert),

        Directory = "reign",
        Folders = {
            Assets = "/Assets",
            Configs = "/Configs"
        },

        FontSize = 16,

        Animation = {
            Time = 0.3,
            Style = "Quint",
            Direction = "Out"
        },

        Theme = nil,

        -- Ignore below
        Threads = { },
        Connections = { },
        SetFlags = { },

        ThemingStuff = { },
        ThemeMap = { },

        OpenFrames = { },

        Holder = nil,
        UnusedHolder = nil,

        Font = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    } do 
        Library.__index = Library

        local Flags = Library.Flags 
        local SetFlags = Library.SetFlags

        local Keys = {
            ["Unknown"]           = "Unknown",
            ["Backspace"]         = "Back",
            ["Tab"]               = "Tab",
            ["Clear"]             = "Clear",
            ["Return"]            = "Return",
            ["Pause"]             = "Pause",
            ["Escape"]            = "Escape",
            ["Space"]             = "Space",
            ["QuotedDouble"]      = '"',
            ["Hash"]              = "#",
            ["Dollar"]            = "$",
            ["Percent"]           = "%",
            ["Ampersand"]         = "&",
            ["Quote"]             = "'",
            ["LeftParenthesis"]   = "(",
            ["RightParenthesis"]  = " )",
            ["Asterisk"]          = "*",
            ["Plus"]              = "+",
            ["Comma"]             = ",",
            ["Minus"]             = "-",
            ["Period"]            = ".",
            ["Slash"]             = "`",
            ["Three"]             = "3",
            ["Seven"]             = "7",
            ["Eight"]             = "8",
            ["Colon"]             = ":",
            ["Semicolon"]         = ";",
            ["LessThan"]          = "<",
            ["GreaterThan"]       = ">",
            ["Question"]          = "?",
            ["Equals"]            = "=",
            ["At"]                = "@",
            ["LeftBracket"]       = "LeftBracket",
            ["RightBracket"]      = "RightBracked",
            ["BackSlash"]         = "BackSlash",
            ["Caret"]             = "^",
            ["Underscore"]        = "_",
            ["Backquote"]         = "`",
            ["LeftCurly"]         = "{",
            ["Pipe"]              = "|",
            ["RightCurly"]        = "}",
            ["Tilde"]             = "~",
            ["Delete"]            = "Delete",
            ["End"]               = "End",
            ["KeypadZero"]        = "Keypad0",
            ["KeypadOne"]         = "Keypad1",
            ["KeypadTwo"]         = "Keypad2",
            ["KeypadThree"]       = "Keypad3",
            ["KeypadFour"]        = "Keypad4",
            ["KeypadFive"]        = "Keypad5",
            ["KeypadSix"]         = "Keypad6",
            ["KeypadSeven"]       = "Keypad7",
            ["KeypadEight"]       = "Keypad8",
            ["KeypadNine"]        = "Keypad9",
            ["KeypadPeriod"]      = "KeypadP",
            ["KeypadDivide"]      = "KeypadD",
            ["KeypadMultiply"]    = "KeypadM",
            ["KeypadMinus"]       = "KeypadM",
            ["KeypadPlus"]        = "KeypadP",
            ["KeypadEnter"]       = "KeypadE",
            ["KeypadEquals"]      = "KeypadE",
            ["Insert"]            = "Insert",
            ["Home"]              = "Home",
            ["PageUp"]            = "PageUp",
            ["PageDown"]          = "PageDown",
            ["RightShift"]        = "RightShift",
            ["LeftShift"]         = "LeftShift",
            ["RightControl"]      = "RightControl",
            ["LeftControl"]       = "LeftControl",
            ["LeftAlt"]           = "LeftAlt",
            ["RightAlt"]          = "RightAlt"
        }

        -- Folders
        if not isfolder(Library.Directory) then 
            makefolder(Library.Directory)
        end

        for _, Folder in Library.Folders do 
            if not isfolder(Library.Directory .. Folder) then 
                makefolder(Library.Directory .. Folder)
            end
        end

        local Themes = {
            ["Preset"] = {
                ["Background"] = Color3.fromRGB(21, 21, 21),
                ["Section Background"] = Color3.fromRGB(22, 22, 22),
                ["Inline"] = Color3.fromRGB(25, 25, 25),
                ["Tab Background"] = Color3.fromRGB(30, 30, 30),
                ["Element"] = Color3.fromRGB(35, 35, 35),
                ["Text"] = Color3.fromRGB(255, 255, 255),
                ["Inactive Text"] = Color3.fromRGB(100, 100, 100),
                ["Accent"] = Color3.fromRGB(67, 133, 255),
                ["Border"] = Color3.fromRGB(0, 0, 0),
                ["Outline"] = Color3.fromRGB(45, 45, 45),
                ["Hovered Element"] = Color3.fromRGB(45, 45, 45),
            }
        }

        Library.Theme = Themes.Preset

        Library.Exit = function(Self)
            for _, Connection in Library.Connections do 
                Connection:Disconnect()
            end

            for _, Thread in Library.Threads do 
                coroutine.close(Thread)
            end

            if Self.Holder then 
                Self.Holder.Instance:Destroy()
            end

            if Self.UnusedHolder then 
                Self.UnusedHolder.Instance:Destroy()
            end

            Library = nil
            getgenv().Library = nil
        end

        Library.Create = function(Self, Class, Properties)
            local Data = {
                Class = Class,
                Properties = Properties,
                Instance = Instance.new(Class)
            }

            for Index, Property in Properties do 
                if Property == "FontFace" then
                    Data.Instance[Property] = Library.Font
                    continue
                end

                if Property == "TextSize" then 
                    Data.Instance[Property] = Library.FontSize
                    continue
                end

                if Property == "Name" then 
                    Data.Instance[Property] = "\0"
                    continue
                end

                if Class == "TextButton" then 
                    if Property == "AutoButtonColor" then 
                        Data.Instance[Property] = false
                        continue
                    end

                    if Property == "Text" then 
                        Data.Instance[Property] = ""
                        continue
                    end
                end

                Data.Instance[Index] = Property
            end

            return setmetatable(Data, Library)
        end

        Library.Thread = function(Self, Function)
            local NewThread = coroutine.create(Function)
            
            coroutine.wrap(function()
                coroutine.resume(NewThread)
            end)()

            table.insert(Library.Threads, NewThread)
            return NewThread
        end

        Library.Connect = function(Self, Signal, Callback)
            local Connection

            if Self.Instance then
                if Self.Instance[Signal] then 
                    Connection = Self.Instance[Signal]:Connect(Callback)
                else
                    Connection = Signal:Connect(Callback)
                end
            else
                Connection = Signal:Connect(Callback)
            end

            table.insert(Library.Connections, Connection)
            return Connection
        end

        Library.Tween = function(Self, Properties, Info, IsRawItem)
            local Object = Self.Instance or IsRawItem
            Info = Info or TweenInfo.new(Library.Animation.Time, Enum.EasingStyle[Library.Animation.Style], Enum.EasingDirection[Library.Animation.Direction])

            if not Object then 
                return 
            end

            local NewTween = TweenService:Create(Object, Info, Properties)
            NewTween:Play()

            return NewTween
        end

        Library.GetTweenProperty = function(Self, IsRawItem)
            local Object = Self.Instance or IsRawItem

            if not Object then 
                return { }
            end

            if Object:IsA("Frame") then
                return { "BackgroundTransparency" }
            elseif Object:IsA("TextLabel") or Object:IsA("TextButton") then
                return { "TextTransparency", "BackgroundTransparency" }
            elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
                return { "BackgroundTransparency", "ImageTransparency" }
            elseif Object:IsA("ScrollingFrame") then
                return { "BackgroundTransparency", "ScrollBarImageTransparency" }
            elseif Object:IsA("TextBox") then
                return { "TextTransparency", "BackgroundTransparency" }
            elseif Object:IsA("UIStroke") then 
                return { "Transparency" }
            end
        end

        Library.Fade = function(Self, Property, Visibility, IsRawItem)
            local Object = Self.Instance or IsRawItem

            if not Object then 
                return 
            end

            local OldTransparency = Object[Property]
            Object[Property] = Visibility and 1 or OldTransparency

            local NewTween = Library:Tween({
                [Property] = Visibility and OldTransparency or 1
            }, nil, Object)

            Library:Connect(NewTween.Completed, function()
                if not Visibility then 
                    task.wait()
                    Object[Property] = OldTransparency
                end
            end)

            return NewTween
        end

        Library.FadeDescendants = function(Self, Visibility, Callback)
            if Visibility then 
                Self.Instance.Visible = true 
            end

            local NewTween 

            local Children = Self.Instance:GetDescendants()
            table.insert(Children, Self.Instance)

            for _, Child in Children do 
                local TransparencyProperty = Library:GetTweenProperty(Child)

                if not TransparencyProperty then 
                    continue 
                end

                if type(TransparencyProperty) == "table" then
                    for _, Property in TransparencyProperty do
                        NewTween = Library:Fade(Property, Visibility, Child)
                    end
                else
                    NewTween = Library:Fade(TransparencyProperty, Visibility, Child)
                end
            end

            Library:Connect(NewTween.Completed, function()
                if Callback and type(Callback) == "function" then 
                    Callback()
                end

                Self.Instance.Visible = Visibility
            end)
        end

        Library.MakeDraggable = function(Self)
            if not Self.Instance then 
                return
            end
        
            local Gui = Self.Instance
            local Dragging = false 
            local DragStart
            local StartPosition 
        
            local Set = function(Input)
                local DragDelta = Input.Position - DragStart
                local NewX = StartPosition.X.Offset + DragDelta.X
                local NewY = StartPosition.Y.Offset + DragDelta.Y

                local ScreenSize = Gui.Parent.AbsoluteSize
                local GuiSize = Gui.AbsoluteSize
        
                NewX = math.clamp(NewX, 0, ScreenSize.X - GuiSize.X)
                NewY = math.clamp(NewY, 0, ScreenSize.Y - GuiSize.Y)
        
                Self:Tween({Position = UDim2.new(0, NewX, 0, NewY)}, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
            end
        
            local InputChanged
        
            Self:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    DragStart = Input.Position
                    StartPosition = Gui.Position
        
                    if InputChanged then 
                        return
                    end
        
                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Dragging = false
                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end
            end)
        
            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if Dragging then
                        Set(Input)
                    end
                end
            end)
        
            return Dragging
        end

        Library.MakeResizeable = function(Self, Minimum)
            if not Self.Instance then
                return
            end

            local Gui = Self.Instance
            Minimum = Minimum or Vector2.new(420, 380)

            local ActiveCorner = nil
            local StartMouse = nil
            local StartSize = nil
            local FixedPoint = nil

            -- Corner-only resizing is much more stable than mixing edge and
            -- corner handles. The opposite corner stays perfectly fixed.
            local CornerSize = 18

            local function makeCorner(Position, AnchorPoint, Name)
                local Handle = Library:Create("TextButton", {
                    Name = "\0",
                    Parent = Gui,
                    Position = Position,
                    AnchorPoint = AnchorPoint,
                    Size = UDim2.fromOffset(CornerSize, CornerSize),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 99999,
                })

                return {
                    Button = Handle,
                    Name = Name,
                }
            end

            local Corners = {
                makeCorner(UDim2.new(0, 0, 0, 0), Vector2.new(0, 0), "TL"),
                makeCorner(UDim2.new(1, 0, 0, 0), Vector2.new(1, 0), "TR"),
                makeCorner(UDim2.new(0, 0, 1, 0), Vector2.new(0, 1), "BL"),
                makeCorner(UDim2.new(1, 0, 1, 0), Vector2.new(1, 1), "BR"),
            }

            local function beginResize(Corner)
                ActiveCorner = Corner
                StartMouse = UserInputService:GetMouseLocation()
                StartSize = Vector2.new(Gui.AbsoluteSize.X, Gui.AbsoluteSize.Y)

                local Pos = Gui.AbsolutePosition
                local Size = Gui.AbsoluteSize

                -- Save the corner opposite the one being dragged.
                if Corner == "TL" then
                    FixedPoint = Vector2.new(Pos.X + Size.X, Pos.Y + Size.Y)
                elseif Corner == "TR" then
                    FixedPoint = Vector2.new(Pos.X, Pos.Y + Size.Y)
                elseif Corner == "BL" then
                    FixedPoint = Vector2.new(Pos.X + Size.X, Pos.Y)
                else -- BR
                    FixedPoint = Vector2.new(Pos.X, Pos.Y)
                end
            end

            for _, Corner in Corners do
                Corner.Button:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1
                    or Input.UserInputType == Enum.UserInputType.Touch then
                        beginResize(Corner.Name)
                    end
                end)
            end

            Library:Connect(UserInputService.InputEnded, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1
                or Input.UserInputType == Enum.UserInputType.Touch then
                    ActiveCorner = nil
                    StartMouse = nil
                    StartSize = nil
                    FixedPoint = nil
                end
            end)

            Library:Connect(RunService.RenderStepped, function()
                if not ActiveCorner or not StartMouse or not FixedPoint then
                    return
                end

                local Mouse = UserInputService:GetMouseLocation()
                local Delta = Mouse - StartMouse

                local NewW = StartSize.X
                local NewH = StartSize.Y

                if ActiveCorner == "TL" or ActiveCorner == "BL" then
                    NewW = StartSize.X - Delta.X
                else
                    NewW = StartSize.X + Delta.X
                end

                if ActiveCorner == "TL" or ActiveCorner == "TR" then
                    NewH = StartSize.Y - Delta.Y
                else
                    NewH = StartSize.Y + Delta.Y
                end

                NewW = math.max(NewW, Minimum.X)
                NewH = math.max(NewH, Minimum.Y)

                local ParentPos = Gui.Parent.AbsolutePosition
                local Left, Top

                if ActiveCorner == "TL" then
                    Left = FixedPoint.X - NewW
                    Top = FixedPoint.Y - NewH
                elseif ActiveCorner == "TR" then
                    Left = FixedPoint.X
                    Top = FixedPoint.Y - NewH
                elseif ActiveCorner == "BL" then
                    Left = FixedPoint.X - NewW
                    Top = FixedPoint.Y
                else -- BR
                    Left = FixedPoint.X
                    Top = FixedPoint.Y
                end

                -- Window:Center() changes MainFrame to AnchorPoint (0, 0),
                -- so keep the resized frame positioned by its actual top-left.
                -- The old center calculation is what caused the window to jump/drift.
                local RelativeX = Left - ParentPos.X
                local RelativeY = Top - ParentPos.Y

                Gui.Position = UDim2.fromOffset(RelativeX, RelativeY)
                Gui.Size = UDim2.fromOffset(NewW, NewH)
            end)
        end

        Library.IsMouseOverFrame = function(Self)
            if not Self.Instance then 
                return 
            end

            local Object = Self.Instance

            local MousePosition = Vector2.new(Mouse.X, Mouse.Y)

            return MousePosition.X >= Object.AbsolutePosition.X and MousePosition.X <= Object.AbsolutePosition.X + Object.AbsoluteSize.X 
            and MousePosition.Y >= Object.AbsolutePosition.Y and MousePosition.Y <= Object.AbsolutePosition.Y + Object.AbsoluteSize.Y
        end

        Library.CompareVectors = function(Self, PointA, PointB)
            return (PointA.X < PointB.X) or (PointA.Y < PointB.Y)
        end

        Library.IsClipped = function(Self, Column)
            if not Self.Instance then 
                return 
            end

            local Parent = Column
            local Object = Self.Instance

            local BoundryTop = Parent.AbsolutePosition
            local BoundryBottom = BoundryTop + Parent.AbsoluteSize

            local Top = Object.AbsolutePosition
            local Bottom = Top + Object.AbsoluteSize 

            return Library:CompareVectors(Top, BoundryTop) or Library:CompareVectors(BoundryBottom, Bottom)
        end

        Library.SafeCall = function(Self, Function, ...)
            local Arguements = { ... }
            local Success, Result = pcall(Function, table.unpack(Arguements))

            if not Success then
                warn(Result)
                return false
            end

            return Success, Result
        end

        Library.Round = function(Self, Number, Float)
            local Multiplier = 1 / (Float or 1)
            return math.floor(Number * Multiplier) / Multiplier
        end

        Library.GetConfig = function(Self)
            local Config = { }

            local Success, Result = Library:SafeCall(function()
                for Index, Value in Library.Flags do 
                    if type(Value) == "table" and Value.Key then
                        Config[Index] = {Key = tostring(Value.Key), Mode = Value.Mode}
                    elseif type(Value) == "table" and Value.Color then
                        Config[Index] = {Color = "#" .. Value.HexValue, Alpha = Value.Alpha}
                    else
                        Config[Index] = Value
                    end
                end
            end)

            if not Success then
                warn("Failed to get config:\n"..Result)
                return
            end

            return HttpService:JSONEncode(Config)
        end

        Library.LoadConfig = function(Self, Config)
            local Decoded = HttpService:JSONDecode(Config)

            local Success, Result = Library:SafeCall(function()
                for Index, Value in Decoded do 
                    local SetFunction = Library.SetFlags[Index]

                    if not SetFunction then
                        continue
                    end

                    if type(Value) == "table" and Value.Key then 
                        SetFunction(Value)
                    elseif type(Value) == "table" and Value.Color then
                        SetFunction(Value.Color, Value.Alpha)
                    else
                        SetFunction(Value)
                    end
                end
            end)

            return Success, Result
        end

        Library.GetConfigsList = function(Self, Element)
            local List = { }
            local ReturnList = { }

            List = listfiles(Library.Directory .. Library.Folders.Configs)

            for Index = 1, #List do 
                local File = List[Index]

                if File:sub(-5) == ".json" then
                    local Position = File:find(".json", 1, true)
                    local StartPosition = Position

                    local Character = File:sub(Position, Position)
                    while Character ~= "/" and Character ~= "\\" and Character ~= "" do
                        Position = Position - 1
                        Character = File:sub(Position, Position)
                    end

                    if Character == "/" or Character == "\\" then
                        table.insert(ReturnList, File:sub(Position + 1, StartPosition - 1))
                    end
                end
            end

            Element:Refresh(ReturnList)
        end

        Library.AddToTheme = function(Self, Properties)
            local Object = Self.Instance

            local ThemeData = {
                Item = Object,
                Properties = Properties,
            }

            for Property, Value in ThemeData.Properties do
                if type(Value) == "string" then
                    if not Library.Theme[Value] then
                        Object[Property] = Value 
                    end

                    Object[Property] = Library.Theme[Value]
                else
                    Object[Property] = Value()
                end
            end

            table.insert(Library.ThemingStuff, ThemeData)
            Library.ThemeMap[Object] = ThemeData
            return Self
        end

        Library.ChangeItemTheme = function(Self, Properties)
            local Object = Self.Instance

            if not Library.ThemingStuff[Object] then 
                return
            end

            Library.ThemingStuff[Object].Properties = Properties
            Library.ThemingStuff[Object] = Library.ThemeMap[Object]
        end

        Library.ChangeTheme = function(Self, Theme, Color)
            Library.Theme[Theme] = Color

            for _, Item in Library.ThemingStuff do
                for Property, Value in Item.Properties do
                    if type(Value) == "string" and Value == Theme then
                        Item.Item[Property] = Color
                    elseif type(Value) == "function" then
                        Item.Item[Property] = Value()
                    end
                end
            end
        end

        Library.OnHover = function(Self, OnHoverEnter, OnHoverLeave)
            local Object = Self.Instance

            if not Object then 
                return 
            end 

            Library:Connect(Object.MouseEnter, OnHoverEnter)
            Library:Connect(Object.MouseLeave, OnHoverLeave)
        end

        
        Library.GlobalUpdateOpenFrames = function(Self)
            for _, Item in Library.OpenFrames do
                local IsOpen = Item.IsOpen 
                local AttachedButton = Item.AttachedButton
                local Frame = Item.Frame

                local CanUpdateNow = Item.CanUpdateNow 

                if CanUpdateNow and IsOpen then
                    Frame.Position = UDim2.new(0, AttachedButton.AbsolutePosition.X, 0, AttachedButton.AbsolutePosition.Y + AttachedButton.AbsoluteSize.Y + 10 + GuiInset)
                end
            end
        end

        Library.Holder = Library:Create("ScreenGui", {
            Parent = gethui(),
            IgnoreGuiInset = true,
            Name = "\0",
            ZIndexBehavior = Enum.ZIndexBehavior.Global,
            ResetOnSpawn = false
        })

        Library.UnusedHolder = Library:Create("ScreenGui", {
            Parent = gethui(),
            Name = "\0",
            Enabled = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Global,
            ResetOnSpawn = false
        })

        Library.NotifHolder = Library:Create("Frame", {
            Name = "\0",
            Parent = Library.Holder.Instance,
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0, 0, 1, 0),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.X
        })
        
        Library:Create("UIPadding", {
            Name = "\0",
            Parent = Library.NotifHolder.Instance,
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10)
        })
        
        Library:Create("UIListLayout", {
            Name = "\0",
            Parent = Library.NotifHolder.Instance,
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 10)
        })    

        do
            Library.CreateColorpicker = function(Self, Data)
                local Colorpicker = {
                    Hue = 0,
                    Saturation = 0,
                    Value = 0,

                    Alpha = 0,

                    Color = Color3.fromRGB(255, 255, 255),
                    HexValue = "#FFFFFF",

                    Flag = Data.Flag,
                    IsOpen = false,

                    Items = { }
                }

                local Items = { } do 
                    Items["ColorpickerButton"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Data.Parent.Instance,
                        TextColor3 = Library.Theme["Border"],
                        Text = "",
                        AutoButtonColor = false,
                        Size = UDim2.new(0, 24, 0, 15),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 175, 211)
                    }):AddToTheme({TextColor3 = 'Border'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["ColorpickerButton"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline"]
                    }):AddToTheme({Color = 'Outline'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["ColorpickerButton"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Border'})
                    
                    Library:Create("UIGradient", {
                        Name = "\0",
                        Parent = Items["ColorpickerButton"].Instance,
                        Rotation = 90,
                        Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(156, 156, 156))
                    }
                    })
                                    
                    Items["ColorpickerWindow"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Library.UnusedHolder.Instance,
                        Visible = false,
                        TextColor3 = Library.Theme["Border"],
                        Text = "",
                        AutoButtonColor = false,
                        Position = UDim2.new(0, 24, 0, 71),
                        Size = UDim2.new(0, 260, 0, 260),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                    }):AddToTheme({BackgroundColor3 = 'Section Background'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["ColorpickerWindow"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Border'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["ColorpickerWindow"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline"]
                    }):AddToTheme({Color = 'Outline'})
                    
                    Items["RGBInputBackground"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["ColorpickerWindow"].Instance,
                        Interactable = true,
                        AnchorPoint = Vector2.new(0, 1),
                        Position = UDim2.new(0, 8, 1, -8),
                        Size = UDim2.new(1, -16, 0, 20),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Element"]
                    }):AddToTheme({BackgroundColor3 = 'Element'})
                    
                    Library:Create("UIGradient", {
                        Name = "\0",
                        Parent = Items["RGBInputBackground"].Instance,
                        Rotation = 90,
                        Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(156, 156, 156))
                    }
                    })
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["RGBInputBackground"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 1)
                    })
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["RGBInputBackground"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline"]
                    }):AddToTheme({Color = 'Outline'})
                    
                    Items["RGBInput"] = Library:Create("TextBox", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["RGBInputBackground"].Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = "255, 175, 211",
                        Size = UDim2.new(1, -12, 0, 15),
                        Position = UDim2.new(0, 6, 0.5, -1),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        PlaceholderColor3 = Library.Theme["Inactive Text"],
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ClearTextOnFocus = false
                    }):AddToTheme({PlaceholderColor3 = 'Inactive Text', TextColor3 = 'Text'})

                    Items["Hue"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["ColorpickerWindow"].Instance,
                        TextColor3 = Library.Theme["Border"],
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Text = "",
                        AutoButtonColor = false,
                        AnchorPoint = Vector2.new(0, 1),
                        Position = UDim2.new(0, 8, 1, -42),
                        Size = UDim2.new(1, -16, 0, 12),
                        BorderSizePixel = 0
                    }):AddToTheme({TextColor3 = 'Border'})
                    
                    Library:Create("UIGradient", {
                        Name = "\0",
                        Parent = Items["Hue"].Instance,
                        Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                    }
                    })
                    
                    Items["HueDragger"] = Library:Create("Frame", {
                        Name = "\0",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = Items["Hue"].Instance,
                        Size = UDim2.new(0, 1, 1, 0),
                        BorderSizePixel = 0
                    })
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["HueDragger"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 0)
                    }):AddToTheme({Color = 'Border'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Hue"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Border'})
                    
                    Items["Alpha"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["ColorpickerWindow"].Instance,
                        TextColor3 = Library.Theme["Border"],
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Text = "",
                        AutoButtonColor = false,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -8, 0, 8),
                        Size = UDim2.new(0, 12, 1, -72),
                        BorderSizePixel = 0
                    }):AddToTheme({TextColor3 = 'Border'})
                    
                    Items["AlphaGradient"] = Library:Create("UIGradient", {
                        Name = "\0",
                        Parent = Items["Alpha"].Instance,
                        Rotation = 90,
                        Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 171, 211)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                    }
                    })
                    
                    Items["AlphaDragger"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Alpha"].Instance,
                        Size = UDim2.new(1, 0, 0, 1),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderSizePixel = 0
                    })
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["AlphaDragger"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 0)
                    })
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Alpha"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Border'})
                    
                    Items["Palette"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["ColorpickerWindow"].Instance,
                        TextColor3 = Library.Theme["Border"],
                        Text = "",
                        AutoButtonColor = false,
                        Position = UDim2.new(0, 8, 0, 8),
                        Size = UDim2.new(1, -40, 1, -72),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 175, 211)
                    }):AddToTheme({TextColor3 = 'Border'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Palette"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Border'})
                    
                    Items["Saturation"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Palette"].Instance,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    })
                    
                    Library:Create("UIGradient", {
                        Name = "\0",
                        Parent = Items["Saturation"].Instance,
                        Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    }
                    })
                    
                    Items["Value"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Palette"].Instance,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Border"]
                    }):AddToTheme({BackgroundColor3 = 'Border'})
                    
                    Library:Create("UIGradient", {
                        Name = "\0",
                        Parent = Items["Value"].Instance,
                        Rotation = 80,
                        Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    }
                    })
                    
                    Items["PaletteDragger"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Palette"].Instance,
                        Size = UDim2.new(0, 2, 0, 2),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderSizePixel = 0
                    })
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["PaletteDragger"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 0)
                    }):AddToTheme({Color = 'Border'})

                    Colorpicker.Items = Items
                end

                function Colorpicker:SetVisibility(Bool)
                    Items["ColorpickerButton"].Instance.Visible = Bool
                end

                function Colorpicker:Update(IsFromAlpha, Debounce)
                    local Hue, Saturation, Value = Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value
                    Colorpicker.Color = Color3.fromHSV(Hue, Saturation, Value)
                    Colorpicker.HexValue = Colorpicker.Color:ToHex()
            
                    Items["ColorpickerButton"]:Tween({BackgroundColor3 = Colorpicker.Color})
                    Items["Palette"]:Tween({BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)})

                    Flags[Colorpicker.Flag] = {
                        Alpha = Colorpicker.Alpha,
                        Color = Colorpicker.Color,
                        HexValue = Colorpicker.HexValue,
                        Transparency = 1 - Colorpicker.Alpha
                    }

                    if not Debounce then 
                        local Red, Green, Blue = math.floor(Colorpicker.Color.R * 255), math.floor(Colorpicker.Color.G * 255), math.floor(Colorpicker.Color.B * 255)
                        Items["RGBInput"].Instance.Text = Red .. ", " .. Green .. ", " .. Blue
                    end
        
                    if not IsFromAlpha then 
                        Items["AlphaGradient"].Instance.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Colorpicker.Color),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                        }
                    end
        
                    if Data.Callback then 
                        Library:SafeCall(Data.Callback, Colorpicker.Color, Colorpicker.Alpha)
                    end
                end

                local Debounce = false 
                local RenderStepped 
                local ColorpickerWindow = Items["ColorpickerWindow"].Instance
                local ColorpickerButton = Items["ColorpickerButton"].Instance

                Colorpicker.AttachedButton = ColorpickerButton
                Colorpicker.CanUpdateNow = false
                Colorpicker.Frame = ColorpickerWindow

                function Colorpicker:SetOpen(Bool)
                    if Debounce then 
                        return 
                    end

                    Colorpicker.IsOpen = Bool

                    Debounce = true 
                    
                    if Colorpicker.IsOpen then 
                        ColorpickerWindow.Position = UDim2.new(0, ColorpickerButton.AbsolutePosition.X, 0, ColorpickerButton.AbsolutePosition.Y + ColorpickerButton.AbsoluteSize.Y + GuiInset)

                        ColorpickerWindow.Parent = Library.Holder.Instance
                        ColorpickerWindow.Visible = true
                        Items["ColorpickerWindow"]:Tween({Position = UDim2.new(0, ColorpickerButton.AbsolutePosition.X, 0, ColorpickerButton.AbsolutePosition.Y + ColorpickerButton.AbsoluteSize.Y + 10 + GuiInset)})
                        
                        Items["ColorpickerWindow"]:FadeDescendants(true, function()
                            Colorpicker.CanUpdateNow = true
                            Debounce = false
                        end)

                        for Index, Value in Library.OpenFrames do 
                            Value:SetOpen(false)
                        end

                        Library.OpenFrames[Colorpicker] = Colorpicker 
                    else
                        Items["ColorpickerWindow"]:Tween({Position = UDim2.new(0, ColorpickerButton.AbsolutePosition.X, 0, ColorpickerButton.AbsolutePosition.Y + ColorpickerButton.AbsoluteSize.Y - 10 + GuiInset)})
                        Items["ColorpickerWindow"]:FadeDescendants(false, function()
                            ColorpickerWindow.Parent = Library.UnusedHolder.Instance
                            Colorpicker.CanUpdateNow = false
                            Debounce = false
                        end)

                        if Library.OpenFrames[Colorpicker] then 
                            Library.OpenFrames[Colorpicker] = nil
                        end

                        if RenderStepped then 
                            RenderStepped:Disconnect()
                            RenderStepped = nil
                        end
                    end

                    local Descendants = ColorpickerWindow:GetDescendants()
                    table.insert(Descendants, ColorpickerWindow)

                    for Index, Value in Descendants do 
                        if Value.ClassName:find("UI") then
                            continue
                        end

                        Value.ZIndex = Colorpicker.IsOpen and 4 or 1
                    end

                    Items["PaletteDragger"].Instance.ZIndex = 5
                    Items["HueDragger"].Instance.ZIndex = 5
                    Items["AlphaDragger"].Instance.ZIndex = 5
                    Items["RGBInput"].Instance.ZIndex = 9
                end
        
                local SlidingPalette = false
                local PaletteChanged
                
                function Colorpicker:SlidePalette(Input)
                    if not Input or not SlidingPalette then
                        return
                    end
        
                    local ValueX = math.clamp(1 - (Input.Position.X - Items["Palette"].Instance.AbsolutePosition.X) / Items["Palette"].Instance.AbsoluteSize.X, 0, 1)
                    local ValueY = math.clamp(1 - (Input.Position.Y - Items["Palette"].Instance.AbsolutePosition.Y) / Items["Palette"].Instance.AbsoluteSize.Y, 0, 1)
        
                    Colorpicker.Saturation = ValueX
                    Colorpicker.Value = ValueY
        
                    local SlideX = math.clamp((Input.Position.X - Items["Palette"].Instance.AbsolutePosition.X) / Items["Palette"].Instance.AbsoluteSize.X, 0, 1)
                    local SlideY = math.clamp((Input.Position.Y - Items["Palette"].Instance.AbsolutePosition.Y) / Items["Palette"].Instance.AbsoluteSize.Y, 0, 1)
        
                    Items["PaletteDragger"]:Tween({Position = UDim2.new(SlideX, 0, SlideY, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                    Colorpicker:Update()
                end
                
                local SlidingHue = false
                local HueChanged
        
                function Colorpicker:SlideHue(Input)
                    if not Input or not SlidingHue then
                        return
                    end
                    
                    local ValueX = math.clamp((Input.Position.X - Items["Hue"].Instance.AbsolutePosition.X) / Items["Hue"].Instance.AbsoluteSize.X, 0, 1)
        
                    Colorpicker.Hue = ValueX
        
                    local SlideX = math.clamp((Input.Position.X - Items["Hue"].Instance.AbsolutePosition.X) / Items["Hue"].Instance.AbsoluteSize.X, 0, 1)
        
                    Items["HueDragger"]:Tween({Position = UDim2.new(SlideX, 0, 0, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                    Colorpicker:Update()
                end
        
                local SlidingAlpha = false 
                local AlphaChanged
        
                function Colorpicker:SlideAlpha(Input)
                    if not Input or not SlidingAlpha then
                        return
                    end
        
                    local ValueY = math.clamp((Input.Position.Y - Items["Alpha"].Instance.AbsolutePosition.Y) / Items["Alpha"].Instance.AbsoluteSize.Y, 0, 1)
        
                    Colorpicker.Alpha = ValueY
        
                    local SlideY = math.clamp((Input.Position.Y - Items["Alpha"].Instance.AbsolutePosition.Y) / Items["Alpha"].Instance.AbsoluteSize.Y, 0, 1)
        
                    Items["AlphaDragger"]:Tween({Position = UDim2.new(0, 0, SlideY, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                    Colorpicker:Update(true)
                end
        
                function Colorpicker:Set(Color, Alpha, Debounce)
                    if type(Color) == "table" then
                        Color = Color3.fromRGB(Color[1], Color[2], Color[3])
                    elseif type(Color) == "string" then
                        Color = Color3.fromHex(Color)
                    else
                        Color = Color -- lul
                    end 

                    Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value = Color:ToHSV()
                    Colorpicker.Alpha = Alpha or 0  
        
                    local PaletteValueX = math.clamp(1 - Colorpicker.Saturation, 0, 1)
                    local PaletteValueY = math.clamp(1 - Colorpicker.Value, 0, 1)
        
                    local AlphaPositionY = math.clamp(Colorpicker.Alpha, 0, 1)
                        
                    local HuePositionX = math.clamp(Colorpicker.Hue, 0, 1)
        
                    Items["PaletteDragger"]:Tween({Position = UDim2.new(PaletteValueX, 0, PaletteValueY, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                    Items["HueDragger"]:Tween({Position = UDim2.new(HuePositionX, 0, 0, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                    Items["AlphaDragger"]:Tween({Position = UDim2.new(0, 0, AlphaPositionY, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                    Colorpicker:Update(false, Debounce)
                end

                Items["ColorpickerButton"]:Connect("MouseButton1Down", function()
                    Colorpicker:SetOpen(not Colorpicker.IsOpen)
                end)
        
                Items["Palette"]:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        SlidingPalette = true 
        
                        Colorpicker:SlidePalette(Input)
        
                        if PaletteChanged then
                            return
                        end
        
                        PaletteChanged = Input.Changed:Connect(function()
                            if Input.UserInputState == Enum.UserInputState.End then
                                SlidingPalette = false
        
                                PaletteChanged:Disconnect()
                                PaletteChanged = nil
                            end
                        end)
                    end
                end)
        
                Items["Hue"]:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        SlidingHue = true 
        
                        Colorpicker:SlideHue(Input)
        
                        if HueChanged then
                            return
                        end
        
                        HueChanged = Input.Changed:Connect(function()
                            if Input.UserInputState == Enum.UserInputState.End then
                                SlidingHue = false
        
                                HueChanged:Disconnect()
                                HueChanged = nil
                            end
                        end)
                    end
                end)
        
                Items["Alpha"]:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        SlidingAlpha = true 
        
                        Colorpicker:SlideAlpha(Input)
        
                        if AlphaChanged then
                            return
                        end
        
                        AlphaChanged = Input.Changed:Connect(function()
                            if Input.UserInputState == Enum.UserInputState.End then
                                SlidingAlpha = false
        
                                AlphaChanged:Disconnect()
                                AlphaChanged = nil
                            end
                        end)
                    end
                end)

                Library:Connect(Items["RGBInput"].Instance:GetPropertyChangedSignal("Text"), function()
                    local Text = Items["RGBInput"].Instance.Text

                    local Red, Green, Blue = Text:match("(%d+),%s*(%d+),%s*(%d+)")
                    Red, Green, Blue = tonumber(Red), tonumber(Green), tonumber(Blue)

                    Colorpicker:Set({Red, Green, Blue}, Colorpicker.Alpha, true)
                end)
        
                Library:Connect(UserInputService.InputChanged, function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                        if SlidingPalette then 
                            Colorpicker:SlidePalette(Input)
                        end
        
                        if SlidingHue then
                            Colorpicker:SlideHue(Input)
                        end
        
                        if SlidingAlpha then
                            Colorpicker:SlideAlpha(Input)
                        end
                    end
                end)
        
                Library:Connect(UserInputService.InputBegan, function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        if not Colorpicker.IsOpen then
                            return
                        end
        
                        if Items["ColorpickerWindow"]:IsMouseOverFrame() then
                            return
                        end
        
                        Colorpicker:SetOpen(false)
                    end
                end)
        
                if Data.Default then
                    Colorpicker:Set(Data.Default, Data.Alpha)
                end
        
                SetFlags[Colorpicker.Flag] = function(Value, Alpha)
                    Colorpicker:Set(Value, Alpha)
                end

                return Colorpicker, Items 
            end

            Library.CreateKeybind = function(Self, Data)
                local Keybind = {
                    Flag = Data.Flag,
                    IsOpen = false,

                    Key = "",
                    Mode = "",
                    Value = "",

                    Toggled = false,
                    Picking = false,

                    Items = { } 
                }

                local Items = { } do
                    Items["KeyButton"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = 14,
                        Parent = Data.Parent.Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = "..",
                        AutoButtonColor = false,
                        Size = UDim2.new(0, 0, 1, 0),
                        TextXAlignment = Enum.TextXAlignment.Right,
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundColor3 = Library.Theme["Element"]
                    }):AddToTheme({BackgroundColor3 = 'Element', TextColor3 = 'Text'})

                    Items["KeyButton"]:OnHover(function()
                        Items["KeyButton"]:Tween({BackgroundColor3 = Library.Theme["Hovered Element"]})
                    end, function()
                        Items["KeyButton"]:Tween({BackgroundColor3 = Library.Theme["Element"]})
                    end)
                    
                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["KeyButton"].Instance,
                        PaddingBottom = UDim.new(0, 3),
                        PaddingRight = UDim.new(0, 7),
                        PaddingLeft = UDim.new(0, 7)
                    })
                    
                    Library:Create("UIGradient", {
                        Name = "\0",
                        Parent = Items["KeyButton"].Instance,
                        Rotation = 90,
                        Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(156, 156, 156))
                    }
                    })
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["KeyButton"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline"]
                    }):AddToTheme({Color = 'Outline'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["KeyButton"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Border'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["KeyButton"].Instance,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })                

                    Items["KeybindWindow"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Library.UnusedHolder.Instance,
                        Visible = false,
                        TextColor3 = Library.Theme["Border"],
                        Text = "",
                        AutoButtonColor = false,
                        Position = UDim2.new(0, 24, 0, 528),
                        Size = UDim2.new(0, 269, 0, 56),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Background"]
                    }):AddToTheme({BackgroundColor3 = 'Background'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["KeybindWindow"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline"]
                    }):AddToTheme({Color = 'Outline'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["KeybindWindow"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Border'})
                    
                    Keybind.Items = Items
                end

                local KeybindObject 

                if Library.KeyList then 
                    KeybindObject = Library.KeyList:Add("", "", "")
                end

                local Update = function()
                    if KeybindObject then 
                        KeybindObject:SetStatus(Keybind.Toggled)
                        KeybindObject:Set(Data.Name, Keybind.Value, Keybind.Mode)
                    end
                end

                local Debounce = false
                local RenderStepped  
                local KeybindWindow = Items["KeybindWindow"].Instance
                local KeyButton = Items["KeyButton"].Instance

                local ModeDropdown = Library:Dropdown({
                    Name = "Mode",
                    Flag = Keybind.Flag .. "ModeDropdown",
                    Parent = Items["KeybindWindow"],
                    Items = { "Toggle", "Hold", "Always" },
                    Default = "Toggle",
                    Callback = function(Value)
                        Keybind.Mode = Value

                        Flags[Keybind.Flag] = {
                            Mode = Keybind.Mode,
                            Key = Keybind.Key,
                            Toggled = Keybind.Toggled
                        }

                        if Data.Callback then 
                            Library:SafeCall(Data.Callback, Keybind.Toggled)
                        end

                        Update()
                    end
                })

                ModeDropdown.Items.Dropdown.Instance.Position = UDim2.new(0, 6, 0, 6)
                ModeDropdown.Items.Dropdown.Instance.Size = UDim2.new(1, -12, 0, 41)

                Keybind.AttachedButton = KeyButton
                Keybind.CanUpdateNow = false
                Keybind.Frame = KeybindWindow

                function Keybind:SetOpen(Bool)
                    if Debounce then 
                        return 
                    end

                    Keybind.IsOpen = Bool

                    Debounce = true 
                    
                    if Keybind.IsOpen then 
                        KeybindWindow.Position = UDim2.new(0, KeyButton.AbsolutePosition.X, 0, KeyButton.AbsolutePosition.Y + KeyButton.AbsoluteSize.Y + GuiInset)

                        KeybindWindow.Parent = Library.Holder.Instance
                        KeybindWindow.Visible = true
                        Items["KeybindWindow"]:Tween({Position = UDim2.new(0, KeyButton.AbsolutePosition.X, 0, KeyButton.AbsolutePosition.Y + KeyButton.AbsoluteSize.Y + 10 + GuiInset)})
                        
                        Items["KeybindWindow"]:FadeDescendants(true, function()
                            Debounce = false 
                            Keybind.CanUpdateNow = true
                        end)

                        for Index, Value in Library.OpenFrames do 
                            Value:SetOpen(false)
                        end

                        Library.OpenFrames[Keybind] = Keybind 
                    else
                        Items["KeybindWindow"]:Tween({Position = UDim2.new(0, KeyButton.AbsolutePosition.X, 0, KeyButton.AbsolutePosition.Y + KeyButton.AbsoluteSize.Y - 10 + GuiInset)})
                        Items["KeybindWindow"]:FadeDescendants(false, function()
                            Items["KeybindWindow"].Instance.Parent = Library.UnusedHolder.Instance
                            Debounce = false
                            Keybind.CanUpdateNow = false
                        end)

                        if Library.OpenFrames[Keybind] then 
                            Library.OpenFrames[Keybind] = nil
                        end

                        if RenderStepped then 
                            RenderStepped:Disconnect()
                            RenderStepped = nil
                        end
                    end

                    local Descendants = KeybindWindow:GetDescendants()
                    table.insert(Descendants, KeybindWindow)

                    for Index, Value in Descendants do 
                        if Value.ClassName:find("UI") then
                            continue
                        end

                        Value.ZIndex = Keybind.IsOpen and 4 or 1
                    end
                end
        
                function Keybind:SetMode(Mode)
                    ModeDropdown:Set(Mode)

                    Flags[Keybind.Flag] = {
                        Mode = Keybind.Mode,
                        Key = Keybind.Key,
                        Toggled = Keybind.Toggled
                    }
        
                    if Data.Callback then 
                        Library:SafeCall(Data.Callback, Keybind.Toggled)
                    end

                    Update()
                end
        
                function Keybind:Press(Bool)
                    if Keybind.Mode == "Toggle" then 
                        Keybind.Toggled = not Keybind.Toggled
                    elseif Keybind.Mode == "Hold" then 
                        Keybind.Toggled = Bool
                    elseif Keybind.Mode == "Always" then 
                        Keybind.Toggled = true
                    end
        
                    Flags[Keybind.Flag] = {
                        Mode = Keybind.Mode,
                        Key = Keybind.Key,
                        Toggled = Keybind.Toggled
                    }
        
                    if Data.Callback then 
                        Library:SafeCall(Data.Callback, Keybind.Toggled)
                    end

                    Update()
                end
        
                function Keybind:Set(Key)
                    if string.find(tostring(Key), "Enum") then 
                        Keybind.Key = tostring(Key)
        
                        Key = Key.Name == "Backspace" and ".." or Key.Name
        
                        local KeyString = Keys[Keybind.Key] or string.gsub(Key, "Enum.", "") or ".."
                        local TextToDisplay = string.gsub(string.gsub(KeyString, "KeyCode.", ""), "UserInputType.", "") or ".."
        
                        Keybind.Value = TextToDisplay
                        Items["KeyButton"].Instance.Text = TextToDisplay
        
                        Flags[Keybind.Flag] = {
                            Mode = Keybind.Mode,
                            Key = Keybind.Key,
                            Toggled = Keybind.Toggled
                        }
        
                        if Data.Callback then 
                            Library:SafeCall(Data.Callback, Keybind.Toggled)
                        end

                        Update()
                    elseif type(Key) == "table" then
                        local RealKey = Key.Key == "Backspace" and ".." or Key.Key
                        Keybind.Key = tostring(Key.Key)
        
                        if Key.Mode then
                            Keybind.Mode = Key.Mode
                            Keybind:SetMode(Key.Mode)
                        else
                            Keybind.Mode = "Toggle"
                            Keybind:SetMode("Toggle")
                        end
        
                        local KeyString = Keys[Keybind.Key] or string.gsub(tostring(RealKey), "Enum.", "") or RealKey
                        local TextToDisplay = KeyString and string.gsub(string.gsub(KeyString, "KeyCode.", ""), "UserInputType.", "") or ".."
        
                        TextToDisplay = string.gsub(string.gsub(KeyString, "KeyCode.", ""), "UserInputType.", "")
        
                        Keybind.Value = TextToDisplay
                        Items["KeyButton"].Instance.Text = TextToDisplay
        
                        if Data.Callback then 
                            Library:SafeCall(Data.Callback, Keybind.Toggled)
                        end

                        Update()
                    elseif table.find({"Toggle", "Hold", "Always"}, Key) then
                        Keybind.Mode = Key
                        Keybind:SetMode(Key)
        
                        if Data.Callback then 
                            Library:SafeCall(Data.Callback, Keybind.Toggled)
                        end

                        Update()
                    end

                    Keybind.Picking = false
                end
        
                Items["KeyButton"]:Connect("MouseButton1Click", function()
                    if Keybind.Disabled then 
                        return 
                    end

                    Keybind.Picking = true 
        
                    Items["KeyButton"].Instance.Text = ".."
        
                    local InputBegan
                    InputBegan = UserInputService.InputBegan:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.Keyboard then 
                            Keybind:Set(Input.KeyCode)
                        else
                            Keybind:Set(Input.UserInputType)
                        end
        
                        InputBegan:Disconnect()
                        InputBegan = nil
                    end)
                end)
        
                Library:Connect(UserInputService.InputBegan, function(Input, GPE)
                    if Keybind.Value == "None" then
                        return
                    end
        
                    if not GPE then
                        if tostring(Input.KeyCode) == Keybind.Key then
                            if Keybind.Mode == "Toggle" then 
                                Keybind:Press()
                            elseif Keybind.Mode == "Hold" then 
                                Keybind:Press(true)
                            elseif Keybind.Mode == "Always" then 
                                Keybind:Press(true)
                            end
                        elseif tostring(Input.UserInputType) == Keybind.Key then
                            if Keybind.Mode == "Toggle" then 
                                Keybind:Press()
                            elseif Keybind.Mode == "Hold" then 
                                Keybind:Press(true)
                            elseif Keybind.Mode == "Always" then 
                                Keybind:Press(true)
                            end
                        end
                    end
            
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        if not Keybind.IsOpen then
                            return
                        end
        
                        if Items["KeybindWindow"]:IsMouseOverFrame() or ModeDropdown.Items.OptionHolder:IsMouseOverFrame() then
                            return
                        end
        
                        Keybind:SetOpen(false)
                    end
                end)
        
                Library:Connect(UserInputService.InputEnded, function(Input, GPE)
                    if GPE then
                        return
                    end

                    if Keybind.Value == "None" then
                        return
                    end
        
                    if tostring(Input.KeyCode) == Keybind.Key then
                        if Keybind.Mode == "Hold" then 
                            Keybind:Press(false)
                        elseif Keybind.Mode == "Always" then 
                            Keybind:Press(true)
                        end
                    elseif tostring(Input.UserInputType) == Keybind.Key then
                        if Keybind.Mode == "Hold" then 
                            Keybind:Press(false)
                        elseif Keybind.Mode == "Always" then 
                            Keybind:Press(true)
                        end
                    end
                end)
        
                Items["KeyButton"]:Connect("MouseButton2Down", function()
                    Keybind:SetOpen(not Keybind.IsOpen)
                end)
        
                if Data.Default then 
                    Keybind:Set({
                        Mode = Data.Mode or "Toggle",
                        Key = Data.Default,
                    })
                end
        
                SetFlags[Keybind.Flag] = function(Value)
                    Keybind:Set(Value)
                end

                return Keybind, Items 
            end

            Library.Notification = function(Self, Name, Duration, Color)
                local Items = { } do 
                    Items["Notification"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Library.NotifHolder.Instance,
                        Size = UDim2.new(0, 0, 0, 28),
                        Position = UDim2.new(0, 1155, 0, 77),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundColor3 = Library.Theme["Background"]
                    }):AddToTheme({BackgroundColor3 = 'Background'})
                    
                    Items["Stroke"] = Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Notification"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline"]
                    }):AddToTheme({Color = 'Outline'})
                    
                    Items["Stroke2"] = Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Notification"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Border'})
                    
                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["Notification"].Instance,
                        TextColor3 = Library.Theme["Text"],
                        TextStrokeColor3 = Library.Theme["Text"],
                        Text = Name,
                        Size = UDim2.new(0, 0, 0, 15),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0.5, -1),
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextStrokeColor3 = 'Text'})
                    
                    Items["Stroke3"] = Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })
                    
                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["Notification"].Instance,
                        PaddingRight = UDim.new(0, 12),
                        PaddingLeft = UDim.new(0, 8)
                    })
                    
                    Items["Liner"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Notification"].Instance,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, 12, 0, 0),
                        Size = UDim2.new(0, 1, 1, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color
                    })                
                end

                for Index, Value in Items do 
                    if Value.Instance:IsA("Frame") then
                        Value.Instance.BackgroundTransparency = 1
                    elseif Value.Instance:IsA("TextLabel") then 
                        Value.Instance.TextTransparency = 1
                    elseif Value.Instance:IsA("UIStroke") then 
                        Value.Instance.Transparency = 1
                    end
                end 

                local GetSize = function()
                    local AbsSize = Items["Notification"].Instance.AbsoluteSize
                    Items["Notification"].Instance.AutomaticSize = Enum.AutomaticSize.None
                    task.wait()
                    Items["Notification"].Instance.Size = UDim2.new(0, AbsSize.X, 0, AbsSize.Y)
                    return AbsSize
                end

                local Size = GetSize()
                task.wait()
                Items["Notification"].Instance.Size = UDim2.new(0, 0, 0, Size.Y)

                local Info = TweenInfo.new(0.85, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0)

                Library:Thread(function()
                    for Index, Value in Items do 
                        if Value.Instance:IsA("Frame") then
                            Value:Tween({BackgroundTransparency = 0}, Info)
                        elseif Value.Instance:IsA("TextLabel") then 
                            Value:Tween({TextTransparency = 0}, Info)
                        elseif Value.Instance:IsA("UIStroke") then 
                            Value:Tween({Transparency = 0}, Info)
                        end
                    end

                    Items["Notification"]:Tween({Size = UDim2.new(0, Size.X, 0, Size.Y)}, Info)

                    task.delay(Duration + 0.1, function()
                        for Index, Value in Items do 
                            if Value.Instance:IsA("Frame") then
                                Value:Tween({BackgroundTransparency = 1})
                            elseif Value.Instance:IsA("TextLabel") then 
                                Value:Tween({TextTransparency = 1})
                            elseif Value.Instance:IsA("UIStroke") then 
                                Value:Tween({Transparency = 1})
                            end
                        end

                        Items["Notification"]:Tween({Size = UDim2.new(0, 0, 0, Size.Y)}, Info)
                        task.wait(0.5)
                        Items["Notification"].Instance:Destroy()
                    end)
                end)
            end

            Library.Watermark = function(Self, Params)
                Params = Params or { }

                local Watermark = {
                    Items = { }
                }

                local Items = { } do 
                    Items["Watermark"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Library.Holder.Instance,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 10 + GuiInset),
                        Size = UDim2.new(0, 0, 0, 28),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    })
                    
                    Items["Watermark"]:MakeDraggable()
                    
                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["Watermark"].Instance,
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0, 8),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })
                    
                    Items["Main"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Watermark"].Instance,
                        Size = UDim2.new(0, 0, 1, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundColor3 = Library.Theme["Background"]
                    }):AddToTheme({BackgroundColor3 = 'Background'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Main"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline"]
                    }):AddToTheme({Color = 'Outline'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Main"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Border'})
                    
                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["Main"].Instance,
                        PaddingRight = UDim.new(0, 8),
                        PaddingLeft = UDim.new(0, 8)
                    })
                    
                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["Main"].Instance,
                        RichText = true,
                        TextColor3 = Library.Theme["Text"],
                        Text = Params.Name,
                        Size = UDim2.new(0, 0, 0, 15),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0.5, -1),
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })                

                    Watermark.Items = Items
                end

                function Watermark:AddItem(Text)
                    local NewItems = { }
                    local NewItem = { }

                    NewItems["NewItem"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Watermark"].Instance,
                        Size = UDim2.new(0, 0, 1, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundColor3 = Library.Theme["Background"]
                    }):AddToTheme({BackgroundColor3 = 'Background'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = NewItems["NewItem"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline"]
                    }):AddToTheme({Color = 'Outline'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = NewItems["NewItem"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Border'})
                    
                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = NewItems["NewItem"].Instance,
                        PaddingRight = UDim.new(0, 8),
                        PaddingLeft = UDim.new(0, 8)
                    })
                    
                    NewItems["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = NewItems["NewItem"].Instance,
                        RichText = true,
                        TextColor3 = Library.Theme["Text"],
                        Text = Text,
                        Size = UDim2.new(0, 0, 0, 15),
                        AnchorPoint = Vector2.new(0, 0.5),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0.5, -1),
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = NewItems["Text"].Instance,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })
                    
                    function NewItem:Set(Text)
                        NewItems["Text"].Instance.Text = Text
                    end

                    return NewItem, NewItems
                end

                return Watermark 
            end

            Library.KeybindList = function(Self, Params)
                Params = Params or { }

                local KeybindList = { }
                Library.KeyList = KeybindList

                local Items = { } do 
                    Items["KeybindList"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Library.Holder.Instance,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 15, 0.5, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.XY,
                        BackgroundColor3 = Library.Theme["Background"]
                    }):AddToTheme({BackgroundColor3 = 'Background'})
                    
                    Items["KeybindList"]:MakeDraggable()
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["KeybindList"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline"]
                    }):AddToTheme({Color = 'Outline'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["KeybindList"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Border'})
                    
                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        RichText = true,
                        TextSize = Library.FontSize,
                        Parent = Items["KeybindList"].Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = Params.Name,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 15),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })
                    
                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["KeybindList"].Instance,
                        PaddingTop = UDim.new(0, 8),
                        PaddingBottom = UDim.new(0, 8),
                        PaddingRight = UDim.new(0, 8),
                        PaddingLeft = UDim.new(0, 8)
                    })
                    
                    Items["Liner"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["KeybindList"].Instance,
                        Position = UDim2.new(0, 0, 0, 25),
                        Size = UDim2.new(1, 0, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Accent"]
                    }):AddToTheme({BackgroundColor3 = 'Accent'})
                    
                    Items["Content"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["KeybindList"].Instance,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 40),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.XY
                    })
                    
                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["Content"].Instance,
                        Padding = UDim.new(0, 8),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })
                end

                function KeybindList:SetVisible(Bool)
                    Items["KeybindList"].Instance.Visible = Bool
                end

                function KeybindList:Center()
                    local AbsPos = Items["KeybindList"].Instance.AbsolutePosition
                    Items["KeybindList"].Instance.AnchorPoint = Vector2.new(0, 0)
                    task.wait()
                    Items["KeybindList"].Instance.Position = UDim2.new(0, AbsPos.X, 0, AbsPos.Y + GuiInset)
                end

                function KeybindList:Add(Name, Key, Mode)
                    local NewKey = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Content"].Instance,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 20),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    })
                    
                    local NewKeyLiner = Library:Create("Frame", {
                        Name = "\0",
                        Parent = NewKey.Instance,
                        Size = UDim2.new(0, 1, 1, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Accent"]
                    }):AddToTheme({BackgroundColor3 = 'Accent'})
                    
                    local NewKeyText = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = NewKey.Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = Name .. " - " .. Key .. " - " .. Mode,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Size = UDim2.new(0, 0, 0, 15),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0.5, -2),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})
                    
                    local NewKeyStroke = Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = NewKeyText.Instance,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })                

                    function NewKey:Set(Name, Key, Mode)
                        NewKeyText.Instance.Text = Name .. " - " .. Key .. " - " .. Mode
                    end

                    function NewKey:SetStatus(Bool)
                        if Bool then 
                            NewKey.Instance.Visible = true

                            NewKeyText:Tween({TextTransparency = 0})
                            NewKeyLiner:Tween({BackgroundTransparency = 0})
                            NewKeyStroke:Tween({Transparency = 0})

                            NewKey:Tween({Size = UDim2.new(0, 0, 0, 20)})

                        else
                            NewKeyText:Tween({TextTransparency = 1})
                            NewKeyLiner:Tween({BackgroundTransparency = 1})
                            NewKeyStroke:Tween({Transparency = 1})

                            NewKey:Tween({Size = UDim2.new(0, 0, 0, 0)})
                            
                            task.wait(Library.Animation.Time)

                            NewKey.Instance.Visible = false
                        end
                    end

                    return NewKey
                end

                KeybindList:Center()

                return KeybindList
            end

            Library.Window = function(Self, Params)
                Params = Params or { }

                local Window = {
                    Name = Params.Name or Params.name or "Window",

                    IsOpen = false,
                    Pages = { },
                    Items = { }
                }

                local Items = { } do 
                    Items["MainFrame"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Library.Holder.Instance,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(0, 695, 0, 713),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Background"]
                    }):AddToTheme({BackgroundColor3 = 'Background'})
                    
                    Items["MainFrame"]:MakeDraggable()
                    Items["MainFrame"]:MakeResizeable(Vector2.new(420, 380))
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["MainFrame"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    }):AddToTheme({Color = 'Border'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["MainFrame"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, -2)
                    }):AddToTheme({Color = 'Border'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["MainFrame"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Accent"],
                        BorderOffset = UDim.new(0, -1)
                    }):AddToTheme({Color = 'Accent'})
                    
                    Items["Title"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["MainFrame"].Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = Window.Name,
                        Size = UDim2.new(0, 0, 0, 15),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0, 6),
                        RichText = true,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Title"].Instance,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })
                    
                    Items["Inline"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["MainFrame"].Instance,
                        Position = UDim2.new(0, 8, 0, 30),
                        Size = UDim2.new(1, -16, 1, -38),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Inline"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Inline"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline'})
                    
                    Items["Content"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Inline"].Instance,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 4, 0, 30),
                        Size = UDim2.new(1, -8, 1, -34),
                        BorderSizePixel = 0
                    })
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Content"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })
                    
                    Items["AllPageHide"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Content"].Instance,
                        Size = UDim2.new(0, 320, 0, 2),
                        Position = UDim2.new(0, 0, 0, -1),
                        ZIndex = 2,
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})                

                    Items["Pages"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Inline"].Instance,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 2, 0, 6),
                        Size = UDim2.new(0, 0, 0, 22),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    })

                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["Pages"].Instance,
                        FillDirection = Enum.FillDirection.Horizontal,
                        VerticalFlex = Enum.UIFlexAlignment.Fill,
                        Padding = UDim.new(0, 7),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["Pages"].Instance,
                        PaddingLeft = UDim.new(0, 3)
                    })

                    Window.Items = Items
                end

                local Debounce = false

                function Window:SetOpen(Bool)
                    if Debounce then 
                        return 
                    end

                    Debounce = true 

                    Window.IsOpen = Bool
                    Items["MainFrame"]:FadeDescendants(Bool, function()
                        Debounce = false
                    end)

                    for Index, Value in Library.OpenFrames do 
                        Value:SetOpen(false)
                    end
                end

                function Window:Center()
                    local AbsPos = Items["MainFrame"].Instance.AbsolutePosition
                    Items["MainFrame"].Instance.AnchorPoint = Vector2.new(0, 0)
                    task.wait()
                    Items["MainFrame"].Instance.Position = UDim2.new(0, AbsPos.X, 0, AbsPos.Y + GuiInset)
                end

                Library:Connect(UserInputService.InputBegan, function(Input)
                    if tostring(Input.KeyCode) == Library.MenuKeybind or tostring(Input.UserInputType) == Library.MenuKeybind then
                        Window:SetOpen(not Window.IsOpen)
                    end
                end)

                Library:Connect(RunService.RenderStepped, function()
                    if Window.IsOpen then
                        Library:GlobalUpdateOpenFrames()
                    end
                end)

                Window:Center()
                return setmetatable(Window, Library)
            end

            Library.Page = function(Self, Params)
                Params = Params or { }

                local Page = {
                    Name = Params.Name or Params.name or "Page",

                    Window = Self,
                    ColumnsData = { },
                    Items = { },
                    Active = false
                }

                local Items = { } do 
                    Items["Inactive"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Page.Window.Items["Pages"].Instance,
                        TextColor3 = Library.Theme["Border"],
                        Text = "",
                        AutoButtonColor = false,
                        Size = UDim2.new(0, 0, 0, 50),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundColor3 = Library.Theme["Tab Background"]
                    }):AddToTheme({BackgroundColor3 = 'Tab Background'})
                    
                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["Inactive"].Instance,
                        TextColor3 = Library.Theme["Inactive Text"],
                        Text = Page.Name,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Size = UDim2.new(0, 0, 0, 15),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0.5, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Inactive Text'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Inactive"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline"]
                    }):AddToTheme({Color = 'Outline'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Inactive"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Border'})
                    
                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["Inactive"].Instance,
                        PaddingRight = UDim.new(0, 12),
                        PaddingLeft = UDim.new(0, 12)
                    })
                    
                    Items["Gradient"] = Library:Create("UIGradient", {
                        Name = "\0",
                        Parent = Items["Inactive"].Instance,
                        Rotation = -90,
                        Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(0.722, 0.26249998807907104),
                        NumberSequenceKeypoint.new(0.83, 0.4937499761581421),
                        NumberSequenceKeypoint.new(1, 1)
                    }
                    })
                    
                    Items["Hide"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Inactive"].Instance,
                        AnchorPoint = Vector2.new(0, 1),
                        Position = UDim2.new(0, -12, 1, 1),
                        Size = UDim2.new(1, 24, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Inline"]
                    }):AddToTheme({BackgroundColor3 = 'Inline'})                

                    Items["Page"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Library.UnusedHolder.Instance,
                        BackgroundTransparency = 1,
                        Visible = false,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderSizePixel = 0
                    })
                    
                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["Page"].Instance,
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalFlex = Enum.UIFlexAlignment.Fill,
                        Padding = UDim.new(0, 8),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })
                    
                    Items["LeftColumn"] = Library:Create("ScrollingFrame", {
                        Name = "\0",
                        Parent = Items["Page"].Instance,
                        ScrollBarImageColor3 = Library.Theme["Border"],
                        Active = true,
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ScrollBarThickness = 0,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        CanvasSize = UDim2.new(0, 0, 0, 0)
                    }):AddToTheme({ScrollBarImageColor3 = 'Border'})
                    
                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["LeftColumn"].Instance,
                        PaddingTop = UDim.new(0, 8),
                        PaddingBottom = UDim.new(0, 8),
                        PaddingRight = UDim.new(0, 2),
                        PaddingLeft = UDim.new(0, 8)
                    })
                    
                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["LeftColumn"].Instance,
                        Padding = UDim.new(0, 8),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Items["RightColumn"] = Library:Create("ScrollingFrame", {
                        Name = "\0",
                        Parent = Items["Page"].Instance,
                        ScrollBarImageColor3 = Library.Theme["Border"],
                        Active = true,
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ScrollBarThickness = 0,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        CanvasSize = UDim2.new(0, 0, 0, 0)
                    }):AddToTheme({ScrollBarImageColor3 = 'Border'})
                    
                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["RightColumn"].Instance,
                        PaddingTop = UDim.new(0, 8),
                        PaddingBottom = UDim.new(0, 8),
                        PaddingRight = UDim.new(0, 8),
                        PaddingLeft = UDim.new(0, 2)
                    })
                    
                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["RightColumn"].Instance,
                        Padding = UDim.new(0, 8),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })                

                    Page.ColumnsData[1] = Items["LeftColumn"]
                    Page.ColumnsData[2] = Items["RightColumn"]

                    Page.Items = Items
                end

                local Debounce = false

                function Page:Turn(Bool)
                    if Debounce then
                        return
                    end

                    Debounce = true

                    Page.Active = Bool 

                    if Bool then 
                        Items["Text"]:ChangeItemTheme({TextColor3 = "Text"})
                        Items["Gradient"]:Tween({Rotation = 90})
                        Items["Text"]:Tween({TextColor3 = Library.Theme.Text})
                    else
                        Items["Text"]:ChangeItemTheme({TextColor3 = "Inactive Text"})
                        Items["Gradient"]:Tween({Rotation = -90})
                        Items["Text"]:Tween({TextColor3 = Library.Theme["Inactive Text"]})
                    end

                    Items["Page"]:FadeDescendants(Bool, function()
                        Debounce = false

                        if Items["Page"].Instance.Visible then
                            Items["Page"].Instance.Parent = Page.Window.Items["Content"].Instance
                        else
                            Items["Page"].Instance.Parent = Library.UnusedHolder.Instance
                        end
                    end)
                end

                Items["Inactive"]:Connect("MouseButton1Down", function()
                    for Index, Value in Page.Window.Pages do 
                        Value:Turn(Value == Page)
                    end
                end)

                if #Page.Window.Pages == 0 then 
                    Page:Turn(true)
                end

                table.insert(Page.Window.Pages, Page)
                Page.Window.Items["AllPageHide"].Instance.Size = UDim2.new(0, Page.Window.Items["Pages"].Instance.AbsoluteSize.X - 1, 0, 1)
                return setmetatable(Page, Library)
            end

            Library.Section = function(Self, Params)
                Params = Params or { } 

                local Section = {
                    Name = Params.Name or Params.name or "Section",
                    Side = Params.Side or Params.side or 1,

                    Window = Self.Window,
                    Page = Self,
                    Items = { },
                }

                local Items = { } do 
                    Items["Section"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Section.Page.ColumnsData[Section.Side].Instance,
                        Size = UDim2.new(1, 0, 0, 25),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                    }):AddToTheme({BackgroundColor3 = 'Section Background'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Section"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    }):AddToTheme({Color = 'Border'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Section"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline"],
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Outline'})
                    
                    Items["Liner"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Section"].Instance,
                        Size = UDim2.new(1, 0, 0, 1),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Accent"]
                    }):AddToTheme({BackgroundColor3 = 'Accent'})
                    
                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = 14,
                        Parent = Items["Section"].Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = Section.Name,
                        Size = UDim2.new(0, 0, 0, 15),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 6, 0, 6),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })
                    
                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["Section"].Instance,
                        PaddingBottom = UDim.new(0, 10)
                    })
                    
                    Items["Content"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Section"].Instance,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0, 30),
                        Size = UDim2.new(1, -16, 0, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.Y
                    })
                    
                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["Content"].Instance,
                        Padding = UDim.new(0, 8),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Section.Items = Items
                end 

                return setmetatable(Section, Library)
            end

            Library.Toggle = function(Self, Params)
                Params = Params or { }

                local Toggle = {
                    Name = Params.Name or Params.name or "Toggle",
                    Flag = Params.Flag or Params.flag or (Params.Name or Params.name),
                    Default = Params.Default or Params.default or false,
                    Callback = Params.Callback or Params.callback or function() end,

                    Window = Self.Window,
                    Page = Self.Page,
                    Section = Self,

                    Value = false,
                    Items = { }
                }

                local Items = { } do 
                    Items["Toggle"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Toggle.Section.Items["Content"].Instance,
                        TextColor3 = Library.Theme["Border"],
                        Text = "",
                        AutoButtonColor = false,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 12),
                        BorderSizePixel = 0
                    }):AddToTheme({TextColor3 = 'Border'})
                    
                    Items["Indicator"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Toggle"].Instance,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        Size = UDim2.new(0, 12, 0, 12),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Element"]
                    }):AddToTheme({BackgroundColor3 = 'Element'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Indicator"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline"]
                    }):AddToTheme({Color = 'Outline'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Indicator"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Border'})
                    
                    Library:Create("UIGradient", {
                        Name = "\0",
                        Parent = Items["Indicator"].Instance,
                        Rotation = 90,
                        Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(156, 156, 156))
                    }
                    })
                    
                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = 14,
                        Parent = Items["Toggle"].Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = Toggle.Name,
                        Size = UDim2.new(0, 0, 0, 12),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 22, 0, -1),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })                

                    Items["SubElements"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Toggle"].Instance,
                        AnchorPoint = Vector2.new(1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, 0, 0, 0),
                        Size = UDim2.new(0, 0, 1, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    })
                    
                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["SubElements"].Instance,
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0, 6),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })                
                
                    Items["Toggle"]:OnHover(function()
                        if Toggle.Value then return end 
                        Items["Indicator"]:Tween({BackgroundColor3 = Library.Theme["Hovered Element"]})
                    end, function()
                        if Toggle.Value then return end 
                        Items["Indicator"]:Tween({BackgroundColor3 = Library.Theme["Element"]})
                    end)

                    Toggle.Items = Items
                end

                function Toggle:Set(Bool)
                    Toggle.Value = Bool 

                    if Bool then 
                        Items["Indicator"]:ChangeItemTheme({BackgroundColor3 = "Accent"})
                        Items["Indicator"]:Tween({BackgroundColor3 = Library.Theme.Accent})
                    else
                        Items["Indicator"]:ChangeItemTheme({BackgroundColor3 = "Element"})
                        Items["Indicator"]:Tween({BackgroundColor3 = Library.Theme.Element})
                    end

                    Flags[Toggle.Flag] = Bool
                    Library:SafeCall(Toggle.Callback, Bool)
                end

                function Toggle:SetVisibility(Bool)
                    Items["Toggle"].Instance.Visible = Bool 
                end

                function Toggle:SetText(Text)
                    Items["Text"].Instance.Text = tostring(Text)
                end

                function Toggle:Colorpicker(Data)
                    Data = Data or { }

                    local Colorpicker = {
                        Flag = Data.Flag or Data.flag or (Data.Name or Data.name or Toggle.Name),
                        Default = Data.Default or Data.default or Color3.fromRGB(255, 255, 255),
                        Callback = Data.Callback or Data.callback or function() end,
                        Alpha = Data.Alpha or Data.alpha or 0,

                        Window = Toggle.Window,
                        Page = Toggle.Page,
                        Section = Toggle.Section,
                    }

                    local NewColorpicker, ColorpickerItems = Library:CreateColorpicker({
                        Parent = Items["SubElements"],
                        Page = Colorpicker.Page,
                        Section = Colorpicker.Section,
                        Flag = Colorpicker.Flag,
                        Default = Colorpicker.Default,
                        Callback = Colorpicker.Callback,
                        Alpha = Colorpicker.Alpha
                    })

                    return NewColorpicker
                end

                function Toggle:Keybind(Data)
                    Data = Data or { }

                    local Keybind = {
                        Name = Data.Name or Data.name or Toggle.Name,
                        Flag = Data.Flag or Data.flag or (Data.Name or Data.name or Toggle.Name),
                        Default = Data.Default or Data.default or Enum.KeyCode.E,
                        Callback = Data.Callback or Data.callback or function() end,
                        Mode = Data.Mode or Data.mode or "Toggle",

                        Window = Toggle.Window,
                        Page = Toggle.Page,
                        Section = Toggle.Section,
                    }

                    local NewKeybind, KeybindItems = Library:CreateKeybind({
                        Parent = Items["SubElements"],
                        Name = Keybind.Name,
                        Page = Keybind.Page,
                        Section = Keybind.Section,
                        Flag = Keybind.Flag,
                        Default = Keybind.Default,
                        Mode = Keybind.Mode,
                        Callback = Keybind.Callback
                    })

                    return NewKeybind
                end

                Items["Toggle"]:Connect("MouseButton1Down", function()
                    Toggle:Set(not Toggle.Value)
                end)

                Toggle:Set(Toggle.Default)

                SetFlags[Toggle.Flag] = function(Value)
                    Toggle:Set(Value)
                end

                return setmetatable(Toggle, Library)
            end

            Library.Button = function(Self, Params)
                Params = Params or { }

                local Button = {
                    Name = Params.Name or Params.name or "Button",
                    Callback = Params.Callback or Params.callback or function() end,

                    Window = Self.Window,
                    Page = Self.Page,
                    Section = Self,
                    Items = { }
                }

                local Items = { } do 
                    Items["Button"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Button.Section.Items["Content"].Instance,
                        TextColor3 = Library.Theme["Border"],
                        Text = "",
                        AutoButtonColor = false,
                        Size = UDim2.new(1, 0, 0, 16),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Element"]
                    }):AddToTheme({BackgroundColor3 = 'Element'})
                    
                    Library:Create("UIGradient", {
                        Name = "\0",
                        Parent = Items["Button"].Instance,
                        Rotation = 90,
                        Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(156, 156, 156))
                    }
                    })
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Button"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline"]
                    }):AddToTheme({Color = 'Outline'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Button"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Border'})
                    
                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = 14,
                        Parent = Items["Button"].Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = Button.Name,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Size = UDim2.new(0, 0, 0, 15),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.5, 0, 0.5, -1),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })                

                    Items["Button"]:OnHover(function()
                        Items["Button"]:Tween({BackgroundColor3 = Library.Theme["Hovered Element"]})
                    end, function()
                        Items["Button"]:Tween({BackgroundColor3 = Library.Theme["Element"]})
                    end)

                    Button.Items = Items
                end

                function Button:Press()
                    Items["Button"]:ChangeItemTheme({BackgroundColor3 = "Accent"})
                    Items["Button"]:Tween({BackgroundColor3 = Library.Theme.Accent})
                    task.wait(0.1)
                    Items["Button"]:ChangeItemTheme({BackgroundColor3 = "Element"})
                    Items["Button"]:Tween({BackgroundColor3 = Library.Theme.Element})
                    
                    Library:SafeCall(Button.Callback)
                end

                function Button:SetVisibility(Bool)
                    Items["Button"].Instance.Visible = Bool
                end

                function Button:SetText(Text)
                    Items["Text"].Instance.Text = tostring(Text)
                end

                Items["Button"]:Connect("MouseButton1Down", function()
                    Button:Press()
                end)

                return setmetatable(Button, Library)
            end

            Library.Slider = function(Self, Params)
                Params = Params or { }

                local Slider = {
                    Name = Params.Name or Params.name or "Slider",
                    Flag = Params.Flag or Params.flag or (Params.Name or Params.name),
                    Default = Params.Default or Params.default or 0,
                    Min = Params.Min or Params.min or 0,
                    Max = Params.Max or Params.max or 100,
                    Callback = Params.Callback or Params.callback or function() end,
                    Decimals = Params.Decimals or Params.decimals or 0,
                    Suffix = Params.Suffix or Params.suffix or "",

                    Window = Self.Window,
                    Page = Self.Page,
                    Section = Self,

                    Value = 0,
                    Sliding = false,
                    Items = { }
                }

                local Items = { } do 
                    Items["Slider"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Slider.Section.Items["Content"].Instance,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 32),
                        BorderSizePixel = 0
                    })
                    
                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = 14,
                        Parent = Items["Slider"].Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = Slider.Name,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 15),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })
                    
                    Items["RealSlider"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["Slider"].Instance,
                        TextColor3 = Library.Theme["Border"],
                        Text = "",
                        AutoButtonColor = false,
                        AnchorPoint = Vector2.new(0, 1),
                        Position = UDim2.new(0, 0, 1, 0),
                        Size = UDim2.new(1, 0, 0, 10),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Element"]
                    }):AddToTheme({BackgroundColor3 = 'Element'})
                    
                    Library:Create("UIGradient", {
                        Name = "\0",
                        Parent = Items["RealSlider"].Instance,
                        Rotation = 90,
                        Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(156, 156, 156))
                    }
                    })
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["RealSlider"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline"]
                    }):AddToTheme({Color = 'Outline'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["RealSlider"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Border'})
                    
                    Items["Accent"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["RealSlider"].Instance,
                        Size = UDim2.new(0.5, 0, 1, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Accent"]
                    }):AddToTheme({BackgroundColor3 = 'Accent'})
                    
                    Library:Create("UIGradient", {
                        Name = "\0",
                        Parent = Items["Accent"].Instance,
                        Rotation = 90,
                        Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(156, 156, 156))
                    }
                    })
                    
                    Items["Value"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = 14,
                        Parent = Items["RealSlider"].Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = "50%",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Size = UDim2.new(0, 0, 0, 15),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.5, 0, 0.5, -1),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Value"].Instance,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Value"].Instance,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })                

                    Items["RealSlider"]:OnHover(function()
                        Items["RealSlider"]:Tween({BackgroundColor3 = Library.Theme["Hovered Element"]})
                    end, function()
                        Items["RealSlider"]:Tween({BackgroundColor3 = Library.Theme["Element"]})
                    end)

                    Slider.Items = Items 
                end

                function Slider:Set(Value)
                    Slider.Value = Library:Round(math.clamp(Value, Slider.Min, Slider.Max), Slider.Decimals)

                    Items["Accent"]:Tween({Size = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0)}, TweenInfo.new(Library.Animation.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
                    Items["Value"].Instance.Text = string.format("%s%s", Slider.Value, Slider.Suffix)

                    Flags[Slider.Flag] = Slider.Value
                    Library:SafeCall(Slider.Callback, Slider.Value)
                end

                function Slider:SetVisibility(Bool)
                    Items["Slider"].Instance.Visible = Bool
                end

                function Slider:GetSize(Input)
                    local SizeX = (Input.Position.X - Items["RealSlider"].Instance.AbsolutePosition.X) / Items["RealSlider"].Instance.AbsoluteSize.X
                    local Value = ((Slider.Max - Slider.Min) * SizeX) + Slider.Min

                    return Value
                end

                function Slider:SetText(Text)
                    Items["Text"].Instance.Text = tostring(Text)
                end

                local InputChanged 
                
                Items["RealSlider"]:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Slider.Sliding = true

                        local Value = Slider:GetSize(Input)

                        Slider:Set(Value)

                        if InputChanged then
                            return
                        end

                        InputChanged = Input.Changed:Connect(function()
                            if Input.UserInputState == Enum.UserInputState.End then
                                Slider.Sliding = false

                                InputChanged:Disconnect()
                                InputChanged = nil
                            end
                        end)
                    end
                end)

                Library:Connect(UserInputService.InputChanged, function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                        if Slider.Sliding then
                            local Value = Slider:GetSize(Input)

                            Slider:Set(Value)
                        end
                    end
                end)

                Slider:Set(Slider.Default)

                SetFlags[Slider.Flag] = function(Value)
                    Slider:Set(Value)
                end

                return setmetatable(Slider, Library)
            end

            Library.Dropdown = function(Self, Params)
                Params = Params or { }

                local Dropdown = {
                    Name = Params.Name or Params.name or "Dropdown",
                    OptionItems = Params.Items or Params.items or { },
                    Flag = Params.Flag or Params.flag or (Params.Name or Params.name),
                    Default = Params.Default or Params.default or "",
                    Callback = Params.Callback or Params.callback or function() end,
                    Multi = Params.Multi or Params.multi or false,

                    Window = Self.Window,
                    Page = Self.Page,
                    Section = Self,

                    Value = { },
                    Options = { },
                    IsOpen = false,
                    Items = { }
                }

                local Parent 

                if Params.Parent then
                    Parent = Params.Parent
                else
                    Parent = Dropdown.Section.Items["Content"]
                end

                local Items = { } do 
                    Items["Dropdown"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Parent.Instance,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 41),
                        BorderSizePixel = 0
                    })
                    
                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = 14,
                        Parent = Items["Dropdown"].Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = Dropdown.Name,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 15),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })
                    
                    Items["RealDropdown"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Items["Dropdown"].Instance,
                        TextColor3 = Library.Theme["Border"],
                        Text = "",
                        AutoButtonColor = false,
                        AnchorPoint = Vector2.new(0, 1),
                        Position = UDim2.new(0, 0, 1, 0),
                        Size = UDim2.new(1, 0, 0, 16),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Element"]
                    }):AddToTheme({BackgroundColor3 = 'Element'})
                    
                    Library:Create("UIGradient", {
                        Name = "\0",
                        Parent = Items["RealDropdown"].Instance,
                        Rotation = 90,
                        Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(156, 156, 156))
                    }
                    })
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["RealDropdown"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline"]
                    }):AddToTheme({Color = 'Outline'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["RealDropdown"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Border'})
                    
                    Items["Value"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = 14,
                        Parent = Items["RealDropdown"].Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = "...",
                        Size = UDim2.new(1, -30, 0, 15),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 6, 0.5, -1),
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BorderSizePixel = 0,
                        TextTruncate = Enum.TextTruncate.AtEnd
                    }):AddToTheme({TextColor3 = 'Text'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Value"].Instance,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })
                    
                    Items["PlusIcon"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = 14,
                        Parent = Items["RealDropdown"].Instance,
                        TextColor3 = Color3.fromRGB(200, 200, 200),
                        Text = "+",
                        AnchorPoint = Vector2.new(1, 0.5),
                        Size = UDim2.new(0, 0, 0, 15),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -6, 0.5, -1),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})     
                    
                    Items["OptionHolder"] = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = Library.FontSize,
                        Parent = Library.UnusedHolder.Instance,
                        Visible = false,
                        TextColor3 = Library.Theme["Border"],
                        Text = "",
                        AutoButtonColor = false,
                        Size = UDim2.new(0, 275, 0, 50),
                        Position = UDim2.new(0.021290751174092293, 0, 0.4147196114063263, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                    }):AddToTheme({BackgroundColor3 = 'Section Background'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["OptionHolder"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Border'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["OptionHolder"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline"]
                    }):AddToTheme({Color = 'Outline'})
                    
                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["OptionHolder"].Instance,
                        Padding = UDim.new(0, 8),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })
                    
                    Library:Create("UIPadding", {
                        Name = "\0",
                        Parent = Items["OptionHolder"].Instance,
                        PaddingTop = UDim.new(0, 6),
                        PaddingBottom = UDim.new(0, 10),
                        PaddingRight = UDim.new(0, 6),
                        PaddingLeft = UDim.new(0, 10)
                    })

                    Items["RealDropdown"]:OnHover(function()
                        Items["RealDropdown"]:Tween({BackgroundColor3 = Library.Theme["Hovered Element"]})
                    end, function()
                        Items["RealDropdown"]:Tween({BackgroundColor3 = Library.Theme["Element"]})
                    end)

                    Dropdown.Items = Items 
                end

                function Dropdown:Set(Value)
                    if Dropdown.Multi then 
                        if type(Value) ~= "table" then 
                            return
                        end

                        Dropdown.Value = Value

                        for Index, Value in Value do
                            local OptionData = Dropdown.Options[Value]
                             
                            if not OptionData then
                                continue
                            end

                            OptionData.IsSelected = true 
                            OptionData:ToggleState("Active")
                        end

                        Flags[Dropdown.Flag] = Value
                        Items["Value"].Instance.Text = table.concat(Value, ", ")
                    else
                        if not Dropdown.Options[Value] then
                            return
                        end

                        local OptionData = Dropdown.Options[Value]

                        Dropdown.Value = Value

                        for Index, Value in Dropdown.Options do
                            if Value ~= OptionData then
                                Value.IsSelected = false 
                                Value:ToggleState("Inactive")
                            else
                                Value.Selected = true 
                                Value:ToggleState("Active")
                            end
                        end

                        Flags[Dropdown.Flag] = Value
                        Items["Value"].Instance.Text = Value
                    end

                    Library:SafeCall(Dropdown.Callback, Dropdown.Value)
                end

                function Dropdown:Add(Value)
                    local OptionButton = Library:Create("TextButton", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = 14,
                        Parent = Items["OptionHolder"].Instance,
                        TextColor3 = Color3.fromRGB(180, 180, 180),
                        Text = Value,
                        AutoButtonColor = false,
                        Size = UDim2.new(1, 0, 0, 15),
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Inactive Text'})

                    local OptionData = {
                        Button = OptionButton,
                        Name = Value,
                        IsSelected = false
                    }
                    
                    function OptionData:ToggleState(Value)
                        if Value == "Active" then
                            OptionData.Button:ChangeItemTheme({TextColor3 = "Accent"})
                            OptionData.Button:Tween({TextColor3 = Library.Theme.Accent})
                        else
                            OptionData.Button:ChangeItemTheme({TextColor3 = "Text"})
                            OptionData.Button:Tween({TextColor3 = Library.Theme.Text})
                        end
                    end

                    function OptionData:Set()
                        OptionData.IsSelected = not OptionData.IsSelected

                        if Dropdown.Multi then 
                            local Index = table.find(Dropdown.Value, OptionData.Name)

                            if Index then 
                                table.remove(Dropdown.Value, Index)
                            else
                                table.insert(Dropdown.Value, OptionData.Name)
                            end

                            OptionData:ToggleState(Index and "Inactive" or "Active")

                            Flags[Dropdown.Flag] = Dropdown.Value

                            local TextFormat = #Dropdown.Value > 0 and table.concat(Dropdown.Value, ", ") or ""
                            Items["Value"].Instance.Text = TextFormat
                        else
                            if OptionData.IsSelected then 
                                Dropdown.Value = OptionData.Name
                                Flags[Dropdown.Flag] = OptionData.Name

                                OptionData.IsSelected = true
                                OptionData:ToggleState("Active")

                                for Index, Value in Dropdown.Options do 
                                    if Value ~= OptionData then
                                        Value.IsSelected = false 
                                        Value:ToggleState("Inactive")
                                    end
                                end

                                Items["Value"].Instance.Text = OptionData.Name
                            else
                                Dropdown.Value = nil
                                Flags[Dropdown.Flag] = nil

                                OptionData.IsSelected = false
                                OptionData:ToggleState("Inactive")

                                Items["Value"].Instance.Text = "..."
                            end
                        end

                        Library:SafeCall(Dropdown.Callback, Dropdown.Value)
                    end

                    OptionData.Button:Connect("MouseButton1Down", function()
                        OptionData:Set()
                    end)

                    Dropdown.Options[OptionData.Name] = OptionData
                    return OptionData
                end

                function Dropdown:Remove(Option)
                    if Dropdown.Options[Option] then
                        Dropdown.Options[Option].Button.Instance:Destroy()
                        Dropdown.Options[Option] = nil
                    end
                end

                function Dropdown:Refresh(List)
                    for Index, Value in Dropdown.Options do 
                        Dropdown:Remove(Value.Name)
                    end

                    for Index, Value in List do 
                        Dropdown:Add(Value)
                    end
                end

                function Dropdown:SetText(Text)
                    Items["Text"].Instance.Text = tostring(Text)
                end

                function Dropdown:SetVisibility(Bool)
                    Items["Dropdown"].Instance.Visible = Bool 
                end

                local Debounce = false 
                local RenderStepped 
                local OptionHolder = Items["OptionHolder"].Instance
                local RealDropdown = Items["RealDropdown"].Instance

                Dropdown.AttachedButton = RealDropdown
                Dropdown.CanUpdateNow = false
                Dropdown.Frame = OptionHolder

                function Dropdown:SetOpen(Bool)
                    if Debounce then 
                        return 
                    end

                    Dropdown.IsOpen = Bool

                    Debounce = true 
                    
                    if Dropdown.IsOpen then 
                        Items["PlusIcon"].Instance.Text = "-"
                        OptionHolder.Position = UDim2.new(0, RealDropdown.AbsolutePosition.X, 0, RealDropdown.AbsolutePosition.Y + RealDropdown.AbsoluteSize.Y + GuiInset)
                        OptionHolder.Size = UDim2.new(0, RealDropdown.AbsoluteSize.X, 0, Dropdown.MaxSize)
                        
                        OptionHolder.Parent = Library.Holder.Instance
                        OptionHolder.Visible = true
                        Items["OptionHolder"]:Tween({Position = UDim2.new(0, RealDropdown.AbsolutePosition.X, 0, RealDropdown.AbsolutePosition.Y + RealDropdown.AbsoluteSize.Y + 10 + GuiInset)})
                        
                        Items["OptionHolder"]:FadeDescendants(true, function()
                            Debounce = false 
                            Dropdown.CanUpdateNow = true
                        end)

                        for Index, Value in Library.OpenFrames do 
                            if not Params.Parent then
                                Value:SetOpen(false)
                            end
                        end

                        Library.OpenFrames[Dropdown] = Dropdown 
                    else
                        Items["PlusIcon"].Instance.Text = "+"
                        Items["OptionHolder"]:Tween({Position = UDim2.new(0, RealDropdown.AbsolutePosition.X, 0, RealDropdown.AbsolutePosition.Y + RealDropdown.AbsoluteSize.Y - 10 + GuiInset)})
                        Items["OptionHolder"]:FadeDescendants(false, function()
                            OptionHolder.Parent = Library.UnusedHolder.Instance
                            Debounce = false
                            Dropdown.CanUpdateNow = false
                        end)

                        if Library.OpenFrames[Dropdown] then 
                            Library.OpenFrames[Dropdown] = nil
                        end

                        if RenderStepped then 
                            RenderStepped:Disconnect()
                            RenderStepped = nil
                        end
                    end

                    local Descendants = OptionHolder:GetDescendants()
                    table.insert(Descendants, OptionHolder)

                    for Index, Value in Descendants do 
                        if Value.ClassName:find("UI") then
                            continue
                        end

                        if not Params.Parent then
                            Value.ZIndex = Dropdown.IsOpen and 3 or 1
                        else
                            Value.ZIndex = Dropdown.IsOpen and 6 or 1
                        end
                    end
                end

                Items["RealDropdown"]:Connect("MouseButton1Down", function()
                    Dropdown:SetOpen(not Dropdown.IsOpen)
                end)

                Library:Connect(UserInputService.InputBegan, function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        if Dropdown.IsOpen then
                            if Items["OptionHolder"]:IsMouseOverFrame() then 
                                return 
                            end

                            Dropdown:SetOpen(false)
                        end
                    end
                end)

                Items["RealDropdown"]:Connect("Changed", function(Property)
                    if Property == "AbsolutePosition" and Dropdown.IsOpen then
                        Dropdown.IsOpen = not Items["OptionHolder"]:IsClipped(Dropdown.Section.Items["Section"].Instance.Parent)
                        Items["OptionHolder"].Instance.Visible = Dropdown.IsOpen
                    end
                end)

                for Index, Value in Dropdown.OptionItems do 
                    Dropdown:Add(Value)
                end

                Dropdown:Set(Dropdown.Default)

                SetFlags[Dropdown.Flag] = function(Value)
                    Dropdown:Set(Value)
                end

                return setmetatable(Dropdown, Library)
            end

            Library.Label = function(Self, Params)
                Params = Params or { }

                local Label = {
                    Name = Params.Name or Params.name or "Label",

                    Window = Self.Window,
                    Page = Self.Page,
                    Section = Self,

                    Items = { }
                }

                local Items = { } do 
                    Items["Label"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Label.Section.Items["Content"].Instance,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 15),
                        BorderSizePixel = 0
                    })
                    
                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = 14,
                        Parent = Items["Label"].Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = Label.Name,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 15),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })
                    
                    Items["SubElements"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Label"].Instance,
                        AnchorPoint = Vector2.new(1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, 0, 0, 0),
                        Size = UDim2.new(0, 0, 1, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    })
                    
                    Library:Create("UIListLayout", {
                        Name = "\0",
                        Parent = Items["SubElements"].Instance,
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0, 6),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })                

                    Label.Items = Items 
                end

                function Label:SetVisibility(Bool)
                    Items["Label"].Instance.Visible = Bool 
                end

                function Label:SetText(Text)
                    Items["Text"].Instance.Text = tostring(Text)
                end

                function Label:Colorpicker(Data)
                    Data = Data or { }

                    local Colorpicker = {
                        Flag = Data.Flag or Data.flag or (Data.Name or Data.name or Label.Name),
                        Default = Data.Default or Data.default or Color3.fromRGB(255, 255, 255),
                        Callback = Data.Callback or Data.callback or function() end,
                        Alpha = Data.Alpha or Data.alpha or 0,

                        Window = Label.Window,
                        Page = Label.Page,
                        Section = Label.Section,
                    }

                    local NewColorpicker, ColorpickerItems = Library:CreateColorpicker({
                        Parent = Items["SubElements"],
                        Page = Colorpicker.Page,
                        Section = Colorpicker.Section,
                        Flag = Colorpicker.Flag,
                        Default = Colorpicker.Default,
                        Callback = Colorpicker.Callback,
                        Alpha = Colorpicker.Alpha
                    })

                    return NewColorpicker
                end

                function Label:Keybind(Data)
                    Data = Data or { }

                    local Keybind = {
                        Name = Data.Name or Data.name or Label.Name,
                        Flag = Data.Flag or Data.flag or (Data.Name or Data.name or Label.Name),
                        Default = Data.Default or Data.default or Enum.KeyCode.E,
                        Callback = Data.Callback or Data.callback or function() end,
                        Mode = Data.Mode or Data.mode or "Toggle",

                        Window = Label.Window,
                        Page = Label.Page,
                        Section = Label.Section,
                    }

                    local NewKeybind, KeybindItems = Library:CreateKeybind({
                        Parent = Items["SubElements"],
                        Name = Keybind.Name,
                        Page = Keybind.Page,
                        Section = Keybind.Section,
                        Flag = Keybind.Flag,
                        Default = Keybind.Default,
                        Mode = Keybind.Mode,
                        Callback = Keybind.Callback
                    })

                    return NewKeybind
                end

                Label:SetText(Label.Name)

                return setmetatable(Label, Library)
            end

            Library.Textbox = function(Self, Params)
                Params = Params or { }

                local Textbox = {
                    Name = Params.Name or Params.name or "Textbox",
                    Flag = Params.Flag or Params.flag or (Params.Name or Params.name),
                    Default = Params.Default or Params.default or "",
                    Callback = Params.Callback or Params.callback or function() end,
                    Finished = Params.Finished or Params.finished or false,
                    Placeholder = Params.Placeholder or Params.placeholder or "",
                    Numeric = Params.Numeric or Params.numeric or false,

                    Window = Self.Window,
                    Page = Self.Page,
                    Section = Self,
                    Value = "",

                    Items = { },
                }

                local Items = { } do 
                    Items["Textbox"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Textbox.Section.Items["Content"].Instance,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 41),
                        BorderSizePixel = 0
                    })
                    
                    Items["Text"] = Library:Create("TextLabel", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = 14,
                        Parent = Items["Textbox"].Instance,
                        TextColor3 = Library.Theme["Text"],
                        Text = Textbox.Name,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 15),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X
                    }):AddToTheme({TextColor3 = 'Text'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Text"].Instance,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })
                    
                    Items["Background"] = Library:Create("Frame", {
                        Name = "\0",
                        Parent = Items["Textbox"].Instance,
                        ClipsDescendants = true,
                        AnchorPoint = Vector2.new(0, 1),
                        Size = UDim2.new(1, 0, 0, 16),
                        Position = UDim2.new(0, 0, 1, 0),
                        Selectable = true,
                        Active = true,
                        BorderSizePixel = 0,
                        BackgroundColor3 = Library.Theme["Element"]
                    }):AddToTheme({BackgroundColor3 = 'Element'})
                    
                    Library:Create("UIGradient", {
                        Name = "\0",
                        Parent = Items["Background"].Instance,
                        Rotation = 90,
                        Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(156, 156, 156))
                    }
                    })
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Background"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Color = Library.Theme["Outline"]
                    }):AddToTheme({Color = 'Outline'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Background"].Instance,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        BorderOffset = UDim.new(0, 1)
                    }):AddToTheme({Color = 'Border'})
                    
                    Items["Input"] = Library:Create("TextBox", {
                        Name = "\0",
                        FontFace = Library.Font,
                        TextSize = 14,
                        Parent = Items["Background"].Instance,
                        Active = false,
                        Selectable = false,
                        AnchorPoint = Vector2.new(0, 0.5),
                        PlaceholderColor3 = Library.Theme["Inactive Text"],
                        PlaceholderText = Textbox.Placeholder,
                        Size = UDim2.new(1, -12, 0, 15),
                        TextColor3 = Library.Theme["Text"],
                        Text = "",
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Position = UDim2.new(0, 6, 0.5, -1),
                        BorderSizePixel = 0
                    }):AddToTheme({TextColor3 = 'Text', PlaceholderColor3 = 'Inactive Text'})
                    
                    Library:Create("UIStroke", {
                        Name = "\0",
                        Parent = Items["Input"].Instance,
                        LineJoinMode = Enum.LineJoinMode.Miter
                    })                

                    Items["Background"]:OnHover(function()
                        Items["Background"]:Tween({BackgroundColor3 = Library.Theme["Hovered Element"]})
                    end, function()
                        Items["Background"]:Tween({BackgroundColor3 = Library.Theme["Element"]})
                    end)

                    Textbox.Items = Items
                end

                function Textbox:SetVisibility(Bool)
                    Items["Textbox"].Instance.Visible = Bool
                end

                function Textbox:SetText(Text)
                    Items["Text"].Instance.Text = tostring(Text)
                end

                function Textbox:Set(Value)
                    if Textbox.Numeric then
                        if (not tonumber(Value)) and string.len(tostring(Value)) > 0 then
                            Value = Textbox.Value
                        end
                    end

                    Textbox.Value = Value
                    Items["Input"].Instance.Text = Value
                    Flags[Textbox.Flag] = Value

                    Library:SafeCall(Textbox.Callback, Value)
                end

                if Textbox.Finished then 
                    Items["Input"]:Connect("FocusLost", function(PressedEnterQuestionMark)
                        if PressedEnterQuestionMark then
                            Textbox:Set(Items["Input"].Instance.Text)
                        end
                    end)
                else
                    Library:Connect(Items["Input"].Instance:GetPropertyChangedSignal("Text"), function()
                        Textbox:Set(Items["Input"].Instance.Text)
                    end)
                end

                Textbox:Set(Textbox.Default)

                SetFlags[Textbox.Flag] = function(Value)
                    Textbox:Set(Value)
                end
                
                return setmetatable(Textbox, Library)
            end

            Library.CreateSettingsPage = function(Self)
                local SettingsPage = Self:Page({Name = "Settings"})

                local ConfigsSection = SettingsPage:Section({Name = "Configs", Side = 1})
                local ThemingSection = SettingsPage:Section({Name = "Theming", Side = 2})

                do
                    local ConfigName 
                    local ConfigSelected 
                    local ConfigsFolder = Library.Directory .. Library.Folders.Configs .. "/"

                    local ConfigsDropdown = ConfigsSection:Dropdown({
                        Name = "Configs",
                        Flag = "ConfigsDropdown",
                        MaxSize = 100,
                        Items = { },
                        Multi = false,
                        Callback = function(Value)
                            ConfigSelected = Value 
                        end
                    })

                    ConfigsSection:Textbox({
                        Name = "Config name",
                        Flag = "ConfigName",
                        Placeholder = "Config name",
                        Callback = function(Value)
                            ConfigName = Value 
                        end
                    })

                    ConfigsSection:Button({
                        Name = "Create",
                        Callback = function()
                            if ConfigName then 
                                if ConfigName == "" then 
                                    return
                                end
        
                                writefile(ConfigsFolder .. ConfigName .. ".json", Library:GetConfig())
                                Library:GetConfigsList(ConfigsDropdown)
                                Library:Notification("Succesfully created config", 3, Color3.fromRGB(0, 255, 0))
                            end
                        end
                    })

                    ConfigsSection:Button({
                        Name = "Delete",
                        Callback = function()
                            if ConfigSelected then 
                                if isfile(ConfigsFolder .. ConfigSelected .. ".json") then
                                    delfile(ConfigsFolder .. ConfigSelected .. ".json")
                                    Library:GetConfigsList(ConfigsDropdown)

                                    Library:Notification("Succesfully deleted config", 3, Color3.fromRGB(0, 255, 0))
                                end
                            end
                        end
                    })

                    ConfigsSection:Button({
                        Name = "Load",
                        Callback = function()
                            if ConfigSelected then 
                                if isfile(ConfigsFolder.. ConfigSelected .. ".json") then
                                    local ConfigContent = readfile(ConfigsFolder.. ConfigSelected .. ".json")
                                    local Success, Error = Library:LoadConfig(ConfigContent)

                                    if Success then 
                                        Library:Notification("Succesfully loaded config", 3, Color3.fromRGB(0, 255, 0))
                                    else
                                        Library:Notification("Failed to load config: \n"..Error, 3, Color3.fromRGB(255, 0, 0))
                                    end
                                end
                            end
                        end
                    })

                    ConfigsSection:Button({
                        Name = "Save",
                        Callback = function()
                            if ConfigSelected then
                                if isfile(ConfigsFolder.. ConfigSelected .. ".json") then
                                    local Success, Error = pcall(function()
                                        writefile(ConfigsFolder .. ConfigSelected .. ".json", Library:GetConfig())
                                    end)

                                    if Success then 
                                        Library:Notification("Succesfully saved config", 3, Color3.fromRGB(0, 255, 0))
                                    else
                                        Library:Notification("Failed to save config: \n"..Error, 3, Color3.fromRGB(255, 0, 0))
                                    end
                                end
                            end
                        end
                    })

                    ConfigsSection:Label({Name = "UI Bind"}):Keybind({Flag = "UIBind", Mode = "Toggle", Default = Enum.KeyCode.Insert, Callback = function(Value)
                        Library.MenuKeybind = Flags["UIBind"].Key
                    end})

                    ConfigsSection:Button({
                        Name = "Unload",
                        Callback = function()
                            Library:Exit()
                        end
                    })

                    ConfigsSection:Dropdown({
                        Name = "Notification Position",
                        Flag = "NotificationPosition",
                        Items = { "Left", "Right" },
                        Default = "Left",
                        Callback = function(Value)
                            if Value == "Right" then 
                                Library.NotifHolder.Instance.AnchorPoint = Vector2.new(1, 0)
                                Library.NotifHolder.Instance.Position = UDim2.new(1, 0, 0, 0)

                                Library.NotifHolder.Instance:FindFirstChildOfClass("UIListLayout").HorizontalAlignment = Enum.HorizontalAlignment.Right
                            elseif Value == "Left" then 
                                Library.NotifHolder.Instance.AnchorPoint = Vector2.new(0, 0)
                                Library.NotifHolder.Instance.Position = UDim2.new(0, 0, 0, 10 + GuiInset)

                                Library.NotifHolder.Instance:FindFirstChildOfClass("UIListLayout").HorizontalAlignment = Enum.HorizontalAlignment.Left
                            end
                        end
                    })

                    ConfigsSection:Dropdown({
                        Name = "Notification Alignment",
                        Flag = "NotificationAlignment",
                        Items = { "Top", "Bottom" },
                        Default = "Top",
                        Callback = function(Value)
                            if Library.Flags["NotificationPosition"] == "Left" and Value == "Bottom" then
                                Library.NotifHolder.Instance.Position = UDim2.new(0, 0, 0, 0)
                            end

                            Library.NotifHolder.Instance:FindFirstChildOfClass("UIListLayout").VerticalAlignment = Enum.VerticalAlignment[Value]
                        end
                    })

                    Library:GetConfigsList(ConfigsDropdown)
                end

                do
                    for Index, Value in Library.Theme do 
                        ThemingSection:Label({Name = Index}):Colorpicker({Flag = Index, Default = Value, Callback = function(Value)
                            Library.Theme[Index] = Value
                            Library:ChangeTheme(Index, Value)
                        end})
                    end
                end
            end
        end
    end

    do
        -- Hide only the old visible window. Its objects remain alive because
        -- later gohth.cc (fg cheat) feature/update code still references them.
        Main.Visible = false

        local Window = Library:Window({
            Name = '<font color="rgb(67, 133, 255)">gohth.cc (fg cheat)</font>'
        })

        local KeybindList = Window:KeybindList({
            Name = '<font color="rgb(67, 133, 255)">gohth.cc (fg cheat)</font> keybinds'
        })
        KeybindList:SetVisible(false)

        --// Minimal centered active keybind list (reference-style)
        task.spawn(function()
            local playerGui = LocalPlayer:WaitForChild("PlayerGui")
            local oldGui = playerGui:FindFirstChild("GohthCenterBinds")
            if oldGui then oldGui:Destroy() end

            local bindGui = Instance.new("ScreenGui")
            bindGui.Name = "GohthCenterBinds"
            bindGui.ResetOnSpawn = false
            bindGui.IgnoreGuiInset = true
            bindGui.DisplayOrder = 998
            bindGui.Parent = playerGui

            local holder = Instance.new("Frame")
            holder.Name = "BindHolder"
            holder.AnchorPoint = Vector2.new(0.5, 1)
            holder.Position = UDim2.new(0.5, 0, 1, -25)
            holder.Size = UDim2.fromOffset(300, 250)
            holder.BackgroundTransparency = 1
            holder.BorderSizePixel = 0
            holder.Parent = bindGui

            local layout = Instance.new("UIListLayout")
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            layout.VerticalAlignment = Enum.VerticalAlignment.Top
            layout.Padding = UDim.new(0, 1)
            layout.Parent = holder

            local rows = {}

            local function makeRow(id)
                local label = Instance.new("TextLabel")
                label.Name = id
                label.Size = UDim2.new(1, 0, 0, 17)
                label.BackgroundTransparency = 1
                label.BorderSizePixel = 0
                label.RichText = true
                label.Text = ""
                label.TextColor3 = Color3.fromRGB(205, 205, 205)
                label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                label.TextStrokeTransparency = 0.35
                label.TextSize = 14
                label.Font = Enum.Font.SourceSansSemibold
                label.TextXAlignment = Enum.TextXAlignment.Center
                label.Visible = false
                label.Parent = holder
                rows[id] = label
                return label
            end

            makeRow("aimlock")
            makeRow("visiblecheck")
            makeRow("teamcheck")
            makeRow("triggerbot")
            makeRow("onscreen")
            makeRow("esp")
            makeRow("speed")
            makeRow("jump")
            makeRow("panic")

            getgenv().GohthBindOverlay = {
                Enabled = true,

                SetVisible = function(value)
                    getgenv().GohthBindOverlay.Enabled = value == true
                    holder.Visible = getgenv().GohthBindOverlay.Enabled
                end,

                Set = function(id, visible, name, keyText)
                    local row = rows[id]
                    if not row then return end

                    row.Visible = (visible == true) and getgenv().GohthBindOverlay.Enabled

                    local accent = (getgenv().Library and getgenv().Library.Theme and getgenv().Library.Theme["Accent"])
                        or Color3.fromRGB(67, 133, 255)
                    local r = math.floor(accent.R * 255)
                    local g = math.floor(accent.G * 255)
                    local b = math.floor(accent.B * 255)

                    row.Text = string.format(
                        '<font color="rgb(%d,%d,%d)">%s</font> <font color="rgb(205,205,205)">&lt;%s&gt;</font>',
                        r, g, b, tostring(name), tostring(keyText)
                    )
                end,

                Refresh = function()
                    if not getgenv().GohthBindOverlay.Enabled then
                        holder.Visible = false
                        return
                    end

                    holder.Visible = true

                    -- Only show features that are currently active/enabled.
                    getgenv().GohthBindOverlay.Set(
                        "aimlock",
                        getgenv().GohthAimlockEnabled == true,
                        "Aim Assist",
                        LOCK_KEY and LOCK_KEY.Name or "Q"
                    )

                    getgenv().GohthBindOverlay.Set(
                        "visiblecheck",
                        LOCK_ENABLED and LOCK_VISIBLE_CHECK,
                        "visible check",
                        "ON"
                    )

                    getgenv().GohthBindOverlay.Set(
                        "teamcheck",
                        LOCK_ENABLED and LOCK_TEAM_CHECK,
                        "ignore team",
                        "ON"
                    )

                    getgenv().GohthBindOverlay.Set(
                        "triggerbot",
                        TRIGGERBOT_ENABLED,
                        "trigger bot",
                        "ON"
                    )

                    getgenv().GohthBindOverlay.Set(
                        "onscreen",
                        TRIGGERBOT_ENABLED and TRIGGERBOT_ONSCREEN_ONLY,
                        "on screen only",
                        "ON"
                    )

                    getgenv().GohthBindOverlay.Set(
                        "esp",
                        ESP_ENABLED,
                        "esp",
                        "ON"
                    )

                    getgenv().GohthBindOverlay.Set(
                        "speed",
                        getgenv().GohthSpeedActive == true,
                        "speed",
                        getgenv().GohthSpeedKeyName or "T"
                    )

                    getgenv().GohthBindOverlay.Set(
                        "jump",
                        getgenv().GohthJumpActive == true,
                        "jump power",
                        "ON"
                    )

                    getgenv().GohthBindOverlay.Set(
                        "panic",
                        getgenv().GohthPanicEnabled == true,
                        "panic ground",
                        getgenv().GohthPanicKeyName or "G"
                    )
                end
            }

            -- Active-state defaults: inactive features stay off the list.
            getgenv().GohthSpeedActive = getgenv().GohthSpeedActive == true
            getgenv().GohthJumpActive = getgenv().GohthJumpActive == true
            getgenv().GohthPanicActive = false

            getgenv().GohthBindOverlay.Refresh()
        end)

        local AimbotPage = Window:Page({Name = "Aim Assist"})
        local VisualsPage = Window:Page({Name = "Visuals"})
        local SpeedPage = Window:Page({Name = "Speed"})
        local MiscPage = Window:Page({Name = "Misc"})
        
        --// WalkSpeed system
        task.spawn(function()
            getgenv().walkSpeedSettings = {
                WalkSpeed = {
                    Enabled = true,
                    Speed = 300,
                },
                Activation = {
                    WalkSpeedToggleKey = "T",
                    Mode = "Toggle", -- Toggle = press once on/off, Hold = active only while held
                }
            }

            local speedState = {
                Enabled = false,
                DefaultSpeed = 16,
            }

            local function getHumanoid()
                local character = LocalPlayer.Character
                return character and character:FindFirstChildOfClass("Humanoid")
            end

            local function applySpeed()
                local humanoid = getHumanoid()
                if not humanoid then return end

                if speedState.Enabled and getgenv().walkSpeedSettings.WalkSpeed.Enabled then
                    humanoid.WalkSpeed = getgenv().walkSpeedSettings.WalkSpeed.Speed
                else
                    humanoid.WalkSpeed = speedState.DefaultSpeed
                end
            end

            LocalPlayer.CharacterAdded:Connect(function(character)
                local humanoid = character:WaitForChild("Humanoid")
                speedState.DefaultSpeed = humanoid.WalkSpeed
                applySpeed()
            end)

            task.spawn(function()
                while task.wait(0.10) do
                    if speedState.Enabled and getgenv().walkSpeedSettings.WalkSpeed.Enabled then
                        applySpeed()
                    end
                end
            end)

            -- IMPORTANT: message (6) uses numeric sides (1 / 2), not "Left".
            local SpeedSection = SpeedPage:Section({
                Name = "WalkSpeed",
                Side = 1
            })

            local SpeedToggle = SpeedSection:Toggle({
                Name = "Enable WalkSpeed",
                Flag = "WeakWalkSpeedEnabled",
                Default = false,
                Callback = function(value)
                    speedState.Enabled = value
                    getgenv().GohthSpeedActive = speedState.Enabled == true
                    applySpeed()
                    if getgenv().GohthBindOverlay then
                        getgenv().GohthBindOverlay.Refresh()
                    end
                end
            })

            -- Changeable activation key. Default = T.
            getgenv().GohthSpeedKeyName = getgenv().GohthSpeedKeyName or "T"

            local SpeedKeybind
            SpeedKeybind = SpeedToggle:Keybind({
                Name = "WalkSpeed Key",
                Flag = "WeakWalkSpeedKey",
                Default = Enum.KeyCode.T,
                Mode = getgenv().walkSpeedSettings.Activation.Mode,
                Callback = function(value)
                    speedState.Enabled = value == true
                    getgenv().GohthSpeedActive = speedState.Enabled
                    applySpeed()

                    if SpeedKeybind and SpeedKeybind.Key then
                        local keyName = tostring(SpeedKeybind.Key):match("Enum%.KeyCode%.(.+)")
                        if keyName then
                            getgenv().GohthSpeedKeyName = keyName
                        end
                    end

                    if getgenv().GohthBindOverlay then
                        getgenv().GohthBindOverlay.Refresh()
                    end
                end
            })

            -- Choose how the speed key behaves:
            -- Toggle = press once to turn speed ON, press again to turn it OFF.
            -- Hold   = speed stays ON only while the key is held.
            SpeedSection:Dropdown({
                Name = "Activation Mode",
                Flag = "WeakWalkSpeedMode",
                Default = getgenv().walkSpeedSettings.Activation.Mode,
                Items = {"Toggle", "Hold"},
                Callback = function(value)
                    if value ~= "Toggle" and value ~= "Hold" then return end

                    getgenv().walkSpeedSettings.Activation.Mode = value

                    if SpeedKeybind then
                        SpeedKeybind:SetMode(value)
                    end

                    -- Switching modes starts from OFF so Hold/Toggle never inherits
                    -- a stale active state from the previous mode.
                    speedState.Enabled = false
                    getgenv().GohthSpeedActive = false
                    applySpeed()

                    if getgenv().GohthBindOverlay then
                        getgenv().GohthBindOverlay.Refresh()
                    end
                end
            })

            -- Sync the selected WalkSpeed key to the bottom keybind list.
            do
                local OriginalSpeedKeySet = SpeedKeybind.Set
                function SpeedKeybind:Set(Key)
                    OriginalSpeedKeySet(self, Key)

                    local keyName = tostring(self.Key):match("Enum%.KeyCode%.(.+)")
                    if keyName then
                        getgenv().GohthSpeedKeyName = keyName
                    end

                    if getgenv().GohthBindOverlay then
                        getgenv().GohthBindOverlay.Refresh()
                    end
                end
            end

            -- Adjustable WalkSpeed amount.
            SpeedSection:Slider({
                Name = "Speed Amount",
                Flag = "WeakWalkSpeedAmount",
                Default = getgenv().walkSpeedSettings.WalkSpeed.Speed,
                Min = 16,
                Max = 1000,
                Decimals = 1,
                Callback = function(value)
                    getgenv().walkSpeedSettings.WalkSpeed.Speed = math.floor(value + 0.5)
                    applySpeed()
                end
            })

        end)

        --// Unified JumpPower / Wall Jump / No Jump Cooldown system
        -- All jump features live in one controller so they cannot overwrite each other.
        task.spawn(function()
            local jumpSettings = {
                SuperEnabled = false,
                Power = 50,

                WallEnabled = false,
                WallCheckDistance = 3.5,
                WallUpForce = 52,

                NoCooldown = false,
            }

            getgenv().GohthJumpState = jumpSettings

            local function getCharacterParts()
                local character = LocalPlayer.Character
                if not character then return nil end

                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local root = character:FindFirstChild("HumanoidRootPart")

                if not humanoid or not root or humanoid.Health <= 0 then
                    return nil
                end

                return character, humanoid, root
            end

            local function isGrounded(humanoid)
                return humanoid.FloorMaterial ~= Enum.Material.Air
            end

            local function getNormalJumpVelocity(humanoid)
                if humanoid.UseJumpPower then
                    return math.max(humanoid.JumpPower, 50)
                end

                return math.sqrt(
                    2 * Workspace.Gravity * math.max(humanoid.JumpHeight, 7.2)
                )
            end

            local function getGroundJumpVelocity(humanoid)
                if jumpSettings.SuperEnabled then
                    return jumpSettings.Power
                end

                return getNormalJumpVelocity(humanoid)
            end

            local function performGroundJump()
                local character, humanoid, root = getCharacterParts()
                if not character then return false end
                if not isGrounded(humanoid) then return false end

                -- Keep Humanoid properties correct for games that read them.
                if jumpSettings.SuperEnabled then
                    humanoid.UseJumpPower = true
                    humanoid.JumpPower = jumpSettings.Power
                end

                -- Request the normal animation/state, then apply the actual vertical
                -- velocity ourselves. This makes JumpPower work even in Da Hood-style
                -- movement code that replaces or throttles the default jump impulse.
                humanoid.Jump = true

                local velocity = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = Vector3.new(
                    velocity.X,
                    getGroundJumpVelocity(humanoid),
                    velocity.Z
                )

                return true
            end

            local function getWallHit(character, root)
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = {character}
                params.IgnoreWater = true

                local cf = root.CFrame
                local directions = {
                    cf.LookVector,
                    -cf.LookVector,
                    cf.RightVector,
                    -cf.RightVector,
                }

                local bestHit
                local bestDistance = math.huge

                for _, direction in ipairs(directions) do
                    local hit = Workspace:Raycast(
                        root.Position,
                        direction.Unit * jumpSettings.WallCheckDistance,
                        params
                    )

                    if hit and hit.Instance and hit.Instance.CanCollide then
                        local distance = (hit.Position - root.Position).Magnitude
                        if distance < bestDistance then
                            bestDistance = distance
                            bestHit = hit
                        end
                    end
                end

                return bestHit
            end

            local function performWallJump()
                if not jumpSettings.WallEnabled then return false end

                local character, humanoid, root = getCharacterParts()
                if not character then return false end
                if isGrounded(humanoid) then return false end

                local hit = getWallHit(character, root)
                if not hit then return false end

                local targetVelocity = jumpSettings.WallUpForce

                -- Super Jump also increases wall-jump height, but Wall Jump is
                -- no longer required for Super Jump to work.
                if jumpSettings.SuperEnabled then
                    targetVelocity = math.max(targetVelocity, jumpSettings.Power)
                end

                local velocity = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = Vector3.new(
                    velocity.X,
                    math.max(velocity.Y, targetVelocity),
                    velocity.Z
                )

                return true
            end

            -- Keep the Humanoid property synced while Super Jump is enabled.
            -- The actual ground jump boost is handled by performGroundJump().
            task.spawn(function()
                while task.wait(0.10) do
                    if jumpSettings.SuperEnabled then
                        local _, humanoid = getCharacterParts()
                        if humanoid then
                            humanoid.UseJumpPower = true
                            humanoid.JumpPower = jumpSettings.Power
                        end
                    end
                end
            end)

            local JumpSection = SpeedPage:Section({
                Name = "JumpPower",
                Side = 2
            })

            JumpSection:Toggle({
                Name = "Enable JumpPower",
                Flag = "WeakJumpPowerEnabled",
                Default = false,
                Callback = function(value)
                    jumpSettings.SuperEnabled = value == true
                    getgenv().GohthJumpActive = jumpSettings.SuperEnabled

                    if jumpSettings.SuperEnabled then
                        local _, humanoid = getCharacterParts()
                        if humanoid then
                            humanoid.UseJumpPower = true
                            humanoid.JumpPower = jumpSettings.Power
                        end
                    end

                    if getgenv().GohthBindOverlay then
                        getgenv().GohthBindOverlay.Refresh()
                    end
                end
            })

            JumpSection:Slider({
                Name = "JumpPower Amount",
                Flag = "WeakJumpPowerAmount",
                Default = jumpSettings.Power,
                Min = 0,
                Max = 500,
                Decimals = 1,
                Callback = function(value)
                    jumpSettings.Power = math.floor(value + 0.5)

                    if jumpSettings.SuperEnabled then
                        local _, humanoid = getCharacterParts()
                        if humanoid then
                            humanoid.UseJumpPower = true
                            humanoid.JumpPower = jumpSettings.Power
                        end
                    end
                end
            })

            local WallJumpSection = SpeedPage:Section({
                Name = "Wall Jump",
                Side = 2
            })

            WallJumpSection:Toggle({
                Name = "Enable Wall Jump",
                Flag = "WeakWallJumpEnabled",
                Default = false,
                Callback = function(value)
                    jumpSettings.WallEnabled = value == true
                end
            })

            WallJumpSection:Toggle({
                Name = "No Jump Cooldown",
                Flag = "WeakNoJumpCooldown",
                Default = false,
                Callback = function(value)
                    jumpSettings.NoCooldown = value == true
                end
            })

            WallJumpSection:Slider({
                Name = "Wall Jump Height",
                Flag = "WeakWallJumpHeight",
                Default = jumpSettings.WallUpForce,
                Min = 20,
                Max = 100,
                Decimals = 1,
                Callback = function(value)
                    jumpSettings.WallUpForce = math.floor(value + 0.5)
                end
            })

            -- One JumpRequest handler for normal jump + wall jump.
            UserInputService.JumpRequest:Connect(function()
                local _, humanoid = getCharacterParts()
                if not humanoid then return end

                if isGrounded(humanoid) then
                    -- Always use our ground handler while Super Jump is on.
                    -- When NoCooldown is on, this also bypasses the game's 3-jump throttle.
                    if jumpSettings.SuperEnabled or jumpSettings.NoCooldown then
                        performGroundJump()
                    end
                else
                    performWallJump()
                end
            end)

            -- Holding Space support for No Jump Cooldown.
            local holdingSpace = false
            local armedForLanding = true

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end

                if input.KeyCode == Enum.KeyCode.Space then
                    holdingSpace = true

                    if jumpSettings.NoCooldown then
                        local _, humanoid = getCharacterParts()
                        if humanoid and isGrounded(humanoid) and armedForLanding then
                            if performGroundJump() then
                                armedForLanding = false
                            end
                        end
                    end
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.Space then
                    holdingSpace = false
                    armedForLanding = true
                end
            end)

            task.spawn(function()
                while task.wait(0.03) do
                    if jumpSettings.NoCooldown and holdingSpace then
                        local _, humanoid = getCharacterParts()

                        if humanoid then
                            if isGrounded(humanoid) then
                                if armedForLanding and performGroundJump() then
                                    armedForLanding = false
                                end
                            else
                                -- Re-arm only after the character actually leaves the ground.
                                armedForLanding = true
                            end
                        end
                    end
                end
            end)
        end)

        --// Panic Ground system
        -- Press the selected key to instantly place your character on the
        -- nearest solid ground directly underneath you.
        task.spawn(function()
            local function panicGround()
                local character = LocalPlayer.Character
                if not character then return end

                local root = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not root or not humanoid or humanoid.Health <= 0 then return end

                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = {character}
                params.IgnoreWater = false

                local result = workspace:Raycast(
                    root.Position,
                    Vector3.new(0, -10000, 0),
                    params
                )

                if result then
                    local groundY = result.Position.Y
                    local rootOffset = humanoid.HipHeight + (root.Size.Y * 0.5)

                    -- Keep the player's current facing direction.
                    local look = root.CFrame.LookVector
                    local flatLook = Vector3.new(look.X, 0, look.Z)
                    if flatLook.Magnitude < 0.001 then
                        flatLook = Vector3.new(0, 0, -1)
                    else
                        flatLook = flatLook.Unit
                    end

                    local newPos = Vector3.new(root.Position.X, groundY + rootOffset, root.Position.Z)
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                    root.CFrame = CFrame.lookAt(newPos, newPos + flatLook)
                end
            end

            local PanicSection = SpeedPage:Section({
                Name = "Panic Ground",
                Side = 1
            })

            getgenv().GohthPanicKeyName = getgenv().GohthPanicKeyName or "G"
            getgenv().GohthPanicEnabled = false
            getgenv().GohthPanicActive = false

            PanicSection:Toggle({
                Name = "Enable Panic Ground",
                Flag = "WeakPanicGroundEnabled",
                Default = false,
                Callback = function(value)
                    getgenv().GohthPanicEnabled = value == true

                    -- Turning the master switch off also clears the keybind state.
                    if not getgenv().GohthPanicEnabled then
                        getgenv().GohthPanicActive = false
                        local bind = getgenv().GohthPanicKeybindObject
                        if bind then
                            bind.Toggled = false
                        end
                    end

                    if getgenv().GohthBindOverlay then
                        getgenv().GohthBindOverlay.Refresh()
                    end
                end
            })

            local PanicKeybind
            PanicKeybind = PanicSection:Label({
                Name = "Panic Ground Key"
            }):Keybind({
                Flag = "WeakPanicGroundKey",
                Default = Enum.KeyCode.G,
                Mode = "Hold",
                Callback = function(value)
                    if PanicKeybind and PanicKeybind.Key then
                        local keyName = tostring(PanicKeybind.Key):match("Enum%.KeyCode%.(.+)")
                        if keyName then
                            getgenv().GohthPanicKeyName = keyName
                        end
                    end

                    -- Keybind only works while Enable Panic Ground is ON.
                    if not getgenv().GohthPanicEnabled then
                        getgenv().GohthPanicActive = false
                        if PanicKeybind then
                            PanicKeybind.Toggled = false
                        end

                        if getgenv().GohthBindOverlay then
                            getgenv().GohthBindOverlay.Refresh()
                        end
                        return
                    end

                    -- The library callback is only used to keep the selected
                    -- key/display synced. Actual Panic Ground activation is
                    -- handled by a direct InputBegan listener below so one
                    -- physical key press always fires exactly once.
                    getgenv().GohthPanicActive = false

                    if getgenv().GohthBindOverlay then
                        getgenv().GohthBindOverlay.Refresh()
                    end
                end
            })

            getgenv().GohthPanicKeybindObject = PanicKeybind

            -- Direct action listener: bypasses the UI library's toggle/hold
            -- state so pressing the selected key once always activates Panic Ground.
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if not getgenv().GohthPanicEnabled then return end
                if UserInputService:GetFocusedTextBox() then return end

                local bind = getgenv().GohthPanicKeybindObject
                if not bind or not bind.Key then return end

                local selectedName = tostring(bind.Key):match("Enum%.KeyCode%.(.+)")
                if not selectedName then return end

                local selectedKey = Enum.KeyCode[selectedName]
                if selectedKey and input.KeyCode == selectedKey then
                    panicGround()
                end
            end)

            -- Sync the selected Panic Ground key to the bottom keybind list.
            do
                local OriginalPanicKeySet = PanicKeybind.Set
                function PanicKeybind:Set(Key)
                    OriginalPanicKeySet(self, Key)

                    local keyName = tostring(self.Key):match("Enum%.KeyCode%.(.+)")
                    if keyName then
                        getgenv().GohthPanicKeyName = keyName
                    end

                    if getgenv().GohthBindOverlay then
                        getgenv().GohthBindOverlay.Refresh()
                    end
                end
            end

            PanicSection:Button({
                Name = "Panic Ground Now",
                Callback = function()
                    panicGround()
                end
            })

        end)

        Window:CreateSettingsPage()

        -- AIMBOT ----------------------------------------------------
        local AimSection = AimbotPage:Section({Name = "Aim Assist", Side = 1})

        AimSection:Toggle({
            Name = "Enable Aim Assist",
            Flag = "WeakAimlock",
            Default = false,
            Callback = function(Value)
                -- Master switch only. Turning this ON arms aimlock, but does not
                -- lock a target until the configured aimlock key is pressed.
                getgenv().GohthAimlockEnabled = Value == true

                -- Whenever the master switch changes, start in an unlocked state.
                LOCK_ENABLED = false
                TARGET = nil
                Camera.CameraType = Enum.CameraType.Custom

                -- Reset the keybind's internal Toggle state so the first key press
                -- after enabling always locks instead of accidentally unlocking.
                local bind = getgenv().GohthAimKeybindObject
                if bind then
                    bind.Toggled = false
                    if bind.Flag and getgenv().Library and getgenv().Library.Flags then
                        getgenv().Library.Flags[bind.Flag] = {
                            Mode = bind.Mode,
                            Key = bind.Key,
                            Toggled = false
                        }
                    end
                end

                if getgenv().GohthBindOverlay then
                    getgenv().GohthBindOverlay.Refresh()
                end
            end
        })

        AimSection:Dropdown({
            Name = "Lock Part",
            Flag = "WeakLockPart",
            Default = LOCK_PART,
            Items = {"Head", "Torso", "HumanoidRootPart"},
            Callback = function(Value)
                LOCK_PART = Value
            end
        })

        AimSection:Slider({
            Name = "FOV",
            Flag = "WeakFOV",
            Default = LOCK_FOV,
            Min = FOV_MIN,
            Max = FOV_MAX,
            Decimals = 1,
            Callback = function(Value)
                LOCK_FOV = math.floor(Value + 0.5)
                updateFOVCircle()
            end
        })

        AimSection:Toggle({
            Name = "Visible Check",
            Flag = "WeakVisibleCheck",
            Default = LOCK_VISIBLE_CHECK,
            Callback = function(Value)
                LOCK_VISIBLE_CHECK = Value
                if getgenv().GohthBindOverlay then
                    getgenv().GohthBindOverlay.Refresh()
                end
            end
        })


        AimSection:Toggle({
            Name = "Ignore Team",
            Flag = "WeakTeamCheck",
            Default = LOCK_TEAM_CHECK,
            Callback = function(Value)
                LOCK_TEAM_CHECK = Value
                if getgenv().GohthBindOverlay then
                    getgenv().GohthBindOverlay.Refresh()
                end
            end
        })

        -- Aim Assist activation mode:
        -- Toggle = press once ON, press again OFF.
        -- Hold   = stays ON only while the aim key is held.
        getgenv().GohthAimActivationMode = getgenv().GohthAimActivationMode or "Toggle"

        -- Aim Assist keybind: the UI library's callback returns the TOGGLED state,
        -- not the newly selected key. Keep the returned Keybind object so we can
        -- read its Key/Value and make it control the real aimlock state.
        local AimKeybind
        AimKeybind = AimSection:Label({
            Name = "Aim Assist Key"
        }):Keybind({
            Flag = "WeakAimKey",
            Default = LOCK_KEY,
            Mode = getgenv().GohthAimActivationMode,
            Callback = function(Value)
                if AimKeybind and AimKeybind.Key then
                    local keyName = tostring(AimKeybind.Key):match("Enum%.KeyCode%.(.+)")
                    if keyName and Enum.KeyCode[keyName] then
                        LOCK_KEY = Enum.KeyCode[keyName]
                    end
                end

                -- The key only does anything while Enable Aim Assist is ON.
                if not getgenv().GohthAimlockEnabled then
                    LOCK_ENABLED = false
                    TARGET = nil
                    Camera.CameraType = Enum.CameraType.Custom

                    if AimKeybind then
                        AimKeybind.Toggled = false
                    end

                    if getgenv().GohthBindOverlay then
                        getgenv().GohthBindOverlay.Refresh()
                    end
                    return
                end

                LOCK_ENABLED = Value == true

                if LOCK_ENABLED then
                    TARGET = getPlayerUnderCrosshair()

                    -- If nobody valid is inside the FOV, remain unlocked.
                    if not TARGET then
                        LOCK_ENABLED = false
                        if AimKeybind then
                            AimKeybind.Toggled = false
                        end
                    end
                else
                    TARGET = nil
                    Camera.CameraType = Enum.CameraType.Custom
                end

                if getgenv().GohthBindOverlay then
                    getgenv().GohthBindOverlay.Refresh()
                end
            end
        })

        getgenv().GohthAimKeybindObject = AimKeybind

        AimSection:Dropdown({
            Name = "Activation Mode",
            Flag = "WeakAimActivationMode",
            Default = getgenv().GohthAimActivationMode,
            Items = {"Toggle", "Hold"},
            Callback = function(Value)
                if Value ~= "Toggle" and Value ~= "Hold" then return end

                getgenv().GohthAimActivationMode = Value

                if AimKeybind then
                    AimKeybind:SetMode(Value)
                    AimKeybind.Toggled = false
                end

                -- Changing modes always starts unlocked so the new mode
                -- cannot inherit the previous Toggle/Hold state.
                LOCK_ENABLED = false
                TARGET = nil
                Camera.CameraType = Enum.CameraType.Custom

                if getgenv().GohthBindOverlay then
                    getgenv().GohthBindOverlay.Refresh()
                end
            end
        })

        -- The library does not send the selected key to Callback, so wrap Set()
        -- and sync LOCK_KEY + the centered keybind list whenever the bind changes.
        do
            local OriginalAimKeySet = AimKeybind.Set
            function AimKeybind:Set(Key)
                OriginalAimKeySet(self, Key)

                local keyName = tostring(self.Key):match("Enum%.KeyCode%.(.+)")
                if keyName and Enum.KeyCode[keyName] then
                    LOCK_KEY = Enum.KeyCode[keyName]
                end

                if getgenv().GohthBindOverlay then
                    getgenv().GohthBindOverlay.Refresh()
                end
            end
        end

        local SmoothSection = AimbotPage:Section({Name = "Aim Assist Smoothness", Side = 2})

        SmoothSection:Toggle({
            Name = "Smooth Aim",
            Flag = "WeakSmooth",
            Default = SMOOTHNESS_ENABLED,
            Callback = function(Value)
                SMOOTHNESS_ENABLED = Value
            end
        })

        SmoothSection:Dropdown({
            Name = "Response",
            Flag = "WeakSmoothType",
            Default = SMOOTHNESS_TYPE,
            Items = {"Soft", "Balanced", "Responsive"},
            Callback = function(Value)
                SMOOTHNESS_TYPE = Value
            end
        })

        SmoothSection:Toggle({
            Name = "Dynamic Smoothing",
            Flag = "WeakDynamicSmooth",
            Default = getgenv().GohthAimSmooth.Dynamic,
            Callback = function(Value)
                getgenv().GohthAimSmooth.Dynamic = Value == true
            end
        })

        SmoothSection:Toggle({
            Name = "Micro Smoothing",
            Flag = "WeakMicroSmooth",
            Default = getgenv().GohthAimSmooth.Micro,
            Callback = function(Value)
                getgenv().GohthAimSmooth.Micro = Value == true
            end
        })

        SmoothSection:Slider({
            Name = "Tracking Speed",
            Flag = "WeakSmoothStrength",
            Default = SMOOTHNESS_VALUE,
            Min = SMOOTHNESS_MIN,
            Max = SMOOTHNESS_MAX,
            Decimals = 0.1,
            Callback = function(Value)
                SMOOTHNESS_VALUE = math.clamp(Value, SMOOTHNESS_MIN, SMOOTHNESS_MAX)
            end
        })

        SmoothSection:Slider({
            Name = "Fine Aim Speed",
            Flag = "WeakDampSpeed",
            Default = getgenv().GohthAimSmooth.NearSpeed,
            Min = DAMP_SPEED_MIN,
            Max = DAMP_SPEED_MAX,
            Decimals = 0.1,
            Callback = function(Value)
                SMOOTH_DAMP_SPEED = math.clamp(Value, DAMP_SPEED_MIN, DAMP_SPEED_MAX)
                getgenv().GohthAimSmooth.NearSpeed = SMOOTH_DAMP_SPEED
            end
        })

        SmoothSection:Slider({
            Name = "Dynamic Curve",
            Flag = "WeakSmoothCurve",
            Default = getgenv().GohthAimSmooth.Curve,
            Min = 0.25,
            Max = 2.5,
            Decimals = 0.05,
            Callback = function(Value)
                getgenv().GohthAimSmooth.Curve = math.clamp(Value, 0.25, 2.5)
            end
        })

        SmoothSection:Label({
            Name = "Higher speed = faster tracking"
        })

        -- Triggerbot settings live in the Aimbot page.
        local TriggerSection = AimbotPage:Section({Name = "Triggerbot Settings", Side = 2})

        TriggerSection:Toggle({
            Name = "Enable Triggerbot",
            Flag = "WeakTriggerbot",
            Default = TRIGGERBOT_ENABLED,
            Callback = function(Value)
                TRIGGERBOT_ENABLED = Value
                if not Value then
                    triggerbotLastShot = 0
                end
                if getgenv().GohthBindOverlay then
                    getgenv().GohthBindOverlay.Refresh()
                end
            end
        })

        TriggerSection:Slider({
            Name = "Fire Interval",
            Flag = "WeakTriggerbotInterval",
            Default = TRIGGERBOT_INTERVAL,
            Min = 0.03,
            Max = 0.50,
            Decimals = 0.01,
            Callback = function(Value)
                TRIGGERBOT_INTERVAL = math.clamp(Value, 0.03, 0.50)
            end
        })

        TriggerSection:Toggle({
            Name = "On Screen Only",
            Flag = "WeakTriggerbotOnScreen",
            Default = TRIGGERBOT_ONSCREEN_ONLY,
            Callback = function(Value)
                TRIGGERBOT_ONSCREEN_ONLY = Value
                if getgenv().GohthBindOverlay then
                    getgenv().GohthBindOverlay.Refresh()
                end
            end
        })

        TriggerSection:Label({
            Name = "Visible targets only (always on)"
        })

        -- VISUALS ---------------------------------------------------
        local ESPSection = VisualsPage:Section({Name = "Player ESP", Side = 1})

        ESPSection:Toggle({
            Name = "Enable ESP",
            Flag = "WeakESP",
            Default = ESP_ENABLED,
            Callback = function(Value)
                ESP_ENABLED = Value
                if getgenv().GohthBindOverlay then
                    getgenv().GohthBindOverlay.Refresh()
                end
            end
        })

        ESPSection:Toggle({
            Name = "Style ESP",
            Flag = "WeakChams",
            Default = CHAMS_ENABLED,
            Callback = function(Value)
                CHAMS_ENABLED = Value
                if getgenv().GohthBindOverlay then
                    getgenv().GohthBindOverlay.Refresh()
                end
            end
        })

        ESPSection:Dropdown({
            Name = "ESP Type",
            Flag = "WeakESPStyle",
            Default = getgenv().WeakESPStyle,
            Items = {"Chams", "Box", "Corner Box"},
            Callback = function(Value)
                getgenv().WeakESPStyle = Value
                if getgenv().GohthBindOverlay then
                    getgenv().GohthBindOverlay.Refresh()
                end
            end
        })

        ESPSection:Toggle({
            Name = "Name ESP",
            Flag = "WeakNameESP",
            Default = NAME_ESP_ENABLED,
            Callback = function(Value)
                NAME_ESP_ENABLED = Value
                if getgenv().GohthBindOverlay then
                    getgenv().GohthBindOverlay.Refresh()
                end
            end
        })

        ESPSection:Toggle({
            Name = "Target Line",
            Flag = "GohthTargetLine",
            Default = getgenv().GohthTargetLineEnabled,
            Callback = function(Value)
                getgenv().GohthTargetLineEnabled = Value == true

                if not Value and getgenv().GohthTargetLineObject then
                    getgenv().GohthTargetLineObject.Visible = false
                end
            end
        })

        ESPSection:Label({Name = "Target Line Color"}):Colorpicker({
            Name = "Target Line Color",
            Flag = "GohthTargetLineColor",
            Default = getgenv().GohthTargetLineColor,
            Callback = function(Color)
                getgenv().GohthTargetLineColor = Color

                if getgenv().GohthTargetLineObject then
                    getgenv().GohthTargetLineObject.BackgroundColor3 = Color
                end
            end
        })

        ESPSection:Label({Name = "Visible Color"}):Colorpicker({
            Flag = "WeakVisibleColor",
            Default = VISIBLE_COLOR,
            Callback = function(Value)
                VISIBLE_COLOR = Value
            end
        })

        local FOVSection = VisualsPage:Section({Name = "FOV", Side = 2})

        FOVSection:Toggle({
            Name = "Show FOV Circle",
            Flag = "WeakShowFOV",
            Default = SHOW_FOV,
            Callback = function(Value)
                SHOW_FOV = Value
                FOV_CIRCLE_ENABLED = Value
                updateFOVCircle()
                if getgenv().GohthBindOverlay then
                    getgenv().GohthBindOverlay.Refresh()
                end
            end
        })

        FOVSection:Label({Name = "FOV Color"}):Colorpicker({
            Flag = "WeakFOVColor",
            Default = FOV_COLOR,
            Callback = function(Value)
                FOV_COLOR = Value
                updateFOVCircle()
            end
        })

        FOVSection:Slider({
            Name = "Thickness",
            Flag = "WeakFOVThickness",
            Default = FOV_THICKNESS,
            Min = 1,
            Max = 8,
            Decimals = 1,
            Callback = function(Value)
                FOV_THICKNESS = math.floor(Value + 0.5)
                updateFOVCircle()
            end
        })

        -- MISC ------------------------------------------------------
        local MiscSection = MiscPage:Section({Name = "gohth.cc (fg cheat)", Side = 1})

        MiscSection:Toggle({
            Name = "Top Status Bar",
            Flag = "GohthTopStatusBar",
            Default = getgenv().GohthTopStatusEnabled ~= false,
            Callback = function(value)
                getgenv().GohthTopStatusEnabled = value == true

                local statusGui = getgenv().GohthTopStatusGui
                if statusGui then
                    statusGui.Enabled = value == true
                end
            end
        })

        MiscSection:Toggle({
            Name = "Center Keybind List",
            Flag = "GohthCenterKeybindList",
            Default = true,
            Callback = function(value)
                -- Keep the old boxed Library keybind list permanently hidden.
                KeybindList:SetVisible(false)

                if getgenv().GohthBindOverlay then
                    getgenv().GohthBindOverlay.SetVisible(value)
                    if value then
                        getgenv().GohthBindOverlay.Refresh()
                    end
                end
            end
        })

        MiscSection:Button({
            Name = "Test Notification",
            Callback = function()
                Library:Notification("gohth.cc (fg cheat) | All systems ready", 3, Library.Theme.Accent)
            end
        })

        MiscSection:Button({
            Name = "Center Menu",
            Callback = function()
                Window:Center()
            end
        })

        -- Keep the message (6) settings/config/theme page intact.
        getgenv().Library = Library

        createNotification()

        Library:Notification("gohth.cc (fg cheat) loaded", 3, Library.Theme.Accent)
    end
end)

-- Keybind changer

local waitingForKeybind = false

local function updateKeybind()

    keyBtn.Text = tostring(LOCK_KEY.Name)

end

keyBtn.MouseButton1Click:Connect(function()

    if waitingForKeybind then return end

    waitingForKeybind = true

    keyBtn.Text = "?"

    keyBtn.TextColor3 = UI.Text

end)

updateKeybind()

-- Hidden labels for updateUI

local LockLabel = createLabel(Main, "LOCK: OFF", UDim2.fromOffset(0, 0), UDim2.fromOffset(1, 1), 1, UI.Text)

LockLabel.Visible = false

----------------------------------------------------------------

--// UI Update

----------------------------------------------------------------

updateUI = function()

    if LOCK_ENABLED then

        LockLabel.Text = "LOCK: ON"

        LockLabel.TextColor3 = UI.Green

        lockStatus.Text = "ON"

        lockStatus.TextColor3 = UI.Green

    else

        LockLabel.Text = "LOCK: OFF"

        LockLabel.TextColor3 = UI.Red

        lockStatus.Text = "OFF"

        lockStatus.TextColor3 = UI.Red

    end

    if TARGET then

        targetVal.Text = TARGET.DisplayName

        targetVal.TextColor3 = UI.Text

    else

        targetVal.Text = "NONE"

        targetVal.TextColor3 = UI.TextDim

    end

end

----------------------------------------------------------------

--// Toggle lock

----------------------------------------------------------------

local function toggleLock()

    LOCK_ENABLED = not LOCK_ENABLED
    if getgenv().GohthBindOverlay then
        getgenv().GohthBindOverlay.Set(
            "aimlock",
            LOCK_ENABLED,
            "aimlock",
            LOCK_KEY and LOCK_KEY.Name or "Q"
        )
    end

    if LOCK_ENABLED then

        TARGET = getPlayerUnderCrosshair()

    else

        TARGET = nil

        Camera.CameraType = Enum.CameraType.Custom

    end

    updateUI()

end

--// Keybind Input Handler

UserInputService.InputBegan:Connect(function(input, gameProcessed)

    if waitingForKeybind then

        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then

            LOCK_KEY = input.KeyCode

            waitingForKeybind = false

            keyBtn.TextColor3 = UI.Accent

            updateKeybind()
            if getgenv().GohthBindOverlay then
                getgenv().GohthBindOverlay.Set(
                    "aimlock",
                    LOCK_ENABLED,
                    "aimlock",
                    LOCK_KEY and LOCK_KEY.Name or "Q"
                )
            end

        end

        return

    end

    if gameProcessed then return end

    -- Aimlock input is handled by the new Library Keybind control above.
    -- Do not also toggle it here, or one key press can be processed twice.

    -- Insert is reserved for the new message (6) menu.
    -- The legacy gohth.cc (fg cheat) Main frame stays permanently hidden.

end)

----------------------------------------------------------------

--// Legacy menu visibility guard
Main.Visible = false
Main:GetPropertyChangedSignal("Visible"):Connect(function()
    if Main.Visible then
        Main.Visible = false
    end
end)

--// Dragging

----------------------------------------------------------------

local dragging = false

local dragStart, startPos

TitleBar.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then

        if Main.Visible then

            dragging = true

            dragStart = input.Position

            startPos = Main.Position

        end

    end

end)

TitleBar.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = false

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(

            startPos.X.Scale,

            startPos.X.Offset + delta.X,

            startPos.Y.Scale,

            startPos.Y.Offset + delta.Y

        )

    end

end)

----------------------------------------------------------------

--// Update ESP (optimized)

----------------------------------------------------------------

-- Cache chams so GetDescendants() is not called for every player every frame.
local WeakChamCache = {}

local function getCachedChams(character)
    local cached = WeakChamCache[character]
    if cached then
        return cached
    end

    cached = {}
    for _, object in ipairs(character:GetDescendants()) do
        if object:IsA("BoxHandleAdornment") and object.Name == "BlockyCham" then
            cached[#cached + 1] = object
        end
    end

    WeakChamCache[character] = cached

    character.DescendantAdded:Connect(function(object)
        if object:IsA("BoxHandleAdornment") and object.Name == "BlockyCham" then
            cached[#cached + 1] = object
        end
    end)

    character.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            WeakChamCache[character] = nil
        end
    end)

    return cached
end

-- Chams/name state does not need to be rewritten every rendered frame.
-- 12 updates/sec is visually responsive while cutting a lot of Lua work.
task.spawn(function()
    while task.wait(1 / 12) do
        local style = getgenv().WeakESPStyle

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local character = player.Character

                if character then
                    for _, object in ipairs(getCachedChams(character)) do
                        if object and object.Parent then
                            object.Color3 = VISIBLE_COLOR
                            object.Visible = ESP_ENABLED and CHAMS_ENABLED and style == "Chams"
                        end
                    end

                    local head = character:FindFirstChild("Head")
                    local nameGui = head and head:FindFirstChild("NameESP")

                    if nameGui then
                        nameGui.Enabled = ESP_ENABLED and NAME_ESP_ENABLED

                        local nameLabel = nameGui:FindFirstChildOfClass("TextLabel")
                        if nameLabel then
                            nameLabel.TextColor3 = VISIBLE_COLOR
                        end
                    end
                end
            end
        end
    end
end)

-- Box/Corner Box still needs per-frame screen positioning, but only when selected.
RunService.RenderStepped:Connect(function()
    if not ESP_ENABLED or not CHAMS_ENABLED then
        return
    end

    local style = getgenv().WeakESPStyle
    if style ~= "Box" and style ~= "Corner Box" then
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            getgenv().WeakBoxESP.update(player, player.Character, VISIBLE_COLOR)
        end
    end
end)

----------------------------------------------------------------

--// Camera lock with Smoothing

----------------------------------------------------------------

--// Camera lock register-isolation scope
task.spawn(function()

local function updateTriggerbot()
    -- Triggerbot only runs while the normal aimlock has an active target.
    if not TRIGGERBOT_ENABLED or not LOCK_ENABLED or not TARGET then
        return
    end

    local character = TARGET.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local lockPart = character and getLockPart(character)
    if not character or not humanoid or humanoid.Health <= 0 or not lockPart then
        return
    end

    -- Always require a real clear line of sight. This is intentionally
    -- independent from the optional Aimlock Visible Check setting.
    if isBehindWall(character) then
        return
    end

    if TRIGGERBOT_ONSCREEN_ONLY then
        local screenPoint, onScreen = Camera:WorldToViewportPoint(lockPart.Position)
        if not onScreen or screenPoint.Z <= 0 then
            return
        end
    end

    local myCharacter = LocalPlayer.Character
    if not myCharacter then
        return
    end

    -- Da Hood-style replicas normally fire guns from Tool.Activated.
    -- Tool:Activate() triggers that same path without hard-coding a RemoteEvent.
    local tool = myCharacter:FindFirstChildOfClass("Tool")
    if not tool then
        return
    end

    -- Pause triggerbot while a knife/melee blade is equipped.
    -- The Triggerbot toggle stays enabled and automatically resumes
    -- when the player switches back to a gun.
    local toolName = string.lower(tool.Name or "")
    if toolName:find("knife", 1, true)
        or toolName:find("blade", 1, true)
        or toolName:find("katana", 1, true)
        or toolName:find("machete", 1, true) then
        return
    end

    -- Respect the Tool's own cooldown state when the gun uses Tool.Enabled.
    local okEnabled, enabled = pcall(function() return tool.Enabled end)
    if okEnabled and enabled == false then
        return
    end

    local now = os.clock()
    if now - triggerbotLastShot < TRIGGERBOT_INTERVAL then
        return
    end
    triggerbotLastShot = now

    pcall(function()
        tool:Activate()
    end)
end

local function updateCameraLock(dt)

    if not LOCK_ENABLED then return end

    if not TARGET or not TARGET.Character or 

        not TARGET.Character:FindFirstChildOfClass("Humanoid") or

        TARGET.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then

        TARGET = getPlayerUnderCrosshair()

        updateUI()

        if not TARGET then return end

    end

    if TARGET and TARGET.Character then

        local lockPart = getLockPart(TARGET.Character)

        if lockPart then

            Camera.CameraType = Enum.CameraType.Custom

            local cameraPosition = Camera.CFrame.Position

            local targetPosition = lockPart.Position

            local targetCFrame = CFrame.lookAt(cameraPosition, targetPosition)

            if SMOOTHNESS_ENABLED then
                -- Frame-rate-independent rotational smoothing.
                -- This keeps the camera response consistent at 60/120/240+ FPS.
                dt = math.clamp(dt or (1 / 60), 1 / 500, 1 / 15)

                local currentCFrame = Camera.CFrame
                local currentLook = currentCFrame.LookVector
                local wantedLook = (targetPosition - cameraPosition).Unit

                local dot = math.clamp(currentLook:Dot(wantedLook), -1, 1)
                local angle = math.acos(dot)

                local settings = getgenv().GohthAimSmooth
                local farSpeed = math.clamp(SMOOTHNESS_VALUE, SMOOTHNESS_MIN, SMOOTHNESS_MAX)
                local nearSpeed = math.clamp(settings.NearSpeed or SMOOTH_DAMP_SPEED, DAMP_SPEED_MIN, DAMP_SPEED_MAX)

                -- Dynamic smoothing:
                -- far from target = faster tracking
                -- close to target = slower/finer tracking
                local speed = farSpeed
                if settings.Dynamic then
                    local distanceScale = math.clamp(angle / math.rad(22), 0, 1)
                    distanceScale = distanceScale ^ math.max(0.25, settings.Curve or 1)
                    speed = nearSpeed + (farSpeed - nearSpeed) * distanceScale
                end

                -- Easy-to-understand response presets.
                if SMOOTHNESS_TYPE == "Soft" then
                    speed *= 0.72
                elseif SMOOTHNESS_TYPE == "Responsive" then
                    speed *= 1.35
                end

                -- Extra precision once the crosshair is nearly on the target.
                if settings.Micro and angle < math.rad(2.5) then
                    speed *= 0.55
                end

                -- Exponential interpolation is stable regardless of frame rate.
                local alpha = 1 - math.exp(-math.max(0.01, speed) * dt)
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, math.clamp(alpha, 0, 1))
            else
                Camera.CFrame = targetCFrame
            end

        end

    end

end

RunService:BindToRenderStep("CrosshairCameraLock", Enum.RenderPriority.Camera.Value + 1, updateCameraLock)
RunService:BindToRenderStep("WeakTriggerbot", Enum.RenderPriority.Camera.Value + 2, updateTriggerbot)

----------------------------------------------------------------

--// Players

----------------------------------------------------------------

for _, player in ipairs(Players:GetPlayers()) do

    setupPlayer(player)

end

Players.PlayerAdded:Connect(setupPlayer)

Players.PlayerRemoving:Connect(function(player)

    if player == TARGET then

        TARGET = nil

        updateUI()

    end

end)
end)

task.wait(0.1)

createFOVCircle()

updateUI()
