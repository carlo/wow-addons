-- ----------------------------------------------------------------------------
-- AHsearch by kunda
-- --------------------------
-- idea based on AHFavorites from Narwick
--
-- THANKS: wowace.com, the ace community and all ace developers
-- ----------------------------------------------------------------------------

AHsearch = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceDB-2.0", "AceEvent-2.0")
AHsearch:RegisterDB("AHsearchDB")
local L = AceLibrary("AceLocale-2.2"):new("AHsearch")
local Dewdrop = AceLibrary("Dewdrop-2.0")
local maxBoxInputLength = 40
local maxItemLevel = 70
local itemRarityColors = {
	[1] = "|cffffff9a", -- all (ah: -1)
	[2] = "|cff9d9d9d", -- poor (ah: 0)
	[3] = "|cffffffff", -- common (ah: 1)
	[4] = "|cff1eff00", -- uncommon (ah: 2)
	[5] = "|cff0070dd", -- rare (ah: 3)
	[6] = "|cffa335ee"  -- epic (ah: 4)
--[7] = "|cffff8000", -- legendary (not in ah index)
--[8] = "|cffe6cc80", -- artifact (not in ah index)
}
local itemRarityNames = {
	[1] = L["All"],      -- all (ah: -1)
	[2] = L["Poor"],     -- poor (ah: 0)
	[3] = L["Common"],   -- common (ah: 1)
	[4] = L["Uncommon"], -- uncommon (ah: 2)
	[5] = L["Rare"],     -- rare (ah: 3)
	[6] = L["Epic"]      -- epic (ah: 4)
--[7] =                -- legendary (not in ah index)
--[8] =                -- artifact (not in ah index)
}
local categoryColors = {
	[1] = "|cffffffff",
	[2] = "|cffbbbbbb",
	[3] = "|cff777777",
	[4] = "|cfff32f00",
	[5] = "|cffff8c00",
	[6] = "|cffffd700",
	[7] = "|cffdeb887",
	[8] = "|cffa0522d",
	[9] = "|cffe9967a",
	[10] = "|cff4169e1",
	[11] = "|cff008cb4",
	[12] = "|cff7edef4",
	[13] = "|cffa020f0",
	[14] = "|cffee82ee",
	[15] = "|cff95004a",
	[16] = "|cff00ff00"
}
local categoryIcons = {
	[1] = "",
	[2] = "Interface\\Icons\\INV_Scroll_03",
	[3] = "Interface\\Icons\\INV_Misc_Bag_10_Black",
	[4] = "Interface\\Icons\\INV_Misc_Coin_01",
	[5] = "Interface\\Icons\\INV_Jewelry_Talisman_08",
	[6] = "Interface\\Icons\\INV_Misc_Bomb_04",
	[7] = "Interface\\Icons\\INV_Misc_Gem_Pearl_04",
	[8] = "Interface\\Icons\\INV_Misc_Gem_Sapphire_01",
	[9] = "Interface\\Icons\\INV_Misc_Gift_01",
	[10] = "Interface\\GroupFrame\\UI-Group-LeaderIcon",
	[11] = "Interface\\Icons\\INV_Potion_03",
	[12] = "Interface\\Icons\\Trade_BlackSmithing",
	[13] = "Interface\\Icons\\Trade_Engineering",
	[14] = "Interface\\Icons\\Trade_Engraving",
	[15] = "Interface\\Icons\\Trade_Mining",
	[16] = "Interface\\Icons\\Trade_Tailoring",
	[17] = "Interface\\Icons\\INV_Misc_Gem_01",
	[18] = "Interface\\Icons\\INV_Misc_Food_15",
	[19] = "Interface\\Icons\\Spell_Holy_SealOfSacrifice",
	[20] = "Interface\\Icons\\Spell_Holy_MindVision"
}
local TOOLTIP_COLOR_DESC	= "|cffbfb166"
local TOOLTIP_COLOR_DATA	= "|cffffffff"
local TOOLTIP_COLOR_YES		= "|cff00ff00"
local TOOLTIP_COLOR_NO		= "|cffff0000"
local _G = getfenv(0)
local ctab = {}
local stab = {}

-- ----------------------------------------------------------------------------
-- print
-- --------------------------
function AHsearch:print(text)
	if DEFAULT_CHAT_FRAME and self.db.profile.chatOutput then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff7fAHsearch: |r"..text)
	end
end
-- --------------------------
-- print
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- OnInitialize
-- --------------------------
function AHsearch:OnInitialize()
	self:RegisterDefaults("profile", {
		search = { },
		chatOutput = false,
		ttDisplay = true,
		ttFiltersDisplay = true
		}
	)
	self:RegisterChatCommand({"/ahs","/ahsearch"})
	self:DBVersionCheck()
end
-- --------------------------
-- OnInitialize
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- OnEnable
-- --------------------------
function AHsearch:OnEnable()
	self:RegisterEvent("AUCTION_HOUSE_SHOW")
	self:RegisterEvent("AUCTION_HOUSE_CLOSED")
end
-- --------------------------
-- OnEnable
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- OnDisable
-- --------------------------
-- function AHsearch:OnDisable()
-- TODO
-- end
-- --------------------------
-- OnDisable
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- events
-- --------------------------
function AHsearch:AUCTION_HOUSE_SHOW()
	self:CreatePullDownButton()
	self:CreatePullDownOptionsMenu()
end
function AHsearch:AUCTION_HOUSE_CLOSED()
	Dewdrop:Close(1)
end
-- --------------------------
-- events
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- CreatePullDownButton
-- --------------------------
function AHsearch:CreatePullDownButton()
	AHsearchButtonFrame = CreateFrame("Frame", "AHsearchButtonFrame", AuctionFrameBrowse)
	AHsearchButtonFrame:SetFrameStrata("HIGH")
	AHsearchButtonFrame:SetWidth(24)
	AHsearchButtonFrame:SetHeight(24)
	AHsearchButtonFrame:ClearAllPoints()
	AHsearchButtonFrame:SetPoint("RIGHT", "BrowseName", "RIGHT", 6, 0)
	AHsearchButtonFrame.button = CreateFrame("Button", "AHsearchButtonFrame.button", AHsearchButtonFrame)
	AHsearchButtonFrame.button:SetFrameStrata("DIALOG")
	AHsearchButtonFrame.button:SetWidth(24)
	AHsearchButtonFrame.button:SetHeight(24)
	AHsearchButtonFrame.button:SetPoint("RIGHT", "AHsearchButtonFrame", "RIGHT", 0, 0)
	AHsearchButtonFrame.button:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
	AHsearchButtonFrame.button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
	AHsearchButtonFrame.button:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
	AHsearchButtonFrame.button:SetScript("OnClick", function() self:CreatePullDownMenu() end)
end
-- --------------------------
-- CreatePullDownButton
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- CreatePullDownMenu
-- --------------------------
function AHsearch:CreatePullDownMenu()
	local tab = self.db.profile.search
	local rcc = self:ReturnCatCheck()
	Dewdrop:Open(AHsearchButtonFrame,
		'point', function(parent)
			return "TOPLEFT","BOTTOMLEFT"
		end,
		'dontHook', true,
		'children', function(level, value)
			if rcc then
				if level == 1 then
					Dewdrop:AddLine(
						'isTitle', true,
						'text', L["No category available!"]
					)
					Dewdrop:AddLine(
						'isTitle', true,
						'text', L["Right-click 'AHsearch Button' for options!"]
					)
				end
			else
				if level == 1 then
					for cat,v in self:sortedpairs(tab) do
						local x = self:ReturnSQcheck(cat)
						Dewdrop:AddLine(
							'text', tab[cat].color..cat,
							'tooltipTitle', self:TooltipDisplay(tab[cat].color..cat),
							'icon', tab[cat].icon,
							'hasArrow', not x,
							'disabled', false,
							'notClickable', x,
							'value', {'catname', cat}
						)
					end
				elseif level == 2 then
					if type(value) == "table" and value[1] == "catname" then
						local cat = value[2]
						for sq,v in self:sortedpairs(tab[cat].queries,1) do
							Dewdrop:AddLine(
								'text', self:ReturnQcolor(cat,sq),
								'tooltipTitle', self:TooltipDisplay(L["Search"]),
								'tooltipText', self:SQtooltip(cat,sq),
								'func', function()
									self:Search(cat,sq)
								end
							)
						end
					end
				end
			end
		end
	)
end
-- --------------------------
-- CreatePullDownMenu
-- ----------------------------------------------------------------------------



