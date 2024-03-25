local allowedCustomization = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomizeGameplay

--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
														    	**BPM Display**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Better optimized frame update bpm display.
]]
local BPM
local a = GAMESTATE:GetPlayerState():GetSongPosition()
local r = GAMESTATE:GetSongOptionsObject("ModsLevel_Current"):MusicRate() * 60
local GetBPS = SongPosition.GetCurBPS

local function UpdateBPM(self)
	local bpm = GetBPS(a) * r
	BPM:settext(notShit.round(bpm, 2))
end

local t =
	Def.ActorFrame {
	Name = "BPMText",
	InitCommand = function(self)
		if (allowedCustomization) then
			Movable.DeviceButton_x.element = self
			Movable.DeviceButton_c.element = self
			Movable.DeviceButton_x.condition = true
			Movable.DeviceButton_c.condition = true
		end
		self:x(MovableValues.BPMTextX):y(MovableValues.BPMTextY):zoom(MovableValues.BPMTextZoom)
		BPM = self:GetChild("BPM")
		if #GAMESTATE:GetCurrentSong():GetTimingData():GetBPMs() > 1 then -- dont bother updating for single bpm files
			self:SetUpdateFunction(UpdateBPM)
			self:SetUpdateRate(0.5)
		else
			BPM:settextf("%5.2f", GetBPS(a) * r) -- i wasn't thinking when i did this, we don't need to avoid formatting for performance because we only call this once -mina
		end
	end,
	LoadFont("Common Normal") ..
		{
			Name = "BPM",
			InitCommand = function(self)
				self:halign(0.5):zoom(0.40)
			end
		},
	DoneLoadingNextSongMessageCommand = function(self)
		self:queuecommand("Init")
	end,
	-- basically a copy of the init
	CurrentRateChangedMessageCommand = function(self)
		r = GAMESTATE:GetSongOptionsObject("ModsLevel_Current"):MusicRate() * 60
		if #GAMESTATE:GetCurrentSong():GetTimingData():GetBPMs() > 1 then
			self:SetUpdateFunction(UpdateBPM)
			self:SetUpdateRate(0.5)
		else
			BPM:settextf("%5.2f", GetBPS(a) * r)
		end
	end,
	PracticeModeReloadMessageCommand = function(self)
		self:playcommand("CurrentRateChanged")
	end,
}

return t
