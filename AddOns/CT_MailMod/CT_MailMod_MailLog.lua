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
-- General Logging

local function encodeLogMessage(success, type, mail, message)
	local entry;
	if ( success and mail ) then
		-- Format:
		--   success, type, receiver, sender, money, sent timestamp, num items (N)
		--   subject, item_1 string, item_2, string, ..., item_N string
		entry = ("1#%s#%s#%s#%d#%d#%d#%s"):format(type, mail.receiver, mail.sender,
				 mail.money, mail:getSendTime(), mail.items, mail.subject);
		
		-- Add the items
		for i = 1, mail.items, 1 do
			entry = entry .. ("#%s/%d"):format(mail:getItemInfo(i));
		end
		
	elseif ( not success and message ) then
		-- Format:
		--   success, type, message
		entry = ("0#%s#%s"):format(type, module:getText(message));
	end
	return entry;
end

function decodeLogMessage(message)
	local success, type, message = message:match("^(%d)#([^#]+)#(.+)$");
	if ( success == "1" ) then
		-- Success
		local receiver, sender, money, timestamp, numItems, message =
			message:match("^([^#]+)#([^#]+)#([^#]+)#([^#]+)#([^#]+)#(.+)$");
		local subject, items = message:match("^(.-)#("..("[^#]+#"):rep(tonumber(numItems)-1).."[^#]+)$");
		if ( not items ) then
			subject = message;
			items = "";
		end
		return true, type, receiver, sender, tonumber(money), tonumber(timestamp), subject, ("#"):split(items);
	else
		-- Failure
		return false, "failure", message;
	end
end

local function getLog()
	local log = module:getOption("mailLog") or { };
	module:setOption("mailLog", log);
	return log;
end

