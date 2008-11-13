-- -------------------------------------------------------------------
-- Localization for AHsearch
-- -------------------------------------------------------------------

local L = AceLibrary("AceLocale-2.2"):new("AHsearch")

L:RegisterTranslations("enUS", function() return {
	["Search"] = true,
	["Search query"] = true,
	["search queries"] = true,
	["Search term"] = true,
	["Category"] = true,
	["Options"] = true,

--- tooltip ------------------
	["Tooltip"] = true,
	["Tooltip settings"] = true,
	["Show tooltip"] = true,
	["Simple filters display"] = true,
	["Tooltip shows only selected filters resp. 'no filters' instead of '1.) -' '2.) -' '3.) -'."] = true,
	["Level Range"] = true,
	["Rarity"] = true,
	[" and better"] = true,
	["Usable Items"] = true,
	["Display on Character"] = true,
	["Filters"] = true,
	["YES"] = true,
	["NO"] = true,

--- Search ------------------
	["SEARCH: Search query: %s - Search term: '%s' - Category: %s"] = true,
	["No category available!"] = true,
	["Right-click 'AHsearch Button' for options!"] = true,

--- Search query: Save ------------------
	["Search query: Save"] = true,
	["Save your current search query in a category."] = true,
	["Overwrite excisting search query '%s' in category '%s'?"] = true,
	["Search query '%s' SAVED in category '%s'!"] = true,

--- Search query: Edit ------------------
	["Search query: Edit"] = true,
	["Edit position, search query, search term, level range, rarity, usable items, display on character and filters for a search query."] = true,

	["Search query: Sort"] = true,
	["Sort search query by assigning a number to it.\nSort sequence:\n1.) number\n2.) rarity\n3.) upper case\n4.) lower case"] = true,
	["ASSIGNED sort number '%s' to search query '%s' (Category: %s)!"] = true,

	["Search query: Rename search query"] = true,
	["Rename the name of your search query. This is the name that is shown in the menu."] = true,
	["Search query '%s' (Search term: '%s' - Category: %s) RENAMED TO '%s'!"] = true,

	["Search query: Rename search term"] = true,
	["Rename the search term of your search query. This is the search term that is shown in the auction house searchtextbox (blank will search all)."] = true,
	["Search term '%s' (Search query: %s - Category: %s) CHANGED TO '%s'!"] = true,

	["Search query: Level range"] = true,
	["Change min. and max. level range (blank (no value) will search all)."] = true,
	["min"] = true,
	["max"] = true,
	["no value"] = true,
	["Min. Level for search query '%s' (Category: %s) CHANGED TO 'no value'!"] = true,
	["Min. Level for search query '%s' (Category: %s) CHANGED TO %s!"] = true,
	["Max. Level for search query '%s' (Category: %s) CHANGED TO 'no value'!"] = true,
	["Max. Level for search query '%s' (Category: %s) CHANGED TO %s!"] = true,

	["Search query: Rarity"] = true,
	["Change rarity. Only selected rarity or better will show in searchresult."] = true,
	["Rarity for search query '%s' (Category: %s) CHANGED TO %s!"] = true,

	["Search query: Usable Items"] = true,
	["Usable Items for search query '%s' (Category: %s) SET TO %s!"] = true,

	["Search query: Display on Character"] = true,
	["Display on Character for search query '%s' (Category: %s) SET TO %s!"] = true,

	["Search query: Filters"] = true,
	["Select a filter. Only one filter is selectable."] = true,
	["no filters"] = true,
	["Filters for search query '%s' (Category: %s) CHANGED TO %s!"] = true,
	["Filters for search query '%s' (Category: %s) CHANGED TO %s-%s!"] = true,
	["Filters for search query '%s' (Category: %s) CHANGED TO %s-%s-%s!"] = true,

--- Search query: Delete ------------------
	["Search query: Delete"] = true,
	["Delete a search query."] = true,
	["Delete search query '%s' in category '%s'?"] = true,
	["Search query '%s' in category '%s' DELETED!"] = true,

--- Search query: Move ------------------
	["Search query: Move"] = true,
	["Move a search query from one category to another category.\n\nATTENTION:\nPosition is set to 1!"] = true,
	["Move\nsearch query '%s'\nin category '%s'\nto category '%s'.\n\nATTENTION:\nPosition is set to 1!"] = true,
	["Search query '%s' in category '%s' MOVED TO category '%s'."] = true,
	["Search query '%s' exists in category '%s'! Overwrite?"] = true,

--- Category: Create ------------------
	["Category: Create"] = true,
	["Create a new category."] = true,
	["Category '%s' exists!\nOverwrite excisting category '%s'?\nAll search queries in that category will be deleted!"] = true,
	["Category '%s' CREATED!"] = true,

--- Category: Edit ------------------
	["Category: Edit"] = true,
	["Rename, sort, set color and icon for a category."] = true,

	["Category: Rename"] = true,
	["Rename category."] = true,
	["Category '%s' RENAMED TO '%s'!"] = true,

	["Category: Sort"] = true,
	["Sort category by assigning a number to it.\nSort sequence:\n1.) number\n2.) upper case\n3.) lower case"] = true,
	["ASSIGNED sort number '%s' to category '%s'!"] = true,
	["Position"] = true,

	["Category: Color"] = true,
	["Set color for a category."] = true,
	["Color"] = true,
	["SELECTED color for category '%s': %s%s ### '%s'|r"] = true,

	["Category: Icon"] = true,
	["Set icon for a category."] = true,
	["Icon"] = true,
	["SELECTED icon for category '%s': %s"] = true,
	["selected"] = true,

--- Category: Delete ------------------
	["Category: Delete"] = true,
	["Delete category and all saved search queries in that category!"] = true,
	["Delete category '%s'?\nAll search queries in that category will be deleted!"] = true,
	["Category '%s' DELETED!"] = true,

--- Chatoutput ------------------
	["Chatoutput"] = true,
	["Activate/Deactivate chatoutput for:\n- SEARCH\n- Search query: SAVE, EDIT, MOVE & DELETE\n- Category: CREATE, EDIT & DELETE"] = true,

--- Help ------------------
	["Help"] = true,
	["Step 1 or 2: Right-click 'AHsearch Button' and create category ('Category: Create')."] = true,
	["Step 1 or 2: Set up your search criteria (you don't have to click the search button)."] = true,
	["Step 3: Right-click 'AHsearch Button' and choose a category in 'Search query: Save'."] = true,
	["Step 4: Give your search a name. Press return."] = true,
	["Step 5: Left-click 'AHsearch Button' for your search queries."] = true,

	["Maximum text length for categories and search queries: %s characters"] = true,
	["Color coding for saved search queries:"] = true,
	["All"] = true,
	["Poor"] = true,
	["Common"] = true,
	["Uncommon"] = true,
	["Rare"] = true,
	["Epic"] = true,

} end)