-- ----------------------------------------------------------------------------
-- Search
-- --------------------------
function AHsearch:Search(cat,sq)
	-- load fields in AuctionFrame
	local tab = self.db.profile.search[cat].queries[sq]
	BrowseName:SetText(tab.name)
	BrowseMinLevel:SetText(tab.minLevel)
	BrowseMaxLevel:SetText(tab.maxLevel)
	AuctionFrameBrowse.selectedInvtypeIndex = tab.invTypeIndex
	AuctionFrameBrowse.selectedClassIndex = tab.classIndex
	AuctionFrameBrowse.selectedClass = CLASS_FILTERS[tab.classIndex]
	AuctionFrameBrowse.selectedSubclassIndex = tab.subclassIndex
	AuctionFrameBrowse.selectedSubclass = tab.subclass
	IsUsableCheckButton:SetChecked(tab.isUsable)
	ShowOnPlayerCheckButton:SetChecked(tab.showOnPlayer)
	AUCTION_DISPLAY_ON_CHARACTER = tostring(tab.showOnPlayer)
	UIDropDownMenu_SetSelectedValue(BrowseDropDown, tab.qualityIndex)
	-- update AuctionFrame
	UIDropDownMenu_Initialize(BrowseDropDown, BrowseDropDown_Initialize)
	AuctionFrameFilters_Update()
	UIDropDownMenu_Refresh(BrowseDropDown, false)
	-- search
	AuctionFrameBrowse_Search()
	self:print(string.format(L["SEARCH: Search query: %s - Search term: '%s' - Category: %s"],sq,tab.name,cat))
	Dewdrop:Close(1)
end
-- --------------------------
-- Search
-- ----------------------------------------------------------------------------



