# Roblox Turn Based Combat Game Prototype (Combat Scripts)
CharacterModule.lua: example character module script containing character stats, functions to perform character skills, and animation IDs and descriptions for each skill

DamageCalculation.lua: module script that computes total damage dealt by attacks when attack function is called; incorporates innate skill damage variance multipler, skill specific damage multipler, critical chance and multipler, and class interaction multipler

DamagePopUpScipt.lua: server script executed when damage pop-up billboard GUI element is cloned and added to display damage of attacks, numbers pop up and fall with size and text color indicating crits and class interaction respectively

HealthBarMisc.lua: module script containing aesthetics for character health bars; includes predefined ID's to class icons and predefined color codes

HealthBarScript.lua: server script that continuously updates billboard GUI health bars for enemies, contains functions to create shrinking and growing effect when sustaining damage or receiving healing, contains functions to change health bar color when character health falls below 1/3 of max

RotatingCrosshairScript.lua: server script that continuously rotates player targeting billboard GUI crosshair

SkillSelectScript.lua: local script that receives skill data during a character's turn; displays skill name, description, and icon in skill buttons GUI; creates remote event for player selected skill

TurnBasedCombat.lua: module script that initiates combat by spawning player team and enemy team, and determining turn order; sends skill data for character to skill button GUI using remote events and awaits player skill selection before performing skills

TurnPointerScript.lua: server script that continuously shifts billboard GUI turn pointer indicator up and down
