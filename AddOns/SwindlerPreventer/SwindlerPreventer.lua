------------------------------------------------------
-- SwindlerPreventer.lua
------------------------------------------------------

SP_SPECIAL_VENDOR_COLOR = {r=1.0, g=0.5, b=0.25};
SP_INDENT = "  ";

SP_AllClasses = { "PALADIN", "SHAMAN", "MAGE", "PRIEST", "WARLOCK", "WARRIOR", "HUNTER", "ROGUE", "DRUID", "ANY" };

-- Configuration
SP_NewItemInfo = { };
SP_NewVendorInfo = { };
SP_NewVendorLocations = { };

function SP_HookTooltip(frame)
	if (frame:GetScript("OnTooltipSetItem")) then
		frame:HookScript("OnTooltipSetItem", SP_OnTooltipSetItem);
	else
		frame:SetScript("OnTooltipSetItem", SP_OnTooltipSetItem);
	end
end

function SP_OnTooltipSetItem()
	if (MerchantFrame:IsVisible()) then
		for buttonIndex = 1, MERCHANT_ITEMS_PER_PAGE do
			local button = getglobal("MerchantItem"..buttonIndex.."ItemButton");
			if (this:IsOwned(button)) then return; end
		end
	end

	local name, link = this:GetItem();
	if (not link) then return; end
	-- workaround for OnTooltipSetItem being called twice for recipes
	local _, _, _, _, _, itemType, _, _, _, _ = GetItemInfo(link);
	if (itemType == SP_RECIPE and this.lastLink ~= link) then
		for i = 1, this:NumLines() do
			local line = getglobal(this:GetName().."TextLeft"..i);
			local text = line:GetText();
			if (text and string.sub(text, 1, 1) == "\n") then 
				this.lastLink = link;
				return; 
			end
		end
	end
	this.lastLink = nil;
	
	if (link) then
		local _, _, itemID  = string.find(link, "item:(%d+)");
		itemID = tonumber(itemID);
		local itemInfo = SP_ItemInfo[itemID];
		if (not itemInfo) then
			itemInfo = SP_NewItemInfo[itemID];
		end
		
		if (not SP_Config.NoRecipes and itemInfo) then
			local myFaction = UnitFactionGroup("player");
			local vendors = GFWTable.Merge(SP_VendorInfo[myFaction][itemID], SP_VendorInfo["Neutral"][itemID]);
			if (SP_NewVendorInfo[myFaction] and SP_NewVendorInfo[myFaction][itemID]) then
				vendors = GFWTable.Merge(vendors, SP_NewVendorInfo[myFaction][itemID]);
			end
			if (SP_NewVendorInfo["Neutral"] and SP_NewVendorInfo["Neutral"][itemID]) then
				vendors = GFWTable.Merge(vendors, SP_NewVendorInfo["Neutral"][itemID]);
			end
			local note = itemInfo.note;
			
			local color;
			local intro;
			if (note) then
				color = SP_SPECIAL_VENDOR_COLOR;
			else
				color = GFW_FONT_COLOR;
			end
			if (not SP_Config.NoShowCost) then
				local priceSummmary;
				if (itemInfo.b and itemInfo.b > 0) then
				 	priceSummmary = GFWUtils.TextGSC(itemInfo.b);
				else
					priceSummmary = "";
				end
				if (itemInfo.h) then
					priceSummmary = priceSummmary .. " + ".. itemInfo.h.. " honor";
				end
				if (itemInfo.a) then
					priceSummmary = priceSummmary .. " + ".. itemInfo.a.. " arena";
				end
				if (itemInfo.i) then
					priceSummmary = priceSummmary .. " + ".. itemInfo.i;
				end
				priceSummmary = string.gsub(priceSummmary, "^ %+ ", "");
				priceSummmary = string.gsub(priceSummmary, " %+ $", "");
				
				intro = string.format(SOLD_FOR_PRICE_BY, GFWUtils.Hilite(priceSummmary));
			else
				intro = SOLD_BY;
			end
					
			if (table.getn(vendors) > 1) then
				this:AddLine(intro..":", color.r, color.g, color.b);
				for i, aVendor in pairs(vendors) do
					local vendorLoc = SP_VendorLocations[aVendor];
					if (not vendorLoc) then
						vendorLoc = SP_NewVendorLocations[aVendor];
					end
					if (vendorLoc) then
						local vendorName = SP_Localized[aVendor] or aVendor;
						local vendorLocation = SP_Localized[vendorLoc] or vendorLoc;
						this:AddLine(SP_INDENT..string.format(VENDOR_LOCATION_FORMAT, vendorName, vendorLocation), color.r, color.g, color.b);
					else
						local version = GetAddOnMetadata("SwindlerPreventer", "Version");
						GFWUtils.PrintOnce(GFWUtils.Red("SwindlerPreventer "..version.." error: ").."Can't find location for "..aVendor..". Please report this at the website you downloaded from.", 60);
						return false;
					end
				end
			elseif (table.getn(vendors) == 1) then
				local vendorLoc = SP_VendorLocations[vendors[1]];
				if (not vendorLoc) then
					vendorLoc = SP_NewVendorLocations[vendors[1]];
				end
				if (vendorLoc) then
					local vendorName = SP_Localized[vendors[1]] or vendors[1];
					local vendorLocation = SP_Localized[vendorLoc] or vendorLoc;
					this:AddLine(intro.." "..string.format(VENDOR_LOCATION_FORMAT, vendorName, vendorLocation), color.r, color.g, color.b);
				else
					local version = GetAddOnMetadata("SwindlerPreventer", "Version");
					GFWUtils.PrintOnce(GFWUtils.Red("SwindlerPreventer "..version.." error: ").."Can't find location for "..vendorName..". Please report this at the website you downloaded from.", 60);
					return false;
				end
			else
				local found = false;
				for _, faction in pairs({"Alliance", "Horde", "Neutral"}) do
					if (SP_VendorInfo[faction][itemID]) then
						found = true;
					end
				end
				if not (found) then
					local version = GetAddOnMetadata("SwindlerPreventer", "Version");
					GFWUtils.PrintOnce(GFWUtils.Red("SwindlerPreventer "..version.." error: ")..link.."("..itemID..") is listed but has no vendors. Please report this at the website you downloaded from.", 60);
					return false;
				end
			end
			if (note ~= "") then
				this:AddLine(note, color.r, color.g, color.b);
			end
			return true;
		end
		
		local libramInfo = SP_LibramInfo[itemID];
		if (not SP_Config.NoLibrams and libramInfo) then
			local color = SP_SPECIAL_VENDOR_COLOR;
			local returnToName = SP_Localized[libramInfo.name] or libramInfo.name;
			local returnToLocation = SP_Localized[SP_VendorLocations[libramInfo.name]] or SP_VendorLocations[libramInfo.name];
			local bonus = SP_Localized[libramInfo.bonus] or libramInfo.bonus;
			this:AddLine(RETURN_TO.." "..string.format(VENDOR_LOCATION_FORMAT, returnToName, returnToLocation), color.r, color.g, color.b);
			this:AddLine(string.format(ARCANUM_FORMAT, bonus), color.r, color.g, color.b);
			return true;
		end

		local tokenInfo = SP_TokenInfo[itemID];
		if ((not SP_Config.NoZG or not SP_Config.NoAQ20 or not SP_Config.NoAQ40) and  tokenInfo) then
			local color = SP_SPECIAL_VENDOR_COLOR;
			local addedLines;
			for _, faction in pairs(SP_TokenFactions) do
				local _, _, factionAbbrev = string.find(faction, "(.-)_FACTION");
				if (SP_Config[factionAbbrev]) then
					local reportLines = {};
					for _, class in pairs(SP_AllClasses) do
						if (not (class == "SHAMAN" and UnitFactionGroup("player") == "Alliance") and 
						    not (class == "PALADIN" and UnitFactionGroup("player") == "Horde")) then
							for _, rewardID in pairs(tokenInfo) do
								local reward = SP_TokenRewards[rewardID];
								if (reward and reward.class == class and reward.faction == faction) then
									local repNeeded;
									if (reward.rep) then
										repNeeded = getglobal("FACTION_STANDING_LABEL"..reward.rep);
									end
									local reportLine = "";
									reportLine = reportLine .. reward.type;
									if (repNeeded) then
										reportLine = reportLine .. " ("..repNeeded..")";
									end
									reportLine = reportLine .. ", ";
									if (reportLines[class]) then
										reportLines[class] = reportLines[class] .. reportLine;
									else
										reportLines[class] = reportLine;
									end
								end
							end
							if (reportLines[class]) then
								reportLines[class] = string.gsub(reportLines[class], ", $", "");
							end
						end
					end
					if (GFWTable.Count(reportLines) > 0) then
						this:AddLine(string.format(SP_FACTION_REWARDS, getglobal(faction)), color.r, color.g, color.b);
						addedLines = true;
						for class, reportLine in pairs(reportLines) do
							this:AddLine("  "..getglobal(class)..": "..reportLine, color.r, color.g, color.b);
						end
					end
				end
			end
			if (addedLines) then
				return true;
			end
		end

		-- FactionFriend also shows tooltips for this stuff; if it's present, let it take over
		if (FFF_Config and not FFF_Config.NoTooltip) then return; end

		local darkmoonInfo = SP_DarkmoonInfo[itemID];
		if (not SP_Config.NoDarkmoon and darkmoonInfo) then
			local color = SP_SPECIAL_VENDOR_COLOR;
			this:AddLine(darkmoonInfo, color.r, color.g, color.b);
			return true;
		end

		for key, tokenSetList in pairs(SP_FactionTokenSets) do
			if (not SP_Config["No"..key]) then
				
				for _, coinSet in pairs(tokenSetList) do
					local found;
					local otherCoins = {};
					for _, coinID in pairs(coinSet) do
						if (itemID == coinID) then
							found = true;
						else
							local itemText = SP_TokenNames[coinID];
							itemText = SP_Localized[itemText] or itemText;
							table.insert(otherCoins, itemText);
						end
					end
					if (found) then
						local color = SP_SPECIAL_VENDOR_COLOR;
						this:AddLine(SP_TURNIN.." "..getglobal(key.."_FACTION"), color.r, color.g, color.b);
						if (table.getn(otherCoins) > 0) then
							this:AddDoubleLine(" ", SP_WITH.." "..table.concat(otherCoins, ", "), color.r, color.g, color.b, color.r, color.g, color.b);
						end
						return true;
					end
				end
			end
		end
	end
	
