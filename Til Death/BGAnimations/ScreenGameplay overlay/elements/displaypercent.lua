local allowedCustomization = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomizeGameplay

--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 					    									**Display Percent**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Displays the current percent for the score.
]]

local usePercent = (playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).UsePercentInGameplay and "%" or "")
local format = "%05.2f"..usePercent
local t =
	Def.ActorFrame {
	Name = "DisplayPercent",
	InitCommand = function(self)
		if (allowedCustomization) then
			Movable.DeviceButton_w.element = self
			Movable.DeviceButton_e.element = self
			Movable.DeviceButton_w.condition = true
			Movable.DeviceButton_e.condition = true
		end
		self:zoom(MovableValues.DisplayPercentZoom):x(MovableValues.DisplayPercentX):y(MovableValues.DisplayPercentY)
	end,
	Def.Quad {
		InitCommand = function(self)
			self:zoomto(60, 13):diffuse(color("0,0,0,0.0")):halign(1):valign(0)
		end
	},
	-- Displays your current percentage score
	LoadFont("Common Large") ..
		{
			Name = "DisplayPercent",
			InitCommand = function(self)
				self:zoom(0.3):halign(1):valign(0)
			end,
			OnCommand = function(self)
				if allowedCustomization then
					self:settextf(format, -10000)
				end
				self:settextf(format, 0)
			end,
			SpottedOffsetCommand = function(self)
				self:settextf(format, wifey)
			end
		},
}

return t
