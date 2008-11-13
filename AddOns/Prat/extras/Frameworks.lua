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
Name: Frameworks
Revision: $Revision: 51543 $
Author(s): Sylvaanar (sylvanaar@mindspring.com)
Website: http://files.wowace.com/Prat/
Description: Logical naming of libraries used througout Prat and all its modules.
]]

PRAT_LIBRARY = AceLibrary

PRAT_FRAMEWORKNAME = "Ace2"

PRAT_FRAMEWORK = {
    Ace2 = {
        LOCALIZATION = "AceLocale-2.2",
        PVP = "Glory-2.0",
        MEDIA = "SharedMedia-1.0",
        PARSING = "Deformat-2.0",
        BASE = "AceAddon-2.0",
        BARMENU = "FuBarPlugin-2.0", 
        TOOLTIPS = "Tablet-2.0", 
        WINDOWMENU = "Waterfall-1.0",
        EVENTS = "AceEvent-2.0",
        DATASTORE = "AceDB-2.0",
        CLASSTRANSLATIONS = "Babble-Class-2.2",
        TABCOMPLETION = "AceTab-2.0",
        DEBUGROUTING = "DebugStub-1.0", 
        CONSOLEMENU = "AceConsole-2.0", 
        NOTIFICATIONS = "Sink-1.0", 
        DEBUG = "AceDebug-2.0",
        HOOKS = "AceHook-2.1",
        MODULES = "AceModuleCore-2.0", 
        DROPDOWNMENU = "Dewdrop-2.0",
        WHO = "WhoLib-1.0"
    },
    
    Rock = {
        LOCALIZATION = "LibRockLocale-1.0",
        MEDIA = "LibSharedMedia-2.0",
        BASE = "LibRock-1.0",
        BARMENU = "LibFuBarPlugin-3.0", 
        EVENTS = "LibRockEvent-1.0",
        DATASTORE = "LibRockDB-1.0",
        CONSOLEMENU = "LibRockConsole-1.0", 
        HOOKS = "LibRockHook-1.0",
        MODULES = "LibRockModuleCore-1.0",     

        -- UNCHANGED --
        PARSING = "Deformat-2.0",
        PVP = "Glory-2.0",

        -- TODO -- 
        TOOLTIPS = "Tablet-2.0", 
        WINDOWMENU = "Waterfall-1.0",
        CLASSTRANSLATIONS = "Babble-Class-2.2",
        TABCOMPLETION = "AceTab-2.0",
        DEBUGROUTING = "DebugStub-1.0", 
        WHOINFOCACHE = "WhoLib-1.0", 
        NOTIFICATIONS = "Sink-1.0", 
        DEBUG = "AceDebug-2.0",
    }
}

PRATLIB = PRAT_FRAMEWORK[PRAT_FRAMEWORKNAME]
