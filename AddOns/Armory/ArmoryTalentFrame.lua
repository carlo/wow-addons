--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmoryTalentFrame.lua,v 1.12, 2008-10-12 18:25:03Z, Maxim Baars$
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

ARMORY_MAX_TALENT_TABS = 5;
ARMORY_MAX_NUM_TALENT_TIERS = 15;
ARMORY_NUM_TALENT_COLUMNS = 4;
ARMORY_MAX_NUM_TALENTS = 40;
ARMORY_TALENT_BRANCH_ARRAY = {};
ARMORY_TALENT_BUTTON_SIZE = 32;
ARMORY_MAX_NUM_BRANCH_TEXTURES = 30;
ARMORY_MAX_NUM_ARROW_TEXTURES = 30;
ARMORY_INITIAL_TALENT_OFFSET_X = 35;
ARMORY_INITIAL_TALENT_OFFSET_Y = 20;

ARMORY_TALENT_BRANCH_TEXTURECOORDS = {
    up = {
        [1] = {0.12890625, 0.25390625, 0 , 0.484375},
        [-1] = {0.12890625, 0.25390625, 0.515625 , 1.0}
    },
    down = {
        [1] = {0, 0.125, 0, 0.484375},
        [-1] = {0, 0.125, 0.515625, 1.0}
    },
    left = {
        [1] = {0.2578125, 0.3828125, 0, 0.5},
        [-1] = {0.2578125, 0.3828125, 0.5, 1.0}
    },
    right = {
        [1] = {0.2578125, 0.3828125, 0, 0.5},
        [-1] = {0.2578125, 0.3828125, 0.5, 1.0}
    },
    topright = {
        [1] = {0.515625, 0.640625, 0, 0.5},
        [-1] = {0.515625, 0.640625, 0.5, 1.0}
    },
    topleft = {
        [1] = {0.640625, 0.515625, 0, 0.5},
        [-1] = {0.640625, 0.515625, 0.5, 1.0}
    },
    bottomright = {
        [1] = {0.38671875, 0.51171875, 0, 0.5},
        [-1] = {0.38671875, 0.51171875, 0.5, 1.0}
    },
    bottomleft = {
        [1] = {0.51171875, 0.38671875, 0, 0.5},
        [-1] = {0.51171875, 0.38671875, 0.5, 1.0}
    },
    tdown = {
        [1] = {0.64453125, 0.76953125, 0, 0.5},
        [-1] = {0.64453125, 0.76953125, 0.5, 1.0}
    },
    tup = {
        [1] = {0.7734375, 0.8984375, 0, 0.5},
        [-1] = {0.7734375, 0.8984375, 0.5, 1.0}
    },
};

ARMORY_TALENT_ARROW_TEXTURECOORDS = {
    top = {
        [1] = {0, 0.5, 0, 0.5},
        [-1] = {0, 0.5, 0.5, 1.0}
    },
    right = {
        [1] = {1.0, 0.5, 0, 0.5},
        [-1] = {1.0, 0.5, 0.5, 1.0}
    },
    left = {
        [1] = {0.5, 1.0, 0, 0.5},
        [-1] = {0.5, 1.0, 0.5, 1.0}
    },
};

function ArmoryTalentFrameTalent_OnEvent(self, event, ...)
    if ( Armory:CanHandleEvents() and GameTooltip:IsOwned(self) ) then
        Armory:SetTalent(PanelTemplates_GetSelectedTab(ArmoryTalentFrame), self:GetID(), false, false);
    end
end

function ArmoryTalentFrameDownArrow_OnClick(self)
    local parent = self:GetParent();
    parent:SetValue(parent:GetValue() + (parent:GetHeight() / 2));
end

function ArmoryTalentFrameTab_OnClick(self)
    PanelTemplates_SetTab(ArmoryTalentFrame, self:GetID());
    ArmoryTalentFrame_Update();
end

