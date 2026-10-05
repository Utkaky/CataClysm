local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local plotNames = {
    ["Plot1"] = {name = "Plot1 (Green)", color = "#55ff55", short = "Green"},
    ["Plot2"] = {name = "Plot2 (Pink)", color = "#ff55aa", short = "Pink"},
    ["Plot3"] = {name = "Plot3 (Purple)", color = "#aa55ff", short = "Purple"},
    ["Plot4"] = {name = "Plot4 (Blue)", color = "#5555ff", short = "Blue"},
    ["Plot5"] = {name = "Plot5 (Yellow)", color = "#ffff55", short = "Yellow"}
}

brokenPlotsSaved = brokenPlotsSaved or {}

local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "NotificationFrame"
NotifyGui.ResetOnSpawn = false
NotifyGui.IgnoreGuiInset = true
NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    NotifyGui.Parent = CoreGui
end)

if not NotifyGui.Parent then
    NotifyGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
end

local NotifyContainer = Instance.new("Frame")
NotifyContainer.Name = "Notifications"
NotifyContainer.AnchorPoint = Vector2.new(1, 0)
NotifyContainer.Position = UDim2.new(1, -18, 0, 18)
NotifyContainer.Size = UDim2.new(0, 350, 1, -36)
NotifyContainer.BackgroundTransparency = 1
NotifyContainer.Parent = NotifyGui

local NotifyLayout = Instance.new("UIListLayout")
NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Top
NotifyLayout.Padding = UDim.new(0, 8)
NotifyLayout.Parent = NotifyContainer

local NotifyCounter = 0

