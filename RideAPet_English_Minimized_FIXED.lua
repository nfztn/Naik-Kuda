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

-- Dedicated drag handle. It stays visible when the menu is minimized and
-- occupies the top bar area without covering the minimize button.
local DragHandle = Instance.new("TextButton")
DragHandle.Name = "DragHandle"
DragHandle.Size = UDim2.new(1, -45, 1, 0)
DragHandle.Position = UDim2.new(0, 0, 0, 0)
DragHandle.BackgroundTransparency = 1
DragHandle.BorderSizePixel = 0
DragHandle.Text = ""
DragHandle.AutoButtonColor = false
DragHandle.Active = true
DragHandle.ZIndex = 5
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
-- DRAG SYSTEM
--------------------------------------------------------------------------------
local dragging = false
local dragStart = nil
local startPos = nil
local dragInput = nil

local function beginDrag(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    -- Do not start dragging when the minimize button is pressed.
    if input.Target == MinimizeBtn then
        return
    end

    dragging = true
    dragStart = input.Position
    startPos = MainFrame.Position

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragInput = input
    else
        dragInput = input
    end

    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
            dragInput = nil
        end
    end)
end

local function updateDrag(input)
    if not dragging or not dragStart or not startPos then
        return
    end

    if input == dragInput
        or input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end

-- The dedicated handle is the primary drag target. MainFrame/TopBar remain
-- connected as fallbacks for compatibility with different executors.
DragHandle.InputBegan:Connect(beginDrag)
TopBar.InputBegan:Connect(beginDrag)
MainFrame.InputBegan:Connect(beginDrag)

UserInputService.InputChanged:Connect(function(input)
    if dragging then
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            updateDrag(input)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        dragInput = nil
    end
end)

--------------------------------------------------------------------------------
-- CONTENT AND BUTTONS
--------------------------------------------------------------------------------

-- Button 1: Toggle global ESP
local ToggleGlobalESPBtn = Instance.new("TextButton")
ToggleGlobalESPBtn.Size = UDim2.new(1, 0, 0, 32)
ToggleGlobalESPBtn.Position = UDim2.new(0, 0, 0, 0)
ToggleGlobalESPBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleGlobalESPBtn.BackgroundTransparency = 0.2
ToggleGlobalESPBtn.Text = "ESP All: OFF"
ToggleGlobalESPBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
ToggleGlobalESPBtn.TextSize = 13
ToggleGlobalESPBtn.Font = Enum.Font.SourceSansBold
ToggleGlobalESPBtn.Parent = ContentContainer

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleGlobalESPBtn

ToggleGlobalESPBtn.MouseButton1Click:Connect(function()
    mainESPActive = not mainESPActive

    if mainESPActive then
        ToggleGlobalESPBtn.Text = "ESP All: ON"
        ToggleGlobalESPBtn.TextColor3 = Color3.fromRGB(0, 255, 120)
    else
        ToggleGlobalESPBtn.Text = "ESP All: OFF"
        ToggleGlobalESPBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    end

    applyGlobalESP(mainESPActive)
end)

-- Button 2: TP Home
local TPHomeBtn = Instance.new("TextButton")
TPHomeBtn.Size = UDim2.new(1, 0, 0, 32)
TPHomeBtn.Position = UDim2.new(0, 0, 0, 37)
TPHomeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TPHomeBtn.BackgroundTransparency = 0.2
TPHomeBtn.Text = "🏠 TP Home"
TPHomeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
TPHomeBtn.TextSize = 13
TPHomeBtn.Font = Enum.Font.SourceSansBold
TPHomeBtn.Parent = ContentContainer

local TPHomeCorner = Instance.new("UICorner")
TPHomeCorner.CornerRadius = UDim.new(0, 6)
TPHomeCorner.Parent = TPHomeBtn

TPHomeBtn.MouseButton1Click:Connect(function()
    teleportToHomePlot()
end)

