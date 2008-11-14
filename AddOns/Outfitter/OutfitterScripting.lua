Outfitter.ScriptContexts = {}
Outfitter.OutfitScriptEvents = {}

function Outfitter:GenerateScriptHeader(pEventIDs, pDescription)
	local vDescription
	
	if pDescription then
		vDescription = '-- $DESC '..pDescription..'\n'
	else
		vDescription = ''
	end
	
	if type(pEventIDs) == "table" then
		pEventIDs = table.concat(pEventIDs, " ")
	end
	
	return '-- $EVENTS '..pEventIDs..'\n'..vDescription..'\n'
end

function Outfitter:GenerateSimpleScript(pEventID, pDescription)
	return
		self:GenerateScriptHeader(pEventID.." NOT_"..pEventID, pDescription)..
		'-- If the activation event fires, equip the outfit\n'..
		'\n'..
		'if event == "'..pEventID..'" then\n'..
		'    equip = true\n'..
		'\n'..
		'-- Otherwise it must be the deactivation event so unequip it\n'..
		'\n'..
		'else\n'..
		'    equip = false\n'..
		'end\n'
end

function Outfitter:GenerateSmartUnequipScript(pEventID, pDescription, pUnequipDelay)
	local vScript
	
	vScript = self:GenerateScriptHeader(pEventID.." NOT_"..pEventID, pDescription)..
		'-- If the activation event fires, equip the outfit\n'..
		'\n'..
		'if event == "'..pEventID..'" then\n'..
		'    equip = true\n'..
		'\n'..
		'-- Otherwise it must be the deactivation event so unequip\n'..
		'-- the outfit.\n'..
		'\n'..
		'-- Note that if you manually equipped the outfit the script\n'..
		'-- will not unequip it for you.  This allows you to avoid excess\n'..
		'-- outfit changes, for example when entering and exiting\n'..
		'-- battlegrounds repeatedly. Remove the didEquip condition\n'..
		'-- to change the behavior to always unequip.\n'..
		'\n'..
		'elseif didEquip then\n'..
		'    equip = false\n' if pUnequipDelay then vScript = vScript..
		'    delay = '..pUnequipDelay..'\n' end vScript = vScript..
		'end\n'
	
	return vScript
end

function Outfitter:GenerateShapeshiftScript(pEventID, pDescription)
	return
		self:GenerateScriptHeader({pEventID, 'NOT_'..pEventID, "OUTFIT_EQUIPPED"}, pDescription)..
		'-- $SETTING DisableBG={Type="Boolean", Label="Don\'t equip in Battlegrounds", Default=false}\n'..
		'-- $SETTING DisablePVP={Type="Boolean", Label="Don\'t equip while PvP flagged", Default=false}\n'..
		'\n'..
		'-- Just return if they\'re PvP\'ing and don\'t want the outfit changing\n'..
		'\n'..
		'if (setting.DisableBG and Outfitter:InBattlegroundZone())\n'..
		'or (setting.DisablePVP and UnitIsPVP("player")) then\n'..
		'    return\n'..
		'end\n'..
		'\n'..
		'-- Return if the user isn\'t in full control\n'..
		'\n'..
		'if not Outfitter.IsDead and not HasFullControl() then\n'..
		'    return\n'..
		'end\n'..
		'\n'..
		'-- If the outfit is being equipped then let Outfitter know\n'..
		'-- which layer it\'s representing\n'..
		'\n'..
		'if event == "OUTFIT_EQUIPPED" then\n'..
		'    layer = "shapeshift"\n'..
		'\n'..
		'-- Equip and set the layer if entering the stance\n'..
		'\n'..
		'elseif event == "'..pEventID..'" then\n'..
		'    equip = true\n'..
		'    layer = "shapeshift"\n'..
		'\n'..
		'-- Just unequip if leaving the stance\n'..
		'\n'..
		'else\n'..
		'    equip = false\n'..
		'end\n'
end

function Outfitter:GenerateDruidShapeshiftScript(pEventID, pDescription)
	return
		self:GenerateScriptHeader({pEventID, 'NOT_'..pEventID, 'OUTFIT_EQUIPPED'}, pDescription)..
		'-- $SETTING DisableBG={Type="Boolean", Label="Don\'t equip in Battlegrounds", Default=false}\n'..
		'-- $SETTING DisablePVP={Type="Boolean", Label="Don\'t equip while PvP flagged", Default=false}\n'..
		'\n'..
		'-- Just return if they\'re PvP\'ing and don\'t want the outfit changing\n'..
		'\n'..
		'if (setting.DisableBG and Outfitter:InBattlegroundZone())\n'..
		'or (setting.DisablePVP and UnitIsPVP("player")) then\n'..
		'    return\n'..
		'end\n'..
		'\n'..
		'-- Return if the user isn\'t in full control\n'..
		'\n'..
		'if not Outfitter.IsDead and not HasFullControl() then\n'..
		'    return\n'..
		'end\n'..
		'\n'..
		'-- If the user is manually equipping the outfit, let\n'..
		'-- Outfitter know which layer it\'s representing\n'..
		'\n'..
		'if event == "OUTFIT_EQUIPPED" then\n'..
		'    layer = "shapeshift"\n'..
		'\n'..
		'-- Equip and set the layer if entering the form\n'..
		'\n'..
		'elseif event == "'..pEventID..'" then\n'..
		'    equip = true\n'..
		'    layer = "shapeshift"\n'..
		'\n'..
		'-- Unequip if leaving the form.  If they\'re in combat also\n'..
		'-- add a 2 second delay so they have time to start casting\n'..
		'-- a heal on themselves without triggering the global cooldown\n'..
		'\n'..
		'else\n'..
		'    equip = false\n'..
		'\n'..
		'    if Outfitter.InCombat then\n'..
		'        delay = 2\n'..
		'    end\n'..
		'end\n'
end

