local L = AceLibrary("AceLocale-2.2"):new("AutoProfitX")
local charSettings, eList
local name = UnitName("player")
local realm = GetRealmName()
local totalProfit = 0
--make proficiency table local (defined in proficiencies.lua)
local prof = AutoProfitX_Proficiencies[UnitClass("player")] or {}
AutoProfitX_Proficiencies = nil
--default button position
local buttonY = -37
local buttonX = -41
local DEFAULT_SPIN_RATE = 0.6

AutoProfitX = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0","AceEvent-2.0","AceDB-2.0")

local waterfall = AceLibrary("Waterfall-1.0")
local tooltip = AceLibrary("Gratuity-2.0")

--some strings commonly used in addon
local linkMatch = "|c%x+|Hitem:[%-%d:]*|h%[.-%]|h|r"
local classMatch = string.format(ITEM_CLASSES_ALLOWED,"([%w, ]*)")

--[[

local helper functions

--]]

--performs deep copy of a table
local function tdeepcopy(from)
	if type(from) == "table" then
		local t = {}
		for k, v in pairs(from) do
			if type(v) == "table" then
				t[k] = tdeepcopy(v)
			else
				t[k] = v
			end
		end
		return t
	end
	return from
end

--returns a formatted money string
local function coppertogold(copper,showGold)
	local strValue = ""
	local val
	val = math.floor(copper/COPPER_PER_GOLD)
	copper = mod(copper,COPPER_PER_GOLD)
	if val > 0 or showGold then
		strValue = val .. L["g "]
	end
	
	val = math.floor(copper/COPPER_PER_SILVER)
	copper = mod(copper,COPPER_PER_SILVER)
	if val > 0 or strValue ~= "" then
		strValue = strValue .. val .. L["s "]
	end
	
	return strValue .. copper .. L["c"]
end

--[[

Main APX functions

--]]

