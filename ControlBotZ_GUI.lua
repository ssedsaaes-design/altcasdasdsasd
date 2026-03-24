--[[
    ControlBotZ Premium GUI
    Created by Antigravity
    A sleek, command-based GUI for controlling your bots without typing.
]]

local ControlBotZ_GUI = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local function create(className, properties, children)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        pcall(function() instance[prop] = value end)
    end
    if children and type(children) == "table" then
        for _, child in ipairs(children) do
            if child and typeof(child) == "Instance" then
                child.Parent = instance
            end
        end
    end
    return instance
end

local cmd_data = {
    {name = "rejoin", args = {}},
    {name = "jump", args = {}},
    {name = "reset", args = {}},
    {name = "sit", args = {}},
    {name = "chat", args = {"message"}},
    {name = "shutdown", args = {}},
    {name = "orbit", args = {"username", "speed"}},
    {name = "unorbit", args = {}},
    {name = "bang", args = {"username", "speed"}},
    {name = "unbang", args = {}},
    {name = "walkto", args = {"username"}},
    {name = "speed", args = {"number"}},
    {name = "bring", args = {}},
    {name = "clearchat", args = {}},
    {name = "privacymode", args = {"enable/disable"}},
    {name = "spin", args = {"number"}},
    {name = "unspin", args = {}},
    {name = "lineup", args = {"direction"}},
    {name = "3drender", args = {"enable/disable"}},
    {name = "dance", args = {"emote"}},
    {name = "fling", args = {"username"}},
    {name = "unfling", args = {}},
    {name = "follow", args = {"username"}},
    {name = "unfollow", args = {}},
    {name = "lookat", args = {"username"}},
    {name = "unlookat", args = {}},
    {name = "stack", args = {"username"}},
    {name = "unstack", args = {}},
    {name = "quit", args = {}},
    {name = "goto", args = {"username"}},
    {name = "carpet", args = {"username"}},
    {name = "uncarpet", args = {}},
    {name = "linefollow", args = {"username"}},
    {name = "unlinefollow", args = {}},
    {name = "riz", args = {"username"}},
    {name = "facebang", args = {"username", "speed"}},
    {name = "unfbang", args = {}},
    {name = "announce", args = {"message"}},
    {name = "rocket", args = {"height"}},
    {name = "antibang", args = {}},
    {name = "2orbit", args = {"username"}},
    {name = "surround", args = {"username", "spacing"}},
    {name = "partsrain", args = {"username", "height"}},
    {name = "unpartsrain", args = {}},
    {name = "hug", args = {"username"}},
    {name = "unhug", args = {}},
    {name = "worm", args = {"username"}},
    {name = "unworm", args = {}},
    {name = "index", args = {}},
    {name = "logchat", args = {"enable/disable"}},
    {name = "4k", args = {"username"}},
    {name = "whitelist+", args = {"username"}},
    {name = "whitelist-", args = {"username"}},
    {name = "admin+", args = {"username"}},
    {name = "admin-", args = {"username"}},
    {name = "goon", args = {"speed"}},
    {name = "ungoon", args = {}},
    {name = "frontflip", args = {}},
    {name = "backflip", args = {}},
    {name = "freeze", args = {}},
    {name = "unfreeze", args = {}},
    {name = "antiafk", args = {"enable/disable"}},
    {name = "version", args = {}},
    {name = "botremove", args = {"index"}},
    {name = "printcmds", args = {}},
    {name = "2stack", args = {"username"}},
    {name = "fpscap", args = {"number"}},
    {name = "2bang", args = {"username"}},
    {name = "fullbox", args = {"username"}},
    {name = "stairs", args = {"username"}},
    {name = "gravity", args = {"number"}},
    {name = "2facebang", args = {"username"}},
    {name = "wings", args = {"username"}},
    {name = "unwings", args = {}},
    {name = "bridge", args = {"username"}},
    {name = "unbridge", args = {}},
    {name = "copychat", args = {"username"}},
    {name = "uncopychat", args = {}},
    {name = "robot", args = {"username"}},
    {name = "unrobot", args = {}},
}

