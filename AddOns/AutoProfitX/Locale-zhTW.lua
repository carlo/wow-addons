local L = AceLibrary("AceLocale-2.2"):new("AutoProfitX")

L:RegisterTranslations("zhTW", function() return {
		--commands
		["options"] = "選項",
		["Show options panel."] = "顯示設定選項",
		["add"] = "新增例外",
		["Add items to global ignore list."] = "新增物品到例外列表",
		["<item link>[<item link>...]"] = "<物品連結>[<物品連結>...]",
		["rem"] = "移除例外",
		["Remove items from global ignore list."] = "移除例外列表中的物品",
		["me"] = "切換例外",
		["Add or remove an item from your exception list."] = "新增或移除例外物品",
		["list"] = "顯示例外",
		["List your exceptions."] = "顯示例外列表",
		
		--options
		["Addon Options"] = "插件選項",
		["Auto Sell"] = "自動販售",
		["Automatically sell junk items when opening vendor window."] = "和商人談話時自動販售灰色物品",
		["Sales Reports"] = "販售通告",
		["Print items being sold in chat frame."] = "在聊天視窗顯示販售的物品",
		["Show Profit"] = "顯示獲利",
		["Print total profit after sale."] = "顯示販售的總獲利",
		["Sell Soulbound"] = "販賣拾榜物品",
		["Sell unusable soulbound items."] = "販賣不能用的拾榜物品",
		["Acquire Unsafe Links"] = "取得不安全的連結",
		["Automatically get information about unsafe item links. (CAUTION: may cause you to disconnect when displaying exception list!!!)"] = "自動向伺服器取得不安全的鍊結的資料, 這有可能會造成斷線",
		["Button Animation Options"] = "按扭動畫",
		["Set up when you want the treasure pile in the button to spin."] = "設定販售按鈕的動畫",
		["Never spin"] = "不轉動",
		["Mouse-over and profit"] = "滑鼠經過或售出物品時",
		["Mouse-over"] = "滑鼠經過",
		["Profits"] = "售出物品時",
		["Spin when you mouse-over the button and there is junk to vendor."] = "當滑鼠經過按鈕或是售出物品時轉動",
		["Spin every time you mouse over."] = "當滑鼠經過按鈕時轉動",
		["Spin every time there is junk to sell."] = "當售出物品時轉動",
		["Reset Button Pos"] = "重置按鈕位置",
		["Reset APX button position on the vendor screen to the top right corner."] = "將自動販售的按鈕重置到視窗右上角",
		["Exception List"] = "例外列表",
		["Clear Exceptions"] = "清除例外列表",
		["Remove all items from exception list."] = "清除例外列表中的所有物品",
		["Import Exception List"] = "匯入例外列表",
		["Choose character to import exceptions from. Your exceptions will be deleted."] = "選擇你要匯入例外列表的角色, 目前角色的例外列表會先被清除",
		
		--functions
		["Added %s to exception list for all characters."] = "將 %s 加入所有角色的例外列表", 		--%s is item link
		["Invalid item link provided."] = "不合法的物品連結",
		["Removed %s from all exception lists."] = "將 %s 自所有角色的例外列表中移除",		--%s is item link
		["Removed %s from exception list."] = "將 %s 自例外列表中移除",		--%s is item link
		["Added %s to exception list."] = "將 %s 加入例外列表",		--%s is item link
		["Exceptions:"] = "例外物品:",
		["Your exception list is empty."] = "你的例外列表是空的",
		["Deleted all exceptions."] = "刪除所有例外物品",
		["Exception list imported from %s on %s."] = "(%s 於 %s) 的例外列表已匯入",		--first %s - character name, second %s - realm
		["Exception list could not be found for %s on %s."] = "(%s 於 %s) 並沒有例外列表",		--first %s - character name, second %s - realm
		["Sold %s."] = "售出 %s",		--%s - item link
		
		--button functions
		["Total profits: %s"] = "全部售價: %s",		--%s is value of all the junk sold
		["Sell Junk Items"] = "出售灰色物品",
		["You have no junk items in your inventory."] = "你的背包裡並沒有灰色物品",
		
		--temporary features
		["Update Exception List"] = "更新例外物品",
		["Update exception list from pre 2.0 AutoProfitX version."] = "更新舊的例外物品列表",
		["Exceptions updated."] = "例外物品已更新",

	} end)