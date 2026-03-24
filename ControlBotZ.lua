local function getService(name)
    local success, service = pcall(function() return game:GetService(name) end)
    return success and service or nil
end

local TextChatService = getService("TextChatService")
local HttpService = getService("HttpService")
local Players = getService("Players")
local Workspace = getService("Workspace")
local RunService = getService("RunService")
local StarterGui = getService("StarterGui")
local VU = getService("VirtualUser") -- Keep if used later

local genv = (type(getgenv) == "function" and getgenv()) or (type(getgenv) == "table" and getgenv) or _G
local LocalPLR = Players.LocalPlayer
while not LocalPLR do task.wait() LocalPLR = Players.LocalPlayer end

Username = genv.Username or LocalPLR.Name
Prefix = genv.Prefix or "."

-- Command Sync Value (Bypasses chat restrictions)
local CommandValueName = "ControlZ_CmdSync"
local SyncValue = Workspace:FindFirstChild(CommandValueName) or Instance.new("StringValue")
SyncValue.Name = CommandValueName
SyncValue.Parent = Workspace

if genv.cbzloaded then
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "Already Running", Text = "ControlZ is already active.", Time = 5 })
    end)
    return
end
genv.cbzloaded = true

-- ──────────────────────────────────────────────────────────────
--  Safe character access – prevents most nil index errors
-- ──────────────────────────────────────────────────────────────
local characterConnections = {}  -- to clean up on death

local function safeGetCharacter()
    local char = LocalPLR.Character
    if not char then return nil end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return nil end
    return char, hum, root
end

local function disconnectAllOnDeath()
    for _, conn in ipairs(characterConnections) do
        pcall(function() conn:Disconnect() end)
    end
    characterConnections = {}
end

-- Clean up old connections when character dies / respawns
LocalPLR.CharacterRemoving:Connect(disconnectAllOnDeath)

