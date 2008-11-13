local CharactersViewer=CharactersViewer

if ( CharactersViewer.Api == nil ) then
	CharactersViewer.Api = {};
end

CharactersViewer.CP = {};
CharactersViewer.CP.Slot ={"Head","Neck","Shoulder","Shirt","Chest","Waist","Legs","Feet","Wrist","Hands","Finger0","Finger1","Trinket0","Trinket1","Back","MainHand","SecondaryHand","Ranged","Tabard"};CharactersViewer.CP.Slot[0]="Ammo";
CharactersViewer.CP.StatsLowerCase ={"strength", "agility", "stamina", "intellect", "spirit"};
CharactersViewer.CP.Stats ={"Strength", "Agility", "Atamina", "Intellect", "Spirit"};
CharactersViewer.CP.ResistLowerCase ={"arcane", "fire", "nature", "frost", "shadow"};

-- Localize static data
local CharactersViewer=CharactersViewer
local myProfile=myProfile
local CPSlot=CharactersViewer["CP"]["Slot"]

-- updated
CharactersViewer.Api.GetInventoryItem = function ( SlotId, param)
	--[[ Api description
		Required input: 
			SlotId	-> must be numerical, it correspond to the Blizzard SlotId
		Optional input:
			param	-> if set to true, will return full information, else the function will return only the itemLink
	--]]

	local temp;
	
	if ((CharactersViewerConfig == nil or CharactersViewerConfig.source == nil or CharactersViewerConfig.source == "CP")) then
		-- Implement the CharacterProfiler Data return
		local realCPSlotId=CPSlot[SlotId]
		if(realCPSlotId) then
			-- Incremental traversal to save table lookups
			local itemData=myProfile and myProfile[CharactersViewer.indexServer]
			itemData=itemData and itemData["Character"]
			itemData=itemData and itemData[CharactersViewer.index]
			itemData=itemData and itemData["Equipment"]
			itemData=itemData and itemData[CPSlot[SlotId]]

			if (itemData) then 
				if ( param == true) then 
					temp={}
					temp["itemLink"] 	= itemData.Item;
					temp["itemTexture"] 	= "Interface\\Icons\\"..itemData.Icon;
					temp["itemCount"] 	= itemData.Quantity;
					temp["itemColor"] 	= itemData.Color;
					temp["itemName"] 	= itemData.Name;
					temp["itemTooltip"] 	= itemData.Tooltip;
				else
					temp=itemData.Item;
				end
			end
		end
	end

	-- Output the data according to the desired param
	if(not temp and param==true) then return { itemLink = nil } end
	return temp;
end;

CharactersViewer.Api.GetInventorySlot = function ( param )
	--[[ Api description
		Purpose: This function is meant to return the  list of slot with information available for the current selected CV player
		Optional input:
			param	-> not used yet
	--]]
	
	local temp = {};
	local index, i;
	i=0;
	
	if ( param == nil or param ~= true ) then 
		param = false;
	end
	
	-- Implement the CharacterProfiler Data return
	if ( myProfile ~= nil	
		and myProfile[CharactersViewer.indexServer] ~= nil
		and myProfile[CharactersViewer.indexServer]["Character"][CharactersViewer.index] ~= nil
		and myProfile[CharactersViewer.indexServer]["Character"][CharactersViewer.index]["Equipment"] ~= nil ) then
			for index = 0, 19 do
				if ( CharactersViewer["CP"]["Slot"][index] ~= nil and myProfile[CharactersViewer.indexServer]["Character"][CharactersViewer.index]["Equipment"][CharactersViewer["CP"]["Slot"][index]] ~= nil ) then 
					temp[i] = index;
					i=i+1;
				end
			end
	end
	return temp;
end;

-- new function
CharactersViewer.Api.getCPContainerData = function (id)
	local section, bag
	if ( id >= 0 and id <= 4 ) then
                section, bag = "Inventory", "Bag"..id;
        elseif (id == 19 ) then
                section, bag = "Bank", "Bag0";
        elseif (id >= 5 and id <= 11) then
                section, bag =  "Bank", "Bag"..(id-4)
        elseif ( id == -2 ) then
                section, bag = "Inventory", "Bag5" ;
	end
	local bagData=myProfile and myProfile[CharactersViewer.indexServer]
	bagData=bagData and bagData["Character"]
	bagData=bagData and bagData[CharactersViewer.index]
	bagData=bagData and bagData[section]
	return bagData and bagData[bag]