function AutoProfitX:OnInitialize()
	--register database
	self:RegisterDB("AutoProfitXDB","AutoProfitXDBPerChar")
	
	--register default character settings
	self:RegisterDefaults("char", {
				autoSell = false,
				silent = false,
				showTotal = true,
				buttonYpos = buttonY,
				buttonXpos = buttonX,
				checkSoulbound = false,
				buttonSpin = "3"
			} )
	
	--initialize charSettings variable
	charSettings = self.db.char

	--register default exception list
	self:RegisterDefaults("account", {
				[realm] = {
					[name] = {
						exceptionList = {}
					}
				}
			} )
			
	--initialize eList variable
	eList = self.db.account[realm][name].exceptionList
			
	--register chat commands
    self:RegisterChatCommand({"/autoprofitx", L["/apx"]}, {
		type = "group",
		args = {
			[L["options"]] = {
				name = L["options"],
				type = "execute",
				desc = L["Show options panel."],
				func = "Open",
				handler = waterfall,
				passValue = "AutoProfitX"
			},
			[L["add"]] = {
				name = L["add"],
				type = "text",
				desc = L["Add items to global ignore list."],
				usage = L["<item link>[<item link>...]"],
				get = false,
				set = "AddGlobal"
			},
			[L["rem"]] = {
				name = L["rem"],
				type = "text",
				desc = L["Remove items from global ignore list."],
				usage = L["<item link>[<item link>...]"],
				get = false,
				set = "RemGlobal"
			},
			[L["me"]] = {
				name = L["me"],
				type = "text",
				desc = L["Add or remove an item from your exception list."],
				usage = L["<item link>[<item link>...]"],
				get = false,
				set = "AddRemLocal"
			},
			[L["list"]] = {
				name = L["list"],
				type = "execute",
				desc = L["List your exceptions."],
				func = "ListExceptions"
			}
		}
	})
	
	--set up options panel
	waterfall:Register("AutoProfitX",
						"aceOptions", {
							type = "group",
							args = {
								addon = {
									type = "group",
									name = L["Addon Options"],
									order = 10,
									args = {
										autoSell = {
											name = L["Auto Sell"],
											type = "toggle",
											desc = L["Automatically sell junk items when opening vendor window."],
											get = function () return charSettings.autoSell end,
											set = "ToggleAutoSell",
											handler = self,
											order = 10
										},
										silent = {
											name = L["Sales Reports"],
											type = "toggle",
											desc = L["Print items being sold in chat frame."],
											get = function () return not charSettings.silent end,
											set = function (v) charSettings.silent = not v end,
											order = 20
										},
										profit = {
											name = L["Show Profit"],
											type = "toggle",
											desc = L["Print total profit after sale."],
											get = function () return charSettings.showTotal end,
											set = function (v) charSettings.showTotal = v end,
											order = 25
										},
										sellSoulbound = {
											name = L["Sell Soulbound"],
											type = "toggle",
											desc = L["Sell unusable soulbound items."],
											get = function () return charSettings.checkSoulbound end,
											set = function (v) charSettings.checkSoulbound = v end,
											order = 30
										},
										buttonSpin = {
											name = L["Button Animation Options"],
											type = "text",
											desc = L["Set up when you want the treasure pile in the button to spin."],
											validate = {
												["0"] = L["Never spin"],
												["1"] = L["Mouse-over and profit"],
												["2"] = L["Mouse-over"],
												["3"] = L["Profits"]
											},
											validateDesc = {
												["0"] = L["Never spin"],
												["1"] = L["Spin when you mouse-over the button and there is junk to vendor."],
												["2"] = L["Spin every time you mouse over."],
												["3"] = L["Spin every time there is junk to sell."]
											},
											get = function () return charSettings.buttonSpin end,
											set = function (v) charSettings.buttonSpin = v end,
											order = 45
										},
										dockButton = {
											name = L["Reset Button Pos"],
											type = "execute",
											desc = L["Reset APX button position on the vendor screen to the top right corner."],
											func = function () self:SetButtonPosition(buttonX,buttonY) end,
											order = 50
										}
									}
								},
								exceptionList = {
									type = "group",
									name = L["Exception List"],
									args = {
										import = {
											name = L["Import Exception List"],
											type = "text",
											desc = L["Choose character to import exceptions from. Your exceptions will be deleted."],
											validate = self:GetCharList(),
											get = false,
											set = "ImportExceptionList",
											handler = self,
											order = 10
										},
										purge = {
											name = L["Clear Exceptions"],
											type = "execute",
											desc = L["Remove all items from exception list."],
											func = "PurgeExceptionList",
											handler = self,
											order = 20
										},
										update = {
											name = L["Update Exception List"],
											type = "execute",
											desc = L["Update exception list from pre 2.0 AutoProfitX version."],
											func = "UpdateExceptionLists",
											handler = self,
											order = 20
										}
									}
								}
							}
						},
						"title", "AutoProfitX",
						"treeLevels",2)
	if ( EarthFeature_AddButton ) then   --add by Isler
		EarthFeature_AddButton(
			{
				id= "AutoProfitX";
				name= L["OneKey Sell"];
				subtext= "AutoProfitX";
				tooltip = L["OneKey sell junk items when opening vendor window"];
				icon= "Interface\\Icons\\Spell_Nature_NatureBlessing";
				callback= function()
					AceLibrary("Waterfall-1.0"):Open('AutoProfitX')
					end;
			}
		);
	end
end

function AutoProfitX:OnEnable()
     --register events
	self:RegisterEvent("MERCHANT_SHOW","OnMerchantShow")
end

--returns a table with all your characters that have used autoprofitx
function AutoProfitX:GetCharList()
	local tbl = {}
	for rlm, charList in pairs(self.db.account) do
		for char in pairs(charList) do
			if char ~= name or rlm ~= realm then
				tinsert(tbl,char .. "@" .. rlm)
			end
		end
	end
	
	return tbl
end

