--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmoryCmd.lua,v 1.5, 2008-11-11 22:24:45Z, Maxim Baars$
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

----------------------------------------------------------
-- ArmoryCommandHandler
----------------------------------------------------------

ArmoryCommandHandler = {};
ArmoryCommandHandler.__index = ArmoryCommandHandler;

function ArmoryCommandHandler:new()
    local self = {};
    setmetatable(self, ArmoryCommandHandler);

    self.delay = 0;
    self.interval = 0.5;
    self.queue = {};
    self.locked = false;

    self.timer = CreateFrame("Frame", nil, UIParent);
    self.timer:SetScript("OnUpdate", function(timer, elapsed) self:OnTimerUpdate(elapsed) end);

    return self;
end

function ArmoryCommandHandler:PrintDebug(...)
    Armory:PrintDebug(date("%X", time()), ...);
end

function ArmoryCommandHandler:AddConditionalCommand(condition, func, ...)
    local command = ArmoryCommand:new(func, ...);
    command.condition = condition;
    self:QueueCommand(command);
    return command;
end

function ArmoryCommandHandler:AddDelayedCommand(delay, func, ...)
    local command = ArmoryCommand:new(func, ...);
    command.time = time() + delay;
    self:QueueCommand(command);
    return command;
end

function ArmoryCommandHandler:AddCommand(func, ...)
    return self:AddDelayedCommand(1.0, func, ...);
end

function ArmoryCommandHandler:QueueCommand(command)
    if ( self.queue[command.key] ) then
        --self:PrintDebug("Command", command.key, "already scheduled");
    else
        self.queue[command.key] = command;
        --self:PrintDebug("Command", command.key, "scheduled");
    end
end

function ArmoryCommandHandler:IsQueued(command)
    return self.queue[command.key] ~= nil;
end

function ArmoryCommandHandler:OnTimerUpdate(elapsed)
    local now = time();
    local dequeued;

    if ( not self.locked and now >= self.delay ) then
        self.locked = true;
        for key, command in pairs(self.queue) do
            if ( now >= command.time and (not command.condition or command.condition()) ) then
                dequeued = command;
                --self:PrintDebug("Command", command.key, "dequeued");
                break;
            end
        end
        if ( dequeued ) then
            dequeued:Execute();
            self.queue[dequeued.key] = nil;
        else
            self.delay = now + self.interval;
        end
        self.locked = false;
    end
end


----------------------------------------------------------
-- ArmoryCommand
----------------------------------------------------------

ArmoryCommand = {};
ArmoryCommand.__index = ArmoryCommand;

function ArmoryCommand:new(func, ...)
    local self = {};
    setmetatable(self, ArmoryCommand);

    local createCommandKey = function(...)
            local key = strsub(tostring(func), 11);
            for i = 1, select("#", ...) do
                key = key..tostring(select(i, ...));
            end
            return key;
        end

    self.func = func;
    self.key = createCommandKey(...);
    if ( select("#", ...) > 1 ) then
        self.args = {...};
    else
        self.args = ...;
    end
    self.condition = nil;
    self.delay = 0;
    self.time = time();

    return self;
end

function ArmoryCommand:Execute()
    if ( self.func ) then
        if ( type(self.args) == "table" ) then
            self.func(unpack(self.args));
        else
            self.func(self.args);
        end
    end
end
