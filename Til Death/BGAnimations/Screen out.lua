local t = Def.ActorFrame {}
ShowingHelp = false
MESSAGEMAN:Broadcast("HideKBHelps")

--black fade
t[#t + 1] = Def.Quad {
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y):zoomto(SCREEN_WIDTH, SCREEN_HEIGHT)
	end,
	OnCommand = function(self)
		self:diffuse(color("0,0,0,0")):sleep(0.08):linear(0.08):diffusealpha(1)
	end
}

return t