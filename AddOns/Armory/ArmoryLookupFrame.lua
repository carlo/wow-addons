--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmoryLookupFrame.lua,v 1.12, 2008-11-11 10:16:30Z, Maxim Baars$
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

ARMORY_LOOKUP_LINES_DISPLAYED = 19;
ARMORY_LOOKUP_HEIGHT = 16;

ARMORY_LOOKUP_SEPARATOR = "\n";
ARMORY_LOOKUP_FIELD_SEPARATOR = "\r";
ARMORY_LOOKUP_CONTENT_SEPARATOR = "\f";

ARMORY_LOOKUP_SKILLS = {
    ARMORY_TRADE_ALCHEMY = "AL",
    ARMORY_TRADE_BLACKSMITHING = "BS",
    ARMORY_TRADE_COOKING = "CO",
    ARMORY_TRADE_ENCHANTING = "EC",
    ARMORY_TRADE_ENGINEERING = "EG",
    --ARMORY_TRADE_FIRST_AID = "FA",
    ARMORY_TRADE_JEWELCRAFTING = "JC",
    ARMORY_TRADE_LEATHERWORKING = "LW",
    --ARMORY_TRADE_POISONS = "PO", 
    ARMORY_TRADE_TAILORING = "TA",
    ARMORY_TRADE_INSCRIPTION = "IN",
};

ARMORY_LOOKUP_TYPE = { LOOKUP_RECIPE = "R", LOOKUP_QUEST = "Q", LOOKUP_CHARACTER = "C", LOOKUP_DOWNLOAD = "D" };

function ArmoryLookupFrame_Toggle()
    if ( ArmoryLookupFrame:IsShown() ) then
        HideUIPanel(ArmoryLookupFrame);
    elseif ( Armory:HasDataSharing() ) then
        ShowUIPanel(ArmoryLookupFrame);
    else
        Armory:PrintTitle(ARMORY_LOOKUP_DISABLED);
    end
end

function ArmoryLookupFrame_OnLoad(self)
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("PLAYER_TARGET_CHANGED");
    self:RegisterEvent("PLAYER_GUILD_UPDATE");
    self:RegisterEvent("RAID_ROSTER_UPDATE");
    self:RegisterEvent("PARTY_MEMBERS_CHANGED");

    self:SetAttribute("UIPanelLayout-defined", true);
    self:SetAttribute("UIPanelLayout-enabled", true);
    self:SetAttribute("UIPanelLayout-area", "left");
    self:SetAttribute("UIPanelLayout-pushable", 5);
    self:SetAttribute("UIPanelLayout-whileDead", true);

    table.insert(UISpecialFrames, "ArmoryLookupFrame");

    SetPortraitToTexture("ArmoryLookupFramePortrait", "Interface\\Icons\\INV_Misc_QuestionMark");

    ArmoryDropDownMenu_Initialize(ArmoryLookupChannelDropDown, ArmoryLookupChannelDropDown_Initialize);
    ArmoryDropDownMenu_SetWidth(ArmoryLookupChannelDropDown, 75);

    ArmoryDropDownMenu_Initialize(ArmoryLookupTradeSkillDropDown, ArmoryLookupTradeSkillDropDown_Initialize);
    ArmoryDropDownMenu_SetWidth(ArmoryLookupTradeSkillDropDown, 115);
    ArmoryDropDownMenu_SetSelectedValue(ArmoryLookupTradeSkillDropDown, "ARMORY_TRADE_ENCHANTING");

    ArmoryDropDownMenu_Initialize(ArmoryLookupQuestDropDown, ArmoryLookupQuestDropDown_Initialize);
    ArmoryDropDownMenu_SetWidth(ArmoryLookupQuestDropDown, 115);
    ArmoryDropDownMenu_SetSelectedID(ArmoryLookupQuestDropDown, 1);

    ArmoryDropDownMenu_Initialize(ArmoryLookupTypeDropDown, ArmoryLookupTypeDropDown_Initialize);
    ArmoryDropDownMenu_SetWidth(ArmoryLookupTypeDropDown, 90);
    ArmoryDropDownMenu_SetSelectedValue(ArmoryLookupTypeDropDown, ARMORY_LOOKUP_TYPE.LOOKUP_RECIPE);

    FauxScrollFrame_SetOffset(ArmoryLookupScrollFrame, 0);
    ArmoryLookupScrollFrameScrollBar:SetMinMaxValues(0, 0); 
    ArmoryLookupScrollFrameScrollBar:SetValue(0);

    ArmoryLookupFrameEditBox:SetText(SEARCH);

    ArmoryAddonMessageFrame_RegisterHandlers(ArmoryLookupFrame_CheckResponse, ArmoryLookupFrame_ProcessRequest);
end

