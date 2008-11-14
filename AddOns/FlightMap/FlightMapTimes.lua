FLIGHTMAPTIMES_FADESTEP  = 0.05;
FLIGHTMAPTIMES_FLASHSTEP = 0.05;

-- Hooked functions
local lFMT_OldTakeTaxiNode;
local lFMT_OldSelectGossipOption;
local lFMT_OldTaxiNodeOnButtonEnter;
local lFMT_OldConfirmSummon;
local lFMT_OldAcceptBattlefieldPort;

StaticPopupDialogs["FLIGHT_CONFIRM"] = {
    text = TEXT(FLIGHTMAP_CONFIRM),
    button1 = TEXT(YES),
    button2 = TEXT(NO),
    OnAccept = function(self)
        -- Start the recorder -- this will also display the timer bar
        FlightMapTimesRecorderFrame_Show();
        -- Take the flight
        lFMT_OldTakeTaxiNode(self.data);
    end,
    timeout = 0,
    hideOnEscape = 1
};

-- TODO: Hook ConfirmSummon() and AcceptBattlefieldPort() to disable time
-- updates

-- Hook SelectGossipOption to watch for gossip based flights
function FlightMapTimes_SelectGossipOption(index)
    local optionTitle = nil;
    local optionType  = nil;
    local getGossipOption = function(...)
        if index * 2 <= select('#', ...) then
            optionTitle = select(index * 2 - 1, ...);
            optionType = select(index * 2, ...);
        end
    end

    getGossipOption(GetGossipOptions());

    -- If the gossip option exists, and is one of the flight types, then
    -- go ahead and set up as if it might be a flight
    if optionTitle and optionType == 'gossip' or optionType == 'taxi' then
        local unitName = UnitName('npc');

        -- Set up basic details
        FlightMapTimesRecorderFrame.flightType = 'gossip';
        FlightMapTimesRecorderFrame.sourceKey = unitName;
        FlightMapTimesRecorderFrame.destKey = optionTitle;
        FlightMapTimesRecorderFrame.destName = 'Flight';
        FlightMapTimesRecorderFrame.duration = nil;
        FlightMapTimesRecorderFrame.timeout = GetTime() + 5;

        -- Look for a known time for this flight
        local map = FlightMap.GossipFlights;
        if map[unitName] then
            local duration = map[unitName].Flights[optionTitle];
            FlightMapTimesRecorderFrame.duration = duration;
        end

        FlightMapTimesRecorderFrame_Show();
    end

    lFMT_OldSelectGossipOption(index);
end

-- Hook TakeTaxiNode() to determine where the player is flying 
function FlightMapTimes_TakeTaxiNode(id)
    -- Some AddOns call this function with an invalid ID!
    if not id or id < 1 or id > NumTaxiNodes() then
        return
    end

    -- Establish where we are and where we're going
    local thisNode, thatNode = nil, id;
    for index = 1, NumTaxiNodes(), 1 do
        local tType = TaxiNodeGetType(index)
        if (tType == "CURRENT") then
            thisNode = index;
            break;
        end
    end

    -- Dig out the flight time data
    local map = FlightMapUtil.getFlightMap();

    -- Get the current continent number
    local cont = FlightMapUtil.getContinent();

    -- Construct node names
    local source = FlightMapUtil.makeNodeName(cont,
            TaxiNodePosition(thisNode));
    local dest = FlightMapUtil.makeNodeName(cont,
            TaxiNodePosition(thatNode));

    -- Set the flight type
    FlightMapTimesRecorderFrame.flightType = 'taxi';

    -- Check if this flight path has a known duration
    if map[source] and map[source].Flights[dest] then
        FlightMapTimesRecorderFrame.duration = map[source].Flights[dest];
    else
        FlightMapTimesRecorderFrame.duration = nil;
    end
    FlightMapTimesRecorderFrame.source = map[source];
    FlightMapTimesRecorderFrame.sourceKey = source;
    FlightMapTimesRecorderFrame.destKey = dest;

    -- Get a shortened name for the destination
    local nodeName = FlightMapUtil.getNameAndZone(TaxiNodeName(thatNode));
    FlightMapTimesRecorderFrame.destName = nodeName;

    -- Check for confirmation box
    if FlightMap.Opts.confirmFlights then
        local name = TaxiNodeName(thatNode);
        local duration = "";

        if map[dest] then name = map[dest].Name; end
        if map[source] and map[source].Flights[dest] then
            local seconds = map[source].Flights[dest];
            local timer = FlightMapUtil.formatTime(seconds);
            duration = FLIGHTMAP_CONFIRM_TIME;
            duration = duration .. timer;
        end
        local dialog = StaticPopup_Show("FLIGHT_CONFIRM", name, duration);
        if dialog then dialog.data = thatNode; end;

        -- Hide the times frame; it will get shown if the flight is accepted.
        FlightMapTimesFrame:Hide();
    else
        -- Get ourselves airborne
        FlightMapTimesRecorderFrame_Show();
        lFMT_OldTakeTaxiNode(id);
    end
