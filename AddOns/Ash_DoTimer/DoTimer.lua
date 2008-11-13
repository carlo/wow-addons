------------------------------------------------------------------------------------------------------------
-- ################### DATA ####################### --
------------------------------------------------------------------------------------------------------------

DoTimer = AsheylaLib:NewModule("DoTimer","TimerLib","SpellLib","GUILib")
local castpetspell --the table for pet spellcasts
local sentpetspell --table for pet spells, to catch resists/whatever
local finalpetspell --another for pet spells, to await the icon
local diesmsg = string.gsub(UNITDIESOTHER,"%%.-s","(.+)") --the chat message sent when something dies
local slainmsg = string.gsub(SELFKILLOTHER,"%%.-s","(.+)") --when you had the killing blow for a death
local spells,localedata --spells that have no target, so treated differently
local defaultsettings
local uniquespells = { --spells that can only be applied once globally, but lack of cooldown allows spamming
	["Hunter's Mark"] = 1,
	["Fear"] = 1,
	["Seduction"] = 1,
	["Prayer of Mending"] = 1,
	["Hibernate"] = 1,
	["Sap"] = 1,
	["Polymorph"] = 1,
	["Banish"] = 1,
	["Enslave Demon"] = 1,
}
local notargetinfo = {
	target = "No Target",
	text = "No Target",
	sex = 0,
	level = 0,
	icon = 0,
	type = "player",
	external = 1,
	priority = 1,
	norepeat = 1,
}

local flag = false

local function dbg(msg)
	if flag then DoTimer:Print(msg) end
end

------------------------------------------------------------------------------------------------------------
-- ################ LOCALIZATION ################### --
------------------------------------------------------------------------------------------------------------

function DoTimer:ReturnEnglish(spellname) --returns the english name of the spell
	spellname = spellname
	local tables = {BOOKTYPE_SPELL,BOOKTYPE_PET}
	local english,texture
	for index,value in ipairs(tables) do
		local i = 1
		while GetSpellName(i,value) do
			local spell = GetSpellName(i,value)
			if spell == spellname then
				texture = GetSpellTexture(i,value)
				break
			end
			i = i + 1
		end
	end
	if texture and localedata[texture] then return localedata[texture].name end
	return "unknown"
end

------------------------------------------------------------------------------------------------------------
-- ############## BASIC FUNCTIONS ################### --
------------------------------------------------------------------------------------------------------------
	
function DoTimer:OnLoad()
	this:RegisterEvent("PLAYER_ENTERING_WORLD")
	this.updatelength = 1
end

function DoTimer:OnEvent(event)
	if event == "PLAYER_ENTERING_WORLD" then self:Startup() -- when you first log in
	elseif self:HasRegisteredSettings() and self:Get("status") then
		if event == "PLAYER_ALIVE" and UnitIsGhost("player") then self:PlayerDeath() --deleting entries because player died
		elseif event == "PLAYER_REGEN_ENABLED" then self:LeftCombat()--deleting mob tables b/c left combat
		elseif event == "UNIT_AURA" then self:ScanTimers(arg1)
		elseif event == "UNIT_SPELLCAST_SUCCEEDED" then self:PotentialSpellTimer()
		elseif event == "CHAT_MSG_COMBAT_HOSTILE_DEATH" then self:HostileDeath()
		elseif event == "UNIT_PET" and arg1 == "player" and (not UnitExists("pet")) then self:DeleteEnslaveTimer()
		end
	end
end

function DoTimer:OnUpdate(elapsed)
	this.updatelength = this.updatelength - elapsed
	if this.updatelength <= 0 then 
		self:ScanSecondaryUnits()
		this.updatelength = 1
	end
end

