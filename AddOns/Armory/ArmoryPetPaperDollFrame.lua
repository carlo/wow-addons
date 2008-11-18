--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmoryPetPaperDollFrame.lua,v 1.11, 2008-11-11 10:16:33Z, Maxim Baars$
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

ARMORY_NUM_PET_SLOTS = 5;

StaticPopupDialogs["ARMORY_DELETE_PET"] = {
    text = ARMORY_DELETE_UNIT,
    button1 = YES,
    button2 = NO,
    OnAccept = function(self)
        Armory:DeletePet(Armory:GetCurrentPet());
    end,
    OnCancel = function(self)
        Armory.selectedPet = ArmoryPetPaperDollFrame.selectedPet;
    end,
    OnHide = function(self)
        ArmoryPetPaperDollFrame_Update(1);
    end,
    timeout = 0,
    whileDead = 1,
    exclusive = 1,
    showAlert = 1,
    hideOnEscape = 1
};

function ArmoryPetPaperDollFrame_OnLoad(self)
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("PET_UI_UPDATE");
    self:RegisterEvent("PET_BAR_UPDATE");
    self:RegisterEvent("PET_UI_CLOSE");
    self:RegisterEvent("UNIT_PET");
    self:RegisterEvent("UNIT_PET_EXPERIENCE");
    self:RegisterEvent("UNIT_MODEL_CHANGED");
    self:RegisterEvent("UNIT_LEVEL");
    self:RegisterEvent("UNIT_RESISTANCES");
    self:RegisterEvent("UNIT_STATS");
    self:RegisterEvent("UNIT_DAMAGE");
    self:RegisterEvent("UNIT_RANGEDDAMAGE");
    self:RegisterEvent("UNIT_ATTACK_SPEED");
    self:RegisterEvent("UNIT_ATTACK_POWER");
    self:RegisterEvent("UNIT_RANGED_ATTACK_POWER");
    self:RegisterEvent("UNIT_DEFENSE");
    self:RegisterEvent("UNIT_ATTACK");
    self:RegisterEvent("UNIT_PET_TRAINING_POINTS");
    self:RegisterEvent("UNIT_HAPPINESS");
    ArmoryPetDamageFrameLabel:SetText(DAMAGE_COLON);
    ArmoryPetAttackPowerFrameLabel:SetText(ATTACK_POWER_COLON);
    ArmoryPetArmorFrameLabel:SetText(ARMOR_COLON);
    ArmoryPetSpellDamageFrameLabel:SetText(SPELL_BONUS_COLON);
end

function ArmoryPetPaperDollFrame_OnEvent(self, event, ...)
    local arg1 = ...;
    if ( not Armory:CanHandleEvents() ) then
        return;
    elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        if ( HasPetUI() ) then
            Armory:Execute(ArmoryPetPaperDollFrame_Update);
        end
    elseif ( event == "PET_UI_UPDATE" or event == "PET_BAR_UPDATE" or (event == "UNIT_PET" and arg1 == "player") ) then
        ArmoryPetTab_Update();
        Armory:Execute(ArmoryPetPaperDollFrame_Update);
    elseif ( event == "PET_UI_CLOSE" ) then
        ArmoryPetTab_Update();
    elseif ( event == "UNIT_PET_EXPERIENCE" ) then
        Armory:Execute(ArmoryPetPaperDollFrame_SetLevel);
    elseif ( event == "UNIT_HAPPINESS" ) then
        Armory:Execute(ArmoryPetPaperDollFrame_SetHappiness);
    elseif ( arg1 == "pet" ) then
        Armory:Execute(ArmoryPetPaperDollFrame_Update);
    end
end

function ArmoryPetPaperDollFrame_OnShow(self)
    ArmoryNameText:Hide();
    ArmoryPetNameText:Show();
    ArmoryPetPaperDollFrame_Update();
end

function ArmoryPetPaperDollFrame_OnHide(self)
    ArmoryNameText:Show();
    ArmoryPetNameText:Hide();
end

