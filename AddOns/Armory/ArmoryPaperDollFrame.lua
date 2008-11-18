--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmoryPaperDollFrame.lua,v 1.44, 2008-11-14 11:29:21Z, Maxim Baars$
    URL: http://www.wow-neighbours.com

    License:
        This program is free software; you can redistribute it and/or
        modify it under the terms of the GNU General Public License
        as published by the Free Software Foundation; either version 2
        of the License, or (at your option) any later version.

        This program is distributed in the hope that it will be useful,
        but WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        GNU General Public License for more details.

        You should have received a copy of the GNU General Public License
        along with this program(see GPL.txt); if not, write to the Free Software
        Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

    Note:
        This AddOn's source code is specifically designed to work with
        World of Warcraft's interpreted AddOn system.
        You have an implicit licence to use this AddOn with these facilities
        since that is it's designated purpose as per:
        http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]] 


ARMORY_SLOTINFO = {
    INVTYPE_2HWEAPON = "MainHandSlot", 
    INVTYPE_BODY = "ShirtSlot",
    INVTYPE_CHEST = "ChestSlot",
    INVTYPE_CLOAK = "BackSlot",
    INVTYPE_CROSSBOW = "RangedSlot",
    INVTYPE_FEET = "FeetSlot",
    INVTYPE_FINGER = "Finger0Slot",
    INVTYPE_FINGER_OTHER = "Finger1Slot",
    INVTYPE_GUN = "RangedSlot",
    INVTYPE_HAND = "HandsSlot",
    INVTYPE_HEAD = "HeadSlot",
    INVTYPE_HOLDABLE = "SecondaryHandSlot",
    INVTYPE_LEGS = "LegsSlot",
    INVTYPE_NECK = "NeckSlot",
    INVTYPE_RANGED = "RangedSlot",
    INVTYPE_RANGEDRIGHT = "RangedSlot",
    INVTYPE_RELIC = "RangedSlot",
    INVTYPE_ROBE = "ChestSlot",
    INVTYPE_SHIELD = "SecondaryHandSlot",
    INVTYPE_SHOULDER = "ShoulderSlot",
    INVTYPE_TABARD = "TabardSlot",
    INVTYPE_THROWN = "RangedSlot",
    INVTYPE_TRINKET = "Trinket0Slot",
    INVTYPE_TRINKET_OTHER = "Trinket1Slot",
    INVTYPE_WAIST = "WaistSlot",
    INVTYPE_WEAPON = "MainHandSlot",
    INVTYPE_WEAPON_OTHER = "SecondaryHandSlot",
    INVTYPE_WEAPONMAINHAND = "MainHandSlot",
    INVTYPE_WEAPONOFFHAND = "SecondaryHandSlot",
    INVTYPE_WRIST = "WristSlot",
    INVTYPE_WAND = "RangedSlot"
};

ARMORY_ANCHOR_SLOTINFO = {
    RIGHT = {point="TOPLEFT",    relativeTo="TOPRIGHT",   xFactor= 1, yFactor=-1, x= 0, y=6},
    LEFT  = {point="TOPRIGHT",   relativeTo="TOPLEFT",    xFactor=-1, yFactor=-1, x= 0, y=6},
    DOWN  = {point="TOPLEFT",    relativeTo="BOTTOMLEFT", xFactor= 1, yFactor=-1, x=-6, y=0},
    UP    = {point="BOTTOMLEFT", relativeTo="TOPLEFT",    xFactor= 1, yFactor= 1, x=-6, y=0}
};

ARMORY_MAX_ALTERNATE_SLOTS = 3;
ARMORY_ALTERNATE_SLOT_SIZE = 40;

function ArmoryPaperDollTalentFrame_OnLoad(self)
    self:RegisterEvent("CHARACTER_POINTS_CHANGED");
    self:RegisterEvent("SPELLS_CHANGED");
end

function ArmoryPaperDollTalentFrame_OnEvent(self, event, ...)
    if ( Armory:CanHandleEvents() ) then
        Armory:Execute(ArmoryPaperDollFrame_UpdateTalent);
    end
end

function ArmoryPaperDollTradeSkillFrame_Update(skillFrame, values)
    local label = getglobal(skillFrame:GetName().."Label");
    local statusbar = getglobal(skillFrame:GetName().."Bar");
    local bartext = getglobal(skillFrame:GetName().."BarText");
    local icon = getglobal(skillFrame:GetName().."ButtonIcon");

    if ( not values ) then
        skillFrame:Hide();
    else
        local skillName, skillRank, skillMaxRank = unpack(values);

        SetPortraitToTexture(icon, Armory:GetProfessionTexture(skillName));
        label:SetText(strupper(skillName));
        statusbar:SetMinMaxValues(0, skillMaxRank);
        statusbar:SetValue(skillRank);
        bartext:SetText(skillRank.." / "..skillMaxRank);
        skillFrame:Show();
    end
end

function ArmoryHealth_OnLoad(self)
    self:RegisterEvent("UNIT_HEALTH");
    self:RegisterEvent("UNIT_MAXHEALTH");
    ArmoryHealthTextFrameLabel:SetText(strupper(HEALTH)..":");
    self.tooltipTitle = HEALTH;
    self.tooltipText = NEWBIE_TOOLTIP_HEALTHBAR;
end

function ArmoryHealth_OnEvent(self, event, ...)
    local arg1 = ...;
    if ( Armory:CanHandleEvents() and arg1 == "player" ) then
        Armory:Execute(ArmoryPaperDollFrame_UpdateHealthBar);
    end
end

function ArmoryMana_UpdateManaType()
	local powerType, powerToken = Armory:UnitPowerType("player");
	local prefix = getglobal(powerToken);
	local info = PowerBarColor[powerToken];
	if ( not info ) then
		-- couldn't find a power token entry...default to indexing by power type or just mana if we don't have that either
		info = PowerBarColor[powerType] or PowerBarColor["MANA"];
	end
    ArmoryManaBar:SetStatusBarColor(info.r, info.g, info.b);
    ArmoryManaTextFrameLabel:SetText(strupper(prefix)..":");
    ArmoryMana.tooltipTitle = prefix;
    ArmoryMana.tooltipText = getglobal("NEWBIE_TOOLTIP_MANABAR"..powerType);
end

function ArmoryMana_OnLoad(self)
    self:RegisterEvent("UNIT_MANA");
    self:RegisterEvent("UNIT_RAGE");
    self:RegisterEvent("UNIT_FOCUS");
    self:RegisterEvent("UNIT_ENERGY");
    self:RegisterEvent("UNIT_MAXMANA");
    self:RegisterEvent("UNIT_MAXRAGE");
    self:RegisterEvent("UNIT_MAXFOCUS");
    self:RegisterEvent("UNIT_MAXENERGY");
    self:RegisterEvent("UNIT_DISPLAYPOWER");
end

function ArmoryMana_OnEvent(self, event, ...)
    local arg1 = ...;
    if ( Armory:CanHandleEvents() and arg1 == "player" ) then
        Armory:Execute(ArmoryPaperDollFrame_UpdateManaBar);
    end
end

function ArmoryPaperDollItemSlotButton_Update(button)
    local unit = "player";
    local textureName = Armory:GetInventoryItemTexture(unit, button:GetID());
    if ( textureName ) then
        SetItemButtonTexture(button, textureName);
        SetItemButtonCount(button, Armory:GetInventoryItemCount(unit, button:GetID()));
        button.hasItem = 1;
    else
        local textureName = button.backgroundTextureName;
        if ( button.checkRelic and Armory:UnitHasRelicSlot(unit) ) then
            textureName = "Interface\\Paperdoll\\UI-PaperDoll-Slot-Relic.blp";
        end
        SetItemButtonTexture(button, textureName);
        SetItemButtonCount(button, 0);
        button.hasItem = nil;
    end
    Armory:SetInventoryItem("player", button:GetID(), true);
    button.link = Armory:GetInventoryItemLink(unit, button:GetID());
end

function ArmoryPaperDollItemSlotButton_OnLoad(self)
    local slotName = self:GetName();
    local id;
    local textureName; 
    local checkRelic;
    id, textureName, checkRelic = GetInventorySlotInfo(strsub(slotName,7));
    self:SetID(id);
    local texture = getglobal(slotName.."IconTexture");
    texture:SetTexture(textureName);
    self.backgroundTextureName = textureName;
    self.checkRelic = checkRelic;
end

function ArmoryPaperDollItemSlotButton_OnEnter(self)
    self.anchor = "ANCHOR_RIGHT";
    if ( self:GetID() >= 16 and self:GetID() <= 18 ) then
        ArmoryAlternateSlotFrame_Show(self, "VERTICAL", "DOWN");
    elseif ( self:GetID() ~= 9 and self:GetID() >= 6 and self:GetID() <= 14 ) then
        self.anchor = "ANCHOR_LEFT";
        ArmoryAlternateSlotFrame_Show(self, "HORIZONTAL", "RIGHT");
    else
        ArmoryAlternateSlotFrame_Show(self, "HORIZONTAL", "LEFT");
    end
    GameTooltip:SetOwner(self, self.anchor);
    if ( not Armory:SetInventoryItem("player", self:GetID()) ) then
        local text = getglobal(strupper(strsub(self:GetName(), 7)));
        if ( self.checkRelic and Armory:UnitHasRelicSlot("player") ) then
            text = getglobal("RELICSLOT");
        end
        GameTooltip:SetText(text);
    end
end

