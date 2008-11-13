CCBreaker = AceLibrary("AceAddon-2.0"):new("Parser-3.0","FuBarPlugin-2.0","AceConsole-2.0","AceDB-2.0")
local CCBabble  = AceLibrary("Babble-Spell-2.2")
local CCLocale  = AceLibrary("AceLocale-2.2"):new("CCBreaker")
local CCTablet = AceLibrary("Tablet-2.0")
CCBreaker.revision = tonumber(string.find("$Revision$","%d+")) or 1

-- Database

CCBreaker:RegisterDB("CCBreakerDB","CCBreakerDBPC")

-- basic datastructures

local oddline = {
	['text']="",
	['text2']="",
	['text3']="",
	['text4']="",
	['textR']=1,
	['textG']=1,
	['textB']=1,
	['text2R']=1,
	['text2G']=1,
	['text2B']=1,
	['text3R']=1,
	['text3G']=1,
	['text3B']=1,
	['text4R']=1,
	['text4G']=1,
	['text4B']=1,
	['justify']="LEFT",
	['justify2']="LEFT",
	['justify3']="LEFT",
	['justify4']="LEFT",
}

local evenline = {
	['text']="",
	['text2']="",
	['text3']="",
	['text4']="",
	['textR']=0.7,
	['textG']=0.7,
	['textB']=0.7,
	['text2R']=0.7,
	['text2G']=0.7,
	['text2B']=0.7,
	['text3R']=0.7,
	['text3G']=0.7,
	['text3B']=0.7,
	['text4R']=0.7,
	['text4G']=0.7,
	['text4B']=0.7,
	['justify']="LEFT",
	['justify2']="LEFT",
	['justify3']="LEFT",
	['justify4']="LEFT",
}


local breakers = {}

-- table recycling
local breakertablecache ={}

local function RecycleBreakerTable()
	while #breakers > 0 do
		table.insert(breakertablecache, table.remove(breakers))
	end
end

local function GetBreakerTable()
	local t
	if #breakertablecache > 0 then
		t = table.remove(breakertablecache)
	else
		t = {}
	end
	return t
end

function CCBreaker:reset()
	self.lastBreaker = nil
	RecycleBreakerTable()
	self:UpdateText()
end

-- Initialisation

CCBreaker.hasIcon = true

function CCBreaker:OnInitialize()
	self.defaultMinimapPosition = 300
end

function CCBreaker:OnEnable()
	self:RegisterParserEvent({eventType = "Dispel"},"CrowdControlBroken")
	self.raidid = 0
end

function CCBreaker:OnDisable()
end

-- Workload



local function CreateText(info,textatt)
	local hlcolor
	local basecolor
	local text
	strings = textatt.strings
	if (strings.two =="") then
		strings.two = CCLocale["[spell] on [target] was removed"]
	end
	if (strings.three =="") then
		strings.three = CCLocale["[spell] on [target] was removed by [breaker]"]
	end
	if (strings.four =="") then
		strings.four = CCLocale["[spell] on [target] was removed by [breaker]'s [ability]"]
	end

	if textatt.colors then
		hlcolor = textatt.color.colortext
		basecolor = "|r"
	else 
		hlcolor = ""
		basecolor = ""
	end
	text = basecolor
	if info.sourceName then
	  if info.sourceAbilityName then
		  text = string.gsub(strings.four,"%[ability%]",hlcolor..info.sourceAbilityName..basecolor)
	  else
		  text = strings.three
	  end
	  text = string.gsub(text,"%[breaker%]",hlcolor..info.sourceName..basecolor)
	else
	  text = strings.two
	end
	text = string.gsub(text,"%[spell%]",hlcolor..info.recipientAbilityName..basecolor)
	text = string.gsub(text,"%[target%]",hlcolor..info.recipientName..basecolor)
	return text
end

local function DisplayConsole(info)
	if CCBreaker.db.char.display.console.enable then
		CCBreaker:Print(CreateText(info,CCBreaker.db.char.display.console))
	end
end

function DisplayCenter(info)
	if CCBreaker.db.char.display.center.enable then
		UIErrorsFrame:AddMessage(CreateText(info,CCBreaker.db.char.display.center),
			1.0, 1.0, 1.0, 5.0)
	end
end

CCBreaker.filters={}
function CCBreaker.filters.unitfilter(filter,value)
	local id
	local name, class, role
	if value then
		unittype,unitnumber = string.match(value,"(%a*)(%d*)")
	else
		return filter.others
	end
	if ((not(unitnumber == "")) and UnitInRaid(value)) then
		name, _, _, _, _, class, _, _, _, role, _ = GetRaidRosterInfo(unitnumber)
	else
		if UnitInParty(value) then
			_,class = UnitClass(value)
			class = string.upper(class)
		end
	end
	

	
	local player = (unittype == "player")
	local party = (unittype == "party")
	local raid = (unittype == "raid")
	local pet = (unittype == "pet")
	local partypet = (unittype == "partypet")
	local raidpet = (unittype == "raidpet")
	
	-- I am in a raid
	if player and UnitInRaid(value) then
		local i = 0
		name, _, _, _, _, class, _, _, _, role, _ =  GetRaidRosterInfo(CCBreaker.raidid)
		if not(name == UnitName("player")) then
			i=1 --go search
		end
		if i >0 then
			local playername = UnitName("player")
			while i <= 40 do
				name, _, _, _, _, class, _, _, _, role, _ = GetRaidRosterInfo(i)
				if name == playername then
					CCBreaker.raidid = i
					i = 40
				end
				i=i+1
			end
		end
	end
	-- finaly got my role for sure
	local typevalue = (  --check
		( player and (filter.player)) or
		( party and (filter.party)) or
		( raid and (filter.raid)) or
		( pet and (filter.pet)) or
		( partypet and (filter.partypet)) or
		( raidpet and (filter.raidpet)) or
		(not (player or party or raid or pet or partypet or raidpet) and filter.others)
		)
	local classvalue = ( --check
		(filter.warrior and class == "WARRIOR") or
		(filter.warlock and class == "WARLOCK") or
		(filter.hunter and class == "HUNTER") or
		(filter.mage and class == "MAGE") or
		(filter.priest and class == "PRIEST") or
		(filter.druid and class == "DRUID") or
		(filter.paladin and class == "PALADIN") or
		(filter.shaman and class == "SHAMAN") or
		(filter.rogue and class == "ROGUE") or 
		(class == nil))
	local rolevalue =  not(((not filter.maintank) and role == "MAINTANK") or
			((not filter.mainassist) and role == "MAINASSIST"))
	return (typevalue and classvalue and rolevalue)
