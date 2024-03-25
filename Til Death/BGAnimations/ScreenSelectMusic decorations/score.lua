-- refactored a bit but still needs work -mina
local rtTable
local rates
local rateIndex = 1
local scoreIndex = 1
local score
local pn = GAMESTATE:GetEnabledPlayers()[1]

local nestedTab = 1
-- TODO: Somehow move this into TranslationMatrices without it looking hacky.
--   -kurulen
local nestedTabs = {
	THEME:GetString("TabScore", "NestedLocal"),
	THEME:GetString("TabScore", "NestedOnline")
}

ssmIsLocalScores = true

local localScores
local hasReplayData

local frameX = 10
local frameY = 40
local frameWidth = SCREEN_WIDTH * 0.56
local frameHeight = 368
local fontScale = 0.4
local offsetX = 10
local offsetY = 20
local netScoresPerPage = 8
local netScoresCurrentPage = 1
local netPageButtonWidth = 50
local netPageButtonHeight = 50
local headeroffY = 10

local selectedrateonly

local judges = {
	"TapNoteScore_W1",
	"TapNoteScore_W2",
	"TapNoteScore_W3",
	"TapNoteScore_W4",
	"TapNoteScore_W5",
	"TapNoteScore_Miss",
	"HoldNoteScore_Held",
	"HoldNoteScore_LetGo"
}

local translated_info = TranslationMatrices["SSMScore"]

local defaultRateText = ""
if themeConfig:get_data().global.RateSort then
	defaultRateText = "1.0x"
else
	defaultRateText = "All"
end

local hoverAlpha = 0.6

veryBraveOrVeryStupid = false

local netScores
-- Only works if ... it should work
-- You know, if we can see the place where the scores should be.
local function updateLeaderBoardForCurrentChart()
	local top = SCREENMAN:GetTopScreen()
	if top:GetName() == "ScreenSelectMusic" or top:GetName() == "ScreenNetSelectMusic" then
		if top:GetMusicWheel():IsSettled() and ((getTabIndex() == 2 and nestedTab == 2)) then
			local steps = GAMESTATE:GetCurrentSteps()
			if steps then
				local leaderboardAttempt = DLMAN:GetChartLeaderBoard(steps:GetChartKey())
				if leaderboardAttempt ~= nil and #leaderboardAttempt > 0 then
					netScores:playcommand("SetFromLeaderboard", leaderboardAttempt)
				elseif leaderboardAttempt ~= nil and #leaderboardAttempt == 0 then
					DLMAN:RequestChartLeaderBoardFromOnline(
						steps:GetChartKey(),
						function(leaderboard)
							netScores:queuecommand("SetFromLeaderboard", leaderboard)
						end
					)
				else
					netScores:queuecommand("SetFromLeaderboard", nil)
				end
			else
				netScores:playcommand("SetFromLeaderboard", {})
			end
		end
	end
end

local function makeRateText(index)
	return LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameWidth - frameX, offsetY + 100 + (index * 15)):zoom(fontScale + 0.05):halign(1):settext("")
		end,
		DisplayCommand = function(self)
			local count = 0
			if rtTable[rates[index]] ~= nil then
				count = #rtTable[rates[index]]
			end
			if index <= #rates then
				self:settextf("%s (%d)", rates[index], count)
				if index == rateIndex then
					self:diffuse(color("#FFFFFF"))
				else
					self:diffuse(getMainColor("positive"))
				end
			else
				self:settext("")
			end
		end,
	}
end

local function makeJudge(index, judge)
	local t = Def.ActorFrame {
		InitCommand = function(self)
			self:y(129 + ((index - 1) * 18))
		end
	}

	--labels
	t[#t + 1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:zoom(0.55):halign(0)
		end,
		BeginCommand = function(self)
			self:settext(getJudgeStrings(judge))
			self:diffuse(getJudgmentColor(judge))
		end
	}

	t[#t + 1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:x(127):zoom(0.55):halign(1):settext("0")
		end,
		DisplayCommand = function(self)
			if judge ~= "HoldNoteScore_Held" and judge ~= "HoldNoteScore_LetGo" then
				self:settext(getScoreTapNoteScore(score, judge))
			else
				self:settext(getScoreHoldNoteScore(score, judge))
			end
		end
	}

	t[#t + 1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:x(130):zoom(0.3):halign(0):settext("")
		end,
		DisplayCommand = function(self)
			if judge ~= "HoldNoteScore_Held" and judge ~= "HoldNoteScore_LetGo" then
				local taps = math.max(1, getMaxNotes(pn))
				local count = getScoreTapNoteScore(score, judge)
				self:settextf("(%03.2f%%)", (count / taps) * 100)
			else
				local holds = math.max(1, getMaxHolds(pn))
				local count = getScoreHoldNoteScore(score, judge)
				self:settextf("(%03.2f%%)", (count / holds) * 100)
			end
		end
	}

	return t
