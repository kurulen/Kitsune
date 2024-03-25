
local hoverAlpha = 0.6

local t = Def.ActorFrame {}

local frameWidth = 280
local frameHeight = 20
local frameX = SCREEN_WIDTH - 5
local frameY = 15

local sortTable = {
	SortOrder_Group = THEME:GetString("SortOrder", "Group"),
	SortOrder_Title = THEME:GetString("SortOrder", "Title"),
	SortOrder_BPM = THEME:GetString("SortOrder", "BPM"),
	SortOrder_TopGrades = THEME:GetString("SortOrder", "TopGrades"),
	SortOrder_Artist = THEME:GetString("SortOrder", "Artist"),
	SortOrder_Genre = THEME:GetString("SortOrder", "Genre"),
	SortOrder_ModeMenu = THEME:GetString("SortOrder", "ModeMenu"),
	SortOrder_Length = THEME:GetString("SortOrder", "Length"),
	SortOrder_Favorites = THEME:GetString("SortOrder", "Favorites"),
	SortOrder_Overall = THEME:GetString("SortOrder", "Overall"),
	SortOrder_Stream = THEME:GetString("SortOrder", "Stream"),
	SortOrder_Jumpstream = THEME:GetString("SortOrder", "Jumpstream"),
	SortOrder_Handstream = THEME:GetString("SortOrder", "Handstream"),
	SortOrder_Stamina = THEME:GetString("SortOrder", "Stamina"),
	SortOrder_JackSpeed = THEME:GetString("SortOrder", "JackSpeed"),
	SortOrder_Chordjack = THEME:GetString("SortOrder", "Chordjack"),
	SortOrder_Technical = THEME:GetString("SortOrder", "Technical"),
	SortOrder_Ungrouped = THEME:GetString("SortOrder", "Ungrouped")
}

local translated_info = TranslationMatrices["SortOrder"]

local group = ""
local lastrandom
local lastlastrandom

local function input(event)
   if group ~= "" and event.DeviceInput.button == "DeviceButton_F10" and INPUTFILTER:IsControlPressed() then
      local w = SCREENMAN:GetTopScreen():GetMusicWheel()
      
      if INPUTFILTER:IsShiftPressed() and lastlastrandom ~= nil then
	 
	 -- if the last random song wasnt filtered out, we can select it
	 -- so end early after jumping to it
	 if w:SelectSong(self.lastlastrandom) then
	    return
	 end
	 -- otherwise, just pick a new random song
      end
      
      local t = w:GetSongsInGroup(group)
      if #t == 0 then return end
      local random_song = t[math.random(#t)]
      w:SelectSong(random_song)
      lastlastrandom = lastrandom
      lastrandom = random_song
      return true
   end
   return false
end

t[#t + 1] = LoadFont("Common Large") .. {
	Name="rando",
	InitCommand = function(self)
		self:xy(frameX, frameY + 5):halign(1):zoom(0.55):maxwidth((frameWidth - 40) / 0.35)
	end,
	BeginCommand = function(self)
		self:queuecommand("Set")
		SCREENMAN:GetTopScreen():AddInputCallback(input)
	end,
	SetCommand = function(self)
	        collectgarbage()
		local sort = GAMESTATE:GetSortOrder()
		local song = GAMESTATE:GetCurrentSong()
		if sort == nil then
			self:settextf("%s: ", translated_info["Sort"])
		elseif sort == "SortOrder_Group" and song ~= nil then
			group = song:GetGroupName()
			lamp = GetPackLampFromGroup(group, true)
			local tier
			if lamp ~= nil then
			   if lamp < 10 then
			      tier = "0"..tostring(lamp)
			   else
			      tier = tostring(lamp)
			   end
			end
			self:settext(group .. (lamp ~= nil and " ["..LampEnum[lamp].."]" or "") )
			self:diffuse(tier ~= nil and getGradeColor("Grade_Tier"..tier) or getMainColor("positive"))
		else
			self:settextf("%s: %s", translated_info["Sort"], sortTable[sort])
			self:diffuse(getMainColor("positive"))
			group = ""
		end
	end,
	SortOrderChangedMessageCommand = function(self)
		self:queuecommand("Set"):diffuse(getMainColor("positive"))
	end,
	CurrentSongChangedMessageCommand = function(self)
		self:playcommand("Set")
	end,
}

t[#t + 1] = StandardDecorationFromFileOptional("BPMDisplay", "BPMDisplay")
t[#t + 1] = StandardDecorationFromFileOptional("BPMLabel", "BPMLabel")

return t
