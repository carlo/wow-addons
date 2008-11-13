local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 48189 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")
local name = "Firewing Warlock"

if GetLocale() == "koKR" then
	name = "불꽃날개 흑마법사"
elseif GetLocale() == "zhCN" then	
	name = "火翼术士"
elseif GetLocale() == "zhTW" then	
	name = "火翼術士"
end

-- You need to register the module with the localized mob name, as this is used to 
ThreatLib:GetModule("NPCCore"):RegisterModule(name, function(FirewingWarlock)
	local triggerStrings = {
		["enUS"] = "%s attempts to run away in fear!",
		["deDE"] = nil,
		["frFR"] = nil,
		["koKR"] = "%s|1이;가; 겁을 먹고 도망치려고 합니다!",
		["zhTW"] = nil,
		["zhCN"] = "%s受到恐惧逃走了",
	}

	function FirewingWarlock:Init()
		local phase2 = triggerStrings[_G.GetLocale()]
		triggerStrings = nil

		self:RegisterCombatant("Firewing Warlock", true)
	
		-- To register a callback to a yell or emote:
		-- self:RegisterChatEvent([yell|event], localizedMobName, yellOrEmoteToTriggerOn, callbackFunction)
		-- self:RegisterChatEvent("yell", BB["Attumen the Huntsman"], phaseThree, self.PhaseThree)
	
		self:RegisterChatEvent("emote", "Firewing Warlock", phase2, self.phaseTransition)
	end

	-- StartFight is called when you engage any of the mobs registered by RegisterCombatant()
	-- Use it to reset any state that you need to maintain in the module (like self.SetNumberOfMobs)
	function FirewingWarlock:StartFight()
		-- SetNumberOfMobs is used as a divisor for global threat. Be sure to set it correctly, and to account for mob deaths during the fight
		-- If you are unsure of the participants, or you want to just be safe, leave this at 1
		self:SetNumberOfMobs(1)
	end

	function FirewingWarlock:phaseTransition()
		DEFAULT_CHAT_FRAME:AddMessage(("|cffffff7f%s|r - Got trigger emote, wiping raid threat"):format(self.name))
		self:SetNumberOfMobs(1)
		self:WipeRaidThreatOnMob("Firewing Warlock")
	end
end

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end