-- ----------------------------------------------------------------------------
-- CreatePullDownOptionsMenu
-- --------------------------
function AHsearch:CreatePullDownOptionsMenu()
	local tab = self.db.profile.search
	Dewdrop:Register(AHsearchButtonFrame.button,
		'point', function(parent)
			return "TOPLEFT","BOTTOMLEFT"
		end,
		'children', function(level, value)
			-- ----------------------------------------------------------------------
			if level == 1 then
			-- ----------------------------------------------------------------------
				local x = self:ReturnGCheck()
				local y = self:ReturnCatCheck()
				Dewdrop:AddLine(
					'isTitle', true,
					'text', L["Search query"]
				)
				Dewdrop:AddLine(
					'text', L["Search query: Save"],
					'tooltipTitle', self:TooltipDisplay(L["Search query: Save"]),
					'tooltipText', L["Save your current search query in a category."],
					'disabled', y,
					'hasArrow', not y,
					'value', "saveSearchQuery"
				)
				Dewdrop:AddLine(
					'text', L["Search query: Edit"],
					'tooltipTitle', self:TooltipDisplay(L["Search query: Edit"]),
					'tooltipText', L["Edit position, search query, search term, level range, rarity, usable items, display on character and filters for a search query."],
					'disabled', x,
					'hasArrow', not x,
					'value', "editSearchQuery"
				)
				Dewdrop:AddLine(
					'text', L["Search query: Move"],
					'tooltipTitle', self:TooltipDisplay(L["Search query: Move"]),
					'tooltipText', L["Move a search query from one category to another category.\n\nATTENTION:\nPosition is set to 1!"],
					'disabled', x,
					'hasArrow', not x,
					'value', "moveSearchQuery"
				)
				Dewdrop:AddLine(
					'text', L["Search query: Delete"],
					'tooltipTitle', self:TooltipDisplay(L["Search query: Delete"]),
					'tooltipText', L["Delete a search query."],
					'disabled', x,
					'hasArrow', not x,
					'value', "deleteSearchQuery"
				)
				Dewdrop:AddLine(
					'isTitle', true,
					'text', L["Category"]
				)
				Dewdrop:AddLine(
					'text', L["Category: Create"],
					'tooltipTitle', self:TooltipDisplay(L["Category: Create"]),
					'tooltipText', L["Create a new category."],
					'hasArrow', true,
					'hasEditBox', true,
					'editBoxValidateFunc', function(catname)
						if catname:len() >= 1 and catname:len() <= maxBoxInputLength then
							return true
						end
					end,
					'editBoxFunc', function(catname)
						local owCheck = self:owCheck(tab,catname)
						local func = function()
							tab[catname] = {}
							tab[catname].order = 1
							tab[catname].color = "|cffffffff"
							tab[catname].icon = ""
							tab[catname].queries = {}
							self:print(string.format(L["Category '%s' CREATED!"],catname))
						end
						if owCheck then
							local confirmTxt = string.format(L["Category '%s' exists!\nOverwrite excisting category '%s'?\nAll search queries in that category will be deleted!"],catname,catname)
							self:ConfirmPopup(confirmTxt,func)
						else
							func()
						end
					end
				)
				Dewdrop:AddLine(
					'text', L["Category: Edit"],
					'tooltipTitle', self:TooltipDisplay(L["Category: Edit"]),
					'tooltipText', L["Rename, sort, set color and icon for a category."],
					'disabled', y,
					'hasArrow', not y,
					'value', "editCat"
				)
				Dewdrop:AddLine(
					'text', L["Category: Delete"],
					'tooltipTitle', self:TooltipDisplay(L["Category: Delete"]),
					'tooltipText', L["Delete category and all saved search queries in that category!"],
					'disabled', y,
					'hasArrow', not y,
					'value', "deleteCat"
				)
				Dewdrop:AddLine(
					'isTitle', true,
					'text', L["Options"]
				)
				Dewdrop:AddLine(
					'text', L["Options"],
					'tooltipTitle', self:TooltipDisplay(L["Options"]),
					'hasArrow', true,
					'value', "options"
				)
				Dewdrop:AddLine(
					'text', L["Chatoutput"],
					'tooltipTitle', self:TooltipDisplay(L["Chatoutput"]),
					'tooltipText', L["Activate/Deactivate chatoutput for:\n- SEARCH\n- Search query: SAVE, EDIT, MOVE & DELETE\n- Category: CREATE, EDIT & DELETE"],
					'checkIcon', "Interface\\Buttons\\UI-CheckBox-Check",
					'checked', self.db.profile.chatOutput,
					'func', function()
						self.db.profile.chatOutput = not self.db.profile.chatOutput
					end
				)
				Dewdrop:AddLine(
					'text', L["Help"],
					'tooltipTitle', self:TooltipDisplay(L["Help"]),
					'func', function()
						self:HelpOutput()
					end
				)
			-- ----------------------------------------------------------------------
			elseif level == 2 then
			-- ----------------------------------------------------------------------
				if value == "saveSearchQuery" then
					for cat,v in self:sortedpairs(tab) do
						Dewdrop:AddLine(
							'text', tab[cat].color..cat,
							'tooltipTitle', self:TooltipDisplay(L["Search query: Save"]),
							'tooltipText', self:TooltipCATName(cat),
							'icon', tab[cat].icon,
							'hasArrow', true,
							'hasEditBox', true,
							'editBoxText', BrowseName:GetText() or "",
							'editBoxValidateFunc', function(sname)
								if sname:len() >= 1 and sname:len() <= maxBoxInputLength then
									return true
								end
							end,
							'editBoxFunc', function(sname)
								local owCheck = self:owCheck(tab[cat].queries,sname)
								local func = function()
									self:SaveSearchInCategory(cat,sname)
								end
								if owCheck then
									local confirmTxt = string.format(L["Overwrite excisting search query '%s' in category '%s'?"],sname,cat)
									self:ConfirmPopup(confirmTxt,func)
								else
									func()
								end
							end
						)
					end
				end

				if value == "editSearchQuery" then
					for cat,v in self:sortedpairs(tab) do
						local x = self:ReturnSQcheck(cat)
						Dewdrop:AddLine(
							'text', tab[cat].color..cat,
							'tooltipTitle', self:TooltipDisplay(L["Search query: Edit"]),
							'tooltipText', self:TooltipCATName(cat),
							'icon', tab[cat].icon,
							'hasArrow', not x,
							'disabled', false,
							'notClickable', x,
							'value', {'editSearchQuery', cat}
						)
					end
				end

				if value == "deleteSearchQuery" then
					for cat,v in self:sortedpairs(tab) do
						local x = self:ReturnSQcheck(cat)
						Dewdrop:AddLine(
							'text', tab[cat].color..cat,
							'tooltipTitle', self:TooltipDisplay(L["Search query: Delete"]),
							'tooltipText', self:TooltipCATName(cat),
							'icon', tab[cat].icon,
							'hasArrow', not x,
							'disabled', false,
							'notClickable', x,
							'value', {'deleteSearchQuery', cat}
						)
					end
				end

				if value == "moveSearchQuery" then
					for cat,v in self:sortedpairs(tab) do
						local x = self:ReturnSQcheck(cat)
						Dewdrop:AddLine(
							'text', tab[cat].color..cat,
							'tooltipTitle', self:TooltipDisplay(L["Search query: Move"]),
							'tooltipText', self:TooltipCATName(cat),
							'icon', tab[cat].icon,
							'hasArrow', not x,
							'disabled', false,
							'notClickable', x,
							'value', {'moveSearchQuery', cat}
						)
					end
				end

				if value == "editCat" then
					for cat,v in self:sortedpairs(tab) do
						Dewdrop:AddLine(
							'text', tab[cat].order.." - "..tab[cat].color..cat..itemRarityColors[2].." ("..self:ReturnSQCount(cat)..")",
							'tooltipTitle', self:TooltipDisplay(L["Category: Edit"]),
							'tooltipText', self:CATtooltip(cat),
							'icon', tab[cat].icon,
							'hasArrow', true,
							'value', {'editCat2', cat}
						)
					end
				end

				if value == "deleteCat" then
					for cat,v in self:sortedpairs(tab) do
						Dewdrop:AddLine(
							'text', tab[cat].color..cat..itemRarityColors[2].." ("..self:ReturnSQCount(cat).." "..L["search queries"]..")",
							'tooltipTitle', self:TooltipDisplay(L["Category: Delete"]),
							'tooltipText', TOOLTIP_COLOR_DESC..L["Category"]..": "..tab[cat].color..cat.."\n"..itemRarityColors[2].."("..self:ReturnSQCount(cat).." "..L["search queries"]..")",
							'icon', tab[cat].icon,
							'func', function()
								local confirmTxt = string.format(L["Delete category '%s'?\nAll search queries in that category will be deleted!"],cat)
								local func = function()
									tab[cat] = nil
									self:print(string.format(L["Category '%s' DELETED!"],cat))
								end
								self:ConfirmPopup(confirmTxt,func)
								Dewdrop:Refresh(2)
							end
						)
					end
				end

				if value == "options" then
					Dewdrop:AddLine(
						'text', L["Tooltip"],
						'tooltipTitle', self:TooltipDisplay(L["Tooltip settings"]),
						'tooltipText', L["Tooltip settings"]..".",
						'hasArrow', true,
						'value', {'tooltip'}
					)
				end
			-- ----------------------------------------------------------------------
			elseif level == 3 then
			-- ----------------------------------------------------------------------
				if type(value) == "table" and value[1] == "editSearchQuery" then
					local subTab = value[2]
					for sq,v in self:sortedpairs(tab[subTab].queries,1) do
						Dewdrop:AddLine(
							'text', tab[subTab].queries[sq].order.." - "..self:ReturnQcolor(subTab,sq),
							'tooltipTitle', self:TooltipDisplay(L["Search query: Edit"]),
							'tooltipText', self:SQtooltip(subTab,sq),
							'hasArrow', true,
							'value', {'editSearchQuery2', subTab, sq}
						)
					end
				end

				if type(value) == "table" and value[1] == "deleteSearchQuery" then
					local subTab = value[2]
					for sq,v in self:sortedpairs(tab[subTab].queries,1) do
						Dewdrop:AddLine(
							'text', tab[subTab].queries[sq].order.." - "..self:ReturnQcolor(subTab,sq),
							'tooltipTitle', self:TooltipDisplay(L["Search query: Delete"]),
							'tooltipText', self:SQtooltip(subTab,sq),
							'func', function()
								local confirmTxt = string.format(L["Delete search query '%s' in category '%s'?"],sq,subTab)
								local func = function()
									tab[subTab].queries[sq] = nil
									self:print(string.format(L["Search query '%s' in category '%s' DELETED!"],sq,subTab))
								end
								self:ConfirmPopup(confirmTxt,func)
							end
						)
					end
				end

				if type(value) == "table" and value[1] == "moveSearchQuery" then
					local subTab = value[2]
					for sq,v in self:sortedpairs(tab[subTab].queries,1) do
						Dewdrop:AddLine(
							'text', tab[subTab].queries[sq].order.." - "..self:ReturnQcolor(subTab,sq),
							'tooltipTitle', self:TooltipDisplay(L["Search query: Move"]),
							'tooltipText', self:SQtooltip(subTab,sq),
							'hasArrow', true,
							'value', {'moveSearchQuery2', subTab, sq}
						)
					end
				end

				if type(value) == "table" and value[1] == "editCat2" then
					local cat = value[2]
					Dewdrop:AddLine(
						'text', self:TooltipCATName(cat),
						'tooltipTitle', self:TooltipDisplay(L["Category: Rename"]),
						'tooltipText', L["Rename category."],
						'hasArrow', true,
						'hasEditBox', true,
						'editBoxText', cat,
						'editBoxValidateFunc', function(newCatName)
							if newCatName:len() >= 1 and newCatName:len() <= maxBoxInputLength then
								return true
							end
						end,
						'editBoxFunc', function(newCatName)
							if newCatName ~= cat then
								local owCheck = self:owCheck(tab,newCatName)
								local func = function()
									tab[newCatName] = tab[cat]
									tab[cat] = nil
									self:print(string.format(L["Category '%s' RENAMED TO '%s'!"],cat,newCatName))
								end
								if owCheck then
									local confirmTxt = string.format(L["Category '%s' exists!\nOverwrite excisting category '%s'?\nAll search queries in that category will be deleted!"],newCatName,newCatName)
									self:ConfirmPopup(confirmTxt,func)
								else
									func()
								end
								Dewdrop:Refresh(2)
								Dewdrop:Close(3)
								Dewdrop:Close(4)
							end
						end
					)
					Dewdrop:AddLine(
						'text', self:TooltipCATPosition(cat),
						'tooltipTitle', self:TooltipDisplay(L["Category: Sort"]),
						'tooltipText', L["Sort category by assigning a number to it.\nSort sequence:\n1.) number\n2.) upper case\n3.) lower case"],
						'disabled', self:ReturnCatCheck(),
						'hasArrow', true,
						'value', {'editCat3pos', cat}
					)
					Dewdrop:AddLine(
						'text', self:TooltipCATColor(cat),
						'tooltipTitle', self:TooltipDisplay(L["Category: Color"]),
						'tooltipText', L["Set color for a category."],
						'disabled', self:ReturnCatCheck(),
						'hasArrow', true,
						'value', {'editCat3color', cat}
					)
					Dewdrop:AddLine(
						'text', self:TooltipCATIcon(cat),
						'tooltipTitle', self:TooltipDisplay(L["Category: Icon"]),
						'tooltipText', L["Set icon for a category."],
						'icon', tab[cat].icon,
						'disabled', self:ReturnCatCheck(),
						'hasArrow', true,
						'value', {'editCat3icon', cat}
					)
				end

				if type(value) == "table" and value[1] == "tooltip" then
					Dewdrop:AddLine(
						'text', L["Show tooltip"],
						'tooltipTitle', self:TooltipDisplay(L["Show tooltip"]),
						'tooltipText', L["Show tooltip"]..".",
						'checkIcon', "Interface\\Buttons\\UI-CheckBox-Check",
						'checked', self.db.profile.ttDisplay,
						'func', function()
							self.db.profile.ttDisplay = not self.db.profile.ttDisplay
						end
					)
					Dewdrop:AddLine(
						'text', L["Simple filters display"],
						'tooltipTitle', self:TooltipDisplay(L["Simple filters display"]),
						'tooltipText', L["Tooltip shows only selected filters resp. 'no filters' instead of '1.) -' '2.) -' '3.) -'."],
						'checkIcon', "Interface\\Buttons\\UI-CheckBox-Check",
						'checked', self.db.profile.ttFiltersDisplay,
						'func', function()
							self.db.profile.ttFiltersDisplay = not self.db.profile.ttFiltersDisplay
						end
					)
				end

			-- ----------------------------------------------------------------------
			elseif level == 4 then
			-- ----------------------------------------------------------------------
				if type(value) == "table" and value[1] == "editSearchQuery2" then
					local cat = value[2]
					local sq = value[3]
					
					Dewdrop:AddLine(
						'text', self:TooltipSQPosition(cat,sq),
						'tooltipTitle', self:TooltipDisplay(L["Search query: Sort"]),
						'tooltipText', L["Sort search query by assigning a number to it.\nSort sequence:\n1.) number\n2.) rarity\n3.) upper case\n4.) lower case"],
						'hasArrow', true,
						'value', {'editSearchQuery2pos', cat, sq}
					)

					Dewdrop:AddLine(
						'text', self:TooltipSQSearchName(cat,sq),
						'tooltipTitle', self:TooltipDisplay(L["Search query: Rename search query"]),
						'tooltipText', L["Rename the name of your search query. This is the name that is shown in the menu."],
						'hasArrow', true,
						'hasEditBox', true,
						'editBoxText', sq,
						'editBoxValidateFunc', function(sqname)
							if sqname:len() >= 1 and sqname:len() <= maxBoxInputLength then
								return true
							end
						end,
						'editBoxFunc', function(sqname)
							if sqname ~= sq then
								local owCheck = self:owCheck(tab[cat].queries,sqname)
								local func = function()
									tab[cat].queries[sqname] = tab[cat].queries[sq]
									tab[cat].queries[sq] = nil
									self:print(string.format(L["Search query '%s' (Search term: '%s' - Category: %s) RENAMED TO '%s'!"],sq,tab[cat].queries[sqname].name,cat,sqname))
								end
								if owCheck then
									local confirmTxt = string.format(L["Overwrite excisting search query '%s' in category '%s'?"],sqname,cat)
									self:ConfirmPopup(confirmTxt,func)
								else
									func()
								end
								Dewdrop:Refresh(3)
								Dewdrop:Close(4)
							end
						end
					)
					Dewdrop:AddLine(
						'text', self:TooltipSQSearchTerm(cat,sq),
						'tooltipTitle', self:TooltipDisplay(L["Search query: Rename search term"]),
						'tooltipText', L["Rename the search term of your search query. This is the search term that is shown in the auction house searchtextbox (blank will search all)."],
						'hasArrow', true,
						'hasEditBox', true,
						'editBoxText', tab[cat].queries[sq].name,
						'editBoxFunc', function(newname)
							local oldname = tab[cat].queries[sq].name
							tab[cat].queries[sq].name = newname
							self:print(string.format(L["Search term '%s' (Search query: %s - Category: %s) CHANGED TO '%s'!"],oldname,sq,cat,newname))
						end
					)
					Dewdrop:AddLine(
						'text', self:TooltipSQLevelRange(cat,sq),
						'tooltipTitle', self:TooltipDisplay(L["Search query: Level range"]),
						'tooltipText', L["Change min. and max. level range (blank (no value) will search all)."],
						'hasArrow', true,
						'value', {'editSearchQuery2LevelRange', cat, sq}
					)
					Dewdrop:AddLine(
						'text', self:TooltipSQRarity(cat,sq),
						'tooltipTitle', self:TooltipDisplay(L["Search query: Rarity"]),
						'tooltipText', L["Change rarity. Only selected rarity or better will show in searchresult."],
						'hasArrow', true,
						'value', {'editSearchQuery2Rarity', cat, sq}
					)
					if tab[cat].queries[sq].isUsable then
						if tab[cat].queries[sq].isUsable == 1 then
							Dewdrop:AddLine(
								'text', TOOLTIP_COLOR_DESC..L["Usable Items"]..": "..TOOLTIP_COLOR_YES..L["YES"],
								'tooltipTitle', self:TooltipDisplay(L["Search query: Usable Items"]),
								'isRadio', true,
								'checked', true,
								'func', function()
									tab[cat].queries[sq].isUsable = 0
									self:print(string.format(L["Usable Items for search query '%s' (Category: %s) SET TO %s!"],sq,cat,TOOLTIP_COLOR_NO..L["NO"]..TOOLTIP_COLOR_DATA))
									Dewdrop:Refresh(3)
									Dewdrop:Close(4)
								end
							)
						else
							Dewdrop:AddLine(
								'text', TOOLTIP_COLOR_DESC..L["Usable Items"]..": "..TOOLTIP_COLOR_NO..L["NO"],
								'tooltipTitle', self:TooltipDisplay(L["Search query: Usable Items"]),
								'isRadio', true,
								'checked', false,
								'func', function()
									tab[cat].queries[sq].isUsable = 1
									self:print(string.format(L["Usable Items for search query '%s' (Category: %s) SET TO %s!"],sq,cat,TOOLTIP_COLOR_YES..L["YES"]..TOOLTIP_COLOR_DATA))
									Dewdrop:Refresh(3)
									Dewdrop:Close(4)
								end
							)
						end
					else
						Dewdrop:AddLine(
							'text', TOOLTIP_COLOR_DESC..L["Usable Items"]..": "..TOOLTIP_COLOR_NO..L["NO"],
							'tooltipTitle', self:TooltipDisplay(L["Search query: Usable Items"]),
							'isRadio', true,
							'checked', false,
							'func', function()
								tab[cat].queries[sq].isUsable = 1
								self:print(string.format(L["Usable Items for search query '%s' (Category: %s) SET TO %s!"],sq,cat,TOOLTIP_COLOR_YES..L["YES"]..TOOLTIP_COLOR_DATA))
								Dewdrop:Refresh(3)
								Dewdrop:Close(4)
							end
						)
					end
					if tab[cat].queries[sq].showOnPlayer then
						if tab[cat].queries[sq].showOnPlayer == 1 then
							Dewdrop:AddLine(
								'text', TOOLTIP_COLOR_DESC..L["Display on Character"]..": "..TOOLTIP_COLOR_YES..L["YES"],
								'tooltipTitle', self:TooltipDisplay(L["Search query: Display on Character"]),
								'isRadio', true,
								'checked', true,
								'func', function()
									tab[cat].queries[sq].showOnPlayer = 0
									self:print(string.format(L["Display on Character for search query '%s' (Category: %s) SET TO %s!"],sq,cat,TOOLTIP_COLOR_NO..L["NO"]..TOOLTIP_COLOR_DATA))
									Dewdrop:Refresh(3)
									Dewdrop:Close(4)
								end
							)
						else
							Dewdrop:AddLine(
								'text', TOOLTIP_COLOR_DESC..L["Display on Character"]..": "..TOOLTIP_COLOR_NO..L["NO"],
								'tooltipTitle', self:TooltipDisplay(L["Search query: Display on Character"]),
								'isRadio', true,
								'checked', false,
								'func', function()
									tab[cat].queries[sq].showOnPlayer = 1
									self:print(string.format(L["Display on Character for search query '%s' (Category: %s) SET TO %s!"],sq,cat,TOOLTIP_COLOR_YES..L["YES"]..TOOLTIP_COLOR_DATA))
									Dewdrop:Refresh(3)
									Dewdrop:Close(4)
								end
							)
						end
					else
						Dewdrop:AddLine(
							'text', TOOLTIP_COLOR_DESC..L["Display on Character"]..": "..TOOLTIP_COLOR_NO..L["NO"],
							'tooltipTitle', self:TooltipDisplay(L["Search query: Display on Character"]),
							'isRadio', true,
							'checked', false,
							'func', function()
								tab[cat].queries[sq].showOnPlayer = 1
								self:print(string.format(L["Display on Character for search query '%s' (Category: %s) SET TO %s!"],sq,cat,TOOLTIP_COLOR_YES..L["YES"]..TOOLTIP_COLOR_DATA))
								Dewdrop:Refresh(3)
								Dewdrop:Close(4)
							end
						)
					end
					Dewdrop:AddLine(
						'text', self:TooltipSQFilters(cat,sq,0),
						'tooltipTitle', self:TooltipDisplay(L["Search query: Filters"]),
						'tooltipText', L["Select a filter. Only one filter is selectable."],
						'hasArrow', true,
						'value', {'editSearchQuery2FiltersLVL1', cat, sq}
					)
					if self.db.profile.ttFiltersDisplay then
						if tab[cat].queries[sq].classIndex then
							Dewdrop:AddLine(
								'text', self:TooltipSQFilters(cat,sq,1),
								'tooltipTitle', "",
								'disabled', true
							)
						end
						if tab[cat].queries[sq].subclass then
							Dewdrop:AddLine(
								'text', self:TooltipSQFilters(cat,sq,2),
								'tooltipTitle', "",
								'disabled', true
							)
						end
						if tab[cat].queries[sq].invTypeIndex then
							Dewdrop:AddLine(
								'text', self:TooltipSQFilters(cat,sq,3),
								'tooltipTitle', "",
								'disabled', true
							)
						end
					else
						Dewdrop:AddLine(
							'text', self:TooltipSQFilters(cat,sq,1),
							'tooltipTitle', "",
							'disabled', true
						)
						Dewdrop:AddLine(
							'text', self:TooltipSQFilters(cat,sq,2),
							'tooltipTitle', "",
							'disabled', true
						)
						Dewdrop:AddLine(
							'text', self:TooltipSQFilters(cat,sq,3),
							'tooltipTitle', "",
							'disabled', true
						)
					end
				end

				if type(value) == "table" and value[1] == "moveSearchQuery2" then
					local oldCat = value[2]
					local query = value[3]
					for newCat,v in self:sortedpairs(tab) do
						if newCat == oldCat then
							Dewdrop:AddLine(
								'text', newCat,
								'tooltipTitle', self:TooltipDisplay(""),
								'icon', tab[newCat].icon,
								'disabled', true
							)
						else
							Dewdrop:AddLine(
								'text', tab[newCat].color..newCat,
								'tooltipTitle', self:TooltipDisplay(L["Search query: Move"]),
								'tooltipText', string.format(L["Move\nsearch query '%s'\nin category '%s'\nto category '%s'.\n\nATTENTION:\nPosition is set to 1!"],query,oldCat,newCat),
								'icon', tab[newCat].icon,
								'func', function()
									if newCat ~= oldCat then
										local owCheck = self:owCheck(tab[newCat].queries,query)
										local func = function()
											tab[newCat].queries[query] = tab[oldCat].queries[query]
											tab[newCat].queries[query].order = 1
											tab[oldCat].queries[query] = nil
											self:print(string.format(L["Search query '%s' in category '%s' MOVED TO category '%s'."],query,oldCat,newCat))
										end
										if owCheck then
											local confirmTxt = string.format(L["Search query '%s' exists in category '%s'! Overwrite?"],query,newCat)
											self:ConfirmPopup(confirmTxt,func)
										else
											func()
										end
										Dewdrop:Refresh(2)
										Dewdrop:Refresh(3)
										Dewdrop:Close(4)
									end
								end
							)
						end
					end
				end

				if type(value) == "table" and value[1] == "editCat3pos" then
					local cat = value[2]
					local c = 1
					for k,v in self:sortedpairs(tab) do
						if c == tab[cat].order then
							Dewdrop:AddLine(
								'text', c,
								'tooltipTitle', "",
								'icon', "Interface\\Buttons\\UI-CheckBox-Check",
								'arg1', c,
								'func', function(value)
									tab[cat].order = value
									self:print(string.format(L["ASSIGNED sort number '%s' to category '%s'!"],value,cat))
									Dewdrop:Refresh(2)
									Dewdrop:Refresh(3)
									Dewdrop:Close(4)
								end
							)
						else
							Dewdrop:AddLine(
								'text', c,
								'tooltipTitle', "",
								'arg1', c,
								'func', function(value)
									tab[cat].order = value
									self:print(string.format(L["ASSIGNED sort number '%s' to category '%s'!"],value,cat))
									Dewdrop:Refresh(2)
									Dewdrop:Refresh(3)
									Dewdrop:Close(4)
								end
							)
						end
						c=c+1
					end
				end

				if type(value) == "table" and value[1] == "editCat3color" then
					local cat = value[2]
					for i=1, getn(categoryColors) do
						if tab[cat].color == categoryColors[i] then
							Dewdrop:AddLine(
								'text', categoryColors[i]..i.." ### - "..cat,
								'tooltipTitle', "",
								'checked', true, 
								'arg1', categoryColors[i],
								'func', function(value)
									tab[cat].color = value
									self:print(string.format(L["SELECTED color for category '%s': %s%s ### '%s'|r"],cat,categoryColors[i],i,cat))
									Dewdrop:Refresh(2)
									Dewdrop:Refresh(3)
									Dewdrop:Close(4)
								end
							)
						else
							Dewdrop:AddLine(
								'text', categoryColors[i]..i.." ### - "..cat,
								'tooltipTitle', "",
								'checked', false, 
								'arg1', categoryColors[i],
								'func', function(value)
									tab[cat].color = value
									self:print(string.format(L["SELECTED color for category '%s': %s%s ### '%s'|r"],cat,categoryColors[i],i,cat))
									Dewdrop:Refresh(2)
									Dewdrop:Refresh(3)
									Dewdrop:Close(4)
								end
							)
						end
					end
				end

				if type(value) == "table" and value[1] == "editCat3icon" then
					local cat = value[2]
					for i=1, getn(categoryIcons) do
						if tab[cat].icon == categoryIcons[i] then
							Dewdrop:AddLine(
								'text', "= "..L["selected"],
								'tooltipTitle', "",
								'icon', categoryIcons[i],
								'arg1', categoryIcons[i],
								'func', function(value)
									tab[cat].icon = value
									self:print(string.format(L["SELECTED icon for category '%s': %s"],cat,categoryIcons[i]))
									Dewdrop:Refresh(2)
									Dewdrop:Refresh(3)
									Dewdrop:Close(4)
								end
							)
						else
							Dewdrop:AddLine(
								'icon', categoryIcons[i],
								'arg1', categoryIcons[i],
								'func', function(value)
									tab[cat].icon = value
									self:print(string.format(L["SELECTED icon for category '%s': %s"],cat,categoryIcons[i]))
									Dewdrop:Refresh(2)
									Dewdrop:Refresh(3)
									Dewdrop:Close(4)
								end
							)
						end
					end
				end
			-- ----------------------------------------------------------------------
			elseif level == 5 then
			-- ----------------------------------------------------------------------
				if type(value) == "table" and value[1] == "editSearchQuery2pos" then
					local cat = value[2]
					local subTab = value[3]
					local c = 1
					for sq,v in self:sortedpairs(tab[cat].queries,1) do
						if c == tab[cat].queries[subTab].order then
							Dewdrop:AddLine(
								'text', c,
								'tooltipTitle', "",
								'icon', "Interface\\Buttons\\UI-CheckBox-Check",
								'arg1', c,
								'func', function(value)
									tab[cat].queries[subTab].order = value
									self:print(string.format(L["ASSIGNED sort number '%s' to search query '%s' (Category: %s)!"],value,subTab,cat))
									Dewdrop:Refresh(3)
									Dewdrop:Close(4)
									Dewdrop:Close(5)
								end
							)
						else
							Dewdrop:AddLine(
								'text', c,
								'tooltipTitle', "",
								'arg1', c,
								'func', function(value)
									tab[cat].queries[subTab].order = value
									self:print(string.format(L["ASSIGNED sort number '%s' to search query '%s' (Category: %s)!"],value,subTab,cat))
									Dewdrop:Refresh(3)
									Dewdrop:Close(4)
									Dewdrop:Close(5)
								end
							)
						end
						c=c+1
					end
				end

				if type(value) == "table" and value[1] == "editSearchQuery2LevelRange" then
					local cat = value[2]
					local sq = value[3]
					Dewdrop:AddLine(
						'text', L["min"],
						'tooltipTitle', "",
						'hasArrow', true,
						'value', {'editSearchQuery2LevelRangeMin', cat, sq}
					)
					Dewdrop:AddLine(
						'text', L["max"],
						'tooltipTitle', "",
						'hasArrow', true,
						'value', {'editSearchQuery2LevelRangeMax', cat, sq}
					)
				end

				if type(value) == "table" and value[1] == "editSearchQuery2Rarity" then
					local cat = value[2]
					local sq = value[3]
					for i=1, getn(itemRarityNames) do
						if i == (tab[cat].queries[sq].qualityIndex+2) then
							Dewdrop:AddLine(
								'text', itemRarityColors[i]..itemRarityNames[i],
								'tooltipTitle', "",
								'icon', "Interface\\Buttons\\UI-CheckBox-Check"
							)
						else
							Dewdrop:AddLine(
								'text', itemRarityColors[i]..itemRarityNames[i],
								'tooltipTitle', "",
								'arg1', (i-2),
								'func', function(value)
									tab[cat].queries[sq].qualityIndex = value
									self:print(string.format(L["Rarity for search query '%s' (Category: %s) CHANGED TO %s!"],sq,cat,itemRarityColors[value+2]..itemRarityNames[value+2]..TOOLTIP_COLOR_DATA))
									Dewdrop:Refresh(3)
									Dewdrop:Close(5)
									Dewdrop:Close(4)
								end
							)
						end
					end
				end

				if type(value) == "table" and value[1] == "editSearchQuery2FiltersLVL1" then
					local cat = value[2]
					local sq = value[3]
					local x = {}
					x[1],x[2],x[3],x[4],x[5],x[6],x[7],x[8],x[9],x[10],x[11],x[12],x[13],x[14],x[15],x[16],x[17],x[18],x[19],x[20] = GetAuctionItemClasses()
					for i=1, getn(x) do
						local a = {}
						a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10],a[11],a[12],a[13],a[14],a[15],a[16],a[17],a[18],a[19],a[20] = GetAuctionItemSubClasses(i)
						local func = function()
							tab[cat].queries[sq].classIndex = i
							tab[cat].queries[sq].subclass = nil
							tab[cat].queries[sq].subclassIndex = nil
							tab[cat].queries[sq].invTypeIndex = nil
							self:print(string.format(L["Filters for search query '%s' (Category: %s) CHANGED TO %s!"],sq,cat,x[i]))
							Dewdrop:Refresh(3)
							Dewdrop:Refresh(4)
							Dewdrop:Close(5)
						end
						local func2 = function()
							tab[cat].queries[sq].classIndex = nil
							tab[cat].queries[sq].subclass = nil
							tab[cat].queries[sq].subclassIndex = nil
							tab[cat].queries[sq].invTypeIndex = nil
							self:print(string.format(L["Filters for search query '%s' (Category: %s) CHANGED TO %s!"],sq,cat,"'"..L["no filters"].."'"))
							Dewdrop:Refresh(3)
							Dewdrop:Refresh(4)
							Dewdrop:Close(5)
						end
						if i == 1 then
							if tab[cat].queries[sq].classIndex then
								Dewdrop:AddLine(
									'text', L["no filters"],
									'tooltipTitle', "",
									'func', func2
								)
							else
								Dewdrop:AddLine(
									'text', L["no filters"],
									'tooltipTitle', "",
									'icon', "Interface\\Buttons\\UI-CheckBox-Check",
									'func', func2
								)
							end
						end
						if getn(a) > 0 then
							if i == tab[cat].queries[sq].classIndex then
								Dewdrop:AddLine(
									'text', x[i],
									'tooltipTitle', "",
									'icon', "Interface\\Buttons\\UI-CheckBox-Check",
									'hasArrow', true,
									'value', {'editSearchQuery2FiltersLVL2', cat, sq, i, x[i], getn(a)},
									'func', func
								)
							else
								Dewdrop:AddLine(
									'text', x[i],
									'tooltipTitle', "",
									'hasArrow', true,
									'value', {'editSearchQuery2FiltersLVL2', cat, sq, i, x[i], getn(a)},
									'func', func
								)
							end
						else
							if i == tab[cat].queries[sq].classIndex then
								Dewdrop:AddLine(
									'text', x[i],
									'tooltipTitle', "",
									'icon', "Interface\\Buttons\\UI-CheckBox-Check",
									'func', func
								)
							else
								Dewdrop:AddLine(
									'text', x[i],
									'tooltipTitle', "",
									'func', func
								)
							end
						end
					end
				end
			-- ----------------------------------------------------------------------
			elseif level == 6 then
			-- ----------------------------------------------------------------------
				if type(value) == "table" and value[1] == "editSearchQuery2LevelRangeMin" then
					local cat = value[2]
					local sq = value[3]
					local lrmin = tonumber(tab[cat].queries[sq].minLevel)
					local lrmax = tonumber(tab[cat].queries[sq].maxLevel)
					local lrsel
					if lrmax then
						if lrmax > maxItemLevel then
							lrsel = maxItemLevel
						else
							lrsel = lrmax
						end
					else
						lrsel = maxItemLevel
					end
					if tab[cat].queries[sq].minLevel == "" then
						Dewdrop:AddLine(
							'text', L["no value"],
							'tooltipTitle', "",
							'icon', "Interface\\Buttons\\UI-CheckBox-Check"
						)
					else
						Dewdrop:AddLine(
							'text', L["no value"],
							'tooltipTitle', "",
							'func', function()
								tab[cat].queries[sq].minLevel = ""
								self:print(string.format(L["Min. Level for search query '%s' (Category: %s) CHANGED TO 'no value'!"],sq,cat))
								Dewdrop:Refresh(3)
								Dewdrop:Refresh(4)
								Dewdrop:Close(6)
								Dewdrop:Close(5)
							end
						)
					end
					for i=0, lrsel do
						if i == lrmin then
							Dewdrop:AddLine(
								'text', i,
								'tooltipTitle', "",
								'icon', "Interface\\Buttons\\UI-CheckBox-Check"
							)
						else
							Dewdrop:AddLine(
								'text', i,
								'tooltipTitle', "",
								'arg1', i,
								'func', function(value)
									tab[cat].queries[sq].minLevel = tostring(value)
									self:print(string.format(L["Min. Level for search query '%s' (Category: %s) CHANGED TO %s!"],sq,cat,value))
									Dewdrop:Refresh(3)
									Dewdrop:Refresh(4)
									Dewdrop:Close(6)
									Dewdrop:Close(5)
								end
							)
						end
					end
				end

				if type(value) == "table" and value[1] == "editSearchQuery2LevelRangeMax" then
					local cat = value[2]
					local sq = value[3]
					local lrmin = tonumber(tab[cat].queries[sq].minLevel)
					local lrmax = tonumber(tab[cat].queries[sq].maxLevel)
					local lrsel
					if lrmin then
						if lrmin > maxItemLevel then
							lrsel = maxItemLevel
						else
							lrsel = lrmin
						end
					else
						lrsel = 0
					end
					for i=lrsel, maxItemLevel do
						if i == lrmax then
							Dewdrop:AddLine(
								'text', i,
								'tooltipTitle', "",
								'icon', "Interface\\Buttons\\UI-CheckBox-Check"
							)
						else
							Dewdrop:AddLine(
								'text', i,
								'tooltipTitle', "",
								'arg1', i,
								'func', function(value)
									tab[cat].queries[sq].maxLevel = tostring(value)
									self:print(string.format(L["Max. Level for search query '%s' (Category: %s) CHANGED TO %s!"],sq,cat,value))
									Dewdrop:Refresh(3)
									Dewdrop:Refresh(4)
									Dewdrop:Close(6)
									Dewdrop:Close(5)
								end
							)
						end
					end
					if tab[cat].queries[sq].maxLevel == "" then
						Dewdrop:AddLine(
							'text', L["no value"],
							'tooltipTitle', "",
							'icon', "Interface\\Buttons\\UI-CheckBox-Check"
						)
					else
						Dewdrop:AddLine(
							'text', L["no value"],
							'tooltipTitle', "",
							'func', function()
								tab[cat].queries[sq].maxLevel = ""
								self:print(string.format(L["Max. Level for search query '%s' (Category: %s) CHANGED TO 'no value'!"],sq,cat))
								Dewdrop:Refresh(3)
								Dewdrop:Refresh(4)
								Dewdrop:Close(6)
								Dewdrop:Close(5)
							end
						)
					end
				end

				if type(value) == "table" and value[1] == "editSearchQuery2FiltersLVL2" then
					local cat = value[2]
					local sq = value[3]
					local lvl1 = value[4]
					local lvl1name = value[5]
					local lvl1count = value[6]
					for i=1, lvl1count do
						local a = {}
						a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10],a[11],a[12],a[13],a[14],a[15],a[16],a[17],a[18],a[19],a[20] = GetAuctionItemSubClasses(lvl1)
						local b = {}
						b[1],b[2],b[3],b[4],b[5],b[6],b[7],b[8],b[9],b[10],b[11],b[12],b[13],b[14],b[15],b[16],b[17],b[18],b[19],b[20] = GetAuctionInvTypes(lvl1,i)
						local func = function()
							tab[cat].queries[sq].classIndex = lvl1
							tab[cat].queries[sq].subclass = "|cffffffff"..a[i].."|r"
							tab[cat].queries[sq].subclassIndex = i
							tab[cat].queries[sq].invTypeIndex = nil
							self:print(string.format(L["Filters for search query '%s' (Category: %s) CHANGED TO %s-%s!"],sq,cat,lvl1name,a[i]))
							Dewdrop:Refresh(3)
							Dewdrop:Refresh(4)
							Dewdrop:Close(5)
							Dewdrop:Close(6)
						end
						if tab[cat].queries[sq].subclassIndex then
							if i == tab[cat].queries[sq].subclassIndex and tab[cat].queries[sq].classIndex == lvl1 then
								if getn(b) > 0 then
									Dewdrop:AddLine(
										'text', a[i],
										'tooltipTitle', "",
										'icon', "Interface\\Buttons\\UI-CheckBox-Check",
										'hasArrow', true,
										'value', {'editSearchQuery2FiltersLVL3', cat, sq, lvl1, lvl1name, i, a[i], getn(b)},
										'func', func
									)
								else
									Dewdrop:AddLine(
										'text', a[i],
										'tooltipTitle', "",
										'icon', "Interface\\Buttons\\UI-CheckBox-Check",
										'func', func
									)
								end
							else
								if getn(b) > 0 then
									Dewdrop:AddLine(
										'text', a[i],
										'tooltipTitle', "",
										'hasArrow', true,
										'value', {'editSearchQuery2FiltersLVL3', cat, sq, lvl1, lvl1name, i, a[i], getn(b)},
										'func', func
									)
								else
									Dewdrop:AddLine(
										'text', a[i],
										'tooltipTitle', "",
										'func', func
									)
								end
							end
						else
							if getn(b) > 0 then
								Dewdrop:AddLine(
									'text', a[i],
									'tooltipTitle', "",
									'hasArrow', true,
									'value', {'editSearchQuery2FiltersLVL3', cat, sq, lvl1, lvl1name, i, a[i], getn(b)},
									'func', func
								)
							else
								Dewdrop:AddLine(
									'text', a[i],
									'tooltipTitle', "",
									'func', func
								)
							end
						end
					end
				end
			-- ----------------------------------------------------------------------
			elseif level == 7 then
			-- ----------------------------------------------------------------------
				if type(value) == "table" and value[1] == "editSearchQuery2FiltersLVL3" then
					local cat = value[2]
					local sq = value[3]
					local lvl1 = value[4]
					local lvl1name = value[5]
					local lvl2 = value[6]
					local lvl2name = value[7]
					local lvl2count = value[8]
					for i=1, lvl2count do
						local a = {}
						a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10],a[11],a[12],a[13],a[14],a[15],a[16],a[17],a[18],a[19],a[20] = GetAuctionInvTypes(lvl1,lvl2)
						local func = function()
							tab[cat].queries[sq].classIndex = lvl1
							tab[cat].queries[sq].subclass = "|cffffffff"..lvl2name.."|r"
							tab[cat].queries[sq].subclassIndex = lvl2
							tab[cat].queries[sq].invTypeIndex = i
							self:print(string.format(L["Filters for search query '%s' (Category: %s) CHANGED TO %s-%s-%s!"],sq,cat,lvl1name,lvl2name,getglobal(a[i])))
							Dewdrop:Refresh(3)
							Dewdrop:Refresh(4)
							Dewdrop:Close(5)
							Dewdrop:Close(6)
							Dewdrop:Close(7)
						end
						if tab[cat].queries[sq].invTypeIndex then
							if i == tab[cat].queries[sq].invTypeIndex and tab[cat].queries[sq].subclassIndex == lvl2 then
								Dewdrop:AddLine(
									'text', getglobal(a[i]),
									'tooltipTitle', "",
									'icon', "Interface\\Buttons\\UI-CheckBox-Check",
									'func', func
								)
							else
								Dewdrop:AddLine(
									'text', getglobal(a[i]),
									'tooltipTitle', "",
									'func', func
								)
							end
						else
							Dewdrop:AddLine(
								'text', getglobal(a[i]),
								'tooltipTitle', "",
								'func', func
							)
						end
					end
				end

			end
		end
	)
