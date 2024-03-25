local profile = PROFILEMAN:GetProfile(PLAYER_1)
local frameX = 10
local frameY = 250 + capWideScale(get43size(120), 90)
local frameWidth = capWideScale(get43size(455), 455)
local score
local song
local steps
local noteField = false
local infoOnScreen = false
local heyiwasusingthat = false
local mcbootlarder
local pOptions = GAMESTATE:GetPlayerState():GetCurrentPlayerOptions()
local usingreverse = pOptions:UsingReverse()
local prevX = capWideScale(get43size(98), 98)
local prevY = 55
local prevrevY = 60
local boolthatgetssettotrueonsongchangebutonlyifonatabthatisntthisone = false
local hackysack = false
local songChanged = false
local songChanged2 = false
local previewVisible = false
local onlyChangedSteps = false
local shouldPlayMusic = false
local prevtab = 0
local sn = Var "LoadingScreen"
local whee

local itsOn = false

local translated_info = TranslationMatrices["WifeTwirl"]

local prevplayerops = "Main"

local hoverAlpha = 0.8
local hoverAlpha2 = 0.6

local mintyFreshIntervalFunction = nil
local update = false

inMultiLobby = false

--[[
	toggleCalcInfo, playMusicForPreview, and toggleNoteField
	are being called from other functions, so they should be pretty high up
	- kurulen
]]

-- to toggle calc info display stuff
local function toggleCalcInfo(state)
	infoOnScreen = state

	if infoOnScreen then
		MESSAGEMAN:Broadcast("CalcInfoOn")
	else
		MESSAGEMAN:Broadcast("CalcInfoOff")
	end
end

-- to reduce repetitive code for setting preview music position with booleans
local function playMusicForPreview(song)
	SOUND:StopMusic()
	SCREENMAN:GetTopScreen():PlayCurrentSongSampleMusic(true, true)
	MESSAGEMAN:Broadcast("PreviewMusicStarted") -- this is lying tbh

	restartedMusic = true

	-- use this opportunity to set all the random booleans to make it consistent
	songChanged = false
	boolthatgetssettotrueonsongchangebutonlyifonatabthatisntthisone = false
	hackysack = false
end

local function toggleNoteField()
	local nf = mcbootlarder:GetChild("NoteField")
	if song and not noteField then -- first time setup
		noteField = true
		MESSAGEMAN:Broadcast("ChartPreviewOn") -- for banner reaction... lazy -mina
		mcbootlarder:playcommand("SetupNoteField")
		mcbootlarder:xy(prevX, prevY)
		mcbootlarder:diffusealpha(1)

		pOptions = GAMESTATE:GetPlayerState():GetCurrentPlayerOptions()
		usingreverse = pOptions:UsingReverse()
		local usingscrollmod = false
		if pOptions:Split() ~= 0 or pOptions:Alternate() ~= 0 or pOptions:Cross() ~= 0 or pOptions:Centered() ~= 0 then
			usingscrollmod = true
		end

		nf:y(prevY * 2.85)
		if usingscrollmod then
			nf:y(prevY * 3.55)
		elseif usingreverse then
			nf:y(prevY * 2.85 + prevrevY)
		end

		if not songChanged then
			playMusicForPreview(song)
			tryingToStart = true
		else
			tryingToStart = false
		end
		songChanged = false
		hackysack = false
		previewVisible = true
		return true
	end

	if song then
		nf:diffusealpha(1)
		if mcbootlarder:IsVisible() then
			mcbootlarder:visible(false)
			nf:visible(false)
			MESSAGEMAN:Broadcast("ChartPreviewOff")
			toggleCalcInfo(false)
			previewVisible = false
			hackysack = changingSongs
			changingSongs = false
			return false
		else
			mcbootlarder:visible(true)
			nf:visible(true)
			if boolthatgetssettotrueonsongchangebutonlyifonatabthatisntthisone or songChanged or songChanged2 then
				if not restartedMusic then
					playMusicForPreview(song)
				end
				boolthatgetssettotrueonsongchangebutonlyifonatabthatisntthisone = false
				hackysack = false
				songChanged = false
				songChanged2 = false
			end
			MESSAGEMAN:Broadcast("ChartPreviewOn")
			previewVisible = true
			return true
		end
	end
	return false
end