function ArmoryPaperDollResistanceTooltip(self)
    if ( self.tooltip ) then
        GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
        GameTooltip:SetText(self.tooltip, 1.0,1.0,1.0);
        GameTooltip:AddLine(self.tooltipSubtext, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
        GameTooltip:Show();
    end
end

function ArmoryPlayerStatFrameLeftDropDown_OnLoad(self)
    ArmoryDropDownMenu_Initialize(self, ArmoryPlayerStatFrameLeftDropDown_Initialize);
    ArmoryDropDownMenu_SetSelectedValue(self, ARMORY_PLAYERSTAT_LEFTDROPDOWN_SELECTION);
    ArmoryDropDownMenu_SetWidth(self, 99);
    ArmoryDropDownMenu_JustifyText(self, "LEFT");
end

function ArmoryPlayerStatFrameLeftDropDown_Initialize()
    -- Setup buttons
    local info = ArmoryDropDownMenu_CreateInfo();
    local checked;
    for i=1, getn(PLAYERSTAT_DROPDOWN_OPTIONS) do
        if ( PLAYERSTAT_DROPDOWN_OPTIONS[i] == ARMORY_PLAYERSTAT_LEFTDROPDOWN_SELECTION ) then
            checked = 1;
        else
            checked = nil;
        end
        info.text = getglobal(PLAYERSTAT_DROPDOWN_OPTIONS[i]);
        info.func = ArmoryPlayerStatFrameLeftDropDown_OnClick;
        info.value = PLAYERSTAT_DROPDOWN_OPTIONS[i];
        info.checked = checked;
        info.owner = ARMORY_DROPDOWNMENU_OPEN_MENU;
        ArmoryDropDownMenu_AddButton(info);
    end
end

function ArmoryPlayerStatFrameLeftDropDown_OnClick(self)
    ArmoryDropDownMenu_SetSelectedValue(getglobal(self.owner), self.value);
    ARMORY_PLAYERSTAT_LEFTDROPDOWN_SELECTION = self.value;
    ArmoryUpdatePaperDollStats("ArmoryPlayerStatFrameLeft", self.value);
end

function ArmoryPlayerStatFrameRightDropDown_OnLoad(self)
    ArmoryDropDownMenu_Initialize(self, ArmoryPlayerStatFrameRightDropDown_Initialize);
    ArmoryDropDownMenu_SetSelectedValue(self, ARMORY_PLAYERSTAT_RIGHTDROPDOWN_SELECTION);
    ArmoryDropDownMenu_SetWidth(self, 99);
    ArmoryDropDownMenu_JustifyText(self, "LEFT");
end

function ArmoryPlayerStatFrameRightDropDown_Initialize()
    -- Setup buttons
    local info = ArmoryDropDownMenu_CreateInfo();
    local checked;
    for i=1, getn(PLAYERSTAT_DROPDOWN_OPTIONS) do
        if ( PLAYERSTAT_DROPDOWN_OPTIONS[i] == ARMORY_PLAYERSTAT_RIGHTDROPDOWN_SELECTION ) then
            checked = 1;
        else
            checked = nil;
        end
        info.text = getglobal(PLAYERSTAT_DROPDOWN_OPTIONS[i]);
        info.func = ArmoryPlayerStatFrameRightDropDown_OnClick;
        info.value = PLAYERSTAT_DROPDOWN_OPTIONS[i];
        info.checked = checked;
        info.owner = ARMORY_DROPDOWNMENU_OPEN_MENU;
        ArmoryDropDownMenu_AddButton(info);
    end
end

function ArmoryPlayerStatFrameRightDropDown_OnClick(self)
    ArmoryDropDownMenu_SetSelectedValue(getglobal(self.owner), self.value);
    ARMORY_PLAYERSTAT_RIGHTDROPDOWN_SELECTION = self.value;
    ArmoryUpdatePaperDollStats("ArmoryPlayerStatFrameRight", self.value);
end

function ArmoryPaperDollFrame_SetGuild()
    local guildName, title, rank = Armory:GetGuildInfo("player");
    if ( guildName ) then
        ArmoryGuildText:Show();
        ArmoryGuildText:SetFormattedText(GUILD_TITLE_TEMPLATE, title, guildName);
    else
        ArmoryGuildText:Hide();
    end
end

function ArmoryPaperDollFrame_SetLevel()
    local unit = "player";
    local currXP = Armory:UnitXP(unit);
    local nextXP = Armory:UnitXPMax(unit);
    local text = format(PLAYER_LEVEL, Armory:UnitLevel(unit), Armory:UnitRace(unit), Armory:UnitClass(unit));
    local restXP, timestamp = Armory:GetXPExhaustion();
    local isResting = Armory:IsResting();

    if ( (nextXP or 0) > 0 ) then
        local percentXP = floor((currXP * 100) / nextXP);
        if ( percentXP > 0 ) then
            text = text.." ("..XP.." "..percentXP.."%";
            if ( timestamp and (restXP or 0) > 0 ) then
                percentXP = (restXP * 100) / nextXP;
                if ( isResting ) then
                    -- 5% of max XP is earned every 8 hours spent resting in an inn or capital city
                    percentXP = percentXP + ((time() - timestamp) / (8 * 60 * 60)) * 5;
                else
                    -- 5% of max XP is earned every 32 hours spent resting outside
                    percentXP = percentXP + ((time() - timestamp) / (32 * 60 * 60)) * 5;
                end
                percentXP = floor(min(percentXP, 150));
                if ( percentXP > 0 ) then
                    text = text.." R "..percentXP.."%";
                end
            end
            text = text..")";
        end
    end
    ArmoryLevelText:SetText(text);
end

function ArmoryPaperDollFrame_SetZone()
    local zoneName = Armory:GetZoneText();
    local subzoneName = Armory:GetSubZoneText();
    if ( subzoneName == zoneName ) then
        subzoneName = "";    
    end

    -- backwards compatible...
    if ( zoneName ) then
        if ( subzoneName ~= "" ) then
            zoneName = zoneName..", "..subzoneName;
        end
        ArmoryZoneText:Show();
        ArmoryZoneText:SetText(zoneName);
    else
        ArmoryZoneText:Hide();
    end
end

function ArmoryPaperDollFrame_SetResistances()
    for i=1, NUM_RESISTANCE_TYPES, 1 do
        local resistance;
        local positive;
        local negative;
        local resistanceLevel
        local base;
        local text = getglobal("ArmoryMagicResText"..i);
        local frame = getglobal("ArmoryMagicResFrame"..i);

        base, resistance, positive, negative = Armory:UnitResistance("player", frame:GetID());
        local petBonus = Armory:ComputePetBonus( "PET_BONUS_RES", resistance );

        local resistanceName = getglobal("RESISTANCE"..(frame:GetID()).."_NAME");
        frame.tooltip = resistanceName.." "..resistance;

        -- resistances can now be negative. Show Red if negative, Green if positive, white otherwise
        if( abs(negative) > positive ) then
            text:SetText(RED_FONT_COLOR_CODE..resistance..FONT_COLOR_CODE_CLOSE);
        elseif( abs(negative) == positive ) then
            text:SetText(resistance);
        else
            text:SetText(GREEN_FONT_COLOR_CODE..resistance..FONT_COLOR_CODE_CLOSE);
        end

        if ( positive ~= 0 or negative ~= 0 ) then
            -- Otherwise build up the formula
            frame.tooltip = frame.tooltip.. " ( "..HIGHLIGHT_FONT_COLOR_CODE..base;
            if( positive > 0 ) then
                frame.tooltip = frame.tooltip..GREEN_FONT_COLOR_CODE.." +"..positive;
            end
            if( negative < 0 ) then
                frame.tooltip = frame.tooltip.." "..RED_FONT_COLOR_CODE..negative;
            end
            frame.tooltip = frame.tooltip..FONT_COLOR_CODE_CLOSE.." )";
        end
        local unitLevel = Armory:UnitLevel("player");
        unitLevel = max(unitLevel, 20);
        local magicResistanceNumber = resistance/unitLevel;
        if ( magicResistanceNumber > 5 ) then
            resistanceLevel = RESISTANCE_EXCELLENT;
        elseif ( magicResistanceNumber > 3.75 ) then
            resistanceLevel = RESISTANCE_VERYGOOD;
        elseif ( magicResistanceNumber > 2.5 ) then
            resistanceLevel = RESISTANCE_GOOD;
        elseif ( magicResistanceNumber > 1.25 ) then
            resistanceLevel = RESISTANCE_FAIR;
        elseif ( magicResistanceNumber > 0 ) then
            resistanceLevel = RESISTANCE_POOR;
        else
            resistanceLevel = RESISTANCE_NONE;
        end
        frame.tooltipSubtext = format(RESISTANCE_TOOLTIP_SUBTEXT, getglobal("RESISTANCE_TYPE"..frame:GetID()), unitLevel, resistanceLevel);

        if( petBonus > 0 ) then
            frame.tooltipSubtext = frame.tooltipSubtext .. "\n" .. format(PET_BONUS_TOOLTIP_RESISTANCE, petBonus);
        end
    end
end

function ArmoryPaperDollFrame_SetStat(statFrame, statIndex)
    local label = getglobal(statFrame:GetName().."Label");
    local text = getglobal(statFrame:GetName().."StatText");
    local stat;
    local effectiveStat;
    local posBuff;
    local negBuff;
    stat, effectiveStat, posBuff, negBuff = Armory:UnitStat("player", statIndex);
    local statName = getglobal("SPELL_STAT"..statIndex.."_NAME");
    label:SetText(statName..":");

    -- Set the tooltip text
    local tooltipText = HIGHLIGHT_FONT_COLOR_CODE..statName.." ";

    if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
        text:SetText(effectiveStat);
        statFrame.tooltip = tooltipText..effectiveStat..FONT_COLOR_CODE_CLOSE;
    else 
        tooltipText = tooltipText..effectiveStat;
        if ( posBuff > 0 or negBuff < 0 ) then
            tooltipText = tooltipText.." ("..(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE;
        end
        if ( posBuff > 0 ) then
            tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..posBuff..FONT_COLOR_CODE_CLOSE;
        end
        if ( negBuff < 0 ) then
            tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..negBuff..FONT_COLOR_CODE_CLOSE;
        end
        if ( posBuff > 0 or negBuff < 0 ) then
            tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
        end
        statFrame.tooltip = tooltipText;

        -- If there are any negative buffs then show the main number in red even if there are
        -- positive buffs. Otherwise show in green.
        if ( negBuff < 0 ) then
            text:SetText(RED_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE);
        else
            text:SetText(GREEN_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE);
        end
    end
    statFrame.tooltip2 = getglobal("DEFAULT_STAT"..statIndex.."_TOOLTIP");
    local _, unitClass = Armory:UnitClass("player");
    unitClass = strupper(unitClass);

    if ( statIndex == 1 ) then
        local attackPower = GetAttackPowerForStat(statIndex, effectiveStat);
        statFrame.tooltip2 = format(statFrame.tooltip2, attackPower);
        if ( unitClass == "WARRIOR" or unitClass == "SHAMAN" or unitClass == "PALADIN" ) then
            statFrame.tooltip2 = statFrame.tooltip2 .. "\n" .. format( STAT_BLOCK_TOOLTIP, max(0, effectiveStat*BLOCK_PER_STRENGTH-10) );
        end
    elseif ( statIndex == 3 ) then
        local baseStam = min(20, effectiveStat);
        local moreStam = effectiveStat - baseStam;
           statFrame.tooltip2 = format(statFrame.tooltip2, (baseStam + (moreStam*HEALTH_PER_STAMINA))*Armory:GetUnitMaxHealthModifier("player"));
        local petStam = Armory:ComputePetBonus( "PET_BONUS_STAM", effectiveStat );
        if( petStam > 0 ) then
            statFrame.tooltip2 = statFrame.tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_STAMINA, petStam);
        end
    elseif ( statIndex == 2 ) then
        local attackPower = GetAttackPowerForStat(statIndex, effectiveStat);
        if ( attackPower > 0 ) then
            statFrame.tooltip2 = format(STAT_ATTACK_POWER, attackPower) .. format(statFrame.tooltip2, Armory:GetCritChanceFromAgility("player"), effectiveStat*ARMOR_PER_AGILITY);
        else
            statFrame.tooltip2 = format(statFrame.tooltip2, Armory:GetCritChanceFromAgility("player"), effectiveStat*ARMOR_PER_AGILITY);
        end
    elseif ( statIndex == 4 ) then
        local baseInt = min(20, effectiveStat);
        local moreInt = effectiveStat - baseInt
        if ( Armory:UnitHasMana("player") ) then
            statFrame.tooltip2 = format(statFrame.tooltip2, baseInt + moreInt*MANA_PER_INTELLECT, Armory:GetSpellCritChanceFromIntellect("player"));
        else
            statFrame.tooltip2 = nil;
        end
        local petInt = Armory:ComputePetBonus("PET_BONUS_INT", effectiveStat );
        if( petInt > 0 ) then
            if ( not statFrame.tooltip2 ) then
                statFrame.tooltip2 = "";
            end
            statFrame.tooltip2 = statFrame.tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_INTELLECT, petInt);
        end
    elseif ( statIndex == 5 ) then
        -- All mana regen stats are displayed as mana/5 sec.
        statFrame.tooltip2 = format(statFrame.tooltip2, Armory:GetUnitHealthRegenRateFromSpirit("player"));
        if ( Armory:UnitHasMana("player") ) then
            local regen = Armory:GetUnitManaRegenRateFromSpirit("player");
            regen = floor( regen * 5.0 );
            statFrame.tooltip2 = statFrame.tooltip2.."\n"..format(MANA_REGEN_FROM_SPIRIT, regen);
        end
    end
    statFrame:Show();
