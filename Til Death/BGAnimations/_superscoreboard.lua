local tzoom = 0.5
local pdh = 48 * tzoom
local ygap = 2
local packspaceY = pdh + ygap
local currentCountry = "Global"

local numscores = 13

-- "tip index", i.e. "current page"
local ti = 0
-- "sub index", i.e. "current score"
local si = 1

local offx = 5
local width = SCREEN_WIDTH * 0.56
local dwidth = width - offx * 2
local height = (numscores + 2) * packspaceY - packspaceY / 3 -- account dumbly for header being moved up

local adjx = 14
local c0x = 10
local c1x = 20 + c0x
local c2x = c1x + (tzoom * 7 * adjx) -- guesswork adjustment for epxected text length
local c5x = dwidth -- right aligned cols
local c4x = c5x - adjx - (tzoom * 3 * adjx) -- right aligned cols
local c3x = c4x - adjx - (tzoom * 10 * adjx) -- right aligned cols

local headeroff = packspaceY / 2
local row2yoff = 1
local netScores

local hoverAlpha = 0.6

local isGlobalRanking = true

local translated_info = TranslationMatrices["ScoreBoard"]

local scoretable = {}

local function input(event)
	local isHoldingCtrl = INPUTFILTER:IsControlPressed()
	local isHoldingShift = INPUTFILTER:IsShiftPressed()
	if ssmIsLocalScores == false and getTabIndex() == 2 then
		if (
			(event.DeviceInput.button == "DeviceButton_1" and isHoldingCtrl and isHoldingShift)
		) and (event.type == "InputEventType_FirstPress" or event.type == "InputEventType_Repeat") then
			netScores:queuecommand("PrevPage")
			return true
		elseif (
			(event.DeviceInput.button == "DeviceButton_2" and isHoldingCtrl and isHoldingShift)
		) and (event.type == "InputEventType_FirstPress" or event.type == "InputEventType_Repeat") then
			netScores:queuecommand("NextPage")
			return true
		elseif (
			(event.DeviceInput.button == "DeviceButton_1" and isHoldingCtrl)
		) and (event.type == "InputEventType_FirstPress" or event.type == "InputEventType_Repeat") then
			netScores:queuecommand("PrevScore")
			return true
		elseif (
			(event.DeviceInput.button == "DeviceButton_2" and isHoldingCtrl)
		) and (event.type == "InputEventType_FirstPress" or event.type == "InputEventType_Repeat") then
			netScores:queuecommand("NextScore")
			return true
		elseif (
			(event.DeviceInput.button == "DeviceButton_3" and isHoldingCtrl and isHoldingShift)
		) and event.type == "InputEventType_FirstPress" then
			local sd = netScores:GetChild("SubNetScore_"..si):GetChild("UserName")
			sd:queuecommand("TakeMeToThePromisedLand")
			return true
		elseif (
			(event.DeviceInput.button == "DeviceButton_4" and isHoldingCtrl and isHoldingShift)
		) and event.type == "InputEventType_FirstPress" then
			local sd = netScores:GetChild("SubNetScore_"..si):GetChild("ScoreName")
			sd:queuecommand("TakeMeToThePromisedLand")
			return true
		elseif (
			(event.DeviceInput.button == "DeviceButton_5" and isHoldingCtrl and isHoldingShift)
		) and event.type == "InputEventType_FirstPress" then
			local sd = netScores:GetChild("SubNetScore_"..si):GetChild("Replay")
			sd:queuecommand("TakeMeToThePromisedLand")
			return true
		elseif (
			(event.DeviceInput.button == "DeviceButton_3" and isHoldingCtrl)
		) and event.type == "InputEventType_FirstPress" then
			local sd = netScores:GetChild("ScoreToggle")
			sd:queuecommand("TakeMeToThePromisedLand")
			return true
		elseif (
			(event.DeviceInput.button == "DeviceButton_4" and isHoldingCtrl)
		) and event.type == "InputEventType_FirstPress" then
			local sd = netScores:GetChild("ValidateToggle")
			sd:queuecommand("TakeMeToThePromisedLand")
			return true
		elseif (
			(event.DeviceInput.button == "DeviceButton_5" and isHoldingCtrl)
		) and event.type == "InputEventType_FirstPress" then
			local sd = netScores:GetChild("RateToggle")
			sd:queuecommand("TakeMeToThePromisedLand")
			return true
		elseif (
			(event.DeviceInput.button == "DeviceButton_space" and isHoldingCtrl and isHoldingShift)
		) and event.type == "InputEventType_FirstPress" then
			local sd = netScores:GetChild("SubNetScore_"..si):GetChild("PlotShow")
			sd:queuecommand("TakeMeToThePromisedLand")
			return true
		end
	end
	return false
