--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmoryInventoryFrame.lua,v 1.22, 2008-11-11 10:16:26Z, Maxim Baars$
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

ARMORY_MAIL_CONTAINER = -3;
ARMORY_AUCTIONS_CONTAINER = -4;
ARMORY_COMPANION_CONTAINER = -5;

ArmoryContainers = { BACKPACK_CONTAINER, 1, 2, 3, 4, KEYRING_CONTAINER, BANK_CONTAINER, 5, 6, 7, 8, 9, 10, 11, ARMORY_MAIL_CONTAINER, ARMORY_AUCTIONS_CONTAINER, ARMORY_COMPANION_CONTAINER };

function ArmoryInventoryFrame_Toggle()
    if ( ArmoryInventoryFrame:IsShown() ) then
        HideUIPanel(ArmoryInventoryFrame);
    else
        ArmoryCloseChildWindows();
        ShowUIPanel(ArmoryInventoryFrame);
    end
end

function ArmoryInventoryFrame_OnLoad(self)
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("BAG_UPDATE");
    --self:RegisterEvent("BAG_UPDATE_COOLDOWN");
    self:RegisterEvent("BANKFRAME_OPENED");
    self:RegisterEvent("BANKFRAME_CLOSED");
    self:RegisterEvent("PLAYERBANKSLOTS_CHANGED");
    self:RegisterEvent("MAIL_SEND_SUCCESS");
    self:RegisterEvent("MAIL_CLOSED");
    self:RegisterEvent("AUCTION_OWNED_LIST_UPDATE");
    self:RegisterEvent("COMPANION_LEARNED");
    self:RegisterEvent("COMPANION_UPDATE");

    SetPortraitToTexture("ArmoryInventoryFramePortrait", "Interface\\Buttons\\Button-Backpack-Up");
    
    -- Tab Handling code
    PanelTemplates_SetNumTabs(self, 2);
    PanelTemplates_SetTab(self, 1);

    hooksecurefunc("SendMail", 
        function(name)
            Armory:SetMailSent(name); 
        end
    );
    hooksecurefunc("ReturnInboxItem", 
        function(id) 
            Armory:SetMailReturned(id); 
            ArmoryInventoryFrame_UpdateFrame(Armory:AddMailSent()); 
            end
    );
    hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", 
        function(self, button)
            local bag = self:GetParent():GetID();
            local slot = self:GetID();
            ArmoryInventoryFramePasteItem(button, GetContainerItemLink(bag, slot));
        end
    );
    hooksecurefunc("ChatFrame_OnHyperlinkShow", 
        function(self, link, text, button)
            ArmoryInventoryFramePasteItem(button, link);
        end
    );
end

function ArmoryInventoryFrame_OnEvent(self, event, ...)
    local arg1 = ...;
    local update = true;
    
    if ( not Armory:CanHandleEvents() ) then
        return;
    elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        Armory:Execute(ArmoryInventoryFrame_UpdateContainer, BACKPACK_CONTAINER);
        Armory:Execute(ArmoryInventoryFrame_UpdateContainer, KEYRING_CONTAINER);
        Armory:Execute(ArmoryInventoryFrame_UpdateContainer, ARMORY_COMPANION_CONTAINER);
        for i = 1, NUM_BAG_SLOTS do
            Armory:Execute(ArmoryInventoryFrame_UpdateContainer, i);
        end
        return;
    elseif ( event == "BAG_UPDATE" and arg1 <= NUM_BAG_SLOTS ) then
        Armory:Execute(ArmoryInventoryFrame_UpdateContainer, arg1);
    elseif ( event == "BAG_UPDATE" and self.bankOpen ) then
        -- Must execute immediately
        ArmoryInventoryFrame_UpdateContainer(arg1);
    elseif ( event == "PLAYERBANKSLOTS_CHANGED" and arg1 <= NUM_BANKGENERIC_SLOTS ) then
        -- Must execute immediately
        ArmoryInventoryFrame_UpdateContainer(BANK_CONTAINER);
    elseif ( event == "BANKFRAME_OPENED" ) then
        self.bankOpen = true;
        -- Must execute immediately
        ArmoryInventoryFrame_UpdateContainer(BANK_CONTAINER);
        for i = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
            ArmoryInventoryFrame_UpdateContainer(i);
        end
    elseif ( event == "BANKFRAME_CLOSED" ) then
        self.bankOpen = false;
        return;
    elseif ( event == "MAIL_SEND_SUCCESS" ) then
        update = Armory:AddMailSent();        
    elseif ( event == "MAIL_CLOSED" ) then
        -- Must execute immediately
        ArmoryInventoryFrame_UpdateContainer(ARMORY_MAIL_CONTAINER);
    elseif ( event == "AUCTION_OWNED_LIST_UPDATE" ) then
        -- Must execute immediately
        ArmoryInventoryFrame_UpdateContainer(ARMORY_AUCTIONS_CONTAINER);
    elseif ( event == "COMPANION_LEARNED" or event == "COMPANION_UPDATE" ) then
        -- Must execute immediately
        ArmoryInventoryFrame_UpdateContainer(ARMORY_COMPANION_CONTAINER);
    end
    
    ArmoryInventoryFrame_UpdateFrame(update);
