--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmoryChat.lua,v 1.4, 2008-10-12 18:24:45Z, Maxim Baars$
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

ARMORYMSG = ARMORY_TITLE;
CHAT_ARMORYMSG_GET = "%s";
CHAT_ARMORYMSG_SEND = ARMORYMSG..": ";

function ArmoryChatSettings(...)
    local arg1, arg2 = ...;

    if ( not ArmoryLocalSettings ) then
        ArmoryLocalSettings = {};
    end
    if ( not ArmoryLocalSettings.Chat ) then
        ArmoryLocalSettings.Chat = {[1]=true, sticky=0, r=HIGHLIGHT_FONT_COLOR.r, g=HIGHLIGHT_FONT_COLOR.g, b=HIGHLIGHT_FONT_COLOR.b};
    end

    if ( arg1 ) then
        if ( select("#", ...) > 1 ) then
            ArmoryLocalSettings.Chat[arg1] = arg2;
        end
        return ArmoryLocalSettings.Chat[arg1];
    end

    return ArmoryLocalSettings.Chat;
end

function ArmoryChatInit()
    ChatTypeInfo["ARMORYMSG"] = ArmoryChatSettings();
    ChatTypeGroup["ARMORYMSG"] = {"CHAT_MSG_ARMORYMSG"};

    table.insert(CHAT_CONFIG_OTHER_SYSTEM, {
        type = "ARMORYMSG",
        checked = function () return IsListeningForMessageType("ARMORYMSG"); end;
        func = function (self, checked) ToggleChatMessageGroup(checked, "ARMORYMSG"); end;
    });

    ArmoryChatRegister();
end

function ArmoryChatRegister()
    for i = 1, NUM_CHAT_WINDOWS do
        if ( ArmoryChatSettings(i) ) then
            local chatFrame = getglobal("ChatFrame"..i);
            if ( chatFrame ) then
                table.insert(chatFrame.messageTypeList, "ARMORYMSG");
            end
        end
    end
end

function ArmoryChatAddMessage(message)
    ArmoryChatOnEvent("CHAT_MSG_ARMORYMSG", message, "", "", "", "", "", 0, 0, "");
end

function ArmoryChatOnEvent(event, ...)
    for i = 1, NUM_CHAT_WINDOWS do
        if ( ArmoryChatSettings(i) ) then
            ChatFrame_OnEvent(getglobal("ChatFrame"..i), event, ...);
        end
    end
end

local Orig_GetChatWindowMessages = GetChatWindowMessages;
function GetChatWindowMessages(index)
    local messages = {Orig_GetChatWindowMessages(index)};

    if ( ArmoryChatSettings(index) ) then
        table.insert(messages, "ARMORYMSG");
    end

    return unpack(messages);
end

local Orig_AddChatWindowMessages = AddChatWindowMessages;
function AddChatWindowMessages(index, chatType)
    if ( chatType == "ARMORYMSG" ) then
        ArmoryChatSettings(index, true);
    else
        Orig_AddChatWindowMessages(index, chatType);
    end
end

local Orig_RemoveChatWindowMessages = RemoveChatWindowMessages;
function RemoveChatWindowMessages(index, chatType)
    if ( chatType == "ARMORYMSG" ) then
        ArmoryChatSettings(index, false);
    else
        Orig_RemoveChatWindowMessages(index, chatType);
    end
end

local Orig_ChangeChatColor = ChangeChatColor;
function ChangeChatColor(chatType, r, g, b)
    if ( chatType == "ARMORYMSG" ) then
        ArmoryChatSettings("r", r);
        ArmoryChatSettings("g", g);
        ArmoryChatSettings("b", b);
    end

    Orig_ChangeChatColor(chatType, r, g, b);
end

local Orig_ResetChatWindows = ResetChatWindows;
function ResetChatWindows()
    Orig_ResetChatWindows();

    ArmoryLocalSettings.Chat = nil;
    ArmoryChatRegister();
end
