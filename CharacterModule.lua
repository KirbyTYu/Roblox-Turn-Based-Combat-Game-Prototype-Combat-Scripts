local damageCalculation = require(game.Workspace.Modules.DamageCalculation)
local statusEffects = require(game.Workspace.Modules.StatusEffects)

local tweenService = game:GetService("TweenService")
local tween

local CharacterModule = {}

CharacterModule.Stats = {
	Name = "MIB Agent",
	Class = "Blaster",
	Level = 10,
	HP = 900,
	MaxHP = 900,
	ATK = 150,
	DEF = 20,
	CritRate = .1,
	CritDMG = 1.5,
	Speed = 15
}

local skillAnimation = Instance.new("Animation")
local skillTrack = nil

function CharacterModule.Idle(char)
	local idleAnimation = Instance.new("Animation")
	idleAnimation.AnimationId = "rbxassetid://14357145124"
	local idleTrack = char.Humanoid:LoadAnimation(idleAnimation)
	idleTrack:Play()
end

function CharacterModule.PreciseShot(char, data)
	skillAnimation.AnimationId = "rbxassetid://14256945432"
	skillTrack = char.Humanoid:LoadAnimation(skillAnimation)
	skillTrack:Play()
	
	local originalCFrame = char.HumanoidRootPart.CFrame
	tween = tweenService:Create(char.HumanoidRootPart, TweenInfo.new(.25), {CFrame = CFrame.new(char.HumanoidRootPart.Position, data.target.HumanoidRootPart.Position)})
	tween:Play()

	skillTrack:GetMarkerReachedSignal("Shot"):Connect(function()
		local soundEffect = Instance.new("Sound", char.Pistol.Pistol)
		soundEffect.SoundId = "rbxassetid://14265564384"
		soundEffect.RollOffMaxDistance = 100
		soundEffect:Play()
		
		damageCalculation.Attack(char, data.target)

		soundEffect.Ended:Connect(function()
			soundEffect:Destroy()
		end)

		skillTrack:GetMarkerReachedSignal("End"):Connect(function()
			tween = tweenService:Create(char.HumanoidRootPart, TweenInfo.new(.25), {CFrame = originalCFrame})
			tween:Play()
		end)
	end)
end

function CharacterModule.EmptyMagazine(char, data)
	skillAnimation.AnimationId = "rbxassetid://14308889084"
	skillTrack = char.Humanoid:LoadAnimation(skillAnimation)
	skillTrack:Play()
	
	local defValues = damageCalculation.CreateDEFTable(data.enemyTeam)
	
	skillTrack:GetMarkerReachedSignal("Shot"):Connect(function()
		local soundEffect = Instance.new("Sound", char.Pistol.Pistol)
		soundEffect.SoundId = "rbxassetid://14265564384"
		soundEffect.RollOffMaxDistance = 100
		soundEffect:Play()

		for index, member in ipairs(data.enemyTeam) do
			damageCalculation.Attack(char, member, .2, defValues, index)
		end

		soundEffect.Ended:Connect(function()
			soundEffect:Destroy()
		end)
	end)

	skillTrack:GetMarkerReachedSignal("Miss"):Connect(function()
		local soundEffect = Instance.new("Sound", char.Pistol.Pistol)
		soundEffect.SoundId = "rbxassetid://14265564384"
		soundEffect.RollOffMaxDistance = 100
		soundEffect:Play()

		soundEffect.Ended:Connect(function()
			soundEffect:Destroy()
		end)
	end)

	skillTrack:GetMarkerReachedSignal("Reload"):Connect(function()
		local soundEffect = Instance.new("Sound", char.Pistol.Pistol)
		soundEffect.SoundId = "rbxassetid://14309019325"
		soundEffect.RollOffMaxDistance = 100
		soundEffect:Play()

		soundEffect.Ended:Connect(function()
			soundEffect:Destroy()
		end)
	end)
end

CharacterModule.Skills = {
	idle = CharacterModule.Idle,
	basic = CharacterModule.PreciseShot,
	special = CharacterModule.EmptyMagazine
}

CharacterModule.Data = {
	basic = {
		name = "Precise Shot",
		description = "Perform a careful, well-aimed shot at one target.",
		image = "rbxassetid://14537010626"
	},
	special = {
		name = "Empty Magazine",
		description = "Empty your magazine upon all enemies.",
		image = "rbxassetid://14537010697"
	}
}

return CharacterModule
