-- smallUI by Azxerman (Open Source)
local smallUI, TweenService = {}, game:GetService("TweenService")
local UserInputService, Players = game:GetService("UserInputService"), game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

smallUI.Theme = {
    Background = Color3.fromRGB(25, 25, 30), Sidebar = Color3.fromRGB(30, 30, 35),
    Topbar = Color3.fromRGB(35, 35, 40), TabActive = Color3.fromRGB(45, 45, 55),
    TabInactive = Color3.fromRGB(35, 35, 40), Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(180, 180, 180), Accent = Color3.fromRGB(88, 101, 242),
    Success = Color3.fromRGB(67, 181, 129), Error = Color3.fromRGB(240, 71, 71),
    Warning = Color3.fromRGB(250, 166, 26), Border = Color3.fromRGB(50, 50, 55),
    ElementBg = Color3.fromRGB(40, 40, 45), ElementHover = Color3.fromRGB(50, 50, 60)
}

local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    return inst
end

local function Tween(inst, props, dur)
    TweenService:Create(inst, TweenInfo.new(dur or 0.3, Enum.EasingStyle.Quart), props):Play()
end

local function Corner(parent, rad)
    return Create("UICorner", {Parent = parent, CornerRadius = UDim.new(0, rad or 6)})
end

local function MakeDraggable(frame, handle)
    local drag, inputPos, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag, inputPos, startPos = true, i.Position, frame.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
        end
    end)
    handle.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then inputPos = i end end)
    UserInputService.InputChanged:Connect(function(i)
        if i == inputPos and drag then
            local delta = i.Position - inputPos
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function smallUI:Init(c)
    c = c or {}
    self.ScreenGui = Create("ScreenGui", {Name = "smallUI", Parent = game.CoreGui, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    self.Main = Create("Frame", {Name = "Main", Parent = self.ScreenGui, BackgroundColor3 = self.Theme.Background, 
        Position = UDim2.new(0.5, -325, 0.5, -225), Size = c.Size or UDim2.new(0, 650, 0, 450), ClipsDescendants = true})
    Corner(self.Main, 8)
    Create("ImageLabel", {Name = "Shadow", Parent = self.Main, AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 40, 1, 40), ZIndex = -1, Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.new(0, 0, 0), ImageTransparency = 0.6, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(23, 23, 277, 277)})
    
    self.Topbar = Create("Frame", {Name = "Topbar", Parent = self.Main, BackgroundColor3 = self.Theme.Topbar, Size = UDim2.new(1, 0, 0, 45)})
    local ctrls = Create("Frame", {Parent = self.Topbar, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0.5, -6), Size = UDim2.new(0, 60, 0, 12)})
    local function CtrlBtn(color, x, name)
        local b = Create("Frame", {Name = name, Parent = ctrls, BackgroundColor3 = color, Position = UDim2.new(0, x, 0, 0), Size = UDim2.new(0, 12, 0, 12)})
        Corner(b, 1)
        return b
    end
    local close, mini = CtrlBtn(self.Theme.Error, 0, "Close"), CtrlBtn(self.Theme.Warning, 20, "Minimize")
    CtrlBtn(self.Theme.Success, 40, "Maximize")
    
    local addr = Create("Frame", {Parent = self.Topbar, BackgroundColor3 = self.Theme.ElementBg, Position = UDim2.new(0, 90, 0.5, -12), Size = UDim2.new(1, -180, 0, 24)})
    Corner(addr, 4)
    Create("TextLabel", {Parent = addr, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0),
        Font = Enum.Font.Gotham, Text = "🔒 " .. (c.Title or "smallUI"), TextColor3 = self.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
    Create("TextLabel", {Parent = self.Topbar, BackgroundTransparency = 1, Position = UDim2.new(1, -150, 0, 0), Size = UDim2.new(0, 140, 1, 0),
        Font = Enum.Font.GothamBold, Text = c.Title or "smallUI", TextColor3 = self.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right})
    
    self.Sidebar = Create("Frame", {Name = "Sidebar", Parent = self.Main, BackgroundColor3 = self.Theme.Sidebar, 
        Position = UDim2.new(0, 0, 0, 45), Size = UDim2.new(0, 140, 1, -45)})
    Create("UIListLayout", {Parent = self.Sidebar, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder})
    Create("UIPadding", {Parent = self.Sidebar, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
    
    self.Content = Create("Frame", {Name = "Content", Parent = self.Main, BackgroundColor3 = self.Theme.Background,
        Position = UDim2.new(0, 140, 0, 45), Size = UDim2.new(1, -140, 1, -45), ClipsDescendants = true})
    
    self.Tabs, self.ActiveTab = {}, nil
    MakeDraggable(self.Main, self.Topbar)
    
    local minimized = false
    mini.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then
        minimized = not minimized
        Tween(self.Main, {Size = minimized and UDim2.new(0, 650, 0, 45) or (c.Size or UDim2.new(0, 650, 0, 450))}, 0.3)
        if not minimized then task.wait(0.3) end
        self.Sidebar.Visible, self.Content.Visible = not minimized, not minimized
    end end)
    
    close.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then self:Destroy() end end)
    
    UserInputService.InputBegan:Connect(function(i, gp) if not gp and i.KeyCode == (c.Keybind or Enum.KeyCode.RightShift) then self.Main.Visible = not self.Main.Visible end end)
    return self
end

function smallUI:CreateTab(name, icon)
    icon = icon or "📄"
    local tab = {Name = name, Elements = {}}
    tab.Button = Create("TextButton", {Name = name.."Tab", Parent = self.Sidebar, BackgroundColor3 = self.Theme.TabInactive,
        Size = UDim2.new(1, 0, 0, 32), Font = Enum.Font.Gotham, Text = "  "..icon.."  "..name,
        TextColor3 = self.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false})
    Corner(tab.Button)
    
    tab.Container = Create("ScrollingFrame", {Name = name.."Container", Parent = self.Content, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 4, ScrollBarImageColor3 = self.Theme.Accent, Visible = false,
        AutomaticCanvasSize = Enum.AutomaticSize.Y})
    Create("UIListLayout", {Parent = tab.Container, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})
    Create("UIPadding", {Parent = tab.Container, PaddingTop = UDim.new(0, 15), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), PaddingBottom = UDim.new(0, 15)})
    
    tab.Button.MouseButton1Click:Connect(function() self:SwitchTab(tab) end)
    tab.Button.MouseEnter:Connect(function() if self.ActiveTab ~= tab then Tween(tab.Button, {BackgroundColor3 = self.Theme.ElementHover}, 0.2) end end)
    tab.Button.MouseLeave:Connect(function() if self.ActiveTab ~= tab then Tween(tab.Button, {BackgroundColor3 = self.Theme.TabInactive}, 0.2) end end)
    
    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then self:SwitchTab(tab) end
    
    function tab:CreateLabel(text)
        return Create("TextLabel", {Parent = tab.Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20),
            Font = Enum.Font.GothamBold, Text = text, TextColor3 = smallUI.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
    end
    
    function tab:CreateButton(text, cb)
        local f = Create("Frame", {Parent = tab.Container, BackgroundColor3 = smallUI.Theme.ElementBg, Size = UDim2.new(1, 0, 0, 36)})
        Corner(f)
        local b = Create("TextButton", {Parent = f, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.Gotham, Text = text, TextColor3 = smallUI.Theme.Text, TextSize = 13})
        b.MouseEnter:Connect(function() Tween(f, {BackgroundColor3 = smallUI.Theme.Accent}, 0.2) end)
        b.MouseLeave:Connect(function() Tween(f, {BackgroundColor3 = smallUI.Theme.ElementBg}, 0.2) end)
        b.MouseButton1Click:Connect(cb)
        return b
    end
    
    function tab:CreateToggle(text, def, cb)
        local f = Create("Frame", {Parent = tab.Container, BackgroundColor3 = smallUI.Theme.ElementBg, Size = UDim2.new(1, 0, 0, 36)})
        Corner(f)
        Create("TextLabel", {Parent = f, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -60, 1, 0),
            Font = Enum.Font.Gotham, Text = text, TextColor3 = smallUI.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local t = Create("Frame", {Parent = f, BackgroundColor3 = def and smallUI.Theme.Accent or smallUI.Theme.Border,
            Position = UDim2.new(1, -48, 0.5, -10), Size = UDim2.new(0, 36, 0, 20)})
        Corner(t, 1)
        local c = Create("Frame", {Parent = t, BackgroundColor3 = Color3.new(1, 1, 1), Position = def and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), Size = UDim2.new(0, 16, 0, 16)})
        Corner(c, 1)
        local en = def or false
        local function upd()
            en = not en
            Tween(t, {BackgroundColor3 = en and smallUI.Theme.Accent or smallUI.Theme.Border}, 0.2)
            Tween(c, {Position = en and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
            cb(en)
        end
        f.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then upd() end end)
        return {Set = function(v) en = v; Tween(t, {BackgroundColor3 = en and smallUI.Theme.Accent or smallUI.Theme.Border}, 0.2)
            Tween(c, {Position = en and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2); cb(en) end, Get = function() return en end}
    end
    
    function tab:CreateSlider(text, min, max, def, cb)
        local f = Create("Frame", {Parent = tab.Container, BackgroundColor3 = smallUI.Theme.ElementBg, Size = UDim2.new(1, 0, 0, 56)})
        Corner(f)
        Create("TextLabel", {Parent = f, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 8), Size = UDim2.new(1, -60, 0, 20),
            Font = Enum.Font.Gotham, Text = text, TextColor3 = smallUI.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local vl = Create("TextLabel", {Parent = f, BackgroundTransparency = 1, Position = UDim2.new(1, -50, 0, 8), Size = UDim2.new(0, 40, 0, 20),
            Font = Enum.Font.GothamBold, Text = tostring(def), TextColor3 = smallUI.Theme.Accent, TextSize = 13})
        local bg = Create("Frame", {Parent = f, BackgroundColor3 = smallUI.Theme.Border, Position = UDim2.new(0, 12, 0, 34), Size = UDim2.new(1, -24, 0, 6)})
        Corner(bg, 1)
        local fill = Create("Frame", {Parent = bg, BackgroundColor3 = smallUI.Theme.Accent, Size = UDim2.new((def - min) / (max - min), 0, 1, 0)})
        Corner(fill, 1)
        local knob = Create("Frame", {Parent = bg, BackgroundColor3 = Color3.new(1, 1, 1), Position = UDim2.new((def - min) / (max - min), -6, 0.5, -6), Size = UDim2.new(0, 12, 0, 12), ZIndex = 2})
        Corner(knob, 1)
        local val, drag = def, false
        local function upd(i)
            local pos = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            val = math.floor(min + (max - min) * pos)
            vl.Text = tostring(val); fill.Size = UDim2.new(pos, 0, 1, 0); knob.Position = UDim2.new(pos, -6, 0.5, -6)
            cb(val)
        end
        bg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true; upd(i) end end)
        UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then upd(i) end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
        return {Set = function(v) val = math.clamp(v, min, max); local pos = (val - min) / (max - min); vl.Text = tostring(val)
            fill.Size = UDim2.new(pos, 0, 1, 0); knob.Position = UDim2.new(pos, -6, 0.5, -6); cb(val) end, Get = function() return val end}
    end
    
    function tab:CreateDropdown(text, opts, cb)
        local f = Create("Frame", {Parent = tab.Container, BackgroundColor3 = smallUI.Theme.ElementBg, Size = UDim2.new(1, 0, 0, 36), ClipsDescendants = true})
        Corner(f)
        local lbl = Create("TextLabel", {Parent = f, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -40, 0, 36),
            Font = Enum.Font.Gotham, Text = text, TextColor3 = smallUI.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local arrow = Create("TextLabel", {Parent = f, BackgroundTransparency = 1, Position = UDim2.new(1, -30, 0, 0), Size = UDim2.new(0, 30, 0, 36),
            Font = Enum.Font.GothamBold, Text = "▼", TextColor3 = smallUI.Theme.SubText, TextSize = 12})
        local cont = Create("Frame", {Parent = f, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 36), Size = UDim2.new(1, 0, 0, #opts * 30)})
        Create("UIListLayout", {Parent = cont, SortOrder = Enum.SortOrder.LayoutOrder})
        local sel, open = opts[1], false
        for _, opt in ipairs(opts) do
            local b = Create("TextButton", {Parent = cont, BackgroundColor3 = smallUI.Theme.ElementBg, Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.Gotham, Text = "   "..opt, TextColor3 = smallUI.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
            b.MouseEnter:Connect(function() Tween(b, {BackgroundColor3 = smallUI.Theme.ElementHover}, 0.2) end)
            b.MouseLeave:Connect(function() Tween(b, {BackgroundColor3 = smallUI.Theme.ElementBg}, 0.2) end)
            b.MouseButton1Click:Connect(function() sel = opt; lbl.Text = text..": "..sel; cb(sel); open = false; Tween(f, {Size = UDim2.new(1, 0, 0, 36)}, 0.2); Tween(arrow, {Rotation = 0}, 0.2) end)
        end
        f.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then open = not open; Tween(f, {Size = open and UDim2.new(1, 0, 0, 36 + #opts * 30) or UDim2.new(1, 0, 0, 36)}, 0.2); Tween(arrow, {Rotation = open and 180 or 0}, 0.2) end end)
        return {Set = function(v) if table.find(opts, v) then sel = v; lbl.Text = text..": "..sel; cb(sel) end end, Get = function() return sel end}
    end
    
    function tab:CreateTextbox(text, ph, cb)
        local f = Create("Frame", {Parent = tab.Container, BackgroundColor3 = smallUI.Theme.ElementBg, Size = UDim2.new(1, 0, 0, 36)})
        Corner(f)
        Create("TextLabel", {Parent = f, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0.4, 0, 1, 0),
            Font = Enum.Font.Gotham, Text = text, TextColor3 = smallUI.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local box = Create("TextBox", {Parent = f, BackgroundColor3 = smallUI.Theme.Background, Position = UDim2.new(0.45, 0, 0.5, -12),
            Size = UDim2.new(0.5, -12, 0, 24), Font = Enum.Font.Gotham, PlaceholderText = ph, Text = "", TextColor3 = smallUI.Theme.Text, TextSize = 12})
        Corner(box, 4)
        box.FocusLost:Connect(function(ep) if ep then cb(box.Text) end end)
        return box
    end
    
    function tab:CreateKeybind(text, def, cb)
        local f = Create("Frame", {Parent = tab.Container, BackgroundColor3 = smallUI.Theme.ElementBg, Size = UDim2.new(1, 0, 0, 36)})
        Corner(f)
        Create("TextLabel", {Parent = f, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -100, 1, 0),
            Font = Enum.Font.Gotham, Text = text, TextColor3 = smallUI.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
        local btn = Create("TextButton", {Parent = f, BackgroundColor3 = smallUI.Theme.Background, Position = UDim2.new(1, -80, 0.5, -12),
            Size = UDim2.new(0, 70, 0, 24), Font = Enum.Font.GothamBold, Text = def and def.Name or "None", TextColor3 = smallUI.Theme.Accent, TextSize = 12})
        Corner(btn, 4)
        local bind, cur = false, def
        btn.MouseButton1Click:Connect(function() bind = true; btn.Text = "..."; local con; con = UserInputService.InputBegan:Connect(function(i)
            if bind and i.UserInputType == Enum.UserInputType.Keyboard then cur = i.KeyCode; btn.Text = cur.Name; bind = false; cb(cur); con:Disconnect() end end) end)
        return {Set = function(k) cur = k; btn.Text = cur and cur.Name or "None" end, Get = function() return cur end}
    end
    
    return tab
end

function smallUI:SwitchTab(tab)
    if self.ActiveTab then
        Tween(self.ActiveTab.Button, {BackgroundColor3 = self.Theme.TabInactive, TextColor3 = self.Theme.SubText}, 0.2)
        self.ActiveTab.Container.Visible = false
    end
    self.ActiveTab = tab
    Tween(tab.Button, {BackgroundColor3 = self.Theme.TabActive, TextColor3 = self.Theme.Text}, 0.2)
    tab.Container.Visible = true
end

function smallUI:Notify(title, msg, dur, t)
    dur, t = dur or 3, t or "Info"
    local colors = {Info = self.Theme.Accent, Success = self.Theme.Success, Error = self.Theme.Error, Warning = self.Theme.Warning}
    local n = Create("Frame", {Parent = self.ScreenGui, BackgroundColor3 = self.Theme.ElementBg, Position = UDim2.new(1, 20, 1, -80), Size = UDim2.new(0, 280, 0, 70), ZIndex = 100})
    Corner(n, 8)
    Create("Frame", {Parent = n, BackgroundColor3 = colors[t], Size = UDim2.new(0, 4, 1, 0)}).CornerRadius = UDim.new(0, 8)
    Create("TextLabel", {Parent = n, BackgroundTransparency = 1, Position = UDim2.new(0, 16, 0, 10), Size = UDim2.new(1, -32, 0, 20),
        Font = Enum.Font.GothamBold, Text = title, TextColor3 = self.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
    Create("TextLabel", {Parent = n, BackgroundTransparency = 1, Position = UDim2.new(0, 16, 0, 32), Size = UDim2.new(1, -32, 0, 30),
        Font = Enum.Font.Gotham, Text = msg, TextColor3 = self.Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
    Tween(n, {Position = UDim2.new(1, -300, 1, -80)}, 0.4)
    task.delay(dur, function() Tween(n, {Position = UDim2.new(1, 20, 1, -80)}, 0.4).Completed:Wait(); n:Destroy() end)
end

function smallUI:Destroy()
    if self.ScreenGui then self.ScreenGui:Destroy() end
    table.clear(self)
end

return smallUI