end

local function input(event)
	local isHoldingCtrl = INPUTFILTER:IsControlPressed()
	local isHoldingShift = INPUTFILTER:IsShiftPressed()

	if ssmIsLocalScores == true and getTabIndex() == 2 then
		if (
			(event.DeviceInput.button == "DeviceButton_1" and isHoldingCtrl and isHoldingShift)
		) and (event.type == "InputEventType_FirstPress" or event.type == "InputEventType_Repeat") then
			moving = true
			localScores:queuecommand("PrevRate")
			return true
		elseif (
			(event.DeviceInput.button == "DeviceButton_2" and isHoldingCtrl and isHoldingShift)
		) and (event.type == "InputEventType_FirstPress" or event.type == "InputEventType_Repeat") then
			moving = true
			localScores:queuecommand("NextRate")
			return true
		elseif (
			(event.DeviceInput.button == "DeviceButton_1" and isHoldingCtrl)
		) and (event.type == "InputEventType_FirstPress" or event.type == "InputEventType_Repeat") then
			moving = true
			localScores:queuecommand("PrevScore")
			return true
		elseif (
			(event.DeviceInput.button == "DeviceButton_2" and isHoldingCtrl)
		) and (event.type == "InputEventType_FirstPress" or event.type == "InputEventType_Repeat") then
			moving = true
			localScores:queuecommand("NextScore")
			return true
		elseif (
			(event.DeviceInput.button == "DeviceButton_3" and isHoldingCtrl and isHoldingShift)
		) and event.type == "InputEventType_FirstPress" then
			if getTabIndex() == 2 and DLMAN:IsLoggedIn() then
				DLMAN:UploadScoresForPack(GAMESTATE:GetCurrentSong():GetGroupName())
			elseif getTabIndex() == 2 and not DLMAN:IsLoggedIn() then
				ms.ok(translated_info["NotLoggedIn"])
			end
			return true
		elseif (
			(event.DeviceInput.button == "DeviceButton_4" and isHoldingCtrl and isHoldingShift)
		) and event.type == "InputEventType_FirstPress" then
			if getTabIndex() == 2 and getScoreForPlot() and hasReplayData then
				SCREENMAN:GetTopScreen():ShowEvalScreenForScore(score)
			end
			return true
		elseif (
			(event.DeviceInput.button == "DeviceButton_5" and isHoldingCtrl and isHoldingShift)
		) and event.type == "InputEventType_FirstPress" then
			if getTabIndex() == 2 and getScoreForPlot() and hasReplayData then
				SCREENMAN:GetTopScreen():PlayReplay(score)
			end
			return true
		elseif (
			(event.DeviceInput.button == "DeviceButton_3" and isHoldingCtrl)
		) and event.type == "InputEventType_FirstPress" then
			if getTabIndex() == 2 and DLMAN:IsLoggedIn() then
				DLMAN:UploadScoresForChart(score:GetChartKey())
			elseif getTabIndex() == 2 and not DLMAN:IsLoggedIn() then
				ms.ok(translated_info["NotLoggedIn"])
			end
			return true
		elseif (
			(event.DeviceInput.button == "DeviceButton_4" and isHoldingCtrl)
		) and event.type == "InputEventType_FirstPress" then
			-- warns the user that this is time-intensive
			if not veryBraveOrVeryStupid then
				easyInputStringOKCancel(translated_info["ProfileUploadWarning"], 3, false, function(answer)
					if answer == "yes" then
						veryBraveOrVeryStupid = true
					else
						veryBraveOrVeryStupid = false
						ms.ok("Not uploading profile scores.")
					end
				end, function()
					veryBraveOrVeryStupid = false
					ms.ok("Not uploading profile scores.")
				end)
			end

			-- checks for if the user just typed "yes"
			if veryBraveOrVeryStupid then
				ms.ok("Uploading profile scores...")
				if getTabIndex() == 2 and DLMAN:IsLoggedIn() then
					DLMAN:UploadAllScores()
				elseif getTabIndex() == 2 and not DLMAN:IsLoggedIn() then
					ms.ok(translated_info["NotLoggedIn"])
				end
			end

			veryBraveOrVeryStupid = false
			return true
		elseif (
			(event.DeviceInput.button == "DeviceButton_5" and isHoldingCtrl)
		) and event.type == "InputEventType_FirstPress" then
			if getTabIndex() == 2 and DLMAN:IsLoggedIn() then
				DLMAN:SendReplayDataForOldScore(score:GetScoreKey())
				ms.ok(translated_info["UploadingReplay"]) --should have better feedback -mina
			elseif getTabIndex() == 2 and not DLMAN:IsLoggedIn() then
				ms.ok(translated_info["NotLoggedIn"])
			end
			return true
		elseif (
			(event.DeviceInput.button == "DeviceButton_space" and isHoldingCtrl and isHoldingShift)
		) and event.type == "InputEventType_FirstPress" then
			if getScoreForPlot() and hasReplayData and getTabIndex() == 2 then
				SCREENMAN:AddNewScreenToTop("ScreenScoreTabOffsetPlot")
			end
			return true
		elseif moving == true then
			moving = false
		end
	end
	return false
