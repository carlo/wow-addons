--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmoryRaidInfoFrame.lua,v 1.5, 2008-10-16 18:17:26Z, Maxim Baars$
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

ARMORY_MAX_RAID_INFOS = 20;
ARMORY_MAX_RAID_INFOS_DISPLAYED = 9;

function ArmoryRaidInfoFrame_OnLoad(self)
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("UPDATE_INSTANCE_INFO");
end

function ArmoryRaidInfoFrame_OnEvent(self, event, ...)
    if ( not Armory:CanHandleEvents() ) then
        return;
    elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        RequestRaidInfo();
    elseif ( event == "UPDATE_INSTANCE_INFO" ) then
        Armory:Execute(ArmoryRaidInfoFrame_Update);
    end
end

function ArmoryRaidInfoFrame_OnShow(self)
    local savedInstances = Armory:GetNumSavedInstances();
    local instanceName, instanceID, instanceReset, instanceDifficulty;
    local j = 1;
    
    for i = 1, ARMORY_MAX_RAID_INFOS do
        if ( i <= savedInstances ) then
            instanceName, instanceID, instanceReset, instanceDifficulty = Armory:GetSavedInstanceInfo(i);

            if ( instanceName ) then
                frameName = _G["ArmoryRaidInfoInstance"..j.."Name"];
                frameNameText = _G["ArmoryRaidInfoInstance"..j.."NameText"];
                frameID = _G["ArmoryRaidInfoInstance"..j.."ID"];
                frameReset = _G["ArmoryRaidInfoInstance"..j.."Reset"];

                if ( instanceDifficulty > 1 ) then
                    frameNameText:SetFormattedText(DUNGEON_NAME_WITH_DIFFICULTY, instanceName, _G["DUNGEON_DIFFICULTY"..instanceDifficulty]);
                else
                    frameNameText:SetText(instanceName);
                end
				frameID:SetText(instanceID);
				frameReset:SetText(RESETS_IN.." "..SecondsToTime(instanceReset, nil, nil, 3));

                getglobal("ArmoryRaidInfoInstance"..j):Show();
                j = j + 1;
            end
        end
    end
    for i = j, ARMORY_MAX_RAID_INFOS do
        getglobal("ArmoryRaidInfoInstance"..i):Hide();
    end

    if ( savedInstances > ARMORY_MAX_RAID_INFOS_DISPLAYED ) then
        ArmoryRaidInfoScrollFrameTop:Show();
        ArmoryRaidInfoScrollFrameBottom:Show();
        ArmoryRaidInfoScrollFrameScrollBar:Show();
        ArmoryRaidInfoScrollFrameScrollBar:SetPoint("TOPLEFT", ArmoryRaidInfoScrollFrame, "TOPRIGHT", 6, 8);
    else
        ArmoryRaidInfoScrollFrameTop:Hide();
        ArmoryRaidInfoScrollFrameBottom:Hide();
        ArmoryRaidInfoScrollFrameScrollBar:Hide();
    end
end

function ArmoryRaidInfoFrame_Update()
    Armory:UpdateInstances();
end