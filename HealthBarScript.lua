local runService = game:GetService("RunService")
local char = require(script.Parent.Parent.Parent.CharacterModule)
local HBMisc = require(game.Workspace.Modules.HealthBarMisc)
wait(.5)

-- health billboard gui elements
local healthBarBillboardGui = script.Parent
local healthBar = healthBarBillboardGui.HealthBar.CurrentHealth
local healthBarChange = healthBarBillboardGui.HealthBar.HealthChange
local healthCount = healthBarBillboardGui.HealthBar.HealthCount

local nameDisplay = healthBarBillboardGui.NameDisplay
nameDisplay.Text = char.Stats.Name

local classDisplay = healthBarBillboardGui.ClassDisplay.ClassIcon
classDisplay.Image = HBMisc.ClassTypes[char.Stats.Class]



-- global health values
local currentHealth
local currentHealthPercent
function updateHealthValues()
	currentHealth = math.min(math.max(char.Stats.HP, 0), char.Stats.MaxHP)
	currentHealthPercent = currentHealth/char.Stats.MaxHP
	healthCount.Text = currentHealth
end
updateHealthValues()



-- tween elements
local TweenService = game:GetService("TweenService")
local tweenHB
function tweenHealthBar(healthBarType)
	local targetSize = UDim2.new(currentHealthPercent,0,1,0)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	tweenHB = TweenService:Create(healthBarType, tweenInfo, {Size = targetSize})
	tweenHB:Play()
end

-- update healthbar every frame
runService.Heartbeat:Connect(function()
	-- check for healing/damage
	if (char.Stats.HP < currentHealth) then -- health is lower than in previous frame (damaged)
		updateHealthValues()
		
		local damaged = HBMisc.HealthBarChangeColors.damaged
		healthBarChange.BackgroundColor3 = Color3.new(damaged.red, damaged.green, damaged.blue)
		healthBar.Size = UDim2.new(currentHealthPercent,0,1,0)
		tweenHealthBar(healthBarChange)
	elseif (char.Stats.HP > currentHealth) then -- health is greater than in previous frame (healed)
		updateHealthValues()
		
		local healed = HBMisc.HealthBarChangeColors.healed
		healthBarChange.BackgroundColor3 = Color3.new(0, healed.green, 0)
		healthBarChange.Size = UDim2.new(currentHealthPercent,0,1,0)
		tweenHealthBar(healthBar)
	end

	-- critical health vs healthy conditionals
	if currentHealthPercent >= 1/3 then -- healthy
		local healthy = HBMisc.HealthBarColors.healthy
		healthBar.BackgroundColor3 = Color3.new(healthy.red, healthy.green, healthy.blue)
	elseif currentHealthPercent < 1/3 then -- critical health
		local critical = HBMisc.HealthBarColors.critical
		healthBar.BackgroundColor3 = Color3.new(critical.red, 0, 0)
	end
end)