end

-- updated
CharactersViewer.Api.getContainerSize= function (id)
	local bagData = CharactersViewer.Api.getCPContainerData(id)
	if ( bagData ) then
		return bagData.Slots
	--elseif ( id == -2 ) then
	--	return 4;
	else
		return 0;
	end
end

-- udated
CharactersViewer.Api.getContainerTexture= function (id)
	local bagData = CharactersViewer.Api.getCPContainerData(id)
	if ( bagData ) then return  "Interface\\Icons\\"..bagData.Icon else return nil end
end

-- udated
CharactersViewer.Api.getContainerName= function (id)
	local bagData = CharactersViewer.Api.getCPContainerData(id)
	if ( bagData ) then return bagData.Name else return nil	end
end

-- updated
function CharactersViewer.Api.getContainer(id)
	local bagData = CharactersViewer.Api.getCPContainerData(id)
	if ( bagData ) then
			local temp = {};
			temp["itemLink"] 	= bagData.Item;
			temp["itemTexture"] 	= "Interface\\Icons\\"..bagData.Icon;
			temp["itemCount"] 	= bagData.Quantity;
			temp["itemColor"] 	= bagData.Color;
			temp["itemName"] 	= bagData.Name;
			temp["itemTooltip"] 	= bagData.Tooltip;
			temp["itemSlots"] 	= bagData.Slots;
			return temp;
	else
		return nil;
	end
end

CharactersViewer.Api.getContainerItem = function(id, j)
	local section, bag = CharactersViewer.Api.getCPContainer(id);
	local arraytemp = {};
	local array = {}
	if ( bag ~= nil ) then 
		if ( myProfile ~= nil
			and myProfile[CharactersViewer.indexServer] ~= nil
			and myProfile[CharactersViewer.indexServer]["Character"][CharactersViewer.index] ~= nil
			and myProfile[CharactersViewer.indexServer]["Character"][CharactersViewer.index][section] ~= nil  
			and myProfile[CharactersViewer.indexServer]["Character"][CharactersViewer.index][section][bag] ~= nil
			and myProfile[CharactersViewer.indexServer]["Character"][CharactersViewer.index][section][bag]["Contents"] ~= nil
			and myProfile[CharactersViewer.indexServer]["Character"][CharactersViewer.index][section][bag]["Contents"][j] ~= nil ) then
				arraytemp = myProfile[CharactersViewer.indexServer]["Character"][CharactersViewer.index][section][bag]["Contents"][j];
		else
			return nil;
		end
	else
		if ( myProfile ~= nil
			and myProfile[CharactersViewer.indexServer] ~= nil
			and myProfile[CharactersViewer.indexServer]["Character"][CharactersViewer.index] ~= nil
			and myProfile[CharactersViewer.indexServer]["Character"][CharactersViewer.index][section] ~= nil  
			and myProfile[CharactersViewer.indexServer]["Character"][CharactersViewer.index][section]["Contents"] ~= nil
			and myProfile[CharactersViewer.indexServer]["Character"][CharactersViewer.index][section]["Contents"][j] ~= nil ) then
				arraytemp = myProfile[CharactersViewer.indexServer]["Character"][CharactersViewer.index][section]["Contents"][j];
		else
			return nil;
		end
	end

	array.Texture = "Interface\\Icons\\"..arraytemp["Icon"];
	array.Quantity = arraytemp.Quantity;
	array.Size = arraytemp.Slots;
	array.Name = arraytemp.Name;
	array.Color = arraytemp.Color;
	array.itemTooltip = arraytemp.Tooltip;
	array.itemLink = arraytemp.Item;

	return array;
end;

-- updated
CharactersViewer.Api.getCPContainer = function (id)
       if ( id >= 0 and id <= 4 ) then
                return "Inventory", "Bag"..id;
        elseif (id == 19 ) then
                return "Bank", "Bag0";
        elseif (id >= 5 and id <= 11) then
                return "Bank", "Bag"..(id-4)
        elseif ( id == -2 ) then
                return "Inventory", "Bag5" ;
	end
