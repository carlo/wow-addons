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
-- Localization

-- Generic
module:setText("OPEN_SELECTED", "Open Selected");
module:setText("SELECT_ALL", "Select All");
module:setText("MAIL_LOG", "Mail Log");

-- Mass Mailing
module:setText("MASS_MAILING", "Mass Mailing");
module:setText("MASS_MAILING_INFO", "You may send as many items as you want to a single person. " ..
			   "Drag and drop an item to the green box below, or Alt+Right-Click an item in your inventory.");
module:setText("MASS_MAILING_ITEMS", "Items");
module:setText("MASS_MAILING_DROP_ITEMS", "Drop items here to add to mail.");
module:setText("MASS_MAILING_DROP_HERE", "Drop the item here to add it to the mail.");
module:setText("MASS_MAILING_CLICK_REMOVE", "Click to remove item from mail.");
module:setText("MASS_MAILING_POSTAGE", "Postage:");
module:setText("MASS_MAILING_SEND", "Send");
module:setText("MASS_MAILING_CANCEL", "Cancel");

-- Log messages
module:setText("MAIL_LOOT_ERROR", "A mail could not be looted because of an error (Inventory full?).");
module:setText("MAIL_OPEN_OK", "Mass opening in progress.");
module:setText("MAIL_OPEN_IS_COD", "The mail could not be opened: Mail is Cash on Delivery");
module:setText("MAIL_OPEN_NO_ITEMS_MONEY", "The mail could not be opened: Mail is empty");