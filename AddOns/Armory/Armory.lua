--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: Armory.lua,v 1.111, 2008-11-18 18:15:37Z, Maxim Baars$
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

StaticPopupDialogs["ARMORY_DB_INCOMPATIBLE"] = {
    text = ARMORY_DB_INCOMPATIBLE,
    button1 = OKAY,
    showAlert = 1,
    timeout = 0,
    whileDead = 1,
}

if ( not Armory ) then
    Armory = {
        debug = false,
        messaging = true,

        title = ARMORY_TITLE,
        version = GetAddOnMetadata("Armory", "Version"),
        dbVersion = 7,
        interface = _G.GetBuildInfo(),
        
        LDB = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Armory", 
            { type = "data source", 
              icon = "Interface\\CharacterFrame\\TemporaryPortrait", 
              text = UNKNOWN,
              label = ARMORY_TITLE
             }),

        options = {
            ARMORY_CMD_SET_SEARCHALL = {
                type = "toggle",
                set = function(value) Armory:SetConfigSaveSearchAll(value and value ~= "0"); end,
                get = function() return Armory:GetConfigSaveSearchAll(); end,
                disabled = function() return not Armory:HasInventory(); end,
                default = false
            },
            ARMORY_CMD_SET_LASTVIEWED = {
                type = "toggle",
                set = function(value) Armory:SetConfigLastViewed(value and value ~= "0"); end,
                get = function() return Armory:GetConfigLastViewed(); end,
                default = false
            },
            ARMORY_CMD_SET_PERCHARACTER = {
                type = "toggle",
                set = function(value) Armory:SetConfigPerCharacter(value and value ~= "0"); end,
                get = function() return Armory:GetConfigPerCharacter(); end,
                default = false
            },
            ARMORY_CMD_SET_SHOWALTEQUIP = {
                type = "toggle",
                set = function(value) Armory:SetConfigShowAltEquipment(value and value ~= "0"); end,
                get = function() return Armory:GetConfigShowAltEquipment(); end,
                disabled = function() return not Armory:HasInventory(); end,
                default = true
            },
            ARMORY_CMD_SET_SHOWUNEQUIP = {
                type = "toggle",
                set = function(value) Armory:SetConfigShowUnequippable(value and value ~= "0"); end,
                get = function() return Armory:GetConfigShowUnequippable(); end,
                disabled = function() return not (Armory:GetConfigShowAltEquipment() and Armory:HasInventory()); end,
                default = true
            },
            ARMORY_CMD_SET_SHOWEQCTOOLTIPS = {
                type = "toggle",
                set = function(value) Armory:SetConfigShowEqcTooltips(value and value ~= "0"); end,
                get = function() return Armory:GetConfigShowEqcTooltips(); end,
                default = true
            },
            ARMORY_CMD_SET_SHOWITEMCOUNT = {
                type = "toggle",
                set = function(value) Armory:SetConfigShowItemCount(value and value ~= "0"); end,
                get = function() return Armory:GetConfigShowItemCount(); end,
                disabled = function() return not Armory:HasInventory(); end,
                default = true
            },
            ARMORY_CMD_SET_SHOWQUESTALTS = {
                type = "toggle",
                set = function(value) Armory:SetConfigShowQuestAlts(value and value ~= "0"); end,
                get = function() return Armory:GetConfigShowQuestAlts(); end,
                disabled = function() return not Armory:HasQuestLog(); end,
                default = true
            },
            ARMORY_CMD_SET_EXPDAYS = {
                type = "range",
                set = function(value) Armory:SetConfigExpirationDays(value); end,
                get = function() return Armory:GetConfigExpirationDays(); end,
                disabled = function() return not Armory:HasInventory(); end,
                default = 3,
                minValue = 0,
                maxValue = 29,
                valueStep = 1
            },
            ARMORY_CMD_SET_SHOWSHAREMSG = {
                type = "toggle",
                set = function(value) Armory:SetConfigShowShareMessages(value and value ~= "0"); end,
                get = function() return Armory:GetConfigShowShareMessages(); end,
                disabled = function() return not Armory:HasDataSharing(); end,
                default = false
            },
            ARMORY_CMD_SET_SHARESKILLS = {
                type = "toggle",
                set = function(value) Armory:SetConfigShareProfessions(value and value ~= "0"); end,
                get = function() return Armory:GetConfigShareProfessions("player"); end,
                disabled = function() return not Armory:HasDataSharing(); end,
                default = true
            },
            ARMORY_CMD_SET_SHAREQUESTS = {
                type = "toggle",
                set = function(value) Armory:SetConfigShareQuests(value and value ~= "0"); end,
                get = function() return Armory:GetConfigShareQuests("player"); end,
                disabled = function() return not Armory:HasDataSharing(); end,
                default = true
            },
            ARMORY_CMD_SET_SHARECHARACTER = {
                type = "toggle",
                set = function(value) Armory:SetConfigShareCharacter(value and value ~= "0"); end,
                get = function() return Armory:GetConfigShareCharacter("player"); end,
                disabled = function() return not Armory:HasDataSharing(); end,
                default = true
            },
            ARMORY_CMD_SET_SHAREALT = {
                type = "toggle",
                set = function(value) Armory:SetConfigShareAsAlt(value and value ~= "0"); end,
                get = function() return Armory:GetConfigShareAsAlt("player"); end,
                disabled = function() return not Armory:HasDataSharing(); end,
                default = true
            },
            ARMORY_CMD_SET_SHAREININSTANCE = {
                type = "toggle",
                set = function(value) Armory:SetConfigShareInInstance(value and value ~= "0"); end,
                get = function() return Armory:GetConfigShareInInstance(); end,
                disabled = function() return not Armory:HasDataSharing(); end,
                default = true
            },
            ARMORY_CMD_SET_SHAREINCOMBAT = {
                type = "toggle",
                set = function(value) Armory:SetConfigShareInCombat(value and value ~= "0"); end,
                get = function() return Armory:GetConfigShareInCombat(); end,
                disabled = function() return not Armory:HasDataSharing(); end,
                default = true
            },
            ARMORY_CMD_SET_SHAREALL = {
                type = "toggle",
                set = function(value) Armory:SetConfigShareAll(value and value ~= "0"); end,
                get = function() return Armory:GetConfigShareAll(); end,
                disabled = function() return not Armory:HasDataSharing(); end,
                default = false
            },
            ARMORY_CMD_SET_SHAREGUILD = {
                type = "toggle",
                set = function(value) Armory:SetConfigShareGuild(value and value ~= "0"); end,
                get = function() return Armory:GetConfigShareGuild(); end,
                disabled = function() return not Armory:HasDataSharing() or Armory:GetConfigShareAll(); end,
                default = true
            },
            ARMORY_CMD_SET_GLOBALSEARCH = {
                type = "toggle",
                set = function(value) Armory:SetConfigGlobalSearch(value and value ~= "0"); end,
                get = function() return Armory:GetConfigGlobalSearch(); end,
                default = true
            },
            ARMORY_CMD_SET_UPDATECRITERIA = {
                type = "toggle",
                set = function(value) Armory:SetConfigUpdateCriteria(value and value ~= "0"); end,
                get = function() return Armory:GetConfigUpdateCriteria(); end,
                disabled = function() return not Armory:HasAchievements(); end,
                default = false
            },
            ARMORY_CMD_CHECK = {
                type = "execute",
                run = function() Armory:CheckMailItems() end,
                disabled = function () return not Armory:HasInventory() or Armory:GetConfigExpirationDays() == 0; end
            },
            ARMORY_CMD_RESET_FRAME = {
                type = "execute",
                run = function() Armory:Reset(ARMORY_CMD_RESET_FRAME, true) end
            },
            ARMORY_CMD_LOOKUP = {
                type = "execute",
                run = function() ArmoryLookupFrame_Toggle() end,
                disabled = function () return not Armory:HasDataSharing(); end
            },
            ARMORY_CMD_SET_SHOWMINIMAP = {
                type = "toggle",
                set = function(value) Armory:SetConfigShowMinimap(value and value ~= "0"); end,
                get = function() return Armory:GetConfigShowMinimap(); end,
                default = true
            },
            ARMORY_CMD_SET_HIDEMMTOOLBAR = {
                type = "toggle",
                set = function(value) Armory:SetConfigHideMinimapIfToolbar(value and value ~= "0"); end,
                get = function() return Armory:GetConfigHideMinimapIfToolbar(); end,
                disabled = function() return not Armory:GetConfigShowMinimap(); end,
                default = true
            },
            ARMORY_CMD_SET_MMB_ANGLE = {
                type = "range",
                set = function(value) Armory:SetConfigMinimapAngle(value); end,
                get = function() return Armory:GetConfigMinimapAngle(); end,
                disabled = function() return not Armory:GetConfigShowMinimap(); end,
                default = 170,
                minValue = 0,
                maxValue = 360,
                valueStep = 0.01
            },
            ARMORY_CMD_SET_MMB_RADIUS = {
                type = "range",
                set = function(value) Armory:SetConfigMinimapRadius(value); end,
                get = function() return Armory:GetConfigMinimapRadius(); end,
                disabled = function() return not Armory:GetConfigShowMinimap(); end,
                default = 80,
                minValue = 80,
                maxValue = 160,
                valueStep = 1
            },
            ARMORY_CMD_SET_FILTERALL = {
                type = "toggle",
                set = function(value) Armory:SetConfigFilterAllMessages(value and value ~= "0"); end,
                get = function() return Armory:GetConfigFilterAllMessages(); end,
                default = true
            },
        },
    };
end

function Armory:Fullname()
    --return self.title..LIGHTYELLOW_FONT_COLOR_CODE.." (v"..self.version..")"..FONT_COLOR_CODE_CLOSE;
    return self.title;
end

function Armory:PrintTitle(...)
    self:Print("["..self:Fullname().."]", ...);
end

function Armory:PrintDebug(...)
    if ( self.debug ) then
        self:PrintMessage(self:ToString(self.interface..RED_FONT_COLOR_CODE, ...), true);
    end
end

function Armory:PrintCommunication(...)
    if ( self:GetConfigShowShareMessages() ) then
        self:PrintMessage(self:ToString("["..self:Fullname().."]"..LIGHTYELLOW_FONT_COLOR_CODE, ...), true);
    end
end

function Armory:Print(...)
    self:PrintMessage(self:ToString(...));
end

function Armory:PrintMessage(msg, filter)
    if ( filter or self:GetConfigFilterAllMessages() ) then
        ArmoryChatAddMessage(msg);
    else
        DEFAULT_CHAT_FRAME:AddMessage(msg);
    end

    if ( Elephant and Elephant.InitCustomStructure and Elephant.CaptureNewMessage ) then
        local lcname, cname = strlower(ARMORY_TITLE), ARMORY_TITLE;
        Elephant:InitCustomStructure(lcname, cname);
        Elephant:CaptureNewMessage({['type'] = "SYSTEM", ['arg1'] = msg, ['time'] = time()}, lcname);
    end
end

function Armory:ChatCommand(msg)
    local args = self:String2Table(msg);
    local printUsage =
        function(cmd)
            self:PrintTitle(ARMORY_CMD_USAGE);
            for i = 1, table.getn(self.usage) do
                if ( not cmd or cmd == ARMORY_CMD_HELP or cmd == self.usage[i][3] ) then
                    self:Print(self:GetUsageLine(i));
                end
            end
        end;

    if ( args and args[1] ) then
        local command = strlower(args[1]);
        if ( command == "debug" ) then
            Armory.debug = not Armory.debug;
            if ( AGB and args[2] and strlower(args[2]) == "agb" ) then
               AGB.debug = Armory.debug;
            end
            if ( Armory.debug ) then
                self:Print("Debug is now on");
            else
                self:Print("Debug is now off");
            end
        else
            table.remove(args, 1);
            if ( self.commands[command] ) then
                if ( self.commands[command](unpack(args)) ) then
                    printUsage(command);
                end
            else
                printUsage();
            end
        end
    else
        self:Toggle();
    end
end

function Armory:SetCommand(label, func)
    local command = getglobal(label:gsub("^(ARMORY_CMD_%u-)_.*$", "%1"));
    local help = getglobal(label.."_TEXT");
    local params, options, usage, disabled;

    if ( label == "ARMORY_CMD_SET_NOVALUE" ) then
        params = "xxx";
    elseif ( label == "ARMORY_CMD_FIND" ) then
        local cat = {ARMORY_CMD_FIND_ALL};
        if ( self:HasInventory() ) then
            table.insert(cat, ARMORY_CMD_FIND_ITEM);
        end
        if ( self:HasQuestLog() ) then
            table.insert(cat, ARMORY_CMD_FIND_QUEST);
        end
        if ( self:HasSpellBook() ) then
            table.insert(cat, ARMORY_CMD_FIND_SPELL);
        end
        if ( self:HasTradeSkills() ) then
            table.insert(cat, ARMORY_CMD_FIND_SKILL);
        end
        if ( #cat == 1 ) then
            return;
        end
        params = strjoin("|", unpack(cat));
    elseif ( label == "ARMORY_CMD_CHECK" and not self:HasInventory() ) then
        return;
    elseif ( getglobal(label) == command ) then
        params = "";
    else
        params = getglobal(label) or "";
    end

    if ( self.options[label] ) then
        if ( self.options[label].disabled and self.options[label].disabled() ) then
            return;
        elseif ( self.options[label].type == "toggle" ) then
            options = ARMORY_CMD_SET_ON.."|"..ARMORY_CMD_SET_OFF;
        end
    end
    if ( getglobal(label.."_PARAMS_TEXT") ) then
        options = getglobal(label.."_PARAMS_TEXT");
        help = format(help, options);
    end
    if ( options and options ~= params ) then
        params = params.." "..options;
    end

    usage = SLASH_ARMORY2.." "..command;
    if ( params ~= "" ) then
        usage = usage.." "..params;
    end
    table.insert(self.usage, {usage, help, command});

    self.commands[command] = func;
end

function Armory:GetUsageLine(index)
    local usage = self.usage[index];
    if ( usage ) then
        return "  "..usage[1]..GRAY_FONT_COLOR_CODE.." - "..usage[2]..FONT_COLOR_CODE_CLOSE;
    end
end

function Armory:PrepareMenu()
    if ( not self.menu ) then
        self.menu = CreateFrame("Frame", "ArmoryMenu", nil, "ArmoryDropDownMenuTemplate");
        ArmoryDropDownMenu_Initialize(self.menu, self.InitializeMenu, "MENU"); 
    end
end

function Armory:InitializeMenu()
    if ( ARMORY_DROPDOWNMENU_MENU_LEVEL == 2 ) then 
        Armory:MenuAddButton("ARMORY_CMD_SET_SHARESKILLS");
        Armory:MenuAddButton("ARMORY_CMD_SET_SHAREQUESTS");
        Armory:MenuAddButton("ARMORY_CMD_SET_SHARECHARACTER");
        Armory:MenuAddButton("ARMORY_CMD_SET_SHAREALT");
        Armory:MenuAddButton("ARMORY_CMD_SET_SHAREININSTANCE");
        Armory:MenuAddButton("ARMORY_CMD_SET_SHAREINCOMBAT");
        Armory:MenuAddButton("ARMORY_CMD_SET_SHOWSHAREMSG");
        Armory:MenuAddButton("ARMORY_CMD_SET_SHAREALL", true);
        Armory:MenuAddButton("ARMORY_CMD_SET_SHAREGUILD");
        Armory:MenuAddButton("ARMORY_CMD_LOOKUP", true);
    else
        local info = {};
        info.text = ARMORY_TITLE;
        info.notClickable = 1;
        info.isTitle = 1;
        ArmoryDropDownMenu_AddButton(info);

        Armory:MenuAddButton("ARMORY_CMD_SET_SEARCHALL");
        Armory:MenuAddButton("ARMORY_CMD_SET_LASTVIEWED");
        Armory:MenuAddButton("ARMORY_CMD_SET_PERCHARACTER");
        Armory:MenuAddButton("ARMORY_CMD_SET_SHOWALTEQUIP", true);
        Armory:MenuAddButton("ARMORY_CMD_SET_SHOWUNEQUIP");
        Armory:MenuAddButton("ARMORY_CMD_SET_SHOWEQCTOOLTIPS");
        Armory:MenuAddButton("ARMORY_CMD_SET_SHOWITEMCOUNT");
        Armory:MenuAddButton("ARMORY_CMD_SET_SHOWQUESTALTS");
        Armory:MenuAddButton("ARMORY_CMD_CHECK");
        Armory:MenuAddButton("ARMORY_CMD_RESET_FRAME");

        ArmoryDropDownMenu_AddButton({text=ARMORY_SHARE_LABEL, hasArrow=1});
    end
end

function Armory:MenuAddButton(label, closeMenu)
    local entry = self.options[label];
    local info = {};

    info.text = getglobal(label.."_MENUTEXT");
    info.tooltipTitle = info.text;
    info.tooltipText = getglobal(label.."_TOOLTIP") or self:Proper(getglobal(label.."_TEXT"));
    if ( entry.type == "toggle" ) then
        info.getFunc = entry.get;
        info.setFunc = entry.set;
        info.func = function() info.setFunc(not info.getFunc()) end;
        info.checked = entry.get();
        info.keepShownOnClick = not closeMenu;
    else
        info.runFunc = entry.run;
        info.func = function() info.runFunc() end;
    end
    if ( entry.disabled ) then
        info.disabled = entry.disabled();
    end

    ArmoryDropDownMenu_AddButton(info, ARMORY_DROPDOWNMENU_MENU_LEVEL);
end

function Armory:Init()
    local _,class = _G.UnitClass("player");

    self.dbLoaded = false;
    self.dbLocked = false;
    self.locked = {};
    self.modulesDbEntry = nil;
    self.settingsDbEntry = nil;
    self.settingsLocalDbEntry = nil;
    self.selectedDbBaseEntry = nil;
    self.playerRealm = _G.GetRealmName();
    self.player = _G.UnitName("player");
    self.playerDbBaseEntry = nil;
    self.characterRealm = _G.GetRealmName();
    self.character = nil;
    self.characterDbBaseEntry = nil;
    self.selectedPet = nil;
    self.profiles = {};
    self.hasEquipment = false;
    self.hasStats = false;
    self.skillLines = nil;
    self.factionLines = nil;
    self.professionLines = nil;
    self.selectedSkill = nil;
    self.selectedSkillLine = 1;
    self.tradeSkillSubClassFilter = {};
    self.tradeSkillInvSlotFilter = {};
    self.tradeSkillFilter = "";
    self.tradeSkillMinLevel = 0;
    self.tradeSkillMaxLevel = 0;
    self.inventoryLines = {};
    self.inventoryFilter = "";
    self.inventoryState = {};
    self.questLines = nil;
    self.selectedQuestLine = 0;
    self.currencyLines = nil;
    self.mailTo = "";
    self.mailItems = {};
    self.categories = nil;
    self.statisticCategories = nil;
    self.achievementLines = nil;
    self.statisticLines = nil;
    self.achievementFilter = "";

    if ( not self.commandHandler ) then
        self.commandHandler = ArmoryCommandHandler:new{};
    end

    SlashCmdList["ARMORY"] = function(...)
        return self:ChatCommand(...);
    end;

    self.commands = {};
    self.usage = {
        {SLASH_ARMORY2, ARMORY_CMD_TOGGLE}
    };

    self:SetCommand("ARMORY_CMD_HELP", function() return true end);
    self:SetCommand("ARMORY_CMD_CONFIG", function() Armory:OpenConfigPanel() end);
    self:SetCommand("ARMORY_CMD_DELETE_ALL", function(...) return Armory:ClearDb(...) end);
    self:SetCommand("ARMORY_CMD_DELETE_REALM", function(...) return Armory:ClearDb(...) end);
    self:SetCommand("ARMORY_CMD_DELETE_CHAR", function(...) return Armory:ClearDb(...) end);
    --self:SetCommand("ARMORY_CMD_SET_NOVALUE");
    --self:SetCommand("ARMORY_CMD_SET_EXPDAYS", function(...) return Armory:SetConfig(...) end);
    --self:SetCommand("ARMORY_CMD_SET_SEARCHALL", function(...) return Armory:SetConfig(...) end);
    --self:SetCommand("ARMORY_CMD_SET_LASTVIEWED", function(...) return Armory:SetConfig(...) end);
    --self:SetCommand("ARMORY_CMD_SET_PERCHARACTER", function(...) return Armory:SetConfig(...) end);
    --self:SetCommand("ARMORY_CMD_SET_SHOWALTEQUIP", function(...) return Armory:SetConfig(...) end);
    --self:SetCommand("ARMORY_CMD_SET_SHOWUNEQUIP", function(...) return Armory:SetConfig(...) end);
    --self:SetCommand("ARMORY_CMD_SET_SHOWEQCTOOLTIPS", function(...) return Armory:SetConfig(...) end);
    --self:SetCommand("ARMORY_CMD_SET_SHOWITEMCOUNT", function(...) return Armory:SetConfig(...) end);
    --self:SetCommand("ARMORY_CMD_SET_SHOWQUESTALTS", function(...) return Armory:SetConfig(...) end);
    self:SetCommand("ARMORY_CMD_RESET_FRAME", function(...) return Armory:Reset(...) end);
    self:SetCommand("ARMORY_CMD_RESET_SETTINGS", function(...) return Armory:Reset(...) end);
    self:SetCommand("ARMORY_CMD_CHECK", function() Armory:CheckMailItems() end);
    self:SetCommand("ARMORY_CMD_FIND", function(...) return Armory:Find(...) end);
    self:SetCommand("ARMORY_CMD_LOOKUP", function(...) ArmoryLookupFrame_Toggle(...) end);

    for i = 1, GetNumAddOns() do
        if ( GetAddOnInfo(i) == ARMORY_SHARE_DOWNLOAD_ADDON ) then
            self:SetCommand("ARMORY_CMD_DOWNLOAD", function(...) ArmoryLookupFrame_StartDownload(...) end);
            break;
        end
    end
end

function Armory:InitDb()
    if ( not ArmoryModules ) then
        ArmoryModules = {};
    end
    self.modulesDbEntry = ArmoryDbEntry:new(ArmoryModules);

    if ( not ArmorySettings ) then
        ArmorySettings = {};
    end
    self.settingsDbEntry = ArmoryDbEntry:new(ArmorySettings);

    if ( not ArmoryLocalSettings ) then
        ArmoryLocalSettings = {};
    end
    self.settingsLocalDbEntry = ArmoryDbEntry:new(ArmoryLocalSettings);

    if ( not (ArmoryDB and self:IsDbCompatible()) ) then
        ArmoryDB = {};
    end
    if ( not ArmoryDB[self.playerRealm] ) then
        ArmoryDB[self.playerRealm] = {};
    end
    if ( not ArmoryDB[self.playerRealm][self.player] ) then
        ArmoryDB[self.playerRealm][self.player] = {};
    end

    self.playerDbBaseEntry = ArmoryDbEntry:new(ArmoryDB[self.playerRealm][self.player]);
    self.selectedDbBaseEntry = self.playerDbBaseEntry;

    self.dbLoaded = true;
end

function Armory:IsDbCompatible()
    local dbEntry = self.settingsDbEntry;
    local dbVersion = dbEntry:GetValue("DbVersion");
    local upgraded;

    if ( not dbVersion ) then
        -- pre version 3
        dbEntry:SetValue("DbVersion", self.dbVersion);

    elseif ( dbVersion ~= self.dbVersion) then
        -- convert from 4 to 5
        if ( dbVersion == 4 ) then
            local settings = {"ShareSkills", "ShareQuests", "ShareCharacter", "ShareAsAlt"};
            for realm in pairs(ArmoryDB) do
                for character in pairs(ArmoryDB[realm]) do
                    for _, setting in ipairs(settings) do
                        if ( not ArmorySettings["PerCharacter"] ) then
                            ArmorySettings["PerCharacter"] = {};
                        end
                        if ( not ArmorySettings["PerCharacter"][realm] ) then
                            ArmorySettings["PerCharacter"][realm] = {};
                        end
                        if ( not ArmorySettings["PerCharacter"][realm][character] ) then
                            ArmorySettings["PerCharacter"][realm][character] = {};
                        end
                        ArmorySettings["PerCharacter"][realm][character][setting] = ArmoryDB[realm][character][setting];
                        ArmoryDB[realm][character][setting] = nil;
                    end
                end
            end

            upgraded = true;
        end

        if ( upgraded ) then
            dbEntry:SetValue("DbVersion", dbVersion + 1);
            return self:IsDbCompatible();
        end

        dbEntry:SetValue("DbVersion", self.dbVersion);
        StaticPopup_Show("ARMORY_DB_INCOMPATIBLE");
        return false;
    end

    return true;
end

function Armory:SetConfig(what, arg1, arg2)
    local invalidCommand = false;
    local entry;

    if ( what ) then
        what = strlower(what);

        if ( what == strlower(ARMORY_CMD_SET_EXPDAYS) ) then
            entry = self.options.ARMORY_CMD_SET_EXPDAYS;
            if ( tonumber(arg1) ) then
                arg1 = tonumber(arg1);
                if ( arg1 >= entry.minValue and arg1 <= entry.maxValue ) then
                    entry.set(tonumber(arg1));
                    if ( arg1 == 0 ) then
                        arg1 = arg1.." ("..OFF..")";
                    end
                    self:Print(format(ARMORY_CMD_SET_SUCCESS, ARMORY_CMD_SET_EXPDAYS, arg1));
                else
                    self:Print(format(ARMORY_CMD_SET_EXPDAYS_INVALID, ARMORY_CMD_SET_EXPDAYS_PARAMS_TEXT, entry.minValue, entry.maxValue));
                end
            elseif ( entry.get() == 0 ) then
                self:Print(format(ARMORY_CMD_SET_NOVALUE, "0 ("..OFF..")"));
            else
                self:Print(format(ARMORY_CMD_SET_NOVALUE, entry.get()));
            end

        else
            if ( what == strlower(ARMORY_CMD_SET_SEARCHALL) ) then
                entry = self.options.ARMORY_CMD_SET_SEARCHALL;
            elseif ( what == strlower(ARMORY_CMD_SET_LASTVIEWED) ) then
                entry = self.options.ARMORY_CMD_SET_LASTVIEWED;
            elseif ( what == strlower(ARMORY_CMD_SET_SHOWALTEQUIP) ) then
                entry = self.options.ARMORY_CMD_SET_SHOWALTEQUIP;
            elseif ( what == strlower(ARMORY_CMD_SET_SHOWUNEQUIP) ) then
                entry = self.options.ARMORY_CMD_SET_SHOWUNEQUIP;
            elseif ( what == strlower(ARMORY_CMD_SET_SHOWEQCTOOLTIPS) ) then
                entry = self.options.ARMORY_CMD_SET_SHOWEQCTOOLTIPS;
            elseif ( what == strlower(ARMORY_CMD_SET_SHOWITEMCOUNT) ) then
                entry = self.options.ARMORY_CMD_SET_SHOWITEMCOUNT;
            elseif ( what == strlower(ARMORY_CMD_SET_SHOWQUESTALTS) ) then
                entry = self.options.ARMORY_CMD_SET_SHOWQUESTALTS;
            elseif ( what == strlower(ARMORY_CMD_SET_PERCHARACTER) ) then
                entry = self.options.ARMORY_CMD_SET_PERCHARACTER;
            end

            if ( entry ) then
                invalidCommand = self:SwitchSetting(what, arg1, entry.set, entry.get);
            else
                invalidCommand = true;
            end
        end
    else
        invalidCommand = true;
    end

    return invalidCommand;
end

function Armory:SwitchSetting(what, arg1, onoffSet, onoffGet)
    local on = strlower(ARMORY_CMD_SET_ON);
    local off = strlower(ARMORY_CMD_SET_OFF);

    if ( arg1 ) then
        arg1 = strlower(arg1);
        if ( arg1 == on ) then
            onoffSet(self, true);
            self:Print(format(ARMORY_CMD_SET_SUCCESS, strlower(what), on));
        elseif ( arg1 == off ) then
            onoffSet(self, false);
            self:Print(format(ARMORY_CMD_SET_SUCCESS, strlower(what), off));
        else
            return true;
        end
    elseif ( onoffGet(self) ) then
        self:Print(format(ARMORY_CMD_SET_NOVALUE, on));
    else
        self:Print(format(ARMORY_CMD_SET_NOVALUE, off));
    end
    return false;
end

function Armory:ClearDb(what, arg1, arg2)
    local invalidCommand = false;
    local playerDeleted;

    if ( what ) then
        what = strlower(what);

        if ( ArmoryFrame:IsVisible() ) then
            self:Toggle();
        end

        self.dbLocked = true;
        if ( what == strlower(ARMORY_CMD_DELETE_ALL) ) then
            ArmoryDB = {};
            playerDeleted = true;
            self:Print(ARMORY_CMD_DELETE_ALL_MSG);
        elseif ( what == strlower(ARMORY_CMD_DELETE_REALM)  ) then
            if ( not arg1 or arg1 == "" ) then
                arg1 = self.playerRealm;
            end
            if ( ArmoryDB[arg1] ) then
                ArmoryDB[arg1] = nil;
                playerDeleted = (arg1 == self.playerRealm);
                self:Print(format(ARMORY_CMD_DELETE_REALM_MSG, arg1));
            else
                self:Print(format(ARMORY_CMD_DELETE_REALM_NOT_FOUND, arg1));
            end
        elseif ( what == strlower(ARMORY_CMD_DELETE_CHAR) ) then
            if ( not arg1 or arg1 == "" ) then
                arg1 = self.player;
            end
            if ( not arg2 or arg2 == "" ) then
                arg2 = self.playerRealm;
            end
            if ( ArmoryDB[arg2] and ArmoryDB[arg2][arg1] ) then
                self:DeleteProfile(arg2, arg1, true);
                playerDeleted = (arg1 == self.player and arg2 == self.playerRealm);
                self:Print(format(ARMORY_CMD_DELETE_CHAR_MSG, arg1, arg2));
            else
                self:Print(format(ARMORY_CMD_DELETE_CHAR_NOT_FOUND, arg1, arg2));
            end
        else
            invalidCommand = true;
        end
    else
        invalidCommand = true;
    end

    self:Init();
    self:InitDb();

    -- make sure all required values are saved once again
    if ( playerDeleted ) then
        for _, frameName in ipairs(ARMORYFRAME_SUBFRAMES) do
            local eventHandler = getglobal(frameName.."_OnEvent");
            if ( eventHandler ) then
                eventHandler("PLAYER_ENTERING_WORLD");
            end
        end
        for _, frameName in ipairs(ARMORYFRAME_CHILDFRAMES) do
            local eventHandler = getglobal(frameName.."_OnEvent");
            if ( eventHandler ) then
                eventHandler("PLAYER_ENTERING_WORLD");
            end
        end
    end

    return invalidCommand;
end

function Armory:Reset(what, silent)
    local invalidCommand = false;

    if ( what ) then
        what = strlower(what);

        if ( what == strlower(ARMORY_CMD_RESET_FRAME) ) then
            ArmoryFrame:ClearAllPoints();
            ArmoryFrame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 0, -104);
        elseif ( what == strlower(ARMORY_CMD_RESET_SETTINGS) ) then
            ArmorySettings = {};
            self.settingsDbEntry = ArmoryDbEntry:new(ArmorySettings);
        else
            invalidCommand = true;
        end
    else
        invalidCommand = true;
    end

    if ( not (invalidCommand or silent) ) then
        self:Print(format(ARMORY_CMD_RESET_SUCCESS, what));
    end

    return invalidCommand;
