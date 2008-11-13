if IsAddOnLoaded("Titan") and not IsAddOnLoaded("FuBar") then
	-- Do not load if Titanbar is loaded
	return
end
local beql, self = beql, beql
local L = AceLibrary("AceLocale-2.2"):new("beql")
local Tablet = AceLibrary("Tablet-2.0")
beqlfu = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceEvent-2.0","FuBarPlugin-2.0")

beqlfu.title = "bEQL"
beqlfu.name = "beql"
beqlfu.revision = beql.revision
beqlfu.defaultPosition = "LEFT"
beqlfu.defaultMinimapPosition = 270
beqlfu.hideWithoutStandby = true
beqlfu.clickableTooltip = true
beqlfu.cannotDetachTooltip = false
beqlfu.hasIcon = "Interface\\Icons\\INV_Letter_03"
beqlfu.independentProfile = false

function beqlfu:OnInitialize()
    local _,questEntries = GetNumQuestLogEntries()
	self.db = beql:AcquireDBNamespace("fubar")
	beqlfu:SetText(questEntries.."/25")
	beql.options.args.fubar = {
		type = "group",
		name = L["FubarPlugin Config"],
		desc = L["FubarPlugin Config"],
		args = {},
	}
	AceLibrary("AceConsole-2.0"):InjectAceOptionsTable(self, beql.options.args.fubar)	
	beqlfu.OnMenuRequest = beql.options		
end

function beqlfu:OnTooltipUpdate()
    local _,questEntries = GetNumQuestLogEntries()
    local _, numfinished = beqlQ:GetNumQuests()
	beqlfu:SetText(questEntries.."/25")
    local cat = Tablet:AddCategory(
        'columns', 2
    )
    cat:AddLine(
		'text', " ",
		'text2'," "
	)
    
    cat:AddLine(
        'text', L["|cffffffffQuests|r"],
        'text2', questEntries
    )
    
    cat:AddLine(
        'text', L["|cffff8000Tracked Quests|r"],
        'text2', GetNumQuestWatches()
    )
    
    cat:AddLine(
        'text', L["|cff00d000Completed Quests|r"],
        'text2', numfinished
    )    
	Tablet:SetHint(L["|cffeda55fClick|r to open Quest Log and |cffeda55fShift+Click|r to open Waterfall config"])    
end

function beqlfu:OnClick()
	if IsShiftKeyDown() then
		beqlwaterfall:Open("bEQL")
	else
		ToggleQuestLog()
	end
end