local function NotifyLib(title, content, duration, icon)
    duration = duration or 5

    NotifyCounter += 1

    local Notification = Instance.new("Frame")
    Notification.Name = "Notification_" .. NotifyCounter
    Notification.Size = UDim2.new(0, 0, 0, 82)
    Notification.BackgroundColor3 = Color3.fromRGB(15, 17, 25)
    Notification.BackgroundTransparency = 0.03
    Notification.BorderSizePixel = 0
    Notification.ClipsDescendants = true
    Notification.LayoutOrder = NotifyCounter
    Notification.Parent = NotifyContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 11)
    Corner.Parent = Notification

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(65, 68, 82)
    Stroke.Transparency = 0.35
    Stroke.Thickness = 1
    Stroke.Parent = Notification

    local IconFrame = Instance.new("Frame")
    IconFrame.Name = "Icon"
    IconFrame.AnchorPoint = Vector2.new(0, 0.5)
    IconFrame.Position = UDim2.new(0, 13, 0.5, 0)
    IconFrame.Size = UDim2.new(0, 46, 0, 46)
    IconFrame.BackgroundColor3 = Color3.fromRGB(63, 57, 150)
    IconFrame.BorderSizePixel = 0
    IconFrame.Parent = Notification

    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 14)
    IconCorner.Parent = IconFrame

    local IconStroke = Instance.new("UIStroke")
    IconStroke.Color = Color3.fromRGB(130, 122, 255)
    IconStroke.Transparency = 0.15
    IconStroke.Thickness = 1.5
    IconStroke.Parent = IconFrame

    local IconGlow = Instance.new("Frame")
    IconGlow.Name = "Glow"
    IconGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    IconGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    IconGlow.Size = UDim2.new(0, 30, 0, 30)
    IconGlow.BackgroundColor3 = Color3.fromRGB(104, 95, 255)
    IconGlow.BackgroundTransparency = 0.45
    IconGlow.BorderSizePixel = 0
    IconGlow.Parent = IconFrame

    local GlowCorner = Instance.new("UICorner")
    GlowCorner.CornerRadius = UDim.new(1, 0)
    GlowCorner.Parent = IconGlow

    local IconLabel = Instance.new("TextLabel")
    IconLabel.Name = "Symbol"
    IconLabel.BackgroundTransparency = 1
    IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    IconLabel.Position = UDim2.new(0.5, 0, 0.5, -1)
    IconLabel.Size = UDim2.new(1, 0, 1, 0)
    IconLabel.Font = Enum.Font.GothamBold

    if icon == "check-circle" then
        IconLabel.Text = "✓"
        IconLabel.TextSize = 24
    else
        IconLabel.Text = "!"
        IconLabel.TextSize = 22
    end

    IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    IconLabel.Parent = IconFrame

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 72, 0, 11)
    Title.Size = UDim2.new(1, -125, 0, 21)
    Title.Font = Enum.Font.GothamBold
    Title.Text = title or "Notification"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextTruncate = Enum.TextTruncate.AtEnd
    Title.Parent = Notification

    local Content = Instance.new("TextLabel")
    Content.Name = "Content"
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 72, 0, 34)
    Content.Size = UDim2.new(1, -125, 0, 35)
    Content.Font = Enum.Font.Gotham
    Content.RichText = true
    Content.Text = content or ""
    Content.TextColor3 = Color3.fromRGB(190, 193, 205)
    Content.TextSize = 12
    Content.TextWrapped = true
    Content.TextXAlignment = Enum.TextXAlignment.Left
    Content.TextYAlignment = Enum.TextYAlignment.Top
    Content.Parent = Notification

    local Timer = Instance.new("TextLabel")
    Timer.Name = "Timer"
    Timer.AnchorPoint = Vector2.new(1, 0)
    Timer.Position = UDim2.new(1, -13, 0, 12)
    Timer.Size = UDim2.new(0, 38, 0, 20)
    Timer.BackgroundTransparency = 1
    Timer.Font = Enum.Font.GothamMedium
    Timer.Text = string.format("%.1f", duration)
    Timer.TextColor3 = Color3.fromRGB(150, 153, 170)
    Timer.TextSize = 11
    Timer.TextXAlignment = Enum.TextXAlignment.Right
    Timer.Parent = Notification

    local BottomLine = Instance.new("Frame")
    BottomLine.Name = "BottomLine"
    BottomLine.AnchorPoint = Vector2.new(0, 1)
    BottomLine.Position = UDim2.new(0, 0, 1, 0)
    BottomLine.Size = UDim2.new(1, 0, 0, 1)
    BottomLine.BackgroundColor3 = Color3.fromRGB(90, 82, 205)
    BottomLine.BackgroundTransparency = 0.3
    BottomLine.BorderSizePixel = 0
    BottomLine.Parent = Notification

    local Sound = Instance.new("Sound")
    Sound.SoundId = "rbxassetid://6026984224"
    Sound.Volume = 0.2
    Sound.Parent = Notification

    pcall(function()
        Sound:Play()
    end)

    TweenService:Create(
        Notification,
        TweenInfo.new(
            0.4,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        {
            Size = UDim2.new(0, 350, 0, 82)
        }
    ):Play()

    task.spawn(function()
        local startTime = os.clock()

        while Notification.Parent do
            local elapsed = os.clock() - startTime
            local remaining = math.max(0, duration - elapsed)

            Timer.Text = string.format("%.1f", remaining)

            if remaining <= 0 then
                break
            end

            task.wait(0.05)
        end
    end)

    task.delay(duration, function()
        if not Notification or not Notification.Parent then
            return
        end

        local HideTween = TweenService:Create(
            Notification,
            TweenInfo.new(
                0.35,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.In
            ),
            {
                Size = UDim2.new(0, 0, 0, 82),
                BackgroundTransparency = 1
            }
        )

        TweenService:Create(
            IconFrame,
            TweenInfo.new(0.2),
            {
                BackgroundTransparency = 1
            }
        ):Play()

        TweenService:Create(
            IconGlow,
            TweenInfo.new(0.2),
            {
                BackgroundTransparency = 1
            }
        ):Play()

        TweenService:Create(
            IconLabel,
            TweenInfo.new(0.2),
            {
                TextTransparency = 1
            }
        ):Play()

        TweenService:Create(
            Title,
            TweenInfo.new(0.2),
            {
                TextTransparency = 1
            }
        ):Play()

        TweenService:Create(
            Content,
            TweenInfo.new(0.2),
            {
                TextTransparency = 1
            }
        ):Play()

        TweenService:Create(
            Timer,
            TweenInfo.new(0.2),
            {
                TextTransparency = 1
            }
        ):Play()

        HideTween:Play()
        HideTween.Completed:Wait()

        Notification:Destroy()
    end)
end

task.spawn(function()
    while true do
        local currentbroken = {}

        for _, folder in pairs(workspace:GetChildren()) do
            if folder:IsA("Folder") and folder.Name:find("SpawnedInToys") then
                local ownerName = folder.Name:gsub("SpawnedInToys", "")

                for _, obj in pairs(folder:GetChildren()) do
                    if obj.Name == "NinjaShuriken"
                        or obj.Name == "ToolCleaver"
                        or obj.Name == "ToolPencil"
                        or obj.Name == "ToolDiggingForkRusty" then

                        local stickyPart = obj:FindFirstChild("StickyPart")

                        if stickyPart then
                            local weld = stickyPart:FindFirstChild("StickyWeld")

                            if weld and weld.Part1 then
                                local attachedPart = weld.Part1
                                local parentPlot = attachedPart.Parent

                                if parentPlot
                                    and parentPlot.Parent
                                    and parentPlot.Parent.Name == "Plots" then

                                    local plotName = parentPlot.Name

                                    local plotData = plotNames[plotName] or {
                                        name = plotName,
                                        color = "#ffffff",
                                        short = plotName
                                    }

                                    local plotDisplay = plotData.name
                                    local plotColor = plotData.color
                                    local plotShort = plotData.short
                                    local key = plotName .. "_" .. ownerName

                                    currentbroken[key] = {
                                        plotDisplay = plotDisplay,
                                        plotColor = plotColor,
                                        plotShort = plotShort,
                                        ownerName = ownerName
                                    }

                                    if not brokenPlotsSaved[key] then
                                        brokenPlotsSaved[key] = {
                                            plotDisplay = plotDisplay,
                                            plotColor = plotColor,
                                            plotShort = plotShort
                                        }

                                        local player = game.Players:FindFirstChild(ownerName)
                                        local displayName = player and player.DisplayName or ownerName

                                        NotifyLib(
                                            "Plot Breaked!",
                                            "The <font color='" .. plotColor .. "'><b>"
                                                .. plotDisplay
                                                .. "</b></font> has broken by <font color='#ffaa00'><b>"
                                                .. displayName
                                                .. "</b></font>",
                                            5,
                                            "!"
                                        )
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        for key, data in pairs(brokenPlotsSaved) do
            if not currentbroken[key] then
                local safeDisplay = data.plotDisplay
                local safeColor = data.plotColor

                brokenPlotsSaved[key] = nil

                NotifyLib(
                    "Plot is Safe",
                    "The <font color='" .. safeColor .. "'><b>"
                        .. safeDisplay
                        .. "</b></font> is safe now",
                    5,
                    "check-circle"
                )
            end
        end

        task.wait(1)
    end
end)
