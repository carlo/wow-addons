--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: 5.0.PRE.2544 (BillyGoat)
	Revision: $Id: AucCommand.lua 2497 2007-11-15 14:55:33Z Norganna $

	Auctioneer command functions.
	Functions to allow setting of values, switching commands etc.

	License:
		This program is free software; you can redistribute it and/or
		modify it under the terms of the GNU General Public License
		as published by the Free Software Foundation; either version 2
		of the License, or (at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program(see GPL.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

	Note:
		This AddOn's source code is specifically designed to work with
		World of Warcraft's interpreted AddOn system.
		You have an implicit licence to use this AddOn with these facilities
		since that is it's designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

Auctioneer_RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auctioneer/AucCommand.lua $", "$Rev: 2497 $")

--Local function prototypes
local register
local convertKhaos
local getKhaosDefault
local setKhaosSetKeyParameter
local setKhaosSetKeyValue
local getKhaosLocaleList
local getKhaosDurationsList
local getKhaosProtectionList
local getKhaosFinishList
local registerKhaos
local buildCommandMap
local commandMap
local commandMapRev
local command
local chatPrintHelp
local onOff
local clear
local alsoInclude
local isValidLocale
local setLocale
local default
local getFrameNames
local getFrameIndex
local setFrame
local protectWindow
local auctionDuration
local finish
local genVarSet
local percentVarSet
local numVarSet
local setFilter
local getFilterVal
local getFilter
local findFilterClass
local setFilter
local getLocale
local debugPrint
local fixLocaleDefault
local onBabylonianSetOrder

local DebugLib = Auctioneer.Util.DebugLib
local Babylonian = LibStub("Babylonian")

function register()
	if (Khaos) then
		if (not Auctioneer_Khaos_Registered) then
			registerKhaos();
		end
	end
end

-- Convert a single key in a table of configuration settings
function convertConfig(t, key, values, ...) --Local
	local modified = false;
	local v;

	for i = 1, select("#", ...) do
		local localizedKey = select(i, ...)
		if (t[localizedKey]) then
			v = t[localizedKey];
			t[localizedKey] = nil;
			modified = true;
		end
	end
	if (t[key]) then v = t[key]; end

	if (v) then
		if (values[v]) then
			t[key] = values[v];
			modified = true;
		else
			t[key] = v;
		end
	end

	return modified;
end

-- Convert Khaos options to standardized keys and values
function convertKhaos()
	if (not Khaos_Configurations) then return; end

	-- Array that maps localized versions of strings to standardized
	local convertOnOff = {	['apagado'] = 'off',	-- esES
							['prendido'] = 'on',	-- esES
							}

	local localeConvMap = { ['apagado'] = 'default',
							['prendido'] = 'default',
							['off'] = 'default',
							['on'] = 'default',
							}

	-- Format: standardizedKey,			valueMap,		esES,						localizedKey
	local conversions = {
			-- Localized stuff to get rid of
			{ 'show-warning',			convertOnOff,	'ver-advertencia' },
			{ 'show-verbose',			convertOnOff,	'ver-literal' },
			{ 'show-stats',				convertOnOff,	'ver-estadisticas'},
			{ 'show-average',			convertOnOff,	'ver-promedio' },
			{ 'show-median',			convertOnOff,	'ver-mediano' },
			{ 'show-suggest',			convertOnOff,	'ver-sugerencia' },
			{ 'embed',					convertOnOff,	'integrado' },
			{ 'show-embed-blankline',	convertOnOff,	'ver-integrado-lineavacia' },
			{ 'pct-bidmarkdown',		convertOnOff,	'pct-menosoferta' },
			{ 'pct-markup',				convertOnOff,	'pct-mas' },
			{ 'pct-maxless',			convertOnOff,	'pct-sinmaximo' },
			{ 'pct-nocomp',				convertOnOff,	'pct-sincomp' },
			{ 'pct-underlow',			convertOnOff,	'pct-bajomenor' },
			{ 'pct-undermkt',			convertOnOff,	'pct-bajomercado' },
			{ 'autofill',				convertOnOff,	'autoinsertar' },
			{ 'show-link',				convertOnOff,	'ver-enlace' },

			-- Changed key names
			{ 'locale',					convertOnOff,	'AuctioneerLocale' },
			{ 'printframe',				convertOnOff,	'AuctioneerPrintFrame' },
			{ 'also',					convertOnOff,	'AuctioneerInclude' },
			{ 'enabled',				convertOnOff,	'AuctioneerEnable' },
		}

	-- Prepend placeholder for the table parameter
	for i,c in ipairs(conversions) do
		table.insert(c, 1, nil)
	end

	for i,config in ipairs(Khaos_Configurations) do
		if (config.configuration and config.configuration.Auctioneer) then
			local converted = false;
			-- Run the defined conversions
			for i,c in ipairs(conversions) do
				-- Replace first parameter with actual table to process
				-- Inserting here will cause problems for the second iteration
				c[1] = config.configuration.Auctioneer
				converted = convertConfig(unpack(c)) or converted
			end

			if (converted) then
				Auctioneer.Util.ChatPrint("Converted old Khaos configuration \"" .. config.name .. "\"")
			end
		end
	end

	fixLocaleDefault()
end

function getKhaosDefault(filter)
	if (filter == "also") then
		return Auctioneer.Core.Constants.FilterDefaults[filter];
	elseif (Auctioneer.Core.Constants.FilterDefaults[filter] == 'on') then
		return true;
	elseif (Auctioneer.Core.Constants.FilterDefaults[filter] == 'off') then
		return false;
	else
		return Auctioneer.Core.Constants.FilterDefaults[filter];
	end
end


function setKhaosSetKeyParameter(key, parameter, value) --Local
	if (Auctioneer_Khaos_Registered) then
		if (Khaos.getSetKey("Auctioneer", key)) then
			Khaos.setSetKeyParameter("Auctioneer", key, parameter, value)
		else
			debugPrint("setKhaosSetKeyParameter(): key "..key.." does not exist", DebugLib.Level.Error)
		end
	end
end

function setKhaosSetKeyValue(key, value) --Local
	if (Auctioneer_Khaos_Registered) then
		local kKey = Khaos.getSetKey("Auctioneer", key)

		if (not kKey) then
			debugPrint("setKhaosSetKeyParameter(): key "..key.." does not exist", DebugLib.Level.Error)
		elseif (kKey.checked ~= nil) then
			if (type(value) == "string") then value = (value == "on"); end
			Khaos.setSetKeyParameter("Auctioneer", key, "checked", value)
		elseif (kKey.value ~= nil) then
			Khaos.setSetKeyParameter("Auctioneer", key, "value", value)
		else
			debugPrint("setKhaosSetKeyValue(): don't know how to update key "..key, DebugLib.Level.Error)
		end
	end
end

function getKhaosLocaleList() --Local
	local options = { [_AUCT('CmdDefault')] = 'default' };
	for locale, data in pairs(AuctioneerLocalizations) do
		options[locale] = locale;
	end
	return options
end

function getKhaosLoadList() --Local
	return {
		[_AUCT('GuiLoad_Always')] = 'always',
		[_AUCT('GuiLoad_Never')] = 'never',
		[_AUCT('GuiLoad_AuctionHouse')] = 'auctionhouse'
	}
end

function getKhaosDurationsList() --Local
	local list = {}
	for i = 0, 3 do
		list[_AUCT('CmdAuctionDuration'..i)] = i
	end
	return list
end

function getKhaosProtectionList() --Local
	local list = {}
	for i = 0, 2 do
		list[_AUCT('CmdProtectWindow'..i)] = i
	end
	return list
end

function getKhaosFinishList() --Local
	local list = {}
	for i = 0, 2 do
		list[_AUCT('CmdFinish'..i)] = i
	end
	return list
end

function registerKhaos()
	-- Convert old Khaos settings to current optionSet
	convertKhaos();

	local optionSet = {
		id="Auctioneer";
		text="Auctioneer";
		helptext=function()
			return _AUCT('GuiMainHelp');
		end;
		difficulty=1;
		default={checked=true};
		options={
			{
				id="Header";
				text="Auctioneer";
				helptext=function()
					return _AUCT('GuiMainHelp');
				end;
				type=K_HEADER;
				difficulty=1;
			};
			{
				id="enabled";
				type=K_TEXT;
				text=function()
					return _AUCT('GuiMainEnable');
				end;
				helptext=function()
					return _AUCT('HelpOnoff');
				end;
				callback=function(state)
					Auctioneer.Command.OnOff(state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return _AUCT('StatOn');
					else
						return _AUCT('StatOff');
					end
				end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				difficulty=1;
			};
			{
				id="LoadSettings";
				type=K_PULLDOWN;
				setup = {
					options = getKhaosLoadList;
					multiSelect = false;
				};
				text=function()
					return _AUCT('GuiLoad');
				end;
				helptext=function()
					return _AUCT('HelpLoad');
				end;
				callback=function(state) end;
				feedback=function(state)
					mainHandler("load " .. state.value, "GUI")
				end;
				default={value = 'auctionhouse'};
				disabled={value = 'never'};
				difficulty=1;
			};
			{
				id="locale";
				type=K_PULLDOWN;
				setup = {
					options = getKhaosLocaleList;
					multiSelect = false;
				};
				text=function()
					return _AUCT('GuiLocale');
				end;
				helptext=function()
					return _AUCT('HelpLocale');
				end;
				callback = function(state)
				end;
				feedback = function (state)
					Auctioneer.Command.SetLocale(state.value);
					return _AUCT('FrmtActSet'):format(_AUCT('CmdLocale'), state.value);
				end;
				default = {
					value = Auctioneer.Command.GetLocale();
				};
				disabled = {
					value = Auctioneer.Command.GetLocale();
				};
				dependencies={enabled={checked=true;}};
				difficulty=2;
			};
			{
				id="AuctioneerStatsHeader";
				type=K_HEADER;
				text=function()
					return _AUCT('GuiStatsHeader');
				end;
				helptext=function()
					return _AUCT('GuiStatsHelp');
				end;
				difficulty=2;
			};
			{
				id="show-stats";
				type=K_TEXT;
				text=function()
					return _AUCT('GuiStatsEnable');
				end;
				helptext=function()
					return _AUCT('HelpStats');
				end;
				callback=function(state)
					Auctioneer.Command.GenVarSet("show-stats", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return _AUCT('FrmtActEnable'):format(_AUCT('ShowStats'));
					else
						return _AUCT('FrmtActDisable'):format(_AUCT('ShowStats'));
					end
				end;
				check=true;
				default={checked=getKhaosDefault('show-stats')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=1;
			};
			{
				id="show-average";
				type=K_TEXT;
				text=function()
					return _AUCT('GuiAverages');
				end;
				helptext=function()
					return _AUCT('HelpAverage');
				end;
				callback=function(state)
					Auctioneer.Command.GenVarSet("show-average", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return _AUCT('FrmtActEnable'):format(_AUCT('ShowAverage'));
					else
						return _AUCT('FrmtActDisable'):format(_AUCT('ShowAverage'));
					end
				end;
				check=true;
				default={checked=getKhaosDefault('show-average')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=2;
			};
			{
				id="show-median";
				type=K_TEXT;
				text=function()
					return _AUCT('GuiMedian');
				end;
				helptext=function()
					return _AUCT('HelpMedian');
				end;
				callback=function(state)
					Auctioneer.Command.GenVarSet("show-median", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return _AUCT('FrmtActEnable'):format(_AUCT('ShowMedian'));
					else
						return _AUCT('FrmtActDisable'):format(_AUCT('ShowMedian'));
					end
				end;
				check=true;
				default={checked=getKhaosDefault('show-median')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=2;
			};
			{
				id="show-suggest";
				type=K_TEXT;
				text=function()
					return _AUCT('GuiSuggest');
				end;
				helptext=function()
					return _AUCT('HelpSuggest');
				end;
				callback=function(state)
					Auctioneer.Command.GenVarSet("show-suggest", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return _AUCT('FrmtActEnable'):format(_AUCT('ShowSuggest'));
					else
						return _AUCT('FrmtActDisable'):format(_AUCT('ShowSuggest'));
					end
				end;
				check=true;
				default={checked=getKhaosDefault('show-suggest')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=2;
			};
			{
				id="show-verbose";
				type=K_TEXT;
				text=function()
					return _AUCT('GuiVerbose');
				end;
				helptext=function()
					return _AUCT('HelpVerbose');
				end;
				callback=function(state)
					Auctioneer.Command.GenVarSet("show-verbose", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return _AUCT('FrmtActEnable'):format(_AUCT('ShowVerbose'));
					else
						return _AUCT('FrmtActDisable'):format(_AUCT('ShowVerbose'));
					end
				end;
				check=true;
				default={checked=getKhaosDefault('show-verbose')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=1;
			};
			{
				id="AuctioneerAuctionHouseHeader";
				type=K_HEADER;
				text=function()
					return _AUCT('GuiAuctionHouseHeader');
				end;
				helptext=function()
					return _AUCT('GuiAuctionHouseHeaderHelp');
				end;
				difficulty=1;
			};
			{
				id="autofill";
				type=K_TEXT;
				text=function()
					return _AUCT('GuiAutofill');
				end;
				helptext=function()
					return _AUCT('HelpAutofill');
				end;
				callback=function(state)
					Auctioneer.Command.GenVarSet("autofill", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return _AUCT('FrmtActEnable'):format(_AUCT('CmdAutofill'));
					else
						return _AUCT('FrmtActDisable'):format(_AUCT('CmdAutofill'));
					end
				end;
				check=true;
				default={checked=getKhaosDefault('autofill')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=1;
			};
			{
				id="auction-duration";
				type=K_PULLDOWN;
				setup = {
					options = getKhaosDurationsList;
					multiSelect = false;
				};
				text=function()
					return _AUCT('GuiAuctionDuration');
				end;
				helptext=function()
					return _AUCT('HelpAuctionDuration');
				end;
				callback=function(state)
					Auctioneer.Command.AuctionDuration(state.value);
				end;
				feedback=function(state)
					return _AUCT('FrmtAuctionDuration'):format(_AUCT('CmdAuctionDuration'..Auctioneer.Command.GetFilterVal('auction-duration')));
				end;
				default = { value = _AUCT('CmdAuctionDuration'..Auctioneer.Core.Constants.FilterDefaults['auction-duration']) };
				disabled = { value = _AUCT('CmdAuctionDuration'..Auctioneer.Core.Constants.FilterDefaults['auction-duration']) };
				dependencies={enabled={checked=true;}};
				difficulty=2;
			};
			{
				id="protect-window";
				type=K_PULLDOWN;
				setup = {
					options = getKhaosProtectionList;
					multiSelect = false;
				};
				text=function()
					return _AUCT('GuiProtectWindow');
				end;
				helptext=function()
					return _AUCT('HelpProtectWindow');
				end;
				callback=function(state)
					Auctioneer.Command.ProtectWindow(state.value);
				end;
				feedback=function(state)
					return _AUCT('FrmtProtectWindow'):format(_AUCT('CmdProtectWindow'..Auctioneer.Command.GetFilterVal('protect-window')));
				end;
				default = { value = _AUCT('CmdProtectWindow'..Auctioneer.Core.Constants.FilterDefaults['protect-window']) };
				disabled = { value = _AUCT('CmdProtectWindow'..Auctioneer.Core.Constants.FilterDefaults['protect-window']) };
				dependencies={enabled={checked=true;}};
				difficulty=3;
			};
			{
				id="finish";
				type=K_PULLDOWN;
				setup = {
					options = getKhaosFinishList;
					multiSelect = false;
				};
				text=function()
					return _AUCT('GuiFinish');
				end;
				helptext=function()
					return _AUCT('HelpFinish');
				end;
				callback=function(state)
					Auctioneer.Command.Finish(state.value);
				end;
				feedback=function(state)
					return _AUCT('FrmtFinish'):format(_AUCT('CmdFinish'..Auctioneer.Command.GetFilterVal('finish')));
				end;
				default = { value = _AUCT('CmdFinish'..Auctioneer.Core.Constants.FilterDefaults['finish']) };
				disabled = { value = _AUCT('CmdFinish'..Auctioneer.Core.Constants.FilterDefaults['finish']) };
				dependencies={enabled={checked=true;}};
				difficulty=3;
			};
			{
				id="show-warning";
				type=K_TEXT;
				text=function()
					return _AUCT('GuiRedo');
				end;
				helptext=function()
					return _AUCT('HelpRedo');
				end;
				callback=function(state)
					Auctioneer.Command.GenVarSet("show-warning", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return _AUCT('FrmtActEnable'):format(_AUCT('ShowRedo'));
					else
						return _AUCT('FrmtActDisable'):format(_AUCT('ShowRedo'));
					end
				end;
				check=true;
				default={checked=getKhaosDefault('show-warning')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=1;
			};
			{
				id="warn-color";
				type=K_TEXT;
				text=function()
					return _AUCT('GuiWarnColor');
				end;
				helptext=function()
					return _AUCT('HelpWarnColor');
				end;
				callback=function(state)
					Auctioneer.Command.GenVarSet("warn-color", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return _AUCT('FrmtActEnable'):format(_AUCT('CmdWarnColor'));
					else
						return _AUCT('FrmtActDisable'):format(_AUCT('CmdWarnColor'));
					end
				end;
				check=true;
				default={checked=getKhaosDefault('warn-color')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=1;
			};
			{
				id="finish-sound";
				type=K_TEXT;
				text=function()
					return _AUCT('GuiFinishSound');
				end;
				helptext=function()
					return _AUCT('HelpFinishSound');
				end;
				callback=function(state)
					Auctioneer.Command.GenVarSet("finish-sound", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return _AUCT('FrmtActEnable'):format(_AUCT('CmdFinishSound'));
					else
						return _AUCT('FrmtActDisable'):format(_AUCT('CmdFinishSound'));
					end
				end;
				check=true;
				default={checked=getKhaosDefault('warn-color')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=1;
			};
			{
				id="AuctioneerEmbedHeader";
				type=K_HEADER;
				text=function()
					return _AUCT('GuiEmbedHeader');
				end;
				helptext=function()
					return _AUCT('HelpEmbed');
				end;
				difficulty=1;
			};
			{
				id="embed";
				type=K_TEXT;
				text=function()
					return _AUCT('GuiEmbed');
				end;
				helptext=function()
					return _AUCT('HelpEmbed');
				end;
				callback=function(state)
					Auctioneer.Command.GenVarSet("embed", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return _AUCT('FrmtActEnable'):format(_AUCT('CmdEmbed'));
					else
						return _AUCT('FrmtActDisable'):format(_AUCT('CmdEmbed'));
					end
				end;
				check=true;
				default={checked=getKhaosDefault('embed')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=1;
			};
			{
				id="show-embed-blankline";
				type=K_TEXT;
				text=function()
					return _AUCT('GuiEmbedBlankline');
				end;
				helptext=function()
					return _AUCT('HelpEmbedBlank');
				end;
				callback=function(state)
					Auctioneer.Command.GenVarSet("show-embed-blankline", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return _AUCT('FrmtActEnable'):format(_AUCT('ShowEmbedBlank'));
					else
						return _AUCT('FrmtActDisable'):format(_AUCT('ShowEmbedBlank'));
					end
				end;
				check=true;
				default={checked=getKhaosDefault('show-embed-blankline')};
				disabled={checked=false};
				dependencies={embed={checked=true;}, enabled={checked=true;}};
				difficulty=1;
			};
			{
				id="AuctioneerClearHeader";
				type=K_HEADER;
				text=function()
					return _AUCT('GuiClearHeader');
				end;
				helptext=function()
					return _AUCT('GuiClearHelp');
				end;
				difficulty=3;
			};
			{
				id="AuctioneerClearAll";
				type=K_BUTTON;
				setup={
					buttonText=function()
						return _AUCT('GuiClearallButton');
					end;
				};
				text=function()
					return _AUCT('GuiClearall');
				end;
				helptext=function()
					return _AUCT('GuiClearallHelp');
				end;
				callback=function()
					Auctioneer.Command.Clear("all");
				end;
				feedback=function()
					return _AUCT('FrmtActClearall'):format(_AUCT('GuiClearallNote'));
				end;
				dependencies={enabled={checked=true;}};
				difficulty=3;
			};
			{
				id="AuctioneerClearSnapshot";
				type=K_BUTTON;
				setup={
					buttonText=function()
						return _AUCT('GuiClearsnapButton');
					end;
				};
				text=function()
					return _AUCT('GuiClearsnap');
				end;
				helptext=function()
					return _AUCT('GuiClearsnapHelp');
				end;
				callback=function()
					Auctioneer.Command.Clear(_AUCT('CmdClearSnapshot'));
				end;
				feedback=function()
					return _AUCT('FrmtActClearsnap');
				end;
				dependencies={enabled={checked=true;}};
				difficulty=3;
			};
			{
				id="AuctioneerPercentsHeader";
				type=K_HEADER;
				text=function()
					return _AUCT('GuiPercentsHeader');
				end;
				helptext=function()
					return _AUCT('GuiPercentsHelp');
				end;
				difficulty=4;
			};
			{
				id="pct-bidmarkdown";
				type=K_EDITBOX;
				setup = {
					callOn = {"tab", "escape", "enter"};
				};
				text=function()
					return _AUCT('GuiBidmarkdown');
				end;
				helptext=function()
					return _AUCT('HelpPctBidmarkdown');
				end;
				callback = function(state)
					Auctioneer.Command.PercentVarSet("pct-bidmarkdown", state.value);
				end;
				feedback = function (state)
					return _AUCT('FrmtActSet'):format(_AUCT('CmdPctBidmarkdown'), state.value.."%");
				end;
				default = {	value = getKhaosDefault('pct-bidmarkdown') };
				disabled = { value = getKhaosDefault('pct-bidmarkdown') };
				dependencies={enabled={checked=true;}};
				difficulty=4;
			};
			{
				id="pct-markup";
				type=K_EDITBOX;
				setup = {
					callOn = {"tab", "escape", "enter"};
				};
				text=function()
					return _AUCT('GuiMarkup');
				end;
				helptext=function()
					return _AUCT('HelpPctMarkup');
				end;
				callback = function(state)
					Auctioneer.Command.PercentVarSet("pct-markup", state.value);
				end;
				feedback = function (state)
					return _AUCT('FrmtActSet'):format(_AUCT('CmdPctMarkup'), state.value.."%");
				end;
				default = {	value = getKhaosDefault('pct-markup') };
				disabled = { value = getKhaosDefault('pct-markup') };
				dependencies={enabled={checked=true;}};
				difficulty=4;
			};
			{
				id="pct-maxless";
				type=K_EDITBOX;
				setup = {
					callOn = {"tab", "escape", "enter"};
				};
				text=function()
					return _AUCT('GuiMaxless');
				end;
				helptext=function()
					return _AUCT('HelpPctMaxless');
				end;
				callback = function(state)
					Auctioneer.Command.PercentVarSet("pct-maxless", state.value);
				end;
				feedback = function (state)
					return _AUCT('FrmtActSet'):format(_AUCT('CmdPctMaxless'), state.value.."%");
				end;
				default = {	value = getKhaosDefault('pct-maxless') };
				disabled = { value = getKhaosDefault('pct-maxless') };
				dependencies={enabled={checked=true;}};
				difficulty=4;
			};
			{
				id="pct-nocomp";
				type=K_EDITBOX;
				setup = {
					callOn = {"tab", "escape", "enter"};
				};
				text=function()
					return _AUCT('GuiNocomp');
				end;
				helptext=function()
					return _AUCT('HelpPctNocomp');
				end;
				callback = function(state)
					Auctioneer.Command.PercentVarSet("pct-nocomp", state.value);
				end;
				feedback = function (state)
					return _AUCT('FrmtActSet'):format(_AUCT('CmdPctNocomp'), state.value.."%");
				end;
				default = {	value = getKhaosDefault('pct-nocomp') };
				disabled = { value = getKhaosDefault('pct-nocomp') };
				dependencies={enabled={checked=true;}};
				difficulty=4;
			};
			{
				id="pct-underlow";
				type=K_EDITBOX;
				setup = {
					callOn = {"tab", "escape", "enter"};
				};
				text=function()
					return _AUCT('GuiUnderlow');
				end;
				helptext=function()
					return _AUCT('HelpPctUnderlow');
				end;
				callback = function(state)
					Auctioneer.Command.PercentVarSet("pct-underlow", state.value);
				end;
				feedback = function (state)
					return _AUCT('FrmtActSet'):format(_AUCT('CmdPctUnderlow'), state.value.."%");
				end;
				default = {	value = getKhaosDefault('pct-underlow') };
				disabled = { value = getKhaosDefault('pct-underlow') };
				dependencies={enabled={checked=true;}};
				difficulty=4;
			};
			{
				id="pct-undermkt";
				type=K_EDITBOX;
				setup = {
					callOn = {"tab", "escape", "enter"};
				};
				text=function()
					return _AUCT('GuiUndermkt');
				end;
				helptext=function()
					return _AUCT('HelpPctUndermkt');
				end;
				callback = function(state)
					Auctioneer.Command.PercentVarSet("pct-undermkt", state.value);
				end;
				feedback = function (state)
					return _AUCT('FrmtActSet'):format(_AUCT('CmdPctUndermkt'), state.value.."%");
				end;
				default = {	value = getKhaosDefault('pct-undermkt') };
				disabled = { value = getKhaosDefault('pct-undermkt') };
				dependencies={enabled={checked=true;}};
				difficulty=4;
			};
			{
				id="AuctioneerAskPriceHeader";
				type=K_HEADER;
				text=function()
					return _AUCT('GuiAskPriceHeader');
				end;
				helptext=function()
					return _AUCT('GuiAskPriceHeaderHelp');
				end;
				difficulty=2;
			};
			{
				id="askprice";
				type=K_TEXT;
				text=function()
					return _AUCT('GuiAskPrice');
				end;
				helptext=function()
					return _AUCT('HelpAskPrice');
				end;
				callback=function(state)
					if (state.checked) then
						Auctioneer.AskPrice.OnOff("on");
					else
						Auctioneer.AskPrice.OnOff("off");
					end
				end;
				feedback=function(state)
					if (state.checked) then
						return (_AUCT('StatAskPriceOn'));
					else
						return (_AUCT('StatAskPriceOff'));
					end
				end;
				check=true;
				default={getKhaosDefault('askprice')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=2;
			};
			{
				id="askprice-trigger";
				type=K_EDITBOX;
				setup = {
					callOn = {"tab", "escape", "enter"};
				};
				text=function()
					return _AUCT('GuiAskPriceTrigger');
				end;
				helptext=function()
					return _AUCT('HelpAskPriceTrigger');
				end;
				callback = function(state)
					Auctioneer.AskPrice.SetTrigger(state.value);
				end;
				feedback = function (state)
					return _AUCT('FrmtActSet'):format("askprice ".._AUCT('CmdAskPriceTrigger'), state.value);
				end;
				default = { value = getKhaosDefault('askprice-trigger') };
				disabled = { value = getKhaosDefault('askprice-trigger') };
				dependencies={askprice={checked=true}, enabled={checked=true;}};
				difficulty=3;
			};
			{
				id="askprice-whispers";
				type=K_TEXT;
				text=function()
					return _AUCT('GuiAskPriceWhispers');
				end;
				helptext=function()
					return _AUCT('HelpAskPriceWhispers');
				end;
				callback=function(state)
					Auctioneer.AskPrice.GenVarSet("whispers", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return _AUCT('FrmtAskPriceEnable'):format("askprice ".._AUCT('CmdAskPriceWhispers'));
					else
						return _AUCT('FrmtAskPriceDisable'):format("askprice ".._AUCT('CmdAskPriceWhispers'));
					end
				end;
				check=true;
				default={getKhaosDefault('askprice-whispers')};
				disabled={checked=false};
				dependencies={askprice={checked=true}, enabled={checked=true;}};
				difficulty=2;
			};
			{
				id="askprice-vendor";
				type=K_TEXT;
				text=function()
					return _AUCT('GuiAskPriceVendor');
				end;
				helptext=function()
					return _AUCT('HelpAskPriceVendor');
				end;
				callback=function(state)
					Auctioneer.AskPrice.GenVarSet("vendor", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return _AUCT('FrmtAskPriceEnable'):format("askprice ".._AUCT('CmdAskPriceVendor'));
					else
						return _AUCT('FrmtAskPriceDisable'):format("askprice ".._AUCT('CmdAskPriceVendor'));
					end
				end;
				check=true;
				default={getKhaosDefault('askprice-vendor')};
				disabled={checked=false};
				dependencies={askprice={checked=true}, enabled={checked=true;}};
				difficulty=2;
			};
			{
				id="askprice-party";
				type=K_TEXT;
				text=function()
					return _AUCT('GuiAskPriceParty');
				end;
				helptext=function()
					return _AUCT('HelpAskPriceParty');
				end;
				callback=function(state)
					Auctioneer.AskPrice.GenVarSet("party", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return _AUCT('FrmtAskPriceEnable'):format("askprice ".._AUCT('CmdAskPriceParty'));
					else
						return _AUCT('FrmtAskPriceDisable'):format("askprice ".._AUCT('CmdAskPriceParty'));
					end
				end;
				check=true;
				default={getKhaosDefault('askprice-party')};
				disabled={checked=false};
				dependencies={askprice={checked=true}, enabled={checked=true;}};
				difficulty=2;
			};
			{
				id="askprice-guild";
				type=K_TEXT;
				text=function()
					return _AUCT('GuiAskPriceGuild');
				end;
				helptext=function()
					return _AUCT('HelpAskPriceGuild');
				end;
				callback=function(state)
					Auctioneer.AskPrice.GenVarSet("guild", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return _AUCT('FrmtAskPriceEnable'):format("askprice ".._AUCT('CmdAskPriceGuild'));
					else
						return _AUCT('FrmtAskPriceDisable'):format("askprice ".._AUCT('CmdAskPriceGuild'));
					end
				end;
				check=true;
				default={getKhaosDefault('askprice-guild')};
				disabled={checked=false};
				dependencies={askprice={checked=true}, enabled={checked=true;}};
				difficulty=2;
			};
			{
				id="askprice-smart";
				type=K_TEXT;
				text=function()
					return _AUCT('GuiAskPriceSmart');
				end;
				helptext=function()
					return _AUCT('HelpAskPriceSmart');
				end;
				callback=function(state)
					Auctioneer.AskPrice.GenVarSet("smart", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return _AUCT('FrmtAskPriceEnable'):format("askprice ".._AUCT('CmdAskPriceSmart'));
					else
						return _AUCT('FrmtAskPriceDisable'):format("askprice ".._AUCT('CmdAskPriceSmart'));
					end
				end;
				check=true;
				default={getKhaosDefault('askprice-smart')};
				disabled={checked=false};
				dependencies={askprice={checked=true}, enabled={checked=true;}};
				difficulty=2;
			};
			{
				id="askprice-word1";
				type=K_EDITBOX;
				setup = {
					callOn = {"tab", "escape", "enter"};
				};
				text=function()
					return _AUCT('GuiAskPriceWord'):format(1);
				end;
				helptext=function()
					return _AUCT('HelpAskPriceWord');
				end;
				callback = function(state)
					Auctioneer.AskPrice.SetCustomSmartWords(nil, 1, state.value)
				end;
				feedback = function (state)
					return _AUCT('FrmtActSet'):format("askprice ".._AUCT('CmdAskPriceWord').." 1", Auctioneer.Command.GetFilterVal('askprice-word1'));
				end;
				default = { value = getKhaosDefault('askprice-word1') };
				disabled = { value = getKhaosDefault('askprice-word1') };
				dependencies={askprice={checked=true}, enabled={checked=true;}};
				difficulty=3;
			};
			{
				id="askprice-word2";
				type=K_EDITBOX;
				setup = {
					callOn = {"tab", "escape", "enter"};
				};
				text=function()
					return _AUCT('GuiAskPriceWord'):format(2)
				end;
				helptext=function()
					return _AUCT('HelpAskPriceWord');
				end;
				callback = function(state)
					Auctioneer.AskPrice.SetCustomSmartWords(nil, 2, state.value);
				end;
				feedback = function (state)
					return _AUCT('FrmtActSet'):format("askprice ".._AUCT('CmdAskPriceWord').." 2", Auctioneer.Command.GetFilterVal('askprice-word2'));
				end;
				default = { value = getKhaosDefault('askprice-word2') };
				disabled = { value = getKhaosDefault('askprice-word2') };
				dependencies={askprice={checked=true}, enabled={checked=true;}};
				difficulty=3;
			};
			{
				id="askprice-ad";
				type=K_TEXT;
				text=function()
					return _AUCT('GuiAskPriceAd');
				end;
				helptext=function()
					return _AUCT('HelpAskPriceAd');
				end;
				callback=function(state)
					Auctioneer.AskPrice.GenVarSet("ad", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return _AUCT('FrmtAskPriceEnable'):format("askprice ".._AUCT('CmdAskPriceAd'));
					else
						return _AUCT('FrmtAskPriceDisable'):format("askprice ".._AUCT('CmdAskPriceAd'));
					end
				end;
				check=true;
				default={getKhaosDefault('askprice-ad')};
				disabled={checked=false};
				dependencies={askprice={checked=true}, enabled={checked=true;}};
				difficulty=2;
			};
			{
				id="AuctioneerOtherHeader";
				type=K_HEADER;
				text=function()
					return _AUCT('GuiOtherHeader');
				end;
				helptext=function()
					return _AUCT('GuiOtherHelp');
				end;
				difficulty=1;
			};
			{
				id="also";
				type=K_EDITBOX;
				setup = {
					callOn = {"tab", "escape", "enter"};
				};
				text=function()
					return _AUCT('GuiAlso');
				end;
				helptext=function()
					return _AUCT('HelpAlso');
				end;
				callback = function(state)
					Auctioneer.Command.AlsoInclude(state.value);
				end;
				feedback = function (state)
					if ((state.value == _AUCT('CmdOff')) or (state.value == "off")) then
						return _AUCT('GuiAlsoOff');
					elseif ((state.value == _AUCT('CmdAlsoOpposite')) or (state.value == "opposite")) then
						return _AUCT('GuiAlsoOpposite')
					elseif ((state.value == _AUCT('CmdAlsoHome')) or (state.value == "home")) then
						return _AUCT('GuiAlsoHome')
					elseif ((state.value == _AUCT('CmdAlsoNeutral')) or (state.value == "neutral")) then
						return _AUCT('GuiAlsoNeutral')
					elseif (not Auctioneer.Util.IsValidAlso(state.value)) then
						return _AUCT('FrmtUnknownArg'):format(state.value, _AUCT('CmdAlso'));
					else
						return _AUCT('GuiAlsoDisplay'):format(state.value);
					end
				end;
				default = { value = getKhaosDefault('also') };
				disabled = { value = getKhaosDefault('also') };
				dependencies={enabled={checked=true;}};
				difficulty=2;
			};
			{
				id="printframe";
				type=K_PULLDOWN;
				setup = {
					options = Auctioneer.Command.GetFrameNames;
					multiSelect = false;
				};
				text=function()
					return _AUCT('GuiPrintin');
				end;
				helptext=function()
					return _AUCT('HelpPrintin');
				end;
				callback=function(state)
					Auctioneer.Command.SetFrame(state.value);
				end;
				feedback=function(state)
					local _, frameName = Auctioneer.Command.GetFrameNames(state.value)
					return _AUCT('FrmtPrintin'):format(frameName);
				end;
				default = { value = getKhaosDefault('printframe') };
				disabled = { value = getKhaosDefault('printframe') };
				dependencies={enabled={checked=true;}};
				difficulty=3;
			};
			{
				id="show-link";
				type=K_TEXT;
				text=function()
					return _AUCT('GuiLink');
				end;
				helptext=function()
					return _AUCT('HelpLink');
				end;
				callback=function(state)
					Auctioneer.Command.GenVarSet("show-link", state.checked);
				end;
				feedback=function(state)
					if (state.checked) then
						return _AUCT('FrmtActEnable'):format(_AUCT('ShowLink'));
					else
						return _AUCT('FrmtActDisable'):format(_AUCT('ShowLink'));
					end
				end;
				check=true;
				default={getKhaosDefault('show-link')};
				disabled={checked=false};
				dependencies={enabled={checked=true;}};
				difficulty=3;
			};
			{
				id="DefaultAll";
				type=K_BUTTON;
				setup={
					buttonText = function()
						return _AUCT('GuiDefaultAllButton');
					end;
				};
				text=function()
					return _AUCT('GuiDefaultAll');
				end;
				helptext=function()
					return _AUCT('GuiDefaultAllHelp');
				end;
				callback=function()
					Auctioneer.Command.Default(_AUCT('CmdClearAll'));
				end;
				feedback=function()
					return _AUCT('FrmtActDefaultall');
				end;
				dependencies={enabled={checked=true;}};
				difficulty=1;
			};
			{
				id="DefaultOption";
				type=K_EDITBOX;
				setup = {
					callOn = {"tab", "escape", "enter"};
				};
				text=function()
					return _AUCT('GuiDefaultOption');
				end;
				helptext=function()
					return _AUCT('HelpDefault');
				end;
				callback = function(state)
					Auctioneer.Command.Default(state.value);
				end;
				feedback = function (state)
					if (state.value == _AUCT('CmdClearAll')) then
						return _AUCT('FrmtActDefaultall');
					else
						return string.format(_AUCT('FrmtActDefault'), state.value);
					end
				end;
				default = {
					value = "";
				};
				disabled = {
					value = "";
				};
				dependencies={enabled={checked=true;}};
				difficulty=4;
			};
		};
	};

	Khaos.registerOptionSet("tooltip", optionSet);
	Auctioneer_Khaos_Registered = true;
	Khaos.refresh();

	-- This setting is not actually stored in the Khaos option set and
	-- requires special treatment to be updated
	setKhaosSetKeyValue("LoadSettings", Stubby.GetConfig("Auctioneer", "LoadType") or "auctionhouse")

	-- hook into Babylonian:SetOrder() to change the local setting in Khaos
	Babylonian:AddNotify(onBabylonianSetOrder)
end


function buildCommandMap()
	Auctioneer.Command.CommandMap = nil;
	Auctioneer.Command.CommandMapRev = nil;

	commandMap = {
		[_AUCT('CmdOn')]				=	'on',
		[_AUCT('CmdOff')]				=	'off',
		[_AUCT('CmdHelp')]				=	'help',
		[_AUCT('CmdToggle')]			=	'toggle',
		[_AUCT('CmdDisable')]			=	'disable',
		[_AUCT('CmdClear')]				=	'clear',
		[_AUCT('CmdLocale')]			=	'locale',
		[_AUCT('CmdDefault')]			=	'default',
		[_AUCT('CmdPrintin')]			=	'print-in',
		[_AUCT('CmdAlso')]				=	'also',
		[_AUCT('CmdEmbed')]				=	'embed',
		[_AUCT('CmdPercentless')]		=	'percentless',
		[_AUCT('CmdPercentlessShort')]	=	'percentless',
		[_AUCT('CmdCompete')]			=	'compete',
		[_AUCT('CmdScan')]				=	'scan',
		[_AUCT('CmdAutofill')]			=	'autofill',
		[_AUCT('CmdWarnColor')]			=	'warn-color',
		[_AUCT('CmdFinishSound')]		=	'finish-sound',
		[_AUCT('CmdAuctionDuration')]	=	'auction-duration',
		[_AUCT('CmdProtectWindow')]		=	'protect-window',
		[_AUCT('CmdFinish')]			=	'finish',
		[_AUCT('CmdBroker')]			=	'broker',
		[_AUCT('CmdBidbroker')]			=	'bidbroker',
		[_AUCT('CmdBidbrokerShort')]	=	'bidbroker',
		[_AUCT('CmdAuctionClick')]		=	'auction-click',
		[_AUCT('CmdPctBidmarkdown')]	=	'pct-bidmarkdown',
		[_AUCT('CmdPctMarkup')]			=	'pct-markup',
		[_AUCT('CmdPctMaxless')]		=	'pct-maxless',
		[_AUCT('CmdPctNocomp')]			=	'pct-nocomp',
		[_AUCT('CmdPctUnderlow')]		=	'pct-underlow',
		[_AUCT('CmdPctUndermkt')]		=	'pct-undermkt',

		--AskPrice related commands
		[_AUCT('CmdAskPriceWhispers')]	=	'whispers',
		[_AUCT('CmdAskPriceVendor')]	=	'vendor',
		[_AUCT('CmdAskPriceGuild')]		=	'guild',
		[_AUCT('CmdAskPriceParty')]		=	'party',
		[_AUCT('CmdAskPriceSmart')]		=	'smart',
		[_AUCT('CmdAskPriceWord')]		=	'word',
		[_AUCT('CmdAskPriceAd')]		=	'ad',

		-- Post/Search Tab related commands
		[_AUCT('CmdBidLimit')]			=	'bid-limit',
		[_AUCT('CmdUpdatePrice')]		=	'update-price',
	}

	commandMapRev = {}
	for k,v in pairs(commandMap) do
		commandMapRev[v] = k;
	end

	Auctioneer.Command.CommandMap = commandMap;
	Auctioneer.Command.CommandMapRev = commandMapRev;
end

--Cleaner Command Handling Functions (added by MentalPower)
function mainHandler(command, source)

	-- Did the command come from khaos or from /auc xxxxx?
	local khaosCommand
	if (source == "GUI") then
		khaosCommand = true;
	else
		khaosCommand = false;
	end;

	--Divide the large command into smaller logical sections (Shameless copy from the original function)
	local cmd, param = command:match("^([%w%-]+)%s*(.*)$");

	cmd = cmd or command or "";
	param = param or "";
	cmd = Auctioneer.Util.DelocalizeCommand(cmd);

	--Now for the real Command handling

	--/auctioneer help
	if ((cmd == "") or (cmd == "help")) then
		chatPrintHelp();

	--/auctioneer (on|off|toggle)
	elseif (cmd == 'on' or cmd == 'off' or cmd == 'toggle') then
		onOff(cmd, khaosCommand);

	--/auctioneer disable
	elseif (cmd == 'disable') then
		Auctioneer.Util.ChatPrint(_AUCT('DisableMsg'));
		Stubby.SetConfig("Auctioneer", "LoadType", "never");
		setKhaosSetKeyValue("LoadSettings", "never")

	--/auctioneer load (always|never|auctionhouse)
	elseif (cmd == 'load') then
		if (param == "always") or (param == "never") or (param == "auctionhouse") then
			Stubby.SetConfig("Auctioneer", "LoadType", param);
			if (not khaosCommand) then
				Auctioneer.Util.ChatPrint("Setting Auctioneer to "..param.." load for this toon");
				setKhaosSetKeyValue("LoadSettings", param)
			end
		end

	--/auctioneer clear (all|snapshot|item)
	elseif (cmd == 'clear') then
		clear(param, khaosCommand);

	--/auctioneer also ReamName-Faction
	elseif (cmd == 'also') then
		alsoInclude(param, khaosCommand);

	--/auctioneer locale
	elseif (cmd == 'locale') then
		setLocale(param, khaosCommand);

	--/auctioneer default (all|option)
	elseif (cmd == 'default') then
		default(param,  khaosCommand);

	--/auctioneer print-in (FrameName|FrameNumber)
	elseif (cmd == 'print-in') then
		setFrame(param, khaosCommand)

	--/auctioneer broker
	elseif (cmd == 'broker') then
		Auctioneer.Filter.DoBroker(param);

	--/auctioneer bidbroker
	elseif (cmd == 'bidbroker' or cmd == "bb") then
		Auctioneer.Filter.DoBidBroker(param);

	--/auctioneer percentless
	elseif (cmd == 'percentless' or cmd == "pl") then
		Auctioneer.Filter.DoPercentLess(param);

	--/auctioneer compete
	elseif (cmd == 'compete') then
		Auctioneer.Filter.DoCompeting(param);

	--/auctioneer scan
	elseif (cmd == 'scan') then
		if (not Auctioneer.ScanManager.Scan()) then
			Auctioneer.Util.ChatPrint(_AUCT('ScanFailed'));
		end

	--/auctioneer protect-window
	elseif (cmd == 'protect-window') then
		protectWindow(param, khaosCommand);

	--/auctioneer auction-duration (2h|8h|24h)
	elseif (cmd == 'auction-duration') then
		auctionDuration(param, khaosCommand);

	--/auctioneer finish (off|logout|exit)
	elseif (cmd == 'finish') then
		finish(param, khaosCommand);

	--/auctioneer low
	elseif (cmd == 'low') then
		Auctioneer.Statistic.DoLow(param);

	--/auctioneer med
	elseif (cmd == 'med') then
		Auctioneer.Statistic.DoMedian(param);

	--/auctioneer hsp
	elseif (cmd == 'hsp') then
		Auctioneer.Statistic.DoHSP(param);

	--/auctioneer askprice (vendor|guild|party|smart|trigger|ad)
	elseif (cmd == 'askprice') then
		Auctioneer.AskPrice.CommandHandler(param, source);

	--/auctioneer (GenVars)
	elseif (
		cmd == 'embed'					or cmd == 'autofill'		or cmd == 'auction-click'	or
		cmd == 'show-verbose'			or cmd == 'show-average'	or cmd == 'finish-sound'	or
		cmd == 'show-median'			or cmd == 'show-stats'		or cmd == 'show-suggest'	or
		cmd == 'show-embed-blankline'	or cmd == 'show-warning'	or cmd == 'warn-color'		or
		cmd == 'update-price'
	) then
		genVarSet(cmd, param, khaosCommand);

	--/auctioneer (PercentVars)
	elseif (
		cmd == 'pct-bidmarkdown'		or cmd == 'pct-markup'		or cmd == 'pct-maxless'		or
		cmd == 'pct-nocomp'				or cmd == 'pct-underlow'	or cmd == 'pct-undermkt'
	) then
		percentVarSet(cmd, param, khaosCommand);

	--/auctioneer (NumVars)
	elseif (cmd == 'bid-limit') then
		numVarSet(cmd, param, khaosCommand);

	--Command not recognized
	else
		if (not khaosCommand) then
			Auctioneer.Util.ChatPrint(_AUCT('FrmtActUnknown'):format(cmd));
		end
	end
end

--Help ME!! (The Handler) (Another shameless copy from the original function)
function chatPrintHelp()
	Auctioneer.Util.ChatPrint(_AUCT('FrmtWelcome'):format(Auctioneer.Version), 0.8, 0.8, 0.2);

	local onOffToggle = " (".._AUCT('CmdOn').."|".._AUCT('CmdOff').."|".._AUCT('CmdToggle')..")";

	local _, frameName = getFrameNames(getFrameIndex())

	Auctioneer.Util.ChatPrint(_AUCT('TextUsage'));
	Auctioneer.Util.ChatPrint("  |cffffffff/auctioneer "..onOffToggle.."|r |cff2040ff["..Auctioneer.Util.GetLocalizedFilterVal("all").."]|r\n          " .. _AUCT('HelpOnoff') .. "\n\n");
	Auctioneer.Util.ChatPrint("  |cffffffff/auctioneer ".._AUCT('CmdDisable').."|r\n          " .. _AUCT('HelpDisable') .. "\n\n");

	local lineFormat = "  |cffffffff/auctioneer %s "..onOffToggle.."|r |cff2040ff[%s]|r\n          %s\n\n";
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('ShowVerbose'),		Auctioneer.Util.GetLocalizedFilterVal('show-verbose'),			_AUCT('HelpVerbose')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('ShowAverage'),		Auctioneer.Util.GetLocalizedFilterVal('show-average'),			_AUCT('HelpAverage')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('ShowMedian'),		Auctioneer.Util.GetLocalizedFilterVal('show-median'),			_AUCT('HelpMedian')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('ShowSuggest'),		Auctioneer.Util.GetLocalizedFilterVal('show-suggest'),			_AUCT('HelpSuggest')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('ShowStats'),			Auctioneer.Util.GetLocalizedFilterVal('show-stats'),			_AUCT('HelpStats')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdAutofill'),		Auctioneer.Util.GetLocalizedFilterVal('autofill'),				_AUCT('HelpAutofill')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdEmbed'),			Auctioneer.Util.GetLocalizedFilterVal('embed'),					_AUCT('HelpEmbed')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('ShowEmbedBlank'),	Auctioneer.Util.GetLocalizedFilterVal('show-embed-blankline'),	_AUCT('HelpEmbedBlank')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('ShowRedo'),			Auctioneer.Util.GetLocalizedFilterVal('show-warning'),			_AUCT('HelpRedo')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdAuctionClick'),	Auctioneer.Util.GetLocalizedFilterVal('auction-click'),			_AUCT('HelpAuctionClick')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdWarnColor'),		Auctioneer.Util.GetLocalizedFilterVal('warn-color'),			_AUCT('HelpWarnColor')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdUpdatePrice'),	Auctioneer.Util.GetLocalizedFilterVal('update-price'),			_AUCT('HelpUpdatePrice')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdFinishSound'),	Auctioneer.Util.GetLocalizedFilterVal('finish-sound'),			_AUCT('HelpFinishSound')));

	lineFormat = "  |cffffffff/auctioneer %s %s|r |cff2040ff[%s]|r\n          %s\n\n";
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdProtectWindow'),		_AUCT('OptProtectWindow'), 		_AUCT('CmdProtectWindow'..Auctioneer.Command.GetFilterVal('protect-window')),		_AUCT('HelpProtectWindow')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdAuctionDuration'),	_AUCT('OptAuctionDuration'),	_AUCT('CmdAuctionDuration'..Auctioneer.Command.GetFilterVal('auction-duration')),	_AUCT('HelpAuctionDuration')));

	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdLocale'),				_AUCT('OptLocale'),				Auctioneer.Util.LocalizeFilterVal(Auctioneer.Command.GetLocale()),					_AUCT('HelpLocale')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdPrintin'),			_AUCT('OptPrintin'),			frameName, _AUCT('HelpPrintin')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdFinish'),				_AUCT('OptFinish'),				_AUCT('CmdFinish'..Auctioneer.Command.GetFilterVal('finish')),						_AUCT('HelpFinish')));

	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdPctMarkup'),			_AUCT('OptPctMarkup'),			Auctioneer.Command.GetFilterVal('pct-markup'),										_AUCT('HelpPctMarkup')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdPctBidmarkdown'),		_AUCT('OptPctBidmarkdown'),		Auctioneer.Command.GetFilterVal('pct-bidmarkdown'),									_AUCT('HelpPctBidmarkdown')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdPctNocomp'),			_AUCT('OptPctNocomp'),			Auctioneer.Command.GetFilterVal('pct-nocomp'),										_AUCT('HelpPctNocomp')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdPctUnderlow'),		_AUCT('OptPctUnderlow'),		Auctioneer.Command.GetFilterVal('pct-underlow'),									_AUCT('HelpPctUnderlow')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdPctUndermkt'),		_AUCT('OptPctUndermkt'),		Auctioneer.Command.GetFilterVal('pct-undermkt'),									_AUCT('HelpPctUndermkt')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdPctMaxless'),			_AUCT('OptPctMaxless'),			Auctioneer.Command.GetFilterVal('pct-maxless'),										_AUCT('HelpPctMaxless')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdBidLimit'),			_AUCT('OptBidLimit'),			Auctioneer.Command.GetFilterVal('bid-limit'),										_AUCT('HelpBidLimit')));

	Auctioneer.AskPrice.ChatPrintHelp()

	lineFormat = "  |cffffffff/auctioneer %s %s|r\n          %s\n\n";
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdClear'),			_AUCT('OptClear'),			_AUCT('HelpClear')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdAlso'),			_AUCT('OptAlso'),			_AUCT('HelpAlso')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdBroker'),			_AUCT('OptBroker'),			_AUCT('HelpBroker')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdBidbroker'),		_AUCT('OptBidbroker'),		_AUCT('HelpBidbroker')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdPercentless'),	_AUCT('OptPercentless'),	_AUCT('HelpPercentless')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdCompete'),		_AUCT('OptCompete'),		_AUCT('HelpCompete')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdScan'),			_AUCT('OptScan'),			_AUCT('HelpScan')));
	Auctioneer.Util.ChatPrint(lineFormat:format(_AUCT('CmdDefault'),		_AUCT('OptDefault'),		_AUCT('HelpDefault')));
end
--[[
	The onOff(state, chatprint) function handles the state of the Auctioneer AddOn (whether it is currently on or off)
	If "on" or "off" is specified in the first argument then Auctioneer's state is changed to that value,
	If "toggle" is specified then it will toggle Auctioneer's state (if currently on then it will be turned off and vice-versa)

	If a boolean (or nil) value is passed as the first argument the conversion is as follows:
	"true" is the same as "on"
	"false" is the same as "off"
	"nil" is the same as "toggle"

	If chatprint is "true" then the state will also be printed to the user.
]]
function onOff(state, khaosCommand)
	if (type(state) == "string") then
		state = Auctioneer.Util.DelocalizeFilterVal(state);

	elseif (state == true) then
		state = 'on'

	elseif (state == false) then
		state = 'off'

	elseif (state == nil) then
		state = 'toggle'
	end

	if (state == 'on' or state == 'off') then
		setFilter('all', state);

	elseif (state == 'toggle') then
		setFilter('all', not getFilter('all'));
	end

	--Print the change and alert the GUI if the command came from slash commands. Do nothing if they came from the GUI.
	if khaosCommand == false then
		state = getFilter('all')
		setKhaosSetKeyValue("enabled", state)

		if (state) then
			Auctioneer.Util.ChatPrint(_AUCT('StatOn'));

		else
			Auctioneer.Util.ChatPrint(_AUCT('StatOff'));
		end
	end
end

--The following functions are almost verbatim copies of the original functions but modified in order to make them compatible with direct GUI access.
function clear(param, khaosCommand)
	if (not (type(param) == "string")) then
		return
	end

	local ahKey = Auctioneer.Util.GetAuctionKey();

	if ((param == _AUCT('CmdClearAll')) or (param == "all")) then
		Auctioneer.Statistic.ClearCache(nil, ahKey);
		Auctioneer.SnapshotDB.Clear(nil, ahKey);
		Auctioneer.HistoryDB.Clear(nil, ahKey);

	elseif ((param == _AUCT('CmdClearSnapshot')) or (param == "snapshot")) then
		Auctioneer.SnapshotDB.Clear(nil, ahKey);

	else
		local items = Auctioneer.Util.GetItems(param);
		if (items) then
			local itemLinks = Auctioneer.Util.GetItemHyperlinks(param);
			for pos, itemKey in ipairs(items) do
				Auctioneer.Statistic.ClearCache(itemKey, ahKey);
				Auctioneer.SnapshotDB.Clear(itemKey, ahKey);
				Auctioneer.HistoryDB.Clear(itemKey, ahKey);
				if khaosCommand == false then
					Auctioneer.Util.ChatPrint(_AUCT('FrmtActClearOk'):format(itemLinks[pos]));
				end
			end
		end
	end

	if khaosCommand == false then
		if ((param == _AUCT('CmdClearAll')) or (param == "all")) then
			Auctioneer.Util.ChatPrint(_AUCT('FrmtActClearall'):format(ahKey));

		elseif ((param == _AUCT('CmdClearSnapshot')) or (param == "snapshot")) then
			Auctioneer.Util.ChatPrint(_AUCT('FrmtActClearsnap'));
		end
	end
end


function alsoInclude(param, khaosCommand)
	local localizedParam = param;

	-- delocalizing the parameter
	param = Auctioneer.Util.DelocalizeFilterVal(param);
	-- delocalizing it, for special also-commands
	if (param == _AUCT('CmdAlsoOpposite')) then
		param = "opposite"
	elseif (param == _AUCT('CmdAlsoHome')) then
		param = "home"
	elseif (param == _AUCT('CmdAlsoNeutral')) then
		param = "neutral"
	end

	-- support case insensitive faction strings and commands
	local realm, faction = param:match("^(.+)-(.+)$")
	if realm then
		-- normal string
		param = realm.."-"..string.lower(faction)
	else
		-- special command or invalid string
		param = string.lower(param)
	end

	if (not Auctioneer.Util.IsValidAlso(param)) then
		if khaosCommand == false then
			Auctioneer.Util.ChatPrint(_AUCT('FrmtUnknownRf'):format(param));
		end
		return
	end

	setFilter('also', param);

	if khaosCommand == false then
		setKhaosSetKeyValue('also', param);

		if (param == "off") then
			Auctioneer.Util.ChatPrint(_AUCT('FrmtActDisable'):format(_AUCT('CmdAlso')));
		else
			Auctioneer.Util.ChatPrint(_AUCT('FrmtActSet'):format(_AUCT('CmdAlso'), localizedParam));
		end
	end
end


function isValidLocale(param)
	return (AuctioneerLocalizations and AuctioneerLocalizations[param])
end


function setLocale(param, khaosCommand)
	param = Auctioneer.Util.DelocalizeFilterVal(param);
	local validLocale;

	if (param == 'default') or (param == 'off') then
		Babylonian:SetOrder('');
		validLocale = true;
	elseif (Auctioneer.Command.IsValidLocale(param)) then
		Babylonian:SetOrder(param);
		validLocale = true;
	else
		validLocale = false;
	end

	if khaosCommand == false then
		if (validLocale) then
			Auctioneer.Util.ChatPrint(_AUCT('FrmtActSet'):format(_AUCT('CmdLocale'), param));
		else
			Auctioneer.Util.ChatPrint(_AUCT("FrmtUnknownLocale"):format(param));
			local locales = "    ";
			for locale, data in pairs(AuctioneerLocalizations) do
				locales = locales .. " '" .. locale .. "' ";
			end
			locales = locales.."'".._AUCT('CmdDefault').."'"
			Auctioneer.Util.ChatPrint(locales);
		end
	end

	if (Auctioneer_Khaos_Registered) then
		Khaos.refresh(nil, nil, true)
	end

	commandMap = nil;
	commandMapRev = nil;
end


function default(param, khaosCommand)
	local paramLocalized

	if ( (param == nil) or (param == "") ) then
		return

	elseif ((param == _AUCT('CmdClearAll')) or (param == "all")) then
		param = "all"
		AuctionConfig.filters = {};

	else
		paramLocalized = param
		param = Auctioneer.Util.DelocalizeCommand(param)
		setFilter(param, nil);
	end

	Auctioneer.Util.SetFilterDefaults();		-- Apply defaults for settings that went missing

	if khaosCommand == false then
		if (param == "all") then
			Auctioneer.Util.ChatPrint(_AUCT('FrmtActDefaultall'));
			for k,v in pairs(AuctionConfig.filters) do
				setKhaosSetKeyValue(k, Auctioneer.Command.GetFilterVal(k));
			end

		else
			Auctioneer.Util.ChatPrint(_AUCT('FrmtActDefault'):format(paramLocalized));
			setKhaosSetKeyValue(param, Auctioneer.Command.GetFilterVal(param));
		end
	end
end

--The following three functions were added by MentalPower to implement the /auc print-in command
function getFrameNames(index)

	local frames = {};
	local frameName = "";

	for i=1, 10 do
		local name, fontSize, r, g, b, a, shown, locked, docked = GetChatWindowInfo(i);

		if ( name == "" ) then
			if (i == 1) then
				frames[_AUCT('TextGeneral')] = 1;

			elseif (i == 2) then
				frames[_AUCT('TextCombat')] = 2;
			end

		else
			frames[name] = i;
		end
	end

	if (type(index) == "number") then
		local name, fontSize, r, g, b, a, shown, locked, docked = GetChatWindowInfo(index);

		if ( name == "" ) then
			if (index == 1) then
				frameName = _AUCT('TextGeneral');

			elseif (index == 2) then
				frameName = _AUCT('TextCombat');
			end

		else
			frameName = name;
		end
	end

	return frames, frameName;
end


function getFrameIndex()
	if (not AuctionConfig.filters) then AuctionConfig.filters = {}; end
	local value = AuctionConfig.filters["printframe"];

	if (not value) then
		return 1;
	end
	return value;
end


function setFrame(frame, khaosCommand)
	local frameNumber
	local frameVal
	frameVal = tonumber(frame)

	--If no arguments are passed, then set it to the default frame.
	if not (frame) then
		frameNumber = 1;

	--If the frame argument is a number then set our chatframe to that number.
	elseif ((frameVal) ~= nil) then
		frameNumber = frameVal;

	--If the frame argument is a string, find out if there's a chatframe with that name, and set our chatframe to that index. If not set it to the default frame.
	elseif (type(frame) == "string") then
		allFrames = getFrameNames();
		if (allFrames[frame]) then
			frameNumber = allFrames[frame];
		else
			frameNumber = 1;
		end

	--If the argument is something else, set our chatframe to its default value.
	else
		frameNumber = 1;
	end

	local _, frameName
	if khaosCommand == false then
		_, frameName = getFrameNames(frameNumber);
		if (getFrameIndex() ~= frameNumber) then
			Auctioneer.Util.ChatPrint(_AUCT('FrmtPrintin'):format(frameName));
		end
	end

	setFilter("printframe", frameNumber);

	if khaosCommand == false then
		Auctioneer.Util.ChatPrint(_AUCT('FrmtPrintin'):format(frameName));
		setKhaosSetKeyValue("printframe", frameNumber);
	end
end

function protectWindow(param, khaosCommand)
	local mode;

	if (param == 'never' or param == 'off' or param == _AUCT('CmdProtectWindow0') or param == _AUCT('CmdOff') or tonumber(param) == 0) then
		mode = 0;
		Auctioneer.Util.ProtectAuctionFrame(false);

	elseif (param == 'scan' or param == _AUCT('CmdProtectWindow1') or tonumber(param) == 1) then
		mode = 1;
		if (Auctioneer.ScanManager.IsScanning()) then
			Auctioneer.Util.ProtectAuctionFrame(true);
		else
			Auctioneer.Util.ProtectAuctionFrame(false);
		end

	elseif (param == 'always' or param == _AUCT('CmdProtectWindow2') or tonumber(param) == 2) then
		mode = 2;
		Auctioneer.Util.ProtectAuctionFrame(true);

	else
		Auctioneer.Util.ChatPrint(_AUCT('FrmtUnknownArg'):format(param, Auctioneer.Util.LocalizeCommand("protect-window")));
		return
	end

	setFilter("protect-window", mode);

	if khaosCommand == false then
		Auctioneer.Util.ChatPrint(_AUCT('FrmtProtectWindow'):format(_AUCT('CmdProtectWindow' .. mode)));
		setKhaosSetKeyValue("protect-window", mode);
	end
end

function auctionDuration(param, khaosCommand)
	local mode;

	if (param == 'last' or param == _AUCT('CmdAuctionDuration0') or tonumber(param) == 0) then
		mode = 0;

	elseif (param == '2h' or param == _AUCT('CmdAuctionDuration1') or tonumber(param) == 1) then
		mode = 1;

	elseif (param == '8h' or param == _AUCT('CmdAuctionDuration2') or tonumber(param) == 2) then
		mode = 2;

	elseif (param == '24h' or param == _AUCT('CmdAuctionDuration3') or tonumber(param) == 3) then
		mode = 3;

	else
		Auctioneer.Util.ChatPrint(_AUCT('FrmtUnknownArg'):format(param, Auctioneer.Util.LocalizeCommand("auction-duration")));
		return
	end

	setFilter("auction-duration", mode);

	if khaosCommand == false then
		Auctioneer.Util.ChatPrint(_AUCT('FrmtAuctionDuration'):format(_AUCT('CmdAuctionDuration' .. mode)));
		setKhaosSetKeyValue("auction-duration", mode);
	end
end

function finish(param, khaosCommand)
	local mode;

	if (param == 'off' or param == _AUCT('CmdFinish0') or tonumber(param) == 0) then
		mode = 0;

	elseif (param == 'logout' or param == _AUCT('CmdFinish1') or tonumber(param) == 1) then
		mode = 1;

	elseif (param == 'exit' or param == _AUCT('CmdFinish2') or tonumber(param) == 2) then
		mode = 2;

	else
		Auctioneer.Util.ChatPrint(_AUCT('FrmtUnknownArg'):format(param, Auctioneer.Util.LocalizeCommand("finish")));
		return
	end

	setFilter("finish", mode);

	if khaosCommand == false then
		Auctioneer.Util.ChatPrint(_AUCT('FrmtFinish'):format(_AUCT('CmdFinish' .. mode)));
		setKhaosSetKeyValue("finish", mode);
	end
end

function genVarSet(variable, param, khaosCommand)
	if (type(param) == "string") then
		param = Auctioneer.Util.DelocalizeFilterVal(param);
	end

	if (param == "on" or param == "off" or type(param) == "boolean") then
		setFilter(variable, param);
	elseif (param == "toggle" or param == nil or param == "") then
		param = setFilter(variable, not getFilter(variable));
	end

	if khaosCommand == false then
		if (getFilter(variable)) then
			Auctioneer.Util.ChatPrint(_AUCT('FrmtActEnable'):format(Auctioneer.Util.LocalizeCommand(variable)));
			setKhaosSetKeyValue(variable, true)
		else
			Auctioneer.Util.ChatPrint(_AUCT('FrmtActDisable'):format(Auctioneer.Util.LocalizeCommand(variable)));
			setKhaosSetKeyValue(variable, false)
		end
	end
end


function percentVarSet(variable, param, khaosCommand)
	local paramVal = tonumber(param);
	if paramVal == nil then
		-- failed to convert the param to a number

		if khaosCommand == false then
			Auctioneer.Util.ChatPrint(_AUCT('FrmtUnknownArg'):format(param, variable));
		end
		return -- invalid argument, don't do anything
	end
	-- param is a valid number, save it
	setFilter(variable, paramVal);

	--Clear the HSP Cache since the profitability numbers have been updated.
	Auctioneer_HSPCache = {};

	if khaosCommand == false then
		Auctioneer.Util.ChatPrint(_AUCT('FrmtActSet'):format(variable, paramVal.."%"));
		setKhaosSetKeyValue(variable, paramVal);
	end
end

function numVarSet(variable, param, khaosCommand)
	local paramVal = tonumber(param);
	if (not paramVal) then
		-- failed to convert the param to a number

		if khaosCommand == false then
			Auctioneer.Util.ChatPrint(_AUCT('FrmtUnknownArg'):format(param, variable));
		end
		return -- invalid argument, don't do anything
	end
	-- param is a valid number, save it
	setFilter(variable, paramVal);

	if khaosCommand == false then
		Auctioneer.Util.ChatPrint(_AUCT('FrmtActSet'):format(variable, paramVal));
		setKhaosSetKeyValue(variable, paramVal);
	end
end

--This marks the end of the New Command processing code.


function setFilter(key, value)
	if (not AuctionConfig.filters) then AuctionConfig.filters = {}; end
	if (type(value) == "boolean") then
		if (value) then
			AuctionConfig.filters[key] = 'on';
		else
			AuctionConfig.filters[key] = 'off';
		end
	else
		AuctionConfig.filters[key] = value;
	end
end

function getFilterVal(type)
	if (not AuctionConfig.filters) then
		AuctionConfig.filters = {};
		Auctioneer.Util.SetFilterDefaults();
	end
	local val = AuctionConfig.filters[type];
	if (not val) then
		val = Auctioneer.Core.Constants.FilterDefaults[type];
	end
	return val;
end

function getFilter(filter)
	local value = getFilterVal(filter);
	if ((value == _AUCT('CmdOn')) or (value == "on")) then
		return true;

	elseif ((value == _AUCT('CmdOff')) or (value == "off")) then
		return false;
	end
	return true;
end

function findFilterClass(text)
	local totalFilters = getn(CLASS_FILTERS);
	for currentFilter=1, totalFilters do
		if (text == CLASS_FILTERS[currentFilter]) then
			return currentFilter, totalFilters;
		end
	end
	return 0, totalFilters;
end

function filterSetFilter(checkbox, filter)
	checkbox.filterVal = filter;
	checkbox:SetChecked(getFilter(filter));
	checkbox:Show();
end

-------------------------------------------------------------------------------
-- Returns the current locale setting, or "default", if the default language is
-- used.
-------------------------------------------------------------------------------
function getLocale()
	local ret = strsplit(",", Babylonian:GetOrder(), 1)
	if ret == "" then
		ret = "default"
	end
	return ret
end

-------------------------------------------------------------------------------
-- Called when Babylonian:SetOrder() is called to update Khaos' locale setting.
--
-- parameters:
--    _ - ignoring the first parameter, which is an empty table, since no
--        parameters are passed when registering this function with Stubby
--        (see Stubby.RegisterFunctionHook() for more details)
--    _ - ignoring the second parameter, which is an empty table, since the
--        the original function was not yet called
--        (see Stubby.RegisterFunctionHook() for more details)
-------------------------------------------------------------------------------
function onBabylonianSetOrder(_, _)
	setKhaosSetKeyValue("locale", getLocale())
end

-------------------------------------------------------------------------------
-- Before 4.0.2 the locale setting was set to '' instead of 'default' which
-- lead to the inapropriate setting in khaos (no selection for locale).
-- The following fix corrects that.
-------------------------------------------------------------------------------
function fixLocaleDefault()
	for _, setting in ipairs(Khaos_Configurations) do
		if setting.configuration and
		   setting.configuration.Auctioneer and
		   setting.configuration.Auctioneer.locale and
		   setting.configuration.Auctioneer.locale.value == "" then
			setting.configuration.Auctioneer.locale.value = "default"
		end
	end
end

-------------------------------------------------------------------------------
-- Prints the specified message to nLog.
--
-- syntax:
--    errorCode, message = debugPrint([message][, title][, errorCode][, level])
--
-- parameters:
--    message   - (string) the error message
--                nil, no error message specified
--    title     - (string) the title for the debug message
--                nil, no title specified
--    errorCode - (number) the error code
--                nil, no error code specified
--    level     - (string) nLog message level
--                         Any nLog.levels string is valid.
--                nil, no level specified
--
-- returns:
--    errorCode - (number) errorCode, if one is specified
--                nil, otherwise
--    message   - (string) message, if one is specified
--                nil, otherwise
-------------------------------------------------------------------------------
function debugPrint(message, title, errorCode, level)
	return Auctioneer.Util.DebugPrint(message, "AucCommand", title, errorCode, level)
end

--=============================================================================
-- Initialization
--=============================================================================
if (Auctioneer.Command) then return end;

Auctioneer.Command = {
	Register = register,
	ConvertKhaos = convertKhaos,
	GetKhaosDefault = getKhaosDefault,
	RegisterKhaos = registerKhaos,
	BuildCommandMap = buildCommandMap,
	CommandMap = commandMap,
	CommandMapRev = commandMapRev,
	MainHandler = mainHandler,
	ChatPrintHelp = chatPrintHelp,
	OnOff = onOff,
	Clear = clear,
	AlsoInclude = alsoInclude,
	IsValidLocale = isValidLocale,
	SetLocale = setLocale,
	Default = default,
	GetFrameNames = getFrameNames,
	GetFrameIndex = getFrameIndex,
	SetFrame = setFrame,
	ProtectWindow = protectWindow,
	AuctionDuration = auctionDuration,
	Finish = finish,
	GenVarSet = genVarSet,
	PercentVarSet = percentVarSet,
	NumVarSet = numVarSet,
	SetFilter = setFilter,
	GetFilterVal = getFilterVal,
	GetFilter = getFilter,
	FindFilterClass = findFilterClass,
	FilterSetFilter = filterSetFilter,
	GetLocale = getLocale,
}
