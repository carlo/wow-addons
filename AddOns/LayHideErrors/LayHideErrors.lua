LayHideErrors_Version = "1.1"
LayHideErrors_ErrorsAreShown = true
LayHideErrors_ErrorSpeachWasEnable = GetCVar("EnableErrorSpeech")

function LayHideErrors_HideErrors()
	LayHideErrors_ErrorsAreShown = false
	LayHideErrors_ErrorSpeachWasEnable = GetCVar("EnableErrorSpeech")
	SetCVar("EnableErrorSpeech", 0)
end

function LayHideErrors_ShowErrors()
	LayHideErrors_ErrorsAreShown = true
	SetCVar("EnableErrorSpeech",LayHideErrors_ErrorSpeachWasEnable)
end

function LayHideErrors_UIErrorsFrame_OnEvent(event, message)
	if LayHideErrors_ErrorsAreShown then
		if ( event == "SYSMSG") then
			this:AddMessage(message, arg2, arg3, arg4, 1.0);
		elseif ( event == "UI_INFO_MESSAGE" ) then
			this:AddMessage(message, 1.0, 1.0, 0.0, 1.0);
		elseif ( event == "UI_ERROR_MESSAGE" ) then
			this:AddMessage(message, 1.0, 0.1, 0.1, 1.0);
		end
	end
end

function LayHideErrors_EventHandler()
	if event == "VARIABLES_LOADED" then
		LayHideErrors_OnLoad()
		LayHideErrorsFrame:UnregisterEvent("VARIABLES_LOADED")
	end
end

function LayHideErrors_OnLoad()
	UIErrorsFrame_OnEvent = LayHideErrors_UIErrorsFrame_OnEvent
end

SLASH_LAYHIDEERRORS_SHOW1 = "/errshow"
SLASH_LAYHIDEERRORS_SHOW2 = "/err1"
SLASH_LAYHIDEERRORS_HIDE1 = "/errhide"
SLASH_LAYHIDEERRORS_HIDE2 = "/err0"
SlashCmdList["LAYHIDEERRORS_SHOW"] = LayHideErrors_ShowErrors
SlashCmdList["LAYHIDEERRORS_HIDE"] = LayHideErrors_HideErrors

DEFAULT_CHAT_FRAME:AddMessage("LayHideErrors v."..LayHideErrors_Version.." loaded. Use \"/err0\" at the begining of your macros and \"/err1\" at the end of it.",0.9,0.8,0)