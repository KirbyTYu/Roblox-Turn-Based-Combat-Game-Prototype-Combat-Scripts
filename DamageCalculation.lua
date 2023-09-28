local DamageCalculation = {}

function DamageCalculation.CreateDEFTable(targets) -- save def values from targets, specifically for multi hit skills
	local defTable = {}
	for index, member in ipairs(targets) do
		defTable[index] = require(targets[index].CharacterModule).Stats.DEF
	end
	return defTable
end

local damageMultiplierRange = .15 -- damage multiplier range for attack variance
function DamageCalculation.ApplyDamageRange(charATK)
	local minDamage = charATK * (1 - damageMultiplierRange)
	local maxDamage = charATK * (1 + damageMultiplierRange)
	return minDamage + (maxDamage - minDamage) * math.random() -- get value from (min <= baseATK <= max)
end

function DamageCalculation.CritChanceAndMultiplier(critRate, critDMG)
	local chance = tonumber(string.format("%.2f", math.random() + .01))
	if critRate >= chance or critRate >= 1 then -- crit chance success if greater than random value between 0 and 1
		return {success = true, multiplier = critDMG} -- apply character's crit multiplier on success
	elseif critRate < chance then
		return {success = false, multiplier = 1}
	end
end

local classes = {"Blaster", "Bruiser", "Fighter", "Infiltrator", "Tactician", "Generalist"}
local classInteractionMatrix = { -- matrix to sort class interaction
	{	0,	1,	0,	0,	-1,	0},	-- Blaster
	{	-1,	0,	1,	0,	0,	0},	-- Bruiser
	{	0,	-1,	0,	1,	0,	0},	-- Fighter
	{	0,	0,	-1,	0,	1,	0},	-- Infiltrator
	{	1,	0,	0,	-1,	0,	0},	-- Tactician
	{	0,	0,	0,	0,	0,	0}	-- Generalist
	-- Bl.	Br.	Fi.	In.	Ta.	Ge.
}
local neutralMultiplier = 1 -- damage multipliers for class interaction
local advantageMultiplier = 1.25
local disadvantageMultiplier = .75
function DamageCalculation.DetermineInteraction(attacker, target)
	local attackerClass = require(attacker.CharacterModule).Stats.Class
	local targetClass = require(target.CharacterModule).Stats.Class

	local attackerClassIndex
	local targetClassIndex

	for index, class in ipairs(classes) do -- determine class index for matrix lookup
		if class == attackerClass then
			attackerClassIndex = index
		end
		if class == targetClass then
			targetClassIndex = index
		end
	end

	local classInteractionLookUp = classInteractionMatrix[attackerClassIndex][targetClassIndex] -- determine multiplier from matrix
	local classInteraction
	if classInteractionLookUp == 0 then
		classInteraction = {interaction = "neutral", multiplier = neutralMultiplier}
	elseif classInteractionLookUp == 1 then
		classInteraction = {interaction = "advantage", multiplier = advantageMultiplier}
	elseif classInteractionLookUp == -1 then
		classInteraction = {interaction = "disadvantage", multiplier = disadvantageMultiplier}
	end

	return classInteraction
end

function DamageCalculation.DEFCalculation(damage, def, index) -- return damage subtracted by def
	local damageAbsorbed = def[index]
	def[index] = math.max(damageAbsorbed - damage, 0) -- update def table if necessary
	return math.max(damage - damageAbsorbed, 0) -- 0 damage with minimum
end

function DamageCalculation.NewDamagePopUp(damage, critical, classInteraction, target) -- add new popup to target
	local damageIndicator = game.ServerStorage.DamagePopUp:Clone()
	damageIndicator.Parent = target.HumanoidRootPart
	
	local advantageRed = 255/255 -- gold text for class advantage
	local advantageGreen = 220/255
	local advantageBlue = 100/255

	local disadvantageAll = 150/255 -- gray text for class disadvantage
	
	local damageNumber = damageIndicator.DamageNumber
	damageNumber.Text = damage -- update damage number
	
	if critical == true then -- update damage text size for crits
		damageNumber.Size = UDim2.new(1, 0, 1, 0)
	elseif critical == false then
		damageNumber.Size = UDim2.new(.35, 0, .35, 0)
	end
	
	if classInteraction == "neutral" then -- update damage text color for class interaction
		damageNumber.TextColor3 = Color3.new(1, 1, 1)
	elseif classInteraction == "advantage" then
		damageNumber.TextColor3 = Color3.new(advantageRed, advantageGreen, advantageBlue)
	elseif classInteraction == "disadvantage" then
		damageNumber.TextColor3 = Color3.new(disadvantageAll, disadvantageAll, disadvantageAll)
	end
end

function DamageCalculation.Attack(attacker, target, damageMultiplier, defModifier, defIndex)
	local attackerModule = require(attacker.CharacterModule)
	local targetModule = require(target.CharacterModule)
	
	if damageMultiplier == nil then -- default arguments
		damageMultiplier = 1
	end
	if defModifier == nil then
		defModifier = {}
		defModifier[1] = targetModule.Stats.DEF
		defIndex = 1
	end
	
	local baseDamage = DamageCalculation.ApplyDamageRange(attackerModule.Stats.ATK) -- calculate damage from multipliers
	local critical = DamageCalculation.CritChanceAndMultiplier(attackerModule.Stats.CritRate, attackerModule.Stats.CritDMG)
	local classInteraction = DamageCalculation.DetermineInteraction(attacker, target)
	
	local rawDamage = math.round(baseDamage * damageMultiplier * critical.multiplier * classInteraction.multiplier)
	local totalDamageDealt = rawDamage --DamageCalculation.DEFCalculation(rawDamage, defModifier, defIndex) -- include DEF
	targetModule.Stats.HP = math.max(targetModule.Stats.HP - totalDamageDealt, 0)
	
	DamageCalculation.NewDamagePopUp(totalDamageDealt, critical.success, classInteraction.interaction, target) -- spawn popup on target
end

return DamageCalculation