function Outfitter:GenerateGatheringScript(pTooltipGatherMessage, pDescription)
	return
		self:GenerateScriptHeader("GAMETOOLTIP_SHOW GAMETOOLTIP_HIDE", pDescription)..
		'-- If the tooltip is being shown see if the outfit should be equipped\n'..
		'\n'..
		'if event == "GAMETOOLTIP_SHOW" then\n'..
		'\n'..
		'    -- Check the tooltip for an orange or red tradeskill message\n'..
		'    -- and equip the outfit if there is one\n'..
		'\n'..
		'    local hasText, isDifficult = Outfitter:TooltipContainsLine(GameTooltip, '..pTooltipGatherMessage..')\n'..
		'\n'..
		'    if hasText and isDifficult then\n'..
		'        equip=true\n'..
		'    end\n'..
		'\n'..
		'    -- The tooltip isn\'t being shown so it\'s being hidden.\n'..
		'    -- A one second delay is used so that the outfit doesn\'t\n'..
		'    -- unequip if the user momentarily moves the cursor off\n'..
		'    -- the node\n'..
		'\n'..
		'elseif didEquip then\n'..
		'    equip=false; delay=1\n'..
		'end'
end

function Outfitter:GenerateLockpickingScript(pTooltipGatherMessage, pDescription)
	return
		self:GenerateScriptHeader("GAMETOOLTIP_SHOW GAMETOOLTIP_HIDE", pDescription)..
		'-- If the tooltip is being shown see if the outfit should be equipped\n'..
		'\n'..
		'if event == "GAMETOOLTIP_SHOW" or event == "TIMER" then\n'..
		'    if event == "GAMETOOLTIP_SHOW" then\n'..
		'        self:RegisterEvent("TIMER")\n'..
		'    end\n'..
		'\n'..
		'    if not SpellIsTargeting() then\n'..
		'        return\n'..
		'    end\n'..
		'\n'..
		'    -- Check the tooltip for an orange or red tradeskill message\n'..
		'    -- and equip the outfit if there is one\n'..
		'\n'..
		'    local hasText, isDifficult = Outfitter:TooltipContainsLine(GameTooltip, Outfitter.cRequiresLockpicking)\n'..
		'\n'..
		'    if hasText and isDifficult then\n'..
		'        equip=true\n'..
		'    end\n'..
		'\n'..
		'    -- The tooltip isn\'t being shown so it\'s being hidden.\n'..
		'    -- A one second delay is used so that the outfit doesn\'t\n'..
		'    -- unequip if the user momentarily moves the cursor off\n'..
		'    -- the node\n'..
		'\n'..
		'else\n'..
		'    self:UnregisterEvent("TIMER")\n'..
		'    if didEquip then -- GAME_TOOLTIP_HIDE\n'..
		'        equip=false; delay=1\n'..
		'    end\n'..
		'end'
end

