--
-- AutoBarProfile
-- Copyright 2007+ Toadkiller of Proudmoore.
--
-- Categories for AutoBar
-- A Category encapsulates a list of items / spells etc. along with metadata describing their use.
-- http://code.google.com/p/autobar/
--

--	PeriodicGroup
--		description
--		texture
--		targetted
--		nonCombat
--		location
--		battleground
--		notUsable (soul shards, arrows, etc.)
--		flying

--	AutoBar
--		arrangeOnUse

--		spell
--		limit


AutoBarCategoryList = {}

local L = AceLibrary("AceLocale-2.2"):new("AutoBar")
local PT = AceLibrary:GetInstance("PeriodicTable-3.0")
local BS = AceLibrary:GetInstance("Babble-Spell-2.2")
local BZ = AceLibrary:GetInstance("Babble-Zone-2.2")
local AceOO = AceLibrary("AceOO-2.0")


local function sortList(a, b)
	local x = tonumber(a[2]);
	local y = tonumber(b[2]);

	if (x == y) then
		if (a[3]) then
			return false;
		else
			if (b[3]) then
				return true;
			else
				return false;
			end
		end
	else
		return x < y;
	end
end


-- Mandatory attributes:
--		description - localized description
--		texture - display icon texture
-- Optional attributes:
--		arrangeOnUse, targetted, nonCombat, location, battleground, notUsable
AutoBarCategory = AceOO.Class()
AutoBarCategory.virtual = true -- this means that it cannot be instantiated. (cannot call :new())

function AutoBarCategory.prototype:init(description, texture)
	AutoBarCategory.super.prototype.init(self) -- very important. Will fail without this.
	self.description = L[description]
	self.texture = texture
end

-- True if an item gets arranged to the top on use
function AutoBarCategory.prototype:SetArrangeOnUse(arrangeOnUse)
	self.arrangeOnUse = arrangeOnUse
end

-- Move item to the top (end) of list
function AutoBarCategory.prototype:ArrangeOnUse(item)
-- TODO: arrangeOnUse

end

-- True if items can be targetted
function AutoBarCategory.prototype:SetTargetted(targetted)
	self.targetted = targetted
end

-- True if only usable outside combat
function AutoBarCategory.prototype:SetNonCombat(nonCombat)
	self.nonCombat = nonCombat
end

-- True if item is location specific
function AutoBarCategory.prototype:SetLocation(location)
	self.location = location
end

-- True if item is for battlegrounds only
function AutoBarCategory.prototype:SetBattleground(battleground)
	self.battleground = battleground
end

-- True if item is not usable (soul shards, arrows, etc.)
function AutoBarCategory.prototype:SetNotUsable(notUsable)
	self.notUsable = notUsable
end

-- Return nil or list of spells matching player class
function AutoBarCategory:FilterClass(castList)
	local spellName, index, filteredList
--DEFAULT_CHAT_FRAME:AddMessage("AutoBarCategory:FilterClass castList " .. tostring(castList))

	-- Filter out CLASS spells from castList
	index = 1
	for i = 1, # castList, 2 do
		if (AutoBar.CLASS == castList[i]) then
			spellName = castList[i + 1]
			if (not filteredList) then
				filteredList = {}
			end
			filteredList[index] = spellName
			index = index + 1
		end
	end
	return filteredList
end

-- Top castable item from castList will cast on RightClick
function AutoBarCategory.prototype:SetCastList(castList)
--DEFAULT_CHAT_FRAME:AddMessage("AutoBarCategory.prototype:SetCastList " .. description .. " castList " .. tostring(castList))
	if (castList) then
		self.spells = castList
		for index, spellName in ipairs(castList) do
--DEFAULT_CHAT_FRAME:AddMessage("AutoBarCategory.prototype:SetCastList " .. tostring(spellName))
			AutoBarSearch:RegisterSpell(spellName)
			if (AutoBarSearch:CanCastSpell(spellName)) then	-- TODO: update on leveling in case new spell aquired
--DEFAULT_CHAT_FRAME:AddMessage("AutoBarCategory.prototype:SetCastList castable " .. tostring(spellName))
				self.castSpell = spellName
			end
		end
	end
end

-- Called once to allocate space and initialize items
function AutoBarCategory.prototype:ItemsInit()
	self.items = nil
end

-- Reset the item list based on changed settings.
-- So pet change, Spellbook changed for spells, etc.
function AutoBarCategory.prototype:Refresh()
end



-- Category consisting of regular items
AutoBarItems = AceOO.Class(AutoBarCategory)

-- ptItems, ptPriorityItems are PeriodicTable sets
-- priorityItems sort higher than items at the same value
function AutoBarItems.prototype:init(description, texture, ptItems, ptPriorityItems)
	AutoBarItems.super.prototype.init(self, description, texture) -- very important. Will fail without this.
	self.ptItems = ptItems
	self.ptPriorityItems = ptPriorityItems

	local rawList = nil
	rawList = self:RawItemsAdd(rawList, ptItems, false)
	if (ptPriorityItems) then
		rawList = self:RawItemsAdd(rawList, ptPriorityItems, true)
	end
	self.items = self:RawItemsConvert(rawList)
end

-- Reset the item list based on changed settings.
function AutoBarItems.prototype:Refresh()
end

-- Convert rawList to a simple array of itemIds, ordered by their value in the set, and priority if any
function AutoBarItems.prototype:RawItemsConvert(rawList)
	local itemArray = {}
	table.sort(rawList, sortList)
	for i, j in ipairs(rawList) do
		itemArray[i] = j[1]
	end
	return itemArray
end


-- Add items from set to rawList
-- If priority is true, the items will have priority over non-priority items with the same values
function AutoBarItems.prototype:RawItemsAdd(rawList, set, priority)
--DEFAULT_CHAT_FRAME:AddMessage("RawItemsAdd set " .. tostring(set).." priority ".. tostring(priority));
	if (not rawList) then
		rawList = {};
	end
	if (set) then
		local cacheSet = PT:GetSetTable(set);
		if (cacheSet) then
			local index = table.getn(rawList) + 1;
			for itemId, value in PT:IterateSet(set) do
				if (not value or type(value) == "boolean") then
					value = 0;
				end
				value = tonumber(value);
				rawList[index] = {itemId, value, priority};
				index = index + 1;
			end
		end
	end
	return rawList;
end





-- Category consisting of regular items
AutoBarPetFood = AceOO.Class(AutoBarItems)

-- ptItems, ptPriorityItems are PeriodicTable sets
-- priorityItems sort higher than items at the same value
function AutoBarPetFood.prototype:init(description, texture, ptItems, ptPriorityItems)
	AutoBarPetFood.super.prototype.init(self, description, texture, ptItems, ptPriorityItems)

	self.castSpell = BS["Feed Pet"];
end

-- Reset the item list based on changed settings.
function AutoBarPetFood.prototype:Refresh()
end



-- Category consisting of spells
AutoBarSpells = AceOO.Class(AutoBarCategory)

-- castList, rightClickList are of the form:
-- { "DRUID", BS["Flight Form"], "DRUID", BS["Swift Flight Form"], ["<class>", "<localized spell name>",] ... }
-- If present rightClickList overrides rightClick spell forcing no action if not present
-- # rightClickList <= # castList per class
-- Icon from castList is used unless not available but rightClickList is
function AutoBarSpells.prototype:init(description, texture, castList, rightClickList)
	AutoBarSpells.super.prototype.init(self, description, texture) -- very important. Will fail without this.
	local spellName, index
--DEFAULT_CHAT_FRAME:AddMessage("AutoBarSpells.prototype:init " .. description .. " castList " .. tostring(castList))

	-- Filter out CLASS spells from castList
	index = 1
	for i = 1, # castList, 2 do
		if (AutoBar.CLASS == castList[i]) then
			spellName = castList[i + 1]
			if (not self.castList) then
				self.castList = {}
			end
			self.castList[index] = spellName
			index = index + 1
		end
	end
--DEFAULT_CHAT_FRAME:AddMessage("AutoBarSpells.prototype:init " .. description .. " self.castList " .. tostring(self.castList))

	-- Filter out CLASS spells from rightClickList
	if (rightClickList) then
		index = 1
		for i = 1, # rightClickList, 2 do
			if (AutoBar.CLASS == rightClickList[i]) then
				spellName = rightClickList[i + 1]
				if (not self.rightClickList) then
					self.rightClickList = {}
				end
				self.rightClickList[index] = spellName
				index = index + 1
			end
		end
	end

	-- Populate items based on currently castable spells
	index = 1
	self.items = {}
	if (self.castList) then
		for i, spellName in ipairs(self.castList) do
			AutoBarSearch:RegisterSpell(spellName)
			if (AutoBarSearch:CanCastSpell(spellName)) then	-- TODO: update on leveling in case new spell aquired
--DEFAULT_CHAT_FRAME:AddMessage("AutoBarSpells.prototype:init castable " .. tostring(spellName))
				self.items[index] = spellName
				index = index + 1
			end
		end
	end