function DoTimer:Startup() --called on first login per session, creates the default settings if needed or else just hides the interface and sets the scale
	self:RegisterSettings()
	self:AddDefaultSettings(defaultsettings)
	ProfileLib:RegisterForProfiles(self)
	DoTimer:MakeSlashCmd("/dotimer","/dot")
	self:CreateTimerInstance()
	self:SetScript("OnDragClick",function(arg1) 
		if arg1 == "RightButton" then 
			DoTimer:RemoveAllTimers() 
		elseif arg1 == "LeftButton" then
			DoTimer:Print("This is the |cff00ffffDoTimer|r anchor.  Access |cff00ffffDoTimer|r's menu by typing '|cff00ff00/dot|r'.  Hide me by checking the '|cff00ff00Locked|r' checkbutton in the menu.")
		end 
	end)
	self:SetScript("OnTargetClick",function(i,module,arg1) if arg1 == "RightButton" then module:RemoveTarget(i) end end)
	self:SetScript("OnTimerClick",function(i,id,module,arg1) 
		if arg1 == "LeftButton" then 
			DoTimer:ToChat(module:GetTarget(i),module:GetTimer(i,id)) 
		elseif arg1 == "RightButton" then 
			if IsShiftKeyDown() then 
				local timer = module:GetTimer(i,id)
				local frame = StaticPopup_Show("DOTIMER",timer.spell)
				frame.data = timer
				frame.data2 = module
			else
				module:RemoveTimer(i,id,"clicked")
			end 
		end
	end)
	self:SetScript("OnTimerEnter",function(i,id,module,this) 
		self:CreateTimerTooltip(module:GetTimer(i,id),this) 
	end)
	local _,class = UnitClass("player")
	spells,localedata = self:DefineSpells(class)
	self:DefineSpell("No Texture","Blank Spot",0,0)
	StaticPopupDialogs["DOTIMER"] = {
		text = "Are you sure you want to block the timer for %s?",
		button1 = "Yes",
		button2 = "No",
		OnAccept = function(timer,module) timer.module:Set("hidden",string.lower(timer.spell),1); module:UpdateSettings() end,
		whileDead = 1,
		hideOnEscape = 1,
		timeout = 0,
	}
	if class == "SHAMAN" then
		DoTimerClassFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		DoTimerClassFrame:SetScript("OnEvent",function()
			if arg1 == "player" and DoTimer:ReturnEnglish(arg2) == "Totemic Call" then
				local i = DoTimer:ReturnTargetTable("No Target",0,0,DoTimer)
				if i then
					for id = DoTimer:GetNumTimers(i),1,-1 do
						local group = DoTimer:ReturnGroup(DoTimer:GetTimer(i,id).texture) or 0
						if group <= 5 and group >= 2 then
							DoTimer:RemoveTimer(i,id,"finished",1)
						end
					end
					DoTimer:CreateInterface()
				end
			end
		end)
	end
	this:UnregisterEvent("PLAYER_ENTERING_WORLD")
	this:RegisterEvent("PLAYER_ALIVE")
	this:RegisterEvent("PLAYER_REGEN_ENABLED")
	this:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	this:RegisterEvent("UNIT_AURA")
	this:RegisterEvent("UNIT_PET")
	this:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

------------------------------------------------------------------------------------------------------------
-- ############ TIMER REMOVAL FUNCTIONS ############## --
------------------------------------------------------------------------------------------------------------

function DoTimer:ScanTimers(unit) --deletes the timers of spells which are no longer on the target
	if UnitExists(unit) then
		if flag and UnitIsUnit(unit,"pet") then return end
		if (not self:Get("playertimers")) and UnitIsUnit(unit,"player") then return end
		if UnitIsUnit(unit,"pet") then self:ScanDebuffs("pet") end
		if UnitCanAttack("player",unit) then 
			self:Debug("scanning the debuffs on ",UnitName(unit) or ""," (",unit,")")
			self:ScanDebuffs(unit) 
		else 
			self:Debug("scanning the buffs on ",UnitName(unit) or ""," (",unit,")")
			self:ScanBuffs(unit)
		end
	end
end

