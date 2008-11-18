--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmorySpellBookFrame.lua,v 1.7, 2008-10-12 18:25:01Z, Maxim Baars$
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

ARMORY_SPELLBOOK_PAGENUMBERS = {};

function ArmoryToggleSpellBook(bookType)
    if ( ( bookType == INSCRIPTION and Armory:UnitLevel("player") < SHOW_INSCRIPTION_LEVEL ) or ( not Armory:HasPetSpells() and bookType == BOOKTYPE_PET ) ) then
	    return;
    end

    local isShown = ArmorySpellBookFrame:IsShown();
    if ( isShown ) then
        ArmorySpellBookFrame.suppressCloseSound = true;
    end
    
    HideUIPanel(ArmorySpellBookFrame);
    if ( (not isShown or (ArmorySpellBookFrame.bookType ~= bookType)) ) then
        ArmorySpellBookFrame.bookType = bookType;
        ArmoryCloseChildWindows();
        ShowUIPanel(ArmorySpellBookFrame);
    end
    ArmorySpellBookFrame_UpdatePages();
    
    ArmorySpellBookFrame.suppressCloseSound = nil;
end

function ArmorySpellBookFrame_OnLoad(self)
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("SPELLS_CHANGED");
    self:RegisterEvent("PET_BAR_UPDATE");

    self.bookType = BOOKTYPE_SPELL;
end

function ArmorySpellBookFrame_OnEvent(self, event, ...)
    if ( not Armory:CanHandleEvents() ) then
        return;
    elseif ( event == "PLAYER_ENTERING_WORLD") then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
    end
    Armory:Execute(ArmorySpellBookFrame_UpdateSpells);
end

function ArmorySpellBookFrame_UpdateSpells()
    Armory:SetSpells();
    ArmorySpellBookFrame_Update();
end

function ArmorySpellBookFrame_OnShow(self)
    -- Init page nums
    ARMORY_SPELLBOOK_PAGENUMBERS[1] = 1;
    ARMORY_SPELLBOOK_PAGENUMBERS[2] = 1;
    ARMORY_SPELLBOOK_PAGENUMBERS[3] = 1;
    ARMORY_SPELLBOOK_PAGENUMBERS[4] = 1;
    ARMORY_SPELLBOOK_PAGENUMBERS[5] = 1;
    ARMORY_SPELLBOOK_PAGENUMBERS[6] = 1;
    ARMORY_SPELLBOOK_PAGENUMBERS[7] = 1;
    ARMORY_SPELLBOOK_PAGENUMBERS[8] = 1;
    ARMORY_SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] = 1;

    -- Set to the first tab by default
    ArmorySpellBookSkillLineTab_OnClick(nil, 1);

    ArmorySpellBookFrame_PlayOpenSound();
    ArmorySpellBookFrame_Update(true);
end