--add global exceptions
function AutoProfitX:AddGlobal(exceptions)
	local itemID
	for link in string.gmatch(exceptions,linkMatch) do	
		itemID = self:GetID(link)
		if itemID then
			--add it to all exception lists
			for realm,charList in pairs(self.db.account) do
				for char,charSettings in pairs(charList) do
					charSettings.exceptionList[itemID] = true
				end
			end
			
			self:Print(L["Added %s to exception list for all characters."],link)
		else
			self:Print(L["Invalid item link provided."])
		end
	end
		
	if AutoProfitX_SellButton:IsVisible() then
		self:OnShowButton()
	end
end

--rem exceptions globaly
function AutoProfitX:RemGlobal(exceptions)
	local itemID
	
	for link in string.gmatch(exceptions,linkMatch) do
		itemID = self:GetID(link)
		if itemID then
			for realm,charList in pairs(self.db.account) do
				for char,charSettings in pairs(charList) do
					charSettings.exceptionList[itemID] = nil
				end
			end
			
			self:Print(L["Removed %s from all exception lists."],link);
		else
			self:Print(L["Invalid item link provided."]);
		end
	end
		
	if AutoProfitX_SellButton:IsVisible() then
		self:OnShowButton()
	end
end

--add/remve local exceptions
function AutoProfitX:AddRemLocal(exceptions)
	local itemID
	
	for link in string.gmatch(exceptions,linkMatch) do
		itemID = self:GetID(link)
		if itemID then
			if eList[itemID] then
				eList[itemID] = nil
				self:Print(L["Removed %s from exception list."],link)
			else
				eList[itemID] = true
				self:Print(L["Added %s to exception list."],link)
			end
		else
			self:Print(L["Invalid item link provided."])
		end
	end
		
	if AutoProfitX_SellButton:IsVisible() then
		self:OnShowButton()
	end
end

--display exception list
function AutoProfitX:ListExceptions()
	local link
	local dispHeader = true

	for i in pairs(eList) do
		if dispHeader then
			self:Print(L["Exceptions:"])
			dispHeader = false
		end

		_, link = GetItemInfo(i)
		if link then
			self:Print(link)
		end
	end
	
	if dispHeader then
		self:Print(L["Your exception list is empty."])
	end
end

--toggle auto sell
function AutoProfitX:ToggleAutoSell()
	charSettings.autoSell = not charSettings.autoSell
	if charSettings.autoSell then
		self:RegisterEvent("MERCHANT_SHOW","OnMerchantShow")
		AutoProfitX_SellButton:Hide()
	else
		self:UnregisterEvent("MERCHANT_SHOW")
		AutoProfitX_SellButton:Show()
	end
end

--purge exception list
function AutoProfitX:PurgeExceptionList()
	eList = { }
	self.db.account[realm][name].exceptionList = eList
	self:Print(L["Deleted all exceptions."])
end

--import exception list
--fromChar must be a string with name@realm
function AutoProfitX:ImportExceptionList(fromChar)
	local iName, iRealm = strsplit("@",fromChar)
	if iName then
		if self.db.account[iRealm] and self.db.account[iRealm][iName] and self.db.account[iRealm][iName].exceptionList then
			eList = tdeepcopy(self.db.account[iRealm][iName].exceptionList)
			self.db.account[realm][name].exceptionList = eList
			self:Print(L["Exception list imported from %s on %s."],iName,iRealm)
		else
			self:Print(L["Exception list could not be found for %s on %s."],iName,iRealm)
		end
		return
	end
end

--MERCHANT_SHOW event handler
function AutoProfitX:OnMerchantShow()
	if charSettings.autoSell then
		local profit = self:GetProfit()
		if profit > 0 then
			self:SellJunk()
			if charSettings.showTotal then
				self:Print(L["Total profits: %s"],coppertogold(profit))
			end
		end
	else
		--register BAG_UPDATE event for updating button
		self:RegisterEvent("BAG_UPDATE","OnBagUpdate")
		self:RegisterEvent("MERCHANT_CLOSED","OnMerchantClosed")
	end
end

--MERCHANT_CLOSED event handler
function AutoProfitX:OnMerchantClosed()
	--unregister BAG_UPDATE event used fr updating icon
	if self:IsEventRegistered("BAG_UPDATE") then
		self:UnregisterEvent("MERCHANT_CLOSED")
		self:UnregisterEvent("BAG_UPDATE")
	end