end

function Armory:OpenConfigPanel()
    InterfaceOptionsFrame_OpenToCategory(ARMORY_TITLE);
end

function Armory:Setting(key, subkey, ...)
    local set = select("#", ...) > 0;
    if ( self.settingsDbEntry ) then
        if ( set ) then
            self.settingsDbEntry:SetSubValue(key, subkey, ...);
            if ( key ~= "General" ) then
                self:LocalSetting(key, subkey, ...);
            end
        end
        if ( key ~= "General" and self:GetConfigPerCharacter() ) then
            return self:LocalSetting(key, subkey);
        else
            return self.settingsDbEntry:GetSubValue(key, subkey);
        end
    end
end

function Armory:LocalSetting(key, subkey, ...)
    local set = select("#", ...) > 0;
    if ( self.settingsLocalDbEntry ) then
        if ( set ) then
            self.settingsLocalDbEntry:SetSubValue(key, subkey, ...);
        end
        return self.settingsLocalDbEntry:GetSubValue(key, subkey);
    end
end

function Armory:CharacterSetting(key, unit, ...)
    local set = select("#", ...) > 0;
    if ( self.settingsDbEntry ) then
        local dbEntry = ArmoryDbEntry:new(self.settingsDbEntry);
        local realm = self.playerRealm;
        local character = self.player;

        if ( set ) then
            dbEntry:SetPosition("PerCharacter", realm, character);
            dbEntry:SetValue(key, ...);        
            dbEntry:ResetPosition();
        end

        if (unit ~= "player") then
            realm, character = self:GetPaperDollLastViewed();
        end
        dbEntry:SetPosition("PerCharacter", realm, character);
        return dbEntry:GetValue(key);
    end
end

function Armory:ItemFilterSetting(key)
    if ( not ArmorySettings ) then
        ArmorySettings = {};
    end
    if ( not ArmorySettings.Filters ) then
        ArmorySettings.Filters = {};
    end
    if ( not ArmorySettings.Filters[key] ) then
        ArmorySettings.Filters[key] = {};
    end
    
    return ArmorySettings.Filters[key];
end

function Armory:CanHandleEvents()
    return self.dbLoaded and not self.dbLocked;
end

function Armory:ExecuteConditional(func, ...)
    return self.commandHandler:AddConditionalCommand(func, ...);
end

function Armory:ExecuteDelayed(delay, func, ...)
    return self.commandHandler:AddDelayedCommand(delay, func, ...);
end

function Armory:Execute(func, ...)
    return self.commandHandler:AddCommand(func, ...);
end

function Armory:IsExecuted(command)
    return not self.commandHandler:IsQueued(command);
end

function Armory:Profiles()
    if ( not self.profiles ) then
        self.profiles = {};
    end

    if ( ArmoryDB and table.getn(self.profiles) == 0 ) then
        for realm in pairs(ArmoryDB) do
            for character in pairs(ArmoryDB[realm]) do
                table.insert(self.profiles, {realm=realm, character=character});
            end
        end
        table.sort(self.profiles, function(a, b) return a.realm..a.character < b.realm..b.character end);
    end

    return self.profiles;
end

function Armory:CurrentProfile()
    local realm, character = self:GetPaperDollLastViewed();
    return {realm=realm, character=character};
end

function Armory:SelectProfile(profile)
    self:LoadProfile(profile.realm, profile.character);
end

function Armory:SetProfile(profile)
    self:SelectProfile(profile);
    self.LDB.icon = Armory:GetPortraitTexture("player");
    self.LDB.text = profile.character;
end

function Armory:LoadProfile(realm, character)
    realm = realm or _G.GetRealmName();
    character = character or self.player;

    self:SetPaperDollLastViewed(realm, nil);
    self.characterDbBaseEntry = nil;

    if ( not ArmoryDB ) then
        return;
    elseif ( not ArmoryDB[realm] ) then
        return;
    elseif ( not ArmoryDB[realm][character] ) then
        return;
    end

    self:SetPaperDollLastViewed(realm, character);
    self.characterDbBaseEntry = ArmoryDbEntry:new(ArmoryDB[realm][character]);
    self.selectedDbBaseEntry = self.characterDbBaseEntry;
end

function Armory:DeleteProfile(realm, character, force)
    if ( (not force) and realm == self.playerRealm and character == self.player ) then
        return;
    elseif ( not ArmoryDB ) then
        return;
    elseif ( not ArmoryDB[realm] ) then
        return;
    elseif ( not ArmoryDB[realm][character] ) then
        return;
    end
    ArmoryDB[realm][character] = nil;
    self.profiles = {};
    self.characterDbBaseEntry = nil;
    self.selectedDbBaseEntry = self.playerDbBaseEntry;

    if ( realm ~= self.playerRealm and table.getn(self:CharacterList(realm)) == 0 ) then
        ArmoryDB[realm] = nil;
        self:SetPaperDollLastViewed(self.playerRealm, nil);
    else
        self:SetPaperDollLastViewed(realm, nil);
    end
end

function Armory:Toggle()
    if ( ArmoryFrame:IsVisible() ) then
        HideUIPanel(ArmoryFrame);
    else
        ShowUIPanel(ArmoryFrame);
    end
end

function Armory:RealmList()
    local list = {};

    if ( ArmoryDB ) then
        for realm in pairs(ArmoryDB) do
            table.insert(list, realm);
        end
        table.sort(list);
    end

    return list;
end

function Armory:CharacterList(realm)
    local list = {};

    if ( realm and ArmoryDB and ArmoryDB[realm] ) then
        for char in pairs(ArmoryDB[realm]) do
            table.insert(list, char);
        end
        table.sort(list);
    end

    return list;
end

function Armory:CheckMailItems(countOnly)
    local maxDays = self:GetConfigExpirationDays();
    local count = 0;

    if ( maxDays > 0 and self:HasInventory() ) then
        local currentProfile = self:CurrentProfile();
        for _, profile in ipairs(self:Profiles()) do
            self:SelectProfile(profile);
            local _, numSlots = self:GetInventoryContainerInfo(ARMORY_MAIL_CONTAINER);
            if ( numSlots ) then
                for i = 1, numSlots do
                    local daysLeft = self:GetContainerInboxItemDaysLeft(ARMORY_MAIL_CONTAINER, i);
                    if ( daysLeft and floor(daysLeft) <= maxDays ) then
                        if ( daysLeft >= 1 ) then
                            daysLeft = format(DAYS_ABBR, floor(daysLeft));
                        else
                            daysLeft = SecondsToTime(floor(daysLeft * 24 * 60 * 60));
                        end
                        if ( daysLeft ~= "" ) then
                            local link = self:GetContainerItemLink(ARMORY_MAIL_CONTAINER, i);
                            local name = self:GetItemLinkInfo(link);
                            if ( not countOnly ) then
                                self:PrintTitle(RED_FONT_COLOR_CODE..format(ARMORY_CHECK_MAIL_MESSAGE, profile.character, profile.realm, name, daysLeft)..FONT_COLOR_CODE_CLOSE);
                            end
                            count = count + 1;
                        end
                    end
                end
            end
        end
        self:SelectProfile(currentProfile);
        if ( count == 0 and not countOnly ) then
            self:PrintTitle(ARMORY_CHECK_MAIL_NONE);
        end
    elseif ( not countOnly ) then
        self:PrintTitle(ARMORY_CHECK_MAIL_DISABLED);
    end

    return count;
end

