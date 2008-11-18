--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmorySkillFrame.lua,v 1.18, 2008-10-20 23:04:09Z, Maxim Baars$
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

ARMORY_NUM_SKILLS_DISPLAYED = 19;
ARMORY_SKILLFRAME_SKILL_HEIGHT = 15;

function ArmorySkillFrame_OnLoad(self)
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("SKILL_LINES_CHANGED");
    self:RegisterEvent("CHARACTER_POINTS_CHANGED");
    self:RegisterEvent("SPELLS_CHANGED");

    ArmorySkillListScrollFrameScrollBar:SetValue(0);
    self.selectedSkill = 0;
    ArmorySkillFrame.statusBarClickedID = 0;
end

function ArmorySkillFrame_OnEvent(self, event, ...)
    if ( not Armory:CanHandleEvents() ) then
        return;
    elseif ( event == "PLAYER_ENTERING_WORLD") then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
    end
    Armory:Execute(ArmorySkillFrame_UpdateSkills, ArmorySkillFrame:IsShown());
end

function ArmorySkillFrame_OnShow(self)
    ArmorySkillFrame_UpdateSkills(true);
end

function ArmorySkillFrame_SetStatusBar(statusBarID, skillIndex, numSkills, adjustedSkillPoints)
    -- Get info
    local skillName, header, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType, skillDescription = Armory:GetSkillLineInfo(skillIndex);
    local skillRankStart = skillRank;
    skillRank = skillRank + numTempPoints;

    -- Skill bar objects
    local statusBarLabel = "ArmorySkillRankFrame"..statusBarID;
    local statusBar = getglobal(statusBarLabel);
    local statusBarSkillRank = getglobal(statusBarLabel.."SkillRank");
    local statusBarName = getglobal(statusBarLabel.."SkillName");
    local statusBarBorder = getglobal(statusBarLabel.."Border");
    local statusBarBackground = getglobal(statusBarLabel.."Background");
    local statusBarFillBar = getglobal(statusBarLabel.."FillBar");

    statusBarFillBar:Hide();

    -- Header objects
    local skillRankFrameBorderTexture = getglobal(statusBarLabel.."Border");
    local skillTypeLabelText = getglobal("ArmorySkillTypeLabel"..statusBarID);

    -- Frame width vars
    local skillRankFrameWidth = 0;

    -- Hide or show skill bar
    if ( skillName == "" ) then
        statusBar:Hide();
        skillTypeLabelText:Hide();
        return;
    end

    -- Is header
    if ( header ) then
        skillTypeLabelText:Show();
        skillTypeLabelText:SetText(skillName);
        skillTypeLabelText.skillIndex = skillIndex;
        skillRankFrameBorderTexture:Hide();
        statusBar:Hide();
        local normalTexture = getglobal("ArmorySkillTypeLabel"..statusBarID.."NormalTexture");
        if ( isExpanded ) then
            skillTypeLabelText:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
        else
            skillTypeLabelText:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
        end
        skillTypeLabelText.isExpanded = isExpanded;
        return;
    else
        if ( skillDescription ) then
            statusBarBorder.tooltipTitle = skillName;
            statusBarBorder.tooltip = skillDescription;
        end
        skillTypeLabelText:Hide();
        skillRankFrameBorderTexture:Show();
        statusBar:Show();
    end

    -- Set skillbar info
    statusBar.skillIndex = skillIndex;
    statusBarName:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
    statusBarSkillRank:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
    statusBarSkillRank:ClearAllPoints();
    statusBarSkillRank:SetPoint("LEFT", statusBarLabel.."SkillName", "RIGHT", 13, 0);
    statusBarSkillRank:SetJustifyH("LEFT");

    -- Anchor the text to the left by default
    statusBarName:ClearAllPoints();
    statusBarName:SetPoint("LEFT", statusBar, "LEFT", 6, 1);

    -- Lock border color if skill is selected
    if (skillIndex == ArmorySkillFrame.selectedSkill) then
        statusBarBorder:LockHighlight();
    else
        statusBarBorder:UnlockHighlight();
    end

    -- Set bar color depending on skill cost
    if (skillCostType == 1) then
        statusBar:SetStatusBarColor(0.0, 0.75, 0.0, 0.5);
        statusBarBackground:SetVertexColor(0.0, 0.5, 0.0, 0.5);
        statusBarFillBar:SetVertexColor(0.0, 1.0, 0.0, 0.5);
    elseif (skillCostType == 2) then
        statusBar:SetStatusBarColor(0.75, 0.75, 0.0, 0.5);
        statusBarBackground:SetVertexColor(0.75, 0.75, 0.0, 0.5);
        statusBarFillBar:SetVertexColor(1.0, 1.0, 0.0, 0.5);
    elseif (skillCostType == 3) then
        statusBar:SetStatusBarColor(0.75, 0.0, 0.0, 0.5);
        statusBarBackground:SetVertexColor(0.75, 0.0, 0.0, 0.5);
        statusBarFillBar:SetVertexColor(1.0, 0.0, 0.0, 0.5);
    else
        statusBar:SetStatusBarColor(0.5, 0.5, 0.5, 0.5);
        statusBarBackground:SetVertexColor(0.5, 0.5, 0.5, 0.5);
        statusBarFillBar:SetVertexColor(1.0, 1.0, 1.0, 0.5);
    end

    -- Default width
    skillRankFrameWidth = 256;

    statusBarName:SetText(skillName);

    -- Show and hide skill up arrows
    if ( stepCost ) then
        -- If is a learnable skill
        -- Set cost, text, and color
        statusBar:SetMinMaxValues(0, 1);
        statusBar:SetValue(0);
        statusBar:SetStatusBarColor(0.25, 0.25, 0.25);
        statusBarBackground:SetVertexColor(0.75, 0.75, 0.75, 0.5);
        statusBarName:SetFormattedText(LEARN_SKILL_TEMPLATE,skillName);
        statusBarSkillRank:SetText("");

        -- If skill is too high level
        if ( Armory:UnitLevel("player") < minLevel ) then
            statusBar:SetValue(0);
            statusBarSkillRank:SetFormattedText(LEVEL_GAINED,skillLevel);
            statusBarName:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
            statusBarSkillRank:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
            return;
        end

    elseif ( rankCost or (numTempPoints > 0) ) then
        -- If is a skill that can be trained up
        if ( not rankCost ) then
            rankCost = 0;
        end

        statusBarName:SetText(skillName);

        -- Setwidth value
        skillRankFrameWidth = 215;
    else
        -- Normal skill
        statusBarName:SetText(skillName);
        statusBar:SetStatusBarColor(0.0, 0.0, 1.0, 0.5);
        statusBarBackground:SetVertexColor(0.0, 0.0, 0.75, 0.5);
    end

    if ( skillMaxRank == 1 ) then
        -- If max rank in a skill is 1 assume that its a proficiency
        statusBar:SetMinMaxValues(0, 1);
        statusBar:SetValue(1);
        statusBar:SetStatusBarColor(0.5, 0.5, 0.5);
        statusBarSkillRank:SetText("");
        statusBarBackground:SetVertexColor(1.0, 1.0, 1.0, 0.5);
    elseif ( skillMaxRank > 0 ) then
        statusBar:SetMinMaxValues(0, skillMaxRank);
        statusBar:SetValue(skillRankStart);
        if (numTempPoints > 0) then
            local fillBarWidth = (skillRank / skillMaxRank) * statusBar:GetWidth();
            statusBarFillBar:SetPoint("TOPRIGHT", statusBarLabel, "TOPLEFT", fillBarWidth, 0);
            statusBarFillBar:Show();
        else
            statusBarFillBar:Hide();
        end
        if ( skillModifier == 0 ) then
            statusBarSkillRank:SetText(skillRank.."/"..skillMaxRank);
        else
            local color = RED_FONT_COLOR_CODE;
            if ( skillModifier > 0 ) then
                color = GREEN_FONT_COLOR_CODE.."+"
            end
            statusBarSkillRank:SetText(skillRank.." ("..color..skillModifier..FONT_COLOR_CODE_CLOSE..")/"..skillMaxRank);
        end
    end