function DoTimer:ScanDebuffs(unit)
	local unitflag = (UnitIsUnit(unit,"target") and "target") or (UnitIsUnit(unit,"focus") and "focus")
	local targetlayout = self:Get("targetlayout")
	local targettable
	local timertable
	local refresh
	local i = 1
	local targetindex = self:ReturnUnitTargetTable(unit)
	dbg("scanning ["..UnitLevel(unit).."]"..UnitName(unit).." ("..unit..")")
	if targetindex then
		self:Debug("the unit already had a target table")
		dbg("this unit matches the data for target #"..targetindex)
		for id = 1,self:GetNumTimers(targetindex) do
			self:GetTimer(targetindex,id).validated = nil
		end
		targettable = self:GetTarget(targetindex)
	else
		dbg("no target table matches this unit")
	end
	local name,rank,texture,count,debufftype,duration,timeleft = UnitDebuff(unit,i)
	while name do
		if duration and timeleft and duration > 0 then
			local debugmsg = name.." is on the unit; duration: "..duration.."; timeleft: "..timeleft..":::"
			local adding = true
			local channelspell = UnitChannelInfo("player")
			if name == channelspell then
				adding = false
				debugmsg = debugmsg.."it was from a channeling spell; ignoring"
			elseif self:InTable(name,spells) then
				adding = false
				debugmsg = debugmsg.."it was a notarget spell; ignoring"
			else
				if targetindex then
					for id = 1,self:GetNumTimers(targetindex) do
						local timer = self:GetTimer(targetindex,id)
						if timer.spell == name and timer.module == self and (timer.type == "debuff" or (timer.type == "hidden" and timer.origtype == "debuff")) then
							timer.validated = true
							adding = false
							debugmsg = debugmsg.."a timer already existed:::"
							local time = GetTime() - duration + timeleft
							if not (math.abs(timer.duration - duration) <= .1 and math.abs(timer.time - time) <= .1) then
								debugmsg = debugmsg.."but improper duration or timeleft; modifying it:::"
								timer.time = time
								timer.duration = duration
								timer.displayed = nil
								refresh = true
							end
							if not (count == timer.count) then
								debugmsg = debugmsg.."but improper stack number; modifying it:::"
								timer.stack = count
							end
							break
						end
					end
				end
			end
			if adding then
				debugmsg = debugmsg.."creating a timer for it; no timer had existed"
				if not targettable then
					targettable = {
						target = UnitName(unit),
						sex = UnitSex(unit),
						level = UnitLevel(unit),
						icon = GetRaidTargetIndex(unit) or 0,
						type = self:ReturnTargetType(unit),
						unit = unitflag,
						norepeat = 1,
					}
					targettable.text = (self:Get("levels") and "["..targettable.level.."] " or "")..((targetlayout == "up" or targetlayout == "down") and targettable.target or string.gsub(targettable.target," ","\n"))
				end
				local _,book,id = self:FindSpellInfo(name,rank,"spell")
				local spelltable = {
					spell = name,
					rank = rank,
					texture = texture,
					duration = duration,
					time = GetTime() - duration + timeleft,
					type = "debuff",
					stack = count,
					validated = true,
				}
				if book and id then spelltable.info = {type = book,id = id} end
				if not timertable then timertable = {} end
				table.insert(timertable,spelltable)
			end
			self:Debug(debugmsg)
		end
		i = i + 1
		name,rank,texture,count,debufftype,duration,timeleft = UnitDebuff(unit,i)
	end
	if targetindex then
		for id = self:GetNumTimers(targetindex),1,-1 do
			local timer = self:GetTimer(targetindex,id)
			if timer then
				if timer.module == self and (timer.type == "debuff" or (timer.type == "hidden" and timer.origtype == "debuff")) and not timer.validated then
					self:Debug(timer.spell," was no longer on the mob; deleting timer")
					refresh = true
					self:RemoveTimer(targetindex,id,"broke",1)
				end
			end
		end
		if timertable then
			for i,v in ipairs(timertable) do 
				local english = self:ReturnEnglish(v.spell) or ""
				if uniquespells[english] then --filtering out spells that can be cast once at a time
					for i = self:GetNumTargets(),1,-1 do
						if not self:GetTarget(i).external then
							for id = self:GetNumTimers(i),1,-1 do
								local timer = self:GetTimer(i,id)
								if timer.spell == v.spell and timer.module == self and self:TimerIsReal(i,id) then 
									self:Debug("removing timers on other targets since it can only be applied once")
									self:RemoveTimer(i,id,"replaced",1)
								end
							end
						end
					end
				end
				self:AddTimer(targetindex,v,1) 
			end
			local flag = refresh
			refresh = false
			self:CreateInterface(flag)
		end
	elseif targettable then 
		targetindex = self:AddTarget(targettable,1)
		for i,v in ipairs(timertable) do
			local english = self:ReturnEnglish(v.spell) or ""
			if uniquespells[english] then --filtering out spells that can be cast once at a time
				for i = self:GetNumTargets(),1,-1 do
					if not self:GetTarget(i).external then
						for id = self:GetNumTimers(i),1,-1 do
							local timer = self:GetTimer(i,id)
							if timer.spell == v.spell and timer.module == self and self:TimerIsReal(i,id) then 
								self:Debug("removing timers on other targets since it can only be applied once")
								self:RemoveTimer(i,id,"replaced",1)
							end
						end
					end
				end
			end
			self:AddTimer(targetindex,v,1) 
		end
		local flag = refresh
		refresh = false
		self:CreateInterface(flag)
	end
	if refresh then self:CreateInterface(1) end