end

local ret = Def.ActorFrame {
	Name = "ScoreParent",
	BeginCommand = function(self)
		netScores = self:GetChild("NetScores")
		self:queuecommand("Set"):visible(false)
		self:GetChild("LocalScores"):xy(frameX, frameY):visible(false)
		netScores:xy(frameX, frameY):visible(false)
	end,
	OffCommand = function(self)
		self:bouncebegin(0.2):xy(-500, 0):diffusealpha(0)
		self:sleep(0.04):queuecommand("Invis")
	end,
	InvisCommand= function(self)
		self:visible(false)
		self:GetChild("LocalScores"):visible(false)
	end,
	OnCommand = function(self)
		self:bouncebegin(0.2):xy(0, 0):diffusealpha(1)
		if getTabIndex() == 2 and nestedTab == 1 then
			self:GetChild("LocalScores"):visible(true)
		else
			self:GetChild("LocalScores"):visible(false)
		end
	end,
	SetCommand = function(self)
		self:finishtweening(1)
		if getTabIndex() == 2 then -- switching to this tab
			local sd = self:GetParent():GetChild("StepsDisplay")
			if nestedTab == 2 then
			        CurrentSubTidbit = "SuperScoreboard"
				sd.nested = true
				sd:visible(false)
			else
			        CurrentSubTidbit = "LocalScoreboard"
				sd.nested = false
				sd:visible(true)
			end
			self:queuecommand("On")
			self:visible(true)
		else
			self:queuecommand("Off")
		end
	end,
	TabChangedMessageCommand = function(self, params)
		self:queuecommand("Set")
		-- if tab was already visible, swap nested tabs
		if params ~= nil and params.from == 2 and params.to == 2 and self:GetVisible() then
			if nestedTab == 1 then nestedTab = 2 else nestedTab = 1 end
			local sd = self:GetParent():GetChild("StepsDisplay")
			self:playcommand("NestedTabChanged")
			if nestedTab == 1 then
				ssmIsLocalScores = true
				self:GetChild("NetScores"):visible(false)
				self:GetChild("LocalScores"):visible(true)
				sd:visible(true)
			else
				ssmIsLocalScores = false
				updateLeaderBoardForCurrentChart()
				self:GetChild("NetScores"):visible(true)
				self:GetChild("LocalScores"):visible(false)
				sd:visible(false)
			end
		end
		updateLeaderBoardForCurrentChart()
	end,
	ChangeStepsMessageCommand = function(self)
		if getTabIndex() ~= 2 then return end
		self:playcommand("Set"):finishtweening()
		updateLeaderBoardForCurrentChart()
	end,
	DelayedChartUpdateMessageCommand = function(self)
		local leaderboardEnabled =
			playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).leaderboardEnabled and DLMAN:IsLoggedIn()
		if GAMESTATE:GetCurrentSteps() then
			local chartkey = GAMESTATE:GetCurrentSteps():GetChartKey()
			if leaderboardEnabled then
			DLMAN:RequestChartLeaderBoardFromOnline(
				chartkey,
				function(leaderboard)
					netScores:playcommand("SetFromLeaderboard", leaderboard)
				end
			)	-- this is also intentionally super bad so we actually do something about it -mina
			elseif (SCREENMAN:GetTopScreen():GetName() == "ScreenSelectMusic" or SCREENMAN:GetTopScreen():GetName() == "ScreenNetSelectMusic") and ((getTabIndex() == 2 and nestedTab == 2)) then
				DLMAN:RequestChartLeaderBoardFromOnline(
				chartkey,
				function(leaderboard)
					netScores:playcommand("SetFromLeaderboard", leaderboard)
				end
			)
			end
		end
	end,
	NestedTabChangedMessageCommand = function(self)
		self:queuecommand("Set")
		updateLeaderBoardForCurrentChart()
	end,
	CodeMessageCommand = function(self, params) -- this is intentionally bad to remind me to fix other things that are bad -mina
		if ((getTabIndex() == 2 and nestedTab == 2)) and DLMAN:GetCurrentRateFilter() then
			local rate = getCurRateValue()
			if params.Name == "PrevScore" and rate < 2.95 then
				GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate(rate + 0.1)
				GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate(rate + 0.1)
				GAMESTATE:GetSongOptionsObject("ModsLevel_Current"):MusicRate(rate + 0.1)
				MESSAGEMAN:Broadcast("CurrentRateChanged")
			elseif params.Name == "NextScore" and rate > 0.75 then
				GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate(rate - 0.1)
				GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate(rate - 0.1)
				GAMESTATE:GetSongOptionsObject("ModsLevel_Current"):MusicRate(rate - 0.1)
				MESSAGEMAN:Broadcast("CurrentRateChanged")
			end
			if params.Name == "PrevRate" and rate < 3 then
				GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate(rate + 0.05)
				GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate(rate + 0.05)
				GAMESTATE:GetSongOptionsObject("ModsLevel_Current"):MusicRate(rate + 0.05)
				MESSAGEMAN:Broadcast("CurrentRateChanged")
			elseif params.Name == "NextRate" and rate > 0.7 then
				GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate(rate - 0.05)
				GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate(rate - 0.05)
				GAMESTATE:GetSongOptionsObject("ModsLevel_Current"):MusicRate(rate - 0.05)
				MESSAGEMAN:Broadcast("CurrentRateChanged")
			end
		end
	end,
	CurrentRateChangedMessageCommand = function(self)
		if ((getTabIndex() == 2 and nestedTab == 2)) and DLMAN:GetCurrentRateFilter() then
			netScores:queuecommand("GetFilteredLeaderboard")
		end
	end,
	Def.Actor {
		Name = "InputBinding",
		BeginCommand = function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(input)
		end
	}
}

