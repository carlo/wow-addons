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
-- Mail Action Queue

local getMailAction, popMailAction;
do
	local actionQueue = { };
	local mailQueue = { };
	
	function module:addMailAction(mail, action)
		if ( mailQueue and action ) then
			tinsert(mailQueue, mail);
			tinsert(actionQueue, action);
		end
	end
	
	function module:clearMailActions()
		if ( #actionQueue > 0 ) then
			module:clearTable(actionQueue);
			module:clearTable(mailQueue);
			return true;
		end
	end
	
	function module:purgeMailActions(mail)
		for i = #mailQueue, 1, -1 do
			if ( mailQueue[i] == mail ) then
				tremove(actionQueue, i);
				tremove(mailQueue, i);
			end
		end
	end
	
	popMailAction = function() -- Local
		return tremove(mailQueue, 1), tremove(actionQueue, 1);
	end
	
	getMailAction = function() -- Local
		return mailQueue[1], actionQueue[1];
	end
end

--------------------------------------------
-- Mail Action Handlers

-- In order for a function to act as a mail action, the following
-- things must be taken into consideration:

-- The return value of the mail action function decides
-- which action to take:

-- true: The action succeeded. Wait .5 sec second and then try the next action.
-- false: The action succeeded, but no wait is necessary.
-- x (number, in seconds): Wait x seconds before retrying the action.
-- function: retry this action until the function returns true.

module:registerMailUpdater(0.5, function(self, func)
	while ( true ) do
		local mail, action = getMailAction();
		if ( mail and action ) then
			local ret = mail[action](mail);
			if ( type(ret) == "number" ) then
				self:rescheduleMailUpdater(ret, func);
				break;
			elseif ( type(ret) ~= "function" or ret(mail) ) then
				popMailAction();
				if ( ret ) then
					break;
				end
			else
				break;
			end
		else
			break;
		end
	end
end);