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
-- Modified Stock UI

-- Move the icons to the right
do

	MailItem1:SetPoint("TOPLEFT", "InboxFrame", "TOPLEFT", 48, -80);
	local item;
	for i = 1, 7, 1 do
		item = _G["MailItem"..i];
		item:SetWidth(280);
		_G["MailItem" .. i .. "ExpireTime"]:SetPoint("TOPRIGHT", item, "TOPRIGHT", 10, -4);
	end
end

-- Add the "Open Selected" and "Select All" buttons
local selectAll;
do
	module:getFrame( {
		["button#s:120:25#l:t:10:-53#v:UIPanelButtonTemplate#OPEN_SELECTED"] = {
			["onclick"] = function(self, arg1)
				if ( arg1 == "LeftButton" ) then
					module:openSelected();
				end
			end
		},
		
		["checkbutton#s:24:24#l:tl:85:-53#v:OptionsCheckButtonTemplate##1:0.82:0"] = {
			["onclick"] = function(self, arg1)
				module:selectAll(self:GetChecked() or false);
				if ( self:GetChecked() ) then
					PlaySound("igMainMenuOptionCheckBoxOn");
				else
					PlaySound("igMainMenuOptionCheckBoxOff");
				end
			end,
			["onload"] = function(self)
				self.text:SetText(module:getText("SELECT_ALL"));
				selectAll = self;
			end,
			["onenter"] = function(self)
				self.text:SetTextColor(1, 1, 1);
			end,
			["onleave"] = function(self)
				self.text:SetTextColor(1, 0.82, 0);
			end
		}
	}, InboxFrame);
end


-- Add the checkboxes
do
	local checkboxes = { };
	local checkboxTbl;
	local function checkboxFunc()
		if ( not checkboxTbl ) then
			checkboxTbl = {
				["onclick"] = function(self, arg1)
					local id = self:GetID() + (InboxFrame.pageNum-1)*INBOXITEMS_TO_DISPLAY;
					local mail = module:getMail(id);
					if ( mail ) then
						mail:flagMassOpen(self:GetChecked() or false);
					end
					if ( self:GetChecked() ) then
						PlaySound("igMainMenuOptionCheckBoxOn");
					else
						PlaySound("igMainMenuOptionCheckBoxOff");
						selectAll:SetChecked(false);
					end
				end
			}
		end
		
		return "checkbutton#s:24:24#r:l:1:0#v:UICheckButtonTemplate", checkboxTbl;
	end
	
	local btn, item, obj, oldFunc;
	for i = 1, INBOXITEMS_TO_DISPLAY, 1 do
		btn = module:getFrame(checkboxFunc, _G["MailItem"..i]);
		btn:SetID(i);
		checkboxes[i] = btn;
	end
	
	module:regCustomEvent("SELECT_ALL", function(self, event, select)
		for key, value in ipairs(checkboxes) do
			value:SetChecked(select);
		end
	end);
	
	hooksecurefunc("InboxFrame_Update", function()
		local offset = (InboxFrame.pageNum-1)*INBOXITEMS_TO_DISPLAY;
		local mail;
		for key, value in ipairs(checkboxes) do
			mail = module:getMail(key+offset);
			if ( mail and mail:isMassOpen() ) then
				value:SetChecked(true);
			else
				value:SetChecked(false);
			end
		end
	end);
end

-- Add the mail log button
do
	local btn = CreateFrame("Button", nil, InboxFrame, "GameMenuButtonTemplate");
	btn:SetWidth(120); btn:SetHeight(25);
	btn:SetText(module:getText("MAIL_LOG"));
	btn:SetPoint("BOTTOM", 0, 90);
	btn:SetScript("OnClick", module.showMailLog);
end