-- TODO: move this (and every other ctrl bind function) into a script
--   -kurulen
local function ssmCtrlBinds(event)
        RunLoops(event)
	if event.type ~= "InputEventType_Release" and getTabIndex() == 0 then
		if event.DeviceInput.button == "DeviceButton_space" then
			toggleNoteField()
		end
	end
	if event.type == "InputEventType_FirstPress" then
		local CtrlPressed = INPUTFILTER:IsControlPressed()
		if CtrlPressed then
			-- regular binds (Screen*SelectMusic)
			if event.DeviceInput.button == "DeviceButton_backslash" then
				-- login/logout
				MESSAGEMAN:Broadcast("LoginHotkeyPressed")
				return true
			elseif event.DeviceInput.button == "DeviceButton_e" then
				-- toggle sample music
				SCREENMAN:GetTopScreen():PauseSampleMusic()
				MESSAGEMAN:Broadcast("MusicPauseToggled")
				return true
			elseif event.DeviceInput.button == "DeviceButton_space" and getTabIndex() == 0 then
				-- toggle calc info/debug
			        if GAMESTATE:GetCurrentGame():GetName() == "dance" then
				   if mcbootlarder:IsVisible() then
				      toggleCalcInfo(not infoOnScreen)
				   else
				      if toggleNoteField() then
					 toggleCalcInfo(true)
				      end
				   end
				end
				return true
			elseif event.DeviceInput.button == "DeviceButton_4" and getTabIndex() == 0 then
				-- rename joined profile
				easyInputStringWithFunction(translated_info["NameChange"], 64, false, setnewdisplayname)
				return true
			elseif event.DeviceInput.button == "DeviceButton_r" and getTabIndex() == 0 then
				-- reload all packs
				--   this also reloads s*sm to fix any "ghost pack" issues
				--   -kurulen
				SONGMAN:DifferentialReload()
				SCREENMAN:GetTopScreen():SetNextScreenName(
					"Screen" .. (inMultiLobby and "Net" or "") .. "SelectMusic"
				)
				SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
				return true
			elseif event.DeviceInput.button == "DeviceButton_y" and getTabIndex() == 0 then
				if song then
					SCREENMAN:GetTopScreen():OpenOptions()
				end
				return true
			end

			-- multiplayer binds (NetSelectMusic)
			
			if inMultiLobby then
				if event.DeviceInput.button == "DeviceButton_u" then
					NSMAN:SendChatMsg("/force", 1, NSMAN:GetCurrentRoomName())
					return true
				elseif event.DeviceInput.button == "DeviceButton_h" and INPUTFILTER:IsShiftPressed() then
				   local filt = FILTERMAN:GetFilteringCommonPacks()
				   SCREENMAN:GetTopScreen():GetMusicWheel():SetPackListFiltering(not filt)
				   SCREENMAN:SystemMessage("Shared packs filter: "..((not filt) and "on" or "off"))
				elseif event.DeviceInput.button == "DeviceButton_h" then
					NSMAN:SendChatMsg("/ready", 1, NSMAN:GetCurrentRoomName())
					local stat, readied = pcall(function()
						local qty = top:GetUserQty()
						local loggedInUser = NSMAN:GetLoggedInUsername()
						for i = 1, qty do
							local user = top:GetUser(i)
							if user == loggedInUser then
								return top:GetUserReady(i)
							end
						end
					end)
					return true
				end
			end
		elseif event.DeviceInput.button == "DeviceButton_F1" then
		   ShowingHelp = not ShowingHelp
		   MESSAGEMAN:Broadcast((ShowingHelp == true and "Show" or "Hide").."KBHelps")
		end
	end
	return false
end

-- to reduce repetitive code for setting preview visibility with booleans
local function setPreviewPartsState(state)
	if state == nil then return end
	mcbootlarder:visible(state)
	mcbootlarder:GetChild("NoteField"):visible(state)
	heyiwasusingthat = not state
	previewVisible = state
	if state ~= infoOnScreen and not state then
		toggleCalcInfo(false)
	end
end

