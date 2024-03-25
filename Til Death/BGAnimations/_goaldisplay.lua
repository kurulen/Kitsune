local tzoom = 0.5
local pdh = 48 * tzoom
local ygap = 2
local packspaceY = pdh + ygap

-- "tip index", i.e. "current page"
local ti = 0
-- "sub index", i.e. "current score"
local si = 1

local numgoals = 12
local offx = 5
local width = SCREEN_WIDTH * 0.56
local dwidth = width - offx * 2
local height = (numgoals + 2) * packspaceY

local adjx = 10
local c0x = 20 -- for: priority and delete button
local c1x = c0x + 25 -- for: rate header, rate and percent
local c2x = c1x + (tzoom * 4 * adjx) -- for: song header and song name
local c5x = dwidth -- for: diff header, msd and steps diff
local c4x = c5x - adjx - (tzoom * 3.5 * adjx) -- for: date header, assigned, achieved
local c3x = c4x - adjx - (tzoom * 10 * adjx) -- for: filter header and song name
local headeroff = packspaceY / 1.5

local rateSort = false
local songSort = false
local dateSort = false
local diffSort = false

local cheese

-- will eat any mousewheel inputs to scroll pages while mouse is over the background frame
local function input(event)
   local isHoldingCtrl = INPUTFILTER:IsControlPressed()
   local isHoldingShift = INPUTFILTER:IsShiftPressed()
   if getTabIndex() == 5 then
      if (
	 (event.DeviceInput.button == "DeviceButton_1" and isHoldingCtrl and isHoldingShift)
      ) and (event.type == "InputEventType_FirstPress" or event.type == "InputEventType_Repeat") then
	 cheese:queuecommand("PrevPage")
	 return true
      elseif (
	 (event.DeviceInput.button == "DeviceButton_2" and isHoldingCtrl and isHoldingShift)
      ) and (event.type == "InputEventType_FirstPress" or event.type == "InputEventType_Repeat") then
	 cheese:queuecommand("NextPage")
	 return true
      elseif (
	 (event.DeviceInput.button == "DeviceButton_3" and isHoldingCtrl and isHoldingShift)
	 and (event.type == "InputEventType_FirstPress")
      ) then
	 local tgt = cheese:GetChild("DateHeader")
	 tgt:queuecommand("Activate")
	 return true
      elseif (
	 (event.DeviceInput.button == "DeviceButton_4" and isHoldingCtrl and isHoldingShift)
	 and (event.type == "InputEventType_FirstPress")
      ) then
	 local tgt = cheese:GetChild("DiffHeader")
	 tgt:queuecommand("Activate")
	 return true
      elseif (
	 (event.DeviceInput.button == "DeviceButton_5" and isHoldingCtrl and isHoldingShift)
      ) and (event.type == "InputEventType_FirstPress") then
	 local tgt = cheese:GetChild("GoalDisplay_"..si):GetChild("DeleteGoal_"..si)
	 tgt:queuecommand("Activate")
	 return true
      elseif (
	 (event.DeviceInput.button == "DeviceButton_1" and isHoldingCtrl)
      ) and (event.type == "InputEventType_FirstPress" or event.type == "InputEventType_Repeat") then
	 cheese:queuecommand("PrevGoal")
	 return true
      elseif (
	 (event.DeviceInput.button == "DeviceButton_2" and isHoldingCtrl)
      ) and (event.type == "InputEventType_FirstPress" or event.type == "InputEventType_Repeat") then
	 cheese:queuecommand("NextGoal")
	 return true
      elseif (
	 (event.DeviceInput.button == "DeviceButton_3" and isHoldingCtrl)
      ) and (event.type == "InputEventType_FirstPress") then
	 local tgt = cheese:GetChild("GoalDisplay_"..si):GetChild("GoalTeleport_"..si)
	 tgt:queuecommand("Activate")
	 return true
      elseif (
	 (event.DeviceInput.button == "DeviceButton_4" and isHoldingCtrl)
      ) and (event.type == "InputEventType_FirstPress") then
	 local tgt = cheese:GetChild("RateHeader")
	 tgt:queuecommand("Activate")
	 return true
      elseif (
	 (event.DeviceInput.button == "DeviceButton_5" and isHoldingCtrl)
      ) and (event.type == "InputEventType_FirstPress") then
	 local tgt = cheese:GetChild("SongHeader")
	 tgt:queuecommand("Activate")
	 return true
      end
   end
   return false
