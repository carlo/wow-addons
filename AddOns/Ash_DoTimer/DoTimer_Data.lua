function DoTimer:DefineSpells(class)
	local spells,localedata
	if class == "WARLOCK" then
		spells = {
			["Howl of Terror"] = 1,
			["Shadowfury"] = 1,
		}
		localedata = {
			["Interface\\Icons\\Spell_Shadow_DeathScream"] = {
				["name"] = "Howl of Terror",
				["duration"] = 8,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Spell_Shadow_Shadowfury"] = {
				["name"] = "Shadowfury",
				["duration"] = 2,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Spell_Shadow_Possession"] = {
				["name"] = "Fear",
				["duration"] = 15,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Spell_Shadow_MindSteal"] = {
				["name"] = "Seduction",
				["duration"] = 15,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Spell_Shadow_Cripple"] = {
				["name"] = "Banish",
				["duration"] = 20,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Spell_Shadow_EnslaveDemon"] = {
				["name"] = "Enslave Demon",
			},
		}
	elseif class == "DRUID" then
		spells = {
			["Demoralizing Roar"] = 1,
			["Challenging Roar"] = 1,
			["Force of Nature"] = 1,
		}
		localedata = {
			["Interface\\Icons\\Ability_Druid_ForceofNature"] = {
				["name"] = "Force of Nature",
				["duration"] = 30,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Ability_Druid_ChallangingRoar"] = {
				["name"] = "Challenging Roar",
				["duration"] = 6,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Ability_Druid_DemoralizingRoar"] = {
				["name"] = "Demoralizing Roar",
				["duration"] = 30,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Spell_Nature_Sleep"] = {
				["name"] = "Hibernate",  
				["duration"] = 20,
				["multiplier"] = 1,
			},
		}
	elseif class == "PRIEST" then
		spells = {
			["Psychic Scream"] = 1,
			["Shadowfiend"] = 1,
		}
		localedata = {
			["Interface\\Icons\\Spell_Shadow_PsychicScream"] = {
				["name"] = "Psychic Scream",  
				["duration"] = 8,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Spell_Holy_PowerWordShield"] = {
				["name"] = "Power Word: Shield",  
				["duration"] = 15,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Spell_Shadow_Shadowfiend"] = {
				["name"] = "Shadowfiend",
				["duration"] = 15,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Spell_Holy_PrayerOfMendingtga"] = {
				["name"] = "Prayer of Mending",
				["duration"] = 30,
				["multiplier"] = 1,
			},
		}
	elseif class == "HUNTER" then
		spells = {
			["Flare"] = 1,
			["Freezing Trap"] = 1,
			["Immolation Trap"] = 1,
			["Explosive Trap"] = 1,
			["Frost Trap"] = 1,
			["Snake Trap"] = 1,
		}
		localedata = {
			["Interface\\Icons\\Spell_Frost_ChainsOfIce"] = {
				["name"] = "Freezing Trap",
				["duration"] = 1,
				["multiplier"] = 60,
				["group"] = 6,
			},
			["Interface\\Icons\\Spell_Frost_FreezingBreath"] = {
				["name"] = "Frost Trap",
				["duration"] = 1,
				["multiplier"] = 60,
				["group"] = 6,
			},
			["Interface\\Icons\\Spell_Fire_FlameShock"] = {
				["name"] = "Immolation Trap",
				["duration"] = 1,
				["multiplier"] = 60,
				["group"] = 6,
			},
			["Interface\\Icons\\Ability_Hunter_SnakeTrap"] = {
				["name"] = "Snake Trap",
				["duration"] = 1,
				["multiplier"] = 60,
			},
			["Interface\\Icons\\Spell_Fire_SelfDestruct"] = {
				["name"] = "Explosive Trap",
				["duration"] = 1,
				["multiplier"] = 60,
				["group"] = 6,
			},
			["Interface\\Icons\\Spell_Fire_Flare"] = {
				["name"] = "Flare",
				["duration"] = 30,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Ability_Hunter_SniperShot"] = {
				["name"] = "Hunter's Mark",
				["duration"] = 2,
				["multiplier"] = 60,
			},
		}
	elseif class == "MAGE" then
		spells = {
			["Blast Wave"] = 1,
			["Cone of Cold"] = 1,
			["Frost Nova"] = 1,
			["Summon Water Elemental"] = 1,
			["Dragon's Breath"] = 1,
		}
		localedata = {
			["Interface\\Icons\\INV_Misc_Head_Dragon_01"] = {
				["name"] = "Dragon's Breath",
				["duration"] = 3,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Spell_Frost_SummonWaterElemental_2"] = {
				["name"] = "Summon Water Elemental",
				["duration"] = 45, 
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Spell_Frost_FrostNova"] = {
				["name"] = "Frost Nova",
				["duration"] = 8,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Spell_Frost_IceShock"] = {
				["name"] = "Counterspell",
				["duration"] = 10,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Spell_Frost_Glacier"] = {
				["name"] = "Cone of Cold",
				["duration"] = 8,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Spell_Holy_Excorcism_02"] = {
				["name"] = "Blast Wave",
				["duration"] = 6,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Spell_Nature_Polymorph"] = {
				["name"] = "Polymorph",
				["duration"] = 50,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Spell_Magic_PolymorphPig"] = {
				["name"] = "Polymorph",
				["duration"] = 50,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Ability_Hunter_Pet_Turtle"] = {
				["name"] = "Polymorph",
				["duration"] = 50,
				["multiplier"] = 1,
			},
		}
	elseif class == "WARRIOR" then
		spells = {
			["Challenging Shout"] = 1,
			["Demoralizing Shout"] = 1,
			["Thunder Clap"] = 1,
			["Intimidating Shout"] = 1,
			["Piercing Howl"] = 1,
		}
		localedata = {
			["Interface\\Icons\\Ability_BullRush"] = {
				["name"] = "Challenging Shout",
				["duration"] = 6,
				["multiplier"] = 1,
				["group"] = 10,
			},
			["Interface\\Icons\\Spell_Shadow_DeathScream"] = {
				["name"] = "Piercing Howl",
				["duration"] = 6,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Ability_Warrior_WarCry"] = {
				["name"] = "Demoralizing Shout",
				["duration"] = 35,
				["multiplier"] = 1,
				["group"] = 10,
			},
			["Interface\\Icons\\Ability_GolemThunderClap"] = {
				["name"] = "Intimidating Shout",
				["duration"] = 8,
				["multiplier"] = 1,
				["group"] = 10,
			},
			["Interface\\Icons\\INV_Gauntlets_04"] = {
				["name"] = "Pummel",
				["duration"] = 4,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Ability_Warrior_ShieldBash"] = {
				["name"] = "Shield Bash",
				["duration"] = 6,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Spell_Nature_ThunderClap"] = {
				["name"] = "Thunder Clap",
				["duration"] = 18,
				["multiplier"] = 1,
			},
		}	
	elseif class == "ROGUE" then
		spells = {
			["Distract"] = 1,
		}
		localedata = {
			["Interface\\Icons\\Ability_Rogue_Distract"] = {
				["name"] = "Distract",
				["duration"] = 10,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Ability_Kick"] = {
				["name"] = "Kick",
				["duration"] = 5,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Ability_Sap"] = {
				["name"] = "Sap",
				["duration"] = 40,
				["multiplier"] = 1,
			},
		}	
	elseif class == "SHAMAN" then
		spells = {
			["Earthbind Totem"] = 1,
			["Stoneskin Totem"] = 1,
			["Stoneclaw Totem"] = 1,
			["Strength of Earth Totem"] = 1,
			["Earth Elemental Totem"] = 1,
			["Tremor Totem"] = 1,
			["Searing Totem"] = 1,
			["Fire Nova Totem"] = 1,
			["Magma Totem"] = 1,
			["Frost Resistance Totem"] = 1,
			["Flametongue Totem"] = 1,
			["Fire Elemental Totem"] = 1,
			["Totem of Wrath"] = 1,
			["Healing Stream Totem"] = 1,
			["Mana Spring Totem"] = 1,
			["Poison Cleansing Totem"] = 1,
			["Disease Cleansing Totem"] = 1,
			["Mana Tide Totem"] = 1,
			["Fire Resistance Totem"] = 1,
			["Grace of Air Totem"] = 1,
			["Windfury Totem"] = 1,
			["Grounding Totem"] = 1,
			["Windwall Totem"] = 1,
			["Sentry Totem"] = 1,
			["Nature Resistance Totem"] = 1,
			["Tranquil Air Totem"] = 1,
			["Wrath of Air Totem"] = 1,
		}
		localedata = {
			["Interface\\Icons\\Spell_Nature_StrengthOfEarthTotem02"] = {
				["name"] = "Earthbind Totem",
				["duration"] = 45,
				["multiplier"] = 1,
				["group"] = 2,
			},
			["Interface\\Icons\\Spell_Nature_StoneSkinTotem"] = {
				["name"] = "Stoneskin Totem",
				["duration"] = 2,
				["multiplier"] = 60,
				["group"] = 2,
			},
			["Interface\\Icons\\Spell_Nature_StoneClawTotem"] = {
				["name"] = "Stoneclaw Totem",
				["duration"] = 15,
				["multiplier"] = 1,
				["group"] = 2,
			},
			["Interface\\Icons\\Spell_Nature_EarthBindTotem"] = {
				["name"] = "Strength of Earth Totem",
				["duration"] = 2,
				["multiplier"] = 60,
				["group"] = 2,
			},
			["Interface\\Icons\\Spell_Nature_EarthElemental_Totem"] = {
				["name"] = "Earth Elemental Totem",
				["duration"] = 2,
				["multiplier"] = 60,
				["group"] = 2,
			},
			["Interface\\Icons\\Spell_Nature_TremorTotem"] = {
				["name"] = "Tremor Totem",
				["duration"] = 2,
				["multiplier"] = 60,
				["group"] = 2,
			},
			["Interface\\Icons\\Spell_Fire_SearingTotem"] = {
				["name"] = "Searing Totem",
				["duration"] = 55,
				["multiplier"] = 1,
				["group"] = 3,
			},
			["Interface\\Icons\\Spell_Fire_SealOfFire"] = {
				["name"] = "Fire Nova Totem",
				["duration"] = 5,
				["multiplier"] = 1,
				["group"] = 3,
			},
			["Interface\\Icons\\Spell_Fire_SelfDestruct"] = {
				["name"] = "Magma Totem",
				["duration"] = 20,
				["multiplier"] = 1,
				["group"] = 3,
			},
			["Interface\\Icons\\Spell_FrostResistanceTotem_01"] = {
				["name"] = "Frost Resistance Totem",
				["duration"] = 2,
				["multiplier"] = 60,
				["group"] = 3,
			},
			["Interface\\Icons\\Spell_Nature_GuardianWard"] = {
				["name"] = "Flametongue Totem",
				["duration"] = 2,
				["multiplier"] = 60,
				["group"] = 3,
			},
			["Interface\\Icons\\Spell_Fire_Elemental_Totem"] = {
				["name"] = "Fire Elemental Totem",
				["duration"] = 2,
				["multiplier"] = 60,
				["group"] = 3,
			},
			["Interface\\Icons\\Spell_Fire_TotemOfWrath"] = {
				["name"] = "Totem of Wrath",
				["duration"] = 2,
				["multiplier"] = 60,
				["group"] = 3,
			},
			["Interface\\Icons\\INV_Spear_04"] = {
				["name"] = "Healing Stream Totem",
				["duration"] = 1,
				["multiplier"] = 60,
				["group"] = 4,
			},
			["Interface\\Icons\\Spell_Nature_ManaRegenTotem"] = {
				["name"] = "Mana Spring Totem",
				["duration"] = 1,
				["multiplier"] = 60,
				["group"] = 4,
			},
			["Interface\\Icons\\Spell_Nature_PoisonCleansingTotem"] = {
				["name"] = "Poison Cleansing Totem",
				["duration"] = 2,
				["multiplier"] = 60,
				["group"] = 4,
			},
			["Interface\\Icons\\Spell_Nature_DiseaseCleansingTotem"] = {
				["name"] = "Disease Cleansing Totem",
				["duration"] = 2,
				["multiplier"] = 60,
				["group"] = 4,
			},
			["Interface\\Icons\\Spell_Frost_SummonWaterElemental"] = {
				["name"] = "Mana Tide Totem",
				["duration"] = 12,
				["multiplier"] = 1,
				["group"] = 4,
			},
			["Interface\\Icons\\Spell_FireResistanceTotem_01"] = {
				["name"] = "Fire Resistance Totem",
				["duration"] = 2,
				["multiplier"] = 60,
				["group"] = 4,
			},
			["Interface\\Icons\\Spell_Nature_InvisibilityTotem"] = {
				["name"] = "Grace of Air Totem",
				["duration"] = 2,
				["multiplier"] = 60,
				["group"] = 5,
			},
			["Interface\\Icons\\Spell_Nature_Windfury"] = {
				["name"] = "Windfury Totem",
				["duration"] = 2,
				["multiplier"] = 60,
				["group"] = 5,
			},
			["Interface\\Icons\\Spell_Nature_GroundingTotem"] = {
				["name"] = "Grounding Totem",
				["duration"] = 45,
				["multiplier"] = 1,
				["group"] = 5,
			},
			["Interface\\Icons\\Spell_Nature_EarthBind"] = {
				["name"] = "Windwall Totem",
				["duration"] = 2,
				["multiplier"] = 60,
				["group"] = 5,
			},
			["Interface\\Icons\\Spell_Nature_RemoveCurse"] = {
				["name"] = "Sentry Totem",
				["duration"] = 5,
				["multiplier"] = 60,
				["group"] = 5,
			},
			["Interface\\Icons\\Spell_Nature_NatureResistanceTotem"] = {
				["name"] = "Nature Resistance Totem",
				["duration"] = 2,
				["multiplier"] = 60,
				["group"] = 5,
			},
			["Interface\\Icons\\Spell_Nature_Brilliance"] = {
				["name"] = "Tranquil Air Totem",
				["duration"] = 2,
				["multiplier"] = 60,
				["group"] = 5,
			},
			["Interface\\Icons\\Spell_Nature_SlowingTotem"] = {
				["name"] = "Wrath of Air Totem",
				["duration"] = 2,
				["multiplier"] = 60,
				["group"] = 5,
			},
			["Interface\\Icons\\Spell_Nature_EarthShock"] = {
				["name"] = "Earth Shock",
				["duration"] = 2,
				["multiplier"] = 1,
			},
			["Interface\\Icons\\Spell_unused"] = {
				["name"] = "Totemic Call",
			},
		}	
	elseif class == "PALADIN" then
		spells = {
			["Consecration"] = 1,
		}
		localedata = {
			["Interface\\Icons\\Spell_Holy_InnerFire"] = {
				["name"] = "Consecration",
				["duration"] = 8,
				["multiplier"] = 1,
			},
		}	
	end
	spells["War Stomp"] = 1
	localedata["Interface\\Icons\\Ability_WarStomp"] = {
		["name"] = "War Stomp",
		["duration"] = 2,
		["multiplier"] = 1,
	}
	return spells,localedata
end

DoTimer:CreateTimerGroup(
	"debuff",true,true,true,true,1,1,{
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
DoTimer:CreateTimerGroup(
	"buff",true,true,true,true,1,1,{
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
DoTimer:CreateTimerGroup(
	"notarget",true,true,true,true,1,1,{
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
