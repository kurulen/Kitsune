-- all the preview stuff should be var'd and used consistently -mina
local prevZoom = 0.65
local musicratio = 1

local seekWidth = capWideScale(280, 300)
local seekHeight = 40
local chordDensity
local calcinfo
local previewVisible = false

local seekPos = 0

local seekIncrement = 5

local yPos = Var("yPos")
local yPosReverse = Var("yPosReverse")
if not yPos then yPos = 55 end
if not yPosReverse then yPosReverse = 60 end

local translated_info = TranslationMatrices["ChartPreview"]

local function chartPreviewCtrlBinds(event)
	local CtrlPressed = INPUTFILTER:IsControlPressed()
	local song = GAMESTATE:GetCurrentSong()

	-- scrolling code
	local function clampAndSeek(incdec)
		local length = song:GetLastSecond()
		seekPos = (incdec and (seekPos + (seekIncrement * musicratio)) or (seekPos - (seekIncrement * musicratio)))
		local overflow = seekPos < length
		local underflow = seekPos >= 0.001
		if overflow and underflow then
			SCREENMAN:GetTopScreen():SetSampleMusicPosition( seekPos )
		elseif not overflow then
			SCREENMAN:GetTopScreen():SetSampleMusicPosition( length - 0.001 )
		elseif not underflow then
			SCREENMAN:GetTopScreen():SetSampleMusicPosition( 0.001 )
		end
	end
	local function handleButtons(name)
		if name == "DeviceButton_j" then
			if song then
				-- seek backwards
				clampAndSeek(false)
			end
		elseif name == "DeviceButton_k" then
			if song then
				-- seek forwards
				clampAndSeek(true)
			end
		end
	end

	-- only do this if the preview is visible, otherwise don't bother
	if previewVisible then
		if event.type == "InputEventType_FirstPress" then
			if CtrlPressed then
				if not SCREENMAN:GetTopScreen():IsSampleMusicPaused() then
					SCREENMAN:GetTopScreen():PauseSampleMusic()
					MESSAGEMAN:Broadcast("MusicPauseToggled")
				end
				handleButtons(event.DeviceInput.button)
			end
		elseif event.type == "InputEventType_Repeat" then
			handleButtons(event.DeviceInput.button)
		elseif event.type == "InputEventType_Release" then
			if event.DeviceInput.button == "DeviceButton_left ctrl" or event.DeviceInput.button == "DeviceButton_right ctrl" then
				if SCREENMAN:GetTopScreen():IsSampleMusicPaused() then
					SCREENMAN:GetTopScreen():PauseSampleMusic()
					MESSAGEMAN:Broadcast("MusicPauseToggled")
				end
			end
		end
	end
	return false
end

local function UpdatePreviewPos(self)
	if not self:IsVisible() then return end
	local scrnm = SCREENMAN:GetTopScreen():GetName()
	local allowedScreens = {
		ScreenSelectMusic = true,
		ScreenNetSelectMusic = true,
	}

	if allowedScreens[scrnm] == true then
		seekPos = SCREENMAN:GetTopScreen():GetSampleMusicPosition()
		local ourPos = seekPos / musicratio
		self:GetChild("Pos"):zoomto(math.min(ourPos,seekWidth), seekHeight)
		self:queuecommand("Highlight")

		-- calcdisplay position indicator (not the best place to put this but it works)
		--[[
			this is idiotic
			- kurulen
			local calcgraphpos = SCREENMAN:GetTopScreen():GetSampleMusicPosition() / musicratio
		]]
		local badorp = self:GetChild("notChordDensityGraph"):GetChild("GraphPos")
		local zorp = self:GetChild("notChordDensityGraph"):GetChild("GraphPos2")
		badorp:zoomto(math.min(ourPos * capWideScale(300,450) / capWideScale(280,300), capWideScale(300,450)), seekHeight * 3):halign(0)
		zorp:zoomto(math.min(ourPos * capWideScale(300,450) / capWideScale(280,300), capWideScale(300,450)), seekHeight * 4):halign(0)
	end
end

local function updateCalcInfoDisplays(actor)
	if not calcinfo:GetVisible() then return end
	sl1 = actor:GetParent():GetChild("notChordDensityGraph"):GetChild("Seek1")
	st1 = actor:GetParent():GetChild("notChordDensityGraph"):GetChild("Seektext1")
	st1:settextf("%0.2f", seekPos * musicratio /  getCurRateValue())
	sl1:visible(true)
	st1:visible(true)
