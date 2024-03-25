local allowedCustomization = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomizeGameplay

local t =
	Def.ActorFrame {
	Name = "MusicRate",
	InitCommand = function(self)
		if (allowedCustomization) then
			Movable.DeviceButton_v.element = self
			Movable.DeviceButton_b.element = self
			Movable.DeviceButton_v.condition = true
			Movable.DeviceButton_b.condition = true
		end
		self:xy(MovableValues.MusicRateX, MovableValues.MusicRateY):zoom(MovableValues.MusicRateZoom)
	end,
	LoadFont("Common Normal") ..
	{
		InitCommand = function(self)
			self:zoom(0.35):settext(getCurRateDisplayString())
		end,
		SetRateCommand = function(self)
			self:settext(getCurRateDisplayString())
		end,
		DoneLoadingNextSongMessageCommand = function(self)
			self:playcommand("SetRate")
		end,
		CurrentRateChangedMessageCommand = function(self)
			self:playcommand("SetRate")
		end
	},
}

return t
