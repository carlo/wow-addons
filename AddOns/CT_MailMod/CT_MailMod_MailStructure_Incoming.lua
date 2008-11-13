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
-- Incoming Mail Structure

local incMail = { };
local incMail_meta = { __index = incMail };

-- Creates the main mail structure.
function module:loadMail(id)
	mail = setmetatable(self:getTable(), incMail_meta);
	mail["id"] = id;
	mail:update();
	return mail;
end

function incMail:update()
	local _, _, sender, subject, money, cod, timeleft, items, read,
				returned, hasText, canReply = GetInboxHeaderInfo(self.id);
	self["sender"] = module:getPlayerName(sender);
	self["subject"] = subject;
	self["money"] = money;
	self["cod"] = cod;
	self["timeleft"] = timeleft;
	self["read"] = read;
	self["returned"] = returned;
	self["hasText"] = hasText;
	self["items"] = items or 0;
	self["receiver"] = module:getPlayerName();
end

function incMail:checkInvalid()
	if ( self.cod > 0 ) then
		return "MAIL_OPEN_IS_COD";
	elseif ( self.items == 0 and self.money == 0 and self.hasText ) then
		return "MAIL_OPEN_NO_ITEMS_MONEY";
	end
end

function incMail:canDelete()
	self:update();
	return ( self.items == 0 and self.money == 0 and not self.hasText );
end

-- Deletes a mail and clears out the mail structure
function incMail:delete()
	if ( self:canDelete() ) then
		GetInboxText(self.id);
		DeleteInboxItem(self.id);
		return true;
	end
end

-- Flags a mail as deleted, which can be used to check if
-- the given mail was successfully deleted.
function incMail:flagDeleted()
	self.deleted = true;
end

function incMail:isDeleted()
	return self.deleted;
end

function incMail:getName(light)
	if ( light ) then
		return string.format("'%s', From %s", self.subject, self.sender);
	else
		return string.format("'%s', From %s (Sent %s)", self.subject, self.sender, self:getSendDate());
	end
end

function incMail:getSendDate()
	return date("%a, %b %d %I:%M%p", self:getSendTime());
end

function incMail:getSendTime()
	return module:getTimeFromOffset(-self.timeleft);
end

--------------------------------------------
-- Retrieval of various things

function incMail:getItemInfo(id)
	local link = GetInboxItemLink(self.id, id);
	return link:match("|H(item:[^|]+)|h"), (select(3, GetInboxItem(self.id, id)));
end

-- Retrieves money from a mail
function incMail:retrieveMoney()
	if ( self:isDeleted() ) then return; end
	
	self.money = 0;
	TakeInboxMoney(self.id);
	return true;
end

-- Retrieves an item from a mail
function incMail:retrieveItem(index)
	if ( self:isDeleted() ) then return; end
	
	local mailId = self.id;
	
	-- If index doesn't exist, find the first available item
	if ( not index ) then
		index = 1;
		while ( GetInboxItemLink(mailId, index) ) do
			index = index + 1;
		end
		index = index - 1;
	end
	
	local link = GetInboxItemLink(mailId, index);
	if ( link ) then
		TakeInboxItem(mailId, index);
		self.items = self.items - 1;
		return true;
	end
	return false;
end

function incMail:retrieveAll()
	if ( self:isDeleted() ) then return; end
	
	-- Retrieves all items and money from a mail
	
	self:update(); -- Make sure we have accurate data
	local invalidReason = self:checkInvalid();
	if ( invalidReason and not self.processed ) then
		-- Mail is invalid, log the error.
		module:logIncoming(false, self, invalidReason);
		return false;
	else
		-- Mail is valid, retrieve it.
		if ( not self.processed ) then
			-- First time opening the mail, log it
			module:logIncoming(true, self, "MAIL_OPEN_OK");
			self.processed = true;
		end
		
		
		if ( self.money > 0 ) then
			self:retrieveMoney();
			return 0.5; -- Wait 0.5 sec
		end
		
		if ( self.items > 0 ) then
			self:retrieveItem();
			return 0.5; -- Wait 0.5 sec
		end
		
		self:delete();
		return self.isDeleted; -- Check to make sure it is deleted before we move on
	end
end

--------------------------------------------
-- Mass Opening-related

function incMail:flagMassOpen(flag)
	self.massOpen = ( flag == nil or flag );
end

function incMail:unflagMassOpen()
	self:flagMassOpen(false);
end

function incMail:isMassOpen()
	return self.massOpen;
end