if LocalPLR.Name ~= Username then
    local logChat = getgenv().logChat
    webhook = getgenv().webhook
    Prefix = getgenv().Prefix or "."
    local bots = getgenv().Bots or {}
    local whitelist = {}
    local admins = {}
    local index

    local function getIndex()
        for i, bot in ipairs(bots) do
            if LocalPLR.DisplayName == bot or LocalPLR.Name == bot then
                index = i
                break
            end
        end
    end
    getIndex()

    local function chat(msg)
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if channel then channel:SendAsync(msg) end
        else
            pcall(function()
                game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
            end)
        end
    end

    chat("ControlBotZ Running!")
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Thank You",
            Text = "thank you for using ControlBotZ!",
            Time = 6
        })
    end)

    local latestVersion = request({
        Url = "https://raw.githubusercontent.com/ssedsaaes-design/ControlBot/refs/heads/main/ControlBotZ%20Version",
        Method = "GET"
    }).Body:match("^%s*(.-)%s*$") or "unknown"

    if latestVersion ~= "1.1.4" then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Old Version!",
                Text = "Get the newest version from discord!",
                Time = 8
            })
        end)
    end

    -- (keep showDefaultGui, sendToWebhook, specifyBots, specifyBots2, getArgs, isR15, isWhitelisted, isAdmin as before)

    local normalGravity = 196.2

    local function commands(player, message)
        local msg = message:lower()
        if not isWhitelisted(player.Name) then return end

        local function getFullPlayerName(typedName)
            if typedName == "me" then return player.Name end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Name:lower():find(typedName:lower(), 1, true) then
                    return plr.Name
                end
            end
        end

        -- WHITELIST / ADMIN / BOTREMOVE / PRINTCMDS (unchanged except printcmds link)

        if msg:sub(1, 10) == Prefix .. "printcmds" then
            print("\n---------- CONTROLBOTZ CMDS ----------\n" .. request({
                Url = "https://raw.githubusercontent.com/ssedsaaes-design/ControlBot/refs/heads/main/ControlBotZ%20Cmds.txt",
                Method = "GET"
            }).Body)
            if index == 1 then chat("Printed commands to console!") end
        end

        -- GOON example – fixed
        if msg:sub(1, 5) == Prefix .. "goon" then
            local args = getArgs(msg:sub(7))
            local speed = tonumber(args[1]) or 1
            specifyBots2(args, 2, function()
                local char, hum = safeGetCharacter()
                if not char or not hum then return end

                local goonAnim = Instance.new("Animation")
                goonAnim.AnimationId = "rbxassetid://99198989"
                local track = hum:LoadAnimation(goonAnim)
                track.Looped = true
                track:Play()
                track:AdjustSpeed(speed)

                local goonAnim2 = Instance.new("Animation")
                goonAnim2.AnimationId = "rbxassetid://168086975"
                local track2 = hum:LoadAnimation(goonAnim2)
                track2.Looped = true
                track2:Play()

                table.insert(characterConnections, track.Stopped:Connect(function() goonAnim:Destroy() end))
                table.insert(characterConnections, track2.Stopped:Connect(function() goonAnim2:Destroy() end))
            end)
        end

        if msg:sub(1, 7) == Prefix .. "ungoon" then
            specifyBots(msg:sub(9), function()
                local char, hum = safeGetCharacter()
                if not char or not hum then return end
                for _, animTrack in ipairs(hum:GetPlayingAnimationTracks()) do
                    if animTrack.Animation.AnimationId == "rbxassetid://99198989" or
                       animTrack.Animation.AnimationId == "rbxassetid://168086975" then
                        animTrack:Stop()
                    end
                end
            end)
        end

        -- Example for a loop command (orbit, bang, follow, stack, etc.)
        -- Replace ALL similar connections with this pattern:
        --[[
        if msg:sub(1, 6) == Prefix .. "orbit" then
            local args = getArgs(message:sub(8))
            local targetName = getFullPlayerName(args[1])
            if not targetName then return end
            local target = Players:FindFirstChild(targetName)
            if not target then return end

            specifyBots2(args, 4, function()
                local conn
                conn = RunService.Heartbeat:Connect(function(dt)
                    local myChar, _, myRoot = safeGetCharacter()
                    if not myChar or not myRoot then return end

                    local tgtChar = target.Character
                    if not tgtChar or not tgtChar:FindFirstChild("HumanoidRootPart") then return end

                    -- your orbit math here...
                end)
                table.insert(characterConnections, conn)
            end)
        end
        ]]

        -- Do the same pattern for:
        -- orbit, 2orbit, lineorbit, follow, linefollow, worm, partsrain,
        -- robot, stack, 2stack, lookat, fling, bang, facebang, 2facebang, etc.

        -- CMDS list (unchanged from previous goon version)
        if msg:sub(1, 5) == Prefix .. "cmds" then
            local page = msg:sub(7)
            if index == 1 then
                if page == "1" then
                    chat("rejoin, jump, reset, sit, chat (message), shutdown, orbit (...)/unorbit, bang (...)/unbang, walkto, speed, bring, clearchat, privacymode")
                    wait(0.2)
                    chat("spin/unspin, lineup, 3drender, dance, fling/unfling, follow/unfollow, lookat/unlookat, stack/unstack, quit")
                    wait(0.2)
                    chat("goto, carpet/uncarpet, linefollow/unlinefollow, riz, facebang/unfbang, announce, rocket, antibang, 2orbit")
                elseif page == "2" then
                    chat("surround, partsrain/unpartsrain, hug/unhug, worm/unworm, index, logchat, 4k, whitelist+/whitelist-")
                    wait(0.2)
                    chat("admin+/admin-, goon (speed)/ungoon, frontflip/backflip, freeze/unfreeze, antiafk, version, botremove, printcmds, fpscap")
                    wait(0.2)
                    chat("2stack/unstack, 2bang, fullbox/unfullbox, stairs/unstairs, gravity, 2facebang, wings/unwings, bridge")
                elseif page == "3" then
                    chat("unbridge, copychat/uncopychat, validate, robot, unrobot")
                else
                    chat("Page 1, 2 or 3")
                end
            end
        end

        -- ... add the rest of your commands with safeGetCharacter() checks
    end

    -- Command Listener (SyncValue)
    SyncValue.Changed:Connect(function(val)
        if not runScript then return end
        if val == "" then return end
        local p = Players:FindFirstChild(Username)
        if p then commands(p, val) end
    end)

    -- Chat listeners (Keeping as backup)
    for _, plr in ipairs(Players:GetPlayers()) do
        plr.Chatted:Connect(function(msg)
            if not runScript then return end
            commands(plr, msg)
            if logChat then sendToWebhook("```"..msg.."```", plr.Name) end
            if copychat and plr.Name == copychatUsername then chat(msg) end
        end)
    end

    Players.PlayerAdded:Connect(function(plr)
        plr.Chatted:Connect(function(msg)
            if not runScript then return end
            commands(plr, msg)
            if logChat then sendToWebhook("```"..msg.."```", plr.Name) end
            if copychat and plr.Name == copychatUsername then chat(msg) end
        end)
    end)

    Players.PlayerRemoving:Connect(function(plr)
        if not runScript then return end
        for i, botName in ipairs(bots) do
            if plr.Name == botName then
                table.remove(bots, i)
                getIndex()
                if index == 1 then chat("Bot "..i.." left") end
                break
            end
        end
    end)
