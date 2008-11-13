local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 49002 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib
local ThreatMobTranslations = ThreatLib:NewModule("MobNameTranslation", "AceEvent-2.0", "AceComm-2.0")

------------------------------------------------------------------------------------
-- Mob name translations, for groups with clients of multiple locales
-- This automatically translates mob names across locales
------------------------------------------------------------------------------------

local lastTargetChangeTime, secondLastTargetChangeTime = GetTime(), GetTime()
local MyLocale = GetLocale()
-- MyLocale = "faKE"
local mobNameTranslations, translationHashes = {}, {}
local new, del, newHash, newSet = ThreatLib.new, ThreatLib.del, ThreatLib.newHash, ThreatLib.newSet
local TailoredBinaryCheckSum = ThreatLib.TailoredBinaryCheckSum
local partyMemberLocales = ThreatLib.partyMemberLocales
local threatTargets = ThreatLib.threatTargets

-- Check a unit and see if we have translations for it for all locales in our party
-- If not, issue a generic translation request.

local function unitIDString(unit)
	return ("%s:%s:%s:%s:%s"):format(
		select(2, UnitClass(unit)) or "[CLS]",
		select(2, UnitRace(unit)) or "[RAC]",
		UnitClassification(unit) or "[CFN]",
		UnitSex(unit) or "[SEX]",
		UnitManaMax(unit) or "[MMX]"
	)
end

function ThreatMobTranslations:OnInitialize()
	self.mobNameTranslationEnabled = false
	self.Debug = function(self, ...) ThreatLib.Debug(ThreatLib, ...) end
	ThreatLib.TranslateForeignMobHash = function(self, mobHash)
		if not ThreatMobTranslations.mobNameTranslationEnabled then return mobHash end
		return ThreatMobTranslations:TranslateForeignMobHash(mobHash)
	end
	ThreatLib.TranslateForeignMobName = function(self, mobName)
		if not ThreatMobTranslations.mobNameTranslationEnabled then return mobName end
		return ThreatMobTranslations:TranslateForeignMobName(mobName)
	end
end

function ThreatMobTranslations:OnEnable()
	self:Debug("Enabling translation...")
	if self.mobNameTranslationEnabled then return end
	self:Debug("Enabled translation!")
	self.mobNameTranslationEnabled = true
	self:RegisterEvent("UNIT_TARGET")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function ThreatMobTranslations:OnDisable()
	self.mobNameTranslationEnabled = false
end

function ThreatLib.OnCommReceiveWhisper:MOB_NAME_TRANSLATION_REQUEST(prefix, sender, distribution, mobName, fromLocale, idString)
	self:Debug("Received mob translations request from %s: %q in %s", sender, mobName, fromLocale)
	
	-- Don't need to respond to requests from people of our own locale
	if fromLocale == MyLocale then return end
	
	-- If we have an existing translation for this name, then just return it instead of checking our target
	if mobNameTranslations[foreignMobName] then
		self:Debug("Replying with cached translation: %q (%s) = %q (%s)", mobNameTranslations[foreignMobName][MyLocale], MyLocale, mobName, fromLocale)
		return mobNameTranslations[foreignMobName][MyLocale]
	end
	if GetTime() - secondLastTargetChangeTime < 2.0 then
		self:Debug("Ignoring translation request for %q from %s (%s): we have changed targets too rapidly", mobName, sender, fromLocale)
		return
	end

	if type(mobName) ~= "string" or type(fromLocale) ~= "string" then
		self:Debug("Invalid types received during MOB_NAME_TRANSLATION_REQUEST from %s", sender)
		return
	end
	if idString and unitIDString("target") ~= idString  then
		self:Debug("idString %q (%s) doesn't match target id string %q (%s)", idString, mobName, unitIDString("target"), UnitName("target"))
		return
	end

	local targetName = UnitName("target")
	if not targetName or targetName == ThreatLib.L["Unknown"] then
		self:Debug("Unable to get target name. Aborting translation request.")
		return 
	end
	
	-- They're giving us the name for our target, so store it
	ThreatMobTranslations:NewMobNameTranslation(targetName, fromLocale, mobName)
	self:Debug("Sending translation reply: %s (%s) = %s (%s)", mobName, fromLocale, targetName, MyLocale)
	ThreatLib:SendCommMessage("GROUP", "MOB_NAME_TRANSLATION_REPLY", mobName, fromLocale, targetName, MyLocale)
end

function ThreatLib.OnCommReceive:MOB_NAME_TRANSLATION_REPLY(prefix, sender, distribution, lMobName, lLocale, fMobName, fLocale)
	-- We don't want translations to locales that aren't ours
	if lLocale ~= MyLocale and fLocale ~= MyLocale then
		return
	end
	
	if type(lMobName) ~= "string" or type(lLocale) ~= "string" or type(fMobName) ~= "string" or type(fLocale) ~= "string" then
		return
	end
	self:Debug("Received mob translations reply from %s: %q (%s) = %q (%s)", sender, lMobName, lLocale, fMobName, fLocale)
	
	-- We don't really care who this is in reply to - we'll spy on all comms to build a list of target names

	local targetName = nil
	local targetLocale = nil
	local mobName = nil
	if fLocale == MyLocale then
		mobName = fMobName
		targetName = lMobName
		targetLocale = lLocale
	elseif lLocale == MyLocale then
		mobName = lMobName
		targetName = fMobName
		targetLocale = fLocale
	else -- no translation for us
		return
	end
	
	ThreatMobTranslations:NewMobNameTranslation(mobName, targetLocale, targetName)
end

