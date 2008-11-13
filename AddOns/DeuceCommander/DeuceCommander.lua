--[[
	DeuceCommander
		"A graphical interface for my Ace2 mods' /commands!? EGAD!"

    By Neronix of Hellscream EU
--]]

DeuceCommander = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceDB-2.0", "FuBarPlugin-2.0")

DeuceCommander.hasIcon = "Interface\\Icons\\INV_Gizmo_07"
DeuceCommander.defaultPosition = "RIGHT"
DeuceCommander.hasNoColor = true
DeuceCommander.cannotDetachTooltip = true

local console = AceLibrary("AceConsole-2.0")
local dewdrop = AceLibrary("Dewdrop-2.0")
local tablet = AceLibrary("Tablet-2.0")

local L = AceLibrary("AceLocale-2.2"):new("DeuceCommander");

L:RegisterTranslations("enUS", function() return {
	["Right-click me to get started!"] = true,
	["No description provided."] = true,
	["Others"] = true,
	["AddOns in category %q."] = true,
} end)

L:RegisterTranslations("frFR", function() return {
	["Right-click me to get started!"] = "Clic Droit pour d\195\169marrer!",
	["No description provided."] = "Pas de description fournie",
	["Others"] = "Autres",
	["AddOns in category %q."] = "AddOns dans la cat\195\169gorie",
} end)

L:RegisterTranslations("zhCN", function() return {
	["Right-click me to get started!"] = "右键点击显示菜单!",
	["No description provided."] = "没有提供描述",
	["Others"] = "其他",
	["AddOns in category %q."] = "%q 类插件.",
} end)

L:RegisterTranslations("zhTW", function() return {
	["Right-click me to get started!"] = "\n|cffeda55f右擊: |r顯示選單!",
	["No description provided."] = "沒有提供說明。",
	["Others"] = "其他",
	["AddOns in category %q."] = "在%q類別的插件。",    
} end)

L:RegisterTranslations("koKR", function() return {
	["Right-click me to get started!"] = "우클릭시 설정창을 엽니다!",
	["No description provided."] = "애드온에 대한 설명이 없습니다.",
	["Others"] = "기타",
	["AddOns in category %q."] = "%q 분류의 애드온들.",
} end)

L:RegisterTranslations("esES", function() return {
	["Right-click me to get started!"] = "\194\161ClicDerecho para iniciarme!",
	["No description provided."] = "No existe descripci\195\179n",
	["Others"] = "Otros",
	["AddOns in category %q."] = "Accesorios en la categor\195\173a %q",
} end)

DeuceCommander:RegisterDB("DeuceCommanderDB")

function DeuceCommander:OnInitialize()
	self:RegisterChatCommand({"/deucecommander", "/deucecomm"})

	-- Create the root of our AceOptions table, ready for addons' tables to be inserted
	self.theTable = { type = "group", args = {} }
end

function DeuceCommander:OnEnable()
	self:Construct()

	function self:OnMenuRequest(level, value)
		dewdrop:FeedAceOptionsTable(self.theTable)
		if level == 1 then dewdrop:AddLine() end
	end

	-- When another addon's loaded, :Construct again to check if the new addon's got a slash command to be added. It's run 2 seconds after ADDON_LOADED to ensure that its slash command is definitely registered
	self:RegisterEvent("ADDON_LOADED", function() self:ScheduleEvent(self.Construct, 2, self) end)
end

function DeuceCommander:OnTooltipUpdate()
	tablet:SetHint(L["Right-click me to get started!"])
end

local localizedCategory = setmetatable({}, { __index = function(self, category)
	local ret = AceLibrary("AceAddon-2.0"):GetLocalizedCategory(category)
	if ret == UNKNOWN then
		ret = L["Others"]
	end
	self[category] = ret
	return ret
end } )

function DeuceCommander:Construct()
	for k,v in pairs(console.registry) do -- v will be the current slash command being dealt with. k is almost always 8 randomly generated characters (Why, ckknight!?)

		-- Explanation of the following logic: If there's no handler and name attached to it, it's probably not a command we should deal with
		-- In a slash command we want to deal with, .handler is a link to the addon object that the command belongs to
		-- And if the entry for the mod's already there, no need to do it again
		if type(v) == "table" and v.handler and v.handler.name and not self.theTable.args[v.handler.name] then

			local addonName = v.handler.name
			local category = localizedCategory[GetAddOnMetadata(addonName, "X-Category") or "Others"]
			category = category:trim()
			if not self.theTable.args[category] then
				self.theTable.args[category] = {
					name = category,
					desc = string.format(L["AddOns in category %q."], category),
					type = "group",
					args = {}
				}
			end
			local cattbl = self.theTable.args[category]

			if (not v.name) or (v.name == "") then
				v.name = addonName
			end

			if (not v.desc) or (v.desc == "") then
				if (not v.handler.notes) or (v.handler.notes == "") then
					v.desc = L["No description provided."]
				else
					v.desc = v.handler.notes
				end
			end

			cattbl.args[addonName] = v -- Stick the mod's table in the root group
		end
	end
end

