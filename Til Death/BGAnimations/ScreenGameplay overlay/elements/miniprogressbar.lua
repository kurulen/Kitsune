local allowedCustomization = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomizeGameplay

local width = 34
local height = 4
local alpha = 0.3

local t =
	Def.ActorFrame {
	Name = "MiniProgressBar",
	InitCommand = function(self)
		self:xy(MovableValues.MiniProgressBarX, MovableValues.MiniProgressBarY)
		if (allowedCustomization) then
			Movable.DeviceButton_q.element = self
			Movable.DeviceButton_q.condition = true
		end
	end,
	Def.Quad {
		InitCommand = function(self)
			self:zoomto(width, height):diffuse(color("#666666")):diffusealpha(alpha)
		end
	},
	Def.Quad {
		InitCommand = function(self)
			self:x(1 + width / 2):zoomto(1, height):diffuse(color("#555555"))
		end
	},
	Def.SongMeterDisplay {
		InitCommand = function(self)
			self:SetUpdateRate(0.5)
		end,
		StreamWidth = width,
		Stream = Def.Quad {
			InitCommand = function(self)
				self:zoomy(height):diffuse(getMainColor("highlight"))
			end
		}
	},
}

return t
