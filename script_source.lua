function OnStyle(styler)
	if styler.language ~= "script_source" then return end
	
        S_DEFAULT = 0
        S_IDENTIFIER = 1
        S_KEYWORD = 2
        S_COMMENT = 3
	S_NUMBER = 4
	S_SYMBOL = 5
	S_DIRECTIVE = 6
	S_WHITESPACE = 7
	S_STRING = 8
	
        charsStart = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ?_"
	charsEnd = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890?._"
	keywords = " local function and or not for in as return break struct if else elseif while repeat until field import package enum true false iterator extends to "
	numbers = ".01234567890"
	symbols = "(){}[]!&+-=~|/<>%^"
	
        styler:StartStyling(styler.startPos, styler.lengthDoc, styler.initStyle)
        while styler:More() do
		-- styler:Token() gets the stuff matched so far
		-- styler:ChangeState(S_KEYWORD) changes style of current token
		-- styler:SetState(S_DEFAULT) submits the finihsed token and starts a new one at S_DEFAULT
		-- styler:ForwardSetState(S_DEFAULT) comb. of SetState and Forward
		-- styler:State() gets state
		-- styler:Match("«") ???
		-- styler:Forward() advances
		
		if styler:State()==S_DEFAULT then
			if charsStart:find(styler:Current(), 1, true) then
				--begin of ID/keyword token
				styler:SetState(S_IDENTIFIER)
			elseif numbers:find(styler:Current(), 1, true) then
				--begin of # token
				styler:SetState(S_NUMBER)
			elseif symbols:find(styler:Current(), 1, true) then
				--begin of symbol token
				styler:SetState(S_SYMBOL)
			elseif styler:Current()=="@" then
				--begin of @ token
				styler:SetState(S_DIRECTIVE)
			elseif styler:Current()=="\"" then
				--begin of " token
				styler:SetState(S_STRING)
			end
		elseif styler:State()==S_IDENTIFIER then
			if not charsEnd:find(styler:Current(), 1, true) then
				--end of ID token
				if keywords:match(" "..styler:Token().." ") then
					styler:ChangeState(S_KEYWORD)
				end
				styler:SetState(S_DEFAULT)
			end
		elseif styler:State()==S_NUMBER then
			if not numbers:find(styler:Current(), 1, true) then
				--end of # token
				styler:SetState(S_DEFAULT)
			end
		elseif styler:State()==S_SYMBOL then
			if not symbols:find(styler:Current(), 1, true) then
				--end of symbol token/begin of comment token
				if styler:Token():match("^%/%/") then
					styler:ChangeState(S_COMMENT)
				else
					styler:SetState(S_DEFAULT)
				end
			end
		elseif styler:State()==S_COMMENT then
			--end of comment token
			if styler:Current()=="\n" then
				styler:SetState(S_DEFAULT)
			end
		elseif styler:State()==S_DIRECTIVE then
			--end of @ token
			if styler:Current():match("%s") then
				styler:SetState(S_DEFAULT)
			end
		elseif styler:State()==S_STRING then
			--end of " token
			if styler:Current()=="\"" then
				styler:SetState(S_DEFAULT)
			end
		end

                styler:Forward()
        end
        styler:EndStyling()
end