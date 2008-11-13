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
-- Customized Inbox UI

--[[ Currently not in use.
do
	local function inboxFrameSkeleton()
		return "frame#s:384:512#tl#p:MailFrame", {
			
		};
	end
	module.inboxFrame = module:getFrame(inboxFrameSkeleton);
end
]]