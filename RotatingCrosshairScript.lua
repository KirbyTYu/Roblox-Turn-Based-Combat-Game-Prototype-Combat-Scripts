local runService = game:GetService("RunService")

local crosshair = script.Parent

runService.Heartbeat:Connect(function()
	local currentTime = tick()
	crosshair.Rotation = (currentTime % 360) * 50
end)
	
