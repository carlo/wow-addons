-- AutoBar
-- http://code.google.com/p/autobar/
-- Courtesy of PDI175
-- Translation updated by lostcup


local L = AceLibrary("AceLocale-2.2"):new("AutoBar")

L:RegisterTranslations("zhCN", function() return {
		["AUTOBAR"] = "消耗品助手",
		["CONFIG_WINDOW"] = "设置窗口",
		["SLASHCMD_LONG"] = "/autobar",
		["SLASHCMD_SHORT"] = "/atb",
		["BUTTON"] = "按钮",
		["EDITSLOT"] = "编辑按钮",
		["VIEWSLOT"] = "察看按钮",
		["LOAD_ERROR"] = "|cff00ff00载入 AutoBarConfig 发生错误。 请确定是否有这个插件，并启用插件。|r 错误：",
		["Toggle the config panel"] = "切换消耗品助手设置窗口",
		["Empty"] = "空白",

		--  AutoBarConfig.lua
		["EMPTY"] = "空";
		["STYLE"] = "风格",
		["STYLE_TIP"] = "改变插件风格",
		["DEFAULT"] = "默认",
		["ZOOMED"] = "放大",
		["DREAMLAYOUT"] = "梦幻",
		["AUTOBAR_CONFIG_DISABLERIGHTCLICKSELFCAST"] = "关闭右键自动施法";
		["AUTOBAR_CONFIG_REMOVECAT"] = "移除当前种类";
		["AUTOBAR_CONFIG_ROW"] = "行";
		["AUTOBAR_CONFIG_COLUMN"] = "列";
		["AUTOBAR_CONFIG_GAPPING"] = "图标间隔";
		["AUTOBAR_CONFIG_ALPHA"] = "图标透明度";
		["AUTOBAR_CONFIG_BUTTONWIDTH"] = "按钮宽度";
		["AUTOBAR_CONFIG_BUTTONHEIGHT"] = "按钮高度";
		["AUTOBAR_CONFIG_DOCKSHIFTX"] = "调整左右依附距离";
		["AUTOBAR_CONFIG_DOCKSHIFTY"] = "调整上下依附距离";
		["AUTOBAR_CONFIG_WIDTHHEIGHTUNLOCKED"] = "不锁定按钮长宽比";
		["AUTOBAR_CONFIG_HIDEKEYBINDING"] = "隐藏快捷键显示";
		["AUTOBAR_CONFIG_HIDECOUNT"] = "隐藏数量显示";
		["AUTOBAR_CONFIG_SHOWEMPTY"] = "显示空按钮";
		["AUTOBAR_CONFIG_SHOWCATEGORYICON"] = "显示物品种类图示";
		["AUTOBAR_CONFIG_HIDETOOLTIP"] = "隐藏提示讯息";
		["AUTOBAR_CONFIG_POPUPDIRECTION"] = "按钮\n弹出\n方向";
		["AUTOBAR_CONFIG_POPUPONSHIFT"] = "按 Shift 弹出按钮";
		["AUTOBAR_CONFIG_HIDEDRAGHANDLE"] = "隐藏拖曳点";
		["AUTOBAR_CONFIG_FRAMESTRATA"] = "提高框体优先级";
		["AUTOBAR_CONFIG_CTRLSHOWSDRAGHANDLE"] = "按 Ctrl 显示拖曳点";
		["AUTOBAR_CONFIG_LOCKACTIONBARS"] = "当锁定 AutoBar 时，\n锁定动作条";
		["AUTOBAR_CONFIG_PLAINBUTTONS"] = "隐藏按钮边框";
		["AUTOBAR_CONFIG_NOPOPUP"] = "不弹出";
		["AUTOBAR_CONFIG_ARRANGEONUSE"] = "使用后重新排列顺序";
		["AUTOBAR_CONFIG_RIGHTCLICKTARGETSPET"] = "右键以宠物为目标";
		["AUTOBAR_CONFIG_DOCKTONONE"] = "无";
		["AUTOBAR_CONFIG_BT3BAR"] = "Bartender3动作条";
		["AUTOBAR_CONFIG_DOCKTOMAIN"] = "主菜单条";
		["AUTOBAR_CONFIG_DOCKTOCHATFRAME"] = "对话框架";
		["AUTOBAR_CONFIG_DOCKTOCHATFRAMEMENU"] = "对话框架菜单";
		["AUTOBAR_CONFIG_DOCKTOACTIONBAR"] = "动作条";
		["AUTOBAR_CONFIG_DOCKTOMENUBUTTONS"] = "菜单按钮";
		["AUTOBAR_CONFIG_ALIGN"] = "按钮排列方向";
		["AUTOBAR_CONFIG_NOTFOUND"] = "(未发现：物品 ";
		["AUTOBAR_CONFIG_SLOTEDITTEXT"] = " 栏位 (左键编辑)";
		["AUTOBAR_CONFIG_CHARACTER"] = "角色";
		["AUTOBAR_CONFIG_SHARED"] = "共用";
		["AUTOBAR_CONFIG_CLASS"] = "职业";
		["AUTOBAR_CONFIG_BASIC"] = "基本";
		["AUTOBAR_CONFIG_USECHARACTER"] = "使用角色";
		["AUTOBAR_CONFIG_USESHARED"] = "使用共用";
		["AUTOBAR_CONFIG_USECLASS"] = "使用职业";
		["AUTOBAR_CONFIG_USEBASIC"] = "使用基本";
		["AUTOBAR_CONFIG_HIDECONFIGTOOLTIPS"] = "隐藏设定提示讯息";
		["AUTOBAR_CONFIG_OSKIN"] = "使用 oSkin";
		["AUTOBAR_CONFIG_PERFORMANCE"] = "记录性能";
		["AUTOBAR_CONFIG_CHARACTERLAYOUT"] = "设定为角色专用";
		["AUTOBAR_CONFIG_SHAREDLAYOUT"] = "设定为共享";
		["AUTOBAR_CONFIG_SHARED1"] = "共享 1";
		["AUTOBAR_CONFIG_SHARED2"] = "共享 2";
		["AUTOBAR_CONFIG_SHARED3"] = "共享 3";
		["AUTOBAR_CONFIG_SHARED4"] = "共享 4";
		["AUTOBAR_CONFIG_EDITCHARACTER"] = "编辑角色的栏位";
		["AUTOBAR_CONFIG_EDITSHARED"] = "编辑共享的栏位";
		["AUTOBAR_CONFIG_EDITCLASS"] = "编辑职业的栏位";
		["AUTOBAR_CONFIG_EDITBASIC"] = "编辑基本的栏位";

		-- AutoBarCategory
		["Misc.Engineering.Fireworks"] = "工程焰火",
		["Tradeskill.Tool.Fishing.Lure"] = "鱼饵",
		["Tradeskill.Tool.Fishing.Gear"] = "钓鱼装备",
		["Tradeskill.Tool.Fishing.Tool"] = "鱼竿",

		["Consumable.Food.Bonus"] = "食物：各类属性提升";
		["Consumable.Food.Buff.Strength"] = "食物：提升力量";
		["Consumable.Food.Buff.Agility"] = "食物：提升敏捷";
		["Consumable.Food.Buff.Attack Power"] = "食物：提升攻击强度";
		["Consumable.Food.Buff.Healing"] = "食物：提升治疗效果";
		["Consumable.Food.Buff.Spell Damage"] = "食物：提升法伤";
		["Consumable.Food.Buff.Stamina"] = "食物：提升耐力";
		["Consumable.Food.Buff.Intellect"] = "食物：提升智力";
		["Consumable.Food.Buff.Spirit"] = "食物：提升精神";
		["Consumable.Food.Buff.Mana Regen"] = "食物：提升法力恢复";
		["Consumable.Food.Buff.HP Regen"] = "食物：提升生命恢复";
		["Consumable.Food.Buff.Other"] = "食物：其他";

		["Consumable.Buff.Health"] = "提升生命力";
		["Consumable.Buff.Armor"] = "提升护甲";
		["Consumable.Buff.Regen Health"] = "提升生命回复";
		["Consumable.Buff.Agility"] = "提升敏捷";
		["Consumable.Buff.Intellect"] = "提升智力";
		["Consumable.Buff.Protection"] = "提升防护力";
		["Consumable.Buff.Spirit"] = "提升精神";
		["Consumable.Buff.Stamina"] = "提升耐力";
		["Consumable.Buff.Strength"] = "提升力量";
		["Consumable.Buff.Attack Power"] = "提升攻击强度";
		["Consumable.Buff.Attack Speed"] = "提升攻击速度";
		["Consumable.Buff.Dodge"] = "提升闪躲机率";
		["Consumable.Buff.Resistance"] = "提升抗性";

		["Consumable.Buff Group.General.Self"] = "自身增益";
		["Consumable.Buff Group.General.Target"] = "目标增益";
		["Consumable.Buff Group.Caster.Self"] = "使用者增益";
		["Consumable.Buff Group.Caster.Target"] = "使用者目标增益";
		["Consumable.Buff Group.Melee.Self"] = "近战增益";
		["Consumable.Buff Group.Melee.Target"] = "近战目标增益";
		["Consumable.Buff.Other.Self"] = "其他人增益";
		["Consumable.Buff.Other.Target"] = "其他人目标增益";
		["Consumable.Buff.Chest"] = "胸甲增益";
		["Consumable.Buff.Shield"] = "盾牌增益";
		["Consumable.Weapon Buff"] = "武器增益";

		["Consumable.Quest.Usable"] = "任务物品";

		["Consumable.Potion.Recovery.Healing.Basic"] = "治疗药水";
		["Consumable.Potion.Recovery.Healing.Blades Edge"] = "治疗药水：刀锋山";
		["Consumable.Potion.Recovery.Healing.Coilfang"] = "治疗药水：盘牙水库";
		["Consumable.Potion.Recovery.Healing.PvP"] = "奥特兰克治疗药水";
		["Consumable.Potion.Recovery.Healing.Tempest Keep"] = "治疗药水：风暴要塞";
		["Consumable.Potion.Recovery.Mana.Basic"] = "法力药水";
		["Consumable.Potion.Recovery.Mana.Blades Edge"] = "法力药水：刀锋山";
		["Consumable.Potion.Recovery.Mana.Coilfang"] = "法力药水：盘牙水库";
		["Consumable.Potion.Recovery.Mana.Pvp"] = "奥特兰克法力药水";
		["Consumable.Potion.Recovery.Mana.Tempest Keep"] = "法力药水：风暴要塞";

		["Consumable.Weapon Buff.Poison.Crippling"] = "致残毒药";
		["Consumable.Weapon Buff.Poison.Deadly"] = "致命毒药";
		["Consumable.Weapon Buff.Poison.Instant"] = "速效毒药";
		["Consumable.Weapon Buff.Poison.Mind Numbing"] = "麻痹毒药";
		["Consumable.Weapon Buff.Poison.Wound"] = "致伤毒药";
		["Consumable.Weapon Buff.Oil.Mana"] = "魔油：提高法力恢复";
		["Consumable.Weapon Buff.Oil.Wizard"] = "魔油：增加伤害/治疗";
		["Consumable.Weapon Buff.Stone.Sharpening Stone"] = "磨刀石";
		["Consumable.Weapon Buff.Stone.Weight Stone"] = "平衡石";

		["Consumable.Bandage.Basic"] = "绷带";
		["Consumable.Bandage.Battleground.Alterac Valley"] = "奥特兰克绷带";
		["Consumable.Bandage.Battleground.Warsong Gulch"] = "战歌绷带";
		["Consumable.Bandage.Battleground.Arathi Basin"] = "阿拉希绷带";

		["Consumable.Food.Edible.Basic.Non-Conjured"] = "食物：无附加效果";
		["Consumable.Food.Percent.Basic"] = "食物：% 恢复生命力";
		["Consumable.Food.Percent.Bonus"] = "食物：% 恢复生命力 (喂食效果)";
		["Consumable.Food.Combo Percent"] = "食物：% 恢复生命力及法力";
		["Consumable.Food.Combo Health"] = "食物：有喝水效果";
		["Consumable.Food.Edible.Bread.Conjured"] = "食物：法师制造物";
		["Consumable.Food.Conjure"] = "造食术";
		["Consumable.Food.Edible.Battleground.Arathi Basin.Basic"] = "食物：阿拉希盆地";
		["Consumable.Food.Edible.Battleground.Warsong Gulch.Basic"] = "食物：战歌峡谷";

		["Consumable.Food.Pet.Bread"] = "食物：宠物面包";
		["Consumable.Food.Pet.Cheese"] = "食物：宠物乳酪";
		["Consumable.Food.Pet.Fish"] = "食物：宠物鱼类";
		["Consumable.Food.Pet.Fruit"] = "食物：宠物水果";
		["Consumable.Food.Pet.Fungus"] = "食物：宠物菌类";
		["Consumable.Food.Pet.Meat"] = "食物：宠物肉类";

		["AUTOBAR_CLASS_CUSTOM"] = "自订";
		["Misc.Minipet.Normal"] = "宠物";
		["Misc.Minipet.Snowball"] = "节庆宠物";
		["AUTOBAR_CLASS_CLEAR"] = "清除栏位";
		["AUTOBAR_CLASS_UNGORORESTORE"] = "安戈洛：恢复水晶";

		["Consumable.Anti-Venom"] = "抗毒药剂";

		["Consumable.Warlock.Healthstone"] = "治疗石";
		["Consumable.Warlock.Create Healthstone"] = "制造治疗石";
		["Consumable.Mage.Mana Stone"] = "法力石";
		["Consumable.Mage.Conjure Mana Stone"] = "制造法力石";
		["Consumable.Potion.Recovery.Dreamless Sleep"] = "昏睡药水";
		["Consumable.Potion.Recovery.Rejuvenation"] = "恢复药水";
		["Consumable.Jeweler.Statue"] = "法力石状态";

		["Misc.Battle Standard.Battleground"] = "战场军旗";
		["Misc.Battle Standard.Alterac Valley"] = "奥特兰克山谷军旗";
		["Consumable.Recovery.Rune"] = "恶魔和黑暗符文";
		["AUTOBAR_CLASS_ARCANE_PROTECTION"] = "祕法防护药水";
		["AUTOBAR_CLASS_FIRE_PROTECTION"] = "火焰防护药水";
		["AUTOBAR_CLASS_FROST_PROTECTION"] = "冰霜防护药水";
		["AUTOBAR_CLASS_NATURE_PROTECTION"] = "自然防护药水";
		["AUTOBAR_CLASS_SHADOW_PROTECTION"] = "暗影防护药水";
		["AUTOBAR_CLASS_SPELL_REFLECTION"] = "法术反弹";
		["AUTOBAR_CLASS_HOLY_PROTECTION"] = "神圣防护药水";
		["AUTOBAR_CLASS_INVULNERABILITY_POTIONS"] = "有限无敌药水";
		["Consumable.Buff.Free Action"] = "自由行动药水";

		["AUTOBAR_CLASS_PORTALS"] = "传送门";
		["Misc.Hearth"] = "炉石";
		["Misc.Booze"] = "酒类";
		["Consumable.Water.Basic"] = "水";
		["Consumable.Water.Percentage"] = "水：% 恢复法力";
		["AUTOBAR_CLASS_WATER_CONJURED"] = "法师造水";
		["AUTOBAR_CLASS_WATER_CONJURE"] = "造水术";
		["Consumable.Water.Buff.Spirit"] = "水：提升精神";
		["Consumable.Buff.Rage.Self"] = "怒气药水";
		["Consumable.Buff.Energy.Self"] = "能量药水";
		["Consumable.Buff.Speed"] = "迅捷药剂";
		["AUTOBAR_CLASS_SOULSHARDS"] = "灵魂碎片";
		["Reagent.Ammo.Arrow"] = "箭";
		["Reagent.Ammo.Bullet"] = "子弹";
		["Reagent.Ammo.Thrown"] = "投掷武器";
		["Misc.Engineering.Explosives"] = "工程学爆炸物";
		["Misc.Mount.Normal"] = "坐骑";
		["Misc.Mount.Summoned"] = "坐骑：召唤类";
		["Misc.Mount.Ahn'Qiraj"] = "坐骑：其拉甲虫";
		["Misc.Mount.Flying"] = "坐骑：飞行类";

	}
end);