end

function SP_OnLoad()

	-- Register Slash Commands
	SLASH_SWINPREV1 = "/swindlerpreventer";
	SLASH_SWINPREV2 = "/swp";
	SlashCmdList["SWINPREV"] = function(msg)
		SP_ChatCommandHandler(msg);
	end

	
	-- Register for Events
	this:RegisterEvent("MERCHANT_SHOW");
	this:RegisterEvent("MERCHANT_UPDATE");

	SP_HookTooltip(GameTooltip);
	SP_HookTooltip(ItemRefTooltip);
	
	table.insert(UISpecialFrames,"SP_OptionsFrame");	
end

function SP_OnEvent(event, arg1)

	if( event == "MERCHANT_SHOW" or event == "MERCHANT_UPDATE" ) then
		SP_ScanMerchant();
	end
end

function SP_ChatCommandHandler(msg)

	if ( msg == "" ) then
		SP_ShowOptions();
		return;
	end

	-- Print Help
	if ( msg == "help" ) or ( msg == "" ) then
		local version = GetAddOnMetadata("SwindlerPreventer", "Version");
		GFWUtils.Print("Fizzwidget SwindlerPreventer "..version..":");
		GFWUtils.Print("/SwindlerPreventer (or /swp)");
		GFWUtils.Print("- "..GFWUtils.Hilite("help").." - Print this helplist.");
		GFWUtils.Print("- "..GFWUtils.Hilite("[item link]").." - Show info for an item in the chat window.");
		GFWUtils.Print("- "..GFWUtils.Hilite("status").." - Check current settings.");
		GFWUtils.Print("- "..GFWUtils.Hilite("recipes on").." | "..GFWUtils.Hilite("off").." - Show info for vendor-supplied recipes in tooltips.");
		GFWUtils.Print("- "..GFWUtils.Hilite("showcost on").." | "..GFWUtils.Hilite("off").." - Also show vendor prices for recipes.");
		GFWUtils.Print("- "..GFWUtils.Hilite("librams on").." | "..GFWUtils.Hilite("off").." - Show info for librams in tooltips.");
		GFWUtils.Print("- "..GFWUtils.Hilite("darkmoon on").." | "..GFWUtils.Hilite("off").." - Show info for Darkmoon Faire grey item turn-ins in tooltips.");
		GFWUtils.Print("- "..GFWUtils.Hilite("zg on").." | "..GFWUtils.Hilite("off").." - Show info for for special raid loot from Zul'Gurub (Zandalar Tribe rewards) in tooltips.");
		GFWUtils.Print("- "..GFWUtils.Hilite("aq20 on").." | "..GFWUtils.Hilite("off").." - Show info for for special raid loot from Ruins of Ahn'Qiraj (Cenarion Circle rewards) in tooltips.");
		GFWUtils.Print("- "..GFWUtils.Hilite("aq40 on").." | "..GFWUtils.Hilite("off").." - Show info for for special raid loot from Ahn'Qiraj (Brood of Nozdormu rewards) in tooltips.");
		GFWUtils.Print("- "..GFWUtils.Hilite("post on").." | "..GFWUtils.Hilite("off").." - Post to raid/party chat when getting raid loot info via "..GFWUtils.Hilite("/swp [item link]")..".");
		return;
	end
	
	if (msg == "version") then
		local version = GetAddOnMetadata("SwindlerPreventer", "Version");
		GFWUtils.Print("Fizzwidget SwindlerPreventer "..version);
		return;
	end
	
	if ( msg == "status" ) then
		local gotSomething;
		if (not SP_Config.NoRecipes) then
			GFWUtils.Print("Showing info for "..GFWUtils.Hilite("vendor-supplied recipes").." in tooltips.");
			gotSomething = 1;
			if (not SP_Config.NoShowCost) then
				GFWUtils.Print("Also showing vendor price for recipes.");
			end
		end
		if (not SP_Config.NoLibrams) then
			GFWUtils.Print("Showing info for "..GFWUtils.Hilite("Librams").." in tooltips.");
			gotSomething = 1;
		end
		if (not SP_Config.NoDarkmoon) then
			GFWUtils.Print("Showing info for "..GFWUtils.Hilite("Darkmoon Faire grey item turn-ins").." in tooltips.");
			gotSomething = 1;
		end
		if (not SP_Config.NoZG) then
			GFWUtils.Print("Showing info for special raid loot from "..GFWUtils.Hilite("Zul'Gurub (Zandalar Tribe rewards)").." in tooltips.");
			gotSomething = 1;
		end
		if (not SP_Config.NoAQ20) then
			GFWUtils.Print("Showing info for special raid loot from "..GFWUtils.Hilite("Ruins of Ahn'Qiraj (AQ20 Cenarion Circle rewards)").." in tooltips.");
			gotSomething = 1;
		end
		if (not SP_Config.NoAQ40) then
			GFWUtils.Print("Showing info for special raid loot from "..GFWUtils.Hilite("Ahn'Qiraj (AQ40 Brood of Nozdormu rewards)").." in tooltips.");
			gotSomething = 1;
		end
		if ((not SP_Config.NoZG or not SP_Config.NoAQ20 or not SP_Config.NoAQ40) and not SP_Config.NoPostToRaid) then
			GFWUtils.Print("Will post to raid/party chat when showing info for raid loot via "..GFWUtils.Hilite("/swp [link]")..".");
		end
		if (not gotSomething) then
			GFWUtils.Print("Not adding any info to tooltips.");
		end
		return;
	end
	
	if (msg == "test") then
		local itemInfoCount = 0;
		for itemID in pairs(SP_ItemInfo) do
			local found = false;
			for _, faction in pairs({"Alliance", "Horde", "Neutral"}) do
				if (SP_VendorInfo[faction][itemID]) then
					found = true;
				end
			end
			if not (found) then
				GFWUtils.Print("Item ID "..itemID.." not found in SP_VendorInfo.");
			end
			itemInfoCount = itemInfoCount + 1;
		end
		GFWUtils.Print(itemInfoCount.." entries in SP_ItemInfo.");
		for _, faction in pairs({"Alliance", "Horde", "Neutral"}) do
			local vendorInfoCount = 0;
			for itemID in pairs(SP_VendorInfo[faction]) do
				if (SP_ItemInfo[itemID] == nil) then
					GFWUtils.Print("Item ID "..itemID.." not found in SP_ItemInfo.");
				end
				vendorInfoCount = vendorInfoCount + 1;
			end
			GFWUtils.Print(vendorInfoCount.." entries in SP_VendorInfo["..faction.."].");
		end
		return;
	end

	local _, _, cmd, args = string.find(msg, "^([%l%d']+) *(.*)");
	if (cmd) then cmd = string.lower(cmd); end
		
	if (args == nil or args == "") then
		args = msg;
	end
	local postedText;
	for itemLink in string.gmatch(args, "|c%x+|Hitem:[-%d:]+|h%[.-%]|h|r") do
		postedText = nil;
		local _, _, itemID  = string.find(itemLink, "item:(%d+)");
		if (itemID == nil or itemID == "") then
			GFWUtils.Print("Usage: "..GFWUtils.Hilite("/swp info <item link>"));
			return;
		end
		itemID = tonumber(itemID);
		
		local itemInfo = SP_ItemInfo[itemID];
		if (itemInfo) then
			local myFaction = UnitFactionGroup("player");
			local vendors = GFWTable.Merge(SP_VendorInfo[myFaction][itemID], SP_VendorInfo["Neutral"][itemID]);
			if (SP_NewVendorInfo[myFaction] and SP_NewVendorInfo[myFaction][itemID]) then
				vendors = GFWTable.Merge(vendors, SP_NewVendorInfo[myFaction][itemID]);
			end
			if (SP_NewVendorInfo["Neutral"] and SP_NewVendorInfo["Neutral"][itemID]) then
				vendors = GFWTable.Merge(vendors, SP_NewVendorInfo["Neutral"][itemID]);
			end
			local note = itemInfo.note;
			local intro = itemLink..": "..string.format(SOLD_FOR_PRICE_BY, GFWUtils.TextGSC(itemInfo.b));

			if (vendors == nil or vendors == {}) then
				local version = GetAddOnMetadata("SwindlerPreventer", "Version");
				GFWUtils.Print(GFWUtils.Red("SwindlerPreventer "..version.." error: ")..itemLink.."("..itemID..") is listed but has no vendors. Please report this at the website you downloaded from.");
				return;
			end
			GFWUtils.Print(intro);
			for i, aVendor in pairs(vendors) do
				local vendorName = SP_Localized[aVendor] or aVendor;
				local vendorLocation = SP_Localized[SP_VendorLocations[aVendor]] or SP_VendorLocations[aVendor];
				if (not vendorLocation) then
					vendorLocation = SP_Localized[SP_NewVendorLocations[aVendor]] or SP_NewVendorLocations[aVendor];
				end
				GFWUtils.Print(string.format(VENDOR_LOCATION_FORMAT, vendorName, vendorLocation));
			end
			if (note and note ~= "") then
				GFWUtils.Print(GFWUtils.Hilite(note));
			end
			postedText = 1;
		end
		
		local libramInfo = SP_LibramInfo[itemID];
		if (libramInfo) then
			local returnToName = SP_Localized[libramInfo.name] or libramInfo.name;
			local returnToLocation = SP_Localized[SP_VendorLocations[libramInfo.name]] or SP_VendorLocations[libramInfo.name];
			local bonus = SP_Localized[libramInfo.bonus] or libramInfo.bonus;
			GFWUtils.Print(itemLink..": "..RETURN_TO.." "..string.format(VENDOR_LOCATION_FORMAT, returnToName, returnToLocation));
			GFWUtils.Print(bonus);
			postedText = 1;
		end
		
		local darkmoonInfo = SP_DarkmoonInfo[itemID];
		if (darkmoonInfo) then
			GFWUtils.Print(itemLink..": "..darkmoonInfo);
			postedText = 1;
		end

		local tokenInfo = SP_TokenInfo[itemID];
		if (tokenInfo) then
			for _, faction in pairs(SP_TokenFactions) do
				local reportLines = {};
				for _, class in pairs(SP_AllClasses) do
					for _, rewardID in pairs(tokenInfo) do
						local reward = SP_TokenRewards[rewardID];
						if (reward and reward.class == class and reward.faction == faction) then
							local link = GFWUtils.ItemLink(rewardID);
							local repNeeded;
							if (reward.rep) then
								repNeeded = getglobal("FACTION_STANDING_LABEL"..reward.rep);
							end
							local reportLine = "";
							if (link) then
								reportLine = reportLine .. link .. " - ";
							end
							reportLine = reportLine .. reward.type;
							if (repNeeded) then
								reportLine = reportLine .. " ("..repNeeded..")";
							end
							reportLine = reportLine .. ", ";
							if (reportLines[class]) then
								reportLines[class] = reportLines[class] .. reportLine;
							else
								reportLines[class] = reportLine;
							end
						end
					end
					if (reportLines[class]) then
						reportLines[class] = string.gsub(reportLines[class], ", $", "");
					end
				end
				if (GFWTable.Count(reportLines) > 0) then
					local _, _, factionAbbrev = string.find(faction, "(.-)_FACTION");
					postedText = 1;
					if (SP_Config[factionAbbrev]) then
						SP_Post(itemLink..": "..string.format(SP_FACTION_REWARDS, getglobal(faction)));
						for class, reportLine in pairs(reportLines) do
							SP_Post("   "..getglobal(class)..": "..reportLine);
						end
					else
						SP_Post(itemLink..": "..string.format(SP_FACTION_REWARDS_COUNT, GFWTable.Count(reportLines), getglobal(faction)));
					end
				end
			end
		end

		local rewardInfo = SP_TokenRewards[itemID];
		if (rewardInfo) then
			local link = GFWUtils.ItemLink(itemID);
			SP_Post(link..": "..string.format(ITEM_REQ_REPUTATION, getglobal(rewardInfo.faction), getglobal("FACTION_STANDING_LABEL"..rewardInfo.rep)));
			local reportLines = {};
			for tokenID, rewards in pairs(SP_TokenInfo) do
				if (GFWTable.KeyOf(rewards, itemID)) then
					local itemText = GFWUtils.ItemLink(tokenID);
					local itemQuality = SP_TokenQuality[tokenID];
					if (itemText == nil) then
						itemText = SP_TokenNames[tokenID];
						itemText = SP_Localized[itemText] or itemText;
						local _, _, _, color = GetItemQualityColor(math.floor(itemQuality));
						itemText = color..itemText..FONT_COLOR_CODE_CLOSE;
					end
					if (rewardInfo == ENSCRIBE) then
						-- ZG enchants take 1 each of any reagent
						itemText = "1 x "..itemText;
					else
						-- other token quests take 1 epic only, or 5 of one green + 5 another green + 2 blue + 1 "special"
						if (itemQuality == 2) then
							itemText = "5 x "..itemText;
						elseif (itemQuality == 3) then
							itemText = "2 x "..itemText;					
						else
							itemText = "1 x "..itemText;
						end
					end
					table.insert(reportLines, itemText);
				end
			end
			table.sort(reportLines);
			for _, line in pairs(reportLines) do
				SP_Post(line);
			end	
			postedText = 1;
		end
		
		if (not postedText) then
			GFWUtils.Print("Nothing known about "..itemLink..".");
		end
	end
	if (postedText) then
		return;
	end
	-- if we made it down here, there were args we didn't understand... time to remind the user what to do.
	SP_ChatCommandHandler("help");

