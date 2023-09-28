local runService = game:GetService("RunService")

local turnPointer = script.Parent

runService.Heartbeat:Connect(function()
	local currentTime = tick()
	local oscillatingValue = math.sin(currentTime * 10) * .05
	turnPointer.StudsOffset = Vector3.new(0, turnPointer.StudsOffset.Y + oscillatingValue, 0)
end)