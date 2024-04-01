-- TODO: add actual BMS-like progress bar
-- TODO: add back the leaderboard.. for multi

-- (hacky) globals for splitting off gameplay elements
tDiff = 0
pbtarget = false
curMeanSum = 0
curMeanCount = 0
wifey = 0
jdgct = 0
jdgCur = nil
dvCur = nil

isReplay = GAMESTATE:GetPlayerState():GetPlayerController() == "PlayerController_Replay"

local allowedCustomization = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomizeGameplay
local practiceMode = GAMESTATE:IsPracticeMode()

local translated_info = TranslationMatrices["WifeJudgmentSpotting"]

-- Screenwide params
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
isCentered = PREFSMAN:GetPreference("Center1Player")
local CenterX = SCREEN_CENTER_X
local mpOffset = 0
if not isCentered then
	CenterX =
		THEME:GetMetric(
		"ScreenGameplay",
		string.format("PlayerP1%sX", ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType()))
	)
	mpOffset = SCREEN_CENTER_X
end
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--

local screen  -- the screen after it is loaded

local WIDESCREENWHY = -5
local WIDESCREENWHX = -5

--receptor/Notefield things
local Notefield
local noteColumns
local usingReverse

local function spaceNotefieldCols(inc)
	if inc == nil then inc = 0 end
	local hCols = math.floor(#noteColumns/2)
	for i, col in ipairs(noteColumns) do
	    col:addx((i-hCols-1) * inc)
	end
end

--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
								     **Wife deviance tracker. Basically half the point of the theme.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	For every doot there is an equal and opposite scoot.
]]
local t =
	Def.ActorFrame {
	Name = "WifePerch",
	OnCommand = function(self)
		if allowedCustomization and SCREENMAN:GetTopScreen():GetName() ~= "ScreenGameplaySyncMachine" then
			-- auto enable autoplay
			GAMESTATE:SetAutoplay(true)
		else
			GAMESTATE:SetAutoplay(false)
		end
		-- Discord thingies
		updateDiscordStatus(false)

		-- now playing thing for streamers
		updateNowPlaying()

		screen = SCREENMAN:GetTopScreen()
		usingReverse = GAMESTATE:GetPlayerState():GetCurrentPlayerOptions():UsingReverse()
		Notefield = screen:GetChild("PlayerP1"):GetChild("NoteField")
		Notefield:addy(MovableValues.NotefieldY * (usingReverse and 1 or -1))
		Notefield:addx(MovableValues.NotefieldX)
		noteColumns = Notefield:get_column_actors()
		-- lifebar stuff
		local lifebar = SCREENMAN:GetTopScreen():GetLifeMeter(PLAYER_1)

		if (allowedCustomization) then
			Movable.pressed = false
			Movable.current = "None"
			Movable.DeviceButton_r.element = Notefield
			Movable.DeviceButton_t.element = noteColumns
			Movable.DeviceButton_r.condition = true
			Movable.DeviceButton_t.condition = true
			Movable.DeviceButton_j.element = lifebar
			Movable.DeviceButton_j.condition = true
			Movable.DeviceButton_k.element = lifebar
			Movable.DeviceButton_k.condition = true
			Movable.DeviceButton_l.element = lifebar
			Movable.DeviceButton_l.condition = true
			Movable.DeviceButton_n.condition = true
			Movable.DeviceButton_n.DeviceButton_up.arbitraryFunction = spaceNotefieldCols
			Movable.DeviceButton_n.DeviceButton_down.arbitraryFunction = spaceNotefieldCols
		end

		if lifebar ~= nil then
			lifebar:zoomtowidth(MovableValues.LifeP1Width)
			lifebar:zoomtoheight(MovableValues.LifeP1Height)
			lifebar:xy(MovableValues.LifeP1X, MovableValues.LifeP1Y)
			lifebar:rotationz(MovableValues.LifeP1Rotation)
		end

		for i, actor in ipairs(noteColumns) do
			actor:zoomtowidth(MovableValues.NotefieldWidth)
			actor:zoomtoheight(MovableValues.NotefieldHeight)
		end

		spaceNotefieldCols(MovableValues.NotefieldSpacing)

		self:diffusealpha(0.75)
	end,
	DoneLoadingNextSongMessageCommand = function(self)
		-- put notefield y pos back on doneloadingnextsong because playlist courses reset this for w.e reason -mina
		screen = SCREENMAN:GetTopScreen()

		-- nil checks are needed because these don't exist when doneloadingnextsong is sent initially
		-- which is convenient for us since addy -mina
		if screen ~= nil and screen:GetChild("PlayerP1") ~= nil then
			Notefield = screen:GetChild("PlayerP1"):GetChild("NoteField")
			Notefield:addy(MovableValues.NotefieldY * (usingReverse and 1 or -1))
		end
		-- update all stats in gameplay (as if it was a reset) when loading a new song
		-- particularly for playlists
		self:playcommand("PracticeModeReset")
	end,
	JudgmentMessageCommand = function(self, msg)
		tDiff = msg.WifeDifferential
		wifey = notShit.floor(msg.WifePercent * 100) / 100
		jdgct = msg.Val
		if msg.Offset ~= nil then
			dvCur = msg.Offset
			if not msg.HoldNoteScore and msg.Offset < 1000 then
				curMeanSum = curMeanSum + msg.Offset
				curMeanCount = curMeanCount + 1
			end
		else
			dvCur = nil
		end
		if msg.WifePBGoal ~= nil and targetTrackerMode ~= 0 then
			pbtarget = msg.WifePBGoal
			tDiff = msg.WifePBDifferential
		end
		jdgCur = msg.Judgment
		self:playcommand("SpottedOffset")
	end,
	PracticeModeResetMessageCommand = function(self)
		tDiff = 0
		wifey = 0
		jdgct = 0
		dvCur = nil
		jdgCur = nil
		curMeanSum = 0
		curMeanCount = 0
		self:playcommand("SpottedOffset")
	end
}

