--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmoryFrame.lua,v 1.72, 2008-11-14 11:27:16Z, Maxim Baars$
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

ARMORY_MAX_LINE_TABS = 9;

ARMORYFRAME_SUBFRAMES = { "ArmoryPaperDollFrame", "ArmoryPetPaperDollFrame", "ArmoryTalentFrame", "ArmoryPVPFrame", "ArmoryOtherFrame" };
ARMORYFRAME_CHILDFRAMES = { "ArmoryTradeSkillFrame", "ArmoryInventoryFrame", "ArmoryQuestLogFrame", "ArmorySpellBookFrame", "ArmoryPVPTeamDetails", "ArmoryAchievementFrame" };

ARMORY_ID = "Armory";
ARMORYFRAME_SUBFRAME = "ArmoryPaperDollFrame";

StaticPopupDialogs["ARMORY_DELETE_CHARACTER"] = {
    text = ARMORY_DELETE_UNIT,
    button1 = YES,
    button2 = NO,
    OnAccept = function(self)
        ArmoryFrame_DeleteCharacter();
    end,
    timeout = 0,
    whileDead = 1,
    exclusive = 1,
    showAlert = 1,
    hideOnEscape = 1
};

StaticPopupDialogs["ARMORY_CHECK_MAIL_POPUP"] = {
    text = ARMORY_CHECK_MAIL_POPUP,
    button1 = OKAY,
    showAlert = 1,
    whileDead = 1,
    timeout = 0,
}

function ArmoryFrame_ToggleArmory(tab)
    local subFrame = getglobal(tab);
    if ( subFrame ) then
        PanelTemplates_SetTab(ArmoryFrame, subFrame:GetID());
        if ( ArmoryFrame:IsVisible() ) then
            if ( subFrame:IsVisible() ) then
                HideUIPanel(ArmoryFrame);    
            else
                PlaySound("igCharacterInfoTab");
                ArmoryFrame_ShowSubFrame(tab);
            end
        else
            ShowUIPanel(ArmoryFrame);
            ArmoryFrame_ShowSubFrame(tab);
        end
    end
end

function ArmoryFrame_ShowSubFrame(frameName)
    for index, value in pairs(ARMORYFRAME_SUBFRAMES) do
        if ( value == frameName ) then
            getglobal(value):Show();
            ARMORYFRAME_SUBFRAME = value;
        else
            getglobal(value):Hide();    
        end    
    end 
end