end

local o = Def.ActorFrame {
	Name = "NetScores",
	InitCommand = function(self)
		netScores = self
	end,
	BeginCommand = function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(input)
		self:playcommand("Update")
	end,
	GetFilteredLeaderboardCommand = function(self)
		if GAMESTATE:GetCurrentSong() then
			scoretable = DLMAN:GetChartLeaderBoard(GAMESTATE:GetCurrentSteps():GetChartKey(), currentCountry)
			ti = 0
			self:playcommand("Update")
		end
	end,
	SetFromLeaderboardCommand = function(self, lb)
		scoretable = lb
		ti = 0
		self:playcommand("GetFilteredLeaderboard") -- we can move all the filter stuff to lua so we're not being dumb hurr hur -mina
		self:playcommand("Update")
	end,
	UpdateCommand = function(self)
		if not scoretable then
			ti = 0
			return
		end
		if ti == #scoretable then
			ti = ti - numscores
		elseif ti > #scoretable - (#scoretable % numscores) then
			ti = #scoretable - (#scoretable % numscores)
		end
		if ti < 0 then
			ti = 0
		end
	end,
	NextPageCommand = function(self)
		ti = ti + numscores
		self:queuecommand("Update")
	end,
	PrevPageCommand = function(self)
		ti = ti - numscores
		self:queuecommand("Update")
	end,
	NextScoreCommand = function(self)
		si = si + 1
		if si > numscores then
			si = 1
			self:queuecommand("NextPage")
		else
			self:queuecommand("Update")
		end
	end,
	PrevScoreCommand = function(self)
		si = si - 1
		if si < 1 then
			if ti == 0 then
				si = 1
			else
				si = numscores
			end
			self:queuecommand("PrevPage")
		else
			self:queuecommand("Update")
		end
	end,

	-- header
	Def.Quad {
		Name = "HeaderBar",
		InitCommand = function(self)
			self:zoomto(width, pdh - 8 * tzoom):halign(0):diffuse(getMainColor("frames")):diffusealpha(0.5):valign(0)
		end
	},
	Def.Quad {
		Name = "Frame",
		InitCommand = function(self)
			self:zoomto(width, height - headeroff):halign(0):valign(0):diffuse(getMainColor("tabs"))
		end,
	},
	-- Error / progress messages for when the scoreboard isn't populated.
	LoadFont("Common normal") .. {
		-- informational text about online scores
		Name = "RequestStatus",
		InitCommand = function(self)
			self:xy(c1x, headeroff + 25):zoom(tzoom):halign(0)
		end,
		UpdateCommand = function(self)
			local numberofscores = scoretable ~= nil and #scoretable or 0
			local online = DLMAN:IsLoggedIn()
			if not GAMESTATE:GetCurrentSong() then
				self:settext("")
			elseif not online and scoretable ~= nil and #scoretable == 0 then
				self:settext(translated_info["LoginToView"])
			else
				if scoretable ~= nil and #scoretable == 0 then
					self:settext(translated_info["NoScoresFound"])
				elseif scoretable == nil then
					self:settext("Chart is not ranked")
				else
					self:settext("")
				end
			end
		end,
		CurrentSongChangedMessageCommand = function(self)
			local online = DLMAN:IsLoggedIn()
			if not GAMESTATE:GetCurrentSong() then
				self:settext("")
			elseif not online and scoretable ~= nil and #scoretable == 0 then
				self:settext(translated_info["LoginToView"])
			elseif scoretable == nil then
				self:settext("Chart is not ranked")
			else
				self:settext(translated_info["NoScoresFound"])
			end
		end
	},

	LoadFont("Common Normal") .. {
		Name="RateToggle",
		--current rate toggle
		InitCommand = function(self)
			self:xy(c5x, headeroff):zoom(tzoom):halign(1):valign(1)
			self:diffuse(getMainColor("positive"))
		end,
		UpdateCommand = function(self)
			if DLMAN:GetCurrentRateFilter() then
				self:settext(translated_info["FilterCurrent"])
			else
				self:settext(translated_info["FilterAll"])
			end
		end,
		TakeMeToThePromisedLandCommand = function(self)
			DLMAN:ToggleRateFilter()
			ti = 0
			self:GetParent():queuecommand("GetFilteredLeaderboard")
		end
	},
	LoadFont("Common Normal") .. {
		Name="ScoreToggle",
		--top score/all score toggle
		InitCommand = function(self)
			self:diffuse(getMainColor("positive"))
			self:xy(c5x - capWideScale(160,190), headeroff):zoom(tzoom):halign(1):valign(1)
		end,
		UpdateCommand = function(self)
			if DLMAN:GetTopScoresOnlyFilter() then
				self:settext(translated_info["TopScoresOnly"])
			else
				self:settext(translated_info["AllScores"])
			end
		end,
		TakeMeToThePromisedLandCommand = function(self)
			DLMAN:ToggleTopScoresOnlyFilter()
			ti = 0
			self:GetParent():queuecommand("GetFilteredLeaderboard")
		end
	},
	LoadFont("Common Normal") .. {
		Name="ValidateToggle",
		--ccon/off filter toggle
		InitCommand = function(self)
			self:diffuse(getMainColor("positive"))
			self:visible(true)
			self:xy(c5x - capWideScale(80,96), headeroff):zoom(tzoom):halign(1):valign(1)
		end,
		UpdateCommand = function(self)
			if DLMAN:GetCCFilter() then
				self:settext(translated_info["InvalidatedScoresOn"])
			else
				self:settext(translated_info["InvalidatedScoresOff"])
			end
		end,
		TakeMeToThePromisedLandCommand = function(self)
			DLMAN:ToggleCCFilter()
			ti = 0
			self:GetParent():queuecommand("GetFilteredLeaderboard")
		end
	}
}