Outfitter.PresetScripts =
{
	{
		Name = Outfitter.cHerbalismOutfit,
		ID = "HERBALISM",
		Category = "TRADE",
		Script = Outfitter:GenerateGatheringScript("UNIT_SKINNABLE_HERB", Outfitter.cHerbalismDescription),
	},
	{
		Name = Outfitter.cMiningOutfit,
		ID = "MINING",
		Category = "TRADE",
		Script = Outfitter:GenerateGatheringScript("UNIT_SKINNABLE_ROCK", Outfitter.cMiningDescription),
	},
	{
		Name = Outfitter.cSkinningOutfit,
		ID = "SKINNING",
		Category = "TRADE",
		Script = Outfitter:GenerateGatheringScript("UNIT_SKINNABLE_LEATHER", Outfitter.cSkinningDescription),
	},
	{
		Name = Outfitter.cLockpickingOutfit,
		ID = "LOCKPICKING",
		Category = "TRADE",
		Class = "ROGUE",
		Script = Outfitter:GenerateLockpickingScript(Outfitter.cLockpickingDescription),
	},
	{
		Name = Outfitter.cLowHealthOutfit,
		ID = "LOW_HEALTH",
		Category = "GENERAL",
		Script = Outfitter:GenerateScriptHeader("UNIT_HEALTH UNIT_MANA", Outfitter.cLowHealthDescription)..
		       '-- $SETTING Health="Number"\n'..
		       '-- $SETTING Mana="Number"\n'..
		       '\n'..
		       'if arg1=="player"\n'..
		       'and (UnitHealth(arg1) < setting.Health\n'..
		       '  or UnitMana(arg1) < setting.Mana) then\n'..
		       '    equip = true\n'..
		       'elseif didEquip then\n'..
		       '    equip = false\n'..
		       'end',
	},
	{
		Name = Outfitter.cHasBuffOutfit,
		ID = "HAS_BUFF",
		Category = "GENERAL",
		Script = Outfitter:GenerateScriptHeader("UNIT_AURA", Outfitter.cHasBuffDescription)..
		         '-- $SETTING buffName = {Type = "String", Label = "Buff name"}\n'..
		         '\n'..
		         'if select(1, ...) ~= "player" then return end\n'..
		         '\n'..
		         'local index = 1\n'..
		         'local lowerName = strlower(setting.buffName)\n'..
		         '\n'..
		         'while true do\n'..
		         '    local buffName = UnitBuff("player", index)\n'..
		         '    if not buffName then break end\n'..
		         '    if strlower(buffName) == lowerName then equip = true break end\n'..
		         '    index = index + 1\n'..
		         'end\n'..
		         '\n'..
		         'if equip == nil and didEquip then equip = false end\n',
	},
	{
		Name = "Trinket Queue",
		ID = "TRINKET_QUEUE",
		Category = "GENERAL",
		Script = Outfitter:GenerateScriptHeader("TIMER", "The highest trinket in the list that isn\'t on cooldown will automatically be equipped for you")..
		       '-- $SETTING Trinkets={Label="Upper slot", Type="StringTable"}\n'..
		       '-- $SETTING Trinkets2={Label="Lower slot", Type="StringTable"}\n'..
		       '\n'..
		       'local upperSlotVisible = true\n'..
		       'local lowerSlotVisible = true\n'..
		       '\n'..
		       'if not Outfitter.OutfitStack:IsTopmostOutfit(outfit) then\n'..
		       '    for index = #Outfitter.OutfitStack.Outfits, 1, -1 do\n'..
		       '        local stackOutfit = Outfitter.OutfitStack.Outfits[index]\n'..
		       '        if outfit == stackOutfit then break end\n'..
		       '        if stackOutfit.Name then\n'..
		       '            if stackOutfit.Items.Trinket0Slot then\n'..
		       '                upperSlotVisible = false\n'..
		       '            end\n'..
		       '            if stackOutfit.Items.Trinket1Slot then\n'..
		       '                lowerSlotVisible = false\n'..
		       '            end\n'..
		       '        end\n'..
		       '    end\n'..
		       'end\n'..
		       '\n'..
		       'if isEquipped and not Outfitter.InCombat and not Outfitter.IsDead and not Outfitter.IsCasting and not Outfitter.IsChanneling then\n'..
		       '    if upperSlotVisible and not Outfitter:InventoryItemIsActive("Trinket0Slot") then\n'..
		       '        for _, itemName in ipairs(setting.Trinkets) do\n'..
		       '            local startTime, duration, enable = GetItemCooldown(itemName)\n'..
		       '            if duration <= 30 then\n'..
		       '                EquipItemByName(itemName)\n'..
		       '                break\n'..
		       '            end\n'..
		       '        end\n'..
		       '    end\n'..
		       '\n'..
		       '    if lowerSlotVisible and not Outfitter:InventoryItemIsActive("Trinket1Slot") then\n'..
		       '        for _, itemName in ipairs(setting.Trinkets2) do\n'..
		       '            local startTime, duration, enable = GetItemCooldown(itemName)\n'..
		       '            if duration <= 30 then\n'..
		       '                EquipItemByName(itemName, 14)\n'..
		       '                break\n'..
		       '            end\n'..
		       '        end\n'..
		       '    end\n'..
		       'end',
	},
	{
		Name = Outfitter.cInZonesOutfit,
		ID = "IN_ZONES",
		Category = "TRADE",
		Script = Outfitter:GenerateScriptHeader("ZONE_CHANGED_INDOORS ZONE_CHANGED ZONE_CHANGED_NEW_AREA", Outfitter.cInZonesOutfitDescription)..
		       '-- $SETTING zoneList={Type=\"ZoneList\", Label=\"Zones\"}\n'..
		       '-- $SETTING minimapZoneList={Type=\"ZoneList\", ZoneType=\"MinimapZone\", Label=\"Minimap zones\"}\n'..
		       '\n'..
		       'local currentZone = GetZoneText()\n'..
		       '\n'..
		       'for _, zoneName in ipairs(setting.zoneList) do\n'..
		       '    if zoneName == currentZone then\n'..
		       '        equip = true\n'..
		       '        break\n'..
		       '    end\n'..
		       'end\n'..
		       '\n'..
		       'if not equip then\n'..
		       '    currentZone = GetMinimapZoneText()\n'..
		       '    for _, zoneName in ipairs(setting.minimapZoneList) do\n'..
		       '        if zoneName == currentZone then\n'..
		       '            equip = true\n'..
		       '            break\n'..
		       '        end\n'..
		       '    end\n'..
		       'end\n'..
		       '\n'..
		       'if didEquip and equip == nil then\n'..
		       '    equip = false\n'..
		       'end',
	},
	{
		Name = Outfitter.cArgentDawnOutfit,
		ID = "ArgentDawn",
		Category = "GENERAL",
		Script = Outfitter:GenerateScriptHeader("ARGENT_DAWN NOT_ARGENT_DAWN", Outfitter.cArgentDawnOutfitDescription)..
		         '-- $SETTING DisableNaxx={Type="Boolean", Label="Disable in Naxxramas"}\n'..
		         'if event == "ARGENT_DAWN" then\n'..
		         '    if not setting.DisableNaxx\n'..
		         '    or not Outfitter:InZoneType("Naxx") then\n'..
		         '        equip = true\n'..
		         '    end\n'..
		         'elseif didEquip then\n'..
		         '    equip = false\n'..
		         'end\n',
	},
	{
		Name = Outfitter.cRidingOutfit,
		ID = "Riding",
		Category = "TRADE",
		Script = Outfitter:GenerateScriptHeader("MOUNTED NOT_MOUNTED", Outfitter.cRidingOutfitDescription)..
		         '-- $SETTING DisableBG={Type="Boolean", Label="Don\'t equip in Battlegrounds", Default=true}\n'..
		         '-- $SETTING DisableInstance={Type="Boolean", Label="Don\'t equip in dungeons", Default=true}\n'..
		         '-- $SETTING DisablePVP={Type="Boolean", Label="Don\'t equip while PvP flagged", Default=false}\n'..
		         '-- $SETTING StayEquippedWhileFalling={Type="Boolean", Label="Leave equipped while falling", Default=false}\n'..
		         '-- $SETTING UnequipDelay={Type="Number", Label="Wait", Suffix="seconds before unequipping", Default=0}\n'..
		         '\n'..
		         '-- Equip on mount unless it\'s disabled\n'..
		         '\n'..
		         'if event == "MOUNTED" then\n'..
		         '    -- The disable options are only checked inside the mounting handler.  This way\n'..
		         '    -- the outfit won\'t equip automatically, but if the player chooses to\n'..
		         '    -- manually equip it after mounting, then Outfitter will still unequip\n'..
		         '    -- it for them when they dismount\n'..
		         '\n'..
		         '    local inInstance, instanceType = IsInInstance()\n'..
		         '    if (setting.DisableInstance and inInstance and (instanceType == "raid" or instanceType == "party"))\n'..
		         '    or (setting.DisableBG and Outfitter:InBattlegroundZone())\n'..
		         '    or (setting.DisablePVP and UnitIsPVP("player")) then\n'..
		         '        return\n'..
		         '    end\n'..
		         '\n'..
		         '    equip = true\n'..
		         '\n'..
		         '-- Unequip on dismount\n'..
		         '\n'..
		         'elseif event == "NOT_MOUNTED" then\n'..
		         '    if not setting.StayEquippedWhileFalling then\n'..
		         '        equip = false\n'..
		         '    else\n'..
				 '        self.UnequipWhenNotFalling = true\n'..
				 '        self.DismountTime = GetTime()\n'..
		         '        self:RegisterEvent("TIMER")\n'..
		         '    end\n'..
		         '\n'..
		         '    if setting.UnequipDelay then\n'..
		         '        delay = setting.UnequipDelay\n'..
		         '    end\n'..
		         '\n'..
		         '-- If they\'re still mounted three seconds after casting then assume\n'..
		         '-- it was nothing important and put the riding gear back on\n'..
		         '\n'..
				 'elseif event == "TIMER" then\n'..
		         '    -- Unequip if the player was falling when dismounted and has now landed\n'..
		         '\n'..
		         '    if self.UnequipWhenNotFalling\n'..
		         '    and GetTime() >= self.DismountTime + 1\n'..
		         '    and not IsFalling() then\n'..
		         '        equip = false\n'..
		         '        self.UnequipWhenNotFalling = nil\n'..
		         '    end\n'..
		         '\n'..
				 '    if not self.UnequipWhenNotFalling then\n'..
				 '        self:UnregisterEvent("TIMER")\n'..
				 '    end\n'..
		         'end\n',
	},
	{
		Name = Outfitter.cSwimmingOutfit,
		ID = "Swimming",
		Category = "TRADE",
		Script = Outfitter:GenerateScriptHeader("SWIMMING NOT_SWIMMING", Outfitter.cSwimmingOutfitDescription)..
				'-- $SETTING DisableBG={Type="Boolean", Label="Don\'t equip in Battlegrounds", Default=false}\n'..
				'-- $SETTING DisablePVP={Type="Boolean", Label="Don\'t equip while PvP flagged", Default=false}\n'..
				'\n'..
				'-- Just return if they\'re PvP\'ing and don\'t want the outfit changing\n'..
				'\n'..
				'if (setting.DisableBG and Outfitter:InBattlegroundZone())\n'..
				'or (setting.DisablePVP and UnitIsPVP("player")) then\n'..
				'    return\n'..
				'end\n'..
				'\n'..
				'if event == "SWIMMING" then\n'..
				'    equip = true\n'..
				'elseif didEquip then\n'..
				'    equip = false\n'..
				'    delay = 2.5 -- Use a delay since hitting spacebar temporarily makes the player not swimming\n'..
				'end\n',
	},
	{
		Name = Outfitter.cFishingOutfit,
		ID = "Fishing",
		Category = "TRADE",
		Script = Outfitter:GenerateScriptHeader("PLAYER_REGEN_ENABLED PLAYER_REGEN_DISABLED PLAYER_ENTERING_WORLD OUTFIT_EQUIPPED OUTFIT_UNEQUIPPED UNIT_AURA", Outfitter.cFishingOutfitDescription)..
		         '-- $SETTING EquipOnTrackFish = {Type = "Boolean", Label = "Equip whenever Track Fish is selected"}\n'..
		         '-- $SETTING EnableAutoLoot = {Type = "Boolean", Label = "Enable auto loot while equipped"}\n'..
		         '\n'..
		         '-- Enable auto looting if the outfit is being equipped and EnableAutoLoot is on\n'..
		         '\n'..
		         'if event == "OUTFIT_EQUIPPED" then\n'..
		         '    if setting.EnableAutoLoot then\n'..
		         '        setting.savedAutoLoot = GetCVar("autoLootDefault")\n'..
		         '        SetCVar("autoLootDefault", "1")\n'..
		         '        setting.didSetAutoLoot = true\n'..
		         '    end\n'..
		         '\n'..
		         '-- Turn auto looting back off if the outfit is being unequipped and we turned it on\n'..
		         '\n'..
		         'elseif event == "OUTFIT_UNEQUIPPED" then\n'..
		         '    if setting.EnableAutoLoot and setting.didSetAutoLoot then\n'..
		         '        SetCVar("autoLootDefault", setting.savedAutoLoot)\n'..
		         '        setting.didSetAutoLoot = nil\n'..
		         '        setting.savedAutoLoot = nil\n'..
		         '    end\n'..
		         '\n'..
		         '-- If the player is entering combat then unequip the outfit\n'..
		         '\n'..
		         'elseif isEquipped and event == "PLAYER_REGEN_DISABLED" then\n'..
		         '    equip = false\n'..
		         '    outfit.didCombatUnequip = true\n'..
		         '\n'..
		         '-- If the outfit was unequipped because of combat\n'..
		         '-- then put it back on when combat is over\n'..
		         '\n'..
		         'elseif outfit.didCombatUnequip and (event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_ENTERING_WORLD") then\n'..
		         '    equip = true\n'..
		         '    outfit.didCombatUnequip = nil\n'..
		         '\n'..
		         '-- Equip the outfit when tracking is changed to Find Fish, unequip\n'..
		         '-- it if the tracking is changed to something else\n'..
		         '\n'..
		         'elseif event == "UNIT_AURA" then \n'..
		         '    if select(1, ...) ~= "player" then return end\n'..
		         '\n'..
		         '    local vTrackingFindFish = GetTrackingTexture() == "Interface\\\\Icons\\\\INV_Misc_Fish_02"\n'..
		         '    if outfit.trackingFindFish == vTrackingFindFish then return end\n'..
		         '    outfit.trackingFindFish = vTrackingFindFish\n'..
		         '\n'..
		         '    if not setting.EquipOnTrackFish then return end\n'..
		         '\n'..
		         '    if vTrackingFindFish then\n'..
		         '        equip = true\n'..
		         '        outfit.equippedByFindFish = true\n'..
		         '    elseif outfit.equippedByFindFish then\n'..
		         '        equip = false\n'..
		         '        outfit.equippedByFindFish = nil\n'..
		         '    end\n'..
		         'end\n',
	},
	{
		Name = Outfitter.cDiningOutfit,
		ID = "Dining",
		Category = "TRADE",
		Script = Outfitter:GenerateSmartUnequipScript("DINING", Outfitter.cDiningOutfitDescription),
	},
	{
		Name = Outfitter.cCityOutfit,
		ID = "City",
		Category = "GENERAL",
		Script = Outfitter:GenerateSimpleScript("CITY", Outfitter.cCityOutfitDescription),
	},
	{
		Name = Outfitter.cBattlegroundOutfit,
		ID = "Battleground",
		Category = "PVP",
		Script = Outfitter:GenerateSmartUnequipScript("BATTLEGROUND", Outfitter.cBattlegroundOutfitDescription),
	},
	{
		Name = Outfitter.cABOutfit,
		ID = "AB",
		Category = "PVP",
		Script = Outfitter:GenerateSmartUnequipScript("BATTLEGROUND_AB", Outfitter.cArathiBasinOutfitDescription),
	},
	{
		Name = Outfitter.cAVOutfit,
		ID = "AV",
		Category = "PVP",
		Script = Outfitter:GenerateSmartUnequipScript("BATTLEGROUND_AV", Outfitter.cAlteracValleyOutfitDescription),
	},
	{
		Name = Outfitter.cWSGOutfit,
		ID = "WSG",
		Category = "PVP",
		Script = Outfitter:GenerateSmartUnequipScript("BATTLEGROUND_WSG", Outfitter.cWarsongGulchOutfitDescription),
	},
	{
		Name = Outfitter.cEotSOutfit,
		ID = "EotS",
		Category = "PVP",
		Script = Outfitter:GenerateSmartUnequipScript("BATTLEGROUND_EOTS", Outfitter.cEotSOutfitDescription),
	},
	{
		Name = Outfitter.cArenaOutfit,
		ID = "Arena",
		Category = "PVP",
		Script = Outfitter:GenerateSmartUnequipScript("BATTLEGROUND_ARENA", Outfitter.cArenaOutfitDescription),
	},
	{
		Name = "Spirit Regen",
		ID = "Spirit",
		Category = "GENERAL",
		Script = Outfitter:GenerateSmartUnequipScript("SPIRIT_REGEN", Outfitter.SpiritRegenOutfitDescription, 0.5),
	},
	{
		Name = Outfitter.cWarriorBattleStance,
		ID = "Battle",
		Class = "WARRIOR",
		Script = Outfitter:GenerateShapeshiftScript("BATTLE_STANCE", Outfitter.cWarriorBattleStanceDescription),
	},
	{
		Name = Outfitter.cWarriorDefensiveStance,
		ID = "Defensive",
		Class = "WARRIOR",
		Script = Outfitter:GenerateShapeshiftScript("DEFENSIVE_STANCE", Outfitter.cWarriorDefensiveStanceDescription),
	},
	{
		Name = Outfitter.cWarriorBerserkerStance,
		ID = "Berserker",
		Class = "WARRIOR",
		Script = Outfitter:GenerateShapeshiftScript("BERSERKER_STANCE", Outfitter.cWarriorBerserkerStanceDescription),
	},
	{
		Name = Outfitter.cDruidCasterForm,
		ID = "Caster",
		Class = "DRUID",
		Script = Outfitter:GenerateScriptHeader("CASTER_FORM NOT_CASTER_FORM OUTFIT_EQUIPPED", Outfitter.cDruidCasterFormDescription)..
			'-- $SETTING DisableBG={Type="Boolean", Label="Don\'t equip in Battlegrounds", Default=false}\n'..
			'-- $SETTING DisablePVP={Type="Boolean", Label="Don\'t equip while PvP flagged", Default=false}\n'..
			'\n'..
			'-- Just return if they\'re PvP\'ing and don\'t want the outfit changing\n'..
			'\n'..
			'if (setting.DisableBG and Outfitter:InBattlegroundZone())\n'..
			'or (setting.DisablePVP and UnitIsPVP("player")) then\n'..
			'    return\n'..
			'end\n'..
			'\n'..
			'-- Return if the user isn\'t in full control\n'..
			'\n'..
			'if not Outfitter.IsDead and not HasFullControl() then\n'..
			'    return\n'..
			'end\n'..
			'\n'..
			'-- If the user is manually equipping the outfit, let\n'..
			'-- Outfitter know which layer it\'s representing\n'..
			'\n'..
			'if event == "OUTFIT_EQUIPPED" then\n'..
			'    layer = "shapeshift"\n'..
			'\n'..
			'-- Equip and set the layer if entering caster form.  When\n'..
			'-- shifting directly between forms, WoW temporarily puts\n'..
			'-- the druid in caster form.  To avoid having the caster\n'..
			'-- outfit equip during those changes, a small delay is\n'..
			'-- added to equipping so it can be canceled when the form\n'..
			'-- shift completes.\n'..
			'\n'..
			'elseif event == "CASTER_FORM" then\n'..
			'    equip = true\n'..
			'    layer = "shapeshift"\n'..
			'    delay = 0.1\n'..
			'\n'..
			'-- Unequip if leaving caster form\n'..
			'\n'..
			'else\n'..
			'    equip = false\n'..
			'end\n',
	},
	{
		Name = Outfitter.cDruidBearForm,
		ID = "Bear",
		Class = "DRUID",
		Script = Outfitter:GenerateDruidShapeshiftScript("BEAR_FORM", "This outfit will be worn whenever you're in Bear or Dire Bear Form"),
	},
	{
		Name = Outfitter.cDruidCatForm,
		ID = "Cat",
		Class = "DRUID",
		Script = Outfitter:GenerateDruidShapeshiftScript("CAT_FORM", "This outfit will be worn whenever you're in Cat Form"),
	},
	{
		Name = Outfitter.cDruidAquaticForm,
		ID = "Aquatic",
		Class = "DRUID",
		Script = Outfitter:GenerateDruidShapeshiftScript("AQUATIC_FORM", "This outfit will be worn whenever you're in Aquatic Form"),
	},
	{
		Name = Outfitter.cDruidFlightForm,
		ID = "Flight",
		Class = "DRUID",
		Script = Outfitter:GenerateDruidShapeshiftScript("FLIGHT_FORM", "This outfit will be worn whenever you're in Flight or Swift Flight Form"),
	},
	{
		Name = Outfitter.cDruidTravelForm,
		ID = "Travel",
		Class = "DRUID",
		Script = Outfitter:GenerateDruidShapeshiftScript("TRAVEL_FORM", "This outfit will be worn whenever you're in Travel Form"),
	},
	{
		Name = Outfitter.cDruidMoonkinForm,
		ID = "Moonkin",
		Class = "DRUID",
		Script = Outfitter:GenerateDruidShapeshiftScript("MOONKIN_FORM", "This outfit will be worn whenever you're in Moonkin Form"),
	},
	{
		Name = Outfitter.cDruidTreeOfLifeForm,
		ID = "Tree",
		Class = "DRUID",
		Script = Outfitter:GenerateDruidShapeshiftScript("TREE_FORM", "This outfit will be worn whenever you're in Tree Form"),
	},
	{
		Name = Outfitter.cDruidProwl,
		ID = "Prowl",
		Class = "DRUID",
		Script = Outfitter:GenerateSimpleScript("STEALTH", "This outfit will be worn whenever you're prowling"),
	},
	{
		Name = Outfitter.cRogueStealth,
		ID = "Stealth",
		Class = "ROGUE",
		Script = Outfitter:GenerateSimpleScript("STEALTH", "This outfit will be worn whenever you're stealthed"),
	},
	{
		Name = Outfitter.cPriestShadowform,
		ID = "Shadowform",
		Class = "PRIEST",
		Script = Outfitter:GenerateShapeshiftScript("SHADOWFORM", Outfitter.cPriestShadowformDescription),
	},
	{
		Name = Outfitter.cShamanGhostWolf,
		ID = "GhostWolf",
		Class = "SHAMAN",
		Script = Outfitter:GenerateSimpleScript("GHOST_WOLF", Outfitter.cShamanGhostWolfDescription),
	},
	{
		Name = Outfitter.cHunterMonkey,
		ID = "Monkey",
		Class = "HUNTER",
		Script = Outfitter:GenerateShapeshiftScript("MONKEY_ASPECT", Outfitter.cHunterMonkeyDescription),
	},
	{
		Name = Outfitter.cHunterHawk,
		ID = "Hawk",
		Class = "HUNTER",
		Script = Outfitter:GenerateShapeshiftScript("HAWK_ASPECT", Outfitter.cHunterHawkDescription),
	},
	{
		Name = Outfitter.cHunterCheetah,
		ID = "Cheetah",
		Class = "HUNTER",
		Script = Outfitter:GenerateShapeshiftScript("CHEETAH_ASPECT", Outfitter.cHunterCheetahDescription),
	},
	{
		Name = Outfitter.cHunterPack,
		ID = "Pack",
		Class = "HUNTER",
		Script = Outfitter:GenerateShapeshiftScript("PACK_ASPECT", Outfitter.cHunterPackDescription),
	},
	{
		Name = Outfitter.cHunterBeast,
		ID = "Beast",
		Class = "HUNTER",
		Script = Outfitter:GenerateShapeshiftScript("BEAST_ASPECT", Outfitter.cHunterBeastDescription),
	},
	{
		Name = Outfitter.cHunterWild,
		ID = "Wild",
		Class = "HUNTER",
		Script = Outfitter:GenerateShapeshiftScript("WILD_ASPECT", Outfitter.cHunterWildDescription),
	},
	{
		Name = Outfitter.cHunterViper,
		ID = "Viper",
		Class = "HUNTER",
		Script = Outfitter:GenerateShapeshiftScript("VIPER_ASPECT", Outfitter.cHunterViperDescription),
	},
	{
		Name = Outfitter.cHunterFeignDeath,
		ID = "Feigning",
		Class = "HUNTER",
		Script = Outfitter:GenerateSimpleScript("FEIGN_DEATH", Outfitter.cHunterFeignDeathDescription),
	},
	{
		Name = Outfitter.cMageEvocate,
		ID = "Evocate",
		Class = "MAGE",
		Script = Outfitter:GenerateSimpleScript("EVOCATE", Outfitter.cMageEvocateDescription),
	},
	{
		Name = Outfitter.cDeathknightBlood,
		ID = "Blood",
		Class = "DEATHKNIGHT",
		Script = Outfitter:GenerateSimpleScript("BLOOD", Outfitter.cDeathknightBloodDescription),
	},
	{
		Name = Outfitter.cDeathknightFrost,
		ID = "Frost",
		Class = "DEATHKNIGHT",
		Script = Outfitter:GenerateSimpleScript("FROST", Outfitter.cDeathknightFrostDescription),
	},
	{
		Name = Outfitter.cDeathknightUnholy,
		ID = "Unholy",
		Class = "DEATHKNIGHT",
		Script = Outfitter:GenerateSimpleScript("UNHOLY", Outfitter.cDeathknightUnholyDescription),
	},
	{
		Name = Outfitter.cSoloOutfit,
		ID = "SOLO",
		Category = "GENERAL",
		Script = Outfitter:GenerateScriptHeader("PLAYER_ENTERING_WORLD RAID_ROSTER_UPDATE PARTY_MEMBERS_CHANGED", Outfitter.cSoloOutfitDescription)..
			'-- $SETTING EquipSolo = {Label="Equip when solo", Type = "Boolean"}\n'..
			'-- $SETTING EquipGroup = {Label="Equip when in a party", Type = "Boolean"}\n'..
			'-- $SETTING EquipRaid = {Label="Equip when in a raid", Type = "Boolean"}\n'..
			'\n'..
			'if setting.EquipSolo\n'..
			'and GetNumRaidMembers() == 0\n'..
			'and GetNumPartyMembers() == 0 then\n'..
			'    equip = true\n'..
			'elseif setting.EquipGroup\n'..
			'and GetNumRaidMembers() == 0\n'..
			'and GetNumPartyMembers() ~= 0 then\n'..
			'    equip = true\n'..
			'elseif setting.EquipRaid\n'..
			'and GetNumRaidMembers() ~= 0 then\n'..
			'    equip = true\n'..
			'elseif didEquip then\n'..
			'    equip = false\n'..
			'end\n',
	},
	{
		Name = Outfitter.cFallingOutfit,
		ID = "FALLING",
		Category = "GENERAL",
		Script = Outfitter:GenerateScriptHeader("TIMER", Outfitter.cFallingOutfitDescription)..
			'if IsFalling() then\n'..
			'    equip = true\n'..
			'    delay = 1.5\n'..
			'elseif didEquip then\n'..
			'    equip = false\n'..
			'end\n',
	},
}

