local L = AceLibrary("AceLocale-2.2"):new("AutoProfitX")

L:RegisterTranslations("enUS", function() return {
		--commands
		--["/autoprofitx"] = true,
		["/apx"] = true,
		["options"] = true,
		["Show options panel."] = true,
		["add"] = true,
		["Add items to global ignore list."] = true,
		["<item link>[<item link>...]"] = true,
		["rem"] = true,
		["Remove items from global ignore list."] = true,
		["me"] = true,
		["Add or remove an item from your exception list."] = true,
		["list"] = true,
		["List your exceptions."] = true,
		
		--options
		["Addon Options"] = true,
		["Auto Sell"] = true,
		["Automatically sell junk items when opening vendor window."] = true,
		["Sales Reports"] = true,
		["Print items being sold in chat frame."] = true,
		["Show Profit"] = true,
		["Print total profit after sale."] = true,
		["Sell Soulbound"] = true,
		["Sell unusable soulbound items."] = true,
		--no longer used
		--["Acquire Unsafe Links"] = true,
		--["Automatically get information about unsafe item links. (CAUTION: may cause you to disconnect when displaying exception list!!!)"] = true,
		["Button Animation Options"] = true,
		["Set up when you want the treasure pile in the button to spin."] = true,
		["Never spin"] = true,
		["Mouse-over and profit"] = true,
		["Mouse-over"] = true,
		["Profits"] = true,
		["Spin when you mouse-over the button and there is junk to vendor."] = true,
		["Spin every time you mouse over."] = true,
		["Spin every time there is junk to sell."] = true,
		["Reset Button Pos"] = true,
		["Reset APX button position on the vendor screen to the top right corner."] = true,
		["Exception List"] = true,
		["Clear Exceptions"] = true,
		["Remove all items from exception list."] = true,
		["Import Exception List"] = true,
		["Choose character to import exceptions from. Your exceptions will be deleted."] = true,
		
		--functions
		["Added %s to exception list for all characters."] = true, 		--%s is item link
		["Invalid item link provided."] = true,
		["Removed %s from all exception lists."] = true,		--%s is item link
		["Removed %s from exception list."] = true,		--%s is item link
		["Added %s to exception list."] = true,		--%s is item link
		["Exceptions:"] = true,
		["Your exception list is empty."] = true,
		["Deleted all exceptions."] = true,
		["Exception list imported from %s on %s."] = true,		--first %s - character name, second %s - realm
		["Exception list could not be found for %s on %s."] = true,		--first %s - character name, second %s - realm
		["Sold %s."] = true,		--%s - item link
		
		--button functions
		["Total profits: %s"] = true,		--%s is value of all the junk sold
		["Sell Junk Items"] = true,
		["You have no junk items in your inventory."] = true,
		
		--temporary features
		["Update Exception List"] = true,
		["Update exception list from pre 2.0 AutoProfitX version."] = true,
		["Exceptions updated."] = true,
		
		--FeatureFrame
		["OneKey Sell"] = true,
		["OneKey sell junk items when opening vendor window"] = true,
		
		--Price
		["g "] = true,
		["s "] = true,
		["c"] = true,
		
		--misc
		["LIST_SEPARATOR"] = ", ",		--separator used to separate words in a list for exmple ", " in rogue, mage, warrior. This is used to split classes listed in the tooltips under Class:
	} end)