end

function DoTimer:ScanBuffs(unit)
	local unitflag = (UnitIsUnit(unit,"target") and "target") or (UnitIsUnit(unit,"focus") and "focus")
	local targetlayout = self:Get("targetlayout")
	local targettable
	local timertable
	local refresh
	local i = 1
	local targetindex = self:ReturnUnitTargetTable(unit)
	if targetindex then
		self:Debug("the unit already had a target table")
		for id = 1,self:GetNumTimers(targetindex) do
			self:GetTimer(targetindex,id).validated = nil
		end
		targettable = self:GetTarget(targetindex)
	end
	local name,rank,texture,count,duration,timeleft = UnitBuff(unit,i)
	while name do
		if duration and timeleft and duration > 0 then
			local maxdur = self:Get("maxbuffduration") * 60
			local debugmsg = name.." is on the unit; duration: "..duration.."; timeleft: "..timeleft..":::"
			local adding = true
			local channelspell = UnitChannelInfo("player")
			if name == channelspell then
				adding = false
				debugmsg = debugmsg.."it was from a channeling spell; ignoring"
			elseif (maxdur > 0) and (duration > maxdur) then
				adding = false
				debugmsg = debugmsg.."but its duration is too long; ignoring"
			else
				if targetindex then
					for id = 1,self:GetNumTimers(targetindex) do
						local timer = self:GetTimer(targetindex,id)
						if timer.spell == name and timer.module == self and (timer.type == "buff" or (timer.type == "hidden" and timer.origtype == "buff")) then
							timer.validated = true
							adding = false
							debugmsg = debugmsg.."a timer already existed:::"
							local time = GetTime() - duration + timeleft
							if not (math.abs(timer.duration - duration) <= .1 and math.abs(timer.time - time) <= .1) then
								debugmsg = debugmsg.."but improper duration or timeleft; modifying it:::"
								timer.time = time
								timer.duration = duration
								timer.displayed = false
								refresh = true
							end
							if not (count == timer.count) then
								debugmsg = debugmsg.."but improper stack number; modifying it:::"
								timer.stack = count
							end
							break
						end
					end
				end
			end
			if adding then
				debugmsg = debugmsg.."creating a timer for it; no timer had existed"
				if not targettable then
					targettable = {
						target = UnitName(unit),
						sex = UnitSex(unit),
						level = UnitLevel(unit),
						icon = GetRaidTargetIndex(unit) or 0,
						type = self:ReturnTargetType(unit),
						unit = unitflag,
						norepeat = 1,
					}
					targettable.text = (self:Get("levels") and "["..targettable.level.."] " or "")..((targetlayout == "up" or targetlayout == "down") and targettable.target or string.gsub(targettable.target," ","\n"))
				end
				local _,book,id = self:FindSpellInfo(name,rank,"spell")
				local spelltable = {
					spell = name,
					rank = rank,
					texture = texture,
					duration = duration,
					time = GetTime() - duration + timeleft,
					type = "buff",
					stack = count,
					validated = true,
				}
				if book and id then spelltable.info = {type = book,id = id} end
				if not timertable then timertable = {} end
				table.insert(timertable,spelltable)
			end
			self:Debug(debugmsg)
		end
		i = i + 1
		name,rank,texture,count,duration,timeleft = UnitBuff(unit,i)
	end
	if targetindex then
		for id = self:GetNumTimers(targetindex),1,-1 do
			local timer = self:GetTimer(targetindex,id)
			if timer then
				if timer.module == self and (timer.type == "debuff" or (timer.type == "hidden" and timer.origtype == "debuff")) and not timer.validated then
					self:Debug(timer.spell," was no longer on the mob; deleting timer")
					refresh = true
					self:RemoveTimer(targetindex,id,"broke",1)
				end
			end
		end
		if timertable then
			for i,v in ipairs(timertable) do 
				local english = self:ReturnEnglish(v.spell) or ""
				if uniquespells[english] then --filtering out spells that can be cast once at a time
					for i = self:GetNumTargets(),1,-1 do
						if not self:GetTarget(i).external then
							for id = self:GetNumTimers(i),1,-1 do
								local timer = self:GetTimer(i,id)
								if timer.spell == v.spell and timer.module == self and self:TimerIsReal(i,id) then 
									self:Debug("removing timers on other targets since it can only be applied once")
									self:RemoveTimer(i,id,"replaced",1)
								end
							end
						end
					end
				end
				self:AddTimer(targetindex,v,1) 
			end
			local flag = refresh
			refresh = false
			self:CreateInterface(flag)
		end
	elseif targettable then 
		targetindex = self:AddTarget(targettable,1)
		for i,v in ipairs(timertable) do
			local english = self:ReturnEnglish(v.spell) or ""
			if uniquespells[english] then --filtering out spells that can be cast once at a time
				for i = self:GetNumTargets(),1,-1 do
					if not self:GetTarget(i).external then
						for id = self:GetNumTimers(i),1,-1 do
							local timer = self:GetTimer(i,id)
							if timer.spell == v.spell and timer.module == self and self:TimerIsReal(i,id) then 
								self:Debug("removing timers on other targets since it can only be applied once")
								self:RemoveTimer(i,id,"replaced",1)
							end
						end
					end
				end
			end
			self:AddTimer(targetindex,v,1) 
		end
		local flag = refresh
		refresh = false
		self:CreateInterface(flag)
	end
	if refresh then self:CreateInterface(1) end
