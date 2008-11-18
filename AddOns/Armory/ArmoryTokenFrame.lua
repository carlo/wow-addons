--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmoryTokenFrame.lua,v 1.0, 2008-10-12 18:25:04Z, Maxim Baars$
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

function ArmoryTokenButton_OnLoad(self)
    local name = self:GetName();
    self.count = getglobal(name.."Count");
    self.name = getglobal(name.."Name");
    self.icon = getglobal(name.."Icon");
    self.check = getglobal(name.."Check");
    self.expandIcon = getglobal(name.."ExpandIcon");
    self.categoryLeft = getglobal(name.."CategoryLeft");
    self.categoryRight = getglobal(name.."CategoryRight");
    self.highlight = getglobal(name.."Highlight");
    self.stripe = getglobal(name.."Stripe");
end

function ArmoryTokenButton_OnClick(self)
    if ( self.isHeader ) then
        if ( self.isExpanded ) then
            Armory:ExpandCurrencyList(self.index, 0);
        else
            Armory:ExpandCurrencyList(self.index, 1);
        end
    end
    ArmoryTokenFrame_Update();
end

function ArmoryTokenFrame_OnLoad(self)
    --self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("KNOWN_CURRENCY_TYPES_UPDATE");
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");

    ArmoryTokenFrameContainerScrollBar.Show = 
        function (self)
            ArmoryTokenFrameContainer:SetWidth(299);
            for _, button in next, getglobal("ArmoryTokenFrameContainer").buttons do
                button:SetWidth(295);
            end
            getmetatable(self).__index.Show(self);
        end;

    ArmoryTokenFrameContainerScrollBar.Hide = 
        function (self)
            ArmoryTokenFrameContainer:SetWidth(313);
            for _, button in next, ArmoryTokenFrameContainer.buttons do
                button:SetWidth(313);
            end
            getmetatable(self).__index.Hide(self);
        end;
        
    ArmoryTokenFrameContainer.update = ArmoryTokenFrame_Update;
    HybridScrollFrame_CreateButtons(ArmoryTokenFrameContainer, "ArmoryTokenButtonTemplate", 0, -2, "TOPLEFT", "TOPLEFT", 0, -TOKEN_BUTTON_OFFSET);
    local buttons = ArmoryTokenFrameContainer.buttons;
    local numButtons = #buttons;
    for i=1, numButtons do
        if ( mod(i, 2) == 1 ) then
            buttons[i].stripe:Hide();
        end
    end
end

function ArmoryTokenFrame_OnEvent(self, event, ...)
    if ( not Armory:CanHandleEvents() ) then
        return;
    elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
    end
    Armory:Execute(ArmoryTokenFrame_UpdateCurrency);
end

function ArmoryTokenFrame_OnShow(self)
    ArmoryTokenFrame_Update();
end

function ArmoryTokenFrame_Update()

    -- Setup the buttons
    local scrollFrame = ArmoryTokenFrameContainer;
    local offset = HybridScrollFrame_GetOffset(scrollFrame);
    local buttons = scrollFrame.buttons;
    local numButtons = #buttons;
    local numTokenTypes = Armory:GetCurrencyListSize();
    local name, isHeader, isExpanded, isUnused, isWatched, count, icon, extraCurrencyType;
    local button, index;
    for i=1, numButtons do
        index = offset+i;
        name, isHeader, isExpanded, isUnused, isWatched, count, extraCurrencyType, icon = Armory:GetCurrencyListInfo(index);
        button = buttons[i];
        button.check:Hide();
        if ( not name or name == "" ) then
            button:Hide();
        else
            if ( isHeader ) then
                button.categoryLeft:Show();
                button.categoryRight:Show();
                button.expandIcon:Show();
                button.count:SetText("");
                button.icon:SetTexture("");
                if ( isExpanded ) then
                    button.expandIcon:SetTexCoord(0.5625, 1, 0, 0.4375);
                else
                    button.expandIcon:SetTexCoord(0, 0.4375, 0, 0.4375);
                end
                button.highlight:SetTexture("Interface\\TokenFrame\\UI-TokenFrame-CategoryButton");
                button.highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -2);
                button.highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 2);
                button:SetText(name);
                button.name:SetText("");
            else
                button.categoryLeft:Hide();
                button.categoryRight:Hide();
                button.expandIcon:Hide();
                button.count:SetText(count);
                button.extraCurrencyType = extraCurrencyType;
                if ( extraCurrencyType == 1 ) then	--Arena points
                    button.icon:SetTexture("Interface\\PVPFrame\\PVP-ArenaPoints-Icon");
                    button.icon:SetTexCoord(0, 1, 0, 1);
                elseif ( extraCurrencyType == 2 ) then --Honor points
                    local factionGroup = Armory:UnitFactionGroup("player");
                    if ( factionGroup ) then
                        button.icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
                        button.icon:SetTexCoord( 0.03125, 0.59375, 0.03125, 0.59375 );
                    else
                        button.icon:Hide() --We don't know their faction yet!
                        button.icon:SetTexCoord(0, 1, 0, 1);
                    end
                else
                    button.icon:SetTexture(icon);
                    button.icon:SetTexCoord(0, 1, 0, 1);
                end
                if ( isWatched ) then
                    button.check:Show();
                end
                button.highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
                button.highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0);
                button.highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0);
                --Gray out the text if the count is 0
                if ( count == 0 ) then
                    button.count:SetFontObject("GameFontDisable");
                    button.name:SetFontObject("GameFontDisable");
                else
                    button.count:SetFontObject("GameFontHighlight");
                    button.name:SetFontObject("GameFontHighlight");
                end
                button:SetText("");
                button.name:SetText(name);
            end
            --Manage highlight
            if ( name == ArmoryTokenFrame.selectedToken ) then
                ArmoryTokenFrame.selectedID = index;
                button:LockHighlight();
            else
                button:UnlockHighlight();
            end

            button.index = index;
            button.isHeader = isHeader;
            button.isExpanded = isExpanded;
            button.isUnused = isUnused;
            button.isWatched = isWatched;
            button:Show();
        end
    end
    local totalHeight = numTokenTypes * (button:GetHeight()+TOKEN_BUTTON_OFFSET);
    local displayedHeight = #buttons * (button:GetHeight()+TOKEN_BUTTON_OFFSET);

    HybridScrollFrame_Update(scrollFrame, numTokenTypes, totalHeight, displayedHeight);
end

function ArmoryTokenFrame_UpdateCurrency()
    Armory:UpdateCurrency();
    ArmoryTokenFrame_Update();
end