if (GetLocale()=="zhCN") then

AUTOBAR_CHAT_MESSAGE1 = "保存的配置是老版本的, 已被清除.  不支持配置的升级.";
AUTOBAR_CHAT_MESSAGE2 = "更新合类物品按钮 #%d 物品 #%d, 使用物品ID替换物品名称.";
AUTOBAR_CHAT_MESSAGE3 = "更新单类物品按钮 #%d, 使用物品ID替换物品名称.";

--  AutoBar_Config.xml
AUTOBAR_CONFIG_VIEWTEXT = "要编辑按钮请选择栏位分页下方的栏位进行编辑。";
AUTOBAR_CONFIG_SLOTVIEWTEXT = "检视综合栏位 (无法编辑)";
AUTOBAR_CONFIG_RESET = "重置为默认";
AUTOBAR_CONFIG_REVERT = "复原";
AUTOBAR_CONFIG_DONE = "完成";
AUTOBAR_CONFIG_DETAIL_CATEGORIES = "(Shift+点击进入详细分类)";
AUTOBAR_CONFIG_DRAGHANDLE = "鼠标左键拖曳移动 AutoBar\n左键锁定 / 解锁\n右键显示功能选项";
AUTOBAR_CONFIG_EMPTYSLOT = "空栏位";
AUTOBAR_CONFIG_CLEARSLOT = "清除栏位";
AUTOBAR_CONFIG_SETSHARED = "共享设定：";
AUTOBAR_CONFIG_SETSHAREDTIP = "选择使用共享文件，将会把共享的设定值套用到所有的角色。";

