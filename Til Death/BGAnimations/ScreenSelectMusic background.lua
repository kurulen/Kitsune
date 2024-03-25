errorBarPresent = false
CurrentTidbit = "ScreenSelectMusic"
CurrentSubTidbit = ""

local t = Def.Quad {
   InitCommand = function(self)
      self:FullScreen()
      self:diffuse(getMainColor("frames"))
   end
}

return t