function ArmoryLookupFrame_OnEvent(self, event, ...)
    if ( not Armory:CanHandleEvents() ) then
        return;
    elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        self.data = {};
        self.type = ARMORY_LOOKUP_TYPE.LOOKUP_RECIPE;
    elseif ( event == "PLAYER_TARGET_CHANGED" ) then
        if ( ArmoryLookupFrame_IsTargetSelected() and self.type == ARMORY_LOOKUP_TYPE.LOOKUP_CHARACTER ) then
            ArmoryLookupFrameEditBox:SetText(UnitName("target"));
        end
    end

    if ( event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_GUILD_UPDATE"
          or event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" ) then
        ArmoryCloseDropDownMenus();
        ArmoryDropDownMenu_Initialize(ArmoryLookupChannelDropDown, ArmoryLookupChannelDropDown_Initialize);
        ArmoryLookupFrame_UpdateLookupButton();
    end
end

function ArmoryLookupFrame_OnUpdate(self, elapsed)
    ArmoryLookupFrame_UpdateTarget();
end

function ArmoryLookupFrame_OnShow(self)
    if ( self.type == ARMORY_LOOKUP_TYPE.LOOKUP_RECIPE ) then
        ArmoryLookupTradeSkillDropDown:Show();
        ArmoryLookupQuestDropDown:Hide();
        ArmoryLookupFrameSearchExactCheckButton:Show();
        ArmoryLookupFrameTitleText:SetText(ARMORY_LOOKUP_SKILL);
    elseif ( self.type == ARMORY_LOOKUP_TYPE.LOOKUP_QUEST ) then
        ArmoryLookupTradeSkillDropDown:Hide();
        ArmoryLookupQuestDropDown:Show();
        ArmoryLookupFrameSearchExactCheckButton:Show();
        ArmoryLookupFrameTitleText:SetText(ARMORY_LOOKUP_QUEST);
    else
        ArmoryLookupTradeSkillDropDown:Hide();
        ArmoryLookupQuestDropDown:Hide();
        ArmoryLookupFrameSearchExactCheckButton:Hide();
        ArmoryLookupFrameTitleText:SetText(ARMORY_LOOKUP_CHARACTER);
    end
    ArmoryLookupFrame_UpdateLookupButton();
    ArmoryLookupFrame_Update();
end

function ArmoryLookupFrameButton_OnClick(self)
    local id = self:GetID();

    if ( IsModifiedClick("CHATLINK") and self.link ) then
        HandleModifiedItemClick(self.link);
    elseif ( id > 0 ) then
        local item = ArmoryLookupFrame.data[id];
        item.isExpanded = not item.isExpanded;
        ArmoryLookupFrame_Update();
    end
end

function ArmoryLookupExpandAllButton_OnClick(self)
    if ( self.collapsed ) then
        self.collapsed = nil;
    else
        self.collapsed = 1;
        ArmoryLookupScrollFrameScrollBar:SetValue(0);
    end
    for _, item in ipairs(ArmoryLookupFrame.data) do
        item.isExpanded = not self.collapsed;
    end
    ArmoryLookupFrame_Update();
end

function ArmoryLookupFrameButton_OnEnter(self)
    if ( self.link ) then
        GameTooltip:SetHyperlink(self.link);
    end
end

function ArmoryLookupFrame_OnTextChanged(self)
    ArmoryLookupFrame_UpdateLookupButton();
end

function ArmoryLookupFrame_OnChar(self, text)
    local pattern = "(["..strjoin("%", ARMORY_MESSAGE_SEPARATOR, ARMORY_LOOKUP_SEPARATOR, ARMORY_LOOKUP_FIELD_SEPARATOR, ARMORY_LOOKUP_CONTENT_SEPARATOR).."])";
    if ( text:match(pattern) ) then
        self:SetText(self:GetText():gsub(pattern, "", 1));
    end
end

function ArmoryLookupFrame_OnEnter(self)
    if ( ArmoryLookupButton:IsEnabled() == 1 ) then
        ArmoryLookupButton_OnClick(ArmoryLookupButton);
    end
end

function ArmoryLookupChannelDropDown_Initialize()
    local info = ArmoryDropDownMenu_CreateInfo();
    local value = ArmoryDropDownMenu_GetSelectedValue(ArmoryLookupChannelDropDown) or "NONE";
    local numChannels = 0;
    local checked;

    local channels = {
        TARGET = ArmoryLookupFrame_IsTargetSelected,
        GUILD = function() return IsInGuild() end,
        RAID = function() return GetNumRaidMembers() > 0 end,
        PARTY = function() return GetNumPartyMembers() > 0 end
    };

    info.func = ArmoryLookupChannelDropDown_OnClick;
    info.owner = ARMORY_DROPDOWNMENU_OPEN_MENU;

    for channel, enable in pairs(channels) do
        if ( enable() ) then
            info.text = getglobal(channel);
            info.value = channel;
            if ( channel == value ) then
                info.checked = 1;
                checked = value;
            else
                info.checked = nil;
            end
            ArmoryDropDownMenu_AddButton(info);
            numChannels = numChannels + 1;
        end
    end

    if ( numChannels == 0 ) then
        info.text = NONE;
        info.value = "NONE";
        info.checked = 1;
        ArmoryDropDownMenu_AddButton(info);
    end

    if ( checked ) then
        ArmoryDropDownMenu_SetSelectedValue(ArmoryLookupChannelDropDown, checked);
    else
        ArmoryDropDownMenu_SetSelectedValue(ArmoryLookupChannelDropDown, ArmoryDropDownMenu_GetValue(1));
    end

    ArmoryLookupChannelDropDown.numChannels = numChannels;
end

function ArmoryLookupChannelDropDown_OnClick(self)
    ArmoryDropDownMenu_SetSelectedValue(ArmoryLookupChannelDropDown, self.value);
    ArmoryLookupFrame_UpdateTarget();
end

function ArmoryLookupTradeSkillDropDown_Initialize()
    local info = ArmoryDropDownMenu_CreateInfo();
    local skills = {};

    info.func = ArmoryLookupTradeSkillDropDown_OnClick;
    info.owner = ARMORY_DROPDOWNMENU_OPEN_MENU;

    for skill in pairs(ARMORY_LOOKUP_SKILLS) do
        table.insert(skills, skill);
    end
    table.sort(skills, function(a, b) return getglobal(a) < getglobal(b) end);

    for _, skill in ipairs(skills) do
        info.text = getglobal(skill);
        info.value = skill;
        info.checked = nil;
        ArmoryDropDownMenu_AddButton(info);
    end
end

function ArmoryLookupTradeSkillDropDown_OnClick(self)
    ArmoryDropDownMenu_SetSelectedValue(ArmoryLookupTradeSkillDropDown, self.value);
end

function ArmoryLookupQuestDropDown_Initialize()
    local info = ArmoryDropDownMenu_CreateInfo();

    info.func = ArmoryLookupQuestDropDown_OnClick;
    info.owner = ARMORY_DROPDOWNMENU_OPEN_MENU;

    info.text = ARMORY_LOOKUP_QUEST_NAME;
    info.checked = nil;
    ArmoryDropDownMenu_AddButton(info);

    info.text = ARMORY_LOOKUP_QUEST_AREA;
    info.checked = nil;
    ArmoryDropDownMenu_AddButton(info);
end

function ArmoryLookupQuestDropDown_OnClick(self)
    ArmoryDropDownMenu_SetSelectedID(ArmoryLookupQuestDropDown, self:GetID());
end

function ArmoryLookupTypeDropDown_Initialize()
    local info = ArmoryDropDownMenu_CreateInfo();

    info.func = ArmoryLookupTypeDropDown_OnClick;
    info.owner = ARMORY_DROPDOWNMENU_OPEN_MENU;

    info.text = SKILLS;
    info.value = ARMORY_LOOKUP_TYPE.LOOKUP_RECIPE;
    info.checked = nil;
    ArmoryDropDownMenu_AddButton(info);

    info.text = QUESTS_LABEL;
    info.value = ARMORY_LOOKUP_TYPE.LOOKUP_QUEST; 
    info.checked = nil;
    ArmoryDropDownMenu_AddButton(info);

    info.text = CHARACTER;
    info.value = ARMORY_LOOKUP_TYPE.LOOKUP_CHARACTER;
    info.checked = nil;
    ArmoryDropDownMenu_AddButton(info);
end

function ArmoryLookupTypeDropDown_OnClick(self)
    local text = ArmoryLookupFrameEditBox:GetText();

    ArmoryLookupFrameEditBox:ClearFocus();
    ArmoryDropDownMenu_SetSelectedValue(ArmoryLookupTypeDropDown, self.value);
    if ( self.value ~= ArmoryLookupFrame.type ) then
        ArmoryLookupFrame.data = {};
        ArmoryLookupFrame.type = self.value;
        if ( self.value == ARMORY_LOOKUP_TYPE.LOOKUP_CHARACTER and text == SEARCH ) then
            if ( ArmoryLookupFrame_IsTargetSelected() ) then
                text = UnitName("target");
            else
                text = NAME;
            end
        elseif ( text == NAME ) then
            text = SEARCH;
        end
        ArmoryLookupFrameEditBox:SetText(text);
        ArmoryLookupFrame_OnShow(ArmoryLookupFrame);
    end
end

function ArmoryLookupButton_OnClick(self)
    ArmoryLookupFrame_SendRequest();
end

function ArmoryLookupFrame_UpdateTarget()
    local channel = ArmoryDropDownMenu_GetSelectedValue(ArmoryLookupChannelDropDown) or "NONE";
    local onlinecount = 0;
    local online;
    if ( channel == "TARGET" and UnitExists("target") ) then
        ArmoryLookupFrameTargetText:SetText(UnitName("target"));
    elseif ( channel == "GUILD" ) then
        GuildRoster();
        for i = 1, GetNumGuildMembers() do
            _, _, _, _, _, _, _, _, online = GetGuildRosterInfo(i);
            if ( online ) then
                onlinecount = onlinecount + 1;
            end
        end
        ArmoryLookupFrameTargetText:SetFormattedText(GUILD_TOTAL, onlinecount);
    elseif ( channel == "RAID" ) then
        ArmoryLookupFrameTargetText:SetFormattedText(NUM_RAID_MEMBERS, GetNumRaidMembers());
    elseif ( channel == "PARTY" ) then
        ArmoryLookupFrameTargetText:SetText("");
    else
        ArmoryLookupFrameTargetText:SetText(ERR_GENERIC_NO_TARGET);
    end
end

function ArmoryLookupFrame_UpdateLookupButton()
    local text = ArmoryLookupFrameEditBox:GetText();

    if ( text ~= SEARCH and text ~= NAME and strlen(text) > 0 and ArmoryLookupChannelDropDown.numChannels > 0 ) then
        ArmoryLookupButton:Enable();    
    else
        ArmoryLookupButton:Disable();
    end
end

function ArmoryLookupFrame_Update()
    local lines = {};
    for i, item in ipairs(ArmoryLookupFrame.data) do
        table.insert(lines, {mainIndex=i});
        if ( item.isExpanded ) then
            for j = 1, table.getn(item.values) do
                table.insert(lines, {mainIndex=i, valueIndex=j});
            end
        end
    end

    local numLines = #lines;
    local offset = FauxScrollFrame_GetOffset(ArmoryLookupScrollFrame);

    if ( offset > numLines ) then
        offset = 0;
        FauxScrollFrame_SetOffset(ArmoryLookupScrollFrame, offset);
    end

    -- ScrollFrame update
    FauxScrollFrame_Update(ArmoryLookupScrollFrame, numLines, ARMORY_LOOKUP_LINES_DISPLAYED, ARMORY_LOOKUP_HEIGHT);

    for i = 1, ARMORY_LOOKUP_LINES_DISPLAYED do
        local lineIndex = i + offset;
        local lineButton = getglobal("ArmoryLookupLine"..i);
        local lineButtonText = getglobal("ArmoryLookupLine"..i.."Text");
        local lineButtonHighlight = getglobal("ArmoryLookupLine"..i.."Highlight");

        if ( lineIndex <= numLines ) then
            local indices = lines[lineIndex];
            local item = ArmoryLookupFrame.data[indices.mainIndex];
            local isHeader = (not indices.valueIndex);
            local color, text;
            if ( isHeader ) then
                lineButton:SetID(indices.mainIndex);
            else
                item = item.values[indices.valueIndex];
                lineButton:SetID(0);
            end
            lineButton.link = item.link;
            if ( item.link ) then
                color = item.link:match("^(|c%x+)|H");
            end
            text = (color or HIGHLIGHT_FONT_COLOR_CODE)..item.name..FONT_COLOR_CODE_CLOSE;
            if ( item.mine ) then
                text = text..GREEN_FONT_COLOR_CODE.."*"..FONT_COLOR_CODE_CLOSE;
            end
            lineButton:SetText(text);

            -- Set button widths if scrollbar is shown or hidden
            if ( ArmoryLookupScrollFrame:IsShown() ) then
                lineButtonText:SetWidth(265);
            else
                lineButtonText:SetWidth(285);
            end
            lineButton:Show();

            if ( isHeader ) then
                if ( item.isExpanded ) then
                    lineButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
                else
                    lineButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
                end
                lineButtonHighlight:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
                lineButton:UnlockHighlight();
            else
                lineButton:SetNormalTexture("");
                lineButtonHighlight:SetTexture("");
            end
        else
            lineButton:Hide();
        end
    end

    -- Set the expand/collapse all button texture
    local numHeaders = 0;
    local notExpanded = 0;
    -- Somewhat redundant loop, but cleaner than the alternatives
    for i = 1, numLines do
        local item = ArmoryLookupFrame.data[lines[i].mainIndex];
        local isHeader = (not lines[i].valueIndex);
        if ( isHeader ) then
            numHeaders = numHeaders + 1;
            if ( not item.isExpanded ) then
                notExpanded = notExpanded + 1;
            end
        end
    end
    -- If all headers are not expanded then show collapse button, otherwise show the expand button
    if ( notExpanded ~= numHeaders ) then
        ArmoryLookupExpandAllButton.collapsed = nil;
        ArmoryLookupExpandAllButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
    else
        ArmoryLookupExpandAllButton.collapsed = 1;
        ArmoryLookupExpandAllButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
    end
end

function ArmoryLookupFrame_IsTargetSelected()
    return UnitExists("target") and UnitIsFriend("player", "target") and UnitIsPlayer("target");
end

function ArmoryLookupFrame_SendRequest()
    local channel = ArmoryDropDownMenu_GetSelectedValue(ArmoryLookupChannelDropDown);
    local search = ArmoryLookupFrameEditBox:GetText();
    local exact = 0;
    local id = ArmoryLookupFrame.type;
    local version, message;

    if ( ArmoryLookupFrameSearchExactCheckButton:GetChecked() ) then
        exact = 1;
    end

    ArmoryLookupFrame.data = {};
    ArmoryLookupFrame_Update();

    if ( id == ARMORY_LOOKUP_TYPE.LOOKUP_RECIPE ) then
        local skill = ArmoryDropDownMenu_GetSelectedValue(ArmoryLookupTradeSkillDropDown);
        version = "1";
        message = strjoin(ARMORY_LOOKUP_SEPARATOR, ARMORY_LOOKUP_SKILLS[skill], exact, search);
    elseif ( id == ARMORY_LOOKUP_TYPE.LOOKUP_QUEST ) then
        version = "1";
        message = strjoin(ARMORY_LOOKUP_SEPARATOR, exact, search, ArmoryDropDownMenu_GetSelectedID(ArmoryLookupQuestDropDown));
    elseif ( id == ARMORY_LOOKUP_TYPE.LOOKUP_CHARACTER ) then
        version = "1";
        message = search;
    else
        return;
    end

    ArmoryAddonMessageFrame_CreateRequest(id, version, message, channel);
end

function ArmoryLookupFrame_SendDownloadRequest(guild)
    local id = ARMORY_LOOKUP_TYPE.LOOKUP_DOWNLOAD;
    local version = "2";
    local message = guild;
    local channel = "GUILD";

    ArmoryAddonMessageFrame_CreateRequest(id, version, message, channel);
end

function ArmoryLookupFrame_ProcessRequest(id, version, message, msgNumber, sender, channel)
    local findFunc, arg1;
    local exact, search 

    if ( id == ARMORY_LOOKUP_TYPE.LOOKUP_RECIPE ) then
        Armory:PrintCommunication(ARMORY_LOOKUP_SKILL);
        if ( version ~= "1" ) then
            Armory:PrintCommunication(string.format(ARMORY_LOOKUP_IGNORED, ARMORY_IGNORE_REASON_VERSION));
            return;
        end

        findFunc = ArmoryLookupFrame_FindRecipe;

        local skill;
        skill, exact, search = strsplit(ARMORY_LOOKUP_SEPARATOR, message);

        if ( skill == ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_ALCHEMY ) then
            arg1 = ARMORY_TRADE_ALCHEMY;
        elseif ( skill == ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_BLACKSMITHING ) then
            arg1 = ARMORY_TRADE_BLACKSMITHING;
        elseif ( skill == ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_COOKING ) then
            arg1 = ARMORY_TRADE_COOKING;
        elseif ( skill == ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_ENCHANTING ) then
            arg1 = ARMORY_TRADE_ENCHANTING;
        elseif ( skill == ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_ENGINEERING ) then
            arg1 = ARMORY_TRADE_ENGINEERING;
        elseif ( skill == ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_JEWELCRAFTING ) then
            arg1 = ARMORY_TRADE_JEWELCRAFTING;
        elseif ( skill == ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_LEATHERWORKING ) then
            arg1 = ARMORY_TRADE_LEATHERWORKING;
        elseif ( skill == ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_POISONS ) then
            arg1 = ARMORY_TRADE_POISONS;
        elseif ( skill == ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_TAILORING ) then
            arg1 = ARMORY_TRADE_TAILORING;
        elseif ( skill == ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_INSCRIPTION ) then
            arg1 = ARMORY_TRADE_INSCRIPTION;
        end

        if ( not arg1 ) then
            Armory:PrintDebug("unknown skill", skill);
            return;
        end

    elseif ( id == ARMORY_LOOKUP_TYPE.LOOKUP_QUEST ) then
        Armory:PrintCommunication(ARMORY_LOOKUP_QUEST);
        if ( version ~= "1" ) then
            Armory:PrintCommunication(string.format(ARMORY_LOOKUP_IGNORED, ARMORY_IGNORE_REASON_VERSION));
            return;
        end

        findFunc = ArmoryLookupFrame_FindQuest;
        exact, search, arg1 = strsplit(ARMORY_LOOKUP_SEPARATOR, message);

    elseif ( id == ARMORY_LOOKUP_TYPE.LOOKUP_CHARACTER ) then
        Armory:PrintCommunication(ARMORY_LOOKUP_CHARACTER);
        if ( version ~= "1" ) then
            Armory:PrintCommunication(string.format(ARMORY_LOOKUP_IGNORED, ARMORY_IGNORE_REASON_VERSION));
            return;
        end

        findFunc = ArmoryLookupFrame_InspectCharacter;
        search = message; --character name

    elseif ( id == ARMORY_LOOKUP_TYPE.LOOKUP_DOWNLOAD ) then
        Armory:PrintCommunication(ARMORY_LOOKUP_SKILL);
        if ( version ~= "1" and version ~= "2" ) then
            Armory:PrintCommunication(string.format(ARMORY_LOOKUP_IGNORED, ARMORY_IGNORE_REASON_VERSION));
            return;
        end

        findFunc = ArmoryLookupFrame_DownloadRecipes;
        search = message; --guild

    else
        return;

    end

    local lookup = search;
    if ( exact == "1" ) then
        lookup = "'"..lookup.."'";
    end
    if ( arg1 ) then
        lookup = arg1..":"..lookup;
    end
    Armory:PrintCommunication(string.format(ARMORY_LOOKUP_REQUEST_DETAIL, lookup));

    local currentProfile = Armory:CurrentProfile();
    local values;

    message = "";

    for _, profile in ipairs(Armory:Profiles()) do
        Armory:SelectProfile(profile);
        if ( ArmoryLookupFrame_CanShare(profile, channel) ) then
            values = findFunc(exact, search, arg1);
            if ( #values > 0 ) then
                if ( message ~= "" ) then
                    message = message..ARMORY_LOOKUP_SEPARATOR;
                end
                message = message..(profile.character..ARMORY_LOOKUP_FIELD_SEPARATOR..table.concat(values, ARMORY_LOOKUP_FIELD_SEPARATOR));
            end
        end
    end
    Armory:SelectProfile(currentProfile);

    if ( message ~= "" ) then
        ArmoryAddonMessageFrame_Send(id, version, message, "TARGET:"..sender, msgNumber);
        Armory:PrintCommunication(string.format(ARMORY_LOOKUP_RESPONSE_SENT, sender));
    end
end

function ArmoryLookupFrame_CanShare(profile, channel)
    if ( not Armory.messaging ) then
        return true; 
    elseif ( profile.realm ~= Armory.playerRealm ) then
        return false;
    elseif ( profile.character ~= Armory.player and not (Armory:GetConfigShareAsAlt("player") and Armory:GetConfigShareAsAlt()) ) then
        return false;
    elseif ( Armory:GetConfigShareAll() ) then
        return true;
    elseif ( channel == "GUILD" and Armory:GetConfigShareGuild() and Armory:GetGuildInfo("player") == GetGuildInfo("player") ) then
        return true;
    else
        return (profile.character == Armory.player);
    end
end

function ArmoryLookupFrame_FindRecipe(exact, search, arg1)
    local dbEntry = Armory.selectedDbBaseEntry;
    local skillName, skillType, ref, link; 
    local refType = "enchant";
    local result = {};

    if ( Armory:GetConfigShareProfessions() and dbEntry:Contains("Professions", arg1) ) then
        dbEntry = ArmoryDbEntry:new(dbEntry:GetValue("Professions", arg1));

        local container = "SkillLines";
        local numEntries = dbEntry:GetNumValues(container);
        for i = 1, numEntries do
            skillName, skillType = dbEntry:GetValue(container, i);
            if ( skillType ~= "header" and ArmoryLookupFrame_IsMatch(skillName, search, exact) ) then
                link = dbEntry:GetSubValue(container, i, "RecipeLink");
                if ( link ) then
                    ref = link:match("|H"..refType..":(%d+)|h");
                    if ( ref ) then
                        table.insert(result, ref);
                    end
                end
            end
        end
    end

    if ( #result > 0 ) then
        table.insert(result, 1, refType);
    end

    return result;
end

function ArmoryLookupFrame_FindQuest(exact, search, arg1)
    local dbEntry = Armory.selectedDbBaseEntry;
    local container = "Quests";

    local name, isHeader;
    local refType = "quest";
    local result = {};

    local addRef = function(result, link, refType)
        if ( link ) then
            local ref = link:match("|H"..refType..":([-%d:]+)|h");
            if ( ref ) then
                table.insert(result, ref);
            end
        end
    end;

    arg1 = arg1 or "1";

    if ( Armory:GetConfigShareQuests() and dbEntry:Contains(container) ) then
        local numEntries = table.getn(dbEntry:GetValue(container));
        local questIndex = 1;
        while ( questIndex <= numEntries ) do
            name, _, _, _, isHeader = dbEntry:GetValue(container, questIndex);
            if ( arg1 == "2" ) then
                -- area (header)
                if ( isHeader and ArmoryLookupFrame_IsMatch(name, search, exact) ) then
                    repeat
                        questIndex = questIndex + 1;
                        name, _, _, _, isHeader = dbEntry:GetValue(container, questIndex);
                        if ( not isHeader ) then
                            addRef(result, dbEntry:GetSubValue(container, questIndex, "Link"), refType);
                        end
                    until ( isHeader or questIndex > numEntries )
                    questIndex = questIndex - 1;
                end
            elseif ( not isHeader and ArmoryLookupFrame_IsMatch(name, search, exact) ) then
                -- name
                addRef(result, dbEntry:GetSubValue(container, questIndex, "Link"), refType);
            end
            questIndex = questIndex + 1;
        end
    end

    if ( #result > 0 ) then
        table.insert(result, 1, refType);
    end

    return result;
end

function ArmoryLookupFrame_InspectCharacter(exact, search, arg1)
    local result = {};

    if ( Armory:GetConfigShareCharacter() and strlower(Armory.character) == strlower(search) ) then
        local refType = "item";
        local items = {refType};
        local link, ref;
        for i = 1, 19 do
            link = Armory:GetInventoryItemLink("player", i);
            if ( link ) then
                ref = link:match("|H"..refType..":([-%d:]+)|h");
            end
            if ( link and ref ) then
                items[i+1] = ref;
            else
                items[i+1] = "";
            end
        end
        table.insert(result, table.concat(items, ARMORY_LOOKUP_CONTENT_SEPARATOR));

        refType = "talent";
        local talents = {};
        local tab = {};
        for i = 1, Armory:GetNumTalentTabs(true, false) do
            local name, _, pointsSpent = Armory:GetTalentTabInfo(i, true, false);
            tab[i] = name..":"..pointsSpent;
            for j = 1, Armory:GetNumTalents(i, true, false) do
                local _, _, _, _, rank, maxRank = Armory:GetTalentInfo(i, j, true, false);
                if ( rank and rank > 0 ) then
                    link = Armory:GetTalentLink(i, j, true, false);
                    if ( link ) then
                        ref = link:match("|H"..refType..":([-%d:]+)|h");
                        if ( ref ) then
                            table.insert(talents, strjoin(";", ref, rank, maxRank));
                        end
                    end
                end
            end
        end

        if ( #talents > 0 ) then
            table.insert(talents, 1, table.concat(tab, " "));
            table.insert(talents, 2, refType);
        end
        table.insert(result, table.concat(talents, ARMORY_LOOKUP_CONTENT_SEPARATOR));
    end

    return result;
end

function ArmoryLookupFrame_DownloadRecipes(exact, search, arg1)
    local dbEntry = Armory.selectedDbBaseEntry;
    local result = {};

    if ( search == Armory:GetGuildInfo("player") and dbEntry:Contains("Professions") ) then
        for profession in pairs(dbEntry:GetValue("Professions")) do
            local skill, recipes;

            if ( profession == ARMORY_TRADE_ALCHEMY ) then
                skill = ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_ALCHEMY;
            elseif ( profession == ARMORY_TRADE_BLACKSMITHING ) then
                skill = ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_BLACKSMITHING;
            elseif ( profession == ARMORY_TRADE_COOKING ) then
                skill = ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_COOKING;
            elseif ( profession == ARMORY_TRADE_ENCHANTING ) then
                skill = ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_ENCHANTING;
            elseif ( profession == ARMORY_TRADE_ENGINEERING ) then
                skill = ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_ENGINEERING;
            elseif ( profession == ARMORY_TRADE_FIRST_AID ) then
                skill = ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_FIRST_AID;
            elseif ( profession == ARMORY_TRADE_JEWELCRAFTING ) then
                skill = ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_JEWELCRAFTING;
            elseif ( profession == ARMORY_TRADE_LEATHERWORKING ) then
                skill = ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_LEATHERWORKING;
            elseif ( profession == ARMORY_TRADE_POISONS ) then
                skill = ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_POISONS;
            elseif ( profession == ARMORY_TRADE_TAILORING ) then
                skill = ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_TAILORING;
            elseif ( profession == ARMORY_TRADE_INSCRIPTION ) then
                skill = ARMORY_LOOKUP_SKILLS.ARMORY_TRADE_INSCRIPTION;
            end

            if ( skill ) then
                recipes = ArmoryLookupFrame_FindRecipe(nil, "", profession);
                if ( #recipes > 0 ) then
                    table.insert(recipes, 1, skill);
                    table.insert(result, table.concat(recipes, ARMORY_LOOKUP_CONTENT_SEPARATOR));
                end
            end
        end
    end

    return result;
end

function ArmoryLookupFrame_CheckResponse()
    for _, id in pairs(ARMORY_LOOKUP_TYPE) do
        ArmoryLookupFrame_ProcessResponse(id);
    end
end

function ArmoryLookupFrame_ProcessResponse(id)
    local module = ArmoryAddonMessageFrame_GetModule(id);
    local data = ArmoryLookupFrame.data;
    local sets, version, fields, values, owner, name, ref, index, link, refType;
    local sort, update, mine;

    for sender, reply in pairs(module.replies) do
        sets = Armory:StringSplit(ARMORY_LOOKUP_SEPARATOR, reply.message);
        for _, set in ipairs(sets) do
            fields = Armory:StringSplit(ARMORY_LOOKUP_FIELD_SEPARATOR, set);
            if ( id == ARMORY_LOOKUP_TYPE.LOOKUP_DOWNLOAD and reply.version == "2" ) then
                -- set: owner\nAL\fenchant\f1234\f3264\f5353\nEN\fenchant\f8262\f7265
                if ( ArmoryGuildRecipes_ProcessResponse ) then
                    for i = 2, #fields do
                        ArmoryGuildRecipes_ProcessResponse(sender, fields[1], Armory:StringSplit(ARMORY_LOOKUP_CONTENT_SEPARATOR, fields[i]));
                    end
                end

            elseif ( id == ARMORY_LOOKUP_TYPE.LOOKUP_CHARACTER and reply.version == "1" ) then
                -- owner\n(1)\n(2)
                -- (1) (19 items) item\f18821:0:0:0:0:0:0:0\f31333:0:0:0:0:0:0:1443794188
                values = ArmoryLookupFrame_ParseCharacterEquipment(fields[2]);
                table.insert(data, {name=ARMORY_EQUIPMENT, values=values});

                -- (2) (talents) tab1 (1) / tab2 (20) / tab3 (40)\ftalent\f14113\f31244\f31226
                name, values = ArmoryLookupFrame_ParseCharacterTalents(fields[3]);
                if ( #values > 0 ) then
                    table.insert(data, {name=name, values=values});
                end
                update = true;

            elseif ( reply.version == "1" ) then
                -- owner\nenchant\n1234\n3264\n5353
                -- owner\nquest\n2323:70\n2432:70
                owner = fields[1];
                mine = (owner == UnitName("player"));
                if ( owner ~= sender ) then
                    owner = sender.." ["..owner.."]";
                elseif ( mine ) then
                    owner = owner..GREEN_FONT_COLOR_CODE.."*"..FONT_COLOR_CODE_CLOSE;
                end
                refType = fields[2];
                for i = 3, #fields do
                    ref = fields[i];
                    if ( ref ) then
                        index = ArmoryLookupFrame_GetData(ref);
                        if ( not index ) then
                            name, link = Armory:GetInfoFromId(refType, ref);
                            if ( name ) then
                                table.insert(data, {id=ref, name=name, link=link, values={{name=owner}}, mine=mine});
                                sort = true;
                            else
                                Armory:PrintDebug("couldn't determine name", ref, owner);
                            end
                        else
                            table.insert(data[index].values, {name=owner});
                            table.sort(data[index].values, function(a, b) return a.name < b.name end);
                        end
                    end
                end
                update = true;

            end
        end
        ArmoryAddonMessageFrame_RemoveReply(module, sender);
    end

    if ( sort ) then        
        table.sort(data, function(a, b) return a.name < b.name end);
    end

    if ( update ) then
        ArmoryLookupFrame_Update();
    end
end

function ArmoryLookupFrame_ParseCharacterEquipment(fields)
    local slots = {HEADSLOT, NECKSLOT, SHOULDERSLOT, SHIRTSLOT, CHESTSLOT, WAISTSLOT, LEGSSLOT, FEETSLOT, WRISTSLOT, HANDSSLOT, 
                   FINGER0SLOT, FINGER1SLOT, TRINKET0SLOT, TRINKET1SLOT, BACKSLOT, MAINHANDSLOT, SECONDARYHANDSLOT, RANGEDSLOT, TABARDSLOT};

    local values = Armory:StringSplit(ARMORY_LOOKUP_CONTENT_SEPARATOR, fields);
    local refType = values[1];
    local result = {};

    for i = 2, #values do
        local name, link = Armory:GetInfoFromId(refType, values[i]);
        if ( name ) then
            table.insert(result, {id=values[i], name=name.." "..GRAY_FONT_COLOR_CODE..slots[i-1], link=link});
        end
    end

    return result;
end

function ArmoryLookupFrame_ParseCharacterTalents(fields)
    local values = Armory:StringSplit(ARMORY_LOOKUP_CONTENT_SEPARATOR, fields);
    local build = values[1];
    local refType = values[2];
    local result = {};

    for i = 3, #values do
        local ref, rank, maxRank = strsplit(";", values[i]);
        local name, link = Armory:GetInfoFromId(refType, ref);
        if ( name ) then
            table.insert(result, {id=ref, name=string.format("%s (%s/%s)", name, rank, maxRank), link=link});
        end
    end

    return build, result;
end

function ArmoryLookupFrame_GetData(id)
    for i, item in ipairs(ArmoryLookupFrame.data) do
        if ( id == item.id ) then
            return i;
        end
    end
end

function ArmoryLookupFrame_IsMatch(name, search, exact)
    if ( exact == "1" ) then
        return Armory:FindNameParts(name, 1, search);
    end
    return Armory:FindNameParts(name, 1, strsplit(" ", search));
end

function ArmoryLookupFrame_StartDownload(...)
    local loaded = IsAddOnLoaded(ARMORY_SHARE_DOWNLOAD_ADDON);
    local reason;

    if ( not loaded ) then
        loaded, reason = LoadAddOn(ARMORY_SHARE_DOWNLOAD_ADDON);
        --if ( not loaded and reason == "DISABLED" ) then
            --EnableAddOn(ARMORY_SHARE_DOWNLOAD_ADDON);
            --loaded, reason = LoadAddOn(ARMORY_SHARE_DOWNLOAD_ADDON);
        --end
    end

    if ( loaded ) then
        ArmoryGuildRecipes_Prepare(ArmoryLookupFrame_SendDownloadRequest);
    elseif ( reason ) then
        Armory:PrintTitle(string.format(ARMORY_SHARE_DOWNLOAD_LOADERROR, getglobal("ADDON_"..reason)));
    end
end