end

function SP_StripColor(text)
	if (string.find(text, "|c%x+|Hitem:[-%d:]+|h%[.-%]|h|r")) then
		return text;
	else
		return string.gsub(text, "|c"..string.rep("%x", 8).."(.-)|r", "%1");
	end
end

function SP_Post(msg)
	if (not SP_Config.NoPostToRaid and GetNumRaidMembers() > 0) then
		msg = SP_StripColor(msg);
		SendChatMessage(msg, "RAID");	
	elseif (not SP_Config.NoPostToRaid and GetNumPartyMembers() > 0) then
		msg = SP_StripColor(msg);
		SendChatMessage(msg, "PARTY");	
	else
		GFWUtils.Print(msg);
	end
end

function SP_CheckMerchant(itemID)
	for merchantIndex = 1, GetMerchantNumItems() do
		local link = GetMerchantItemLink(merchantIndex);
		local _, _, merchantItemID  = string.find(link, "item:(%d+)");
		if (tonumber(merchantItemID) == itemID) then
			return true;
		end
	end
	return false;
end

function SP_ScanMerchant()
	for index = 1, GetMerchantNumItems() do
		local link = GetMerchantItemLink(index);
		if ( link ) then
			local _, _, _, _, _, itemType, subType, _, _, _ = GetItemInfo(link);
			if (itemType == SP_RECIPE and subType ~= SP_BOOK) or (itemType == SP_MISCELLANEOUS and subType == SP_PET) or (itemType == SP_QUIVER) or (itemType == SP_CONTAINER) then
				local itemID = GFWUtils.DecomposeItemLink(link);
				local added, price, honorPoints, arenaPoints;
				_, _, price, _, _, _, extendedCost = GetMerchantItemInfo(index);
				local priceSummmary;
				if (price and price > 0) then
				 	priceSummmary = GFWUtils.TextGSC(price);
				else
					priceSummmary = "";
				end
				local itemSummary = "";
				if (price == 0 and extendedCost) then
					honorPoints, arenaPoints, itemCount = GetMerchantItemCostInfo(index);
					if (honorPoints > 0) then
						priceSummmary = priceSummmary .. " + ".. honorPoints.. " honor";
					else
						honorPoints = nil;
					end
					if (arenaPoints > 0) then
						priceSummmary = priceSummmary .. " + ".. arenaPoints.. " arena";
					else
						arenaPoints = nil;
					end
					if (itemCount > 0) then
						for costIndex = 1, itemCount, 1 do
							local itemTexture, itemValue = GetMerchantItemCostItem(index, costIndex);
							SPHiddenTooltip:ClearLines();
							SPHiddenTooltip:SetOwner(UIParent, "ANCHOR_NONE");
							SPHiddenTooltip:Show();
							SPHiddenTooltip:SetMerchantCostItem(index, costIndex);
							local itemName = SPHiddenTooltipTextLeft1:GetText();
							if (not itemName) then
								itemName = "Unknown Item";
							end
							itemSummary = itemSummary .. string.format(" + %d %s", itemValue, itemName);
						end
					end
					priceSummmary = priceSummmary .. itemSummary;
					itemSummary = string.gsub(itemSummary, "^ %+ ", "");
					priceSummmary = string.gsub(priceSummmary, "^ %+ ", "");
					priceSummmary = string.gsub(priceSummmary, " %+ $", "");
					if (itemSummary == "") then
						itemSummary = nil;
					end
				end
				if (not SP_ItemInfo[itemID]) then
					local requiresFaction;
					if (SP_ItemRequiresFaction(link)) then
						requiresFaction = REQ_FACTION;
					end
					SP_NewItemInfo[itemID] = { b=price, h=honorPoints, a=arenaPoints, i=itemSummary, note=requiresFaction };
					added = true;
				end
				local vendorName = UnitName("npc");
				local vendorFaction = UnitFactionGroup("npc");
				if (vendorFaction ~= UnitFactionGroup("player")) then
					vendorFaction = "Neutral";
				end
				if (SP_VendorInfo[vendorFaction][itemID] == nil or GFWTable.KeyOf(SP_VendorInfo[vendorFaction][itemID], vendorName) == nil) then
					if (SP_NewVendorInfo[vendorFaction] == nil) then
						SP_NewVendorInfo[vendorFaction] = {};
					end
					if (SP_NewVendorInfo[vendorFaction][itemID] == nil) then
						SP_NewVendorInfo[vendorFaction][itemID] = {};
					end
					if (GFWTable.KeyOf(SP_NewVendorInfo[vendorFaction][itemID], vendorName) == nil) then
						table.insert(SP_NewVendorInfo[vendorFaction][itemID], vendorName);
						added = true;
					end
				end
				if (not SP_VendorLocations[vendorName] and not SP_NewVendorLocations[vendorName]) then
					SP_NewVendorLocations[vendorName] = GetRealZoneText();
					added = true;
				end
				if (added) then
					local version = GetAddOnMetadata("SwindlerPreventer", "Version");
					GFWUtils.PrintOnce(string.format("Swindler Preventer %s has detected new data!  Please report the following message:  %s [%s] sold for %s by %s (%s) in %s.", version, link, itemID, GFWUtils.Hilite(priceSummmary), GFWUtils.Hilite(vendorName), vendorFaction, GFWUtils.Hilite(GetRealZoneText())));
				end
			end
		end
	end
