local enabled = PREFSMAN:GetPreference("ShowBackgrounds")
local fadePercentage = 0.8

local t = Def.ActorFrame {}

-- bg
if enabled then
	t[#t + 1] = Def.Sprite {
		Name = "BGSprite",
		InitCommand = function(self)
			self:diffusealpha(0)
		end,
		CurrentSongChangedMessageCommand = function(self)
			self:stoptweening():smooth(0.5):diffusealpha(0)
			self:sleep(0.2):queuecommand("ModifySongBackground")
		end,
		ModifySongBackgroundCommand = function(self)
			if GAMESTATE:GetCurrentSong() and GAMESTATE:GetCurrentSong():GetBackgroundPath() then
				self:finishtweening()
				self:visible(true)
				self:LoadBackground(GAMESTATE:GetCurrentSong():GetBackgroundPath())
				self:ScaleToBounds(SCREEN_WIDTH, SCREEN_HEIGHT, self:GetWidth(), self:GetHeight())
				self:Center()
				self:sleep(0.05)
				self:smooth(0.4):diffusealpha(1)
			else
				self:visible(false)
			end
		end,
		OffCommand = function(self)
			self:smooth(0.6):diffusealpha(0)
		end,
	}
end

t[#t+1] = Def.Quad {
   InitCommand=function(self)
      self:FullScreen():diffuse(0,0,0,fadePercentage)
   end
}

--vertical bar left of songwheel
t[#t + 1] = Def.Quad {
	InitCommand = function(self)
		self:xy(SCREEN_WIDTH - capWideScale(get43size(350), 350), 0):halign(0):valign(0):zoomto(4, SCREEN_HEIGHT)
		self:diffuse(getMainColor("highlight")):diffusealpha(0.5)
	end
}

return t
