--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmoryOtherFrame.lua,v 1.3, 2008-10-12 18:24:53Z, Maxim Baars$
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

ARMORY_MAX_OTHER_TABS = 5;
ARMORY_OTHER_TABS = {REPUTATION, SKILLS, RAID, CURRENCY};

ARMORYOTHERFRAME_SUBFRAMES = { "ArmoryReputationFrame", "ArmorySkillFrame", "ArmoryRaidInfoFrame", "ArmoryTokenFrame" };

function ArmoryOtherFrame_ShowSubFrame()
    for index, value in pairs(ARMORYOTHERFRAME_SUBFRAMES) do
        getglobal(value):Hide();    
        if ( value == ARMORYOTHERFRAME_SUBFRAMES[PanelTemplates_GetSelectedTab(ArmoryOtherFrame)] ) then
            getglobal(value):Show();
        end    
    end 
end

function ArmoryOtherFrameTab_OnClick(self)
    PanelTemplates_SetTab(ArmoryOtherFrame, self:GetID());
    ArmoryOtherFrame_ShowSubFrame();
    PlaySound("igCharacterInfoTab");
end

function ArmoryOtherFrame_OnLoad(self)
    PanelTemplates_SetNumTabs(self, #ARMORY_OTHER_TABS);
    PanelTemplates_SetTab(self, 1);

    local tab;
    local maxWidth = 285;
    for i = 1, ARMORY_MAX_OTHER_TABS do
        tab = getglobal("ArmoryOtherFrameTab"..i);
        if ( i <= #ARMORY_OTHER_TABS ) then
            tab:SetText(ARMORY_OTHER_TABS[i]);
            PanelTemplates_TabResize(tab, 0, nil, maxWidth);
            maxWidth = maxWidth - tab:GetWidth() - 10;
            tab:Show();
        else
            tab:Hide();
        end
    end
end

function ArmoryOtherFrame_OnShow(self)
    PanelTemplates_SetTab(self, PanelTemplates_GetSelectedTab(self));
    ArmoryOtherFrame_ShowSubFrame();
end