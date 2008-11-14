local LayHideErrors_Version = "1.2"
local LayHideErrors_ErrorsAreShown = true
local LayHideErrors_ErrorSpeachWasEnable = GetCVar("Sound_EnableSFX")

local function LayHideErrors_HideErrors()
	LayHideErrors_ErrorsAreShown = false
	LayHideErrors_ErrorSpeachWasEnable = GetCVar("Sound_EnableSFX")
	SetCVar("Sound_EnableSFX", 0)
end

local function LayHideErrors_ShowErrors()
	LayHideErrors_ErrorsAreShown = true
	SetCVar("Sound_EnableSFX",LayHideErrors_ErrorSpeachWasEnable)
end

local LayHideErrors_old_UIErrorsFrame_OnEvent = UIErrorsFrame_OnEvent

function UIErrorsFrame_OnEvent(event, message)
	if LayHideErrors_ErrorsAreShown then
		LayHideErrors_old_UIErrorsFrame_OnEvent(event, message)
	end
end


SLASH_LAYHIDEERRORS_SHOW1 = "/errshow"
SLASH_LAYHIDEERRORS_SHOW2 = "/err1"
SLASH_LAYHIDEERRORS_HIDE1 = "/errhide"
SLASH_LAYHIDEERRORS_HIDE2 = "/err0"
SlashCmdList["LAYHIDEERRORS_SHOW"] = LayHideErrors_ShowErrors
SlashCmdList["LAYHIDEERRORS_HIDE"] = LayHideErrors_HideErrors

DEFAULT_CHAT_FRAME:AddMessage("LayHideErrors v."..LayHideErrors_Version.." loaded. Use \"/err0\" at the begining of your macros and \"/err1\" at the end of it.",0.9,0.8,0)