end

CharactersViewer.Api.splitstring = function ( input )                      -- CharactersViewer.library.splitstrin
	 local list = {};
	 local i = 0;
	 for w in string.gmatch(input, "([^ ]+)") do
		  list[i] = w;
		  i = i + 1;
	 end
	 return list
end;

CharactersViewer.Api.splitstats = function ( input )
	if ( input ~= nil ) then
		local list = {};
		local i = 0;
		for w in string.gmatch(input, "(%d+)") do
		  list[i] = tonumber(w);
		  i = i + 1;
		end
		return list[0], list[1], list[2], list[3], list[4];
	else
		return 0,0,0,0,0;
	end
end;

CharactersViewer.Api.MakeLink = function(link)                               -- CharactersViewer.library.MakeLink
	local temp = link;
	if( link and string.sub(link,1,5) == "item:") then
		local name,_,quality = GetItemInfo(link);
		local color = CharactersViewer.Api.returnColor(quality);
		if(name) then
			temp = "|c"..color.."|H"..link.."|h["..name.."]|h|r";
		else
			temp = false;
		end
	end
	return temp;
end;

CharactersViewer.Api.returnColor = function (quality)                        -- CharactersViewer.library.returnColor
	color = {
		[0] = "ff9d9d9d",    -- poor, gray
		[1] = "ffffffff",    -- common, white
		[2] = "ff1eff00",    -- uncommon, green
		[3] = "ff0070dd",    -- rare, blue
		[4] = "ffa335ee",    -- epic, purple
		[5] = "ffff8000",    -- legendary, orange
	}
	return color[quality];
end;

CharactersViewer.gui = {};
CharactersViewer.gui.ItemButton = {};
CharactersViewer.gui.ItemButton.OnClick = function (button)
	rpgoCP_EventHandler('RPGOCP_SCAN');
	local id, item, link, longlink;
	id = this:GetID();
	
	if(id >= 0 and id <= 19) then
		-- Equipement slot
		item = CharactersViewer.Api.GetInventoryItem( id, true );
	elseif ( ( id > -100 and id < 0 ) or  (id >=100 and id <=599 ) or (id >= 600 and id <= 1299) or ( id >= 2000 and id < 2100 ) ) then
		local Slot, Container = CharactersViewer.Api.ContainerSlotFromId( id );
		item = CharactersViewer.Api.getContainerItem  ( Container,  Slot);
	end
	
	if( item ~= nil and item["itemLink"] ) then
		link = item["itemLink"];
		longlink = CharactersViewer.Api.MakeLink( "item:"..link )
	
		if ( button == "LeftButton" ) then
			if ( IsControlKeyDown() and not ignoreModifiers ) then
				DressUpItemLink("item:"..link);
			elseif ( IsShiftKeyDown() and not ignoreModifiers ) then
				if ( ChatFrameEditBox:IsShown() ) then
					ChatFrameEditBox:Insert(longlink);
				else
					-- PlaceHolder
				end
			else
				-- PlaceHolder
			end
		end	
		
		-- Component interaction, http://www.curse-gaming.com/mod.php?addid=1256, added by Flisher 2005-06-16
		-- CharactersViewerItemButton_OnClick must be kept in backtracking ability CharactersViewer.button.onclick();
		if(Comp_TestOnClick and Comp_TestOnClick() and link) then
			return Comp_OnClick(arg1, link);
		end
	end
end;


