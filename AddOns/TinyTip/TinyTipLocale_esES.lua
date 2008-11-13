
if TinyTipLocale and TinyTipLocale == "esES" then
	-- slash commands
	SLASH_TINYTIP1 = "/tinytip"
	SLASH_TINYTIP2 = "/ttip"

	-- TinyTipUtil
	TinyTipLocale_InitDB1		= "Perfil vac\195\173o. Asignando los valores por defecto..."
	TinyTipLocale_InitDB2		= "Valores por defecto asignados."
	TinyTipLocale_InitDB3		= "Detectada una nueva versi\195\179n de la base de datos. Migrando..."
	TinyTipLocale_InitDB4		= "Migraci\195\179n Completa."
	TinyTipLocale_InitDB5		= "Listo."

	TinyTipLocale_DefaultDB1	= "Todos los ajustes se han reajustado a los valores por defecto."
	TinyTipLocale_DefaultDB2	= "Error - La versi\195\179n de la base de datos no coincide."

	TinyTipLocale_Unknown		= "Desconocido"

	-- TinyTip core
	TinyTipLocale_Tapped		= "Tapped"
	TinyTipLocale_RareElite		= string.format("%s %s", getglobal("ITEM_QUALITY3_DESC"), getglobal("ELITE") )

	TinyTipLocale_Level = getglobal("LEVEL")

	TinyTipLocale = nil -- we no longer need this
end