end
-- --------------------------
-- CreatePullDownOptionsMenu
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- SaveSearchInCategory
-- --------------------------
function AHsearch:SaveSearchInCategory(cat,sq)
	local lastSearch = { 
		name = BrowseName:GetText(), 
		order = 1,
		minLevel = BrowseMinLevel:GetText(), 
		maxLevel = BrowseMaxLevel:GetText(), 
		invTypeIndex = AuctionFrameBrowse.selectedInvtypeIndex, 
		classIndex = AuctionFrameBrowse.selectedClassIndex,
		subclassIndex = AuctionFrameBrowse.selectedSubclassIndex,
		subclass = AuctionFrameBrowse.selectedSubclass,
		isUsable = IsUsableCheckButton:GetChecked(),
		showOnPlayer = ShowOnPlayerCheckButton:GetChecked()
	}

	if not UIDropDownMenu_GetSelectedValue(BrowseDropDown) then
		lastSearch.qualityIndex = -1
		UIDropDownMenu_SetSelectedValue(BrowseDropDown, -1)
		UIDropDownMenu_Initialize(BrowseDropDown, BrowseDropDown_Initialize)
		AuctionFrameFilters_Update()
		UIDropDownMenu_Refresh(BrowseDropDown, false)
	else
		lastSearch.qualityIndex = UIDropDownMenu_GetSelectedValue(BrowseDropDown)
	end

	self.db.profile.search[cat].queries[sq] = {}
	self.db.profile.search[cat].queries[sq] = lastSearch
	self:print(string.format(L["Search query '%s' SAVED in category '%s'!"],sq,cat))
	Dewdrop:Close(1)
