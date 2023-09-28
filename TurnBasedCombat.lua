local turnBasedCombat = {}

local thisPlayer
game.ReplicatedStorage.GetThisPlayer.OnServerEvent:Connect(function(player)
	thisPlayer = player
end)

local playerTeamPositions = {
	Vector3.new(12.5, 3, 15),
	Vector3.new(12.5, 3, 5),
	Vector3.new(12.5, 3, -5),
	Vector3.new(12.5, 3, -15)
}

local enemyTeamPositions = {
	Vector3.new(-12.5, 3, -5),
	Vector3.new(-12.5, 3, 5),
	Vector3.new(-12.5, 3, -15),
	Vector3.new(-12.5, 3, 15)
}

local tempPlayerTeamLocation = game.ServerStorage.EnemyDatabase["Men In Black"]
turnBasedCombat.BattleInfo = {
	playerTeam = {tempPlayerTeamLocation["MIB Agent"]:Clone(), tempPlayerTeamLocation["MIB Agent"]:Clone(), tempPlayerTeamLocation["MIB Agent"]:Clone(), tempPlayerTeamLocation["MIB Agent"]:Clone()},
	enemyTeam = {},
	turnOrder = {},
	numParticipants = 0,
	currentOrderTracker = 1,
	target = nil
}



function turnBasedCombat.SpawnPlayerTeam()
	for currentPos = 1, #turnBasedCombat.BattleInfo.playerTeam, 1 do
		local currentChar = turnBasedCombat.BattleInfo.playerTeam[currentPos]
		currentChar.Parent = game.Workspace.PlayerTeam
		currentChar:MoveTo(playerTeamPositions[currentPos]) -- position character
		require(currentChar.CharacterModule).Skills["idle"](currentChar)
	end
	turnBasedCombat.BattleInfo.numParticipants += #turnBasedCombat.BattleInfo.playerTeam
end

function turnBasedCombat.SpawnEnemyTeam(enemyName)
	local enemyTypes = game:GetService("ServerStorage").EnemyDatabase[enemyName]:GetChildren() -- get enemy folder
	local numTypes = #enemyTypes
	local randNumEnemies = math.random(2, #enemyTeamPositions) -- random enemy count between 2-4
	for currentPos = 1, randNumEnemies, 1 do
		local enemyTypeVal = math.random(1, numTypes) -- randomize enemies
		local newEnemy = enemyTypes[enemyTypeVal]:Clone()
		newEnemy.Parent = game.Workspace.EnemyTeam
		newEnemy:MoveTo(enemyTeamPositions[currentPos]) -- position enemy
		local healthBarBillboardGui = game.ServerStorage.HealthBarBillboardGui:Clone() -- add healthbar
		healthBarBillboardGui.Parent = newEnemy.HumanoidRootPart
		--require(newEnemy.CharacterModule).Skills["idle"](newEnemy)
	end
	--turnBasedCombat.BattleInfo.numParticipants += randNumEnemies
end

function turnBasedCombat.DetermineOrder() -- sort turn order by speed algorithm
	turnBasedCombat.BattleInfo.playerTeam = game.Workspace.PlayerTeam:GetChildren()
	turnBasedCombat.BattleInfo.enemyTeam = game.Workspace.EnemyTeam:GetChildren()
	turnBasedCombat.BattleInfo.turnOrder = {table.unpack(turnBasedCombat.BattleInfo.playerTeam)}
	table.sort(turnBasedCombat.BattleInfo.turnOrder, function(char1, char2) return require(char1.CharacterModule).Stats.Speed > require(char2.CharacterModule).Stats.Speed end)
end

local turnPointer = game:GetService("ServerStorage").TurnPointer:Clone()
function turnBasedCombat.Turn() -- update skills for each turn
	if turnBasedCombat.BattleInfo.currentOrderTracker <= turnBasedCombat.BattleInfo.numParticipants then
		local currentChar = turnBasedCombat.BattleInfo.turnOrder[turnBasedCombat.BattleInfo.currentOrderTracker]
		game.ReplicatedStorage.SendSkills:FireClient(thisPlayer, require(currentChar.CharacterModule).Data) -- update skill icons with current character skills
		turnPointer.Parent = turnBasedCombat.BattleInfo.turnOrder[turnBasedCombat.BattleInfo.currentOrderTracker].HumanoidRootPart -- move turn pointer
	else
		turnBasedCombat.BattleInfo.currentOrderTracker = 1
		turnBasedCombat.Turn()
	end
end

local crosshair = game:GetService("ServerStorage").Crosshair:Clone()
function turnBasedCombat.Start(enemyName) -- run functions to start battle
	game.ReplicatedStorage.BattleTransitionStart:FireClient(thisPlayer, enemyName)
	turnBasedCombat.SpawnPlayerTeam()
	turnBasedCombat.SpawnEnemyTeam(enemyName)
	turnBasedCombat.DetermineOrder()
	turnBasedCombat.Turn()
	turnBasedCombat.BattleInfo.target = turnBasedCombat.BattleInfo.enemyTeam[1]
	crosshair.Parent = turnBasedCombat.BattleInfo.target.HumanoidRootPart
	game.ReplicatedStorage.SendTeamStats:FireClient(thisPlayer, turnBasedCombat.BattleInfo.playerTeam)
end



game.ReplicatedStorage.SkillSelected.OnServerEvent:Connect(function(player, skillSelected) -- receive event when skill selected
	local currentChar = turnBasedCombat.BattleInfo.turnOrder[turnBasedCombat.BattleInfo.currentOrderTracker]
	if #currentChar.Humanoid:GetPlayingAnimationTracks() >= 2 then
		print("redo")
	else
		require(currentChar.CharacterModule).Skills[skillSelected](currentChar, table.clone(turnBasedCombat.BattleInfo))
		turnBasedCombat.BattleInfo.currentOrderTracker += 1
	end
end)

game.ReplicatedStorage.TargetSelected.OnServerEvent:Connect(function(player, enemySelected) -- receive event when enemy selected
	local found = false
	for _, character in ipairs(turnBasedCombat.BattleInfo.enemyTeam) do
		if character == enemySelected then
			found = true
			break
		end
	end
	if found == true then -- change target
		turnBasedCombat.BattleInfo.target = enemySelected
		crosshair.Parent = turnBasedCombat.BattleInfo.target.HumanoidRootPart
	end
end)

return turnBasedCombat
