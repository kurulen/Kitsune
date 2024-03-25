t = Def.ActorFrame { }

t[#t + 1] = Def.Quad {
		OnCommand = function(self)
			self:zoomto(SCREEN_WIDTH, SCREEN_HEIGHT):Center():diffuse(0,0,0,0)
			self:linear(0.08):diffuse(getMainColor("frames"))
		end
	}

return t