end
-- --------------------------
-- SaveSearchInCategory
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- sortedpairs
-- --------------------------
function AHsearch:sortedpairs(t,lvl)
	_G.ntab = {}
	for k,v in pairs(t) do
		table.insert(_G.ntab,k)
	end

	if lvl then
		table.sort(_G.ntab,
			function(a,b)
				if t[a].order == t[b].order then
					if t[a].qualityIndex == t[b].qualityIndex then
						if a < b then
							return true
						end
					end
					if t[a].qualityIndex > t[b].qualityIndex then
						return true
					end	
				end
				if t[a].order < t[b].order then
					return true
				end
			end
		)
	else
		table.sort(_G.ntab,
			function(a,b)
				if t[a].order == t[b].order then
					if a < b then
						return true
					end
				end
				if t[a].order < t[b].order then
					return true					
				end
			end
		)
	end

	local i = 0
	local function _f(_s,_v)
		i = i + 1
		local k = _G.ntab[i]
		if (k) then
			return k,t[k]
		end
	end
	return _f,nil,nil
end
-- --------------------------
-- sortedpairs
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- checks
-- --------------------------
function AHsearch:owCheck(t,check)
	local x = false
	for k,v in pairs(t) do
		if k == check then
			x = true
			break
		end
	end
	return x