--		spellList = {}
--		spellList[1] = self:RegisterSpell(BS["Teleport: Moonglade"])
--		self.items = spellList
end

-- Reset the item list based on changed settings.
function AutoBarSpells.prototype:Refresh()
end



-- Fill in category item lists with the raw data from PeriodicTable.
-- Unless AutoBar is drastically restructured thats the most use we can get from PeriodicTable
function AutoBarCategoryInitialize()
--	Misc.Hearth
--	["HEARTHSTONE"] = {
--		["description"] = Misc.Hearth;
--		["texture"] = "INV_Misc_Rune_01";
--		["items"] = {
--			6948,			-- HearthStone
--		},
--	},
	AutoBarCategoryList["HEARTHSTONE"] = AutoBarItems:new(
			"Misc.Hearth", "INV_Misc_Rune_01", "Misc.Hearth")

--	["ACTION_POTIONS"] = {
--		["description"] = Consumable.Buff.Free Action; -- Consumable.Buff.Free Action
--		["texture"] = "INV_Potion_04";
--		["items"] = {
--			20008,		-- Living Action Potion
--			5634,		-- Free Action Potion
--		},
--	},
	AutoBarCategoryList["Consumable.Buff.Free Action"] = AutoBarItems:new(
			"Consumable.Buff.Free Action", "INV_Potion_04", "Consumable.Buff.Free Action")

--	AutoBarCategoryList["ANTI_VENOM"]["items"] = self:GetSetItemsArrayPT3("Consumable.Anti-Venom");
--	["ANTI_VENOM"] = {
--		["description"] = Consumable.Anti-Venom;
--		["texture"] = "INV_Drink_14";
--		["targetted"] = true;
--	},
	AutoBarCategoryList["ANTI_VENOM"] = AutoBarItems:new(
			"Consumable.Anti-Venom", "INV_Drink_14", "Consumable.Anti-Venom")
	AutoBarCategoryList["ANTI_VENOM"]:SetTargetted(true)

--	["BATTLE_STANDARD"] = {
--		["description"] = Misc.Battle Standard.Battleground; Misc.Battle Standard.Battleground
--		["texture"] = "INV_BannerPVP_01";
--		["battleground"] = true;
--		["items"] = {
--			18606,	-- Alliance Battle Standard
--			18607,	-- Horde Battle Standard
--		},
--	},
	AutoBarCategoryList["BATTLE_STANDARD"] = AutoBarItems:new(
			"Misc.Battle Standard.Battleground", "INV_BannerPVP_01", "Misc.Battle Standard.Battleground")
	AutoBarCategoryList["BATTLE_STANDARD"]:SetBattleground(true)

--	["BATTLE_STANDARD_AV"] = {
--		["description"] = Misc.Battle Standard.Alterac Valley; Misc.Battle Standard.Alterac Valley
--		["texture"] = "INV_BannerPVP_02";
--		["location"] = AUTOBAR_ALTERACVALLEY;
--		["items"] = {
--			19045,	-- Stormpike Battle Standard
--			19046,	-- Frostwolf Battle Standard
--		},
--	},
	AutoBarCategoryList["BATTLE_STANDARD_AV"] = AutoBarItems:new(
			"Misc.Battle Standard.Alterac Valley", "INV_BannerPVP_02", "Misc.Battle Standard.Alterac Valley")
	AutoBarCategoryList["BATTLE_STANDARD_AV"]:SetLocation(BZ["Alterac Valley"])

--	AutoBarCategoryList["ARROWS"]["items"] = self:GetSetItemsArrayPT3("Reagent.Ammo.Arrow");
--	["ARROWS"] = {
--		["description"] = Reagent.Ammo.Arrow;
--		["texture"] = "INV_Ammo_Arrow_02";
--		["notUsable"] = true;
--	},
	AutoBarCategoryList["ARROWS"] = AutoBarItems:new(
			"Reagent.Ammo.Arrow", "INV_Ammo_Arrow_02", "Reagent.Ammo.Arrow")
	AutoBarCategoryList["ARROWS"]:SetNotUsable(true)

--	AutoBarCategoryList["BULLETS"]["items"] = self:GetSetItemsArrayPT3("Reagent.Ammo.Bullet");
--	["BULLETS"] = {
--		["description"] = Reagent.Ammo.Bullet;
--		["texture"] = "INV_Ammo_Bullet_02";
--		["notUsable"] = true;
--	},
	AutoBarCategoryList["BULLETS"] = AutoBarItems:new(
			"Reagent.Ammo.Bullet", "INV_Ammo_Bullet_02", "Reagent.Ammo.Bullet")
	AutoBarCategoryList["BULLETS"]:SetNotUsable(true)

--	AutoBarCategoryList["THROWN"]["items"] = self:GetSetItemsArrayPT3("Reagent.Ammo.Thrown");
--	["THROWN"] = {
--		["description"] = Reagent.Ammo.Thrown;
--		["texture"] = "INV_Axe_19";
--		["notUsable"] = true;
--	},
	AutoBarCategoryList["THROWN"] = AutoBarItems:new(
			"Reagent.Ammo.Thrown", "INV_Axe_19", "Reagent.Ammo.Thrown")
	AutoBarCategoryList["THROWN"]:SetNotUsable(true)

--	AutoBarCategoryList["EXPLOSIVES"]["items"] = self:GetSetItemsArrayPT3("Misc.Engineering.Explosives");
--	["EXPLOSIVES"] = {
--		["description"] = Misc.Engineering.Explosives;
--		["texture"] = "INV_Misc_Bomb_08";
--		["targetted"] = true;
--	},
	AutoBarCategoryList["EXPLOSIVES"] = AutoBarItems:new(
			"Misc.Engineering.Explosives", "INV_Misc_Bomb_08", "Misc.Engineering.Explosives")
	AutoBarCategoryList["EXPLOSIVES"]:SetTargetted(true)

--	["Misc.Engineering.Fireworks"] = {
--		["description"] = L["Misc.Engineering.Fireworks"];
--		["texture"] = "INV_Misc_MissileSmall_Red";
--		["arrangeOnUse"] = true,
--	},
	AutoBarCategoryList["Misc.Engineering.Fireworks"] = AutoBarItems:new(
			"Misc.Engineering.Fireworks", "INV_Misc_MissileSmall_Red", "Misc.Engineering.Fireworks")
	AutoBarCategoryList["Misc.Engineering.Fireworks"]:SetArrangeOnUse(true)

--	AutoBarCategoryList["Tradeskill.Tool.Fishing.Gear"]["items"] = self:GetSetItemsArrayPT3("Tradeskill.Tool.Fishing.Gear");
--	["FISHING_GEAR"] = {
--		["texture"] = "INV_Helmet_31",
--		["description"] = L["Tradeskill.Tool.Fishing.Gear"],
--	},
	AutoBarCategoryList["Tradeskill.Tool.Fishing.Gear"] = AutoBarItems:new(
			"Tradeskill.Tool.Fishing.Gear", "INV_Helmet_31", "Tradeskill.Tool.Fishing.Gear")

--	AutoBarCategoryList["Tradeskill.Tool.Fishing.Lure"]["items"] = self:GetSetItemsArrayPT3("Tradeskill.Tool.Fishing.Lure");
--	["FISHING_LURES"] = {
--		["texture"] = "INV_Misc_Food_26",
--		["targetted"] = "WEAPON",
--		["description"] = L["Tradeskill.Tool.Fishing.Lure"],
--	},
	AutoBarCategoryList["Tradeskill.Tool.Fishing.Lure"] = AutoBarItems:new(
			"Tradeskill.Tool.Fishing.Lure", "INV_Misc_Food_26", "Tradeskill.Tool.Fishing.Lure")
	AutoBarCategoryList["Tradeskill.Tool.Fishing.Lure"]:SetTargetted("WEAPON")

--	AutoBarCategoryList["Tradeskill.Tool.Fishing.Tool"]["items"] = self:GetSetItemsArrayPT3("Tradeskill.Tool.Fishing.Tool");
--	["FISHING_POLES"] = {
--		["texture"] = "INV_Fishingpole_01",
--		["description"] = L["Tradeskill.Tool.Fishing.Tool"],
--	},
	AutoBarCategoryList["Tradeskill.Tool.Fishing.Tool"] = AutoBarItems:new(
			"Tradeskill.Tool.Fishing.Tool", "INV_Fishingpole_01", "Tradeskill.Tool.Fishing.Tool")

--	["RUNES"] = {
--		["description"] = Consumable.Recovery.Rune; Consumable.Recovery.Rune
--		["texture"] = "Spell_Shadow_SealOfKings";
--		["items"] = {
--			20520,	-- Dark Rune
--			12662,	-- Demonic Rune
--		},
--	},
	AutoBarCategoryList["RUNES"] = AutoBarItems:new(
			"Consumable.Recovery.Rune", "Spell_Shadow_SealOfKings", "Consumable.Recovery.Rune")


