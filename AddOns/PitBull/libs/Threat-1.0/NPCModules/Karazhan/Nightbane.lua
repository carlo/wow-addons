local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54018 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Nightbane"], BB["Restless Skeleton"], function(Nightbane)
	Nightbane:RegisterTranslation("enUS", function() return {
		["Enough! I shall land and crush you myself!"] = "Enough! I shall land and crush you myself!",
		["Insects! Let me show you my strength up close!"] = "Insects! Let me show you my strength up close!",
		["Miserable vermin. I shall exterminate you from the air!"] = "Miserable vermin. I shall exterminate you from the air!",
		["Smoldering Breath"] = "Smoldering Breath"
	} end)

	Nightbane:RegisterTranslation("deDE", function() return {
		["Enough! I shall land and crush you myself!"] = "Genug! Ich werde landen und mich h\195\182chst pers\195\182nlich um Euch k\195\188mmern!",
		["Insects! Let me show you my strength up close!"] = "Insekten! Lasst mich Euch meine Kraft aus n\195\164chster N\195\164he demonstrieren!",
		["Miserable vermin. I shall exterminate you from the air!"] = "Abscheuliches Gew\195\188rm! Ich werde euch aus der Luft vernichten!",
		["Smoldering Breath"] = nil
	} end)

	Nightbane:RegisterTranslation("frFR", function() return {
		["Enough! I shall land and crush you myself!"] = "Assez ! Je vais atterrir et vous écraser moi-même !",
		["Insects! Let me show you my strength up close!"] = "Insectes ! Je vais vous montrer de quel bois je me chauffe !",
		["Miserable vermin. I shall exterminate you from the air!"] = "Misérable vermine. Je vais vous exterminer des airs !",
		["Smoldering Breath"] = "Souffle ardent"
	} end)

	Nightbane:RegisterTranslation("koKR", function() return {
		["Enough! I shall land and crush you myself!"] = "그만! 내 친히 내려가서 너희를 짓이겨주마!",
		["Insects! Let me show you my strength up close!"] = "하루살이 같은 놈들! 나의 힘을 똑똑히 보여주겠다!",
		["Miserable vermin. I shall exterminate you from the air!"] = "이 더러운 기생충들, 내가 하늘에서 너희의 씨를 말리리라!",
		["Smoldering Breath"] = nil
	} end)

	Nightbane:RegisterTranslation("zhTW", function() return {
		["Enough! I shall land and crush you myself!"] = "夠了!我要親自挑戰你!",
		["Insects! Let me show you my strength up close!"] = "昆蟲!給你們近距離嚐嚐我的厲害!",
		["Miserable vermin. I shall exterminate you from the air!"] = "悲慘的害蟲。我將讓你消失在空氣中!",
		["Smoldering Breath"] = "悶息術"
	} end)
	
	Nightbane:RegisterTranslation("zhCN", function() return {
		["Enough! I shall land and crush you myself!"] = "够了！我要落下来把你们打得粉碎！",
		["Insects! Let me show you my strength up close!"] = "没用的虫子！让你们见识一下我的力量吧！",
		["Miserable vermin. I shall exterminate you from the air!"] = "可怜的渣滓。我要腾空而起，让你尝尝毁灭的滋味！",
		["Smoldering Breath"] = "浓烟吐息"
	} end)

	------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------
	local yell1 = Nightbane:GetTranslation("Enough! I shall land and crush you myself!")
	local yell2 = Nightbane:GetTranslation("Insects! Let me show you my strength up close!")
	local yell3 = Nightbane:GetTranslation("Miserable vermin. I shall exterminate you from the air!")
	local breath = Nightbane:GetTranslation("Smoldering Breath")

	Nightbane:UnregisterTranslations()

	function Nightbane:Init()
		self:RegisterCombatant(BB["Nightbane"], true)
		self:RegisterCombatant(BB["Restless Skeleton"], self.SingleDeath)

		self:RegisterChatEvent("yell", BB["Nightbane"], yell1, self.endPhaseTransition)
		self:RegisterChatEvent("yell", BB["Nightbane"], yell2, self.endPhaseTransition)
		self:RegisterChatEvent("yell", BB["Nightbane"], yell3, self.startPhaseTransition)
		
		if breath then
			self:RegisterModuleVar(breath, "NightbaneBreathMultiplier", 1.0)
			self.attacks[breath] = function(self, mob, target)
				local multiplier = self:GetModuleVar("NightbaneBreathMultiplier", 1.0)
				self.ModifyThreat(mob, target, multiplier, 0)
			end
		end
	end

	function Nightbane:StartFight()
		self:SetNumberOfMobs(1)
	end

	function Nightbane:startPhaseTransition()
		if BB["Restless Skeleton"] then
			self:SetNumberOfMobs(6)		-- Nightbane + 5 skeletons
			self:WipeRaidThreatOnMob(BB["Restless Skeleton"])
		end	
	end

	function Nightbane:endPhaseTransition()
		self:WipeRaidThreatOnMob(BB["Nightbane"])
	end
end)

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end