function ArmorySpellBookFrame_Update(showing)
    local hasPetSpells, petToken = Armory:HasPetSpells();
    hasPetSpells = hasPetSpells and Armory:HasPetUI();
    if ( not hasPetSpells and ArmorySpellBookFrame.bookType == BOOKTYPE_PET ) then
        ArmorySpellBookFrame.bookType = BOOKTYPE_SPELL;
    end

    -- Hide all tabs
    ArmorySpellBookFrameTabButton1:Hide();
    ArmorySpellBookFrameTabButton2:Hide();
    ArmorySpellBookFrameTabButton3:Hide();

    -- Setup skillline tabs
    if ( showing ) then
        ArmorySpellBookSkillLineTab_OnClick(nil, ArmorySpellBookFrame.selectedSkillLine);
    end

    local numSkillLineTabs = Armory:GetNumSpellTabs();
    local name, texture, offset, numSpells;
    local skillLineTab;
    for i = 1, MAX_SKILLLINE_TABS do
        skillLineTab = getglobal("ArmorySpellBookSkillLineTab"..i);
        if ( i <= numSkillLineTabs and ArmorySpellBookFrame.bookType == BOOKTYPE_SPELL ) then
            name, texture = Armory:GetSpellTabInfo(i);
            skillLineTab:SetNormalTexture(texture);
            skillLineTab.tooltip = name;
            skillLineTab:Show();

            -- Set the selected tab
            if ( ArmorySpellBookFrame.selectedSkillLine == i ) then
                skillLineTab:SetChecked(1);
            else
                skillLineTab:SetChecked(nil);
            end
        else
            skillLineTab:Hide();
        end
    end

    -- Setup tabs
    ArmorySpellBookFrame.petTitle = nil;
    if ( hasPetSpells ) then
        ArmorySpellBookFrame_SetTabType(ArmorySpellBookFrameTabButton1, BOOKTYPE_SPELL);
        ArmorySpellBookFrame_SetTabType(ArmorySpellBookFrameTabButton2, BOOKTYPE_PET, petToken);
        ArmorySpellBookFrame_SetTabType(ArmorySpellBookFrameTabButton3, INSCRIPTION);
    else
        ArmorySpellBookFrame_SetTabType(ArmorySpellBookFrameTabButton1, BOOKTYPE_SPELL);
        
        if ( Armory:UnitLevel("player") >= SHOW_INSCRIPTION_LEVEL ) then
            ArmorySpellBookFrame_SetTabType(ArmorySpellBookFrameTabButton2, INSCRIPTION);
        end

        if ( ArmorySpellBookFrame.bookType == BOOKTYPE_PET ) then
            -- if has no pet spells but trying to show the pet spellbook close the window;
            HideUIPanel(ArmorySpellBookFrame);
            ArmorySpellBookFrame.bookType = BOOKTYPE_SPELL;
        end
    end
    if ( ArmorySpellBookFrame.bookType == BOOKTYPE_SPELL ) then
        ArmorySpellBookTitleText:SetText(SPELLBOOK);
        ArmorySpellBookFrame_ShowSpells();
        ArmorySpellBookFrame_HideGlyphFrame();
        ArmorySpellBookFrame_UpdatePages();
    elseif ( ArmorySpellBookFrame.bookType == BOOKTYPE_PET ) then
        ArmorySpellBookTitleText:SetText(ArmorySpellBookFrame.petTitle);
        ArmorySpellBookFrame_ShowSpells();
        ArmorySpellBookFrame_HideGlyphFrame();
        ArmorySpellBookFrame_UpdatePages();
    else
        ArmorySpellBookTitleText:SetText(INSCRIPTION);
        ArmorySpellBookFrame_HideSpells();
        ArmorySpellBookFrame_ShowGlyphFrame();
    end
end

function ArmorySpellBookFrame_HideSpells()
    for i = 1, SPELLS_PER_PAGE do
        getglobal("ArmorySpellButton" .. i):Hide();
    end

    for i = 1, MAX_SKILLLINE_TABS do
        getglobal("ArmorySpellBookSkillLineTab" .. i):Hide();
    end

    ArmorySpellBookPrevPageButton:Hide();
    ArmorySpellBookNextPageButton:Hide();
    ArmorySpellBookPageText:Hide();
end

function ArmorySpellBookFrame_ShowSpells()
    for i = 1, SPELLS_PER_PAGE do
        getglobal("ArmorySpellButton" .. i):Show();
    end

    ArmorySpellBookPrevPageButton:Show();
    ArmorySpellBookNextPageButton:Show();
    ArmorySpellBookPageText:Show();
end

function ArmorySpellBookFrame_ShowGlyphFrame()
    ArmorySpellBookFrameIcon:Hide();
    ArmorySpellBookFrameTopLeft:Hide();
    ArmorySpellBookFrameTopRight:Hide();
    ArmorySpellBookFrameBotLeft:Hide();
    ArmorySpellBookFrameBotRight:Hide();
    ArmoryGlyphFrame:Show();
end

function ArmorySpellBookFrame_HideGlyphFrame()
    ArmorySpellBookFrameIcon:Show();
    ArmorySpellBookFrameTopLeft:Show();
    ArmorySpellBookFrameTopRight:Show();
    ArmorySpellBookFrameBotLeft:Show();
    ArmorySpellBookFrameBotRight:Show();
    ArmoryGlyphFrame:Hide();
end