function CharactersViewer.gui.ItemButton.OnEnter(tooltip, id)                        -- Cleaned by Flisher 2005-05-31
	--rpgoCP_EventHandler('RPGOCP_SCAN');
	local item, link, text, flag
	local bypass = false;		-- used to bypass the tooltip

	-- Detecting if it's from the inventory or equipment
	text = UNKNOWN;
	if ( id == nil ) then
		id = this:GetID();
		flag = true;
	else
		flag = false;
	end
	if ( tooltip == nil ) then
		-- Default Tooltip
		tooltip = getglobal("GameTooltip");
	else
		-- Tooltip from external source (like EquipCompare)
	end
	if(id >= 0 and id <= 19) then
		if ( CharactersViewer.indexSelf == false) then
			item = CharactersViewer.Api.GetInventoryItem( id, true );
			text = CharactersViewer.constant.inventorySlot.Name[id];
		else
			item = GetInventoryItemLink("player", id);
			bypass = true;
		end
	elseif ( ( id > -100 and id < 0 ) or  (id >=100 and id <=599 ) or (id >= 600 and id <= 1299) or ( id >= 2000 and id < 2100 ) ) then
		local Slot, Container = CharactersViewer.Api.ContainerSlotFromId( id );
		item = CharactersViewer.Api.getContainerItem  ( Container,  Slot);
		if ( item == nil ) then
			text = EMPTY;
		end
	end

	---- todo: Regenate full link
	if ( flag == true ) then
		ShowUIPanel(tooltip);
		tooltip:SetOwner(this, "ANCHOR_RIGHT");
	end
	
	if ( bypass == true and item ~= nil ) then
		tooltip:SetHyperlink(item);
	elseif( item ~= nil and item["itemLink"] ) then
		if( GetItemInfo("item:" .. item["itemLink"]) ) then
			tooltip:SetHyperlink("item:" .. item["itemLink"]);
		elseif ( item ~= nil and item["itemTooltip"] ~= nil ) then
			tooltip:SetText(item["itemTooltip"]);
		elseif ( item ~= nil and item["Name"] ~= nil ) then
			tooltip:SetText(item["Name"]);
		end
	else
		tooltip:SetText(text);
	end

	if ( CharactersViewer.index ~= nil and CharactersViewer.index ~= UnitName("player") and CharactersViewer.indexServer ~= nil and CharactersViewer.indexServer ~= GetRealmName()) then
		tooltip:AddLine(CharactersViewer.index .. " " .. INVENTORY_TOOLTIP);
		tooltip:Show();
	else
		tooltip:Show();
	end

	-- Book of Crafts inter-operability (http://www.curse-gaming.com/mod.php?addid=1397)
	if(BookOfCrafts_UpdateGameToolTips and link) then
		BookOfCrafts_UpdateGameToolTips();
	end

	if( RecipeBook_DoHookedFunction ) then
		RecipeBook_DoHookedFunction();
	end
	
end;

CharactersViewer.Api.GetParam = function (param, character, server)
	if ( character == nil ) then
		character = CharactersViewer.index;
	end
	if ( server == nil ) then
		server = CharactersViewer.indexServer;
	end
 
	if ( myProfile ~= nil and myProfile[server] ~= nil and myProfile[server]["Character"][character] ~= nil ) then   
		if ( param == "level" ) then
			return tostring( myProfile[server]["Character"][character].Level);
		elseif ( param == "name" ) then
			return tostring( myProfile[server]["Character"][character].Name);
		elseif ( param == "server" ) then
			return tostring( myProfile[server]["Character"][character].Server);
		elseif ( param == "class" ) then	
			return tostring( myProfile[server]["Character"][character].Class);
		elseif ( param == "race" ) then	
			return tostring( myProfile[server]["Character"][character].Race);
		elseif ( param == "raceen" ) then	
			return tostring( myProfile[server]["Character"][character].RaceEn);
		elseif ( param == "sex" ) then	
			return tostring( myProfile[server]["Character"][character].Sex);
		elseif ( param == "sexid" ) then	
			return tonumber( myProfile[server]["Character"][character].SexId) or 0;
		
		elseif ( param == "isresting" ) then	
			return myProfile[server]["Character"][character].IsResting;

		elseif ( param == "xptimestamp" ) then	
			if ( myProfile[server]["Character"][character].timestamp ~= nil and myProfile[server]["Character"][character].timestamp.Attributes ~= nil ) then
				return myProfile[server]["Character"][character].timestamp.Attributes;
			else
				return nil;
			end

		elseif ( param == "xp" ) then	
			return myProfile[server]["Character"][character].Experience;

		elseif ( param == "health" ) then
			return tostring( myProfile[server]["Character"][character].Health);
		elseif ( param == "mana" ) then
			return tostring( myProfile[server]["Character"][character].Mana);
		elseif ( param == "powertype" ) then
			return tostring( myProfile[server]["Character"][character].Power);		

		elseif ( param == "crit" ) then
			return myProfile[server]["Character"][character]["Attributes"]["Melee"]["CritChance"];
		elseif ( param == "block" ) then
			return myProfile[server]["Character"][character]["Attributes"]["Defense"]["BlockChance"];		
		elseif ( param == "dodge" ) then
			return myProfile[server]["Character"][character]["Attributes"]["Defense"]["DodgeChance"];		
		elseif ( param == "parry" ) then
			return myProfile[server]["Character"][character]["Attributes"]["Defense"]["ParryChance"];		
		elseif ( param == "defense" ) then
			return myProfile[server]["Character"][character]["Attributes"]["Defense"]["DefensePercent"];		

		elseif ( param == "money" ) then
			if ( myProfile[server]["Character"][character].Money ) then
				local temp = 0;
				if ( myProfile [server]["Character"][character].Money.Copper ) then
					temp = temp + myProfile[server]["Character"][character].Money.Copper;
				end
				if ( myProfile [server]["Character"][character].Money.Silver ) then
					temp = temp + myProfile[server]["Character"][character].Money.Silver * 100;
				end
				if ( myProfile [server]["Character"][character].Money.Gold ) then
					temp = temp + myProfile[server]["Character"][character].Money.Gold * 10000;
				end
				return temp;
			else
				return 0;
			end
		elseif ( param == "splitmoney" ) then
			local gold = 0;
			local copper = 0;
			local silver = 0;
			if ( myProfile[server]["Character"][character].Money ) then
				if ( myProfile [server]["Character"][character].Money.Copper ) then
					copper = myProfile[server]["Character"][character].Money.Copper;
				end
				if ( myProfile [server]["Character"][character].Money.Silver ) then
					silver = myProfile[server]["Character"][character].Money.Silver;
				end
				if ( myProfile [server]["Character"][character].Money.Gold ) then
					gold = myProfile[server]["Character"][character].Money.Gold;
				end
			end
				return gold, silver, copper;

		elseif ( param == "alliancemoney" ) then
			local temp = 0;
			for index, character in pairs(myProfile[server]["Character"]) do
				if ( character.FactionEn ~= nil and character.FactionEn == "Alliance" and character.Money ~= nil) then
					if ( character.Money.Copper ) then
						temp = temp + character.Money.Copper;
					end
					if ( character.Money.Silver ) then
						temp = temp + character.Money.Silver * 100;
					end
					if ( character.Money.Gold ) then
						temp = temp + character.Money.Gold * 10000;
					end	
				end
			end		
			return temp;	

		elseif ( param == "hordemoney" ) then
			local temp = 0;
			for index, character in pairs(myProfile[server]["Character"]) do
				if ( character.FactionEn ~= nil and character.FactionEn == "Horde" and character.Money ~= nil) then
					if ( character.Money.Copper ) then
						temp = temp + character.Money.Copper;
					end
					if ( character.Money.Silver ) then
						temp = temp + character.Money.Silver * 100;
					end
					if ( character.Money.Gold ) then
						temp = temp + character.Money.Gold * 10000;
					end	
				end
			end		
			return temp;
	
		elseif ( param == "servermoney" ) then
			return CharactersViewer.Api.GetParam("alliancemoney") + CharactersViewer.Api.GetParam("hordemoney");
			
		elseif ( param == "faction" ) then
			return myProfile[server]["Character"][character].Faction;		
		elseif ( param == "factionEn" ) then
			return myProfile[server]["Character"][character].Faction;		
				
		elseif ( param == "strength" ) then
			return myProfile[server]["Character"][character]["Attributes"]["Stats"].Strength;
		elseif ( param == "agility" ) then
			return myProfile[server]["Character"][character]["Attributes"]["Stats"].Agility;
		elseif ( param == "stamina" ) then
			return myProfile[server]["Character"][character]["Attributes"]["Stats"].Stamina;
		elseif ( param == "intellect" ) then
			return myProfile[server]["Character"][character]["Attributes"]["Stats"].Intellect;
		elseif ( param == "spirit" ) then
			return myProfile[server]["Character"][character]["Attributes"]["Stats"].Spirit	;
		
		elseif ( param == "armor" ) then
			return myProfile[server]["Character"][character]["Attributes"]["Defense"].Armor;

		elseif ( param == "guildname" ) then		
			if ( myProfile[server]["Character"][character]["Guild"] ~= nil ) then
				return myProfile[server]["Character"][character]["Guild"].GuildName;
			end
		elseif ( param == "guildrank" ) then				
			if ( myProfile[server]["Character"][character]["Guild"] ~= nil ) then
				return myProfile[server]["Character"][character]["Guild"].Rank;
			end
		elseif ( param == "guildtitle" ) then				
			if ( myProfile[server]["Character"][character]["Guild"] ~= nil ) then
				return myProfile[server]["Character"][character]["Guild"].Title;
			end
		
		elseif ( param == "pvprank" ) then				
			if ( myProfile[server]["Character"][character]["Honor"] ~= nil and myProfile[server]["Character"][character]["Honor"].Current ~= nil ) then
				return myProfile[server]["Character"][character]["Honor"].Current.Rank or "";
			else
				return "";
			end
		elseif ( param == "hk" ) then				
			if ( myProfile[server]["Character"][character]["Honor"] ~= nil) then
				return myProfile[server]["Character"][character]["Honor"].LifetimeHK or "";
			else
				return 0;
			end
		elseif ( param == "dk" ) then				
			if ( myProfile[server]["Character"][character]["Honor"] ~= nil) then
				return myProfile[server]["Character"][character]["Honor"].LifetimeDK or "";
			else
				return 0;
			end
		elseif ( param == "weekhk" ) then				
			if ( myProfile[server]["Character"][character]["Honor"] ~= nil and myProfile[server]["Character"][character]["Honor"]["ThisWeek"] ~= nil) then
				return myProfile[server]["Character"][character]["Honor"]["ThisWeek"].HK or 0;
			else
				return 0;
			end
		elseif ( param == "weekcontrib" ) then				
			if ( myProfile[server]["Character"][character]["Honor"] ~= nil and myProfile[server]["Character"][character]["Honor"]["ThisWeek"] ~= nil) then
				return myProfile[server]["Character"][character]["Honor"]["ThisWeek"].Contribution or 0;
			else
				return 0;
			end
			


		elseif ( param == "resistfrost" ) then				
			return myProfile[server]["Character"][character]["Attributes"]["Resists"].Frost;
		elseif ( param == "resistfire" ) then				
			return myProfile[server]["Character"][character]["Attributes"]["Resists"].Fire;
		elseif ( param == "resistnature" ) then			
			return myProfile[server]["Character"][character]["Attributes"]["Resists"].Nature;
		elseif ( param == "resistshadow" ) then			
			return myProfile[server]["Character"][character]["Attributes"]["Resists"].Shadow;
		elseif ( param == "resistarcane" ) then			
			return myProfile[server]["Character"][character]["Attributes"]["Resists"].Arcane;

		elseif ( param == "damagerange1" ) then			
			if ( myProfile[server]["Character"][character]["Attributes"]["Melee"] ~= nil) then
				return myProfile[server]["Character"][character]["Attributes"]["Melee"]["MainHand"]["DamageRange"];
			end
		elseif ( param == "damagerange2" ) then			
			if ( myProfile[server]["Character"][character]["Attributes"]["Melee"] ~= nil) then
				return myProfile[server]["Character"][character]["Attributes"]["Melee"]["MainHand"]["DamageRange"];
			end 
			
		elseif ( param == "attackspeed1" ) then			
			if ( myProfile[server]["Character"][character]["Attributes"]["Melee"] ~= nil) then
				return myProfile[server]["Character"][character]["Attributes"]["Melee"]["MainHand"]["AttackSpeed"];
			end
		elseif ( param == "attackspeed2" ) then			
			if ( myProfile[server]["Character"][character]["Attributes"]["Melee"] ~= nil) then
				return myProfile[server]["Character"][character]["Attributes"]["Melee"]["MainHand"]["AttackSpeed"];
			end
		elseif ( param == "attackpower" ) then			
			if ( myProfile[server]["Character"][character]["Attributes"]["Melee"] ~= nil) then
				return myProfile[server]["Character"][character]["Attributes"]["Melee"]["AttackPowerDPS"];
			end

		elseif ( param == "hasrelic" ) then			
			return myProfile[server]["Character"][character].HasRelic;
		
		elseif ( param == "rangeddamage" ) then			
			if ( myProfile[server]["Character"][character]["Attributes"]["Ranged Attack"] ~= nil) then
				return myProfile[server]["Character"][character]["Attributes"]["Ranged Attack"].DamageRangeBase;
			end	
		elseif ( param == "rangedattackrating" ) then			
			if ( myProfile[server]["Character"][character]["Ranged Attack"] ~= nil) then
				return myProfile[server]["Character"][character]["Ranged Attack"].AttackRating;
			end	
		elseif ( param == "rangedattackspeed" ) then			
			if ( myProfile[server]["Character"][character]["Ranged Attack"] ~= nil) then
				return myProfile[server]["Character"][character]["Ranged Attack"].AttackSpeed;
			end
		elseif ( param == "rangedttackpower" ) then			
			if ( myProfile[server]["Character"][character]["Ranged Attack"] ~= nil) then
				return myProfile[server]["Character"][character]["Ranged Attack"].AttackPower;
			end
		elseif ( param == "haswandequipped" ) then
			return myProfile[server]["Character"][character].HasWandEquipped;
		elseif ( param == "hasranged" ) then
			return myProfile[server]["Character"][character]["Ranged Attack"] ~= nil or false;
		elseif ( param == "location" ) then			
			local temp = "";
			if ( myProfile[server]["Character"][character].SubZone ~= nil) then
				temp = " (" .. myProfile[server]["Character"][character].SubZone .. ")";
			end
			if ( myProfile[server]["Character"][character].Zone ~= nil) then
				temp = myProfile[server]["Character"][character].Zone .. temp;
			end
			return temp;
		
		elseif ( param == "bankexist" ) then
			if (myProfile[server]["Character"][character].Bank ~= nil ) then
				return true;
			else
				return false;
			end
		elseif (param == "banktimestamp" ) then
			if (myProfile[server]["Character"][character].timestamp ~= nil and myProfile[server]["Character"][character].timestamp.Bank ~= nil) then
				return date("!%m/%d/%y %H:%M:%S", myProfile[server]["Character"][character].timestamp.Bank);
			else
				return "";
			end
		else 
			return "N/A";
		end
	end

end;

CharactersViewer.Api.ContainerSlotFromId = function( id )
		return mod(id+100,100) , floor((id-100)/100) ;
end;

function CharactersViewer.Api.CalcRestedXP(data, isresting, timestamp)
	 local temp = {
		  estimated = 0;
		  levelratio = 0;
		  percentrested = 0;
	 }
	 local current,level,bonus;
	 
	 _,_,current,level,bonus = string.find(data,"(%d+):(%d+):(%d+)");
	 	 
	 if(data and bonus and isresting ~= nil and level and timestamp) then
		  local speed = isresting and 4 or 1;
		  local estimated = bonus;
		  if(timestamp < time()) then
				estimated = bonus + floor((time()-timestamp) * level * 1.5 / 864000 / 4 * speed);
				if(estimated  > (level * 1.5) ) then
					 estimated = (level * 1.5);
				end
		  end
		  temp = {
				estimated = estimated;
				levelratio = floor(estimated/level *10)/10;
				percentrested = floor(estimated / (level  *1.5) *100)/100;
		  }
	 end
	 return temp;
end;

function CharactersViewer.Api.GetConfig(param)
	if ( CharactersViewerConfig ~= nil and param ~= nil) then
		return CharactersViewerConfig[param];
	else
		return nil;
	end
end

function CharactersViewer.Api.SetConfig(param, value)
	if ( CharactersViewerConfig == nil ) then
		CharactersViewerConfig = {};
	end
	CharactersViewerConfig[param] = value; 
end
				
--function CharactersViewer.Api.GetCharactersList(option)			-> In CharactersViewer.lua

-- Legacy Support
CharactersViewer.Switch = CharactersViewer.Api.Switch;
CharactersViewerItemButton_OnClick = CharactersViewer.gui.ItemButton.OnClick;
CharactersViewer_Tooltip_SetInventoryItem = CharactersViewer.gui.ItemButton.OnEnter;
