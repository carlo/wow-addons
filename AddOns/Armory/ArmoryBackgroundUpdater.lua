--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmoryBackgroundUpdater.lua,v 1.0, 2008-11-11 22:24:45Z, Maxim Baars$
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

ArmoryBackgroundUpdater = {};
ArmoryBackgroundUpdater.__index = ArmoryBackgroundUpdater;

function ArmoryBackgroundUpdater:new()
    local self = {}; 
    setmetatable(self, ArmoryBackgroundUpdater);
    self.timer = CreateFrame("Frame", nil, UIParent);
    self.timer:Hide();
    self.timer:SetScript("OnUpdate", 
        function(timer) 
            if ( not self.thread ) then
                return;
            elseif ( coroutine.status(self.thread) == "dead" ) then
                timer:Hide();
                return;
            elseif ( coroutine.status(self.thread) == "suspended") then 
                coroutine.resume(self.thread, self);
            end
        end
    );
    return self;
end

function ArmoryBackgroundUpdater:Start(updateFunc)
    if ( not self.thread or coroutine.status(self.thread) == "dead" ) then
        self.thread = coroutine.create(updateFunc);
        self.timer:Show();
    end
end

function ArmoryBackgroundUpdater:Suspend()
    if ( self.thread ) then
        coroutine.yield(self.thread, self);
    end
end