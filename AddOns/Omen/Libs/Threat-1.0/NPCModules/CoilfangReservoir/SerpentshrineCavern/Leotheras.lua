local MAJOR_VERSION = "Threat-1.0"
local MINOR_VERSION = tonumber(("$Revision: 54018 $"):match("%d+"))

if MINOR_VERSION > _G.ThreatLib_MINOR_VERSION then
	_G.ThreatLib_MINOR_VERSION = MINOR_VERSION
end

ThreatLib_funcs[#ThreatLib_funcs+1] = function()

local ThreatLib = _G.ThreatLib

local BB = AceLibrary("Babble-Boss-2.2")

ThreatLib:GetModule("NPCCore"):RegisterModule(BB["Leotheras the Blind"], BB["Shadow of Leotheras"], function(Leotheras)
	Leotheras:RegisterTranslation("enUS", function() return {
		["Be gone, trifling elf.  I am in control now!"] = "Be gone, trifling elf.  I am in control now!",
		["No... no! What have you done? I am the master! Do you hear me? I am... aaggh! Can't... contain him."] = "No... no! What have you done? I am the master! Do you hear me? I am... aaggh! Can't... contain him.",
		["Finally, my banishment ends!"] = "Finally, my banishment ends!",
		["Whirlwind fades from Leotheras the Blind."] = "Whirlwind fades from Leotheras the Blind."
	} end)

	Leotheras:RegisterTranslation("deDE", function() return {
		["Be gone, trifling elf.  I am in control now!"] = "Ich habe jetzt die Kontrolle!",
		["No... no! What have you done? I am the master! Do you hear me? I am... aaggh! Can't... contain him."] = "Ich bin der Meister! H\195\182rt Ihr?",
		["Finally, my banishment ends!"] = "Endlich hat meine Verbannung ein Ende!",
		["Whirlwind fades from Leotheras the Blind."] = "Wirbelwind schwindet von Leotheras der Blinde."
	} end)

	Leotheras:RegisterTranslation("frFR", function() return {
		["Be gone, trifling elf.  I am in control now!"] = "Hors d'ici, elfe insignifiant. Je prends le contrôle !",
		["No... no! What have you done? I am the master! Do you hear me? I am... aaggh! Can't... contain him."] = "Non… Non ! Mais qu'avez-vous fait ? C'est moi le maître ! Vous entendez ? Moi ! Je suis… Aaargh ! Impossible… de… retenir…",
		["Finally, my banishment ends!"] = "Enfin, mon exil s'achève !",
		["Whirlwind fades from Leotheras the Blind."] = "Tourbillon sur Leotheras l'Aveugle vient de se dissiper."
	} end)

	Leotheras:RegisterTranslation("koKR", function() return {
		["Be gone, trifling elf.  I am in control now!"] = "꺼져라, 엘프 꼬맹이. 지금부터는 내가 주인이다!",
		["No... no! What have you done? I am the master! Do you hear me? I am... aaggh! Can't... contain him."] = "안 돼... 안 돼! 무슨 짓이냐? 내가 주인이야! 내 말 듣지 못해? 나란 말이야! 내가... 으아악! 놈을 억누를 수... 없... 어.",
		["Finally, my banishment ends!"] = "드디어, 내가 풀려났도다!",
		["Whirlwind fades from Leotheras the Blind."] = "눈먼 레오테라스의 몸에서 소용돌이 효과가 사라졌습니다."
	} end)

	Leotheras:RegisterTranslation("zhTW", function() return {
		["Be gone, trifling elf.  I am in control now!"] = "消失吧，微不足道的精靈。現在開始由我掌管!",
		["No... no! What have you done? I am the master! Do you hear me? I am... aaggh! Can't... contain him."] = "不…不!你做了什麼?我是主人!你沒聽見我在說話嗎?我…..啊!無法…控制它。",
		["Finally, my banishment ends!"] = "終於結束了我的流放生涯!",
		["Whirlwind fades from Leotheras the Blind."] = "旋風斬效果從『盲目者』李奧薩拉斯身上消失。"
	} end)
	
	Leotheras:RegisterTranslation("zhCN", function() return {
		["Be gone, trifling elf.  I am in control now!"] = "滚开吧，脆弱的精灵。现在我说了算！",
		["No... no! What have you done? I am the master! Do you hear me? I am... aaggh! Can't... contain him."] = "不……不！你在干什么？我才是主宰！你听到没有？我……啊啊啊啊！控制……不住了。",
		["Finally, my banishment ends!"] = "我的放逐终于结束了！",
		["Whirlwind fades from Leotheras the Blind."] = "旋风斩效果从盲眼者莱欧瑟拉斯身上消失。"
	} end)

	local whirlwindTrigger = Leotheras:GetTranslation("Whirlwind fades from Leotheras the Blind.")
	local demonPhase = Leotheras:GetTranslation("Be gone, trifling elf.  I am in control now!")
	local splitPhase = Leotheras:GetTranslation("No... no! What have you done? I am the master! Do you hear me? I am... aaggh! Can't... contain him.")
	local initialPhase = Leotheras:GetTranslation("Finally, my banishment ends!")

	Leotheras:UnregisterTranslations()

	function Leotheras:Init()
		if not whirlwindTrigger then
			error(("No ThreatLib localization available for %s in locale %s"):format(BB["Leotheras the Blind"], GetLocale()))
		end

		self:RegisterCombatant(BB["Leotheras the Blind"], true)
		self:RegisterCombatant(BB["Shadow of Leotheras"], false)

		self:RegisterChatEvent("yell", BB["Leotheras the Blind"], demonPhase, self.demonTransition)
		self:RegisterChatEvent("yell", BB["Leotheras the Blind"], splitPhase, self.splitTransition)
		self:RegisterChatEvent("yell", BB["Leotheras the Blind"], initialPhase, self.humanTransition)
	end

	function Leotheras:demonTransition()
		self:SetNumberOfMobs(1)
		self:WipeAllRaidThreat()
		ThreatLib:Debug("Wiping due to demon transition!")
		-- self:WipeRaidThreatOnMob(BB["Leotheras the Blind"])
		-- self:WipeRaidThreatOnMob(BB["Shadow of Leotheras"])
		if self:IsEventScheduled("LeotherasWhirlwindTimer") then
			self:CancelScheduledEvent("LeotherasWhirlwindTimer")
		end
		self:ScheduleEvent("LeotherasDemonTimer", self.humanTransition, 60, self)
	end

	function Leotheras:humanTransition()
		ThreatLib:Debug("Wiping due to human transition!")
		self:WipeAllRaidThreat()
		-- self:WipeRaidThreatOnMob(BB["Leotheras the Blind"])
	end

	function Leotheras:StartFight()
		self:SetNumberOfMobs(1)
	end

	function Leotheras:splitTransition()
		ThreatLib:Debug("Wiping due to split transition!")
		self:SetNumberOfMobs(2)		-- Leotheras + Shadow of Leotheras
		self:WipeAllRaidThreat()
		-- self:WipeRaidThreatOnMob(BB["Leotheras the Blind"])
		-- self:WipeRaidThreatOnMob(BB["Shadow of Leotheras"])
		if self:IsEventScheduled("LeotherasDemonTimer") then
			self:CancelScheduledEvent("LeotherasDemonTimer")
		end
	end

	function Leotheras:OnEnable()
		-- This is really, really, really probably the wrong way to do this.
		ThreatLib:GetModule("NPCCore").modulePrototype.OnEnable(self)
		self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	end

	function Leotheras:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
		if msg == whirlwindTrigger then
			ThreatLib:Debug("Got whirlwind trigger")
			self:ScheduleEvent("LeotherasWhirlwindTimer", self.humanTransition, 12, self)
			--self:humanTransition()
		end
	end
end)

table.insert(ThreatLib.UpvalueFixers, function(lib)
	ThreatLib = lib
end)

end
