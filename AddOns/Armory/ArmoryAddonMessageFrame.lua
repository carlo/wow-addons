--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmoryAddonMessageFrame.lua,v 1.9, 2008-11-11 10:16:23Z, Maxim Baars$
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

ARMORY_BROADCAST_DELAY = 180;
ARMORY_MESSAGE_UPDATE_DELAY = 0.5;
ARMORY_MESSAGE_SEPARATOR = "\v";

ARMORY_MESSAGE_MODULE = {};
ARMORY_MESSAGE_RESPONSE_HANDLERS = {};
ARMORY_MESSAGE_REQUEST_HANDLERS = {};

function ArmoryAddonMessageFrame_RegisterHandlers(responseHandler, requestHandler)
    if ( type(responseHandler) == "function" ) then
        table.insert(ARMORY_MESSAGE_RESPONSE_HANDLERS, responseHandler);
    end
    if ( type(requestHandler) == "function" ) then
        table.insert(ARMORY_MESSAGE_REQUEST_HANDLERS, requestHandler);
    end
end

function ArmoryAddonMessageFrame_OnLoad(self)
    self.timerDelay = 0;
    self.broadcastDelay = 0;
    self:RegisterEvent("CHAT_MSG_ADDON");
end

function ArmoryAddonMessageFrame_OnEvent(self, event, ...)
    local arg1, arg2, arg3, arg4 = ...;
    
    if ( not Armory:CanHandleEvents() ) then
        return;
    elseif ( event == "CHAT_MSG_ADDON" and arg1 == ARMORY_ID ) then
        ArmoryAddonMessageFrame_ParseMessage(arg2, arg3, arg4);
    end
end

function ArmoryAddonMessageFrame_OnUpdate(self, elapsed)
    self.timerDelay = self.timerDelay + elapsed;
    if ( self.timerDelay > ARMORY_MESSAGE_UPDATE_DELAY ) then
        self.timerDelay = 0;
        for _, handler in ipairs(ARMORY_MESSAGE_RESPONSE_HANDLERS) do
            handler();
        end
    end

    self.broadcastDelay = self.broadcastDelay + elapsed;
    if ( self.broadcastDelay < ARMORY_BROADCAST_DELAY ) then
        return;
    end
    self.broadcastDelay = 0;

    if ( IsInGuild() ) then
        ArmoryAddonMessageFrame_SendMessage(Armory.version, "GUILD");
    end

    if ( GetNumRaidMembers() > 0 ) then
        ArmoryAddonMessageFrame_SendMessage(Armory.version, "RAID");
    elseif ( GetNumPartyMembers() > 0 ) then
        ArmoryAddonMessageFrame_SendMessage(Armory.version, "PARTY");
    end
end

