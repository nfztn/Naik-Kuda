-- RideAPet - English UI + Minimize/Expand Menu
-- LocalScript en StarterPlayerScripts o StarterGui

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- UI Parent
local TargetParent = CoreGui:FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Target folder
local RenderedEggsFolder = Workspace:WaitForChild("RenderedEggs", 10) or Workspace:FindFirstChild("RenderedEggs")

-- ESP state
local mainESPActive = false
local mainESPColor = Color3.fromRGB(255, 255, 0)
local defaultCustomColor = Color3.fromRGB(0, 255, 0)
local highlights = {}
local currentSearchQuery = ""

-- TP Home keybind
local tpKeybind = Enum.KeyCode.T
local listeningForKey = false

--------------------------------------------------------------------------------
-- ESP SYSTEM
--------------------------------------------------------------------------------
local function updateEggESP(inst)
    if not inst or (not inst:IsA("Model") and not inst:IsA("BasePart")) then
        return
    end

    local data = highlights[inst]
    if not data then
        data = {
            Highlight = nil,
            CustomColor = nil,
            CustomActive = false
        }
        highlights[inst] = data
    end

    local shouldShow = false
    local colorToUse = mainESPColor

    if data.CustomActive then
        shouldShow = true
        colorToUse = data.CustomColor or defaultCustomColor
    elseif mainESPActive then
        shouldShow = true
        colorToUse = mainESPColor
    end

    if shouldShow then
        if not data.Highlight or not data.Highlight.Parent then
            local hl = Instance.new("Highlight")
            hl.Name = "EggESP_Highlight"
            hl.Adornee = inst
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.Parent = inst
            data.Highlight = hl
        end

        data.Highlight.FillColor = colorToUse
        data.Highlight.OutlineColor = colorToUse
        data.Highlight.Enabled = true
    else
        if data.Highlight then
            data.Highlight.Enabled = false
        end
    end
end

local function applyGlobalESP(state)
    mainESPActive = state

    if RenderedEggsFolder then
        for _, child in ipairs(RenderedEggsFolder:GetChildren()) do
            updateEggESP(child)
        end
    end
end

-- Dynamic connections for new objects
if RenderedEggsFolder then
    RenderedEggsFolder.ChildAdded:Connect(function(child)
        task.wait(0.1)
        updateEggESP(child)
    end)

    RenderedEggsFolder.ChildRemoved:Connect(function(child)
        if highlights[child] then
            if highlights[child].Highlight then
                highlights[child].Highlight:Destroy()
            end
            highlights[child] = nil
        end
    end)
end

--------------------------------------------------------------------------------
-- TELEPORT SYSTEM
--------------------------------------------------------------------------------
local function teleportToModel(targetInst)
    if not targetInst then
        return
    end

    local character = LocalPlayer.Character
    if not character then
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return
    end

    local targetCFrame = nil

    if targetInst:IsA("Model") then
        targetCFrame = targetInst:GetPivot()
    elseif targetInst:IsA("BasePart") then
        targetCFrame = targetInst.CFrame
    end

    if targetCFrame then
        hrp.CFrame = targetCFrame * CFrame.new(0, 3, 0)
    end
end

-- Find and teleport to the player's home plot
local function teleportToHomePlot()
    local plotsFolder = Workspace:FindFirstChild("Plots")
    if not plotsFolder then
        return
    end

    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local dataFolder = plot:FindFirstChild("Data")
        if dataFolder then
            local ownerVal = dataFolder:FindFirstChild("Owner")
            if ownerVal then
                local isOwner = false

                if ownerVal:IsA("StringValue") and ownerVal.Value == LocalPlayer.Name then
                    isOwner = true
                elseif ownerVal:IsA("ObjectValue") and ownerVal.Value == LocalPlayer then
                    isOwner = true
                elseif tostring(ownerVal.Value) == LocalPlayer.Name then
                    isOwner = true
                end

                if isOwner then
                    teleportToModel(plot)
                    break
                end
            end
        end
    end
end

--------------------------------------------------------------------------------
-- GUI CREATION
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RenderedEggsESP_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = TargetParent

