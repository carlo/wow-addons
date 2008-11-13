---------------------------------------------------------------------------------
--
-- Prat - A framework for World of Warcraft chat mods
--
-- Copyright (C) 2006-2007  Prat Development Team
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to:
--
-- Free Software Foundation, Inc., 
-- 51 Franklin Street, Fifth Floor, 
-- Boston, MA  02110-1301, USA.
--
--
-------------------------------------------------------------------------------



--[[
Name: PratChannelSeparator
Revision: $Revision: 51543 $
Author(s): Krtek (krtek4@gmail.com)
           Sylvanaar (sylvanaar@mindspring.com)
Website: http://www.wowace.com/files/index.php?path=Prat/
Documentation: http://www.wowace.com/wiki/Prat/Integrated_Modules#ChannelSeparator
Subversion: http://svn.wowace.com/wowace/trunk/Prat/
Discussions: http://groups.google.com/group/wow-prat
Issues and feature requests: http://code.google.com/p/prat/issues/list
Description: Module for Prat that separates chat channels in the chat setting menu (default=on).
Dependencies: Prat
]]

-- Get Utility Libraries
local util, DBG, CLR = GetPratUtils()

-- set prat module name
local PRAT_MODULE = Prat:RequestModuleName("PratChannelSeparator")

if PRAT_MODULE == nil then 
    return 
end

-- define localized strings
local L = PRAT_LIBRARY(PRATLIB.LOCALIZATION):new(PRAT_MODULE)

L:RegisterTranslations("enUS", function() return {
    ["ChannelSeparator"] = true,
    ["Separates chat channels in chat setting menu."] = true,
} end)

L:RegisterTranslations("deDE", function() return {
    ["ChannelSeparator"] = "Kanal Trennen",
    ["Separates chat channels in chat setting menu."] = "Trennt Chat Kan\195\164le in dem Chateinstellungs Men\195\188.",
} end)

L:RegisterTranslations("esES", function() return {
    ["ChannelSeparator"] = "Separador de Canal",
    ["Separates chat channels in chat setting menu."] = "Separa los canales de chat en el men\195\186 de ajustes del chat",
} end)

L:RegisterTranslations("koKR", function() return {
    ["ChannelSeparator"] = "채널구분",
    ["Separates chat channels in chat setting menu."] = "대화 설정 메뉴에 대화 채널을 구분합니다.",
} end)

--Chinese Translation: 月色狼影@CWDG
--CWDG site: http://Cwowaddon.com
L:RegisterTranslations("zhCN", function() return {
    ["ChannelSeparator"] = "频道分离",
    ["Separates chat channels in chat setting menu."] = "分离聊天频道设置菜单。",
} end)

L:RegisterTranslations("zhTW", function() return {
    ["ChannelSeparator"] = "頻道分隔",
    ["Separates chat channels in chat setting menu."] = "在聊天設定選單中分隔聊天頻道。",
} end)

L:RegisterTranslations("frFR", function() return {
    ["ChannelSeparator"] = "S\195\169paration des canaux",
    ["Separates chat channels in chat setting menu."] = "S\195\169pare les canaux dans le menu des r\195\169glages de chat.",
} end)

BATTLEGROUND = TEXT(CHAT_MSG_BATTLEGROUND)

-- get prat module categories
local cat = Prat.Categories

-- create prat module
Prat_ChannelSeparator = Prat:NewModule(PRAT_MODULE)
Prat_ChannelSeparator.revision = tonumber(string.sub("$Revision: 51543 $", 12, -3))

-- define key module values
Prat_ChannelSeparator.moduleName = L["ChannelSeparator"]
Prat_ChannelSeparator.moduleDesc = L["Separates chat channels in chat setting menu."]
Prat_ChannelSeparator.consoleName = "chanseparator"
Prat_ChannelSeparator.guiName = L["ChannelSeparator"]
Prat_ChannelSeparator.Categories = { cat.CHANNEL }

-- define the default db values
Prat_ChannelSeparator.defaultDB = {
    on = true,
    OFFICER = {},
    RAID = {},
    BATTLEGROUND = {},
}

-- create a moduleOptions stub (for setting self.moduleOptions)
Prat_ChannelSeparator.moduleOptions = {}

-- build the options menu using prat templates
Prat_ChannelSeparator.toggleOptions = {}

--[[------------------------------------------------
    Module Event Functions
------------------------------------------------]]--

-- things to do when the module is initialized
function Prat_ChannelSeparator:OnModuleInit()
    self.OriginalChatTypeGroup = {}
    self.OriginalChannelMenuChatTypeGroups = {}