end

function DoTimer:PlayerDeath()
	self:Debug(event)
	if UnitIsGhost("player") then
		self:Debug("dead and released; removing all timers")
		for i = self:GetNumTargets(),1,-1 do
			if (not self:GetTarget(i).external) or (self:GetTarget(i).target == "No Target") then self:RemoveTarget(i,1) end
		end
		self:CreateInterface()
	end
end

function DoTimer:HostileDeath()
	self:Debug(event)
	self:Debug(arg1)
	local died = self:ParseString(arg1,diesmsg) --checking if the dead mob had any tables
	if not died then
		died = self:ParseString(arg1,slainmsg)
	end
	if died == UnitName("target") and UnitIsDead("target") then --your target died, we will delete its entries
		self:Debug("current target died")
		local found = self:ReturnUnitTargetTable("target")
		if found then --sure enough, it did!
			self:Debug("and it had timers; removing entire table")
			self:RemoveTarget(found)
			--DoTimer_AddText(died.." died and its entries were removed.")
		end
	elseif died == UnitName("focus") and UnitIsDead("focus") then --your target died, we will delete its entries
		self:Debug("current focus died")
		local found = self:ReturnUnitTargetTable("focus")
		if found then --sure enough, it did!
			self:Debug("and it had timers; removing entire table")
			self:RemoveTarget(found)
			--DoTimer_AddText(died.." died and its entries were removed.")
		end
	else --will ignore if mob, will delete if player
		self:Debug("mob died, not current target")
		for i = self:GetNumTargets(),1,-1 do
			local target = self:GetTarget(i)
			if  target.target == died and target.type == "player" then
				self:Debug("removing its timers anyway though")
				self:RemoveTarget(i) --dont bother with appreciated stuff; it has a unique name so it should be removed outright
				break
				--DoTimer_AddText(died.." died and its entries were removed.")
			end
		end
	end
end