function ArmoryTalentFrame_OnLoad(self)
    PanelTemplates_SetNumTabs(self, 3);
    PanelTemplates_SetTab(self, 1);
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("CHARACTER_POINTS_CHANGED");
    self:RegisterEvent("SPELLS_CHANGED");
    ArmoryTalentFrameScrollFrameScrollBarScrollDownButton:SetScript("OnClick", ArmoryTalentFrameDownArrow_OnClick);
    for i=1, ARMORY_MAX_NUM_TALENT_TIERS do
        ARMORY_TALENT_BRANCH_ARRAY[i] = {};
        for j=1, ARMORY_NUM_TALENT_COLUMNS do
            ARMORY_TALENT_BRANCH_ARRAY[i][j] = {id=nil, up=0, left=0, right=0, down=0, leftArrow=0, rightArrow=0, topArrow=0};
        end
    end
end

function ArmoryTalentFrame_OnEvent(self, event, ...)
    if ( not Armory:CanHandleEvents() ) then
        return;
    elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
    end
    Armory:ExecuteConditional(ArmoryTalentFrame_UpdateCondition, ArmoryTalentFrame_UpdateTalents);
end

function ArmoryTalentFrameTalent_OnClick(self)
    if ( IsModifiedClick("CHATLINK") ) then
        local link = Armory:GetTalentLink(ArmoryTalentFrame.selectedTab, self:GetID(), false, false);
        if ( link ) then
            ChatEdit_InsertLink(link);
        end
    end
end

function ArmoryTalentTooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    Armory:SetTalent(ArmoryTalentFrame.selectedTab, self:GetID(), inspect, pet);
end

function ArmoryTalentFrame_UpdateCondition()
    return GetNumTalentTabs(false, false) > 0;
end

function ArmoryTalentFrame_UpdateTalents()
    Armory:SetTalents();
    ArmoryTalentFrame_Update();
end

function ArmoryTalentFrame_OnShow(self)
    PanelTemplates_SetTab(self, 1);
    Armory:SetTalents();
    ArmoryTalentFrame_Update();
end

