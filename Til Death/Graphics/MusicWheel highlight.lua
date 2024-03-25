return Def.ActorFrame {
	Def.Quad {
		Name = "Horizontal",
		InitCommand = function(self)
			self:xy(0, -2):zoomto(854, 34):halign(0)
		end,
		AnimateCommand = function(self)
			self:diffuseshift():effectcolor1(1,1,1,0.5):effectcolor2(0.5,0.5,0.5,0.5)
		end,
		BeginCommand = function(self)
			self:diffuse(1,1,1,0.5)
			self:queuecommand("Animate")
		end,
		OffCommand = function(self)
			self:visible(false)
		end
	}
}