local t = Def.ActorFrame {
	Name = "wifetwirler",
	BeginCommand = function(self)
		self:queuecommand("MintyFresh")
	end,
	OffCommand = function(self)
		self:bouncebegin(0.2):xy(-500, 0):diffusealpha(0)
		toggleCalcInfo(false)
		self:sleep(0.04):queuecommand("Invis")
	end,
	InvisCommand= function(self)
		self:visible(false)
	end,
	OnCommand = function(self)
		self:bouncebegin(0.2):xy(0, 0):diffusealpha(1)
	end,
	CurrentSongChangedMessageCommand = function()
		-- This will disable mirror when switching songs if OneShotMirror is enabled or if permamirror is flagged on the chart (it is enabled if so in screengameplayunderlay/default)
		if playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).OneShotMirror or profile:IsCurrentChartPermamirror() then
			local modslevel = topscreen == "ScreenEditOptions" and "ModsLevel_Stage" or "ModsLevel_Preferred"
			local playeroptions = GAMESTATE:GetPlayerState():GetPlayerOptions(modslevel)
			playeroptions:Mirror(false)
		end
		-- if not on General and we started the noteField and we changed tabs then changed songs
		-- this means the music should be set again as long as the preview is still "on" but off screen
		if getTabIndex() ~= 0 and noteField and heyiwasusingthat then
			boolthatgetssettotrueonsongchangebutonlyifonatabthatisntthisone = true
		end

		-- if the preview was turned on ever but is currently not on screen as the song changes
		-- this goes hand in hand with the above boolean
		if noteField and not previewVisible then
			songChanged = true
		end

		-- check to see if the song actually really changed
		-- >:(
		if noteField and GAMESTATE:GetCurrentSong() ~= song then
			-- always true if switching songs and preview has ever been opened
			songChanged2 = true
			restartedMusic = false
		else
			songChanged2 = false
		end

		-- an awkwardly named bool describing the fact that we just changed songs
		-- used in notefield creation function to see if we should restart music
		-- it is immediately turned off when toggling notefield
		changingSongs = true
		tryingToStart = false

		-- if switching songs, we want the notedata to disappear temporarily
		if noteField and songChanged2 and previewVisible then
			mcbootlarder:GetChild("NoteField"):finishtweening()
			mcbootlarder:GetChild("NoteField"):diffusealpha(0)
		end
	end,
	DelayedChartUpdateMessageCommand = function(self)
		-- wait for the music wheel to settle before playing the music
		-- to keep things very slightly more easy to deal with
		-- and reduce a tiny bit of lag
		local s = GAMESTATE:GetCurrentSong()
		local unexpectedlyChangedSong = s ~= song

		shouldPlayMusic = false
		-- should play the music because the notefield is visible
		shouldPlayMusic = shouldPlayMusic or (noteField and mcbootlarder:GetChild("NoteField") and mcbootlarder:GetChild("NoteField"):IsVisible())
		-- should play the music if we switched songs while on a different tab
		shouldPlayMusic = shouldPlayMusic or boolthatgetssettotrueonsongchangebutonlyifonatabthatisntthisone
		-- should play the music if we switched to a song from a pack tab
		-- also applies for if we just toggled the notefield or changed screen tabs
		shouldPlayMusic = shouldPlayMusic or hackysack
		-- should play the music if we already should and we either jumped song or we didnt change the song
		shouldPlayMusic = shouldPlayMusic and (not onlyChangedSteps or unexpectedlyChangedSong) and not tryingToStart

		-- at this point the music will or will not play ....

		boolthatgetssettotrueonsongchangebutonlyifonatabthatisntthisone = false
		hackysack = false
		tryingToStart = false
		songChanged = false
		onlyChangedSteps = true
	end,
	PlayingSampleMusicMessageCommand = function(self)
		-- delay setting the music for preview up until after the sample music starts (smoothness)
		if shouldPlayMusic then
			shouldPlayMusic = false
			local s = GAMESTATE:GetCurrentSong()
			if s then
				if mcbootlarder and mcbootlarder:GetChild("NoteField") then mcbootlarder:GetChild("NoteField"):diffusealpha(1) end
				playMusicForPreview(s)
			end
		end
	end,
	MintyFreshCommand = function(self)
		self:finishtweening()
		local bong = GAMESTATE:GetCurrentSong()
		-- if not on a song and preview is on, hide it (dont turn it off)
		if not bong and noteField and mcbootlarder:IsVisible() then
			setPreviewPartsState(false)
			MESSAGEMAN:Broadcast("ChartPreviewOff")
		end

		-- if the song changed
		if song ~= bong then
			if not lockbools then
				onlyChangedSteps = false
			end
			if not song and previewVisible and not lockbools then
				hackysack = true -- used in cases when moving from null song (pack hover) to a song (this fixes searching and preview not working)
			end
			song = bong
			self:queuecommand("MortyFarts")
		else
			if not lockbools and not songChanged2 then
				onlyChangedSteps = true
			end
		end

		-- on general tab
		if getTabIndex() == 0 then
		        CurrentSubTidbit = ""
			-- if preview was on and should be made visible again
			if heyiwasusingthat and bong and noteField then
				setPreviewPartsState(true)
				MESSAGEMAN:Broadcast("ChartPreviewOn")
			elseif bong and noteField and previewVisible then
				-- make sure that it is visible even if it isnt, when it should be
				-- (haha lets call this 1000000 times nothing could go wrong)
				setPreviewPartsState(true)
			end

			self:visible(true)
			self:queuecommand("On")
			update = true
		else
			-- changing tabs off of general with preview on, hide the preview
			if bong and noteField and mcbootlarder:IsVisible() then
				setPreviewPartsState(false)
				MESSAGEMAN:Broadcast("ChartPreviewOff")
			end

			self:queuecommand("Off")
			update = false
		end
		lockbools = false
	end,
	TabChangedMessageCommand = function(self)
		local newtab = getTabIndex()
		if newtab ~= prevtab then
			self:queuecommand("MintyFresh")
			prevtab = newtab
			if getTabIndex() == 0 and noteField then
				mcbootlarder:GetChild("NoteField"):diffusealpha(1)
				lockbools = true
			elseif getTabIndex() ~= 0 and noteField then
				hackysack = mcbootlarder:IsVisible()
				onlyChangedSteps = false
				boolthatgetssettotrueonsongchangebutonlyifonatabthatisntthisone = false
				lockbools = true
			end
		end
	end,
	MilkyTartsCommand = function(self) -- when entering pack screenselectmusic explicitly turns visibilty on notefield off -mina
		if noteField and mcbootlarder:IsVisible() then
			toggleCalcInfo(false)
		end
	end,
	CurrentStepsChangedMessageCommand = function(self)
		-- this basically queues MintyFresh every 0.5 seconds but only once and also resets the 0.5 seconds
		-- if you scroll again
		-- so if you scroll really fast it doesnt pop at all until you slow down
		-- lag begone
		local topscr = SCREENMAN:GetTopScreen()

		if mintyFreshIntervalFunction ~= nil then
			topscr:clearInterval(mintyFreshIntervalFunction)
			mintyFreshIntervalFunction = nil
		end
		mintyFreshIntervalFunction = topscr:setInterval(function()
			self:queuecommand("MintyFresh")
			if mintyFreshIntervalFunction ~= nil then
				topscr:clearInterval(mintyFreshIntervalFunction)
				mintyFreshIntervalFunction = nil
			end
		end,
		0.05)
	end,
	-- square above the large bar (rate, msd, notecount)
	Def.Quad {
		InitCommand = function(self)
			self:xy(frameX, frameY - 99):zoomto(110, 140):halign(0):valign(0):diffuse(getMainColor("tabs"))
			self:diffusealpha(1)
		end
	},
	-- large bottom bar (percent, wife version, length...)
	Def.Quad {
		InitCommand = function(self)
			self:xy(frameX, frameY + 18):zoomto(frameWidth + 4, 50):halign(0):valign(0):diffuse(getMainColor("tabs"))
			self:diffusealpha(1)
		end
	},
	-- light line on the left
	Def.Quad {
		InitCommand = function(self)
			self:xy(frameX, frameY - 99):zoomto(8, 167):halign(0):valign(0):diffuse(getMainColor("highlight")):diffusealpha(1)
		end
	},
}

