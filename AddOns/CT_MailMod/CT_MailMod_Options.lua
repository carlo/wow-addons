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
-- Options Window

module.frame = function()
	return "frame#all", {
		"font#tl:5:-5#v:GameFontNormalLarge#CT Team Tip",
		"font#t:0:-20#l:25:0#r#s:0:100#v:ChatFontNormal#You can hold ALT and click an item in your inventory"..
			" to add it to the mail window.  Doing this while targeting a player will add"..
			" items to trade, or open a trade window.  Doing this at the auction house will"..
			" add an item to the auction house window.#l",
		
		"font#tl:5:-125#v:GameFontNormalLarge#Options",
		"checkbutton#tl:10:-145#o:blockTrades#Block Trades When Using Mailbox",
		"checkbutton#tl:10:-165#o:printLog#Print Log Messages to Chat",
		"checkbutton#tl:10:-185#o:saveLog:true#Save Log Messages to /maillog",
	};
end

module.update = function(self, type, value)
	if ( type == "blockTrades" ) then
		if ( MailFrame:IsVisible() ) then
			self:blockTrades(value);
		end
	elseif ( type == "saveLog" ) then
		self.saveLog = value;
	elseif ( type == "printLog" ) then
		self.printLog = value;
	elseif ( type == "init" ) then
		self.saveLog = self:getOption("saveLog") or true;
		self.printLog = self:getOption("printLog");
	end
end