end

-- Hook TaxiNodeOnButtonEnter() to show flight times; this is hooked
-- after the Blizzard UI function so that the tooltip can be replaced
-- with one featuring additional information.
function FlightMapTimes_TaxiNodeOnButtonEnter(button)
    -- Let old function get its job done
    lFMT_OldTaxiNodeOnButtonEnter(button);

    -- Establish a node key
    local index = button:GetID();
    local thisCont = FlightMapUtil.getContinent();
    local x, y = TaxiNodePosition(index);
    local nodeKey = FlightMapUtil.makeNodeName(thisCont, x, y);  

    -- Establish a source node
    local sourceKey;
    for i = 1, NumTaxiNodes(), 1 do
        if TaxiNodeGetType(i) == "CURRENT" then
            local x, y = TaxiNodePosition(i);
            sourceKey = FlightMapUtil.makeNodeName(thisCont, x, y);
        end
    end

    -- Recreate the tooltip!
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
    FlightMapUtil.addFlightsForNode(GameTooltip, nodeKey, "", sourceKey);
    SetTooltipMoney(GameTooltip, TaxiNodeCost(button:GetID()));
    GameTooltip:Show();
end

function FlightMapTimes_OnLoad(self)
    lFMT_OldTakeTaxiNode = TakeTaxiNode;
    lFMT_OldSelectGossipOption = SelectGossipOption;
    if Sea and Sea.util and Sea.util.hook then
        lFMT_OldTaxiNodeOnButtonEnter = function() end;
        lFMT_OldSelectGossipOption = function() end;
        Sea.util.hook("TakeTaxiNode", "FlightMapTimes_TakeTaxiNode", "replace");
        Sea.util.hook("SelectGossipOption",
                "FlightMapTimes_SelectGossipOption", "before");
        Sea.util.hook("TaxiNodeOnButtonEnter",
                "FlightMapTimes_TaxiNodeOnButtonEnter", "after");
    else
        lFMT_OldTaxiNodeOnButtonEnter = TaxiNodeOnButtonEnter;
        TakeTaxiNode = FlightMapTimes_TakeTaxiNode;
        TaxiNodeOnButtonEnter = FlightMapTimes_TaxiNodeOnButtonEnter;
        SelectGossipOption = FlightMapTimes_SelectGossipOption;
    end
    self:RegisterForDrag("LeftButton");
    FlightMapTimesFlash:SetAlpha(0);
end

local function lSaveFlightTime(length, from, to, flightType)
    -- Check for locked times
    if FlightMap.Opts.lockFlightTimes then return; end

    -- TODO: check for summoned/battlegrounded

    -- Where to store the flight time?
    local map = FlightMapUtil.getFlightMap();
    if flightType == 'gossip' then
        map = FlightMap.GossipFlights;
        if not map[from] then
            map[from] = {Flights = {}}
        end
    end

    if map[from] then
        map[from].Flights[to] = length;
    end
end