Outfitter.cScriptCategoryOrder =
{
	GENERAL = 0,
	TRADE = 1,
	PVP = 2,
}

table.sort(
		Outfitter.PresetScripts,
		function (pItem1, pItem2)
			if pItem1.Category ~= pItem2.Category then
				if not pItem1.Category then
					return true
				elseif not pItem2.Category then
					return false
				else
					return Outfitter.cScriptCategoryOrder[pItem1.Category] < Outfitter.cScriptCategoryOrder[pItem2.Category]
				end
			elseif not pItem2.Name then
				return false
			elseif not pItem1.Name then
				return true
			else
				return pItem1.Name < pItem2.Name
			end
		end)

function Outfitter:LoadString(pString)
	assert(loadstring(pString, "Outfit Script"))()
end

Outfitter.cScriptPrefix =
'Outfitter.ScriptFunc = function (self, event, ...)\n'..
'   local outfit = self.Outfit\n'..
'	if outfit.Disabled or (outfit.CombatDisabled and (Outfitter.InCombat or Outfitter.MaybeInCombat)) then return end\n'..
'	local equip, layer, delay\n'..
'	local didEquip, didUnequip, isEquipped = outfit.didEquip, outfit.didUnequip, Outfitter:WearingOutfit(outfit)\n'..
'	local time, setting = GetTime(), outfit.ScriptSettings\n'

