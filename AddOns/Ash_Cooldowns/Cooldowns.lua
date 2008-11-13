Cooldowns = AsheylaLib:NewModule("Cooldowns","TimerLib","SpellLib","GUILib")
local cooldownstarget = {
	target = "Cooldowns ", --the space is in case some player named "Cooldowns" exists
	sex = 0,
	level = 0,
	icon = 0,
	type = "player",
	external = true,
	text = "Cooldowns",
	norepeat = 1,
}
local cooldownsdata 
local loaded
local defaultsettings
local lastusedspell
local lastuseditem
local lastusedequippeditem
local spelltarget = {}

function Cooldowns:OnLoad()
	this:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function Cooldowns:OnEvent(event)
	if event == "PLAYER_ENTERING_WORLD" then 
		if loaded then 
			if self:Get("status") then self:CheckAllCooldowns() end
		else
			self:Startup() 
		end
	elseif self:HasRegisteredSettings() and self:Get("status") then
		if event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then self:PotentialCooldown()
		elseif event == "UNIT_SPELLCAST_SENT" then spelltarget[arg2] = arg4
		else self:CheckForCooldowns(event)
		end
	end
end

function Cooldowns:CheckModule()
	Cooldowns:Set("targetlayout",nil)
	local oldmodule = (Cooldowns:Get("dotimer") and Cooldowns or DoTimer)
	local newmodule = (Cooldowns:Get("dotimer") and DoTimer or Cooldowns)
	if oldmodule then
		local i = oldmodule:ReturnTargetTable("Cooldowns ",0,0,self)
		if i then
			newmodule:AddTarget(oldmodule:GetTarget(i))
			newmodule:CreateInterface()
			oldmodule:RemoveTarget(i) 
		end
	end
end

function Cooldowns:Startup() --called on first login per session, creates the default settings if needed or else just hides the interface and sets the scale
	self:RegisterSettings()
	self:AddDefaultSettings(defaultsettings)
	ProfileLib:RegisterForProfiles(self)
	self:AddSettingsUpdateScript(function() Cooldowns:CheckModule() end)
	Cooldowns:MakeSlashCmd("/cooldowns","/cd")
	self:CreateTimerInstance()
	self:SetScript("OnDragClick",function(arg1) 
		if arg1 == "RightButton" then 
			Cooldowns:RemoveAllTimers() 
		elseif arg1 == "LeftButton" then
			Cooldowns:Print("This is the |cff00ffffCooldowns|r anchor.  Access |cff00ffffCooldowns|r's menu by typing '|cff00ff00/cd|r'.  Hide me by checking the '|cff00ff00Locked|r' checkbutton in the menu.")
		end 
	end)
	self:SetScript("OnTargetClick",function(i,module,arg1) if arg1 == "RightButton" then module:RemoveTarget(i) end end)
	self:SetScript("OnTimerClick",function(i,id,module,arg1) 
		if arg1 == "LeftButton" then 
			Cooldowns:ToChat(module:GetTimer(i,id)) 
		elseif arg1 == "RightButton" then 
			if IsShiftKeyDown() then 
				local timer = module:GetTimer(i,id)
				local frame = StaticPopup_Show("COOLDOWNS",timer.spell)
				frame.data = timer
				frame.data2 = module
			else
				module:RemoveTimer(i,id,"clicked")
			end 
		end
	end)
	self:SetScript("OnTimerEnter",function(i,id,module,this) 
		Cooldowns:CreateTimerTooltip(module:GetTimer(i,id),this) 
	end)
	StaticPopupDialogs["COOLDOWNS"] = {
		text = "Are you sure you want to block the timer for %s?",
		button1 = "Yes",
		button2 = "No",
		OnAccept = function(timer,module) timer.module:Set("hidden",string.lower(timer.spell),1); module:UpdateSettings() end,
		whileDead = 1,
		hideOnEscape = 1,
		timeout = 0,
	}
	cooldownsdata = Cooldowns:DefineSpells()
	this:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	this:RegisterEvent("BAG_UPDATE_COOLDOWN")
	this:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
	this:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	this:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	this:RegisterEvent("UNIT_SPELLCAST_SENT")
	loaded = true
end

function Cooldowns:PotentialCooldown()
	local texture,book,id = self:FindSpellInfo(arg2,arg3,"item")
	if cooldownsdata[texture] then
		local spell = {spell = arg2, texture = texture}
		if book and id then
			spell.info = {type = book, id = id}
		end
		spell.type = "cooldown"
		spell.duration = cooldownsdata[texture].duration
		spell.time = GetTime()
		spell.english = cooldownsdata[texture].name
		if spell.english == "Soulstone" then spell.rank = (spelltarget[arg2] or "") else spell.rank = "" end
		self:CreateCooldown(spell)
	else
		if texture then
			if IsEquippedItem(arg2) then
				lastusedequippeditem = arg2
			else
				lastuseditem = arg2
			end
		else
			lastusedspell = arg2
		end
	end
end