end

local hoverAlpha = 0.6

local function byAchieved(scoregoal, nocolor, yescolor)
	if not scoregoal or scoregoal:IsAchieved() then
		return yescolor or Saturation(getMainColor("enabled"), 0.55) end
	return nocolor or color("#aaaaaa")
end
local filts = {
	THEME:GetString("TabGoals", "FilterAll"),
	THEME:GetString("TabGoals", "FilterCompleted"),
	THEME:GetString("TabGoals", "FilterIncomplete")
}

local translated_info = {
	PriorityLong = THEME:GetString("TabGoals", "PriorityLong"),
	PriorityShort = THEME:GetString("TabGoals", "PriorityShort"),
	RateLong = THEME:GetString("TabGoals", "RateLong"),
	RateShort = THEME:GetString("TabGoals", "RateShort"),
	Song = THEME:GetString("TabGoals", "Song"),
	Date = THEME:GetString("TabGoals", "Date"),
	Difficulty = THEME:GetString("TabGoals", "Difficulty"),
	Best = THEME:GetString("TabGoals", "Best"),
	Assigned = THEME:GetString("TabGoals", "AssignedDate"),
	Achieved = THEME:GetString("TabGoals", "AchievedDate"),
	Vacuous = THEME:GetString("TabGoals", "VacuousGoal"),
}

