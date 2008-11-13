if TinyTipChatLocale and TinyTipChatLocale == "esES" then
	TinyTipChatLocale_MenuTitle = "Opciones de TinyTip"

	TinyTipChatLocale_On = "Activado"
	TinyTipChatLocale_Off = "Desactivado"
	TinyTipChatLocale_GameDefault = "Valores por Defecto del Juego"
	TinyTipChatLocale_TinyTipDefault = "Valores por Defecto de TinyTip"

	if getglobal("TinyTipAnchorExists") then
		TinyTipChatLocale_Opt_Main_Anchor			= "Anclado"
		TinyTipChatLocale_Opt_MAnchor					= "Ancla de Unidad"
		TinyTipChatLocale_Opt_FAnchor					= "Ancla de Marco"
		TinyTipChatLocale_Opt_MOffX						= "Offset de Unidad [X]"
		TinyTipChatLocale_Opt_MOffY						= "Offset de Unidad [Y]"
		TinyTipChatLocale_Opt_FOffX						= "Offset de Marco [X]"
		TinyTipChatLocale_Opt_FOffY						= "Offset de Marco [Y]"
		TinyTipChatLocale_Opt_AnchorAll				= "Anclar Tooltips Personalizados"
		TinyTipChatLocale_Opt_AlwaysAnchor		= "Siempre Anclar Tooltips de Juego"

		TinyTipChatLocale_ChatMap_Anchor = {
			["LEFT"]				= "IZQUIERDA",
			["RIGHT"]				= "DERECHA",
			["BOTTOMRIGHT"]	= "ABAJO A LA DERECHA",
			["BOTTOMLEFT"]	= "ABAJO A LA IZQUIERDA",
			["BOTTOM"]			= "ABAJO",
			["TOP"]					= "ARRIBA",
			["TOPLEFT"] 		= "ARRIBA A LA IZQUIERDA",
			["TOPRIGHT"] 		= "ARRIBA A LA DERECHA",
			["CENTER"]			= "CENTRO"
		}

		TinyTipChatLocale_Anchor_Cursor = "CURSOR"
		TinyTipChatLocale_Anchor_Sticky = "PEGAJOSO"

		TinyTipChatLocale_Desc_Main_Anchor = "Establece la posici\195\179n del tooltip."
		TinyTipChatLocale_Desc_MAnchor = "Establece el ancla para el tooltip cuando se pasa el rat\195\179n sobre unidades en el marco del mundo."
		TinyTipChatLocale_Desc_FAnchor = "Establece el ancla para el tooltip cuando el rat\195\179n pasa por encima de CUALQUIER marco (excepto el Marco del Mundo)."
		TinyTipChatLocale_Desc_MOffX = "Establece el offset horizontal desde el punto de anclado para las unidades."
		TinyTipChatLocale_Desc_MOffY = "Establece el offset vertical desde el punto de anclado para las unidades."
		TinyTipChatLocale_Desc_FOffX = "Establece el offset horizontal desde el punto de anclado cuando se pasa el rat\195\179n por encima de CUALQUIER marco."
		TinyTipChatLocale_Desc_FOffY = "Establece el offset vertical desde el punto de anclado cuando se pasa el rat\195\179n por encima de CUALQUIER marco."
		TinyTipChatLocale_Desc_AnchorAll = "Aplica un Anclado Personalizado a TODOS los tooltips de Marco que usan GameTooltip_SetDefaultAnchor, no solo GameTooltip."
		TinyTipChatLocale_Desc_AlwaysAnchor = "Fuerza Anclado de Marco cada vez que se muestra el GameTooltip. Esto puede ser usado con filones de mineral y cualquier otro marco que use GameTooltip."

		if getglobal("GetAddOnMetadata")("TinyTipExtras", "Title") then
			TinyTipChatLocale_Opt_ETAnchor				= "Ancla de Tooltip Extra"
			TinyTipChatLocale_Opt_ETOffX					= "Offset del Tooltip Extra [X]"
			TinyTipChatLocale_Opt_ETOffY					= "Offset del Tooltip Extra [Y]"
			TinyTipChatLocale_Desc_ETAnchor 			= "Establece el ancla para el Tooltip Extra."
			TinyTipChatLocale_Desc_ETOffX					= "Establece el offset horizontal desde el punto de anclado para el Tooltip Extra."
			TinyTipChatLocale_Desc_ETOffY					= "Establece el offset vertical desde el punto de anclado para el Tooltip Extra."

			TinyTipChatLocale_Opt_PvPIconAnchor1	= "Ancla del Icono de Rango JcJ"
			TinyTipChatLocale_Opt_PvPIconAnchor2	= "Ancla Relativa del Icono de Rango JcJ"
			TinyTipChatLocale_Opt_PvPIconOffX			= "Offset del Icono de Rango JcJ [X]"
			TinyTipChatLocale_Opt_PvPIconOffY			= "Offset del Icono de Rango JcJ [Y]"

			TinyTipChatLocale_Desc_PvPIconAnchor1	= "Establece el ancla para el Icono de Rango JcJ."
			TinyTipChatLocale_Desc_PvPIconAnchor2	= "Establece el ancla relativa para el Icono de Rango JcJ"
			TinyTipChatLocale_Desc_PvPIconOffX		= "Establece el offset horizontal desde el punto de anclado para el Icono de Rango JcJ."
			TinyTipChatLocale_Desc_PvPIconOffY		= "Establece el offset vertical desde el punto de anclado para el Icono de Rango JcJ."

			TinyTipChatLocale_Opt_RTIconAnchor1		= "Ancla del Icono de Objetivo de Banda"
			TinyTipChatLocale_Opt_RTIconAnchor2		= "Icono de Objetivo de Banda Relative Anchor"
			TinyTipChatLocale_Opt_RTIconOffX			= "Offset del Icono de Objetivo de Banda [X]"
			TinyTipChatLocale_Opt_RTIconOffY			= "Offset del Icono de Objetivo de Banda [Y]"

			TinyTipChatLocale_Desc_RTIconAnchor1	= "Establece el ancla para el Icono de Objetivo de Banda."
			TinyTipChatLocale_Desc_RTIconAnchor2	= "Establece el ancla relativa para el Icono de Objetivo de Banda."
			TinyTipChatLocale_Desc_RTIconOffX			= "Establece el offset horizontal desde el punto de anclado para el Icono de Objetivo de Banda."
			TinyTipChatLocale_Desc_RTIconOffY			= "Establece el offset vertical desde el punto de anclado para el Icono de Objetivo de Banda."

			TinyTipChatLocale_Opt_BuffAnchor1			= "Ancla de Buff"
			TinyTipChatLocale_Opt_BuffAnchor2			= "Ancla relativa de Buff"
			TinyTipChatLocale_Opt_BuffOffX				= "Offset de Buff [X]"
			TinyTipChatLocale_Opt_BuffOffY				= "Offset de Buff [Y]"

			TinyTipChatLocale_Opt_DebuffAnchor1		= "Ancla de Debuff"
			TinyTipChatLocale_Opt_DebuffAnchor2		= "Ancla relativa de Debuff"
			TinyTipChatLocale_Opt_DebuffOffX			= "Offset de Debuff [X]"
			TinyTipChatLocale_Opt_DebuffOffY			= "Offset de Debuff [Y]"

			TinyTipChatLocale_Desc_BuffAnchor1	= "Establece el ancla para los Iconos de Buff."
			TinyTipChatLocale_Desc_BuffAnchor2	= "Establece el ancla relativa para los Iconos de Buff."
			TinyTipChatLocale_Desc_BuffOffX			= "Establece el offset horizontal desde el punto de anclado para los Iconos de Buff."
			TinyTipChatLocale_Desc_BuffOffY			= "Establece el offset vertical desde el punto de anclado para los Iconos de Buff."

			TinyTipChatLocale_Desc_DebuffAnchor1	= "Establece el ancla para los Iconos de Debuff."
			TinyTipChatLocale_Desc_DebuffAnchor2	= "Establece el ancla relativa para los Iconos de Debuff."
			TinyTipChatLocale_Desc_DebuffOffX			= "Establece el offset horizontal desde el punto de anclado para los Iconos de Debuff."
			TinyTipChatLocale_Desc_DebuffOffY			= "Establece el offset vertical desde el punto de anclado para los Iconos de Debuff."
		end
	end

	TinyTipChatLocale_Opt_Main_Text					= "Texto"
	TinyTipChatLocale_Opt_HideLevelText			= "Ocultar el texto del Nivel"
	TinyTipChatLocale_Opt_HideRace					= "Ocultar el texto de Raza y Tipo de Criatura"
	TinyTipChatLocale_Opt_KeyElite					= "Usar claves de clasificaci\195\179n"
	TinyTipChatLocale_Opt_PvPRank						= "Rango de JcJ"
	TinyTipChatLocale_Opt_LevelGuess				= "Estimar el nivel"
	TinyTipChatLocale_Opt_ReactionText			= "Mostrar el texto de reacci\195\179nhow Reaction Text"
	TinyTipChatLocale_Opt_KeyServer						= "Mostrar (*) en vez del nombre del servidor"

	TinyTipChatLocale_Desc_Main_Text = "Cambia qu\195\169 texto se muestra dentro del tooltip de unidad."
	TinyTipChatLocale_Desc_HideLevelText = "Determina si se oculta el nivel de texto."
	TinyTipChatLocale_Desc_HideRace = "Determina si se oculta la raza del jugador o el tipo de criatura."
	TinyTipChatLocale_Desc_KeyElite = "Usa * para Elites, ! para Raros, !* para Elites Raros, y ** para Jefes del Mundo."
	TinyTipChatLocale_Desc_PvPRank = "Establece las opciones para mostrar el rango JcJ como texto."
	TinyTipChatLocale_Desc_ReactionText = "Determina si se muestra el texto de reacci\195\179n (Aliado, Hostil, etc)"
	TinyTipChatLocale_Desc_LevelGuess = "Deterrmina si se muestra >(Tu Nivel +10) en vez de ?? para niveles desconocidos."
	TinyTipChatLocale_Desc_KeyServer = "Muestra (*) junto al nombre de la unidad en vez de el nombre de servidor si pertenecen a un servidor diferente."

	TinyTipChatLocale_Opt_Main_Appearance			= "Apariencia"
	TinyTipChatLocale_Opt_Scale								= "Escala"
	TinyTipChatLocale_Opt_Fade								= "Efecto de Desvanecimiento"
	TinyTipChatLocale_Opt_BGColor							= "Coloreado del Fondo"
	TinyTipChatLocale_Opt_Border							= "Coloreado del Borde"
	TinyTipChatLocale_Opt_SmoothBorder				= "Suavizar Borde y Fondo"
	TinyTipChatLocale_Opt_Friends							= "Colorear a Amigos y compa\195\177eros de Hermandad"
	TinyTipChatLocale_Opt_HideInFrames				= "Ocultar tooltip para marcos de unidad"
	TinyTipChatLocale_Opt_FormatDisabled			= "Desactivar formateado de tooltips"
	TinyTipChatLocale_Opt_Compact							= "Mostrar tooltip compacto"

	TinyTipChatLocale_ChatIndex_PvPRank = { 
		[1] = TinyTipChatLocale_Off, 
		[2] = "Mostrar nombre de rango",
		[3] = "Mostrar n\195\186mero de rango tras el nombre"
	}

	TinyTipChatLocale_ChatIndex_Fade = {
		[1] = "Desvanecer siempre",
		[2] = "Nunca desvanecer"
	}

	TinyTipChatLocale_ChatIndex_BGColor = {
		[1] = TinyTipChatLocale_GameDefault,
		[2] = "Colorear PNJs como PJs",
		[3] = "Siempre negro"
	}

	TinyTipChatLocale_ChatIndex_Border = {
		[1] = TinyTipChatLocale_GameDefault,
		[2] = "Ocultar borde"
	}

	TinyTipChatLocale_ChatIndex_Friends = {
		[1] = "Solo colorear nombre",
		[2] = "No colorear"
	}

	TinyTipChatLocale_Desc_Main_Appearance = "Establece la apariencia y comportamiento del tooltip."
	TinyTipChatLocale_Desc_Fade = "Determina si el tooltip se desvanece o simplemente se oculta."
	TinyTipChatLocale_Desc_Scale =  "Determina la escala del tooltip (y de los iconos adjuntos)."
	TinyTipChatLocale_Desc_BGColor = "Establec el esquema de color para el fondo del tooltip de unidad."
	TinyTipChatLocale_Desc_Border = "Establece el esquema de color para el borde del tooltip de unidad."
	TinyTipChatLocale_Desc_SmoothBorder = "Cambia el tama\195\177o y transparencia del fondo y borde del tooltip."
	TinyTipChatLocale_Desc_Friends = "Establece el color del fondo o nombre de forma diferente para amigos y compa\195\177eros de hermandad."
	TinyTipChatLocale_Desc_HideInFrames = "Oculta el tooltip cuando se pasa el rat\195\179n por encima de marcos de unidad."
	TinyTipChatLocale_Desc_FormatDisabled = "Desactiva el formateado especial para tooltips de TinyTip."
	TinyTipChatLocale_Desc_Compact = "Compacta el tooltip sin cambiar su escala."


	if getglobal("GetAddOnMetadata")("TinyTipExtras", "Title") then
		TinyTipChatLocale_Opt_PvPIconScale	= "Escala del Icono JcJ"
		TinyTipChatLocale_Opt_RTIconScale		= "Escala del Icono de Objetivo de Banda"
		TinyTipChatLocale_Opt_BuffScale			= "Escala de los iconos de Buff y Debuff"

		TinyTipChatLocale_Desc_PvPIconScale		= "Establece la escala del Icono JcJ."
		TinyTipChatLocale_Desc_RTIconScale		= "Establece la escala del Icono de Objetivo de Banda."
		TinyTipChatLocale_Desc_BuffScale			= "Establece la escala de los iconos de Buff y Debuff."

		TinyTipChatLocale_Opt_Main_Targets				= "Objetivo de ..."
		TinyTipChatLocale_Opt_ToT									= "Unidad del Tooltip"
		TinyTipChatLocale_Opt_ToP									= "Grupo"
		TinyTipChatLocale_Opt_ToR									= "Banda"

		TinyTipChatLocale_ChatIndex_ToT = {
			[1] = "Mostrar el objetivo de la unidad del tooltip en una nueva linea",
			[2] = "Mostrar el objetivo en la misma linea que el nombre de la unidad"
		}

		TinyTipChatLocale_ChatIndex_ToP = {
			[1] = "Mostrar cada nombre",
			[2] = "Mostrar el n\195\186mero de jugadores"
		}

		TinyTipChatLocale_ChatIndex_ToR = {
			[1] = "Mostrar el n\195\186mero de jugadores",
			[2] = "Mostrar la cuenta de cada clase",
			[3] = "Mostrar TODOS los nombres"
		}

		TinyTipChatLocale_Desc_Main_Targets = "A\195\177ade informaci\195\179n del objetivo del objetivo al tooltip de unidad."
		TinyTipChatLocale_Desc_ToT = "Determina si se muestra el nombre del objetivo de la unidad del tooltip."
		TinyTipChatLocale_Desc_ToP = "Determina si se muestra cu\195\161ntos en tu grupo tienen seleccionada a la unidad del tooltip."
		TinyTipChatLocale_Desc_ToR = "Determina si se muestra cu\195\161ntos en tu banda tienen seleccionada a la unidad del tooltip."

		TinyTipChatLocale_Opt_Main_Extras					= "Extras"
		TinyTipChatLocale_Opt_PvPIcon							= "Mostrar Icono de Rango JcJ"
		TinyTipChatLocale_Opt_ExtraTooltip				= "Tooltip Extra de TinyTip"
		TinyTipChatLocale_Opt_Buffs								= "Buffs"
		TinyTipChatLocale_Opt_Debuffs							= "Debuffs"
		TinyTipChatLocale_Opt_ManaBar					= "Mostrar la barra de man\195\161"
		TinyTipChatLocale_Opt_RTIcon					= "Mostrar el Icono de Objetivo de Banda"

		TinyTipChatLocale_ChatIndex_ExtraTooltip	= {
			[1] = "Mostrar informaci\195\179n de otros accesorios",
			[2] = "Mostrar informaci\195\179n de otros accesorios y TinyTip Extra"
		}

		TinyTipChatLocale_ChatIndex_Buffs = {
			[1] = "Mostrar 8 Buffs",
			[2] = "Mostrar solo Buffs que puedes lanzar",
			[3] = "Mostrar en el tooltip el n\195\186mero de buffs que puedes lanzar"
		}

		TinyTipChatLocale_ChatIndex_Debuffs = {
			[1] = "Mostrar 8 Debuffs",
			[2] = "Mostrar solo debuffs que puedes disipar",
			[3] = "Mostrar en el tooltip el n\195\186mero de debuffs que puedes disipar",
			[4] = "Mostrar en el tooltip el n\195\186mero de cada tipo de debuff que puedes disipar",
			[5] = "Mostrar en el tooltip el n\195\186mero de TODOS los tipos de debuff"
		}

		TinyTipChatLocale_Desc_Main_Extras = "Caracter\195\173sticas extra no inclu\195\173das en el n\195\186cleo de TinyTip."
		TinyTipChatLocale_Desc_PvPIcon = "Determina sis e muestra el icono del rango JcJ del jugador a la izquierda del tooltip."
		TinyTipChatLocale_Desc_ExtraTooltip = "A\195\177ade informaci\195\179n de otros accesorios y/o TinyTip en un tooltip separado."
		TinyTipChatLocale_Desc_Buffs			= "Muestra la informaci\195\179n sobre los buffs de una unidad."
		TinyTipChatLocale_Desc_Debuffs		= "Muestra la informaci\195\179n sobre los debuffs de una unidad."
		TinyTipChatLocale_Desc_ManaBar		= "Muestra la barra de man\195\161 bajo la barra de salud."
		TinyTipChatLocale_Desc_RTIcon			= "Muestra el icono de objetivo de banda en el tooltip de la unidad, si existe."
	end

	TinyTipChatLocale_Opt_Profiles = "Guardar ajustes por personaje"
	TinyTipChatLocale_Desc_Profiles = "Determina si se guardan tus ajustes por personaje o globalmente."

	TinyTipChatLocale_Opt_Main_Default = "Reestablecer Opciones"
	TinyTipChatLocale_Desc_Main_Default = "Asigna los valores por defecto a este accesorio."

	-- slash command-related stuff
	TinyTipChatLocale_DefaultWarning = "\194\191Est\195\161s SEGURO de que quieres devolver tus ajustes a sus valores por defecto? Entonces escribe "
	TinyTipChatLocale_NotValidCommand = "no es un comando v\195\161lido."

	TinyTipChatLocale_Confirm = "confirmar" -- must be lowercase!
	TinyTipChatLocale_Opt_Slash_Default = "default" -- ditto

	-- we're done with this.
	TinyTipChatLocale = nil
end
