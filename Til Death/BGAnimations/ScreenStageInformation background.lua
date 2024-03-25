local DecideCount = tonumber(THEME:GetMetric("ScreenStageInformation", "DecideCount"))
local DecideChoice = math.random(DecideCount)

local t = Def.ActorFrame {
   Def.Actor {
      OnCommand = function(self)
	 -- this pcall makes it so that the sound will not play
	 -- if the ogg files have been removed
	 pcall(function(DecideChoice)
	       SOUND:PlayOnce(THEME:GetPathS("Stage", "decide "..DecideChoice))
	 end, DecideChoice)
      end
   },
   -- bg
   Def.Sprite {
      OnCommand = function(self)
	 pcall(function()
	       self:LoadFromSongBackground(GAMESTATE:GetCurrentSong())
	       self:FullScreen()
	 end)
      end
   },
   Def.Quad {
      OnCommand = function(self)
	 self:FullScreen()
	 self:diffuse(0,0,0,0.3)
	 self:visible(true)
      end
   },
   Def.Quad {
      OnCommand = function(self)
	 self:FullScreen()
	 self:diffuse(0,0,0,1)
	 self:visible(true)
	 self:sleep(1.8)
	 self:linear(0.2):addy(328):diffusealpha(0.8)
      end
   },
   --banner
   Def.Sprite {
      OnCommand = function(self)
	 pcall(function()
	       local scale = 1.5
	       self:scaletoclipped((512*scale), (160*scale))
	       self:Center()
	       self:addy(-96)
	       self:LoadFromSongBanner(GAMESTATE:GetCurrentSong())
	       self:sleep(1.8)
	       self:accelerate(0.2):y(-SCREEN_HEIGHT)
	 end)
      end
   },
   LoadFont("Common Normal") .. {
      OnCommand = function(self)
	 local mt = GAMESTATE:GetCurrentSong():GetDisplayMainTitle()
	 if mt then
	    local lc = GetLineCount(mt)
	    self:zoom(2)
	    self:valign(1)
	    self:settext(mt)
	    if lc > 1 then
	       if lc > 2 then
		  self:settext("----------")
	       else
		  self:zoom(0.85)
		  self:valign(self:GetZoom())
	       end
	    end
	    self:maxwidth(350)
	    self:Center()
	    self:addy(98)
	    self:sleep(1.8)
	    self:accelerate(0.2):addy(48)
	 end
      end
   },
   LoadFont("Common Normal") .. {
      OnCommand = function(self)
	 local st = GAMESTATE:GetCurrentSong():GetDisplaySubTitle()
	 if st then
	    local lc = GetLineCount(st)
	    self:zoom(1)
	    self:valign(1)
	    self:settext(st)
	    if lc > 1 then
	       if lc > 2 then
		  self:settext("----------")
	       else
		  self:zoom(0.85)
		  self:valign(self:GetZoom())
	       end
	    end
	    self:maxwidth(350)
	    self:Center()
	    self:addy(138)
	    self:sleep(1.8)
	    self:accelerate(0.2):addy(48)
	 end
      end
   },
   LoadFont("Common Normal") .. {
      OnCommand = function(self)
	 local at = GAMESTATE:GetCurrentSong():GetDisplayArtist()
	 if at then
	    local lc = GetLineCount(at)
	    self:zoom(1)
	    self:valign(1)
	    self:settext(at)
	    if lc > 1 then
	       if lc > 2 then
		  self:settext("----------")
	       else
		  self:zoom(0.85)
		  self:valign(self:GetZoom())
	       end
	    end
	    self:maxwidth(350)
	    self:Center()
	    self:addy(178)
	    self:sleep(1.8)
	    self:accelerate(0.2):addy(48)
	 end
      end
   }
}

if CurrentSubTidbit ~= "Gameplay" then
   return t
else
   return Def.Actor {
      OnCommand = function(self)
	 SCREENMAN:GetTopScreen():PostScreenMessage("SM_GoToNextScreen", 0)
      end
   }
end