end

local t = Def.ActorFrame {
	Name = "ChartPreview",
	InitCommand=function(self)
		self:visible(false)
        self:SetUpdateFunction(UpdatePreviewPos)
		calcinfo = self:GetChild("notChordDensityGraph"):visible(false):draworder(1000) -- actor for calcinfo
		chordDensity = self:GetChild("ChordDensityGraph"):visible(false):draworder(1000)
	end,
	BeginCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(chartPreviewCtrlBinds)
	end,
	CurrentSongChangedMessageCommand=function(self)
		self:GetChild("pausetext"):settext("")
	end,
	CurrentStepsChangedMessageCommand = function(self)
		if GAMESTATE:GetCurrentSong() then
            musicratio = (GAMESTATE:GetCurrentSteps():GetFirstSecond() / getCurRateValue() + GAMESTATE:GetCurrentSteps():GetLengthSeconds()) / seekWidth * getCurRateValue()
		end
	end,
    SetupNoteFieldCommand=function(self)
		self:playcommand("NoteFieldVisible")
	end,
	ChartPreviewOffMessageCommand=function(self)
		previewVisible = false
		self:SetUpdateFunction(nil)
	end,
	ChartPreviewOnMessageCommand=function(self)
		previewVisible = true
		self:SetUpdateFunction(UpdatePreviewPos)
		self:GetChild("NoteField"):playcommand("LoadNoteData", {steps = GAMESTATE:GetCurrentSteps()})
	end,
	NoteFieldVisibleMessageCommand = function(self)
		self:visible(true)
		self:SetUpdateFunction(UpdatePreviewPos)
		chordDensity:visible(true):y(20)				-- need to control this manually -mina
		chordDensity:GetChild("cdbg"):diffusealpha(0)	-- we want to use our position background for draw order stuff -mina
		chordDensity:queuecommand("GraphUpdate")		-- first graph will be empty if we dont force this on initial creation
	end,
	OptionsScreenClosedMessageCommand = function(self)
		local pOptions = GAMESTATE:GetPlayerState():GetCurrentPlayerOptions()
		local usingscrollmod = false
		local usingreverse = pOptions:UsingReverse()
		local noteField = self:GetChild("NoteField")
		if not noteField then return end
		if pOptions:Split() ~= 0 or pOptions:Alternate() ~= 0 or pOptions:Cross() ~= 0 or pOptions:Centered() ~= 0 then
			usingscrollmod = true
		end

		noteField:y(yPos * 2.85)
		if usingscrollmod then
			noteField:y(yPos * 3.55)
		elseif usingreverse then
			noteField:y(yPos * 2.85 + yPosReverse)
		end
	end,

	Def.NoteFieldPreview {
		Name = "NoteField",
		DrawDistanceBeforeTargetsPixels = 600,
		DrawDistanceAfterTargetsPixels = 0,
		--YReverseOffsetPixels = 100,

		BeginCommand = function(self)
			self:zoom(prevZoom):draworder(90)
			self:x(seekWidth/2)
			self:GetParent():SortByDrawOrder()
		end,
		CurrentStepsChangedMessageCommand = function(self, params)
			local steps = params.ptr
			-- only load new notedata if the preview is visible
			if self:GetParent():GetVisible() then
				self:playcommand("LoadNoteData", {steps = steps})
			end
		end,
		LoadNoteDataCommand = function(self, params)
			local steps = params.steps
			if steps ~= nil then
				self:LoadNoteData(steps)
			else
				self:LoadDummyNoteData()
			end
		end
	},

	Def.Quad {
		Name = "BG",
		InitCommand = function(self)
			self:xy(seekWidth/2, SCREEN_HEIGHT/2)
			self:diffuse(color("0.05,0.05,0.05,1"))
		end,
		CurrentStyleChangedMessageCommand=function(self)
			local cols = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
			self:zoomto(48 * cols, SCREEN_HEIGHT)
		end
	},
	LoadFont("Common Large") .. {
		Name = "pausetext",
		InitCommand = function(self)
			self:xy(seekWidth/2, SCREEN_HEIGHT/2):draworder(900):zoom(0.5)
			self:settext(""):diffuse(color("0.8,0,0"))
			self:shadowlength(1):shadowcolor(0,0,0,1)
		end,
		NoteFieldVisibleMessageCommand = function(self)
			self:settext("")
		end,
		PreviewMusicStartedMessageCommand = function(self)
			self:playcommand("Set")
		end,
		SetCommand = function(self)
			if SCREENMAN:GetTopScreen():IsSampleMusicPaused() then
				self:settext(translated_info["Paused"])
			else
				self:settext("")
			end
		end,
		MusicPauseToggledMessageCommand = function(self)
			self:playcommand("Set")
		end,
	},
	Def.Quad {
		Name = "PosBG",
		InitCommand = function(self)
			--self:zoomto(seekWidth, seekHeight):halign(0):diffuse(color(".1,.1,.1,1")):draworder(900) -- alt bg for calc info
			self:zoomto(seekWidth, seekHeight):halign(0):diffuse(color("1,1,1,1")):draworder(900) -- cdgraph bg
		end,
		HighlightCommand = function(self)	-- use the bg for detection but move the seek pointer -mina
			if isOver(self) then
				local seek = seekPos
				local seektext = self:GetParent():GetChild("Seektext")
				local chordDensityGraph = self:GetParent():GetChild("ChordDensityGraph")

				seek:visible(true)
				seektext:visible(true)
				seek:x(INPUTFILTER:GetMouseX() - self:GetParent():GetX())
				seektext:x(INPUTFILTER:GetMouseX() - self:GetParent():GetX() - 4)	-- todo: refactor this lmao -mina
				seektext:y(INPUTFILTER:GetMouseY() - self:GetParent():GetY())
				if chordDensityGraph.npsVector ~= nil and #chordDensityGraph.npsVector > 0 then
					local percent = clamp((INPUTFILTER:GetMouseX() - self:GetParent():GetX()) / seekWidth, 0, 1)
					local xtime = seek:GetX() * musicratio / getCurRateValue()
					local hoveredindex = clamp(math.ceil(chordDensityGraph.finalNPSVectorIndex * percent), math.min(1, chordDensityGraph.finalNPSVectorIndex), chordDensityGraph.finalNPSVectorIndex)
					local hoverednps = chordDensityGraph.npsVector[hoveredindex]
					local timingData = GAMESTATE:GetCurrentSteps():GetTimingData()
					local bpm = timingData:GetBPMAtBeat(timingData:GetBeatFromElapsedTime(seek:GetX() * musicratio)) * getCurRateValue()
					seektext:settextf("%0.2f\n%d %s\n%d %s", xtime, hoverednps, translated_info["NPS"], bpm, translated_info["BPM"])
				else
					seektext:settextf("%0.2f", seek:GetX() * musicratio / getCurRateValue())
				end

				updateCalcInfoDisplays(self)
			else
				self:GetParent():GetChild("Seektext"):visible(false)
				self:GetParent():GetChild("notChordDensityGraph"):GetChild("Seektext1"):visible(false)
				self:GetParent():GetChild("notChordDensityGraph"):GetChild("Seek1"):visible(false)
			end
		end
	},
	Def.Quad {
		Name = "Pos",
		InitCommand = function(self)
			self:zoomto(0, seekHeight):diffuse(color("0,1,0,.5")):halign(0):draworder(900)
		end
	}
}

t[#t + 1] = LoadActor("_chorddensitygraph.lua")
t[#t + 1] = LoadActor("_calcdisplay.lua")

-- more draw order shenanigans
t[#t + 1] = LoadFont("Common Normal") .. {
	Name = "Seektext",
	InitCommand = function(self)
		self:y(8):valign(0):halign(1):draworder(1100):diffuse(color("0.8,0,0")):zoom(0.4)
	end
}

t[#t + 1] = Def.Actor {
	CodeMessageCommand = function(self, params)
		-- because this button covers the background
		if params.Name == "SeekLeft" then
			SCREENMAN:GetTopScreen():SetSampleMusicPosition( -0.5 * musicratio )
		elseif params.Name == "SeekRight" then
			SCREENMAN:GetTopScreen():SetSampleMusicPosition( 0.5 * musicratio )
		end
	end,
}

return t