end

--BAG_UPDATE event handler
function AutoProfitX:OnBagUpdate()
	--update icon
	if AutoProfitX_SellButton:IsVisible() then
		self:OnShowButton()
	end
end

--returns itemID of the item when provided with an item link
function AutoProfitX:GetID(link)
	return string.match(link,"item:(%d+)")
end

--sells junk items
function AutoProfitX:SellJunk()
	local link
	
	if ( MerchantFrame:IsVisible() and MerchantFrame.selectedTab == 1 ) then
		for bag = 0, 4 do
			for slot = 1, GetContainerNumSlots(bag) do
				--if slot not empty and item is junk
				link = GetContainerItemLink(bag, slot)
				if link and self:IsJunk(link,bag,slot) then
					--sell item
					UseContainerItem(bag, slot)
					--if sale reporting is turned on (not silent), display sale message
					if not charSettings.silent then
						self:Print(L["Sold %s."],link)
					end
				end
			end
		end
	end
end

--returns true if item is junk
function AutoProfitX:IsJunk(link,bag,slot)
	local _, _, quality = GetItemInfo(link)
	local id = self:GetID(link)
	
	if eList[id] then
		-- since it's in the exception list, return true if not poor
		return quality ~= 0
 	end
	
	-- Not in the list, return true if it's poor quality
	if quality == 0 then
		return true
	end
	
	--Not poor quality, check if it's usable
	if charSettings.checkSoulbound and bag and slot and not self:IsUsable(bag,slot,link) then
		return true
	end
	
	return false
end

--returns false if a soulbound item cannot be used by player class
function AutoProfitX:IsUsable(bag,slot,link)
	--if it's not soulbound then you can always use it
	tooltip:SetBagItem(bag,slot)
	if not tooltip:Find(ITEM_SOULBOUND) then
		return true
	end
	
	--check if item has class requirement
	local class = UnitClass("player")
	local _, _, classes = tooltip:Find(classMatch)
	if classes then
		local found = false
		classes = {strsplit(L["LIST_SEPARATOR"], classes)}
		for _, c in ipairs(classes) do
			if class == c then
				found = true
			end
		end
		if not found then
			--class not in the list so you can't use it
			return false
		end
	end

	--check if class can ever use this item
	local _, _, _, _, _, iType, iSubType, _, iEquipLoc = GetItemInfo(link)
	local tbl = prof[iType]
	if tbl and (tbl[iSubType] or (tbl.noOffhand and iEquipLoc == "INVTYPE_WEAPONOFFHAND")) then
		return false
	end

	--seems usable
	return true
end

--returns the sum of all junk item sell prices
function AutoProfitX:GetProfit()
	totalProfit = 0
	if MerchantFrame:IsVisible() then
		local bagSlots, link
		for bag = 0,4 do
			bagSlots = GetContainerNumSlots(bag)
			if bagSlots > 0 then
				for slot = 1, bagSlots do
					link = GetContainerItemLink(bag, slot)
					if link then
						if AutoProfitX:IsJunk(link,bag,slot) then
							AutoProfitX_Tooltip:SetBagItem(bag, slot)
						end
					end
				end
			end
		end
	end
	return totalProfit
end

--[[

Button functions

]]

--drags button APX button
function AutoProfitX:DragButton()
	--farthest right and left positions on the merchant frame (relative to merchant frame)
	local MAX_RIGHT = -41
	local MAX_LEFT = -280
	local detatch = false
	local scale = MerchantFrame:GetEffectiveScale()
	local cursorOffset = 1
	--current cursor x coordinate
    local xpos, ypos = GetCursorPosition()
	xpos = xpos/scale
	ypos = ypos/scale
	--merchant fame position (right border of frame)
	local mwpos = MerchantFrame:GetRight()

	if IsShiftKeyDown() or charSettings.buttonXpos > MAX_RIGHT or charSettings.buttonXpos < MAX_LEFT or charSettings.buttonYpos ~= buttonY then
		detatch = true
	end

	--cursor x offset from merchant frame's right border
    xpos = xpos - mwpos - cursorOffset

	--if detatched, set y position
	--otherwise check if x is in bounds
	if detatch then
		local mwypos = MerchantFrame:GetTop()
		ypos = ypos - mwypos - cursorOffset
	else
		--check if cursor is not outside the topbar of merchant frame
		if xpos > MAX_RIGHT then
			xpos = MAX_RIGHT
		elseif xpos < MAX_LEFT then
			xpos = MAX_LEFT
		end
		ypos = nil
	end

	--position button
	self:SetButtonPosition(xpos,ypos)
