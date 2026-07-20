loadstring([[
    local player = game.Players.LocalPlayer
    if not player then return end
    local PlayerGui = player:WaitForChild("PlayerGui")
    local RS = game:GetService("ReplicatedStorage")

    -- 修复：重复注入自动删除旧按钮，防止多个UI堆叠
    if PlayerGui:FindFirstChild("AttackButton") then
        PlayerGui.AttackButton:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AttackButton"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = UDim2.new(0, 20, 0, 180)
    btn.Text = "⚔️攻击"
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    btn.BorderSizePixel = 0
    btn.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = btn

    -- 新增：状态指示灯（绿=正常，红=找不到远程事件）
    local StatusDot = Instance.new("Frame")
    StatusDot.Size = UDim2.new(0, 12, 0, 12)
    StatusDot.Position = UDim2.new(1, -14, 0, 2)
    StatusDot.BorderSizePixel = 0
    StatusDot.BackgroundColor3 = Color3.new(0, 1, 0)
    local DotRound = Instance.new("UICorner")
    DotRound.CornerRadius = UDim.new(1, 0)
    DotRound.Parent = StatusDot
    StatusDot.Parent = btn

    -- 修复：拆分远程事件查找，代码更清晰
    local RemotesFolder = RS:FindFirstChild("Remotes")
    local AttacksFolder = RemotesFolder and RemotesFolder:FindFirstChild("Attacks")
    local event = AttacksFolder and AttacksFolder:FindFirstChild("BasicAttack")
    if not event then
        StatusDot.BackgroundColor3 = Color3.new(1, 0, 0)
    end

    btn.MouseButton1Click:Connect(function()
        -- 修复：检测角色和生命值，无角色/死亡不发包
        local char = player.Character
        if not char then
            warn("未加载角色，无法触发攻击")
            return
        end
        local Humanoid = char:FindFirstChildOfClass("Humanoid")
        if not Humanoid or Humanoid.Health <= 0 then
            warn("角色已死亡，无法触发攻击")
            return
        end

        if event then
            event:FireServer()
        else
            warn("BasicAttack 事件未找到")
        end
    end)

    -- 修复拖拽：增加屏幕边界，按钮不会拖出屏幕丢失
    local function drag(gui)
        local dragging, startPos, dragStart
        local camera = workspace.CurrentCamera

        gui.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = gui.Position
            end
        end)
        gui.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                local delta = input.Position - dragStart
                local newX = startPos.X.Offset + delta.X
                local newY = startPos.Y.Offset + delta.Y

                local viewSize = camera.ViewportSize
                local maxX = viewSize.X - gui.AbsoluteSize.X
                local maxY = viewSize.Y - gui.AbsoluteSize.Y
                newX = math.clamp(newX, 0, maxX)
                newY = math.clamp(newY, 0, maxY)

                gui.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
            end
        end)
        gui.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end
    drag(btn)

    print("✅ 攻击按钮已加载，点击触发 BasicAttack")
]])()