else
    -- ──────────────────────────────────────────────────────────────
    --  Controller GUI Logic
    -- ──────────────────────────────────────────────────────────────
    
    -- Embed the GUI here or load it
    -- Since the user provided the files locally, we try to load it from the local path first
    local prefix = getgenv().Prefix or "."
    
    local function loadGUI()
        -- Command Data Table
        local cmd_data = {
            {name = "rejoin", args = {}}, {name = "jump", args = {}}, {name = "reset", args = {}}, {name = "sit", args = {}},
            {name = "chat", args = {"message"}}, {name = "shutdown", args = {}}, {name = "orbit", args = {"username", "speed"}},
            {name = "unorbit", args = {}}, {name = "bang", args = {"username", "speed"}}, {name = "unbang", args = {}},
            {name = "walkto", args = {"username"}}, {name = "speed", args = {"number"}}, {name = "bring", args = {}},
            {name = "clearchat", args = {}}, {name = "privacymode", args = {"enable/disable"}}, {name = "spin", args = {"number"}},
            {name = "unspin", args = {}}, {name = "lineup", args = {"direction"}}, {name = "3drender", args = {"enable/disable"}},
            {name = "dance", args = {"emote"}}, {name = "fling", args = {"username"}}, {name = "unfling", args = {}},
            {name = "follow", args = {"username"}}, {name = "unfollow", args = {}}, {name = "lookat", args = {"username"}},
            {name = "unlookat", args = {}}, {name = "stack", args = {"username"}}, {name = "unstack", args = {}},
            {name = "quit", args = {}}, {name = "goto", args = {"username"}}, {name = "carpet", args = {"username"}},
            {name = "uncarpet", args = {}}, {name = "linefollow", args = {"username"}}, {name = "unlinefollow", args = {}},
            {name = "riz", args = {"username"}}, {name = "facebang", args = {"username", "speed"}}, {name = "unfbang", args = {}},
            {name = "announce", args = {"message"}}, {name = "rocket", args = {"height"}}, {name = "antibang", args = {}},
            {name = "2orbit", args = {"username"}}, {name = "surround", args = {"username", "spacing"}},
            {name = "partsrain", args = {"username", "height"}}, {name = "unpartsrain", args = {}}, {name = "hug", args = {"username"}},
            {name = "unhug", args = {}}, {name = "worm", args = {"username"}}, {name = "unworm", args = {}}, {name = "index", args = {}},
            {name = "logchat", args = {"enable/disable"}}, {name = "4k", args = {"username"}}, {name = "whitelist+", args = {"username"}},
            {name = "whitelist-", args = {"username"}}, {name = "admin+", args = {"username"}}, {name = "admin-", args = {"username"}},
            {name = "goon", args = {"speed"}}, {name = "ungoon", args = {}}, {name = "frontflip", args = {}}, {name = "backflip", args = {}},
            {name = "freeze", args = {}}, {name = "unfreeze", args = {}}, {name = "antiafk", args = {"enable/disable"}},
            {name = "version", args = {}}, {name = "botremove", args = {"index"}}, {name = "printcmds", args = {}},
            {name = "2stack", args = {"username"}}, {name = "fpscap", args = {"number"}}, {name = "2bang", args = {"username"}},
            {name = "fullbox", args = {"username"}}, {name = "stairs", args = {"username"}}, {name = "gravity", args = {"number"}},
            {name = "2facebang", args = {"username"}}, {name = "wings", args = {"username"}}, {name = "unwings", args = {}},
            {name = "bridge", args = {"username"}}, {name = "unbridge", args = {}}, {name = "copychat", args = {"username"}},
            {name = "uncopychat", args = {}}, {name = "robot", args = {"username"}}, {name = "unrobot", args = {}},
        }

        local TweenService = game:GetService("TweenService")
        local UserInputService = game:GetService("UserInputService")
        
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

        local CoreGui = game:GetService("CoreGui")
        local success, _ = pcall(function() local x = CoreGui.Name end)
        local Parent = success and CoreGui or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

        local ScreenGui = create("ScreenGui", { Name = "ControlBotZ_GUI", Parent = Parent, ResetOnSpawn = false })
        local MainFrame = create("Frame", {
            Name = "MainFrame", Size = UDim2.new(0, 350, 0, 450), Position = UDim2.new(0.5, -175, 0.5, -225),
            BackgroundColor3 = Color3.fromRGB(15, 15, 15), BorderSizePixel = 0, Active = true, Draggable = true, Parent = ScreenGui
        }, {
            create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            create("UIStroke", { Color = Color3.fromRGB(45, 45, 45), Thickness = 1.5 })
        })

        local TitleBar = create("Frame", {
            Name = "TitleBar", Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Color3.fromRGB(25, 25, 25), BorderSizePixel = 0, Parent = MainFrame
        }, {
            create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            create("Frame", { Size = UDim2.new(1, 0, 0, 5), Position = UDim2.new(0, 0, 1, -5), BackgroundColor3 = Color3.fromRGB(25, 25, 25), BorderSizePixel = 0 }),
            create("TextLabel", {
                Text = "ControlBotZ Controller", Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14, Font = Enum.Font.BuilderSansExtraBold, TextXAlignment = Enum.TextXAlignment.Left
            })
        })

        local SearchBox = create("TextBox", {
            Name = "SearchBox", Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 45),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20), BorderSizePixel = 0, Text = "", PlaceholderText = "Search Commands...",
            TextColor3 = Color3.fromRGB(255, 255, 255), PlaceholderColor3 = Color3.fromRGB(120, 120, 120), TextSize = 13, Font = Enum.Font.BuilderSansMedium, Parent = MainFrame
        }, { create("UICorner", { CornerRadius = UDim.new(0, 5) }), create("UIStroke", { Color = Color3.fromRGB(40, 40, 40) }) })

        local List = create("ScrollingFrame", {
            Name = "List", Size = UDim2.new(1, -20, 1, -100), Position = UDim2.new(0, 10, 0, 85),
            BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, Parent = MainFrame
        }, { create("UIListLayout", { Padding = UDim.new(0, 4) }) })

        local function send(msg)
            -- SyncValue Command (Bypasses Chat)
            SyncValue.Value = msg
            
            -- Small delay and clear to allow repeated commands
            task.delay(0.1, function() if SyncValue.Value == msg then SyncValue.Value = "" end end)
        end

        local activeItem = nil
        local cmdItems = {}

        for _, data in ipairs(cmd_data) do
            local Item = create("Frame", {
                Size = UDim2.new(1, -5, 0, 32), BackgroundColor3 = Color3.fromRGB(22, 22, 22), BorderSizePixel = 0, ClipsDescendants = true, Parent = List
            }, { create("UICorner", { CornerRadius = UDim.new(0, 4) }) })

            local Btn = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Text = "", Parent = Item
            })
            
            local Label = create("TextLabel", {
                Text = data.name, Size = UDim2.new(1, -40, 0, 32), Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 13, Font = Enum.Font.BuilderSansBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = Item
            })

            local Arrow = create("TextLabel", {
                Text = #data.args > 0 and "+" or ">", Size = UDim2.new(0, 30, 0, 32), Position = UDim2.new(1, -30, 0, 0),
                BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(100, 100, 100), TextSize = 13, Font = Enum.Font.BuilderSansBold, Parent = Item
            })

            local InputArea = create("Frame", { Size = UDim2.new(1, -20, 0, 0), Position = UDim2.new(0, 10, 0, 35), BackgroundTransparency = 1, Visible = false, Parent = Item }, { create("UIListLayout", { Padding = UDim.new(0, 4) }) })
            local inputs = {}
            for _, arg in ipairs(data.args) do
                local i = create("TextBox", {
                    Size = UDim2.new(1, -10, 0, 28), BackgroundColor3 = Color3.fromRGB(30, 30, 30), BorderSizePixel = 0, Text = "", PlaceholderText = arg,
                    TextColor3 = Color3.fromRGB(255, 255, 255), PlaceholderColor3 = Color3.fromRGB(80, 80, 80), TextSize = 12, Font = Enum.Font.BuilderSansMedium, Parent = InputArea
                }, { create("UICorner", { CornerRadius = UDim.new(0, 4) }) })
                table.insert(inputs, i)
            end
            local Exec = create("TextButton", {
                Size = UDim2.new(1, -10, 0, 28), BackgroundColor3 = Color3.fromRGB(0, 150, 255), Text = "Execute", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 12, Font = Enum.Font.BuilderSansBold, Visible = #data.args > 0, Parent = InputArea
            }, { create("UICorner", { CornerRadius = UDim.new(0, 4) }) })

            local open = false
            local function toggle(state)
                open = state
                local h = state and (32 + (#data.args * 32) + (#data.args > 0 and 35 or 0) + 10) or 32
                TweenService:Create(Item, TweenInfo.new(0.2), { Size = UDim2.new(1, -5, 0, h) }):Play()
                InputArea.Visible = state
                Arrow.Rotation = state and 45 or 0
            end

            Btn.MouseButton1Click:Connect(function()
                if #data.args == 0 then
                    send(Prefix .. data.name)
                    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    wait(0.1)
                    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
                else
                    if activeItem and activeItem ~= toggle then activeItem(false) end
                    toggle(not open)
                    activeItem = open and toggle or nil
                end
            end)

            Exec.MouseButton1Click:Connect(function()
                local vals = {}
                for _, i in ipairs(inputs) do table.insert(vals, i.Text) end
                send(Prefix .. data.name .. " " .. table.concat(vals, " "))
                if activeItem == toggle then activeItem(false) activeItem = nil end
            end)

            table.insert(cmdItems, { item = Item, name = data.name })
        end

        SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local q = SearchBox.Text:lower()
            for _, i in ipairs(cmdItems) do i.item.Visible = i.name:find(q) ~= nil end
        end)

        local vis = true
        UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
                vis = not vis
                MainFrame.Visible = vis
            end
        end)

        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", { Title = "ControlBotZ GUI", Text = "Controller Loaded. Press RightControl to toggle.", Time = 5 })
        end)
    end

    coroutine.wrap(loadGUI)()
end
end