function ArmoryAddonMessageFrame_Send(id, version, message, destination, msgNumber)
    local maxlen = 255 - strlen(ARMORY_ID) - 1;
    local msgType = "A";
    local segments = {};
    local segmentType = " ";
    local len;

    -- request or push?
    if ( msgNumber == nil or msgNumber == -1 ) then
        local module = ArmoryAddonMessageFrame_GetModule(id);
        module.msgno = module.msgno + 1;
        module.numReplies = 0;
        for key in pairs(module.replies) do
            module.replies[key] = nil;
        end
        for key in pairs(module.buffer) do
            module.buffer[key] = nil;
        end
        if ( msgNumber == nil ) then
            msgType = "R";
        else
            msgType = "P";
        end
        msgNumber = module.msgno;

        Armory:PrintDebug("Sending type", id, msgType, "#", msgNumber);
    else
        Armory:PrintDebug("Replying type", id, msgType, "#", msgNumber);
    end

    -- create message segments
    maxlen = maxlen - strlen(ArmoryAddonMessageFrame_GetSegment(id, version, msgType, msgNumber, segmentType, 0));
    repeat
        len = min(maxlen, strlen(message));
        if ( len > 0 ) then
            table.insert(segments, strsub(message, 1, len));
            if ( strlen(message) > len ) then            
                message = strsub(message, len - strlen(message));
            else
                message = "";
            end
        end
    until ( len == 0 );

    local segment;
    for i = 1, #segments do
        if ( i == #segments ) then
            segmentType = "L";
        end
        segment = ArmoryAddonMessageFrame_GetSegment(id, version, msgType, msgNumber, segmentType, i, segments[i]);
        ArmoryAddonMessageFrame_SendMessage(segment, destination);
    end
end

function ArmoryAddonMessageFrame_GetModule(id)
    if ( not ARMORY_MESSAGE_MODULE[id] ) then
        ARMORY_MESSAGE_MODULE[id] = {msgno=0, replies={}, buffer={}, numReplies=0};
    end
    return ARMORY_MESSAGE_MODULE[id];
end

function ArmoryAddonMessageFrame_AddReply(module, sender, message, version)
    if ( not module.replies[sender] ) then
        module.numReplies = module.numReplies + 1;
    end
    module.replies[sender] = {message=message, version=version, timestamp=time()};
end

function ArmoryAddonMessageFrame_RemoveReply(module, sender)
    module.replies[sender] = nil;
    module.numReplies = max(0, module.numReplies - 1);
end

function ArmoryAddonMessageFrame_GetSegment(id, version, msgType, msgNumber, segmentType, index, segment)
    return strjoin(ARMORY_MESSAGE_SEPARATOR, id, version, msgType, msgNumber, segmentType..strsub("00"..index, -3), segment or "");
end

function ArmoryAddonMessageFrame_SendMessage(message, destination)
    local target = destination:match("^TARGET:(.*)");

    if ( target ) then 
        destination = "WHISPER";
    end
    if ( Armory.messaging ) then
        ChatThrottleLib:SendAddonMessage("NORMAL", ARMORY_ID, message, destination, target);
    else
        ArmoryAddonMessageFrame_ParseMessage(message, "WHISPER", target or "test");
    end

    Armory:PrintDebug("Send", destination, target, message:gsub("%c", " "));
end

function ArmoryAddonMessageFrame_ParseMessage(message, channel, sender)
    local fields = Armory:StringSplit(ARMORY_MESSAGE_SEPARATOR, message);
    local getNextField = function(fields)
        local field = fields[1];
        table.remove(fields, 1);
        return field;
    end;

    Armory:PrintDebug("Received", sender, message:gsub("%c", " "));

    if ( #fields >= 6 ) then
        if ( not Armory:HasDataSharing() ) then
            Armory:PrintDebug("Sharing disabled");
            return;
        end

        local id = getNextField(fields);
        local module = ArmoryAddonMessageFrame_GetModule(id);
        local version = getNextField(fields);
        local msgType = getNextField(fields);
        local msgNumber = tonumber(getNextField(fields));

        -- msgNumber 0 in a reply indicates that the message number is not relevant (must be forced)
        if ( msgType == "A" and msgNumber > 0 and msgNumber ~= module.msgno ) then
            -- not an answer to the last request
            Armory:PrintDebug("Wrong message number", id, msgNumber, "expected:", module.msgno);
            return;
        end

        if ( not module.buffer[sender] ) then
            module.buffer[sender] = {count = 0};
        end
        local buffer = module.buffer[sender];
        local segment = getNextField(fields);
        local segmentType = strsub(segment, 1, 1);
        local index = tonumber(strsub(segment, 2));

        buffer[index] = strjoin(ARMORY_MESSAGE_SEPARATOR, unpack(fields));

        -- last segment
        if ( segmentType == "L" ) then
            buffer.count = index;
        end

        if ( buffer.count > 0 ) then
            -- join segments
            message = "";
            for i = 1, buffer.count do
                -- make sure all segments are received
                if ( buffer[i] == nil ) then
                    Armory:PrintDebug("Incomplete message");
                    module.buffer[sender] = nil;
                    return;
                end
                message = message..buffer[i];
            end
            module.buffer[sender] = nil;

            if ( msgType == "A" ) then
                -- queue answers to requests made
                Armory:PrintCommunication(string.format(ARMORY_LOOKUP_RESPONSE_RECEIVED, sender));
                ArmoryAddonMessageFrame_AddReply(module, sender, message, version);

            else
                -- can be a request for data or data pushed onto the channel
                if ( msgType == "R" ) then
                    Armory:PrintCommunication(string.format(ARMORY_LOOKUP_REQUEST_RECEIVED, sender));
                end

                if ( ArmoryAddonMessageFrame_CanSend() ) then
                    for _, handler in ipairs(ARMORY_MESSAGE_REQUEST_HANDLERS) do
                        handler(id, version, message, msgNumber, sender, channel);
                    end
                end
            end
        end
    elseif ( fields[1]:match("^[%d%.]+") ) then
        -- version broadcast received
        ArmoryPaperDollFrame_UpdateVersion(fields[1]);
    end
end

function ArmoryAddonMessageFrame_CreateRequest(id, version, message, destination)
    if ( destination == "TARGET" ) then
        if ( UnitExists("target") ) then
            ArmoryAddonMessageFrame_Send(id, version, message, destination..":"..UnitName("target"));
            Armory:PrintCommunication(string.format(ARMORY_LOOKUP_REQUEST_SENT, UnitName("target")));
        end
    else
        ArmoryAddonMessageFrame_Send(id, version, message, destination);

        local target = destination:match("TARGET:(.+)");
        if ( target ) then
            Armory:PrintCommunication(string.format(ARMORY_LOOKUP_REQUEST_SENT, target));
        else
            Armory:PrintCommunication(string.format(ARMORY_LOOKUP_REQUEST_SENT, strlower(destination)));
        end
    end
end

function ArmoryAddonMessageFrame_CanSend(hideMessage)
    local ignoreReason;

    if ( IsInInstance() and not Armory:GetConfigShareInInstance() ) then
        ignoreReason = ARMORY_IGNORE_REASON_INSTANCE;
    elseif ( (PlayerFrame.inCombat or PlayerFrame.onHateList) and not Armory:GetConfigShareInCombat() ) then
        ignoreReason = ARMORY_IGNORE_REASON_COMBAT;
    end

    if ( ignoreReason and not hideMessage ) then
        Armory:PrintCommunication(string.format(ARMORY_LOOKUP_IGNORED, ignoreReason));
    end

    return (not ignoreReason);
end