end

function AutoProfitX:OnEnterButton()
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
	GameTooltip:SetText(L["Sell Junk Items"])
	local profit = self:GetProfit()
	--spin button if on mouse-over is selected
	if charSettings.buttonSpin == "2" then
		self:ButtonSpin()
	end
	if profit > 0 then
		--spin button if on mouse-over and profit is selected
		if charSettings.buttonSpin == "1" then
			self:ButtonSpin()
		end
		SetTooltipMoney(GameTooltip, profit)
	else
		GameTooltip:AddLine(L["You have no junk items in your inventory."], 1.0, 1.0, 1.0, 1)
	end
	GameTooltip:Show()
end

function AutoProfitX:OnLeaveButton()
	GameTooltip:Hide()
	if charSettings.buttonSpin ~= "3" then
		self:ButtonStopSpin()
	end
end

function AutoProfitX:OnClickButton()
	local profit = self:GetProfit()
	if profit > 0 then
		GameTooltip:Hide()
		self:SellJunk()
		if charSettings.showTotal then
			self:Print(L["Total profits: %s"],coppertogold(profit))
		end
		if charSettings.buttonSpin ~= "2" then
			self:ButtonStopSpin()
		end
	end
end

function AutoProfitX:OnShowButton()
	if charSettings.autoSell then
		this:Hide()
	end
	if charSettings.buttonSpin == "3" and self:GetProfit() > 0 then
		self:ButtonSpin()
	end
end

function AutoProfitX:SetButtonPosition(buttonXpos,buttonYpos)
	buttonXpos = tonumber(buttonXpos)
	buttonYpos = tonumber(buttonYpos)
	
	if buttonXpos then
		charSettings.buttonXpos = buttonXpos
	end
	
	if buttonYpos then
		charSettings.buttonYpos = buttonYpos
	end
	
	AutoProfitX_SellButton:SetPoint("TOPRIGHT","MerchantFrame","TOPRIGHT",charSettings.buttonXpos,charSettings.buttonYpos)
end

function AutoProfitX:AddTooltipMoney()
	if arg1 then
		totalProfit = totalProfit + arg1
	end
end

function AutoProfitX:ButtonSpin(spinRate)
	spinRate = tonumber(spinRate)
	if not spinRate then
		spinRate = DEFAULT_SPIN_RATE
	end
	
	AutoProfitX_SellButton_TreasureModel.rotRate = spinRate
end

function AutoProfitX:ButtonStopSpin()
	AutoProfitX_SellButton_TreasureModel.rotRate = 0
end

--[[

Temporary features

--]]
--updates the exception list from pre 2.0 APX
function AutoProfitX:UpdateExceptionLists()
	if AutoProfitX_Settings then
		for realm, charList in pairs(AutoProfitX_Settings) do
			for char, settings in pairs(charList) do
				for itemID in pairs(settings.ExceptionList) do
					if tonumber(itemID) then
						if not self.db.account[realm] then
							self.db.account[realm] = {[char] = { exceptionList = {[itemID] = true}}}
						elseif not self.db.account[realm][char] then
							self.db.account[realm][char] = { exceptionList = {[itemID] = true}}
						else
							self.db.account[realm][char].exceptionList[itemID] = true
						end
					end
				end
			end
		end
	end
	--get rid of old variables
	AutoProfitX_Settings = nil
	AutoProfitX_ExceptionlistVersion = nil
	
	self:Print(L["Exceptions updated."])
end
