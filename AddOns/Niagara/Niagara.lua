--[[
	Niagara
		"A graphical interface for my Ace2 mods' /commands!? 
	The main Library that this addon is based on is in early beta and will be buggy
	Code heavily used from DeuceCommander  By Neronix of Hellscream EU thanks
--]] 
local waterfall = AceLibrary("Waterfall-1.0")
local console = AceLibrary("AceConsole-2.0")
 
Niagara = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceDB-2.0", "FuBarPlugin-2.0")--, "AceHook-2.1")

local L = AceLibrary("AceLocale-2.2"):new("Niagara")

L:RegisterTranslations("enUS", function() return {
	["Open"] = true,
	["Opens GUI"] = true,
	["Categories"] = true,
	["Toggle Category view"] = true,
	["Disabled"] = true,
	["Enabled"] = true,
	["TreeType"] = true,
	["Toggle Tree types"] = true,
	["Click To Open GUI"]= true,
    ["No description provided."] = true,
    ["Others"] = true,
    ["AddOns in category %q."] = true,
	["Niagara falls"] = true,
	["SECTIONS"] = true,
	["TREE"] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["Open"] = "열기",
	["Opens GUI"] = "GUI창을 엽니다",
	["Categories"] = "분류",
	["Toggle Category view"] = "분류별 보기를 토글합니다",
	["Disabled"] = "사용 안함",
	["Enabled"] = "사용",
	["TreeType"] = "분류별 구조",
	["Toggle Tree types"] = "분류별 구조 방식을 토글합니다",
	["Click To Open GUI"]= "클릭시 GUI창을 엽니다",
	["No description provided."] = "제공된 상세 설명이 없습니다.",
	["Others"] = "기타",
	["AddOns in category %q."] = "%q 분류 내 애드온",
} end)

L:RegisterTranslations("zhTW", function() return {
	["Open"] = "開啟",
	["Opens GUI"] = "開啟設定介面",
	["Categories"] = "分類",
	["Toggle Category view"] = "切換分類顯示",
	["Disabled"] = "停用",
	["Enabled"] = "啟用",
	["TreeType"] = "樹狀結構",
	["Toggle Tree types"] = "切換樹狀結構",
	["Click To Open GUI"]= "\n|cffeda55f左擊: |r開啟設定介面。",
    ["No description provided."] = "沒有提供說明。",
    ["Others"] = "其他",
    ["AddOns in category %q."] = "在%q分類的插件。",
	["Niagara falls"] = "Niagara falls",
	["SECTIONS"] = "分段",
	["TREE"] = "樹狀",
} end)

L:RegisterTranslations("zhCN", function() return {
	["Open"] = "开启",
	["Opens GUI"] = "开启设定接口",
	["Categories"] = "分类",
	["Toggle Category view"] = "切换分类显示",
	["Disabled"] = "停用",
	["Enabled"] = "启用",
	["TreeType"] = "树状结构",
	["Toggle Tree types"] = "切换树状结构",
	["Click To Open GUI"]= "点击开启设定接口",
    ["No description provided."] = "没有提供说明。",
    ["Others"] = "其它",
    ["AddOns in category %q."] = "在 %q 分类的插件。",
} end)


L:RegisterTranslations("deDE", function() return {
	["Open"] = "\195\150ffnen",
	["Opens GUI"] = "\195\150ffnet die Benutzeroberfl\195\164che",
	["Categories"] = "Kategorien",
	["Toggle Category view"] = "Die Kategorieansicht umschalten",
	["Disabled"] = "Deaktiviert",
	["Enabled"] = "Aktiviert",
	["TreeType"] = "TreeType",
	["Toggle Tree types"] = "TreeTypes umschalten",
	["Click To Open GUI"]= "Klicken, um die Benutzeroberfl\195\164che zu \195\182ffnen",
    ["No description provided."] = "Keine Beschreibung verf\195\188gbar.",
    ["Others"] = "Andere",
    ["AddOns in category %q."] = "Addons in Kategorie %q.",
} end)

Niagara.Menu = { 
	type = "group", 
	args = {
		Open = {
			name = L["Open"],
			order = 1,
			type = "execute",
			desc = L["Opens GUI"],
			disabled = "~IsActive",
			func = function() waterfall:Open("Niagara") AceLibrary("Dewdrop-2.0"):Close() end,
		},
		Category = {
			name = L["Categories"],
			desc = L["Toggle Category view"],
			type = "toggle",
			order = 2,
			get = function() return Niagara.db.profile.cat end,
			set = "cat",
			map = { [false] = L["Disabled"], [true] = L["Enabled"] }
		},
		TreeType = {
			name = L["TreeType"],
			desc = L["Toggle Tree types"],
			type = "text",
			order = 3,
			get = function() return Niagara.db.profile.tt end,
			set = "tree",
			validate = { SECTIONS = L["SECTIONS"], TREE = L["TREE"]}
		}
}}