local leftcombatfunc = function(self,elapsed)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed >= 3 then
		if not UnitAffectingCombat("player") then
			DoTimer:Debug("still out of combat 3 seconds later; removing all non-enslave, non-player timers")
			for i = DoTimer:GetNumTargets(),1,-1 do
				if not ((DoTimer:GetTarget(i).type == "player") or DoTimer:GetTarget(i).external) then DoTimer:RemoveTarget(i) end
			end
		end
		self:SetScript("OnUpdate",nil)
	end
end

function DoTimer:LeftCombat()
	self:Debug("left combat")
	DoTimerCombatFrame.elapsed = 0
	DoTimerCombatFrame:SetScript("OnUpdate",leftcombatfunc)
end

function DoTimer:DeleteEnslaveTimer()
	for i = 1,self:GetNumTargets() do
		for id = 1,self:GetNumTimers(i) do
			if self:GetTimer(i,id).texture == "Interface\\Icons\\Spell_Shadow_EnslaveDemon" then 
				self:RemoveTimer(i,id,"broke")
				return
			end
		end
	end
end

function DoTimer:UnitMatchesData(targettable)
	local unit = targettable.unit
	if UnitExists(unit) and UnitName(unit) == targettable.target and UnitSex(unit) == targettable.sex and UnitLevel(unit) == targettable.level and (GetRaidTargetIndex(unit) or 0) == targettable.icon then return true end
	return false
end

function DoTimer:UnitIsTable(unit,targettable)
	if UnitExists(unit) and UnitName(unit) == targettable.target and UnitSex(unit) == targettable.sex and UnitLevel(unit) == targettable.level and (GetRaidTargetIndex(unit) or 0) == targettable.icon then return true end
	return false
end

function DoTimer:TargetTableIsTable(table1,table2)
	return (table1.target == table2.target and table1.sex == table2.sex and table1.level == table2.level and table1.icon == table2.icon)
end

function DoTimer:ReturnGroup(texture)
	return (localedata[texture] and localedata[texture].group)
end

-----------------------------------------------------------------------------------------------------------
-- ########### GENERAL TIMER FUNCTIONS ############### --
-----------------------------------------------------------------------------------------------------------

function DoTimer:PotentialSpellTimer()
	if self:InTable(arg2,spells) then
		self:Debug("spell success: ",arg2)
		local spell = {}
		local texture,type,id = self:FindSpellInfo(arg2,arg3,"spell")
		spell.spell = arg2
		spell.rank = arg3
		spell.info = {type = type,id = id}
		spell.type = "notarget"
		spell.texture = texture
		spell.duration = self:ReturnDuration(spell)
		spell.time = GetTime()
		local notargetindex = self:ReturnTargetTable("No Target",0,0,self)
		if not notargetindex then notargetindex = self:AddTarget(self:CopyTable(notargetinfo)) end
		self:AddTimer(notargetindex,spell)
	end
end

function DoTimer:InTable(query,checkedtable) --checks a spell to see if it needs to be watched (as in, it was in that big spell list at the top)
	return checkedtable[self:ReturnEnglish(query)] --used to be longer, but code changes made it simpler.  dont feel like replacing it in the code, so it's here to stay
end

function DoTimer:ReturnDuration(spelltable) --returns the duration of a spell
	if spelltable.texture == "Interface\\Icons\\Spell_Fire_SearingTotem" and string.find(spelltable.rank,"7") then return 60 end --yay for stupid searing totem going from "55 secs" to "1 min" >< throws off the entire system!
	for index,value in ipairs({BOOKTYPE_SPELL,BOOKTYPE_PET}) do 
		local i = 1
		while GetSpellName(i,value) do
			local spellname,spellrank = GetSpellName(i,value)
			if spellname == spelltable.spell and ((spellrank == spelltable.rank) or (spelltable.rank == "") or (value == BOOKTYPE_PET)) then
				local text = self:GetSpellInfo(i,value,"left","max")
				local allnumbers = self:ReturnPossibleDurations(self:ParseString(text,"(%d[%d%p]*)"))
				local basenumber = localedata[spelltable.texture].duration
				local multiplier = localedata[spelltable.texture].multiplier
				if allnumbers[1] == nil then allnumbers[1] = basenumber end
				local truenumber
				for index2,value2 in ipairs(allnumbers) do
					if ((not truenumber) or (math.abs(value2 - basenumber) < math.abs(truenumber - basenumber))) then truenumber = value2 end
				end
				return truenumber * multiplier
			end
			i = i + 1
		end
	end
	return 0