AUTOBAR_CONFIG_TAB_SLOTS = "栏位";
AUTOBAR_CONFIG_TAB_BAR = "动作条";
AUTOBAR_CONFIG_TAB_BUTTONS = "按钮";
AUTOBAR_CONFIG_TAB_POPUP = "弹出";
AUTOBAR_CONFIG_TAB_PROFILE = "设定";
AUTOBAR_CONFIG_TAB_KEYS = "Keys";

AUTOBAR_TOOLTIP1 = " (数量：";
AUTOBAR_TOOLTIP2 = " [自定义物品]";
AUTOBAR_TOOLTIP4 = " [只能在战场使用]";
AUTOBAR_TOOLTIP5 = " [仅用于非战斗状态]";
AUTOBAR_TOOLTIP6 = " [使用条件限制]";
AUTOBAR_TOOLTIP7 = " [使用后需冷却]";
AUTOBAR_TOOLTIP8 = "\n(左键用于主手武器\n右键用于副手武器)";

AUTOBAR_CONFIG_DOCKTO = "依附于：";
AUTOBAR_CONFIG_USECHARACTERTIP = "角色栏位的物品只适用于这个角色。";
AUTOBAR_CONFIG_USESHAREDTIP = "共用栏位的物品适用于其他角色使用相同的物品。\n共用项目可由专案分页中选择。";
AUTOBAR_CONFIG_USECLASSTIP = "职业栏位的物品适用于所有相同职业的角色。";
AUTOBAR_CONFIG_USEBASICTIP = "基本栏位的物品适用于所有角色可用的基本物品。";
AUTOBAR_CONFIG_CHARACTERLAYOUTTIP = "改变可见的栏位只作用于这个角色。";
AUTOBAR_CONFIG_SHAREDLAYOUTTIP = "改变可见的栏位可作用于所有角色使用相同的共用设定。";
AUTOBAR_CONFIG_TIPOVERRIDE = "这一层的物品优先顺序优于下一层的栏位。\n";
AUTOBAR_CONFIG_TIPOVERRIDDEN = "上一层的物品优先顺序优于这一层的栏位。\n";
AUTOBAR_CONFIG_TIPAFFECTSCHARACTER = "变动只作用于这个角色。";
AUTOBAR_CONFIG_TIPAFFECTSALL = "变动作用于所有角色。";
AUTOBAR_CONFIG_SETUPSINGLE = "单一设定";
AUTOBAR_CONFIG_SETUPSHARED = "共用设定";
AUTOBAR_CONFIG_SETUPSTANDARD = "标准设定";
AUTOBAR_CONFIG_SETUPBLANKSLATE = "清空栏位";
AUTOBAR_CONFIG_SETUPSINGLETIP = "左键将设定单一角色为职业的 AutoBar。";
AUTOBAR_CONFIG_SETUPSHAREDTIP = "左键为共用设定\n开启角色专用以及共用栏位。";
AUTOBAR_CONFIG_SETUPSTANDARDTIP = "开启编辑并使用所有栏位。";
AUTOBAR_CONFIG_SETUPBLANKSLATETIP = "清除所有角色和共用的按钮。";
AUTOBAR_CONFIG_RESETSINGLETIP = "左键将重置为单一角色设定的预设值。";
AUTOBAR_CONFIG_RESETSHAREDTIP = "左键将重置为角色共用设定的预设值。\n职业专用按钮会复制到角色栏位。\n预设按钮将复制到共用的栏位。";
AUTOBAR_CONFIG_RESETSTANDARDTIP = "左键将重置为标准预设值。\n职业专用按钮会在职业栏位中。\n预设按钮在基本栏位中。\n共用和角色栏位将会清除。";