local t = Def.ActorFrame {
	Name = "LocalScores",
	InitCommand = function(self)
		rtTable = nil
		localScores = self
	end,
	OnCommand = function(self)
		if nestedTab == 1 and self:IsVisible() then
			if GAMESTATE:GetCurrentSong() ~= nil then
				rtTable = getRateTable()
				if rtTable ~= nil then
					rates, rateIndex = getUsedRates(rtTable)
					scoreIndex = 1
					self:queuecommand("Display")
				else
					self:queuecommand("Init")
				end
			else
				self:queuecommand("Init")
			end
		end
	end,
	NestedTabChangedMessageCommand = function(self)
		self:visible(nestedTab == 1)
		self:queuecommand("Set")
	end,
	CurrentStepsChangedMessageCommand = function(self)
		if getTabIndex() == 2 then
			self:playcommand("On")
			if rtTable == nil or #rtTable == 0 or rates == nil or #rates == 0 or rates[rateIndex] == nil or rtTable[rates[rateIndex]] == nil then
				return
			end
			self:playcommand("Display")
		end
	end,
	CodeMessageCommand = function(self, params)
		if nestedTab == 1 and rtTable ~= nil and rtTable[rates[rateIndex]] ~= nil then
			if params.Name == "NextRate" then
				self:queuecommand("NextRate")
			elseif params.Name == "PrevRate" then
				self:queuecommand("PrevRate")
			elseif params.Name == "NextScore" then
				self:queuecommand("NextScore")
			elseif params.Name == "PrevScore" then
				self:queuecommand("PrevScore")
			end
		end
	end,
	NextRateCommand = function(self)
		rateIndex = ((rateIndex) % (#rates)) + 1
		scoreIndex = 1
		self:queuecommand("Display")
	end,
	PrevRateCommand = function(self)
		rateIndex = ((rateIndex - 2) % (#rates)) + 1
		scoreIndex = 1
		self:queuecommand("Display")
	end,
	NextScoreCommand = function(self)
		scoreIndex = ((scoreIndex) % (#rtTable[rates[rateIndex]])) + 1
		self:queuecommand("Display")
	end,
	PrevScoreCommand = function(self)
		scoreIndex = ((scoreIndex - 2) % (#rtTable[rates[rateIndex]])) + 1
		self:queuecommand("Display")
	end,
	DisplayCommand = function(self)
		score = rtTable[rates[rateIndex]][scoreIndex]
		if getTabIndex() == 2 then
			hasReplayData = score:HasReplayData()
		else
			hasReplayData = false
		end
		setScoreForPlot(score)
	end,
	Def.Quad {
		Name = "FrameDisplay",
		InitCommand = function(self)
			self:zoomto(frameWidth, frameHeight):halign(0):valign(0):diffuse(getMainColor("tabs"))
		end,
	}
}

-- header bar
t[#t + 1] = Def.Quad {
	InitCommand = function(self)
		self:zoomto(frameWidth, offsetY):halign(0):valign(0):diffuse(getMainColor("frames")):diffusealpha(0.5)
	end
}

local l = Def.ActorFrame {
	-- stuff inside the frame.. so we can move it all at once
	InitCommand = function(self)
		self:xy(offsetX, offsetY + headeroffY)
	end,
	LoadFont("Common Large") .. {
		Name = "Grades",
		InitCommand = function(self)
			self:y(20):zoom(0.65):halign(0):maxwidth(60 / 0.65):settext("")
		end,
		DisplayCommand = function(self)
			self:settext(THEME:GetString("Grade", ToEnumShortString(score:GetWifeGrade())))
			self:diffuse(getGradeColor(score:GetWifeGrade()))
		end
	},
	-- Wife display
	LoadFont("Common Normal") .. {
		Name = "Wife",
		InitCommand = function(self)
			self:xy(65, 15):zoom(0.6):halign(0):settext("")
		end,
		DisplayCommand = function(self)
			if score:GetWifeScore() == 0 then
				self:settextf("NA")
			else
				local wv = score:GetWifeVers()
				local ws = "Wife" .. wv .. " J"
				local judge = 4
				if PREFSMAN:GetPreference("SortBySSRNormPercent") == false then
					judge = table.find(ms.JudgeScalers, notShit.round(score:GetJudgeScale(), 2))
				end
				if not judge then judge = 4 end
				if judge < 4 then judge = 4 end
				local js = judge ~= 9 and judge or "ustice"
				local perc = score:GetWifeScore() * 100
				if perc > 99.65 then
					self:settextf("%05.4f%% (%s)", notShit.floor(perc, 4), ws .. js)
				else
					self:settextf("%05.2f%% (%s)", notShit.floor(perc, 2), ws .. js)
				end
				self:diffuse(getGradeColor(score:GetWifeGrade()))
			end
		end
	},
	LoadFont("Common Normal") .. {
		Name = "Score",
		InitCommand = function(self)
			self:xy(65, 30):zoom(0.6):halign(0):settext("")
		end,
		DisplayCommand = function(self)
			if score:GetWifeScore() == 0 then
				self:settext("")
			else
				local overall = score:GetSkillsetSSR("Overall")
				self:settextf("%.2f", overall):diffuse(byMSD(overall))
			end
		end
	},
	LoadFont("Common Normal") .. {
		Name = "Score",
		InitCommand = function(self)
			self:xy(65, 43):zoom(0.5):halign(0):settext("")
		end,
		DisplayCommand = function(self)
			if score:GetWifeScore() == 0 then
				self:settext("")
			else
				local ss = GAMESTATE:GetCurrentSteps():GetRelevantSkillsetsByMSDRank(getCurRateValue(), 1)
				if ss ~= "" then
					self:settext(THEME:GetString("Skillsets", ss))
				else
					self:settext("")
				end
			end
		end
	},
	LoadFont("Common Normal") .. {
		Name = "ClearType",
		InitCommand = function(self)
			self:y(44):zoom(0.5):halign(0):settext(""):diffuse(color(colorConfig:get_data().clearType["NoPlay"]))
		end,
		DisplayCommand = function(self)
			self:settext(getClearTypeFromScore(pn, score, 0))
			self:diffuse(getClearTypeFromScore(pn, score, 2))
		end
	},
	LoadFont("Common Normal") .. {
		Name = "Mods",
		InitCommand = function(self)
			self:y(63):zoom(0.4):halign(0):maxwidth(capWideScale(690,1000))
			self:settextf("%s:", translated_info["Mods"]):settext("")
		end,
		DisplayCommand = function(self)
			self:settextf("%s: %s", translated_info["Mods"], getModifierTranslations(score:GetModifiers()))
		end
	},
	LoadFont("Common Normal") .. {
		Name = "Date",
		InitCommand = function(self)
			self:y(78):zoom(0.4):halign(0):settextf("%s:", translated_info["DateAchieved"]):settext("")
		end,
		DisplayCommand = function(self)
			self:settextf("%s: %s", translated_info["DateAchieved"], getScoreDate(score))
		end
	},
	LoadFont("Common Normal") .. {
		Name = "Combo",
		InitCommand = function(self)
			self:y(93):zoom(0.4):halign(0):settextf("%s:", translated_info["MaxCombo"]):settext("")
		end,
		DisplayCommand = function(self)
			self:settextf("%s: %d", translated_info["MaxCombo"], score:GetMaxCombo())
		end
	},
	LoadFont("Common Normal") .. {
		Name = "ComboBreaks",
		InitCommand = function(self)
			self:y(108):zoom(0.4):halign(0):settextf("%s:", translated_info["ComboBreaks"]):settext("")
		end,
		DisplayCommand = function(self)
			local comboBreaks = getScoreComboBreaks(score)
			if comboBreaks ~= nil then
				self:settextf("%s: %s", translated_info["ComboBreaks"], comboBreaks)
			else
				self:settextf("%s: -", translated_info["ComboBreaks"])
			end
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(frameWidth - offsetX - frameX, frameHeight - headeroffY - 15 - offsetY):zoom(0.5):halign(1)
			self:settext(translated_info["NoScores"])
		end,
		DisplayCommand = function(self)
			self:settextf("%s %s - %s %d/%d", translated_info["Rate"], rates[rateIndex], translated_info["Showing"], scoreIndex, #rtTable[rates[rateIndex]])
			self:zoom(0.4)
		end
	},
	LoadFont("Common Normal") .. {
		Name = "Judge",
		InitCommand = function(self)
			self:xy(frameX + offsetX + 55,frameHeight - headeroffY - 65 - offsetY):zoom(0.45):halign(0.5):settext("")
		end,
		DisplayCommand = function(self)
			local j = table.find(ms.JudgeScalers, notShit.round(score:GetJudgeScale(), 2))
			if not j then j = 4 end
			if j < 4 then j = 4 end
			self:settextf("%s %i", translated_info["Judge"], j)
		end
	},
	LoadFont("Common Normal") .. {
		Name = "ChordCohesion",
		InitCommand = function(self)
			self:xy(frameX + offsetX + 55,frameHeight - headeroffY - 50 - offsetY):zoom(0.4):halign(0.5):settext("")
		end,
		DisplayCommand = function(self)
			if score:GetChordCohesion() then
				self:settextf("%s: %s", translated_info["ChordCohesion"], translated_info["Yes"])
				self:diffuse(1,0,0,1)
			else
				self:settextf("%s: %s", translated_info["ChordCohesion"], translated_info["No"])
				self:diffuse(1,1,1,1)
			end
		end
	},
}

for i = 1, 10 do
	t[#t + 1] = makeRateText(i)
end

for i = 1, #judges do
	l[#l + 1] = makeJudge(i, judges[i])
end

t[#t + 1] = l

t[#t + 1] = Def.Quad {
	Name = "ScrollBar",
	InitCommand = function(self)
		self:x(frameWidth):zoomto(4, 0):halign(1):valign(1):diffuse(getMainColor("highlight")):diffusealpha(0.75)
	end,
	DisplayCommand = function(self)
		self:finishtweening()
		self:smooth(0.15)
		self:zoomy(((frameHeight - offsetY) / #rtTable[rates[rateIndex]]))
		self:y((((frameHeight - offsetY) / #rtTable[rates[rateIndex]]) * scoreIndex) + offsetY)
	end
}

ret[#ret + 1] = t

-- online score display
ret[#ret + 1] = LoadActor("../_superscoreboard")

-- nested tab counter
ret[#ret + 1] = LoadFont("Common Normal") .. {
	BeginCommand = function(self)
		self:xy(frameX + offsetX/2, frameY + offsetY - 4)
		self:diffuse(getMainColor("positive")):maxwidth(153-80):maxheight(40):zoom(0.65)
		self:settextf("(%d/%d)", nestedTab, #nestedTabs)
		self:align(0,1)
	end,
	NestedTabChangedMessageCommand = function(self)
		self:settextf("(%d/%d)", nestedTab, #nestedTabs)
	end
}

return ret
