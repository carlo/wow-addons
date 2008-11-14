--[[
-- Name: TinyTip
-- Author: Thrae of Maelstrom (aka "Matthew Carras")
-- Release Date:
-- Release Version: 2.0
--
-- This provides the modular core of TinyTip. It is
-- required for proper database functionality and
-- best optimization with a lot of modules.
--]]

local _G = getfenv(0)

--[[---------------------------------------------
-- Local References
----------------------------------------------]]
local strformat = string.format
local UIParent, GameTooltip = _G.UIParent, _G.GameTooltip
local UnitClass, UnitIsPlayer = UnitClass, UnitIsPlayer

local L = _G.TinyTipLocale
local classColours, hooks, origfuncs
local EventFrame
local db, _

--[[----------------------------------------------------------------------
-- Quick Localization
------------------------------------------------------------------------]]

local slash2 = "ttip"
--[[
if GetLocale() == "deDE" then
    slash2 = "foo"
else...
--]]

--[[----------------------------------------------------------------------
-- Module Initialization
------------------------------------------------------------------------]]

local core
local name, localizedname = GetAddOnInfo("TinyTip")
core = DongleStub("Dongle-1.0"):New(name)
core.name, core.localizedname = name, localizedname or name
_G.TinyTip = core

--[[----------------------------------------------------------------------
-- Shared Utility Functions
------------------------------------------------------------------------]]

function core.ColourPlayer(unit)
    local _,c = UnitClass(unit)
    return ( c and UnitIsPlayer(unit) and classColours[c] ) or "FFFFFF"
end

--[[----------------------------------------------------------------------
-- Events
-------------------------------------------------------------------------]]

local function OnShow(self)
    local dbp = core.db.profile
    if dbp["HideInFrames"] then
        local owner, unit = GameTooltip:GetOwner(), GameTooltip:GetUnit()
        if unit and owner ~= UIParent then
            if dbp["HideInCombat"] then
                if InCombatLockdown() then
                    GameTooltip:Hide()
                end
            else
                GameTooltip:Hide()
            end
        end
    elseif dbp["HideInCombat"] then
        if InCombatLockdown() then
            local unit = GameTooltip:GetUnit()
            if unit then
                GameTooltip:Hide()
            end
        end
    end
end

function core:PLAYER_ENTERING_WORLD()
    local dbp = self.db.profile
    GameTooltip:SetScale( dbp["Scale"] or 1.0 )
end

local function showoptionsgui()
    if not IsAddOnLoaded("TinyTipOptions") then
        local _, reason = LoadAddOn("TinyTipOptions")
        local _, title = GetAddOnInfo("TinyTipOptions")
        if reason then
            core:Print( title .. " (Enable) LoadOnDemand Error - " .. reason )
        else
            --self:Print( "Loaded " .. title)
        end
    end
    TinyTipOptions:Show()
end

--[[----------------------------------------------------------------------
-- Hooking
------------------------------------------------------------------------]]

local function handlerOnTooltipSetUnit(origfunc,handlers,self,...)
    if not handlers then
        if origfunc then
            return origfunc(self,...)
        end
    else
        origfunc(self,...)
    end

    local _, unit = self:GetUnit()
    if unit and UnitExists(unit) and GameTooltipTextLeft1:IsShown() then
        for i = 1,#handlers do
            handlers[i](unit)
        end

        self:Show()
    end
end

local function handler(origfunc,handlers,...)
    if not handlers then
        if origfunc then
            return origfunc(...)
        end
    else
        origfunc(...)
    end

    for i = 1,#handlers do
        handlers[i](...)
    end
end

local function isHooked(handlers, handler)
    if not handlers then return true end
    for _,v in ipairs(handlers) do
        if v == handler then
            return true
        end
    end
end

local function hook(object, func, mainhandler, handler, isscript, priority)
    if not origfuncs then origfuncs = {} end
    if not origfuncs[object] then origfuncs[object] = {} end
    if not hooks then hooks = {} end
    if not hooks[object] then hooks[object] = { [func] = {} } end

    if not isHooked(hooks[object][func], handler) then
        if priority then
            table.insert(hooks[object][func], priority, handler)
        else
            table.insert(hooks[object][func], handler)
        end
    end

    if origfuncs[object][func] == nil then
        if isscript then
            origfuncs[object][func] = object:GetScript(func) or false
            object:SetScript(func, function(...) mainhandler(origfuncs[object][func], hooks[object][func], ...) end)
        else
            origfuncs[object][func] = object[func] or false
            object[func] = function(...) mainhandler(origfuncs[object][func], hooks[object][func], ...) end
        end
    end
end

local function unhook(object, func, handler)
    if not hooks or not hooks[object] or not hooks[object][func] then return end
    local handlers = hooks[object][func]
    for i = 1, #handlers do
        if handlers[i] == handler then
            table.remove(handlers, i)
            return true
        end
    end
end

function core.HookOnTooltipSetUnit(tooltip, handler, priority)
    hook(tooltip, "OnTooltipSetUnit", handlerOnTooltipSetUnit, handler, true, priority)