function Cooldowns:CheckAllCooldowns()
	self:CheckForCooldowns("ACTIONBAR_UPDATE_COOLDOWN")
	self:CheckForCooldowns("BAG_UPDATE_COOLDOWN")
	self:CheckForCooldowns("SPELL_UPDATE_COOLDOWN")
	self:CheckForCooldowns("PET_BAR_UPDATE_COOLDOWN")
end

function Cooldowns:CheckForCooldowns(event)
	local mincd = self:Get("mincd")
	local maxcd = self:Get("maxcd") * 3600
	if event == "ACTIONBAR_UPDATE_COOLDOWN" then
		local lastitemcd = 0
		if lastusedequippeditem then
			lastitemcd = select(2,GetItemCooldown(lastusedequippeditem))
		end
		for i = 1,19 do
			local spellname = GetItemInfo(GetInventoryItemLink("player",i) or "")
			local texture = GetInventoryItemTexture("player",i)
			if spellname and (not cooldownsdata[texture]) then
				local start,duration,real = GetInventoryItemCooldown("player",i)
				if start > 0 and duration >= mincd and (duration <= maxcd or maxcd == 0) and real == 1 and self:TimerIsRelevent(start,duration,(spellname == lastusedequippeditem)) then
					local entry = {
						spell = spellname,
						rank = "", 
						texture = texture, 
						duration = duration, 
						time = start,
						type = "cooldown",
						english = spellname,
						info = {
							type = "item",
							id = self:GetItemID(GetInventoryItemLink("player",i)),
						},
					}
					self:CreateCooldown(entry)
				elseif start == 0 then
					self:RemoveCooldown(spellname,"item")
				end
			end
		end
		lastusedequippeditem = nil
	elseif event == "BAG_UPDATE_COOLDOWN" then
		local lastitemcd = 0
		if lastuseditem then
			lastitemcd = select(2,GetItemCooldown(lastuseditem))
		end
		for b = 0,4 do
			for s = 1,GetContainerNumSlots(b) do
				local spellname = GetItemInfo(GetContainerItemLink(b,s) or "")	
				local texture = GetContainerItemInfo(b,s)				
				if spellname and (not cooldownsdata[texture]) then
					local start,duration,real = GetContainerItemCooldown(b,s)
					if start > 0 and duration >= mincd and (duration <= maxcd or maxcd == 0) and real == 1 and self:TimerIsRelevent(start,duration,(spellname == lastuseditem)) then
						local entry = {
							spell = spellname,
							rank = "", 
							texture = texture, 
							duration = duration, 
							time = start,
							type = "cooldown",
							english = spellname,
							info = {
								type = "item",
								id = self:GetItemID(GetContainerItemLink(b,s))
							},
						}
						self:CreateCooldown(entry)
					elseif start == 0 then
						self:RemoveCooldown(spellname,"item")
					end
				end
			end
		end
		lastuseditem = nil
	elseif event == "SPELL_UPDATE_COOLDOWN" then
		local numtabs = GetNumSpellTabs()
		local _,_,offset,num = GetSpellTabInfo(numtabs)
		local numspells = offset + num
		local lastspellcd = 0
		if lastusedspell then
			lastspellcd = select(2,GetSpellCooldown(lastusedspell))
		end
		local lastscannedspell
		for i = numspells,1,-1 do
			local spellname = GetSpellName(i,BOOKTYPE_SPELL)
			local texture = GetSpellTexture(i,BOOKTYPE_SPELL)
			if spellname and (not (lastscannedspell == spellname)) and (not cooldownsdata[texture]) then
				lastscannedspell = spellname
				local start,duration,real = GetSpellCooldown(i,BOOKTYPE_SPELL)
				if start > 0 and duration >= mincd and (duration <= maxcd or maxcd == 0) and real == 1 and self:TimerIsRelevent(start,duration,(spellname == lastusedspell)) then
					local entry = {
						spell = spellname,
						rank = "", 
						texture = texture, 
						duration = duration, 
						time = start,
						type = "cooldown",
						english = spellname,
						info = {
							type = BOOKTYPE_SPELL,
							id = i,
						},
					}
					if duration <= 1.5 then
						entry.spell = "Global Cooldown"
						entry.texture = "Interface\\Icons\\Spell_Lightning_LightningBolt01"
					end
					self:CreateCooldown(entry)
				elseif start == 0 then
					self:RemoveCooldown(spellname,"spell")
				end
			end
		end
		lastusedspell = nil
	elseif event == "PET_BAR_UPDATE_COOLDOWN" then
		for i = 1,10 do
			local spellname = GetPetActionInfo(i)
			local _,_,texture = GetPetActionInfo(i)
			if spellname and (not cooldownsdata[texture]) then
				local start,duration,real = GetPetActionCooldown(i)
				if start > 0 and duration >= mincd and (duration <= maxcd or maxcd == 0) and real == 1 and self:TimerIsRelevent(start,duration) then
					local entry = {
						spell = spellname,
						rank = "", 
						texture = texture, 
						duration = duration, 
						time = start,
						type = "cooldown",
						english = spellname,
						info = {
							type = BOOKTYPE_PET,
							id = Cooldowns:ReturnPetID(spellname),
						},
					}
					self:CreateCooldown(entry)
				elseif start == 0 then
					self:RemoveCooldown(spellname,"spell")
				end
			end
		end
	end
