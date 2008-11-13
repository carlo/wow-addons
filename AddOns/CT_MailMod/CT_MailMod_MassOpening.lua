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
-- Mass Opening

function module:selectAll(select)
	select = ( select == nil or select );
	for key, value in ipairs(self:getMailList()) do
		value:flagMassOpen(select);
	end
	
	module:raiseCustomEvent("SELECT_ALL", select);
end

function module:openSelected()
	-- Opens all mail flagged as "mass open".
	for key, value in ipairs(self:getMailList()) do
		if ( value:isMassOpen() ) then
			self:addMailAction(value, "retrieveAll");
		end
		value:unflagMassOpen();
	end
	self:selectAll(false);
end

--------------------------------------------
-- Quick Opening

local obj;
for i = 1, INBOXITEMS_TO_DISPLAY, 1 do
	obj = _G["MailItem"..i.."Button"];
	oldFunc = obj:GetScript("OnClick");
	obj:SetScript("OnClick", function(self, button)
		if ( button == "RightButton" and IsAltKeyDown() ) then
			module:addMailAction(module:getMail(self.index), "retrieveAll");
			return;
		end
		oldFunc(self, button);
	end);
end

local oldInboxFrameItem_OnEnter = InboxFrameItem_OnEnter;
function InboxFrameItem_OnEnter(...)
	oldInboxFrameItem_OnEnter(...);
	if ( not this.cod ) then
		GameTooltip:AddLine("Press Alt-Right-Click to quick open.", 1, 1, 0.5);
		GameTooltip:Show();
	end
end