function Armory:GetItemCount(link)
    local currentProfile = self:CurrentProfile();
    local list = {};

    if ( self:HasInventory() and Armory:GetConfigShowItemCount() ) then
        for _, profile in ipairs(self:Profiles()) do
            self:SelectProfile(profile);
            if ( profile.realm == currentProfile.realm ) then
                local count, bagCount, bankCount, mailCount = self:ScanInventory(link);
                local mine = profile.character == currentProfile.character;
                if ( count > 0 ) then
                    local details = {};
                    if ( bagCount > 0 ) then
                        table.insert(details, TUTORIAL_TITLE10.." "..bagCount);
                    end
                    if ( bankCount > 0 ) then
                        table.insert(details, ARMORY_BANK_CONTAINER_NAME.." "..bankCount);
                    end
                    if ( mailCount > 0 ) then
                        table.insert(details, MAIL_LABEL.." "..mailCount);
                    end
                    if ( #details > 0 ) then
                        details = "("..table.concat(details, ", ")..")";
                    else
                        details = "";
                    end
                    
                    local info = {name=profile.character, count=count, mine=mine, details=details};
                    SetTableColor(info, Armory:GetConfigItemCountColor());
                    table.insert(list, info);
                end
            end
        end
        self:SelectProfile(currentProfile);
    end

    return list;
end

function Armory:FindSpellTexture(name)
    local spellTab, spellId;

    for spellTab = 1, _G.GetNumSpellTabs() do
        local _, _, offset, numSpells = _G.GetSpellTabInfo(spellTab);
        for spellId = 1 + offset, numSpells + offset do
            spellName = _G.GetSpellName(spellId, BOOKTYPE_SPELL);
            if ( spellName == name ) then
                return _G.GetSpellTexture(spellId, spellTab);
            end
        end
    end
end

function Armory:IsToday(time)
    return ( date("%x", time) == date("%x") );
end

function Armory:MakeDate(day, month, year)
    if ( day and month and year ) then
        if ( year < 2000 ) then
            year = year + 2000;
        end
        return time({year=year, month=month, day=day});
    end
end

function Armory:Round(num, idp)
    local mult = 10^(idp or 0);
    return math.floor(num * mult + 0.5) / mult;
    --return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

function Armory:StringSplit(separator, value)
    local fields = {};
    gsub(value..separator, "([^"..separator.."]*)"..separator, function(v) table.insert(fields, v) end);
    return fields;
end

function Armory:CopyTable(src, dest)
    for k, v in pairs(src) do
        if ( type(v) == "table" ) then
            dest[k] = {};
            self:CopyTable(v, dest[k]);
        else
            dest[k] = v;
        end
    end
end

function Armory:String2Table(string)
    local words = {};
    local word, rest;

    string = strtrim(string);
    while ( string and string ~="" ) do
        if ( strfind(string, '^"[%w%s]-"') ) then
            _, _, word, rest = strfind(string, '^"([%w%s]-)"(.*)');
        else
            _, _, word, rest = strfind(string, '(%w+)(.*)');
        end
        table.insert(words, word);
        if ( rest ) then
            rest = strtrim(rest);
        end
        string = rest;
    end
    return words;
end

function Armory:ToString(...)
    local string = "";
    for i = 1, select("#", ...) do
        if ( type(select(i, ...)) == "table" ) then
            for _, v in ipairs(select(i, ...)) do
                string = string.." "..self:ToString(v);
            end
        else
            string = string.." "..tostring(select(i, ...));
        end
    end
    return string;
end

function Armory:Text2String(text, r, g, b)
    return strjoin("§", self:Round(r, 2), self:Round(g, 2), self:Round(b, 2), text);
end

function Armory:String2Text(s)
    return strsplit("§", s);
end

function Armory:Tooltip2Table(tooltip, all)
    local name = tooltip:GetName();
    local lines = {};
    local textLeft, textRight, icon, relativeTo, line;

    local getLine = function(fontString)
            if ( fontString ) then
                local text = fontString:GetText();
                if ( text and strtrim(text) ~= "" ) then
                    return self:Text2String(text, fontString:GetTextColor());
                end
            end
            return "";
        end

    for i = 1, tooltip:NumLines() do
        textLeft = getglobal(name.."TextLeft"..i);
        if ( textLeft and textLeft:IsShown() ) then
            lines[i] = getLine(textLeft);
        else
            lines[i] = "";
        end
        textRight = getglobal(name.."TextRight"..i);
        if ( textRight and textRight:IsShown() ) then
            lines[i] = lines[i].."\t"..getLine(textRight);
        end

        if ( not all and lines[i] == "" ) then
            table.remove(lines, i);
            break;
        end
    end

    for i = 1, 10 do
        icon = getglobal(name.."Texture"..i);
        if ( icon and icon:IsShown() ) then
            _, relativeTo = icon:GetPoint();
            line = tonumber(relativeTo:GetName():match("(%d+)$"));
            if ( line > 0 and line <= #lines ) then
                lines[line] = lines[line].."\v"..icon:GetTexture();
            end
        else
            break;
        end
    end
        
    return lines;
end

function Armory:Table2Tooltip(tooltip, t, firstWrap)
    local line, texture, left, right, textLeft, textRight;
    local colorLeft = {};
    local colorRight = {};

    tooltip:ClearLines();
    for i = 1, #t do
        line, texture = strsplit("\v", t[i]);
        if ( line ) then
            left, right = strsplit("\t", line);
            if ( left ) then
                colorLeft.r, colorLeft.g, colorLeft.b, textLeft = self:String2Text(left);
                if ( right ) then
                    colorRight.r, colorRight.g, colorRight.b, textRight = self:String2Text(right);
                    tooltip:AddDoubleLine(textLeft, textRight, colorLeft.r, colorLeft.g, colorLeft.b, colorRight.r, colorRight.g, colorRight.b);
                elseif ( (textLeft or "") == "" ) then
                    tooltip:AddLine(" ");
                else
                    tooltip:AddLine(textLeft, colorLeft.r, colorLeft.g, colorLeft.b, not texture and i >= (firstWrap or 3));
                end
            end
            if ( texture ) then
                tooltip:AddTexture(texture);
            end
        end
    end
end

function Armory:PrepareTooltip()
    local timestamp = time();
    if ( not self.tooltip ) then
        self.tooltip = CreateFrame("GameTooltip", "ArmoryTooltip", UIParent, "GameTooltipTemplate");
    end
    while ( self:IsLocked(self.tooltip:GetName()) and time() - timestamp < 10 ) do end
    self:Lock(self.tooltip:GetName());
    self.tooltip:SetOwner(UIParent, "ANCHOR_NONE");
    self.tooltip:ClearLines();
end

function Armory:ReleaseTooltip()
    self:Unlock(self.tooltip:GetName());
end

function Armory:GetItemLinkInfo(link)
    local itemColor, itemId, itemName;
    if ( link ) then
        itemColor, itemId, itemName = link:match("(|c%x+)|Hitem:([-%d:]+)|h%[(.-)%]|h|r");
    end
    return itemName, itemId, itemColor;
end

function Armory:GetInfoFromId(idType, id)
    local name, link, fontString, color;

    if ( not (idType and id) or strlen(id) == 0 ) then
        return;
    end

    self:PrepareTooltip();
    self.tooltip:SetHyperlink(idType..":"..id);
    name = self.tooltip:GetSpell();
    if ( name ) then
        link = _G.GetSpellLink(id);
    else
        name, link = self.tooltip:GetItem();
    end
    if ( not name ) then
        for i = 1, self.tooltip:NumLines() do
            fontString = getglobal(self.tooltip:GetName().."TextLeft"..i);
            if ( fontString and fontString:IsShown() ) then
                name = fontString:GetText();
                color = self:HexColor(fontString:GetTextColor());
                break;
            end
        end
    end
    self:ReleaseTooltip();
    
    if ( name and not link ) then
        if ( idType == "spell" ) then
            color = "|cff71d5ff";
        elseif ( idType == "quest" ) then
            color = "|cffffff00";
        elseif ( idType == "talent" ) then
            color = "|cff4e96f7";
        elseif ( idType == "glyph" ) then
            color = "|cff66bbff";
        elseif ( not color ) then
            color = "|cffffd000";
        end
        link = color.."|H"..idType..":"..id.."|h["..name.."]|h|r";
    end

    return name, link;
end

function Armory:GetNameFromLink(link)
    if ( link ) then
        return link:match("|h%[(.-)%]|h|r$");
    end
end

function Armory:GetColorFromLink(link)
    if ( link ) then
        return link:match("^(|c%x+)|H");
    end
end

function Armory:GetQualityFromLink(link)
    return self:GetQualityFromColor(self:GetColorFromLink(link));
end

function Armory:GetQualityFromColor(color)
    if ( color ) then
        for i = 0, 6 do
            local _, _, _, hex = GetItemQualityColor(i);
            if color == hex then
                return i
            end
        end
    end
    return -1
end

function Armory:CanEquip(link)
    local notEquippableText = function(name)
            local fontString = getglobal(self.tooltip:GetName().."Text"..name);
            if ( fontString ) then
                local r, g, b = fontString:GetTextColor();
                r = self:Round(r, 1);
                g = self:Round(g, 1);
                b = self:Round(b, 1);
                if ( r == RED_FONT_COLOR.r and g == RED_FONT_COLOR.g and b == RED_FONT_COLOR.b ) then
                    return fontString:GetText();
                end
            end
            return "";
        end

    if ( link ) then
        local _, _, _, _, _, _, _, _, equipLoc = GetItemInfo(link);
        if ( ARMORY_SLOTINFO[equipLoc] ) then
            self:PrepareTooltip();
            self.tooltip:SetHyperlink(link);
            local text;
            for i = 2, self.tooltip:NumLines() do
                text = notEquippableText("Left"..i);
                if ( text ~= "" and not text:match(DURABILITY_TEMPLATE) ) then
                    self:ReleaseTooltip();
                    return nil;
                end
                text = notEquippableText("Right"..i);
                if ( text ~= "" ) then
                    self:ReleaseTooltip();
                    return nil;
                end
            end
            self:ReleaseTooltip();
            return 1;
        end
    end
end

function Armory:Lock(semaphore)
    self.locked[semaphore] = 1;
end

function Armory:Unlock(semaphore)
    self.locked[semaphore] = nil;
end

function Armory:IsLocked(semaphore)
    return self.locked[semaphore];
end

function Armory:Proper(text)
    return text:gsub("^%l", string.upper);
end

function Armory:HexColor(r, g, b)
    if ( type(r) == "table" ) then
        if ( r.r ) then
            b = r.b;
            g = r.g;
            r = r.r;
        else
            b = r[3];
            g = r[2];
            r = r[1];
        end
    end
    return "|cff"..format("%02x%02x%02x", r*255, g*255, b*255);
end


----------------------------------------------------------
-- LDB 
----------------------------------------------------------

function Armory.LDB:OnClick(button)
    GameTooltip:Hide();
    if ( button == "LeftButton" ) then
        Armory:Toggle();
    elseif ( button == "RightButton" ) then
        ArmoryToggleDropDownMenu(1, nil, Armory.menu, self, 0, 0);
    end
end

function Armory.LDB:OnTooltipShow()
    if ( not ArmoryDropDownList1:IsVisible() ) then
        local realm, character = Armory:GetPaperDollLastViewed();
        self:AddLine(ARMORY_TITLE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
        self:AddDoubleLine(ARMORY_TOOLTIP1, character, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
        self:AddDoubleLine(ARMORY_TOOLTIP2, realm, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
        self:AddLine(ARMORY_TOOLTIP_HINT1.."\n"..ARMORY_TOOLTIP_HINT2, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
    end
end

function Armory.LDB:OnEnter()
    if ( not ArmoryDropDownList1:IsVisible() ) then
        GameTooltip:SetOwner(self, "ANCHOR_NONE");
        GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT");
        GameTooltip:ClearLines();
        Armory.LDB.OnTooltipShow(GameTooltip);
        GameTooltip:Show();
    end
end

function Armory.LDB:OnLeave()
    GameTooltip:Hide();
end

----------------------------------------------------------
-- Config
----------------------------------------------------------

function Armory:SetConfigExpirationDays(days)
    local option = self.options.ARMORY_CMD_SET_EXPDAYS;
    self:Setting("General", "ExpirationDays", max(min(days, option.maxValue), option.minValue));
end

function Armory:GetConfigExpirationDays()
    local option = self.options.ARMORY_CMD_SET_EXPDAYS;
    return self:Setting("General", "ExpirationDays") or option.default;
end

function Armory:SetInventoryListViewMode(checked)
    self:Setting("Inventory", "ListView", checked);
end

function Armory:GetInventoryListViewMode()
    return self:Setting("Inventory", "ListView") or nil;
end

function Armory:SetConfigSaveSearchAll(on)
    self:Setting("General", "SearchAll", on);
    if ( on ) then
        self:SetInventorySearchAll(self.inventorySearchAll);
    end
end

function Armory:GetConfigSaveSearchAll()
    return self:Setting("General", "SearchAll") or nil;
end

function Armory:SetInventorySearchAll(checked)
    if ( self:GetConfigSaveSearchAll() ) then
        self:Setting("Inventory", "SearchAll", checked);
    end
end

function Armory:GetInventorySearchAll()
    if ( self:GetConfigSaveSearchAll() ) then
        return self:Setting("Inventory", "SearchAll") or self.inventorySearchAll;
    else
        return self.inventorySearchAll;
    end
end

function Armory:SetInventoryBagLayout(checked)
    self:Setting("Inventory", "BagLayout", checked);
end

function Armory:GetInventoryBagLayout()
    return self:Setting("Inventory", "BagLayout") or nil;
end

function Armory:SetShowAllSpellRanks(checked)
    self:Setting("SpellBook", "ShowAllSpellRanks", checked);
end

function Armory:GetShowAllSpellRanks()
    return self:Setting("SpellBook", "ShowAllSpellRanks") or nil;
end

function Armory:SetConfigLastViewed(on)
    self:Setting("General", "LastViewed", on);
    if ( on ) then
        self:SetPaperDollLastViewed(self.characterRealm, self.character);
    else
        self.characterRealm, self.character = self:GetPaperDollLastViewed();
    end
end

function Armory:GetConfigLastViewed()
    return self:Setting("General", "LastViewed") or nil;
end

function Armory:SetPaperDollLastViewed(realm, character)
    if ( self:GetConfigLastViewed() ) then
        self:Setting("PaperDoll", "LastViewed", realm, character);
    end
    self.characterRealm = realm;
    self.character = character;
end

function Armory:GetPaperDollLastViewed()
    local realm, character;
    if ( self:GetConfigLastViewed() ) then
        realm, character = self:Setting("PaperDoll", "LastViewed");
    else
        realm = self.characterRealm;
        character = self.character;
    end
    return (realm or self.playerRealm), (character or self.player);
end

function Armory:SetConfigShowAltEquipment(on)
    self:Setting("General", "HideAltEquipment", not on);
end

function Armory:GetConfigShowAltEquipment()
    return not self:Setting("General", "HideAltEquipment");
end

function Armory:SetConfigShowUnequippable(on)
    self:Setting("General", "HideUnequippable", not on);
end

function Armory:GetConfigShowUnequippable()
    return not self:Setting("General", "HideUnequippable");
end

function Armory:SetConfigShowEqcTooltips(on)
    self:Setting("General", "HideEqcTooltips", not on);
end

function Armory:GetConfigShowEqcTooltips()
    return not self:Setting("General", "HideEqcTooltips");
end

function Armory:SetConfigShowItemCount(on)
    self:Setting("General", "HideItemCount", not on);
end

function Armory:GetConfigShowItemCount()
    return not self:Setting("General", "HideItemCount");
end

function Armory:SetConfigShowQuestAlts(on)
    self:Setting("General", "HideQuestAlts", not on);
end

function Armory:GetConfigShowQuestAlts()
    return not self:Setting("General", "HideQuestAlts");
end

function Armory:SetConfigPerCharacter(on)
    self:Setting("General", "PerCharacter", on);
end

function Armory:GetConfigPerCharacter()
    return self:Setting("General", "PerCharacter") or nil;
end

function Armory:SetConfigShowMinimap(on)
    self:Setting("General", "HideMinimap", not on);
end

function Armory:GetConfigShowMinimap()
    return not self:Setting("General", "HideMinimap");
end

function Armory:SetConfigHideMinimapIfToolbar(on)
    self:Setting("General", "ShowMinimapToolbar", not on);
end

function Armory:GetConfigHideMinimapIfToolbar()
    return not self:Setting("General", "ShowMinimapToolbar");
end

function Armory:SetConfigMinimapAngle(angle)
    local option = self.options.ARMORY_CMD_SET_MMB_ANGLE;
    self:LocalSetting("Minimap", "Angle", max(min(angle, option.maxValue), option.minValue));
end

function Armory:GetConfigMinimapAngle()
    local option = self.options.ARMORY_CMD_SET_MMB_ANGLE;
    return self:LocalSetting("Minimap", "Angle") or option.default;
end

function Armory:SetConfigMinimapRadius(radius)
    local option = self.options.ARMORY_CMD_SET_MMB_RADIUS;
    self:LocalSetting("Minimap", "Radius",  max(min(radius, option.maxValue), option.minValue));
end

function Armory:GetConfigMinimapRadius()
    local option = self.options.ARMORY_CMD_SET_MMB_RADIUS;
    return self:LocalSetting("Minimap", "Radius") or option.default;
end

function Armory:SetConfigFilterAllMessages(on)
    self:Setting("General", "PartialFilter", not on);
end

function Armory:GetConfigFilterAllMessages()
    return not self:Setting("General", "PartialFilter");
end

function Armory:SetConfigShowShareMessages(on)
    self:Setting("General", "SharingMessages", on);
end

function Armory:GetConfigShowShareMessages()
    return self:Setting("General", "SharingMessages");
end

function Armory:SetConfigShareProfessions(on)
    self:CharacterSetting("ShareSkills", "player", on);
end

function Armory:GetConfigShareProfessions(unit)
    local share = self:CharacterSetting("ShareSkills", unit);
    if ( share == nil ) then
        share = true;
    end
    return share;
end

function Armory:SetConfigShareQuests(on)
    self:CharacterSetting("ShareQuests", "player", on);
end

function Armory:GetConfigShareQuests(unit)
    local share = self:CharacterSetting("ShareQuests", unit);
    if ( share == nil ) then
        share = true;
    end
    return share;
end

function Armory:SetConfigShareCharacter(on)
    self:CharacterSetting("ShareCharacter", "player", on);
end

function Armory:GetConfigShareCharacter(unit)
    local share = self:CharacterSetting("ShareCharacter", unit);
    if ( share == nil ) then
        share = true;
    end
    return share;
end

function Armory:SetConfigShareAsAlt(on)
    self:CharacterSetting("ShareAsAlt", "player", on);
end

function Armory:GetConfigShareAsAlt(unit)
    local share = self:CharacterSetting("ShareAsAlt", unit);
    if ( share == nil ) then
        share = true;
    end
    return share;
end

function Armory:SetConfigShareInInstance(on)
    self:Setting("General", "DontShareInInstance", not on);
end

function Armory:GetConfigShareInInstance()
    return not self:Setting("General", "DontShareInInstance");
end

function Armory:SetConfigShareInCombat(on)
    self:Setting("General", "DontShareInCombat", not on);
end

function Armory:GetConfigShareInCombat()
    return not self:Setting("General", "DontShareInCombat");
end

function Armory:SetConfigShareAll(on)
    self:Setting("General", "ShareAll", on);
end

function Armory:GetConfigShareAll()
    return self:Setting("General", "ShareAll");
end

function Armory:SetConfigShareGuild(on)
    self:Setting("General", "ShareNonGuild", not on);
end

function Armory:GetConfigShareGuild()
    return not self:Setting("General", "ShareNonGuild");
end

function Armory:SetConfigItemCountColor(r, g, b)
    self:Setting("General", "ItemCountColor", r, g, b);
end

function Armory:GetConfigItemCountColor(default)
    local r, g, b = self:Setting("General", "ItemCountColor");
    if ( default or not r ) then
        r, g, b = GetTableColor(GRAY_FONT_COLOR);
    end
    return r, g, b;
end

function Armory:SetConfigQuestAltsColor(r, g, b)
    self:Setting("General", "QuestAltsColor", r, g, b);
end

function Armory:GetConfigQuestAltsColor(default)
    local r, g, b = self:Setting("General", "QuestAltsColor");
    if ( default or not r ) then
        r, g, b = GetTableColor(GREEN_FONT_COLOR);
    end
    return r, g, b;
end

function Armory:SetConfigGlobalSearch(on)
    self:Setting("General", "SearchRealmOnly", not on);
end

function Armory:GetConfigGlobalSearch()
    return not self:Setting("General", "SearchRealmOnly");
end

function Armory:SetConfigUpdateCriteria(on)
    self:Setting("General", "UpdateCriteria", on);
end

function Armory:GetConfigUpdateCriteria()
    --return self:Setting("General", "UpdateCriteria");
    return true;
end

----------------------------------------------------------
-- Modules
----------------------------------------------------------

function Armory:HasInventory(value)
    if ( value ~= nil ) then
        self:SetModule("Inventory", value);
    end
    return self:GetModule("Inventory");
end

function Armory:HasQuestLog(value)
    if ( value ~= nil ) then
        self:SetModule("QuestLog", value);
    end
    return self:GetModule("QuestLog");
end

function Armory:HasSpellBook(value)
    if ( value ~= nil ) then
        self:SetModule("SpellBook", value);
    end
    return self:GetModule("SpellBook");
end

function Armory:HasTradeSkills(value)
    if ( value ~= nil ) then
        self:SetModule("Professions", value);
    end
    return self:GetModule("Professions");
end

function Armory:HasAchievements(value)
    if ( value ~= nil ) then
        self:SetModule("Achievements", value);
    end
    return self:GetModule("Achievements");
end

function Armory:HasDataSharing(value)
    if ( value ~= nil ) then
        self:SetModule("DataSharing", value);
    end
    return self:GetModule("DataSharing");
end

function Armory:SetModule(module, enable)
    local dbEntry = self.modulesDbEntry;

    if ( dbEntry ) then
        dbEntry:SetValue("Disable"..module, not enable);
    end
end

function Armory:GetModule(module)
    local dbEntry = self.modulesDbEntry;
    local value;

    if ( dbEntry ) then
        value = dbEntry:GetValue("Disable"..module);
    end

    return not value;
end

----------------------------------------------------------
-- General Internals
----------------------------------------------------------

function Armory:SetGetCharacterValue(key, ...)
    self:SetCharacterValue(key, ...);
    return self:GetCharacterValue(key);
end

function Armory:SetCharacterValue(key, ...)
    self.playerDbBaseEntry:SetValue(key, ...);
end

function Armory:GetCharacterValue(key, unit)
    if ( unit == "player" ) then
        return self.playerDbBaseEntry:GetValue(key);
    end
    return self.selectedDbBaseEntry:GetValue(key);
end

function Armory:SetGetPetValue(key, ...)
    --self:PrintDebug("SetGetPetValue", _G.HasPetUI(), _G.UnitName("pet"), self:GetCurrentPet(), "=>", key, ... );
    if ( _G.HasPetUI() and self:IsPersistentPet() ) then
        self:SetPetValue(_G.UnitName("pet"), key, ...);
    end
    if ( self:PetExists(self:GetCurrentPet()) ) then
        return self:GetPetValue(self:GetCurrentPet(), key);
    end
    return ...;
end

function Armory:SelectPet(baseEntry, index)
    local dbEntry = ArmoryDbEntry:new(baseEntry);
    dbEntry:SetPosition("Pets", index);
    return dbEntry;
end

function Armory:SetPetValue(index, key, ...)
    if ( index ~= UNKNOWN and not self:IsLocked("Pets") ) then
        self:SelectPet(self.playerDbBaseEntry, index):SetValue(key, ...);
    end
end

function Armory:GetPetValue(index, key)
    local dbEntry = self.selectedDbBaseEntry;

    if ( dbEntry:Contains("Pets", index, key) ) then
        return self:SelectPet(dbEntry, index):GetValue(key);
    end
end

function Armory:DeletePet(pet, unit)
    local dbEntry = self.selectedDbBaseEntry;

    if ( unit == "player" ) then
        dbEntry = self.playerDbBaseEntry;
    end

      if ( pet and dbEntry:Contains("Pets", pet) ) then
        dbEntry:SetSubValue("Pets", pet, nil);
    end
end

----------------------------------------------------------
-- General Hooks
----------------------------------------------------------

local Orig_PetAbandon = _G.PetAbandon;
function PetAbandon(...)
    local pet = UnitName("pet");
    Armory:Lock("Pets");
    Armory:DeletePet(pet, "player");
    Orig_PetAbandon(...);
    Armory:Unlock("Pets");
    Armory:PrintDebug("PetAbandon", pet);
end

local Orig_PetRename = _G.PetRename;
function PetRename(name, ...)
    local dbEntry = Armory.playerDbBaseEntry;
    local pet = UnitName("pet");
    Armory:Lock("Pets");
    if ( pet and dbEntry:Contains("Pets", pet) ) then
        local values = {};
        Armory:CopyTable(dbEntry:GetSubValue("Pets", pet), values);
        dbEntry:SetSubValue("Pets", name, values);
        dbEntry:SetSubValue("Pets", pet, nil);
    end
    Orig_PetRename(name, ...);
    Armory:Unlock("Pets");
    Armory:PrintDebug("PetRename", pet, name);
end

----------------------------------------------------------
-- General Interface
----------------------------------------------------------

function Armory:GetAdjustedSkillPoints()
    return self:SetGetCharacterValue("AdjustedSkillPoints", _G.GetAdjustedSkillPoints());
end

function Armory:GetArenaCurrency()
    return self:SetGetCharacterValue("ArenaCurrency", _G.GetArenaCurrency());
end

function Armory:GetArmorPenetration()
    return self:SetGetCharacterValue("ArmorPenetration", _G.GetArmorPenetration());
end

function Armory:GetBlockChance()
    return self:SetGetCharacterValue("BlockChance", _G.GetBlockChance());
end

 function Armory:GetCombatRating(index)
    if ( index ) then
        return self:SetGetCharacterValue("CombatRating"..index, _G.GetCombatRating(index)) or 0;
    end
end

function Armory:GetCombatRatingBonus(index)
    if ( index ) then
        return self:SetGetCharacterValue("CombatRatingBonus"..index, _G.GetCombatRatingBonus(index)) or 0;
    end
end

function Armory:GetCritChance()
    return self:SetGetCharacterValue("CritChance", _G.GetCritChance());
end

function Armory:GetCritChanceFromAgility(unit)
    if ( strlower(unit) == "pet" ) then
        return self:SetGetPetValue("CritChanceFromAgility", _G.GetCritChanceFromAgility(unit));
    end
    return self:SetGetCharacterValue("CritChanceFromAgility", _G.GetCritChanceFromAgility(unit));
end

function Armory:GetCurrentPet()
    local pets = self:GetPets();
    local pet = self:UnitName("pet") or UNKNOWN;
    if ( not self.selectedPet ) then
        self.selectedPet = pet;
    end
    if ( not self:PetExists(self.selectedPet) ) then
        if ( #pets > 0 ) then
            self.selectedPet = pets[1];
        else
            self.selectedPet = pet;
        end
    end
    return self.selectedPet;
end

function Armory:GetDodgeChance()
    return self:SetGetCharacterValue("DodgeChance", _G.GetDodgeChance());
end

function Armory:GetExpertise()
    return self:SetGetCharacterValue("Expertise", _G.GetExpertise());
end

function Armory:GetExpertisePercent()
    return self:SetGetCharacterValue("ExpertisePercent", _G.GetExpertisePercent());
end

function Armory:GetGuildInfo(unit)
    return self:SetGetCharacterValue("Guild", _G.GetGuildInfo("player"));
end

function Armory:GetHonorCurrency()
    return self:SetGetCharacterValue("HonorCurrency", _G.GetHonorCurrency());
end

function Armory:GetInventoryAlertStatus(index)
    if ( index ) then
        return self:SetGetCharacterValue("InventoryAlertStatus"..index, _G.GetInventoryAlertStatus(index));
    end
end

function Armory:GetInventoryItemBroken(unit, index)
    if ( index ) then
        return self:SetGetCharacterValue("InventoryItemBroken"..index, _G.GetInventoryItemBroken("player", index));
    end
end

function Armory:GetInventoryItemCount(unit, index)
    if ( index ) then
        return self:SetGetCharacterValue("InventoryItemCount"..index, _G.GetInventoryItemCount("player", index));
    end
end

function Armory:GetInventoryItemLink(unit, index)
    if ( index ) then
        return self:SetGetCharacterValue("InventoryItemLink"..index, _G.GetInventoryItemLink("player", index));
    end
end

function Armory:GetInventoryItemTexture(unit, index)
    if ( index ) then
        return self:SetGetCharacterValue("InventoryItemTexture"..index, _G.GetInventoryItemTexture("player", index));
    end
end

function Armory:GetInventoryItemQuality(unit, index)
    if ( index ) then
        return self:SetGetCharacterValue("InventoryItemQuality"..index, _G.GetInventoryItemQuality("player", index));
    end
end

function Armory:GetManaRegen()
    return self:SetGetCharacterValue("ManaRegen", _G.GetManaRegen());
end

function Armory:GetMaxCombatRatingBonus(index)
    if ( index ) then
        return self:SetGetCharacterValue("MaxCombatRatingBonus"..index, _G.GetMaxCombatRatingBonus(index)) or 0;
    end
end

function Armory:GetMoney()
    return self:SetGetCharacterValue("Money", _G.GetMoney()) or 0;
end

function Armory:GetParryChance()
    return self:SetGetCharacterValue("ParryChance", _G.GetParryChance());
end

function Armory:GetPetExperience()
    return self:SetGetPetValue("Experience", _G.GetPetExperience());
end

function Armory:GetPetFoodTypes()
    return self:SetGetPetValue("FoodTypes", _G.GetPetFoodTypes());
end

function Armory:GetPetHappiness()
    return self:SetGetPetValue("Happiness", _G.GetPetHappiness());
end

function Armory:GetPetIcon()
    local _, isHunterPet = self:HasPetUI();
    if ( isHunterPet ) then
        return self:SetGetPetValue("Icon", _G.GetPetIcon());
    end
    if ( self:UnitCreatureFamily("pet") ) then
        return "Interface\\Icons\\Spell_Shadow_Summon"..self:UnitCreatureFamily("pet");
    end
end

function Armory:GetPets(unit)
    local dbEntry = self.selectedDbBaseEntry;
    local list = {};
    local cleanup = {};

    if ( unit == "player" ) then
        dbEntry = self.playerDbBaseEntry;
    end

    if ( dbEntry:Contains("Pets") ) then
        for pet, values in pairs(dbEntry:GetValue("Pets")) do
            -- sanity check
            if ( pet == UNKNOWN or not values.Family ) then
                table.insert(cleanup, pet);
            else
                table.insert(list, pet);
            end
        end
        table.sort(list);

        -- should never happen, but better save than sorry
        for _, pet in ipairs(cleanup) do
            self:DeletePet(pet, unit);
            self:PrintDebug("Pet", pet, "removed");
        end
    end

    return list;
end

function Armory:GetPetTalentPoints()
    return self:SetGetPetValue("TalentPoints", _G.GetPetTalentPoints());
end

function Armory:GetPortraitTexture(unit)
    local portrait = "Interface\\CharacterFrame\\TemporaryPortrait";

    if ( strlower(unit) == "pet" ) then
        portrait = portrait .. "-Pet";
    else
        local sex = self:UnitSex(unit);
        local _, raceEn = self:UnitRace(unit);
        if ( sex == 2 ) then
            portrait = portrait .. "-Male-" .. raceEn;
        elseif ( sex == 3 ) then
            portrait = portrait .. "-Female-" .. raceEn;
        end
    end

    return portrait;
end

function Armory:GetRangedCritChance()
    return self:SetGetCharacterValue("RangedCritChance", _G.GetRangedCritChance());
end

function Armory:GetRestState()
    return self:SetGetCharacterValue("RestState", _G.GetRestState());
end

function Armory:GetShieldBlock()
    return self:SetGetCharacterValue("ShieldBlock", _G.GetShieldBlock());
end

function Armory:GetSpellBonusDamage(holySchool)
    if ( holySchool ) then
        return self:SetGetCharacterValue("SpellBonusDamage"..holySchool, _G.GetSpellBonusDamage(holySchool));
    end
end

function Armory:GetSpellBonusHealing()
    return self:SetGetCharacterValue("SpellBonusHealing", _G.GetSpellBonusHealing());
end

function Armory:GetSpellCritChance(holySchool)
    if ( holySchool ) then
        return self:SetGetCharacterValue("SpellCritChance"..holySchool, _G.GetSpellCritChance(holySchool));
    end
end

function Armory:GetSpellCritChanceFromIntellect(unit)
    if ( strlower(unit) == "pet" ) then
        return self:SetGetPetValue("SpellCritChanceFromIntellect", _G.GetSpellCritChanceFromIntellect(unit));
    end
    return self:SetGetCharacterValue("SpellCritChanceFromIntellect", _G.GetSpellCritChanceFromIntellect(unit));
end

function Armory:GetSpellPenetration()
    return self:SetGetCharacterValue("SpellPenetration", _G.GetSpellPenetration());
end

function Armory:GetTotalAchievementPoints()
    return self:SetGetCharacterValue("TotalAchievementPoints", _G.GetTotalAchievementPoints()) or 0;
end

function Armory:GetUnitHealthModifier(unit)
    if ( strlower(unit) == "pet" ) then
        return self:SetGetPetValue("HealthModifier", _G.GetUnitHealthModifier(unit));
    end
    return self:SetGetCharacterValue("HealthModifier", _G.GetUnitHealthModifier(unit));
end

function Armory:GetUnitHealthRegenRateFromSpirit(unit)
    if ( strlower(unit) == "pet" ) then
        return self:SetGetPetValue("HealthRegenRateFromSpirit", _G.GetUnitHealthRegenRateFromSpirit(unit));
    end
    return self:SetGetCharacterValue("HealthRegenRateFromSpirit", _G.GetUnitHealthRegenRateFromSpirit(unit));
end

function Armory:GetUnitManaRegenRateFromSpirit(unit)
    if ( strlower(unit) == "pet" ) then
        return self:SetGetPetValue("ManaRegenRateFromSpirit", _G.GetUnitManaRegenRateFromSpirit(unit));
    end
    return self:SetGetCharacterValue("ManaRegenRateFromSpirit", _G.GetUnitManaRegenRateFromSpirit(unit));
end

function Armory:GetUnitMaxHealthModifier(unit)
    if ( strlower(unit) == "pet" ) then
        return self:SetGetPetValue("MaxHealthModifier", _G.GetUnitMaxHealthModifier(unit));
    end
    return self:SetGetCharacterValue("MaxHealthModifier", _G.GetUnitMaxHealthModifier(unit));
end

function Armory:GetUnitPowerModifier(unit)
    if ( strlower(unit) == "pet" ) then
        return self:SetGetPetValue("PowerModifier", _G.GetUnitPowerModifier(unit));
    end
    return self:SetGetCharacterValue("PowerModifier", _G.GetUnitPowerModifier(unit));
end

function Armory:GetPVPLifetimeStats()
    return self:SetGetCharacterValue("PVPLifetimeStats", _G.GetPVPLifetimeStats());
end

function Armory:GetPVPSessionStats()
    local time, hk, cp = self:SetGetCharacterValue("PVPSessionStats", time(), _G.GetPVPSessionStats());

    if ( not Armory:IsToday(time) ) then
        hk = 0;
        cp = 0;
    end

    return hk, cp;
end

function Armory:GetPVPYesterdayStats()
    local time, hk, cp = self:SetGetCharacterValue("PVPYesterdayStats", time(), _G.GetPVPYesterdayStats());

    if ( not Armory:IsToday(time) ) then
        hk = 0;
        cp = 0;
    end

    return hk, cp;
end

function Armory:GetSubZoneText()
    return self:SetGetCharacterValue("SubZone", _G.GetSubZoneText());
end

function Armory:GetXPExhaustion()
    return self:SetGetCharacterValue("XPExhaustion", _G.GetXPExhaustion(), time());
end

function Armory:GetZoneText()
    return self:SetGetCharacterValue("Zone", _G.GetZoneText());
end

function Armory:HasPetSpells()
    return self:SetGetPetValue("HasSpells", _G.HasPetSpells());
end

function Armory:HasPetUI()
    local pets = self:GetPets();
    if ( #pets == 0 and self.character == self.player ) then
        return _G.HasPetUI();
    end
    local _, unitClass = self:UnitClass("player");
    return #pets > 0, strupper(unitClass) == "HUNTER";
end

function Armory:HasWandEquipped()
    return self:SetGetCharacterValue("HasWandEquipped", _G.HasWandEquipped());
end

function Armory:IsPersistentPet()
    return (_G.UnitName("pet") or UNKNOWN) ~= UNKNOWN and _G.UnitCreatureFamily("pet");
end

function Armory:InRepairMode()
   return self:SetGetCharacterValue("InRepairMode", _G.InRepairMode());
end

function Armory:IsResting()
   return self:SetGetCharacterValue("IsResting", _G.IsResting());
end

function Armory:PetExists(pet, unit)
    local dbEntry = self.selectedDbBaseEntry;

    if ( unit == "player" ) then
        dbEntry = self.playerDbBaseEntry;
    end

    return dbEntry:Contains("Pets", pet);
end

----------------------------------------------------------

function Armory:SetBagItem(id, index)
    local link = self:GetContainerItemLink(id, index);
    if ( link ) then
        GameTooltip:SetHyperlink(link);

        if ( id == ARMORY_MAIL_CONTAINER ) then
            local daysLeft = Armory:GetContainerInboxItemDaysLeft(id, index);
            if ( daysLeft ) then
                if ( daysLeft >= 1 ) then
                    daysLeft = LIGHTYELLOW_FONT_COLOR_CODE.."  "..format(DAYS_ABBR, floor(daysLeft)).." "..FONT_COLOR_CODE_CLOSE;
                else
                    daysLeft = RED_FONT_COLOR_CODE.."  "..SecondsToTime(floor(daysLeft * 24 * 60 * 60))..FONT_COLOR_CODE_CLOSE;
                end
                GameTooltip:AppendText(daysLeft);
                GameTooltip:Show();
            end

        elseif ( id == ARMORY_AUCTIONS_CONTAINER ) then
            local timeLeft, timestamp = self:GetInventoryContainerValue(id, "TimeLeft"..index);
            if ( timeLeft ) then
                local timeLeftScanned = SecondsToTime(time() - timestamp, true);
                if ( timeLeftScanned ~= "" ) then
                    timeLeftScanned = " "..string.format(GUILD_BANK_LOG_TIME, timeLeftScanned);
                end

                local tooltipLines = self:Tooltip2Table(GameTooltip);
                table.insert(tooltipLines, 2, self:Text2String(getglobal("AUCTION_TIME_LEFT"..timeLeft)..timeLeftScanned, 1.0, 1.0, 0.6));
                self:Table2Tooltip(GameTooltip, tooltipLines, 4);
                GameTooltip:Show();
            end
        end
    end
end

function Armory:SetInventoryItem(unit, index, dontShow, tooltip, link)
    if ( index ) then
        local hasItem, hasCooldown, repairCost;
        if ( link ) then
            hasItem = true;
        else
            hasItem, hasCooldown, repairCost = self:SetInventoryItemInfo(unit, index);
        end
        if ( hasItem and not dontShow ) then
            link = link or self:GetInventoryItemLink("player", index);
            if ( link ) then
                if ( not tooltip ) then
                    GameTooltip:SetHyperlink(link);
                else
                    tooltip:SetHyperlink(link);
                    if ( PawnUpdateTooltip ) then
                         PawnUpdateTooltip(tooltip:GetName(), "SetHyperlink", link);
                         if ( PawnAttachIconToTooltip ) then
                            PawnAttachIconToTooltip(tooltip, true, link);
                         end
                    end

                    local tooltipLines = self:Tooltip2Table(tooltip, true);
                    local realm, character = self:GetPaperDollLastViewed();
                    table.insert(tooltipLines, 1, self:Text2String(character.." "..realm, 0.5, 0.5, 0.5));
                    self:Table2Tooltip(tooltip, tooltipLines, 4);
                    tooltip:Show();
                end
            end
        end
        return hasItem, hasCooldown, repairCost;
    end
end

function Armory:SetInventoryItemInfo(unit, index)
    if ( index ) then
        local hasItem, hasCooldown, repairCost;
        self:PrepareTooltip();
        hasItem, hasCooldown, repairCost = self.tooltip:SetInventoryItem("player", index);
        self:ReleaseTooltip();
        return self:SetGetCharacterValue("InventoryItem"..index, hasItem, hasCooldown, repairCost);
    end
end

function Armory:SetItemLink(button, link)
    -- to enable hooks
    button.link = link;
end

function Armory:SetPortraitTexture(frame, unit)
    frame:SetTexture(self:GetPortraitTexture(unit));
    return "Portrait1";
end

function Armory:SetGlyph(id)
    local link = self:GetGlyphLink(id);
    if ( link ) then
        GameTooltip:SetHyperlink(link);
    end
end

function Armory:SetQuestLogItem(itemType, id)
    local link = self:GetQuestLogItemLink(itemType, id);
    if ( link ) then
        GameTooltip:SetHyperlink(link);
    end
end
function Armory:SetQuestLogRewardSpell()
    local link = self:GetQuestLogSpellLink();
    if ( link ) then
        GameTooltip:SetHyperlink(link);
    end
end

function Armory:SetSpell(id, bookType)
    local link = self:GetSpellLink(id, bookType);
    if ( link ) then
        GameTooltip:SetHyperlink(link);
    end
end

function Armory:SetTalent(index, id, inspect, pet)
    local link = self:GetTalentLink(index, id, inspect, pet);
    if ( link ) then
        GameTooltip:SetHyperlink(link);
    end
end

function Armory:SetTradeSkillItem(index, reagent)
    if ( index ) then
        local link;
        if ( reagent ) then
            link = self:GetTradeSkillReagentItemLink(index, reagent);
        else
            link = self:GetTradeSkillItemLink(index);
        end
        if ( link ) then
            GameTooltip:SetHyperlink(link);
        end
    end
end

----------------------------------------------------------

function Armory:UnitArmor(unit)
    if ( strlower(unit) == "pet" ) then
        return self:SetGetPetValue("Armor", _G.UnitArmor(unit));
    end
    return self:SetGetCharacterValue("Armor", _G.UnitArmor(unit));
end

function Armory:UnitAttackBothHands(unit)
    return self:SetGetCharacterValue("AttackBothHands", _G.UnitAttackBothHands("player"));
end

function Armory:UnitAttackPower(unit)
    if ( strlower(unit) == "pet" ) then
        return self:SetGetPetValue("AttackPower", _G.UnitAttackPower(unit));
    end
    return self:SetGetCharacterValue("AttackPower", _G.UnitAttackPower(unit));
end

function Armory:UnitAttackSpeed(unit)
    if ( strlower(unit) == "pet" ) then
        return self:SetGetPetValue("AttackSpeed", _G.UnitAttackSpeed(unit));
    end
    return self:SetGetCharacterValue("AttackSpeed", _G.UnitAttackSpeed(unit));
end

function Armory:UnitCharacterPoints(unit)
    return self:SetGetCharacterValue("CharacterPoints", _G.UnitCharacterPoints("player"));
end

function Armory:UnitClass(unit)
    return self:SetGetCharacterValue("Class", _G.UnitClass("player"));
end

function Armory:UnitCreatureFamily(unit)
    return self:SetGetPetValue("Family", _G.UnitCreatureFamily("pet"));
end

function Armory:UnitDamage(unit)
    if ( strlower(unit) == "pet" ) then
        return self:SetGetPetValue("Damage", _G.UnitDamage(unit));
    end
    return self:SetGetCharacterValue("Damage", _G.UnitDamage(unit));
end

function Armory:UnitDefense(unit)
   return self:SetGetCharacterValue("Defense", _G.UnitDefense("player"));
end

function Armory:UnitFactionGroup(unit)
    return self:SetGetCharacterValue("FactionGroup", _G.UnitFactionGroup("player"));
end

function Armory:UnitHasMana(unit)
    if ( strlower(unit) == "pet" ) then
        return self:SetGetPetValue("HasMana", _G.UnitHasMana(unit));
    end
    return self:SetGetCharacterValue("HasMana", _G.UnitHasMana(unit));
end

function Armory:UnitHasRelicSlot(unit)
    return self:SetGetCharacterValue("HasRelicSlot", _G.UnitHasRelicSlot("player"));
end

function Armory:UnitHasResSickness(unit)
    local hasResSickness = false;
    local texture;
    local index = 1;

    unit = "player";

    if ( _G.UnitDebuff(unit, index) ) then
        while ( _G.UnitDebuff(unit, index) ) do
            texture = _G.UnitDebuff(unit, index);
            if ( texture == "Interface\\Icons\\Spell_Shadow_DeathScream" ) then
                hasResSickness = true;
                break;
            end
            index = index + 1;
        end
    end

    return self:SetGetCharacterValue("HasResSickness", hasResSickness);
end

function Armory:UnitHealth(unit)
    if ( strlower(unit) == "pet" ) then
        return self:SetGetPetValue("Health", _G.UnitHealth(unit));
    end
    return self:SetGetCharacterValue("Health", _G.UnitHealth(unit));
end

function Armory:UnitHealthMax(unit)
    if ( strlower(unit) == "pet" ) then
        return self:SetGetPetValue("HealthMax", _G.UnitHealthMax(unit));
    end
    return self:SetGetCharacterValue("HealthMax", _G.UnitHealthMax(unit));
end

function Armory:UnitIsDeadOrGhost(unit)
    if ( strlower(unit) == "pet" ) then
        return self:SetGetPetValue("IsDead", _G.UnitIsDeadOrGhost(unit));
    end
    return self:SetGetCharacterValue("IsDead", _G.UnitIsDeadOrGhost(unit));
end

function Armory:UnitLevel(unit)
    if ( strlower(unit) == "pet" ) then
        return self:SetGetPetValue("Level", _G.UnitLevel(unit));
    end
    return self:SetGetCharacterValue("Level", _G.UnitLevel(unit));
end

function Armory:UnitMana(unit)
    if ( strlower(unit) == "pet" ) then
        return self:SetGetPetValue("Mana", _G.UnitMana(unit));
    end
    return self:SetGetCharacterValue("Mana", _G.UnitMana(unit));
end

function Armory:UnitManaMax(unit)
    if ( strlower(unit) == "pet" ) then
        return self:SetGetPetValue("ManaMax", _G.UnitManaMax(unit));
    end
    return self:SetGetCharacterValue("ManaMax", _G.UnitManaMax(unit));
end

function Armory:UnitName(unit)
    if ( strlower(unit) == "pet" ) then
        return self:SetGetCharacterValue("Pet", _G.UnitName(unit));
    end
    return self:SetGetCharacterValue("Name", _G.UnitName(unit));
end

function Armory:UnitPowerType(unit)
    return self:SetGetCharacterValue("PowerType", _G.UnitPowerType("player"));
end

function Armory:UnitPVPName(unit)
    return self:SetGetCharacterValue("PVPName", _G.UnitPVPName("player"));
end

function Armory:UnitRace(unit)
    return self:SetGetCharacterValue("Race", _G.UnitRace("player"));
end

function Armory:UnitRangedAttack(unit)
    return self:SetGetCharacterValue("RangedAttack", _G.UnitRangedAttack("player"));
end

function Armory:UnitRangedAttackPower(unit)
    return self:SetGetCharacterValue("RangedAttackPower", _G.UnitRangedAttackPower("player"));
end

function Armory:UnitRangedDamage(unit)
    return self:SetGetCharacterValue("RangedDamage", _G.UnitRangedDamage("player"));
end

function Armory:UnitResistance(unit, index)
    if ( index ) then
        if ( strlower(unit) == "pet" ) then
            return self:SetGetPetValue("Resistance"..index,  _G.UnitResistance(unit, index));
        end
        return self:SetGetCharacterValue("Resistance"..index,  _G.UnitResistance(unit, index));
    end
end

function Armory:UnitSex(unit)
    return self:SetGetCharacterValue("Sex", _G.UnitSex("player"));
end

function Armory:UnitStat(unit, index)
    if ( index ) then
        if ( strlower(unit) == "pet" ) then
            return self:SetGetPetValue("Stat"..index,  _G.UnitStat(unit, index));
        end
        return self:SetGetCharacterValue("Stat"..index,  _G.UnitStat(unit, index));
    end
end

function Armory:UnitXP(unit)
    return self:SetGetCharacterValue("XP", _G.UnitXP("player"));
end

function Armory:UnitXPMax(unit)
    return self:SetGetCharacterValue("XPMax", _G.UnitXPMax("player"));
end

----------------------------------------------------------
-- Miscellaneous stubs
----------------------------------------------------------

function Armory:ComputePetBonus(stat, value)
    local _, unitClass = Armory:UnitClass("player");
    unitClass = strupper(unitClass);
    if( unitClass == "WARLOCK" ) then
        if( WARLOCK_PET_BONUS[stat] ) then
            return value * WARLOCK_PET_BONUS[stat];
        else
            return 0;
        end
    elseif( unitClass == "HUNTER" ) then
        if( HUNTER_PET_BONUS[stat] ) then
            return value * HUNTER_PET_BONUS[stat];
        else
            return 0;
        end
    end

    return 0;
end

function Armory:GetDodgeBlockParryChanceFromDefense()
    local base, modifier = Armory:UnitDefense("player");
    local defensePercent = DODGE_PARRY_BLOCK_PERCENT_PER_DEFENSE * ((base + modifier) - (Armory:UnitLevel("player")*5));
    defensePercent = max(defensePercent, 0);
    return defensePercent;
end

function Armory:GetKeyRingSize()
    local numKeyringSlots = self:GetContainerNumSlots(KEYRING_CONTAINER);
    local maxSlotNumberFilled = 0;
    local numItems = 0;
    for i=1, numKeyringSlots do
        local texture = self:GetContainerItemInfo(KEYRING_CONTAINER, i);
        -- Update max slot
        if ( texture and i > maxSlotNumberFilled) then
            maxSlotNumberFilled = i;
        end
        -- Count how many items you have
        if ( texture ) then
            numItems = numItems + 1;
        end
    end

    -- Round to the nearest 4 rows that will hold the keys
    local modulo = maxSlotNumberFilled % 4;
    local size;
    if ( (modulo == 0) and (numItems < maxSlotNumberFilled) ) then
        size = maxSlotNumberFilled;
    else
        -- Only expand if the number of keys in the keyring exceed or equal the max slot filled
        size = maxSlotNumberFilled + (4 - modulo);
    end
    size = min(size, numKeyringSlots);

    return size;
end

----------------------------------------------------------
-- Factions Storage
----------------------------------------------------------

function Armory:SetFactions()
    local container = "Factions";
    local dbEntry = self.playerDbBaseEntry;
    local preserveState = {};
    local preserved = 0;
    local name, isHeader, isCollapsed;

    if ( not self:IsLocked(container) ) then
        self:Lock(container);

        self:PrintDebug("UPDATE", container);

        -- preserve current header state
        if ( dbEntry:Contains(container) ) then
            for i = 1, table.getn(dbEntry:GetValue(container)) do
                name, _, _, _, _, _, _, _, isHeader, isCollapsed = dbEntry:GetValue(container, i);
                if ( isHeader ) then
                    -- name is more reliable than index
                    preserveState[name] = isCollapsed or 0;
                    preserved = preserved + 1;
                end
            end
        end

        -- store the complete (expanded) list
        local funcNumLines = _G.GetNumFactions;
        local funcGetLineInfo = _G.GetFactionInfo;
        local funcGetLineState = function(index)
            local _, _, _, _, _, _, _, _, isHeader, isCollapsed = _G.GetFactionInfo(index);
            return isHeader, not isCollapsed;
        end;
        local funcExpand = _G.ExpandFactionHeader;
        local funcCollapse = _G.CollapseFactionHeader;

        dbEntry:SetExpandableListValues(container, funcNumLines, funcGetLineState, funcGetLineInfo, funcExpand, funcCollapse);

        -- restore state
        if ( preserved > 0 ) then
            for i = 1, dbEntry:GetNumValues(container) do
                name = dbEntry:GetValue(container, i);
                if ( preserveState[name] ~= nil ) then
                   self:SetFactionHeaderState(dbEntry:GetRawValue(container, i), preserveState[name] ~= 0);
                end
            end
        end

        self:Unlock(container);
    else
        self:PrintDebug("LOCKED", container);
    end
 end

----------------------------------------------------------
-- Factions Internals
----------------------------------------------------------

function Armory:SetFactionHeaderState(headerValues, collapsed)
    local isHeaderIndex = "9";
    local isCollapsedIndex = "10";

    if ( headerValues[isHeaderIndex] and collapsed ) then
        headerValues[isCollapsedIndex] = 1;
    else
        headerValues[isCollapsedIndex] = nil;
    end
end

function Armory:UpdateFactionHeaderState(index, state)
    local container = "Factions";
    local dbEntry = self.selectedDbBaseEntry;

    if ( index == 0 ) then
        for i = 1, dbEntry:GetNumValues(container) do
            self:SetFactionHeaderState(dbEntry:GetRawValue(container, i), state);
        end
    else
        if ( not self.factionLines ) then
            self:GetFactionLines();
        end
        if ( index > 0 and index <= table.getn(self.factionLines) ) then
            self:SetFactionHeaderState(dbEntry:GetRawValue(container, self.factionLines[index]), state);
        end
    end
end

function Armory:GetFactionLines()
    local container = "Factions";
    local dbEntry = self.selectedDbBaseEntry;
    local count = dbEntry:GetNumValues(container);
    local collapsed = false;
    local childCollapsed = false;

    self.factionLines = {};
    for i = 1, count do
        local _, _, _, _, _, _, _, _, isHeader, isCollapsed, _, _, isChild = dbEntry:GetValue(container, i);
        if ( isHeader and not isChild ) then
            table.insert(self.factionLines, i);
            collapsed = isCollapsed;
            childCollapsed = false;
        elseif ( isHeader and isChild ) then
            if ( not collapsed ) then
                table.insert(self.factionLines, i);
            end
            childCollapsed = collapsed or isCollapsed;
        elseif ( not (collapsed or childCollapsed) ) then
            table.insert(self.factionLines, i);
        end
    end

    return self.factionLines;
end

----------------------------------------------------------
-- Factions Interface
----------------------------------------------------------

function Armory:GetNumFactions()
    return table.getn(self:GetFactionLines());
end

function Armory:GetFactionInfo(index)
    if ( not self.factionLines ) then
        self:GetFactionLines();
    end
    if ( index > 0 and index <= table.getn(self.factionLines) ) then
        return self.selectedDbBaseEntry:GetValue("Factions", self.factionLines[index]);
    end
end

function Armory:ExpandFactionHeader(index)
    self:UpdateFactionHeaderState(index, false);
end

function Armory:CollapseFactionHeader(index)
    self:UpdateFactionHeaderState(index, true);
end


----------------------------------------------------------
-- Arena Teams Storage
----------------------------------------------------------

function Armory:UpdateArenaTeams()
    local dbEntry = self.playerDbBaseEntry;
    local container, numTeamMembers;
    local i;

    for id = 1, MAX_ARENA_TEAMS do
        container = "ArenaTeam"..id; 

        dbEntry:SetValue(container, _G.GetArenaTeam(id));

        if ( _G.GetArenaTeam(id) ) then
            _G.ArenaTeamRoster(id);

            numTeamMembers = _G.GetNumArenaTeamMembers(id, 1);
            if ( numTeamMembers > 0 ) then
                dbEntry:SetSubValue(container, "NumTeamMembers", numTeamMembers);
                for i = 1, numTeamMembers do
                    dbEntry:SetSubValue(container, "Info"..i, _G.GetArenaTeamRosterInfo(id, i));
                end
            end
        end
    end
end

----------------------------------------------------------
-- Arean Teams Internals
----------------------------------------------------------

function Armory:GetArenaTeamValue(id, key)
    local container = "ArenaTeam"..id;
    local dbEntry = self.selectedDbBaseEntry;
    if ( key == nil ) then
        return dbEntry:GetValue(container);
    end
    return dbEntry:GetSubValue(container, key);
end

----------------------------------------------------------
-- Arena Teams Interface
----------------------------------------------------------

function Armory:GetArenaTeam(id)
    return self:GetArenaTeamValue(id);
end

function Armory:GetNumArenaTeamMembers(id, showOffline)
    return self:GetArenaTeamValue(id, "NumTeamMembers") or 0;
end

function Armory:GetArenaTeamRosterInfo(id, index)
    if ( index ) then
        return self:GetArenaTeamValue(id, "Info"..index);
    end
end


----------------------------------------------------------
-- Inventory Storage
----------------------------------------------------------

function Armory:SetContainer(id)
    local container = "Container"..id;
    local name, numSlots, isCollapsed = self:GetInventoryContainerInfo(id, "player");

    if ( not self:IsLocked(container) ) then
        self:Lock(container);

        self:PrintDebug("UPDATE", container);

        self:SetInventoryContainerInfo(id, nil);

        if ( self:HasInventory() ) then
            local items = {};
            local daysLeft, timeLeft, itemCount, texture, count, quality;

            if ( id == ARMORY_MAIL_CONTAINER ) then
                for index = 1, _G.GetInboxNumItems() do
                    _, _, _, _, _, _, daysLeft, itemCount = _G.GetInboxHeaderInfo(index);
                    if ( itemCount ) then
                        for i = 1, ATTACHMENTS_MAX_RECEIVE do
                            _, texture, count, quality = _G.GetInboxItem(index, i);
                            if ( texture ) then
                                local itemInfo = {};
                                itemInfo.Texture = texture;
                                itemInfo.Count = count;
                                itemInfo.Quality = quality;
                                itemInfo.Link = _G.GetInboxItemLink(index, i);
                                itemInfo.DaysLeft = daysLeft;
                                itemInfo.Equipable = self:CanEquip(itemInfo.Link);
                                table.insert(items, itemInfo);
                            end
                        end
                    end
                end

            elseif ( id == ARMORY_AUCTIONS_CONTAINER ) then
                for i = 1, _G.GetNumAuctionItems("owner") do
                    _, texture, count, quality = _G.GetAuctionItemInfo("owner", i);
                    if ( texture ) then
                        local itemInfo = {};
                        itemInfo.Texture = texture;
                        itemInfo.Count = count;
                        itemInfo.Quality = quality;
                        itemInfo.Link = _G.GetAuctionItemLink("owner", i);
                        itemInfo.TimeLeft = _G.GetAuctionItemTimeLeft("owner", i);
                        table.insert(items, itemInfo);
                    end
                end

            elseif ( id == ARMORY_COMPANION_CONTAINER ) then
                local spellID;
                for _, mode in ipairs({"MOUNT", "CRITTER"}) do
                    for i = 1, _G.GetNumCompanions(mode) do
                        _, _, spellID, texture = _G.GetCompanionInfo(mode, i);
                        if ( texture ) then
                            local itemInfo = {};
                            itemInfo.Texture = texture;
                            itemInfo.Count = 1;
                            itemInfo.Quality = -1;
                            itemInfo.Link = _G.GetSpellLink(spellID);
                            table.insert(items, itemInfo);
                        end
                    end
                end

            else
                for i = 1, _G.GetContainerNumSlots(id) do
                    texture, count, _, quality = _G.GetContainerItemInfo(id, i);
                    if ( texture ) then
                        local itemInfo = {};
                        itemInfo.Index = i;
                        itemInfo.Texture = texture;
                        itemInfo.Count = count;
                        itemInfo.Quality = quality;
                        itemInfo.Link = _G.GetContainerItemLink(id, i);
                        itemInfo.Equipable = self:CanEquip(itemInfo.Link);
                        table.insert(items, itemInfo);
                    end
                end
                
            end

            if ( id == BANK_CONTAINER ) then
                numSlots = NUM_BANKGENERIC_SLOTS;
            elseif ( id ~= ARMORY_MAIL_CONTAINER and id ~= ARMORY_AUCTIONS_CONTAINER and id ~= ARMORY_COMPANION_CONTAINER ) then
                numSlots = _G.GetContainerNumSlots(id);
                name = _G.GetBagName(id);
            else
                numSlots = #items;
            end

            self:SetInventoryContainerInfo(id, name, numSlots, isCollapsed);

            for i = 1, #items do
                local itemInfo = items[i];
                -- GetContainerItemInfo returns: texture, itemCount, locked, quality, readable
                self:SetInventoryContainerValue(id, "Info"..i, itemInfo.Texture, itemInfo.Count, itemInfo.Locked, itemInfo.Quality, itemInfo.Readable, itemInfo.Index);
                self:SetInventoryContainerValue(id, "Link"..i, itemInfo.Link);
                self:SetInventoryContainerValue(id, "Equip"..i, itemInfo.Equipable);
                if ( itemInfo.DaysLeft ) then
                    self:SetInventoryContainerValue(id, "DaysLeft"..i, itemInfo.DaysLeft, time());
                elseif ( itemInfo.TimeLeft ) then
                    self:SetInventoryContainerValue(id, "TimeLeft"..i, itemInfo.TimeLeft, time());
                end
            end
        end
        
        self:Unlock(container);
    else
        self:PrintDebug("LOCKED", container);
    end
end

function Armory:SetMailSent(name)
    self.mailTo = strtrim(name);
    self.mailItems = {};
    
    local link, texture, count, quality;
    for i = 1, ATTACHMENTS_MAX_SEND do
        _, texture, count, quality = _G.GetSendMailItem(i);
        if ( texture ) then
            Armory:PrepareTooltip();
            Armory.tooltip:SetSendMailItem(i);
            _, link = Armory.tooltip:GetItem();
            Armory:ReleaseTooltip();

            local itemInfo = {};
            itemInfo.Texture = texture;
            itemInfo.Count = count;
            itemInfo.Quality = quality;
            itemInfo.Link = link;
            table.insert(self.mailItems, itemInfo);
        end
    end
end

function Armory:SetMailReturned(id)
	local _, _, sender, _, _, _, _, itemCount = _G.GetInboxHeaderInfo(id);

    self.mailTo = sender;
    self.mailItems = {};

    local texture, count, quality;
    if ( itemCount ) then
        for i = 1, ATTACHMENTS_MAX_RECEIVE do
            _, texture, count, quality = _G.GetInboxItem(id, i);
            if ( texture ) then
                local itemInfo = {};
                itemInfo.Texture = texture;
                itemInfo.Count = count;
                itemInfo.Quality = quality;
                itemInfo.Link = _G.GetInboxItemLink(id, i);
                table.insert(self.mailItems, itemInfo);
            end
        end
    end
end

function Armory:AddMailSent()
    local id = ARMORY_MAIL_CONTAINER;
    local numItems = table.getn(self.mailItems);
    local update;

    if ( self:HasInventory() and self.mailTo ~= "" and numItems > 0 ) then
        local currentProfile = self:CurrentProfile();
        for _, profile in ipairs(self:Profiles()) do
            if ( profile.realm == self.playerRealm and strlower(profile.character) == strlower(self.mailTo) ) then
                self:SelectProfile(profile);

                local dbEntry = self.selectedDbBaseEntry;
                local name, numSlots, isCollapsed = self:GetInventoryContainerInfo(id);
                local index = (numSlots or 0);
                
                if ( index == 0 ) then
                    -- initialize container info
                    dbEntry:SetSubValue("Inventory", "Container"..id, name, numSlots, isCollapsed);
                end
                
                dbEntry:SetPosition("Inventory", "Container"..id);
                dbEntry:SetValue("2", index + numItems);

                for i = 1, numItems do
                    local itemInfo = self.mailItems[i];
                    index = index + 1;

                    -- GetContainerItemInfo returns: texture, itemCount, locked, quality, readable
                    dbEntry:SetValue("Info"..index, itemInfo.Texture, itemInfo.Count, nil, itemInfo.Quality);
                    dbEntry:SetValue("Link"..index, itemInfo.Link);
                    dbEntry:SetValue("DaysLeft"..index, 31, time());
                    dbEntry:SetValue("Equip"..index, self:CanEquip(itemInfo.Link));
                end

                update = (profile.character == currentProfile.character);
                break;
            end
        end
        self:SelectProfile(currentProfile);
    end
    
    self.mailTo = "";
        
    return update;
end

function Armory:UpdateInventoryEquippable()
    local id, container, numSlots, link;
    for i = 1, #ArmoryContainers do
        id = ArmoryContainers[i];
        if ( id ~= ARMORY_AUCTIONS_CONTAINER and id ~= ARMORY_COMPANION_CONTAINER ) then
            container = "Container"..id;
            if ( not self:IsLocked(container) ) then
                _, numSlots = self:GetInventoryContainerInfo(id, "player");
                if ( numSlots ) then
                    for index = 1, numSlots do
                        link = self:GetInventoryContainerValue(id, "Link"..index, "player");
                        self:SetInventoryContainerValue(id, "Equip"..index, self:CanEquip(link));
                    end
                end
            else
                self:PrintDebug("LOCKED (equip)", container);
            end
        end
    end
end

----------------------------------------------------------
-- Inventory Internals
----------------------------------------------------------

function Armory:SetInventoryContainerInfo(id, ...)
    self.playerDbBaseEntry:SetSubValue("Inventory", "Container"..id, ...);
end

function Armory:GetInventoryContainerInfo(id, unit)
    local dbEntry = self.selectedDbBaseEntry;
    if ( unit and unit == "player" ) then
        dbEntry = self.playerDbBaseEntry;
    end
    return dbEntry:GetSubValue("Inventory", "Container"..id);
end

function Armory:GetInventoryContainerInfoEx(id, unit)
    local name, numSlots, isCollapsed = self:GetInventoryContainerInfo(id, unit);

    if ( id == BANK_CONTAINER ) then
        name = ARMORY_BANK_CONTAINER_NAME;
    elseif ( id == KEYRING_CONTAINER ) then
        name = KEYRING;
    elseif ( id == ARMORY_MAIL_CONTAINER ) then
        name = INBOX;
    elseif ( id == ARMORY_AUCTIONS_CONTAINER ) then
        name = AUCTIONS;
    elseif ( id == ARMORY_COMPANION_CONTAINER ) then
        name = COMPANIONS;
    elseif ( name ) then
        local prefix = "";
        if ( id > NUM_BAG_SLOTS ) then
            prefix = ARMORY_BANK_CONTAINER_NAME.." #"..(id - NUM_BAG_SLOTS).." - ";
        elseif ( id > 0 ) then
            prefix = "#"..id.." - ";
        end
        name = prefix..format(CONTAINER_SLOTS, numSlots, name);
    else
		name = UNKNOWN;
    end

    return name, numSlots, isCollapsed;
end

function Armory:SelectInventoryContainer(baseEntry, id)
    local dbEntry = ArmoryDbEntry:new(baseEntry);
    dbEntry:SetPosition("Inventory", "Container"..id);
    return dbEntry;
end

function Armory:SetInventoryContainerValue(id, key, ...)
    self:SelectInventoryContainer(self.playerDbBaseEntry, id):SetValue(key, ...);
end

function Armory:GetInventoryContainerValue(id, key, unit)
    local dbEntry = self.selectedDbBaseEntry;
    if ( unit and unit == "player" ) then
        dbEntry = self.playerDbBaseEntry;
    end

    if ( dbEntry:Contains("Inventory", "Container"..id, key) ) then
        return self:SelectInventoryContainer(dbEntry, id):GetValue(key);
    end
end

function Armory:GetInventoryLines()
    local id, itemLines, header, group;
    local link, name, numSlots, itemCount, itemId, isCollapsed;
    local inventoryList = {};
    local currentProfile = self:CurrentProfile();
    local numRealms = table.getn(self:RealmList());

    self.inventoryLines = {};

    if ( self.inventorySearchAll ) then
        for _, profile in ipairs(self:Profiles()) do
            table.insert(inventoryList, profile);
        end
    else
        table.insert(inventoryList, currentProfile);
    end

    for _, profile in ipairs(inventoryList) do
        self:SelectProfile(profile);

        if ( self.inventorySearchAll ) then
            if ( numRealms > 1 ) then
                group = {profile.character.." ("..profile.realm..")", nil, 0};
            else
                group = {profile.character, nil, 0};
            end
        end

        for i = 1, #ArmoryContainers do
            id = ArmoryContainers[i];
            name, numSlots, isCollapsed = self:GetInventoryContainerInfoEx(id);
            header = {name, id, numSlots, isCollapsed, true, nil, nil, profile.realm, profile.character, 0};
            if ( numSlots and numSlots > 0 ) then
                itemLines = {};
                for index = 1, numSlots do
                    link = self:GetContainerItemLink(id, index);
                    name = self:GetNameFromLink(link);
                    if ( name and self:MatchInventoryItem(name, link, true) ) then
                        _, itemCount = self:GetContainerItemInfo(id, index);
                        table.insert(itemLines, {name, id, itemCount, nil, nil, index, link, profile.realm, profile.character});
                    else
                        -- free slot
                        header[10] = header[10] + 1;
                    end
                end
                if ( #itemLines == 0 and not self:InventoryFilterActive() ) then
                    table.insert(itemLines, {EMPTY, id, 0, nil, nil, 0, nil, profile.realm, profile.character});
                end
                if ( #itemLines > 0 ) then
                    if ( group ) then
                        table.insert(self.inventoryLines, group);
                        group = nil;
                    end
                    table.insert(self.inventoryLines, header);
                    -- if inventory of all characters is viewed the states are kept in a separate state table
                    if ( self.inventorySearchAll ) then
                        isCollapsed = self.inventoryState[self:GetInventoryStateKey(header)];
                    end
                    if ( not isCollapsed ) then
                        table.sort(itemLines, function(a, b) return a[1] < b[1] end);
                        for _, v in ipairs(itemLines) do
                            table.insert(self.inventoryLines, v);
                        end
                    end
                end
            end
        end
    end

    self:SelectProfile(currentProfile);

    return self.inventoryLines;
end

function Armory:SetContainerState(containerValues, collapsed)
    local isCollapsedIndex = "3";

    if ( collapsed ) then
        containerValues[isCollapsedIndex] = 1;
    else
        containerValues[isCollapsedIndex] = nil;
    end
end

function Armory:UpdateContainerState(id, state)
    local container = "Inventory";
    local dbEntry = self.selectedDbBaseEntry;

    if ( self.inventorySearchAll ) then
        return;
    elseif ( id == 9999 ) then
        for key in pairs(dbEntry:GetValue(container)) do
            self:SetContainerState(dbEntry:GetRawValue(container, key), state);
        end
    else
        local key = "Container"..id;
        if ( dbEntry:Contains(container, key) ) then
            self:SetContainerState(dbEntry:GetRawValue(container, key), state);
        end
    end
end

function Armory:UpdateInventoryState(id, state)
    if ( not self.inventorySearchAll ) then
        if ( id == 9999 ) then
            for i = 1, table.getn(self.inventoryLines) do
                self:UpdateInventoryState(i, state);
            end
        else
            local _, containerId, _, _, isHeader = self:GetInventoryLineInfo(id);
            if ( isHeader ) then
                self:UpdateContainerState(containerId, state);
            end
        end
    elseif ( id == 9999 ) then
        if ( state ) then
            for i = 1, table.getn(self.inventoryLines) do
                self:UpdateInventoryState(i, state);
            end
        else
            self.inventoryState = {};
        end
    elseif ( id > 0 and id <= table.getn(self.inventoryLines) ) then
        local key = self:GetInventoryStateKey(self.inventoryLines[id]);
        local isHeader = self.inventoryLines[id][5];
        if ( key ) then
            if ( state and isHeader ) then
                self.inventoryState[key] = 1;
            else
                self.inventoryState[key] = nil;
            end
        end
    end
end

function Armory:GetInventoryStateKey(line)
    local name, id, _, _, _, _, _, realm, character = unpack(line);
    if ( id ) then
        return (name or UNKNOWN)..(realm or "")..(character or "")..id;
    end
end

----------------------------------------------------------
-- Inventory Interface
----------------------------------------------------------

function Armory:GetBagName(id)
    return ( self:GetInventoryContainerInfo(id) );
end

function Armory:GetContainerNumSlots(id)
    local _, numSlots = self:GetInventoryContainerInfo(id);
    return numSlots or 0;
end

function Armory:GetContainerItemInfo(id, index)
    return self:GetInventoryContainerValue(id, "Info"..index);
end

function Armory:GetContainerItemLink(id, index)
    return self:GetInventoryContainerValue(id, "Link"..index);
end

function Armory:GetContainerInboxItemDaysLeft(id, index)
    local daysLeft, timestamp = self:GetInventoryContainerValue(id, "DaysLeft"..index);
    if ( daysLeft ) then
       daysLeft = daysLeft - (time() - timestamp) / (24 * 60 * 60);
    end
    return daysLeft;
end

function Armory:GetContainerItemCanEquip(id, index)
    return self:GetInventoryContainerValue(id, "Equip"..index);
end

function Armory:GetNumInventoryLines()
    return table.getn(self:GetInventoryLines());
end

function Armory:GetInventoryLineInfo(index)
    if ( not self.inventoryLines ) then
        self:GetInventoryLines();
    end
    if ( index > 0 and index <= table.getn(self.inventoryLines) ) then
        return unpack(self.inventoryLines[index]);
    end
end

function Armory:GetInventoryLineState(id)
    local isCollapsed;
    if ( self.inventorySearchAll ) then
        local key = self:GetInventoryStateKey(self.inventoryLines[id]);
        if ( key ) then
            isCollapsed = self.inventoryState[key];
        end
    else
        _, _, _, isCollapsed = Armory:GetInventoryLineInfo(id);
    end
    return isCollapsed;
end

function Armory:ExpandContainer(id)
    self:UpdateContainerState(id, false);
end

function Armory:CollapseContainer(id)
    self:UpdateContainerState(id, true);
end

function Armory:ExpandInventoryHeader(id)
    self:UpdateInventoryState(id, false);
end

function Armory:CollapseInventoryHeader(id)
    self:UpdateInventoryState(id, true);
end

function Armory:InventoryFilterActive()
    return (self.inventoryFilter ~= "" or ArmoryItemFilter_IsEnabled());
end

function Armory:MatchInventoryItem(name, link, emptyMatch)
    local match;
    
    if ( self.inventoryFilter == "" ) then
        match = ArmoryItemFilter(link);
        if ( not emptyMatch ) then
            match = match and ArmoryItemFilter_IsEnabled();
        end
    else
        if ( string.match(self.inventoryFilter, "^=%d$") ) then
            match = (tonumber(strsub(self.inventoryFilter, 2)) == self:GetQualityFromLink(link));
        else
            match = string.find(strlower(name), strlower(self.inventoryFilter), 1, true);
        end
        match = match and ArmoryItemFilter(link);
    end
    return match;
end

function Armory:SetInventoryItemNameFilter(text)
    if ( strsub(text, 1, 1) == "=" ) then
        text = strlower(strsub(text, 2));
        if ( not tonumber(text) ) then
            for i = 0, 6 do
                if ( text == strlower(getglobal("ITEM_QUALITY"..i.."_DESC")) ) then
                    text = tostring(i);
                    break;
                end
            end
        end
        if ( not text:match("[0-6]") ) then
            return;
        end
        text = "="..text;
    end

    local refresh = (self.inventoryFilter ~= text);
    self.inventoryFilter = text;
    if ( refresh ) then
        self.inventoryState = {};
    end
    return refresh;
end

function Armory:GetInventoryItemNameFilter()
    return self.inventoryFilter;
end

function Armory:SetInventorySearchAllFilter(searchAll)
    local refresh = (self.inventorySearchAll ~= searchAll);
    self.inventorySearchAll = searchAll;
    if ( refresh ) then
        self.inventoryState = {};
    end
    return refresh;
end

function Armory:GetInventorySearchAllFilter()
    return self.inventorySearchAll;
end

function Armory:ScanInventory(link, bagsOnly)
    local id, itemCount;
    local count = 0;
    local bagCount = 0;
    local bankCount = 0;
    local mailCount = 0;

    if ( link ) then
        local name = self:GetNameFromLink(link);
        if ( name ) then
            for i = 1, #ArmoryContainers do
                id = ArmoryContainers[i];
                if ( (bagsOnly and id >= BACKPACK_CONTAINER and id <= NUM_BAG_SLOTS) or (not bagsOnly and id ~= ARMORY_AUCTIONS_CONTAINER and id ~= ARMORY_COMPANION_CONTAINER ) ) then 
                    for index = 1, self:GetContainerNumSlots(id) do
                        if ( self:GetNameFromLink(self:GetContainerItemLink(id, index)) == name ) then
                            _, itemCount = self:GetContainerItemInfo(id, index);
                            if ( itemCount ) then
                                if ( id == ARMORY_MAIL_CONTAINER ) then
                                    mailCount = mailCount + itemCount;
                                elseif ( id >= BACKPACK_CONTAINER and id <= NUM_BAG_SLOTS ) then
                                    bagCount = bagCount + itemCount;
                                elseif ( id == BANK_CONTAINER or (id > NUM_BAG_SLOTS and id <= NUM_BAG_SLOTS + NUM_BANKBAGSLOTS) ) then
                                    bankCount = bankCount + itemCount;
                                end
                                count = count + itemCount;
                            end
                        end
                    end
                end
            end
        end
    end

    return count, bagCount, bankCount, mailCount;
end

function Armory:Find(...)
    local invalidCommand = false;

    if ( select("#", ...) > 0 ) then
        local flags = {};
        local where = strlower(select(1, ...));
        local firstArg = 2;
        if ( where == strlower(ARMORY_CMD_FIND_ALL) ) then
            flags[ARMORY_CMD_FIND_ALL] = 1;
        elseif ( where == strlower(ARMORY_CMD_FIND_ITEM) ) then
            flags[ARMORY_CMD_FIND_ITEM] = 1;
        elseif ( where == strlower(ARMORY_CMD_FIND_QUEST) ) then
            flags[ARMORY_CMD_FIND_QUEST] = 1;
        elseif ( where == strlower(ARMORY_CMD_FIND_SPELL) ) then
            flags[ARMORY_CMD_FIND_SPELL] = 1;
        elseif ( where == strlower(ARMORY_CMD_FIND_SKILL) ) then
            flags[ARMORY_CMD_FIND_SKILL] = 1;
        else
            flags[ARMORY_CMD_FIND_ITEM] = 1;
            firstArg = 1;
        end

        if ( select(firstArg, ...) ) then
            local currentProfile = self:CurrentProfile();
            local numRealms = table.getn(self:RealmList());
            local found = {};
            local count = 0;

            local itemPattern = NORMAL_FONT_COLOR_CODE.." %s: "..FONT_COLOR_CODE_CLOSE.." %s";
            
            for _, profile in ipairs(self:Profiles()) do
                if ( self:GetConfigGlobalSearch() or profile.realm == self.playerRealm ) then
                    self:SelectProfile(profile);
                    if ( (flags[ARMORY_CMD_FIND_ALL] or flags[ARMORY_CMD_FIND_ITEM]) and self:HasInventory() ) then
                        found[ARMORY_CMD_FIND_ITEM] = self:FindItem(firstArg, ...);
                    end
                    if ( (flags[ARMORY_CMD_FIND_ALL] or flags[ARMORY_CMD_FIND_QUEST]) and self:HasQuestLog() ) then
                        found[ARMORY_CMD_FIND_QUEST] = self:FindQuest(firstArg, ...);
                    end
                    if ( (flags[ARMORY_CMD_FIND_ALL] or flags[ARMORY_CMD_FIND_SPELL]) and self:HasSpellBook() ) then
                        found[ARMORY_CMD_FIND_SPELL] = self:FindSpell(firstArg, ...);
                    end
                    if ( (flags[ARMORY_CMD_FIND_ALL] or flags[ARMORY_CMD_FIND_SKILL]) and self:HasTradeSkills() ) then
                        found[ARMORY_CMD_FIND_SKILL] = self:FindSkill(nil, firstArg, ...);
                    end
                    for _, list in pairs(found) do
                        for _, line in ipairs(list) do
                            if ( self:GetConfigGlobalSearch() and numRealms > 1 ) then
                                self:Print(format("%s (%s)"..itemPattern, profile.character, profile.realm, line.label, line.value));
                            else
                                self:Print(format("%s"..itemPattern, profile.character, line.label, line.value));
                            end
                            count = count + 1;
                        end
                    end
                 end
            end
            self:SelectProfile(currentProfile);

            if ( (flags[ARMORY_CMD_FIND_ALL] or flags[ARMORY_CMD_FIND_ITEM]) and AGB and AGB.Find ) then
                for _, line in ipairs(AGB:Find(firstArg, ...)) do
                    self:Print(format("%s (%s)"..itemPattern, GUILD_BANK, line.guild, line.label, line.value));
                    count = count + 1;
                end
            end

            if ( count == 0 ) then
                self:Print(ARMORY_CMD_FIND_NOT_FOUND);
            else
                self:Print(format(ARMORY_CMD_FIND_FOUND, count));
            end
        else
            invalidCommand = true;
        end
    else
        invalidCommand = true;
    end

    return invalidCommand;
end

function Armory:FindNameParts(name, start, ...)
    local numParts = select("#", ...);
    if ( not name or start > numParts ) then
        return false;
    end

    name = strlower(name);
    for i = start, numParts do
        if ( not string.find(name, strlower(select(i, ...)), 1, true) ) then
            return false;
        end
    end
    return true;
end

function Armory:FindItem(firstArg, ...)
    local id, container, numSlots, items, link, name, itemCount;
    local list = {};

    for i = 1, #ArmoryContainers do
        id = ArmoryContainers[i];
        container, numSlots = self:GetInventoryContainerInfoEx(id);
        if ( numSlots or 0 > 0 ) then
            for index = 1, numSlots do
                link = self:GetContainerItemLink(id, index);
                name = self:GetNameFromLink(link);
                if ( name and self:FindNameParts(name, firstArg, ...) ) then
                    _, itemCount = self:GetContainerItemInfo(id, index);
                    if ( itemCount > 1 ) then
                        table.insert(list, {label=container, value=(link or name).."x"..itemCount});
                    else
                        table.insert(list, {label=container, value=(link or name)});
                    end
                end
            end
        end
    end

    local numEntries = self:GetNumQuestLogEntries();
    if ( numEntries ) then
        local currentSelection = self:GetQuestLogSelection();

        for questIndex = 1, numEntries do
            local questLogTitleText, level, _, _, isHeader = self:GetQuestLogTitle(questIndex);
            local label;

            if ( not isHeader ) then
                self:SelectQuestLogEntry(questIndex);
                label = ARMORY_CMD_FIND_QUEST_REWARD.." "..self:HexColor(ArmoryGetDifficultyColor(level))..questLogTitleText..FONT_COLOR_CODE_CLOSE;
                for i = 1, self:GetNumQuestLogChoices() do
                    link = self:GetQuestLogItemLink("choice", i);
                    name = self:GetQuestLogChoiceInfo(i);
                    if ( self:FindNameParts(name, firstArg, ...) ) then
                        table.insert(list, {label=label, value=(link or name)});
                    end
                end
                for i = 1, self:GetNumQuestLogRewards() do
                    link = self:GetQuestLogItemLink("reward", i);
                    name = self:GetQuestLogRewardInfo(i);
                    if ( self:FindNameParts(name, firstArg, ...) ) then
                        table.insert(list, {label=label, value=(link or name)});
                    end
                end
            end
        end

        self:SelectQuestLogEntry(currentSelection);
    end

    self:FindSkill(list, firstArg, ...);

    return list;
end

function Armory:FindQuest(firstArg, ...)
    local name, level, isHeader, link;
    local numEntries = self:GetNumQuestLogEntries();
    local list = {};

    if ( numEntries ) then
        for questIndex = 1, numEntries do
            name, level, _, _, isHeader = self:GetQuestLogTitle(questIndex);
            if ( not isHeader ) then
                if ( self:FindNameParts(name, firstArg, ...) ) then
                    link = self:GetQuestLink(questIndex);
                    name = self:HexColor(ArmoryGetDifficultyColor(level))..name..FONT_COLOR_CODE_CLOSE;
                    table.insert(list, {label=QUEST_LOG, value=(link or name)});
                end
            end
        end
    end

    return list;
end

function Armory:FindSpell(firstArg, ...)
    local list = {};

    local numSkillLineTabs = self:GetNumSpellTabs();
    local tabName, spellName, subSpellName, offset, numSpells, link;
    if ( numSkillLineTabs ) then
        for i = 1, numSkillLineTabs do
            tabName, _, offset, numSpells = self:GetSpellTabInfo(i);
            for j = 1, numSpells do
                spellName, subSpellName = self:GetSpellName(j + offset, BOOKTYPE_SPELL);
                if ( self:FindNameParts(spellName, firstArg, ...) ) then
                    link = self:GetSpellLink(j + offset, BOOKTYPE_SPELL);
                    if ( subSpellName and subSpellName ~= "" ) then
                        table.insert(list, {label=SPELLBOOK.." "..tabName, value=(link or spellName).." ("..subSpellName..")"});
                    else
                        table.insert(list, {label=SPELLBOOK.." "..tabName, value=(link or spellName)});
                    end
                end
            end
        end
    end

    local pets = self:GetPets();
    local currentPet = self.selectedPet;
    for i = 1, #pets do
        self.selectedPet = pets[i];
        local numPetSpells = self:HasPetSpells() or 0;
        for id = 1, numPetSpells do
            spellName, subSpellName = self:GetSpellName(id, BOOKTYPE_PET);
            if ( self:FindNameParts(spellName, firstArg, ...) ) then
                link = self:GetSpellLink(id, BOOKTYPE_PET);
                if ( subSpellName and subSpellName ~= "" ) then
                    table.insert(list, {label=SPELLBOOK.." "..self.selectedPet, value=(link or spellName).." ("..subSpellName..")"});
                else
                    table.insert(list, {label=SPELLBOOK.." "..self.selectedPet, value=(link or spellName)});
                end
            end
        end
    end
    self.selectedPet = currentPet;

    local numEntries = self:GetNumQuestLogEntries();
    if ( numEntries ) then
        local currentSelection = self:GetQuestLogSelection();

        for questIndex = 1, numEntries do
            local questLogTitleText, level, _, _, isHeader = self:GetQuestLogTitle(questIndex);
            local label;

            if ( not isHeader ) then
                self:SelectQuestLogEntry(questIndex);
                if ( self:GetQuestLogRewardSpell() ) then
                    local _, name = self:GetQuestLogRewardSpell();
                    if ( self:FindNameParts(name, firstArg, ...) ) then
                        label = ARMORY_CMD_FIND_QUEST_REWARD.." "..self:HexColor(ArmoryGetDifficultyColor(level))..questLogTitleText..FONT_COLOR_CODE_CLOSE;
                        table.insert(list, {label=label, value=name});
                    end
                end
            end
        end

        self:SelectQuestLogEntry(currentSelection);
    end

    return list;
end

function Armory:FindSkill(itemList, firstArg, ...)
    local list = itemList or {};

    -- need low-level access because of all the possible active filters
    local professions = self.selectedDbBaseEntry:GetValue("Professions");
    if ( professions ) then
        local container = "SkillLines";
        local link, dbEntry;
        for name in pairs(professions) do
            dbEntry = ArmoryDbEntry:new(professions[name]);
            for i = 1, dbEntry:GetNumValues(container) do
                local skillName, skillType = dbEntry:GetValue(container, i);
                if ( skillType ~= "header" and self:FindNameParts(skillName, firstArg, ...) ) then
                    if ( itemList ) then
                        link = dbEntry:GetSubValue(container, i, "ItemLink");
                    else
                        link = dbEntry:GetSubValue(container, i, "RecipeLink");
                    end
                    if ( link ) then
                        table.insert(list, {label=name, value=link});
                    end
                end
            end
        end
    end

    return list;
end

----------------------------------------------------------
-- Quests Storage
----------------------------------------------------------

function Armory:UpdateQuests()
    local container = "Quests";
    local dbEntry = self.playerDbBaseEntry;
    local _, numQuests = _G.GetNumQuestLogEntries();

    if ( not self:IsLocked(container) ) then
        self:Lock(container);

        self:PrintDebug("UPDATE", container);

        if ( self:HasQuestLog() ) then
            self:SetQuests();

            dbEntry:SetSubValue(container, "NumQuests", numQuests);
            dbEntry:SetSubValue(container, "MaxDailyQuests", _G.GetMaxDailyQuests());
            dbEntry:SetSubValue(container, "DailyQuestsCompleted", _G.GetDailyQuestsCompleted());
        else
            dbEntry:SetValue(container, nil);
        end

        self:Unlock(container);
    else
        self:PrintDebug("LOCKED", container);
    end
end

function Armory:SetQuests()
    local container = "Quests";
    local dbEntry = self.playerDbBaseEntry;
    local preserveState = {};
    local preserved = 0;
    local name, isHeader, isCollapsed;
    local currentQuest = _G.GetQuestLogSelection();

    -- preserve current header state
    if ( dbEntry:Contains(container) ) then
        for i = 1, table.getn(dbEntry:GetValue(container)) do
            name, _, _, _, isHeader, isCollapsed = dbEntry:GetValue(container, i);
            if ( isHeader ) then
                -- name is more reliable than index
                preserveState[name] = isCollapsed or 0;
                preserved = preserved + 1;
            end
        end
    end

    -- store the complete (expanded) list
    local funcNumLines = _G.GetNumQuestLogEntries;
    local funcGetLineInfo = _G.GetQuestLogTitle;
    local funcGetLineState = function(index)
            local _, _, _, _, isHeader, isCollapsed = _G.GetQuestLogTitle(index);
            return isHeader, not isCollapsed;
        end;
    local funcExpand = _G.ExpandQuestHeader;
    local funcCollapse = _G.CollapseQuestHeader;
    local funcSelect = _G.SelectQuestLogEntry;
    local funcAdditionalInfo =
            function(index)
                return {
                    Link = _G.GetQuestLink,
                    Failed = _G.IsCurrentQuestFailed,
                    Text = _G.GetQuestLogQuestText,
                    TimeLeft = 
                        function(index) 
                            return _G.GetQuestLogTimeLeft(), time(); 
                        end,
                    RequiredMoney = _G.GetQuestLogRequiredMoney,
                    RewardMoney = _G.GetQuestLogRewardMoney,
                    RewardHonor = _G.GetQuestLogRewardHonor,
                    RewardSpell = _G.GetQuestLogRewardSpell,
                    RewardTalents = _G.GetQuestLogRewardTalents,
                    SpellLink = _G.GetQuestLogSpellLink,
                    RewardTitle = _G.GetQuestLogRewardTitle,
                    GroupNum = _G.GetQuestLogGroupNum,
                    NumLeaderBoards = _G.GetNumQuestLeaderBoards,
                    LeaderBoards =
                        function(index)
                            local data = {};
                            for i = 1, _G.GetNumQuestLeaderBoards() do
                                data[i] = ArmoryDbEntry.Save(_G.GetQuestLogLeaderBoard(i));
                            end
                            return data;
                        end,
                    NumRewards = _G.GetNumQuestLogRewards,
                    Rewards =
                        function(index)
                            local data = {};
                            for i = 1,  _G.GetNumQuestLogRewards() do
                                data["Info"..i] = ArmoryDbEntry.Save(_G.GetQuestLogRewardInfo(i));
                                data["Link"..i] = ArmoryDbEntry.Save(_G.GetQuestLogItemLink("reward", i));
                            end
                            return data;
                        end,
                    NumChoices = _G.GetNumQuestLogChoices,
                    Choices =
                        function(index)
                            local data = {};
                            for i = 1, _G.GetNumQuestLogChoices() do
                                data["Info"..i] = ArmoryDbEntry.Save(_G.GetQuestLogChoiceInfo(i));
                                data["Link"..i] = ArmoryDbEntry.Save(_G.GetQuestLogItemLink("choice", i));
                            end
                            return data;
                        end
               };
            end

    dbEntry:SetExpandableListValues(container, funcNumLines, funcGetLineState, funcGetLineInfo, funcExpand, funcCollapse, funcAdditionalInfo, funcSelect);

    -- restore state
    if ( preserved > 0 ) then
        for i = 1, dbEntry:GetNumValues(container) do
            name = dbEntry:GetValue(container, i);
            if ( preserveState[name] ~= nil ) then
               self:SetQuestHeaderState(dbEntry:GetRawValue(container, i), preserveState[name] ~= 0);
            end
        end
    end

    _G.SelectQuestLogEntry(currentQuest);
 end

----------------------------------------------------------
-- Quests Internals
----------------------------------------------------------

function Armory:GetQuestLineValue(index, key, subkey)
    if ( not self.questLines ) then
        self:GetQuestLines();
    end
    if ( index > 0 and index <= table.getn(self.questLines) ) then
        local dbEntry = ArmoryDbEntry:new(self.selectedDbBaseEntry);
        if ( not key ) then
            return dbEntry:GetValue("Quests", self.questLines[index]);
        else
            dbEntry:SetPosition("Quests", self.questLines[index]);
            if ( subkey ) then
                return dbEntry:GetSubValue(key, subkey);
            else
                return dbEntry:GetValue(key);
            end
        end
    end
end

function Armory:SetQuestHeaderState(headerValues, collapsed)
    local isHeaderIndex = "5";
    local isCollapsedIndex = "6";

    if ( headerValues[isHeaderIndex] and collapsed ) then
        headerValues[isCollapsedIndex] = 1;
    else
        headerValues[isCollapsedIndex] = nil;
    end
end

function Armory:UpdateQuestHeaderState(index, state)
    local container = "Quests";
    local dbEntry = self.selectedDbBaseEntry;

    if ( index == 0 ) then
        for i = 1, dbEntry:GetNumValues(container) do
            self:SetQuestHeaderState(dbEntry:GetRawValue(container, i), state);
        end
    else
        if ( not self.questLines ) then
            self:GetQuestLines();
        end
        if ( index > 0 and index <= table.getn(self.questLines) ) then
            self:SetQuestHeaderState(dbEntry:GetRawValue(container , self.questLines[index]), state);
        end
    end
end

function Armory:GetQuestLines()
    local container = "Quests";
    local dbEntry = self.selectedDbBaseEntry;
    local count = dbEntry:GetNumValues(container);
    local collapsed = false;

    self.questLines = {};
    for i = 1, count do
        local _, _, _, _, isHeader, isCollapsed = dbEntry:GetValue(container, i);
        if ( isHeader ) then
            table.insert(self.questLines, i);
            collapsed = isCollapsed;
        elseif ( not collapsed ) then
            table.insert(self.questLines, i);
        end
    end

    return self.questLines;
end

----------------------------------------------------------
-- Quests Interface
----------------------------------------------------------

function Armory:GetDailyQuestsCompleted()
    return self.selectedDbBaseEntry:GetSubValue("Quests", "DailyQuestsCompleted");
end

function Armory:GetMaxDailyQuests()
    return self.selectedDbBaseEntry:GetSubValue("Quests", "MaxDailyQuests");
end

function Armory:GetNumQuestLogEntries()
    local numEntries = table.getn(self:GetQuestLines());
    local numQuests = self.selectedDbBaseEntry:GetSubValue("Quests", "NumQuests");
    return numEntries, numQuests;
end

function Armory:GetQuestLogTitle(index)
    return self:GetQuestLineValue(index);
end

function Armory:ExpandQuestHeader(index)
    self:UpdateQuestHeaderState(index, false);
end

function Armory:CollapseQuestHeader(index)
    self:UpdateQuestHeaderState(index, true);
end

function Armory:GetQuestLink(index)
    return self:GetQuestLineValue(index, "Link");
end

function Armory:GetQuestLogSelection()
    return self.selectedQuestLine;
end

function Armory:SelectQuestLogEntry(index)
    self.selectedQuestLine = index;
end

function Armory:IsCurrentQuestFailed()
    return self:GetQuestLineValue(self.selectedQuestLine, "Failed");
end

function Armory:GetQuestLogQuestText()
    return self:GetQuestLineValue(self.selectedQuestLine, "Text");
end

function Armory:GetQuestLogTimeLeft()
    local timeLeft, timestamp = self:GetQuestLineValue(self.selectedQuestLine, "TimeLeft");

    if ( timeLeft ) then
        timeLeft = timeLeft - (time() - timestamp);
        if ( timeLeft < 0 ) then
            timeLeft = 0;
        end
    end
    return timeLeft;
end

function Armory:GetQuestLogRequiredMoney()
    return self:GetQuestLineValue(self.selectedQuestLine, "RequiredMoney");
end

function Armory:GetQuestLogRewardMoney()
    return self:GetQuestLineValue(self.selectedQuestLine, "RewardMoney");
end

function Armory:GetQuestLogRewardHonor()
    return self:GetQuestLineValue(self.selectedQuestLine, "RewardHonor");
end

function Armory:GetQuestLogRewardSpell()
    return self:GetQuestLineValue(self.selectedQuestLine, "RewardSpell");
end

function Armory:GetQuestLogRewardTalents()
    return self:GetQuestLineValue(self.selectedQuestLine, "RewardTalents");
end

function Armory:GetQuestLogRewardTitle()
    return self:GetQuestLineValue(self.selectedQuestLine, "RewardTitle");
end

function Armory:GetQuestLogSpellLink()
    return self:GetQuestLineValue(self.selectedQuestLine, "SpellLink");
end

function Armory:GetQuestLogGroupNum()
    return self:GetQuestLineValue(self.selectedQuestLine, "GroupNum");
end

function Armory:GetNumQuestLeaderBoards()
    return self:GetQuestLineValue(self.selectedQuestLine, "NumLeaderBoards");
end

function Armory:GetQuestLogLeaderBoard(id)
    return self:GetQuestLineValue(self.selectedQuestLine, "LeaderBoards", id);
end

function Armory:GetNumQuestLogRewards()
    return self:GetQuestLineValue(self.selectedQuestLine, "NumRewards");
end

function Armory:GetQuestLogRewardInfo(id)
    return self:GetQuestLineValue(self.selectedQuestLine, "Rewards", "Info"..id);
end

function Armory:GetNumQuestLogChoices()
    return self:GetQuestLineValue(self.selectedQuestLine, "NumChoices");
end

function Armory:GetQuestLogChoiceInfo(id)
    return self:GetQuestLineValue(self.selectedQuestLine, "Choices", "Info"..id);
end

function Armory:GetQuestLogItemLink(itemType, id)
    if ( itemType == "reward" ) then
        return self:GetQuestLineValue(self.selectedQuestLine, "Rewards", "Link"..id);
    elseif ( itemType == "choice" ) then
        return self:GetQuestLineValue(self.selectedQuestLine, "Choices", "Link"..id);
    end
end

----------------------------------------------------------
-- Raid Info Storage
----------------------------------------------------------

function Armory:UpdateInstances()
    local container = "Instances";
    local dbEntry = self.playerDbBaseEntry;
    local numInstances = _G.GetNumSavedInstances();

    if ( not self:IsLocked(container) ) then
        self:Lock(container);

        self:PrintDebug("UPDATE", container);

        dbEntry:SetValue(container, {});

        dbEntry:SetSubValue(container, "NumInstances", numInstances);
        dbEntry:SetSubValue(container, "TimeStamp", time());
        for i = 1, numInstances do
            dbEntry:SetSubValue(container, "Instance"..i, _G.GetSavedInstanceInfo(i));
        end

        self:Unlock(container);
    else
        self:PrintDebug("LOCKED", container);
    end
end

----------------------------------------------------------
-- Raid Info Internals
----------------------------------------------------------

function Armory:GetInstanceValue(key)
    local dbEntry = self.selectedDbBaseEntry;
    return dbEntry:GetSubValue("Instances", key);
end

----------------------------------------------------------
-- Raid Info Interface
----------------------------------------------------------

function Armory:GetNumSavedInstances()
    return self:GetInstanceValue("NumInstances") or 0;
end

function Armory:GetSavedInstanceInfo(id)
    local timestamp = self:GetInstanceValue("TimeStamp");
    local instanceName, instanceID, instanceReset, instanceDifficulty = self:GetInstanceValue("Instance"..id);

    if ( instanceReset ) then
        instanceReset = instanceReset - (time() - timestamp);
        if ( instanceReset > 0 ) then
            return instanceName, instanceID, instanceReset, instanceDifficulty;
        end
    end
end

----------------------------------------------------------
-- Skills Storage
----------------------------------------------------------

function Armory:SetSkills()
    local container = "Skills";
    local dbEntry = self.playerDbBaseEntry;
    local preserveState = {};
    local name, isHeader, isExpanded;
    local skills = {};
    local data, found;

    if ( not self:IsLocked(container) ) then
        self:Lock(container);

        self:PrintDebug("UPDATE", container);

        -- preserve current header state
        if ( dbEntry:Contains(container) ) then
            for i = 1, table.getn(dbEntry:GetValue(container)) do
                name, isHeader, isExpanded = dbEntry:GetValue(container, i);
                if ( isHeader ) then
                    -- name is more reliable than index
                    preserveState[name] = isExpanded or 0;
                end
            end
        end

        -- store the complete (expanded) list
        local funcNumLines = _G.GetNumSkillLines;
        local funcGetLineInfo = _G.GetSkillLineInfo;
        local funcGetLineState = function(index)
        local _, isHeader, isExpanded = _G.GetSkillLineInfo(index);
            return isHeader, isExpanded;
        end;
        local funcExpand = _G.ExpandSkillHeader;
        local funcCollapse = _G.CollapseSkillHeader;

        dbEntry:SetExpandableListValues(container, funcNumLines, funcGetLineState, funcGetLineInfo, funcExpand, funcCollapse);

        -- restore state
        for i = 1, dbEntry:GetNumValues(container) do
            name = dbEntry:GetValue(container, i);
            table.insert(skills, name);
            if ( preserveState[name] ~= nil ) then
                self:SetSkillHeaderState(dbEntry:GetRawValue(container, i), preserveState[name] ~= 0);
            end
        end

        -- check if the stored trade skills are still valid
        data = dbEntry:GetValue("Professions");
        if ( data ) then
            for name,_ in pairs(data) do
                found = false;
                for i = 1, #skills do
                    if ( name == skills[i] ) then
                        found = true;
                        break;
                    end
                end
                if ( not found and #skills > 0 ) then
                    self:PrintDebug("DELETE profession", name);
                    dbEntry:SetSubValue("Professions", name, nil);
                end
            end
        end

        self:Unlock(container);
    else
        self:PrintDebug("LOCKED", container);
    end
end

----------------------------------------------------------
-- Skills Internals
----------------------------------------------------------

function Armory:SetSkillHeaderState(headerValues, expanded)
    local isHeaderIndex = "2";
    local isExpandedIndex = "3";

    if ( headerValues[isHeaderIndex] and expanded ) then
        headerValues[isExpandedIndex] = 1;
    else
        headerValues[isExpandedIndex] = nil;
    end
end

function Armory:UpdateSkillHeaderState(index, state)
    local container = "Skills";
    local dbEntry = self.selectedDbBaseEntry;

    if ( index == 0 ) then
        for i = 1, dbEntry:GetNumValues(container) do
            self:SetSkillHeaderState(dbEntry:GetRawValue(container, i), state);
        end
    else
        if ( not self.skillLines ) then
            self:GetSkillLines();
        end
        if ( index > 0 and index <= table.getn(self.skillLines) ) then
            self:SetSkillHeaderState(dbEntry:GetRawValue(container, self.skillLines[index]), state);
        end
    end
end

function Armory:GetSkillLines()
    local container = "Skills";
    local dbEntry = self.selectedDbBaseEntry;
    local count = dbEntry:GetNumValues(container);
    local expanded = true;

    self.skillLines = {};
    for i = 1, count do
        local _, isHeader, isExpanded = dbEntry:GetValue(container, i);
        if ( isHeader ) then
            table.insert(self.skillLines, i);
            expanded = isExpanded;
        elseif ( expanded ) then
            table.insert(self.skillLines, i);
        end
    end

    return self.skillLines;
end

----------------------------------------------------------
-- Skills Interface
----------------------------------------------------------

function Armory:GetNumSkillLines()
    return table.getn(self:GetSkillLines());
end

function Armory:GetSkillLineInfo(index)
    if ( not self.skillLines ) then
        self:GetSkillLines();
    end
    if ( index > 0 and index <= table.getn(self.skillLines) ) then
        return self.selectedDbBaseEntry:GetValue("Skills", self.skillLines[index]);
    end
end

function Armory:ExpandSkillHeader(index)
    self:UpdateSkillHeaderState(index, true);
end

function Armory:CollapseSkillHeader(index)
    self:UpdateSkillHeaderState(index, false)
end

----------------------------------------------------------
-- Spells Storage
----------------------------------------------------------

function Armory:SetSpells()
    local container = "Spells";
    local dbEntry = self.playerDbBaseEntry;

    if ( not self:IsLocked(container) ) then
        self:Lock(container);

        self:PrintDebug("UPDATE", container);

        dbEntry:SetValue(container, nil);
        if ( self:HasSpellBook() ) then
            local numSkillLineTabs = _G.GetNumSpellTabs();
            local id;

            self:SetSpellValue(BOOKTYPE_SPELL, "NumTabs", numSkillLineTabs);
            for i = 1, numSkillLineTabs do
                local _, _, offset, numSpells = _G.GetSpellTabInfo(i);

                self:SetSpellValue(BOOKTYPE_SPELL, "Info"..i, _G.GetSpellTabInfo(i));
                for j = 1, numSpells do
                    id = j + offset;
                    self:SetSpellValue(BOOKTYPE_SPELL, "DisplayId"..id, _G.GetKnownSlotFromHighestRankSlot(id));
                    self:SetSpellValue(BOOKTYPE_SPELL, "AutoCast"..id, _G.GetSpellAutocast(id, BOOKTYPE_SPELL));
                    self:SetSpellValue(BOOKTYPE_SPELL, "Name"..id, _G.GetSpellName(id, BOOKTYPE_SPELL));
                    self:SetSpellValue(BOOKTYPE_SPELL, "Texture"..id, _G.GetSpellTexture(id, BOOKTYPE_SPELL));
                    self:SetSpellValue(BOOKTYPE_SPELL, "Link"..id, _G.GetSpellLink(id, BOOKTYPE_SPELL));
                end
            end

            if ( self:IsPersistentPet() ) then
                self:SelectPet(dbEntry, _G.UnitName("pet")):SetValue(container, nil);
                local numPetSpells = _G.HasPetSpells() or 0;
                for id = 1, numPetSpells do
                    self:SetSpellValue(BOOKTYPE_PET, "AutoCast"..id, _G.GetSpellAutocast(id, BOOKTYPE_PET));
                    self:SetSpellValue(BOOKTYPE_PET, "Name"..id, _G.GetSpellName(id, BOOKTYPE_PET));
                    self:SetSpellValue(BOOKTYPE_PET, "Texture"..id, _G.GetSpellTexture(id, BOOKTYPE_PET));
                    self:SetSpellValue(BOOKTYPE_PET, "Link"..id, _G.GetSpellLink(id, BOOKTYPE_PET));
                end
            end
        end

        self:Unlock(container);
    else
        self:PrintDebug("LOCKED", container);
    end
end

----------------------------------------------------------
-- Spells Internals
----------------------------------------------------------

function Armory:SetSpellValue(index, key, ...)
    local container = "Spells";
    local dbEntry = self.playerDbBaseEntry;

    if ( index == BOOKTYPE_PET ) then
        if ( self:IsPersistentPet() ) then
            self:SelectPet(dbEntry, _G.UnitName("pet")):SetSubValue(container, key, ...);
        end
    else
        dbEntry:SetSubValue(container, key, ...);
    end
end

function Armory:GetSpellValue(index, key)
    local container = "Spells";
    local dbEntry = self.selectedDbBaseEntry;

    if ( index == BOOKTYPE_PET ) then
        if ( self:PetExists(self:GetCurrentPet()) and self:SelectPet(dbEntry, self:GetCurrentPet()):Contains(container, key) ) then
            return self:SelectPet(dbEntry, self:GetCurrentPet()):GetSubValue(container, key);
        end
    elseif ( dbEntry:Contains(container, key) ) then
        return dbEntry:GetSubValue(container, key);
    end
end

----------------------------------------------------------
-- Spells Interface
----------------------------------------------------------

function Armory:GetKnownSlotFromHighestRankSlot(id)
    return self:GetSpellValue(BOOKTYPE_SPELL, "DisplayId"..id) or id;
end

function Armory:GetNumSpellTabs()
    return self:GetSpellValue(BOOKTYPE_SPELL, "NumTabs") or 0;
end

function Armory:GetSpellAutocast(id, bookType)
    if ( id and bookType ) then
        return self:GetSpellValue(bookType, "Autocast"..id);
    end
end

function Armory:GetSpellName(id, bookType)
    if ( id and bookType ) then
        return self:GetSpellValue(bookType, "Name"..id);
    end
end

function Armory:GetSpellLink(id, bookType)
    if ( id and bookType ) then
        return self:GetSpellValue(bookType, "Link"..id);
    end
end

function Armory:GetSpellTabInfo(spellTab)
    if ( spellTab ) then
        return self:GetSpellValue(BOOKTYPE_SPELL, "Info"..spellTab);
    end
end

function Armory:GetSpellTexture(id, bookType)
    if ( id and bookType ) then
        return self:GetSpellValue(bookType, "Texture"..id);
    end
end

function Armory:GetSpellTooltip(id, bookType)
    if ( id and bookType ) then
        return self:GetSpellValue(bookType, "Tooltip"..id);
    end
end

----------------------------------------------------------
-- Glyphs Storage
----------------------------------------------------------

function Armory:UpdateGlyphs()
    local container = "Glyphs";
    local dbEntry = self.playerDbBaseEntry;

    if ( not self:IsLocked(container) ) then
        self:Lock(container);

        self:PrintDebug("UPDATE", container);

        dbEntry:SetValue(container, {});
        for i = 1, ARMORY_NUM_GLYPH_SLOTS do
            dbEntry:SetSubValue(container, "Info"..i, _G.GetGlyphSocketInfo(i));
            dbEntry:SetSubValue(container, "Link"..i, _G.GetGlyphLink(i));
        end

        self:Unlock(container);
    else
        self:PrintDebug("LOCKED", container);
    end
end

----------------------------------------------------------
-- Glyphs Internals
----------------------------------------------------------

function Armory:GetGlyphValue(key)
    local dbEntry = self.selectedDbBaseEntry;
    return dbEntry:GetSubValue("Glyphs", key);
end

----------------------------------------------------------
-- Glyphs Interface
----------------------------------------------------------

function Armory:GetGlyphSocketInfo(id)
    return self:GetGlyphValue("Info"..id);
end

function Armory:GetGlyphLink(id)
    return self:GetGlyphValue("Link"..id);
end

----------------------------------------------------------
-- Talents Storage
----------------------------------------------------------

function Armory:SetTalents()
    local inspect = false;
    local pet = false;

    for i = 1, _G.GetNumTalentTabs(inspect, pet) do
       self:SetTalentValue(i, "Info", _G.GetTalentTabInfo(i, inspect, pet));
       self:SetTalentValue(i, "NumTalents", _G.GetNumTalents(i, inspect, pet));
       for j = 1, _G.GetNumTalents(i, inspect, pet) do
           self:SetTalentValue(i, "Info"..j, _G.GetTalentInfo(i, j, inspect, pet));
           self:SetTalentValue(i, "Prereqs"..j, _G.GetTalentPrereqs(i, j, inspect, pet));
           self:SetTalentValue(i, "Link"..j, _G.GetTalentLink(i, j, inspect, pet));
       end
    end
end

----------------------------------------------------------
-- Talents Internals
----------------------------------------------------------

function Armory:SelectTalent(baseEntry, index)
    local dbEntry = ArmoryDbEntry:new(baseEntry);
    dbEntry:SetPosition("Talents", index);
    return dbEntry;
end

function Armory:SetTalentValue(index, key, ...)
    self:SelectTalent(self.playerDbBaseEntry, index):SetValue(key, ...);
end

function Armory:GetTalentValue(index, key)
    local dbEntry = self.selectedDbBaseEntry;

    if ( dbEntry:Contains("Talents", index, key) ) then
        return self:SelectTalent(dbEntry, index):GetValue(key);
    end
end

----------------------------------------------------------
-- Talents Interface
----------------------------------------------------------

function Armory:GetNumTalentTabs(inspect, pet)
    return self.selectedDbBaseEntry:GetNumValues("Talents");
end

function Armory:GetNumTalents(index, inspect, pet)
    if ( index ) then
        return self:GetTalentValue(index, "NumTalents") or 0;
    end
end

function Armory:GetTalentTabInfo(index, inspect, pet)
    if ( index ) then
        return self:GetTalentValue(index, "Info");
    end
end

function Armory:GetTalentInfo(index, id, inspect, pet)
    if ( index and id ) then
        return self:GetTalentValue(index, "Info"..id);
    end
end

function Armory:GetTalentLink(index, id, inspect, pet)
    if ( index and id ) then
        return self:GetTalentValue(index, "Link"..id);
    end
end

function Armory:GetTalentPrereqs(index, id, inspect, pet)
    if ( index and id ) then
        return self:GetTalentValue(index, "Prereqs"..id);
    end
end

function Armory:GetTalentTooltip(index, id)
    if ( index and id ) then
        return self:GetTalentValue(index, "Tooltip"..id);
    end
end

----------------------------------------------------------
-- TradeSkills Storage
----------------------------------------------------------

function Armory:UpdateTradeSkill()
    local container = "SkillLines";
    local name, rank, maxRank;
    local toInvSlots = function(...)
    local slots = {};
        for i = 1, select("#", ...) do
            table.insert(slots, getglobal(select(i, ...)));
        end
        return unpack(slots);
    end;

    if ( not self:HasTradeSkills() ) then
        self:ClearProfessions();
        return;
    end

    name, rank, maxRank = _G.GetTradeSkillLine();
    if ( name and name ~= "UNKNOWN" and not self:IsLocked(container) ) then
        self:Lock(container);

        self:PrintDebug("UPDATE", name);

        self:SetProfessionValue(name, "Rank", rank, maxRank);
--      self:SetProfessionValue(name, "RepeatCount", _G.GetTradeskillRepeatCount());
        self:SetProfessionValue(name, "SubClasses", _G.GetTradeSkillSubClasses());
        self:SetProfessionValue(name, "InvSlots", _G.GetTradeSkillInvSlots());
        self:SetProfessionValue(name, "ListLink", _G.GetTradeSkillListLink());
        self:SetTradeSkills(name);

        self:Unlock(container);
    else
        self:PrintDebug("LOCKED", name);
    end
end

function Armory:SetTradeSkills(name)
    local container = "SkillLines";
    local dbEntry, data;
    local preserveState = {};
    local skillType, isHeader, isExpanded;

    if ( not name or name == "UNKNOWN" ) then
        self:PrintDebug("UNKNOWN trade skill");
        return;
    end
    
    dbEntry = self:SelectProfession(self.playerDbBaseEntry, name);

    -- preserve current state
    local button = getglobal("TradeSkillFrameAvailableFilterCheckButton");
    local subClasses = {_G.GetTradeSkillSubClasses()};
    local invSlots = {_G.GetTradeSkillInvSlots()};
    local state = { subClassFilter=0, invSlotFilter=0, makeable=false, index=_G.GetTradeSkillSelectionIndex(), collapsed={} };
    state.text, state.minLevel, state.maxLevel = self:GetTradeSkillItemFilter();
    if ( button ) then
        state.makeable = button:GetChecked();
    end
    for i = 0, #subClasses do
        if ( _G.GetTradeSkillSubClassFilter(i) ) then
            state.subClassFilter = i;
            break;
        end
    end
    for i = 0, #invSlots do
        if ( _G.GetTradeSkillInvSlotFilter(i) ) then
            state.invSlotFilter = i;
            break;
        end
    end

    if ( (state.minLevel or 0) ~= 0 or (state.maxLevel or 0) ~= 0 ) then
        _G.SetTradeSkillItemLevelFilter(0, 0);
    end
    if ( state.text and state.text ~= "" ) then
        _G.SetTradeSkillItemNameFilter(nil);
    end
    if ( state.subClassFilter > 0 ) then
        _G.SetTradeSkillSubClassFilter(0, 1, 1);
    end
    if ( state.invSlotFilter > 0 ) then
        _G.SetTradeSkillInvSlotFilter(0, 1, 1);
    end
    if ( state.makeable ) then
        _G.TradeSkillOnlyShowMakeable(nil);
    end
    
    for i = _G.GetNumTradeSkills(), 1, -1 do
        _, skillType, _, isExpanded = _G.GetTradeSkillInfo(i);
        isHeader = (skillType == "header");
        if ( isHeader and not isExpanded ) then
            table.insert(state.collapsed, i);
            _G.ExpandTradeSkillSubClass(i);
        end
    end

    -- retrieve slot types (would be to time consuming if put in funcAdditionalInfo)
    local invSlots = {_G.GetTradeSkillInvSlots()};
    local invSlotTypes = {};
    for i = 1, #invSlots do
        _G.SetTradeSkillInvSlotFilter(i, 1, 1);
        for id = 1, _G.GetNumTradeSkills() do
            name = _G.GetTradeSkillInfo(id);
            if ( invSlotTypes[name] ) then
                table.insert(invSlotTypes[name], invSlots[i]);
            else
                invSlotTypes[name] = {invSlots[i]};
            end
        end
    end
    _G.SetTradeSkillInvSlotFilter(0, 1, 1);

    if ( dbEntry:Contains(container) ) then
        for i = 1, table.getn(dbEntry:GetValue(container)) do
            name, skillType, _, isExpanded = dbEntry:GetValue(container, i);
            isHeader = (skillType == "header");
            if ( isHeader ) then
                -- name is more reliable than index
                preserveState[name] = isExpanded or 0;
            end
        end
    end

    local funcNumLines = _G.GetNumTradeSkills;
    local funcGetLineInfo = _G.GetTradeSkillInfo;
    local funcGetLineState =
        function(index)
            local _, skillType, _, isExpanded = _G.GetTradeSkillInfo(index);
            local isHeader = (skillType == "header");
            return isHeader, isExpanded;
        end;
    local funcAdditionalInfo =
        function(index)
            return {
                Description = _G.GetTradeSkillDescription,
                Cooldown =
                    function(index)
                        if ( _G.GetTradeSkillCooldown(index) ) then
                            return _G.GetTradeSkillCooldown(index), time();
                        end
                    end,
                Icon = _G.GetTradeSkillIcon,
                NumMade = _G.GetTradeSkillNumMade,
                NumReagents = _G.GetTradeSkillNumReagents,
                Reagents =
                    function(index)
                        local data = {};
                        for i = 1, _G.GetTradeSkillNumReagents(index) do
                            data["ReagentInfo"..i] = ArmoryDbEntry.Save(_G.GetTradeSkillReagentInfo(index, i));
                            data["ReagentItemLink"..i] = ArmoryDbEntry.Save(_G.GetTradeSkillReagentItemLink(index, i));
                        end
                        return data;
                    end,
                Tools = _G.GetTradeSkillTools,
                ItemLink = _G.GetTradeSkillItemLink,
                RecipeLink = _G.GetTradeSkillRecipeLink,
            };
        end

    -- store the complete (expanded) list
    dbEntry:SetExpandableListValues(container, funcNumLines, funcGetLineState, funcGetLineInfo, nil, nil, funcAdditionalInfo);

    -- restore state 
    table.sort(state.collapsed);
    for _, i in pairs(state.collapsed) do
        _G.CollapseTradeSkillSubClass(i);
    end

    if ( (state.minLevel or 0) ~= 0 or (state.maxLevel or 0) ~= 0 ) then
        _G.SetTradeSkillItemLevelFilter(state.minLevel, state.maxLevel);
    end
    if ( state.text and state.text ~= "" ) then
        _G.SetTradeSkillItemNameFilter(state.text);
    end
    if ( state.subClassFilter > 0 ) then
        _G.SetTradeSkillSubClassFilter(state.subClassFilter, 1, 1);
    end
    if ( state.invSlotFilter > 0 ) then
        _G.SetTradeSkillInvSlotFilter(state.invSlotFilter, 1, 1);
    end
    if ( state.makeable ) then
        _G.TradeSkillOnlyShowMakeable(state.makeable);
    end
    
    _G.SelectTradeSkill(state.index);

    for i = 1, dbEntry:GetNumValues(container) do
        data = dbEntry:GetRawValue(container, i);
        name = data["1"];
        data.InvSlot = invSlotTypes[name];
        if ( preserveState[name] ~= nil ) then
            self:SetTradeSkillHeaderState(data, preserveState[name] ~= 0);
        end
    end
end

----------------------------------------------------------
-- TradeSkills Internals
----------------------------------------------------------

hooksecurefunc("SetTradeSkillItemNameFilter", function(text)
    if ( not Armory:IsLocked("SkillLines") ) then
        Armory.tradeSkillItemNameFilter = text;
    end
end);

function Armory:GetTradeSkillItemFilter(text)
    if ( not text ) then
        text = self.tradeSkillItemNameFilter or "";
    end
    if ( text == SEARCH ) then
        text = "";
    end
    
    local minLevel, maxLevel;
    local approxLevel = strmatch(text, "^~(%d+)");
    if ( approxLevel ) then
        minLevel = approxLevel - 2;
        maxLevel = approxLevel + 2;
    else
        minLevel, maxLevel = strmatch(text, "^(%d+)%s*-*%s*(%d*)$");
    end
    if ( minLevel ) then
        if ( maxLevel == "" or maxLevel < minLevel ) then
            maxLevel = minLevel;
        end
        text = nil;
    else
        minLevel = 0;
        maxLevel = 0;
    end

    return text, minLevel, maxLevel;
end

function Armory:SetTradeSkillHeaderState(headerValues, expanded)
    local skillTypeIndex = "2";
    local isExpandedIndex = "4";

    if ( headerValues[skillTypeIndex] == "header" and expanded ) then
        headerValues[isExpandedIndex] = 1;
    else
        headerValues[isExpandedIndex] = nil;
    end
end

function Armory:UpdateTradeSkillHeaderState(index, state)
    local container = "SkillLines";
    local dbEntry = self:SelectProfession(self.selectedDbBaseEntry, self.selectedSkill);

    if ( index == 0 ) then
        for i = 1, dbEntry:GetNumValues(container) do
            self:SetTradeSkillHeaderState(dbEntry:GetRawValue(container, i), state);
        end
    else
        if ( not self.professionLines ) then
            self:GetProfessionLines();
        end
        if ( index > 0 and index <= table.getn(self.professionLines) ) then
            self:SetTradeSkillHeaderState(dbEntry:GetRawValue(container, self.professionLines[index]), state);
        end
    end

    self.professionLines = nil;
end

function Armory:GetProfessionLines()
    local container = "SkillLines";
    local dbEntry = self.selectedDbBaseEntry;
    local groups = {};
    local group = { id=0, expanded=true, included=true, items={} };
    local numReagents, oldPosition, names, isIncluded, itemMinLevel, invSlot;
    local hasFilter = self:HasTradeSkillFilter();

    self.professionLines = {};

    if ( dbEntry:Contains("Professions", self.selectedSkill, container) ) then
        dbEntry = self:SelectProfession(dbEntry, self.selectedSkill)

        -- apply filters
        for i = 1, dbEntry:GetNumValues(container) do
            local name, skillType, _, isExpanded = dbEntry:GetValue(container, i);
            if ( skillType == "header" ) then
                if ( self.tradeSkillSubClassFilter ) then
                    isIncluded = self.tradeSkillSubClassFilter[name];
                else
                    isIncluded = true;
                end
                group = { id=i, expanded=isExpanded, included=isIncluded, items={} };
                table.insert(groups, group);
             elseif ( group.included ) then
                numReagents = dbEntry:GetSubValue(container, i, "NumReagents") or 0;
                names = name or "";
                if ( numReagents > 0 and dbEntry:Contains(container, i, "Reagents") ) then
                    _, oldPosition = dbEntry:SetPosition(container, i, "Reagents");
                    for index = 1, numReagents do
                        names = names.."\t"..(dbEntry:GetValue("ReagentInfo"..index) or "");
                    end
                    dbEntry:ResetPosition(oldPosition);
                end

                invSlot = dbEntry:GetSubValue(container, i, "InvSlot");
                if ( self.tradeSkillInvSlotFilter ) then
                    if ( type(invSlot) == "table" ) then
                        isIncluded = false;
                        for _, slot in pairs(invSlot) do
                            if ( self.tradeSkillInvSlotFilter[slot] ) then
                                isIncluded = true;
                                break;
                            end
                        end
                    else
                        isIncluded = self.tradeSkillInvSlotFilter[invSlots];
                    end
                else
                    isIncluded = true;
                end
                if ( isIncluded and self.tradeSkillMinLevel > 0 and self.tradeSkillMaxLevel > 0 ) then
                    _, _, _, _, itemMinLevel = _G.GetItemInfo(dbEntry:GetSubValue(container, i, "ItemLink"));
                    isIncluded = itemMinLevel and itemMinLevel >= self.tradeSkillMinLevel and itemMinLevel <= self.tradeSkillMaxLevel;
                elseif ( isIncluded and not name or (self.tradeSkillFilter ~= "" and not string.find(strlower(names), strlower(self.tradeSkillFilter), 1, true)) ) then
                    isIncluded = false;
                end

                if ( isIncluded ) then
                    table.insert(group.items, i);
                end
             end
        end

        -- build the list
        if ( #groups == 0 ) then
            for _, id in ipairs(group.items) do
                table.insert(self.professionLines, id);
            end
        else
            for i = 1, #groups do
                if ( groups[i].included and (table.getn(groups[i].items) > 0 or not hasFilter) ) then
                    table.insert(self.professionLines, groups[i].id);
                    if ( groups[i].expanded ) then
                        for _, id in ipairs(groups[i].items) do
                            table.insert(self.professionLines, id);
                        end
                    end
                end
            end
        end
    end

    return self.professionLines;
end

function Armory:SelectProfession(baseEntry, name)
    local dbEntry = ArmoryDbEntry:new(baseEntry);
    if ( dbEntry:SetPosition("Professions", name) ) then
        -- new entry
        dbEntry:SetValue("Texture", self:FindSpellTexture(name));
    end
    return dbEntry;
end

function Armory:ClearProfessions()
    local dbEntry = self.playerDbBaseEntry;
    dbEntry:SetValue("Professions", nil);
end

function Armory:SetProfessionValue(name, key, ...)
    if ( name ~= "UNKNOWN" ) then
        self:SelectProfession(self.playerDbBaseEntry, name):SetValue(key, ...);
    end
end

function Armory:GetProfessionValue(key)
    local dbEntry = self.selectedDbBaseEntry;

    if ( dbEntry:Contains("Professions", self.selectedSkill, key) ) then
        return self:SelectProfession(dbEntry, self.selectedSkill):GetValue(key);
    end
end

function Armory:GetProfessionLineValue(index, key)
    local container = "SkillLines";
    local dbEntry = self.selectedDbBaseEntry;

    if ( not self.professionLines ) then
        self:GetProfessionLines();
    end

    if ( index > 0 and index <= table.getn(self.professionLines) ) then
        local id = self.professionLines[index];
        if ( dbEntry:Contains("Professions", self.selectedSkill, container) ) then
            dbEntry = self:SelectProfession(dbEntry, self.selectedSkill);
            if ( key ) then
                return dbEntry:GetSubValue(container, id, key);
            else
                return dbEntry:GetValue(container, id);
            end
        end
    end
end

function Armory:GetProfessionLineSubValue(index, key, subkey)
    local container = "SkillLines";
    local dbEntry = self.selectedDbBaseEntry;

    if ( not self.professionLines ) then
        self:GetProfessionLines();
    end

    if ( index > 0 and index <= table.getn(self.professionLines) ) then
        local id = self.professionLines[index];
        if ( dbEntry:Contains("Professions", self.selectedSkill, container, id, key, subkey) ) then
            dbEntry = self:SelectProfession(dbEntry, self.selectedSkill);
            dbEntry:SetPosition(container, id);
            return dbEntry:GetSubValue(key, subkey);
        end
    end
end

----------------------------------------------------------
-- TradeSkills Interface
----------------------------------------------------------

function Armory:GetProfessionTexture(name)
    local dbEntry = ArmoryDbEntry:new(self.selectedDbBaseEntry);
    local texture;

    if ( dbEntry:Contains("Professions", name, "Texture") ) then
        texture = self:SelectProfession(dbEntry, name):GetValue("Texture");
    end

    -- Note: Sometimes the name cannot be found because it differs from the spellbook (e.g. "Mining" vs "Smelting")
    if ( not texture ) then
        ----  Maybe we should solely rely on the table below...
        ----  Note: not all entries are relevant
        local tradeIcons = {};
        tradeIcons[ARMORY_TRADE_ALCHEMY] = "Trade_Alchemy";
        tradeIcons[ARMORY_TRADE_BLACKSMITHING] = "Trade_BlackSmithing";
        tradeIcons[ARMORY_TRADE_COOKING] = "INV_Misc_Food_15";
        tradeIcons[ARMORY_TRADE_ENCHANTING] = "Trade_Engraving";
        tradeIcons[ARMORY_TRADE_ENGINEERING] = "Trade_Engineering";
        tradeIcons[ARMORY_TRADE_FIRST_AID] = "Spell_Holy_SealOfSacrifice";
        tradeIcons[ARMORY_TRADE_FISHING] = "Trade_Fishing";
        tradeIcons[ARMORY_TRADE_HERBALISM] = "Trade_Herbalism";
        tradeIcons[ARMORY_TRADE_JEWELCRAFTING] = "INV_Misc_Gem_01";
        tradeIcons[ARMORY_TRADE_LEATHERWORKING] = "Trade_LeatherWorking";
        tradeIcons[ARMORY_TRADE_MINING] = "Trade_Mining";
        tradeIcons[ARMORY_TRADE_POISONS] = "Trade_BrewPoison";
        tradeIcons[ARMORY_TRADE_SKINNING] = "INV_Weapon_ShortBlade_01";
        tradeIcons[ARMORY_TRADE_TAILORING] = "Trade_Tailoring";
        tradeIcons[ARMORY_TRADE_INSCRIPTION] = "INV_Inscription_Tradeskill01";

        if ( tradeIcons[name] ) then
            texture = "Interface\\Icons\\"..tradeIcons[name];
        else
            texture = "Interface\\Icons\\INV_Misc_QuestionMark";
        end
    end

    return texture;
end

function Armory:GetNumProfessions()
    return table.getn(self.GetProfessionNames());
end

function Armory:GetProfessionNames()
    local data = self.selectedDbBaseEntry:GetValue("Professions");
    local list = {};

    if ( data ) then
        for name, _ in pairs(data) do
            table.insert(list, name);
        end
    end

    return list;
end

function Armory:GetNumTradeSkills()
    if ( not self.professionLines ) then
        self:GetProfessionLines();
    end
    return table.getn(self.professionLines);
end

function Armory:GetTradeSkillInfo(index)
    return self:GetProfessionLineValue(index);
end

function Armory:ExpandTradeSkillSubClass(index)
    self:UpdateTradeSkillHeaderState(index, true)
end

function Armory:CollapseTradeSkillSubClass(index)
    self:UpdateTradeSkillHeaderState(index, false)
end

function Armory:SetTradeSkillInvSlotFilter(index, onOff, exclusive)
    local dbEntry = self.selectedDbBaseEntry;
    local invSlots = {self:GetTradeSkillInvSlots()};

    if ( (index or 0) == 0 ) then
        self.tradeSkillInvSlotFilter = {};
        for i = 1, #invSlots do
            self.tradeSkillInvSlotFilter[invSlots[i]] = onOff;
        end
    elseif ( exclusive ) then
        for i = 1, #invSlots do
            if ( i == index ) then
                self.tradeSkillInvSlotFilter[invSlots[i]] = onOff;
            else
                self.tradeSkillInvSlotFilter[invSlots[i]] = not onOff;
            end
        end
    else
        self.tradeSkillInvSlotFilter[invSlots[index]] = onOff;
    end

    self:ExpandTradeSkillSubClass(0);
end

function Armory:GetTradeSkillInvSlotFilter(index)
    local invSlots = {self:GetTradeSkillInvSlots()};
    local checked = true;

    if ( (index or 0) == 0 ) then
        for i = 1, #invSlots do
            if ( not self.tradeSkillInvSlotFilter[invSlots[i]] ) then
                checked = false;
                break;
            end
        end
    else
        checked = self.tradeSkillInvSlotFilter[invSlots[index]];
    end

    return checked;
end

function Armory:SetTradeSkillSubClassFilter(index, onOff, exclusive)
    local subClasses = {self:GetTradeSkillSubClasses()};

    if ( (index or 0) == 0 ) then
        self.tradeSkillSubClassFilter = {};
        for i = 1, #subClasses do
            self.tradeSkillSubClassFilter[subClasses[i]] = onOff;
        end
    elseif ( exclusive ) then
        for i = 1, #subClasses do
            if ( i == index ) then
                self.tradeSkillSubClassFilter[subClasses[i]] = onOff;
            else
                self.tradeSkillSubClassFilter[subClasses[i]] = not onOff;
            end
        end
    else
        self.tradeSkillSubClassFilter[subClasses[index]] = onOff;
    end

    self:ExpandTradeSkillSubClass(0);
end

function Armory:GetTradeSkillSubClassFilter(index)
    local subClasses = {self:GetTradeSkillSubClasses()};
    local checked = true;

    if ( (index or 0) == 0 ) then
        for i = 1, #subClasses do
            if ( not self.tradeSkillSubClassFilter[subClasses[i]] ) then
                checked = false;
                break;
            end
        end
    else
        checked = self.tradeSkillSubClassFilter[subClasses[index]];
    end

    return checked;
end

function Armory:SetTradeSkillItemNameFilter(text)
    local refresh = (self.tradeSkillFilter ~= text);
    self.tradeSkillFilter = text;
    if ( refresh and self.professionLines ) then
        self:ExpandTradeSkillSubClass(0);
    end
    return refresh;
end

function Armory:GetTradeSkillItemNameFilter()
    return self.tradeSkillFilter;
end

function Armory:SetTradeSkillItemLevelFilter(minLevel, maxLevel)
    local refresh = (self.tradeSkillMinLevel ~= minLevel or self.tradeSkillMaxLevel ~= maxLevel);
    self.tradeSkillMinLevel = max(0, minLevel);
    self.tradeSkillMaxLevel = max(0, maxLevel);
    if ( refresh and self.professionLines ) then
        self:ExpandTradeSkillSubClass(0);
    end
    return refresh;
end

function Armory:GetTradeSkillItemLevelFilter()
    return self.tradeSkillMinLevel, self.tradeSkillMaxLevel;
end

function Armory:HasTradeSkillFilter()
    if ( not self:GetTradeSkillSubClassFilter(0) ) then
        return true;
    elseif ( not self:GetTradeSkillInvSlotFilter(0) ) then
        return true;
    elseif ( self.tradeSkillMinLevel > 0 and self.tradeSkillMaxLevel > 0 ) then
        return true;
    elseif ( self.tradeSkillFilter ~= "" ) then
        return true;
    end
    return false;
end

function Armory:SelectTradeSkill(index)
    self.selectedSkillLine = index;
end

function Armory:GetTradeSkillSelectionIndex()
    return self.selectedSkillLine;
end

function Armory:GetTradeSkillLine()
    if ( self.selectedSkill ) then
        local rank, maxRank = self:GetProfessionValue("Rank");
        return self.selectedSkill, rank, maxRank;
    else
        return "UNKNOWN", 0, 0;
    end
end

function Armory:GetFirstTradeSkill()
    if ( not self.professionLines ) then
        self:GetProfessionLines();
    end
    for i = 1, table.getn(self.professionLines) do
        local _, skillType = self:GetTradeSkillInfo(i);
        if ( skillType ~= "header" ) then
            return i;
        end
    end
    return 0;
end

function Armory:GetTradeskillRepeatCount()
    return self:GetProfessionValue("RepeatCount") or 0;
end

function Armory:GetTradeSkillSubClasses()
    return self:GetProfessionValue("SubClasses");
end

function Armory:GetTradeSkillInvSlots()
    return self:GetProfessionValue("InvSlots");
end

function Armory:GetTradeSkillListLink()
    return self:GetProfessionValue("ListLink");
end

function Armory:GetTradeSkillDescription(index)
    return self:GetProfessionLineValue(index, "Description");
end

function Armory:GetTradeSkillSpellFocus(index)
    return self:GetProfessionLineValue(index, "SpellFocus") or "";
end

function Armory:GetTradeSkillCooldown(index)
    local cooldown, timestamp = self:GetProfessionLineValue(index, "Cooldown");

    if ( cooldown ) then
        cooldown = cooldown - (time() - timestamp);
        if ( cooldown < 0 ) then
            cooldown = 0;
        end
    end
    return cooldown;
end

function Armory:GetTradeSkillIcon(index)
    return self:GetProfessionLineValue(index, "Icon") or nil;
end

function Armory:GetTradeSkillNumMade(index)
    local minMade, maxMade = self:GetProfessionLineValue(index, "NumMade");
    minMade = minMade or 0;
    maxMade = maxMade or 0;
    return minMade, maxMade;
end

function Armory:GetTradeSkillNumReagents(index)
    return self:GetProfessionLineValue(index, "NumReagents") or 0;
end

function Armory:GetTradeSkillTools(index)
    return self:GetProfessionLineValue(index, "Tools") or "";
end

function Armory:GetTradeSkillItemLink(index)
    return self:GetProfessionLineValue(index, "ItemLink");
end

function Armory:GetTradeSkillRecipeLink(index)
    return self:GetProfessionLineValue(index, "RecipeLink");
end

function Armory:GetTradeSkillReagentInfo(index, id)
    return self:GetProfessionLineSubValue(index, "Reagents", "ReagentInfo"..id);
end

function Armory:GetTradeSkillReagentItemLink(index, id)
    return self:GetProfessionLineSubValue(index, "Reagents", "ReagentItemLink"..id);
end

----------------------------------------------------------
-- Currency Storage
----------------------------------------------------------

function Armory:UpdateCurrency()
    local container = "Currency";
    local dbEntry = self.playerDbBaseEntry;
    local preserveState = {};
    local preserved = 0;
    local name, isHeader, isExpanded;

    if ( not self:IsLocked(container) ) then
        self:Lock(container);

        self:PrintDebug("UPDATE", container);

        -- preserve current header state
        if ( dbEntry:Contains(container) ) then
            for i = 1, table.getn(dbEntry:GetValue(container)) do
                name, isHeader, isExpanded = dbEntry:GetValue(container, i);
                if ( isHeader ) then
                    -- name is more reliable than index
                    preserveState[name] = isExpanded or 0;
                    preserved = preserved + 1;
                end
            end
        end

        -- store the complete (expanded) list
        local funcNumLines = _G.GetCurrencyListSize;
        local funcGetLineInfo = _G.GetCurrencyListInfo;
        local funcGetLineState = function(index)
            local _, isHeader, isExpanded = _G.GetCurrencyListInfo(index);
            return isHeader, isExpanded;
        end;
        local funcExpand = function(index) _G.ExpandCurrencyList(index, 1); end;
        local funcCollapse = function(index) _G.ExpandCurrencyList(index, 0); end;
        local funcAdditionalInfo =
                function(index)
                    return {
                        Tooltip =
                            function(index)
                                local _, _, _, _, _, _, extraCurrencyType = _G.GetCurrencyListInfo(index);
                                local tooltip;
                                if ( extraCurrencyType ~= 1 and extraCurrencyType ~= 2 ) then
                                    Armory:PrepareTooltip();
                                    Armory.tooltip:SetCurrencyToken(index);
                                    tooltip = Armory:Tooltip2Table(Armory.tooltip);
                                    Armory:ReleaseTooltip();
                                end
                                return tooltip;
                            end,
                    };
                end;

        dbEntry:SetExpandableListValues(container, funcNumLines, funcGetLineState, funcGetLineInfo, funcExpand, funcCollapse, funcAdditionalInfo);

        -- restore state
        if ( preserved > 0 ) then
            for i = 1, dbEntry:GetNumValues(container) do
                name = dbEntry:GetValue(container, i);
                if ( preserveState[name] ~= nil ) then
                   self:SetCurrencyHeaderState(dbEntry:GetRawValue(container, i), preserveState[name] ~= 0);
                end
            end
        end

        self:Unlock(container);
    else
        self:PrintDebug("LOCKED", container);
    end
end

----------------------------------------------------------
-- Currency Internals
----------------------------------------------------------

function Armory:GetCurrencyLineValue(index, key, subkey)
    if ( not self.currencyLines ) then
        self:GetCurrencyLines();
    end
    if ( index > 0 and index <= table.getn(self.currencyLines) ) then
        local dbEntry = ArmoryDbEntry:new(self.selectedDbBaseEntry);
        if ( not key ) then
            return dbEntry:GetValue("Currency", self.currencyLines[index]);
        else
            dbEntry:SetPosition("Currency", self.currencyLines[index]);
            if ( subkey ) then
                return dbEntry:GetSubValue(key, subkey);
            else
                return dbEntry:GetValue(key);
            end
        end
    end
end

function Armory:SetCurrencyHeaderState(headerValues, expanded)
    local isHeaderIndex = "2";
    local isExpandedIndex = "3";

    if ( headerValues[isHeaderIndex] and expanded ) then
        headerValues[isExpandedIndex] = 1;
    else
        headerValues[isExpandedIndex] = nil;
    end
end

function Armory:UpdateCurrencyHeaderState(index, state)
    local container = "Currency";
    local dbEntry = self.selectedDbBaseEntry;

    if ( index == 0 ) then
        for i = 1, dbEntry:GetNumValues(container) do
            self:SetCurrencyHeaderState(dbEntry:GetRawValue(container, i), state);
        end
    else
        if ( not self.currencyLines ) then
            self:GetCurrencyLines();
        end
        if ( index > 0 and index <= table.getn(self.currencyLines) ) then
            self:SetCurrencyHeaderState(dbEntry:GetRawValue(container, self.currencyLines[index]), state);
        end
    end
end

function Armory:GetCurrencyLines()
    local container = "Currency";
    local dbEntry = self.selectedDbBaseEntry;
    local count = dbEntry:GetNumValues(container);
    local expanded = true;

    self.currencyLines = {};
    for i = 1, count do
        local _, isHeader, isExpanded = dbEntry:GetValue(container, i);
        if ( isHeader ) then
            table.insert(self.currencyLines, i);
            expanded = isExpanded;
        elseif ( expanded ) then
            table.insert(self.currencyLines, i);
        end
    end

    return self.currencyLines;
end

----------------------------------------------------------
-- Currency Interface
----------------------------------------------------------

function Armory:GetCurrencyListSize()
    return table.getn(self:GetCurrencyLines());
end

function Armory:GetCurrencyListInfo(index)
    if ( not self.currencyLines ) then
        self:GetCurrencyLines();
    end
    if ( index > 0 and index <= table.getn(self.currencyLines) ) then
        return self.selectedDbBaseEntry:GetValue("Currency", self.currencyLines[index]);
    end
end

function Armory:ExpandCurrencyList(index, expand)
    self:UpdateCurrencyHeaderState(index, expand == 1);
end

function Armory:SetCurrencyToken(index)
    local tooltipLines = self:GetCurrencyLineValue(index, "Tooltip");
    if ( tooltipLines ) then
        self:Table2Tooltip(GameTooltip, tooltipLines);
        GameTooltip:Show();
    end
end


----------------------------------------------------------
-- Achievement Storage
----------------------------------------------------------

function Armory:UpdateAchievements(force)
    local container = "Achievements";
    local dbEntry = self.playerDbBaseEntry;

    if ( not self:HasAchievements() ) then
        dbEntry:SetValue(container, nil);
        return;
    end

    if ( not self:IsLocked(container) ) then
        self:Lock(container);
        
        self:PrintDebug("UPDATE", container);

        if ( not self.hasAchievements ) then
            self.hasAchievements = true;
            self.categories = {};
            self:GetCategoryList(self.categories, _G.GetCategoryList);
            self.achievementUpdater = ArmoryBackgroundUpdater:new();
            self.achievementCache = ArmoryDbEntry:new({});
        end

        local updater = self.achievementUpdater;
        local dbCache = self.achievementCache;
        
        if ( force ) then
            dbEntry:SetValue(container, {});
            for _, category in ipairs(self.categories) do
                for i = 1, _G.GetCategoryNumAchievements(category.id) do
                    self:UpdateAchievement(category.id, i);
                end
            end
            self:Unlock(container);
        else
            self.achievementsDirty = true;
            updater:Start(
                function(updater)
                    while ( self.achievementsDirty ) do
                        local start = time();
                        self.achievementsDirty = false;
                        for _, category in ipairs(self.categories) do
                            for i = 1, _G.GetCategoryNumAchievements(category.id) do
                                self:UpdateAchievement(category.id, i, dbCache);
                                updater:Suspend();
                            end
                        end
                        dbEntry:SetValue(container, {});
                        self:CopyTable(dbCache.db, dbEntry.db);
                        self:PrintDebug(container, "updated in", time() - start, "s.");
                    end
                    self:Unlock(container);
                end
            );
         end
    else
        self.achievementsDirty = true;
        self:PrintDebug("LOCKED", container);
    end
end

function Armory:UpdateAchievement(achievementId, index, dbEntry)
    if ( not self:HasAchievements() ) then
        return;
    elseif ( not dbEntry ) then
        dbEntry = self.playerDbBaseEntry;
    end

    self:GetTotalAchievementPoints();

    local id, completed, month, day, year;
    if ( not index ) then -- Blizz does it like this...
        id, _, _, completed, month, day, year = _G.GetAchievementInfo(achievementId);
    else
        id, _, _, completed, month, day, year = _G.GetAchievementInfo(achievementId, index);
    end
    if ( not id ) then
        return;
    end
        
    local container = "Achievements";
    local key = tostring(id);
    local quantity = 0;
    local totalQuantity = 0;
    local started;

    if ( not completed ) then
        for i = 1, _G.GetAchievementNumCriteria(id) do
            local _, criteriaType, completed, quantityNumber, reqQuantity, _, flags, assetId = _G.GetAchievementCriteriaInfo(id, i);
            if ( criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetId ) then
                _, _, _, completed = _G.GetAchievementInfo(assetId);
                totalQuantity = totalQuantity + 1;
                if ( completed ) then
                    quantity = quantity + 1;
                    started = true;
                end
            elseif ( bit.band(flags, ACHIEVEMENT_CRITERIA_PROGRESS_BAR) == ACHIEVEMENT_CRITERIA_PROGRESS_BAR ) then
                totalQuantity = totalQuantity + reqQuantity;
                quantity = quantity + quantityNumber;
                if ( quantityNumber > 0 ) then
                    started = true;
                end
            elseif ( completed ) then
                totalQuantity = totalQuantity + 1;
                quantity = quantity + 1;
                started = true;
            else
                totalQuantity = totalQuantity + 1;
            end
        end
    end
    
    if ( completed or started ) then
        dbEntry:SetSubValue(container, key, index, _G.GetAchievementLink(id), completed, self:MakeDate(day, month, year), quantity, totalQuantity);
    end
end

function Armory:UpdateStatistics(force)
    local container = "Statistics";
    local dbEntry = self.playerDbBaseEntry;

    if ( not self:HasAchievements() ) then
        dbEntry:SetValue(container, nil);
        return;
    end

    if ( not self:IsLocked(container) ) then
        self:Lock(container);
        
        self:PrintDebug("UPDATE", container);
        
        if ( not self.hasStatistics ) then
            self.hasStatistics = true;
            self.statisticCategories = {};
            self:GetCategoryList(self.statisticCategories, _G.GetStatisticsCategoryList);
            self.statisticUpdater = ArmoryBackgroundUpdater:new();
            self.statisticCache = ArmoryDbEntry:new({});
        end

        local updater = self.statisticUpdater;
        local dbCache = self.statisticCache;

        if ( force ) then
            local id, quantity;
            dbEntry:SetValue(container, {});
            for _, category in ipairs(self.statisticCategories) do
                for i = 1, _G.GetCategoryNumAchievements(category.id) do
                    id = _G.GetAchievementInfo(category.id, i);
                    quantity = _G.GetStatistic(id);
                    if ( quantity and quantity ~= "--" ) then
                        dbEntry:SetSubValue(container, tostring(id), i, quantity);
                    end
                end
            end
            self:Unlock(container);
        else
            self.statisticDirty = true;
            updater:Start(
                function(updater)
                    local id, quantity;
                    while ( self.statisticDirty ) do
                        local start = time();
                        self.statisticDirty = false;
                        for _, category in ipairs(self.statisticCategories) do
                            for i = 1, _G.GetCategoryNumAchievements(category.id) do
                                id = _G.GetAchievementInfo(category.id, i);
                                quantity = _G.GetStatistic(id);
                                if ( quantity and quantity ~= "--" ) then
                                    dbCache:SetSubValue(container, tostring(id), i, quantity);
                                end
                                updater:Suspend();
                            end
                        end
                        dbEntry:SetValue(container, {});
                        self:CopyTable(dbCache.db, dbEntry.db);
                        self:PrintDebug(container, "updated in", time() - start, "s.");
                    end
                    self:Unlock(container);
                end
            );
        end
    else
        self.statisticDirty = true;
        self:PrintDebug("LOCKED", container);
    end
end

----------------------------------------------------------
-- Achievement Internals
----------------------------------------------------------

function Armory:GetCategoryList(categories, categoryAccessor)
    local cats = categoryAccessor();
    local parent;
    
    for _, id in ipairs(cats) do
        _, parent = _G.GetCategoryInfo(id);
        if ( parent == -1 ) then
            table.insert(categories, { id=id });
        end
    end

    for i = #cats, 1, -1 do 
        _, parent = _G.GetCategoryInfo(cats[i]);
        for j, category in ipairs(categories) do
            if ( category.id == parent ) then
                table.insert(categories, j+1, { id=cats[i], parent=category.id });
            end
        end
    end
end

function Armory:GetAchievementLines()
    local container = "Achievements";
    local dbEntry = self.selectedDbBaseEntry;
    local achievements = {};

    self.achievementLines = {};
    
    if ( dbEntry:Contains(container) ) then
        for _, category in ipairs(self.categories) do
            achievements[tostring(category.id)] = {};
        end

        local index, link, completed, date;
        for id in pairs(dbEntry:GetValue(container)) do
            index, link, completed, date, quantity, reqQuantity = dbEntry:GetSubValue(container, id);
            table.insert(achievements[tostring(_G.GetAchievementCategory(id))], {id=id, order=index, link=link, completed=completed, date=date, quantity=quantity, reqQuantity=reqQuantity});
        end
        
        for _, achievement in pairs(achievements) do
            table.sort(achievement, function(a, b) return a.order < b.order end);
        end
        
        local counts = {};
        local numAchievements;
        for _, category in ipairs(self.categories) do
            numAchievements = table.getn(achievements[tostring(category.id)]);
            counts[tostring(category.id)] = (counts[tostring(category.id)] or 0) + numAchievements;
            if ( category.parent ) then
                counts[tostring(category.parent)] = (counts[tostring(category.parent)] or 0) + numAchievements;
            end
        end
     
        local collapsed = false;
        local childCollapsed = false;
        local name, include;
        for _, category in ipairs(self.categories) do
            if ( counts[tostring(category.id)] > 0 ) then
                name = _G.GetCategoryInfo(category.id);
                if ( category.parent ) then
                    if ( not collapsed ) then
                        table.insert(self.achievementLines, {name=name, id=category.id, isHeader=true, isChild=true, collapsed=category.collapsed});
                    end
                    childCollapsed = collapsed or category.collapsed;
                else
                    table.insert(self.achievementLines, {name=name, id=category.id, isHeader=true, collapsed=category.collapsed});
                    collapsed = category.collapsed;
                    childCollapsed = false;
                end
                if ( not (collapsed or childCollapsed) ) then
                    for _, achievement in ipairs(achievements[tostring(category.id)]) do
                        _, name = _G.GetAchievementInfo(achievement.id);
                        if ( self.achievementFilter == "" ) then
                            include = true;
                        else
                            include = string.find(strlower(name), strlower(self.achievementFilter), 1, true);
                        end
                        if ( include ) then
                            table.insert(self.achievementLines, {name=name, id=achievement.id, link=achievement.link, completed=achievement.completed, date=achievement.date, quantity=achievement.quantity, reqQuantity=achievement.reqQuantity});
                        end
                    end
                end
            end
        end
    end
        
    return self.achievementLines;
end

function Armory:GetStatisticLines()
    local container = "Statistics";
    local dbEntry = self.selectedDbBaseEntry;
    local statistics = {};

    self.statisticLines = {};
    
    if ( dbEntry:Contains(container) ) then
        for _, category in ipairs(self.statisticCategories) do
            statistics[tostring(category.id)] = {};
        end

        local index, quantity;
        for id in pairs(dbEntry:GetValue(container)) do
            index, quantity = dbEntry:GetSubValue(container, id);
            table.insert(statistics[tostring(_G.GetAchievementCategory(id))], {id=id, order=index, quantity=quantity});
        end
        
        for _, statistic in pairs(statistics) do
            table.sort(statistic, function(a, b) return a.order < b.order end);
        end
        
        local counts = {};
        local numStatistics;
        for _, category in ipairs(self.statisticCategories) do
            numStatistics = table.getn(statistics[tostring(category.id)]);
            counts[tostring(category.id)] = (counts[tostring(category.id)] or 0) + numStatistics;
            if ( category.parent ) then
                counts[tostring(category.parent)] = (counts[tostring(category.parent)] or 0) + numStatistics;
            end
        end
     
        local collapsed = false;
        local childCollapsed = false;
        local name, include;
        for _, category in ipairs(self.statisticCategories) do
            if ( counts[tostring(category.id)] > 0 ) then
                name = _G.GetCategoryInfo(category.id);
                if ( category.parent ) then
                    if ( not collapsed ) then
                        table.insert(self.statisticLines, {name=name, id=category.id, isHeader=true, isChild=true, collapsed=category.collapsed});
                    end
                    childCollapsed = collapsed or category.collapsed;
                else
                    table.insert(self.statisticLines, {name=name, id=category.id, isHeader=true, collapsed=category.collapsed});
                    collapsed = category.collapsed;
                    childCollapsed = false;
                end
                if ( not (collapsed or childCollapsed) ) then
                    for _, statistic in ipairs(statistics[tostring(category.id)]) do
                        _, name = _G.GetAchievementInfo(statistic.id);
                        if ( self.achievementFilter == "" ) then
                            include = true;
                        else
                            include = string.find(strlower(name), strlower(self.achievementFilter), 1, true);
                        end
                        if ( include ) then
                            table.insert(self.statisticLines, {name=name, id=statistic.id, quantity=statistic.quantity});
                        end
                    end
                end
            end
        end
    end
        
    return self.statisticLines;
end

function Armory:SetAchievementHeaderState(isAchievement, index, collapsed)
    local categories, line;
    
    if ( isAchievement ) then
        categories = self.categories;
        line = self.achievementLines[index];
    else
        categories = self.statisticCategories;
        line = self.statisticLines[index];
    end

    for _, category in ipairs(categories) do
        if ( index == 0 ) then
            category.collapsed = collapsed;
        elseif ( category.id == line.id ) then
            category.collapsed = collapsed;
            break;
        end
    end
end

----------------------------------------------------------
-- Achievement Interface
----------------------------------------------------------

function Armory:GetNumAchievements()
    return table.getn(self:GetAchievementLines());
end

function Armory:GetAchievementInfo(index)
    if ( not self.achievementLines ) then
        self:GetAchievementLines();
    end
    if ( index > 0 and index <= table.getn(self.achievementLines) ) then
        local line = self.achievementLines[index];
        return line.name, line.isHeader, line.isChild, line.collapsed, line.link, line.completed, line.date, line.quantity, line.reqQuantity;
    end
end

function Armory:ExpandAchievementHeader(isAchievement, index)
    self:SetAchievementHeaderState(isAchievement, index, false);
end

function Armory:CollapseAchievementHeader(isAchievement, index)
    self:SetAchievementHeaderState(isAchievement, index, true);
end

function Armory:GetNumStatistics()
    return table.getn(self:GetStatisticLines());
end

function Armory:GetStatisticInfo(index)
    if ( not self.statisticLines ) then
        self:GetStatisticLines();
    end
    if ( index > 0 and index <= table.getn(self.statisticLines) ) then
        local line = self.statisticLines[index];
        return line.name, line.isHeader, line.isChild, line.collapsed, line.quantity;
    end
end

function Armory:SetAchievementFilter(text)
    local refresh = (self.achievementFilter ~= text);
    self.achievementFilter = text;
    return refresh;
end

function Armory:GetAchievementFilter()
    return self.achievementFilter;
end