end

function DoTimer:ReturnPossibleDurations(...)
	local t = self:AcquireTable()
	for i = 1,select("#",...) do
		local num = select(i,...)
		if type(num) == "number" then table.insert(t,num) end
	end
	return t
end

------------------------------------------------------------------------------------------------------------
-- ############### OTHER FUNCTIONS ################# --
------------------------------------------------------------------------------------------------------------

function DoTimer:Commands(msg,bypass) --governs the /command
	if msg == "" then 
		self:ShowGUI()
		return
	elseif msg == "reset" then
		self:ClearSettings()
		self:Commands("reset position",1)
	elseif msg == "reset position" then
		self:Set("offsetX",nil)
	elseif string.sub(msg,1,4) == "help" then 
		self:AddHelpMenu(msg)
		return
	else
		self:Print("Type |cff00ff00/dotimer help|r for some info, or |cff00ff00/dotimer|r to open the menu!")
		return
	end
	if not bypass then self:UpdateSettings() end
end

function DoTimer:ReturnData()
	return {spells = spells, localedata = localedata}
end

function DoTimer:ToChat(t,d)
	if d.module:TimerIsReal(d) then
		local displayed = d.displayed
		local spell = d.spell
		local rank = d.rank
		local target = t.target
		local level = t.level
		if (displayed and spell and rank and target and level) then
			displayed = self:ReturnFormattedDuration(displayed)
			local subentries,unsubbedmsg
			if target == "No Target" then
				subentries = {
					["%d"] = displayed,
					["%s"] = spell,
					["%r"] = rank,
				}
				unsubbedmsg = self:Get("chatmsgnotarget")	
			else
				subentries = {
					["%d"] = displayed,
					["%s"] = spell,
					["%r"] = rank,
					["%t"] = target,
					["%l"] = level,
				}
				unsubbedmsg = self:Get("chatmsgnormal")
			end
			local chat = "SAY"
			if GetNumRaidMembers() > 0 then chat = "RAID" elseif GetNumPartyMembers() > 0 then chat = "PARTY" end
			local msg = string.gsub(unsubbedmsg,"(%%%a)",function(a) return subentries[a] or "" end)
			msg = string.gsub(msg,"%(%)","")
			SendChatMessage(msg,chat)
		end
	end
end

function DoTimer:CreateTimerTooltip(d,frame)
	if self:Get("tooltips") then
		GameTooltip:SetOwner(frame,"ANCHOR_RIGHT")
		if d.info then	
			local type = d.info.type
			if type == BOOKTYPE_SPELL then
				GameTooltip:SetSpell(d.info.id,BOOKTYPE_SPELL)
			elseif type == "item" then
				GameTooltip:SetHyperlink(DoTimer:ReturnItemLink(d.info.id))
			elseif type == BOOKTYPE_PET then
				GameTooltip:SetSpell(d.info.id,BOOKTYPE_PET)								
			end
		else
			GameTooltip:AddLine(d.spell,1,1,1)
			GameTooltip:AddLine(d.rank,1,1,1)
		end
		GameTooltip:AddLine("Left-click to announce.  Right-click to remove.  Shift+right-click to hide.",1,1,1,1)
		GameTooltip:Show()
	end
end

function DoTimer:DefineSpell(texture,name,duration,multiplier,group)
	localedata[texture] = {
		name = name,
		duration = duration,
		multiplier = multiplier,
		group = group,
	}
end

local raidtargets = setmetatable({},{__index=function(t,k)
    t[k] = ('raid%dtarget'):format(k)
    return t[k]
end})

local partytargets = setmetatable({},{__index=function(t,k)
    t[k] = ('party%dtarget'):format(k)
    return t[k]
end})

local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitIsFriend = UnitIsFriend
local GetNumRaidMembers = GetNumRaidMembers
local GetNumPartyMembers = GetNumPartyMembers