Niagara.hasIcon = "Interface\\Icons\\Ability_Creature_Cursed_05"
Niagara.defaultPosition = "RIGHT"
Niagara.hasNoColor = true
Niagara.cannotDetachTooltip = true
Niagara.hideWithoutStandby = true
Niagara.OnMenuRequest = Niagara.Menu

function Niagara:OnInitialize()
self:RegisterDB("NiagaraDB")
self:RegisterDefaults("profile", {tt = "SECTIONS", cat = 0})
self.revision = tonumber(string.sub("$Rev: 49275 $", 7, -3))
self.version = self.version .. " |cffff8888r"..self.revision.."|r"
self:RegisterChatCommand({"/Niagara"}, self.Menu)
end

function Niagara:OnEnable()
self.theTable = {type = "group", args = {}}
self:ScheduleEvent(self.InitialConstruct, 3, self)
waterfall:Register("Niagara", "title", L["Niagara falls"], 'treeType', self.db.profile.cat and "TREE" or self.db.profile.tt, "aceOptions", self.theTable, "colorR", 0.4, "colorG", 0.6, "colorB", 0.8)
end

function Niagara:OnDisable()
waterfall:Close("Niagara")
waterfall:UnRegister("Niagara")
end

function Niagara:InitialConstruct()
self:Construct()
self:RegisterEvent("Ace2_AddonInitialized", "Construct")
end

function Niagara:Construct()
	for k,v in pairs(AceLibrary("AceConsole-2.0").registry) do
		if type(v) == "table" and v.handler and v.handler.name and not self.theTable.args[v.handler.name] then
			local addonName = v.handler.name
			if string.find(addonName, ".") then addonName = string.gsub(addonName, "%.", "") end
			if not v.name or v.name == "" then
				v.name = addonName
			end
			if (not v.desc) or (v.desc == "") then
				if (not v.handler.notes) or (v.handler.notes == "") then
					v.desc = L["No description provided."]
				else
					v.desc = v.handler.notes
				end
			end
			if v.args then
				if self.db.profile.cat then
					local category = GetAddOnMetadata(addonName, "X-Category") and AceLibrary("AceAddon-2.0"):GetLocalizedCategory(GetAddOnMetadata(addonName, "X-Category")) or L["Others"]
						if not self.theTable.args[category] then
							self.theTable.args[category] = {
								name = category,
								desc = string.format(L["AddOns in category %q."], category),
								type = "group",
								args = {}
							}
						end
					self.theTable.args[category].args[addonName] = v
				else
					self.theTable.args[addonName] = v
				end
				waterfall:Refresh("Niagara")
			end
		end
	end
	--[[
	if PitBull and not self.db.profile.cat then
		self.theTable.args.PitBull = PitBull.options
	elseif PitBull and self.db.profile.cat then
		local category = AceLibrary("AceAddon-2.0"):GetLocalizedCategory(GetAddOnMetadata("PitBull", "X-Category"))
		if not self.theTable.args[category] then
			self.theTable.args[category] = {
				name = category,
				desc = string.format(L["AddOns in category %q."], category),
				type = "group",
				args = {}
			}
		end
		self.theTable.args[category].args["PitBull"] = PitBull.options
	end]]
end

function Niagara:cat()
waterfall:Close("Niagara")
self.db.profile.cat = not self.db.profile.cat
self.theTable = {type = "group", args = {}}
self:Construct()
waterfall:Register("Niagara", "title", L["Niagara falls"], 'treeType', self.db.profile.cat and "TREE" or self.db.profile.tt, "aceOptions", self.theTable, "colorR", 0.4, "colorG", 0.6, "colorB", 0.8)
end

function Niagara:tree(v)
waterfall:Close("Niagara")
self.db.profile.tt = v
waterfall:Register("Niagara", "title", L["Niagara falls"], 'treeType', self.db.profile.cat and "TREE" or self.db.profile.tt, "aceOptions", self.theTable, "colorR", 0.4, "colorG", 0.6, "colorB", 0.8)
end

function Niagara:OnClick()
	waterfall:Open("Niagara")
end

function Niagara:OnTooltipUpdate()
	AceLibrary("Tablet-2.0"):SetHint(L["Click To Open GUI"])
end 
