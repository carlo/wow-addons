Outfitter.cItemStatInfo =
{
	{ID = "Agility", Name = Outfitter.cAgilityStatName, Category = "Stat"},
	{ID = "Intellect", Name = Outfitter.cIntellectStatName, Category = "Stat"},
	{ID = "Spirit", Name = Outfitter.cSpiritStatName, Category = "Stat"},
	{ID = "Stamina", Name = Outfitter.cStaminaStatName, Category = "Stat"},
	{ID = "Strength", Name = Outfitter.cStrengthStatName, Category = "Stat"},
	{ID = "Health", Name = Outfitter.cHealthStatName, Category = "Stat"},
	{ID = "Mana", Name = Outfitter.cManaStatName, Category = "Stat"},
	{ID = "TotalStats", Name = Outfitter.cTotalStatsName, Category = "Stat"},
	
	{ID = "ManaRegen", Name = Outfitter.cManaRegenStatName, Category = "Regen"},
	{ID = "CombatManaRegen", Name = Outfitter.cCombatManaRegenStatName, Category = "Regen"},
	{ID = "HealthRegen", Name = Outfitter.cHealthRegenStatName, Category = "Regen"},
	{ID = "CombatHealthRegen", Name = Outfitter.cCombatHealthRegenStatName, Category = "Regen"},
	
	{ID = "SpellCrit", Name = Outfitter.cSpellCritStatName, Category = "Spell"},
	{ID = "SpellHit", Name = Outfitter.cSpellHitStatName, Category = "Spell"},
	{ID = "SpellHaste", Name = Outfitter.cSpellHasteStatName, Category = "Spell"},
	{ID = "SpellDmg", Name = Outfitter.cSpellDmgStatName, Category = "Spell"},
	{ID = "FrostDmg", Name = Outfitter.cFrostDmgStatName, Category = "Spell"},
	{ID = "FireDmg", Name = Outfitter.cFireDmgStatName, Category = "Spell"},
	{ID = "ArcaneDmg", Name = Outfitter.cArcaneDmgStatName, Category = "Spell"},
	{ID = "ShadowDmg", Name = Outfitter.cShadowDmgStatName, Category = "Spell"},
	{ID = "NatureDmg", Name = Outfitter.cNatureDmgStatName, Category = "Spell"},
	{ID = "Healing", Name = Outfitter.cHealingStatName, Category = "Spell"},
	
	{ID = "Armor", Name = Outfitter.cArmorStatName, Category = "Melee"},
	{ID = "Defense", Name = Outfitter.cDefenseStatName, Category = "Melee"},
	{ID = "Dodge", Name = Outfitter.cDodgeStatName, Category = "Melee"},
	{ID = "Parry", Name = Outfitter.cParryStatName, Category = "Melee"},
	{ID = "Block", Name = Outfitter.cBlockStatName, Category = "Melee"},
	{ID = "Resilience", Name = Outfitter.cResilienceStatName, Category = "Melee"},
	{ID = "MeleeDmg", Name = Outfitter.cMeleeDmgStatName, Category = "Melee"},
	{ID = "MeleeCrit", Name = Outfitter.cMeleeCritStatName, Category = "Melee"},
	{ID = "MeleeHit", Name = Outfitter.cMeleeHitStatName, Category = "Melee"},
	{ID = "MeleeHaste", Name = Outfitter.cMeleeHasteStatName, Category = "Melee"},
	
	{ID = "Attack", Name = Outfitter.cAttackStatName, Category = "Melee"},
	{ID = "RangedAttack", Name = Outfitter.cRangedAttackStatName, Category = "Melee"},
	
	{ID = "ArcaneResist", Name = Outfitter.cArcaneResistStatName, Category = "Resist"},
	{ID = "FireResist", Name = Outfitter.cFireResistStatName, Category = "Resist"},
	{ID = "FrostResist", Name = Outfitter.cFrostResistStatName, Category = "Resist"},
	{ID = "NatureResist", Name = Outfitter.cNatureResistStatName, Category = "Resist"},
	{ID = "ShadowResist", Name = Outfitter.cShadowResistStatName, Category = "Resist"},
	
	{ID = "Fishing", Name = Outfitter.cFishingStatName, Category = "Trade"},
	{ID = "Herbalism", Name = Outfitter.cHerbalismStatName, Category = "Trade"},
	{ID = "Mining", Name = Outfitter.cMiningStatName, Category = "Trade"},
	{ID = "Skinning", Name = Outfitter.cSkinningStatName, Category = "Trade"},
}

