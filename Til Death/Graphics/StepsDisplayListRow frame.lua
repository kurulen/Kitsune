local t = Def.ActorFrame {}

t[#t + 1] = Def.Quad {
	InitCommand = function(self)
		self:zoomto(20, 20):diffuse(color("#ffffff")):diffusealpha(0.7)
	end
}

t[#t + 1] = Def.Quad {
	InitCommand = function(self)
		self:zoomto(54, 20):diffuse(color("#ffffff")):diffusealpha(0.5):halign(0)
	end,
}

return t
