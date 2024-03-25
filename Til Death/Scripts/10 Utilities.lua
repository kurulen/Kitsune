ShortDiffToDiffLUT = {
   ["BG"] = "Difficulty_Beginner",
   ["EZ"] = "Difficulty_Easy",
   ["NM"] = "Difficulty_Medium",
   ["HD"] = "Difficulty_Hard",
   ["IN"] = "Difficulty_Challenge",
   ["ED"] = "Difficulty_Edit",
}

DiffToShortDiffLUT = {
   ["Difficulty_Beginner"] = "BG",
   ["Difficulty_Easy"] = "EZ",
   ["Difficulty_Medium"] = "NM",
   ["Difficulty_Hard"] = "HD",
   ["Difficulty_Challenge"] = "IN",
   ["Difficulty_Edit"] = "ED",
}

ShortDiffToFancyLUT = {
   ["BG"] = "Beginner",
   ["EZ"] = "Easy",
   ["NM"] = "Medium",
   ["HD"] = "Hard",
   ["IN"] = "Insane",
   ["ED"] = "Edit",
}

LampEnum = {
   [1] = "AAAAA",
   [2] = "AAAA",
   [3] = "AAAA",
   [4] = "AAAA",
   [5] = "AAA",
   [6] = "AAA",
   [7] = "AAA",
   [8] = "AA",
   [9] = "AA",
   [10] = "AA",
   [11] = "A",
   [12] = "A",
   [13] = "A",
   [14] = "Clear",
   [15] = "Clear",
   [16] = "Clear",
   [99] = "",
}

function simpleGetMSD(steps)
   return steps:GetMSD(getCurRateValue(), 1)
end

function sleep(time)
   local curtime = os.time()
   while os.time() - curtime <= time do end
end

-- i can be as inefficient as i want, you're not my dad
function GetStepsFromChartKey(ck)
   local songs = SONGMAN:GetAllSongs()
   for _, x in ipairs(songs) do
      for _, y in ipairs(x:GetAllSteps()) do
	 if y:GetChartKey() == ck then
	    return y
	 end
      end
   end
   return nil
end

local function GetBestGradeForSong(song)
    local gradeTier = 99
    for _, chart in ipairs(song:GetAllSteps()) do
       local scorestack = SCOREMAN:GetScoresByKey(chart:GetChartKey())
       -- scorestack is nil if no scores on the chart
       if scorestack ~= nil then
	  -- the scores are in lists for each rate
	  -- find the highest
	  for _, l in pairs(scorestack) do
	     local scoresatrate = l:GetScores()
	     for _, s in ipairs(scoresatrate) do
		local gt = tostring(s:GetGrade())
		local gtNum
		if (gt ~= "Grade_Failed") and (gt ~= "NUM_Grade") and (gt ~= "Grade_Invalid") then 
		   gtNum = tonumber(gt:sub(-2, -1))
		   gradeTier = math.min(gradeTier, gtNum)
		end
	     end
	  end
       end
    end
    return gradeTier
end

function SecondsToVagueHours(secs)
   return notShit.round(secs * 0.0002777778, 2)
end

function GroupLowerToUpper(group)
   local groups = SONGMAN:GetSongGroupNames()
   for _, v in ipairs(groups) do
      if string.lower(v) == group then
	 return v
      end
   end
   return nil
end

function GetLineCount(text)
   local ret = split("\n", text)
   return #ret
end

function GetPackLampFromGroup(group, ugly)
   local songs = SONGMAN:GetSongsInGroup(group)
   local grades = {}
   local lamp = 99
   if songs then
      for _, x in ipairs(songs) do
	 grades[#grades+1] = GetBestGradeForSong(x)
      end
      if grades ~= {} then
	 if #grades ~= #songs then
	    return nil
	 end
	 for _, g in ipairs(grades) do
	    if (g < 17) then 
	       lamp = math.min(lamp, g)
	    else
	       return nil
	    end
	 end
	 if ugly then
	    return lamp
	 else
	    return LampEnum[lamp]
	 end
      end
   end
   return nil
end

function GetDifficultyNameFromSteps(steps, long)
   local ret = tostring(steps:GetDifficulty())
   if not ret or ret == "" then ret = "Difficulty_Edit" end
   if long then return ret else
      return DiffToShortDiffLUT[ret]
   end
end

function TimeToSeconds(timestr)
   local factors = {60 * 60 * 24, 60 * 60, 60, 1}
   local components = {}
   local stat, _ = pcall(function(str)
	 local _ = tonumber(str)
   end, timestr)
   if stat == true then
      return tonumber(timestr)
   end
   for v in string.gmatch(timestr, "%d+") do
      components[#components+1] = tonumber(v)
   end
   if #components > #factors then
      return nil
   end
   local ret = 0
   local clamp = #factors - #components
   for i, v in ipairs(components) do
      ret = ret + (v * factors[clamp+i])
   end
   return ret
end

function easyInputStringWithParams(question, maxLength, isPassword, funcOK, params)
	SCREENMAN:AddNewScreenToTop("ScreenTextEntry")
	local settings = {
		Question = question,
		MaxInputLength = maxLength,
		Password = isPassword,
		OnOK = function(answer)
			funcOK(answer, params)
		end
	}
	SCREENMAN:GetTopScreen():Load(settings)
end

function setnewdisplayname(answer)
	if answer ~= "" then
		local profile = PROFILEMAN:GetProfile(PLAYER_1)
		profile:RenameProfile(answer)
		profileName = answer
		MESSAGEMAN:Broadcast("ProfileRenamed", {doot = answer})
	end
end

function easyInputStringWithFunction(question, maxLength, isPassword, func)
	easyInputStringWithParams(
		question,
		maxLength,
		isPassword,
		function(answer, params)
			func(answer)
		end,
		{}
	)
end

--Tables are passed by reference right? So the value is tablewithvalue to pass it by ref
function easyInputString(question, maxLength, isPassword, tablewithvalue)
	easyInputStringWithParams(
		question,
		maxLength,
		isPassword,
		function(answer, params)
			tablewithvalue.inputString = answer
		end,
		{}
	)
end

function easyInputStringOKCancel(question, maxLength, isPassword, funcOK, funcCancel)
	SCREENMAN:AddNewScreenToTop("ScreenTextEntry")
	local settings = {
		Question = question,
		MaxInputLength = maxLength,
		Password = isPassword,
		OnOK = function(answer)
			funcOK(answer)
		end,
		OnCancel = function()
			funcCancel()
		end,
	}
	SCREENMAN:GetTopScreen():Load(settings)
end

function table:sliceArray(alpha, omega)
	local function oob(input, target)
		return ((input > target) and true or false)
	end
	local function nilCheck(obj)
		if obj ~= nil then return true else return false end
	end
	if nilCheck(omega) then if oob(omega, #self) then return nil end end
	if oob(alpha, #self) then return nil end

	local ret = {}
	for i = alpha, (nilCheck(omega) and omega or #self) do
		ret[#ret+1] = self[i]
	end

	return ret
end

function table:popSliceArray(alpha, omega)
	local sliced = self:sliceArray(alpha, omega)

	if #sliced == #self then
		return sliced, nil
	end

	local ret = self:sliceArray(omega+1)

	return sliced, ret
end