function ArmorySpellBookFrame_UpdatePages()
    local currentPage, maxPages = ArmorySpellBook_GetCurrentPage();
    if ( maxPages == 0 ) then
        ArmorySpellBookPrevPageButton:Disable();
        ArmorySpellBookNextPageButton:Disable();
        ArmorySpellBookPageText:SetText("");
        return;
    end
    if ( currentPage > maxPages ) then
        if ( ArmorySpellBookFrame.bookType == BOOKTYPE_PET ) then
            ARMORY_SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] = maxPages;
        else
            ARMORY_SPELLBOOK_PAGENUMBERS[ArmorySpellBookFrame.selectedSkillLine] = maxPages;
        end
        currentPage = maxPages;
        ArmorySpellBook_UpdateSpells();
        if ( currentPage == 1 ) then
            ArmorySpellBookPrevPageButton:Disable();
        else
            ArmorySpellBookPrevPageButton:Enable();
        end
        if ( currentPage == maxPages ) then
            ArmorySpellBookNextPageButton:Disable();
        else
            ArmorySpellBookNextPageButton:Enable();
        end
    end
    if ( currentPage == 1 ) then
        ArmorySpellBookPrevPageButton:Disable();
    else
        ArmorySpellBookPrevPageButton:Enable();
    end
    if ( currentPage == maxPages ) then
        ArmorySpellBookNextPageButton:Disable();
    else
        ArmorySpellBookNextPageButton:Enable();
    end
    ArmorySpellBookPageText:SetFormattedText(PAGE_NUMBER, currentPage);
    -- Hide spell rank checkbox if the player is a rogue or warrior
    local _, class = Armory:UnitClass("player");
    local showSpellRanks = true;
    if ( class == "ROGUE" or class == "WARRIOR" ) then
        showSpellRanks = false;
    end
    if ( ArmorySpellBookFrame.bookType == BOOKTYPE_SPELL and showSpellRanks ) then
        ArmoryShowAllSpellRanksCheckBox:Show();
    else
        ArmoryShowAllSpellRanksCheckBox:Hide();
    end
end

function ArmorySpellBookFrame_SetTabType(tabButton, bookType, token)
    if ( bookType == BOOKTYPE_SPELL ) then
        tabButton.bookType = BOOKTYPE_SPELL;
        tabButton:SetText(SPELLBOOK);
        tabButton:SetFrameLevel(ArmorySpellBookFrame:GetFrameLevel() + 1);
        tabButton.binding = "TOGGLESPELLBOOK";
    elseif ( bookType == BOOKTYPE_PET ) then
        tabButton.bookType = BOOKTYPE_PET;
        tabButton:SetText(getglobal("PET_TYPE_"..token));
        tabButton:SetFrameLevel(ArmorySpellBookFrame:GetFrameLevel() + 1);
        tabButton.binding = "TOGGLEPETBOOK";
        ArmorySpellBookFrame.petTitle = getglobal("PET_TYPE_"..token);
    else
        tabButton.bookType = INSCRIPTION;
        tabButton:SetText(GLYPHS);
        tabButton:SetFrameLevel(ArmorySpellBookFrame:GetFrameLevel() + 2);
        tabButton.binding = "TOGGLEINSCRIPTION";
    end
    if ( ArmorySpellBookFrame.bookType == bookType ) then
        tabButton:Disable();
    else
        tabButton:Enable();
    end
    tabButton:Show();
end

function ArmorySpellBookFrame_PlayOpenSound()
    if ( ArmorySpellBookFrame.bookType == BOOKTYPE_SPELL ) then
        PlaySound("igSpellBookOpen");
    elseif ( ArmorySpellBookFrame.bookType == BOOKTYPE_PET ) then
        -- Need to change to pet book open sound
        PlaySound("igAbilityOpen");
    else
        PlaySound("igSpellBookOpen");
    end
end

function ArmorySpellBookFrame_PlayCloseSound()
    if ( not ArmorySpellBookFrame.suppressCloseSound ) then
        if ( ArmorySpellBookFrame.bookType == BOOKTYPE_SPELL ) then
            PlaySound("igSpellBookClose");
        else
            -- Need to change to pet book close sound
            PlaySound("igAbilityClose");
        end
    end
end

function ArmorySpellBookFrame_OnHide(self)
    ArmorySpellBookFrame_PlayCloseSound();
end

function ArmorySpellButton_OnEnter(self)
    local id = ArmorySpellBook_GetSpellID(self:GetID());
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    if ( id and Armory:SetSpell(id, ArmorySpellBookFrame.bookType) ) then
        self.UpdateTooltip = ArmorySpellButton_OnEnter;
    else
        self.UpdateTooltip = nil;
    end
end