function Outfitter:GetItemLinkStats(pItemLink, pDistribution)
	OutfitterTooltip:SetOwner(OutfitterFrame, "ANCHOR_BOTTOMRIGHT", 0, 0)
	OutfitterTooltip:SetHyperlink(pItemLink)
	
	local vStats = self:GetItemStatsFromTooltip(OutfitterTooltip)
	
	OutfitterTooltip:Hide()
	
	return vStats
end

function Outfitter:GetItemStatsFromTooltip(pTooltip, pDistribution)
	local vStats = {}
	local vTooltipName = pTooltip:GetName()
	local vLineCount = pTooltip:NumLines()
	
	for vLineIndex = 1, vLineCount do
		local vLeftTextFrame = getglobal(vTooltipName.."TextLeft"..vLineIndex)
		
		if not vLeftTextFrame then
			break
		end
		
		local vLeftText = vLeftTextFrame:GetText()
		-- local vRightText = getglobal(vTooltipName.."TextRight"..vLineIndex):GetText()
		
		if vLeftText then
			-- Check for the start of the set bonus section
			
			local vStartIndex, vEndIndex, vValue = string.find(vLeftText, "%(%d/%d%)")
			
			if vStartIndex then
				break
			end
			
			--
			
			local vLineStats = Outfitter:GetTooltipLineStats(vLeftText)
			
			if vLineStats then
				for vStatID, vValue in pairs(vLineStats) do
					Outfitter.Stats_AddStatValue(vStats, vStatID, vValue)
				end
			end
		end
	end -- for vLineIndex
	
	return vStats
end

function Outfitter:ConvertRatingsToStats(pStats)
	local vRatingDistribution = Outfitter:GetPlayerRatingStatDistribution()
	
	for vStatID, vValue in pairs(pStats) do
		Outfitter.Stats_DistributeValue(pStats, vValue, vRatingDistribution[vStatID])
	end
end

function Outfitter:DistributeSecondaryStats(pStats, pDistribution)
	local vStats = {} -- Have to collect them separately or they'll mess up the iterator
	
	for vStatID, vValue in pairs(pStats) do
		Outfitter.Stats_DistributeValue(vStats, vValue, pDistribution[vStatID])
	end
	
	-- Add the secondary stats back in
	
	for vStatID, vValue in pairs(vStats) do
		Outfitter.Stats_AddStatValue(pStats, vStatID, vValue)
	end
end

function Outfitter:AddStats(pItem1, pItem2, pStatID)
	local vStat = 0
	
	if pItem1
	and pItem1[pStatID] then
		vStat = pItem1[pStatID]
	end
	
	if pItem2
	and pItem2[pStatID] then
		vStat = vStat + pItem2[pStatID]
	end
	
	return vStat
end

function Outfitter:GetTooltipLineStats(pText)
	-- Remove the trailing period if it's there
	
	if string.sub(pText, -1) == "." then
		pText = string.sub(pText, 1, -2)
	end
	
	-- Remove any color-code close if it's there
	
	if string.sub(pText, -2) == FONT_COLOR_CODE_CLOSE then
		pText = string.sub(pText, 1, -3)
	end
	
	--
	
	for _, vStatInfo in ipairs(Outfitter.cItemStatFormats) do
		if type(vStatInfo) == "string" then
			local vResult = {string.find(pText, vStatInfo)}
			
			if vResult[1] then
				local vStatList = {}
				
				for vIndex = 3, #vResult, 2 do
					local vStatPhrase = vResult[vIndex]
					local vValue = tonumber(vResult[vIndex + 1])
					
					-- Swap them around if the number is first
					
					if vValue == nil then
						vStatPhrase = vResult[vIndex + 1]
						vValue = tonumber(vResult[vIndex])
					end
					
					if vStatPhrase and vValue then
						local vTypes = Outfitter.cItemStatPhrases[strlower(vStatPhrase)]
						
						if vTypes then
							if type(vTypes) == "string" then
								if not vStatList[vTypes] then
									vStatList[vTypes] = vValue
								else
									vStatList[vTypes] = vStatList[vTypes] + vValue
								end
							else
								for _, vStatID in ipairs(vTypes) do
									if not vStatList[vStatID] then
										vStatList[vStatID] = vValue
									else
										vStatList[vStatID] = vStatList[vStatID] + vValue
									end
								end
							end
						end
					end
				end
				
				-- Outfitter:DebugTable("StatList", vStatList)
				
				return vStatList
			end -- if vResult[1]
		elseif type(vStatInfo) == "table" then
			local vStartIndex, vEndIndex = string.find(pText, vStatInfo.Format)
			
			if vStartIndex then
				local vStatList = {}
				
				for _, vStatID in ipairs(vStatInfo.Types) do
					if not vStatList[vStatID] then
						vStatList[vStatID] = vStatInfo.Value
					else
						vStatList[vStatID] = vStatList[vStatID] + vStatInfo.Value
					end
				end
				
				return vStatList
			end
		end -- table
	end -- for
