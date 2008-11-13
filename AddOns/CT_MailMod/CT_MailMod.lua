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

--------------------------------------------
-- Initialization

local module = { };
local _G = getfenv(0);

local MODULE_NAME = "CT_MailMod";
local MODULE_VERSION = strmatch(GetAddOnMetadata(MODULE_NAME, "version"), "^([%d.]+)");

module.name = MODULE_NAME;
module.version = MODULE_VERSION;

_G[MODULE_NAME] = module;
CT_Library:registerModule(module);

-- Max attachment slots
module.MAX_ATTACHMENTS = 12;

--------------------------------------------
-- Table Pool

do
	local tblPool = setmetatable({ }, { __mode="v" }); -- Weak table (values)
	
	function module:getTable()
		return tremove(tblPool) or { };
	end
	
	function module:releaseTable(tbl)
		self:clearTable(tbl, true);
		tinsert(tblPool, tbl);
	end
end

--------------------------------------------
-- Mail Updaters

do
	local updaters = { };
	local startValues = { };
	
	function module:registerMailUpdater(t, func)
		startValues[func] = t;
		updaters[func] = t;
	end
	
	function module:rescheduleMailUpdater(t, func)
		updaters[func] = t;
	end
	
	local f = CreateFrame("Frame");
	local pairs = pairs; -- Local copy for speed
	
	f:SetScript("OnUpdate", function(self, elapsed)
		for key, value in pairs(updaters) do
			value = value - elapsed;
			if ( value <= 0 ) then
				key(module, key);
				updaters[key] = startValues[key] + value;
			else
				updaters[key] = value;
			end
		end
	end);
	
	f:SetScript("OnEvent", function(self, event)
		if ( event == "MAIL_SHOW" ) then
			self:Show();
		else
			self:Hide();
		end
	end);
	
	f:RegisterEvent("MAIL_SHOW");
	f:RegisterEvent("MAIL_CLOSED");
	f:Hide();
end

--------------------------------------------
-- Incoming Mail List

do
	local mailList = { };
	local numMails = 0;
	
	local function mailListSort(a, b)
		return a.id < b.id;
	end
	
	function module:clearMailList()
		-- Clear all currently stored mail
		for key, value in pairs(mailList) do
			self:releaseTable(value);
			mailList[key] = nil;
		end
	end
	
	function module:updateMailList(force)
		local numInboxItems = GetInboxNumItems();
		if ( numInboxItems == numMails and not force ) then
			return;
		end
		numMails = numInboxItems;
		-- Store all the timeleft fields of our current mails
		local cachedTimes = self:getTable();
		for key, value in ipairs(mailList) do
			cachedTimes[value.timeleft] = value;
		end
		
		-- Loop through our mail, and update any records that changed id's.
		local timeleft, entry;
		local sort = false;
		for i = 1, numInboxItems, 1 do
			timeleft = select(7, GetInboxHeaderInfo(i));
			entry = cachedTimes[timeleft];
			if ( entry ) then
				entry.id = i;
				entry:update();
				cachedTimes[timeleft] = nil;
				sort = true;
			else
				tinsert(mailList, i, self:loadMail(i));
			end
		end
		
		-- Since we unset the cachedTimes entries for mail that was
		-- updated, any mail that is still left in the table
		-- is mail that was deleted or is otherwise now missing.
		for key, value in pairs(cachedTimes) do
			value:flagDeleted();
			self:purgeMailFromList(value);
			self:purgeMailActions(value);
		end
		
		if ( sort ) then
			-- Sort our mail list to make sure the keys match the .id attributes
			table.sort(mailList, mailListSort);
		end
		self:releaseTable(cachedTimes);
	end
	
	function module:getMailList()
		return mailList;
	end
	
	function module:getMail(id)
		return mailList[id];
	end
	
	function module:purgeMailFromList(mail)
		for key, value in ipairs(mailList) do
			if ( value == mail ) then
				tremove(mailList, key);
				return;
			end
		end
	end
end

--------------------------------------------
-- Updating

do
	local function closeMailbox()
		module:clearMailList();
		module:clearMailActions();
	end

	local function inventoryFull()
		if ( module:clearMailActions() ) then
			-- We successfully cleared one or more pending actions
			module:logIncoming(false, nil, "MAIL_LOOT_ERROR");
		end
	end

	local lootErrors = {
		[ERR_ITEM_MAX_COUNT] = true,
		[ERR_INV_FULL] = true
	};

	local function onEvent(event, arg1)
		if ( event == "UI_ERROR_MESSAGE" and lootErrors[arg1] ) then
			inventoryFull(arg1);
		else
			module:updateMailList(event == "MAIL_SHOW");
		end
	end

	-- Update the mail list when the inbox updates or is shown
	module:regEvent("MAIL_INBOX_UPDATE", onEvent);
	module:regEvent("MAIL_SHOW", onEvent);

	-- 
	module:regEvent("UI_ERROR_MESSAGE", onEvent);

	-- Clear the mail list when the inbox closes
	module:regEvent("MAIL_CLOSED", closeMailbox);
end