function ArmoryTalentFrame_Update()
    ----------------------------
    -- Blizzard_TalentUI part --
    ----------------------------
    
    -- Initialize talent tables if necessary
    local numTalents = Armory:GetNumTalents(PanelTemplates_GetSelectedTab(ArmoryTalentFrame), false, false);
    -- Setup Tabs
    local tab, name, iconTexture, pointsSpent, button;
    local numTabs = Armory:GetNumTalentTabs(false, false);
    local maxWidth = 285;
    for i=1, ARMORY_MAX_TALENT_TABS do
        tab = getglobal("ArmoryTalentFrameTab"..i);
        if ( i <= numTabs ) then
            name, iconTexture, pointsSpent = Armory:GetTalentTabInfo(i, false, false);
            if ( i == PanelTemplates_GetSelectedTab(ArmoryTalentFrame) ) then
                -- If tab is the selected tab set the points spent info
                --TalentFrameSpentPoints:SetText(format(MASTERY_POINTS_SPENT, name).." "..HIGHLIGHT_FONT_COLOR_CODE..pointsSpent..FONT_COLOR_CODE_CLOSE);
                ArmoryTalentFrame.pointsSpent = pointsSpent;
            end
            tab:SetText(name);
            PanelTemplates_TabResize(tab, 0, nil, maxWidth);
            maxWidth = maxWidth - tab:GetWidth() - 10;
            tab:Show();
        else
            tab:Hide();
        end
    end

    PanelTemplates_SetNumTabs(ArmoryTalentFrame, numTabs);
    PanelTemplates_UpdateTabs(ArmoryTalentFrame);

    --------------------------
    -- TalentFrameBase part --
    -------------------------- 
    
    -- Setup Frame
    ArmoryTalentFrame_UpdateTalentPoints();
    local base;
    local name, texture, points, fileName = Armory:GetTalentTabInfo(PanelTemplates_GetSelectedTab(ArmoryTalentFrame), false, false);
    if ( name ) then
        base = "Interface\\TalentFrame\\"..fileName.."-";
    else
        -- temporary default for classes without talents poor guys
        base = "Interface\\TalentFrame\\MageFire-";
    end

    ArmoryTalentFrameBackgroundTopLeft:SetTexture(base.."TopLeft");
    ArmoryTalentFrameBackgroundTopRight:SetTexture(base.."TopRight");
    ArmoryTalentFrameBackgroundBottomLeft:SetTexture(base.."BottomLeft");
    ArmoryTalentFrameBackgroundBottomRight:SetTexture(base.."BottomRight");

    -- Just a reminder error if there are more talents than available buttons
    if ( numTalents > ARMORY_MAX_NUM_TALENTS ) then
        message("Too many talents in talent frame!");
    end

    ArmoryTalentFrame_ResetBranches();
    local tier, column, rank, maxRank, isExceptional, isLearnable;
    local forceDesaturated, tierUnlocked;
    for i=1, ARMORY_MAX_NUM_TALENTS do
        button = getglobal("ArmoryTalentFrameTalent"..i);
        if ( i <= numTalents ) then
            -- Set the button info
            name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = Armory:GetTalentInfo(PanelTemplates_GetSelectedTab(ArmoryTalentFrame), i, false, false);
            if ( name ) then
                getglobal("ArmoryTalentFrameTalent"..i.."Rank"):SetText(rank);
                ArmorySetTalentButtonLocation(button, tier, column);
                ARMORY_TALENT_BRANCH_ARRAY[tier][column].id = button:GetID();

                -- If player has no talent points then show only talents with points in them
                if ( (ArmoryTalentFrame.talentPoints <= 0 and rank == 0)  ) then
                    forceDesaturated = 1;
                else
                    forceDesaturated = nil;
                end

                -- If the player has spent at least 5 talent points in the previous tier
                if ( ( (tier - 1) * PLAYER_TALENTS_PER_TIER <= ArmoryTalentFrame.pointsSpent ) ) then
                    tierUnlocked = 1;
                else
                    tierUnlocked = nil;
                end
                SetItemButtonTexture(button, iconTexture);

                -- Talent must meet prereqs or the player must have no points to spend
                if ( ArmoryTalentFrame_SetPrereqs(tier, column, forceDesaturated, tierUnlocked, Armory:GetTalentPrereqs(PanelTemplates_GetSelectedTab(ArmoryTalentFrame), i, false, false)) and meetsPrereq ) then
                    SetItemButtonDesaturated(button, nil);

                    if ( rank < maxRank ) then
                        -- Rank is green if not maxed out
                        getglobal("ArmoryTalentFrameTalent"..i.."Slot"):SetVertexColor(0.1, 1.0, 0.1);
                        getglobal("ArmoryTalentFrameTalent"..i.."Rank"):SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
                    else
                        getglobal("ArmoryTalentFrameTalent"..i.."Slot"):SetVertexColor(1.0, 0.82, 0);
                        getglobal("ArmoryTalentFrameTalent"..i.."Rank"):SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                    end
                    getglobal("ArmoryTalentFrameTalent"..i.."RankBorder"):Show();
                    getglobal("ArmoryTalentFrameTalent"..i.."Rank"):Show();
                else
                    SetItemButtonDesaturated(button, 1, 0.65, 0.65, 0.65);
                    getglobal("ArmoryTalentFrameTalent"..i.."Slot"):SetVertexColor(0.5, 0.5, 0.5);
                    if ( rank == 0 ) then
                        getglobal("ArmoryTalentFrameTalent"..i.."RankBorder"):Hide();
                        getglobal("ArmoryTalentFrameTalent"..i.."Rank"):Hide();
                    else
                        getglobal("ArmoryTalentFrameTalent"..i.."RankBorder"):SetVertexColor(0.5, 0.5, 0.5);
                        getglobal("ArmoryTalentFrameTalent"..i.."Rank"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
                    end
                end

                button:Show();
            else    
                button:Hide();
            end
        else
            button:Hide();
        end
    end

    -- Draw the prerq branches
    local node;
    local textureIndex = 1;
    local xOffset, yOffset;
    -- Variable that decides whether or not to ignore drawing pieces
    local ignoreUp;
    local tempNode;
    ArmoryTalentFrame_ResetBranchTextureCount();
    ArmoryTalentFrame_ResetArrowTextureCount();
    for i=1, ARMORY_MAX_NUM_TALENT_TIERS do
        for j=1, ARMORY_NUM_TALENT_COLUMNS do
            node = ARMORY_TALENT_BRANCH_ARRAY[i][j];

            -- Setup offsets
            xOffset = ((j - 1) * 63) + ARMORY_INITIAL_TALENT_OFFSET_X + 2;
            yOffset = -((i - 1) * 63) - ARMORY_INITIAL_TALENT_OFFSET_Y - 2;

            if ( node.id ) then
                -- Has talent
                if ( node.up ~= 0 ) then
                    if ( not ignoreUp ) then
                        ArmoryTalentFrame_SetBranchTexture(i, j, ARMORY_TALENT_BRANCH_TEXTURECOORDS["up"][node.up], xOffset, yOffset + ARMORY_TALENT_BUTTON_SIZE);
                    else
                        ignoreUp = nil;
                    end
                end
                if ( node.down ~= 0 ) then
                    ArmoryTalentFrame_SetBranchTexture(i, j, ARMORY_TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset, yOffset - ARMORY_TALENT_BUTTON_SIZE + 1);
                end
                if ( node.left ~= 0 ) then
                    ArmoryTalentFrame_SetBranchTexture(i, j, ARMORY_TALENT_BRANCH_TEXTURECOORDS["left"][node.left], xOffset - ARMORY_TALENT_BUTTON_SIZE, yOffset);
                end
                if ( node.right ~= 0 ) then
                    -- See if any connecting branches are gray and if so color them gray
                    tempNode = ARMORY_TALENT_BRANCH_ARRAY[i][j+1];    
                    if ( tempNode.left ~= 0 and tempNode.down < 0 ) then
                        ArmoryTalentFrame_SetBranchTexture(i, j-1, ARMORY_TALENT_BRANCH_TEXTURECOORDS["right"][tempNode.down], xOffset + ARMORY_TALENT_BUTTON_SIZE, yOffset);
                    else
                        ArmoryTalentFrame_SetBranchTexture(i, j, ARMORY_TALENT_BRANCH_TEXTURECOORDS["right"][node.right], xOffset + ARMORY_TALENT_BUTTON_SIZE + 1, yOffset);
                    end

                end
                -- Draw arrows
                if ( node.rightArrow ~= 0 ) then
                    ArmoryTalentFrame_SetArrowTexture(i, j, ARMORY_TALENT_ARROW_TEXTURECOORDS["right"][node.rightArrow], xOffset + ARMORY_TALENT_BUTTON_SIZE/2 + 5, yOffset);
                end
                if ( node.leftArrow ~= 0 ) then
                    ArmoryTalentFrame_SetArrowTexture(i, j, ARMORY_TALENT_ARROW_TEXTURECOORDS["left"][node.leftArrow], xOffset - ARMORY_TALENT_BUTTON_SIZE/2 - 5, yOffset);
                end
                if ( node.topArrow ~= 0 ) then
                    ArmoryTalentFrame_SetArrowTexture(i, j, ARMORY_TALENT_ARROW_TEXTURECOORDS["top"][node.topArrow], xOffset, yOffset + ARMORY_TALENT_BUTTON_SIZE/2 + 5);
                end
            else
                -- Doesn't have a talent
                if ( node.up ~= 0 and node.left ~= 0 and node.right ~= 0 ) then
                    ArmoryTalentFrame_SetBranchTexture(i, j, ARMORY_TALENT_BRANCH_TEXTURECOORDS["tup"][node.up], xOffset , yOffset);
                elseif ( node.down ~= 0 and node.left ~= 0 and node.right ~= 0 ) then
                    ArmoryTalentFrame_SetBranchTexture(i, j, ARMORY_TALENT_BRANCH_TEXTURECOORDS["tdown"][node.down], xOffset , yOffset);
                elseif ( node.left ~= 0 and node.down ~= 0 ) then
                    ArmoryTalentFrame_SetBranchTexture(i, j, ARMORY_TALENT_BRANCH_TEXTURECOORDS["topright"][node.left], xOffset , yOffset);
                    ArmoryTalentFrame_SetBranchTexture(i, j, ARMORY_TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset , yOffset - 32);
                elseif ( node.left ~= 0 and node.up ~= 0 ) then
                    ArmoryTalentFrame_SetBranchTexture(i, j, ARMORY_TALENT_BRANCH_TEXTURECOORDS["bottomright"][node.left], xOffset , yOffset);
                elseif ( node.left ~= 0 and node.right ~= 0 ) then
                    ArmoryTalentFrame_SetBranchTexture(i, j, ARMORY_TALENT_BRANCH_TEXTURECOORDS["right"][node.right], xOffset + TALENT_BUTTON_SIZE, yOffset);
                    ArmoryTalentFrame_SetBranchTexture(i, j, ARMORY_TALENT_BRANCH_TEXTURECOORDS["left"][node.left], xOffset + 1, yOffset);
                elseif ( node.right ~= 0 and node.down ~= 0 ) then
                    ArmoryTalentFrame_SetBranchTexture(i, j, ARMORY_TALENT_BRANCH_TEXTURECOORDS["topleft"][node.right], xOffset , yOffset);
                    ArmoryTalentFrame_SetBranchTexture(i, j, ARMORY_TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset , yOffset - 32);
                elseif ( node.right ~= 0 and node.up ~= 0 ) then
                    ArmoryTalentFrame_SetBranchTexture(i, j, ARMORY_TALENT_BRANCH_TEXTURECOORDS["bottomleft"][node.right], xOffset , yOffset);
                elseif ( node.up ~= 0 and node.down ~= 0 ) then
                    ArmoryTalentFrame_SetBranchTexture(i, j, ARMORY_TALENT_BRANCH_TEXTURECOORDS["up"][node.up], xOffset , yOffset);
                    ArmoryTalentFrame_SetBranchTexture(i, j, ARMORY_TALENT_BRANCH_TEXTURECOORDS["down"][node.down], xOffset , yOffset - 32);
                    ignoreUp = 1;
                end
            end
        end
    end
    -- Hide any unused branch textures
    for i=ArmoryTalentFrame_GetBranchTextureCount(), ARMORY_MAX_NUM_BRANCH_TEXTURES do
        getglobal("ArmoryTalentFrameBranch"..i):Hide();
    end
    -- Hide and unused arrowl textures
    for i=ArmoryTalentFrame_GetArrowTextureCount(), ARMORY_MAX_NUM_ARROW_TEXTURES do
        getglobal("ArmoryTalentFrameArrow"..i):Hide();
    end
end

function ArmoryTalentFrame_SetArrowTexture(tier, column, texCoords, xOffset, yOffset)
    local arrowTexture = ArmoryTalentFrame_GetArrowTexture();
    arrowTexture:SetTexCoord(texCoords[1], texCoords[2], texCoords[3], texCoords[4]);
    arrowTexture:SetPoint("TOPLEFT", "ArmoryTalentFrameArrowFrame", "TOPLEFT", xOffset, yOffset);
end

function ArmoryTalentFrame_SetBranchTexture(tier, column, texCoords, xOffset, yOffset)
    local branchTexture = ArmoryTalentFrame_GetBranchTexture();
    branchTexture:SetTexCoord(texCoords[1], texCoords[2], texCoords[3], texCoords[4]);
    branchTexture:SetPoint("TOPLEFT", "ArmoryTalentFrameScrollChildFrame", "TOPLEFT", xOffset, yOffset);
end

function ArmoryTalentFrame_GetArrowTexture()
    local arrowTexture = getglobal("ArmoryTalentFrameArrow"..ArmoryTalentFrame.arrowIndex);
    ArmoryTalentFrame.arrowIndex = ArmoryTalentFrame.arrowIndex + 1;
    if ( not arrowTexture ) then
        message("Not enough arrow textures");
    else
        arrowTexture:Show();
        return arrowTexture;
    end
end

function ArmoryTalentFrame_GetBranchTexture()
    local branchTexture = getglobal("ArmoryTalentFrameBranch"..ArmoryTalentFrame.textureIndex);
    ArmoryTalentFrame.textureIndex = ArmoryTalentFrame.textureIndex + 1;
    if ( not branchTexture ) then
        --branchTexture = CreateTexture("TalentFrameBranch"..TalentFrame.textureIndex);
        message("Not enough branch textures");
    else
        branchTexture:Show();
        return branchTexture;
    end
end

function ArmoryTalentFrame_ResetArrowTextureCount()
    ArmoryTalentFrame.arrowIndex = 1;
end

function ArmoryTalentFrame_ResetBranchTextureCount()
    ArmoryTalentFrame.textureIndex = 1;
end

function ArmoryTalentFrame_GetArrowTextureCount()
    return ArmoryTalentFrame.arrowIndex;
end

function ArmoryTalentFrame_GetBranchTextureCount()
    return ArmoryTalentFrame.textureIndex;
end

function ArmoryTalentFrame_SetPrereqs(buttonTier, buttonColumn, forceDesaturated, tierUnlocked, ...)
    local tier, column, isLearnable;
    local requirementsMet;
    if ( tierUnlocked and not forceDesaturated ) then
        requirementsMet = 1;
    else
        requirementsMet = nil;
    end
    for i=1, select("#", ...), 3 do
        tier, column, isLearnable = select(i, ...);
        if ( not isLearnable or forceDesaturated ) then
            requirementsMet = nil;
        end
        ArmoryTalentFrame_DrawLines(buttonTier, buttonColumn, tier, column, requirementsMet);
    end
    return requirementsMet;
end


function ArmoryTalentFrame_DrawLines(buttonTier, buttonColumn, tier, column, requirementsMet)
    if ( requirementsMet ) then
        requirementsMet = 1;
    else
        requirementsMet = -1;
    end

    -- Check to see if are in the same column
    if ( buttonColumn == column ) then
        -- Check for blocking talents
        if ( (buttonTier - tier) > 1 ) then
            -- If more than one tier difference
            for i=tier + 1, buttonTier - 1 do
                if ( ARMORY_TALENT_BRANCH_ARRAY[i][buttonColumn].id ) then
                    -- If there's an id, there's a blocker
                    message("Error this layout is blocked vertically "..ARMORY_TALENT_BRANCH_ARRAY[buttonTier][i].id);
                    return;
                end
            end
        end

        -- Draw the lines
        for i=tier, buttonTier - 1 do
            ARMORY_TALENT_BRANCH_ARRAY[i][buttonColumn].down = requirementsMet;
            if ( (i + 1) <= (buttonTier - 1) ) then
                ARMORY_TALENT_BRANCH_ARRAY[i + 1][buttonColumn].up = requirementsMet;
            end
        end

        -- Set the arrow
        ARMORY_TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].topArrow = requirementsMet;
        return;
    end
    -- Check to see if they're in the same tier
    if ( buttonTier == tier ) then
        local left = min(buttonColumn, column);
        local right = max(buttonColumn, column);

        -- See if the distance is greater than one space
        if ( (right - left) > 1 ) then
            -- Check for blocking talents
            for i=left + 1, right - 1 do
                if ( ARMORY_TALENT_BRANCH_ARRAY[tier][i].id ) then
                    -- If there's an id, there's a blocker
                    message("there's a blocker "..tier.." "..i);
                    return;
                end
            end
        end
        -- If we get here then we're in the clear
        for i=left, right - 1 do
            ARMORY_TALENT_BRANCH_ARRAY[tier][i].right = requirementsMet;
            ARMORY_TALENT_BRANCH_ARRAY[tier][i+1].left = requirementsMet;
        end
        -- Determine where the arrow goes
        if ( buttonColumn < column ) then
            ARMORY_TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].rightArrow = requirementsMet;
        else
            ARMORY_TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].leftArrow = requirementsMet;
        end
        return;
    end
    -- Now we know the prereq is diagonal from us
    local left = min(buttonColumn, column);
    local right = max(buttonColumn, column);
    -- Don't check the location of the current button
    if ( left == column ) then
        left = left + 1;
    else
        right = right - 1;
    end
    -- Check for blocking talents
    local blocked = nil;
    for i=left, right do
        if ( ARMORY_TALENT_BRANCH_ARRAY[tier][i].id ) then
            -- If there's an id, there's a blocker
            blocked = 1;
        end
    end
    left = min(buttonColumn, column);
    right = max(buttonColumn, column);
    if ( not blocked ) then
        ARMORY_TALENT_BRANCH_ARRAY[tier][buttonColumn].down = requirementsMet;
        ARMORY_TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].up = requirementsMet;

        for i=tier, buttonTier - 1 do
            ARMORY_TALENT_BRANCH_ARRAY[i][buttonColumn].down = requirementsMet;
            ARMORY_TALENT_BRANCH_ARRAY[i + 1][buttonColumn].up = requirementsMet;
        end

        for i=left, right - 1 do
            ARMORY_TALENT_BRANCH_ARRAY[tier][i].right = requirementsMet;
            ARMORY_TALENT_BRANCH_ARRAY[tier][i+1].left = requirementsMet;
        end
        -- Place the arrow
        ARMORY_TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].topArrow = requirementsMet;
        return;
    end
    -- If we're here then we were blocked trying to go vertically first so we have to go over first, then up
    if ( left == buttonColumn ) then
        left = left + 1;
    else
        right = right - 1;
    end
    -- Check for blocking talents
    for i=left, right do
        if ( ARMORY_TALENT_BRANCH_ARRAY[buttonTier][i].id ) then
            -- If there's an id, then throw an error
            message("Error, this layout is undrawable "..ARMORY_TALENT_BRANCH_ARRAY[buttonTier][i].id);
            return;
        end
    end
    -- If we're here we can draw the line
    left = min(buttonColumn, column);
    right = max(buttonColumn, column);
    --TALENT_BRANCH_ARRAY[tier][column].down = requirementsMet;
    --TALENT_BRANCH_ARRAY[buttonTier][column].up = requirementsMet;

    for i=tier, buttonTier-1 do
        ARMORY_TALENT_BRANCH_ARRAY[i][column].up = requirementsMet;
        ARMORY_TALENT_BRANCH_ARRAY[i+1][column].down = requirementsMet;
    end

    -- Determine where the arrow goes
    if ( buttonColumn < column ) then
        ARMORY_TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].rightArrow =  requirementsMet;
    else
        ARMORY_TALENT_BRANCH_ARRAY[buttonTier][buttonColumn].leftArrow =  requirementsMet;
    end
