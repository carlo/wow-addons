function Cooldowns:DefineSpells()
	local othercooldowns = {
		["Interface\\Icons\\INV_Misc_Orb_04"] = { --soulstones
			["name"] = "Soulstone",
			["duration"] = 1800,
		},
		["Interface\\Icons\\INV_Stone_04"] = { --healthstones
			["name"] = "Healthstone",
			["duration"] = 120,
		},	
	}
	return othercooldowns
end

Cooldowns:CreateTimerGroup(
	"cooldown",true,true,true,true,1,1,{
		begin = {
			r = .2,
			g = 1.0,
			b = .2,
		},
		half = {
			r = 1.0,
			g = 1.0,
			b = .2,
		},
		final = {
			r = 1.0,
			g = .2,
			b = .2,
		},
	}
)