local goaltable
local o = Def.ActorFrame {
	Name = "GoalDisplay",
	InitCommand = function(self)
		cheese = self
		self:xy(0, 0)
	end,
	BeginCommand = function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(input)
	end,
	OnCommand = function(self)
		GetPlayerOrMachineProfile(PLAYER_1):SetFromAll()
		self:queuecommand("GoalTableRefresh")
	end,
	GoalTableRefreshMessageCommand = function(self)
		goaltable = GetPlayerOrMachineProfile(PLAYER_1):GetGoalTable()
		ti = 0
		self:queuecommand("Update")
	end,
	UpdateCommand = function(self)
		if ti == #goaltable then
			ti = ti - numgoals
		elseif ti > #goaltable - (#goaltable % numgoals) then
			ti = #goaltable - (#goaltable % numgoals)
		end
		if ti < 0 then
			ti = 0
		end
	end,
	DFRFinishedMessageCommand = function(self)
		GetPlayerOrMachineProfile(PLAYER_1):SetFromAll()
		self:queuecommand("GoalTableRefresh")
	end,
	NextPageCommand = function(self)
		ti = ti + numgoals
		self:queuecommand("Update")
	end,
	PrevPageCommand = function(self)
		ti = ti - numgoals
		self:queuecommand("Update")
	end,
	NextGoalCommand = function(self)
		si = si + 1
		if si > numgoals then
			si = 1
			self:queuecommand("NextPage")
		else
			self:queuecommand("Update")
		end
	end,
	PrevGoalCommand = function(self)
		si = si - 1
		if si < 1 then
			if ti == 0 then
				si = 1
			else
				si = numgoals
			end
			self:queuecommand("PrevPage")
		else
			self:queuecommand("Update")
		end
	end,
	Def.Quad {
		Name = "FrameDisplay",
		InitCommand = function(self)
			self:zoomto(width, height - headeroff):halign(0):valign(0):diffuse(getMainColor("tabs"))
		end
	},
	-- headers
	Def.Quad {
		InitCommand = function(self)
			self:xy(offx, headeroff):zoomto(dwidth, pdh):halign(0):diffuse(getMainColor("frames"))
		end
	},
	LoadFont("Common normal") .. {
		--index header
		InitCommand = function(self)
			self:xy(width / 2, headeroff):zoom(tzoom):halign(0.5)
		end,
		UpdateCommand = function(self)
			self:settextf("%i-%i (%i)", ti + 1, ti + numgoals, #goaltable)
		end
	},
	LoadFont("Common normal") .. {
	   Name="PriorityHeader",
	   --priority header
		InitCommand = function(self)
			self:xy(c0x, headeroff):zoom(tzoom):halign(0.5)
			self:diffuse(getMainColor("positive"))
		end,
		UpdateCommand = function(self)
			self:settext(translated_info["PriorityShort"])
		end,
	},
	LoadFont("Common normal") .. {
	   --rate header
	   Name = "RateHeader",
		InitCommand = function(self)
			self:xy(c1x, headeroff):zoom(tzoom):halign(0.5):settext(translated_info["RateLong"])
			self:diffuse(getMainColor("positive"))
		end,
		ActivateCommand = function(self)
		   ti = 0
		   rateSort = not rateSort
		   GetPlayerOrMachineProfile(PLAYER_1):SortByRate()
		   self:GetParent():queuecommand("GoalTableRefresh")
		   if rateSort == true then
		      self:diffuse(getMainColor("highlight"))
		   else
		      songSort = false
		      dateSort = false
		      diffSort = false
		      GetPlayerOrMachineProfile(PLAYER_1):SetFromAll()
		      self:queuecommand("GoalTableRefresh")
		      self:diffuse(getMainColor("positive"))
		   end
		end
	},
	LoadFont("Common normal") .. {
	   Name = "SongHeader",
	   --song header
		InitCommand = function(self)
			self:xy(c2x, headeroff):zoom(tzoom):halign(0):settext(translated_info["Song"])
			self:diffuse(getMainColor("positive"))
		end,
		ActivateCommand = function(self)
		   ti = 0
		   songSort = not songSort
		   GetPlayerOrMachineProfile(PLAYER_1):SortByName()
		   self:GetParent():queuecommand("GoalTableRefresh")
		   if songSort == true then
		      self:diffuse(getMainColor("highlight"))
		   else
		      dateSort = false
		      diffSort = false
		      rateSort = false
		      GetPlayerOrMachineProfile(PLAYER_1):SetFromAll()
		      self:queuecommand("GoalTableRefresh")
		      self:diffuse(getMainColor("positive"))
		   end
		end
	},
	LoadFont("Common normal") .. {
	   Name = "DateHeader",
	   --date header
		InitCommand = function(self)
			self:xy(c4x - capWideScale(5, 35), headeroff):zoom(tzoom):halign(1):settext(translated_info["Date"])
			self:diffuse(getMainColor("positive"))
		end,
		ActivateCommand = function(self)
		   ti = 0
		   dateSort = not dateSort
		   GetPlayerOrMachineProfile(PLAYER_1):SortByDate()
		   self:GetParent():queuecommand("GoalTableRefresh")
		   if dateSort == true then
		      self:diffuse(getMainColor("highlight"))
		   else
		      diffSort = false
		      songSort = false
		      rateSort = false
		      GetPlayerOrMachineProfile(PLAYER_1):SetFromAll()
		      self:queuecommand("GoalTableRefresh")
		      self:diffuse(getMainColor("positive"))
		   end
		end
	},
	LoadFont("Common normal") .. {
	   --diff header
	   Name = "DiffHeader",
		InitCommand = function(self)
			self:xy(c5x, headeroff):zoom(tzoom):halign(1):settext(translated_info["Difficulty"])
			self:diffuse(getMainColor("positive"))
		end,
		ActivateCommand = function(self)
		   ti = 0
		   diffSort = not diffSort
		   GetPlayerOrMachineProfile(PLAYER_1):SortByDiff()
		   self:GetParent():queuecommand("GoalTableRefresh")
		   if diffSort == true then
		      self:diffuse(getMainColor("highlight"))
		   else
		      dateSort = false
		      songSort = false
		      rateSort = false
		      GetPlayerOrMachineProfile(PLAYER_1):SetFromAll()
		      self:queuecommand("GoalTableRefresh")
		      self:diffuse(getMainColor("positive"))
		   end
		end
	}
}

local function makeGoalDisplay(i)
	local sg
	local ck
	local goalsong
	local goalsteps

	local o = Def.ActorFrame {
	   Name = "GoalDisplay_"..i,
		InitCommand = function(self)
			self:y(packspaceY * i + headeroff)
		end,
		UpdateCommand = function(self)
			sg = goaltable[(i + ti)]
			if sg then
				ck = sg:GetChartKey()
				goalsong = SONGMAN:GetSongByChartKey(ck)
				goalsteps = SONGMAN:GetStepsByChartKey(ck)
				self:queuecommand("Display")
				self:visible(true)
			else
				self:visible(false)
			end
		end,
		Def.Quad {
		   Name = "GoalBG_"..i,
			InitCommand = function(self)
				self:x(offx):zoomto(dwidth, pdh):halign(0)
			end,
			DisplayCommand = function(self)
			   if self:GetName() == "GoalBG_"..si then
			      self:diffuse(color("#444444D9"))
			      self:diffusealpha(1)
			   else
			      self:diffuse(color("#111111D9"))
			      self:diffusealpha(0.8)
			   end
			end
		},
		LoadFont("Common normal") .. {
		   Name = "PriorityControl_"..i,
			--priority
			InitCommand = function(self)
				self:x(c0x):zoom(tzoom):halign(0.5):valign(1)
			end,
			DisplayCommand = function(self)
				self:settext(sg:GetPriority())
				self:diffuse(byAchieved(sg, getMainColor("positive"),Color.White))
			end,
			ActivateCommand = function(self, params)
				if params.up and sg then
					sg:SetPriority(sg:GetPriority() + 1)
					self:GetParent():queuecommand("Update")
				elseif params.down and sg then
					sg:SetPriority(sg:GetPriority() - 1)
					self:GetParent():queuecommand("Update")
				end
			end,
		},
		LoadFont("Common normal") .. {
		   Name = "DeleteGoal_"..i,
			-- delete button
			InitCommand = function(self)
				self:xy(c0x - 13,pdh/2.3):zoom(0.3):halign(0):valign(1):settext("X"):diffuse(Color.Red)
			end,
			ActivateCommand = function(self)
			   sg:Delete()
			   GetPlayerOrMachineProfile(PLAYER_1):SetFromAll()
			   self:GetParent():GetParent():queuecommand("GoalTableRefresh")
			end
		},
		LoadFont("Common normal") .. {
		   Name = "RateControl_"..i,
			--rate
			InitCommand = function(self)
				self:x(c1x):zoom(tzoom):halign(0.5):valign(1)
			end,
			DisplayCommand = function(self)
				local ratestring = string.format("%.2f", sg:GetRate()):gsub("%.?0$", "") .. "x"
				self:settext(ratestring)
				self:diffuse(byAchieved(sg, getMainColor("positive")))
			end,
			ActivateCommand = function(self, params)
				if params.up and sg then
					sg:SetRate(sg:GetRate() + 0.1)
					self:GetParent():queuecommand("Update")
				elseif params.down and sg then
					sg:SetRate(sg:GetRate() - 0.1)
					self:GetParent():queuecommand("Update")
				end
			end,
		},
		LoadFont("Common normal") .. {
		   Name = "PercentControl_"..i,
			--percent
			InitCommand = function(self)
				self:x(c1x):zoom(tzoom):halign(0.5):valign(0):maxwidth((50 - capWideScale(10, 10)) / tzoom)
			end,
			DisplayCommand = function(self)
				local perc = notShit.round(sg:GetPercent() * 100000) / 1000
				if perc <= 99 or perc == 100 then
					self:settextf("%.f%%", perc)
				elseif (perc < 99.8) then
					self:settextf("%.2f%%", perc)
				else
					self:settextf("%.3f%%", perc)
				end
				self:diffuse(byAchieved(sg, getMainColor("positive")))
			end,
			ActivateCommand = function(self, params)
				if params.up and sg then
					sg:SetPercent(sg:GetPercent() + 0.01)
					self:GetParent():queuecommand("Update")
				elseif params.down and sg then
					sg:SetPercent(sg:GetPercent() - 0.01)
					self:GetParent():queuecommand("Update")
				end
			end,
		},
		LoadFont("Common normal") .. {
		   Name = "GoalTeleport_"..i,
			--song name
			InitCommand = function(self)
				self:x(c2x):zoom(tzoom):maxwidth((c3x - c2x - capWideScale(32, 62)) / tzoom):halign(0):valign(1):draworder(1)
			end,
			DisplayCommand = function(self)
				if goalsong then
					self:settext(goalsong:GetDisplayMainTitle()):diffuse(getMainColor("positive"))
				else
					self:settext(sg:GetChartKey()):diffuse(getMainColor("negative"))
				end
			end,
			ActivateCommand = function(self)
				if sg ~= nil and goalsong and goalsteps then
					local success = SCREENMAN:GetTopScreen():GetMusicWheel():SelectSong(goalsong)
					if success then
						GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate(sg:GetRate())
						GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate(sg:GetRate())
						GAMESTATE:GetSongOptionsObject("ModsLevel_Current"):MusicRate(sg:GetRate())
						MESSAGEMAN:Broadcast("GoalSelected")
					end
				end
			end
		},
		LoadFont("Common normal") .. {
			--pb
			InitCommand = function(self)
				self:x(c2x):zoom(tzoom):halign(0):valign(0)
			end,
			DisplayCommand = function(self)
				local pb = sg:GetPBUpTo()
				if pb then
					local pbwife = pb:GetWifeScore() * 100
					local pbstr = ""
					if pbwife > 99.65 then
						pbstr = string.format("%05.4f%%", notShit.floor(pbwife, 4))
					else
						pbstr = string.format("%05.2f%%", notShit.floor(pbwife, 2))
					end
					if pb:GetMusicRate() < sg:GetRate() then
						local ratestring = string.format("%.2f", pb:GetMusicRate()):gsub("%.?0$", "") .. "x"
						self:settextf("%s: %s (%s)", translated_info["Best"], pbstr, ratestring)
					else
						self:settextf("%s: %s", translated_info["Best"], pbstr)
					end
					self:diffuse(getGradeColor(pb:GetWifeGrade()))
					self:visible(true)
				else
					self:settextf("(%s: %5.2f%%)", translated_info["Best"], 0)
					self:diffuse(byAchieved(sg))
				end
			end
		},
		LoadFont("Common normal") .. {
			--assigned
			InitCommand = function(self)
				self:x(c4x):zoom(tzoom):halign(1):valign(0):maxwidth(width / 4 / tzoom)
			end,
			DisplayCommand = function(self)
				self:settextf("%s: %s", translated_info["Assigned"], sg:WhenAssigned()):diffuse(byAchieved(sg))
			end
		},
		LoadFont("Common normal") .. {
			--achieved
			InitCommand = function(self)
				self:x(c4x):zoom(tzoom):halign(1):valign(1):maxwidth(width / 4 / tzoom)
			end,
			DisplayCommand = function(self)
				if sg:IsAchieved() then
					self:settextf("%s: %s", translated_info["Achieved"], sg:WhenAchieved())
				elseif sg:IsVacuous() then
					self:settext(translated_info["Vacuous"])
				else
					self:settext("")
				end
				self:diffuse(byAchieved(sg))
			end
		},
		LoadFont("Common normal") .. {
			--msd diff
			InitCommand = function(self)
				self:x(c5x):zoom(tzoom):halign(1):valign(1)
			end,
			DisplayCommand = function(self)
				if goalsteps then
					local msd = goalsteps:GetMSD(sg:GetRate(), 1)
					self:settextf("%5.1f", msd):diffuse(byMSD(msd))
				else
					self:settext("??")
				end
			end
		},
		LoadFont("Common normal") .. {
			--steps diff
			InitCommand = function(self)
				self:x(c5x):zoom(tzoom):halign(1):valign(0)
			end,
			DisplayCommand = function(self)
				if goalsteps and goalsong then
					local diff = goalsteps:GetDifficulty()
					self:settext(getShortDifficulty(diff))
					self:diffuse(getDifficultyColor(diff))
				else
					self:settext("??")
					self:diffuse(getMainColor("negative"))
				end
			end
		},
	}
	return o
end

for i = 1, numgoals do
	o[#o + 1] = makeGoalDisplay(i)
end

return o
