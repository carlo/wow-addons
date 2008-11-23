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

local outMail = { };
local outMail_meta = { __index = outMail };

-- Creates the main mail structure.
function module:newOutgoingMail(...)
	mail = setmetatable(self:getTable(), outMail_meta);
	mail:populate(...);
	mail["sender"] = self:getPlayerName();
	mail["items"] = 0;
	mail["itemTbl"] = self:getTable();
	return mail;
end

function outMail:populate(to, subject, text)
	self["receiver"] = module:getPlayerName(to);
	self["receiverName"] = to;
	self["subject"] = subject;
	self["text"] = text;
end

function outMail:getData()
	return self["receiverName"], self["subject"], self["text"];
end

function outMail:getName()
	return string.format("'%s', To %s", self.subject, self.receiverName);
end

function outMail:addItem(container, slot)
	if ( container and slot ) then
		local itemTbl = self.itemTbl;
		tinsert(itemTbl, container);
		tinsert(itemTbl, slot);
		self.items = self.items + 1;
	end
end

function outMail:removeItem(i)
	local items = self.items;
	if ( items >= i ) then
		self.items = items - 1;
		local slot, container = tremove(self.itemTbl, i*2), tremove(self.itemTbl, i*2-1);
		return container, slot;
	end
end

function outMail:getSendDate()
	return date("%a, %b %d %I:%M%p");
end

function outMail:getSendTime()
	return time();
end

do
	local function iter(tbl, i)
		i = i + 1;
		local v = tbl[i*2-1];
		if ( v ) then
			return i, v, tbl[i*2];
		end
	end
	
	function outMail:iterItems()
		return iter, self.itemTbl, 0;
	end
end

--------------------------------------------
-- Retrieval of various things

function outMail:getItemInfo(id)
	id = id*2-1;
	local container, slot = self.itemTbl[id], self.itemTbl[id+1];
	
	local link = GetContainerItemLink(container, slot);
	return link:match("|H(item:[^|]+)|h"), (select(2, GetContainerItemInfo(container, slot)));
end

function outMail:getNumMails()
	local items = self.items;
	if ( items == 0 ) then
		return 1;
	else
		return math.ceil(self.items/module.MAX_ATTACHMENTS);
	end
end

function outMail:getCost()
	local items = self.items;
	if ( items == 0 ) then
		return 30;
	else
		return items * 30;
	end
end

function module:getMailCost(items)
	if ( items == 0 ) then
		return 30;
	else
		return items * 30;
	end
end

--------------------------------------------
-- Sending Related

function outMail:flagSent()
	self.sent = true;
end

function outMail:isSent()
	return self.sent;
end

do
	local canSend = true;
	local function waitSent()
		return canSend;
	end
	
	module:regEvent("MAIL_SEND_SUCCESS", function()
		canSend = true;
	end);

	function outMail:send()
		if ( canSend and not self:isSent() ) then
			local MAX_ATTACHMENTS = module.MAX_ATTACHMENTS;
			local numMails = self:getNumMails();

			-- Split into several mails if necessary
			for i = numMails, 2, -1 do
				local mail = module:newOutgoingMail(self:getData())
				for i = math.min(i*12, self.items), (i-1)*12+1, -1 do
					mail:addItem(self:removeItem(i));
				end
				module:addMailAction(mail, "send");
			end

			for id, container, slot in self:iterItems() do
				if ( id <= MAX_ATTACHMENTS ) then
					PickupContainerItem(container, slot);
					ClickSendMailItemButton(id);
				end
			end

			SendMail(self.receiverName, self.subject, self.text);
			
			canSend = false;
			self:flagSent();
		end
		return waitSent;
	end
end