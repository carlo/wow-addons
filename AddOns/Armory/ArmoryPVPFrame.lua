--[[
    Armory Addon for World of Warcraft(tm).
    Revision: $Id: ArmoryPVPFrame.lua,v 1.16, 2008-10-12 18:24:56Z, Maxim Baars$
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


function ArmoryPVPFrame_OnLoad(self)
    ArmoryPVPFrameLine1:SetAlpha(0.3);
    ArmoryPVPHonorKillsLabel:SetVertexColor(0.6, 0.6, 0.6);
    ArmoryPVPHonorHonorLabel:SetVertexColor(0.6, 0.6, 0.6);
    ArmoryPVPHonorTodayLabel:SetVertexColor(0.6, 0.6, 0.6);
    ArmoryPVPHonorYesterdayLabel:SetVertexColor(0.6, 0.6, 0.6);
    ArmoryPVPHonorLifetimeLabel:SetVertexColor(0.6, 0.6, 0.6);

    self:RegisterEvent("ARENA_TEAM_UPDATE");
    self:RegisterEvent("ARENA_TEAM_ROSTER_UPDATE");
    self:RegisterEvent("PLAYER_PVP_KILLS_CHANGED");
    self:RegisterEvent("PLAYER_PVP_RANK_CHANGED");
    self:RegisterEvent("HONOR_CURRENCY_UPDATE");
end

function ArmoryPVPFrame_OnEvent(self, event, ...)
    local arg1 = ...;
    if ( not Armory:CanHandleEvents() ) then
        return;
    elseif ( event == "ARENA_TEAM_UPDATE" ) then
        ArmoryPVPFrame_Update();
    elseif ( event == "ARENA_TEAM_ROSTER_UPDATE" ) then
        ArmoryPVPFrame_Update();
    else
        ArmoryPVPHonor_Update();
    end
end

function ArmoryPVPFrame_OnShow(self)
    ArmoryPVPFrame_Update();
end

function ArmoryPVPFrame_SetFaction()
    local factionGroup = Armory:UnitFactionGroup("player");
    if ( factionGroup ) then
        ArmoryPVPFrameHonorIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
        ArmoryPVPFrameHonorIcon:Show();
    end
end

function ArmoryPVPFrame_OnHide(self)
    ArmoryPVPTeamDetails:Hide();
end

function ArmoryPVPFrame_Update()
    Armory:UpdateArenaTeams();

    ArmoryPVPFrame_SetFaction();
    ArmoryPVPHonor_Update();
    ArmoryPVPTeam_Update();

    if ( ArmoryPVPTeamDetails:IsShown() ) then
        local team = Armory:GetArenaTeam(ArmoryPVPTeamDetails.team);
        if ( team ) then
            ArmoryPVPTeamDetails_Update(ArmoryPVPTeamDetails.team);
        else
            ArmoryPVPTeamDetails:Hide();
        end
    end
end

function ArmoryPVPTeam_Update()
    -- Display Elements
    local button, buttonName, highlight, data, standard, emblem, border;
    -- Data Elements
    local teamName, teamSize, teamRating, teamPlayed, teamWins, teamLoss, seasonTeamPlayed, seasonTeamWins, playerPlayed, playerPlayedPct, teamRank, playerRating;
    local background = {};
    local borderColor = {};
    local emblemColor = {};
    local ARENA_TEAMS = {};
    ARENA_TEAMS[1] = {size = 2};
    ARENA_TEAMS[2] = {size = 3};
    ARENA_TEAMS[3] = {size = 5};

    -- Sort teams by size

    local buttonIndex = 0;
    for index, value in pairs(ARENA_TEAMS) do
        for i=1, MAX_ARENA_TEAMS do
            teamName, teamSize = Armory:GetArenaTeam(i);
            if ( value.size == teamSize ) then
                value.index = i;
            end
        end
    end

    -- fill out data
    for index, value in pairs(ARENA_TEAMS) do
        buttonIndex = buttonIndex + 1;
        button = getglobal("ArmoryPVPTeam"..buttonIndex);
        if ( value.index ) then
            -- Pull Values
            teamName, teamSize, teamRating, teamPlayed, teamWins, seasonTeamPlayed, seasonTeamWins, playerPlayed, seasonPlayerPlayed, teamRank, playerRating, background.r, background.g, background.b, emblem, emblemColor.r, emblemColor.g, emblemColor.b, border, borderColor.r, borderColor.g, borderColor.b = Armory:GetArenaTeam(value.index);

            -- Only show season related info
            teamPlayed = seasonTeamPlayed;
            teamWins = seasonTeamWins;
            playerPlayed = seasonPlayerPlayed;

            teamLoss = teamPlayed - teamWins;
            if ( teamPlayed ~= 0 ) then
                playerPlayedPct =  floor( ( playerPlayed / teamPlayed ) * 100 );        
            else
                playerPlayedPct =  floor( ( playerPlayed / 1 ) * 100 );
            end

            -- Set button elements to variables 
            buttonName = "ArmoryPVPTeam"..buttonIndex;
            data = buttonName.."Data";
            standard = buttonName.."Standard";

            button:SetID(value.index);

            -- Populate Data
            getglobal(data.."TypeLabel"):SetText(ARENA_THIS_SEASON);
            getglobal(data.."Name"):SetText(teamName);
            getglobal(data.."Rating"):SetText(teamRating);
            getglobal(data.."Games"):SetText(teamPlayed);
            getglobal(data.."Wins"):SetText(teamWins);
            getglobal(data.."Loss"):SetText(teamLoss);

            getglobal(data.."Played"):SetText(playerRating);
            getglobal(data.."Played"):SetVertexColor(1.0, 1.0, 1.0);
            getglobal(data.."PlayedLabel"):SetText(RATING);

            -- Set TeamSize Banner
            getglobal(standard.."Banner"):SetTexture("Interface\\PVPFrame\\PVP-Banner-"..teamSize);
            getglobal(standard.."Banner"):SetVertexColor(background.r, background.g, background.b);
            getglobal(standard.."Border"):SetVertexColor(borderColor.r, borderColor.g, borderColor.b);
            getglobal(standard.."Emblem"):SetVertexColor(emblemColor.r, emblemColor.g, emblemColor.b);
            if ( border ~= -1 ) then
                getglobal(standard.."Border"):SetTexture("Interface\\PVPFrame\\PVP-Banner-"..teamSize.."-Border-"..border);
            end
            if ( emblem ~= -1 ) then
                getglobal(standard.."Emblem"):SetTexture("Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-"..emblem);
            end

            -- Set visual elements
            getglobal(data):Show();
            button:SetAlpha(1);
            getglobal(buttonName.."Highlight"):SetAlpha(1);
            getglobal(buttonName.."Highlight"):SetBackdropBorderColor(1.0, 0.82, 0);
            getglobal(standard):SetAlpha(1);
            getglobal(standard.."Border"):Show();
            getglobal(standard.."Emblem"):Show();
            getglobal(buttonName.."Background"):SetVertexColor(0, 0, 0);
            getglobal(buttonName.."Background"):SetAlpha(1);
            getglobal(buttonName.."TeamType"):Hide();
        else
            -- Set button elements to variables 
            buttonName = "ArmoryPVPTeam"..buttonIndex;
            data = buttonName.."Data";

            -- Set standard type
            local standardBanner = getglobal(buttonName.."StandardBanner");
            standardBanner:SetTexture("Interface\\PVPFrame\\PVP-Banner-"..value.size);
            standardBanner:SetVertexColor(1, 1, 1);

            -- Hide or Show items
            button:SetAlpha(0.4);
            getglobal(data):Hide();
            getglobal(buttonName.."Background"):SetVertexColor(0, 0, 0);
            getglobal(buttonName.."Standard"):SetAlpha(0.1);
            getglobal(buttonName.."StandardBorder"):Hide();
            getglobal(buttonName.."StandardEmblem"):Hide();
            getglobal(buttonName.."TeamType"):SetFormattedText(PVP_TEAMSIZE, value.size, value.size);
            getglobal(buttonName.."TeamType"):Show();
        end
    end
end

function ArmoryPVPTeam_OnEnter(self)
    local highlight = getglobal(self:GetName().."Highlight");
    if ( Armory:GetArenaTeam(self:GetID()) ) then
        highlight:Show();
        GameTooltip_AddNewbieTip(self, ARENA_TEAM, 1.0, 1.0, 1.0, CLICK_FOR_DETAILS, 1);
    end        
end

function ArmoryPVPTeamDetails_OnShow(self)
    PlaySound("igSpellBookOpen");
end

function ArmoryPVPTeamDetails_OnHide(self)
    PlaySound("igSpellBookClose");
end

function ArmoryPVPTeamDetails_Update(id)
    local numMembers = Armory:GetNumArenaTeamMembers(id, 1);
    local name, rank, level, class, online, played, win, loss, seasonPlayed, seasonWin, seasonLoss, rating;
    local teamName, teamSize, teamRating, teamPlayed, teamWins,  seasonTeamPlayed, seasonTeamWins, playerPlayed, seasonPlayerPlayed, teamRank, personalRating  = Armory:GetArenaTeam(id);        
    local button;
    local teamIndex;

    -- Display General Team Stats
    ArmoryPVPTeamDetailsName:SetText(teamName);
    ArmoryPVPTeamDetailsSize:SetFormattedText(PVP_TEAMSIZE, teamSize, teamSize);
    ArmoryPVPTeamDetailsRank:SetText(teamRank);
    ArmoryPVPTeamDetailsRating:SetText(teamRating);

    -- Display General Team Data
    ArmoryPVPTeamDetailsGames:SetText(seasonTeamPlayed);
    ArmoryPVPTeamDetailsWins:SetText(seasonTeamWins);
    ArmoryPVPTeamDetailsLoss:SetText(seasonTeamPlayed - seasonTeamWins);
    ArmoryPVPTeamDetailsStatsType:SetText(strupper(ARENA_THIS_SEASON));

    local nameText, classText, playedText, winLossWin, winLossLoss, ratingText;
    local nameButton, classButton, playedButton, winLossButton;
    -- Display Team Member Specific Info
    local playedValue, winValue, lossValue, playedPct;
    for i=1, MAX_ARENA_TEAM_MEMBERS, 1 do
        button = getglobal("ArmoryPVPTeamDetailsButton"..i);
        if ( i > numMembers ) then
            button:Hide();
        else

            button.teamIndex = i;
            -- Get Data
            name, rank, level, class, online, played, win, seasonPlayed, seasonWin, rating = Armory:GetArenaTeamRosterInfo(id, i);
            loss = played - win;
            seasonLoss = seasonPlayed - seasonWin;
            if ( class ) then
                button.tooltip = LEVEL.." "..level.." "..class;
            else
                button.tooltip = LEVEL.." "..level;
            end

            -- Populate Data into the display
            playedValue = seasonPlayed;
            winValue = seasonWin;
            lossValue = seasonLoss;
            teamPlayed = seasonTeamPlayed;

            if ( teamPlayed ~= 0 ) then
                playedPct =  floor( ( playedValue / teamPlayed ) * 100 );        
            else
                playedPct =  floor( (playedValue / 1 ) * 100 );
            end

            if ( playedPct < 10 ) then
                getglobal("ArmoryPVPTeamDetailsButton"..i.."PlayedText"):SetVertexColor(1.0, 0, 0);
            else
                getglobal("ArmoryPVPTeamDetailsButton"..i.."PlayedText"):SetVertexColor(1.0, 1.0, 1.0);
            end

            playedPct = format("%d", playedPct);

            getglobal("ArmoryPVPTeamDetailsButton"..i.."Played").tooltip = playedPct.."%";

            nameText = getglobal("ArmoryPVPTeamDetailsButton"..i.."NameText");
            classText = getglobal("ArmoryPVPTeamDetailsButton"..i.."ClassText");
            playedText = getglobal("ArmoryPVPTeamDetailsButton"..i.."PlayedText")
            winLossWin = getglobal("ArmoryPVPTeamDetailsButton"..i.."WinLossWin");
            winLossLoss = getglobal("ArmoryPVPTeamDetailsButton"..i.."WinLossLoss");
            ratingText = getglobal("ArmoryPVPTeamDetailsButton"..i.."RatingText");

            --- Not needed after Arena Season 3 change.
            nameButton = getglobal("ArmoryPVPTeamDetailsButton"..i.."Name");
            classButton = getglobal("ArmoryPVPTeamDetailsButton"..i.."Class");
            playedButton = getglobal("ArmoryPVPTeamDetailsButton"..i.."Played")
            winLossButton = getglobal("ArmoryPVPTeamDetailsButton"..i.."WinLoss");

            nameText:SetText(name);
            classText:SetText(class);
            playedText:SetText(playedValue);
            winLossWin:SetText(winValue)
            winLossLoss:SetText(lossValue);
            ratingText:SetText(rating);

            -- Color Entries based on Online status
            local r, g, b;
            if ( online ) then
                if ( rank > 0 ) then
                    r = 1.0;
                    g = 1.0;
                    b = 1.0;
                else
                    r = 1.0;
                    g = 0.82;
                    b = 0.0;
                end
            else
                r = 0.5;
                g = 0.5;
                b = 0.5;
            end

            nameText:SetTextColor(r, g, b);
            classText:SetTextColor(r, g, b);
            playedText:SetTextColor(r, g, b);
            winLossWin:SetTextColor(r, g, b);
            getglobal("ArmoryPVPTeamDetailsButton"..i.."WinLoss-"):SetTextColor(r, g, b);
            winLossLoss:SetTextColor(r, g, b);
            ratingText:SetTextColor(r, g, b);

            button:Show();
        end
    end
end

function ArmoryPVPTeam_OnClick(self, id)
    local teamName, teamSize = Armory:GetArenaTeam(id);
    if ( not teamName ) then
        return;
    else
        if ( ArmoryPVPTeamDetails:IsShown() and id == ArmoryPVPTeamDetails.team ) then
            ArmoryPVPTeamDetails:Hide();
        else
            ArmoryCloseChildWindows();
            ArmoryPVPTeamDetails.team = id;
            ArmoryPVPTeamDetails_Update(id);
            ArmoryPVPTeamDetails:Show();
        end
    end
end

function ArmoryPVPTeam_OnMouseDown(self)
    if ( Armory:GetArenaTeam(self:GetID()) ) then
        local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint();
        self:SetPoint(point, relativeTo, relativePoint, offsetX-2, offsetY-2);
    end
end

function ArmoryPVPTeam_OnMouseUp(self)
    if ( Armory:GetArenaTeam(self:GetID()) ) then
        local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint();
        self:SetPoint(point, relativeTo, relativePoint, offsetX+2, offsetY+2);
    end
end

-- PVP Honor Data
function ArmoryPVPHonor_Update()
    local hk, cp, contribution;

    -- Yesterday's values
    hk, contribution = Armory:GetPVPYesterdayStats();
    ArmoryPVPHonorYesterdayKills:SetText(hk);
    ArmoryPVPHonorYesterdayHonor:SetText(contribution);

    -- Lifetime values
    hk, contribution =  Armory:GetPVPLifetimeStats();
    ArmoryPVPHonorLifetimeKills:SetText(hk);
    ArmoryPVPFrameHonorPoints:SetText(Armory:GetHonorCurrency());
    ArmoryPVPFrameArenaPoints:SetText(Armory:GetArenaCurrency())    

    -- Today's values
    hk, cp = Armory:GetPVPSessionStats();
    ArmoryPVPHonorTodayKills:SetText(hk);
    ArmoryPVPHonorTodayHonor:SetText(cp);
    ArmoryPVPHonorTodayHonor:SetHeight(14);
end
