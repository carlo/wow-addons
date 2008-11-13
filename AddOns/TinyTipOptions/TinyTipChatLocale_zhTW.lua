--[[ TinyTip by Thrae
-- 
--
-- Traditional Chinese Localization
-- For TinyTipChat
--
-- Any wrong words, change them here.
-- 
-- TinyTipChatLocale should be defined in your FIRST localization
-- code.
--
-- Note: Other localization is in TinyTipLocale_zhTW.
-- 
-- Contributors: 舞葉@語風
--]]

TinyTipChatLocale= GetLocale()

if TinyTipChatLocale and TinyTipChatLocale == "zhTW" then
	TinyTipChatLocale_MenuTitle = "TinyTip設定"

	TinyTipChatLocale_On = "開啟"
	TinyTipChatLocale_Off = "關閉"
	TinyTipChatLocale_GameDefault = "遊戲預設"
	TinyTipChatLocale_TinyTipDefault = "TinyTip預設"

	if getglobal("TinyTipAnchorExists") then
		TinyTipChatLocale_Opt_Main_Anchor			= "錨點"
		TinyTipChatLocale_Opt_MAnchor					= "人物訊息錨點"
		TinyTipChatLocale_Opt_FAnchor					= "視窗訊息錨點"
		TinyTipChatLocale_Opt_MOffX						= "人物訊息列偏移量[X]"
		TinyTipChatLocale_Opt_MOffY						= "人物訊息列偏移量[Y]"
		TinyTipChatLocale_Opt_FOffX						= "視窗訊息列偏移量[X]"
		TinyTipChatLocale_Opt_FOffY						= "視窗訊息列偏移量[Y]"
		TinyTipChatLocale_Opt_AnchorAll				= "將自訂訊息依附在錨點上"
		TinyTipChatLocale_Opt_AlwaysAnchor		= "總是將遊戲訊息調依附在錨點上"

		TinyTipChatLocale_ChatMap_Anchor = {
			["LEFT"]				= "左中", 
			["RIGHT"]				= "右中", 
			["BOTTOMRIGHT"]	= "右下", 
			["BOTTOMLEFT"]	= "左下", 
			["BOTTOM"]			= "正下方", 
			["TOP"]					= "正上方", 
			["TOPLEFT"] 		= "左上", 
			["TOPRIGHT"] 		= "右上",
			["CENTER"]			= "正中央"
		}

		TinyTipChatLocale_Anchor_Cursor = "游標"
		TinyTipChatLocale_Anchor_Sticky = "依附"

		TinyTipChatLocale_Desc_Main_Anchor = "設置訊息列位置。"
		TinyTipChatLocale_Desc_MAnchor = "設定游標經過人物時顯示的訊息條錨點位置。"
		TinyTipChatLocale_Desc_FAnchor = "設定游標經過任何物件時顯示的訊息條錨點位置。"
		TinyTipChatLocale_Desc_MOffX = "設定人物訊息列相對於錨點的水平偏移量。"
		TinyTipChatLocale_Desc_MOffY = "設定人物訊息列相對於錨點的垂直偏移量。"
		TinyTipChatLocale_Desc_FOffX = "設定視窗訊息列相對於錨點的水平偏移量。"
		TinyTipChatLocale_Desc_FOffY = "設定視窗訊息列相對於錨點的垂直偏移量。"
		TinyTipChatLocale_Desc_AnchorAll = "將自定義錨點設定套用在所有使用遊戲預設視窗訊息的錨點的視窗訊息列。"
		TinyTipChatLocale_Desc_AlwaysAnchor = "強制任何遊戲訊息列使用自定義錨點設置，包括礦點的訊息和任何遊戲的訊息。"

		if getglobal("GetAddOnMetadata")("TinyTipExtras", "Title") then
			TinyTipChatLocale_Opt_ETAnchor				= "額外訊息條錨點"
			TinyTipChatLocale_Opt_ETOffX					= "額外訊息條偏移量[X]"
			TinyTipChatLocale_Opt_ETOffY					= "額外訊息條偏移量[Y]"
			TinyTipChatLocale_Desc_ETAnchor 			= "設定額外訊息條錨點位置。"
			TinyTipChatLocale_Desc_ETOffX					= "設定額外訊息條相對於錨點的水平偏移量。"
			TinyTipChatLocale_Desc_ETOffY					= "設定額外訊息條相對於錨點的水平偏移量。"

			TinyTipChatLocale_Opt_PvPIconAnchor1	= "官階圖示錨點"
			TinyTipChatLocale_Opt_PvPIconAnchor2	= "官階圖示相對錨點"
			TinyTipChatLocale_Opt_PvPIconOffX			= "官階圖示偏移量[X]"
			TinyTipChatLocale_Opt_PvPIconOffY			= "官階圖示偏移量[Y]"

			TinyTipChatLocale_Desc_PvPIconAnchor1	= "設定官階圖示的錨點位置。"
			TinyTipChatLocale_Desc_PvPIconAnchor2	= "設定官階圖示的相對錨點位置。"
			TinyTipChatLocale_Desc_PvPIconOffX		= "設定官階圖示相對於錨點的水平偏移量。"
			TinyTipChatLocale_Desc_PvPIconOffY		= "設定官階圖示相對於錨點的垂直偏移量。"

			TinyTipChatLocale_Opt_RTIconAnchor1		= "團隊目標圖示錨點"
			TinyTipChatLocale_Opt_RTIconAnchor2		= "團隊目標圖示相對錨點"
			TinyTipChatLocale_Opt_RTIconOffX			= "團隊目標圖示偏移量[X]"
			TinyTipChatLocale_Opt_RTIconOffY			= "團隊目標圖示偏移量[Y]"

			TinyTipChatLocale_Desc_RTIconAnchor1	= "設定團隊目標圖示的錨點位置。"
			TinyTipChatLocale_Desc_RTIconAnchor2	= "設定團隊目標圖示的相對錨點位置。"
			TinyTipChatLocale_Desc_RTIconOffX			= "設定團隊目標圖示相對於錨點的水平偏移量。"
			TinyTipChatLocale_Desc_RTIconOffY			= "設定團隊目標圖示相對於錨點的垂直偏移量。"

			TinyTipChatLocale_Opt_BuffAnchor1			= "增益效果圖示錨點"
			TinyTipChatLocale_Opt_BuffAnchor2			= "增益效果圖示相對錨點"
			TinyTipChatLocale_Opt_BuffOffX				= "增益效果圖示偏移量[X]"
			TinyTipChatLocale_Opt_BuffOffY				= "增益效果圖示偏移量[Y]"

			TinyTipChatLocale_Opt_DebuffAnchor1		= "不良效果圖示錨點"
			TinyTipChatLocale_Opt_DebuffAnchor2		= "不良效果圖示相對錨點"
			TinyTipChatLocale_Opt_DebuffOffX			= "不良效果圖示偏移量[X]"
			TinyTipChatLocale_Opt_DebuffOffY			= "不良效果圖示偏移量[Y]"

			TinyTipChatLocale_Desc_BuffAnchor1	= "設定增益效果圖示的錨點位置。"
			TinyTipChatLocale_Desc_BuffAnchor2	= "設定增益效果圖示的相對錨點位置。"
			TinyTipChatLocale_Desc_BuffOffX			= "設定增益效果圖示相對於錨點的水平偏移量。"
			TinyTipChatLocale_Desc_BuffOffY			= "設定增益效果圖示相對於錨點的垂直偏移量。"

			TinyTipChatLocale_Desc_DebuffAnchor1	= "設定不良效果圖示的錨點位置。"
			TinyTipChatLocale_Desc_DebuffAnchor2	= "設定不良效果圖示的相對錨點位置。"
			TinyTipChatLocale_Desc_DebuffOffX			= "設定不良效果圖示相對於錨點的水平偏移量。"
			TinyTipChatLocale_Desc_DebuffOffY			= "設定不良效果圖示相對於錨點的水平偏移量。"
		end
	end

	TinyTipChatLocale_Opt_Main_Text					= "內文"
	TinyTipChatLocale_Opt_HideLevelText			= "隱藏等級訊息"
	TinyTipChatLocale_Opt_HideRace					= "隱藏職業和生物類型訊息"
	TinyTipChatLocale_Opt_KeyElite					= "啟用分類標示"
	TinyTipChatLocale_Opt_PvPRank						= "官階訊息"
	TinyTipChatLocale_Opt_LevelGuess				= "預測等級"
	TinyTipChatLocale_Opt_ReactionText			= "顯示敵對狀態訊息"
	TinyTipChatLocale_Opt_KeyServer						= "用(*)取代伺服器名稱"

	TinyTipChatLocale_Desc_Main_Text = "設定人物訊息列中顯示的內文訊息。"
	TinyTipChatLocale_Desc_HideLevelText = "切換是否隱藏等級訊息。"
	TinyTipChatLocale_Desc_HideRace = "切換是否隱藏玩家職業和生物類型訊息。"
	TinyTipChatLocale_Desc_KeyElite = "以*標示精英生物，以!標示稀有生物，以!*標示稀有精英生物，以**標示世界首領。"
	TinyTipChatLocale_Desc_PvPRank = "設定官階訊息顯示方式。"
	TinyTipChatLocale_Desc_ReactionText = "切換是否顯示敵對狀態訊息。（友好，敵對等等。）"
	TinyTipChatLocale_Desc_LevelGuess = "切換是以(你的等級 +10)還是以??顯示等級高出你10級以上的生物。"
	TinyTipChatLocale_Desc_KeyServer = "如果玩家是來自另一個伺服器，則在名字後面用(*)取代伺服器名稱。"

	TinyTipChatLocale_Opt_Main_Appearance			= "外觀"
	TinyTipChatLocale_Opt_Scale								= "縮放"
	TinyTipChatLocale_Opt_Fade								= "淡出效果"
	TinyTipChatLocale_Opt_BGColor							= "背景顏色"
	TinyTipChatLocale_Opt_Border							= "邊框顏色"
	TinyTipChatLocale_Opt_SmoothBorder				= "平滑邊框與背景"
	TinyTipChatLocale_Opt_Friends							= "以特別的顏色顯示好友與公會成員"
	TinyTipChatLocale_Opt_HideInFrames				= "隱藏人物頭像訊息列"
	TinyTipChatLocale_Opt_FormatDisabled			= "禁用訊息列排版"
	TinyTipChatLocale_Opt_Compact							= "顯示迷你訊息列"

	TinyTipChatLocale_ChatIndex_PvPRank = { 
		[1] = TinyTipChatLocale_Off, 
		[2] = "顯示官階名",
		[3] = "在名字後面顯示官階名"
	}

	TinyTipChatLocale_ChatIndex_Fade = {
		[1] = "總是淡出",
		[2] = "絕不淡出"
	}

	TinyTipChatLocale_ChatIndex_BGColor = {
		[1] = TinyTipChatLocale_GameDefault,
		[2] = "以玩家方式顯示NPC",
		[3] = "總是顯示黑色"
	}

	TinyTipChatLocale_ChatIndex_Border = {
		[1] = TinyTipChatLocale_GameDefault,
		[2] = "隱藏邊框" 
	}

	TinyTipChatLocale_ChatIndex_Friends = {
		[1] = "只對名字上色",
		[2] = "不上色"
	}

	TinyTipChatLocale_Desc_Main_Appearance = "設定訊息列外觀與行為。"
	TinyTipChatLocale_Desc_Fade = "切換是讓訊息列逐漸淡出或是直接消失。"
	TinyTipChatLocale_Desc_Scale =  "設定訊息列的縮放比例。（包括附帶的圖示）"
	TinyTipChatLocale_Desc_BGColor = "設定人物訊息列背景的顏色設定。"
	TinyTipChatLocale_Desc_Border = "設定人物訊息列邊框的顏色設定。"
	TinyTipChatLocale_Desc_SmoothBorder = "切換是否改變訊息列背景和邊框的預設透明度。"
	TinyTipChatLocale_Desc_Friends = "設定是否使用特别的顏色顯示好友和同公會成員的名字或訊息列背景。"
	TinyTipChatLocale_Desc_HideInFrames = "當游標移經人物頭像時隱藏訊息列。"
	TinyTipChatLocale_Desc_FormatDisabled = "禁用TinyTip訊息列排版。"
	TinyTipChatLocale_Desc_Compact = "在不改縮放放比例的情况下迷你化的訊息列。"


	if getglobal("GetAddOnMetadata")("TinyTipExtras", "Title") then
		TinyTipChatLocale_Opt_PvPIconScale	= "官階圖示縮放"
		TinyTipChatLocale_Opt_RTIconScale		= "團隊目標圖示縮放"
		TinyTipChatLocale_Opt_BuffScale			= "增益與不良效果圖示縮放"

		TinyTipChatLocale_Desc_PvPIconScale		= "設定官階圖示縮放比例。"
		TinyTipChatLocale_Desc_RTIconScale		= "設定團隊目標圖示縮放比例。"
		TinyTipChatLocale_Desc_BuffScale			= "設定增益與不良效果圖示縮放比例。"

		TinyTipChatLocale_Opt_Main_Targets				= "目標訊息"
		TinyTipChatLocale_Opt_ToT									= "訊息列人物"
		TinyTipChatLocale_Opt_ToP									= "小隊"
		TinyTipChatLocale_Opt_ToR									= "團隊"

		TinyTipChatLocale_ChatIndex_ToT = {
			[1] = "另起一行顯示其目標",
			[2] = "在同一行顯示其目標"
		}

		TinyTipChatLocale_ChatIndex_ToP = {
			[1] = "顯示每位玩家的名字",
			[2] = "只顯示玩家數量"
		}

		TinyTipChatLocale_ChatIndex_ToR = {
			[1] = "只顯示玩家數量",
			[2] = "顯示每個職業的玩家數量",
			[3] = "顯示所有玩家的名字"
		}

		TinyTipChatLocale_Desc_Main_Targets = "為人物訊息列添加目標的目標訊息。"
		TinyTipChatLocale_Desc_ToT = "設定是否顯示訊息列對應人物的目標的名字。"
		TinyTipChatLocale_Desc_ToP = "設定關注訊息列對應人物的小隊隊友的顯示。"
		TinyTipChatLocale_Desc_ToR = "設定關注訊息列對應人物的團隊隊友的顯示。"

		TinyTipChatLocale_Opt_Main_Extras					= "額外功能"
		TinyTipChatLocale_Opt_PvPIcon							= "顯示官階圖示"
		TinyTipChatLocale_Opt_ExtraTooltip				= "TinyTip額外訊息列"
		TinyTipChatLocale_Opt_Buffs								= "增益效果"
		TinyTipChatLocale_Opt_Debuffs							= "不良效果"
		TinyTipChatLocale_Opt_ManaBar					= "顯示法力狀態列"
		TinyTipChatLocale_Opt_RTIcon					= "顯示團隊目標圖示"

		TinyTipChatLocale_ChatIndex_ExtraTooltip	= {
			[1] = "顯示其他插件的訊息",
			[2] = "以額外訊息列顯示TinyTip與其他插件的額外訊息"
		}

		TinyTipChatLocale_ChatIndex_Buffs = {
			[1] = "顯示8個增益效果",
			[2] = "只顯示你能施放的增益效果",
			[3] = "顯示你能施放的增益效果的計數"
		}

		TinyTipChatLocale_ChatIndex_Debuffs = {
			[1] = "顯示8個不良效果",
			[2] = "只顯示你能驅散的不良效果",
			[3] = "顯示你能驅散的不良效果的計數",
			[4] = "顯示你能驅散的每個類型的不良效果的計數",
			[5] = "顯示你能驅散的全部類型的不良效果的計數"
		}

		TinyTipChatLocale_Desc_Main_Extras = "TinyTip核心不支援額外能。"
		TinyTipChatLocale_Desc_PvPIcon = "切換是否在訊息列左端顯示玩家的官階圖示。"
		TinyTipChatLocale_Desc_ExtraTooltip = "以額外訊息列顯示TinyTip與其他插件的額外訊息。"
		TinyTipChatLocale_Desc_Buffs			= "顯示人物的增益效果訊息。"
		TinyTipChatLocale_Desc_Debuffs		= "顯示人物的不良效果訊息。"
		TinyTipChatLocale_Desc_ManaBar		= "在生命列下增加法力列的顯示。"
		TinyTipChatLocale_Desc_RTIcon			= "顯示訊息列對應人物的團隊目標。"
	end

	TinyTipChatLocale_Opt_Profiles = "為每位人物單獨儲存設定"
	TinyTipChatLocale_Desc_Profiles = "切換是否為每位人物单讀儲存設定。"

	TinyTipChatLocale_Opt_Main_Default = "重置設定"
	TinyTipChatLocale_Desc_Main_Default = "將插件設定重置為預設狀態。"

	-- slash command-related stuff
	TinyTipChatLocale_DefaultWarning = "確定要將插件設定為預設狀態嗎？請選擇：："
	TinyTipChatLocale_NotValidCommand = "不是一個有效的指令。"

	TinyTipChatLocale_Confirm = "confirm" -- must be lowercase!
	TinyTipChatLocale_Opt_Slash_Default = "default" -- ditto

	-- we're done with this.
	TinyTipChatLocale = nil
end