function ArmorySpellButton_UpdateButton(self)
    if ( not ArmorySpellBookFrame.selectedSkillLine ) then
        ArmorySpellBookFrame.selectedSkillLine = 1;
    end
    local temp, texture, offset, numSpells = ArmorySpellBook_GetTabInfo(ArmorySpellBookFrame.selectedSkillLine);
    ArmorySpellBookFrame.selectedSkillLineOffset = offset;

    local id, displayID = ArmorySpellBook_GetSpellID(self:GetID());
    local name = self:GetName();
    local iconTexture = getglobal(name.."IconTexture");
    local spellString = getglobal(name.."SpellName");
    local subSpellString = getglobal(name.."SubSpellName");
    local autoCastableTexture = getglobal(name.."AutoCastable");
    
    if ( (ArmorySpellBookFrame.bookType ~= BOOKTYPE_PET) and (not displayID or displayID > (offset + numSpells)) ) then
        self:Disable();
        iconTexture:Hide();
        spellString:Hide();
        subSpellString:Hide();
        autoCastableTexture:Hide();
        getglobal(name.."NormalTexture"):SetVertexColor(1.0, 1.0, 1.0);
        return;
    else
        self:Enable();
    end
    local texture = Armory:GetSpellTexture(id, ArmorySpellBookFrame.bookType);
    local highlightTexture = getglobal(name.."Highlight");
    local normalTexture = getglobal(name.."NormalTexture");
    -- If no spell, hide everything and return
    if ( not texture or (strlen(texture) == 0) ) then
        iconTexture:Hide();
        spellString:Hide();
        subSpellString:Hide();
        autoCastableTexture:Hide();
        highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
        normalTexture:SetVertexColor(1.0, 1.0, 1.0);
        return;
    end
    local spellLink, tradeSkillLink = Armory:GetSpellLink(id, ArmorySpellBookFrame.bookType);
    if ( tradeSkillLink ) then
        self.link = tradeSkillLink;
    else
        self.link = spellLink;
    end

    local autoCastAllowed = Armory:GetSpellAutocast(id, ArmorySpellBookFrame.bookType);
    if ( autoCastAllowed ) then
        autoCastableTexture:Show();
    else
        autoCastableTexture:Hide();
    end

    local spellName, subSpellName = Armory:GetSpellName(id, ArmorySpellBookFrame.bookType);
    local isPassive = IsPassiveSpell(id, ArmorySpellBookFrame.bookType);
    if ( isPassive ) then
        normalTexture:SetVertexColor(0, 0, 0);
        highlightTexture:SetTexture("Interface\\Buttons\\UI-PassiveHighlight");
        --subSpellName = PASSIVE_PARENS;
        spellString:SetTextColor(PASSIVE_SPELL_FONT_COLOR.r, PASSIVE_SPELL_FONT_COLOR.g, PASSIVE_SPELL_FONT_COLOR.b);
    else
        normalTexture:SetVertexColor(1.0, 1.0, 1.0);
        highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
        spellString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
    end
    iconTexture:SetTexture(texture);
    spellString:SetText(spellName);
    subSpellString:SetText(subSpellName);
    if ( subSpellName ~= "" ) then
        spellString:SetPoint("LEFT", self, "RIGHT", 4, 4);
    else
        spellString:SetPoint("LEFT", self, "RIGHT", 4, 2);
    end

    iconTexture:Show();
    spellString:Show();
    subSpellString:Show();
end

function ArmorySpellBookPrevPageButton_OnClick(self)
    local pageNum = ArmorySpellBook_GetCurrentPage() - 1;
    if ( ArmorySpellBookFrame.bookType == BOOKTYPE_SPELL ) then
        PlaySound("igAbiliityPageTurn");
        ARMORY_SPELLBOOK_PAGENUMBERS[ArmorySpellBookFrame.selectedSkillLine] = pageNum;
    else
        ArmorySpellBookTitleText:SetText(ArmorySpellBookFrame.petTitle);
        -- Need to change to pet book pageturn sound
        PlaySound("igAbiliityPageTurn");
        ARMORY_SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] = pageNum;
    end
    ArmorySpellBook_UpdatePageArrows();
    ArmorySpellBookPageText:SetFormattedText(PAGE_NUMBER, pageNum);
    ArmorySpellBook_UpdateSpells();
end