function ControlBotZ_GUI.Load(prefix)
    prefix = prefix or "."
    
    local CoreGui = game:GetService("CoreGui")
    local success, _ = pcall(function() local x = CoreGui.Name end)
    local Parent = success and CoreGui or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    local ScreenGui = create("ScreenGui", {
        Name = "ControlBotZ_GUI",
        Parent = Parent,
        ResetOnSpawn = false
    })

    local MainFrame = create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 500, 0, 400),
        Position = UDim2.new(0.5, -250, 0.5, -200),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 0,
        Active = true,
        Draggable = true,
        Parent = ScreenGui
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        create("UIStroke", {
            Color = Color3.fromRGB(40, 40, 40),
            Thickness = 2,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
    })

    local TitleBar = create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Parent = MainFrame
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        create("Frame", { -- To cover bottom corners
            Size = UDim2.new(1, 0, 0, 10),
            Position = UDim2.new(0, 0, 1, -10),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BorderSizePixel = 0
        }),
        create("TextLabel", {
            Text = "ControlBotZ",
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 18,
            Font = Enum.Font.BuilderSansExtraBold,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    })

    local TitleGradient = create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 170))
        }),
        Parent = TitleBar
    })

    local SearchBox = create("TextBox", {
        Name = "SearchBox",
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = "Search commands...",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
        TextSize = 14,
        Font = Enum.Font.BuilderSansMedium,
        Parent = MainFrame
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        create("UIStroke", { Color = Color3.fromRGB(50, 50, 50), Thickness = 1 })
    })

    local CommandsList = create("ScrollingFrame", {
        Name = "CommandsList",
        Size = UDim2.new(1, -20, 1, -100),
        Position = UDim2.new(0, 10, 0, 90),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100),
        Parent = MainFrame
    }, {
        create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5)
        })
    })

    local function chat(msg)
        local TextChatService = game:GetService("TextChatService")
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if channel then channel:SendAsync(msg) end
        else
            pcall(function()
                game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
            end)
        end
    end

    local activeCommandFrame = nil

    local function createCommandButton(data)
        local Frame = create("Frame", {
            Name = data.name,
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BorderSizePixel = 0,
            ClipsDescendants = true
        }, {
            create("UICorner", { CornerRadius = UDim.new(0, 6) }),
            create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 2
            })
        })

        local Label = create("TextLabel", {
            Text = data.name,
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            TextSize = 14,
            Font = Enum.Font.BuilderSansBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Frame
        })

        local Arrow = create("TextLabel", {
            Text = #data.args > 0 and ">" or "⚡",
            Size = UDim2.new(0, 20, 1, 0),
            Position = UDim2.new(1, -30, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            TextSize = 14,
            Font = Enum.Font.BuilderSansBold,
            Parent = Frame
        })

        local InputContainer = create("Frame", {
            Size = UDim2.new(1, -20, 0, 0),
            Position = UDim2.new(0, 10, 0, 40),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = Frame
        }, {
            create("UIListLayout", { Padding = UDim.new(0, 5) })
        })

        local inputs = {}
        for _, argName in ipairs(data.args) do
            local input = create("TextBox", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                BorderSizePixel = 0,
                Text = "",
                PlaceholderText = argName,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
                TextSize = 12,
                Font = Enum.Font.BuilderSansMedium,
                Parent = InputContainer
            }, {
                create("UICorner", { CornerRadius = UDim.new(0, 4) })
            })
            table.insert(inputs, input)
        end

        local ExecuteBtn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Color3.fromRGB(0, 170, 255),
            BorderSizePixel = 0,
            Text = "Execute",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.BuilderSansBold,
            Visible = #data.args > 0,
            Parent = InputContainer
        }, {
            create("UICorner", { CornerRadius = UDim.new(0, 4) })
        })

        local expanded = false
        local function toggle(state)
            expanded = state
            local targetSize = state and (40 + (#data.args * 35) + (#data.args > 0 and 35 or 0) + 10) or 40
            TweenService:Create(Frame, TweenInfo.new(0.3), { Size = UDim2.new(1, 0, 0, targetSize) }):Play()
            InputContainer.Visible = state
            Arrow.Rotation = state and 90 or 0
        end

        Frame.TextButton.MouseButton1Click:Connect(function()
            if #data.args == 0 then
                chat(prefix .. data.name)
                -- Flash effect
                local originalColor = Frame.BackgroundColor3
                Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                wait(0.1)
                Frame.BackgroundColor3 = originalColor
            else
                if activeCommandFrame and activeCommandFrame ~= Frame then
                    activeCommandFrame:Toggle(false)
                end
                toggle(not expanded)
                activeCommandFrame = expanded and { Toggle = toggle } or nil
            end
        end)

        ExecuteBtn.MouseButton1Click:Connect(function()
            local argValues = {}
            for _, input in ipairs(inputs) do
                table.insert(argValues, input.Text)
            end
            chat(prefix .. data.name .. " " .. table.concat(argValues, " "))
            toggle(false)
        end)

        return Frame
    end

    local cmdButtons = {}
    for _, data in ipairs(cmd_data) do
        local btn = createCommandButton(data)
        btn.Parent = CommandsList
        table.insert(cmdButtons, { btn = btn, name = data.name })
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        for _, item in ipairs(cmdButtons) do
            item.btn.Visible = item.name:find(query) ~= nil
        end
    end)

    -- Toggle with RightControl
    local visible = true
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
            visible = not visible
            MainFrame.Visible = visible
        end
    end)
    
    -- Mobile support: button to open?
    -- For now keep it simple for windows user.
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ControlBotZ GUI",
        Text = "Loaded successfully. Press RightControl to toggle.",
        Time = 5
    })
end

return ControlBotZ_GUI
