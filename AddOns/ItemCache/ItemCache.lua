function ItemCache_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED");
	SLASH_ItemCache1 = "/ic";
	SlashCmdList["ItemCache"] = function(msg)
		ItemCache_SlashCommandHandler(msg);
	end
end

function ItemCache_OnEvent(event)
	if (DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage("ItemCache 1.1 Loaded! (/ic for options)",1.5,1,0.5);
	end
end

function ItemCache_MakeLink(sLink, sName, rarity)
	local r,g,b,hex = GetItemQualityColor(rarity)
	s = format("%s|H%s|h[%s]|h|r",hex,sLink,sName);
	return s;
end

function ItemCache_SlashCommandHandler ( msg )
	if ( msg ) then
		msg = string.lower( msg );
		local aug = {};
		for word in string.gmatch(msg, "%S+") do 
			tinsert(aug, word);
		end
		
		local command = aug[1];
		tremove(aug, 1);
		local searchstring = table.concat(aug, " ");
		
		if command == "find" then
			local found = 0;
			for i=1,30000 do
				local sName, sLink, rarity = GetItemInfo(i);
				if sName then
					if (string.find(strupper(sName), strupper(searchstring))) then
						DEFAULT_CHAT_FRAME:AddMessage(i .. " " .. ItemCache_MakeLink(sLink, sName, rarity), 1,0,0);
					found = found + 1;
					end;
				end
				if (found >= 15) then
					break
				end
			end
			if found == 1 then
				DEFAULT_CHAT_FRAME:AddMessage(found .. " item found.");
			else
				DEFAULT_CHAT_FRAME:AddMessage(found .. " items found.");
			end

			
		elseif command == "iteminfo" then
			local name,link,rarity,minlevel,itemtype,subtype,stackcount,equiploc,texture = GetItemInfo(tonumber(aug[1]));
			if name then
				DEFAULT_CHAT_FRAME:AddMessage("name="..name..", link="..link..", rarity="..rarity..", minlevel="..minlevel);
			else
				DEFAULT_CHAT_FRAME:AddMessage("itemId "..aug[1].." not found in cache.")
			end
			
		elseif command == "dump" then
			link=GetContainerItemLink(0,1);
			if link then
				local t={}, v, f;
				for i=1,strlen(link) do
					v = strbyte(link,i);
					if v==124 then 
						f="||";
					else 
						f="%c";
					end
					tinsert(t,format(f,v));
				end;
				DEFAULT_CHAT_FRAME:AddMessage(table.concat(t,""))
			end

		elseif command == "rar" then
			local found = 0;
			for i=1,30000 do
				local sName, sLink, rarity = GetItemInfo(i);
				if sName then
					if format("%d",rarity) == searchstring then
						DEFAULT_CHAT_FRAME:AddMessage(i .. " " .. ItemCache_MakeLink(sLink, sName, rarity), 1,0,0);
						found = found + 1;
					end
					if found == 20 then
						break
					end
				end
			end
		else
			-- DEFAULT_CHAT_FRAME:AddMessage("/ic iteminfo <itemId> - show info about item");
			DEFAULT_CHAT_FRAME:AddMessage("/ic find <text> - find item in database with <text> in the name");
			-- DEFAULT_CHAT_FRAME:AddMessage("/ic dump - dump raw link to item in first slot in backpack");
		end
	end
end