-- User's script will be inserted here

Outfitter.cScriptSuffix =
'	self:PostProcess(equip, layer, delay, time)\n'..
'end'

Outfitter.cInputPrefix = "Outfitter.ScriptInputs={"
Outfitter.cInputSuffix = "}"

function Outfitter:LoadScript(pScript)
	local vSucceeded, vMessage = pcall(Outfitter.LoadString, Outfitter, pScript)
	
	if vMessage then
		local _, _, vLine, vMessage2 = string.find(vMessage, Outfitter.cExtractErrorFormat)
		
		if vLine then
			vMessage = string.format(Outfitter.cScriptErrorFormat, vLine, vMessage2)
		end
	end
	
	return vSucceeded, vMessage
end

function Outfitter:ParseScriptFields(pScript)
	local vSettings = {}
	local vMessage
	
	for vSetting, vValue in string.gmatch(pScript, "--%s*$([%w_]+)([^\r\n]*)") do
		vSetting = string.upper(vSetting)
		
		if vSetting == "EVENTS" then
			if not vSettings.Events then
				vSettings.Events = vValue
			else
				vSettings.Events = vSettings.Events.." "..vValue
			end
			
		elseif vSetting == "DESC" then
			vSettings.Description = vValue
		
		elseif vSetting == "SETTING" then
			local vScript = Outfitter.cInputPrefix..vValue..Outfitter.cInputSuffix
			local vSucceeded
			
			Outfitter.ScriptInputs = nil
			
			vSucceeded, vMessage = Outfitter:LoadScript(vScript)
			
			if not vSucceeded then
				return nil, vMessage
			end
			
			if Outfitter.ScriptInputs then
				if not vSettings.Inputs then
					vSettings.Inputs = {}
				end
				
				for vKey, vValue in pairs(Outfitter.ScriptInputs) do
					if type(vValue) == "string" then
						vValue = {Type = vValue, Label = vKey}
						
						if vValue.Type ~= "Boolean" then
							vValue.Label = vValue.Label..":"
						end
					end
					
					vValue.Field = vKey
					table.insert(vSettings.Inputs, vValue)
				end
				
				Outfitter.ScriptInputs = nil
			end
		end
	end
	
	return vSettings