end

function AHsearch:ReturnGCheck()
	local x = true
	for k,v in pairs(self.db.profile.search) do
		for l,w in pairs(self.db.profile.search[k].queries) do
			x = false
			break
		end
	end
	return x
end

function AHsearch:ReturnCatCheck()
	local x = true
	for k,v in pairs(self.db.profile.search) do
		x = false
		break
	end
	return x
end

function AHsearch:ReturnCatCount()
	local x = 0
	for k,v in pairs(self.db.profile.search) do
		x = x + 1
	end
	return x
end

function AHsearch:ReturnSQcheck(cat)
	local x = true
	for k,v in pairs(self.db.profile.search[cat].queries) do
		x = false
		break
	end
	return x
end

function AHsearch:ReturnSQCount(cat)
	local x = 0
	for k,v in pairs(self.db.profile.search[cat].queries) do
		x = x + 1
	end
	return x
end
-- --------------------------
-- checks
-- ----------------------------------------------------------------------------



-- ----------------------------------------------------------------------------
-- TooltipDisplay
-- --------------------------
function AHsearch:TooltipDisplay(text)
	if self.db.profile.ttDisplay then
		return text
	else
		return ""
	end
end
-- --------------------------
-- TooltipDisplay
-- ----------------------------------------------------------------------------