end

function Outfitter.TankPoints_New()
	local vTankPointData = {}
	local vStatDistribution = Outfitter:GetPlayerStatDistribution()
	
	if not vStatDistribution then
		Outfitter:ErrorMessage("Missing stat distribution data for "..Outfitter.PlayerClass)
		return
	end
	
	vTankPointData.PlayerLevel = UnitLevel("player")
	vTankPointData.StaminaFactor = 1.0 -- Warlocks with demonic embrace = 1.15
	
	-- Get the base stats
	
	vTankPointData.BaseStats = {}
	
	Outfitter.Stats_AddStatValue(vTankPointData.BaseStats, "Strength", UnitStat("player", 1))
	Outfitter.Stats_AddStatValue(vTankPointData.BaseStats, "Agility", UnitStat("player", 2))
	Outfitter.Stats_AddStatValue(vTankPointData.BaseStats, "Stamina", UnitStat("player", 3))
	Outfitter.Stats_AddStatValue(vTankPointData.BaseStats, "Intellect", UnitStat("player", 4))
	Outfitter.Stats_AddStatValue(vTankPointData.BaseStats, "Spirit", UnitStat("player", 5))
	
	Outfitter.Stats_AddStatValue(vTankPointData.BaseStats, "Health", UnitHealthMax("player"))
	
	vTankPointData.BaseStats.Health = vTankPointData.BaseStats.Health - vTankPointData.BaseStats.Stamina * 10
	
	vTankPointData.BaseStats.Dodge = GetDodgeChance()
	vTankPointData.BaseStats.Parry = GetParryChance()
	vTankPointData.BaseStats.Block = GetBlockChance()
	
	local vBaseDefense, vBuffDefense = UnitDefense("player")
	Outfitter.Stats_AddStatValue(vTankPointData.BaseStats, "Defense", vBaseDefense + vBuffDefense)
	
	-- Replace the armor with the current value since that already includes various factors
	
	local vBaseArmor, vEffectiveArmor, vArmor, vArmorPosBuff, vArmorNegBuff = UnitArmor("player")
	vTankPointData.BaseStats.Armor = vEffectiveArmor
	
	Outfitter:DebugMessage("------------------------------------------")
	Outfitter:DebugTable("vTankPointData", vTankPointData)
	
	-- Subtract out the current outfit
	
	local vCurrentOutfitStats = Outfitter.TankPoints_GetCurrentOutfitStats(vStatDistribution)
	
	Outfitter:DebugMessage("------------------------------------------")
	Outfitter:DebugTable("vCurrentOutfitStats", vCurrentOutfitStats)
	
	Outfitter.Stats_SubtractStats(vTankPointData.BaseStats, vCurrentOutfitStats)
	
	-- Calculate the buff stats (stuff from auras/spell buffs/whatever)
	
	vTankPointData.BuffStats = {}
	
	-- Reset the cumulative values
	
	Outfitter.TankPoints_Reset(vTankPointData)
	
	Outfitter:DebugMessage("------------------------------------------")
	Outfitter:DebugTable("vTankPointData", vTankPointData)
	
	Outfitter:DebugMessage("------------------------------------------")
	return vTankPointData
end

function Outfitter.TankPoints_Reset(pTankPointData)
	pTankPointData.AdditionalStats = {}
end