-- lifebard
t[#t + 1] =
	Def.ActorFrame {
	Name = "LifeP1",
}

-- shit for combo display
local comboX = 0
local comboY = 60

-- CUZ WIDESCREEN DEFAULTS SCREAAAAAAAAAAAAAAAAAAAAAAAAAM -mina
if IsUsingWideScreen() then
	comboX = comboX + WIDESCREENWHX
	comboY = comboY - WIDESCREENWHY
end

--This just initializes the initial point or not idk not needed to mess with this any more
function ComboTransformCommand(self, params)
	self:x(comboX)
	self:y(comboY)
end

-- anything that isn't yet in loadactors has been moved
t[#t + 1] = LoadActor("elements/default")

-------------------------------------------------------------------------------------------------------------- practice mode
-- this should really be moved, so
-- TODO: move this to elements
-- ~kurulen
local prevZoom = 0.65
local musicratio = 1

-- hurrrrr nps quadzapalooza -mina
local wodth = capWideScale(get43size(240), 280)
local hidth = 40
local cd
local loopStartPos
local loopEndPos

local function handleRegionSetting(positionGiven)
	-- don't allow a negative region
	-- internally it is limited to -2
	-- the start delay is 2 seconds, so limit this to 0
	if positionGiven < 0 then return end

	-- first time starting a region
	if not loopStartPos and not loopEndPos then
		loopStartPos = positionGiven
		MESSAGEMAN:Broadcast("RegionSet")
		return
	end

	-- reset region to bookmark only if double right click
	if positionGiven == loopStartPos or positionGiven == loopEndPos then
		loopEndPos = nil
		loopStartPos = positionGiven
		MESSAGEMAN:Broadcast("RegionSet")
		SCREENMAN:GetTopScreen():ResetLoopRegion()
		return
	end

	-- measure the difference of the new pos from each end
	local startDiff = math.abs(positionGiven - loopStartPos)
	local endDiff = startDiff + 0.1
	if loopEndPos then
		endDiff = math.abs(positionGiven - loopEndPos)
	end

	-- use the diff to figure out which end to move

	-- if there is no end, then you place the end
	if not loopEndPos then
		if loopStartPos < positionGiven then
			loopEndPos = positionGiven
		elseif loopStartPos > positionGiven then
			loopEndPos = loopStartPos
			loopStartPos = positionGiven
		else
			-- this should never happen
			-- but if it does, reset to bookmark
			loopEndPos = nil
			loopStartPos = positionGiven
			MESSAGEMAN:Broadcast("RegionSet")
			SCREENMAN:GetTopScreen():ResetLoopRegion()
			return
		end
	else
		-- closer to the start, move the start
		if startDiff < endDiff then
			loopStartPos = positionGiven
		else
			loopEndPos = positionGiven
		end
	end
	SCREENMAN:GetTopScreen():SetLoopRegion(loopStartPos, loopEndPos)
	MESSAGEMAN:Broadcast("RegionSet", {loopLength = loopEndPos-loopStartPos})
end

local function duminput(event)
	if event.type == "InputEventType_Release" then
		if event.DeviceInput.button == "DeviceButton_right mouse button" then
			MESSAGEMAN:Broadcast("MouseRightClick")
		end
	elseif event.type == "InputEventType_FirstPress" then
		if event.DeviceInput.button == "DeviceButton_backspace" then
			if loopStartPos ~= nil then
				SCREENMAN:GetTopScreen():SetSongPositionAndUnpause(loopStartPos, 1, true)
			end
		elseif event.button == "EffectUp" then
			SCREENMAN:GetTopScreen():AddToRate(0.05)
		elseif event.button == "EffectDown" then
			SCREENMAN:GetTopScreen():AddToRate(-0.05)
		elseif event.button == "Coin" then
			handleRegionSetting(SCREENMAN:GetTopScreen():GetSongPosition())
		elseif event.DeviceInput.button == "DeviceButton_mousewheel up" then
			if GAMESTATE:IsPaused() then
				local pos = SCREENMAN:GetTopScreen():GetSongPosition()
				local dir = GAMESTATE:GetPlayerState():GetCurrentPlayerOptions():UsingReverse() and 1 or -1
				local nextpos = pos + dir * 0.05
				if loopEndPos ~= nil and nextpos >= loopEndPos then
					handleRegionSetting(nextpos + 1)
				end
				SCREENMAN:GetTopScreen():SetSongPosition(nextpos, 0, false)
			end
		elseif event.DeviceInput.button == "DeviceButton_mousewheel down" then
			if GAMESTATE:IsPaused() then
				local pos = SCREENMAN:GetTopScreen():GetSongPosition()
				local dir = GAMESTATE:GetPlayerState():GetCurrentPlayerOptions():UsingReverse() and 1 or -1
				local nextpos = pos - dir * 0.05
				if loopEndPos ~= nil and nextpos >= loopEndPos then
					handleRegionSetting(nextpos + 1)
				end
				SCREENMAN:GetTopScreen():SetSongPosition(nextpos, 0, false)
			end
		end
	end

	return false
end

local function UpdatePreviewPos(self)
	local pos = SCREENMAN:GetTopScreen():GetSongPosition() / musicratio
	self:GetChild("Pos"):zoomto(math.min(math.max(0, pos), wodth), hidth)
	self:queuecommand("Highlight")
end

local pm = Def.ActorFrame {
	Name = "ChartPreview",
	InitCommand = function(self)
		self:xy(MovableValues.PracticeCDGraphX, MovableValues.PracticeCDGraphY)
		self:SetUpdateFunction(UpdatePreviewPos)
		cd = self:GetChild("ChordDensityGraph"):visible(true):draworder(1000):y(20)
		if (allowedCustomization) then
			Movable.DeviceButton_z.element = self
			Movable.DeviceButton_z.condition = practiceMode
		end
	end,
	BeginCommand = function(self)
		musicratio = GAMESTATE:GetCurrentSteps():GetLastSecond() / (wodth)
		SCREENMAN:GetTopScreen():AddInputCallback(duminput)
		cd:GetChild("cdbg"):diffusealpha(0)
		self:SortByDrawOrder()
		self:queuecommand("GraphUpdate")
	end,
	PracticeModeReloadMessageCommand = function(self)
		musicratio = GAMESTATE:GetCurrentSteps():GetLastSecond() / wodth
	end,
	Def.Quad {
		Name = "BG",
		InitCommand = function(self)
			self:x(wodth / 2)
			self:diffuse(color("0.05,0.05,0.05,1"))
		end
	},
	Def.Quad {
		Name = "PosBG",
		InitCommand = function(self)
			self:zoomto(wodth, hidth):halign(0):diffuse(color("1,1,1,1")):draworder(900)
		end,
		HighlightCommand = function(self) -- use the bg for detection but move the seek pointer -mina
			if isOver(self) then
				local seek = self:GetParent():GetChild("Seek")
				local seektext = self:GetParent():GetChild("Seektext")
				local cdg = self:GetParent():GetChild("ChordDensityGraph")

				seek:visible(true)
				seektext:visible(true)
				seek:x(INPUTFILTER:GetMouseX() - self:GetParent():GetX())
				seektext:x(INPUTFILTER:GetMouseX() - self:GetParent():GetX() - 4)	-- todo: refactor this lmao -mina
				seektext:y(INPUTFILTER:GetMouseY() - self:GetParent():GetY())
				if cdg.npsVector ~= nil and #cdg.npsVector > 0 then
					local percent = clamp((INPUTFILTER:GetMouseX() - self:GetParent():GetX()) / wodth, 0, 1)
					local hoveredindex = clamp(math.ceil(cdg.finalNPSVectorIndex * percent), math.min(1, cdg.finalNPSVectorIndex), cdg.finalNPSVectorIndex)
					local hoverednps = cdg.npsVector[hoveredindex]
					local td = GAMESTATE:GetCurrentSteps():GetTimingData()
					local bpm = td:GetBPMAtBeat(td:GetBeatFromElapsedTime(seek:GetX() * musicratio)) * getCurRateValue()
					seektext:settextf("%0.2f\n%d %s\n%d %s", seek:GetX() * musicratio / getCurRateValue(), hoverednps, translated_info["NPS"], bpm, translated_info["BPM"])
				else
					seektext:settextf("%0.2f", seek:GetX() * musicratio / getCurRateValue())
				end
			else
				self:GetParent():GetChild("Seektext"):visible(false)
				self:GetParent():GetChild("Seek"):visible(false)
			end
		end
	},
	Def.Quad {
		Name = "Pos",
		InitCommand = function(self)
			self:zoomto(0, hidth):diffuse(color("0,1,0,.5")):halign(0):draworder(900)
		end
	}
}

-- Load the CDGraph with a forced width parameter.
pm[#pm + 1] = LoadActorWithParams("../_chorddensitygraph.lua", {width = wodth})

-- more draw order shenanigans
pm[#pm + 1] = LoadFont("Common Normal") .. {
	Name = "Seektext",
	InitCommand = function(self)
		self:y(8):valign(1):halign(1):draworder(1100):diffuse(color("0.8,0,0")):zoom(0.4)
	end
}

pm[#pm + 1] = UIElements.QuadButton(1, 1) .. {
	Name = "Seek",
	InitCommand = function(self)
		self:zoomto(2, hidth):diffuse(color("1,.2,.5,1")):halign(0.5):draworder(1100)
		self:z(2)
	end,
	MouseDownCommand = function(self, params)
		if params.event == "DeviceButton_left mouse button" then
			local withCtrl = INPUTFILTER:IsControlPressed()
			if withCtrl then
				handleRegionSetting(self:GetX() * musicratio)
			else
				SCREENMAN:GetTopScreen():SetSongPosition(self:GetX() * musicratio, 0, false)
			end
		elseif params.event == "DeviceButton_right mouse button" then
			handleRegionSetting(self:GetX() * musicratio)
		end
	end,
}

pm[#pm + 1] = Def.Quad {
	Name = "BookmarkPos",
	InitCommand = function(self)
		self:zoomto(2, hidth):diffuse(color(".2,.5,1,1")):halign(0.5):draworder(1100)
		self:visible(false)
	end,
	SetCommand = function(self)
		self:visible(true)
		self:zoomto(2, hidth):diffuse(color(".2,.5,1,1")):halign(0.5)
		self:x(loopStartPos / musicratio)
	end,
	RegionSetMessageCommand = function(self, params)
		if not params or not params.loopLength then
			self:playcommand("Set")
		else
			self:visible(true)
			self:x(loopStartPos / musicratio):halign(0)
			self:zoomto(params.loopLength / musicratio, hidth):diffuse(color(".7,.2,.7,0.5"))
		end
	end,
	CurrentRateChangedMessageCommand = function(self)
		if not loopEndPos and loopStartPos then
			self:playcommand("Set")
		elseif loopEndPos and loopStartPos then
			self:playcommand("RegionSet", {loopLength = (loopEndPos - loopStartPos)})
		end
	end,
	PracticeModeReloadMessageCommand = function(self)
		self:playcommand("CurrentRateChanged")
	end
}

if practiceMode and not isReplay then
	t[#t + 1] = pm
	if not allowedCustomization then
		-- enable pausing
		t[#t+1] = UIElements.QuadButton(1, 1) .. {
			Name = "PauseArea",
			InitCommand = function(self)
				self:halign(0):valign(0)
				self:z(1)
				self:diffusealpha(0)
				self:zoomto(SCREEN_WIDTH, SCREEN_HEIGHT)
			end,
			MouseDownCommand = function(self, params)
				if params.event == "DeviceButton_right mouse button" then
					local top = SCREENMAN:GetTopScreen()
					if top then
						top:TogglePause()
					end
				end
			end,
		}
	end
end

return t
