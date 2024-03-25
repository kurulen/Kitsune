if IsSMOnlineLoggedIn() then
	CloseConnection()
end

local currentlyPlayingSomething = false
local musicSong = nil
local musicTitle = ""
local musicLength = ""
local musicLengthRaw = 0.0

-- pleeeasepleasePLEASE poco do not strip this out in 73.0 -kurulen
local lastPlay = nil
local lastUpdate = os.time()

local playingMusic = {}
local playingMusicCounter = 1
local gameneedsupdating = false

local latest = tonumber((DLMAN:GetLastVersion():gsub("[.]", "", 1)))
local current = tonumber((GAMESTATE:GetEtternaVersion():gsub("[.]", "", 1)))

local frameX = THEME:GetMetric("ScreenTitleMenu", "ScrollerX") - 10
local frameY = THEME:GetMetric("ScreenTitleMenu", "ScrollerY")

local function updateProgressBar(self)
	if currentlyPlayingSomething then
		lastUpdate = os.time()
		local jb = self:GetChild("JukeboxProgress")
		local jbt = self:GetChild("JukeboxProgressTime")

		-- lastUpdate should be reasonably accurate to the current second. -kurulen
		local progDiff = (lastPlay + math.floor(musicLengthRaw)) - lastUpdate
		local progRatio = progDiff / math.floor(musicLengthRaw)
		jb:cropright(progRatio)

		jbt:settext(SecondsToMMSS(math.abs(((lastPlay + math.floor(musicLengthRaw)) - lastUpdate) - math.floor(musicLengthRaw))))
	end
end

