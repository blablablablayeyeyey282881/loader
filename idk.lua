-- NEXA HTTP SPY V1.0 - Advanced HTTP Monitoring Tool
-- With Enhanced Serializer Integration

if rconsoleprint then
    rconsoleprint("https://eleutheri.com - #1 Whitelist Service\n\n")
end

assert(syn or http, "Unsupported exploit (should support syn.request or http.request)")

local options = ({...})[1] or { 
    AutoDecode = true, 
    Highlighting = true, 
    SaveLogs = true, 
    CLICommands = true, 
    ShowResponse = true, 
    BlockedURLs = {}, 
    API = true,
    GuiEnabled = true
}
local version = "NEXA HTTP SPY V1.0"
local logname = string.format("%d-%s-log.txt", game.PlaceId, os.date("%d_%m_%y"))

if options.SaveLogs then
    pcall(function()
        writefile(logname, string.format("NEXA HTTP Logs from %s\n\n", os.date("%d/%m/%y")))
    end)
end

-- Enhanced Serializer (Staliezer) Integration
local Serializer = (function()
    local config   = { 
        spaces = 4, 
        highlighting = false,
        showMetatables = false,
        maxDepth = 10,
        showFunctions = true,
        showUserdata = true,
        prettyPrint = true,
        colorScheme = {
            string = "\27[32m",
            number = "\27[33m",
            boolean = "\27[36m",
            keyword = "\27[35m",
            comment = "\27[37m",
            reset = "\27[0m"
        }
    };

    local clonef   = clonefunction;
    local str      = string;
    local gme      = game;
    local sub      = clonef(str.sub);
    local format   = clonef(str.format);
    local rep      = clonef(str.rep);
    local byte     = clonef(str.byte);
    local match    = clonef(str.match);
    local gmatch   = clonef(str.gmatch);
    local find     = clonef(str.find);
    local getfn    = clonef(gme.GetFullName);
    local info     = clonef(debug.getinfo);
    local huge     = math.huge;
    local Type     = clonef(typeof);
    local Pairs    = clonef(pairs);
    local Assert   = clonef(assert);
    local tostring = clonef(tostring);
    local concat   = clonef(table.concat);
    local getmet   = clonef(getmetatable);
    local rawget   = clonef(rawget);
    local rawset   = clonef(rawset);
    local insert   = clonef(table.insert);
    local sort     = clonef(table.sort);
    local Tab      = rep(" ", config.spaces or 4);
    local Serialize;

    -- Enhanced data types with more Roblox-specific types
    local DataTypes = {
        Axes = true,
        BrickColor = true,
        CatalogSearchParams = true,
        CFrame = true,
        Color3 = true,
        ColorSequence = true,
        ColorSequenceKeypoint = true,
        DateTime = true,
        DockWidgetPluginGuiInfo = true,
        Enum = true,
        Faces = true,
        Instance = true,
        NumberRange = true,
        NumberSequence = true,
        NumberSequenceKeypoint = true,
        OverlapParams = true,
        PathWaypoint = true,
        PhysicalProperties = true,
        Random = true,
        Ray = true,
        RaycastParams = true,
        RaycastResult = true,
        Rect = true,
        Region3 = true,
        Region3int16 = true,
        TweenInfo = true,
        UDim = true,
        UDim2 = true,
        Vector2 = true,
        Vector2int16 = true,
        Vector3 = true,
        Vector3int16 = true,
        SharedTable = true,
        EventConnection = true,
        RBXScriptSignal = true,
        RBXScriptConnection = true
    }

    -- Enhanced tostring with metatable handling
    local function Tostring(obj) 
        local mt, r, b = getmet(obj);
        if not mt or Type(mt) ~= "table" then
            return tostring(obj);
        end;
        
        b = rawget(mt, "__tostring");
        rawset(mt, "__tostring", nil);
        r = tostring(obj);
        rawset(mt, "__tostring", b);
        return r;
    end;

    -- Improved argument serialization with type hints
    local function serializeArgs(...) 
        local Serialized = {};
        local args = {...};
        
        for i,v in Pairs(args) do
            local valueType = Type(v);
            local SerializeIndex = #Serialized + 1;
            
            if valueType == "string" then
                Serialized[SerializeIndex] = format("%s\"%s\"%s", 
                    config.colorScheme.string, 
                    formatString(v), 
                    config.colorScheme.reset);
            elseif valueType == "table" then
                Serialized[SerializeIndex] = Serialize(v, 0);
            elseif valueType == "number" then
                Serialized[SerializeIndex] = format("%s%s%s", 
                    config.colorScheme.number, 
                    formatNumber(v), 
                    config.colorScheme.reset);
            elseif valueType == "boolean" then
                Serialized[SerializeIndex] = format("%s%s%s", 
                    config.colorScheme.boolean, 
                    tostring(v), 
                    config.colorScheme.reset);
            elseif valueType == "function" then
                Serialized[SerializeIndex] = config.showFunctions and formatFunction(v) or "function() end";
            elseif valueType == "Instance" then
                Serialized[SerializeIndex] = getfn(v);
            elseif DataTypes[valueType] then
                Serialized[SerializeIndex] = format("%s%s%s", 
                    config.colorScheme.keyword, 
                    Tostring(v), 
                    config.colorScheme.reset);
            else
                Serialized[SerializeIndex] = Tostring(v);
            end;
        end;

        return concat(Serialized, ", ");
    end;

    -- Enhanced function formatting with source info if available
    local function formatFunction(func)
        if not config.showFunctions then
            return "function() end";
        end
        
        if info then
            local proto = info(func, "nS");
            local params = {};
            local source = proto and proto.source and sub(proto.source, 1, 50) or "[no source]";

            if proto and proto.nparams then
                for i=1, proto.nparams do
                    params[i] = format("p%d", i);
                end;
                if proto.isvararg then
                    params[#params+1] = "...";
                end;
            end;

            return format("%sfunction (%s) %s-- %s%s%s", 
                config.colorScheme.keyword,
                concat(params, ", "),
                config.colorScheme.comment,
                proto.name or "anonymous",
                source ~= "[no source]" and " | " .. sub(source, 1, 30) or "",
                config.colorScheme.reset);
        end;
        return "function() end";
    end;

    -- Enhanced string formatting with better escaping
    local function formatString(str) 
        local escaped = {};
        local patterns = {
            { "\\", "\\\\" },
            { "\"", "\\\"" },
            { "\n", "\\n" },
            { "\r", "\\r" },
            { "\t", "\\t" },
            { "\b", "\\b" },
            { "\f", "\\f" }
        };
        
        for char, replacement in Pairs(patterns) do
            str = gsub(str, char, replacement);
        end;
        
        -- Escape non-printable characters
        str = gsub(str, "[\x00-\x1F\x7F-\xFF]", function(c)
            return format("\\%03d", byte(c));
        end);
        
        return str;
    end;

    -- Enhanced number formatting with special value handling
    local function formatNumber(numb) 
        if numb == huge then
            return "math.huge";
        elseif numb == -huge then
            return "-math.huge";
        elseif numb ~= numb then -- NaN
            return "0/0";
        end;
        
        -- Handle integers vs floats
        if numb % 1 == 0 then
            return tostring(numb);
        else
            return format("%.6f", numb):gsub("%.?0+$", "");
        end;
    end;

    -- Enhanced index formatting with better type handling
    local function formatIndex(idx, scope)
        local indexType = Type(idx);
        local finishedFormat = idx;

        if indexType == "string" then
            if match(idx, "^[%a_][%w_]*$") then
                return idx;
            else
                finishedFormat = format("%s\"%s\"%s", 
                    config.colorScheme.string, 
                    formatString(idx), 
                    config.colorScheme.reset);
            end;
        elseif indexType == "table" then
            scope = scope + 1;
            finishedFormat = Serialize(idx, scope);
        elseif indexType == "number" or indexType == "boolean" then
            local color = indexType == "number" and config.colorScheme.number or config.colorScheme.boolean;
            finishedFormat = format("%s%s%s", color, formatNumber(idx), config.colorScheme.reset);
        elseif indexType == "function" then
            finishedFormat = config.showFunctions and formatFunction(idx) or "function() end";
        elseif indexType == "Instance" then
            finishedFormat = getfn(idx);
        else
            finishedFormat = Tostring(idx);
        end;

        return format("[%s]", finishedFormat);
    end;

    -- Main serialization function with depth control and metatable support
    Serialize = function(tbl, scope, checked, path) 
        checked = checked or {};
        path = path or "root";
        
        -- Depth control
        if scope >= (config.maxDepth or huge) then
            return format("%s\"... (max depth reached)\"%s", 
                config.colorScheme.comment, 
                config.colorScheme.reset);
        end;

        -- Circular reference detection
        if checked[tbl] then
            return format("%s\"%s -- circular reference to %s\"%s", 
                config.colorScheme.comment, 
                Tostring(tbl), 
                checked[tbl], 
                config.colorScheme.reset);
        end;

        checked[tbl] = path;
        scope = scope or 0;

        local Serialized = {};
        local scopeTab = config.prettyPrint and rep(Tab, scope) or "";
        local scopeTab2 = config.prettyPrint and rep(Tab, scope+1) or "";
        local keys = {};
        local tblLen = 0;

        -- Collect all keys to sort them for consistent output
        for k in Pairs(tbl) do
            insert(keys, k);
        end;
        
        -- Sort keys for consistent output
        sort(keys, function(a, b)
            local typeA, typeB = Type(a), Type(b);
            
            -- Numbers first, then strings, then other types
            if typeA == "number" and typeB ~= "number" then return true end;
            if typeB == "number" and typeA ~= "number" then return false end;
            if typeA == "string" and typeB ~= "string" then return true end;
            if typeB == "string" and typeA ~= "string" then return false end;
            
            -- Same type comparison
            return tostring(a) < tostring(b);
        end);

        -- Process each key-value pair
        for _, k in Pairs(keys) do
            local v = tbl[k];
            local formattedIndex = formatIndex(k, scope);
            local valueType = Type(v);
            local SerializeIndex = #Serialized + 1;
            local currentPath = path .. "." .. (Type(k) == "string" and k or "[" .. tostring(k) .. "]");

            if valueType == "string" then
                Serialized[SerializeIndex] = format("%s%s = %s\"%s\"%s,%s", 
                    scopeTab2, formattedIndex, 
                    config.colorScheme.string, 
                    formatString(v), 
                    config.colorScheme.reset,
                    config.prettyPrint and "\n" or " ");
            elseif valueType == "number" or valueType == "boolean" then
                local color = valueType == "number" and config.colorScheme.number or config.colorScheme.boolean;
                Serialized[SerializeIndex] = format("%s%s = %s%s%s,%s", 
                    scopeTab2, formattedIndex, 
                    color, 
                    formatNumber(v), 
                    config.colorScheme.reset,
                    config.prettyPrint and "\n" or " ");
            elseif valueType == "table" then
                Serialized[SerializeIndex] = format("%s%s = %s,%s", 
                    scopeTab2, formattedIndex, 
                    Serialize(v, scope+1, checked, currentPath),
                    config.prettyPrint and "\n" or " ");
            elseif valueType == "function" then
                Serialized[SerializeIndex] = format("%s%s = %s,%s", 
                    scopeTab2, formattedIndex, 
                    config.showFunctions and formatFunction(v) or "function() end",
                    config.prettyPrint and "\n" or " ");
            elseif valueType == "Instance" then
                Serialized[SerializeIndex] = format("%s%s = %s,%s", 
                    scopeTab2, formattedIndex, 
                    getfn(v),
                    config.prettyPrint and "\n" or " ");
            elseif valueType == "userdata" then
                if config.showUserdata then
                    if DataTypes[valueType] then
                        Serialized[SerializeIndex] = format("%s%s = %s%s%s,%s", 
                            scopeTab2, formattedIndex, 
                            config.colorScheme.keyword, 
                            Tostring(v), 
                            config.colorScheme.reset,
                            config.prettyPrint and "\n" or " ");
                    else
                        Serialized[SerializeIndex] = format("%s%s = %s-- userdata: %s%s,%s", 
                            scopeTab2, formattedIndex, 
                            config.colorScheme.comment, 
                            valueType,
                            config.colorScheme.reset,
                            config.prettyPrint and "\n" or " ");
                    end;
                else
                    Serialized[SerializeIndex] = format("%s%s = %s-- userdata hidden%s,%s", 
                        scopeTab2, formattedIndex, 
                        config.colorScheme.comment,
                        config.colorScheme.reset,
                        config.prettyPrint and "\n" or " ");
                end;
            else
                Serialized[SerializeIndex] = format("%s%s = %s\"%s\"%s,%s", 
                    scopeTab2, formattedIndex, 
                    config.colorScheme.string, 
                    Tostring(v), 
                    config.colorScheme.reset,
                    config.prettyPrint and "\n" or " ");
            end;

            tblLen = tblLen + 1;
        end;

        -- Handle metatables
        if config.showMetatables then
            local mt = getmet(tbl);
            if mt then
                local formattedIndex = formatIndex("__metatable", scope);
                local mtPath = path .. ".__metatable";
                insert(Serialized, format("%s%s = %s,%s", 
                    scopeTab2, formattedIndex, 
                    Serialize(mt, scope+1, checked, mtPath),
                    config.prettyPrint and "\n" or " "));
            end;
        end;

        -- Remove trailing comma if pretty printing
        if config.prettyPrint and #Serialized > 0 then
            local lastValue = Serialized[#Serialized];
            if lastValue then
                Serialized[#Serialized] = sub(lastValue, 0, -3) .. (config.prettyPrint and "\n" or "");
            end;
        end;

        -- Format the output
        if tblLen > 0 or (config.showMetatables and getmet(tbl)) then
            if config.prettyPrint then
                if scope < 1 then
                    return format("{\n%s}", concat(Serialized));
                else
                    return format("{\n%s%s}", concat(Serialized), scopeTab);
                end;
            else
                return format("{ %s }", concat(Serialized));
            end;
        else
            return "{}";
        end;
    end;

    -- Enhanced serializer API
    local Serializer = {};

    function Serializer.Serialize(tbl)
        if Type(tbl) ~= "table" then
            error("invalid argument #1 to 'Serialize' (table expected)");
        end;
        Assert(Type(tbl) == "table", "");
        return Serialize(tbl);
    end;

    function Serializer.FormatArguments(...) 
        return serializeArgs(...);
    end;

    function Serializer.FormatString(str) 
        if Type(str) ~= "string" then
            error("invalid argument #1 to 'FormatString' (string expected)");
        end;
        return formatString(str);
    end;

    function Serializer.UpdateConfig(options) 
        Assert(Type(options) == "table", "invalid argument #1 to 'UpdateConfig' (table expected)");
        
        -- Update config with new options
        for k, v in Pairs(options) do
            if config[k] ~= nil then
                config[k] = v;
            end;
        end;
        
        -- Update dependent values
        Tab = rep(" ", config.spaces or 4);
        
        -- Update color scheme if provided
        if options.colorScheme then
            for k, v in Pairs(options.colorScheme) do
                if config.colorScheme[k] ~= nil then
                    config.colorScheme[k] = v;
                end;
            end;
        end;
    end;

    -- Additional utility functions
    function Serializer.SetColorScheme(scheme)
        Assert(Type(scheme) == "table", "invalid argument #1 to 'SetColorScheme' (table expected)");
        config.colorScheme = scheme;
    end;

    function Serializer.GetConfig()
        -- Return a copy of the config
        local copy = {};
        for k, v in Pairs(config) do
            if Type(v) == "table" then
                copy[k] = {};
                for k2, v2 in Pairs(v) do
                    copy[k][k2] = v2;
                end;
            else
                copy[k] = v;
            end;
        end;
        return copy;
    end;

    return Serializer;
end)()

-- Configure the serializer based on options
Serializer.UpdateConfig({ highlighting = options.Highlighting })

-- Rest of the initialization with pcall protection
local RecentCommit = "Latest changes"
pcall(function()
    RecentCommit = game.HttpService:JSONDecode(game:HttpGet("https://api.github.com/repos/NotDSF/HttpSpy/commits?per_page=1&path=init.lua"))[1].commit.message
end)

-- Create GUI with error handling
local success, err = pcall(function()
    local clonef = clonefunction
    local format = clonef(string.format)
    local gsub = clonef(string.gsub)
    local match = clonef(string.match)
    local append = clonef(appendfile)
    local Type = clonef(type)
    local crunning = clonef(coroutine.running)
    local cwrap = clonef(coroutine.wrap)
    local cresume = clonef(coroutine.resume)
    local cyield = clonef(coroutine.yield)
    local Pcall = clonef(pcall)
    local Pairs = clonef(pairs)
    local Error = clonef(error)
    local getnamecallmethod = clonef(getnamecallmethod)
    local blocked = options.BlockedURLs
    local enabled = true
    local reqfunc = (syn or http).request
    local libtype = syn and "syn" or "http"
    local hooked = {}
    local proxied = {}
    local methods = {
        HttpGet = not syn,
        HttpGetAsync = not syn,
        GetObjects = true,
        HttpPost = not syn,
        HttpPostAsync = not syn
    }

    local OnRequest = Instance.new("BindableEvent")

    -- Theme definitions
    local Themes = {
        Dark = {
            Background = Color3.fromRGB(25, 25, 25),
            TitleBar = Color3.fromRGB(35, 35, 35),
            Text = Color3.fromRGB(220, 220, 220),
            Button = Color3.fromRGB(80, 80, 80),
            ButtonHover = Color3.fromRGB(100, 100, 100),
            LogBackgroundRequest = Color3.fromRGB(45, 30, 30),
            LogBackgroundResponse = Color3.fromRGB(30, 45, 30),
            ControlBar = Color3.fromRGB(35, 35, 35),
            FilterBox = Color3.fromRGB(50, 50, 50),
            MinimizedIcon = Color3.fromRGB(35, 35, 35),
            CloseButton = Color3.fromRGB(120, 40, 40),
            CloseButtonHover = Color3.fromRGB(150, 50, 50),
            ToggleButtonEnabled = Color3.fromRGB(80, 80, 80),
            ToggleButtonDisabled = Color3.fromRGB(120, 40, 40),
            ClearButton = Color3.fromRGB(60, 60, 60),
            ClearButtonHover = Color3.fromRGB(80, 80, 80),
            ExportButton = Color3.fromRGB(60, 100, 60),
            ExportButtonHover = Color3.fromRGB(80, 120, 80),
            CopyButton = Color3.fromRGB(70, 70, 100),
            CopyButtonHover = Color3.fromRGB(90, 90, 120),
            BorderColor = Color3.fromRGB(60, 60, 60)
        },
        Light = {
            Background = Color3.fromRGB(240, 240, 240),
            TitleBar = Color3.fromRGB(220, 220, 220),
            Text = Color3.fromRGB(40, 40, 40),
            Button = Color3.fromRGB(200, 200, 200),
            ButtonHover = Color3.fromRGB(180, 180, 180),
            LogBackgroundRequest = Color3.fromRGB(255, 230, 230),
            LogBackgroundResponse = Color3.fromRGB(230, 255, 230),
            ControlBar = Color3.fromRGB(220, 220, 220),
            FilterBox = Color3.fromRGB(255, 255, 255),
            MinimizedIcon = Color3.fromRGB(220, 220, 220),
            CloseButton = Color3.fromRGB(255, 180, 180),
            CloseButtonHover = Color3.fromRGB(255, 150, 150),
            ToggleButtonEnabled = Color3.fromRGB(200, 200, 200),
            ToggleButtonDisabled = Color3.fromRGB(255, 180, 180),
            ClearButton = Color3.fromRGB(200, 200, 200),
            ClearButtonHover = Color3.fromRGB(180, 180, 180),
            ExportButton = Color3.fromRGB(200, 230, 200),
            ExportButtonHover = Color3.fromRGB(180, 210, 180),
            CopyButton = Color3.fromRGB(200, 200, 230),
            CopyButtonHover = Color3.fromRGB(180, 180, 210),
            BorderColor = Color3.fromRGB(180, 180, 180)
        }
    }

    local currentTheme = Themes.Dark
    local isMinimized = false

    -- Create GUI
    local HttpSpyGui = Instance.new("ScreenGui")
    HttpSpyGui.Name = "NEXAHttpSpy"
    HttpSpyGui.DisplayOrder = 999
    HttpSpyGui.ResetOnSpawn = false
    HttpSpyGui.Parent = game:GetService("CoreGui")

    -- Main Window Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0.5, 0, 0.6, 0)
    MainFrame.Position = UDim2.new(0.25, 0, 0.2, 0)
    MainFrame.BackgroundColor3 = currentTheme.Background
    MainFrame.BorderColor3 = currentTheme.BorderColor
    MainFrame.BorderSizePixel = 1
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = HttpSpyGui

    -- Make window draggable
    local dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = MainFrame.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                    dragStart = nil
                end
            end)
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Title Bar with modern styling
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = currentTheme.TitleBar
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 2
    TitleBar.Parent = MainFrame

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = TitleBar

    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -250, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = version
    TitleText.TextColor3 = currentTheme.Text
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 16
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.ZIndex = 3
    TitleText.Parent = TitleBar

    -- Button container
    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Size = UDim2.new(0, 230, 1, 0)
    ButtonContainer.Position = UDim2.new(1, -235, 0, 0)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.Parent = TitleBar

    -- Theme Toggle Button
    local ThemeButton = Instance.new("TextButton")
    ThemeButton.Size = UDim2.new(0, 35, 0, 25)
    ThemeButton.Position = UDim2.new(0, 0, 0.5, -12.5)
    ThemeButton.Text = "🌓"
    ThemeButton.Font = Enum.Font.GothamBold
    ThemeButton.TextSize = 16
    ThemeButton.BackgroundColor3 = currentTheme.Button
    ThemeButton.TextColor3 = currentTheme.Text
    ThemeButton.BorderSizePixel = 0
    ThemeButton.AutoButtonColor = false
    ThemeButton.ZIndex = 3
    ThemeButton.Parent = ButtonContainer

    local ThemeCorner = Instance.new("UICorner")
    ThemeCorner.CornerRadius = UDim.new(0, 4)
    ThemeCorner.Parent = ThemeButton

    -- Toggle Button
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 70, 0, 25)
    ToggleButton.Position = UDim2.new(0, 40, 0.5, -12.5)
    ToggleButton.Text = "Disable"
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.TextSize = 12
    ToggleButton.BackgroundColor3 = enabled and currentTheme.ToggleButtonEnabled or currentTheme.ToggleButtonDisabled
    ToggleButton.TextColor3 = currentTheme.Text
    ToggleButton.BorderSizePixel = 0
    ToggleButton.AutoButtonColor = false
    ToggleButton.ZIndex = 3
    ToggleButton.Parent = ButtonContainer

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 4)
    ToggleCorner.Parent = ToggleButton

    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    MinimizeButton.Position = UDim2.new(0, 115, 0.5, -12.5)
    MinimizeButton.Text = "—"
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.TextSize = 16
    MinimizeButton.BackgroundColor3 = currentTheme.Button
    MinimizeButton.TextColor3 = currentTheme.Text
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.AutoButtonColor = false
    MinimizeButton.ZIndex = 3
    MinimizeButton.Parent = ButtonContainer

    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(0, 4)
    MinimizeCorner.Parent = MinimizeButton

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Position = UDim2.new(0, 145, 0.5, -12.5)
    CloseButton.Text = "✕"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 14
    CloseButton.BackgroundColor3 = currentTheme.CloseButton
    CloseButton.TextColor3 = currentTheme.Text
    CloseButton.BorderSizePixel = 0
    CloseButton.AutoButtonColor = false
    CloseButton.ZIndex = 3
    CloseButton.Parent = ButtonContainer

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseButton

    -- Minimized Icon - Modern circular design
    local MinimizedIcon = Instance.new("TextButton")
    MinimizedIcon.Size = UDim2.new(0, 50, 0, 50)
    MinimizedIcon.Position = UDim2.new(0.5, -25, 0, 15)
    MinimizedIcon.Text = "N"
    MinimizedIcon.Font = Enum.Font.GothamBold
    MinimizedIcon.TextSize = 24
    MinimizedIcon.BackgroundColor3 = currentTheme.MinimizedIcon
    MinimizedIcon.TextColor3 = currentTheme.Text
    MinimizedIcon.BorderSizePixel = 0
    MinimizedIcon.AutoButtonColor = false
    MinimizedIcon.Visible = false
    MinimizedIcon.ZIndex = 999
    MinimizedIcon.Parent = HttpSpyGui

    local MinimizedCorner = Instance.new("UICorner")
    MinimizedCorner.CornerRadius = UDim.new(0, 25)
    MinimizedCorner.Parent = MinimizedIcon

    -- Make minimized icon draggable
    local iconDragInput, iconDragStart, iconStartPos
    MinimizedIcon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            iconDragStart = input.Position
            iconStartPos = MinimizedIcon.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                    iconDragStart = nil
                end
            end)
        end
    end)

    MinimizedIcon.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and iconDragStart then
            local delta = input.Position - iconDragStart
            MinimizedIcon.Position = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X, iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y)
        end
    end)

    -- Button hover effects with pcall protection
    local function safeHover(button, enterColor, leaveColor)
        pcall(function()
            button.MouseEnter:Connect(function()
                button.BackgroundColor3 = enterColor
            end)
            button.MouseLeave:Connect(function()
                button.BackgroundColor3 = leaveColor
            end)
        end)
    end

    safeHover(ThemeButton, currentTheme.ButtonHover, currentTheme.Button)
    safeHover(MinimizeButton, currentTheme.ButtonHover, currentTheme.Button)
    safeHover(CloseButton, currentTheme.CloseButtonHover, currentTheme.CloseButton)
    safeHover(ToggleButton, currentTheme.ButtonHover, enabled and currentTheme.ToggleButtonEnabled or currentTheme.ToggleButtonDisabled)
    safeHover(MinimizedIcon, currentTheme.ButtonHover, currentTheme.MinimizedIcon)

    -- Theme toggle functionality
    pcall(function()
        ThemeButton.MouseButton1Click:Connect(function()
            currentTheme = currentTheme == Themes.Dark and Themes.Light or Themes.Dark
            applyTheme()
        end)
    end)

    -- Minimize functionality
    pcall(function()
        MinimizeButton.MouseButton1Click:Connect(function()
            isMinimized = not isMinimized
            MainFrame.Visible = not isMinimized
            MinimizedIcon.Visible = isMinimized
            
            if isMinimized then
                local mainFramePos = MainFrame.Position
                MinimizedIcon.Position = UDim2.new(mainFramePos.X.Scale, mainFramePos.X.Offset + MainFrame.AbsoluteSize.X/2 - 25, 0, 15)
            else
                MainFrame.Position = MinimizedIcon.Position - UDim2.new(0, MainFrame.AbsoluteSize.X/2 - 25, 0, 0)
            end
        end)
    end)

    -- Click minimized icon to restore
    pcall(function()
        MinimizedIcon.MouseButton1Click:Connect(function()
            isMinimized = false
            MainFrame.Visible = true
            MinimizedIcon.Visible = false
            MainFrame.Position = MinimizedIcon.Position - UDim2.new(0, MainFrame.AbsoluteSize.X/2 - 25, 0, 0)
        end)
    end)

    -- Close/unload functionality
    pcall(function()
        CloseButton.MouseButton1Click:Connect(function()
            if __namecall then
                hookmetamethod(game, "__namecall", __namecall)
            end
            
            if __request then
                hookfunction(reqfunc, __request)
            end
            
            HttpSpyGui:Destroy()
            getgenv().NEXAHttpSpy = nil
        end)
    end)

    pcall(function()
        ToggleButton.MouseButton1Click:Connect(function()
            enabled = not enabled
            ToggleButton.Text = enabled and "Disable" or "Enable"
            ToggleButton.BackgroundColor3 = enabled and currentTheme.ToggleButtonEnabled or currentTheme.ToggleButtonDisabled
        end)
    end)

    -- Logs Frame
    local LogsFrame = Instance.new("ScrollingFrame")
    LogsFrame.Size = UDim2.new(1, -10, 1, -80)
    LogsFrame.Position = UDim2.new(0, 5, 0, 40)
    LogsFrame.BackgroundTransparency = 1
    LogsFrame.ScrollBarImageColor3 = currentTheme.Button
    LogsFrame.ScrollBarThickness = 8
    LogsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    LogsFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    LogsFrame.Parent = MainFrame

    local LogsLayout = Instance.new("UIListLayout")
    LogsLayout.Padding = UDim.new(0, 10)
    LogsLayout.Parent = LogsFrame

    -- Control Bar
    local ControlBar = Instance.new("Frame")
    ControlBar.Size = UDim2.new(1, 0, 0, 35)
    ControlBar.Position = UDim2.new(0, 0, 1, -35)
    ControlBar.BackgroundColor3 = currentTheme.ControlBar
    ControlBar.BorderSizePixel = 0
    ControlBar.Parent = MainFrame

    -- Clear Button
    local ClearButton = Instance.new("TextButton")
    ClearButton.Size = UDim2.new(0, 90, 0, 25)
    ClearButton.Position = UDim2.new(0, 10, 0.5, -12.5)
    ClearButton.Text = "Clear Logs"
    ClearButton.Font = Enum.Font.Gotham
    ClearButton.TextSize = 12
    ClearButton.BackgroundColor3 = currentTheme.ClearButton
    ClearButton.TextColor3 = currentTheme.Text
    ClearButton.BorderSizePixel = 0
    ClearButton.AutoButtonColor = false
    ClearButton.Parent = ControlBar

    local ClearCorner = Instance.new("UICorner")
    ClearCorner.CornerRadius = UDim.new(0, 4)
    ClearCorner.Parent = ClearButton

    safeHover(ClearButton, currentTheme.ClearButtonHover, currentTheme.ClearButton)

    -- Export Button
    local ExportButton = Instance.new("TextButton")
    ExportButton.Size = UDim2.new(0, 90, 0, 25)
    ExportButton.Position = UDim2.new(0, 110, 0.5, -12.5)
    ExportButton.Text = "Export"
    ExportButton.Font = Enum.Font.Gotham
    ExportButton.TextSize = 12
    ExportButton.BackgroundColor3 = currentTheme.ExportButton
    ExportButton.TextColor3 = currentTheme.Text
    ExportButton.BorderSizePixel = 0
    ExportButton.AutoButtonColor = false
    ExportButton.Parent = ControlBar

    local ExportCorner = Instance.new("UICorner")
    ExportCorner.CornerRadius = UDim.new(0, 4)
    ExportCorner.Parent = ExportButton

    safeHover(ExportButton, currentTheme.ExportButtonHover, currentTheme.ExportButton)

    -- Filter Box with clear button
    local FilterContainer = Instance.new("Frame")
    FilterContainer.Size = UDim2.new(0, 200, 0, 25)
    FilterContainer.Position = UDim2.new(1, -210, 0.5, -12.5)
    FilterContainer.BackgroundColor3 = currentTheme.FilterBox
    FilterContainer.BorderSizePixel = 0
    FilterContainer.Parent = ControlBar

    local FilterCorner = Instance.new("UICorner")
    FilterCorner.CornerRadius = UDim.new(0, 4)
    FilterCorner.Parent = FilterContainer

    local FilterBox = Instance.new("TextBox")
    FilterBox.Size = UDim2.new(1, -25, 1, 0)
    FilterBox.Position = UDim2.new(0, 5, 0, 0)
    FilterBox.PlaceholderText = "Filter requests..."
    FilterBox.Text = ""
    FilterBox.Font = Enum.Font.Gotham
    FilterBox.TextSize = 12
    FilterBox.BackgroundColor3 = Color3.new(1, 1, 1)
    FilterBox.BackgroundTransparency = 1
    FilterBox.TextColor3 = currentTheme.Text
    FilterBox.TextXAlignment = Enum.TextXAlignment.Left
    FilterBox.Parent = FilterContainer

    local ClearFilterButton = Instance.new("TextButton")
    ClearFilterButton.Size = UDim2.new(0, 20, 0, 20)
    ClearFilterButton.Position = UDim2.new(1, -22.5, 0.5, -10)
    ClearFilterButton.Text = "✕"
    ClearFilterButton.Font = Enum.Font.GothamBold
    ClearFilterButton.TextSize = 12
    ClearFilterButton.BackgroundColor3 = Color3.new(1, 1, 1)
    ClearFilterButton.BackgroundTransparency = 1
    ClearFilterButton.TextColor3 = currentTheme.Text
    ClearFilterButton.BorderSizePixel = 0
    ClearFilterButton.AutoButtonColor = false
    ClearFilterButton.Parent = FilterContainer

    -- Request Counter
    local RequestCount = Instance.new("TextLabel")
    RequestCount.Size = UDim2.new(0, 120, 1, 0)
    RequestCount.Position = UDim2.new(1, -340, 0, 0)
    RequestCount.Text = "Requests: 0"
    RequestCount.Font = Enum.Font.Gotham
    RequestCount.TextSize = 12
    RequestCount.BackgroundTransparency = 1
    RequestCount.TextColor3 = currentTheme.Text
    RequestCount.TextXAlignment = Enum.TextXAlignment.Right
    RequestCount.Parent = ControlBar

    local requestCount = 0
    local function updateRequestCount()
        requestCount = requestCount + 1
        RequestCount.Text = "Requests: "..requestCount
    end

    -- Apply theme function
    local function applyTheme()
        MainFrame.BackgroundColor3 = currentTheme.Background
        MainFrame.BorderColor3 = currentTheme.BorderColor
        TitleBar.BackgroundColor3 = currentTheme.TitleBar
        TitleText.TextColor3 = currentTheme.Text
        ThemeButton.BackgroundColor3 = currentTheme.Button
        MinimizeButton.BackgroundColor3 = currentTheme.Button
        CloseButton.BackgroundColor3 = currentTheme.CloseButton
        ToggleButton.BackgroundColor3 = enabled and currentTheme.ToggleButtonEnabled or currentTheme.ToggleButtonDisabled
        MinimizedIcon.BackgroundColor3 = currentTheme.MinimizedIcon
        MinimizedIcon.TextColor3 = currentTheme.Text
        LogsFrame.ScrollBarImageColor3 = currentTheme.Button
        ControlBar.BackgroundColor3 = currentTheme.ControlBar
        ClearButton.BackgroundColor3 = currentTheme.ClearButton
        ExportButton.BackgroundColor3 = currentTheme.ExportButton
        FilterContainer.BackgroundColor3 = currentTheme.FilterBox
        FilterBox.TextColor3 = currentTheme.Text
        ClearFilterButton.TextColor3 = currentTheme.Text
        RequestCount.TextColor3 = currentTheme.Text
        
        -- Update log entries
        for _, logEntry in ipairs(LogsFrame:GetChildren()) do
            if logEntry:IsA("Frame") then
                local bg = logEntry:FindFirstChild("Background")
                if bg then
                    bg.BackgroundColor3 = logEntry.IsResponse and currentTheme.LogBackgroundResponse or currentTheme.LogBackgroundRequest
                end
                
                local label = logEntry:FindFirstChild("Content")
                if label then
                    label.TextColor3 = currentTheme.Text
                end
                
                local copyButton = logEntry:FindFirstChild("CopyButton")
                if copyButton then
                    copyButton.BackgroundColor3 = currentTheme.CopyButton
                end
                
                local timeText = logEntry:FindFirstChild("Timestamp")
                if timeText then
                    timeText.TextColor3 = currentTheme.Text
                end
            end
        end
    end

    -- Clear logs with confirmation
    pcall(function()
        ClearButton.MouseButton1Click:Connect(function()
            local confirmDialog = Instance.new("Frame")
            confirmDialog.Size = UDim2.new(0, 300, 0, 150)
            confirmDialog.Position = UDim2.new(0.5, -150, 0.5, -75)
            confirmDialog.BackgroundColor3 = currentTheme.Background
            confirmDialog.BorderColor3 = currentTheme.BorderColor
            confirmDialog.BorderSizePixel = 1
            confirmDialog.ZIndex = 1000
            confirmDialog.Parent = HttpSpyGui
            
            local dialogCorner = Instance.new("UICorner")
            dialogCorner.CornerRadius = UDim.new(0, 8)
            dialogCorner.Parent = confirmDialog
            
            local dialogTitle = Instance.new("TextLabel")
            dialogTitle.Size = UDim2.new(1, 0, 0, 40)
            dialogTitle.Position = UDim2.new(0, 0, 0, 0)
            dialogTitle.BackgroundTransparency = 1
            dialogTitle.Text = "Confirm Clear"
            dialogTitle.TextColor3 = currentTheme.Text
            dialogTitle.Font = Enum.Font.GothamBold
            dialogTitle.TextSize = 16
            dialogTitle.Parent = confirmDialog
            
            local dialogMessage = Instance.new("TextLabel")
            dialogMessage.Size = UDim2.new(1, -20, 0, 50)
            dialogMessage.Position = UDim2.new(0, 10, 0, 50)
            dialogMessage.BackgroundTransparency = 1
            dialogMessage.Text = "Are you sure you want to clear all logs?"
            dialogMessage.TextColor3 = currentTheme.Text
            dialogMessage.Font = Enum.Font.Gotham
            dialogMessage.TextSize = 14
            dialogMessage.TextWrapped = true
            dialogMessage.Parent = confirmDialog
            
            local confirmButton = Instance.new("TextButton")
            confirmButton.Size = UDim2.new(0, 100, 0, 30)
            confirmButton.Position = UDim2.new(0.25, -50, 1, -40)
            confirmButton.Text = "Yes"
            confirmButton.Font = Enum.Font.Gotham
            confirmButton.TextSize = 12
            confirmButton.BackgroundColor3 = currentTheme.CloseButton
            confirmButton.TextColor3 = currentTheme.Text
            confirmButton.BorderSizePixel = 0
            confirmButton.Parent = confirmDialog
            
            local confirmCorner = Instance.new("UICorner")
            confirmCorner.CornerRadius = UDim.new(0, 4)
            confirmCorner.Parent = confirmButton
            
            local cancelButton = Instance.new("TextButton")
            cancelButton.Size = UDim2.new(0, 100, 0, 30)
            cancelButton.Position = UDim2.new(0.75, -50, 1, -40)
            cancelButton.Text = "No"
            cancelButton.Font = Enum.Font.Gotham
            cancelButton.TextSize = 12
            cancelButton.BackgroundColor3 = currentTheme.Button
            cancelButton.TextColor3 = currentTheme.Text
            cancelButton.BorderSizePixel = 0
            cancelButton.Parent = confirmDialog
            
            local cancelCorner = Instance.new("UICorner")
            cancelCorner.CornerRadius = UDim.new(0, 4)
            cancelCorner.Parent = cancelButton
            
            safeHover(confirmButton, currentTheme.CloseButtonHover, currentTheme.CloseButton)
            safeHover(cancelButton, currentTheme.ButtonHover, currentTheme.Button)
            
            confirmButton.MouseButton1Click:Connect(function()
                local children = LogsFrame:GetChildren()
                for i = #children, 1, -1 do
                    local child = children[i]
                    if child:IsA("Frame") then
                        child:Destroy()
                    end
                end
                requestCount = 0
                RequestCount.Text = "Requests: 0"
                confirmDialog:Destroy()
            end)
            
            cancelButton.MouseButton1Click:Connect(function()
                confirmDialog:Destroy()
            end)
        end)
    end)

    -- Export logs functionality
    pcall(function()
        ExportButton.MouseButton1Click:Connect(function()
            local exportData = "NEXA HTTP SPY EXPORT - "..os.date("%d/%m/%y %H:%M:%S").."\n\n"
            
            for _, logEntry in ipairs(LogsFrame:GetChildren()) do
                if logEntry:IsA("Frame") then
                    local content = logEntry:FindFirstChild("Content")
                    if content then
                        exportData = exportData..content.Text.."\n\n"
                    end
                end
            end
            
            local exportName = string.format("NEXA-export-%s.txt", os.date("%d_%m_%y_%H_%M_%S"))
            writefile(exportName, exportData)
            
            -- Show success message
            local successMessage = Instance.new("TextLabel")
            successMessage.Size = UDim2.new(0, 200, 0, 30)
            successMessage.Position = UDim2.new(0.5, -100, 0.5, -15)
            successMessage.BackgroundColor3 = currentTheme.ExportButton
            successMessage.TextColor3 = currentTheme.Text
            successMessage.Font = Enum.Font.Gotham
            successMessage.TextSize = 14
            successMessage.Text = "Exported to "..exportName
            successMessage.Parent = HttpSpyGui
            
            local successCorner = Instance.new("UICorner")
            successCorner.CornerRadius = UDim.new(0, 4)
            successCorner.Parent = successMessage
            
            game:GetService("Debris"):AddItem(successMessage, 3)
        end)
    end)

    -- Clear filter functionality
    pcall(function()
        ClearFilterButton.MouseButton1Click:Connect(function()
            FilterBox.Text = ""
        end)
    end)

    -- Enhanced printf function for GUI with error handling
    local function printf(text, isResponse)
        if options.SaveLogs then
            pcall(function()
                append(logname, gsub(text, "%\27%[%d+m", ""))
            end)
        end
        
        if not options.GuiEnabled then return end
        
        local cleanText = text:gsub("\27%[[%d;]+m", "")
        
        task.spawn(function()
            pcall(function()
                local logEntry = Instance.new("Frame")
                logEntry.Size = UDim2.new(1, -10, 0, 0)
                logEntry.Position = UDim2.new(0, 5, 0, 0)
                logEntry.BackgroundTransparency = 1
                logEntry.AutomaticSize = Enum.AutomaticSize.Y
                logEntry.IsResponse = isResponse
                logEntry.Parent = LogsFrame
                
                -- Entry background
                local bg = Instance.new("Frame")
                bg.Name = "Background"
                bg.Size = UDim2.new(1, 0, 1, 0)
                bg.BackgroundColor3 = isResponse and currentTheme.LogBackgroundResponse or currentTheme.LogBackgroundRequest
                bg.BackgroundTransparency = 0.9
                bg.BorderSizePixel = 0
                bg.Parent = logEntry
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 6)
                corner.Parent = bg
                
                -- Copy button
                local copyButton = Instance.new("TextButton")
                copyButton.Name = "CopyButton"
                copyButton.Size = UDim2.new(0, 50, 0, 20)
                copyButton.Position = UDim2.new(1, -55, 0, 5)
                copyButton.Text = "Copy"
                copyButton.Font = Enum.Font.Gotham
                copyButton.TextSize = 11
                copyButton.BackgroundColor3 = currentTheme.CopyButton
                copyButton.TextColor3 = currentTheme.Text
                copyButton.BorderSizePixel = 0
                copyButton.AutoButtonColor = false
                copyButton.Parent = logEntry
                
                local copyCorner = Instance.new("UICorner")
                copyCorner.CornerRadius = UDim.new(0, 4)
                copyCorner.Parent = copyButton
                
                safeHover(copyButton, currentTheme.CopyButtonHover, currentTheme.CopyButton)
                
                pcall(function()
                    copyButton.MouseButton1Click:Connect(function()
                        setclipboard(cleanText)
                        copyButton.Text = "Copied!"
                        task.wait(1)
                        copyButton.Text = "Copy"
                    end)
                end)
                
                -- Content label
                local label = Instance.new("TextLabel")
                label.Name = "Content"
                label.Size = UDim2.new(1, -60, 0, 0)
                label.Position = UDim2.new(0, 10, 0, 5)
                label.Text = cleanText
                label.TextColor3 = currentTheme.Text
                label.BackgroundTransparency = 1
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.TextYAlignment = Enum.TextYAlignment.Top
                label.TextWrapped = true
                label.Font = Enum.Font.Code
                label.TextSize = 13
                label.AutomaticSize = Enum.AutomaticSize.Y
                label.Parent = logEntry
                
                -- Timestamp
                local timeText = Instance.new("TextLabel")
                timeText.Name = "Timestamp"
                timeText.Size = UDim2.new(1, -60, 0, 15)
                timeText.Position = UDim2.new(0, 10, 1, -20)
                timeText.Text = os.date("%H:%M:%S")
                timeText.TextColor3 = currentTheme.Text
                timeText.BackgroundTransparency = 1
                timeText.TextXAlignment = Enum.TextXAlignment.Left
                timeText.Font = Enum.Font.Gotham
                timeText.TextSize = 10
                timeText.Parent = logEntry
                
                -- Auto-scroll to bottom if not filtering
                if FilterBox.Text == "" then
                    task.wait()
                    LogsFrame.CanvasPosition = Vector2.new(0, LogsFrame.AbsoluteCanvasSize.Y)
                end
                
                updateRequestCount()
            end)
        end)
    end

    -- Fixed filter functionality with error handling
    pcall(function()
        FilterBox:GetPropertyChangedSignal("Text"):Connect(function()
            local filterText = string.lower(FilterBox.Text)
            
            for _, logEntry in ipairs(LogsFrame:GetChildren()) do
                if logEntry:IsA("Frame") then
                    local label = logEntry:FindFirstChild("Content")
                    if label and label.Text then
                        logEntry.Visible = filterText == "" or string.find(string.lower(label.Text), filterText, 1, true) ~= nil
                    end
                end
            end
        end)
    end)

    local function ConstantScan(constant)
        for i,v in Pairs(getgc(true)) do
            if type(v) == "function" and islclosure(v) and getfenv(v).script == getfenv(saveinstance).script and table.find(debug.getconstants(v), constant) then
                return v;
            end;
        end;
    end;

    local function DeepClone(tbl, cloned)
        cloned = cloned or {};

        for i,v in Pairs(tbl) do
            if Type(v) == "table" then
                cloned[i] = DeepClone(v);
                continue;
            end;
            cloned[i] = v;
        end;

        return cloned;
    end;

    local __namecall, __request;
    __namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod();

        if methods[method] then
            printf("game:"..method.."("..Serializer.FormatArguments(...)..")\n\n");
        end;

        return __namecall(self, ...);
    end));

    __request = hookfunction(reqfunc, newcclosure(function(req) 
        if Type(req) ~= "table" then return __request(req); end;
        
        local RequestData = DeepClone(req);
        if not enabled then
            return __request(req);
        end;

        if Type(RequestData.Url) ~= "string" then return __request(req) end;

        if not options.ShowResponse then
            printf(libtype..".request("..Serializer.Serialize(RequestData)..")\n\n");
            return __request(req);
        end;

        local t = crunning();
        cwrap(function() 
            if RequestData.Url and blocked[RequestData.Url] then
                printf(libtype..".request("..Serializer.Serialize(RequestData)..") -- blocked url\n\n");
                return cresume(t, {});
            end;

            if RequestData.Url then
                local Host = string.match(RequestData.Url, "https?://(%w+.%w+)/");
                if Host and proxied[Host] then
                    RequestData.Url = gsub(RequestData.Url, Host, proxied[Host], 1);
                end; 
            end;

            OnRequest:Fire(RequestData);

            local ok, ResponseData = Pcall(__request, RequestData);
            if not ok then
                Error(ResponseData, 0);
            end;

            local BackupData = {};
            for i,v in Pairs(ResponseData) do
                BackupData[i] = v;
            end;

            if BackupData.Headers["Content-Type"] and match(BackupData.Headers["Content-Type"], "application/json") and options.AutoDecode then
                local body = BackupData.Body;
                local ok, res = Pcall(game.HttpService.JSONDecode, game.HttpService, body);
                if ok then
                    BackupData.Body = res;
                end;
            end;

            printf(libtype..".request("..Serializer.Serialize(RequestData)..")\n\n", false);
            printf("Response Data: "..Serializer.Serialize(BackupData).."\n\n", true);
            cresume(t, hooked[RequestData.Url] and hooked[RequestData.Url](ResponseData) or ResponseData);
        end)();
        return cyield();
    end));

    if request then
        replaceclosure(request, reqfunc);
    end;

    if syn and syn.websocket then
        local WsConnect, WsBackup = debug.getupvalue(syn.websocket.connect, 1);
        WsBackup = hookfunction(WsConnect, function(...) 
            printf("syn.websocket.connect("..Serializer.FormatArguments(...)..")\n\n");
            return WsBackup(...);
        end);
    end;

    if syn and syn.websocket then
        local HttpGet;
        HttpGet = hookfunction(getupvalue(ConstantScan("ZeZLm2hpvGJrD6OP8A3aEszPNEw8OxGb"), 2), function(self, ...) 
            printf("game.HttpGet(game, "..Serializer.FormatArguments(...)..")\n\n");
            return HttpGet(self, ...);
        end);

        local HttpPost;
        HttpPost = hookfunction(getupvalue(ConstantScan("gpGXBVpEoOOktZWoYECgAY31o0BlhOue"), 2), function(self, ...) 
            printf("game.HttpPost(game, "..Serializer.FormatArguments(...)..")\n\n");
            return HttpPost(self, ...);
        end);
    end

    for method, enabled in Pairs(methods) do
        if enabled then
            local b;
            b = hookfunction(game[method], newcclosure(function(self, ...) 
                printf("game."..method.."(game, "..Serializer.FormatArguments(...)..")\n\n");
                return b(self, ...);
            end));
        end;
    end;

    if not debug.info(2, "f") then
        printf("You are running an outdated version, please use the loadstring at https://github.com/NotDSF/HttpSpy\n");
    end;

    -- Initialize with welcome message
    task.spawn(function()
        printf("NEXA HTTP SPY V1.0 (Creator: https://github.com/NotDSF)\nChange Logs:\n\t"..RecentCommit.."\nLogs are automatically being saved to: "..(options.SaveLogs and logname or "(You aren't saving logs, enable SaveLogs if you want to save logs)").."\n\n")
    end)

    if not options.API then return end

    local API = {}
    API.OnRequest = OnRequest.Event

    function API:HookSynRequest(url, hook) 
        hooked[url] = hook
    end

    function API:ProxyHost(host, proxy) 
        proxied[host] = proxy
    end

    function API:RemoveProxy(host) 
        if not proxied[host] then
            error("host isn't proxied", 0)
        end
        proxied[host] = nil
    end

    function API:UnHookSynRequest(url) 
        if not hooked[url] then
            error("url isn't hooked", 0)
        end
        hooked[url] = nil
    end

    function API:BlockUrl(url) 
        blocked[url] = true
    end

    function API:WhitelistUrl(url) 
        blocked[url] = false
    end

    -- Enhanced GUI control to API
    function API:ToggleGui(visible)
        HttpSpyGui.Enabled = visible
        options.GuiEnabled = visible
    end

    function API:SetGuiPosition(position)
        MainFrame.Position = position
    end

    function API:SetGuiSize(size)
        MainFrame.Size = size
    end

    function API:SetTheme(themeName)
        if Themes[themeName] then
            currentTheme = Themes[themeName]
            applyTheme()
        end
    end

    return API
end)

if not success and err then
    warn("NEXA HTTP SPY initialization failed: "..tostring(err))
    if rconsoleprint then
        rconsoleprint("@@RED@@")
        rconsoleprint("NEXA HTTP SPY initialization error: "..tostring(err).."\n")
    end
    return nil
end