end

function ArmoryInventoryFrame_UpdateFrame(update)
    if ( update and ArmoryInventoryFrame:IsShown() ) then
        Armory:Execute(ArmoryInventoryFrame_Update);
    end
end

function ArmoryInventoryFrame_UpdateContainer(id)
    Armory:SetContainer(id);
    Armory.tooltipItemLink = nil;
    Armory.tooltipItemCounts = nil;
end

function ArmoryInventoryFrameButton_OnClick(self)
    local id = self:GetID();
    if ( ArmoryInventoryListViewFrame:IsShown() ) then
        if ( self.isCollapsed ) then
            Armory:ExpandInventoryHeader(id);
        else
            Armory:CollapseInventoryHeader(id);
        end
    else
        if ( self.isCollapsed ) then
            Armory:ExpandContainer(id);
        else
            Armory:CollapseContainer(id);
        end
    end
    ArmoryInventoryFrame_Update();
end

function ArmoryInventoryFrame_OnShow(self)
    if ( Armory:GetInventoryItemNameFilter() == "" ) then
        ArmoryInventoryFrameEditBox:SetText(SEARCH);
    else
        ArmoryInventoryFrameEditBox:SetText(Armory:GetInventoryItemNameFilter());
    end
    if ( Armory:GetInventoryListViewMode() ) then
        PanelTemplates_SetTab(self, 2);
    else
        PanelTemplates_SetTab(self, 1);
    end
    ArmoryInventoryFrame_Update();
end

function ArmoryInventoryFrame_Update()
    if ( Armory:GetInventoryListViewMode() ) then
        ArmoryInventoryIconViewFrame:Hide();
        if ( ArmoryInventoryListViewFrame:IsShown() ) then
            ArmoryInventoryListViewFrame_Update();
        else
            ArmoryInventoryListViewFrame:Show();
        end
    else
        ArmoryInventoryListViewFrame:Hide();
        if ( ArmoryInventoryIconViewFrame:IsShown() ) then
            ArmoryInventoryIconViewFrame_Update();
        else
            ArmoryInventoryIconViewFrame:Show();
        end
    end    
end

function ArmoryInventoryFrameTab_OnClick(self)
    ArmoryCloseDropDownMenus();
    PanelTemplates_SetTab(ArmoryInventoryFrame, self:GetID());
    ArmoryInventoryFrameEnableListView(self:GetID() == 2);
end

function ArmoryInventoryFrameEnableListView(checked)
    Armory:SetInventoryListViewMode(checked);
    ArmoryInventoryFrame_Update();
end

function ArmoryInventoryMoneyFrame_OnShow(self)
    MoneyFrame_Update("ArmoryInventoryMoneyFrame", Armory:GetMoney());
end

function ArmoryInventoryMoneyFrame_OnEnter(self)
    local currentRealm, currentCharacter = Armory:GetPaperDollLastViewed();
    local currentFaction = Armory:UnitFactionGroup("player");
    local money = 0;
    for _, character in ipairs(Armory:CharacterList(currentRealm)) do
        Armory:LoadProfile(currentRealm, character);
        if ( Armory:UnitFactionGroup("player") == currentFaction ) then
            money = money + Armory:GetMoney();
        end
    end
    Armory:LoadProfile(currentRealm, currentCharacter);

    GameTooltip:AddLine(format(ARMORY_MONEY_TOTAL, currentRealm, currentFaction), "", 1, 1, 1);
    SetTooltipMoney(GameTooltip, money);
    GameTooltip:Show();
end

function ArmoryInventoryFilter_OnTextChanged(self)
    local text = self:GetText();
    local refresh;

    if ( text == SEARCH ) then
        refresh = Armory:SetInventoryItemNameFilter("");
    elseif ( text ~= "=" ) then
        refresh = Armory:SetInventoryItemNameFilter(text);
    end
    if ( refresh ) then
        ArmoryInventoryFrame_Update();
    end
end

function ArmoryInventoryFilterDropDown_OnLoad(self)
    ArmoryItemFilter_InitializeDropDown(self);
end

function ArmoryInventoryFilterDropDown_OnShow(self)
    ArmoryItemFilter_SelectDropDown(self, ArmoryInventoryFrame_Update);
end

function ArmoryInventoryFramePasteItem(button, link)
    if ( not ArmoryInventoryFrameEditBox:IsVisible() ) then
        return;
    elseif ( button == "LeftButton" and IsAltKeyDown() ) then
        local itemName = GetItemInfo(link);
        if ( itemName ) then
            ArmoryInventoryFrameEditBox:SetText(itemName);
        end
    end
end
