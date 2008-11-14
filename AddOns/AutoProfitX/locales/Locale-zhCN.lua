local L = AceLibrary("AceLocale-2.2"):new("AutoProfitX")

L:RegisterTranslations("zhCN", function() return {
		--commands
		--["/autoprofitx"] = "/autoprofix",
		["/apx"] = "/apx",
		["options"] = "选项",
		["Show options panel."] = "显示设定选项",
		["add"] = "添加例外",
		["Add items to global ignore list."] = "添加物品到例外列表",
		["<item link>[<item link>...]"] = "<物品连结>[<物品连结>...]",
		["rem"] = "移除例外",
		["Remove items from global ignore list."] = "移除例外列表中的物品",
		["me"] = "切换例外",
		["Add or remove an item from your exception list."] = "添加或移除例外物品",
		["list"] = "显示例外",
		["List your exceptions."] = "显示例外列表",
		
		--options
		["Addon Options"] = "插件选项",
		["Auto Sell"] = "自动贩卖",
		["Automatically sell junk items when opening vendor window."] = "和商人谈话时自动贩卖灰色物品",
		["Sales Reports"] = "贩卖通告",
		["Print items being sold in chat frame."] = "在聊天窗口显示贩卖的物品",
		["Show Profit"] = "显示获利",
		["Print total profit after sale."] = "显示贩卖的总获利",
		["Sell Soulbound"] = "贩卖拾绑物品",
		["Sell unusable soulbound items."] = "贩卖不能用的拾绑物品",
		--no longer used
		--["Acquire Unsafe Links"] = "取得不安全的链接",
		--["Automatically get information about unsafe item links. (CAUTION: may cause you to disconnect when displaying exception list!!!)"] = "自动向服务器搜索不安全的链接的数据, 这有可能会造成断线",
		["Button Animation Options"] = "按扭动画",
		["Set up when you want the treasure pile in the button to spin."] = "设定贩卖按钮的动画",
		["Never spin"] = "不转动",
		["Mouse-over and profit"] = "鼠标经过或售出物品时",
		["Mouse-over"] = "鼠标经过",
		["Profits"] = "售出物品时",
		["Spin when you mouse-over the button and there is junk to vendor."] = "当鼠标经过按钮或是售出物品时转动",
		["Spin every time you mouse over."] = "当鼠标经过按钮时转动",
		["Spin every time there is junk to sell."] = "当售出物品时转动",
		["Reset Button Pos"] = "重置按钮位置",
		["Reset APX button position on the vendor screen to the top right corner."] = "将自动贩卖的按钮重置到窗口右上角",
		["Exception List"] = "例外列表",
		["Clear Exceptions"] = "清除例外列表",
		["Remove all items from exception list."] = "清除例外列表中的所有物品",
		["Import Exception List"] = "加入例外列表",
		["Choose character to import exceptions from. Your exceptions will be deleted."] = "选择你要加入例外列表的角色, 目前角色的例外列表会先被清除",
		
		--functions
		["Added %s to exception list for all characters."] = "将 %s 加入所有角色的例外列表", 		--%s is item link
		["Invalid item link provided."] = "不合法的物品连结",
		["Removed %s from all exception lists."] = "将 %s 自所有角色的例外列表中移除",		--%s is item link
		["Removed %s from exception list."] = "将 %s 自例外列表中移除",		--%s is item link
		["Added %s to exception list."] = "将 %s 加入例外列表",		--%s is item link
		["Exceptions:"] = "例外物品:",
		["Your exception list is empty."] = "你的例外列表是空的",
		["Deleted all exceptions."] = "删除所有例外物品",
		["Exception list imported from %s on %s."] = "(%s 于 %s) 的例外列表已汇入",		--first %s - character name, second %s - realm
		["Exception list could not be found for %s on %s."] = "(%s 于 %s) 并没有例外列表",		--first %s - character name, second %s - realm
		["Sold %s."] = "售出 %s",		--%s - item link
		
		--button functions
		["Total profits: %s"] = "全部售价: %s",		--%s is value of all the junk sold
		["Sell Junk Items"] = "出售灰色物品",
		["You have no junk items in your inventory."] = "你的背包里并没有灰色物品",
		
		--temporary features
		["Update Exception List"] = "更新例外物品",
		["Update exception list from pre 2.0 AutoProfitX version."] = "更新旧的例外物品列表",
		["Exceptions updated."] = "例外物品已更新",
		
		--FeatureFrame
		["OneKey Sell"] = "一键贩卖",
		["OneKey sell junk items when opening vendor window"] = "在和NPC交易时一键/自动贩卖灰色垃圾物品，支持过滤",
		
		--Price
		["g "] = "金 ",
		["s "] = "银 ",
		["c"] = "铜",

	} end)