-- Keybind button for TP Home
local KeybindBtn = Instance.new("TextButton")
KeybindBtn.Size = UDim2.new(1, 0, 0, 26)
KeybindBtn.Position = UDim2.new(0, 0, 0, 74)
KeybindBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
KeybindBtn.BackgroundTransparency = 0.3
KeybindBtn.Text = "TP Home Key: [" .. tpKeybind.Name .. "]"
KeybindBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
KeybindBtn.TextSize = 11
KeybindBtn.Font = Enum.Font.SourceSans
KeybindBtn.Parent = ContentContainer

local KeybindCorner = Instance.new("UICorner")
KeybindCorner.CornerRadius = UDim.new(0, 6)
KeybindCorner.Parent = KeybindBtn

KeybindBtn.MouseButton1Click:Connect(function()
    listeningForKey = true
    KeybindBtn.Text = "Press a key..."
    KeybindBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if listeningForKey and input.UserInputType == Enum.UserInputType.Keyboard then
        tpKeybind = input.KeyCode
        listeningForKey = false
        KeybindBtn.Text = "TP Home Key: [" .. tpKeybind.Name .. "]"
        KeybindBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    elseif not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == tpKeybind then
            teleportToHomePlot()
        end
    end
end)

-- Button 3: Show / hide egg list
local ToggleListBtn = Instance.new("TextButton")
ToggleListBtn.Size = UDim2.new(1, 0, 0, 32)
ToggleListBtn.Position = UDim2.new(0, 0, 0, 105)
ToggleListBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleListBtn.BackgroundTransparency = 0.2
ToggleListBtn.Text = "Show Egg List ▼"
ToggleListBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
ToggleListBtn.TextSize = 13
ToggleListBtn.Font = Enum.Font.SourceSansBold
ToggleListBtn.Parent = ContentContainer

local ListToggleCorner = Instance.new("UICorner")
ListToggleCorner.CornerRadius = UDim.new(0, 6)
ListToggleCorner.Parent = ToggleListBtn

-- Dropdown list container
local ListContainerFrame = Instance.new("Frame")
ListContainerFrame.Size = UDim2.new(1, 0, 0, 170)
ListContainerFrame.Position = UDim2.new(0, 0, 0, 142)
ListContainerFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ListContainerFrame.BackgroundTransparency = 0.3
ListContainerFrame.Visible = false
ListContainerFrame.Parent = ContentContainer

local ListFrameCorner = Instance.new("UICorner")
ListFrameCorner.CornerRadius = UDim.new(0, 6)
ListFrameCorner.Parent = ListContainerFrame

-- Refresh button
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(1, -10, 0, 25)
RefreshBtn.Position = UDim2.new(0, 5, 0, 5)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
RefreshBtn.BackgroundTransparency = 0.2
RefreshBtn.Text = "🔄 Refresh List"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.TextSize = 12
RefreshBtn.Font = Enum.Font.SourceSansBold
RefreshBtn.Parent = ListContainerFrame

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 4)
RefreshCorner.Parent = RefreshBtn

-- Search box
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -10, 0, 25)
SearchBox.Position = UDim2.new(0, 5, 0, 35)
SearchBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SearchBox.BackgroundTransparency = 0.2
SearchBox.PlaceholderText = "🔍 Search model..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.TextSize = 12
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = ListContainerFrame

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 4)
SearchCorner.Parent = SearchBox

local SearchPadding = Instance.new("UIPadding")
SearchPadding.PaddingLeft = UDim.new(0, 8)
SearchPadding.Parent = SearchBox

-- Scrolling frame for items
local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(1, -10, 1, -70)
ScrollList.Position = UDim2.new(0, 5, 0, 65)
ScrollList.BackgroundTransparency = 1
ScrollList.BorderSizePixel = 0
ScrollList.ScrollBarThickness = 4
ScrollList.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
ScrollList.Parent = ListContainerFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.Parent = ScrollList

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end)

