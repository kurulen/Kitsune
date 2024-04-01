local bgbrightness = PREFSMAN:GetPreference("BGBrightness")

return Def.Quad {
	InitCommand = function(self)
		self:FullScreen():diffuse(color(colorConfig:get_data().gameplay["background"].."FF"))
		if bgbrightness then
		   self:diffusealpha(1-tonumber(bgbrightness))
		end
	end
}
