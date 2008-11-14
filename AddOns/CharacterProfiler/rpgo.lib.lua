local VERSION = 03000001
if(not rpgo) then rpgo={}; end
if(not rpgo.db) then rpgo.db={}; end
rpgo.db.class = {WARRIOR=1,PALADIN=2,HUNTER=3,ROGUE=4,PRIEST=5,DEATHKNIGHT=6,SHAMAN=7,MAGE=8,WARLOCK=9,DRUID=11};
rpgo.db.race = {Human=1,Orc=2,Dwarf=3,NightElf=4,Scourge=5,Tauren=6,Gnome=7,Troll=8,BloodElf=10,Draenei=11};
--[[########################################################
--## general functions
--######################################################--]]
--[UnitSex] arg1:unit
rpgo.UnitSex = function(arg1)
	local UnitSexLabel={UNKNOWN,MALE,FEMALE};
	local unitSexID=UnitSex(arg1);
	return UnitSexLabel[unitSexID],mod(unitSexID,2);
end

--[UnitClass] arg1:unit
rpgo.UnitClass = function(arg1)
	local unitClass,unitClassEn=UnitClass(arg1);
	return unitClass,unitClassEn,rpgo.db.class[unitClassEn];
end
--[UnitClass] arg1:unit
rpgo.UnitClassID = function(classEn)
	return rpgo.db.class[classEn];
end
--[UnitRace] arg1:unit
rpgo.UnitRace = function(arg1)
	local unitRace,unitRaceEn=UnitRace(arg1);
	return unitRace,unitRaceEn,rpgo.db.race[unitRaceEn];
end
--[UnitHasResSickness]
rpgo.UnitHasResSickness = function(unit)
	local idx=1;
	if(UnitDebuff(unit,idx)) then
		while(UnitDebuff(unit,idx)) do
			buffTexture=UnitDebuff(unit,idx);
			if(buffTexture == "Interface\\Icons\\Spell_Shadow_DeathScream") then
				return true;
			end
			idx=idx+1;
		end
	end
	return nil;
end

--[parseMoney]
rpgo.parseMoney = function(money)
	local gold,silver,copper;
	local COPPER_PER_GOLD=COPPER_PER_SILVER * SILVER_PER_GOLD;
	gold=floor(money/COPPER_PER_GOLD);
		money=mod(money,COPPER_PER_GOLD);
	silver=floor(money/COPPER_PER_SILVER);
		copper=mod(money,COPPER_PER_SILVER);
	return gold,silver,copper;
end
--[rpgo.round](num,[digit])
rpgo.round = function(num,digit)
	if(not tonumber(num)) then return nil; end
	if(digit==nil) then digit=0; end
--	local shift=10^digit;
--	return floor( num*shift + 0.5 ) / shift;
	if(num==0) then return num; end
	local fmt
	if(digit<10) then fmt="%.0"..digit.."f";
	else fmt="%."..digit.."f"; end
	return format(fmt,num);
end
--[function] str
rpgo.version = function()
	local version,_,_ = GetBuildInfo();
	local _,_,version,major,minor=string.find(version,"(%d+).(%d+).(%d+)");
	return tonumber(version),tonumber(major),tonumber(minor);
end
rpgo.versionkey = function()
	local version,buildnum,_ = GetBuildInfo();
	return strjoin(":", rpgo.GetSystem(),version,buildnum);
end
--[function] str
rpgo.GetSystem = function()
	local _,_,sys=string.find(GetCVar("realmList"),"^[%a.]-(%a+).%a+.%a+.%a+$");
	if(not sys) then sys="" end return sys;
end

--[[########################################################
--## date functions
--######################################################--]]
--[Date2Epoch](datestr)
if(not rpgo.Date2Epoch) then
rpgo.Date2Epoch = function(datestr)
	local epoch;
	if(datestr) then
		local _,_,y,m,d,h,n,s=string.find(datestr,"(%d%d%d%d)-(%d%d)-(%d%d) (%d%d):(%d%d):(%d%d)");
		epoch = time( {year=y,month=m,day=d,hour=h,min=n,sec=s} );
	end
	return epoch;
end
end

if(not rpgo.tablecopy) then
rpgo.tablecopy = function(to,from)
	for k,v in pairs(from) do
		if(type(v)=="table") then
			to[k] = {};
			rpgo.tablecopy(to[k], v);
		else
			to[k] = v;
		end
	end
end
end

--[[########################################################
--## item functions
--######################################################--]]
--[GetContainerNumSlots]
rpgo.GetContainerNumSlots = function(bagID)
	if(bagID==KEYRING_CONTAINER) then
		return GetKeyRingSize();
	else
		return GetContainerNumSlots(bagID);
	end
end
--[ItemHasGem] itemStr
rpgo.ItemHasGem = function(itemStr)
	local gid1,gid2,gid3;
	if(itemStr) then _,_,gid1,gid2,gid3=string.find(itemStr,"|Hitem:%d+:[-%d]+:([-%d]+):([-%d]+):([-%d]+):[-%d]+:[-%d]+:[-%d]+:[%d]+|h");
		if( gid1 and gid2 and gid3 and gid1+gid2+gid3 ~= 0) then
			return true;
		end
	end
	return nil;
end
--[GetItemInfo] itemStr
rpgo.GetItemInfo = function(itemStr)
	if(itemStr) then
		local itemColor,itemID;
		local itemName,itemLink,itemRarity,itemLevel,itemMinLevel,itemType,itemSubType,itemStackCount,itemEquipLoc,invTexture = GetItemInfo(itemStr);
		if(itemLink) then
			_,_,itemColor,itemID=string.find(itemLink,"|c(%x+)|Hitem:([-%d:]+)|h%[.-%]|h");
		end
		return itemColor,itemLink,itemID,itemName,invTexture;
	end
	return nil;
end
--[GetItemInfoTT] tooltip
rpgo.GetItemInfoTT = function(tooltip)
	local ttName,ttFrame
	if( tooltip ) then
		if(type(tooltip)=="string") then
			ttName=tooltip;
			ttFrame=getglobal(tooltip);
		elseif(type(tooltip)=="table" and tooltip:IsObjectType("GameTooltip")) then
			ttName=UIParent.GetName(tooltip);
			ttFrame=tooltip;
		end
	end
	local nTT,cTT,r,g,b;
	if(ttName==nil) then return end
	ttText=getglobal(ttName.."TextLeft1");
	if(ttText) then
		nTT=ttText:GetText();
	end
	if(nTT) then r,g,b=ttText:GetTextColor(); cTT=string.format("ff%02x%02x%02x",r*256,g*256,b*256); end
	return nTT,cTT;
end
--[GetItemID] itemStr
rpgo.GetItemID = function(itemStr)
	local id,rid;
	if(itemStr) then _,_,id,rid=string.find(itemStr,"|Hitem:(%d+):[-%d]+:[-%d]+:[-%d]+:[-%d]+:[-%d]+:([-%d]+):[-%d]+:[%d]+|h"); end
	return tonumber(id),tonumber(rid);
end

--[GetQuestID] questStr
rpgo.GetQuestID = function(questStr)
	local id,lvl;
	if(questStr) then _,_,id,lvl=string.find(questStr,"|Hquest:(%d+):([-%d]+)|h"); end
	return tonumber(id);
end

--[GetSpellID] spellStr
rpgo.GetSpellID = function(spellStr)
	local id;
	if(spellStr) then _,_,id=string.find(spellStr,"|Hspell:(%d+)|h"); end
	return tonumber(id);
end

--[GetTalentID] talentStr
rpgo.GetTalentID = function(talentStr)
	local id;
	if(talentStr) then _,_,id=string.find(talentStr,"|Htalent:(%d+):[-%d]+|h"); end
	return tonumber(id);
end

--[GetRecipeId] recipeStr
rpgo.GetRecipeId = function(recipeStr)
	local id;
	if(recipeStr) then _,_,id = string.find(recipeStr, "|Henchant:(%d+)|h"); end
	return tonumber(id);
end

--[[########################################################
--## tooltip functions
--######################################################--]]
--[SetTooltip] text
rpgo.SetTooltip = function(text)
	if(text) then
		GameTooltip:SetOwner(this,"ANCHOR_BOTTOMRIGHT");
		GameTooltip:SetText(text);
	end
end
--[ScanTooltipOO]
rpgo.ScanTooltipOO = function(self)
	if( not self.tooltipname ) then
		self.tooltipname=UIParent.GetName(self.tooltip);
	end
	if( not self.tooltip:IsOwned(UIParent) ) then
		self:PrintDebug("tooltip fix owner");
		self.tooltip:SetOwner(UIParent,"ANCHOR_NONE");
	end
	return rpgo.ScanTooltip(self.tooltipname,self.tooltip,self.prefs.tooltipshtml)
end
--[ScanTooltip] ttName,ttFrame,isHTML
rpgo.ScanTooltip = function(ttName,ttFrame,isHTML)
	if(ttFrame and ttFrame:NumLines()~=0) then
		local idx,ttFontStr,tmpbuff,ttText=nil,nil,nil,{};
		for idx=1,ttFrame:NumLines() do
			tmpbuff=nil;
			ttFontStr=getglobal(ttName.."TextLeft"..idx);
			if(ttFontStr and ttFontStr:IsShown()) then
				tmpbuff=ttFontStr:GetText();
				if (ttFontStr) then
					tmpbuff=string.gsub(tmpbuff,"\n","<br>");
					tmpbuff=string.gsub(tmpbuff,"\r","");
				end
			end
			ttFontStr=getglobal(ttName.."TextRight"..idx);
			if(ttFontStr and ttFontStr:IsShown() and ttFontStr:GetText()) then
				tmpbuff=tmpbuff.."\t"..ttFontStr:GetText();
			end
			if(tmpbuff) then table.insert(ttText,tmpbuff); end
		end
		ttFrame:ClearLines();
		if(isHTML) then return table.concat(ttText,"<br>");
		else return ttText; end
	end
	return nil
end

--[[########################################################
--## string functions
--######################################################--]]
--[rpgo.ParseString](msg,restruct)
if(not rpgo.ParseString) then
rpgo.ParseString = function(msg,restruct)
	local strparse={string.find(msg,restruct.str)};
	table.remove(strparse,1);
	table.remove(strparse,1);
	if( restruct.ord ) then
		local strord={};
		for i,j in pairs(restruct.ord) do
			strord[i] = strparse[i];
		end
		for i,j in pairs(restruct.ord) do
			strparse[i] = strord[tonumber(j)];
		end
	end
	return strparse
end
end
--[rpgo.ConvertString](str,anc)
if(not rpgo.ConvertString) then
rpgo.ConvertString = function(str,anc)
	local ndig,nstr
	str = string.gsub(str,"([%^%(%)%.%[%]%*%+%-%?])","%%%1");
	str,ndig = string.gsub(str, '%%(%d?%$?)d', '(%1%%d+)');
	str,nstr = string.gsub(str, '%%(%d?%$?)s', '(%1.-)');
	local ord={};
	local j = 1;
	for i in string.gmatch(str,"%((%d)%$.") do
		str = string.gsub(str, '%(%d+%$', '(', 1);
		if(tonumber(i) ~= j) then ord[j]=i end
		j=j+1;
	end
	if(anc) then str = "^"..str.."$" end
	return str,ndig+nstr,ord;
end
end

--[StripColor] str
rpgo.StripColor = function(str)
	if(not str) then return nil end
	local function strippingHelper(word) return string.gsub(word,"|c%x%x%x%x%x%x%x%x(.-)|r","%1") end
	if(type(str)=="table") then
		for i=1,table.getn(str),1 do
			str[i]=strippingHelper(str[i]);
		end
	else str=strippingHelper(str); end
	return str;
end
--[Str2Ary] str
rpgo.Str2Ary = function(str)
	local tab={};
	str = strtrim(str);
	while( str and str ~="" ) do
		local word,string;
		if( strfind(str, '^|c.+|r') ) then
			_,_,word,string = strfind( str, '^(|c.+|r)(.*)');
		elseif( strfind(str, '^"[^"]+"') ) then
			_,_,word,string = strfind( str, '^"([^"]+)"(.*)');
		else
			_,_,word,string = strfind( str, '^(%S+)(.*)');
		end
		if( word ) then
			table.insert(tab,word);
		end
		if( string ) then
			string=strtrim(string);
		end
		str = string;
	end
	return tab;
end
--[Str2Abbr] str
rpgo.Str2Abbr = function(str)
	local abbr='';
	local function S2Ahelper(word) abbr=abbr..string.sub(word,1,1) end
	if not string.find(string.gsub(str,"%w+",S2Ahelper),"%S") then return abbr end end
--[Arg2Tab] arg:key.1,key.n,val.1,val.n
rpgo.Arg2Tab = function(...)
	local tab={};
	local split=floor( select("#",...) /2);
	for i=1,split do tab[select(i,...)]=select(i+split,...); end
	return tab; end
--[Arg2Ary] arg:arg.1,arg.n
rpgo.Arg2Ary = function(...)
	local tab={};
	for i=1,select("#",...) do tab[i]=select(i,...); end
	return tab; end
