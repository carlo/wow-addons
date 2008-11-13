--##########################################################
if(not rpgo) then rpgo={}; end
if(not rpgo.colorTitle) then rpgo.colorTitle="909090"; end
if(not rpgo.colorGreen) then rpgo.colorGreen="00cc00"; end
if(not rpgo.colorRed)   then rpgo.colorRed  ="ff0000"; end
--if(not rpgo.func) then rpgo.func={}; end

local VERSION = 2000302
if(rpgo.ver and rpgo.ver >= VERSION) then return end
--[[########################################################
--## addon object functions
--######################################################--]]
--[RegisterEvents] [table]events, [bool]val
rpgo.RegisterEvents=function(self,val)
	if (not self or not self.events or not self.frame ) then return end
	if( val ) then
		for index,event in pairs(self.events) do
			self.frame:RegisterEvent(event); end
	else
		for index,event in pairs(self.events) do
			self.frame:UnregisterEvent(event); end
	end
end

--[[########################################################
--## pref functions
--######################################################--]]
--[PrefInit]
rpgo.PrefInit=function(self)
	if( self.prefs and self.PREFS ) then
		return rpgo.PrefInitSub(self.prefs,self.PREFS);
	end
end
--[PrefTidy]
rpgo.PrefTidy=function(self)
	if( self.prefs and self.PREFS) then
		return rpgo.PrefTidySub(self.prefs,self.PREFS);
	end
end

--[PrefInit] structPref,structDefault
rpgo.PrefInitSub = function(structPref,structDefault)
	for pref,val in pairs(structDefault) do
		if(type(structDefault[pref])=="table") then
			if(not structPref[pref]) then
				structPref[pref]={};
			end
			rpgo.PrefInitSub(structPref[pref],structDefault[pref]);
		elseif(structPref[pref] == nil) then
			structPref[pref]=val;
		end
	end
end
--[PrefTidy] structPref,structDefault
rpgo.PrefTidySub=function(structPref,structDefault)
	for pref,val in pairs(structPref) do
		if(type(structDefault[pref])=="table") then rpgo.PrefTidySub(structPref[pref],structDefault[pref]);
		elseif(structDefault[pref] == nil) then structPref[pref]=nil; end end end
--[TogglePref] togglePref
rpgo.TogglePrefOO=function(self,pref,val)
	if(not self or not pref) then return end
	--if(not self or not pref or not val) then return end
	--if(not self.PREFS or not self.prefs) then return end
	if( type(pref)=="string" ) then
		pref = string.lower(pref);
	end
	if( self.PREFS[pref]==nil or self.prefs[pref]==nil) then return end
	local prefkey,prefval,retval;
	local msg="["..pref.."]";
	if( type(val)=="string" ) then
		if(tonumber(val)) then
			val = tonumber(val);
		end
	end
	--if( self.PREFS[pref] ) then
	--	prefkey = self.PREFS[pref];
	--elseif( self.PREFS[pref] ) then
	--	prefkey = self.PREFS[pref];
	--end
	--self:PrintDebug( prefkey );

	if( type(self.PREFS[pref])=="boolean" ) then
		if( type(val)=="string" ) then
			val=string.lower(val);
			if(val=="on") then
				prefval=true;
			elseif(val=="off") then
				prefval=false;
			end
		elseif ( type(val)=="number" ) then
			prefval=(val>=1 or false);
		elseif ( type(val)=="boolean" ) then
			prefval=val;
		end
	elseif( type(self.PREFS[pref])=="number" ) then
		if( type(val)=="number" ) then
			prefval=val;
		elseif ( tonumber(val) ) then
			prefval=tonumber(val);
		end
	elseif( type(self.PREFS[pref])=="string" ) then
		if( type(val)=="string" ) then
			prefval=val;
		elseif ( tostring(val) ) then
			prefval=tostring(val);
		end
	end
--self:PrintDebug( pref, self.prefs[pref], type(self.PREFS[pref]) )
--self:PrintDebug( 'val', val, type(val) );
--self:PrintDebug( 'new', prefval, type(prefval) );
	if(prefval~=nil) then
		if( self.prefs[pref]~=prefval ) then
			self.prefs[pref]=prefval;
			if( self.funcs and self.funcs[pref] ) then
				self.funcs[pref](self.prefs[pref]);
			end
			retval=true;
		end
	end
	if(retval) then
		msg=msg.." changed";
	else
		msg=msg.." currently";
	end
	msg=msg.." "..rpgo.PrefColorize(self.prefs[pref]);
	self:PrintTitle(msg);
end
--[TogglePref] togglePref
--toRemove TOC>20003
rpgo.TogglePref=function(struct,pref,val)
	local retval=nil;
	if(val and type(var)=="string") then val=string.lower(val); end;
	if(val=="on") then val=true;
	elseif(val=="off") then val=false; end
	if(type(val)=="boolean" and struct[pref]~=val) then
		struct[pref]=val; retval=true;
	else retval=false; end
	return retval
end

--[PrefColorize] pref
rpgo.PrefColorize = function(pref)
	if(type(pref)=="boolean") then
		if(pref) then
			return rpgo.StringColorize(rpgo.colorGreen,"on|r")
		else
			return rpgo.StringColorize(rpgo.colorRed,"off|r")
		end
	elseif(type(pref)~="table") then
			return rpgo.StringColorize(rpgo.colorTitle,"["..pref.."]|r")
	else
			return rpgo.StringColorize(rpgo.colorTitle,"["..tostring(pref).."]|r")
	end
end

--[State] pref
rpgo.State = function(self,...)
	if(not self.state) then return end
	local state = self.state;
	local n=select("#",...);
	local key=select(1,...);
	if(n==2) then
		local val=select(2,...);
		if(val=='++') then
			state[key]=state[key]+1;
		elseif(val=='++') then
			state[key]=state[key]-1;
		else
			state[key]=val;
		end
		return true;
	elseif( state and state[key] ) then
		return state[key];
	end
	return nil;
end

--[[########################################################
--## helper functions
--######################################################--]]
--[LiteScan] [self.pref.lite]
rpgo.LiteScan = function(self)
	if(not self or not self.prefs or not self.prefs.lite) then return false; end
	local msg;
	if(UnitInRaid("player")) then msg="raid";
	elseif(IsInInstance()) then msg="instance"; end
	if(msg) then
		if(not self.state["_litemsg"]) then
			rpgo.PrintTitle(self,"scan skipped: character is in "..msg);
			self.state["_litemsg"]=true;
		end
		return true;
	end
	return false;
end

--[[########################################################
--## print object
--######################################################--]]
--[PrintMsg] self,msg
rpgo.PrintMsg = function(...)
	if(not select("#",...)) then return end
	DEFAULT_CHAT_FRAME:AddMessage(...);
end
--[PrintTitle] self,msg
rpgo.PrintTitle = function(self,msg,title,version)
	if(not self) then return end
	if(not msg or msg==nil) then msg="" else msg=" "..msg end
	local tmsg="";
	if(self["PROVIDER"]) then
		tmsg = self["PROVIDER"];
	end
	if(title and self["TITLE"]) then
		tmsg = tmsg.."-"..self["TITLE"];
	elseif(self["ABBR"]) then
		tmsg = tmsg.."-"..self["ABBR"];
	end
	if(rpgo and rpgo.colorTitle) then
		tmsg = "|cff"..rpgo.colorTitle..tmsg.."|r";
	end
	if(version and self["VERSION"]) then
		tmsg = tmsg.." [v" .. self["VERSION"] .. "]";
	end
	DEFAULT_CHAT_FRAME:AddMessage(tmsg..msg);
end
--[PrintUsage] [self,self.usage]
rpgo.PrintUsage = function(self)
	if(self.usage) then
		rpgo.PrintTitle(self,"Usage",true,true);
		for index=1,table.getn(self.usage),1 do
			rpgo.PrintMsg(rpgo.AssempleHelp(self.usage[index]));
		end
	end
end
--[PrintDebug] self,msg
rpgo.PrintDebug = function(self,...)
	if(self and self.prefs and self.prefs.debug) then
		local i;
		local msg={};
		local tmsg="";
		if(self["PROVIDER"]) then
			tmsg = tmsg..self["PROVIDER"];
		end
		if(self["ABBR"]) then
			tmsg = tmsg..self["ABBR"];
		end
		tmsg = tmsg..">"
		if(rpgo and rpgo.colorTitle) then
			tmsg = "|cff"..rpgo.colorTitle..tmsg.."|r";
		end
		for i=1,select("#",...) do
			if(rpgoGetObjStr)then
				msg[i]=rpgoGetObjStr(select(i,...));
			else
				msg[i] = select(i,...);
				if(msg[i]==nil) then
					msg[i]='<nil>';
				elseif( type(msg[i])=="boolean") then
					msg[i]='<boolean>';
				elseif( type(msg[i])=="table") then
					msg[i]='<table>';
				end
			end
		end
		if( msg ) then
			tmsg = tmsg .. " ".."[" .. table.concat(msg,":") .. "]";
		end
		if(RPGODEBUG_CHAT_FRAME) then
			RPGODEBUG_CHAT_FRAME:AddMessage(tmsg);
		else
			DEFAULT_CHAT_FRAME:AddMessage(tmsg,0.8,0.8,0.8);
		end
	end
end

--[AssempleHelp] (helpline)
rpgo.AssempleHelp = function(helpline)
	local msg; if(type(helpline)=="table") then
		msg="  |cff"..rpgo.colorTitle..helpline[1].."|r     "..helpline[2];
		if(helpline[3]) then msg=msg.."\n     "..helpline[3]; end
		else msg=helpline; end
		return msg; end
--[StringColorize] color,msg
rpgo.StringColorize = function(color,msg)
	if(color and msg) then
		return "|cff"..color..msg.."|r";
	end
end
--[UpdateDate]
rpgo.UpdateDate = function(self,...)
	if(not self.db) then return; end;
	local struct=self.db;
	if ( not struct["timestamp"] ) then struct["timestamp"]={}; end
	local timestamp = time();
	local currHour,currMinute=GetGameTime();
	struct["timestamp"]["init"]={};
	struct["timestamp"]["init"]["TimeStamp"]=timestamp;
	struct["timestamp"]["init"]["Date"]=date("%Y-%m-%d %H:%M:%S",timestamp);
	struct["timestamp"]["init"]["DateUTC"]=date("!%Y-%m-%d %H:%M:%S",timestamp);
	struct["timestamp"]["init"]["ServerTime"]=format("%02d:%02d",currHour,currMinute);
	struct["timestamp"]["init"]["datakey"]=rpgo.versionkey();
end

--[table:count]
function table:count()
	local i = 0
	for _ in pairs(self) do i = i + 1 end
	return i
end

rpgo.ver = VERSION;