function Outfitter.TankPoints_GetTotalStat(pTankPointData, pStat)
	local vTotalStat = pTankPointData.BaseStats[pStat]
	
	if not vTotalStat then
		vTotalStat = 0
	end
	
	local vAdditionalStat = pTankPointData.AdditionalStats[pStat]
	
	if vAdditionalStat then
		vTotalStat = vTotalStat + vAdditionalStat
	end
	
	local vBuffStat = pTankPointData.BuffStats[pStat]
	
	if vBuffStat then
		vTotalStat = vTotalStat + vBuffStat
	end
	
	--
	
	return vTotalStat
end

function Outfitter.TankPoints_CalcTankPoints(pTankPointData, pStanceModifier)
	if not pStanceModifier then
		pStanceModifier = 1
	end
	
	Outfitter:DebugTable("pTankPointData", pTankPointData)
	
	local vEffectiveArmor = Outfitter.TankPoints_GetTotalStat(pTankPointData, "Armor")
	
	Outfitter:TestMessage("Armor: "..vEffectiveArmor)
	
	local vArmorReduction = vEffectiveArmor / ((85 * pTankPointData.PlayerLevel) + 400)
	
	vArmorReduction = vArmorReduction / (vArmorReduction + 1)
	
	local vEffectiveHealth = Outfitter.TankPoints_GetTotalStat(pTankPointData, "Health")
	
	Outfitter:TestMessage("Health: "..vEffectiveHealth)
	
	Outfitter:TestMessage("Stamina: "..Outfitter.TankPoints_GetTotalStat(pTankPointData, "Stamina"))
	
	--
	
	local vEffectiveDodge = Outfitter.TankPoints_GetTotalStat(pTankPointData, "Dodge") * 0.01
	local vEffectiveParry = Outfitter.TankPoints_GetTotalStat(pTankPointData, "Parry") * 0.01
	local vEffectiveBlock = Outfitter.TankPoints_GetTotalStat(pTankPointData, "Block") * 0.01
	local vEffectiveDefense = Outfitter.TankPoints_GetTotalStat(pTankPointData, "Defense")
	
	-- Add agility and defense to dodge
	
	-- defenseInputBox:GetNumber() * 0.04 + agiInputBox:GetNumber() * 0.05

	Outfitter:TestMessage("Dodge: "..vEffectiveDodge)
	Outfitter:TestMessage("Parry: "..vEffectiveParry)
	Outfitter:TestMessage("Block: "..vEffectiveBlock)
	Outfitter:TestMessage("Defense: "..vEffectiveDefense)
	
	local vDefenseModifier = (vEffectiveDefense - pTankPointData.PlayerLevel * 5) * 0.04 * 0.01
	
	Outfitter:TestMessage("Crit reduction: "..vDefenseModifier)
	
	local vMobCrit = max(0, 0.05 - vDefenseModifier)
	local vMobMiss = 0.05 + vDefenseModifier
	local vMobDPS = 1
	
	local vTotalReduction = 1 - (vMobCrit * 2 + (1 - vMobCrit - vMobMiss - vEffectiveDodge - vEffectiveParry)) * (1 - vArmorReduction) * pStanceModifier
	
	Outfitter:TestMessage("Total reduction: "..vTotalReduction)
	
	local vTankPoints = vEffectiveHealth / (vMobDPS * (1 - vTotalReduction))
	
	return vTankPoints
	
	--[[
	Stats used in TankPoints calculation:
		Health
		Dodge
		Parry
		Block
		Defense
		Armor
	]]--
end

function Outfitter.TankPoints_GetCurrentOutfitStats(pStatDistribution)
	local vTotalStats = {}
	
	for _, vSlotName in ipairs(Outfitter.cSlotNames) do
		local vStats = Outfitter.ItemList_GetItemStats({SlotName = vSlotName})
		
		if vStats then
			Outfitter:TestMessage("--------- "..vSlotName)
			
			for vStat, vValue in pairs(vStats) do
				Outfitter.Stats_AddStatValue(vTotalStats, vStat, vValue)
			end
		end
	end
	
	return vTotalStats
end

function Outfitter.TankPoints_Test()
	local vStatDistribution = Outfitter:GetPlayerStatDistribution()
	
	local vTankPointData = Outfitter.TankPoints_New()
	local vStats = Outfitter.TankPoints_GetCurrentOutfitStats(vStatDistribution)
	
	Outfitter.Stats_AddStats(vTankPointData.AdditionalStats, vStats)
	
	local vTankPoints = Outfitter.TankPoints_CalcTankPoints(vTankPointData)
	
	Outfitter:TestMessage("TankPoints = "..vTankPoints)
end

