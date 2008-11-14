local L = AceLibrary("AceLocale-2.2"):new("DrDamage")

DrDamage.PlayerAura = {}
DrDamage.TargetAura = {}
DrDamage.Consumables = {}

local function DrD_LoadAuras()
	local playerClass = select(2,UnitClass("player"))
	local playerHealer = (playerClass == "PRIEST") or (playerClass == "SHAMAN") or (playerClass == "PALADIN") or (playerClass == "DRUID")
	local playerCaster = (playerClass == "MAGE") or (playerClass == "PRIEST") or (playerClass == "WARLOCK")
	local playerMelee = (playerClass == "ROGUE") or (playerClass == "WARRIOR") or (playerClass == "HUNTER")
	local playerHybrid = (playerClass == "DEATH KNIGHT") or (playerClass == "DRUID") or (playerClass == "PALADIN") or (playerClass == "SHAMAN")	
	local Aura = DrDamage.PlayerAura
	local GetSpellInfo = GetSpellInfo
	local arcane, fire, frost, nature, shadow, holy
	
	if playerCaster or playerHybrid then
		arcane = (playerClass == "DRUID") or (playerClass == "MAGE")
		fire = (playerClass == "SHAMAN") or (playerClass == "WARLOCK") or (playerClass == "MAGE")
		frost = (playerClass == "DEATH KNIGHT") or (playerClass == "SHAMAN") or (playerClass == "MAGE")
		nature = (playerClass == "SHAMAN") or (playerClass == "DRUID")
		shadow = (playerClass == "DEATH KNIGHT") or (playerClass == "PRIEST") or (playerClass == "WARLOCK")
		holy = (playerClass == "PRIEST") or (playerClass == "PALADIN")
	end
	
	--Bloodlust
	Aura[GetSpellInfo(2825)] = { School = "All", Mods = { ["castTime"] = function(v) return v/1.3 end } }
	--Heroism
	Aura[GetSpellInfo(32182)] = Aura[GetSpellInfo(2825)]
	--Inspiring Presence
	Aura[GetSpellInfo(28878)] = { Value = 1, ModType = "hitPerc", }
	--Aura of the Crusader (Darkmoon Card: Crusade)
	Aura[GetSpellInfo(39439)] = { Mods = { ["AP"] = 120 }, }
	Aura[GetSpellInfo(39441)] = { Mods = { ["spellDmg"] = 80 }, }
	
	if playerCaster or playerHybrid then
		--Totem of Wrath
		Aura[GetSpellInfo(30706)] = { Caster = true, School = "All", Value = 3, ModType = "hitPerc", Mods = { ["critPerc"] = 3 } }
		--Wrath of Air
		Aura[GetSpellInfo(3738)] = { Caster = true, School = "All", Mods = { ["castTime"] = function(v) return v/1.05 end } }
		--Vibrant Blood
		Aura[GetSpellInfo(35329)] = { Caster = true, Value = 0.1 }
		--Bloodgem Infusion
		Aura[GetSpellInfo(34379)] = { Caster = true, School = "All", Value = 0.05, }
		--Power Infusion
		Aura[GetSpellInfo(10060)] = { Caster = true, School = "All", Mods = { ["castTime"] = function(v) return v/1.2 end } }
		--Moonkin Aura
		Aura[GetSpellInfo(24907)] = { Caster = true, School = "All", Mods = { ["critPerc"] = 5 } }
		--Elemental Oath x 2
		Aura[GetSpellInfo(53410)] = { Caster = true, School = "All", Mods = { ["critPerc"] = 3 } }
		Aura[GetSpellInfo(53414)] = { Caster = true, School = "All", Mods = { ["critPerc"] = 5 } }
	end
		
	if playerHealer then
		--A'dal's Song of Battle
		Aura[GetSpellInfo(39953)] = { School = "Healing", Value = 0.05 }
		--Vile Slime
		Aura[GetSpellInfo(40099)] = { School = "Healing", Value = -0.5 }
		--Debilitating Spray
		Aura[GetSpellInfo(40079)] = { School = "Healing", Value = -0.5 }
		--Vile Sludge
		Aura[GetSpellInfo(38246)] = { School = "Healing", Value = -0.5 }	
		--Nether Portal - Serenity
		Aura[GetSpellInfo(30422)] = { School = "Healing", Value = 0.05, Apps = 99 }
	end
	
	--Target debuffs
	Aura = DrDamage.TargetAura
	
	if playerCaster or playerHybrid then
		--SCHOOL SPECIFIC
		--Shadow/Arcane/Fire/Frost/Nature Vulnerability --Excludes Holy, so still School Specific --DALLYTEMP		
		if shadow or arcane or fire or frost or nature then 
			--Curse of the Elements --Changed to include all ranks --DALLYTEMP
			Aura[GetSpellInfo(1490)] = { School = { "Shadow", "Arcane", "Fire", "Frost", "Nature" }, Ranks = 5, Value = {0.06, 0.08, 0.1, 0.1, 0.1 }, ActiveAura = "Soul Siphon", }
			--Earth and Moon x 3  -- Unlike all the other ones, this isn't stacks or applications, it's 5 seperate debuffs based on the talent of the applying class, so all 5 entries appear to be necessary --DALLYTEMP
			Aura[GetSpellInfo(60431)] = { School = { "Shadow", "Arcane", "Fire", "Frost", "Nature" }, Value = 0.04, }
			Aura[GetSpellInfo(60432)] = { School = { "Shadow", "Arcane", "Fire", "Frost", "Nature" }, Value = 0.09, }
			Aura[GetSpellInfo(60433)] = { School = { "Shadow", "Arcane", "Fire", "Frost", "Nature" }, Value = 0.13, }
			--Aura[GetSpellInfo(60434)] = { School = { "Shadow", "Arcane", "Fire", "Frost", "Nature" }, Value = 0.1, }
			--Aura[GetSpellInfo(48509)] = { School = { "Shadow", "Arcane", "Fire", "Frost", "Nature" }, Value = 0.13, }
		end
		
		--General		
		--Misery --Changed to include all ranks --DALLYTEMP
		Aura[GetSpellInfo(33196)] = { Value = 1, Ranks = 3, ModType = "hitPerc", Caster = true }		
		--Improved Scorch --Affects all spells now --DALLYTEMP
		Aura[GetSpellInfo(22959)] = { Apps = 5, Value = 2, ModType = "critPerc", Caster = true }
		--Winter's Chill --Affects all spells now --DALLYTEMP
		Aura[GetSpellInfo(12579)] = { Apps = 5, Value = 2, ModType = "critPerc", Caster = true }
		
		--Weapon Debuffs
		--Spell Vulnerability (from Nightfall)
		Aura[GetSpellInfo(23605)] = { Value = 0.15, Caster = true }
		--Magic Disruption (from Misery)
		Aura[GetSpellInfo(36478)] = { Value = 0.05, Apps = 5, Caster = true }
	end
	if playerHealer then
		--Amplify Magic	--Changed to reflect new healing values --DALLYTEMP
		Aura[GetSpellInfo(1008)] = { School = "Healing", ModType = "spellDmg", Ranks = 7, Value = { 16, 32, 53, 80, 96, 128, 255 }, }
		--Quick Recovery
		Aura[GetSpellInfo(31245)] = { School = "Healing", Ranks = 2, Value = 0.1 }
		--Demon Armor --Changed Fel Armour to Demon Armour --DALLYTEMP
		Aura[GetSpellInfo(27260)] = { School = "Healing", Value = 0.2, }
		--Curse of the Bleeding Hollow
		Aura[GetSpellInfo(34073)] = { School = "Healing", Value = -0.15 }
		--Wound Poison
		Aura[GetSpellInfo(43461)] = { School = "Healing", Apps = 5, Value = -0.1, }
		--Mortal Strike
		Aura[GetSpellInfo(12294)] = { School = "Healing", Value = -0.5, }
		--Veil of Shadow
		Aura[GetSpellInfo(17820)] = { School = "Healing", Value = -0.75, }
		--Nether Portal - Dominance
		Aura[GetSpellInfo(30423)] = { School = "Healing", Value = -0.01, Apps = 10 }
	end
	if playerMelee or playerHybrid then
		--Shadowform
		Aura[GetSpellInfo(15473)] = { School = { "Ranged", "Physical" }, Value = -0.15 }
		--Holyform
		Aura[GetSpellInfo(46565)] = { School = { "Ranged", "Physical" }, Value = -0.2 }
		--Armor Disruption
		Aura[GetSpellInfo(36482)] = { School = {"Ranged", "Physical" }, Value = 0.05, Apps = 5 }
		--Hemorrhage
		Aura[GetSpellInfo(16511)] = { School = { "Ranged", "Physical" }, Value = { 13, 21, 29, 42, 75 }, Ranks = 5, ModType = "dmgBonus" }
		-- Bleed bonuses for Trauma, Mangle (Bear) and Mangle (Cat)
		Aura[GetSpellInfo(46856)] = { School = "Physical", Value = { 0.15, 0.3 }, Ranks = 2, ModType = "bleedBonus" }
		Aura[GetSpellInfo(33878)] = { School = "Physical", Value = 0.3, ModType = "bleedBonus" }
		Aura[GetSpellInfo(33876)] = { School = "Physical", Value = 0.3, ModType = "bleedBonus" }
	end
	
	local Consumables = DrDamage.Consumables
	if arcane or holy or nature then
		Consumables[GetItemInfo(22861) or "Flask of Blinding Light"] = { School = { "Arcane", "Holy", "Nature" }, Mods = { ["spellDmg"] = 80 }, Alt = GetSpellInfo(46839) }
	end
	if shadow or fire or frost then
		Consumables[GetItemInfo(22866) or "Flask of Pure Death"] = { School = { "Shadow", "Fire", "Frost" }, Mods = { ["spellDmg"] = 80 }, Alt = GetSpellInfo(46837) }
	end
	if shadow then
		Consumables[GetItemInfo(22835) or "Elixir of Major Shadow Power"] = { School = "Shadow", Mods = { ["spellDmg"] = 55 }, Alt = GetSpellInfo(28503) }
	end
	if fire then
		Consumables[GetItemInfo(22833) or "Elixir of Major Firepower"] = { School = "Fire", Mods = { ["spellDmg"] = 55 }, Alt = GetSpellInfo(28501) }
	end
	if frost then
		Consumables[GetItemInfo(22827) or "Elixir of Major Frost Power"] = { School = "Frost", Mods = { ["spellDmg"] = 55 }, Alt = GetSpellInfo(28493) }
	end
	if playerHealer then
		Consumables[GetItemInfo(22825) or "Elixir of Healing Power"] = { School = "Healing", Mods = { ["spellDmg"] = 50 }, Alt = GetSpellInfo(28491) }
		Consumables[GetItemInfo(20748) or "Brilliant Mana Oil"] = { School = "Healing", Mods = { ["manaRegen"] = 2.4, ["spellDmg"] = 25 }, Oil = true }
		Consumables[GetItemInfo(22521) or "Superior Mana Oil"] = { School = "All", Mods = { ["manaRegen"] = 2.8 }, Oil = true }
		
		Consumables[L["+44 Healing Food"]] = { School = "Healing", Mods = { ["spellDmg"] = 44 }, Alt = GetSpellInfo(33263) }
	end
	if playerCaster or playerHybrid or playerHealer then
		--Adept's Elixir
		Consumables[GetSpellInfo(33721)] = { School = "All", Mods = { ["spellDmg"] = 24, ["critPerc"] = 1.08696 } }
		Consumables[GetItemInfo(13512) or "Flask of Supreme Power"] = { Mods = { ["spellDmg"] = 70 }, Alt = GetSpellInfo(32900) }
		Consumables[GetItemInfo(22522) or "Superior Wizard Oil"] = { School = "All", Mods = { ["spellDmg"] = 42 }, Oil = true }
		Consumables[GetItemInfo(20749) or "Brilliant Wizard Oil"] = { School = "All", Mods = { ["spellDmg"] = 36, ["critPerc"] = 0.634 }, Oil = true }
		Consumables[GetItemInfo(22853) or "Flask of Mighty Restoration"] = { School = "All", Mods = { ["manaRegen"] = 5 }, Alt = GetSpellInfo(41610) }
		Consumables[GetItemInfo(22840) or "Elixir of Major Mageblood"] = { School = "All", Mods = { ["manaRegen"] = 3.2 }, Alt = GetSpellInfo(28509) }
		
		Consumables[L["+23 Damage Food"]] = { Mods = { ["spellDmg"] = 23, }, Alt = GetSpellInfo(33263) }
		Consumables[L["+20 Spell Critical Strike Food"]] = { School = "All", Mods = { ["critPerc"] = 0.9058 }, Alt = GetSpellInfo(33263) }
	end
	if playerMelee or playerHybrid then
		Consumables[GetItemInfo(22854) or "Flask of Relentless Assault"] = { School = { "Ranged", "Physical" }, Mods = { ["AP"] = 120 }, Alt = GetSpellInfo(41608) }
		--Elixir of Demonslaying
		Consumables[GetSpellInfo(11406)] = { School = { "Physical", "Ranged" }, Mods = { ["AP"] = 265 }, }
		
		Consumables[L["+40 AP Food"]] = { School = { "Ranged", "Physical" }, Mods = { ["AP"] = 40 }, Alt = GetSpellInfo(33263) }
		Consumables[L["+20 Hit Rating Food"]] = { School = { "Ranged", "Physical" }, Mods = { ["hitPerc"] = 1.269 }, Alt = GetSpellInfo(33263) }
	end
end

DrD_LoadAuras()
DrD_LoadAuras = nil