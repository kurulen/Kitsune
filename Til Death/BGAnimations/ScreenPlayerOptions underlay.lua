t = Def.ActorFrame { }

t[#t + 1] =
	Def.Quad {
		OnCommand = function(self)
			self:zoomto(SCREEN_WIDTH, SCREEN_HEIGHT):Center():diffusealpha(1):diffuse(getMainColor("frames"))
		end
	}

return t
