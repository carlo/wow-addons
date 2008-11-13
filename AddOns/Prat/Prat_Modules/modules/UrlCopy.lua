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
Name: PratUrlCopy
Revision: $Revision: 51543 $
Author(s): Krtek (krtek4@gmail.com)
Website: http://www.wowace.com/files/index.php?path=Prat/
Documentation: http://www.wowace.com/wiki/Prat/Integrated_Modules#UrlCopy
SVN: http://svn.wowace.com/wowace/trunk/Prat/
Description: Module for Prat that makes it easy to copy URLs in chat windows.
Dependencies: Prat
]]

-- Get Utility Libraries
local util, DBG, CLR = GetPratUtils()

local PRAT_MODULE = Prat:RequestModuleName("PratUrlCopy")

if PRAT_MODULE == nil then
    return
end

local L = PRAT_LIBRARY(PRATLIB.LOCALIZATION):new(PRAT_MODULE)

L:RegisterTranslations("enUS", function() return {
    ["UrlCopy"] = true,
    ["URL formating options."] = true,
    ["Show Brackets"] = true,
    ["Toggle showing brackets on and off."] = true,
    ["Use Popup"] = true,
    ["Use popup window to show URL."] = true,
    ["Color URL"] = true,
    ["Toggle the URL color on and off."] = true,
    ["Set Color"] = true,
    ["Change the color of the URL."] = true,
    ["Toggle"] = true,
    ["Toggle the module on and off."] = true,
} end)

--[[
    Chinese Local : CWDG Translation Team 昏睡墨鱼 (Thomas Mo)
    CWDG site: http://Cwowaddon.com
]]

L:RegisterTranslations("zhCN", function() return {
    ["UrlCopy"] = "复制超链接",
    ["URL formating options."] = "超链接格式选项.",
    ["Show Brackets"] = "显示括号",
    ["Toggle showing brackets on and off."] = "切换显示括号功能打开与关闭.",
    ["Use Popup"] = "弹出",
    ["Use popup window to show URL."] = "用弹出窗口显示超链接.",
    ["Color URL"] = "颜色",
    ["Toggle the URL color on and off."] = "切换超链接颜色打开与关闭.",
    ["Set Color"] = "设置颜色",
    ["Change the color of the URL."] = "更改超链接颜色.",
    ["Toggle"] = "切换",
    ["Toggle the module on and off."] = "切换此模块的打开与关闭.",
} end)

L:RegisterTranslations("zhTW", function() return {
    ["UrlCopy"] = "複製超連結",
    ["URL formating options."] = "超連結格式選項。",
    ["Show Brackets"] = "顯示括號",
    ["Toggle showing brackets on and off."] = "切換顯示括號功能。",
    ["Use Popup"] = "使用彈出視窗",
    ["Use popup window to show URL."] = "用彈出視窗顯示超連結。",
    ["Color URL"] = "顏色",
    ["Toggle the URL color on and off."] = "切換使用超連結顏色。",
    ["Set Color"] = "設定顏色",
    ["Change the color of the URL."] = "更改超連結顏色。",
-- no use anymore    ["Toggle"] = true,
-- no use anymore    ["Toggle the module on and off."] = true,
} end)

L:RegisterTranslations("koKR", function() return {
    ["UrlCopy"] = "URL 복사",
    ["URL formating options."] = "URL 형식 설정입니다.",
    ["Show Brackets"] = "괄호 표시",
    ["Toggle showing brackets on and off."] = "괄호를 표시합니다.",
    ["Use Popup"] = "팝업 사용",
    ["Use popup window to show URL."] = "URL 표시를 위한 팝업창을 사용합니다.",
    ["Color URL"] = "URL 색상",
    ["Toggle the URL color on and off."] = "URL에 색상을 사용합니다.",
    ["Set Color"] = "색상 설정",
    ["Change the color of the URL."] = "URL의 색상을 변경합니다.",
    ["Toggle"] = "사용",
    ["Toggle the module on and off."] = "기능 사용 여부를 결정합니다.",
} end)

L:RegisterTranslations("esES", function() return {
    ["UrlCopy"] = "Copia de URL",
    ["URL formating options."] = "Opciones de formato de URL",
    ["Show Brackets"] = "Mostrar Par\195\169ntesis",
    ["Toggle showing brackets on and off."] = "Determina si se muestran los par\195\169ntesis",
    ["Use Popup"] = "Usar Ventana Emergente",
    ["Use popup window to show URL."] = "Usa una ventana emergente para mostrar la URL",
    ["Color URL"] = "Color del URL",
    ["Toggle the URL color on and off."] = "Determina si se colorea la URL",
    ["Set Color"] = "Establecer Color",
    ["Change the color of the URL."] = "Cambia el color del URL",
    ["Toggle"] = "Activar",
    ["Toggle the module on and off."] = "Activa y desactiva este m\195\179dulo.",
} end)

