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
Name: PratChatLangButton
Revision: $Revision: 25389 $
Author(s): Derkyle (derkyle@gmail.com)
Website: http://www.wowace.com/files/index.php?path=Prat/
Documentation: http://www.wowace.com/wiki/Prat/Integrated_Modules#Buttons
Subversion: http://svn.wowace.com/wowace/trunk/Prat/
Discussions: http://groups.google.com/group/wow-prat
Issues and feature requests: http://code.google.com/p/prat/issues/list
Description: Module for Prat that adds the chat language button to chat frame.
Dependencies: Prat
]]

-- Get Utility Libraries
local util, DBG, CLR = GetPratUtils()

-- set prat module name
local PRAT_MODULE = Prat:RequestModuleName("PratChatLangButton")

if PRAT_MODULE == nil then 
    return 
end

-- define localized strings
local L = PRAT_LIBRARY(PRATLIB.LOCALIZATION):new(PRAT_MODULE)


L:RegisterTranslations("enUS", function() return {
 ["ChatLangButton"] = true,
 ["Toggle the chat language button."] = true,
} end)

L:RegisterTranslations("deDE", function() return {
 ["ChatLangButton"] = "Chat Sprachentaste",
 ["Toggle the chat language button."] = "Aktiviert die Chat Sprachentaste.",
} end)

L:RegisterTranslations("frFR", function() return {
 ["ChatLangButton"] = "Choix de la langue",
 ["Toggle the chat language button."] = "Active/dsactive le bouton de choix de la langue.",
} end)

L:RegisterTranslations("koKR", function() return {
 ["ChatLangButton"] = "대화언어버튼",
 ["Toggle the chat language button."] = "대화 언어 버튼을 표시합니다.",
} end)

L:RegisterTranslations("zhTW", function() return {
 ["ChatLangButton"] = "聊天語言按鈕",
 ["Toggle the chat language button."] = "切換是否顯示聊天語言按鈕。",
} end)

L:RegisterTranslations("esES", function() return {
 ["ChatLangButton"] = "Botón de Idioma de Chat",
 ["Toggle the chat language button."] = "Muestra y oculta el botón de idioma de chat",
} end)
--Chinese Translation: 月色狼影@CWDG
--CWDG site: http://Cwowaddon.com
L:RegisterTranslations("zhCN", function() return {
 ["ChatLangButton"] = "语言设置按钮",
 ["Toggle the chat language button."] = "切换显示聊天框语言设置按钮",
} end)

-- get prat module categories
local cat = Prat.Categories

-- create prat module
Prat_ChatLangButton = Prat:NewModule(PRAT_MODULE)
Prat_ChatLangButton.revision = tonumber(string.sub("$Revision: 25389 $", 12, -3))

-- define key module values
Prat_ChatLangButton.moduleName = L["ChatLangButton"]
Prat_ChatLangButton.moduleDesc = L["Toggle the chat language button."]
Prat_ChatLangButton.consoleName = "chatlangbutton"
Prat_ChatLangButton.guiName = L["ChatLangButton"]
Prat_ChatLangButton.Categories = { cat.BUTTON, cat.FRAME }

-- define the default db values
Prat_ChatLangButton.defaultDB = {
    on = false,
    colors = {},
}

-- create a moduleOptions stub (for setting self.moduleOptions)
Prat_ChatLangButton.moduleOptions = {}

-- build the options menu using prat templates
Prat_ChatLangButton.toggleOptions = {}

-- add module options not covered by templates
function Prat_ChatLangButton:GetModuleOptions()
    self.moduleOptions = {
        name = L["ChatLangButton"],
        desc = L["Toggle the chat language button."],
        type = "group",
        args = {
        }
    }
   	return self.moduleOptions
end

--[[------------------------------------------------
    Module Toggle Functions
------------------------------------------------]]--

-- things to do when the module is enabled
function Prat_ChatLangButton:OnModuleEnable()
	ChatFrameMenuButton:Show();
	--ChatMenu:Show();
end

-- things to do when the module is disabled
function Prat_ChatLangButton:OnModuleDisable()
	-- unregister events
	ChatFrameMenuButton:Hide();
end