function ArmorySpellBookNextPageButton_OnClick(self)
    local pageNum = ArmorySpellBook_GetCurrentPage() + 1;
    if ( ArmorySpellBookFrame.bookType == BOOKTYPE_SPELL ) then
        PlaySound("igAbiliityPageTurn");
        ARMORY_SPELLBOOK_PAGENUMBERS[ArmorySpellBookFrame.selectedSkillLine] = pageNum;
    else
        ArmorySpellBookTitleText:SetText(ArmorySpellBookFrame.petTitle);
        -- Need to change to pet book pageturn sound
        PlaySound("igAbiliityPageTurn");
        ARMORY_SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] = pageNum;
    end
    ArmorySpellBook_UpdatePageArrows();
    ArmorySpellBookPageText:SetFormattedText(PAGE_NUMBER, pageNum);
    ArmorySpellBook_UpdateSpells();
end

function ArmorySpellBookSkillLineTab_OnClick(self, id)
    ArmorySpellBookFrame.selectedSkillLine = id or self:GetID();
    local name, texture, offset, numSpells = ArmorySpellBook_GetTabInfo(ArmorySpellBookFrame.selectedSkillLine);
    ArmorySpellBookFrame.selectedSkillLineOffset = offset;
    ArmorySpellBookFrame.selectedSkillLineNumSpells = numSpells;
    ArmorySpellBook_UpdatePageArrows();
    ArmorySpellBookFrame_Update();
    ArmorySpellBookPageText:SetFormattedText(PAGE_NUMBER, ArmorySpellBook_GetCurrentPage());
    ArmorySpellBook_UpdateSpells();
end

function ArmorySpellBookFrameTabButton_OnClick(self)
    -- suppress the hiding sound so we don't play a hide and show sound simultaneously
    ArmorySpellBookFrame.suppressCloseSound = true;
    ArmoryToggleSpellBook(self.bookType, true);
    ArmorySpellBookFrame.suppressCloseSound = false;
end

function ArmorySpellBook_GetSpellID(id)
    if ( ArmorySpellBookFrame.bookType == BOOKTYPE_PET ) then
        return id + (SPELLS_PER_PAGE * (ARMORY_SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] - 1));
    elseif ( ArmorySpellBookFrame.selectedSkillLineOffset ) then
        local slot = id + ArmorySpellBookFrame.selectedSkillLineOffset + ( SPELLS_PER_PAGE * (ARMORY_SPELLBOOK_PAGENUMBERS[ArmorySpellBookFrame.selectedSkillLine] - 1));
        if ( not Armory:GetShowAllSpellRanks() ) then
            return Armory:GetKnownSlotFromHighestRankSlot(slot), slot;
        end
        return slot, slot;
    end
end

function ArmorySpellBook_UpdatePageArrows()
    local currentPage, maxPages = ArmorySpellBook_GetCurrentPage();
    if ( currentPage == 1 ) then
        ArmorySpellBookPrevPageButton:Disable();
    else
        ArmorySpellBookPrevPageButton:Enable();
    end
    if ( maxPages == 0 or currentPage == maxPages ) then
        ArmorySpellBookNextPageButton:Disable();
    else
        ArmorySpellBookNextPageButton:Enable();
    end
end

function ArmorySpellBook_GetCurrentPage()
    local currentPage, maxPages;
    local numPetSpells = Armory:HasPetSpells();
    if ( numPetSpells and Armory:HasPetUI() and ArmorySpellBookFrame.bookType == BOOKTYPE_PET ) then
        currentPage = ARMORY_SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET];
        maxPages = ceil(numPetSpells / SPELLS_PER_PAGE);
    else
        currentPage = ARMORY_SPELLBOOK_PAGENUMBERS[ArmorySpellBookFrame.selectedSkillLine];
        local name, texture, offset, numSpells = ArmorySpellBook_GetTabInfo(ArmorySpellBookFrame.selectedSkillLine);
        if ( numSpells ) then
            maxPages = ceil(numSpells / SPELLS_PER_PAGE);
        else
            maxPages = 0;
        end
    end
    return currentPage, maxPages;
end

function ArmorySpellBook_GetTabInfo(skillLine)
    local name, texture, offset, numSpells, highestRankOffset, highestRankNumSpells = Armory:GetSpellTabInfo(skillLine);

    if ( not Armory:GetShowAllSpellRanks() ) then
        offset = highestRankOffset;
        numSpells = highestRankNumSpells;
    end
    return name, texture, offset, numSpells;
end

function ArmorySpellBook_UpdateSpells()
    for i = 1, SPELLS_PER_PAGE do
       ArmorySpellButton_UpdateButton(getglobal("ArmorySpellButton"..i));
    end
end