L:RegisterTranslations("deDE", function() return {
    ["UrlCopy"] = "URL Kopieren",
    ["URL formating options."] = "URL Format Optionen",
    ["Show Brackets"] = "Zeige Klammern",
    ["Toggle showing brackets on and off."] = "Schaltet das Anzeigen von Klammern an und aus.",
    ["Use Popup"] = "Benutze Popup",
    ["Use popup window to show URL."] = "Benutze Popup Fenster um die URL anzuzeigen.",
    ["Color URL"] = "F\195\164rbe URL",
    ["Toggle the URL color on and off."] = "Schaltet das einf\195\164rben der URL ein und aus.",
    ["Set Color"] = "W\195\164hle Farbe",
    ["Change the color of the URL."] = "Farbe der URL \195\164ndern.",
    ["Toggle"] = "Einschalten",
    ["Toggle the module on and off."] = "Schaltet das Modul an und aus.",
} end)

L:RegisterTranslations("frFR", function() return {
    ["UrlCopy"] = "Copie des URL",
    ["URL formating options."] = "Options d'affichage des URL.",
    ["Show Brackets"] = "Crochets",
    ["Toggle showing brackets on and off."] = "Affiche/masque les crochets autour de l'URL",
    ["Use Popup"] = "Fen\195\170tre flottante",
    ["Use popup window to show URL."] = "Affiche l'URL dans une fen\195\170tre flottante.",
    ["Color URL"] = "Colorer l'URL",
    ["Toggle the URL color on and off."] = "Affiche ou non l'URL en couleur.",
    ["Set Color"] = "Couleur",
    ["Change the color of the URL."] = "Change la couleur de l'URL.",
} end)


Prat_UrlCopy = Prat:NewModule(PRAT_MODULE)

Prat_UrlCopy.revision = tonumber(string.sub("$Revision: 51543 $", 12, -3))

Prat_UrlCopy.defaultDB = {
        on = true,
        bracket = true,
        popup = true,
        colorurl = true,
        color = {
            r = 1,
            g = 1,
            b = 1,
        },
}

Prat_UrlCopy.moduleName = L["UrlCopy"]
Prat_UrlCopy.consoleName = string.lower(Prat_UrlCopy.moduleName)

Prat_UrlCopy.moduleOptions = {}

Prat_UrlCopy.linkTable = {}

local cat = Prat.Categories

Prat_UrlCopy.Categories = { cat.LINK, cat.COLORS, cat.FILTER, cat.TEXT }

local function Link(...)
    return Prat_UrlCopy:Link(...)
end
local function LinkAndYield(...)
    return Prat_UrlCopy:LinkAndYield(...)
end
local function Skip(...)
    return Prat_UrlCopy:Skip(...)
end

Prat_UrlCopy.modulePatterns = {
        -- X://Y url
    { pattern = "(%a+://%S+[^%p%s])", matchfunc=Link},
        -- www.X.Y url
    { pattern = "(www%.[%w_-]+%.%S+[^%p%s])", matchfunc=Link},
        -- X@X.Y url (---> email)
    { pattern = "([%w_.-]+@[%w_.-]+%.%a%a%a?%a?)", matchfunc=Link},
        -- XXX.YYY.ZZZ.WWW:VVVV/UUUUU url
    { pattern = "(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?/%S+[^%p%s])", matchfunc=Link},
        -- XXX.YYY.ZZZ.WWW:VVVV url (IP of ts server for example)
    { pattern = "(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)", matchfunc=Link},
        -- XXX.YYY.ZZZ.WWW/VVVVV url (---> IP)
    { pattern = "(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?/%S+[^%p%s])", matchfunc=Link},
        -- XXX.YYY.ZZZ.WWW url (---> IP)
    { pattern = "(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)", matchfunc=Link},
        -- X.Y.Z:WWWW/VVVVV url
    { pattern = "([%w_.-]+[%w_-]%.%a%a%a?%a?:%d%d?%d?%d?%d?/%S+[^%p%s])", matchfunc=Link},
        -- X.Y.Z:WWWW url  (ts server for example)
    { pattern = "([%w_.-]+[%w_-]%.%a%a%a?%a?:%d%d?%d?%d?%d?)", matchfunc=Link},
        -- X.Y.Z/WWWWW url
    { pattern = "([%w_.-]+[%w_-]%.%a%a%a?%a?/%S+[^%p%s])", matchfunc=Link},
        -- X.Y.Z url where Z is greater than 4 characters
    { pattern = "([%w_.-]+[%w_-]%.%a%a%a%a%a+)", matchfunc=Skip},
        -- X.Y.Z url at end of line
    { pattern = "([%w_.-]+[%w_-]%.%a%a%a?%a?)$", matchfunc=Link},
        -- X.Y.Z url
    { pattern = "([%w_.-]+[%w_-]%.%a%a%a?%a?)(%A)", matchfunc=LinkAndYield},
}