function ArmoryFrame_OnLoad(self)
    Armory:Init();

    -- Sliding frame
    --this:SetAttribute("UIPanelLayout-defined", true);
    --this:SetAttribute("UIPanelLayout-enabled", true);
    --this:SetAttribute("UIPanelLayout-area", "left");
    --this:SetAttribute("UIPanelLayout-pushable", 5);
    --this:SetAttribute("UIPanelLayout-whileDead", true);

    self:RegisterEvent("ADDON_LOADED");
    self:RegisterEvent("VARIABLES_LOADED");
    self:RegisterEvent("UNIT_NAME_UPDATE");
    self:RegisterEvent("PLAYER_PVP_RANK_CHANGED");
    self:RegisterEvent("PLAYER_UPDATE_RESTING");

    -- Tab Handling code
    PanelTemplates_SetNumTabs(self, #ARMORYFRAME_SUBFRAMES);
    PanelTemplates_SetTab(self, 1);

    -- Allows Armory to be closed with the Escape key
    table.insert(UISpecialFrames, "ArmoryFrame");

    if ( IsAddOnLoaded("EnhTooltip") ) then
        Armory_EnhTooltip_OnLoad();
    end
end

function ArmoryFrame_OnEvent(self, event, ...)
    local arg1, arg2 = ...;
    
    if ( event == "ADDON_LOADED" ) then
        if ( arg1 == "Armory" ) then
            self.init = true;
            if ( IsAddOnLoaded("oGlow") ) then
                Armory_oGlow_OnLoad();
            end
        end
        if ( self.init ) then
            ArmoryMinimapButton_Init();
        end
    elseif ( event == "VARIABLES_LOADED" ) then
        Armory:InitDb();
        Armory:SetProfile(Armory:CurrentProfile());

        ArmoryChatInit();
        ArmoryTooltipsInit();
        Armory:PrepareMenu();

        local expire = Armory:CheckMailItems(true);
        if ( expire > 0 ) then
            StaticPopup_Show("ARMORY_CHECK_MAIL_POPUP", expire);
        end
    elseif ( not Armory:CanHandleEvents() ) then
        return;
    elseif ( (event == "UNIT_NAME_UPDATE" and arg1 == "player") or event == "PLAYER_PVP_RANK_CHANGED" ) then
        Armory:Execute(ArmoryFrame_UpdateName);
    elseif ( event == "PLAYER_UPDATE_RESTING" ) then
        Armory:Execute(ArmoryFrame_UpdateResting);
    elseif ( event == "CHAT_MSG_ADDON" and arg1 == ARMORY_ID ) then
        ArmoryPaperDollFrame_UpdateVersion(arg2);
    end
end

function ArmoryFrame_UpdateName()
    ArmoryNameText:SetText(Armory:UnitPVPName("player"));
end

function ArmoryFrame_UpdateResting()
    if ( Armory:IsResting() ) then
        ArmoryRestIcon:Show();
    else
        ArmoryRestIcon:Hide();
    end
end

function ArmoryFrame_OnShow(self)
    PlaySound("igCharacterInfoOpen");
    ArmoryFrame_Update(Armory:CurrentProfile());
end

function ArmoryFrame_OnHide(self)
    PlaySound("igCharacterInfoClose");
end

function ArmoryFrameTab_OnClick(self)
    local id = self:GetID();
    
    if ( id == 1 ) then
        ArmoryFrame_ToggleArmory("ArmoryPaperDollFrame");
    elseif ( id == 2 ) then
        ArmoryFrame_ToggleArmory("ArmoryPetPaperDollFrame");
    elseif ( id == 3 ) then
        ArmoryFrame_ToggleArmory("ArmoryTalentFrame");
    elseif ( id == 4 ) then
        ArmoryFrame_ToggleArmory("ArmoryPVPFrame");
    elseif ( id == 5 ) then
        ArmoryFrame_ToggleArmory("ArmoryOtherFrame");
    end
    PlaySound("igCharacterInfoTab");
end

function ArmoryFrame_Update(profile, refresh)
    Armory:SetProfile(profile);
    Armory:SetPortraitTexture(ArmoryFramePortrait, "player");
    ArmoryFrame_UpdateName();
    ArmoryFrame_UpdateResting();
    ArmoryFrame_UpdateLineTabs();
    ArmoryAlternateSlotFrame_HideSlots();
    ArmoryPetTab_Update();

    if ( table.getn(Armory:Profiles()) > 1 ) then
        ArmoryNameDropDownButton:Enable();
        ArmoryFrameLeftButton:Enable();
        ArmoryFrameRightButton:Enable();
    else
        ArmoryNameDropDownButton:Disable();
        ArmoryFrameLeftButton:Disable();
        ArmoryFrameRightButton:Disable();
    end

    if ( refresh ) then
        local subFrameUpdate = getglobal(ARMORYFRAME_SUBFRAME.."_OnShow");
        if ( subFrameUpdate ) then
            subFrameUpdate(getglobal(ARMORYFRAME_SUBFRAME));
        end
        ArmoryCloseChildWindows(true);
    end
end

function ArmoryNameDropDown_OnLoad(self)
    ArmoryDropDownMenu_Initialize(self, ArmoryNameDropDown_Initialize);
    ArmoryDropDownMenu_SetWidth(self, 10);
end

function ArmoryNameDropDown_Initialize()
    -- Setup buttons
    local currentRealm, currentCharacter = Armory:GetPaperDollLastViewed();
    local unit = "player";
    local info, checked;
    for _, realm in ipairs(Armory:RealmList()) do
        info = ArmoryDropDownMenu_CreateInfo();
        info.text = realm;
        info.notClickable = 1;
        info.notCheckable = 1;
        info.isTitle = 1;
        ArmoryDropDownMenu_AddButton(info);
        for _, character in ipairs(Armory:CharacterList(realm)) do
            local profile = {realm=realm, character=character};
            Armory:SelectProfile(profile);
            if ( realm == currentRealm and character == currentCharacter ) then
                checked = 1;
                ArmoryDropDownMenu_SetSelectedValue(ArmoryNameDropDown, profile);
            else
                checked = nil;
            end
            info = ArmoryDropDownMenu_CreateInfo();
            info.text = character;
            info.func = ArmoryNameDropDown_OnClick;
            info.value = profile;
            info.checked = checked;
            info.tooltipTitle = Armory:UnitPVPName(unit);
            info.tooltipText = format(PLAYER_LEVEL, Armory:UnitLevel(unit), Armory:UnitRace(unit), Armory:UnitClass(unit));
            ArmoryDropDownMenu_AddButton(info);
        end
    end
    Armory:LoadProfile(currentRealm, currentCharacter);
end

function ArmoryNameDropDown_OnClick(self)
    ArmoryDropDownMenu_SetSelectedValue(ArmoryNameDropDown, self.value);
    ArmoryFrame_Update(self.value, true); 
end

function ArmoryFrame_DeleteCharacter()
    local realm, character = Armory:GetPaperDollLastViewed();
    local profile = ArmoryFrameCharacterCycle(false, true);
    Armory:DeleteProfile(realm, character, true);
    ArmoryFrame_Update(profile, true);
end

function ArmoryFrame_UpdateLineTabs()
    local tabId = 1;

    if ( Armory:HasInventory() ) then
        ArmoryFrame_SetLineTab(tabId, "Inventory", INVENTORY_TOOLTIP, "Interface\\Icons\\INV_Misc_Bag_08");
        tabId = tabId + 1;
    end

    if ( Armory:HasQuestLog() ) then
        ArmoryFrame_SetLineTab(tabId, "QuestLog", QUESTLOG_BUTTON, "Interface\\Icons\\INV_Misc_Book_08");
        tabId = tabId + 1;
    end

    if ( Armory:HasSpellBook() ) then
        ArmoryFrame_SetLineTab(tabId, "SpellBook", SPELLBOOK_BUTTON, "Interface\\Icons\\INV_Misc_Book_09");
        tabId = tabId + 1;
    end

    if ( Armory:HasAchievements() and Armory:GetTotalAchievementPoints() > 0 ) then
        ArmoryFrame_SetLineTab(tabId, "Achievements", ACHIEVEMENT_BUTTON, "Interface\\Icons\\Achievement_Level_10");
        tabId = tabId + 1;
    end

    if ( Armory:HasTradeSkills() ) then
        for _, name in ipairs(Armory:GetProfessionNames()) do
            local lineTab = ArmoryFrame_SetLineTab(tabId, "TradeSkill", name, Armory:GetProfessionTexture(name));
            if ( lineTab ) then
                lineTab.skillName = name;
                tabId = tabId + 1;
            end
        end
    end

    -- Hide unused tabs
    for i = tabId, ARMORY_MAX_LINE_TABS do
        getglobal("ArmoryFrameLineTab"..i):Hide();
    end
end

function ArmoryFrame_SetLineTab(id, tabType, tooltip, texture)
    if ( id and id > 0 and id <= ARMORY_MAX_LINE_TABS ) then
        local lineTab = getglobal("ArmoryFrameLineTab"..id);
        if ( lineTab ) then
            lineTab:SetNormalTexture(texture);
            lineTab.tooltip = tooltip;
            lineTab.tabType = tabType;
            lineTab:Show();
        end
        return lineTab;
    end
end

function ArmoryFrameLineTabTooltip(self)
    if ( self.tooltip ) then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetText(self.tooltip);
    end
end

function ArmoryFrameLineTab_OnClick(self)
    for i = 1, ARMORY_MAX_LINE_TABS do
        local lineTab = getglobal("ArmoryFrameLineTab"..i);
        if ( lineTab:GetID() ~= self:GetID() ) then
            lineTab:SetChecked(nil);
        end
    end

    if ( self.tabType == "Inventory" ) then
        ArmoryInventoryFrame_Toggle();
    elseif ( self.tabType == "QuestLog" ) then
        ArmoryQuestLogFrame_Toggle();
    elseif ( self.tabType == "SpellBook" ) then
        ArmoryToggleSpellBook(BOOKTYPE_SPELL);
    elseif ( self.tabType == "Achievements" ) then
        ArmoryAchievementFrame_Toggle()
    elseif ( self.tabType == "TradeSkill" ) then
        if ( ArmoryTradeSkillFrame:IsShown() and self.skillName == Armory.selectedSkill ) then
            ArmoryTradeSkillFrame_Hide();
            return;
        end
        Armory.selectedSkill = self.skillName;
        ArmoryTradeSkillFrame_Show();
    end
end

function ArmoryFrameLeft_Click(self)
    ArmoryFrameCharacterCycle(false);
end

function ArmoryFrameLeft_OnEnter(self)
    local profile = ArmoryFrameCharacterCycle(false, true);
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
    if ( profile ) then
        GameTooltip:SetText(profile.character, 1.0, 1.0, 1.0);
        GameTooltip:AddLine(profile.realm);
        GameTooltip:SetScale(0.75);
        GameTooltip:Show();
        self.UpdateTooltip = ArmoryFrameLeft_OnEnter;
    else
        self.UpdateTooltip = nil;
    end
end

function ArmoryFrameRight_Click(self)
    ArmoryFrameCharacterCycle(true);
end

function ArmoryFrameRight_OnEnter(self)
    local profile = ArmoryFrameCharacterCycle(true, true);
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
    if ( profile ) then
        GameTooltip:SetText(profile.character, 1.0, 1.0, 1.0);
        GameTooltip:AddLine(profile.realm);
        GameTooltip:SetScale(0.75);
        GameTooltip:Show();
        self.UpdateTooltip = ArmoryFrameRight_OnEnter;
    else
        self.UpdateTooltip = nil;
    end
end

function ArmoryFrameCharacterCycle(next, peek)
    local currentRealm, currentCharacter = Armory:GetPaperDollLastViewed();
    local profiles = Armory:Profiles();
    local selected = 0;

    for index, profile in ipairs(profiles) do
        if ( profile.realm == currentRealm and profile.character == currentCharacter ) then
            selected = index;
            break;
        end
    end

    if ( next ) then
        selected = selected + 1;
    else
        selected = selected - 1;
    end
    if ( selected > #profiles ) then
        selected = 1;
    elseif ( selected < 1 ) then
        selected = #profiles;
    end

    if ( peek ) then
        return profiles[selected];
    end

    ArmoryFrameSelectCharacter(profiles[selected])
end

function ArmoryFrameSelectCharacter(profile)
    ArmoryFrame_Update(profile, true); 
    ArmoryCloseDropDownMenus();
    Armory_EQC_Refresh();
    if ( not ArmoryFrame:IsShown() ) then
        local text = profile.character;
        if ( table.getn(Armory:RealmList()) > 1 ) then
            if ( profile.realm == GetRealmName() ) then
                text = text..RED_FONT_COLOR_CODE;
            end
            text = text.." ("..profile.realm..")";
        end
        ArmoryMessageFrame:AddMessage(text);
        ArmoryMessageFrame:Show();
    end
end

function ArmoryCloseChildWindows(reopen)
    local childWindow, currentChild;
    for index, value in pairs(ARMORYFRAME_CHILDFRAMES) do
        childWindow = getglobal(value);
        if ( childWindow ) then
            if ( childWindow:IsVisible() ) then
                currentChild = childWindow;
            end
            childWindow:Hide();
        end
    end
    if ( reopen and currentChild ) then
        if ( currentChild:GetName() == "ArmoryTradeSkillFrame" ) then
            for _, name in ipairs(Armory:GetProfessionNames()) do
                if ( name == Armory.selectedSkill ) then
                     ArmoryTradeSkillFrame_Show();
                     break;
                end
            end
        else
            currentChild:Show();
        end
    end
end

function ArmoryChildWindow_OnMouseUp(self, button)
    if ( ArmoryFrame.isMoving ) then
        ArmoryFrame:StopMovingOrSizing();
        ArmoryFrame.isMoving = false;
    end
end

function ArmoryChildWindow_OnMouseDown(self, button)
    if ( ( ( not ArmoryFrame.isLocked ) or ( ArmoryFrame.isLocked == 0 ) ) and ( button == "LeftButton" ) ) then
        ArmoryFrame:StartMoving();
        ArmoryFrame.isMoving = true;
    end
end

function ArmoryMinimapButton_Init()
    if ( Armory:GetConfigShowMinimap() ) then
        if ( Armory:GetConfigHideMinimapIfToolbar() and (IsAddOnLoaded("FuBar") or IsAddOnLoaded("Titan")) ) then
            ArmoryMinimapButton:Hide();
        else
            ArmoryMinimapButton_Move();
            ArmoryMinimapButton:Show();
        end
    else
        ArmoryMinimapButton:Hide();
    end
end

function ArmoryMinimapButton_OnLoad(self)
    self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
    self:RegisterForDrag("LeftButton");
    self.updateDelay = 0;
end

function ArmoryMinimapButton_OnEnter(self)
    if ( not self.isMoving ) then
        Armory.LDB.OnEnter(self);
    end
end

function ArmoryMiniMapButton_OnClick(self, button)
    if ( not self.isMoving ) then
        Armory.LDB.OnClick(self, button);
    end
end

function ArmoryMinimapButton_OnUpdate(self, elapsed)
    self.updateDelay = self.updateDelay + elapsed;

    if ( self.isMoving ) then
        local xpos, ypos = GetCursorPosition();
        local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom();
        local angle;

        xpos = xmin - xpos / Minimap:GetEffectiveScale() + 70;
        ypos = ypos / Minimap:GetEffectiveScale() - ymin - 70;

        angle = math.deg(math.atan2(ypos, xpos));
        if ( angle < 0 ) then
            angle = angle + 360;
        end

        Armory:SetConfigMinimapAngle(angle);
        ArmoryOptionsMinimapPanelAngleSlider:SetValue(angle);

    elseif ( self.updateDelay > 0.5 ) then
        self.updateDelay = 0;

        if ( Armory.dbLoaded ) then
            ArmoryMinimapButtonIcon:SetTexture(Armory:GetPortraitTexture("player"));
        end
    end
end

function ArmoryMinimapButton_Move()
    local angle = Armory:GetConfigMinimapAngle();
    local radius = Armory:GetConfigMinimapRadius();
    local xpos = radius * cos(angle);
    local ypos = radius * sin(angle);

    ArmoryMinimapButton:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", 54 - xpos, ypos - 55);
end

local Orig_GameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem;
function GameTooltip_ShowCompareItem(...)
    if ( ArmoryComparisonTooltip1:IsVisible() or ArmoryComparisonTooltip2:IsVisible() ) then
        return;
    end    
    return Orig_GameTooltip_ShowCompareItem(...);
end

function ArmoryComparisonFrame_OnUpdate(self, elapsed)
    local link, tooltip;

    self.updateTime = self.updateTime - elapsed;
    if ( self.updateTime > 0 ) then
        return;
    end
    self.updateTime = TOOLTIP_UPDATE_TIME;

    if ( not Armory:GetConfigShowEqcTooltips() ) then
        return;
    elseif ( GameTooltip:IsVisible() ) then
        tooltip = GameTooltip;
    elseif ( ItemRefTooltip:IsVisible() ) then
        tooltip = ItemRefTooltip;
    end
    self.tooltip = tooltip;

    if ( IsAltKeyDown() and tooltip ) then
        _, link = tooltip:GetItem();
        if ( self.link ~= link ) then
            self.link = link;
            self.hasShoppingTooltips = ShoppingTooltip1:IsVisible() or ShoppingTooltip2:IsVisible() or ShoppingTooltip3:IsVisible();
            if ( link ) then
                self.hasComparison = true;

                ShoppingTooltip1:Hide();
                ShoppingTooltip2:Hide();
                ShoppingTooltip3:Hide();

                ArmoryShowCompareItem(tooltip, link);
            end
        end

    elseif ( self.hasComparison ) then
        self.hasComparison = false;
        self.link = nil;

        ArmoryComparisonTooltip1:Hide();
        ArmoryComparisonTooltip2:Hide();

        if ( GameTooltip:IsVisible() and self.hasShoppingTooltips ) then
            GameTooltip_ShowCompareItem();
        end

    end
end

function ArmoryShowCompareItem(tooltip, link)
    ArmoryComparisonTooltip1:Hide();
    ArmoryComparisonTooltip2:Hide();

    if ( not link or link == "" ) then
        return;
    end

    local _, _, _, _, _, _, _, _, equipLoc = GetItemInfo(link);
    local slot = ARMORY_SLOTINFO[equipLoc];
    local slots = {};
    if ( not slot ) then
        return;
    elseif ( slot:match("Finger.Slot") ) then
        slots[1] = "Finger0Slot";
        slots[2] = "Finger1Slot";
    elseif ( slot:match("Trinket.Slot") ) then
        slots[1] = "Trinket0Slot";
        slots[2] = "Trinket1Slot";
    elseif ( slot == "MainHandSlot" or slot == "SecondaryHandSlot" ) then
        slots[1] = "SecondaryHandSlot";
        slots[2] = "MainHandSlot";
    else
        slots[1] = slot;
        slots[2] = nil;
    end

    local slotId = GetInventorySlotInfo(slots[1]);
    local itemLink = Armory:GetInventoryItemLink("player", slotId);
    if ( not itemLink ) then
        slots[1] = slots[2];
        slots[2] = nil;
    end
    if ( not slots[1] ) then
        return;
    end

    -- find correct side
    local side = "left";
    local rightDist = 0;
    local leftPos = tooltip:GetLeft();
    local rightPos = tooltip:GetRight();
    if ( not rightPos ) then
        rightPos = 0;
    end
    if ( not leftPos ) then
        leftPos = 0;
    end

    rightDist = GetScreenWidth() - rightPos;

    if (leftPos and (rightDist < leftPos)) then
        side = "left";
    else
        side = "right";
    end

    -- see if we should slide the tooltip
    if ( tooltip:GetAnchorType() ) then
        local totalWidth = 0;
        if ( slots[1]  ) then
            Armory:SetInventoryItem("player", GetInventorySlotInfo(slots[1]), nil, ArmoryComparisonTooltip1);
            totalWidth = totalWidth + ArmoryComparisonTooltip1:GetWidth();
        end
        if ( slots[2]  ) then
            Armory:SetInventoryItem("player", GetInventorySlotInfo(slots[2]), nil, ArmoryComparisonTooltip2);
            totalWidth = totalWidth + ArmoryComparisonTooltip2:GetWidth();
        end

        if ( (side == "left") and (totalWidth > leftPos) ) then
            tooltip:SetAnchorType(tooltip:GetAnchorType(), (totalWidth - leftPos), 0);
        elseif ( (side == "right") and (rightPos + totalWidth) >  GetScreenWidth() ) then
            tooltip:SetAnchorType(tooltip:GetAnchorType(), -((rightPos + totalWidth) - GetScreenWidth()), 0);
        end
    end

    -- anchor the compare tooltips
    if ( slots[1] ) then
        ArmoryComparisonTooltip1:SetOwner(tooltip, "ANCHOR_NONE");
        ArmoryComparisonTooltip1:ClearAllPoints();
        if ( side and side == "left" ) then
            ArmoryComparisonTooltip1:SetPoint("TOPRIGHT", tooltip:GetName(), "TOPLEFT", 0, -10);
        else
            ArmoryComparisonTooltip1:SetPoint("TOPLEFT", tooltip:GetName(), "TOPRIGHT", 0, -10);
        end
        Armory:SetInventoryItem("player", GetInventorySlotInfo(slots[1]), nil, ArmoryComparisonTooltip1);

        if ( slots[2] ) then
            ArmoryComparisonTooltip2:SetOwner(ArmoryComparisonTooltip1, "ANCHOR_NONE");
            ArmoryComparisonTooltip2:ClearAllPoints();
            if ( side and side == "left" ) then
                ArmoryComparisonTooltip2:SetPoint("TOPRIGHT", "ArmoryComparisonTooltip1", "TOPLEFT", 0, 0);
            else
                ArmoryComparisonTooltip2:SetPoint("TOPLEFT", "ArmoryComparisonTooltip1", "TOPRIGHT", 0, 0);
            end
            Armory:SetInventoryItem("player", GetInventorySlotInfo(slots[2]), nil, ArmoryComparisonTooltip2);
        end
    end
end

function Armory_EQC_Refresh()
    local frame = ArmoryComparisonFrame;
    if ( frame.hasComparison ) then
        ArmoryShowCompareItem(frame.tooltip, frame.link);
    end

    if ( EquipCompare_PostClearTooltip ) then
        EquipCompare_PostClearTooltip();
    end
end

function ArmoryTooltipsInit()
    local gttSetItemFunc = GameTooltip:GetScript("OnTooltipSetItem");
    local gttClearedFunc = GameTooltip:GetScript("OnTooltipCleared");

    GameTooltip:SetScript("OnTooltipSetItem", function(self, ...) return ArmoryEnhanceTooltip(gttSetItemFunc, self, ...) end);
    GameTooltip:SetScript("OnTooltipCleared", function(self, ...) return ArmoryClearTooltip(gttClearedFunc, self, ...) end);

    local irtSetItemFunc = ItemRefTooltip:GetScript("OnTooltipSetItem");
    local irtClearedFunc = ItemRefTooltip:GetScript("OnTooltipCleared");

    ItemRefTooltip:SetScript("OnTooltipSetItem", function(self, ...) return ArmoryEnhanceTooltip(irtSetItemFunc, self, ...) end);
    ItemRefTooltip:SetScript("OnTooltipCleared", function(self, ...) return ArmoryClearTooltip(irtClearedFunc, self, ...) end);
end

function ArmoryEnhanceTooltip(origFunc, tooltip, ...)
    if ( origFunc ) then
        origFunc(tooltip, ...);
    end

    if ( not tooltip or tooltip:GetName() == "ArmoryTooltip" ) then
        return;
    elseif ( not Armory.tooltipHasCounts ) then
        local _, link = tooltip:GetItem();
        
        if ( link ~= Armory.tooltipItemLink ) then
            Armory.tooltipItemLink = link;
            if ( link ) then
                Armory.tooltipItemCounts = Armory:GetItemCount(link);
            else
                Armory.tooltipItemCounts = nil;
            end
        end
        
        if ( Armory.tooltipItemCounts ) then 
            Armory.tooltipHasCounts = true;
            for k, v in ipairs(Armory.tooltipItemCounts) do
                tooltip:AddDoubleLine(format("%s [%d]", v.name, v.count), v.details, v.r, v.g, v.b, v.r, v.g, v.b);
            end
            tooltip:Show();
        end
    end
end

function ArmoryClearTooltip(origFunc, tooltip, ...)
    if ( origFunc ) then
        origFunc(tooltip, ...);
    end
    Armory.tooltipHasCounts = nil;
end

----------------------------------------------------------
-- EnhTooltip support
----------------------------------------------------------

function Armory_EnhTooltip_OnLoad()
    Stubby.RegisterFunctionHook("Armory.SetQuestLogItem", 200, Armory_EnhTooltip_HookSetQuestLogItem);
    Stubby.RegisterFunctionHook("Armory.SetInventoryItem", 200, Armory_EnhTooltip_HookSetInventoryItem);
    Stubby.RegisterFunctionHook("Armory.SetBagItem", 200, Armory_EnhTooltip_HookSetBagItem);
    Stubby.RegisterFunctionHook("Armory.SetTradeSkillItem", 200, Armory_EnhTooltip_HookSetTradeSkillItem);
end

function Armory_EnhTooltip_HookSetQuestLogItem(funcArgs, retVal, frame, qtype, slot)
    local link = Armory:GetQuestLogItemLink(qtype, slot);
    if ( link ) then
        local name, texture, quantity, quality, usable = Armory:GetQuestLogRewardInfo(slot);
        name = name or Armory:GetNameFromLink(link);
        quality = Armory:GetQualityFromLink(link);
        return EnhTooltip.TooltipCall(GameTooltip, name, link, quality, quantity);
    end
end

function Armory_EnhTooltip_HookSetInventoryItem(funcArgs, retVal, frame, unit, slot, dontShow, tooltip, link)
    if ( (link or Armory:SetInventoryItemInfo(unit, slot)) and not dontShow and not tooltip ) then
        link = link or Armory:GetInventoryItemLink(unit, slot);
        if ( link ) then
            local name = Armory:GetNameFromLink(link);
            local quantity = 1;
            local quality = Armory:GetQualityFromLink(link);
            return EnhTooltip.TooltipCall(GameTooltip, name, link, quality, quantity);
        end
    end
end

function Armory_EnhTooltip_HookSetBagItem(funcArgs, retVal, frame, frameID, buttonID)
    local link = Armory:GetContainerItemLink(frameID, buttonID);
    local name = Armory:GetNameFromLink(link);
    if ( name ) then
        local texture, itemCount, locked, quality, readable = Armory:GetContainerItemInfo(frameID, buttonID);
        if ( not (quality and quality ~= -1) ) then
            quality = Armory:GetQualityFromLink(link);
        end
        return EnhTooltip.TooltipCall(GameTooltip, name, link, quality, itemCount);
    end
end

function Armory_EnhTooltip_HookSetTradeSkillItem(funcArgs, retVal, frame, skill, slot)
    local link;
    if ( slot ) then
        link = Armory:GetTradeSkillReagentItemLink(skill, slot);
        if ( link ) then
            local name, texture, quantity, quantityHave = Armory:GetTradeSkillReagentInfo(skill, slot);
            local quality = Armory:GetQualityFromLink(link);
            return EnhTooltip.TooltipCall(GameTooltip, name, link, quality, quantity);
        end
    else
        link = Armory:GetTradeSkillItemLink(skill);
        if ( link ) then
            local name = Armory:GetNameFromLink(link);
            local quality = Armory:GetQualityFromLink(link);
            return EnhTooltip.TooltipCall(GameTooltip, name, link, quality);
        end
    end
end


----------------------------------------------------------
-- oGlow support
----------------------------------------------------------

function Armory_oGlow_OnLoad()
    hooksecurefunc("ArmoryPaperDollItemSlotButton_Update", Armory_oGlow_PaperDollItemSlotButton_Update);
    hooksecurefunc(Armory, "SetItemLink", Armory_oGlow_SetItemLink);
end

function Armory_oGlow_PaperDollItemSlotButton_Update(button)
    local getAlertStatus = function(buttonName)
        local alertSlots = {
            "ArmoryHeadSlot",
            "ArmoryShoulderSlot",
            "ArmoryChestSlot",
            "ArmoryWaistSlot",
            "ArmoryLegsSlot",
            "ArmoryFeetSlot",
            "ArmoryWristSlot",
            "ArmoryHandsSlot",
            "ArmoryMainHandSlot",
            "ArmorySecondaryHandSlot",
            "ArmoryRangedSlot"
        };
        for index, value in pairs(alertSlots) do
            if ( value == buttonName ) then
                return Armory:GetInventoryAlertStatus(index) or 2;
            end
        end
        return 2;
    end

    local slotId = button:GetID();
    local quality = Armory:GetInventoryItemQuality("player", slotId) or Armory:GetQualityFromLink(button.link);
    local isBroken = Armory:GetInventoryItemBroken("player", slotId);
    local status = getAlertStatus(button:GetName());

    if ( isBroken ) then
        quality = 100;
    elseif ( status == 3 ) then
        quality = 99;
    end
    oGlow(button, quality);
end

function Armory_oGlow_SetItemLink(self, button, link)
    if ( link ) then
        local _, _, quality = GetItemInfo(link);
        local icon = getglobal(button:GetName().."IconTexture");
        oGlow(button, quality or Armory:GetQualityFromLink(link), icon);
    elseif ( button.bc ) then
        button.bc:Hide();
    end
end
