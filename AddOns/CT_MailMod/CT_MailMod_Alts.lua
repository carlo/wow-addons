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
-- Alt Recognition

local function addAlt(name)
	local alts = module:getOption("alts") or { };
	alts[name] = true;
	module:setOption("alts", alts);
end

function module:nameIsPlayer(name)
	return module:getOption("alts")[name];
end

module:regEvent("PLAYER_ENTERING_WORLD", function()
	addAlt(module:getPlayerName());
end);