-- We got new mobNameTranslations: store it, build translationHashes and reverse mobNameTranslations
function ThreatMobTranslations:NewMobNameTranslation(mobName, foreignLocale, foreignMobName)
	-- Not going to worry about table recycling here, as we'll likely just keep mob names around for the entire session.
	-- Anyone think we should do otherwise? Clear on zone-out or something?
	if foreignLocale == MyLocale then
		error("Translation error: Attempting to set a foreign translation for local locale. Please report to Antiarc.")
	end
	self:Debug("Got new translation for %s: %s (%s)", mobName, foreignMobName, foreignLocale)
	local t = mobNameTranslations[mobName]
	if not t then
		t = new()
		mobNameTranslations[mobName] = t
	end
	if t[foreignLocale] then
		if t[foreignLocale] ~= foreignMobName then
			error(string.format("Conflicting translation for %s in %s: old is %q, new is %q. Please report to Antiarc.", mobName, foreignLocale, t[foreignLocale], foreignMobName))
		end
		return
	end
	t[foreignLocale] = foreignMobName

	-- Also add reverse translation entry for TranslateForeignMobName()
	t = mobNameTranslations[foreignMobName]
	if not t then
		t = new()
		mobNameTranslations[foreignMobName] = t
	end
	if not t[MyLocale] then
		t[MyLocale] = mobName
	end

	-- Create a lookup table entry of foreign mob name hash = local mob name hash
	-- (I don't think we have to reiterate ALL mobNameTranslations here, just store hash of the new one)
	local mobHash = TailoredBinaryCheckSum[mobName]
	local foreignMobHash = TailoredBinaryCheckSum[foreignMobName]
	translationHashes[foreignMobHash] = mobHash

	-- If we got threat-data from other players for this mob before we got the translation, convert it
	for unitName, locale in pairs(partyMemberLocales) do
		if locale == foreignLocale then
			local data = threatTargets[unitName]
			if data then
				local fd = data[foreignMobHash]
				if fd then
					self:Debug("Converting threat from %s to %s (adding %s foreign threat to %s local)", foreignMobHash, mobHash, fd, (data[mobHash] or 0))
					data[foreignMobHash] = nil
					data[mobHash] = (data[mobHash] or 0) + fd				
				end
			end
		end
	end
end

function ThreatMobTranslations:TranslateForeignMobHash(mobHash)
	if not ThreatMobTranslations.mobNameTranslationEnabled then
		return mobHash
	end
	return translationHashes[mobHash] or mobHash
end

function ThreatMobTranslations:TranslateForeignMobName(mobName)
	if not ThreatMobTranslations.mobNameTranslationEnabled then
		return mobName
	end
	if mobNameTranslations[mobName] and mobNameTranslations[mobName][MyLocale] then
		return mobNameTranslations[mobName][MyLocale]
	end
	return mobName
end

function ThreatMobTranslations:UNIT_TARGET(unit)
	if not ThreatMobTranslations.mobNameTranslationEnabled then
		return
	end
	
	-- Make sure it isn't a pet
	if unit == "player" or unit == "npc" or not UnitIsPlayer(unit) or not (UnitInParty(unit) or UnitInRaid(unit)) then
		return
	end

	local targetUnit = unit .. "target"
	local partyMemberName = UnitName(unit)
	local foreignLocale = partyMemberLocales[partyMemberName]
	
	if UnitExists(targetUnit) and not UnitIsPlayer(targetUnit) and not UnitPlayerControlled(targetUnit) and foreignLocale and foreignLocale ~= MyLocale then
		local localMobName = UnitName(targetUnit)
		if not localMobName or localMobName == ThreatLib.L["Unknown"] then return end
		-- We already have a translation for the specified locale/mob
		if mobNameTranslations[localMobName] and mobNameTranslations[localMobName][foreignLocale] then
			return
		end
		local idString = unitIDString(targetUnit)

		-- We don't have it, ask them for the name
		self:Debug("Sending translation request for %q in %s to %s", localMobName, foreignLocale, partyMemberName)
		ThreatLib:SendCommMessage("WHISPER", partyMemberName, "MOB_NAME_TRANSLATION_REQUEST", localMobName, MyLocale, idString)
		-- ThreatLib:SendCommMessage("GROUP", "MOB_NAME_TRANSLATION_REQUEST", partyMemberName, localMobName, MyLocale, idString)
	end
end

function ThreatMobTranslations:PLAYER_TARGET_CHANGED()
	secondLastTargetChangeTime = lastTargetChangeTime
	lastTargetChangeTime = GetTime()
	-- GetNameTranslations(self, "target")
end

function ThreatLib:DumpTranslationHashes(mobName)
	if not AceLibrary:HasInstance("AceConsole-2.0") then
		error("Threat:DumpTranslationHashes() requires AceConsole-2.0", 2)
	end
	if mobName then
		AceLibrary("AceConsole-2.0"):PrintLiteral(translationHashes[mobName])
	else
		AceLibrary("AceConsole-2.0"):PrintLiteral(translationHashes)
	end
end

function ThreatLib:DumpTranslationTable(mobName)
	if not AceLibrary:HasInstance("AceConsole-2.0") then
		error("Threat:DumpTranslationTable() requires AceConsole-2.0", 2)
	end
	if mobName then
		AceLibrary("AceConsole-2.0"):PrintLiteral(mobNameTranslations[mobName])
	else
		AceLibrary("AceConsole-2.0"):PrintLiteral(mobNameTranslations)
	end
end

tinsert(ThreatLib.UpvalueFixers, function(lib, oldLib)
	ThreatLib = lib
end)

end