end

function ArmorySkillFrame_UpdateSkills(updateFrame)
    -- SetSkills will trigger SKILL_LINES_CHANGED
    ArmorySkillFrame:UnregisterEvent("SKILL_LINES_CHANGED");
    Armory:SetSkills();
    ArmorySkillFrame:RegisterEvent("SKILL_LINES_CHANGED");
    if ( updateFrame ) then
        ArmorySkillFrame_Update();
    end
end

function ArmorySkillFrame_Update()
    local numSkills = Armory:GetNumSkillLines();
    local adjustedSkillPoints = Armory:GetAdjustedSkillPoints();
    local offset = FauxScrollFrame_GetOffset(ArmorySkillListScrollFrame) + 1;
    local index = 1;
    for i=offset,  offset + ARMORY_NUM_SKILLS_DISPLAYED - 1 do
        if ( i <= numSkills ) then
            ArmorySkillFrame_SetStatusBar(index, i, numSkills, adjustedSkillPoints);
        else
            break;
        end
        index = index + 1;
    end

    -- Hide unused bars
    for i=index, ARMORY_NUM_SKILLS_DISPLAYED do
        getglobal("ArmorySkillRankFrame"..i):Hide();
        getglobal("ArmorySkillTypeLabel"..i):Hide();
    end

    local talentPoints, currSkillPoints = Armory:UnitCharacterPoints("player");

    -- Update skill points
    ArmorySkillFrame.UpdatedSkillPoints = Armory:GetAdjustedSkillPoints();

    -- Update scrollFrame
    FauxScrollFrame_Update(ArmorySkillListScrollFrame, numSkills, ARMORY_NUM_SKILLS_DISPLAYED, ARMORY_SKILLFRAME_SKILL_HEIGHT );

    -- Update linetabs
    ArmoryFrame_UpdateLineTabs();
end

function ArmorySkillBar_OnClick(self)
    ArmorySkillFrame.selectedSkill = self:GetID();
end
