local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54284 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Attumen the Huntsman"], BB["Midnight"], function(Attumen)
	Attumen:RegisterTranslation("enUS", function() return {
		["%s calls for her master!"] = "%s calls for her master!",
		["Come Midnight, let's disperse this petty rabble!"] = "Come Midnight, let's disperse this petty rabble!"
	} end)

	Attumen:RegisterTranslation("deDE", function() return {
		["%s calls for her master!"] = "%s ruft nach ihrem Meister!",
		["Come Midnight, let's disperse this petty rabble!"] = "Komm Mittnacht, lass' uns dieses Gesindel auseinander treiben!"
	} end)

	Attumen:RegisterTranslation("frFR", function() return {
		["%s calls for her master!"] = "%s appelle son maître !",
		["Come Midnight, let's disperse this petty rabble!"] = "Viens, Minuit, allons disperser cette insignifiante racaille !"
	} end)

	Attumen:RegisterTranslation("koKR", function() return {
		["%s calls for her master!"] = "%s|1이;가; 주인을 부릅니다!",
		["Come Midnight, let's disperse this petty rabble!"] = "이랴! 이 오합지졸을 데리고 실컷 놀아보자!"
	} end)

	Attumen:RegisterTranslation("zhTW", function() return {
		["%s calls for her master!"] = "%s呼叫他的主人!",
		["Come Midnight, let's disperse this petty rabble!"] = "來吧午夜，讓我們驅散這群小規模的烏合之眾!"
	} end)

	Attumen:RegisterTranslation("zhCN", function() return {
		["%s calls for her master!"] = "%s呼叫她的主人！",--check
		["Come Midnight, let's disperse this petty rabble!"] = "来吧，午夜，让我们解决这群乌合之众！"
	} end)

	local phaseTwo = Attumen:GetTranslation("%s calls for her master!")
	local phaseThree = Attumen:GetTranslation("Come Midnight, let's disperse this petty rabble!")

	Attumen:UnregisterTranslations()

	function Attumen:Init()
		self:RegisterCombatant(BB["Midnight"])
		self:RegisterCombatant(BB["Attumen the Huntsman"], true)

		self:RegisterChatEvent("emote", BB["Midnight"], phaseTwo, self.PhaseTwo)
		self:RegisterChatEvent("yell", BB["Attumen the Huntsman"], phaseThree, self.PhaseThree)
	end

	-- StartFight is called when you engage any of the mobs registered by RegisterCombatant()
	-- Use it to reset any state that you need to maintain in the module (like self.SetNumberOfMobs)
	function Attumen:StartFight()
		-- SetNumberOfMobs is used as a divisor for global threat. Be sure to set it correctly, and to account for mob deaths during the fight
		-- If you are unsure of the participants, or you want to just be safe, leave this at 1
		self:SetNumberOfMobs(1)
	end

	function Attumen:PhaseTwo()
		self:SetNumberOfMobs(2)
	end

	function Attumen:PhaseThree()
		self:SetNumberOfMobs(1)
		self:WipeAllRaidThreat()
	end
end)

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end
