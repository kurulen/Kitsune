return Def.ActorFrame{
   OnCommand = function(self)
      SCREENMAN:GetTopScreen():AddInputCallback(function(event)
	    if event.type == "InputEventType_FirstPress" then
	       if event.button == "Back" then
		  SCREENMAN:GetTopScreen():Cancel()
	       end
	    end
      end)
      IPCOpenEditor()
      SCREENMAN:GetTopScreen():Cancel()
   end,
   LoadFont("Common Large") .. {
      InitCommand = function(self)
	 self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
	 self:zoom(0.85)
	 self:settext("Attempting to open your editor..\nPress <Back> if you're stuck here.")
	 self:Center()
      end
   }
}