--	AutoBarCategoryList["BANDAGES"]["items"] = self:GetSetItemsArrayPT3("Consumable.Bandage.Basic");
--	["BANDAGES"] = {
--		["description"] = Consumable.Bandage.Basic;
--		["texture"] = "INV_Misc_Bandage_Netherweave_Heavy";
--		["targetted"] = true;
--	},
	AutoBarCategoryList["BANDAGES"] = AutoBarItems:new(
			"Consumable.Bandage.Basic", "INV_Misc_Bandage_Netherweave_Heavy", "Consumable.Bandage.Basic")
	AutoBarCategoryList["BANDAGES"]:SetTargetted(true)

--	AutoBarCategoryList["ALTERAC_BANDAGES"]["items"] = self:GetSetItemsArrayPT3("Consumable.Bandage.Battleground.Alterac Valley");
--	["ALTERAC_BANDAGES"] = {
--		["description"] = Consumable.Bandage.Battleground.Alterac Valley;
--		["texture"] = "INV_Misc_Bandage_12";
--		["targetted"] = true;
--		["location"] = AUTOBAR_ALTERACVALLEY;
--	},
	AutoBarCategoryList["ALTERAC_BANDAGES"] = AutoBarItems:new(
			"Consumable.Bandage.Battleground.Alterac Valley", "INV_Misc_Bandage_12", "Consumable.Bandage.Battleground.Alterac Valley")
	AutoBarCategoryList["ALTERAC_BANDAGES"]:SetTargetted(true)
	AutoBarCategoryList["ALTERAC_BANDAGES"]:SetLocation(BZ["Alterac Valley"])

--	AutoBarCategoryList["ARATHI_BANDAGES"]["items"] = self:GetSetItemsArrayPT3("Consumable.Bandage.Battleground.Arathi Basin");
--	["ARATHI_BANDAGES"] = {
--		["description"] = Consumable.Bandage.Battleground.Arathi Basin;
--		["texture"] = "INV_Misc_Bandage_12";
--		["targetted"] = true;
--		["location"] = AUTOBAR_ARATHIBASIN;
--	},
	AutoBarCategoryList["ARATHI_BANDAGES"] = AutoBarItems:new(
			"Consumable.Bandage.Battleground.Arathi Basin", "INV_Misc_Bandage_12", "Consumable.Bandage.Battleground.Arathi Basin")
	AutoBarCategoryList["ARATHI_BANDAGES"]:SetTargetted(true)
	AutoBarCategoryList["ARATHI_BANDAGES"]:SetLocation(BZ["Arathi Basin"])

--	AutoBarCategoryList["WARSONG_BANDAGES"]["items"] = self:GetSetItemsArrayPT3("Consumable.Bandage.Battleground.Warsong Gulch");
--	["WARSONG_BANDAGES"] = {
--		["description"] = Consumable.Bandage.Battleground.Warsong Gulch;
--		["texture"] = "INV_Misc_Bandage_12";
--		["targetted"] = true;
--		["location"] = AUTOBAR_WARSONGGULCH;
--	},
	AutoBarCategoryList["WARSONG_BANDAGES"] = AutoBarItems:new(
			"Consumable.Bandage.Battleground.Warsong Gulch", "INV_Misc_Bandage_12", "Consumable.Bandage.Battleground.Warsong Gulch")
	AutoBarCategoryList["WARSONG_BANDAGES"]:SetTargetted(true)
	AutoBarCategoryList["WARSONG_BANDAGES"]:SetLocation(BZ["Warsong Gulch"])