function ArmoryPetPaperDollFrame_Update(petChanged)
    if ( petChanged and ArmorySpellBookFrame:IsShown() ) then
        ArmorySpellBookFrame:Hide();
        ArmorySpellBookFrame:Show();
    end

    local currentPet = Armory:GetCurrentPet();
    if ( currentPet == UNKNOWN and not HasPetUI() ) then
        ArmoryPetTab_Update(); 
        return;
    end
    ArmoryPetNameText:SetText(currentPet);
    ArmoryPetPaperDollFrame_SetLevel();
    ArmoryPetPaperDollFrame_SetHappiness();
    ArmoryPetPaperDollFrame_SetResistances();
    ArmoryPetPaperDollFrame_SetStats();
    ArmoryPaperDollFrame_SetDamage(ArmoryPetDamageFrame, "Pet");
    ArmoryPaperDollFrame_SetArmor(ArmoryPetArmorFrame, "Pet");
    ArmoryPaperDollFrame_SetAttackPower(ArmoryPetAttackPowerFrame, "Pet");
    ArmoryPetPaperDollFrame_SetSpellBonusDamage();

    local button, background, icon;
    local pets = Armory:GetPets();
    for i = 1, ARMORY_NUM_PET_SLOTS do
        button = getglobal("ArmoryPetPaperDollFramePet"..i);
        background = getglobal("ArmoryPetPaperDollFramePet"..i.."Background");
        if ( i <= #pets ) then
            Armory.selectedPet = pets[i];
            background:SetVertexColor(1.0, 1.0, 1.0);
            button:Enable();
            icon = Armory:GetPetIcon();
            SetItemButtonTexture(button, icon);
            if ( icon ) then
                button.tooltip = Armory.selectedPet;
                button.tooltipSubtext = format(UNIT_TYPE_LEVEL_TEMPLATE, Armory:UnitLevel("pet"), Armory:UnitCreatureFamily("pet")).."\n"..GREEN_FONT_COLOR_CODE..ARMORY_DELETE_UNIT_HINT;
            else
                button.tooltip = nil;
                button.tooltipSubtext = "";
            end
            button:SetChecked(Armory.selectedPet == currentPet and icon);
        else
            SetItemButtonTexture(button, "");
            background:SetVertexColor(1.0,0.1,0.1);
            button:SetChecked(false);
            button:Disable();
        end
    end
    Armory.selectedPet = currentPet;
    ArmoryPetPaperDollFrame.selectedPet = currentPet;

    local _, canGainXP = Armory:HasPetUI();
    if ( canGainXP ) then
        ArmoryPetPaperDollPetInfo:Show();
        ArmoryPetDietText:SetText(format(PET_DIET_TEMPLATE, BuildListString(Armory:GetPetFoodTypes())));
        ArmoryPetTalentPointText:SetText(Armory:GetPetTalentPoints());
        ArmoryPetTalentPointText:Show();
        ArmoryPetTalentPointLabel:Show();
    else
        ArmoryPetPaperDollPetInfo:Hide();
        ArmoryPetTalentPointText:Hide();
        ArmoryPetTalentPointLabel:Hide();
    end
end

function ArmoryPetPaperDollFrame_SetLevel()
    local currXP, nextXP = Armory:GetPetExperience();
    local text = "";
    if ( Armory:UnitCreatureFamily("pet") ) then
        text = format(UNIT_TYPE_LEVEL_TEMPLATE, Armory:UnitLevel("pet"), Armory:UnitCreatureFamily("pet"));
    end
    if ( (nextXP or 0) > 0 ) then
        local percentXP = floor((currXP * 100) / nextXP);
        if ( percentXP > 0 ) then
            text = text.." ("..XP.." "..percentXP.."%)";
        end
    end
    ArmoryPetLevelText:SetText(text);
end

function ArmoryPetPaperDollFrame_SetHappiness()
    ---------------
    -- PetFrame ---
    ---------------
    local happiness, damagePercentage = Armory:GetPetHappiness();
    local hasPetUI, isHunterPet = Armory:HasPetUI();
    if ( not happiness or not isHunterPet ) then
        ArmoryPetPaperDollPetInfo:Hide();
        return;    
    end
    ArmoryPetPaperDollPetInfo:Show();
    if ( happiness == 1 ) then
        ArmoryPetFrameHappinessTexture:SetTexCoord(0.375, 0.5625, 0, 0.359375);
    elseif ( happiness == 2 ) then
        ArmoryPetFrameHappinessTexture:SetTexCoord(0.1875, 0.375, 0, 0.359375);
    elseif ( happiness == 3 ) then
        ArmoryPetFrameHappinessTexture:SetTexCoord(0, 0.1875, 0, 0.359375);
    end
    ArmoryPetPaperDollPetInfo.tooltip = getglobal("PET_HAPPINESS"..happiness);
    ArmoryPetPaperDollPetInfo.tooltipDamage = format(PET_DAMAGE_PERCENTAGE, damagePercentage);
end

function ArmoryPetPaperDollFrame_SetResistances()
    local base, resistance, positive, negative;
    local index, text, frame;
    for i = 1, NUM_PET_RESISTANCE_TYPES do
        index = i + 1;
        if ( i == NUM_PET_RESISTANCE_TYPES ) then
            index = 1;
        end
        text = getglobal("ArmoryPetMagicResText"..i);
        frame = getglobal("ArmoryPetMagicResFrame"..i);

        base, resistance, positive, negative = Armory:UnitResistance("pet", frame:GetID());
        frame.tooltip = getglobal("RESISTANCE"..frame:GetID().."_NAME");

        -- resistances can now be negative. Show Red if negative, Green if positive, white otherwise
        if( resistance < 0 ) then
            text:SetText(RED_FONT_COLOR_CODE..resistance..FONT_COLOR_CODE_CLOSE);
        elseif( resistance == 0 ) then
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
    end
end

function ArmoryPetPaperDollFrame_SetStats()
    for i = 1, NUM_PET_STATS do
        local label = getglobal("ArmoryPetStatFrame"..i.."Label");
        local text = getglobal("ArmoryPetStatFrame"..i.."StatText");
        local frame = getglobal("ArmoryPetStatFrame"..i);
        local stat, effectiveStat, posBuff, negBuff;
        label:SetText(getglobal("SPELL_STAT"..i.."_NAME")..":");
        stat, effectiveStat, posBuff, negBuff = Armory:UnitStat("pet", i);
        -- Set the tooltip text
        local tooltipText = HIGHLIGHT_FONT_COLOR_CODE..getglobal("SPELL_STAT"..i.."_NAME").." ";

        if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
            text:SetText(effectiveStat);
            frame.tooltip = tooltipText..effectiveStat..FONT_COLOR_CODE_CLOSE;
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
            frame.tooltip = tooltipText;

            -- If there are any negative buffs then show the main number in red even if there are
            -- positive buffs. Otherwise show in green.
            if ( negBuff < 0 ) then
                text:SetText(RED_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE);
            else
                text:SetText(GREEN_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE);
            end
        end

        -- Second tooltip line
        frame.tooltip2 = getglobal("DEFAULT_STAT"..i.."_TOOLTIP");
        if ( i == 1 ) then
            local attackPower = 2 * effectiveStat - 20;
            frame.tooltip2 = format(frame.tooltip2, attackPower);
        elseif ( i == 2 ) then
            --local newLineIndex = strfind(frame.tooltip2, "\n");
            local newLineIndex = strfind(frame.tooltip2, "|n");
            frame.tooltip2 = strsub(frame.tooltip2, 1, newLineIndex - 1);
            frame.tooltip2 = format(frame.tooltip2, Armory:GetCritChanceFromAgility("pet"));
        elseif ( i == 3 ) then
            local expectedHealthGain = (((stat - posBuff - negBuff) - 20) * 10 + 20) * Armory:GetUnitHealthModifier("pet");
            local realHealthGain = ((effectiveStat - 20) * 10 + 20) * Armory:GetUnitHealthModifier("pet");
            local healthGain = (realHealthGain - expectedHealthGain) * Armory:GetUnitMaxHealthModifier("pet");
            frame.tooltip2 = format(frame.tooltip2, healthGain);
        elseif ( i == 4 ) then
            if ( Armory:UnitHasMana("pet") ) then
                local manaGain = ((effectiveStat - 20) * 15 + 20) * Armory:GetUnitPowerModifier("pet");
                frame.tooltip2 = format(frame.tooltip2, manaGain, Armory:GetSpellCritChanceFromIntellect("pet"));
            else
                local newLineIndex = strfind(frame.tooltip2, "|n") + 2;
                frame.tooltip2 = strsub(frame.tooltip2, newLineIndex);
                frame.tooltip2 = format(frame.tooltip2, Armory:GetSpellCritChanceFromIntellect("pet"));
            end
        elseif ( i == 5 ) then
            frame.tooltip2 = format(frame.tooltip2, Armory:GetUnitHealthRegenRateFromSpirit("pet"));
            if ( Armory:UnitHasMana("pet") ) then
                frame.tooltip2 = frame.tooltip2.."\n"..format(MANA_REGEN_FROM_SPIRIT, Armory:GetUnitManaRegenRateFromSpirit("pet"));
            end
        end
    end
end

function ArmoryPetPaperDollFrame_SetSpellBonusDamage()
    local _, unitClass = Armory:UnitClass("player");
    unitClass = strupper(unitClass);
    local spellDamageBonus = 0;
    if( unitClass == "WARLOCK" ) then
        local bonusFireDamage = Armory:GetSpellBonusDamage(3);
        local bonusShadowDamage = Armory:GetSpellBonusDamage(6);
        if ( bonusShadowDamage > bonusFireDamage ) then
            spellDamageBonus = Armory:ComputePetBonus("PET_BONUS_SPELLDMG_TO_SPELLDMG", bonusShadowDamage);
        else
            spellDamageBonus = Armory:ComputePetBonus("PET_BONUS_SPELLDMG_TO_SPELLDMG", bonusFireDamage);
        end
    elseif( unitClass == "HUNTER" ) then
        local base, posBuff, negBuff = Armory:UnitRangedAttackPower("player");
        local totalAP = base + posBuff + negBuff;
        spellDamageBonus = Armory:ComputePetBonus("PET_BONUS_RAP_TO_SPELLDMG", totalAP);
    end
    local spellDamageBonusText = format("%d", spellDamageBonus);

    ArmoryPetSpellDamageFrameLabel:SetText(SPELL_BONUS_COLON);
    if ( spellDamageBonus > 0 ) then
        spellDamageBonusText = GREEN_FONT_COLOR_CODE.."+"..spellDamageBonusText..FONT_COLOR_CODE_CLOSE;
    elseif( spellDamageBonus < 0 ) then
        spellDamageBonusText = RED_FONT_COLOR_CODE..spellDamageBonusText..FONT_COLOR_CODE_CLOSE;
    end

    ArmoryPetSpellDamageFrameStatText:SetText(spellDamageBonusText);
    ArmoryPetSpellDamageFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..SPELL_BONUS..FONT_COLOR_CODE_CLOSE.." "..spellDamageBonusText;
    ArmoryPetSpellDamageFrame.tooltip2 = DEFAULT_STATSPELLBONUS_TOOLTIP;

    ArmoryPetSpellDamageFrame:Show();
end

function ArmoryPetSlot_OnClick(self, button)
    local pets = Armory:GetPets();
    if ( pets[self:GetID()] ) then
        for i = 1, ARMORY_NUM_PET_SLOTS do
            getglobal("ArmoryPetPaperDollFramePet"..i):SetChecked(false);
        end
        self:SetChecked(true);
        Armory.selectedPet = pets[self:GetID()];
        if ( button == "RightButton" ) then
            StaticPopup_Show("ARMORY_DELETE_PET", Armory:GetCurrentPet());
        else
            ArmoryPetPaperDollFrame_Update(1);
        end
    end
end

function ArmoryPetTab_Update()
    -- If doesn't have a petUI then disable the pet tab and return
    if ( not Armory:HasPetUI() ) then
        if ( ArmoryPetPaperDollFrame:IsVisible() ) then
            ArmoryFrame_ToggleArmory("ArmoryPaperDollFrame");
        end
        ArmoryFrameTab2:Hide();
        ArmoryFrameTab3:SetPoint("LEFT", "ArmoryFrameTab2", "LEFT", 0, 0);
    else
        ArmoryFrameTab2:Show();
        ArmoryFrameTab3:SetPoint("LEFT", "ArmoryFrameTab2", "RIGHT", -16, 0);
    end
end
