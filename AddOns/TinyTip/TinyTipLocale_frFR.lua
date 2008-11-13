--[[ TinyTip by Thrae
-- 
-- French Localization
-- Any wrong words, change them here.
-- 
-- TinyTipLocale should be defined in your FIRST included
-- localization file.
--
-- Note: Localized slash commands are in TinyTipChatLocale_frFR.
--
-- Contributors: Adirelle
--]]

if TinyTipLocale and TinyTipLocale == "frFR" then
	-- slash commands
	SLASH_TINYTIP1 = "/tinytip"
	SLASH_TINYTIP2 = "/ttip"

	-- TinyTipUtil
	-- NEEDS TRANSLATION
	TinyTipLocale_InitDB1           = "Profil vide. Chargement du profil par d\195\169faut..."
	TinyTipLocale_InitDB2           = "Profil par d\195\169faut charg\195\169."
	TinyTipLocale_InitDB3           = "Nouvelle version de base de donn\195\169es d\195\169tect\195\169e. Mise \195\160 niveau en cours..."
	TinyTipLocale_InitDB4           = "Mise \195\160 niveau compl\195\168te."
	TinyTipLocale_InitDB5           = "Pr\195\170t."

	TinyTipLocale_DefaultDB1        = "Le profil par d\195\169faut a \195\169t\195\169 r\195\169staur\195\169."
	TinyTipLocale_DefaultDB2        = "Erreur - diff\195\169rence de version de base de donn\195\169es."

	TinyTipLocale_Unknown           = "Inconnu(e)"

	-- TinyTip core
	TinyTipLocale_Tapped		= "Engag\195\169"
	TinyTipLocale_RareElite		= "Elite Rare"

	TinyTipLocale_Level = getglobal("LEVEL")

	TinyTipLocale = nil -- we no longer need this
end