--	AutoBarCategoryList["FOOD"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Edible.Basic.Non-Conjured");
--	["FOOD"] = {
--		["description"] = Consumable.Food.Edible.Basic.Non-Conjured;
--		["texture"] = "INV_Misc_Food_23";
--		["nonCombat"] = true,
--	},
	AutoBarCategoryList["FOOD"] = AutoBarItems:new(
			"Consumable.Food.Edible.Basic.Non-Conjured", "INV_Misc_Food_23", "Consumable.Food.Edible.Basic.Non-Conjured")
	AutoBarCategoryList["FOOD"]:SetNonCombat(true)

--	AutoBarCategoryList["FOOD_ARATHI"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Edible.Battleground.Arathi Basin.Basic");
--	["FOOD_ARATHI"] = {
--		["description"] = Consumable.Food.Edible.Battleground.Arathi Basin.Basic;
--		["texture"] = "INV_Misc_Food_33";
--		["nonCombat"] = true,
--		["location"] = AUTOBAR_ARATHIBASIN;
--	},
	AutoBarCategoryList["FOOD_ARATHI"] = AutoBarItems:new(
			"Consumable.Food.Edible.Battleground.Arathi Basin.Basic", "INV_Misc_Food_33", "Consumable.Food.Edible.Battleground.Arathi Basin.Basic")
	AutoBarCategoryList["FOOD_ARATHI"]:SetNonCombat(true)
	AutoBarCategoryList["FOOD_ARATHI"]:SetLocation(BZ["Arathi Basin"])

--	AutoBarCategoryList["FOOD_WARSONG"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Edible.Battleground.Warsong Gulch.Basic");
--	["FOOD_WARSONG"] = {
--		["description"] = Consumable.Food.Edible.Battleground.Warsong Gulch.Basic;
--		["texture"] = "INV_Misc_Food_33";
--		["nonCombat"] = true,
--		["location"] = AUTOBAR_WARSONGGULCH;
--	},
	AutoBarCategoryList["FOOD_WARSONG"] = AutoBarItems:new(
			"Consumable.Food.Edible.Battleground.Warsong Gulch.Basic", "INV_Misc_Food_33", "Consumable.Food.Edible.Battleground.Warsong Gulch.Basic")
	AutoBarCategoryList["FOOD_WARSONG"]:SetNonCombat(true)
	AutoBarCategoryList["FOOD_WARSONG"]:SetLocation(BZ["Warsong Gulch"])

--	AutoBarCategoryList["FOOD_COMBO"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Combo Health");
--	["FOOD_COMBO"] = {
--		["description"] = Consumable.Food.Combo Health;
--		["texture"] = "INV_Misc_Food_33";
--		["nonCombat"] = true,
--	},
	AutoBarCategoryList["FOOD_COMBO"] = AutoBarItems:new(
			"Consumable.Food.Combo Health", "INV_Misc_Food_33", "Consumable.Food.Combo Health")
	AutoBarCategoryList["FOOD_COMBO"]:SetNonCombat(true)

--	AutoBarCategoryList["FOOD_CONJURED"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Edible.Bread.Conjured");
--	["FOOD_CONJURED"] = {
--		["description"] = Consumable.Food.Edible.Bread.Conjured;
--		["texture"] = "INV_Misc_Food_73CinnamonRoll";
--		["nonCombat"] = true,
--		["castList"] = {"MAGE", BS["Conjure Food"],},
--	},
	AutoBarCategoryList["FOOD_CONJURED"] = AutoBarItems:new(
			"Consumable.Food.Edible.Bread.Conjured", "INV_Misc_Food_73CinnamonRoll", "Consumable.Food.Edible.Bread.Conjured")
	AutoBarCategoryList["FOOD_CONJURED"]:SetNonCombat(true)
	AutoBarCategoryList["FOOD_CONJURED"]:SetCastList(AutoBarCategory:FilterClass({"MAGE", BS["Conjure Food"],}))

--	AutoBarCategoryList["FOOD_PERCENT"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Percent.Basic");
--	["FOOD_PERCENT"] = {
--		["description"] = Consumable.Food.Percent.Basic;
--		["texture"] = "INV_Misc_Food_60",
--	},
	AutoBarCategoryList["FOOD_PERCENT"] = AutoBarItems:new(
			"Consumable.Food.Percent.Basic", "INV_Misc_Food_60", "Consumable.Food.Percent.Basic")
	AutoBarCategoryList["FOOD_PERCENT"]:SetNonCombat(true)

--	AutoBarCategoryList["FOOD_PERCENT_BONUS"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Percent.Bonus");
--	["FOOD_PERCENT_BONUS"] = {
--		["description"] = Consumable.Food.Percent.Bonus;
--		["texture"] = "INV_Misc_Food_62",
--	},
	AutoBarCategoryList["FOOD_PERCENT_BONUS"] = AutoBarItems:new(
			"Consumable.Food.Percent.Bonus", "INV_Misc_Food_62", "Consumable.Food.Percent.Bonus")
	AutoBarCategoryList["FOOD_PERCENT_BONUS"]:SetNonCombat(true)

--	AutoBarCategoryList["FOOD_PERCENT_COMBO"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Combo Percent");
--	["FOOD_PERCENT_COMBO"] = {
--		["description"] = Consumable.Food.Combo Percent;
--		["texture"] = "INV_Food_ChristmasFruitCake_01",
--	},
	AutoBarCategoryList["FOOD_PERCENT_COMBO"] = AutoBarItems:new(
			"Consumable.Food.Combo Percent", "INV_Food_ChristmasFruitCake_01", "Consumable.Food.Combo Percent")
	AutoBarCategoryList["FOOD_PERCENT_COMBO"]:SetNonCombat(true)

--	rawList = self:RawItemsAdd(nil, "Consumable.Food.Edible.Bread.Basic", false);
--	rawList = self:RawItemsAdd(rawList, "Consumable.Food.Edible.Bread.Conjured", true);
--	AutoBarCategoryList["FOOD_PET_BREAD"]["items"] = self:RawItemsConvert(rawList);
--	["FOOD_PET_BREAD"] = {
--		["description"] = Consumable.Food.Pet.Bread;
--		["texture"] = "INV_Misc_Food_35";
--		["nonCombat"] = true,
--		["targetted"] = "PET";
--		["castSpell"] = BS["Feed Pet"];
--	},
	AutoBarCategoryList["FOOD_PET_BREAD"] = AutoBarPetFood:new(
			"Consumable.Food.Pet.Bread", "INV_Misc_Food_35", "Consumable.Food.Edible.Bread.Basic", "Consumable.Food.Edible.Bread.Conjured")
	AutoBarCategoryList["FOOD_PET_BREAD"]:SetNonCombat(true)
	AutoBarCategoryList["FOOD_PET_BREAD"]:SetTargetted("PET")

--	AutoBarCategoryList["FOOD_PET_CHEESE"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Edible.Cheese.Basic");
--	["FOOD_PET_CHEESE"] = {
--		["description"] = Consumable.Food.Pet.Cheese;
--		["texture"] = "INV_Misc_Food_37";
--		["nonCombat"] = true,
--		["targetted"] = "PET";
--		["castSpell"] = BS["Feed Pet"];
--	},
	AutoBarCategoryList["FOOD_PET_CHEESE"] = AutoBarPetFood:new(
			"Consumable.Food.Pet.Cheese", "INV_Misc_Food_37", "Consumable.Food.Edible.Cheese.Basic")
	AutoBarCategoryList["FOOD_PET_CHEESE"]:SetNonCombat(true)
	AutoBarCategoryList["FOOD_PET_CHEESE"]:SetTargetted("PET")

--	rawList = self:RawItemsAdd(nil, "Consumable.Food.Inedible.Fish", false);
--	rawList = self:RawItemsAdd(rawList, "Consumable.Food.Edible.Fish.Basic", true);
--	AutoBarCategoryList["FOOD_PET_FISH"]["items"] = self:RawItemsConvert(rawList);
--	["FOOD_PET_FISH"] = {
--		["description"] = Consumable.Food.Pet.Fish;
--		["texture"] = "INV_Misc_Fish_22";
--		["nonCombat"] = true,
--		["targetted"] = "PET";
--		["castSpell"] = BS["Feed Pet"];
--	},
	AutoBarCategoryList["FOOD_PET_FISH"] = AutoBarPetFood:new(
			"Consumable.Food.Pet.Fish", "INV_Misc_Fish_22", "Consumable.Food.Inedible.Fish", "Consumable.Food.Edible.Fish.Basic")
	AutoBarCategoryList["FOOD_PET_FISH"]:SetNonCombat(true)
	AutoBarCategoryList["FOOD_PET_FISH"]:SetTargetted("PET")

--	AutoBarCategoryList["FOOD_PET_FRUIT"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Edible.Fruit.Basic");
--	["FOOD_PET_FRUIT"] = {
--		["description"] = Consumable.Food.Pet.Fruit;
--		["texture"] = "INV_Misc_Food_19";
--		["nonCombat"] = true,
--		["targetted"] = "PET";
--		["castSpell"] = BS["Feed Pet"];
--	},
	AutoBarCategoryList["FOOD_PET_FRUIT"] = AutoBarPetFood:new(
			"Consumable.Food.Pet.Fruit", "INV_Misc_Food_19", "Consumable.Food.Edible.Fruit.Basic")
	AutoBarCategoryList["FOOD_PET_FRUIT"]:SetNonCombat(true)
	AutoBarCategoryList["FOOD_PET_FRUIT"]:SetTargetted("PET")

--	AutoBarCategoryList["FOOD_PET_FUNGUS"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Edible.Fungus.Basic");	-- Now includes senjin combo ;-(
--	["FOOD_PET_FUNGUS"] = {
--		["description"] = Consumable.Food.Pet.Fungus;
--		["texture"] = "INV_Mushroom_05";
--		["nonCombat"] = true,
--		["targetted"] = "PET";
--		["castSpell"] = BS["Feed Pet"];
--	},
	AutoBarCategoryList["FOOD_PET_FUNGUS"] = AutoBarPetFood:new(
			"Consumable.Food.Pet.Fungus", "INV_Mushroom_05", "Consumable.Food.Edible.Fungus.Basic")
	AutoBarCategoryList["FOOD_PET_FUNGUS"]:SetNonCombat(true)
	AutoBarCategoryList["FOOD_PET_FUNGUS"]:SetTargetted("PET")

--	rawList = self:RawItemsAdd(nil, "Consumable.Food.Inedible.Meat", false);
--	rawList = self:RawItemsAdd(rawList, "Consumable.Food.Edible.Meat.Basic", true);
--	AutoBarCategoryList["FOOD_PET_MEAT"]["items"] = self:RawItemsConvert(rawList);
--	["FOOD_PET_MEAT"] = {
--		["description"] = Consumable.Food.Pet.Meat;
--		["texture"] = "INV_Misc_Food_14";
--		["nonCombat"] = true,
--		["targetted"] = "PET";
--		["castSpell"] = BS["Feed Pet"];
--	},
	AutoBarCategoryList["FOOD_PET_MEAT"] = AutoBarPetFood:new(
			"Consumable.Food.Pet.Meat", "INV_Misc_Food_14", "Consumable.Food.Inedible.Meat", "Consumable.Food.Edible.Meat.Basic")
	AutoBarCategoryList["FOOD_PET_MEAT"]:SetNonCombat(true)
	AutoBarCategoryList["FOOD_PET_MEAT"]:SetTargetted("PET")

--	AutoBarCategoryList["FOOD_BUFF"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Bonus");
--	["FOOD_BUFF"] = {
--		["description"] = L["Consumable.Food.Bonus"];
--		["texture"] = "INV_Misc_Food_47";
--		["nonCombat"] = true,
--	},
	AutoBarCategoryList["Consumable.Food.Bonus"] = AutoBarItems:new(
			"Consumable.Food.Bonus", "INV_Misc_Food_47", "Consumable.Food.Bonus")
	AutoBarCategoryList["Consumable.Food.Bonus"]:SetNonCombat(true)

--	AutoBarCategoryList["FOOD_AGILITY"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Buff.Agility");
--	["FOOD_AGILITY"] = {
--		["description"] = L["FOOD_AGILITY"];
--		["texture"] = "INV_Misc_Fish_13";
--		["nonCombat"] = true,
--	},
	AutoBarCategoryList["FOOD_AGILITY"] = AutoBarItems:new(
			"Consumable.Food.Buff.Agility", "INV_Misc_Fish_13", "Consumable.Food.Buff.Agility")
	AutoBarCategoryList["FOOD_AGILITY"]:SetNonCombat(true)

--	AutoBarCategoryList["FOOD_ATTACK_POWER"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Buff.Attack Power");
--	["FOOD_ATTACK_POWER"] = {
--		["description"] = L["FOOD_ATTACK_POWER"];
--		["texture"] = "INV_Misc_Fish_13";
--		["nonCombat"] = true,
--	},
	AutoBarCategoryList["FOOD_ATTACK_POWER"] = AutoBarItems:new(
			"Consumable.Food.Buff.Attack Power", "INV_Misc_Fish_13", "Consumable.Food.Buff.Attack Power")
	AutoBarCategoryList["FOOD_ATTACK_POWER"]:SetNonCombat(true)

--	AutoBarCategoryList["FOOD_HEALING"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Buff.Healing");
--	["FOOD_HEALING"] = {
--		["description"] = L["FOOD_HEALING"];
--		["texture"] = "INV_Misc_Fish_13";
--		["nonCombat"] = true,
--	},
	AutoBarCategoryList["FOOD_HEALING"] = AutoBarItems:new(
			"Consumable.Food.Buff.Healing", "INV_Misc_Fish_13", "Consumable.Food.Buff.Healing")
	AutoBarCategoryList["FOOD_HEALING"]:SetNonCombat(true)

--	AutoBarCategoryList["FOOD_HPREGEN"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Buff.HP Regen");
--	["FOOD_HPREGEN"] = {
--		["description"] = L["FOOD_HPREGEN"];
--		["texture"] = "INV_Misc_Fish_19";
--		["nonCombat"] = true,
--	},
	AutoBarCategoryList["FOOD_HPREGEN"] = AutoBarItems:new(
			"Consumable.Food.Buff.HP Regen", "INV_Misc_Fish_19", "Consumable.Food.Buff.HP Regen")
	AutoBarCategoryList["FOOD_HPREGEN"]:SetNonCombat(true)

--	AutoBarCategoryList["FOOD_INTELLECT"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Buff.Intellect");
--	["FOOD_INTELLECT"] = {
--		["description"] = L["FOOD_INTELLECT"];
--		["texture"] = "INV_Misc_Food_63";
--		["nonCombat"] = true,
--	},
	AutoBarCategoryList["FOOD_INTELLECT"] = AutoBarItems:new(
			"Consumable.Food.Buff.Intellect", "INV_Misc_Food_63", "Consumable.Food.Buff.Intellect")
	AutoBarCategoryList["FOOD_INTELLECT"]:SetNonCombat(true)

--	AutoBarCategoryList["FOOD_MANAREGEN"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Buff.Mana Regen");
--	["FOOD_MANAREGEN"] = {
--		["description"] = L["FOOD_MANAREGEN"];
--		["texture"] = "INV_Drink_17";
--		["nonCombat"] = true,
--	},
	AutoBarCategoryList["FOOD_MANAREGEN"] = AutoBarItems:new(
			"Consumable.Food.Buff.Mana Regen", "INV_Drink_17", "Consumable.Food.Buff.Mana Regen")
	AutoBarCategoryList["FOOD_MANAREGEN"]:SetNonCombat(true)

--	AutoBarCategoryList["FOOD_SPELL_DAMAGE"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Buff.Spell Damage");
--	["FOOD_SPELL_DAMAGE"] = {
--		["description"] = L["FOOD_SPELL_DAMAGE"];
--		["texture"] = "INV_Misc_Food_65";
--		["nonCombat"] = true,
--	},
	AutoBarCategoryList["FOOD_SPELL_DAMAGE"] = AutoBarItems:new(
			"Consumable.Food.Buff.Spell Damage", "INV_Misc_Food_65", "Consumable.Food.Buff.Spell Damage")
	AutoBarCategoryList["FOOD_SPELL_DAMAGE"]:SetNonCombat(true)

--	AutoBarCategoryList["FOOD_SPIRIT"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Buff.Spirit");
--	["FOOD_SPIRIT"] = {
--		["description"] = L["FOOD_SPIRIT"];
--		["texture"] = "INV_Misc_Fish_03";
--		["nonCombat"] = true,
--	},
	AutoBarCategoryList["FOOD_SPIRIT"] = AutoBarItems:new(
			"Consumable.Food.Buff.Spirit", "INV_Misc_Fish_03", "Consumable.Food.Buff.Spirit")
	AutoBarCategoryList["FOOD_SPIRIT"]:SetNonCombat(true)

--	AutoBarCategoryList["FOOD_STAMINA"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Buff.Stamina");
--	["FOOD_STAMINA"] = {
--		["description"] = L["FOOD_STAMINA"];
--		["texture"] = "INV_Misc_Food_65";
--		["nonCombat"] = true,
--	},
	AutoBarCategoryList["FOOD_STAMINA"] = AutoBarItems:new(
			"Consumable.Food.Buff.Stamina", "INV_Misc_Food_65", "Consumable.Food.Buff.Stamina")
	AutoBarCategoryList["FOOD_STAMINA"]:SetNonCombat(true)

--	AutoBarCategoryList["Consumable.Food.Buff.Strength"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Buff.Strength");
--	["Consumable.Food.Buff.Strength"] = {
--		["description"] = L["Consumable.Food.Buff.Strength"];
--		["texture"] = "INV_Misc_Food_41";
--		["nonCombat"] = true,
--	},
	AutoBarCategoryList["Consumable.Food.Buff.Strength"] = AutoBarItems:new(
			"Consumable.Food.Buff.Strength", "INV_Misc_Food_41", "Consumable.Food.Buff.Strength")
	AutoBarCategoryList["Consumable.Food.Buff.Strength"]:SetNonCombat(true)

--
--	AutoBarCategoryList["Consumable.Food.Buff.Other"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Buff.Other");
--	["Consumable.Food.Buff.Other"] = {
--		["description"] = L["Consumable.Food.Buff.Other"];
--		["texture"] = "INV_Drink_17";
--		["nonCombat"] = true,
--	},
	AutoBarCategoryList["Consumable.Food.Buff.Other"] = AutoBarItems:new(
			"Consumable.Food.Buff.Other", "INV_Drink_17", "Consumable.Food.Buff.Other")
	AutoBarCategoryList["Consumable.Food.Buff.Other"]:SetNonCombat(true)


	AutoBarCategoryList["HEALPOTIONS"] = AutoBarItems:new(
			"Consumable.Potion.Recovery.Healing.Basic", "INV_Potion_54", "Consumable.Potion.Recovery.Healing.Basic")

	AutoBarCategoryList["HEALPOTIONS_BG"] = AutoBarItems:new(
			"Consumable.Potion.Recovery.Healing.PvP", "INV_Potion_39", "Consumable.Potion.Recovery.Healing.PvP")
	AutoBarCategoryList["HEALPOTIONS_BG"]:SetBattleground(true)

	AutoBarCategoryList["Consumable.Potion.Recovery.Healing.Blades Edge"] = AutoBarItems:new(
			"Consumable.Potion.Recovery.Healing.Blades Edge", "INV_Potion_167", "Consumable.Potion.Recovery.Healing.Blades Edge")
	AutoBarCategoryList["Consumable.Potion.Recovery.Healing.Blades Edge"]:SetLocation(BZ["Blade's Edge Mountains"])

	AutoBarCategoryList["Consumable.Potion.Recovery.Healing.Coilfang"] = AutoBarItems:new(
			"Consumable.Potion.Recovery.Healing.Coilfang", "INV_Potion_167", "Consumable.Potion.Recovery.Healing.Coilfang")
	AutoBarCategoryList["Consumable.Potion.Recovery.Healing.Coilfang"]:SetLocation("Coilfang")

	AutoBarCategoryList["Consumable.Potion.Recovery.Healing.Tempest Keep"] = AutoBarItems:new(
			"Consumable.Potion.Recovery.Healing.Tempest Keep", "INV_Potion_153", "Consumable.Potion.Recovery.Healing.Tempest Keep")
	AutoBarCategoryList["Consumable.Potion.Recovery.Healing.Tempest Keep"]:SetLocation("Tempest Keep")

	AutoBarCategoryList["MANAPOTIONS"] = AutoBarItems:new(
			"Consumable.Potion.Recovery.Mana.Basic", "INV_Potion_76", "Consumable.Potion.Recovery.Mana.Basic")

	AutoBarCategoryList["MANAPOTIONS_BG"] = AutoBarItems:new(
			"Consumable.Potion.Recovery.Mana.Pvp", "INV_Potion_81", "Consumable.Potion.Recovery.Mana.Pvp")
	AutoBarCategoryList["MANAPOTIONS_BG"]:SetBattleground(true)

	AutoBarCategoryList["Consumable.Potion.Recovery.Mana.Blades Edge"] = AutoBarItems:new(
			"Consumable.Potion.Recovery.Mana.Blades Edge", "INV_Potion_168", "Consumable.Potion.Recovery.Mana.Blades Edge")
	AutoBarCategoryList["Consumable.Potion.Recovery.Mana.Blades Edge"]:SetLocation(BZ["Blade's Edge Mountains"])

	AutoBarCategoryList["Consumable.Potion.Recovery.Mana.Coilfang"] = AutoBarItems:new(
			"Consumable.Potion.Recovery.Mana.Coilfang", "INV_Potion_168", "Consumable.Potion.Recovery.Mana.Coilfang")
	AutoBarCategoryList["Consumable.Potion.Recovery.Mana.Coilfang"]:SetLocation("Coilfang")

	AutoBarCategoryList["Consumable.Potion.Recovery.Mana.Tempest Keep"] = AutoBarItems:new(
			"Consumable.Potion.Recovery.Mana.Tempest Keep", "INV_Potion_156", "Consumable.Potion.Recovery.Mana.Tempest Keep")
	AutoBarCategoryList["Consumable.Potion.Recovery.Mana.Tempest Keep"]:SetLocation("Tempest Keep")

--	AutoBarCategoryList["HEALTHSTONE"]["items"] = self:GetSetItemsArrayPT3("Consumable.Warlock.Healthstone");
--	["HEALTHSTONE"] = {
--		["description"] = Consumable.Warlock.Healthstone;
--		["texture"] = "INV_Stone_04";
--	},
	AutoBarCategoryList["HEALTHSTONE"] = AutoBarItems:new(
			"Consumable.Warlock.Healthstone", "INV_Stone_04", "Consumable.Warlock.Healthstone")

--	AutoBarCategoryList["MINI_PET"]["items"] = self:GetSetItemsArrayPT3("Misc.Minipet.Normal");
--	["MINI_PET"] = {
--		["description"] = Misc.Minipet.Normal;
--		["texture"] = "Ability_Creature_Poison_05";
--		["arrangeOnUse"] = true,
--	},
	AutoBarCategoryList["MINI_PET"] = AutoBarItems:new(
			"Misc.Minipet.Normal", "Ability_Creature_Poison_05", "Misc.Minipet.Normal")
	AutoBarCategoryList["MINI_PET"]:SetArrangeOnUse(true)

--	AutoBarCategoryList["MINI_PET_HOLIDAY"]["items"] = self:GetSetItemsArrayPT3("Misc.Minipet.Snowball");
--	["MINI_PET_HOLIDAY"] = {
--		["description"] = Misc.Minipet.Snowball;
--		["texture"] = "INV_Misc_Bag_17";
--		["arrangeOnUse"] = true,
--	},
	AutoBarCategoryList["MINI_PET_HOLIDAY"] = AutoBarItems:new(
			"Misc.Minipet.Snowball", "INV_Misc_Bag_17", "Misc.Minipet.Snowball")
	AutoBarCategoryList["MINI_PET_HOLIDAY"]:SetArrangeOnUse(true)

--	AutoBarCategoryList["MOUNTS"]["items"] = self:GetSetItemsArrayPT3("Misc.Mount.Normal");
--	["MOUNTS"] = {
--		["description"] = Misc.Mount.Normal;
--		["texture"] = "Ability_Mount_JungleTiger";
--		["nonCombat"] = true,
--		["arrangeOnUse"] = true,
--	},
	AutoBarCategoryList["MOUNTS"] = AutoBarItems:new(
			"Misc.Mount.Normal", "Ability_Mount_JungleTiger", "Misc.Mount.Normal")
	AutoBarCategoryList["MOUNTS"]:SetNonCombat(true)
	AutoBarCategoryList["MOUNTS"]:SetArrangeOnUse(true)

--	AutoBarCategoryList["MOUNTS_QIRAJI"]["items"] = self:GetSetItemsArrayPT3("Misc.Mount.Ahn'Qiraj");
--	["MOUNTS_QIRAJI"] = {
--		["description"] = Misc.Mount.Ahn'Qiraj;
--		["texture"] = "INV_Misc_QirajiCrystal_05";
--		["nonCombat"] = true,
--		["arrangeOnUse"] = true,
--		["location"] = AUTOBAR_AHN_QIRAJ;
--	},
	AutoBarCategoryList["MOUNTS_QIRAJI"] = AutoBarItems:new(
			"Misc.Mount.Ahn'Qiraj", "INV_Misc_QirajiCrystal_05", "Misc.Mount.Ahn'Qiraj")
	AutoBarCategoryList["MOUNTS_QIRAJI"]:SetNonCombat(true)
	AutoBarCategoryList["MOUNTS_QIRAJI"]:SetArrangeOnUse(true)
	AutoBarCategoryList["MOUNTS_QIRAJI"]:SetLocation(BZ["Ahn'Qiraj"])

--	AutoBarCategoryList["MOUNTS_FLYING"]["items"] = self:GetSetItemsArrayPT3("Misc.Mount.Flying");
--	["MOUNTS_FLYING"] = {
--		["description"] = Misc.Mount.Flying;
--		["texture"] = "Ability_Mount_Wyvern_01";
--		["nonCombat"] = true,
--		["arrangeOnUse"] = true,
----		["location"] = AUTOBAR_OUTLAND;  TODO: can fly check
--	},
	AutoBarCategoryList["MOUNTS_FLYING"] = AutoBarItems:new(
			"Misc.Mount.Flying", "Ability_Mount_Wyvern_01", "Misc.Mount.Flying")
	AutoBarCategoryList["MOUNTS_FLYING"]:SetNonCombat(true)
	AutoBarCategoryList["MOUNTS_FLYING"]:SetArrangeOnUse(true)

--	AutoBarCategoryList["REJUVENATION_POTIONS"]["limit"] = { ["downhp"] = {}, ["downmana"] = {},  }
--	AutoBarCategoryList["REJUVENATION_POTIONS"]["items"] = self:GetSetItemsArrayPT3("Consumable.Potion.Recovery.Rejuvenation",
--			AutoBarCategoryList["REJUVENATION_POTIONS"]["limit"]["downhp"],
--			AutoBarCategoryList["REJUVENATION_POTIONS"]["limit"]["downmana"],
--			1.1);
--	["REJUVENATION_POTIONS"] = {
--		["description"] = Consumable.Potion.Recovery.Rejuvenation;
--		["texture"] = "INV_Potion_47";
--	},
	AutoBarCategoryList["REJUVENATION_POTIONS"] = AutoBarItems:new(
			"Consumable.Potion.Recovery.Rejuvenation", "INV_Potion_47", "Consumable.Potion.Recovery.Rejuvenation")

--	AutoBarCategoryList["STONE_STATUES"]["items"] = self:GetSetItemsArrayPT3("Consumable.Jeweler.Statue");
--	["STONE_STATUES"] = {
--		["description"] = Consumable.Jeweler.Statue;
--		["texture"] = "INV_Misc_Statue_10";
--	},
	AutoBarCategoryList["STONE_STATUES"] = AutoBarItems:new(
			"Consumable.Jeweler.Statue", "INV_Misc_Statue_10", "Consumable.Jeweler.Statue")

--	AutoBarCategoryList["DREAMLESS_SLEEP"]["items"] = self:GetSetItemsArrayPT3("Consumable.Potion.Recovery.Dreamless Sleep");
--	["DREAMLESS_SLEEP"] = {
--		["description"] = Consumable.Potion.Recovery.Dreamless Sleep;
--		["texture"] = "INV_Potion_83";
--	},
	AutoBarCategoryList["DREAMLESS_SLEEP"] = AutoBarItems:new(
			"Consumable.Potion.Recovery.Dreamless Sleep", "INV_Potion_83", "Consumable.Potion.Recovery.Dreamless Sleep")

--	AutoBarCategoryList["MANASTONE"]["items"] = self:GetSetItemsArrayPT3("Consumable.Mage.Mana Stone");
--	["MANASTONE"] = {
--		["description"] = Consumable.Mage.Mana Stone;
--		["texture"] = "INV_Misc_Gem_Emerald_01";
--	},
	AutoBarCategoryList["MANASTONE"] = AutoBarItems:new(
			"Consumable.Mage.Mana Stone", "INV_Misc_Gem_Emerald_01", "Consumable.Mage.Mana Stone")

--	AutoBarCategoryList["RAGEPOTIONS"]["items"] = self:GetSetItemsArrayPT3("Consumable.Buff.Rage.Self");
--	["RAGEPOTIONS"] = {
--		["description"] = Consumable.Buff.Rage.Self;
--		["texture"] = "INV_Potion_24";
--	},
	AutoBarCategoryList["RAGEPOTIONS"] = AutoBarItems:new(
			"Consumable.Buff.Rage.Self", "INV_Potion_24", "Consumable.Buff.Rage.Self")

--	["ENERGYPOTIONS"] = {
--		["description"] = Consumable.Buff.Energy.Self;
--		["texture"] = "INV_Drink_Milk_05";
--		["items"] = { 7676 },
--	},
	AutoBarCategoryList["ENERGYPOTIONS"] = AutoBarItems:new(
			"Consumable.Buff.Energy.Self", "INV_Drink_Milk_05", "Consumable.Buff.Energy.Self")

--	["BOOZE"] = {
--		["description"] = Misc.Booze;
--		["texture"] = "INV_Drink_03";
--		["nonCombat"] = true,
--	},
	AutoBarCategoryList["BOOZE"] = AutoBarItems:new(
			"Misc.Booze", "INV_Drink_03", "Misc.Booze")
	AutoBarCategoryList["BOOZE"]:SetNonCombat(true)

--	rawList = self:RawItemsAdd(nil, "Consumable.Water.Basic", false);
--	rawList = self:RawItemsAdd(rawList, "Consumable.Water.Conjured", true);
--	AutoBarCategoryList["WATER"]["items"] = self:RawItemsConvert(rawList);
--	["WATER"] = {
--		["description"] = Consumable.Water.Basic;
--		["texture"] = "INV_Drink_10";
--		["nonCombat"] = true,
--		["castList"] = {"MAGE", BS["Conjure Water"],},
--	},
	AutoBarCategoryList["WATER"] = AutoBarItems:new(
			"Consumable.Water.Basic", "INV_Drink_10", "Consumable.Water.Basic", "Consumable.Water.Conjured")
	AutoBarCategoryList["WATER"]:SetNonCombat(true)
	AutoBarCategoryList["WATER"]:SetCastList(AutoBarCategory:FilterClass({"MAGE", BS["Conjure Water"],}))

--	["WATER_PERCENT"] = {
--		["description"] = Consumable.Water.Percentage; Consumable.Water.Percentage
--		["texture"] = "INV_Drink_04";
--		["nonCombat"] = true,
--	},
	AutoBarCategoryList["WATER_PERCENT"] = AutoBarItems:new(
			"Consumable.Water.Percentage", "INV_Drink_04", "Consumable.Water.Percentage")
	AutoBarCategoryList["WATER_PERCENT"]:SetNonCombat(true)

--	AutoBarCategoryList["WATER_SPIRIT"]["items"] = self:GetSetItemsArrayPT3("Consumable.Water.Buff.Spirit");
--	["WATER_SPIRIT"] = {
--		["description"] = Consumable.Water.Buff.Spirit;
--		["texture"] = "INV_Drink_16";
--		["nonCombat"] = true,
--	},
	AutoBarCategoryList["WATER_SPIRIT"] = AutoBarItems:new(
			"Consumable.Water.Buff.Spirit", "INV_Drink_16", "Consumable.Water.Buff.Spirit")
	AutoBarCategoryList["WATER_SPIRIT"]:SetNonCombat(true)


	AutoBarCategoryList["OIL_MANA"] = AutoBarItems:new("Consumable.Weapon Buff.Oil.Mana", "INV_Potion_100",
			"Consumable.Weapon Buff.Oil.Mana")
	AutoBarCategoryList["OIL_MANA"]:SetTargetted("WEAPON")

	AutoBarCategoryList["OIL_WIZARD"] = AutoBarItems:new("Consumable.Weapon Buff.Oil.Wizard", "INV_Potion_105",
			"Consumable.Weapon Buff.Oil.Wizard")
	AutoBarCategoryList["OIL_WIZARD"]:SetTargetted("WEAPON")

	AutoBarCategoryList["POISON-CRIPPLING"] = AutoBarItems:new("Consumable.Weapon Buff.Poison.Crippling", "INV_Potion_19",
			"Consumable.Weapon Buff.Poison.Crippling")
	AutoBarCategoryList["POISON-CRIPPLING"]:SetTargetted("WEAPON")

	AutoBarCategoryList["POISON-DEADLY"] = AutoBarItems:new("Consumable.Weapon Buff.Poison.Deadly", "Ability_Rogue_DualWeild",
			"Consumable.Weapon Buff.Poison.Deadly")
	AutoBarCategoryList["POISON-DEADLY"]:SetTargetted("WEAPON")

	AutoBarCategoryList["POISON-INSTANT"] = AutoBarItems:new("Consumable.Weapon Buff.Poison.Instant", "Ability_Poisons",
			"Consumable.Weapon Buff.Poison.Instant", "Consumable.Weapon Buff.Poison.Anesthetic")
	AutoBarCategoryList["POISON-INSTANT"]:SetTargetted("WEAPON")

	AutoBarCategoryList["POISON-MINDNUMBING"] = AutoBarItems:new("Consumable.Weapon Buff.Poison.Mind Numbing", "Spell_Nature_NullifyDisease",
			"Consumable.Weapon Buff.Poison.Mind Numbing")
	AutoBarCategoryList["POISON-MINDNUMBING"]:SetTargetted("WEAPON")

	AutoBarCategoryList["POISON-WOUND"] = AutoBarItems:new("Consumable.Weapon Buff.Poison.Wound", "Ability_PoisonSting",
			"Consumable.Weapon Buff.Poison.Wound")
	AutoBarCategoryList["POISON-WOUND"]:SetTargetted("WEAPON")

	AutoBarCategoryList["SHARPENINGSTONES"] = AutoBarItems:new("Consumable.Weapon Buff.Stone.Sharpening Stone", "INV_Stone_SharpeningStone_01",
			"Consumable.Weapon Buff.Stone.Sharpening Stone")
	AutoBarCategoryList["SHARPENINGSTONES"]:SetTargetted("WEAPON")

	AutoBarCategoryList["WEIGHTSTONES"] = AutoBarItems:new("Consumable.Weapon Buff.Stone.Weight Stone", "INV_Stone_WeightStone_02",
			"Consumable.Weapon Buff.Stone.Weight Stone")
	AutoBarCategoryList["WEIGHTSTONES"]:SetTargetted("WEAPON")


	AutoBarCategoryList["BUFF_GENERAL"] = AutoBarItems:new("Consumable.Buff Group.General.Self", "INV_Potion_80",
			"Consumable.Buff Group.General.Self")

	AutoBarCategoryList["BUFF_GENERAL_TARGET"] = AutoBarItems:new("Consumable.Buff Group.General.Target", "INV_Potion_80",
			"Consumable.Buff Group.General.Target")
	AutoBarCategoryList["BUFF_GENERAL_TARGET"]:SetTargetted(true)

	AutoBarCategoryList["BUFF_CASTER"] = AutoBarItems:new("Consumable.Buff Group.Caster.Self", "INV_Potion_66",
			"Consumable.Buff Group.Caster.Self")

	AutoBarCategoryList["BUFF_CASTER_TARGET"] = AutoBarItems:new("Consumable.Buff Group.Caster.Target", "INV_Potion_66",
			"Consumable.Buff Group.Caster.Target")
	AutoBarCategoryList["BUFF_CASTER_TARGET"]:SetTargetted(true)

	AutoBarCategoryList["BUFF_MELEE"] = AutoBarItems:new("Consumable.Buff Group.Melee.Self", "INV_Potion_43",
			"Consumable.Buff Group.Melee.Self")

	AutoBarCategoryList["BUFF_MELEE_TARGET"] = AutoBarItems:new("Consumable.Buff Group.Melee.Target", "INV_Potion_43",
			"Consumable.Buff Group.Melee.Target")
	AutoBarCategoryList["BUFF_MELEE_TARGET"]:SetTargetted(true)

	AutoBarCategoryList["BUFF_OTHER"] = AutoBarItems:new("Consumable.Buff.Other.Self", "INV_Potion_80",
			"Consumable.Buff.Other.Self")

	AutoBarCategoryList["BUFF_OTHER_TARGET"] = AutoBarItems:new("Consumable.Buff.Other.Target", "INV_Potion_80",
			"Consumable.Buff.Other.Target")
	AutoBarCategoryList["BUFF_OTHER_TARGET"]:SetTargetted(true)


	AutoBarCategoryList["BUFF_CHEST"] = AutoBarItems:new("Consumable.Buff.Chest", "INV_Misc_Rune_10",
			"Consumable.Buff.Chest")
	AutoBarCategoryList["BUFF_CHEST"]:SetTargetted("CHEST")

	AutoBarCategoryList["BUFF_SHIELD"] = AutoBarItems:new("Consumable.Buff.Shield", "INV_Misc_Rune_13",
			"Consumable.Buff.Shield")
	AutoBarCategoryList["BUFF_SHIELD"]:SetTargetted("SHIELD")

	AutoBarCategoryList["BUFF_WEAPON"] = AutoBarItems:new("Consumable.Weapon Buff", "INV_Misc_Rune_13",
			"Consumable.Weapon Buff")
	AutoBarCategoryList["BUFF_WEAPON"]:SetTargetted("WEAPON")
	AutoBarCategoryList["BUFF_WEAPON"]:SetArrangeOnUse(true)

	AutoBarCategoryList["BUFF_HEALTH"] = AutoBarItems:new("Consumable.Buff.Health", "INV_Potion_43",
			"Consumable.Buff.Health")

	AutoBarCategoryList["BUFF_ARMOR"] = AutoBarItems:new("Consumable.Buff.Armor", "INV_Potion_66",
			"Consumable.Buff.Armor")

	AutoBarCategoryList["BUFF_REGENHEALTH"] = AutoBarItems:new("Consumable.Buff.Regen Health", "INV_Potion_80",
			"Consumable.Buff.Regen Health")

	AutoBarCategoryList["BUFF_AGILITY"] = AutoBarItems:new("Consumable.Buff.Agility", "INV_Scroll_02",
			"Consumable.Buff.Agility")
	AutoBarCategoryList["BUFF_AGILITY"]:SetTargetted(true)

	AutoBarCategoryList["BUFF_INTELLECT"] = AutoBarItems:new("Consumable.Buff.Intellect", "INV_Scroll_01",
			"Consumable.Buff.Intellect")
	AutoBarCategoryList["BUFF_INTELLECT"]:SetTargetted(true)

--	AutoBarCategoryList["BUFF_PROTECTION"] = AutoBarItems:new("Consumable.Buff.Protection", "INV_Scroll_07",
--			"Consumable.Buff.Protection")
--	AutoBarCategoryList["BUFF_PROTECTION"]:SetTargetted(true)

	AutoBarCategoryList["BUFF_SPIRIT"] = AutoBarItems:new("Consumable.Buff.Spirit", "INV_Scroll_01",
			"Consumable.Buff.Spirit")
	AutoBarCategoryList["BUFF_SPIRIT"]:SetTargetted(true)

	AutoBarCategoryList["BUFF_STAMINA"] = AutoBarItems:new("Consumable.Buff.Stamina", "INV_Scroll_07",
			"Consumable.Buff.Stamina")
	AutoBarCategoryList["BUFF_STAMINA"]:SetTargetted(true)

	AutoBarCategoryList["BUFF_STRENGTH"] = AutoBarItems:new("Consumable.Buff.Strength", "INV_Scroll_02",
			"Consumable.Buff.Strength")
	AutoBarCategoryList["BUFF_STRENGTH"]:SetTargetted(true)

	AutoBarCategoryList["BUFF_ATTACKPOWER"] = AutoBarItems:new("Consumable.Buff.Attack Power", "INV_Misc_MonsterScales_07",
			"Consumable.Buff.Attack Power")
	AutoBarCategoryList["BUFF_ATTACKPOWER"]:SetTargetted(true)

	AutoBarCategoryList["BUFF_ATTACKSPEED"] = AutoBarItems:new("Consumable.Buff.Attack Speed", "INV_Misc_MonsterScales_17",
			"Consumable.Buff.Attack Speed")
	AutoBarCategoryList["BUFF_ATTACKSPEED"]:SetTargetted(true)

	AutoBarCategoryList["BUFF_DODGE"] = AutoBarItems:new("Consumable.Buff.Dodge", "INV_Misc_MonsterScales_17",
			"Consumable.Buff.Dodge")
	AutoBarCategoryList["BUFF_DODGE"]:SetTargetted(true)

	AutoBarCategoryList["BUFF_RESISTANCE"] = AutoBarItems:new("Consumable.Buff.Resistance", "INV_Misc_MonsterScales_15",
			"Consumable.Buff.Resistance.Self")

	AutoBarCategoryList["BUFF_RESISTANCE_TARGET"] = AutoBarItems:new("Consumable.Buff.Resistance", "INV_Misc_MonsterScales_15",
			"Consumable.Buff.Resistance.Target")
	AutoBarCategoryList["BUFF_RESISTANCE_TARGET"]:SetTargetted(true)

--	["Consumable.Buff.Speed"] = {
--		["description"] = Consumable.Buff.Speed;
--		["texture"] = "INV_Potion_95";
--		["items"] = { 20081, 2459, },
--	},
	AutoBarCategoryList["Consumable.Buff.Speed"] = AutoBarItems:new("Consumable.Buff.Speed", "INV_Potion_95",
			"Consumable.Buff.Speed")

	AutoBarCategoryList["QUEST_ITEMS"] = AutoBarItems:new("Consumable.Quest.Usable", "INV_BannerPVP_02",
			"Consumable.Quest.Usable")
	AutoBarCategoryList["QUEST_ITEMS"]:SetArrangeOnUse(true)



--	["AAACLEAR"] = {
--		["description"] = L["AUTOBAR_CLASS_CLEAR"];
--		["texture"] = "INV_Misc_Fork&Knife";
--		["items"] = {},
--	},
	AutoBarCategoryList[""] = AutoBarItems:new(
			"AUTOBAR_CLASS_CLEAR", "INV_Misc_Fork&Knife", nil)

--	["HEALTHSTONE_CONJURE"] = {
--		["description"] = L["Consumable.Warlock.Create Healthstone"],
--		["texture"] = BS:GetShortSpellIcon("Create Healthstone"),
--		["spell"] = true,
--		["castList"] = {"WARLOCK", BS["Create Healthstone"]};
--	},
	AutoBarCategoryList["HEALTHSTONE_CONJURE"] = AutoBarSpells:new(
			"Consumable.Warlock.Create Healthstone", BS:GetShortSpellIcon("Create Healthstone"), {
			"WARLOCK", BS["Create Healthstone"]
			})

--	["MANASTONE_CONJURE"] = {
--		["description"] = L["Consumable.Mage.Conjure Mana Stone"];
--		["texture"] = "INV_Misc_Gem_Emerald_01";
--	},
	AutoBarCategoryList["MANASTONE_CONJURE"] = AutoBarSpells:new(
			"Consumable.Mage.Conjure Mana Stone", "INV_Misc_Gem_Emerald_01", {
			"MAGE", BS["Conjure Mana Agate"],
			"MAGE", BS["Conjure Mana Jade"],
			"MAGE", BS["Conjure Mana Citrine"],
			"MAGE", BS["Conjure Mana Ruby"],
			"MAGE", BS["Conjure Mana Emerald"],
			})

--	["PORTALS"] = {
--		["description"] = L["AUTOBAR_CLASS_PORTALS"];
--		["texture"] = "Spell_Arcane_PortalShattrath";
--		["spell"] = true,
--	},
	AutoBarCategoryList["PORTALS"] = AutoBarSpells:new(
			"AUTOBAR_CLASS_PORTALS", "Spell_Arcane_PortalShattrath", {
			"MAGE", BS["Teleport: Undercity"],
			"MAGE", BS["Teleport: Thunder Bluff"],
			"MAGE", BS["Teleport: Stormwind"],
			"MAGE", BS["Teleport: Silvermoon"],
			"MAGE", BS["Teleport: Exodar"],
			"MAGE", BS["Teleport: Darnassus"],
			"MAGE", BS["Teleport: Ironforge"],
			"MAGE", BS["Teleport: Orgrimmar"],
			"MAGE", BS["Teleport: Shattrath"],
			"DRUID", BS["Teleport: Moonglade"],
			"SHAMAN", BS["Astral Recall"],
			"WARLOCK", BS["Ritual of Summoning"],

			-- TODO: dump these in favour of right click / settings for either?
			"MAGE", BS["Portal: Undercity"],
			"MAGE", BS["Portal: Thunder Bluff"],
			"MAGE", BS["Portal: Stormwind"],
			"MAGE", BS["Portal: Silvermoon"],
			"MAGE", BS["Portal: Exodar"],
			"MAGE", BS["Portal: Darnassus"],
			"MAGE", BS["Portal: Ironforge"],
			"MAGE", BS["Portal: Orgrimmar"],
			"MAGE", BS["Portal: Shattrath"],
			}, {
			"MAGE", BS["Portal: Undercity"],
			"MAGE", BS["Portal: Thunder Bluff"],
			"MAGE", BS["Portal: Stormwind"],
			"MAGE", BS["Portal: Silvermoon"],
			"MAGE", BS["Portal: Exodar"],
			"MAGE", BS["Portal: Darnassus"],
			"MAGE", BS["Portal: Ironforge"],
			"MAGE", BS["Portal: Orgrimmar"],
			"MAGE", BS["Portal: Shattrath"],
			})

--	["WATER_CONJURE"] = {
--		["description"] = L["AUTOBAR_CLASS_WATER_CONJURE"],
--		["texture"] = BS:GetShortSpellIcon("Conjure Water"),
--		["spell"] = true,
--	},
	AutoBarCategoryList["WATER_CONJURE"] = AutoBarSpells:new(
			"AUTOBAR_CLASS_WATER_CONJURE", BS:GetShortSpellIcon("Conjure Water"), {
			"MAGE", BS["Conjure Water"],
			})

--	["FOOD_CONJURE"] = {
--		["description"] = L["Consumable.Food.Conjure"];
--		["texture"] = BS:GetShortSpellIcon("Conjure Food"),
--		["spell"] = true,
--	},
	AutoBarCategoryList["FOOD_CONJURE"] = AutoBarSpells:new(
			"Consumable.Food.Conjure", BS:GetShortSpellIcon("Conjure Food"), {
			"MAGE", BS["Conjure Food"],
			})

--	["MOUNTS_SUMMONED"] = {
--		["description"] = L["Misc.Mount.Summoned"];
--		["texture"] = "Ability_Mount_JungleTiger";
--		["nonCombat"] = true,
--		["arrangeOnUse"] = true,
--		["spell"] = true,
--		["castList"] = {"PALADIN", BS["Summon Warhorse"], "PALADIN", BS["Summon Charger"], "WARLOCK", BS["Summon Felsteed"], "WARLOCK", BS["Summon Dreadsteed"], "DRUID", BS["Travel Form"], "DRUID", BS["Flight Form"], "DRUID", BS["Swift Flight Form"], "SHAMAN", BS["Ghost Wolf"],},
--	},
	AutoBarCategoryList["MOUNTS_SUMMONED"] = AutoBarSpells:new(
			"Misc.Mount.Summoned", "Ability_Mount_JungleTiger", {"PALADIN", BS["Summon Warhorse"], "PALADIN", BS["Summon Charger"], "WARLOCK", BS["Summon Felsteed"], "WARLOCK", BS["Summon Dreadsteed"], "DRUID", BS["Travel Form"], "DRUID", BS["Flight Form"], "DRUID", BS["Swift Flight Form"], "SHAMAN", BS["Ghost Wolf"],})
	AutoBarCategoryList["MOUNTS_SUMMONED"]:SetNonCombat(true)
	AutoBarCategoryList["MOUNTS_SUMMONED"]:SetArrangeOnUse(true)
end


--	["CUSTOM"] = {
--		["description"] = AUTOBAR_CLASS_CUSTOM;
--		["texture"] = "INV_Misc_Bandage_12",
--		["custom"] = true;
--		["items"] = { 19307 },
--	},

-- /dump AutoBarCategoryList["MOUNTS_SUMMONED"]