end

function Outfitter:LoadOutfitScript(pScript)
	local vScript = Outfitter.cScriptPrefix..pScript..Outfitter.cScriptSuffix

	Outfitter.ScriptFunc = nil
	
	local vSucceeded, vMessage = Outfitter:LoadScript(vScript)
	local vScriptFunc = Outfitter.ScriptFunc
	
	Outfitter.ScriptFunc = nil
	
	return vScriptFunc, vMessage
end

function Outfitter:ActivateScript(pOutfit)
	local vScript = Outfitter:GetScript(pOutfit)
	
	if gOutfitter_Settings.Options.DisableAutoSwitch
	or pOutfit.Disabled
	or not vScript then
		return
	end
	
	local vScriptFields = Outfitter:ParseScriptFields(vScript)
	local vScriptSettings = {}
	
	if not vScriptFields then
		return
	end
	
	if not vScriptFields.Events then
		Outfitter:ErrorMessage("The script for %s does not specify any events", pOutfit.Name)
		return
	end
	
	-- Initialize the settings to their defaults
	
	if not pOutfit.ScriptSettings then
		pOutfit.ScriptSettings = {}
	end
	
	if vScriptFields.Inputs then
		for _, vDescriptor in ipairs(vScriptFields.Inputs) do
			local vDefault = vDescriptor.Default
			
			if vDefault == nil then
				local vType = string.lower(vDescriptor.Type)
				local vTypeInfo = Outfitter.SettingTypeInfo[vType]
				
				if not vTypeInfo then
					Outfitter:ErrorMessage("Script for outfit %s has an unknown $SETTING type (%s)", pOutfit.Name, vDescriptor.Type or "nil")
					return
				end
				
				vDefault = vTypeInfo.Default -- Override the built-in default if the $SETTING specifies its own default
			end
			
			-- Set to the default if the value is missing or if
			-- it's the wrong type
			
			if pOutfit.ScriptSettings[vDescriptor.Field] == nil
			or type(pOutfit.ScriptSettings[vDescriptor.Field]) ~= type(vDefault) then	
				pOutfit.ScriptSettings[vDescriptor.Field] = vDefault
			end
		end
	end
	
	local vScriptContext, vErrorMessage = Outfitter._ScriptContext:NewContext(pOutfit, vScript)
	
	if not vScriptContext then
		Outfitter:ErrorMessage("Couldn't activate script for %s", pOutfit.Name)
		Outfitter:ErrorMessage(vErrorMessage)
		return
	end
	
	Outfitter.ScriptContexts[pOutfit] = vScriptContext
	
	for vEventID in string.gmatch(vScriptFields.Events, "([%w%d_]+)") do
		vScriptContext:RegisterEvent(vEventID)
	end
	
	self:DispatchOutfitEvent("INITIALIZE", pOutfit.Name, pOutfit)