local unitids = {}

function DoTimer:ScanSecondaryUnits()
	if flag then return end
	if UnitExists("pettarget") then
		self:ScanTimers("pettarget")
	end
	local num = GetNumRaidMembers()
	if num > 0 then
		for i,v in pairs(unitids) do unitids[i] = nil end
		for i = 1,num do
			local unit = raidtargets[i]
			if UnitExists(unit) then
				if UnitCanAttack("player",unit) then
					local intable = false
					for _,v in ipairs(unitids) do
						if UnitIsUnit(unit,v) then intable = true break end
					end
					if not intable then table.insert(unitids,unit) end
				end
			end
		end
		for i,v in ipairs(unitids) do self:ScanTimers(v) end
	else
		num = GetNumPartyMembers()
		if num > 0 then
			for i,v in pairs(unitids) do unitids[i] = nil end
			for i = 1,num do
				local unit = partytargets[i]
				if UnitExists(unit) then
					if UnitCanAttack("player",unit) then
						local intable = false
						for _,v in ipairs(unitids) do
							if UnitIsUnit(unit,v) then intable = true break end
						end
						if not intable then table.insert(unitids,unit) end
					end
				end
			end
			for i,v in ipairs(unitids) do self:ScanTimers(v) end
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_FOCUS_CHANGED")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:SetScript("OnEvent",function(self,event) 
	local unit = (event == "PLAYER_TARGET_CHANGED" and "target" or "focus")
	self.unit = unit
	dbg("triggering a refresh of unitIDs: "..unit)
	for i = 1,DoTimer:GetNumTargets() do
		local target = DoTimer:GetTarget(i)
		if not target.external then
			if target.unit == unit then target.unit = nil end
		end
	end
	local i = DoTimer:FindUnitTargetTable(unit)
	if i then
		local target = DoTimer:GetTarget(i)
		target.unit = unit
		dbg("target table #"..i.." (["..target.level.."]"..target.target..") was mapped to the unitID "..target.unit)
	end
	DoTimer:ScanTimers(unit)
	if DoTimer:Get("sort"..unit) or DoTimer:Get("only"..unit) then DoTimer:CreateInterface() end
end)

function DoTimer:AddHelpMenu(msg) --the help menu displayed ingame
	if msg == "help info" then
		DoTimer:AddAuthorInfo()
	elseif msg == "help new" then
		self:Print("|cff00ffffDoTimer Beginner's Guide:|r")
		self:Print("|cff00ff00Please Note|r: The information in this subsection will not detail any other commands.  Please read the option's tooltip for a full understanding of how it works.")
		self:Print("|cff00ff00First Installation|r: You will notice a small black circle in the middle of your screen.  It is to this circle that the timers are anchored.  Move it around by dragging it.  Hide it by locking the interface via \"/dotimer lock\".")
		self:Print("|cff00ff00DoTimers|r: When you go out into the world and DoT a mob, timers will automatically appear.  There is no configuration required for this basic step.")
		self:Print("|cff00ff00Ghost Timers|r: These are shown when a real timer expires.  You can control how long they stay on your screen, or if they appear at all.")
		self:Print("|cff00ff00Troubleshooting|r: If you ever have any errors, please contact me.  It would be best if you include a way to duplicate the problem.  Before doing this, try disabling your other addons and seeing if the problem goes away.  If it does, figure out the conflicting addon and tell me.")
		self:Print("|cff00ff00Features|r: Many features of this addon have been direct requests by other players.  If you ever have any suggestions, feel free to contact me about them.")
	else
		self:Print("|cff00ffffDoTimer Help Menu:|r")
		self:Print("|cff00ff00help new|r: information for first-time users")
		self:Print("|cff00ff00help general|r: basic addon features")
		self:Print("|cff00ff00help info|r: displays some version/author info")
	end
end

defaultsettings = {
	["tooltips"] = true,
	["levels"] = true,
	["chatmsgnormal"] = "My %s(%r) will expire on [%l]%t in %d.",
	["chatmsgnotarget"] = "My %s(%r) will finish in %d.",
	["maxbuffduration"] = 1,
	["playertimers"] = false,
}
