------------------------------------------------
--                 CT_MailMod                 --
--                                            --
-- Mail several items at once with almost no  --
-- effort at all. Also takes care of opening  --
-- several mail items at once, reducing the   --
-- time spent on maintaining the inbox for    --
-- bank mules and such.                       --
-- Please do not modify or otherwise          --
-- redistribute this without the consent of   --
-- the CTMod Team. Thank you.                 --
------------------------------------------------

local _G = getfenv(0);
local module = _G["CT_MailMod"];

--------------------------------------------
-- Utility Functions

function module:getTimeFromOffset(dayOffset)
	local seconds = math.floor(dayOffset*(24*3600)+0.5);
	local tbl = date("*t");
	tbl.sec = tbl.sec + seconds;
	return time(tbl);
end

function module:getPlayerName(name)
	name = name or UnitName("player");
	return ("%s @ %s"):format(name, GetCVar("realmName"));
end

function module:filterName(str)
	local name, realm = str:match("^(.-) @ (.+)$");
	if ( realm == GetCVar("realmName") ) then
		return name;
	else
		return str;
	end
end

--------------------------------------------
-- Custom Events

do
	local events = { };
	
	function module:regCustomEvent(event, func)
		local tbl = events[event] or { };
		tinsert(tbl, func);
		events[event] = tbl;
	end
	
	function module:raiseCustomEvent(event, ...)
		local tbl = events[event];
		if ( tbl ) then
			for key, value in ipairs(tbl) do
				value(self, event, ...);
			end
		end
	end
end

--------------------------------------------
-- Block Trades

do
	local function resetBlock()
		SetCVar("blockTrades", module:getOption("lastBlock"));
	end
	
	function module:blockTrades(block)
		block = ( block == nil or block );
		if ( block ) then
			module:setOption("lastBlock", GetCVar("blockTrades"), true);
			SetCVar("blockTrades", 1);
		else
			resetBlock();
		end
	end
	
	module:regEvent("PLAYER_ENTERING_WORLD", resetBlock);
	module:regEvent("MAIL_CLOSED", resetBlock);
	module:regEvent("MAIL_SHOW", function()
		module:blockTrades(module:getOption("blockTrades"));
	end);
	
end

--------------------------------------------
-- Alt+Click to Initiate Trade

do
	local prepareTrade;
	do
		local prepBag, prepItem, prepPlayer;
		local function clearTrade()
			prepBag, prepItem, prepPlayer = nil;
		end
		
		prepareTrade = function(bag, item, player) -- Local
			prepBag, prepItem, prepPlayer = bag, item, player;
			module:schedule(3, clearTrade);
		end
		
		module:regEvent("TRADE_SHOW", function()
			if ( prepBag and prepItem and UnitName("NPC") == prepPlayer ) then
				PickupContainerItem(prepBag, prepItem);
				ClickTradeButton(1);
			end
			clearTrade();
		end);
	end
	
	local oldFunc = ContainerFrameItemButton_OnModifiedClick;
	function ContainerFrameItemButton_OnModifiedClick(...)
		local bag, item = this:GetParent():GetID(), this:GetID(); -- Ugly, but can't be helped
		if ( (...) == "LeftButton" and IsAltKeyDown() ) then
			if ( not CursorHasItem() and 
			     ( not TradeFrame or not TradeFrame:IsVisible() ) and
			     ( not AuctionFrame or not AuctionFrame:IsVisible() ) and
			     UnitExists("target") and
			     CheckInteractDistance("target", 2) and
			     UnitIsFriend("player", "target") and
			     UnitIsPlayer("target")
			) then
				InitiateTrade("target");
				prepareTrade(bag, item, UnitName("target"));
				return;
			end
		end
		return oldFunc(...);
	end
end