end

function Outfitter:DeactivateScript(pOutfit)
	self:DispatchOutfitEvent("TERMINATE", pOutfit.Name, pOutfit)
	
	if Outfitter.ScriptContexts[pOutfit] then
		Outfitter.ScriptContexts[pOutfit]:UnregisterAllEvents()
		Outfitter.ScriptContexts[pOutfit] = nil
	end
end

function Outfitter:OutfitHasScript(pOutfit)
	return  pOutfit.ScriptID ~= nil or pOutfit.Script ~= nil
end

function Outfitter:GetScriptDescription(pScript)
	if not pScript then
		return
	end
	
	local vScriptFields = Outfitter:ParseScriptFields(pScript)
	
	if not vScriptFields then
		return
	end
	
	return vScriptFields.Description
end

function Outfitter:ScriptHasSettings(pScript)
	if not pScript then
		return
	end
	
	local vScriptFields = Outfitter:ParseScriptFields(pScript)
	
	if not vScriptFields then
		return
	end
	
	return vScriptFields.Inputs ~= nil and #vScriptFields.Inputs ~= 0
end

function Outfitter:ActivateAllScripts()
	for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
		for vOutfitIndex, vOutfit in ipairs(vOutfits) do
			vOutfit.LastScriptTime = nil
			vOutfit.ScriptLockupCount = 0
			Outfitter:ActivateScript(vOutfit)
		end
	end