end

-- Helper functions
function ArmoryTalentFrame_UpdateTalentPoints()
    local cp1, cp2 = Armory:UnitCharacterPoints("player");
    --ArmoryTalentFrameTalentPointsText:SetText(cp1);
    ArmoryTalentFrame.talentPoints = cp1;
end

function ArmorySetTalentButtonLocation(button, tier, column)
    column = ((column - 1) * 63) + ARMORY_INITIAL_TALENT_OFFSET_X;
    tier = -((tier - 1) * 63) - ARMORY_INITIAL_TALENT_OFFSET_Y;
    button:SetPoint("TOPLEFT", button:GetParent(), "TOPLEFT", column, tier);
end

function ArmoryTalentFrame_ResetBranches()
    for i=1, ARMORY_MAX_NUM_TALENT_TIERS do
        for j=1, ARMORY_NUM_TALENT_COLUMNS do
            ARMORY_TALENT_BRANCH_ARRAY[i][j].id = nil;
            ARMORY_TALENT_BRANCH_ARRAY[i][j].up = 0;
            ARMORY_TALENT_BRANCH_ARRAY[i][j].down = 0;
            ARMORY_TALENT_BRANCH_ARRAY[i][j].left = 0;
            ARMORY_TALENT_BRANCH_ARRAY[i][j].right = 0;
            ARMORY_TALENT_BRANCH_ARRAY[i][j].rightArrow = 0;
            ARMORY_TALENT_BRANCH_ARRAY[i][j].leftArrow = 0;
            ARMORY_TALENT_BRANCH_ARRAY[i][j].topArrow = 0;
        end
    end
end
