function SMOnlineScreen() -- used for various SMOnline-enabled screens:
	if not IsNetSMOnline() then
		return "ScreenSelectMusic"
	end
	if not IsSMOnlineLoggedIn() then
		return "ScreenSMOnlineLogin"
	end
	return "ScreenNetRoom"
end
Branch.StartGame = function()
	multiplayer = false
	if PROFILEMAN:GetNumLocalProfiles() >= 2 then
		return "ScreenSelectProfile"
	else
		return "ScreenProfileLoad"
	end
end
Branch.MultiScreen = function()
	if IsNetSMOnline() then
	        MultiLoops = 0
		if not IsSMOnlineLoggedIn() then
			return "ScreenNetSelectProfile"
		else
			return "ScreenNetSelectProfile" --return "ScreenNetRoom" 	-- cant do this, we need to select a local profile even
		end																-- if logged into smo -mina
	else
	        if MultiLoops == 3 then
		   SCREENMAN:SystemMessage("Could not connect to multiplayer!")
		   MultiLoops = 0
		   return "ScreenNetworkOptions"
		else
		   local LastMulti = PREFSMAN:GetPreference("LastConnectedMultiServer") or "multi.etternaonline.com"
		   ConnectToServer(LastMulti)
		   MultiLoops = MultiLoops + 1
		   return Branch.MultiScreen()
		end
	end
end
Branch.OptionsEdit = function()
	-- Similar to above, don't let anyone in here with 0 songs.
	return "ScreenOptionsEdit"
end
Branch.AfterSelectStyle = function()
	if IsNetConnected() then
		ReportStyle()
		GAMESTATE:ApplyGameCommand("playmode,regular")
	end
	return "ScreenProfileLoad"
end
Branch.AfterSelectProfile = function()
	return "ScreenSelectMusic"
end

Branch.LeaveAssets = function()
	if IsSMOnlineLoggedIn(PLAYER_1) then
		if NSMAN:GetCurrentRoomName() then
			return "ScreenNetSelectMusic"
		else
			return "ScreenNetRoom"
		end
	end
	return "ScreenSelectMusic"
end
