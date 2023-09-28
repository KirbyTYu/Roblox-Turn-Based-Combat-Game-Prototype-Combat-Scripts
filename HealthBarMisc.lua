local healthBarMisc = {}

healthBarMisc.HealthBarColors = {
	healthy = {
		red = 16/255,
		green = 255/255,
		blue = 195/255
	},
	critical = {
		red = 150/255
	}
}

healthBarMisc.HealthBarChangeColors = {
	damaged = {
		red = 255/255,
		green = 191/255,
		blue = 62/255
	},
	healed = {
		green = 180/255
	}
}

healthBarMisc.ClassTypes = {
	Blaster = "rbxassetid://14619072888",
	Bruiser = "rbxassetid://14619080739",
	Fighter = "rbxassetid://14619082222",
	Infiltrator = "rbxassetid://14619083620",
	Tactician = "rbxassetid://14619085224",
	Generalist = "rbxassetid://14619087073"
}

return healthBarMisc
