--[[ TinyTip by Thrae
-- 
--
-- German Localization
-- For TinyTipChat
--
-- Any wrong words, change them here.
-- 
-- TinyTipChatLocale should be defined in your FIRST localization
-- code.
--
-- Note: Other localization is in TinyTipLocale_deDE.
-- 
-- Contributors: Gamefaq 
--]]

if TinyTipChatLocale and TinyTipChatLocale == "deDE" then
	TinyTipChatLocale_MenuTitle = "TinyTip Optionen"

	TinyTipChatLocale_On = "An"
	TinyTipChatLocale_Off = "Aus"
	TinyTipChatLocale_GameDefault = "WoW Grundeinstellung"
	TinyTipChatLocale_TinyTipDefault = "TinyTip's Grundeinstellung"

	if getglobal("TinyTipAnchorExists") then
		TinyTipChatLocale_Opt_Main_Anchor			= "Tooltip Grundposition"
		TinyTipChatLocale_Opt_MAnchor					= "Spieler Position"
		TinyTipChatLocale_Opt_FAnchor					= "Fenster Position"
		TinyTipChatLocale_Opt_MOffX						= "Spieler Position waagerechte [X-Achse]"
		TinyTipChatLocale_Opt_MOffY						= "Spieler Position senkrechte [Y-Achse]"
		TinyTipChatLocale_Opt_FOffX						= "Fenster Position waagerechte [X-Achse]"
		TinyTipChatLocale_Opt_FOffY						= "Fenster Position senkrechte [Y-Achse]"
		TinyTipChatLocale_Opt_AnchorAll				= "Verankern von Zusatz Tooltips am Fix Punkt"
		TinyTipChatLocale_Opt_AlwaysAnchor		= "Spiel Tooltips immer am Fix Punkt verankern"

		TinyTipChatLocale_ChatMap_Anchor = {
			["LEFT"]				= "LINKS", 
			["RIGHT"]				= "RECHTS", 
			["BOTTOMRIGHT"]	= "UNTENRECHTS", 
			["BOTTOMLEFT"]	= "UNTENLINKS", 
			["BOTTOM"]			= "UNTEN", 
			["TOP"]					= "OBEN", 
			["TOPLEFT"] 		= "OBENLINKS", 
			["TOPRIGHT"] 		= "OBENRECHTS",
			["CENTER"]			= "MITTE"
		}

		TinyTipChatLocale_Anchor_Cursor = "CURSOR"
		TinyTipChatLocale_Anchor_Sticky = "FEST"

		TinyTipChatLocale_Desc_Main_Anchor = "Justiert die Tooltip Position."
		TinyTipChatLocale_Desc_MAnchor = "Justiert die Position für den Tooltip wenn man mit dem Mausecourser über andere Spieler im Hauptfenster geht."
		TinyTipChatLocale_Desc_FAnchor = "Justiert die Position des Tooltips wenn man über ein BELIBIGES Fenster mit dem Mauscourser geht ein (außer das Hauptfenster)."
		TinyTipChatLocale_Desc_MOffX = "Justiert die horinzontale Position des Tooptips ein für den Fixpunkt der Spieler."
		TinyTipChatLocale_Desc_MOffY = "Justiert die vertikale Position des Tooltips für den Fixpunkt der Spieler."
		TinyTipChatLocale_Desc_FOffX = "Justiert die waagerechte Position des Tooltips ausgehend vom Fixpunkt für ALLE Fenster."
		TinyTipChatLocale_Desc_FOffY = "Justiert die senkrechte Position des Tooltips ausgehend vom Fixpunkt für ALLE Fenster."
		TinyTipChatLocale_Desc_AnchorAll = "Positioniert ALLE Zusatz Fenster Tooltips am Tooltip Fixpunkt welche die 'GameTooltip_SetDefaultAnchor' Funktion benutzen, anstelle des WoW Tooltippunktes."
		TinyTipChatLocale_Desc_AlwaysAnchor = "Fixiere die Positionen von Fenster Tooltips am Tooltip Fixpunkt welche den erweiterten WoW Tooltip verwenden. Dies kann zb. mit dem Bergbauvorkommen, Kräuter usw. Tooltips verwendet werden und jedem anderen Tooltipfenster das den erweiterten WoW Tooltip verwendet."

		if getglobal("GetAddOnMetadata")("TinyTipExtras", "Title") then
			TinyTipChatLocale_Opt_ETAnchor				= "Extra Tooltip Position"
			TinyTipChatLocale_Opt_ETOffX					= "Extra Tooltip horizontale Position[X-Achse]"
			TinyTipChatLocale_Opt_ETOffY					= "Extra Tooltip vertikale Position [Y-Achse]"
			TinyTipChatLocale_Desc_ETAnchor 			= "Justiert die Position für den Extra Tooltip."
			TinyTipChatLocale_Desc_ETOffX					= "Justiert die horizontale Position für den Fixpunkt des Extra Tooltips."
			TinyTipChatLocale_Desc_ETOffY					= "Justiert die vertikale Position für den Fixpunkt des Extra Tooltips."

			TinyTipChatLocale_Opt_PvPIconAnchor1	= "PvP Rangsymbol Position"
			TinyTipChatLocale_Opt_PvPIconAnchor2	= "PvP Rangsymbol Grundposition"
			TinyTipChatLocale_Opt_PvPIconOffX			= "PvP Rangsymbol [X-Achse]"
			TinyTipChatLocale_Opt_PvPIconOffY			= "PvP Rangsymbol [Y-Achse]"

			TinyTipChatLocale_Desc_PvPIconAnchor1	= "Justiert die Position für das PVP Symbol."
			TinyTipChatLocale_Desc_PvPIconAnchor2	= "Justiert die Grundposition für das PVP Rangsymbol."
			TinyTipChatLocale_Desc_PvPIconOffX		= "Justiert die horizontale X-Achsen Position für den Fixpunkt des PVP Rangsymbols."
			TinyTipChatLocale_Desc_PvPIconOffY		= "Justiert die vertikale Y-Achsen Position für den Fixpunkt des PVP Rangsymbols."

			TinyTipChatLocale_Opt_RTIconAnchor1		= "Schlachtgruppenziel Symbol Fixpunkt"
			TinyTipChatLocale_Opt_RTIconAnchor2		= "Schlachtgruppenziel Symbol Grundpositions Fixpunkt"
			TinyTipChatLocale_Opt_RTIconOffX			= "Schlachtgruppenziel Symbol [X-Achse]"
			TinyTipChatLocale_Opt_RTIconOffY			= "Schlachtgruppenziel Symbol [Y-Achse]"

			TinyTipChatLocale_Desc_RTIconAnchor1	= "Justiert die Position für das Schlachtgruppenziel Symbol."
			TinyTipChatLocale_Desc_RTIconAnchor2	= "Justiert die Grundposition für das Schlachtgruppenziel Symbol."
			TinyTipChatLocale_Desc_RTIconOffX			= "Justiert die horizontale X-Achsen Position für den Fixpunkt des Schlachtgruppenziel Symbols."
			TinyTipChatLocale_Desc_RTIconOffY			= "Justiert die vertikale Y-Achsen Position für den Fixpunkt des Schlachtgruppenziel Symbols."

			TinyTipChatLocale_Opt_BuffAnchor1			= "Buffs Position"
			TinyTipChatLocale_Opt_BuffAnchor2			= "Buffs Grundposition"
			TinyTipChatLocale_Opt_BuffOffX				= "Buffs [X-Achse]"
			TinyTipChatLocale_Opt_BuffOffY				= "Buffs [Y-Achse]"

			TinyTipChatLocale_Opt_DebuffAnchor1		= "Debuffs Position"
			TinyTipChatLocale_Opt_DebuffAnchor2		= "Debuffs Grundposition"
			TinyTipChatLocale_Opt_DebuffOffX			= "Debuff [X-Achse]"
			TinyTipChatLocale_Opt_DebuffOffY			= "Debuff [Y-Achse]"

			TinyTipChatLocale_Desc_BuffAnchor1	= "Justiert die Position für die Buff Symbole."
			TinyTipChatLocale_Desc_BuffAnchor2	= "Justiert die Grundposition für die Buff Symbole ."
			TinyTipChatLocale_Desc_BuffOffX			= "Justiert die horizontale X-Achsen Position für den Fixpunkt der Buff Symbole."
			TinyTipChatLocale_Desc_BuffOffY			= "Justiert die vertikale Y-Achsen Position für den Fixpunkt der Buff Symbole."

			TinyTipChatLocale_Desc_DebuffAnchor1	= "Justiert die Position für die Debuff Symbole."
			TinyTipChatLocale_Desc_DebuffAnchor2	= "Justiert die Grundposition für die Debuff Symbole."
			TinyTipChatLocale_Desc_DebuffOffX			= "Justiert die horizontale X-Achsen Position für den Fixpunkt der Debuff Symbole."
			TinyTipChatLocale_Desc_DebuffOffY			= "Justiert die vertikale Y-Achsen Position für den Fixpunkt die Debuff Symbole."
		end
	end

	TinyTipChatLocale_Opt_Main_Text					= "Text"
	TinyTipChatLocale_Opt_HideLevelText			= "Verstecke Level Text"
	TinyTipChatLocale_Opt_HideRace					= "Verstecke Rassen und Kreatur Typen Text"
	TinyTipChatLocale_Opt_KeyElite					= "Benutze Rar/Elite Markierung"
	TinyTipChatLocale_Opt_PvPRank						= "PvP Rang"
	TinyTipChatLocale_Opt_LevelGuess				= "Verstecke Levelnangabe"
	TinyTipChatLocale_Opt_ReactionText			= "Zeige Reaktionstext"
	TinyTipChatLocale_Opt_KeyServer					= "Anzeigen von (*) anstelle des Server Namens"

	TinyTipChatLocale_Desc_Main_Text = "Stellt ein was im Spieler Tooltip angezeigt wird."
	TinyTipChatLocale_Desc_HideLevelText = "Das Level des Ziels anzeigen?"
	TinyTipChatLocale_Desc_HideRace = "Spieler Rasse oder Monster Typ anzeigen?"
	TinyTipChatLocale_Desc_KeyElite = "Anzeigeart * für Elite, ! für Rare, !* für Rare Elite, und ** für Welt Boss."
	TinyTipChatLocale_Desc_PvPRank = "Stelle die Optionen ein um den PVP Rang in Textform anzuzeigen."
	TinyTipChatLocale_Desc_ReactionText = "Reaktionstext der Ziele anzeigen ? (Freundlich, Feindlich, usw.)"
	TinyTipChatLocale_Desc_LevelGuess = "Anzeige umschalten (Dein Level +10) anstelle von ?? für unbekannte Gegner Level?"
	TinyTipChatLocale_Desc_KeyServer = "Anzeigen von (*) neben den Spieler Namen, wenn sie von einem anderen Server stammen anstatt den Server Namen anzuzeigen."

	TinyTipChatLocale_Opt_Main_Appearance			= "Aussehen"
	TinyTipChatLocale_Opt_Scale								= "Skalierung"
	TinyTipChatLocale_Opt_Fade								= "Ausblenden Effect"
	TinyTipChatLocale_Opt_BGColor							= "Hintergrund Optionen"
	TinyTipChatLocale_Opt_Border							= "Rand Optionen"
	TinyTipChatLocale_Opt_SmoothBorder				= "Rand und Hintergrund glätten"
	TinyTipChatLocale_Opt_Friends							= "Farbton für Freunde und Gildenkollegen"
	TinyTipChatLocale_Opt_HideInFrames				= "Verstecke Tooltips von Spieler Fenstern"
	TinyTipChatLocale_Opt_FormatDisabled			= "Deaktiviere Tooltip Formatierung"
	TinyTipChatLocale_Opt_Compact							= "Zeige kompakten Tooltip"

	TinyTipChatLocale_ChatIndex_PvPRank = { 
		[1] = TinyTipChatLocale_Off, 
		[2] = "Zeige Rang Namen",
		[3] = "Zeige Rang Nummer nach dem Namen"
	}

	TinyTipChatLocale_ChatIndex_Fade = {
		[1] = "Immer Ausblenden ",
		[2] = "Nie Ausblenden"
	}

	TinyTipChatLocale_ChatIndex_BGColor = {
		[1] = TinyTipChatLocale_GameDefault,
		[2] = "Färbe NPCs wie PCs",
		[3] = "Immer Schwarz"
	}

	TinyTipChatLocale_ChatIndex_Border = {
		[1] = TinyTipChatLocale_GameDefault,
		[2] = "Verstecke Rahmen"
	}

	TinyTipChatLocale_ChatIndex_Friends = {
		[1] = "Färbe nur Namen",
		[2] = "Kein einfärben"
	}

	TinyTipChatLocale_Desc_Main_Appearance = "Stellt Aussehen und Verhalten des Tooltips ein."
	TinyTipChatLocale_Desc_Fade = "Tooltip weich ausblenden lassen oder einfach wegschalten?"
	TinyTipChatLocale_Desc_Scale =  "Stellt die Skalierung des Tooltips und eventuell angehefter Icons ein."
	TinyTipChatLocale_Desc_BGColor = "Stellt die Farben des Tooltip Hintergunds ein."
	TinyTipChatLocale_Desc_Border = "Stellt die Farben für den Tooltipramen ein."
	TinyTipChatLocale_Desc_SmoothBorder = "Verändert die voreingestellte Transpazenz und Größe des Hintergrunds und Rahmens."
	TinyTipChatLocale_Desc_Friends = "Namen und Hintegrund anders einfärben als von Freunden und Gidenmitgliedern?"
	TinyTipChatLocale_Desc_HideInFrames = "Verstecke den Tooltip von Interface Fenstern (Party/Schachtgruppe/Ziel) die zu Spielern gehören, wenn man mit dem Mauscourser über sie geht."
	TinyTipChatLocale_Desc_FormatDisabled = "Deaktiviert TinyTip's spezielle Tooltip Formatierung."
	TinyTipChatLocale_Desc_Compact = "Verkleinert den Tooltip ohne Änderrung der Skalierung."

	
	if getglobal("GetAddOnMetadata")("TinyTipExtras", "Title") then
		TinyTipChatLocale_Opt_PvPIconScale	= "PvP Symbol Skalierung"
		TinyTipChatLocale_Opt_RTIconScale		= "Schlachtgruppenziel Skalierung"
		TinyTipChatLocale_Opt_BuffScale			= "Buff und Debuff Skalierung"

		TinyTipChatLocale_Desc_PvPIconScale		= "Stellt die größe das PVP Symbols ein."
		TinyTipChatLocale_Desc_RTIconScale		= "Stellt die größe das Schlachtgruppen Symbols ein."
		TinyTipChatLocale_Desc_BuffScale			= "Stellt die größe des Buff und Debuff Symbols ein."

		TinyTipChatLocale_Opt_Main_Targets				= "Ziel von..."
		TinyTipChatLocale_Opt_ToT									= "Spieler Tooltip's "
		TinyTipChatLocale_Opt_ToP									= "Gruppe"
		TinyTipChatLocale_Opt_ToR									= "Schlachtgruppe"

		TinyTipChatLocale_ChatIndex_ToT = {
			[1] = "Zeige Ziel des Spielers in einer neuen Spalte",
			[2] = "Zeige Ziel des Spielers in der gleichen Spalte wie seinen Namen"
		}

		TinyTipChatLocale_ChatIndex_ToP = {
			[1] = "Zeige alle Namen",
			[2] = "Zeige # der Spieler"
		}

		TinyTipChatLocale_ChatIndex_ToR = {
			[1] = "Zeige # der Spieler",
			[2] = "Zeige Anzahl aus jeder Klasse",
			[3] = "Zeige ALL Namen"
		}

		TinyTipChatLocale_Desc_Main_Targets = "Zeigt das Ziel des eigenen Ziels auch im Tooltip an."
		TinyTipChatLocale_Desc_ToT = "Stellt ein ob man den Namen des Ziels, vom eigenen Ziel angezeigt haben möchte."
		TinyTipChatLocale_Desc_ToP = "Anzeigen ob jemand anderes aus deiner Gruppe, dein Ziel auch angeklickt hat."
		TinyTipChatLocale_Desc_ToR = "Anzeigen ob jemand anderes aus deiner Schlachtgruppe, dein Ziel auch angeklickt hat."

		TinyTipChatLocale_Opt_Main_Extras					= "Extras"
		TinyTipChatLocale_Opt_PvPIcon							= "Zeige PvP Rangsymbol"
		TinyTipChatLocale_Opt_ExtraTooltip				= "TinyTip's Extra Tooltip"
		TinyTipChatLocale_Opt_Buffs								= "Buffs"
		TinyTipChatLocale_Opt_Debuffs							= "Debuffs"
		TinyTipChatLocale_Opt_ManaBar					= "Zeigt Mana Balken"
		TinyTipChatLocale_Opt_RTIcon					= "Zeigt Schlachtgruppensymbol"

		TinyTipChatLocale_ChatIndex_ExtraTooltip	= {
			[1] = "Zeige Informationen von anderen Addons",
			[2] = "Zeige von anderen Addons & TinyTip's Extra Infos"
		}

		TinyTipChatLocale_ChatIndex_Buffs = {
			[1] = "Zeige 8 Buffs",
			[2] = "Zeige nur selbst zauberbare Buffs",
			[3] = "Zeige Menge an Buffs im Tooltip"
		}

		TinyTipChatLocale_ChatIndex_Debuffs = {
			[1] = "Zeige 8 Debuffs",
			[2] = "Zeige NUR selbst entfernbare Debuffs",
			[3] = "Zeige Menge von entfernbaren Debuffs im Tooltip",
			[4] = "Zeige Menge von jeder Art selbst entfernbarer Debuffs im Tooltip",
			[5] = "Zeige Menge von ALLEN Arten von Debuffs im Tooltip"
		}

		TinyTipChatLocale_Desc_Main_Extras = "Extra Funktionen die nicht im TinyTip Basis Addon enthalten sind."
		TinyTipChatLocale_Desc_PvPIcon = "Anzeigen des PVP Rang Icons eines Spielers neben dem Tooltip?"
		TinyTipChatLocale_Desc_ExtraTooltip = "Zusätzliche Addon Informationen von TinyTip und anderen Addons in einem SEPERATEN Tooltip anzzeigen? (Manche Addons benötigen einen zusatz Tooltip für ihre Informationen.)"
		TinyTipChatLocale_Desc_Buffs			= "Zeige Informationen welche Buffs das Ziel hat."
		TinyTipChatLocale_Desc_Debuffs		= "Zeige Informationen welche Debuffs das Ziel hat."
		TinyTipChatLocale_Desc_ManaBar		= "Zeige eine Manaleiste unter der Lebensenergieleiste."
		TinyTipChatLocale_Desc_RTIcon			= "Zeigt das Schlachtgruppensymbol für das ausgewählte Ziel, falls es existiert."
	end

	TinyTipChatLocale_Opt_Profiles = "Speichere die Einstellungen pro Charakter"
	TinyTipChatLocale_Desc_Profiles = "Auswahl ob man pro Charakter die Einstellungen speichern möchte oder global für alle."

	TinyTipChatLocale_Opt_Main_Default = "Optionen zurücksetzen"
	TinyTipChatLocale_Desc_Main_Default = "Setzt die Einstellungen zurrück auf die Grundeinstellungen."

	-- slash command-related stuff
	TinyTipChatLocale_DefaultWarning = "Bist du SICHER das du die Einstellungen zurrück auf die Grundeinstellungen setzen willst? Tippe ein "
	TinyTipChatLocale_NotValidCommand = "ist keine gültige eingabe."

	TinyTipChatLocale_Confirm = "bestätige" -- must be lowercase!
	TinyTipChatLocale_Opt_Slash_Default = "standart" -- ditto

	-- we're done with this.
	TinyTipChatLocale = nil
end