function Prat_UrlCopy:GetModuleOptions()
    self.moduleOptions = {
        name = L["UrlCopy"],
        desc = L["URL formating options."],
        type = "group",
        args = {
            bracket = {
                name = L["Show Brackets"],
                desc = L["Toggle showing brackets on and off."],
                type = "toggle",
                order = 160,
                get = function() return self.db.profile.bracket end,
                set = function(v) self.db.profile.bracket = v end,
            },
            popup = {
                name = L["Use Popup"],
                desc = L["Use popup window to show URL."],
                type = "toggle",
                order = 170,
                get = function() return self.db.profile.popup end,
                set = function(v) self.db.profile.popup = v end,
            },
            colorurl = {
                name = L["Color URL"],
                desc = L["Toggle the URL color on and off."],
                type = "toggle",
                order = 180,
                get = function() return self.db.profile.colorurl end,
                set = function(v) self.db.profile.colorurl = v end
            },
            setcolor = {
                name = L["Set Color"],
                desc = L["Change the color of the URL."],
                type = "color",
                order = 190,
                get = function() return self.db.profile.color.r, self.db.profile.color.g, self.db.profile.color.b end,
                set = function(r, g, b, a) self.db.profile.color.r, self.db.profile.color.g, self.db.profile.color.b = r, g, b end,
                disabled = function() if not self.db.profile.colorurl then return true else return false end end,
            },
        }
    }

    return  self.moduleOptions
end

function Prat_UrlCopy:OnModuleEnable()
    -- { linkid, linkfunc, handler }
    Prat:RegisterLinkType(  { linkid="url", linkfunc=Prat_UrlCopy.Url_Link, handler=Prat_UrlCopy }, Prat_UrlCopy.moduleName)
end

Prat_UrlCopy.IWIN = "|cff9d9d9d|Hitem:18230:0:0:0:0:0:0:1763172530|h[Broken I.W.I.N. Button]|h|r"


--[[------------------------------------------------
	Core Functions
------------------------------------------------]]--


function Prat_UrlCopy:Url_Link(link, text, button, ...)
    Prat_UrlCopy:ShowUrl(link)
    return false
end

function Prat_UrlCopy:StaticPopupUrl(link)
    StaticPopupDialogs["SHOW_URL"] = StaticPopupDialogs["SHOW_URL"] or {
        text = "URL : %s",
        button2 = ACCEPT,
        hasEditBox = 1,
        hasWideEditBox = 1,

        OnShow = function()
            this:SetWidth(420)
            
            local editBox = getglobal(this:GetName().."WideEditBox")
            editBox:SetText(StaticPopupDialogs["SHOW_URL"].urltext)
            editBox:SetFocus()
            editBox:HighlightText(0)

            local button = getglobal(this:GetName().."Button2")
            button:ClearAllPoints()
            button:SetWidth(200)
            button:SetPoint("CENTER", editBox, "CENTER", 0, -30)
        end,

        OnHide = function() end,
        OnAccept = function() end,
        OnCancel = function() end,
        EditBoxOnEscapePressed = function() this:GetParent():Hide() end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1
    }

    StaticPopupDialogs["SHOW_URL"].urltext = link
    StaticPopup_Show ("SHOW_URL", link)
end

function Prat_UrlCopy:EditBoxUrl(link)
    if (not ChatFrameEditBox:IsShown()) then
        ChatFrame_OpenChat(link, DEFAULT_CHAT_FRAME)
    else
        ChatFrameEditBox:Insert(link)
    end
end

function Prat_UrlCopy:ShowUrl(link)
    link = strsub(link, 5)
    if ( self.db.profile.popup ) then
        Prat_UrlCopy:StaticPopupUrl(link)
    else
        Prat_UrlCopy:EditBoxUrl(link)
    end
end


-- Utility Function (called by gsub)
function Prat_UrlCopy:RawLink(link)
    local returnedLink = ""

    if Prat_UrlCopy.db.profile.colorurl then
        local c = Prat_UrlCopy.db.profile.color
        local color = string.format("%02x%02x%02x", c.r*255, c.g*255, c.b*255)
        returnedLink = "|cff" .. color
    end

    link = link:gsub('%%', '%%%%')

    returnedLink = returnedLink .. "|Hurl:" .. link .. "|h"

    if ( Prat_UrlCopy.db.profile.bracket ) then
        returnedLink = returnedLink .. "[" .. link .. "]"
    else
        returnedLink = returnedLink .. link
    end

    returnedLink = returnedLink .. "|h|r"

    return returnedLink
end

function  Prat_UrlCopy:LinkAndYield(link, yield, ...)
    if link == nil or yield == nil then
        return ""
    end

    return Prat_UrlCopy:AddLink(Prat_UrlCopy:RawLink(link))..yield
end

function  Prat_UrlCopy:Link(link, ...)
    if link == nil then
        return ""
    end

    return Prat_UrlCopy:AddLink(Prat_UrlCopy:RawLink(link))
end

function  Prat_UrlCopy:Skip(link, ...)
    if link == nil then
        return ""
    end

    return Prat_UrlCopy:AddLink(link)
end


function Prat_UrlCopy:AddLink(link)
     return Prat:RegisterMatch(link)
end