t[#t + 1] = Def.ActorFrame{
	Name = "ActorBindings",
	Def.Actor {
		Name = "PlayerOptionsBinding",
		OptionsScreenClosedMessageCommand = function(self)
			-- hate this so much
			-- the point of this is to force the multi paged options screen to work when using this button
			-- its a massive hack
			local nextplayerops = getenv("NewOptions") or "Main"
			if nextplayerops == prevplayerops then
				-- exit the options and dont reopen and reset its state
				setenv("NewOptions", "Main")
				prevplayerops = "Main"
				return
			end

			prevplayerops = nextplayerops
			setenv("NewOptions", nextplayerops)
			-- if you ever reload the options screen and the game hard locks, this is why
			SCREENMAN:GetTopScreen():OpenOptions()
		end,
	},
	Def.Actor {
		Name = "ChartTagBinding",
		MintyFreshCommand = function(self)
			if song then
				ptags = tags:get_data().playerTags
				steps = GAMESTATE:GetCurrentSteps()
				chartKey = steps:GetChartKey()
				ctags = {}
				for k, v in pairs(ptags) do
					if ptags[k][chartKey] then
						ctags[#ctags + 1] = k
					end
				end
			end
		end
	},
	Def.Actor {
		-- very descriptive... -kurulen
		Name = "CtrlBindsBinding",
		BeginCommand = function(self)
		   whee = SCREENMAN:GetTopScreen():GetMusicWheel()

		   if sn and (sn == "ScreenNetSelectMusic") then
		      inMultiLobby = true
		   end
		   SCREENMAN:GetTopScreen():AddInputCallback(ssmCtrlBinds)
		end,
		EndCommand = function(self)
		   ShowingHelp = false
		   MESSAGEMAN:Broadcast("HideKBHelps")
		end
	},
	Def.Actor {
		Name = "SetupChartPreviewBinding",
		BeginCommand = function(self)
			-- funnily enough this still works because we're in a doubly-nested actorframe
			-- fuck the rules we do what we want
			--   -kurulen
			mcbootlarder = self:GetParent():GetParent():GetChild("ChartPreview")
		end
	}
}

-- Music Rate Display
t[#t + 1] = LoadFont("Common Large") .. {
	InitCommand = function(self)
		-- technically self:x() -kurulen
		self:aux(24.5)
		self:xy(self:getaux(), SCREEN_BOTTOM - 227):visible(true):halign(0):zoom(0.38):maxwidth(
			capWideScale(get43size(360), 360) / capWideScale(get43size(0.45), 0.45)
		)
	end,
	MintyFreshCommand = function(self)
		if song then
			self:settext(getCurRateDisplayString())
		else
			self:settext("")
		end
	end,
	CodeMessageCommand = function(self, params)
		local rate = getCurRateValue()
		ChangeMusicRate(rate, params)
		local ratestring = getCurRateDisplayString()
		-- %d5x matches 1.05x, 1.15x, 1.25x, ... -kurulen
		self:x(((ratestring:find("%d5x") ~= nil) and self:getaux()-4 or self:getaux()))
		-- making it so that 3xMusic is actually 3.0xMusic
		--   (for consistency purposes) -kurulen
		ratestring = ((ratestring == "3xMusic") and "3.0xMusic" or ratestring)
		self:settext(ratestring)
	end,
	GoalSelectedMessageCommand = function(self)
		self:queuecommand("MintyFresh")
	end
}

t[#t + 1] = Def.ActorFrame {
	Name = "RateDependentStuff", -- msd/display score/bpm/songlength -mina
	MintyFreshCommand = function()
		score = GetDisplayScore()
	end,
	CurrentRateChangedMessageCommand = function(self)
		self:queuecommand("MintyFresh") --steps stuff
		self:queuecommand("MortyFarts") --songs stuff
	end,
	LoadFont("Common Large") .. {
		Name = "MSD",
		InitCommand = function(self)
			self:xy(frameX + 58, frameY - 62):halign(0.5):zoom(0.6):maxwidth(110 / 0.6)
		end,
		MintyFreshCommand = function(self)
			if song then
				local stype = steps:GetStepsType()
				local meter = steps:GetMSD(getCurRateValue(), 1)
				self:settextf("%05.2f", meter)
				self:diffuse(byMSD(meter))
			else
				self:settext("")
			end
		end
	},
	-- skillset suff (these 3 can prolly be wrapped)
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameX + 120, frameY - 60):halign(0):zoom(0.6, maxwidth, 125)
		end,
		MintyFreshCommand = function(self)
			if song and GAMESTATE:GetCurrentStyle():ColumnsPerPlayer() == 4 then
				local ss = steps:GetRelevantSkillsetsByMSDRank(getCurRateValue(), 1)
				local out = ss == "" and "" or ms.SkillSetsTranslatedByName[ss]

				self:settext(out)
			else
				self:settext("")
			end
		end,
		ChartPreviewOnMessageCommand = function(self)
			self:visible(false)
		end,
		ChartPreviewOffMessageCommand = function(self)
			self:visible(true)
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameX + 120, frameY - 30):halign(0):zoom(0.6, maxwidth, 125)
		end,
		MintyFreshCommand = function(self)
			if song and GAMESTATE:GetCurrentStyle():ColumnsPerPlayer() == 4 then
				local ss = steps:GetRelevantSkillsetsByMSDRank(getCurRateValue(), 2)
				local out = ss == "" and "" or ms.SkillSetsTranslatedByName[ss]
				self:settext(out)
			else
				self:settext("")
			end
		end,
		ChartPreviewOnMessageCommand = function(self)
			self:visible(false)
		end,
		ChartPreviewOffMessageCommand = function(self)
			self:visible(true)
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameX + 120, frameY):halign(0):zoom(0.6, maxwidth, 125)
		end,
		MintyFreshCommand = function(self)
			if song and GAMESTATE:GetCurrentStyle():ColumnsPerPlayer() == 4 then
				local ss = steps:GetRelevantSkillsetsByMSDRank(getCurRateValue(), 3)
				local out = ss == "" and "" or ms.SkillSetsTranslatedByName[ss]
				self:settext(out)
			else
				self:settext("")
			end
		end,
		ChartPreviewOnMessageCommand = function(self)
			self:visible(false)
		end,
		ChartPreviewOffMessageCommand = function(self)
			self:visible(true)
		end
	},
	-- **score related stuff** These need to be updated with rate changed commands
	-- Primary percent score
	LoadFont("Common Large") .. {
		InitCommand = function(self)
			self:xy(frameX + 58, frameY + 48):zoom(0.6):halign(0.5):maxwidth(150):valign(1)
		end,
		MintyFreshCommand = function(self)
			if song and score then
				local perc = score:GetWifeScore() * 100
				if perc > 99.65 then
					self:settextf("%05.4f%%", notShit.floor(perc, 4))
				else
					self:settextf("%05.2f%%", notShit.floor(perc, 2))
				end
				self:diffuse(getGradeColor(score:GetWifeGrade()))
			else
				self:settext("")
			end
		end
	},
	-- Mirror PB Indicator
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameX + 37, frameY + 57):zoom(0.5):halign(1)
		end,
		MintyFreshCommand = function(self)
			if song and score then
				local mirrorStr = ""
				if score:GetModifiers():lower():find("mirror") then
					mirrorStr = "(M)"
				end
				self:settext(mirrorStr)
			else
				self:settext("")
			end
		end
	},
	-- Rate for the displayed score
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameX + 58, frameY + 57):zoom(0.5):halign(0.5)
		end,
		MintyFreshCommand = function(self)
			if song and score then
				local rate = notShit.round(score:GetMusicRate(), 3)
				local notCurRate = notShit.round(getCurRateValue(), 3) ~= rate
				local rate = string.format("%.2f", rate)
				if rate:sub(#rate, #rate) == "0" then
					rate = rate:sub(0, #rate - 1)
				end
				rate = rate .. "x"
				if notCurRate then
					self:settext("(" .. rate .. ")")
				else
					self:settext(rate)
				end
			else
				self:settext("")
			end
		end
	},
	-- wife 2/3 indicator
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameX + 76, frameY + 57):zoom(0.5):halign(0):maxwidth(140)
		end,
		MintyFreshCommand = function(self)
			if song and score then
				local wv = score:GetWifeVers()
				local ws = " W" .. wv
				self:settext(ws):diffuse(getGradeColor(score:GetWifeGrade()))
			else
				self:settext("")
			end
		end
	},
	-- goal for current rate if there is one stuff
	LoadFont("Common Normal") .. {
		Name = "Goalll",
		InitCommand = function(self)
			self:xy(capWideScale(frameX + 140,frameX + 154), frameY + 27):zoom(0.6):halign(0.5):valign(0)
			self:diffuse(getMainColor("positive"))
		end,
		MintyFreshCommand = function(self)
			if song and steps then
				local goal = profile:GetEasiestGoalForChartAndRate(steps:GetChartKey(), getCurRateValue())
				if goal then
					local perc = notShit.round(goal:GetPercent() * 100000) / 1000
					if (perc < 99.8) then
						self:settextf("%s\n%.2f%%", translated_info["GoalTarget"], perc)
					else
						self:settextf("%s\n%.3f%%", translated_info["GoalTarget"], perc)
					end
				else
					self:settext("")
				end
			else
				self:settext("")
			end
		end,
	},
	-- Date score achieved on
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(capWideScale(frameX + 180,frameX + 205), frameY + 59):zoom(0.4):halign(0)
		end,
		MintyFreshCommand = function(self)
			if song and score then
				self:settext(score:GetDate())
			else
				self:settext("")
			end
		end
	},
	-- MaxCombo
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(capWideScale(frameX + 180,frameX + 205), frameY + 45):zoom(0.4):halign(0)
		end,
		MintyFreshCommand = function(self)
			if song and score then
				self:settextf("%s: %d", translated_info["MaxCombo"], score:GetMaxCombo())
			else
				self:settext("")
			end
		end
	},
	LoadFont("Common Normal") .. {
		Name = "ClearType",
		InitCommand = function(self)
			self:xy(capWideScale(frameX + 180,frameX + 205), frameY + 30):zoom(0.6):halign(0)
		end,
		MintyFreshCommand = function(self)
			if song and score then
				self:visible(true)
				self:settext(getClearTypeFromScore(PLAYER_1, score, 0))
				self:diffuse(getClearTypeFromScore(PLAYER_1, score, 2))
			else
				self:visible(false)
			end
		end
	},
	-- **song stuff that scales with rate**
	Def.BPMDisplay {
		File = THEME:GetPathF("BPMDisplay", "bpm"),
		Name = "BPMDisplay",
		InitCommand = function(self)
			self:xy(capWideScale(get43size(384), 400) + 62, SCREEN_BOTTOM - 110.5):halign(1):zoom(0.50):maxwidth(50)
		end,
		MintyFreshCommand = function(self)
			if song then
				self:visible(true)
				self:SetFromSteps(steps)
			else
				self:visible(false)
			end
		end
	},
	LoadFont("Common Large") .. {
		Name = "PlayableDuration",
		InitCommand = function(self)
			self:xy((capWideScale(get43size(384), 400)) + 62, SCREEN_BOTTOM - 91.5):visible(true):halign(1):zoom(
				capWideScale(get43size(0.6), 0.6)
			):maxwidth(capWideScale(get43size(360), 360) / capWideScale(get43size(0.45), 0.45))
		end,
		MintyFreshCommand = function(self)
			if song then
				local playabletime = GetPlayableTime()
				self:settext(SecondsToMMSS(playabletime))
				self:diffuse(byMusicLength(playabletime))
			else
				self:settext("")
			end
		end
	},
}