end

function Outfitter:DeactivateAllScripts()
	for vCategoryID, vOutfits in pairs(gOutfitter_Settings.Outfits) do
		for vOutfitIndex, vOutfit in ipairs(vOutfits) do
			Outfitter:DeactivateScript(vOutfit)
		end
	end
end

function Outfitter:GetPresetScriptByID(pID)
	for _, vPresetScript in ipairs(Outfitter.PresetScripts) do
		if vPresetScript.ID == pID then
			return vPresetScript
		end
	end
end

function Outfitter:FindMatchingPresetScriptID(pScript)
	for _, vPresetScript in ipairs(Outfitter.PresetScripts) do
		if vPresetScript.Script == pScript then
			return vPresetScript.ID
		end
	end
end

----------------------------------------
Outfitter._ScriptContext = {}
----------------------------------------

function Outfitter._ScriptContext:NewContext(pOutfit, pScript)
	local vFunction, vMessage = Outfitter:LoadOutfitScript(pScript)
	
	if not vFunction then
		return nil, vMessage
	end
	
	return Outfitter:NewObject(self, pOutfit, vFunction)
end

function Outfitter._ScriptContext:Construct(pOutfit, pFunction)
	self.Outfit = pOutfit
	self.Function = pFunction
	
	if not pFunction then
		Outfitter:ErrorMessage("Internal error: Attempting to create a script context with a nil function")
	end
end

function Outfitter._ScriptContext:RegisterEvent(pEventID)
	if pEventID == "OUTFIT_EQUIPPED"
	or pEventID == "OUTFIT_UNEQUIPPED" then
		if not Outfitter.OutfitScriptEvents[pEventID] then
			Outfitter.OutfitScriptEvents[pEventID] = {}
		end
		
		Outfitter.OutfitScriptEvents[pEventID][self.Outfit] = self
	else
		MCEventLib:RegisterEvent(pEventID, self.Function, self)
	end
end

function Outfitter._ScriptContext:UnregisterEvent(pEventID)
	if pEventID == "OUTFIT_EQUIPPED"
	or pEventID == "OUTFIT_UNEQUIPPED" then
		Outfitter.OutfitScriptEvents[pEventID][self.Outfit] = nil
	else
		MCEventLib:UnregisterEvent(pEventID, self.Function, self)
	end
end

function Outfitter._ScriptContext:UnregisterAllEvents(pEventID)
	for vEventID, vOutfits in pairs(Outfitter.OutfitScriptEvents) do
		vOutfits[self.Outfit] = nil
	end
	
	MCEventLib:UnregisterAllEvents(self.Function, self)
end

function Outfitter._ScriptContext:Debug(pFormat, ...)
	Outfitter:NoteMessage("["..self.Outfit.Name.."] "..pFormat, ...)
end

function Outfitter._ScriptContext:PostProcess(pEquip, pLayer, pDelay, pStartTime)
	-- If the script took a long time to run and it hasn't been very long since
	-- the last time we'll increment a counter.  If that counters gets too high
	-- we can assume the script is misbehaving and shut it down
	
	local vTime = GetTime()
	
	if vTime - pStartTime > 0.1
	and self.Outfit.LastScriptTime
	and pStartTime - self.LastScriptTime < 0.5 then
		if not self.ScriptLockupCount then
			self.ScriptLockupCount = 1
		else
			self.ScriptLockupCount = self.ScriptLockupCount + 1
			
			if self.ScriptLockupCount > 20 then
				Outfitter:ErrorMessage("Excessive CPU time in script for %s, script deactivated.", self.Outfit.Name or "<unnamed>")
				Outfitter:DeactivateScript(self.Outfit)
			end
		end
	else
		self.ScriptLockupCount = 0
	end
	
	self.LastScriptTime = pStartTime
	
	--
	
	if pEquip ~= nil then
		local vChanged
		
		Outfitter:BeginEquipmentUpdate()
		
		if pEquip then
			if not Outfitter:WearingOutfit(self.Outfit) then
				Outfitter:WearOutfit(self.Outfit, pLayer, true)
				vChanged = true
			end
		else
			if Outfitter:WearingOutfit(self.Outfit) then
				Outfitter:RemoveOutfit(self.Outfit, true)
				vChanged = true
			end
		end
		
		-- Adjust the last equipped time to cause a delay if requested
		
		if vChanged and pDelay then
			Outfitter:SetUpdateDelay(pStartTime, pDelay)
		end
		
		Outfitter:EndEquipmentUpdate()
	elseif pLayer then
		Outfitter:TagOutfitLayer(self.Outfit, pLayer)
	end
end