--  AutoBarConfig.lua
AUTOBAR_TOOLTIP9 = "合类物品按钮";
AUTOBAR_TOOLTIP10 = " (按物品ID定制)";
AUTOBAR_TOOLTIP11 = "\n(物品ID未经过验证)";
AUTOBAR_TOOLTIP12 = " (按物品名称定制)";
AUTOBAR_TOOLTIP13 = "单类物品按钮\n\n";
AUTOBAR_TOOLTIP14 = "\n不能直接使用.";
AUTOBAR_TOOLTIP15 = "\n武器目标\n(左键用于主手武器\n右键用于副手武器.)";
AUTOBAR_TOOLTIP16 = "\n需目标.";
AUTOBAR_TOOLTIP17 = "\n仅用于非战斗状态.";
AUTOBAR_TOOLTIP18 = "\n仅用于战斗状态.";
AUTOBAR_TOOLTIP19 = "\n使用地点：";
AUTOBAR_TOOLTIP20 = "\n使用条件限制：";
AUTOBAR_TOOLTIP21 = "所需恢复生命";
AUTOBAR_TOOLTIP22 = "所需恢复法力";
AUTOBAR_TOOLTIP23 = "单类物品按钮\n\n";

--  AutoBarItemList.lua
--AUTOBAR_ALTERACVALLEY = "奥特兰克山谷";
--AUTOBAR_WARSONGGULCH = "战歌峡谷";
--AUTOBAR_ARATHIBASIN = "阿拉希盆地";
--AUTOBAR_AHN_QIRAJ = "安其拉";

end