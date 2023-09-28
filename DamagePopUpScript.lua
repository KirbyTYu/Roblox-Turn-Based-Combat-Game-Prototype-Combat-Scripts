local runService = game:GetService("RunService")

local damagePopUp = script.Parent

local frameDuration = 24
local xOffset = 3
local xOffsetIncrement = (-xOffset/frameDuration) + (xOffset/frameDuration - (-xOffset/frameDuration)) * math.random()
local yOffset = 0

function fadeAndDestroy()
	local tweenService = game:GetService("TweenService")
	local tween = tweenService:Create(damagePopUp.DamageNumber, TweenInfo.new(.5), {TextTransparency = 1, TextStrokeTransparency = 1})
	tween:Play()
	tween.Completed:Wait()
	damagePopUp:Destroy()
end

local finished = false
local speedReductionModifier = 5
local heightModifier = 2.5
local sinFunction = function(input) -- predefined sin function to determine arc
	return math.sin(input/speedReductionModifier) * heightModifier
end
local sinFunctionMinimum = 15 * math.pi / 2
runService.Heartbeat:Connect(function() -- move popup along arc every frame
	if finished == false  then
		damagePopUp.StudsOffset = Vector3.new(damagePopUp.StudsOffset.X + xOffsetIncrement, sinFunction(yOffset), 0)
		yOffset += sinFunctionMinimum / frameDuration
	end
	if sinFunction(yOffset) <= sinFunction(sinFunctionMinimum) and finished == false then -- stop at minimum value of sin function
		finished = true
		wait(1)
		fadeAndDestroy()
	end
end)
