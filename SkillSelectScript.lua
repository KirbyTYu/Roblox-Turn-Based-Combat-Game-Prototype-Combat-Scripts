local UserInputService = game:GetService("UserInputService")

-- requires skill selected and target selected to perform skill
local skillSelected = nil
local enemySelected = nil

-- contains data for skills for current character
local skillData

-- get skill icon gui objects
local skillGuiParent = script.Parent
local basicIcon = skillGuiParent.SkillIcons.Basic
local specialIcon = skillGuiParent.SkillIcons.Special
local ultimateIcon = skillGuiParent.SkillIcons.Ultimate
local iconList = {basicIcon, specialIcon, ultimateIcon}
local skillDescription = skillGuiParent.SkillDescription -- display skill descriptions

function showIcons()
	for index, icon in ipairs(iconList) do
		if icon.Image ~= "" then
			icon.Visible = true
		end
	end
end

function hideIcons()
	for index, icon in ipairs(iconList) do
		icon.Visible = false
	end
	skillDescription.Visible = false
end

-- update gui for current character turn
game.ReplicatedStorage.SendSkills.OnClientEvent:Connect(function(data)
	skillData = data
	basicIcon.Image = data.basic.image
	specialIcon.Image = data.special.image
	if data.ultimate then
		ultimateIcon.Image = data.ultimate.image
	end
	showIcons()
end)

basicIcon.MouseEnter:Connect(function()
	skillDescription.Text = "Basic Attack: " .. skillData.basic.name .. "\n" .. skillData.basic.description
	skillDescription.Visible = true
end)

basicIcon.MouseLeave:Connect(function()
	skillDescription.Visible = false
end)

specialIcon.MouseEnter:Connect(function()
	skillDescription.Text = "Special Attack: " .. skillData.special.name .. "\n" .. skillData.special.description
	skillDescription.Visible = true
end)

specialIcon.MouseLeave:Connect(function()
	skillDescription.Visible = false
end)

ultimateIcon.MouseEnter:Connect(function()
	skillDescription.Text = "Ultimate Attack: " .. skillData.ultimate.name .. "\n" .. skillData.ultimate.description
	skillDescription.Visible = true
end)

ultimateIcon.MouseLeave:Connect(function()
	skillDescription.Visible = false
end)



-- updates skill selected
basicIcon.MouseButton1Click:Connect(function()
	skillSelected = "basic"
	game.ReplicatedStorage.SkillSelected:FireServer(skillSelected)
	hideIcons()
end)

specialIcon.MouseButton1Click:Connect(function()
	skillSelected = "special"
	game.ReplicatedStorage.SkillSelected:FireServer(skillSelected)
	hideIcons()
end)

ultimateIcon.MouseButton1Click:Connect(function()
	skillSelected = "ultimate"
	game.ReplicatedStorage.SkillSelected:FireServer(skillSelected)
	hideIcons()
end)

-- updates current target
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		enemySelected = game.Players.LocalPlayer:GetMouse().Target.Parent
		game.ReplicatedStorage.TargetSelected:FireServer(enemySelected)
	end
end)