end

function Cooldowns:TimerIsRelevent(start,duration,waslastcast)
	local module = (self:Get("dotimer") and DoTimer or Cooldowns)
	local i = module:ReturnTargetTable("Cooldowns ",0,0,self)
	if i then
		for id = module:GetNumTimers(i),1,-1 do
			local timer = module:GetTimer(i,id)
			if timer then
				if math.abs(timer.duration - duration) <= .1 and (math.abs(timer.time - start) <= .1) and Cooldowns:TimerIsReal(timer) then 
					if timer.spell == "Global Cooldown" then return false end
					if waslastcast then
						module:RemoveTimer(i,id,"replaced")
						return true
					else
						return false
					end
				end
			end
		end
	end
	return true
end

function Cooldowns:CreateCooldown(spelltable)
	local module = (Cooldowns:Get("dotimer") and DoTimer or Cooldowns)
	local i = module:ReturnTargetTable("Cooldowns ",0,0,self)
	if i then
		for id = module:GetNumTimers(i),1,-1 do
			local timer = module:GetTimer(i,id)
			if timer.spell == spelltable.spell then
				module:RemoveTimer(i,id,"inaccurate",1)
			end
		end
	end
	local cooldownsindex = module:ReturnTargetTable("Cooldowns ",0,0,self)
	if not cooldownsindex then cooldownsindex = module:AddTarget(module:CopyTable(cooldownstarget),nil,self) end
	module:AddTimer(cooldownsindex,spelltable,nil,self)
end

function Cooldowns:RemoveCooldown(spell,type)
	local time = GetTime()
	local module = (self:Get("dotimer") and DoTimer or Cooldowns)
	local i = module:ReturnTargetTable("Cooldowns ",0,0,self)
	if i then
		for id = module:GetNumTimers(i),1,-1 do
			local timer = module:GetTimer(i,id)
			if timer.spell == spell and time <= timer.time + timer.duration and timer.info.type == type and timer.module == self and self:TimerIsReal(timer) then
				module:RemoveTimer(i,id,"finished")
			end
		end
	end
end

function Cooldowns:CreateTimerTooltip(c,frame)
	if self:Get("tooltips") then
		GameTooltip:SetOwner(frame,"ANCHOR_RIGHT")
		if c.info then
			local type = c.info.type
			if type == BOOKTYPE_SPELL then
				GameTooltip:SetSpell(c.info.id,BOOKTYPE_SPELL)
			elseif type == "item" then
				GameTooltip:SetHyperlink(Cooldowns:ReturnItemLink(c.info.id))
			elseif type == BOOKTYPE_PET then
				GameTooltip:SetSpell(c.info.id,BOOKTYPE_PET)
			end
		else
			GameTooltip:AddLine(c.spell,1,1,1)
		end
		if c.english == "Soulstone" then GameTooltip:AppendText(string.format(" (%s)",c.rank)) end
		GameTooltip:AddLine("Left-click to announce.  Right-click to remove.  Shift+right-click to hide.",1,1,1,1)
		GameTooltip:Show()
	end
end

function Cooldowns:Commands(msg,bypass) --governs the /command
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
		self:Print("Type |cff00ff00/cooldowns help|r for more options, or |cff00ff00/cooldowns|r to open the menu!")
		return
	end
	if not bypass then self:UpdateInterface() end
end

function Cooldowns:ToChat(c)
	if c.module:TimerIsReal(c) then
		local displayed = c.displayed
		local spell = c.spell
		local rank = c.rank
		if (displayed and spell and rank) then
			displayed = self:ReturnFormattedDuration(displayed)
			local subentries,unsubbedmsg
			if c.english == "Soulstone" then
				subentries = {
					["%d"] = displayed,
					["%s"] = spell,
					["%t"] = rank,
				}
				unsubbedmsg = self:Get("chatmsgsoulstone")
			else
				subentries = {
					["%d"] = displayed,
					["%s"] = spell,
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

function Cooldowns:AddHelpMenu(msg) --the help menu displayed ingame
	if msg == "help info" then
		self:Print("|cff00ffffCooldowns Version/Author Info:|r")
		self:Print("|cff00ff00Current version|r: "..AsheylaLib:ReturnDateUploaded())
		self:Print("|cff00ff00Date Uploaded|r: "..AsheylaLib:ReturnDateUploaded())
		self:Print("|cff00ff00Author|r: Asheyla <Warcraft Gaming Faction>, Shattered Hand (Horde)")
		self:Print("|cff00ff00Email|r: ross456@gmail.com")
		self:Print("|cff00ff00Paypal Donations|r: ross456@gmail.com")
	else
		self:Print("|cff00ffffCooldowns Help Menu:|r")
		self:Print("|cff00ff00help info|r: displays some version/author info")
	end
end

defaultsettings = {
	dotimer = false,
	targetlayout = "down",
	mincd = 2,
	maxcd = 1,
	chatmsgnormal = "My cooldown for %s will complete in %d.",
	chatmsgsoulstone = "My soulstone on %t will expire in %d.",
	tooltips = true,
}