local function ctrlBinds(event)
        RunLoops(event)
	local CtrlPressed = INPUTFILTER:IsControlPressed()
	if event.type == "InputEventType_FirstPress" then
		if event.DeviceInput.button == "DeviceButton_space" then
			local function startSong()
				currentlyPlayingSomething = true
				local sngs = SONGMAN:GetAllSongs()
				if #sngs == 0 then ms.ok("No songs to play") return end

				local s = sngs[math.random(#sngs)]
				local p = s:GetMusicPath()
				local l = s:MusicLengthSeconds()
				local top = SCREENMAN:GetTopScreen()

				local thisSong = playingMusicCounter
				playingMusic[thisSong] = true

				SOUND:StopMusic()
				SOUND:PlayMusicPart(p, 0, l)

				musicSong = s
				musicTitle = s:GetMainTitle()
				musicLength = SecondsToMMSS(l)
				musicLengthRaw = l
				lastUpdate = os.time()
				lastPlay = os.time()

				MESSAGEMAN:Broadcast("StartedPlayingMenuMusic", {song = musicSong})
				ms.ok("You put a coin in the jukebox.")

				top:setTimeout(
					function()
						if not playingMusic[thisSong] then return end
						playingMusicCounter = playingMusicCounter + 1
						startSong()
					end,
					l
				)

			end

			SCREENMAN:GetTopScreen():setTimeout(function()
					if not currentlyPlayingSomething then
						playingMusic[playingMusicCounter] = false
						playingMusicCounter = playingMusicCounter + 1
						startSong()
					else
						currentlyPlayingSomething = false
						lastUpdate = os.time()
						MESSAGEMAN:Broadcast("StoppedPlayingMenuMusic")
						SOUND:StopMusic()
						playingMusic = {}
						playingMusicCounter = playingMusicCounter + 1
						ms.ok("The jukebox runs out of coins.")
					end
				end,
			0.1)
		elseif event.DeviceInput.button == "DeviceButton_F1" then
		   ShowingHelp = not ShowingHelp
		   MESSAGEMAN:Broadcast((ShowingHelp == true and "Show" or "Hide").."KBHelps")
		end
	end
end

local t = Def.ActorFrame {
	BeginCommand = function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(ctrlBinds)
		MESSAGEMAN:Broadcast("StoppedPlayingMenuMusic")
		self:SetUpdateFunction(updateProgressBar)
		if latest and latest > current then
			gameneedsupdating = true
		end
	end
}

--Left gray rectangle
t[#t + 1] = Def.Quad {
	InitCommand = function(self)
		self:xy(0, 0):halign(0):valign(0):zoomto(250, 900):diffuse(getTitleColor('BG_Left')):diffusealpha(1)
	end,
	StartedPlayingMenuMusicMessageCommand = function(self)
	   self:linear(0.08):diffusealpha(0.9)
	end,
	StoppedPlayingMenuMusicMessageCommand = function(self)
	   self:linear(0.08):diffusealpha(1)
	end
}

--Right gray rectangle
t[#t + 1] = Def.Quad {
	InitCommand = function(self)
		self:xy(250, 0):halign(0):valign(0):zoomto(1000, 900):diffuse(getTitleColor('BG_Right')):diffusealpha(1)
	end,
	StartedPlayingMenuMusicMessageCommand = function(self)
	   self:linear(0.08):diffusealpha(0.9)
	end,
	StoppedPlayingMenuMusicMessageCommand = function(self)
	   self:linear(0.08):diffusealpha(1)
	end
}

--Light purple line
t[#t + 1] = Def.Quad {
	InitCommand = function(self)
		self:xy(235, 0):halign(0):valign(0):zoomto(10, 900):diffuse(getTitleColor('Line_Left')):diffusealpha(1)
	end
}

--Dark purple line
t[#t + 1] = Def.Quad {
	InitCommand = function(self)
		self:xy(245, 0):halign(0):valign(0):zoomto(10, 900):diffuse(getTitleColor('Line_Right')):diffusealpha(1)
	end
}

--Theme logo
t[#t + 1] = Def.ActorFrame {
	BeginCommand=function(self)
		self:xy(125,frameY-82):zoom(0.7):align(0.5,1)
		self:diffuse(getMainColor("positive"))
	end,
	Def.Quad {
	   InitCommand=function(self)
	      self:zoomto(15,2)
	      self:addx(-15)
	      self:addy(-15)
	      self:addrotationz(8)
	   end
	},
	Def.Quad {
	   InitCommand=function(self)
	      self:zoomto(15,2)
	      self:addx(15)
	      self:addy(-15)
	      self:addrotationz(-8)
	   end
	},
	LoadFont("Common normal") .. {
	   InitCommand=function(self)
	      self:zoom(1)
	      self:settext("w")
	   end
	}
}

--Theme version
t[#t + 1] = LoadFont("Common Large") .. {
	InitCommand=function(self)
		self:xy(125,frameY-52):zoom(0.325):align(0.5,1)
		self:diffuse(getMainColor("positive"))
	end,
	OnCommand=function(self)
		self:settext("v"..getThemeVersion())
	end
}

--Version number
t[#t + 1] = LoadFont("Common Large") .. {
	Name = "Version",
	InitCommand=function(self)
		self:xy(125,frameY-35):zoom(0.25):align(0.5,1)
		self:diffuse(getMainColor("positive"))
	end,
	BeginCommand = function(self)
		self:settext("Etterna v"..GAMESTATE:GetEtternaVersion())
	end
}

-- Update nag text
t[#t + 1] = LoadFont("Common Large") .. {
	OnCommand = function(self)
		self:xy(12, SCREEN_HEIGHT-84):align(0,0):zoom(0.25):diffuse(getMainColor("positive"))
		if gameneedsupdating then
			self:settext(string.format(THEME:GetString("ScreenTitleMenu", "UpdateAvailable"), latest))
		else
			self:settext("")
		end
	end
}

-- Jukebox track title
t[#t + 1] = LoadFont("Common Large") .. {
	BeginCommand=function(self)
		self:xy(284, SCREEN_HEIGHT-23):align(0,0):zoom(0.25):diffuse(getMainColor("positive"))
		self:maxwidth(512)
		self:diffusealpha(0)
	end,
	StoppedPlayingMenuMusicMessageCommand=function(self)
		self:settext("")
		self:diffusealpha(0)
	end,
	StartedPlayingMenuMusicMessageCommand=function(self)
		if musicTitle == "" then
			self:settext("No title")
		else
			self:settext(musicTitle)
		end
		self:diffusealpha(1)
	end
}

-- Jukebox progress bottom (static)
t[#t + 1] = Def.Quad {
	BeginCommand=function(self)
		self:xy(SCREEN_WIDTH-capWideScale(220,400), SCREEN_HEIGHT-21):align(0,0):zoomto(capWideScale(160,290),8):diffuse(getTitleColor("Line_Right"))
		self:diffusealpha(0)
	end,
	StoppedPlayingMenuMusicMessageCommand=function(self)
		self:diffusealpha(0)
	end,
	StartedPlayingMenuMusicMessageCommand=function(self)
		self:diffusealpha(1)
	end
}

-- Jukebox progress top (sliding)
t[#t + 1] = Def.Quad {
	Name="JukeboxProgress",
	BeginCommand=function(self)
		self:xy(SCREEN_WIDTH-capWideScale(220,400), SCREEN_HEIGHT-21):align(0,0):zoomto(capWideScale(160,290),8):diffuse(getTitleColor("Line_Left"))
		self:diffusealpha(0)
	end,
	StoppedPlayingMenuMusicMessageCommand=function(self)
		self:diffusealpha(0)
	end,
	StartedPlayingMenuMusicMessageCommand=function(self)
		self:diffusealpha(1)
	end
}

-- Jukebox length
t[#t + 1] = LoadFont("Common Large") .. {
	BeginCommand=function(self)
		self:xy(SCREEN_WIDTH-48, SCREEN_HEIGHT-23):align(0,0):zoom(0.25):diffuse(getMainColor("positive"))
		self:diffusealpha(0)
	end,
	StoppedPlayingMenuMusicMessageCommand=function(self)
		self:settext("")
		self:diffusealpha(0)
	end,
	StartedPlayingMenuMusicMessageCommand=function(self)
		self:settext(musicLength)
		self:diffusealpha(1)
	end
}

-- Jukebox progress time
t[#t + 1] = LoadFont("Common Large") .. {
	Name = "JukeboxProgressTime",
	BeginCommand=function(self)
		self:xy(SCREEN_WIDTH-48, SCREEN_HEIGHT-46):align(0,0):zoom(0.25):diffuse(getMainColor("positive"))
		self:diffusealpha(0)
	end,
	StoppedPlayingMenuMusicMessageCommand=function(self)
		self:settext("")
		self:diffusealpha(0)
	end,
	StartedPlayingMenuMusicMessageCommand=function(self)
		self:settext(SecondsToMMSS(((lastPlay + math.floor(musicLengthRaw)) - lastUpdate) - math.floor(musicLengthRaw)))
		self:diffusealpha(1)
	end
}

return t