-- "Radar values", noteinfo that isn't rate dependent -mina
local function radarPairs(i)
	local o = Def.ActorFrame {
		Name = "radarpair_"..i,
		LoadFont("Common Normal") .. {
			InitCommand = function(self)
				self:xy(frameX + 13, frameY - 52 + 13 * i):zoom(0.5):halign(0):maxwidth(120)
			end,
			MintyFreshCommand = function(self)
				if song then
					self:settext(ms.RelevantRadarsShort[i])
				else
					self:settext("")
				end
			end
		},
		LoadFont("Common Normal") .. {
			InitCommand = function(self)
				self:xy(frameX + 105, frameY + -52 + 13 * i):zoom(0.5):halign(1):maxwidth(60)
			end,
			CurrentStepsChangedMessageCommand = function(self, steps)
				if steps.ptr then
					self:settext(steps.ptr:GetRelevantRadars()[i])
				else
					self:settext("")
				end
			end
		},
	}
	return o
end
local r = Def.ActorFrame {
	Name = "RadarValues",
}
-- Create the radar values
for i = 1, 5 do
	r[#r + 1] = radarPairs(i)
end

-- negative bpm warning
r[#r + 1] = LoadFont("Common Large") .. {
	InitCommand = function(self)
		self:xy(frameX + 120, SCREEN_BOTTOM - 245):visible(true):halign(0):zoom(0.5)
		self:diffuse(getMainColor("negative"))
	end,
	MintyFreshCommand = function(self)
		if song and steps:GetTimingData():HasWarps() then
			self:settext(translated_info["NegBPM"])
		else
			self:settext("")
		end
	end
}

t[#t + 1] = r

-- song only stuff that doesnt change with rate
-- bpm
t[#t + 1] =LoadFont("Common Normal") .. {
	InitCommand = function(self)
		self:xy(capWideScale(get43size(379), 395) + 41, SCREEN_BOTTOM - 110.5):halign(1):zoom(0.50)
	end,
	MortyFartsCommand = function(self)
		if song then
			self:settext(translated_info["BPM"])
		else
			self:settext("")
		end
	end
}

-- cdtitle
t[#t + 1] = Def.ActorFrame {
	Name = "CDTitle",
	Def.Sprite {
		Name = "ArtistImage",
		InitCommand = function(self)
			self:xy(capWideScale(get43size(344), 364) + 50, capWideScale(get43size(345), 255))
			self:halign(0.5):valign(1)
		end,
		CurrentStyleChangedMessageCommand = function(self)
			self:playcommand("MortyFarts")
		end,
		MortyFartsCommand = function(self)
			self:finishtweening()
			self.song = song
			if song then
				if song:HasCDTitle() then
					self:visible(true)
					self:Load(song:GetCDTitlePath())
				else
					self:visible(false)
				end
			else
				self:visible(false)
			end
			local height = self:GetHeight()
			local width = self:GetWidth()

			if height >= 60 and width >= 75 then
				if height * (75 / 60) >= width then
					self:zoom(60 / height)
				else
					self:zoom(75 / width)
				end
			elseif height >= 60 then
				self:zoom(60 / height)
			elseif width >= 75 then
				self:zoom(75 / width)
			else
				self:zoom(1)
			end
			if isOver(self) then
				self:playcommand("ToolTip")
			end
		end,
		ChartPreviewOnMessageCommand = function(self)
			if not itsOn then
				self:addx(capWideScale(34, 0))
				itsOn = true
			end
			self:playcommand("ToolTip")
		end,
		ChartPreviewOffMessageCommand = function(self)
			if itsOn then
				self:addx(capWideScale(-34, 0))
				itsOn = false
			end
			self:playcommand("ToolTip")
		end
	},
	Def.Quad {
		InitCommand = function(self)
			self:xy(capWideScale(get43size(344), 364) + 50, capWideScale(get43size(345), 255) + 10)
			self:align(0.5,0)
			self:diffusealpha(0)
		end,
		MortyFartsCommand = function(self)
			local song = GAMESTATE:GetCurrentSong()
			if song ~= nil then
				local width = self:GetParent():GetChild("ArtistImage"):GetWidth()
				self:zoomto(128, 24)
				self:diffuse(getMainColor("tabs"))
				self:diffusealpha(1)
			else
				self:diffusealpha(0)
			end
		end,
		CurrentStyleChangedMessageCommand = function(self)
			self:playcommand("MortyFarts")
		end
	},
	LoadFont("Common Normal") .. {
		Name = "ArtistName",
		InitCommand = function(self)
			self:xy(capWideScale(get43size(344), 364) + 50, capWideScale(get43size(345), 255) + 16)
			self:align(0.5,0)
			self:diffusealpha(0)
		end,
		MortyFartsCommand = function(self)
			local width = self:GetParent():GetChild("ArtistImage"):GetWidth()
			local song = GAMESTATE:GetCurrentSong()
			self:maxwidth(245)
			self:zoom(0.5)
			self:diffusealpha(1)
			
			if song ~= nil then
				self:settext(song:GetOrTryAtLeastToGetSimfileAuthor())
			else
				self:diffusealpha(0)
			end
		end,
		CurrentStyleChangedMessageCommand = function(self)
			self:playcommand("MortyFarts")
		end,
		ChartPreviewOnMessageCommand = function(self)
		   self:addx(capWideScale(34, 0))
		end,
		ChartPreviewOffMessageCommand = function(self)
		   self:addx(capWideScale(-34, 0))
		end
	}
}

-- banner
t[#t + 1] = Def.Sprite {
	Name = "Banner",
	InitCommand = function(self)
		self:x(10):y(51):halign(0):valign(0)
		self:scaletoclipped(capWideScale(get43size(384), 384), capWideScale(get43size(120), 120)):diffusealpha(0.9)
	end,
	MintyFreshCommand = function(self)
		if INPUTFILTER:IsBeingPressed("tab") then
			self:finishtweening():smooth(0.25):diffusealpha(0):sleep(0.2):queuecommand("ModifyBanner")
		else
			self:finishtweening():queuecommand("ModifyBanner")
		end
	end,
	ModifyBannerCommand = function(self)
		self:finishtweening()
		if song and GAMESTATE:GetCurrentSong() ~= nil then
			local bnpath = GAMESTATE:GetCurrentSong():GetBannerPath()
			if not BannersEnabled() then
				self:visible(false)
			end
			self:diffusealpha(0)
			local stat, _ = pcall(function(self)
			      self:LoadBackground(bnpath)
			end, self)
			if stat == true then
			   self:diffusealpha(0.9)
			end
		else
			local bnpath = SONGMAN:GetSongGroupBannerPath(SCREENMAN:GetTopScreen():GetMusicWheel():GetSelectedSection())
			if not BannersEnabled() then
				self:visible(false)
			end
			self:diffusealpha(0)
			local stat, _ = pcall(function(self)
			      -- idk why song group banners are able to be "" but they are
			      self:LoadBackground( ((bnpath ~= "") and bnpath or nil) )
			end, self)
			if stat == true then
			   self:diffusealpha(0.9)
			end
		end
	end,
	ChartPreviewOnMessageCommand = function(self)
		self:visible(false)
	end,
	ChartPreviewOffMessageCommand = function(self)
		self:visible(BannersEnabled())
	end
}

-- chart tags
t[#t + 1] = LoadFont("Common Normal") .. {
	InitCommand = function(self)
		self:xy(frameX + 300, frameY - 60):halign(0):zoom(0.6):maxwidth(capWideScale(54, 450) / 0.6)
	end,
	MintyFreshCommand = function(self)
		if song and ctags[1] then
			self:settext(ctags[1])
		else
			self:settext("")
		end
	end,
	ChartPreviewOnMessageCommand = function(self)
		self:visible(false)
	end,
	ChartPreviewOffMessageCommand = function(self)
		self:visible(true)
	end
}
t[#t + 1] = LoadFont("Common Normal") .. {
	InitCommand = function(self)
		self:xy(frameX + 300, frameY - 30):halign(0):zoom(0.6):maxwidth(capWideScale(54, 450) / 0.6)
	end,
	MintyFreshCommand = function(self)
		if song and ctags[2] then
			self:settext(ctags[2])
		else
			self:settext("")
		end
	end
}
t[#t + 1] = LoadFont("Common Normal") .. {
	InitCommand = function(self)
		self:xy(frameX + 300, frameY):halign(0):zoom(0.6):maxwidth(capWideScale(54, 450) / 0.6)
	end,
	MintyFreshCommand = function(self)
		if song and ctags[3] then
			self:settext(ctags[3])
		else
			self:settext("")
		end
	end
}

-- the chart preview actor
t[#t + 1] = LoadActorWithParams("../_chartpreview.lua", {yPos = prevY, yPosReverse = prevrevY})
return t