end


function CCBreaker.filters.showeffects(showeffects,spell)
	return (((spell == CCBabble["Shackle Undead"]) and (showeffects.shackleundead)) or
		((spell == CCBabble["Hibernate"]) and (showeffects.hibernate)) or
		((spell == CCBabble["Sap"]) and (showeffects.sap)) or
		((spell == CCBabble["Seduction"]) and (showeffects.seduction)) or
		(((spell == CCBabble["Polymorph"]) or (spell == CCBabble["Polymorph: Pig"]) 
			or (spell == CCBabble["Polymorph: Turtle"])) and (showeffects.polymorph)) or
		((spell == CCBabble["Freezing Trap Effect"]) and (showeffects.freezingtrap)))
end



function CCBreaker:filter(info)
	local filters = self.filters
	local sourceid
	local targetid


	local db = self.db.char
	local spell	= info.recipientAbilityName
	local showfrom = self.db.char.showfrom
	return (
		-- "Show on" filter 
		filters.unitfilter(db.showon,info.recipientID) and
		-- "Show From" filter
		filters.unitfilter(db.showfrom,info.sourceID) and
		-- "Show Effect" filter
		filters.showeffects(db.showeffects,info.recipientAbilityName)
	)   
end

function CCBreaker:OnTextUpdate()
	local text = {}
	local lastbreaker = self.lastBreaker
	local fubar = self.db.char.display.fubar
	if ((lastbreaker == nil) or not
		(fubar.spell or 
		fubar.target or
		fubar.breaker or
		fubar.ability
		))then 
		table.insert(text,"CCBreaker")
	else
		if fubar.spell then 
			table.insert(text,lastbreaker.spell)
		end
		if fubar.target then
			table.insert(text,lastbreaker.target)
		end
		if (fubar.breaker and not (lastbreaker.breaker=="")) then
			table.insert(text,lastbreaker.breaker)
		end
		if (fubar.ability and not (lastbreaker.ability=="")) then
			table.insert(text,lastbreaker.ability)
		end
	end 
		self:SetText(table.concat(text,"|"))
end

function CCBreaker:OnTooltipUpdate()
	local cat = CCTablet:AddCategory(
		'text',"",
		'columns', 4
	)
	
	cat:AddLine(
		'text', CCLocale["spell"],
		'text2',CCLocale["target"],
		'text3',CCLocale["breaker"],
		'text4',CCLocale["ability"],
		'textR',0,
		'textG',1,
		'textB',0,
		'text2R',0,
		'text2G',1,
		'text2B',0,
		'text3R',0,
		'text3G',1,
		'text3B',0,
		'text4R',0,
		'text4G',1,
		'text4B',0,
		'justify',"LEFT",
		'justify2',"LEFT",
		'justify3',"LEFT",
		'justify4',"LEFT"
	)

	local isodd = true
	local current
	
	for i=1, #breakers do
		if isodd then current = oddline else current = evenline end
		isodd = not isodd
		current['text'] = breakers[#breakers+1-i].spell
		current['text2'] = breakers[#breakers+1-i].target
		current['text3'] = breakers[#breakers+1-i].breaker
		current['text4'] = breakers[#breakers+1-i].ability
		cat:AddLine(current)
	end
	
	CCTablet:SetHint(CCLocale["Rightclick for options"])
end

function CCBreaker:CrowdControlBroken(info)
	if CCBreaker.db.char.debug then
		CCBreaker:PrintLiteral(info)
		CCBreaker:PrintLiteral(CCBreaker:filter(info))
		self:PrintLiteral(self.db.char.display.console)
	end
	if CCBreaker:filter(info) then
		DisplayConsole(info)
		DisplayCenter(info)
		
		--tooltip
		local breaker = GetBreakerTable()
		if (info.recipientAbilityName) then 
		breaker.spell = info.recipientAbilityName
		else
			breaker.spell = ""
		end
	
		if (info.recipientName) then 
			breaker.target = info.recipientName
		else
			breaker.target = ""
		end
		
		if (info.sourceAbilityName) then 
			breaker.ability = info.sourceAbilityName
		else
			breaker.ability = ""
		end
		
		if (info.sourceName) then 
			breaker.breaker = info.sourceName
		else
			breaker.breaker = ""
		end
		table.insert(breakers,breaker)
		self.lastBreaker = breaker
		self:UpdateText()
	end
end