end

function SP_ItemRequiresFaction(link)
	SPHiddenTooltip:ClearLines();
	SPHiddenTooltip:SetHyperlink(link);
	for lineNum = 1, SPHiddenTooltip:NumLines() do
		local leftText = getglobal("SPHiddenTooltipTextLeft"..lineNum):GetText();
		if (SP_ITEM_REQ_REPUTATION == nil) then
			SP_ITEM_REQ_REPUTATION = GFWUtils.FormatToPattern(ITEM_REQ_REPUTATION);
		end
		local _, _, faction, rep = string.find(leftText, SP_ITEM_REQ_REPUTATION);
		if (faction and rep) then
			return true;
		end
	end
end

-- private, for building localization tables
function SP_Translate(langCode)

	tempTranslations = {};
	
	local localizedVendorInfo = getglobal("SP_VendorInfo_"..langCode);
	local localizedVendorLocations = getglobal("SP_VendorLocations_"..langCode);
	for faction, factionVendorList in pairs(SP_VendorInfo) do
		for itemID, vendorList in pairs(factionVendorList) do
			local localizedVendors = localizedVendorInfo[faction][itemID];
			if (localizedVendors and type(localizedVendors) == "table") then
				for index, name in pairs(vendorList) do
					local localizedName = localizedVendors[index];
					
					if (localizedName == nil) then break; end
					
					if (localizedName ~= name) then
						if (tempTranslations[name] == nil) then
							tempTranslations[name] = {};
						end
						table.insert(tempTranslations[name], localizedName);
					end
					
					local location = SP_VendorLocations[name];
					local localizedLocation = localizedVendorLocations[localizedName];
					if (localizedLocation and localizedLocation ~= location) then
						if (tempTranslations[location] == nil) then
							tempTranslations[location] = {};
						end
						table.insert(tempTranslations[location], localizedLocation);
					end
				end
			end
		end
	end
	
	local localizedLibramInfo = getglobal("SP_LibramInfo_"..langCode);
	for itemID, libramInfo in pairs(SP_LibramInfo) do
		local localizedInfo = localizedLibramInfo[itemID];
		if (localizedInfo and type(localizedInfo) == "table") then
					
			if (localizedInfo.name ~= libramInfo.name) then
				if (tempTranslations[libramInfo.name] == nil) then
					tempTranslations[libramInfo.name] = {};
				end
				table.insert(tempTranslations[libramInfo.name], localizedInfo.name);
			end
			if (localizedInfo.bonus ~= libramInfo.bonus) then
				if (tempTranslations[libramInfo.bonus] == nil) then
					tempTranslations[libramInfo.bonus] = {};
				end
				table.insert(tempTranslations[libramInfo.bonus], localizedInfo.bonus);
			end
			
			local location = SP_VendorLocations[libramInfo.name];
			local localizedLocation = localizedVendorLocations[localizedInfo.name];
			if (localizedLocation and localizedLocation ~= location) then
				if (tempTranslations[location] == nil) then
					tempTranslations[location] = {};
				end
				table.insert(tempTranslations[location], localizedLocation);
			end
		end
	end
	
	SP_Config[langCode] = {};
	for baseString, translations in pairs(tempTranslations) do
		if (table.getn(translations) == 1) then
			SP_Config[langCode][baseString] = translations[1];
		else
			local mergedTranslations = {}
			for _, translation in pairs(translations) do
				if (GFWTable.KeyOf(mergedTranslations, translation) == nil) then
					table.insert(mergedTranslations, translation);
				end
			end
			if (table.getn(mergedTranslations) == 1) then
				SP_Config[langCode][baseString] = mergedTranslations[1];
			else
				SP_Config[langCode][baseString] = mergedTranslations;
			end
		end
	end

