--[[
-- Name: TinyTip
-- Author: Thrae of Maelstrom (aka "Matthew Carras")
-- Release Date: 6-25-06
--
-- These functions allow you to change options via a
-- Dewdrop GUI. Loaded on demand by TinyTip.
--
-- This part does NOT need to be localized, look in
-- TinyTipChatLocale_xxXX.lua.
--]]

local _G = getfenv(0)
local core = TinyTip
local L = _G.TinyTipOptionsLocale
local title = select(2, GetAddOnInfo("TinyTipOptions"))
local db, _

local config = LibStub("AceConfig-3.0")
local dialog = LibStub("AceConfigDialog-3.0")

local module = core:NewModule("TinyTipOptions")

local defaults = {
    ["MAnchor"] = "CURSOR",
    ["FAnchor"] = "GAMEDEFAULT",
    ["Scale"] = 1.0,
}

local function toggle(info)
    db = core:GetDB()
    local k = info[#info]
    db[k] = nil or not db[k]
    core:ReInitialize()
end

local function get(info)
    db = core:GetDB()
    local k = info[#info]
    return db[k] or defaults[k]
end

local function set(info,value)
    db = core:GetDB()
    local k = info[#info]
    if value and value == defaults[k] then
        value = nil
    end
    db[k] = value
    core:ReInitialize()
end

local function getnum(info)
    db = core:GetDB()
    return db[info[#info]] or 0
end

local function setnum(info,value)
    db = core:GetDB()
    local k = info[#info]
    value = tonumber(value)
    if value and value == defaults[k] then
        value = nil
    end
    db[k] = tonumber(value)
    core:ReInitialize()
end

local function geti(info)
    db = core:GetDB()
    return db[info[#info]] or 1
end

local function seti(info,value)
    db = core:GetDB()
    value = tonumber(value)
    value = value - 1
    if value < 1 then value = nil end
    db[info[#info]] = value
    core:ReInitialize()
end

local function DDAddRadioBoxes(opt, map, func, default)
    local k,v
    dewdrop:AddLine('text', default or L.GameDefault,
        'isRadio', true,
        'checked', not db[opt],
        'func', func or SetDB,
        'arg1', opt
    )
    for k,v in pairs(map) do
        dewdrop:AddLine('text', L[v] or v,
            'isRadio', true,
            'checked', db[opt] == k,
            'func', func or SetDB,
            'arg1', opt,
            'arg2', k
        )
    end
end

local function createToggle(opt, order)
    return {
        type = "toggle",
        order = order,
        get = get,
        set = toggle,
        name = L["Opt_" .. opt],
        desc = L["Desc_" .. opt],
    }
end

local function createNumInput(opt, order)
    return {
        type = "input",
        order = order,
        get = getnum,
        set = setnum,
        name = L["Opt_" .. opt],
        desc = L["Desc_" .. opt],
    }
end

local function createSelection(opt, order, map, default)
    for _,v in ipairs(map) do
        if L[v] then v = L[v] end
    end
    table.insert(map, 1, default)

    return {
        type = "select",
        order = order,
        get = geti,
        set = seti,
        name = L["Opt_" .. opt],
        desc = L["Desc_" .. opt],
        values = map,
    }
end

local function createRange(opt, order, min, max, ispercent)
    return {
        type = "range",
        order = order,
        get = getnum,
        set = setnum,
        name = L["Opt_" .. opt],
        desc = L["Desc_" .. opt],
        min = min,
        max = max,
        isPercent = ispercent,
    }
end

local options
function module:Initialize()
    if not options then
        local Map_MAnchor = {
            ["GAMEDEFAULT"] = L.GameDefault,
            ["CURSOR"] = L.CURSOR,
        }
        local Map_FAnchor = {
            ["GAMEDEFAULT"] = L.GameDefault,
            ["CURSOR"] = L.CURSOR,
            ["SMART"] = L.SMART,
        }
        for k,v in pairs(L.Map_Anchor) do
            Map_MAnchor[k] = v
            Map_FAnchor[k] = v
        end

        options = {
            type = "group",
            name = title,
            args = {
                positioning = {
                    type = "group",
                    order = 2,
                    name = L["Opt_Main_Anchor"],
                    desc = L["Desc_Main_Anchor"],
                    args = {
                        ["MAnchor"] = {
                            type = "select",
                            order = 2,
                            get = get,
                            set = set,
                            name = L["Opt_MAnchor"],
                            desc = L["Desc_MAnchor"],
                            values = Map_MAnchor,
                        },
                        ["MOffX"] = createNumInput("MOffX", 3),
                        ["MOffY"] = createNumInput("MOffY", 4),
                        ["FAnchor"] = {
                            type = "select",
                            order = 5,
                            get = get,
                            set = set,
                            name = L["Opt_FAnchor"],
                            desc = L["Desc_FAnchor"],
                            values = Map_FAnchor,
                        },
                        ["FOffX"] = createNumInput("FOffX", 6),
                        ["FOffY"] = createNumInput("FOffY", 7),
                    }, -- args
                }, -- positioning

                basic = {
                    type = "group",
                    order = 3,
                    name = L["Opt_Main_Text"],
                    desc = L["Desc_Main_Text"],
                    args = {
                        ["PvPRankText"] = createSelection("PvPRankText", 2, L.Map_PvPRankText, L.TinyTipDefault),
                        ["HideRace"] = createToggle("HideRace", 3),
                        ["HideNPCType"] = createToggle("HideNPCType", 4),
                        ["KeyElite"] = createToggle("KeyElite", 5),
                        ["ReactionText"] = createToggle("ReactionText", 6),
                        ["LevelGuess"] = createToggle("LevelGuess", 7),
                        ["KeyServer"] = createToggle("KeyServer", 8),
                    },
                }, -- basic

                appearance = {
                    type = "group",
                    order = 4,
                    name = L["Opt_Main_Appearance"],
                    desc = L["Desc_Main_Appearance"],
                    args = {
                        ["Scale"] = createRange("Scale", 2, 0.01, 1.0, true),
                        ["BGColor"] = createSelection("BGColor", 3, L.Map_BGColor, L.TinyTipDefault),
                        ["Border"] = createSelection("Border", 4, L.Map_Border, L.TinyTipDefault),
                        ["ColourFriends"] = createSelection("ColourFriends", 5, L.Map_ColourFriends, L.TinyTipDefault),
                        ["HideInFrames"] = createToggle("HideInFrames", 6),
                        ["HideInCombat"] = createToggle("HideInCombat", 7),
                    },
                }, -- appearance

                targets = {
                    type = "group",
                    order = 5,
                    name = L["Opt_Main_Targets"],
                    desc = L["Desc_Main_Targets"],
                    args = {
                        ["TargetsTooltipUnit"] = createSelection("TargetsTooltipUnit", 2, L.Map_TargetsTooltipUnit, L.TinyTipDefault),
                        ["TargetsParty"] = createSelection("TargetsParty", 3, L.Map_TargetsParty, L.TinyTipDefault),
                        ["TargetsRaid"] = createSelection("TargetsRaid", 4, L.Map_TargetsRaid, L.TinyTipDefault),
                        ["TargetsNoEventUpdate"] = createToggle("TargetsNoEventUpdate", 5),
                    },
                }, -- targets

                general = {
                    type = "group",
                    order = 1,
                    name = L["Main_General"],
                    args = {
                        profiles = {
                            type = "toggle",
                            get = function() return core:GetCurrentProfile() ~= "global" end,
                            set = function() core:ToggleSetProfile() end,
                            name = L["Opt_Profiles"],
                            desc = L["Desc_Profiles"],
                        },
                        resetdb = {
                            type = "execute",
                            order = 1,
                            confirm = true,
                            confirmText = L["ResetDB_Confirm"],
                            func = function() core.ResetDatabase() end,
                            name = L["Opt_Main_Default"],
                            desc = L["Desc_Main_Default"],
                        },
                    },
                },
            } -- main args
        }

        config:RegisterOptionsTable("TinyTip", {
            name = core.localizedname,
            type = "group",
            args = {
                help = {
                    type = "description",
                    name = L["WhatIsTinyTip"],
                },
            },
        })
        dialog:SetDefaultSize("TinyTip", 600, 400)
        dialog:AddToBlizOptions("TinyTip", "TinyTip")

        config:RegisterOptionsTable("TinyTip-General", options.args.general)
        dialog:AddToBlizOptions("TinyTip-General", options.args.general.name, "TinyTip")

        config:RegisterOptionsTable("TinyTipPositioning", options.args.positioning)
        dialog:AddToBlizOptions("TinyTipPositioning", options.args.positioning.name, "TinyTip")

        config:RegisterOptionsTable("TinyTipBasic", options.args.basic)
        dialog:AddToBlizOptions("TinyTipBasic", options.args.basic.name, "TinyTip")

        config:RegisterOptionsTable("TinyTip-Appearance", options.args.appearance)
        dialog:AddToBlizOptions("TinyTip-Appearance", options.args.appearance.name, "TinyTip")

        config:RegisterOptionsTable("TinyTipTargets", options.args.targets)
        dialog:AddToBlizOptions("TinyTipTargets", options.args.targets.name, "TinyTip")
    end
end

function module:Show()
    InterfaceOptionsFrame:Show()
end