local function getLogMessage(id)
	local log = getLog();
	return log[#log+1-id]; -- Reversed
end

local function logMessage(self, type, success, mail, message)
	if ( self.printLog ) then
		local message = self:getText(message);
		if ( mail ) then
			message = ("%s: %s"):format(mail:getName(true), message);
		end
		( success and self.printformat or self.errorformat )("<MailMod> %s", message);
	end
	if ( self.saveLog ) then
		local entry = encodeLogMessage(success, type, mail, message);
		
		tinsert(getLog(), entry);
	end
end

--------------------------------------------
-- Incoming Mail Log

function module:logIncoming(...)
	return logMessage(self, "incoming", ...);
end

--------------------------------------------
-- Outgoing Mail Log

function module:logOutgoing( ...)
	return logMessage(self, "outgoing", ...);
end

--------------------------------------------
-- Mail Log UI

do
	local updateMailLog;
	local function mailLogFrameSkeleton()
		local scrollChild = {
			-- "texture#tl#br:0:1#1:1:1:0.25"
			"texture#s:40:20#l:5:0#i:icon",
			"font#s:100:20#l:55:0#i:receiver#v:ChatFontNormal##1:1:1:l",
			"font#s:100:20#l:160:0#i:sender#v:ChatFontNormal##1:1:1:l",
			"font#s:200:20#l:265:0#i:subject#v:ChatFontNormal##1:1:1:l",
			"font#tl:55:0#br:-5:0#i:message#v:ChatFontNormal##1:0:0:l",
			-- Having a moneyframe "here", but creating it dynamically later
			-- Having several icons "here", but creating them dynamically later
		}
		
		return "frame#n:CT_MailMod_MailLog#s:800:500", {
			"backdrop#tooltip#0:0:0:0.75",
			"font#t:0:-10#v:GameFontNormalHuge#MAIL_LOG#1:1:1",
			
			"font#tl:60:-47#v:GameFontNormalLarge#Receiver#1:1:1",
			"font#tl:165:-47#v:GameFontNormalLarge#Sender#1:1:1",
			"font#tl:270:-47#v:GameFontNormalLarge#Subject#1:1:1",
			"font#tl:475:-47#v:GameFontNormalLarge#Money#1:1:1",
			"font#tl:553:-47#v:GameFontNormalLarge#Items#1:1:1",
			
			--"font#tl:20:-40#v:GameFontNormalLarge#Filter:#1:1:1",
			--"dropdown#n:CT_MAILMOD_MAILLOGDROPDOWN1#tl:80:-43#All Mail#Incoming Mail#Outgoing Mail",
			--"dropdown#n:CT_MAILMOD_MAILLOGDROPDOWN2#tl:220:-43#i:charDropdown#All Characters",
			
			
			
			["button#s:100:25#tr:-5:-5#v:GameMenuButtonTemplate#Close"] = {
				["onclick"] = function(self)
					HideUIPanel(CT_MailMod_MailLog);
				end
			},
			--"button#s:100:25#tr:-135:-38#v:GameMenuButtonTemplate#Reset Data",
			"texture#tl:5:-67#br:tr:-5:-69#1:0.82:0",
			
			["frame#tl:5:-72#br:-5:5#i:scrollChildren"] = {
				["frame#s:0:20#tl:0:0#r#i:1"] = scrollChild,
				["frame#s:0:20#tl:0:-20#r#i:2"] = scrollChild,
				["frame#s:0:20#tl:0:-40#r#i:3"] = scrollChild,
				["frame#s:0:20#tl:0:-60#r#i:4"] = scrollChild,
				["frame#s:0:20#tl:0:-80#r#i:5"] = scrollChild,
				["frame#s:0:20#tl:0:-100#r#i:6"] = scrollChild,
				["frame#s:0:20#tl:0:-120#r#i:7"] = scrollChild,
				["frame#s:0:20#tl:0:-140#r#i:8"] = scrollChild,
				["frame#s:0:20#tl:0:-160#r#i:9"] = scrollChild,
				["frame#s:0:20#tl:0:-180#r#i:10"] = scrollChild,
				["frame#s:0:20#tl:0:-200#r#i:11"] = scrollChild,
				["frame#s:0:20#tl:0:-220#r#i:12"] = scrollChild,
				["frame#s:0:20#tl:0:-240#r#i:13"] = scrollChild,
				["frame#s:0:20#tl:0:-260#r#i:14"] = scrollChild,
				["frame#s:0:20#tl:0:-280#r#i:15"] = scrollChild,
				["frame#s:0:20#tl:0:-300#r#i:16"] = scrollChild,
				["frame#s:0:20#tl:0:-320#r#i:17"] = scrollChild,
				["frame#s:0:20#tl:0:-340#r#i:18"] = scrollChild,
				["frame#s:0:20#tl:0:-360#r#i:19"] = scrollChild,
				["frame#s:0:20#tl:0:-380#r#i:20"] = scrollChild,
				["frame#s:0:20#tl:0:-400#r#i:21"] = scrollChild,
			},
			
			["onload"] = function(self)
				self:EnableMouse(true);
				module:registerMovable("MAILLOG", self, true);
				
				-- Scroll Frame
				local scrollFrame = CreateFrame("ScrollFrame", "CT_MailMod_MailLog_ScrollFrame",
					self, "FauxScrollFrameTemplate");
				scrollFrame:SetPoint("TOPLEFT", self, 5, -72);
				scrollFrame:SetPoint("BOTTOMRIGHT", self, -26, 5);
				scrollFrame:SetScript("OnVerticalScroll", function()
					FauxScrollFrame_OnVerticalScroll(20, updateMailLog);
				end);
			end,
			
			["onmousedown"] = function(self, button)
				if ( button == "LeftButton" ) then
					module:moveMovable("MAILLOG");
				end
			end,
			
			["onmouseup"] = function(self, button)
				if ( button == "LeftButton" ) then
					module:stopMovable("MAILLOG");
				elseif ( button == "RightButton" ) then
					module:resetMovable("MAILLOG");
					self:ClearAllPoints();
					self:SetPoint("CENTER", UIParent);
				end
			end,
			
			["onenter"] = function(self)
				module:displayPredefinedTooltip(self, "DRAG");
			end,
			
			["onleave"] = function(self)
				module:hideTooltip();
			end
		};
	end
	
	local updateMailEntry, mailLogFrame;
	
	do
		local createMoneyFrame;
		do
			local moneyTypeInfo = {
				UpdateFunc = function()
					return this.staticMoney;
				end,
				collapse = 1,
				truncateSmallCoins = 1,
			};

			createMoneyFrame = function(parent, id) -- Local
				local frameName = "CT_MailMod_MailLogMoneyFrame"..id;
				local frame = CreateFrame("Frame", frameName, parent, "SmallMoneyFrameTemplate");
				
				_G[frameName.."GoldButton"]:EnableMouse(false);
				_G[frameName.."SilverButton"]:EnableMouse(false);
				_G[frameName.."CopperButton"]:EnableMouse(false);
				
				frame:SetPoint("LEFT", parent, "LEFT", 470, 0);
				frame.moneyType = "STATIC";
				frame.hasPickup = 0;
				frame.info = moneyTypeInfo
				return frame;
			end
		end
		
		local createItemFrame;
		do
			local function itemOnEnter(self)
				GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
				GameTooltip:SetHyperlink(self.link);
				GameTooltip:AddLine(("Item Count: \124cffffffff%d\r"):format(self.count), 1, 0.82, 0);
				GameTooltip:Show();
			end

			local function itemOnLeave(self)
				GameTooltip:Hide();
			end

			createItemFrame = function(parent, id) -- Local
				local button = CreateFrame("Button", nil, parent);
				button:SetWidth(16);
				button:SetHeight(16);
				button:SetPoint("LEFT", parent, "LEFT", 530+id*18, 0);
				button:SetScript("OnEnter", itemOnEnter);
				button:SetScript("OnLeave", itemOnLeave);
				return button;
			end
		end
		
		local function formatPlayer(name)
			if ( name == module:getPlayerName() ) then
				name = "\124cff888888Me\124r";
			elseif ( module:nameIsPlayer(name) ) then
				name = ("\124cffffd100%s\124r"):format(module:filterName(name));
			else
				name = module:filterName(name);
			end
			return name;
		end
		
		updateMailEntry = function(frame, i, success, type, receiver, sender, money, timestamp, subject, ...) -- Local
			local moneyFrame = frame.moneyFrame;
			local items = select('#', ...);
			
			frame.timestamp = timestamp;
			
			if ( success ) then
				-- Success
				
				-- Format players
				receiver = formatPlayer(receiver);
				sender = formatPlayer(sender);
				
				frame.receiver:SetText(receiver);
				frame.sender:SetText(sender);
				frame.subject:SetText(subject);
				frame.message:SetText("");
			else
				-- Failure
				money = 0;
				frame.receiver:SetText("");
				frame.sender:SetText("");
				frame.subject:SetText("");
				frame.message:SetText(receiver);
			end
			
			-- Icon
			frame.icon:SetTexture("Interface\\AddOns\\CT_MailMod\\Images\\mail_"..type);
			
			-- Handling money
			if ( money > 0 ) then
				if ( not moneyFrame ) then
					moneyFrame = createMoneyFrame(frame, i);
					frame.moneyFrame = moneyFrame;
				end
				moneyFrame:Show();
				MoneyFrame_Update(moneyFrame:GetName(), money);
			elseif ( moneyFrame ) then
				MoneyFrame_Update(moneyFrame:GetName(), 0);
				moneyFrame:Hide();
			end
			
			-- Handling items
			for y = 1, module.MAX_ATTACHMENTS, 1 do
				item = frame[tostring(y)];
				if ( y <= items ) then
					if ( not item ) then
						item = createItemFrame(frame, y);
					end
					local link, count = (select(y, ...));
					link, count = link:match("^([^/]+)/(.+)$");
					if ( link and count ) then
						item:SetNormalTexture(select(10, GetItemInfo(link)) or "Interface\\Icons\\INV_Misc_QuestionMark");
						item.link = link;
						item.count = count;
					else
						item:Hide();
					end
				elseif ( item ) then
					item:Hide();
				end
			end
		end
	end
	
	updateMailLog = function()
		FauxScrollFrame_Update(CT_MailMod_MailLog_ScrollFrame, #getLog(), 21, 20);
		local offset = FauxScrollFrame_GetOffset(CT_MailMod_MailLog_ScrollFrame);
		local tostring, children, frame = tostring, mailLogFrame.scrollChildren;
		
		for i = 1, 21, 1 do
			frame = children[tostring(i)];
			local entry = getLogMessage(i+offset);
			if ( entry ) then
				frame:Show();
				updateMailEntry(frame, i, decodeLogMessage(entry));
			else
				frame:Hide();
			end
		end
	end
	
	local function showMailLog()
		if ( not mailLogFrame ) then
			mailLogFrame = module:getFrame(mailLogFrameSkeleton);
		end
		tinsert(UISpecialFrames, "CT_MailMod_MailLog");
		ShowUIPanel(CT_MailMod_MailLog);
		updateMailLog();
	end
	
	module:setSlashCmd(showMailLog, "/maillog");
	module.showMailLog = showMailLog;
end