function FlightMapTimes_OnUpdate(self, elapsed)
    -- Make sure the user is still airborne
    if not UnitOnTaxi("player") then
        local alpha = self:GetAlpha() - FLIGHTMAPTIMES_FADESTEP;
        local flash = FlightMapTimesFlash:GetAlpha();
        -- Flash the overlay in
        if flash < 1 then
            flash = flash + FLIGHTMAPTIMES_FLASHSTEP;
            if flash > 1 then flash = 1; end
            FlightMapTimesFlash:SetAlpha(flash);
        -- Fade the bar out
        elseif alpha > 0 then
            self:SetAlpha(alpha);
        else
            -- Hide up, reset alpha/flash
            self:SetWidth(195);
            self:Hide();
            self:SetAlpha(1.0);
            FlightMapTimesFlash:SetAlpha(0);
        end
    else
        local dest = ": "..self.destination;
        local label;
        local now = GetTime();
        -- If the time was too short, wipe it out and save a new one!
        if (self.endTime and self.endTime < now) then
            self.endTime = nil;
            FlightMapTimesFrame:SetMinMaxValues(0, 100);
            FlightMapTimesFrame:SetValue(100);
            FlightMapTimesFrame:SetStatusBarColor(0.0, 0.0, 1.0);
            FlightMapTimesSpark:Hide();
        end

        -- Update the spark, status bar and label
        if (self.endTime) then
            local remains = self.endTime - now;
            label = FlightMapUtil.formatTime(remains, true)..dest;
            local sparkPos = ((now - self.startTime)
                            / (self.endTime - self.startTime)) * self:GetWidth();
            FlightMapTimesSpark:SetPoint("CENTER",
                    "FlightMapTimesFrame", "LEFT", sparkPos, 2);
            FlightMapTimesFrame:SetValue(now);
        else
            label = string.format(FLIGHTMAP_TIMING,FlightMapUtil.formatTime(now - self.startTime))..dest;
        end
        FlightMapTimesText:SetText(label);

        -- If alpha is below one, fade-in is active
        local alpha = self:GetAlpha();
        if (alpha < 1) then
            alpha = alpha + FLIGHTMAPTIMES_FADESTEP * 4;
            if (alpha > 1) then alpha = 1; end
            self:SetAlpha(alpha);
        end
    end
end

-- Hookable function: display a flight bar
function FlightMapTimes_BeginFlight(duration, destination)
    -- If timer display is disabled, just return
    if not FlightMap.Opts.useTimer then return; end

    -- Update all variables
    FlightMapTimesFrame.destination = destination;
    FlightMapTimesFrame.duration = duration;
    FlightMapTimesFrame.startTime = GetTime();
    if FlightMapTimesFrame.duration ~= nil then
        FlightMapTimesFrame.endTime = FlightMapTimesFrame.startTime
                                    + FlightMapTimesFrame.duration;

        -- Prepare status bar and spark
        FlightMapTimesFrame:SetMinMaxValues(
                FlightMapTimesFrame.startTime,
                FlightMapTimesFrame.endTime);
        FlightMapTimesFrame:SetValue(FlightMapTimesFrame.startTime);
        FlightMapTimesFrame:SetStatusBarColor(1.0, 0.7, 0.0);
        FlightMapTimesSpark:Show();
    else
        FlightMapTimesFrame.endTime = nil;

        -- Prepare status bar and spark
        FlightMapTimesFrame:SetMinMaxValues(0, 100);
        FlightMapTimesFrame:SetValue(100);
        FlightMapTimesFrame:SetStatusBarColor(0.0, 0.0, 1.0);
        FlightMapTimesSpark:Hide();
    end

    -- Prepare to fade in
    FlightMapTimesFrame:SetAlpha(0);
    FlightMapTimesFrame:Show();
end

-- Hookable function: hide a flight bar
function FlightMapTimes_EndFlight()
    -- Nothing needs to be done for FlightMap's built-in timer bar
end

-- Reset all of the state variables
function FlightMapTimesRecorderFrame_Show()
    FlightMapTimesRecorderFrame.started = false;
    FlightMapTimesRecorderFrame:Show();
end

-- Take care of monitoring flight status
function FlightMapTimesRecorderFrame_OnUpdate(self, elapsed)
    -- Wait for us to be in flight; when we are, set up all variables
    -- and tell the flight timer bar to show itself
    if not self.started then
        local now = GetTime();
        if UnitOnTaxi("player") then
            self.started = true;
            self.startTime = now;
            if self.duration then
                self.endTime = self.startTime + self.duration;
            else
                self.endTime = nil;
            end

            FlightMapTimes_BeginFlight(self.duration, self.destName);
        elseif self.flightType == 'gossip' and self.timeout <= now then
            -- Time out waiting to get onto the bird, this gossip was not
            -- a flight
            self:Hide();
        end
    elseif not UnitOnTaxi("player") then
        -- If the player is no longer in the air, then the ride is over
        self:Hide();

        -- Update the flight's duration
        local length = GetTime() - self.startTime;
        lSaveFlightTime(length, self.sourceKey, self.destKey, self.flightType);

        FlightMapTimes_EndFlight();
    end
end

-- Movable window
function FlightMapTimes_OnDragStart(self)
    if IsShiftKeyDown() then
        FlightMapTimesFrame:StartMoving();
    end
end

function FlightMapTimes_OnDragStop(self)
    FlightMapTimesFrame:StopMovingOrSizing();
end
