--[[ TinyTip by Thrae
-- 
-- Traditional Chinese Localization
-- Any wrong words, change them here.
-- 
-- TinyTipLocale should be defined in your FIRST localization
-- code.
--
-- Note: Localized slash commands are in TinyTipChatLocale_zhTW.
-- Contributors: 舞葉@語風
--]]

TinyTipLocale = GetLocale()

if TinyTipLocale and TinyTipLocale == "zhTW" then
	-- slash commands
	SLASH_TINYTIP1 = "/tinytip"
	SLASH_TINYTIP2 = "/ttip"

	-- TinyTipUtil
	TinyTipLocale_InitDB1		= "沒有設定檔，採用預設值進行設定"
	TinyTipLocale_InitDB2		= "預設設定。"
	TinyTipLocale_InitDB3		= "已偵測到新的資料版本，正在轉移中..."
	TinyTipLocale_InitDB4		= "轉移完成"
	TinyTipLocale_InitDB5		= "準備就緒。"

	TinyTipLocale_DefaultDB1	= "所有設定都將回復到預設值。"
	TinyTipLocale_DefaultDB2	= "錯誤 - 資料庫版本錯誤。"

	TinyTipLocale_Unknown		= "未知"

	-- TinyTip core
	TinyTipLocale_Tapped		= "戰鬥中"
	TinyTipLocale_RareElite		= string.format("%s %s", getglobal("ITEM_QUALITY3_DESC"), getglobal("ELITE") )

	TinyTipLocale_Level = getglobal("LEVEL")

	TinyTipLocale = nil -- we no longer need this
end