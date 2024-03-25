CurrentTidbit = "ScreenTitleMenu"

local t = Def.ActorFrame {}

t[#t + 1] = Def.Sprite {
   BeginCommand = function(self)
      self:diffusealpha(0)
   end,
   StartedPlayingMenuMusicMessageCommand = function(self,params)
      if params then
	 if params.song then
	    local status, _ = pcall(function(self, params)
		  self:LoadFromSongBackground(params.song)
	    end, self, params)
	    if status == true then
	       self:linear(0.08):diffusealpha(1)
	       self:ScaleToBounds(SCREEN_WIDTH, SCREEN_HEIGHT, self:GetWidth(), self:GetHeight())
	       self:Center()
	    end
	 end
      end
   end,
   StoppedPlayingMenuMusicMessageCommand = function(self)
      self:linear(0.08):diffusealpha(0)
   end,
}

return t