-- ----------------------------------------------------------------------------
-- SQtooltip
-- --------------------------
function AHsearch:SQtooltip(cat,sq)
	if not self.db.profile.ttDisplay then return end
	local tab = self.db.profile.search
	local ttt = ""
	ttt = ttt..self:TooltipCATName(cat)
	ttt = ttt.."\n"..self:TooltipSQPosition(cat,sq)
	ttt = ttt.."\n"..self:TooltipSQSearchName(cat,sq)
	ttt = ttt.."\n"..self:TooltipSQSearchTerm(cat,sq)
	ttt = ttt.."\n"..self:TooltipSQLevelRange(cat,sq)
	ttt = ttt.."\n"..self:TooltipSQRarity(cat,sq)
	ttt = ttt.."\n"..self:TooltipSQUsableItems(cat,sq)
	ttt = ttt.."\n"..self:TooltipSQPreview(cat,sq)
	
	if self.db.profile.ttFiltersDisplay then
		if tab[cat].queries[sq].classIndex then
			if tab[cat].queries[sq].subclass then
				if tab[cat].queries[sq].invTypeIndex then
					ttt = ttt.."\n"..self:TooltipSQFilters(cat,sq,0).."\n"..self:TooltipSQFilters(cat,sq,1).."\n"..self:TooltipSQFilters(cat,sq,2).."\n"..self:TooltipSQFilters(cat,sq,3)
				else
					ttt = ttt.."\n"..self:TooltipSQFilters(cat,sq,0).."\n"..self:TooltipSQFilters(cat,sq,1).."\n"..self:TooltipSQFilters(cat,sq,2)
				end
			else
				ttt = ttt.."\n"..self:TooltipSQFilters(cat,sq,0).."\n"..self:TooltipSQFilters(cat,sq,1)
			end
		else
			ttt = ttt.."\n"..self:TooltipSQFilters(cat,sq,0)
		end
	else
		ttt = ttt.."\n"..self:TooltipSQFilters(cat,sq,0).."\n"..self:TooltipSQFilters(cat,sq,1).."\n"..self:TooltipSQFilters(cat,sq,2).."\n"..self:TooltipSQFilters(cat,sq,3)
	end
	return ttt
end

function AHsearch:TooltipSQPosition(cat,sq)
	return TOOLTIP_COLOR_DESC..L["Position"]..": "..TOOLTIP_COLOR_DATA..self.db.profile.search[cat].queries[sq].order
end

function AHsearch:TooltipSQSearchName(cat,sq)
	return TOOLTIP_COLOR_DESC..L["Search query"]..": "..itemRarityColors[self.db.profile.search[cat].queries[sq].qualityIndex+2]..sq
end

function AHsearch:TooltipSQSearchTerm(cat,sq)
	local tt_st = self.db.profile.search[cat].queries[sq].name
	if tt_st == "" then
		tt_st = "-"
	end
	return TOOLTIP_COLOR_DESC..L["Search term"]..": "..TOOLTIP_COLOR_DATA..tt_st
end