end 

function ArmoryPaperDollFrame_SetArmor(statFrame, unit)
    if ( not unit ) then
        unit = "player";
    end
    local base, effectiveArmor, armor, posBuff, negBuff = Armory:UnitArmor(unit);
    getglobal(statFrame:GetName().."Label"):SetText(ARMOR_COLON);
    local text = getglobal(statFrame:GetName().."StatText");

    PaperDollFormatStat(ARMOR, base, posBuff, negBuff, statFrame, text);
    local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, Armory:UnitLevel(unit));
    statFrame.tooltip2 = format(DEFAULT_STATARMOR_TOOLTIP, armorReduction);

    if ( unit == "player" ) then
        local petBonus = Armory:ComputePetBonus( "PET_BONUS_ARMOR", effectiveArmor );
        if( petBonus > 0 ) then
            statFrame.tooltip2 = statFrame.tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_ARMOR, petBonus);
        end
    end

    statFrame:Show();
end

function ArmoryPaperDollFrame_SetAttackBothHands(statFrame, unit)
    if ( not unit ) then
        unit = "player";
    end
    local mainHandAttackBase, mainHandAttackMod, offHandAttackBase, offHandAttackMod = Armory:UnitAttackBothHands(unit);

    getglobal(statFrame:GetName().."Label"):SetText(COMBAT_RATING_NAME1..":");
    local text = getglobal(statFrame:GetName().."StatText");

    if( mainHandAttackMod == 0 ) then
        text:SetText(mainHandAttackBase);
    else
        local color = RED_FONT_COLOR_CODE;
        if( mainHandAttackMod > 0 ) then
            color = GREEN_FONT_COLOR_CODE;
        end
        text:SetText(color..(mainHandAttackBase + mainHandAttackMod)..FONT_COLOR_CODE_CLOSE);
    end

    if( mainHandAttackMod == 0 ) then
        statFrame.weaponSkill = COMBAT_RATING_NAME1.." "..mainHandAttackBase;
    else
        local color = RED_FONT_COLOR_CODE;
        statFrame.weaponSkill = COMBAT_RATING_NAME1.." "..(mainHandAttackBase + mainHandAttackMod).." ("..mainHandAttackBase..color.." "..mainHandAttackMod..")";
        if( mainHandAttackMod > 0 ) then
            color = GREEN_FONT_COLOR_CODE;
            statFrame.weaponSkill = COMBAT_RATING_NAME1.." "..(mainHandAttackBase + mainHandAttackMod).." ("..mainHandAttackBase..color.." +"..mainHandAttackMod..FONT_COLOR_CODE_CLOSE..")";
        end
    end

    local total = Armory:GetCombatRating(CR_WEAPON_SKILL) + Armory:GetCombatRating(CR_WEAPON_SKILL_MAINHAND);
    statFrame.weaponRating = format(WEAPON_SKILL_RATING, total);
    if ( total > 0 ) then
        statFrame.weaponRating = statFrame.weaponRating..format(WEAPON_SKILL_RATING_BONUS, Armory:GetCombatRatingBonus(CR_WEAPON_SKILL) + Armory:GetCombatRatingBonus(CR_WEAPON_SKILL_MAINHAND));
    end

    local speed, offhandSpeed = Armory:UnitAttackSpeed(unit);
    if ( offhandSpeed ) then
        if( offHandAttackMod == 0 ) then
            statFrame.offhandSkill = COMBAT_RATING_NAME1.." "..offHandAttackBase;
        else
            local color = RED_FONT_COLOR_CODE;
            statFrame.offhandSkill = COMBAT_RATING_NAME1.." "..(offHandAttackBase + offHandAttackMod).." ("..offHandAttackBase..color.." "..offHandAttackMod..")";
            if( offHandAttackMod > 0 ) then
                color = GREEN_FONT_COLOR_CODE;
                statFrame.offhandSkill = COMBAT_RATING_NAME1.." "..(offHandAttackBase + offHandAttackMod).." ("..offHandAttackBase..color.." +"..offHandAttackMod..FONT_COLOR_CODE_CLOSE..")";
            end
        end

        total = Armory:GetCombatRating(CR_WEAPON_SKILL) + Armory:GetCombatRating(CR_WEAPON_SKILL_OFFHAND);
        statFrame.offhandRating = format(WEAPON_SKILL_RATING, total);
        if ( total > 0 ) then
            statFrame.offhandRating = statFrame.offhandRating..format(WEAPON_SKILL_RATING_BONUS, Armory:GetCombatRatingBonus(CR_WEAPON_SKILL) + Armory:GetCombatRatingBonus(CR_WEAPON_SKILL_OFFHAND));
        end
    else
        statFrame.offhandSkill = nil;
    end

    statFrame:Show();
end

function ArmoryPaperDollFrame_SetAttackSpeed(statFrame, unit)
    if ( not unit ) then
        unit = "player";
    end
    local speed, offhandSpeed = Armory:UnitAttackSpeed(unit);
    speed = format("%.2f", speed);
    if ( offhandSpeed ) then
        offhandSpeed = format("%.2f", offhandSpeed);
    end
    local text;    
    if ( offhandSpeed ) then
        text = speed.." / "..offhandSpeed;
    else
        text = speed;
    end
    ArmoryPaperDollFrame_SetLabelAndText(statFrame, WEAPON_SPEED, text);

    statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..ATTACK_SPEED.." "..text..FONT_COLOR_CODE_CLOSE;
    statFrame.tooltip2 = format(CR_HASTE_RATING_TOOLTIP, Armory:GetCombatRating(CR_HASTE_MELEE), Armory:GetCombatRatingBonus(CR_HASTE_MELEE));

    statFrame:Show();
end

function ArmoryPaperDollFrame_SetAttackPower(statFrame, unit)
    if ( not unit ) then
        unit = "player";
    end    
    getglobal(statFrame:GetName().."Label"):SetText(ATTACK_POWER_COLON);
    local text = getglobal(statFrame:GetName().."StatText");
    local base, posBuff, negBuff = Armory:UnitAttackPower(unit);

    PaperDollFormatStat(MELEE_ATTACK_POWER, base, posBuff, negBuff, statFrame, text);
    statFrame.tooltip2 = format(MELEE_ATTACK_POWER_TOOLTIP, max((base+posBuff+negBuff), 0)/ATTACK_POWER_MAGIC_NUMBER);

    statFrame:Show();
end

function ArmoryPaperDollFrame_SetBlock(statFrame)
    local chance = Armory:GetBlockChance();

    ArmoryPaperDollFrame_SetLabelAndText(statFrame, STAT_BLOCK, chance, 1);
    statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..getglobal("BLOCK_CHANCE").." "..string.format("%.02f", chance).."%"..FONT_COLOR_CODE_CLOSE;
    statFrame.tooltip2 = format(CR_BLOCK_TOOLTIP, Armory:GetCombatRating(CR_BLOCK), Armory:GetCombatRatingBonus(CR_BLOCK), Armory:GetShieldBlock());

    statFrame:Show();
end