local function makeSubNetScore(i)
	local hs

	local o = Def.ActorFrame {
		Name = "SubNetScore_"..i,
		InitCommand = function(self)
			self:y(packspaceY * i + headeroff)
			if i > numscores or hs == nil then
				self:visible(false)
			else
				self:visible(true)
			end
		end,
		CurrentSongChangedMessageCommand = function(self)
			self:visible(false)
		end,
		UpdateCommand = function(self)
			if scoretable ~= nil then
				hs = scoretable[(i + ti)]
			else
				hs = nil
			end
			if hs and i <= numscores then
				self:visible(true)
				self:playcommand("Display")
			else
				self:visible(false)
			end
		end,
		Def.Quad {
			Name="ScoreBG_"..i,
			InitCommand = function(self)
				self:x(offx):zoomto(dwidth, pdh):halign(0)
			end,
			DisplayCommand = function(self)
				self:diffuse(color("#111111CC"))
				self:diffusealpha(0.8)
			end,
			UpdateCommand = function(self)
				if self:GetName() == "ScoreBG_"..si then
					self:diffuse(color("#444444CC"))
					self:diffusealpha(1)
				end
			end
		},
		-- Score labels
		LoadFont("Common normal") .. {
			--rank
			InitCommand = function(self)
				self:x(c0x):zoom(tzoom):halign(0):valign(0)
			end,
			DisplayCommand = function(self)
				self:settextf("%i.", i + ti)
			end
		},
		LoadFont("Common normal") .. {
			--ssr
			InitCommand = function(self)
				self:x(c2x - c1x + offx):zoom(tzoom + 0.05):halign(0.5):valign(1)
			end,
			DisplayCommand = function(self)
				local ssr = hs:GetSkillsetSSR("Overall")
				self:settextf("%.2f", ssr):diffuse(byMSD(ssr))
			end
		},
		LoadFont("Common normal") .. {
			--rate
			InitCommand = function(self)
				self:x(c2x - c1x + offx):zoom(tzoom - 0.05):halign(0.5):valign(0):addy(row2yoff)
			end,
			DisplayCommand = function(self)
				local ratestring = string.format("%.2f", hs:GetMusicRate()):gsub("%.?0$", "") .. "x"
				self:settext(ratestring)
			end,
		},
		LoadFont("Common Normal") .. {
			Name = "UserName",
			InitCommand = function(self)
				self:x(c2x):zoom(tzoom + 0.1):maxwidth((c3x - c2x - capWideScale(10, 40)) / tzoom):halign(0):valign(1)
			end,
			DisplayCommand = function(self)
				self:settext(hs:GetDisplayName())
				if hs:GetChordCohesion() then
					self:diffuse(color("#F0EEA6"))
				else
					self:diffuse(getMainColor("positive"))
				end
			end,
			TakeMeToThePromisedLandCommand = function(self)
				local urlstringyo = "https://etternaonline.com/user/" .. hs:GetDisplayName()
				GAMESTATE:ApplyGameCommand("urlnoexit," .. urlstringyo)
			end
		},
		LoadFont("Common Normal") .. {
			Name = "ScoreName",
			InitCommand = function(self)
				self:x(c2x):zoom(tzoom - 0.05):halign(0):valign(0):maxwidth(width / 2 / tzoom):addy(row2yoff)
			end,
			DisplayCommand = function(self)
				self:settext(hs:GetJudgmentString())
				if hs:GetChordCohesion() then
					self:diffuse(color("#F0EEA6"))
				else
					self:diffuse(getMainColor("positive"))
				end
			end,
			TakeMeToThePromisedLandCommand = function(self)
				local urlstringyo = "https://etternaonline.com/score/view/" .. hs:GetScoreid() .. hs:GetUserid()
				GAMESTATE:ApplyGameCommand("urlnoexit," .. urlstringyo)
			end,
		},
		LoadFont("Common Normal") .. {
			Name = "Replay",
			InitCommand = function(self)
				self:x(capWideScale(c3x + 52, c3x)):zoom(tzoom - 0.05):halign(1):valign(0):maxwidth(width / 2 / tzoom):addy(
					row2yoff
				):diffuse(getMainColor("enabled"))
			end,
			BeginCommand = function(self)
				if SCREENMAN:GetTopScreen():GetName() == "ScreenNetSelectMusic" then
					self:visible(false)
				end
			end,
			DisplayCommand = function(self)
				if GAMESTATE:GetCurrentSteps() then
					if hs:HasReplayData() then
						self:settext(translated_info["Watch"])
					else
						self:settext("")
					end
				end
			end,
			TakeMeToThePromisedLandCommand = function(self)
				if hs then
					DLMAN:RequestOnlineScoreReplayData(
						hs,
						function()
							SCREENMAN:GetTopScreen():PlayReplay(hs)
						end
					)
				end
			end,
		},
		Def.Actor {
			Name = "PlotShow",
			TakeMeToThePromisedLandCommand = function(self)
				if hs then
					if SCREENMAN:GetTopScreen():GetName() == "ScreenNetSelectMusic" then return end
					if hs:HasReplayData() then
						DLMAN:RequestOnlineScoreReplayData(
							hs,
							function()
								setScoreForPlot(hs)
								SCREENMAN:AddNewScreenToTop("ScreenScoreTabOffsetPlot")
							end
						)
					end
				end
			end
		},
		LoadFont("Common normal") .. {
			--percent
			Name="NormalText",
			InitCommand = function(self)
				self:x(c5x):zoom(tzoom + 0.15):halign(1):valign(1)
			end,
			DisplayCommand = function(self)
				self:settextf("%05.2f%%", notShit.floor(hs:GetWifeScore() * 100, 2)):diffuse(getGradeColor(hs:GetWifeGrade()))
			end
		},
		LoadFont("Common normal") .. {
			--percent
			Name="LongerText",
			InitCommand = function(self)
				self:x(c5x):zoom(tzoom + 0.15):halign(1):valign(1)
				self:visible(false)
			end,
			DisplayCommand = function(self)
				local perc = hs:GetWifeScore() * 100
				if perc > 99.7 then
					self:settextf("%05.5f%%", notShit.floor(perc, 5))
				else
					self:settextf("%05.4f%%", notShit.floor(perc, 4))
				end
				self:diffuse(getGradeColor(hs:GetWifeGrade()))
			end
		},
		LoadFont("Common normal") .. {
			--date
			InitCommand = function(self)
				self:x(c5x):zoom(tzoom - 0.05):halign(1):valign(0):maxwidth(width / 4 / tzoom):addy(row2yoff)
			end,
			DisplayCommand = function(self)
				if IsUsingWideScreen() then
					self:settext(hs:GetDate())
				else
					self:settext(hs:GetDate():sub(1, 10))
				end
			end,
			CollapseCommand = function(self)
				self:visible(false)
			end,
			ExpandCommand = function(self)
				self:visible(true):addy(-row2yoff)
			end
		}
	}
	return o
end

for i = 1, numscores do
	o[#o + 1] = makeSubNetScore(i)
end

local ccs = DLMAN:GetCountryCodes()
--Trace("" .. Serialize(ccs))

return o
