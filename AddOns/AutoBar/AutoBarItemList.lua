--
-- AutoBar
-- Item List Database
--
-- Maintained by Azethoth / Toadkiller of Proudmoore.  Original author Saien of Hyjal
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


AutoBarItemList = {};

local L = AceLibrary("AceLocale-2.2"):new("AutoBar");
local PT = AceLibrary:GetInstance("PeriodicTable-3.0");
local BS = AceLibrary:GetInstance("Babble-Spell-2.2");


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


-- Get set as a simple array of itemIds, ordered by their value in the set
-- If provided, also record the values scaled by downFactor into downHp, downMana
function AutoBarItemList:GetSetItemsArrayPT3(set, downHp, downMana, downFactor)
	local itemArray = {};
	local cacheSet = PT:GetSetTable(set);
	if (cacheSet) then
		local sortedList = {};
		local index = 1;
		for itemId, value in PT:IterateSet(set) do
			if (type(value) == "boolean") then
				value = 0;
			end
			sortedList[index] = { itemId, value };
			index = index + 1;
		end
		table.sort(sortedList, sortList);
		for i, j in ipairs(sortedList) do
			itemArray[i] = j[1];
			if (downHp) then
				downHp[i] = j[2] * downFactor;
			end
			if (downMana) then
				downMana[i] = j[2]* downFactor;
			end
		end
	end
	return itemArray;
end


-- Convert rawList to a simple array of itemIds, ordered by their value in the set, and priority if any
-- If provided, also record the values scaled by downFactor into downHp, downMana
function AutoBarItemList:RawItemsConvert(rawList, downHp, downMana, downFactor)
	local itemArray = {};
	table.sort(rawList, sortList);
	for i, j in ipairs(rawList) do
		itemArray[i] = j[1];
		if (downHp) then
			downHp[i] = j[2] * downFactor;
		end
		if (downMana) then
			downMana[i] = j[2]* downFactor;
		end
	end
	return itemArray;
end


-- Add items from set to rawList
-- If priority is true, the items will have priority over non-priority items with the same values
function AutoBarItemList:RawItemsAdd(rawList, set, priority)
--DEFAULT_CHAT_FRAME:AddMessage("RawItemsAdd set " .. tostring(set).." priority ".. tostring(priority));
	if (not rawList) then
		rawList = {};
	end
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
	return rawList;
end