function ArmoryPaperDollFrame_SetDamage(statFrame, unit)
    if ( not unit ) then
        unit = "player";
    end
    getglobal(statFrame:GetName().."Label"):SetText(DAMAGE_COLON);
    local text = getglobal(statFrame:GetName().."StatText");
    local speed, offhandSpeed = Armory:UnitAttackSpeed(unit);

    local minDamage;
    local maxDamage; 
    local minOffHandDamage;
    local maxOffHandDamage; 
    local physicalBonusPos;
    local physicalBonusNeg;
    local percent;
    minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = Armory:UnitDamage(unit);
    local displayMin = max(floor(minDamage),1);
    local displayMax = max(ceil(maxDamage),1);

    minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg;
    maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg;

    local baseDamage = (minDamage + maxDamage) * 0.5;
    local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
    local totalBonus = (fullDamage - baseDamage);
    local damagePerSecond = (max(fullDamage,1) / speed);
    local damageTooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1);

    local colorPos = "|cff20ff20";
    local colorNeg = "|cffff2020";

    -- epsilon check
    if ( totalBonus < 0.1 and totalBonus > -0.1 ) then
        totalBonus = 0.0;
    end

    if ( totalBonus == 0 ) then
        if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
            text:SetText(displayMin.." - "..displayMax);    
        else
            text:SetText(displayMin.."-"..displayMax);
        end
    else

        local color;
        if ( totalBonus > 0 ) then
            color = colorPos;
        else
            color = colorNeg;
        end
        if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
            text:SetText(color..displayMin.." - "..displayMax.."|r");    
        else
            text:SetText(color..displayMin.."-"..displayMax.."|r");
        end
        if ( physicalBonusPos > 0 ) then
            damageTooltip = damageTooltip..colorPos.." +"..physicalBonusPos.."|r";
        end
        if ( physicalBonusNeg < 0 ) then
            damageTooltip = damageTooltip..colorNeg.." "..physicalBonusNeg.."|r";
        end
        if ( percent > 1 ) then
            damageTooltip = damageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";
        elseif ( percent < 1 ) then
            damageTooltip = damageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
        end

    end
    statFrame.damage = damageTooltip;
    statFrame.attackSpeed = speed;
    statFrame.dps = damagePerSecond;

    -- If there's an offhand speed then add the offhand info to the tooltip
    if ( offhandSpeed ) then
        minOffHandDamage = (minOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;
        maxOffHandDamage = (maxOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;

        local offhandBaseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5;
        local offhandFullDamage = (offhandBaseDamage + physicalBonusPos + physicalBonusNeg) * percent;
        local offhandDamagePerSecond = (max(offhandFullDamage,1) / offhandSpeed);
        local offhandDamageTooltip = max(floor(minOffHandDamage),1).." - "..max(ceil(maxOffHandDamage),1);
        if ( physicalBonusPos > 0 ) then
            offhandDamageTooltip = offhandDamageTooltip..colorPos.." +"..physicalBonusPos.."|r";
        end
        if ( physicalBonusNeg < 0 ) then
            offhandDamageTooltip = offhandDamageTooltip..colorNeg.." "..physicalBonusNeg.."|r";
        end
        if ( percent > 1 ) then
            offhandDamageTooltip = offhandDamageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";
        elseif ( percent < 1 ) then
            offhandDamageTooltip = offhandDamageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
        end
        statFrame.offhandDamage = offhandDamageTooltip;
        statFrame.offhandAttackSpeed = offhandSpeed;
        statFrame.offhandDps = offhandDamagePerSecond;
    else
        statFrame.offhandAttackSpeed = nil;
    end

    statFrame:Show();
end

function ArmoryPaperDollFrame_SetDefense(statFrame, unit)
    if ( not unit ) then
        unit = "player";
    end
    local base, modifier = Armory:UnitDefense(unit);
    local posBuff = 0;
    local negBuff = 0;
    if ( modifier > 0 ) then
        posBuff = modifier;
    elseif ( modifier < 0 ) then
        negBuff = modifier;
    end
    getglobal(statFrame:GetName().."Label"):SetText(DEFENSE_COLON);
    local text = getglobal(statFrame:GetName().."StatText");

    PaperDollFormatStat(DEFENSE, base, posBuff, negBuff, statFrame, text);
    local defensePercent = Armory:GetDodgeBlockParryChanceFromDefense();
    statFrame.tooltip2 = format(DEFAULT_STATDEFENSE_TOOLTIP, Armory:GetCombatRating(CR_DEFENSE_SKILL), Armory:GetCombatRatingBonus(CR_DEFENSE_SKILL), defensePercent, defensePercent);

    statFrame:Show();
end

function ArmoryPaperDollFrame_SetDodge(statFrame)
    local chance = Armory:GetDodgeChance();

    ArmoryPaperDollFrame_SetLabelAndText(statFrame, STAT_DODGE, chance, 1);
    statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..getglobal("DODGE_CHANCE").." "..string.format("%.02f", chance).."%"..FONT_COLOR_CODE_CLOSE;
    statFrame.tooltip2 = format(CR_DODGE_TOOLTIP, Armory:GetCombatRating(CR_DODGE), Armory:GetCombatRatingBonus(CR_DODGE));

    statFrame:Show();
end

function ArmoryPaperDollFrame_SetLabelAndText(statFrame, label, text, isPercentage)
    getglobal(statFrame:GetName().."Label"):SetText(label..":");
    if ( isPercentage ) then
        text = format("%.2f%%", text);
    end
    getglobal(statFrame:GetName().."StatText"):SetText(text);
end

function ArmoryPaperDollFrame_SetManaRegen(statFrame)
    getglobal(statFrame:GetName().."Label"):SetText(MANA_REGEN..":");
    local text = getglobal(statFrame:GetName().."StatText");
    if ( not Armory:UnitHasMana("player") ) then
        text:SetText(NOT_APPLICABLE);
        statFrame.tooltip = nil;
        return;
    end

    local base, casting = Armory:GetManaRegen();
    -- All mana regen stats are displayed as mana/5 sec.
    base = floor( base * 5.0 );
    casting = floor( casting * 5.0 );
    text:SetText(base);
    statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. MANA_REGEN .. FONT_COLOR_CODE_CLOSE;
    statFrame.tooltip2 = format(MANA_REGEN_TOOLTIP, base, casting);

    statFrame:Show();
end

function ArmoryPaperDollFrame_SetExpertise(statFrame, unit)
    if ( not unit ) then
        unit = "player";
    end
    local expertise, offhandExpertise = Armory:GetExpertise();
    local speed, offhandSpeed = Armory:UnitAttackSpeed(unit);
    local text;
    if( offhandSpeed ) then
        text = expertise.." / "..offhandExpertise;
    else
        text = expertise;
    end
    ArmoryPaperDollFrame_SetLabelAndText(statFrame, STAT_EXPERTISE, text);

    statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..getglobal("COMBAT_RATING_NAME"..CR_EXPERTISE).." "..text..FONT_COLOR_CODE_CLOSE;

    local expertisePercent, offhandExpertisePercent = Armory:GetExpertisePercent();
    expertisePercent = format("%.2f", expertisePercent);
    if( offhandSpeed ) then
        offhandExpertisePercent = format("%.2f", offhandExpertisePercent);
        text = expertisePercent.."% / "..offhandExpertisePercent.."%";
    else
        text = expertisePercent.."%";
    end
    statFrame.tooltip2 = format(CR_EXPERTISE_TOOLTIP, text, Armory:GetCombatRating(CR_EXPERTISE), Armory:GetCombatRatingBonus(CR_EXPERTISE));

    statFrame:Show();
end

function ArmoryPaperDollFrame_SetMeleeCritChance(statFrame)
    getglobal(statFrame:GetName().."Label"):SetText(MELEE_CRIT_CHANCE..":");
    local text = getglobal(statFrame:GetName().."StatText");
    local critChance = Armory:GetCritChance();
    critChance = format("%.2f%%", critChance);
    text:SetText(critChance);
    statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..MELEE_CRIT_CHANCE.." "..critChance..FONT_COLOR_CODE_CLOSE;
    statFrame.tooltip2 = format(CR_CRIT_MELEE_TOOLTIP, Armory:GetCombatRating(CR_CRIT_MELEE), Armory:GetCombatRatingBonus(CR_CRIT_MELEE));
end

function ArmoryPaperDollFrame_SetParry(statFrame)
    local chance = Armory:GetParryChance();
    ArmoryPaperDollFrame_SetLabelAndText(statFrame, STAT_PARRY, chance, 1);

    statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..getglobal("PARRY_CHANCE").." "..string.format("%.02f", chance).."%"..FONT_COLOR_CODE_CLOSE;
    statFrame.tooltip2 = format(CR_PARRY_TOOLTIP, Armory:GetCombatRating(CR_PARRY), Armory:GetCombatRatingBonus(CR_PARRY));

    statFrame:Show();
end

function ArmoryPaperDollFrame_SetResilience(statFrame)
    local melee = Armory:GetCombatRating(CR_CRIT_TAKEN_MELEE);
    local ranged = Armory:GetCombatRating(CR_CRIT_TAKEN_RANGED);
    local spell = Armory:GetCombatRating(CR_CRIT_TAKEN_SPELL);

    local minResilience = min(melee, ranged);
    minResilience = min(minResilience, spell);

    local lowestRating = CR_CRIT_TAKEN_MELEE;
    if ( melee == minResilience ) then
        lowestRating = CR_CRIT_TAKEN_MELEE;
    elseif ( ranged == minResilience ) then
        lowestRating = CR_CRIT_TAKEN_RANGED;
    else
        lowestRating = CR_CRIT_TAKEN_SPELL;
    end

    local maxRatingBonus = Armory:GetMaxCombatRatingBonus(lowestRating);
    local lowestRatingBonus = Armory:GetCombatRatingBonus(lowestRating);

    ArmoryPaperDollFrame_SetLabelAndText(statFrame, STAT_RESILIENCE, minResilience);
    statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..STAT_RESILIENCE.." "..minResilience..FONT_COLOR_CODE_CLOSE;
    statFrame.tooltip2 = format(RESILIENCE_TOOLTIP, lowestRatingBonus, min(lowestRatingBonus * RESILIENCE_CRIT_CHANCE_TO_DAMAGE_REDUCTION_MULTIPLIER, maxRatingBonus), lowestRatingBonus);

    statFrame:Show();
end

function ArmoryPaperDollFrame_SetRangedAttack(statFrame, unit)
    if ( not unit ) then
        unit = "player";
    elseif ( unit == "pet" ) then
        return;
    end

    local hasRelic = Armory:UnitHasRelicSlot(unit);
    local rangedAttackBase, rangedAttackMod = Armory:UnitRangedAttack(unit);
    getglobal(statFrame:GetName().."Label"):SetText(COMBAT_RATING_NAME1..":");
    local text = getglobal(statFrame:GetName().."StatText");

    -- If no ranged texture then set stats to n/a
    local rangedTexture = Armory:GetInventoryItemTexture("player", 18);
    if ( rangedTexture and not hasRelic ) then
        ArmoryPaperDollFrame.noRanged = nil;
    else
        text:SetText(NOT_APPLICABLE);
        ArmoryPaperDollFrame.noRanged = 1;
        statFrame.tooltip = nil;
    end
    if ( not rangedTexture or hasRelic ) then
        return;
    end

    if( rangedAttackMod == 0 ) then
        text:SetText(rangedAttackBase);
        statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..COMBAT_RATING_NAME1.." "..rangedAttackBase..FONT_COLOR_CODE_CLOSE;
    else
        local color = RED_FONT_COLOR_CODE;
        if( rangedAttackMod > 0 ) then
              color = GREEN_FONT_COLOR_CODE;
            statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..COMBAT_RATING_NAME1.." "..(rangedAttackBase + rangedAttackMod).." ("..rangedAttackBase..color.." +"..rangedAttackMod..FONT_COLOR_CODE_CLOSE..HIGHLIGHT_FONT_COLOR_CODE..")";
        else
            statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..COMBAT_RATING_NAME1.." "..(rangedAttackBase + rangedAttackMod).." ("..rangedAttackBase..color.." "..rangedAttackMod..FONT_COLOR_CODE_CLOSE..HIGHLIGHT_FONT_COLOR_CODE..")";
        end
        text:SetText(color..(rangedAttackBase + rangedAttackMod)..FONT_COLOR_CODE_CLOSE);
    end
    local total = Armory:GetCombatRating(CR_WEAPON_SKILL) + Armory:GetCombatRating(CR_WEAPON_SKILL_RANGED);
    statFrame.tooltip2 = format(WEAPON_SKILL_RATING, total);
    if ( total > 0 ) then
        statFrame.tooltip2 = statFrame.tooltip2..format(WEAPON_SKILL_RATING_BONUS, Armory:GetCombatRatingBonus(CR_WEAPON_SKILL) + Armory:GetCombatRatingBonus(CR_WEAPON_SKILL_RANGED));
    end

    statFrame:Show();
end

function ArmoryPaperDollFrame_SetRangedDamage(statFrame, unit)
    if ( not unit ) then
        unit = "player";
    elseif ( unit == "pet" ) then
        return;
    end
    getglobal(statFrame:GetName().."Label"):SetText(DAMAGE_COLON);
    local text = getglobal(statFrame:GetName().."StatText");

    -- If no ranged attack then set to n/a
    local hasRelic = Armory:UnitHasRelicSlot(unit);    
    local rangedTexture = Armory:GetInventoryItemTexture("player", 18);
    if ( rangedTexture and not hasRelic ) then
        ArmoryPaperDollFrame.noRanged = nil;
    else
        text:SetText(NOT_APPLICABLE);
        ArmoryPaperDollFrame.noRanged = 1;
        statFrame.damage = nil;
        return;
    end

    local rangedAttackSpeed, minDamage, maxDamage, physicalBonusPos, physicalBonusNeg, percent = Armory:UnitRangedDamage(unit);
    local displayMin = max(floor(minDamage),1);
    local displayMax = max(ceil(maxDamage),1);

    local baseDamage;
    local fullDamage;
    local totalBonus;
    local damagePerSecond;
    local tooltip;

    if ( Armory:HasWandEquipped() ) then
        baseDamage = (minDamage + maxDamage) * 0.5;
        fullDamage = baseDamage * percent;
        totalBonus = 0;
        if ( rangedAttackSpeed == 0 ) then
            damagePerSecond = 0;
        else
            damagePerSecond = (max(fullDamage,1) / rangedAttackSpeed);
        end
        tooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1);
    else
        minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg;
        maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg;

        baseDamage = (minDamage + maxDamage) * 0.5;
        fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
        totalBonus = (fullDamage - baseDamage);
        if ( rangedAttackSpeed == 0 ) then
            damagePerSecond = 0;
        else
            damagePerSecond = (max(fullDamage,1) / rangedAttackSpeed);
        end
        tooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1);
    end

    if ( totalBonus == 0 ) then
        if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
            text:SetText(displayMin.." - "..displayMax);    
        else
            text:SetText(displayMin.."-"..displayMax);
        end
    else
        local colorPos = "|cff20ff20";
        local colorNeg = "|cffff2020";
        local color;
        if ( totalBonus > 0 ) then
            color = colorPos;
        else
            color = colorNeg;
        end
        if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
            text:SetText(color..displayMin.." - "..displayMax.."|r");    
        else
            text:SetText(color..displayMin.."-"..displayMax.."|r");
        end
        if ( physicalBonusPos > 0 ) then
            tooltip = tooltip..colorPos.." +"..physicalBonusPos.."|r";
        end
        if ( physicalBonusNeg < 0 ) then
            tooltip = tooltip..colorNeg.." "..physicalBonusNeg.."|r";
        end
        if ( percent > 1 ) then
            tooltip = tooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";
        elseif ( percent < 1 ) then
            tooltip = tooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
        end
        statFrame.tooltip = tooltip.." "..format(DPS_TEMPLATE, damagePerSecond);
    end
    statFrame.attackSpeed = rangedAttackSpeed;
    statFrame.damage = tooltip;
    statFrame.dps = damagePerSecond;

    statFrame:Show();