end

-- private, for generating base tables from auto-gathered data
function SP_GetNames()
	for itemID, itemInfo in pairs(SP_NewItemInfo) do
		local name = GetItemInfo(itemID);
		itemInfo.n = name;
	end
	for faction, vendorList in pairs(SP_NewVendorInfo) do
		for itemID, vendors in pairs(vendorList) do
			if (SP_VendorInfo[faction][itemID]) then
				for _, vendor in pairs(SP_VendorInfo[faction][itemID]) do
					if (not GFWTable.KeyOf(vendors, vendor)) then
						table.insert(vendors, vendor);
					end
				end
			end
			local name = GetItemInfo(itemID);
			vendors.n = name;
		end
	end
end

------------------------------------------------------
-- Dongle & GFWOptions stuff
------------------------------------------------------

SwindlerPreventer = {};
local GFWOptions = DongleStub("GFWOptions-1.0");

local function buildOptionsUI(panel)

	SwindlerPreventer.optionsText = {
		Recipes = SP_OPTION_RECIPES,
		ShowCost = SP_OPTION_RECIPE_COST,
		Librams = SP_OPTION_LIBRAM,
		Darkmoon = SP_OPTION_DARKMOON,
		AD = SP_OPTION_AD,
		ZG = SP_OPTION_ZG.." "..GFWUtils.Gray(SP_OPTION_ZG_FACTION),
		AQ20 = SP_OPTION_AQ20.." "..GFWUtils.Gray(SP_OPTION_AQ20_FACTION),
		AQ40 = SP_OPTION_AQ40.." "..GFWUtils.Gray(SP_OPTION_AQ40_FACTION),
		PostToRaid = SP_OPTION_POST_RAID,
	};
	
	local s, widget, lastWidget;
	s = panel:CreateFontString("SP_OptionsPanel_GeneralHeader", "ARTWORK", "GameFontNormal");
	s:SetPoint("TOPLEFT", panel.contentAnchor, "BOTTOMLEFT", 0, -16);
	s:SetText(SP_OPTIONS_GENERAL);
	lastWidget = s;

	widget = panel:CreateCheckButton("Recipes", true);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", -2, -2);
	lastWidget = widget;
	
	widget = panel:CreateCheckButton("ShowCost", true);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 16, -2);
	lastWidget.dependentControls = { widget };
	lastWidget = widget;

	widget = panel:CreateCheckButton("Librams", true);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", -16, -2);
	lastWidget = widget;

	widget = panel:CreateCheckButton("Darkmoon", true);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -2);
	lastWidget = widget;

	widget = panel:CreateCheckButton("AD", true);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -2);
	lastWidget = widget;
	
	s = panel:CreateFontString("SP_OptionsPanel_RaidHeader", "ARTWORK", "GameFontNormal");
	s:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 2, -16);
	s:SetText(SP_OPTIONS_RAID);
	lastWidget = s;

	widget = panel:CreateCheckButton("ZG", true);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", -2, -2);
	lastWidget = widget;

	widget = panel:CreateCheckButton("AQ20", true);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -2);
	lastWidget = widget;

	widget = panel:CreateCheckButton("AQ40", true);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -2);
	lastWidget = widget;

	widget = panel:CreateCheckButton("PostToRaid", true);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -2);

end

function SP_ShowOptions()
	InterfaceOptionsFrame_OpenToCategory(SP_OptionsPanel);
end

function SwindlerPreventer:Initialize()
	self.defaults = { 
		profile = {
			NoRecipes = false,
			NoShowCost = false,
			NoLibrams = false,
			NoDarkmoon = false,
			NoAD = false,
			NoZG = false,
			NoAQ20 = false,
			NoAQ40 = false,
			NoPostToRaid = false,
		}
	};
	self.db = self:InitializeDB("SwindlerPreventerDB", self.defaults);
	SP_Config = self.db.profile;
end

function SwindlerPreventer:Enable()
	-- conditionalize 2.4 stuff for now so we can run on 2.3
	if (InterfaceOptions_AddCategory) then
		GFWOptions:CreateMainPanel("SwindlerPreventer", "SP_OptionsPanel");
		SP_OptionsPanel.BuildUI = buildOptionsUI;
	end
end

SwindlerPreventer = DongleStub("Dongle-1.2"):New("SwindlerPreventer", SwindlerPreventer);

