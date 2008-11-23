------------------------------------------------------
-- GFWTooltip.lua
-- Generic tooltip hooking
-- Credit where due: mostly based on GDI's Reagent Info (which in turn uses code from ItemsMatrix, LootLink, and Auctioneer)
-- Additional inspiration from Reagent Watch and EnhTooltip
------------------------------------------------------
local GFWTOOLTIP_THIS_VERSION = 12;
------------------------------------------------------

------------------------------------------------------
-- External API
------------------------------------------------------

--[[ GFWTooltip_AddCallback(modName, callbackFunction)

Allows you to have a function called whenever a tooltip is displayed. 
The function is called with arguments (frame, name, link, source):

	frame: the instance of GameTooltip being shown, which you can modify via its API
	name: the first line of the tooltip, typically an item name.
	link: a hyperlink to the item being shown in the tooltip
	source: a non-localized string identifying why this tooltip is being shown 
			(e.g. "MERCHANT" for an item seen in the MerchantFrame)
	
Your callback function should return true if it modifies the tooltip, so we know not to modify the same tooltip twice.

Example:

	function MyTooltipCallback(frame, name, link, source)
		frame:AddLine("some stuff");
		return true;
	end
	function MyMod_OnLoad()
		GFWTooltip_AddCallback("MyMod", MyTooltipCallback);
	end
]]

local function addCallback(modName, callbackFunction)
	GFWTooltip_Callbacks[modName] = callbackFunction;
end

------------------------------------------------------
-- Initial setup
------------------------------------------------------

if (GFWTooltip == nil) then
	GFWTooltip = {};
end
if (GFWTooltip_Callbacks == nil) then
	GFWTooltip_Callbacks = {};
end
if (GFWTooltip_HookedFunctionNames == nil) then
	GFWTooltip_HookedFunctionNames = {};
end
local hookTableName = "GFWTooltip_"..GFWTOOLTIP_THIS_VERSION.."_HookFunctions";
if (getglobal(hookTableName) == nil) then
	setglobal(hookTableName, {});
end
local G = GFWTooltip;
local Hooked = GFWTooltip_HookedFunctionNames;
local Hook = getglobal(hookTableName);

------------------------------------------------------
-- Internal functions
------------------------------------------------------

local checkTimer; -- Timer for frequency of tooltip checks
local gameToolTipOwner; -- The current owner of the GameTooltip
local currentTooltip; -- Current Tooltip frame

local function hookFunction(functionName)
	if (not Hooked[functionName]) then
		Hooked[functionName] = true;
	end
	hooksecurefunc(functionName, Hook[functionName]);
end

local function hookMethod(objectName, functionName)
	local signature = objectName.."_"..functionName;
	local object = getglobal(objectName);
	if (not Hooked[signature]) then
		Hooked[signature] = true;
	end
	hooksecurefunc(object, functionName, Hook[signature]);
end

-- We call this at the bottom of this file to get things started. 
local function setupHookFunctions()

	-- Hooks for Blizzard's GameTooltip functions
	hookMethod("GameTooltip", "SetHyperlink");
	hookMethod("GameTooltip", "SetLootItem");
	hookMethod("GameTooltip", "SetQuestItem");
	hookMethod("GameTooltip", "SetQuestLogItem");
	hookMethod("GameTooltip", "SetInventoryItem");
	hookMethod("GameTooltip", "SetMerchantItem");
	hookMethod("GameTooltip", "SetCraftItem");
	hookMethod("GameTooltip", "SetTradeSkillItem");
	hookMethod("GameTooltip", "SetAuctionSellItem");
	hookMethod("GameTooltip", "SetBagItem");
	hookMethod("GameTooltip", "SetOwner");
	hookFunction("GameTooltip_OnHide");
	
	-- Hooks for other Blizzard functions
	-- hookFunction("ContainerFrameItemButton_OnEnter");
	-- hookFunction("ContainerFrame_Update");
	hookFunction("SetItemRef");

	-- Dynamic-load Blizzard functions
	hookFunction("AuctionFrame_LoadUI");

end

local function addTooltipInfo(frame, name, link, source)
	if (frame.gfwDone == 1) then return; end -- we've already been here

	local changedTooltip = false;
	for modName, callback in pairs(GFWTooltip_Callbacks) do
		if (callback ~= nil and type(callback) == "function") then
			local modifiedInCallback = callback(frame, name, link, source);
			changedTooltip = changedTooltip or modifiedInCallback;
			if (modifiedInCallback) then
				--GFWUtils.DebugLog("Ran tooltip callback for ".. modName..", tooltip modified.");
			else
				--GFWUtils.DebugLog("Ran tooltip callback for ".. modName..", tooltip not modified.");
			end
		end
	end
	--GFWUtils.DebugLog("Done with tooltip callbacks.");
	if (changedTooltip) then
		frame.gfwDone = 1;
		frame:Show();
	end

end

-- Checks the tooltip info for an item name.  If one is found and we haven't updated the tip already, process it.
local function checkTooltipInfo(frame, link, source)
	if (link and link ~= GFWTooltip_LastLink) then
		frame.gfwDone = nil;
	end
	if (link == nil) then
		link = GFWTooltip_LastLink;
	end

	-- If we've already added our information, no need to do it again
	currentTooltip = frame;
	if ( frame == nil ) then
		return;
	end
	if (not frame:IsVisible()) then
		frame.gfwDone = nil;
	end
	local _, _, itemID = string.find(link, "item:(%d+)");
	itemID = tonumber(itemID);
	if (itemID) then 
		local name = G.NameFromLink(itemID);
		if (name and name ~= GFWTooltip_LastName) then
			frame.gfwDone = nil;
		end
		if ( not frame.gfwDone) then
			addTooltipInfo(frame, name, link, source);
			GFWTooltip_LastLink = link;
			GFWTooltip_LastName = name;
			frame:Show();
			return;
		end
	end