end

function ArmoryPaperDollFrame_SetRangedAttackSpeed(statFrame, unit)
    if ( not unit ) then
        unit = "player";
    elseif ( unit == "pet" ) then
        return;
    end
    local text;
    -- If no ranged attack then set to n/a
    if ( ArmoryPaperDollFrame.noRanged ) then
        text = NOT_APPLICABLE;
        statFrame.tooltip = nil;
    else
        text = Armory:UnitRangedDamage(unit);
        text = format("%.2f", text);
        statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..ATTACK_SPEED.." "..text..FONT_COLOR_CODE_CLOSE;
    end
    ArmoryPaperDollFrame_SetLabelAndText(statFrame, WEAPON_SPEED, text);
    statFrame.tooltip2 = format(CR_HASTE_RATING_TOOLTIP, Armory:GetCombatRating(CR_HASTE_RANGED), Armory:GetCombatRatingBonus(CR_HASTE_RANGED));

    statFrame:Show();
end

function ArmoryPaperDollFrame_SetRangedAttackPower(statFrame, unit)
    if ( not unit ) then
        unit = "player";
    end    
    getglobal(statFrame:GetName().."Label"):SetText(ATTACK_POWER_COLON);
    local text = getglobal(statFrame:GetName().."StatText");
    local base, posBuff, negBuff = Armory:UnitRangedAttackPower(unit);

    PaperDollFormatStat(RANGED_ATTACK_POWER, base, posBuff, negBuff, statFrame, text);
    local totalAP = base+posBuff+negBuff;
    statFrame.tooltip2 = format(RANGED_ATTACK_POWER_TOOLTIP, max((totalAP), 0)/ATTACK_POWER_MAGIC_NUMBER);
    local petAPBonus = Armory:ComputePetBonus( "PET_BONUS_RAP_TO_AP", totalAP );
    if( petAPBonus > 0 ) then
        statFrame.tooltip2 = statFrame.tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_RANGED_ATTACK_POWER, petAPBonus);
    end

    local petSpellDmgBonus = Armory:ComputePetBonus( "PET_BONUS_RAP_TO_SPELLDMG", totalAP );
    if( petSpellDmgBonus > 0 ) then
        statFrame.tooltip2 = statFrame.tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_SPELLDAMAGE, petSpellDmgBonus);
    end

    statFrame:Show();
end

function ArmoryPaperDollFrame_SetRating(statFrame, ratingIndex)
    local label = getglobal(statFrame:GetName().."Label");
    local text = getglobal(statFrame:GetName().."StatText");
    local statName = getglobal("COMBAT_RATING_NAME"..ratingIndex);
    label:SetText(statName..":");
    local rating = Armory:GetCombatRating(ratingIndex);
    local ratingBonus = Armory:GetCombatRatingBonus(ratingIndex);
    text:SetText(rating);

    -- Set the tooltip text
    statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..statName.." "..rating..FONT_COLOR_CODE_CLOSE;
    -- Can probably axe this if else tree if all rating tooltips follow the same format
    if ( ratingIndex == CR_HIT_MELEE ) then
        statFrame.tooltip2 = format(CR_HIT_MELEE_TOOLTIP, Armory:UnitLevel("player"), ratingBonus, Armory:GetCombatRating(CR_ARMOR_PENETRATION), Armory:GetArmorPenetration());
    elseif ( ratingIndex == CR_HIT_RANGED ) then
        statFrame.tooltip2 = format(CR_HIT_RANGED_TOOLTIP, Armory:UnitLevel("player"), ratingBonus, Armory:GetCombatRating(CR_ARMOR_PENETRATION), Armory:GetArmorPenetration());
    elseif ( ratingIndex == CR_DODGE ) then
        statFrame.tooltip2 = format(CR_DODGE_TOOLTIP, ratingBonus);
    elseif ( ratingIndex == CR_PARRY ) then
        statFrame.tooltip2 = format(CR_PARRY_TOOLTIP, ratingBonus);
    elseif ( ratingIndex == CR_BLOCK ) then
        statFrame.tooltip2 = format(CR_PARRY_TOOLTIP, ratingBonus);
    elseif ( ratingIndex == CR_HIT_SPELL ) then
        statFrame.tooltip2 = format(CR_HIT_SPELL_TOOLTIP, Armory:UnitLevel("player"), ratingBonus, Armory:GetSpellPenetration(), Armory:GetSpellPenetration());
    elseif ( ratingIndex == CR_CRIT_SPELL ) then
        local holySchool = 2;
        local minCrit = Armory:GetSpellCritChance(holySchool);
        statFrame.spellCrit = {};
        statFrame.spellCrit[holySchool] = minCrit;
        local spellCrit;
        for i=(holySchool+1), MAX_SPELL_SCHOOLS do
            spellCrit = Armory:GetSpellCritChance(i);
            minCrit = min(minCrit, spellCrit);
            statFrame.spellCrit[i] = spellCrit;
        end
        minCrit = format("%.2f%%", minCrit);
        statFrame.minCrit = minCrit;
    elseif ( ratingIndex == CR_EXPERTISE ) then
        statFrame.tooltip2 = format(CR_EXPERTISE_TOOLTIP, ratingBonus);
    else
        statFrame.tooltip2 = HIGHLIGHT_FONT_COLOR_CODE..getglobal("COMBAT_RATING_NAME"..ratingIndex).." "..rating;    
    end

    statFrame:Show();
end

function ArmoryPaperDollFrame_SetRangedCritChance(statFrame)
    getglobal(statFrame:GetName().."Label"):SetText(RANGED_CRIT_CHANCE..":");
    local text = getglobal(statFrame:GetName().."StatText");
    local critChance = Armory:GetRangedCritChance();-- + Armory:GetCritChanceFromAgility();
    critChance = format("%.2f%%", critChance);
    text:SetText(critChance);
    statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..RANGED_CRIT_CHANCE.." "..critChance..FONT_COLOR_CODE_CLOSE;
    statFrame.tooltip2 = format(CR_CRIT_RANGED_TOOLTIP, Armory:GetCombatRating(CR_CRIT_RANGED), Armory:GetCombatRatingBonus(CR_CRIT_RANGED));
end

function ArmoryPaperDollFrame_SetSpellBonusDamage(statFrame)
    getglobal(statFrame:GetName().."Label"):SetText(BONUS_DAMAGE..":");
    local text = getglobal(statFrame:GetName().."StatText");
    local holySchool = 2;
    -- Start at 2 to skip physical damage
    local minModifier = Armory:GetSpellBonusDamage(holySchool);
    statFrame.bonusDamage = {};
    statFrame.bonusDamage[holySchool] = minModifier;
    local bonusDamage;
    for i=(holySchool+1), MAX_SPELL_SCHOOLS do
        bonusDamage = Armory:GetSpellBonusDamage(i);
        minModifier = min(minModifier, bonusDamage);
        statFrame.bonusDamage[i] = bonusDamage;
    end
    text:SetText(minModifier);
    statFrame.minModifier = minModifier;

    statFrame:Show();
end