end

function core.UnhookOnTooltipSetUnit(tooltip, handler)
    unhook(tooltip, "OnTooltipSetUnit", handler)
end

--[[----------------------------------------------------------------------
-- Database Functions
------------------------------------------------------------------------]]

function core:GetDB()
    return self.db.profile
end

function core:GetCurrentProfile()
    return self.db:GetCurrentProfile()
end

function core:ToggleSetProfile()
    if self.db:GetCurrentProfile() ~= "char" then
        self.db:SetProfile("char")
    else
        self.db:SetProfile("global")
    end

    self:ReInitialize()
end

function core:ResetDatabase()
    self:Print(self.localizedname .. ": ResetDB.")
    db:ResetDB()
    self:ReInitialize()
end

--[[----------------------------------------------------------------------
-- Module State
-------------------------------------------------------------------------]]

function core:ReInitialize()
    self:UnregisterAllEvents()

    local dbp = self.db.profile
    if dbp["Scale"] and dbp["Scale"] ~= 1.0 then
        GameTooltip:SetScale( dbp["Scale"] or 1.0 )
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
    end
    if dbp["HideInFrames"] or dbp["HideInCombat"] then
        if not EventFrame then
            EventFrame = CreateFrame("Frame", nil, GameTooltip)
            EventFrame:Show()
        end
        EventFrame:SetScript("OnShow", OnShow)
        -- EventFrame:SetScript("OnHide", OnHide)
    elseif EventFrame then
        EventFrame:SetScript("OnShow", nil)
        -- EventFrame:SetScript("OnHide", nil)
    end

    for name,module in self:IterateModules() do
        if module.ReInitialize then
            module:ReInitialize(dbp)
        end
    end
end

--[[
function core:Standby()
    for name,module in self:IterateModules() do
        module:Standby()
    end
    classColours = nil
end

function core:Wakeup()
end
--]]

-- For initializing the database and hooking functions.
function core:Initialize()
    if TinyTipDB and TinyTipDB._v then
        self:Print(self.localizedname .. ": Detected TinyTip 1.x database. Resetting values.")
        TinyTipDB = {}
    end

    self.db = self:InitializeDB("TinyTipDB", { profile = { } }, "global")
    db = self.db

    -- Load all modules for "Always".
    --[[
    for i=1,GetNumAddOns() do
        if not IsAddOnLoaded(i) and GetAddOnMetadata(i, "X-TinyTip-Load-Always") then
            local _, reason = LoadAddOn(i)
            local _, title = GetAddOnInfo(i)
            if reason then
                self:Print( title .. " (Initialize) LoadOnDemand Error - " .. reason )
            else
                self:Print( "Loaded " .. title)
            end
        end
    end
    --]]

    -- Call "Initialize" for internal modules.
    for name,module in self:IterateModules() do
        if module.Initialize then
            local reason = select(6, GetAddOnInfo(name))
            if reason == "MISSING" then
                module:Initialize()
            end
        end
    end

    self:ReInitialize()
end

-- Setting variables that only need to be set once goes here.
function core:Enable()
    if not classColours then
        classColours = {}
        self.ClassColours = classColours
        for k,v in pairs(RAID_CLASS_COLORS) do
            classColours[k] = strformat("%2x%2x%2x", v.r*255, v.g*255, v.b*255)
        end
    end

    -- Load all modules for "Always".
    for i=1,GetNumAddOns() do
        if not IsAddOnLoaded(i) and GetAddOnMetadata(i, "X-TinyTip-Load-Always") then
            local _, reason = LoadAddOn(i)
            local _, title = GetAddOnInfo(i)
            if reason then
                self:Print( title .. " (Enable) LoadOnDemand Error - " .. reason )
            else
                --self:Print( "Loaded " .. title)
            end
        end
    end

    -- Call "Enable" for internal modules.
    for name,module in self:IterateModules() do
        if module.Enable then
            local reason = select(6, GetAddOnInfo(name))
            if reason == "MISSING" then
                module:Enable()
            end
        end
    end

    local enabled, loadable = select(4, GetAddOnInfo("TinyTipOptions"))
    if enabled and loadable then
        local hijack = CreateFrame("Frame", nil, InterfaceOptionsFrame)
        hijack:SetScript("OnShow", function()
            hijack:Hide()
            local _, reason = LoadAddOn("TinyTipOptions")
            local _, title = GetAddOnInfo("TinyTipOptions")
            if reason then
                self:Print( title .. " (Enable) LoadOnDemand Error - " .. reason )
            else
                --self:Print( "Loaded " .. title)
            end
        end)
    end

    _G["SLASH_TINYTIP1"] = "/" .. string.lower(self.name)
    _G["SLASH_TINYTIP2"] = "/" .. string.upper(self.localizedname)
    _G["SLASH_TINYTIP3"] = "/" .. string.lower(self.localizedname)
    _G["SLASH_TINYTIP4"] = "/" .. slash2
    _G.SlashCmdList["TINYTIP"] = showoptionsgui
end