end

local function nameFromLink(link)
	if (link) then
		if (type(link) == "string") then
			local _, _, itemString = string.find(link, "(item:[-%d:]+)");
			return (GetItemInfo(itemString));
		else
			return (GetItemInfo(link));
		end
	else
		return nil;
	end
end


local function findItemInBags(findName)
	for bag = 0, 4, 1 do
		size = GetContainerNumSlots(bag);
		if (size) then
			for slot = size, 1, -1 do
				local link = GetContainerItemLink(bag, slot);
				if (link) then
					local itemName = G.NameFromLink(link);
					if (itemName == findName) then
						return bag, slot;
					end
				end
			end
		end
	end
end


--------------------
-- Hook Functions --
--------------------

function Hook.AuctionFrame_LoadUI()
	if (not Hooked.AuctionFrameItem_OnEnter) then
		hookFunction("AuctionFrameItem_OnEnter");

		GFWUtils.DebugLog("GFWTooltip AuctionFrame hooks installed.");
	end
end

function Hook.GameTooltip_SetHyperlink(tooltip, link)
	local name = G.NameFromLink(link);
	addTooltipInfo(tooltip, name, link, "LINK");
end

function Hook.GameTooltip_SetLootItem(this, slot)
	local link = GetLootSlotLink(slot);
	local name = G.NameFromLink(link);
	addTooltipInfo(this, name, link, "LOOT");
end

function Hook.GameTooltip_SetQuestItem(this, qtype, slot)
	local link = GetQuestItemLink(qtype, slot);
	local name = G.NameFromLink(link);
	addTooltipInfo(this, name, link, "QUEST");
end

function Hook.GameTooltip_SetQuestLogItem(this, qtype, slot)
	local link = GetQuestLogItemLink(qtype, slot);
	local name = G.NameFromLink(link);
	addTooltipInfo(this, name, link, "QUESTLOG");
end

function Hook.GameTooltip_SetMerchantItem(this, slot)
	local link = GetMerchantItemLink(slot);
	local name = G.NameFromLink(link);
	addTooltipInfo(this, name, link, "MERCHANT");
end

function Hook.AuctionFrameItem_OnEnter(type, index)
	local link = GetAuctionItemLink(type, index);
	local name = G.NameFromLink(link);
	addTooltipInfo(GameTooltip, name, link, "AUCTION");
end

function Hook.GameTooltip_SetInventoryItem(this, unit, slot)
	local link = GetInventoryItemLink(unit, slot);
	local name = G.NameFromLink(link);
	addTooltipInfo(this, name, link, "INVENTORY");
end

function Hook.GameTooltip_SetCraftItem(this, skill, slot)
	local link;
	if (slot) then
		link = GetCraftReagentItemLink(skill, slot);
		local name = G.NameFromLink(link);
		addTooltipInfo(this, name, link, "CRAFT_REAGENT");
	else
		link = GetCraftItemLink(skill);
		local name = G.NameFromLink(link);
		addTooltipInfo(this, name, link, "CRAFT_ITEM");
	end
end

function Hook.GameTooltip_SetTradeSkillItem(this, skill, slot)
	local link;
	if (slot) then
		link = GetTradeSkillReagentItemLink(skill, slot);
		local name = G.NameFromLink(link);
		addTooltipInfo(this, name, link, "TRADESKILL_REAGENT");
	else
		link = GetTradeSkillItemLink(skill);
		local name = G.NameFromLink(link);
		addTooltipInfo(this, name, link, "TRADESKILL_ITEM");
	end
end

function Hook.GameTooltip_SetAuctionSellItem(this)
    local name, texture, quantity, quality, canUse, price = GetAuctionSellItemInfo();
	if (name) then
		local bag, slot = findItemInBags(name);
		if (bag) then
			local link = GetContainerItemLink(bag, slot);
			addTooltipInfo(this, name, link, "AUCTION_SELL");
		end
	end
end

function Hook.GameTooltip_SetBagItem(this, bag, slot)
	local link = GetContainerItemLink(bag, slot);
	if (link) then
		checkTooltipInfo(GameTooltip, link, "CONTAINER");
	end
end

function Hook.GameTooltip_OnHide()
	GFWTooltip_LastLink = nil;
	GFWTooltip_LastName = nil;
	GameTooltip.gfwDone = nil;
	if ( currentTooltip ) then
		currentTooltip.gfwDone = nil;
		currentTooltip = nil;
	end
end

function Hook.GameTooltip_SetOwner(this, owner, anchor)
	gameToolTipOwner = owner;
end

function Hook.SetItemRef(link, text, button)
	if (not ItemRefTooltip:IsVisible()) then
		ItemRefTooltip.gfwDone = nil;
	end
	checkTooltipInfo(ItemRefTooltip, link, "ITEMREF");
end


------------------------------------------------------
-- load only if not already loaded
------------------------------------------------------

if (G.Version == nil or (tonumber(G.Version) and G.Version < GFWTOOLTIP_THIS_VERSION)) then

	-- Initialize state variables
	checkTimer = 0; -- Timer for frequency of tooltip checks

	-- Export functions
	setupHookFunctions();
	G.AddCallback = addCallback;
	GFWTooltip_AddCallback = addCallback;
	GFWTooltip.FindItemInBags = findItemInBags;
	GFWTooltip.NameFromLink = nameFromLink;
	
	-- Set version number
	G.Version = GFWTOOLTIP_THIS_VERSION;

	GFWUtils.Print("GFWTooltip v"..GFWTOOLTIP_THIS_VERSION.." loaded.");

end


