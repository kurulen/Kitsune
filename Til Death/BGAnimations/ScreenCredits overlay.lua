return Def.ActorFrame{
   OnCommand = function(self)
      SCREENMAN:GetTopScreen():AddInputCallback(function(event)
	    if event.type == "InputEventType_FirstPress" then
	       if event.button == "Back" then
		  SOUND:StopMusic()
		  SCREENMAN:GetTopScreen():Cancel()
	       end
	    end
      end)
   end,
   LoadFont("Common Large") .. {
      InitCommand = function(self)
	 self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
	 self:zoom(0.55)

	 local rf = RageFileUtil:CreateRageFile()
	 local ok = rf:Open("Themes/"..THEME:GetCurThemeName().."/Other/credits.txt", 1)
	 if ok == true then
	    self:settext(rf:Read())
	 end

	 self:addy(SCREEN_HEIGHT * 5.45)
	 self:queuecommand("Animate")
      end,
      AnimateCommand = function(self)
	 SOUND:PlayMusicPart(THEME:GetPathS("ScreenCredits", "music"), 0.0, 115.826, 0.0, 0.0, false, false, false)

	 self:linear(115.826):addy(-SCREEN_HEIGHT * 9.85)
      end
   }
}