end

local function GetGroupSetting(chatFrame, group)
	local info = ChatTypeGroup[group];
	if ( info ) then
		for index, value in pairs(chatFrame.messageTypeList) do
			if ( strupper(value) == strupper(group) ) then
				return true
			end
		end
	end
	
	return false
end

-- things to do when the module is enabled
function Prat_ChannelSeparator:OnModuleEnable()
    self.OriginalChatTypeGroup = ChatTypeGroup
    ChatTypeGroup["GUILD"] = {
        "CHAT_MSG_GUILD",
        "GUILD_MOTD",
    };
    ChatTypeGroup["OFFICER"] = {
        "CHAT_MSG_OFFICER",
    };
    ChatTypeGroup["PARTY"] = {
        "CHAT_MSG_PARTY",
    };
    ChatTypeGroup["RAID"] = {
        "CHAT_MSG_RAID",
        "CHAT_MSG_RAID_LEADER",
        "CHAT_MSG_RAID_WARNING",
    };
    ChatTypeGroup["BATTLEGROUND"] = {
        "CHAT_MSG_BATTLEGROUND",
        "CHAT_MSG_BATTLEGROUND_LEADER",
    };
    self.OriginalChannelMenuChatTypeGroups = ChannelMenuChatTypeGroups
    ChannelMenuChatTypeGroups = {};
    ChannelMenuChatTypeGroups[1] = "SAY";
    ChannelMenuChatTypeGroups[2] = "YELL";
    ChannelMenuChatTypeGroups[3] = "GUILD";
    ChannelMenuChatTypeGroups[4] = "OFFICER";
    ChannelMenuChatTypeGroups[5] = "WHISPER";
    ChannelMenuChatTypeGroups[6] = "PARTY";
    ChannelMenuChatTypeGroups[7] = "RAID";
    ChannelMenuChatTypeGroups[8] = "BATTLEGROUND";
    local add = false
    for i=1,NUM_CHAT_WINDOWS do
        frame = getglobal("ChatFrame"..i)
    
        if self.db.profile.OFFICER[i] == nil then
            self.db.profile.OFFICER[i] = GetGroupSetting(frame, "GUILD")
        end
        if self.db.profile.RAID[i] == nil then
            self.db.profile.RAID[i] = GetGroupSetting(frame, "PARTY")
        end
        if self.db.profile.BATTLEGROUND[i] == nil then
            self.db.profile.BATTLEGROUND[i] = GetGroupSetting(frame, "PARTY")
        end     
        
         
        if self.db.profile.OFFICER[i] then 
            ChatFrame_AddMessageGroup(frame, "OFFICER")
        else
            ChatFrame_RemoveMessageGroup(frame, "OFFICER")
        end
        if self.db.profile.RAID[i] then 
            ChatFrame_AddMessageGroup(frame, "RAID")
        else
            ChatFrame_RemoveMessageGroup(frame, "RAID")            
        end
        if self.db.profile.BATTLEGROUND[i] then 
            ChatFrame_AddMessageGroup(frame, "BATTLEGROUND")
        else
            ChatFrame_RemoveMessageGroup(frame, "BATTLEGROUND")        
        end
    end

    self:SecureHook("ChatFrame_AddMessageGroup");
    self:SecureHook("ChatFrame_RemoveMessageGroup");
end



-- things to do when the module is disabled
function Prat_ChannelSeparator:OnModuleDisable()
    ChatTypeGroup = {}
    ChatTypeGroup = self.OriginalChatTypeGroup
    ChannelMenuChatTypeGroups = {}
    ChannelMenuChatTypeGroups = self.OriginalChannelMenuChatTypeGroups
end




function Prat_ChannelSeparator:ChatFrame_AddMessageGroup(frame, group)
    if group == "OFFICER" then
        self.db.profile.OFFICER[frame:GetID()] = true
    end
    if group == "RAID" then
        self.db.profile.RAID[frame:GetID()] = true
    end
    if group == "BATTLEGROUND" then
        self.db.profile.BATTLEGROUND[frame:GetID()] = true
    end
end


function Prat_ChannelSeparator:ChatFrame_RemoveMessageGroup(frame, group)
    if group == "OFFICER" then
        self.db.profile.OFFICER[frame:GetID()] = false
    end
    if group == "RAID" then
        self.db.profile.RAID[frame:GetID()] = false
    end
    if group == "BATTLEGROUND" then
        self.db.profile.BATTLEGROUND[frame:GetID()] = false
    end
end