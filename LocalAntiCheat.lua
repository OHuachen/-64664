-- Roblox 本地端全套反作弊 | 带开关+状态指示灯（绿开/红关）
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================== 防御总配置 ====================
local Settings = {
    AllDefense = true,       -- 总开关
    AntiESP = true,          -- 反透视
    AntiKnockback = true,    -- 防甩飞击退
    LimitSpeed = true,       -- 限制超速飞天
    DangerWarning = true     -- 外挂预警弹窗
}
local Character, Humanoid, RootPart
local OriginalTransparency = {}

--==================== 创建UI界面 ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LocalAntiCheatUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- 主窗口框架
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 180)
MainFrame.Position = UDim2.new(0.02,0,0.1,0)
MainFrame.BackgroundColor3 = Color3.new(0.12,0.12,0.14)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.new(0.3,0.3,0.35)
MainFrame.Parent = ScreenGui

-- 标题
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundTransparency = 1
Title.Text = "本地防御系统"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.new(1,1,1)
Title.Parent = MainFrame

-- 总开关文本
local SwitchText = Instance.new("TextLabel")
SwitchText.Size = UDim2.new(0,160,0,32)
SwitchText.Position = UDim2.new(0,15,0,40)
SwitchText.BackgroundTransparency = 1
SwitchText.Text = "全部防御功能"
Title.Font = Enum.Font.Gotham
Title.TextSize = 14
Title.TextColor3 = Color3.new(0.9,0.9,0.9)
SwitchText.Parent = MainFrame

-- 状态圆点（核心：绿点开启 / 红点关闭）
local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0,14,0,14)
StatusDot.Position = UDim2.new(0,180,0,49)
StatusDot.BorderSizePixel = 1
StatusDot.BorderColor3 = Color3.new(1,1,1)
StatusDot.BackgroundColor3 = Settings.AllDefense and Color3.new(0,0.8,0) or Color3.new(0.8,0,0)
StatusDot.CornerRadius = UDim.new(0.5,0)
StatusDot.Parent = MainFrame

-- 点击开关按钮
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0,50,0,26)
ToggleBtn.Position = UDim2.new(0,175,0,42)
ToggleBtn.BackgroundColor3 = Color3.new(0.2,0.2,0.22)
ToggleBtn.BorderSizePixel = 1
ToggleBtn.BorderColor3 = Color3.new(0.4,0.4,0.45)
ToggleBtn.Text = Settings.AllDefense and "关闭" or "开启"
ToggleBtn.Font = Enum.Font.Gotham
ToggleBtn.TextSize = 12
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Parent = MainFrame

-- 预警提示文字
local WarnText = Instance.new("TextLabel")
WarnText.Size = UDim2.new(0,220,0,28)
WarnText.Position = UDim2.new(0,10,0,90)
WarnText.BackgroundTransparency = 1
WarnText.Text = "无外挂威胁"
WarnText.Font = Enum.Font.Gotham
WarnText.TextSize = 13
WarnText.TextColor3 = Color3.new(0,1,0)
WarnText.Parent = MainFrame

--==================== UI切换逻辑 ====================
local function UpdateUIStyle()
    if Settings.AllDefense then
        StatusDot.BackgroundColor3 = Color3.new(0,0.8,0) -- 绿色=开启
        ToggleBtn.Text = "关闭"
    else
        StatusDot.BackgroundColor3 = Color3.new(0.8,0,0) -- 红色=关闭
        ToggleBtn.Text = "开启"
    end
end

-- 按钮点击切换总开关
ToggleBtn.MouseButton1Click:Connect(function()
    Settings.AllDefense = not Settings.AllDefense
    UpdateUIStyle()
end)

--==================== 角色刷新初始化 ====================
local function InitCharacter(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
    task.wait(0.2)
    OriginalTransparency = {}
    for _,part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            OriginalTransparency[part] = part.Transparency
        end
    end
end
LocalPlayer.CharacterAdded:Connect(InitCharacter)
if LocalPlayer.Character then InitCharacter(LocalPlayer.Character) end

--==================== 核心防御循环 ====================
RunService.RenderStepped:Connect(function()
    if not Settings.AllDefense or not Character or Humanoid.Health <= 0 then
        WarnText.Text = "防御已关闭"
        WarnText.TextColor3 = Color3.new(1,0,0)
        return
    end
    WarnText.Text = "无外挂威胁"
    WarnText.TextColor3 = Color3.new(0,1,0)

    -- 1. 反透视ESP：强制还原自身零件透明度
    if Settings.AntiESP then
        for part,oriTrans in pairs(OriginalTransparency) do
            if part:IsDescendantOf(Character) then
                if part.Transparency ~= oriTrans or part.LocalTransparencyModifier ~= 0 then
                    part.Transparency = oriTrans
                    part.LocalTransparencyModifier = 0
                end
            end
        end
    end

    -- 2. 防甩飞/击退冲击
    if Settings.AntiKnockback then
        local moveDir = Humanoid.MoveDirection
        local vel = RootPart.AssemblyLinearVelocity
        local safeY = vel.Y
        if moveDir.Magnitude > 0 then
            RootPart.AssemblyLinearVelocity = Vector3.new(moveDir.X * Humanoid.WalkSpeed, safeY, moveDir.Z * Humanoid.WalkSpeed)
        else
            RootPart.AssemblyLinearVelocity = Vector3.new(0, safeY, 0)
        end
        RootPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
    end

    -- 3. 限制超速、飞天
    if Settings.LimitSpeed then
        local speed = RootPart.AssemblyLinearVelocity.Magnitude
        if speed > 42 then
            RootPart.AssemblyLinearVelocity *= Vector3.new(0.28,1,0.28)
        end
    end

    -- 4. 扫描敌人预警自瞄/追踪子弹
    if Settings.DangerWarning then
        local dangerDetect = false
        -- 检测敌方玩家锁定
        for _,player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then continue end
            local enemyChar = player.Character
            if not enemyChar then continue end
            local enemyHRP = enemyChar:FindFirstChild("HumanoidRootPart")
            if not enemyHRP then continue end

            local aimToMe = (RootPart.Position - enemyHRP.Position).Unit
            local enemyLook = enemyHRP.CFrame.LookVector
            local angle = math.deg(math.acos(math.clamp(enemyLook:Dot(aimToMe), -1, 1)))
            local dist = (RootPart.Position - enemyHRP.Position).Magnitude
            if angle < 16 and dist < 75 then
                dangerDetect = true
                break
            end
        end
        -- 检测高速追踪子弹
        for _,part in ipairs(workspace:GetPartsInRange(RootPart.Position, 38)) do
            local bulletVel = part.AssemblyLinearVelocity.Magnitude
            if bulletVel > 72 and part.Size.Z > 0.45 then
                local bulletToMe = (RootPart.Position - part.Position).Unit
                local bulletDir = part.AssemblyLinearVelocity.Unit
                local angle = math.deg(math.acos(math.clamp(bulletDir:Dot(bulletToMe), -1, 1)))
                if angle < 24 then
                    dangerDetect = true
                    break
                end
            end
        end
        if dangerDetect then
            WarnText.Text = "⚠️ 检测敌方外挂锁定！找掩体！"
            WarnText.TextColor3 = Color3.new(1,0,0)
        end
    end
end)