function ArmoryPaperDollFrame_SetSpellBonusHealing(statFrame)
    getglobal(statFrame:GetName().."Label"):SetText(BONUS_HEALING..":");
    local text = getglobal(statFrame:GetName().."StatText");
    local bonusHealing = Armory:GetSpellBonusHealing();
    text:SetText(bonusHealing);
    statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. BONUS_HEALING .. FONT_COLOR_CODE_CLOSE;
    statFrame.tooltip2 =format(BONUS_HEALING_TOOLTIP, bonusHealing);

    statFrame:Show();
end

function ArmoryPaperDollFrame_SetSpellCritChance(statFrame)
    getglobal(statFrame:GetName().."Label"):SetText(SPELL_CRIT_CHANCE..":");
    local text = getglobal(statFrame:GetName().."StatText");
    local holySchool = 2;
    -- Start at 2 to skip physical damage
    local minCrit = Armory:GetSpellCritChance(holySchool);
    statFrame.spellCrit = {};
    statFrame.spellCrit[holySchool] = minCrit;
    local spellCrit;
    for i=(holySchool+1), MAX_SPELL_SCHOOLS do
        spellCrit = Armory:GetSpellCritChance(i);
        minCrit = min(minCrit, spellCrit);
        statFrame.spellCrit[i] = spellCrit;
    end
    -- Add agility contribution
    --minCrit = minCrit + Armory:GetSpellCritChanceFromIntellect();
    minCrit = format("%.2f%%", minCrit);
    text:SetText(minCrit);
    statFrame.minCrit = minCrit;
    statFrame:Show();
end

function ArmoryPaperDollFrame_SetSpellHaste(statFrame)
    getglobal(statFrame:GetName().."Label"):SetText(SPELL_HASTE..":");
    local text = getglobal(statFrame:GetName().."StatText");
    text:SetText(Armory:GetCombatRating(CR_HASTE_SPELL));

    statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. SPELL_HASTE .. FONT_COLOR_CODE_CLOSE;
    statFrame.tooltip2 = format(SPELL_HASTE_TOOLTIP, Armory:GetCombatRatingBonus(CR_HASTE_SPELL));

    statFrame:Show();
end

function ArmoryPaperDollFrame_SetSpellPenetration(statFrame)
    getglobal(statFrame:GetName().."Label"):SetText(SPELL_PENETRATION..":");
    local text = getglobal(statFrame:GetName().."StatText");
    text:SetText(Armory:GetSpellPenetration());

    statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. SPELL_PENETRATION .. FONT_COLOR_CODE_CLOSE;
    statFrame.tooltip2 = SPELL_PENETRATION_TOOLTIP;

    statFrame:Show();
end

function ArmoryUpdatePaperDollStats(prefix, index)
    local stat1 = getglobal(prefix..1);
    local stat2 = getglobal(prefix..2);
    local stat3 = getglobal(prefix..3);
    local stat4 = getglobal(prefix..4);
    local stat5 = getglobal(prefix..5);
    local stat6 = getglobal(prefix..6);

    stat1.tooltip = nil;
    stat2.tooltip = nil;
    stat3.tooltip = nil;
    stat4.tooltip = nil;
    stat5.tooltip = nil;
    stat6.tooltip = nil;

    -- reset any OnEnter scripts that may have been changed
    stat1:SetScript("OnEnter", PaperDollStatTooltip);
    stat2:SetScript("OnEnter", PaperDollStatTooltip);
    stat4:SetScript("OnEnter", PaperDollStatTooltip);

    stat6:Show();

    if ( index == "PLAYERSTAT_BASE_STATS" or not Armory.hasStats ) then
        ArmoryPaperDollFrame_SetStat(stat1, 1);
        ArmoryPaperDollFrame_SetStat(stat2, 2);
        ArmoryPaperDollFrame_SetStat(stat3, 3);
        ArmoryPaperDollFrame_SetStat(stat4, 4);
        ArmoryPaperDollFrame_SetStat(stat5, 5);
        ArmoryPaperDollFrame_SetArmor(stat6);
    end
    if ( index == "PLAYERSTAT_MELEE_COMBAT" or not Armory.hasStats ) then
        ArmoryPaperDollFrame_SetDamage(stat1);
        ArmoryPaperDollFrame_SetAttackSpeed(stat2);
        ArmoryPaperDollFrame_SetAttackPower(stat3);
        ArmoryPaperDollFrame_SetRating(stat4, CR_HIT_MELEE);
        ArmoryPaperDollFrame_SetMeleeCritChance(stat5);
        ArmoryPaperDollFrame_SetExpertise(stat6);
        if ( index == "PLAYERSTAT_MELEE_COMBAT" ) then
            stat1:SetScript("OnEnter", ArmoryDamageFrame_OnEnter);
        end
    end
    if ( index == "PLAYERSTAT_RANGED_COMBAT" or not Armory.hasStats ) then
        ArmoryPaperDollFrame_SetRangedDamage(stat1);
        ArmoryPaperDollFrame_SetRangedAttackSpeed(stat2);
        ArmoryPaperDollFrame_SetRangedAttackPower(stat3);
        ArmoryPaperDollFrame_SetRating(stat4, CR_HIT_RANGED);
        ArmoryPaperDollFrame_SetRangedCritChance(stat5);
        stat6:Hide();
        if ( index == "PLAYERSTAT_RANGED_COMBAT" ) then
            stat1:SetScript("OnEnter", ArmoryRangedDamageFrame_OnEnter);
        end
    end
    if ( index == "PLAYERSTAT_SPELL_COMBAT" or not Armory.hasStats ) then
        ArmoryPaperDollFrame_SetSpellBonusDamage(stat1);
        ArmoryPaperDollFrame_SetSpellBonusHealing(stat2);
        ArmoryPaperDollFrame_SetRating(stat3, CR_HIT_SPELL);
        ArmoryPaperDollFrame_SetSpellCritChance(stat4);
        ArmoryPaperDollFrame_SetSpellHaste(stat5);
        ArmoryPaperDollFrame_SetManaRegen(stat6);
        if ( index == "PLAYERSTAT_SPELL_COMBAT" ) then
            stat1:SetScript("OnEnter", ArmorySpellBonusDamage_OnEnter);
            stat4:SetScript("OnEnter", ArmorySpellCritChance_OnEnter);
        end
    end
    if ( index == "PLAYERSTAT_DEFENSES" or not Armory.hasStats ) then
        ArmoryPaperDollFrame_SetArmor(stat1);
        ArmoryPaperDollFrame_SetDefense(stat2);
        ArmoryPaperDollFrame_SetDodge(stat3);
        ArmoryPaperDollFrame_SetParry(stat4);
        ArmoryPaperDollFrame_SetBlock(stat5);
        ArmoryPaperDollFrame_SetResilience(stat6);
    end

    Armory.hasStats = true;
end

