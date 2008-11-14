local L = AceLibrary("AceLocale-2.2"):new("beql")

L:RegisterTranslations("zhCN", function() return{

	["Bayi's Extended Quest Log"] = "增强任务日志",
	["No Objectives!"] = "无目标!",
	["(Done)"] = "（已完成）",
	["Click to open Quest Log"] = "点击打开任务日志",
	["Completed!"] = "完成！",
	[" |cffff0000Disabled by|r"] = "|cffff0000禁止于|r",
	["Reload UI ?"] = "是否重新载入UI？",	
	["FubarPlugin Config"] = "Fubar插件设置",
	["Requires Interface Reload"] = "需要重新载入界面",

	["Quest Log Options"] = "任务日志选项",
	["Options related to the Quest Log"] = "任务日志选项设置",
	["Lock Quest Log"] = "锁定",
	["Makes the quest log unmovable"] = "锁定任务日志",
	["Always Open Minimized"] = "最小化",
	["Force the quest log to open minimized"] = "强制最小化打开任务日志",
	["Always Open Maximized"] = "最大化",
	["Force the quest log to open maximized"] = "强制最大化打开任务日志",
	["Show Quest Level"] = "任务等级",
	["Shows the quests level"] = "显示任务的等级",
	["Info on Quest Completion"] = "任务完成信息",
	["Shows a message and plays a sound when you complete a quest"] = "当完成任务时显示信息并播放声音",
	["Auto Complete Quest"] = "自动完成任务",
	["Automatically Complete Quests"] = "自动完成任务",
	["Mob Tooltip Quest Info"] = "怪物提示",
	["Show quest info in mob tooltips"] = "在怪物提示中显示任务信息",
	["Item Tooltip Quest Info"] = "物品提示",
	["Show quest info in item tooltips"] = "在物品提示中显示任务信息",
	["Simple Quest Log"] = "精简日志",
	["Uses the default Blizzard Quest Log"] = "使用Blizzard默认任务日志",
	["Quest Log Alpha"] = "日志透明度",
	["Sets the Alpha of the Quest Log"] = "设置任务日志的透明度",

	["Quest Tracker"] = "任务追踪",
	["Quest Tracker Options"] = "任务追踪器选项",
	["Options related to the Quest Tracker"] = "任务追踪器选项设置",
	["Lock Tracker"] = "锁定",
	["Makes the quest tracker unmovable"] = "锁定任务追踪器",
	["Show Tracker Header"] = "标题",
	["Shows the trackers header"] = "显示任务追踪器标题",
	["Hide Completed Objectives"] = "隐藏已完成目标",
	["Automatical hide completed objectives in tracker"] = "自动隐藏追踪器中已完成的目标",
	["Remove Completed Quests"] = "移除已完成任务",
	["Automatical remove completed quests from tracker"] = "自动从追踪器中移除已完成的任务",
	["Font Size"] = "字体大小",
	["Changes the font size of the tracker"] = "更改任务追踪器的字体大小",
	["Sort Tracker Quests"] = "任务排序",
	["Sort the quests in tracker"] = "对追踪器中的任务进行排序",
	["Show Quest Zones"] = "区域",
	["Show the quests zone it belongs to above its name"] = "显示任务所在地区",
	["Add New Quests"] = "添加新任务",
	["Automatical add new Quests to tracker"] = "自动在追踪器中添加新任务",
	["Add Untracked"] = "添加未追踪",
	["Automatical add quests with updated objectives to tracker"] = "获取任务物品后自动将相关任务添加至追踪列表",
	["Reset tracker position"] = "重置追踪列表位置",
	["Active Tracker"] = "活跃列表",
	["Showing on mouseover tooltips, clicking opens the tracker, rightclicking removes the quest from tracker"] = "显示鼠标提示信息，左键点击打开追踪列表，右键点击把任务从列表中移除。",	
	["Hide Objectives for Completed only"] = "隐藏完成任务目标",
	["Hide objectives only for completed quests"] = "仅隐藏已完成任务的目标",	

	["Markers"] = "标记",
	["Customize the Objective/Quest Markers"] = "自定义目标/任务标记",
	["Show Objective Markers"] = "显示目标标记",
	["Display Markers before objectives"] = "在目标前显示标记",
	["Use Listing"] = "使用列表",
	["User Listing rather than symbols"] = "以列表替代符号",
	["List Type"] = "列表类型",
	["Set the type of listing"] = "设置列表的类型",
	["Symbol Type"] = "符号类型",
	["Set the type of symbol"] = "设置符号的类型",

	["Colors"] = "颜色",
	["Set tracker Colors"] = "设置追踪器颜色",
	["Background"] = "背景",
	["Use Background"] = "使用背景",
	["Custom Background Color"] = "自定义背景颜色",
	["Use custom color for background"] = "背景使用自定义颜色",
	["Background Color"] = "背景",
	["Sets the Background Color"] = "设置背景颜色",
	["Background Corner Color"] = "转角",
	["Sets the Background Corner Color"] = "设置背景转角颜色",
	["Use Quest Level Colors"] = "等级",
	["Use the colors to indicate quest difficulty"] = "使用颜色表示任务难度",
	["Custom Zone Color"] = "自定义区域颜色",
	["Use custom color for Zone names"] = "区域名称使用自定义颜色",
	["Zone Color"] = "区域",
	["Sets the zone color"] = "设置区域颜色",
	["Fade Colors"] = "淡出",
	["Fade the objective colors"] = "目标颜色淡出",
	["Custom Objective Color"] = "自定义目标颜色",
	["Use custom color for objective text"] = "目标文本使用自定义颜色",
	["Objective Color"] = "目标",
	["Sets the color for objectives"] = "设置目标颜色",
	["Completed Objective Color"] = "完成目标",
	["Sets the color for completed objectives"] = "设置已完成目标颜色",
	["Custom Header Color"] = "自定义标题颜色",
	["Use custom color for headers"] = "标题使用自定义颜色",
	["Completed Header Color"] = "完成标题",
	["Sets the color for completed headers"] = "设置已完成标题颜色",
	["Failed Header Color"] = "失败标题颜色",
	["Sets the color for failed quests"] = "为失败的任务设置颜色",
	["Header Color"] = "标题",
	["Sets the color for headers"] = "设置标题颜色",
	["Disable Tracker"] = "关闭追踪列表",
	["Disable the Tracker"] = "关闭追踪列表",
	["Quest Tracker Alpha"] = "任务追踪透明度",
	["Sets the Alpha of the Quest Tracker"] = "设置任务追踪列表的透明度",
	["Auto Resize Tracker"] = "Auto Resize Tracker",
	["Automatical resizes the tracker depending on the lenght of the text in it"] = "Automatical resizes the tracker depending on the lenght of the text in it",
	["Fixed Tracker Width"] = "Fixed Tracker Width",
	["Sets the fixed width of the tracker if auto resize is disabled"] = "Sets the fixed width of the tracker if auto resize is disabled",		

	["Pick Locale"] = "本地化选择",
	["Change Locale (needs Interface Reload)"] = "更改本地化方案（需要重载界面）",

	["|cffffffffQuests|r"] = "|cffffffff任务|r",
	["|cffff8000Tracked Quests|r"] = "|cffff8000追踪任务|r",
	["|cff00d000Completed Quests|r"] = "|cff00d000完成任务|r",
	["|cffeda55fClick|r to open Quest Log and |cffeda55fShift+Click|r to open Waterfall config"] = "|cffeda55f点击|r打开任务日志|cffeda55f按住Shift点击|r打开Waterfall样式设置界面",

	["Tooltip"] = "提示信息",
	["Tooltip Options"] = "提示选项",
	["Tracker Tooltip"] = "追踪提示",
	["Showing mouseover tooltips in tracker"] = "鼠标经过时在追踪列表上显示提示信息",
	["Quest Description in Tracker Tooltip"] = "提示任务描述",
	["Displays the actual quest's description in the tracker tooltip"] = "在追踪提示上显示完全的任务描述",
	["Party Quest Progression info"] = "小队任务进度",
	["Displays Party members quest status in the tooltip - Quixote must be installed on the partymembers client"] = "在提示信息上显示小队成员任务状态 - 队友必须也安装了Quixote库才能获取信息",
	["Enable Left Click"] = "允许左击",
	["Left clicking a quest in the tracker opens the Quest Log"] = "左键点击追踪列表中的任务来打开任务日志",
	["Enable Right Click"] = "允许右击",
	["Right clicking a quest in the tracker removes it from the tracker"] = "右键点击追踪列表中的任务以将其从列表移除",
	["Quest Log Scale"] = "任务日志缩放",
	["Sets the Scale of the Quest Log"] = "设置任务日志的缩放比例",
	["Force Tracker Unlock"] = "强制解锁",
	["Make the Tracker movable even with CTMod loaded. Please check your CTMod config before using it"] = "即使载入了CTMod依旧可以移动追踪列表，使用前请检查CTMod的设置",
	["Quest Progression to Party Chat"] = "报告任务进度",
	["Prints the Quest Progression Status to the Party Chat"] = "将任务进度报告到小队频道",		
	["Completion Sound"] = "完成音效",
	["Select the sound to be played when a quest is completed"] = "选择任务完成时所播放的音效",	

	["Quest Description Color"] = "任务描述颜色",
	["Sets the color for the Quest description"] = "设置任务描述的颜色",
	["Party Member Color"] = "队友颜色",
	["Party Member with Quixote Color"] = "使用Quixote库的队友颜色",
	["Sets the color for Party member"] = "为队友设置颜色",		
	
--[[ new with 3.0
	["Main Options"] = true, -- translate me!!!
	["Enable Addon"] = true, -- translate me!!!
	["Enable this Addon"] = true, -- translate me!!!
	["General Quest Log Options"] = true, -- translate me!!!
	["No sound"] = true, -- translate me!!!
	["Don't play a sound"] = true, -- translate me!!!
	["Watch Options"] = true, -- translate me!!!
	["Zones"] = true, -- translate me!!!
	["NPC color"] = true, -- translate me!!!
	["Title color"] = true, -- translate me!!!

-- Fubar
	["Show icon"] = true, -- translate me!!!
	["Show the plugins icon on the panel."] = true, -- translate me!!!
	["Show text"] = true, -- translate me!!!
	["Show the plugins text on the panel."] = true, -- translate me!!!
	["Show colored text"] = true, -- translate me!!!
	["Allow the plugin to color its text."] = true, -- translate me!!!
	["Detach tooltip"] = true, -- translate me!!!
	["Detach the tooltip from the panel."] = true, -- translate me!!!
	["Lock tooltip"] = true, -- translate me!!!
	["Lock the tooltips position. When the tooltip is locked, you must use Alt to access it with your mouse."] = true, -- translate me!!!
	["Position"] = true, -- translate me!!!
	["Position the plugin on the panel."] = true, -- translate me!!!
	["Left"] = true, -- translate me!!!
	["Right"] = true, -- translate me!!!
	["Center"] = true, -- translate me!!!
	["Attach to minimap"] = true, -- translate me!!!
	["Attach the plugin to the minimap instead of the panel."] = true, -- translate me!!!
	["Hide plugin"] = true, -- translate me!!!
	["Hidden"] = true, -- translate me!!!
	["Hide the plugin from the panel or minimap, leaving the addon running."] = true, -- translate me!!!
	["Other"] = true, -- translate me!!!
	["Close"] = true, -- translate me!!!
	["Close the menu."] = true, -- translate me!!!
	["Minimap position"] = true, -- translate me!!!

-- Profiles
	["Profiles"] = true, -- translate me!!!
 
-- Achievement Tracker
	["Achievement Tracker"] = true, -- translate me!!!
	["Enable Achievement Tracker"] = true, -- translate me!!!
	["Enables the Achievement Tracker, which can be moved an collapsed."] = true, -- translate me!!!
	["Makes the achievement tracker unmovable"] = true, -- translate me!!!
	["Show Achievement Tracker Header"] = true, -- translate me!!!
	["Shows the header of the Achievementtracker"] = true, -- translate me!!!
	["Save tracked Achievement"] = true, -- translate me!!!
	["Save last tracked Achievement and resore it after login"] = true, -- translate me!!!
	["Remove Completed Achievement"] = true, -- translate me!!!
	["Automatical remove the completed Achievement from tracker"] = true, -- translate me!!!
	["Achievement Tracker Alpha"] = true, -- translate me!!!
	["Sets the Alpha of the Achievement Tracker"] = true, -- translate me!!!
	["Achievement Tracker Scale"] = true, -- translate me!!!
	["Sets the Scale of the Achievement Tracker"] = true, -- translate me!!!
--]]
-- Profiles

	["ace2profile_default"] = "默认",
	["ace2profile_intro"] = "你可以选择一个活动的数据配置文件，这样你的每个角色就可以拥有不同的设置值，可以给你的插件配置带来极大的灵活性。" ,
	["ace2profile_reset_desc"] = "将当前的配置文件恢复到它的默认值，用于你的配置文件损坏，或者你只是想重来的情况。",
	["ace2profile_reset"] = "重置配置文件",
	["ace2profile_reset_sub"] = "将当前的配置文件恢复为默认值",
	["ace2profile_choose_desc"] = "你可以通过在文本框内输入一个名字创立一个新的配置文件，也可以选择一个已经存在的配置文件。",
	["ace2profile_new"] = "新建",
	["ace2profile_new_sub"] = "新建一个空的配置文件。",
	["ace2profile_choose"] = "现有的配置文件",
	["ace2profile_choose_sub"] = "从当前可用的配置文件里面选择一个。",
	["ace2profile_copy_desc"] = "从当前某个已保存的配置文件复制到当前正使用的配置文件。",
	["ace2profile_copy"] = "复制自",
	["ace2profile_delete_desc"] = "从数据库里删除不再使用的配置文件，以节省空间，并且清理SavedVariables文件。",
	["ace2profile_delete"] = "删除一个配置文件",
	["ace2profile_delete_sub"] = "从数据库里删除一个配置文件。",
	["ace2profile_delete_confirm"] = "你确定要删除所选择的配置文件么？",
	["ace2profile_profiles"] = "配置文件",
	["ace2profile_profiles_sub"] = "管理配置文件",


} end )

if GetLocale() == "zhCN" then

BEQL_COMPLETE = "%(完成%)"
BEQL_QUEST_ACCEPTED = "接受任务: "
BINDING_HEADER_beqlTITLE = "bEQL"
BINDING_NAME_TrackerToggle = "打开/关闭追踪列表"

end

-- original Locale : CWDG Translation Team 昏睡墨鱼 (Thomas Mo)
-- locale updated on 2007/08/22：lostcup @ NGACN