--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmoryInventoryListViewFrame.lua,v 1.24, 2008-11-11 10:16:29Z, Maxim Baars$
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

ARMORY_INVENTORY_LINES_DISPLAYED = 20;
ARMORY_INVENTORY_HEIGHT = 16;

function ArmoryInventoryListViewFrame_OnShow(self)
    FauxScrollFrame_SetOffset(ArmoryInventoryListViewScrollFrame, 0);
    ArmoryInventoryListViewScrollFrameScrollBar:SetMinMaxValues(0, 0); 
    ArmoryInventoryListViewScrollFrameScrollBar:SetValue(0);
    Armory:SetInventorySearchAllFilter(Armory:GetInventorySearchAll());
    ArmoryInventoryListViewFrameSearchAllCheckButton:SetChecked(Armory:GetInventorySearchAllFilter());
    ArmoryInventoryListViewFrame_Update();
end

function ArmoryInventoryListItemButton_OnEnter(self)
    if ( self.item ) then
        local currentRealm, currentCharacter = Armory:GetPaperDollLastViewed();
        Armory:LoadProfile(self.realm, self.character);
        Armory:SetBagItem(self.container, self.item);
        Armory:LoadProfile(currentRealm, currentCharacter);
    end
end

function ArmoryInventoryListViewFrame_Update()
    if ( not ArmoryInventoryListViewFrame:IsShown() ) then
        return;
    end
    
    local numLines = Armory:GetNumInventoryLines();
    local offset = FauxScrollFrame_GetOffset(ArmoryInventoryListViewScrollFrame);

    if ( numLines == 0 ) then
        ArmoryInventoryCollapseAllButton:Disable();
    else
        ArmoryInventoryCollapseAllButton:Enable();
    end

    if ( offset > numLines ) then
        offset = 0;
        FauxScrollFrame_SetOffset(ArmoryInventoryListViewScrollFrame, offset);
    end

    -- ScrollFrame update
    FauxScrollFrame_Update(ArmoryInventoryListViewScrollFrame, numLines, ARMORY_INVENTORY_LINES_DISPLAYED, ARMORY_INVENTORY_HEIGHT);

    for i = 1, ARMORY_INVENTORY_LINES_DISPLAYED do
        local lineIndex = i + offset;
        local name, id, numAvailable, _, isHeader, index, link, realm, character, numFreeSlots = Armory:GetInventoryLineInfo(lineIndex);
        local lineButton = getglobal("ArmoryInventoryLine"..i);
        local lineButtonText = getglobal("ArmoryInventoryLine"..i.."Text");
        local lineButtonHighlight = getglobal("ArmoryInventoryLine"..i.."Highlight");
        local lineButtonDisabled = getglobal("ArmoryInventoryLine"..i.."Disabled");
        if ( lineIndex <= numLines ) then
               -- Set button widths if scrollbar is shown or hidden
            if ( ArmoryInventoryListViewScrollFrame:IsShown() ) then
                lineButtonText:SetWidth(265);
                lineButtonDisabled:SetWidth(295);
            else
                lineButtonText:SetWidth(285);
                lineButtonDisabled:SetWidth(315);
            end
            lineButton:Enable();

            lineButton:SetID(lineIndex);
            lineButton.container = id;
            lineButton.item = index;
            lineButton.link = link;
            lineButton.character = character;
            lineButton.realm = realm;
            lineButton:Show();
            if ( isHeader ) then
                lineButton.isCollapsed = Armory:GetInventoryLineState(lineIndex);
                if ( numFreeSlots and id ~= KEYRING_CONTAINER and id ~= ARMORY_MAIL_CONTAINER and id ~= ARMORY_AUCTIONS_CONTAINER and id ~= ARMORY_COMPANION_CONTAINER ) then
                    local containerName, numSlots = Armory:GetInventoryContainerInfo(id);
                    local prefix = "";
                    if ( id > NUM_BAG_SLOTS ) then
                        prefix = ARMORY_BANK_CONTAINER_NAME.." #"..(id - NUM_BAG_SLOTS).." - ";
                    elseif ( id > 0 ) then
                        prefix = "#"..id.." - ";
                    end
                    if ( numSlots ) then
                        name = format("%s[%d/%d] %s", prefix, numSlots - numFreeSlots, numSlots, containerName or name);
                    else
                        name = format("%s %s", prefix, containerName or name);
                    end
                end
                lineButton:SetText(name);
                if ( lineButton.isCollapsed ) then
                    lineButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
                else
                    lineButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
                end
                lineButtonHighlight:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
                lineButton:UnlockHighlight();
            elseif ( not name ) then
                return;
            else
                lineButton:SetNormalTexture("");
                lineButtonHighlight:SetTexture("");
                if ( numAvailable > 1 ) then
                    name = name.." ["..numAvailable.."]";
                end
                if ( link ) then
                    local color = Armory:GetColorFromLink(link);
                    if ( color ) then
                        name = color..name.."|r";
                    end
                end
                lineButton:SetText(name);

                -- Character/Realm header
                if ( id == nil ) then
                    lineButton:Disable();
                else
                    ArmoryInventoryListViewShowIcon(lineButton);
                end
            end
        else
            lineButton:Hide();
        end
    end

    -- Set the expand/collapse all button texture
    local numHeaders = 0;
    local notExpanded = 0;
    local numGroups = 0;
    for i = 1, numLines do
        local _, id, _, _, isHeader = Armory:GetInventoryLineInfo(i);
        local isItem = false;
        if ( id == nil ) then
            numGroups = numGroups + 1;
        elseif ( isHeader ) then
            numHeaders = numHeaders + 1;
            if ( Armory:GetInventoryLineState(i) ) then
                notExpanded = notExpanded + 1;
            end
        else
            isItem = true;
        end
    end
    -- If all headers are not expanded then show collapse button, otherwise show the expand button
    if ( notExpanded ~= (numLines - numGroups) ) then
        ArmoryInventoryCollapseAllButton.isCollapsed = nil;
        ArmoryInventoryCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
    else
        ArmoryInventoryCollapseAllButton.isCollapsed = 1;
        ArmoryInventoryCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
    end

    -- Indent items
    for i = 1, ARMORY_INVENTORY_LINES_DISPLAYED do
        local lineButton = getglobal("ArmoryInventoryLine"..i);
        local _, id, _, _, isHeader = Armory:GetInventoryLineInfo(lineButton:GetID());
        if ( id and not isHeader ) then
            getglobal("ArmoryInventoryLine"..i.."NormalTexture"):SetPoint("TOPLEFT", lineButton, "TOPLEFT", 21, 0);
            getglobal("ArmoryInventoryLine"..i.."Text"):SetPoint("TOPLEFT", lineButton, "TOPLEFT", 40, 0);
        else
            getglobal("ArmoryInventoryLine"..i.."NormalTexture"):SetPoint("TOPLEFT", lineButton, "TOPLEFT", 3, 0);
            getglobal("ArmoryInventoryLine"..i.."Text"):SetPoint("TOPLEFT", lineButton, "TOPLEFT", 21, 0);
        end
    end
end

function ArmoryInventoryListViewSearchAll(checked)
    Armory:SetInventorySearchAll(checked);
    if ( Armory:SetInventorySearchAllFilter(checked) ) then
        ArmoryInventoryListViewFrame_OnShow(ArmoryInventoryListViewFrame);
    end
end

function ArmoryInventoryListViewShowIcon(button)
    local currentRealm, currentCharacter = Armory:GetPaperDollLastViewed();
    Armory:LoadProfile(button.realm, button.character);

    local texture = Armory:GetContainerItemInfo(button.container, button.item);
    if ( texture ) then
        button:SetNormalTexture(texture);
    end
    Armory:LoadProfile(currentRealm, currentCharacter);
end