function ArmoryAttackFrame_OnEnter(self)
    -- Main hand weapon
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(INVTYPE_WEAPONMAINHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
    GameTooltip:AddLine(self.weaponSkill);
    GameTooltip:AddLine(self.weaponRating);
    -- Check for offhand weapon
    if ( self.offhandSkill ) then
        GameTooltip:AddLine("\n");
        GameTooltip:AddLine(INVTYPE_WEAPONOFFHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
        GameTooltip:AddLine(self.offhandSkill);
        GameTooltip:AddLine(self.offhandRating);
    end
    GameTooltip:Show();
end

function ArmoryDamageFrame_OnEnter(self)
    -- Main hand weapon
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    if ( self == ArmoryPetDamageFrame ) then
        GameTooltip:SetText(INVTYPE_WEAPONMAINHAND_PET, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
    else
        GameTooltip:SetText(INVTYPE_WEAPONMAINHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
    end
    GameTooltip:AddDoubleLine(ATTACK_SPEED_COLON, format("%.2f", self.attackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
    GameTooltip:AddDoubleLine(DAMAGE_COLON, self.damage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
    GameTooltip:AddDoubleLine(DAMAGE_PER_SECOND, format("%.1f", self.dps), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
    -- Check for offhand weapon
    if ( self.offhandAttackSpeed ) then
        GameTooltip:AddLine("\n");
        GameTooltip:AddLine(INVTYPE_WEAPONOFFHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
        GameTooltip:AddDoubleLine(ATTACK_SPEED_COLON, format("%.2f", self.offhandAttackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
        GameTooltip:AddDoubleLine(DAMAGE_COLON, self.offhandDamage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
        GameTooltip:AddDoubleLine(DAMAGE_PER_SECOND, format("%.1f", self.offhandDps), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
    end
    GameTooltip:Show();
end

function ArmoryRangedDamageFrame_OnEnter(self)
    if ( not self.damage ) then
        return;
    end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(INVTYPE_RANGED, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
    GameTooltip:AddDoubleLine(ATTACK_SPEED_COLON, format("%.2f", self.attackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
    GameTooltip:AddDoubleLine(DAMAGE_COLON, self.damage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
    GameTooltip:AddDoubleLine(DAMAGE_PER_SECOND, format("%.1f", self.dps), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
    GameTooltip:Show();
end

function ArmorySpellBonusDamage_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..BONUS_DAMAGE.." "..self.minModifier..FONT_COLOR_CODE_CLOSE);
    for i=2, MAX_SPELL_SCHOOLS do
        GameTooltip:AddDoubleLine(getglobal("DAMAGE_SCHOOL"..i), self.bonusDamage[i], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
        GameTooltip:AddTexture("Interface\\PaperDollInfoFrame\\SpellSchoolIcon"..i);
    end

    local petStr, damage;
    if( self.bonusDamage[6] > self.bonusDamage[3] ) then
        petStr = PET_BONUS_TOOLTIP_WARLOCK_SPELLDMG_SHADOW;
        damage = self.bonusDamage[6];
    else
        petStr = PET_BONUS_TOOLTIP_WARLOCK_SPELLDMG_FIRE;
        damage = self.bonusDamage[3];
    end

    local petBonusAP = Armory:ComputePetBonus("PET_BONUS_SPELLDMG_TO_AP", damage );
    local petBonusDmg = Armory:ComputePetBonus("PET_BONUS_SPELLDMG_TO_SPELLDMG", damage );
    if( petBonusAP > 0 or petBonusDmg > 0 ) then
        GameTooltip:AddLine("\n" .. format(petStr, petBonusAP, petBonusDmg), nil, nil, nil, 1 );
    end
    GameTooltip:Show();
end

function ArmorySpellCritChance_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..COMBAT_RATING_NAME11.." "..Armory:GetCombatRating(11)..FONT_COLOR_CODE_CLOSE);
    local spellCrit;
    for i=2, MAX_SPELL_SCHOOLS do
        spellCrit = format("%.2f", self.spellCrit[i]);
        spellCrit = spellCrit.."%";
        GameTooltip:AddDoubleLine(getglobal("DAMAGE_SCHOOL"..i), spellCrit, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
        GameTooltip:AddTexture("Interface\\PaperDollInfoFrame\\SpellSchoolIcon"..i);
    end
    GameTooltip:Show();
end

function ArmoryPaperDollFrame_SetStatDropDown()
    local _, classFileName = Armory:UnitClass("player");
    classFileName = strupper(classFileName);
    ARMORY_PLAYERSTAT_LEFTDROPDOWN_SELECTION = "PLAYERSTAT_BASE_STATS";
    if ( classFileName == "MAGE" or classFileName == "PRIEST" or classFileName == "WARLOCK" or classFileName == "DRUID" ) then
        ARMORY_PLAYERSTAT_RIGHTDROPDOWN_SELECTION = "PLAYERSTAT_SPELL_COMBAT";
    elseif ( classFileName == "HUNTER" ) then
        ARMORY_PLAYERSTAT_RIGHTDROPDOWN_SELECTION = "PLAYERSTAT_RANGED_COMBAT";
    else
        ARMORY_PLAYERSTAT_RIGHTDROPDOWN_SELECTION = "PLAYERSTAT_MELEE_COMBAT";
    end
end

function ArmoryPaperDollFrame_ResetStatDropDown()
    ArmoryPaperDollFrame_SetStatDropDown();
    ArmoryDropDownMenu_SetSelectedValue(ArmoryPlayerStatFrameLeftDropDown, ARMORY_PLAYERSTAT_LEFTDROPDOWN_SELECTION);
    ArmoryDropDownMenu_SetSelectedValue(ArmoryPlayerStatFrameRightDropDown, ARMORY_PLAYERSTAT_RIGHTDROPDOWN_SELECTION);
    ArmoryUpdatePaperDollStats("ArmoryPlayerStatFrameLeft", ARMORY_PLAYERSTAT_LEFTDROPDOWN_SELECTION);    
    ArmoryUpdatePaperDollStats("ArmoryPlayerStatFrameRight", ARMORY_PLAYERSTAT_RIGHTDROPDOWN_SELECTION);    
end

function ArmoryPaperDollFrame_OnLoad(self)
    self:RegisterEvent("VARIABLES_LOADED");
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("UNIT_LEVEL");
    self:RegisterEvent("UNIT_DAMAGE");
    self:RegisterEvent("PLAYER_DAMAGE_DONE_MODS");
    self:RegisterEvent("UNIT_RESISTANCES");
    self:RegisterEvent("UNIT_ATTACK_POWER");
    self:RegisterEvent("UNIT_ATTACK_SPEED");
    self:RegisterEvent("UNIT_RANGEDDAMAGE");
    self:RegisterEvent("UNIT_ATTACK");
    self:RegisterEvent("UNIT_STATS");
    self:RegisterEvent("UNIT_RANGED_ATTACK_POWER");
    self:RegisterEvent("PLAYER_GUILD_UPDATE");
    self:RegisterEvent("COMBAT_RATING_UPDATE");
    self:RegisterEvent("UNIT_INVENTORY_CHANGED");
    self:RegisterEvent("ZONE_CHANGED");
    self:RegisterEvent("ZONE_CHANGED_INDOORS");
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
    self:RegisterEvent("PLAYER_CONTROL_LOST");
    self:RegisterEvent("PLAYER_CONTROL_GAINED");
    self:RegisterEvent("PLAYER_XP_UPDATE");
    self:RegisterEvent("UPDATE_EXHAUSTION");
    self:RegisterEvent("SKILL_LINES_CHANGED");
    self:RegisterEvent("UPDATE_FACTION");

    ARMORY_PLAYERSTAT_LEFTDROPDOWN_SELECTION = nil;
    ARMORY_PLAYERSTAT_RIGHTDROPDOWN_SELECTION = nil;

    ArmoryPaperDollFrame_UpdateVersion();
end

function ArmoryPaperDollFrame_OnEvent(self, event, unit)
    if ( event == "VARIABLES_LOADED" ) then
        -- Set defaults if no settings for the dropdowns
        if ( not ARMORY_PLAYERSTAT_LEFTDROPDOWN_SELECTION or not ARMORY_PLAYERSTAT_RIGHTDROPDOWN_SELECTION ) then
            ArmoryPaperDollFrame_SetStatDropDown();
        end
    elseif ( not Armory:CanHandleEvents() ) then
        return;
    elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        Armory:Execute(ArmoryPaperDollFrame_Update);
        -- Do it again because sometimes the call above misses some data, but this time wait for it...
        Armory:ExecuteConditional(ArmoryPaperDollFrame_HasData, ArmoryPaperDollFrame_Update);
    end

    if ( unit == "player" ) then
        if ( event == "UNIT_LEVEL" or event == "PLAYER_XP_UPDATE" or event == "UPDATE_EXHAUSTION" ) then
            Armory:Execute(ArmoryPaperDollFrame_SetLevel);
        elseif ( event == "UNIT_DAMAGE" or event == "PLAYER_DAMAGE_DONE_MODS" or event == "UNIT_ATTACK_SPEED" or 
                 event == "UNIT_RANGEDDAMAGE" or event == "UNIT_ATTACK" or event == "UNIT_STATS" or 
                 event == "UNIT_RANGED_ATTACK_POWER" or event == "UNIT_INVENTORY_CHANGED" ) then
            Armory:Execute(ArmoryPaperDollFrame_UpdateStats);
        elseif ( event == "UNIT_RESISTANCES" ) then
            Armory:Execute(ArmoryPaperDollFrame_SetResistances);
            Armory:Execute(ArmoryPaperDollFrame_UpdateStats);
        elseif ( event == "UNIT_RANGED_ATTACK_POWER" ) then
            Armory:Execute(ArmoryPaperDollFrame_SetRangedAttack);
        elseif ( event == "PLAYER_GUILD_UPDATE" ) then
            Armory:Execute(ArmoryPaperDollFrame_SetGuild);
        end
    end

    if ( event == "COMBAT_RATING_UPDATE" ) then
        Armory:Execute(ArmoryPaperDollFrame_UpdateStats);
    elseif ( event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" ) then
        Armory:Execute(ArmoryPaperDollFrame_SetZone);
    elseif ( event == "PLAYER_CONTROL_LOST" ) then
        self:UnregisterEvent("ZONE_CHANGED");
        self:UnregisterEvent("ZONE_CHANGED_INDOORS");
    elseif ( event == "PLAYER_CONTROL_GAINED" ) then
        self:RegisterEvent("ZONE_CHANGED");
        self:RegisterEvent("ZONE_CHANGED_INDOORS");
        Armory:Execute(ArmoryPaperDollFrame_SetZone);
    elseif ( (event == "UNIT_LEVEL" and unit == "player") or event == "SKILL_LINES_CHANGED" or event == "UPDATE_FACTION" ) then
        Armory:Execute(ArmoryPaperDollFrame_UpdateEquippable);
    end
end

function ArmoryPaperDollFrame_HasData()
    local unit = "player"; 
    return UnitLevel(unit) and UnitRace(unit) and UnitClass(unit);
end

function ArmoryPaperDollFrame_OnShow(self)
    ArmoryPaperDollFrame_Update();
end

function ArmoryPaperDollFrame_UpdateStats(unit)
    ArmoryPaperDollFrame_ResetStatDropDown();
    ArmoryPaperDollItemSlotButton_Update(ArmoryHeadSlot);
    ArmoryPaperDollItemSlotButton_Update(ArmoryNeckSlot);
    ArmoryPaperDollItemSlotButton_Update(ArmoryShoulderSlot);
    ArmoryPaperDollItemSlotButton_Update(ArmoryBackSlot);
    ArmoryPaperDollItemSlotButton_Update(ArmoryChestSlot);
    ArmoryPaperDollItemSlotButton_Update(ArmoryShirtSlot);
    ArmoryPaperDollItemSlotButton_Update(ArmoryTabardSlot);
    ArmoryPaperDollItemSlotButton_Update(ArmoryWristSlot);
    ArmoryPaperDollItemSlotButton_Update(ArmoryHandsSlot);
    ArmoryPaperDollItemSlotButton_Update(ArmoryWaistSlot);
    ArmoryPaperDollItemSlotButton_Update(ArmoryLegsSlot);
    ArmoryPaperDollItemSlotButton_Update(ArmoryFeetSlot);
    ArmoryPaperDollItemSlotButton_Update(ArmoryFinger0Slot);
    ArmoryPaperDollItemSlotButton_Update(ArmoryFinger1Slot);
    ArmoryPaperDollItemSlotButton_Update(ArmoryTrinket0Slot);
    ArmoryPaperDollItemSlotButton_Update(ArmoryTrinket1Slot);
    ArmoryPaperDollItemSlotButton_Update(ArmoryMainHandSlot);
    ArmoryPaperDollItemSlotButton_Update(ArmorySecondaryHandSlot);
    ArmoryPaperDollItemSlotButton_Update(ArmoryRangedSlot);

    Armory.hasEquipment = true;
    Armory_EQC_Refresh();
end

function ArmoryPaperDollFrame_UpdateHealthBar()
    local currValue = Armory:UnitHealth("player");
    local maxValue = Armory:UnitHealthMax("player");

    -- Safety check to make sure we never get an empty bar.
    if ( maxValue == 0 ) then
        maxValue = 1;
    end

    ArmoryHealthBar:SetMinMaxValues(0, maxValue);
    ArmoryHealthBar:SetStatusBarColor(0.0, 1.0, 0.0);
    ArmoryHealthBar:SetValue(currValue);
    ArmoryHealthBarText:SetText(currValue.." / "..maxValue);
    ArmoryHealthFrame_Update();
end

function ArmoryPaperDollFrame_UpdateManaBar()
    local currValue = Armory:UnitMana("player");
    local maxValue = Armory:UnitManaMax("player");

    ArmoryManaBar:SetMinMaxValues(0, maxValue);
    ArmoryManaBar:SetValue(currValue);
    ArmoryMana_UpdateManaType();
    ArmoryManaBarText:SetText(currValue.." / "..maxValue);
    ArmoryHealthFrame_Update();
end

function ArmoryHealthFrame_Update()
    local width = max(ArmoryHealthTextFrameLabel:GetStringWidth(), ArmoryManaTextFrameLabel:GetStringWidth());
    local barSize = 191 - width;
    local textSize = width + 22;
    local point, relativeTo, relativePoint, x, y;
    
    ArmoryHealthTextFrame:SetWidth(textSize);
    ArmoryHealthBarText:SetWidth(barSize);

    point, relativeTo, relativePoint, x, y = ArmoryHealthBar:GetPoint();
    ArmoryHealthBar:SetPoint(point, relativeTo, relativePoint, textSize + 10, y);
    ArmoryHealthBar:SetWidth(barSize);
   
    point, relativeTo, relativePoint, x, y = ArmoryHealthBackgroundBar:GetPoint();
    ArmoryHealthBackgroundBar:SetPoint(point, relativeTo, relativePoint, textSize + 10, y);
    ArmoryHealthBackgroundBar:SetWidth(barSize);
    
    ArmoryManaTextFrame:SetWidth(textSize);
    ArmoryManaBarText:SetWidth(barSize);

    point, relativeTo, relativePoint, x, y = ArmoryManaBar:GetPoint();
    ArmoryManaBar:SetPoint(point, relativeTo, relativePoint, textSize + 10, y);
    ArmoryManaBar:SetWidth(barSize);
   
    point, relativeTo, relativePoint, x, y = ArmoryManaBackgroundBar:GetPoint();
    ArmoryManaBackgroundBar:SetPoint(point, relativeTo, relativePoint, textSize + 10, y);
    ArmoryManaBackgroundBar:SetWidth(barSize);
end

function ArmoryPaperDollFrame_UpdateTalent()
    local inspect = false;
    local pet = false;
    local talents = {};
    local maxPointsSpent = 0;
    local specialism = NONE;
    local iconTexture;

    for i = 1, Armory:GetNumTalentTabs(inspect, pet) do
        local name, texture, pointsSpent = Armory:GetTalentTabInfo(i, inspect, pet);
        talents[i] = pointsSpent;
        if ( pointsSpent > maxPointsSpent ) then
            specialism = name;
            iconTexture = texture;
            maxPointsSpent = pointsSpent;
        end
    end

    if ( iconTexture ) then
        SetPortraitToTexture(ArmoryPaperDollTalentButtonIcon, iconTexture);
    else
        ArmoryPaperDollTalentButtonIcon:SetTexture("");
    end
    ArmoryPaperDollTalentText:SetText(strupper(specialism));
    ArmoryPaperDollTalentPoints:SetText(strjoin(" / ", unpack(talents)));
end

function ArmoryPaperDollFrame_UpdateSkills()
    local key = "Skills";
    local dbEntry = Armory.selectedDbBaseEntry;
    local inProfessions = false;
    local skills = {};

    for i = 1, dbEntry:GetNumValues(key) do
        local skillName, isHeader, _, skillRank, _, _, skillMaxRank = dbEntry:GetValue(key, i);
        if ( isHeader and skillName == TRADE_SKILLS ) then
            inProfessions = true;
        elseif ( inProfessions and isHeader ) then
            break;
        elseif ( inProfessions ) then
            table.insert(skills, {skillName, skillRank, skillMaxRank});
        end
    end

    if ( #skills == 0 ) then
        ArmoryPaperDollTradeSkillFrame_Update(ArmoryPaperDollTradeSkillFrame1, nil);
        ArmoryPaperDollTradeSkillFrame_Update(ArmoryPaperDollTradeSkillFrame2, nil);
    elseif ( #skills == 1 ) then
        ArmoryPaperDollTradeSkillFrame_Update(ArmoryPaperDollTradeSkillFrame1, skills[1]);
        ArmoryPaperDollTradeSkillFrame_Update(ArmoryPaperDollTradeSkillFrame2, nil);
    else
        ArmoryPaperDollTradeSkillFrame_Update(ArmoryPaperDollTradeSkillFrame1, skills[1]);
        ArmoryPaperDollTradeSkillFrame_Update(ArmoryPaperDollTradeSkillFrame2, skills[2]);
    end
end

function ArmoryPaperDollFrame_Update()
    ArmoryPaperDollFrame_SetGuild();
    ArmoryPaperDollFrame_SetZone();
    ArmoryPaperDollFrame_SetLevel();
    ArmoryPaperDollFrame_SetResistances();
    ArmoryPaperDollFrame_UpdateStats();
    ArmoryPaperDollFrame_UpdateHealthBar();
    ArmoryPaperDollFrame_UpdateManaBar();
    ArmoryPaperDollFrame_UpdateTalent();
    ArmoryPaperDollFrame_UpdateSkills();
end

function ArmoryAlternateSlotFrame_Show(parent, orientation, direction)
    if ( not Armory:GetConfigShowAltEquipment() ) then
        return;
    end

    local frame = ArmoryAlternateSlotFrame;
    local slotName = strsub(parent:GetName(), 7);
    local _, parentId = Armory:GetItemLinkInfo(parent.link)
    local id, link, equipLoc, texture, itemId;
    local items = {};
    local numItems = 0;

    for i = 1, #ArmoryContainers do
        id = ArmoryContainers[i];
        if ( id ~= KEYRING_CONTAINER and id ~= ARMORY_MAIL_CONTAINER and id ~= ARMORY_AUCTIONS_CONTAINER and id ~= ARMORY_COMPANION_CONTAINER ) then
            for index = 1, Armory:GetContainerNumSlots(id) do
                link = Armory:GetContainerItemLink(id, index);
                if ( link and (Armory:GetContainerItemCanEquip(id, index) or Armory:GetConfigShowUnequippable()) ) then
                    _, _, _, _, _, _, _, _, equipLoc, texture = GetItemInfo(link);
                    if ( ARMORY_SLOTINFO[equipLoc] and ARMORY_SLOTINFO[equipLoc] == slotName ) then
                        _, itemId = Armory:GetItemLinkInfo(link);
                        if ( not items[itemId] and itemId ~= parentId ) then
                            items[itemId] = {link=link, texture=texture};
                            numItems = numItems + 1;
                        end
                    end
                end
            end
        end
    end

    if ( numItems == 0 ) then
        frame:Hide();
        return;
    end

    local length = min(numItems, ARMORY_MAX_ALTERNATE_SLOTS) * ARMORY_ALTERNATE_SLOT_SIZE;
    local xOffset = 12;
    local yOffset = 14;
    if ( direction == "LEFT" and parent:GetLeft() - length + xOffset < 0 ) then
        direction = "RIGHT";
    elseif ( direction == "RIGHT" and parent:GetRight() + length - xOffset > GetScreenWidth() ) then
        direction = "LEFT";
    elseif ( parent:GetBottom() - length + yOffset < 0 ) then
        direction = "UP";
    end
    local anchor = ARMORY_ANCHOR_SLOTINFO[direction];
    local row, column, x, y, button;
    local i = 0;
    for _, item in pairs(items) do
        row = floor(i / ARMORY_MAX_ALTERNATE_SLOTS);
        column = i % ARMORY_MAX_ALTERNATE_SLOTS;
           if ( orientation == "VERTICAL" ) then
            x = row;
            y = column;
           else
            x = column;
            y = row;
        end
        i = i + 1;
        x = (8 + x * ARMORY_ALTERNATE_SLOT_SIZE) * anchor.xFactor;
        y = (8 + y * ARMORY_ALTERNATE_SLOT_SIZE) * anchor.yFactor;

        -- "^Armory.*Slot" pattern used by EQC
        button = getglobal("ArmoryAlternate"..i.."Slot");
        if ( not button ) then
            button = CreateFrame("CheckButton", "ArmoryAlternate"..i.."Slot", frame, "ItemButtonTemplate");
            button:SetScript("OnClick", ArmoryAlternateSlotButton_OnClick);
            button:SetScript("OnEnter", ArmoryAlternateSlotButton_OnEnter);
            button:SetScript("OnLeave", ArmoryAlternateSlotButton_OnLeave);
        end
        SetItemButtonTexture(button, item.texture);
        Armory:SetItemLink(button, item.link);
        button.anchor = parent.anchor;
        button:SetID(parent:GetID());
        button:ClearAllPoints();
        button:SetPoint(anchor.point, frame, anchor.point, x, y);
        button:SetFrameLevel(frame:GetFrameLevel() + 1);
        button:Show();
    end

    ArmoryAlternateSlotFrame_HideSlots(numItems + 1);

    frame:ClearAllPoints();
    frame:SetParent(parent);
    frame:SetFrameLevel(parent:GetFrameLevel() + 3);
    frame:SetScale(.85);
    frame:SetPoint(anchor.point, parent, anchor.relativeTo, anchor.x, anchor.y);
    if ( orientation == "VERTICAL" ) then
        frame:SetWidth((row + 1) * ARMORY_ALTERNATE_SLOT_SIZE + xOffset);
        frame:SetHeight(length + yOffset);
    else
        frame:SetWidth(length + xOffset);
        frame:SetHeight((row + 1) * ARMORY_ALTERNATE_SLOT_SIZE + yOffset);
    end
    frame.delay = 0;
    frame:Show();
end

function ArmoryAlternateSlotButton_OnClick(self)
    if ( IsModifiedClick("CHATLINK") and self.link ) then
        HandleModifiedItemClick(self.link);
    end
end

function ArmoryAlternateSlotButton_OnEnter(self)
       GameTooltip:SetOwner(self, self.anchor);
       Armory:SetInventoryItem("player", self:GetID(), false, false, self.link);
end

function ArmoryAlternateSlotButton_OnLeave(self)
    GameTooltip:Hide();
end

function ArmoryAlternateSlotFrame_OnUpdate(self, elapsed)
    local now = time();
    if ( self:IsVisible() and now >= self.delay ) then
        if ( MouseIsOver(self) or MouseIsOver(self:GetParent()) ) then
            return;
        end
        self:Hide();
    end
    self.delay = now + 0.5;
end

function ArmoryAlternateSlotFrame_HideSlots(start)
    local i = start or 1;
      while ( getglobal("ArmoryAlternate"..i.."Slot") ) do
        getglobal("ArmoryAlternate"..i.."Slot"):Hide();
        i = i + 1;
    end
end

function ArmoryPaperDollFrame_UpdateEquippable()
    Armory:PrintDebug("UPDATE Equippable");
    Armory:UpdateInventoryEquippable();
end

function ArmoryPaperDollFrame_UpdateVersion(version)
    local major, minor, rel, lastVersion;

    ArmoryVersionText:SetText("v"..Armory.version);

    if ( not ArmoryPaperDollFrame.lastVersion ) then
        major, minor, rel = strsplit(".", Armory.version);
        ArmoryPaperDollFrame.lastVersion = major * 100 + (minor or 0) + (rel or 0) / 100;
    end

    if ( version ) then
        major, minor, rel = strsplit(".", version);
        lastVersion = major * 100 + (minor or 0) + (rel or 0) / 100;
        if ( lastVersion > ArmoryPaperDollFrame.lastVersion ) then
            ArmoryPaperDollFrame.lastVersion = lastVersion;
            ArmoryNewVersionText:SetFormattedText("|cffff0000new!|r v|cffffffff%s", version);
            ArmoryNewVersionText:Show();
        end
    end
end