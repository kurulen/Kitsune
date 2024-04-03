local searchstring = ""
local frameX = 10
local frameY = 300
local active = false
local errored = false
local whee
local lastsearchstring = ""

local SCHEMA = {
   ["msd"] = 1,
   ["stream"] = 2,
   ["jumpstream"] = 3,
   ["handstream"] = 4,
   ["stamina"] = 5,
   ["jackspeed"] = 6,
   ["chordjack"] = 7,
   ["technical"] = 8,
   ["title"] = 9,
   ["subtitle"] = 10,
   ["stepartist"] = 11,
   ["artist"] = 12,
   ["length"] = 13,
}
local SUBTAGS = {
   ["="] = 1,
   ["=="] = 1,
   [">="] = 2,
   [">"] = 2,
   ["<="] = 3,
   ["<"] = 3,
}

local function search(wheel, query)
   if query == "" then 
      return {}
   end

   local qtable = split(",", query)
   local filters = {}
   local steps = {}
   local songs = {}
   local cdts = {}

   local curFilterOp
   local curFilterSub
   local curFilterTgt
   
   for _, x in ipairs(SONGMAN:GetAllSongs()) do
      local allsteps = x:GetAllSteps()
      for _, y in ipairs(allsteps) do
	 songs[y] = x
	 steps[#steps+1] = y
      end
   end

   for _, x in ipairs(qtable) do
      for y, _ in pairs(SUBTAGS) do
	 local stx, edx = string.find(x, y)
	 if stx and edx then
	    curFilterOp = string.sub(x, 1, stx-1)
	    curFilterSub = string.sub(x, stx, edx)
	    curFilterTgt = string.sub(x, edx+1)
	    break
	 end
      end
      if (not curFilterOp) and (not curFilterSub) and (not curFilterTgt) then
	 filters[#filters+1] = {"title", "==", x}
      else
	 filters[#filters+1] = {curFilterOp, curFilterSub, curFilterTgt}
      end
      curFilterOp, curFilterSub, curFilterTgt = nil, nil, nil
   end

   for _, x in ipairs(filters) do
      for _, y in ipairs(steps) do
	 local opcode = SCHEMA[x[1]]
	 local subtag = SUBTAGS[x[2]]
	 local target = x[3]

	 -- if opcode is 1-8, then we want to filter MSD
	 if opcode < 9 then
	    target = tonumber(target)
	    local msd = math.floor(y:GetMSD(getCurRateValue(), opcode))
	    -- unavoidable yanderedev coding style
	    if msd == target and subtag == 1 then
	       cdts[#cdts+1] = y
	    elseif msd >= target and subtag == 2 then
	       cdts[#cdts+1] = y
	    elseif msd <= target and subtag == 3 then
	       cdts[#cdts+1] = y
	    end
	 -- if opcode is 9 or greater, then we want to filter chart metadata
	 else
	    -- if we want the title, subtitle, stepartist, or artist,
	    --   then using >= or <= is unreasonable, obviously
	    if opcode >= 9 and opcode <= 12 then
	       local matcher = function(opcode, songs, cdts, translit)
		  local various
		  if opcode == 9 then various = (translit and songs[y]:GetTranslitMainTitle() or songs[y]:GetDisplayMainTitle()) end
		  if opcode == 10 then various = (translit and songs[y]:GetTranslitSubTitle() or songs[y]:GetDisplaySubTitle()) end
		  if opcode == 11 then various = songs[y]:GetOrTryAtLeastToGetSimfileAuthor() end
		  if opcode == 12 then various = (translit and songs[y]:GetTranslitArtist() or songs[y]:GetDisplayArtist()) end
		  if not various then various = "" end
		  if string.match(string.lower(various), target..".*") then
		     cdts[#cdts+1] = y
		     return true, songs, cdts
		  else
		     return false, songs, cdts
		  end
	       end
	       result, songs, cdts = matcher(opcode, songs, cdts, false)
	       if result == false then
		  result, songs, cdts = matcher(opcode, songs, cdts, true)
	       end
	    elseif opcode == 13 then
	       -- length filter
	       local length = math.floor(songs[y]:MusicLengthSeconds())
	       local timetgt = TimeToSeconds(target)
	       if timetgt then
		  if length == timetgt and opcode == 1 then
		     cdts[#cdts+1] = y
		  elseif length >= timetgt and opcode == 2 then
		     cdts[#cdts+1] = y
		  elseif length <= timetgt and opcode == 3 then
		     cdts[#cdts+1] = y
		  end
	       end
	    end
	 end
      end
      steps = cdts
      cdts = {}
   end

   cdts = {}
   for _, x in ipairs(steps) do
      cdts[#cdts+1] = x:GetChartKey()
   end
   steps = cdts

   return steps
end

local function searchInput(event)
   if lastsearchstring ~= searchstring then
      MESSAGEMAN:Broadcast("UpdateString")
      lastsearchstring = searchstring
   end
   if event.type == "InputEventType_FirstPress" and active == true then
      if event.button == "Back" or (event.button == "Start" and INPUTFILTER:IsControlPressed()) then
	 local tind = getTabIndex()
	 searchstring = ""
	 whee:FilterByStepKeys({})
	 resetTabIndex(0)
	 MESSAGEMAN:Broadcast("TabChanged", {from = tind, to = 0})
	 MESSAGEMAN:Broadcast("EndingSearch")
	 return false
      elseif event.button == "Start" then
	 local tind = getTabIndex()
	 local stat, _ = pcall(function(whee, searchstring)
	       local cks = search(whee, searchstring)
	       whee:FilterByStepKeys({})
	       resetTabIndex(0)
	       whee:FilterByStepKeys(cks)
	 end, whee, searchstring)
	 if stat == false then
	    searchstring = "Error!"
	    errored = true
	 end
	 MESSAGEMAN:Broadcast("TabChanged", {from = tind, to = 0})
	 MESSAGEMAN:Broadcast("EndingSearch")
	 return false
      elseif event.DeviceInput.button == "DeviceButton_space" then -- add space to the string
	 if errored then
	    searchstring = ""
	    errored = false
	 end
	 searchstring = searchstring .. " "
	 return false
      elseif event.DeviceInput.button == "DeviceButton_backspace" then
	 if errored then
	    searchstring = ""
	    errored = false
	 end
	 searchstring = searchstring:sub(1, -2) -- remove the last element of the string
	 return false
      elseif event.DeviceInput.button == "DeviceButton_v" and INPUTFILTER:IsControlPressed() then
	 searchstring = searchstring .. Arch.getClipboard()
	 return false
      elseif errored then
	 searchstring = ""
	 errored = false
	 return false
      elseif event.char and event.char:match('[%%%+%-%!%@%#%$%^%&%*%(%)%=%_%.%,%:%;%\'%"%>%<%?%/%~%|%w%[%]%{%}%`%\\]') then
	 searchstring = searchstring .. event.char
	 return false
      end
   end
end

local translated_info = TranslationMatrices["SongSearch"]

local t =
	Def.ActorFrame {
	BeginCommand = function(self)
		self:visible(false)
		self:queuecommand("Set")
		whee = SCREENMAN:GetTopScreen():GetMusicWheel()
		SCREENMAN:GetTopScreen():AddInputCallback(searchInput)
	end,
	OffCommand = function(self)
		self:bouncebegin(0.2):xy(-500, 0):diffusealpha(0)
		self:sleep(0.04):queuecommand("Invis")
	end,
	InvisCommand= function(self)
		self:visible(false)
	end,
	OnCommand = function(self)
		self:bouncebegin(0.2):xy(0, 0):diffusealpha(1)
	end,
	SetCommand = function(self)
		self:finishtweening()
		if getTabIndex() == 3 then
		        CurrentSubTidbit = ""
			MESSAGEMAN:Broadcast("BeginningSearch")
			self:visible(true)
			self:queuecommand("On")
			active = true
			whee:Move(0)
			SCREENMAN:set_input_redirected(PLAYER_1, true)
			MESSAGEMAN:Broadcast("RefreshSearchResults")
		else
			self:queuecommand("Off")
			active = false
			SCREENMAN:set_input_redirected(PLAYER_1, false)
		end
	end,
	TabChangedMessageCommand = function(self)
		self:queuecommand("Set")
	end,
	LoadFont("Common Large") ..
		{
			InitCommand = function(self)
				self:xy(frameX + 250 - capWideScale(get43size(95), 10), frameY - 93):zoom(0.7):halign(0.5):maxwidth(470)
			end,
			SetCommand = function(self)
				if active then
					self:settextf("%s:", translated_info["Active"])
					self:diffuse(getGradeColor("Grade_Tier10"))
				elseif not active and searchstring ~= "" then
					self:settext(translated_info["Complete"])
					self:diffuse(getGradeColor("Grade_Tier04"))
				else
					self:settext("")
				end
			end,
			UpdateStringMessageCommand = function(self)
				self:queuecommand("Set")
			end
		},
	Def.Quad {
		InitCommand = function(self)
			self:xy(frameX - capWideScale(3.5,-3.5), frameY - 46):zoomto(capWideScale(362.5,472), 44):align(0,0.5):diffuse(getMainColor("tabs"))
		end,
	},
	LoadFont("Common Large") ..
		{
			InitCommand = function(self)
				self:xy(frameX + 250 - capWideScale(get43size(95), 10), frameY - 50):zoom(0.7)
				self:halign(0.5):maxwidth(capWideScale(500,650))
			end,
			SetCommand = function(self)
				self:settext(searchstring)
			end,
			UpdateStringMessageCommand = function(self)
				self:queuecommand("Set")
			end
		},
	LoadFont("Common Large") ..
		{
			InitCommand = function(self)
				self:xy(frameX + 20, frameY - 200):zoom(0.4):halign(0)
				self:settext(translated_info["ExplainStart"])
			end
		},
	LoadFont("Common Large") ..
		{
			InitCommand = function(self)
				self:xy(frameX + 20, frameY - 175):zoom(0.4):halign(0)
				self:settext(translated_info["ExplainBack"])
			end
		},
	LoadFont("Common Normal") ..
		{
			InitCommand = function(self)
				self:xy(frameX + 20, frameY + 40):zoom(0.4):halign(0)
				self:settext(translated_info["ExplainTags"])
			end
		},
}

return t