function AHsearch:TooltipSQLevelRange(cat,sq)
	local tt_lr
	local tt_lrmin = self.db.profile.search[cat].queries[sq].minLevel
	local tt_lrmax = self.db.profile.search[cat].queries[sq].maxLevel
	if tt_lrmin == "" and tt_lrmax == "" then
		tt_lr = "-"
	end
	if tt_lrmin == "" and tt_lrmax ~= "" then
		tt_lr = "-"..tt_lrmax
	end
	if tt_lrmin ~= "" and tt_lrmax == "" then
		tt_lr = tt_lrmin.."+"
	end
	if tt_lrmin ~= "" and tt_lrmax ~= "" then
		if tt_lrmin == tt_lrmax then
			tt_lr = tt_lrmin
		else
			tt_lr = tt_lrmin.."-"..tt_lrmax
		end
	end
	return TOOLTIP_COLOR_DESC..L["Level Range"]..": "..TOOLTIP_COLOR_DATA..tt_lr
end

function AHsearch:TooltipSQRarity(cat,sq)
	local tt_r = self.db.profile.search[cat].queries[sq].qualityIndex+2
	local tt_rb = ""
	if tt_r > 1 and tt_r < 6 then
		tt_rb = TOOLTIP_COLOR_DATA..L[" and better"]
	end 
	return TOOLTIP_COLOR_DESC..L["Rarity"]..": "..itemRarityColors[tt_r]..itemRarityNames[tt_r]..tt_rb
end

function AHsearch:TooltipSQUsableItems(cat,sq)
	local tt_UI = self.db.profile.search[cat].queries[sq].isUsable
	if tt_UI == 1 then
		return TOOLTIP_COLOR_DESC..L["Usable Items"]..": "..TOOLTIP_COLOR_YES..L["YES"]
	else
		return TOOLTIP_COLOR_DESC..L["Usable Items"]..": "..TOOLTIP_COLOR_NO..L["NO"]
	end
end

function AHsearch:TooltipSQPreview(cat,sq)
	local tt_UI = self.db.profile.search[cat].queries[sq].showOnPlayer
	if tt_UI == 1 then
		return TOOLTIP_COLOR_DESC..L["Display on Character"]..": "..TOOLTIP_COLOR_YES..L["YES"]
	else
		return TOOLTIP_COLOR_DESC..L["Display on Character"]..": "..TOOLTIP_COLOR_NO..L["NO"]
	end
end

function AHsearch:TooltipSQFilters(cat,sq,lvl)
	local ttf_c = CLASS_FILTERS[self.db.profile.search[cat].queries[sq].classIndex]
	local ttf_sc = self.db.profile.search[cat].queries[sq].subclass
	local ttf_iTI = self.db.profile.search[cat].queries[sq].invTypeIndex
	if ttf_c then
		if ttf_sc then
			if ttf_iTI then
				local a = {}
				a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10],a[11],a[12],a[13],a[14],a[15],a[16],a[17],a[18],a[19],a[20] = GetAuctionInvTypes(self.db.profile.search[cat].queries[sq].classIndex, self.db.profile.search[cat].queries[sq].subclassIndex)
				p1 = TOOLTIP_COLOR_DATA.."1.) "..ttf_c
				p2 = TOOLTIP_COLOR_DATA.."2.) "..ttf_sc
				if getglobal(a[ttf_iTI]) then
					p3 = TOOLTIP_COLOR_DATA.."3.) "..getglobal(a[ttf_iTI])
				else
					p3 = TOOLTIP_COLOR_DATA.."3.) sub-cat no longer available!!!"
				end
			else
				p1 = TOOLTIP_COLOR_DATA.."1.) "..ttf_c
				p2 = TOOLTIP_COLOR_DATA.."2.) "..ttf_sc
				p3 = TOOLTIP_COLOR_DATA.."3.) -"
			end
		else
			p1 = TOOLTIP_COLOR_DATA.."1.) "..ttf_c
			p2 = TOOLTIP_COLOR_DATA.."2.) -"
			p3 = TOOLTIP_COLOR_DATA.."3.) -"
		end
	else
		p1 = TOOLTIP_COLOR_DATA.."1.) -"
		p2 = TOOLTIP_COLOR_DATA.."2.) -"
		p3 = TOOLTIP_COLOR_DATA.."3.) -"
	end

	if lvl == 0 then
		if not ttf_c then
			return TOOLTIP_COLOR_DESC..L["Filters"]..": "..TOOLTIP_COLOR_DATA..L["no filters"]
		else
			return TOOLTIP_COLOR_DESC..L["Filters"]..":"
		end
	end
	if lvl == 1 then
		return p1
	end
	if lvl == 2 then
		return p2
	end
	if lvl == 3 then
		return p3
	end
end
-- --------------------------
-- SQtooltip
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- CATtooltip
-- --------------------------
function AHsearch:CATtooltip(cat)
	if not self.db.profile.ttDisplay then return end
	local tab = self.db.profile.search
	local ttt = ""
	ttt = ttt..self:TooltipCATName(cat)
	ttt = ttt.."\n"..self:TooltipCATPosition(cat)
	ttt = ttt.."\n"..self:TooltipCATColor(cat)
	ttt = ttt.."\n"..self:TooltipCATIcon(cat)
	return ttt
end

function AHsearch:TooltipCATName(cat)
	return TOOLTIP_COLOR_DESC..L["Category"]..": "..self.db.profile.search[cat].color..cat
end

function AHsearch:TooltipCATPosition(cat)
	return TOOLTIP_COLOR_DESC..L["Position"]..": "..TOOLTIP_COLOR_DATA..self.db.profile.search[cat].order
end

function AHsearch:TooltipCATColor(cat)
	return TOOLTIP_COLOR_DESC..L["Color"]..": "..self.db.profile.search[cat].color.."###"
end

function AHsearch:TooltipCATIcon(cat)
	local x = TOOLTIP_COLOR_NO..L["NO"]
	if self.db.profile.search[cat].icon ~= "" then
		x = TOOLTIP_COLOR_YES..L["YES"]
	end
	return TOOLTIP_COLOR_DESC..L["Icon"]..": "..x
end
-- --------------------------
-- CATtooltip
-- ----------------------------------------------------------------------------



-- ----------------------------------------------------------------------------
-- DBVersionCheck
-- --------------------------
function AHsearch:DBVersionCheck()
	if not self.db.profile.version then
		self.db.profile.version = 1
		for cat,v in pairs(self.db.profile.search) do
			self.db.profile.search[cat].color = "|cffffffff"
			self.db.profile.search[cat].icon = ""
		end
	end
end
-- --------------------------
-- DBVersionCheck
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- ConfirmPopup
-- --------------------------
function AHsearch:ConfirmPopup(message, func, ...)
	if not StaticPopupDialogs["AHSEARCH_CONFIRM_DIALOG"] then
		StaticPopupDialogs["AHSEARCH_CONFIRM_DIALOG"] = {}
	end
	local t = StaticPopupDialogs["AHSEARCH_CONFIRM_DIALOG"]
	for k in pairs(t) do
		t[k] = nil
	end
	t.text = message
	t.button1 = ACCEPT or "Accept"
	t.button2 = CANCEL or "Cancel"
	t.OnAccept = function()
		func(unpack(t))
	end
	for i = 1, select('#', ...) do
		t[i] = select(i, ...)
	end
	t.timeout = 0
	t.whileDead = 1
	t.hideOnEscape = 1
	
	Dewdrop:Close()
	StaticPopup_Show("AHSEARCH_CONFIRM_DIALOG")
end
-- --------------------------
-- ConfirmPopup
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- ReturnQcolor
-- --------------------------
function AHsearch:ReturnQcolor(cat,sq)
	return itemRarityColors[(self.db.profile.search[cat].queries[sq].qualityIndex+2)]..sq
end
-- --------------------------
-- ReturnQcolor
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- HelpOutput
-- --------------------------
function AHsearch:HelpOutput()
	local a = self.db.profile.chatOutput
	self.db.profile.chatOutput = true
	self:print("-- "..L["Help"].." -----------------")	
	self:print(L["Step 1 or 2: Right-click 'AHsearch Button' and create category ('Category: Create')."])
	self:print(L["Step 1 or 2: Set up your search criteria (you don't have to click the search button)."])
	self:print(L["Step 3: Right-click 'AHsearch Button' and choose a category in 'Search query: Save'."])
	self:print(L["Step 4: Give your search a name. Press return."])
	self:print(L["Step 5: Left-click 'AHsearch Button' for your search queries."])
	self:print("-- "..L["Help"].." -----------------")
	self:print(string.format(L["Maximum text length for categories and search queries: %s characters"],maxBoxInputLength))
	self:print(L["Color coding for saved search queries:"]..
		" "..itemRarityColors[1].."#"..L["All"].."#"..
		" "..itemRarityColors[2].."#"..L["Poor"].."#"..
		" "..itemRarityColors[3].."#"..L["Common"].."#"..
		" "..itemRarityColors[4].."#"..L["Uncommon"].."#"..
		" "..itemRarityColors[5].."#"..L["Rare"].."#"..
		" "..itemRarityColors[6].."#"..L["Epic"].."#")
	self.db.profile.chatOutput = a
end
-- --------------------------
-- HelpOutput
-- ----------------------------------------------------------------------------
