-- -------------------------------------------------------------------
-- Localization for AHsearch
-- -------------------------------------------------------------------

local L = AceLibrary("AceLocale-2.2"):new("AHsearch")

L:RegisterTranslations("deDE", function() return {
	["Search"] = "Suche",
	["Search query"] = "Suchabfrage",
	["search queries"] = "Suchabfragen",
	["Search term"] = "Suchbegriff",
	["Category"] = "Kategorie",
	["Options"] = "Optionen",

--- tooltip ------------------
	["Tooltip"] = "Tooltip",
	["Tooltip settings"] = "Tooltip Einstellungen",
	["Show tooltip"] = "Tooltip anzeigen",
	["Simple filters display"] = "Einfache Filter Anzeige",
	["Tooltip shows only selected filters resp. 'no filters' instead of '1.) -' '2.) -' '3.) -'."] = "Tooltip zeigt nur ausgewählte Filter bzw. 'kein filter' statt '1.) -' '2.) -' '3.) -'.",
	["Level Range"] = "Stufenreichweite",
	["Rarity"] = "Seltenheit",
	[" and better"] = " und besser",
	["Usable Items"] = "Benutzbare Gegenstände",
	["Display on Character"] = "Vorschau",
	["Filters"] = "Filter",
	["YES"] = "JA",
	["NO"] = "NEIN",
	
--- Search ------------------
	["SEARCH: Search query: %s - Search term: '%s' - Category: %s"] = "SUCHE: Suchabfrage: %s - Suchbegriff: '%s' - Kategorie: %s",
	["No category available!"] = "Keine Kategorie verfügbar!",
	["Right-click 'AHsearch Button' for options!"] = "Rechtsklick auf 'AHsearch Button' für Optionen!",

--- Search query: Save ------------------
	["Search query: Save"] = "Suchabfrage: Speichern",
	["Save your current search query in a category."] = "Speichere die aktuelle Suchabfrage in einer Kategorie.",
	["Overwrite excisting search query '%s' in category '%s'?"] = "Vorhandene Suchabfrage '%s' in Kategorie '%s' überschreiben?",
	["Search query '%s' SAVED in category '%s'!"] = "Suchabfrage '%s' in Kategorie '%s' GESPEICHERT!",

--- Search query: Edit ------------------
	["Search query: Edit"] = "Suchabfrage: Bearbeiten",
	["Edit position, search query, search term, level range, rarity, usable items, display on character and filters for a search query."] = "Position, Suchabfrage, Suchbegriff, Stufenreichweite, Seltenheit, Benutzbare Gegenstände, Vorschau und Filter einer Suchabfrage ändern.",

	["Search query: Sort"] =  "Suchabfrage: Sortieren",
	["Sort search query by assigning a number to it.\nSort sequence:\n1.) number\n2.) rarity\n3.) upper case\n4.) lower case"] = "Suchabfrage mit einer zuordnenden Nummer sortieren.\nSortierreihenfolge:\n1.) Nummer\n2.) Seltenheit\n3.) Großschreibung\n4.) Kleinschreibung",
	["ASSIGNED sort number '%s' to search query '%s' (Category: %s)!"] = "Sortiernummer '%s' der Suchabfrage '%s' (Kategorie: %s) ZUGEORDNET!",

	["Search query: Rename search query"] = "Suchabfrage: Suchabfrage umbenennen",
	["Rename the name of your search query. This is the name that is shown in the menu."] = "Den Namen der Suchabfrage umbenennen. Dieser Name wird im Menu gezeigt.",
	["Search query '%s' (Search term: '%s' - Category: %s) RENAMED TO '%s'!"] = "Suchabfrage '%s' (Suchbegriff: '%s' - Kategorie: %s) in '%s' UMBENANNT!",

	["Search query: Rename search term"] = "Suchabfrage: Suchbegriff umbenennen",
	["Rename the search term of your search query. This is the search term that is shown in the auction house searchtextbox (blank will search all)."] = "Den Suchbegriff der Suchabfrage umbenennen. Suchbegriff der im Auktionhaus in der Suchtextbox erscheint (unausgefüllt wird alles durchsucht).",
	["Search term '%s' (Search query: %s - Category: %s) CHANGED TO '%s'!"] = "Suchbegriff '%s' (Suchabfrage: %s - Kategorie: %s) in '%s' GEÄNDERT!",

	["Search query: Level range"] = "Suchabfrage: Stufenreichweite",
	["Change min. and max. level range (blank (no value) will search all)."] = "Min. und max. Level ändern (unausgefüllt (kein wert) wird alles durchsucht).",
	["min"] = "min",
	["max"] = "max",
	["no value"] = "kein wert",
	["Min. Level for search query '%s' (Category: %s) CHANGED TO 'no value'!"] = "Min. Level der Suchabfrage '%s' (Kategorie: %s) in 'kein wert' GEÄNDERT!",
	["Min. Level for search query '%s' (Category: %s) CHANGED TO %s!"] = "Min. Level der Suchabfrage '%s' (Kategorie: %s) in %s GEÄNDERT!",
	["Max. Level for search query '%s' (Category: %s) CHANGED TO 'no value'!"] = "Max. Level der Suchabfrage '%s' (Kategorie: %s) in 'kein wert' GEÄNDERT!",
	["Max. Level for search query '%s' (Category: %s) CHANGED TO %s!"] = "Max. Level der Suchabfrage '%s' (Kategorie: %s) in %s GEÄNDERT!",

	["Search query: Rarity"] = "Suchabfrage: Seltenheit",
	["Change rarity. Only selected rarity or better will show in searchresult."] = "Seltenheit ändern. Nur die ausgewählte Seltenheitsstufe oder besser wird im Suchergebnis angezeigt.",
	["Rarity for search query '%s' (Category: %s) CHANGED TO %s!"] = "Seltenheit der Suchabfrage '%s' (Kategorie: %s) in %s GEÄNDERT!",

	["Search query: Usable Items"] = "Suchabfrage: Benutzbare Gegenstände",
	["Usable Items for search query '%s' (Category: %s) SET TO %s!"] = "Benutzbare Gegenstände der Suchabfrage '%s' (Kategorie: %s) auf %s GESETZT!",

	["Search query: Display on Character"] = "Suchabfrage: Vorschau",
	["Display on Character for search query '%s' (Category: %s) SET TO %s!"] = "Vorschau der Suchabfrage '%s' (Kategorie: %s) auf %s GESETZT!",

	["Search query: Filters"] = "Suchabfrage: Filter",
	["Select a filter. Only one filter is selectable."] = "Filter auswählen. Nur ein Filter ist auswählbar.",
	["no filters"] = "kein filter",
	["Filters for search query '%s' (Category: %s) CHANGED TO %s!"] = "Filter der Suchabfrage '%s' (Kategorie: %s) auf %s GEÄNDERT!",
	["Filters for search query '%s' (Category: %s) CHANGED TO %s-%s!"] = "Filter der Suchabfrage '%s' (Kategorie: %s) auf %s-%s GEÄNDERT!",
	["Filters for search query '%s' (Category: %s) CHANGED TO %s-%s-%s!"] = "Filter der Suchabfrage '%s' (Kategorie: %s) auf %s-%s-%s GEÄNDERT!",

--- Search query: Delete ------------------
	["Search query: Delete"] = "Suchabfrage: Löschen",
	["Delete a search query."] = "Lösche eine Suchabfrage.",
	["Delete search query '%s' in category '%s'?"] = "Suchabfrage '%s' in Kategorie '%s' löschen?",
	["Search query '%s' in category '%s' DELETED!"] = "Suchabfrage '%s' in Kategorie '%s' GELÖSCHT!",

--- Search query: Move ------------------
	["Search query: Move"] = "Suchabfrage: Verschieben",
	["Move a search query from one category to another category.\n\nATTENTION:\nPosition is set to 1!"] = "Verschiebe eine Suchabfrage von einer Kategorie in eine andere Kategorie.\n\nACHTUNG:\nPosition wird auf 1 gesetzt!",
	["Move\nsearch query '%s'\nin category '%s'\nto category '%s'.\n\nATTENTION:\nPosition is set to 1!"] = "Verschiebe\nSuchabfrage '%s'\nvon Kategorie '%s'\nnach Kategorie '%s'.\n\nACHTUNG:\nPosition wird auf 1 gesetzt!",
	["Search query '%s' in category '%s' MOVED TO category '%s'."] = "Suchabfrage '%s' in Kategorie '%s' nach Kategorie '%s' VERSCHOBEN.",
	["Search query '%s' exists in category '%s'! Overwrite?"] = "Suchabfrage '%s' ist in Kategorie '%s' vorhanden! Überschreiben?",

--- Category: Create ------------------
	["Category: Create"] = "Kategorie: Erstellen",
	["Create a new category."] = "Erstelle eine neue Kategorie.",
	["Category '%s' exists!\nOverwrite excisting category '%s'?\nAll search queries in that category will be deleted!"] = "Kategorie '%s' vorhanden!\nVorhandene Kategorie '%s' überschreiben?\nAlle Suchabfragen in dieser Kategorie werden gelöscht!",
	["Category '%s' CREATED!"] = "Kategorie '%s' ERSTELLT!",

--- Category: Edit ------------------
	["Category: Edit"] = "Kategorie: Bearbeiten",
	["Rename, sort, set color and icon for a category."] = "Kategorie umbenennen, sortieren, Farbe und Icon zuweisen.",

	["Category: Rename"] = "Kategorie: Umbenennen",
	["Rename category."] = "Kategorie umbenennen.",
	["Category '%s' RENAMED TO '%s'!"] = "Kategorie '%s' in '%s' UMBENANNT!",

	["Category: Sort"] = "Kategorie: Sortieren",
	["Sort category by assigning a number to it.\nSort sequence:\n1.) number\n2.) upper case\n3.) lower case"] = "Kategorie mit einer zuordnenden Nummer sortieren.\nSortierreihenfolge:\n1.) Nummer\n2.) Großschreibung\n3.) Kleinschreibung",
	["ASSIGNED sort number '%s' to category '%s'!"] = "Sortiernummer '%s' der Kategorie '%s' ZUGEORDNET!",
	["Position"] = "Position",

	["Category: Color"] = "Kategorie: Farbe",
	["Set color for a category."] = "Kategorie Farbe zuweisen.",
	["Color"] = "Farbe",
	["SELECTED color for category '%s': %s%s ### '%s'|r"] = "GEWÄHLTE Farbe für Kategorie '%s': %s%s ### '%s'|r",

	["Category: Icon"] = "Kategorie: Icon",
	["Set icon for a category."] = "Kategorie Icon zuweisen.",
	["Icon"] = "Icon",
	["SELECTED icon for category '%s': %s"] = "GEWÄHLTES Icon für Kategorie '%s': %s",
	["selected"] = "ausgewählt",

--- Category: Delete ------------------
	["Category: Delete"] = "Kategorie: Löschen",
	["Delete category and all saved search queries in that category!"] = "Kategorie und alle gespeicherten Suchabfragen in dieser Kategorie löschen!",
	["Delete category '%s'?\nAll search queries in that category will be deleted!"] = "Kategorie '%s' löschen?\nAlle Suchabfragen in dieser Kategorie werden gelöschen!",
	["Category '%s' DELETED!"] = "Kategorie '%s' GELÖSCHT!",

--- Chatoutput ------------------
	["Chatoutput"] = "Chatausgabe",
	["Activate/Deactivate chatoutput for:\n- SEARCH\n- Search query: SAVE, EDIT, MOVE & DELETE\n- Category: CREATE, EDIT & DELETE"] = "Aktiviert/Deaktiviert Chatausgabe für:\n- SUCHE\n- Suchabfrage: SPEICHERN, BEARBEITEN, VERSCHIEBEN & LÖSCHEN\n- Kategorie: ERSTELLEN, BEARBEITEN & LÖSCHEN",

--- Help ------------------
	["Help"] = "Hilfe",
	["Step 1 or 2: Right-click 'AHsearch Button' and create category ('Category: Create')."] = "Schritt 1 oder 2: Rechtsklick 'AHsearch-Button' und erstelle eine Kategorie ('Kategorie: Erstellen').",
	["Step 1 or 2: Set up your search criteria (you don't have to click the search button)."] = "Schritt 1 oder 2: Stell deine Suchanfrage ein (Suchen-Button klicken nicht erforderlich).",
	["Step 3: Right-click 'AHsearch Button' and choose a category in 'Search query: Save'."] = "Schritt 3: Rechtsklick 'AHsearch-Button' und wähle eine Kategorie in 'Suchabfrage: Speichern'.",
	["Step 4: Give your search a name. Press return."] = "Schritt 4: Gib deiner Suche einen Namen. Drücke Return.",
	["Step 5: Left-click 'AHsearch Button' for your search queries."] = "Schritt 5: Linksklick 'AHsearch-Button' für deine Suchabfragen.",

	["Maximum text length for categories and search queries: %s characters"] = "Maximale Textlänge für Kategorien und Suchabfragen: %s Buchstaben",
	["Color coding for saved search queries:"] = "Farbcodierung für gespeicherte Suchabfragen:",
	["All"] = "Alle",
	["Poor"] = "Schlecht",
	["Common"] = "Verbreitet",
	["Uncommon"] = "Selten",
	["Rare"] = "Rar",
	["Epic"] = "Episch",

} end)