-- Main frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 210)
MainFrame.Position = UDim2.new(0.5, -170, 0.35, -105)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 8)
MainUICorner.Parent = MainFrame

local MainUIStroke = Instance.new("UIStroke")
MainUIStroke.Color = Color3.fromRGB(60, 60, 60)
MainUIStroke.Thickness = 1.5
MainUIStroke.Parent = MainFrame

-- Top bar / drag bar / minimize button
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TopBar.BackgroundTransparency = 0.2
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

local AuthorLabel = Instance.new("TextLabel")
AuthorLabel.Size = UDim2.new(1, -50, 0, 15)
AuthorLabel.Position = UDim2.new(0, 10, 0, 4)
AuthorLabel.BackgroundTransparency = 1
AuthorLabel.Text = "Script By Nfztn"
AuthorLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
AuthorLabel.TextSize = 11
AuthorLabel.Font = Enum.Font.SourceSansBold
AuthorLabel.TextXAlignment = Enum.TextXAlignment.Left
AuthorLabel.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 0, 16)
TitleLabel.Position = UDim2.new(0, 10, 0, 18)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Eggs ESP Menu"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local GameLabel = Instance.new("TextLabel")
GameLabel.Size = UDim2.new(1, -50, 0, 12)
GameLabel.Position = UDim2.new(0, 10, 0, 34)
GameLabel.BackgroundTransparency = 1
GameLabel.Text = "Game: Ride A Pet"
GameLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
GameLabel.TextSize = 10
GameLabel.Font = Enum.Font.SourceSansItalic
GameLabel.TextXAlignment = Enum.TextXAlignment.Left
GameLabel.Parent = TopBar

-- Minimize button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeButton"
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 10)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MinimizeBtn.BackgroundTransparency = 0.3
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 18
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.AutoButtonColor = true
MinimizeBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

-- Dedicated mobile drag handle. It remains visible when minimized and sits
-- to the left of the minimize button so the two controls never overlap.
local DragHandle = Instance.new("TextButton")
DragHandle.Name = "DragHandle"
DragHandle.Size = UDim2.new(1, -45, 1, 0)
DragHandle.Position = UDim2.new(0, 0, 0, 0)
DragHandle.BackgroundTransparency = 1
DragHandle.BorderSizePixel = 0
DragHandle.Text = ""
DragHandle.AutoButtonColor = false
DragHandle.Active = true
DragHandle.ZIndex = 10
DragHandle.Parent = TopBar

--------------------------------------------------------------------------------
-- MINIMIZE / EXPAND SYSTEM
--------------------------------------------------------------------------------
local NormalSize = UDim2.new(0, 340, 0, 210)
local ListSize = UDim2.new(0, 340, 0, 320)
local MinimizedSize = UDim2.new(0, 340, 0, 50)
local isMinimized = false
local listIsOpen = false

local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -20, 0, 265)
ContentContainer.Position = UDim2.new(0, 10, 0, 55)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local function setMinimized(state)
    isMinimized = state

    if isMinimized then
        ContentContainer.Visible = false
        MinimizeBtn.Text = "+"
        MainFrame:TweenSize(
            MinimizedSize,
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quart,
            0.2,
            true
        )
    else
        MinimizeBtn.Text = "-"
        MainFrame:TweenSize(
            listIsOpen and ListSize or NormalSize,
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quart,
            0.2,
            true
        )
        task.delay(0.12, function()
            if not isMinimized then
                ContentContainer.Visible = true
            end
        end)
    end
end

MinimizeBtn.MouseButton1Click:Connect(function()
    setMinimized(not isMinimized)
end)

--------------------------------------------------------------------------------
-- DRAG SYSTEM (MOBILE ONLY)
--------------------------------------------------------------------------------
-- Use TouchMoved directly instead of relying on mouse-style drag events.
-- This keeps the minimized window draggable on mobile executors.
local dragging = false
local dragStart = nil
local startPos = nil

DragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.TouchMoved:Connect(function(touch, gameProcessed)
    if not dragging or not dragStart or not startPos then
        return
    end

    local delta = touch.Position - dragStart

    MainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end)

UserInputService.TouchEnded:Connect(function()
    dragging = false
    dragStart = nil
    startPos = nil
end)