-- Populate list with filter and teleport support
local function populateList()
    for _, child in ipairs(ScrollList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    if not RenderedEggsFolder then
        return
    end

    local query = currentSearchQuery:lower()

    for _, egg in ipairs(RenderedEggsFolder:GetChildren()) do
        if query == "" or string.find(egg.Name:lower(), query, 1, true) then
            local ItemFrame = Instance.new("Frame")
            ItemFrame.Size = UDim2.new(1, -6, 0, 30)
            ItemFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            ItemFrame.BackgroundTransparency = 0.3
            ItemFrame.Parent = ScrollList

            local ItemCorner = Instance.new("UICorner")
            ItemCorner.CornerRadius = UDim.new(0, 4)
            ItemCorner.Parent = ItemFrame

            local ItemName = Instance.new("TextLabel")
            ItemName.Size = UDim2.new(1, -115, 1, 0)
            ItemName.Position = UDim2.new(0, 8, 0, 0)
            ItemName.BackgroundTransparency = 1
            ItemName.Text = egg.Name
            ItemName.TextColor3 = Color3.fromRGB(200, 200, 200)
            ItemName.TextSize = 12
            ItemName.Font = Enum.Font.SourceSans
            ItemName.TextXAlignment = Enum.TextXAlignment.Left
            ItemName.TextTruncate = Enum.TextTruncate.AtEnd
            ItemName.Parent = ItemFrame

            -- Teleport button
            local TPBtn = Instance.new("TextButton")
            TPBtn.Size = UDim2.new(0, 32, 0, 22)
            TPBtn.Position = UDim2.new(1, -102, 0.5, -11)
            TPBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            TPBtn.BackgroundTransparency = 0.2
            TPBtn.Text = "TP"
            TPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            TPBtn.TextSize = 10
            TPBtn.Font = Enum.Font.SourceSansBold
            TPBtn.Parent = ItemFrame

            local TPCorner = Instance.new("UICorner")
            TPCorner.CornerRadius = UDim.new(0, 4)
            TPCorner.Parent = TPBtn

            TPBtn.MouseButton1Click:Connect(function()
                teleportToModel(egg)
            end)

            -- Individual green ESP button
            local GreenESPBtn = Instance.new("TextButton")
            GreenESPBtn.Size = UDim2.new(0, 62, 0, 22)
            GreenESPBtn.Position = UDim2.new(1, -66, 0.5, -11)
            GreenESPBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 70)
            GreenESPBtn.BackgroundTransparency = 0.3

            local isCustom = highlights[egg] and highlights[egg].CustomActive
            GreenESPBtn.Text = isCustom and "Green: ON" or "Green ESP"
            GreenESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            GreenESPBtn.TextSize = 10
            GreenESPBtn.Font = Enum.Font.SourceSansBold
            GreenESPBtn.Parent = ItemFrame

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 4)
            BtnCorner.Parent = GreenESPBtn

            GreenESPBtn.MouseButton1Click:Connect(function()
                if not highlights[egg] then
                    highlights[egg] = {
                        Highlight = nil,
                        CustomColor = defaultCustomColor,
                        CustomActive = false
                    }
                end

                local current = highlights[egg].CustomActive
                highlights[egg].CustomActive = not current
                highlights[egg].CustomColor = defaultCustomColor

                if highlights[egg].CustomActive then
                    GreenESPBtn.Text = "Green: ON"
                    GreenESPBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 90)
                else
                    GreenESPBtn.Text = "Green ESP"
                    GreenESPBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 70)
                end

                updateEggESP(egg)
            end)
        end
    end
end

-- Real-time search filtering
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    currentSearchQuery = SearchBox.Text
    populateList()
end)

-- Dropdown list toggle
ToggleListBtn.MouseButton1Click:Connect(function()
    listIsOpen = not listIsOpen
    ListContainerFrame.Visible = listIsOpen

    if listIsOpen then
        ToggleListBtn.Text = "Hide Egg List ▲"
        populateList()
        if not isMinimized then
            MainFrame:TweenSize(ListSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
        end
    else
        ToggleListBtn.Text = "Show Egg List ▼"
        if not isMinimized then
            MainFrame:TweenSize(NormalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
        end
    end
end)

-- Refresh list
RefreshBtn.MouseButton1Click:Connect(function()
    populateList()
end)