-- Fill in category item lists with the raw data from PeriodicTable.
-- Unless AutoBar is drastically restructured thats the most use we can get from PeriodicTable
function AutoBarItemList:Initialize()
	local rawList;	--TODO: Recycle it

	rawList = self:RawItemsAdd(nil, "Consumable.Food.Edible.Bread.Basic", false);
	rawList = self:RawItemsAdd(rawList, "Consumable.Food.Edible.Bread.Conjured", true);
	AutoBar_Category_Info["FOOD_PET_BREAD"]["items"] = self:RawItemsConvert(rawList);

	AutoBar_Category_Info["FOOD_PET_CHEESE"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Edible.Cheese.Basic");

	rawList = self:RawItemsAdd(nil, "Consumable.Food.Inedible.Fish", false);
	rawList = self:RawItemsAdd(rawList, "Consumable.Food.Edible.Fish.Basic", true);
	AutoBar_Category_Info["FOOD_PET_FISH"]["items"] = self:RawItemsConvert(rawList);

	AutoBar_Category_Info["FOOD_PET_FRUIT"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Edible.Fruit.Basic");
	AutoBar_Category_Info["FOOD_PET_FUNGUS"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Edible.Fungus.Basic");	-- Now includes senjin combo ;-(

	rawList = self:RawItemsAdd(nil, "Consumable.Food.Inedible.Meat", false);
	rawList = self:RawItemsAdd(rawList, "Consumable.Food.Edible.Meat.Basic", true);
	AutoBar_Category_Info["FOOD_PET_MEAT"]["items"] = self:RawItemsConvert(rawList);

end


AutoBar_Category_Info = {
	["AAACLEAR"] = {
		["description"] = L["AUTOBAR_CLASS_CLEAR"];
		["texture"] = "INV_Misc_Fork&Knife";
		["items"] = {},
	},
	----------------
	["HEALTHSTONE_CONJURE"] = {
		["description"] = L["Consumable.Warlock.Create Healthstone"],
		["texture"] = BS:GetShortSpellIcon("Create Healthstone"),
		["spell"] = true,
		["castList"] = {"WARLOCK", BS["Create Healthstone"]};
	},
	["MANASTONE_CONJURE"] = {
		["description"] = L["Consumable.Mage.Conjure Mana Stone"];
		["texture"] = "INV_Misc_Gem_Emerald_01";
	},
	----------------
	["PORTALS"] = {
		["description"] = L["AUTOBAR_CLASS_PORTALS"];
		["texture"] = "Spell_Arcane_PortalShattrath";
		["spell"] = true,
	},
	----------------
	["WATER_CONJURE"] = {
		["description"] = L["AUTOBAR_CLASS_WATER_CONJURE"],
		["texture"] = BS:GetShortSpellIcon("Conjure Water"),
		["spell"] = true,
	},
	--------------
	["FOOD_PET_BREAD"] = {
		["description"] = L["Consumable.Food.Edible.Basic.Non-Conjured_PET_BREAD"];
		["texture"] = "INV_Misc_Food_35";
		["nonCombat"] = true,
		["targetted"] = "PET";
		["castSpell"] = BS["Feed Pet"];
	},
	["FOOD_PET_CHEESE"] = {
		["description"] = L["Consumable.Food.Edible.Basic.Non-Conjured_PET_CHEESE"];
		["texture"] = "INV_Misc_Food_37";
		["nonCombat"] = true,
		["targetted"] = "PET";
		["castSpell"] = BS["Feed Pet"];
	},
	["FOOD_PET_FISH"] = {
		["description"] = L["Consumable.Food.Edible.Basic.Non-Conjured_PET_FISH"];
		["texture"] = "INV_Misc_Fish_22";
		["nonCombat"] = true,
		["targetted"] = "PET";
		["castSpell"] = BS["Feed Pet"];
	},
	["FOOD_PET_FRUIT"] = {
		["description"] = L["Consumable.Food.Edible.Basic.Non-Conjured_PET_FRUIT"];
		["texture"] = "INV_Misc_Food_19";
		["nonCombat"] = true,
		["targetted"] = "PET";
		["castSpell"] = BS["Feed Pet"];
	},
	["FOOD_PET_FUNGUS"] = {
		["description"] = L["Consumable.Food.Edible.Basic.Non-Conjured_PET_FUNGUS"];
		["texture"] = "INV_Mushroom_05";
		["nonCombat"] = true,
		["targetted"] = "PET";
		["castSpell"] = BS["Feed Pet"];
	},
	["FOOD_PET_MEAT"] = {
		["description"] = L["Consumable.Food.Edible.Basic.Non-Conjured_PET_MEAT"];
		["texture"] = "INV_Misc_Food_14";
		["nonCombat"] = true,
		["targetted"] = "PET";
		["castSpell"] = BS["Feed Pet"];
	},
	["FOOD_CONJURE"] = {
		["description"] = L["Consumable.Food.Edible.Basic.Non-Conjured_CONJURE"];
		["texture"] = BS:GetShortSpellIcon("Conjure Food"),
		["spell"] = true,
	},
	--------------
	["MOUNTS_SUMMONED"] = {
		["description"] = L["Misc.Mount.Summoned"];
		["texture"] = "Ability_Mount_JungleTiger";
		["nonCombat"] = true,
		["arrangeOnUse"] = true,
		["spell"] = true,
		["castList"] = {"PALADIN", BS["Summon Warhorse"], "PALADIN", BS["Summon Charger"], "WARLOCK", BS["Summon Felsteed"], "WARLOCK", BS["Summon Dreadsteed"], "DRUID", BS["Travel Form"], "DRUID", BS["Flight Form"], "DRUID", BS["Swift Flight Form"], "SHAMAN", BS["Ghost Wolf"],},
	},
};

-- /dump AutoBar_Category_Info["MOUNTS_SUMMONED"]
