local allowedCustomization = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomizeGameplay

--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 					    									**Display Mean**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Displays the current mean for the score.
]]
local t = Def.ActorFrame {
	Name = "DisplayMean",
	InitCommand = function(self)
		if (allowedCustomization) then
			Movable.DeviceButton_comma.element = self
			Movable.DeviceButton_m.element = self
			Movable.DeviceButton_comma.condition = true
			Movable.DeviceButton_m.condition = true
		end
		self:zoom(MovableValues.DisplayMeanZoom):x(MovableValues.DisplayMeanX):y(MovableValues.DisplayMeanY)
	end,
	-- Displays your current mean score
	LoadFont("Common Large") .. {
		Name = "DisplayPercent",
		InitCommand = function(self)
			self:zoom(0.3):halign(1):valign(0)
		end,
		OnCommand = function(self)
			if allowedCustomization then
				self:settextf("%5.2f", -10000)
			end
			self:settextf("%5.2f", 0)
		end,
		SpottedOffsetCommand = function(self)
			local mean = curMeanSum / curMeanCount
			if curMeanCount == 0 then
				mean = 0
			end
			self:settextf("%5.2f", mean)
		end
	},
}

return t
