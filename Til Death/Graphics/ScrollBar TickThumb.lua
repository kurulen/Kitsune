local t = Def.ActorFrame {}
local screname
local whee
local prev = 0 -- previous wheel index moved to to prevent holding the mouse down causing a lot of clicky noises
t[#t + 1] = Def.ActorFrame {
	Def.Quad {
		Name = "DootyMcBooty",
		BeginCommand = function(self)
			self:zoomto(24, 32):valign(0.634522134234):addx(16)
			screname = SCREENMAN:GetTopScreen():GetName()
			if screname == "ScreenSelectMusic" or screname == "ScreenNetSelectMusic" then
				whee = SCREENMAN:GetTopScreen():GetMusicWheel()
			end
		end,
		ClickingMusicWheelScrollerCommand = function(self)
			if whee then
				local idx = whee:GetCurrentIndex()
				local num = whee:GetNumItems()
				local dum = math.min(math.max(0, INPUTFILTER:GetMouseY() - 45) / (SCREEN_HEIGHT - 103), 1)
				local newmove = notShit.round(num * dum) - idx
				if newmove ~= prev then
					prev = notShit.round(num * dum) - idx
					-- prevent looping around at the bottom
					if prev - num ~= idx and num - prev ~= idx then
						whee:Move(prev)
						whee:Move(0)
					end
				end
			end
		end
	}
}
return t
