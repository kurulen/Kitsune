local function input(event)
   if event.type == "InputEventType_FirstPress" then
      if event.button == "Back" then
	 SCREENMAN:GetTopScreen():Cancel()
      end
   end
end

local t = Def.ActorFrame{
   OnCommand = function(self)
      SCREENMAN:GetTopScreen():AddInputCallback(input)
   end
}

local function generateOptionRows(filename)
   local ret = Def.ActorFrame {
      
   }
end

t[#t+1] = generateOptionRows(THEME:GetPathO("ScreenNewOptions", "rows"))

t[#t+1] = LoadActor("_frame")

t[#t + 1] = LoadFont("Common Large") .. {
   InitCommand = function(self)
      self:xy(5, 32):halign(0):valign(1):zoom(0.55):diffuse(getMainColor("highlight"))
	  :settext(THEME:GetString("ScreenNewOptions", "Title"))
   end
}

return t
