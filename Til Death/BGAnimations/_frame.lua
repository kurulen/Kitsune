local t = Def.ActorFrame {}
local topFrameHeight = 35
local bottomFrameHeight = 54
local borderWidth = 4

t[#t+1] = Def.ActorFrame {
   --Frames
   Def.Quad {
      InitCommand = function(self)
	 self:xy(0, 0):halign(0):valign(0):zoomto(SCREEN_WIDTH, topFrameHeight):diffuse(getMainColor("frames"))
      end
   },

   Def.Quad {
      InitCommand = function(self)
	 self:xy(0, SCREEN_HEIGHT):halign(0):valign(1):zoomto(SCREEN_WIDTH, bottomFrameHeight):diffuse(getMainColor("frames"))
      end
   },

   --FrameBorders
   Def.Quad {
      InitCommand = function(self)
	 self:xy(0, topFrameHeight):halign(0):valign(1):zoomto(SCREEN_WIDTH, borderWidth):diffuse(0,0,0,1):diffusealpha(1)
      end
   },
   Def.Quad {
      InitCommand = function(self)
	 self:xy(0, topFrameHeight):halign(0):valign(1):zoomto(SCREEN_WIDTH, borderWidth):diffuse(getMainColor("highlight")):diffusealpha(0.5)
      end
   },

   Def.Quad {
      InitCommand = function(self)
	 self:zoomto(4, SCREEN_HEIGHT - topFrameHeight * 2.4)
	 self:xy(1.7, SCREEN_CENTER_Y * 0.96):diffuse(0,0,0,1)
      end
   },
   Def.Quad{
      InitCommand = function(self)
	 self:zoomto(4, SCREEN_HEIGHT - topFrameHeight * 2.4)
	 self:xy(SCREEN_RIGHT - 2, SCREEN_CENTER_Y * 0.96):diffuse(0,0,0,1)
      end
   },
   Def.Quad {
      InitCommand = function(self)
	 self:zoomto(4, SCREEN_HEIGHT - topFrameHeight * 2.4)
	 self:xy(1.7, SCREEN_CENTER_Y * 0.96):diffuse(getMainColor("highlight")):diffusealpha(0.5)
      end
   },
   Def.Quad{
      InitCommand = function(self)
	 self:zoomto(4, SCREEN_HEIGHT - topFrameHeight * 2.4)
	 self:xy(SCREEN_RIGHT - 2, SCREEN_CENTER_Y * 0.96):diffuse(getMainColor("highlight")):diffusealpha(0.5)
      end
   }
}

t[#t+1] = Def.Quad {
   Name = "QuoteBG",
   InitCommand = function(self)
      self:diffuse(0,0,0,0.8)
      self:diffusealpha(0.8)
      self:halign(0)
      self:xy(0, SCREEN_HEIGHT-44)
      self:zoomto(SCREEN_WIDTH, 14)
   end,
   BeginCommand = function(self)
      if string.find(SCREENMAN:GetTopScreen():GetName(), "ScreenColor.*") then
	 self:visible(false)
      end
   end
}

t[#t + 1] = Def.Quad {
	InitCommand = function(self)
		self:xy(0, SCREEN_HEIGHT - bottomFrameHeight):halign(0):valign(0):zoomto(SCREEN_WIDTH, borderWidth):diffuse(0,0,0,1):diffusealpha(1)
	end
}
t[#t + 1] = Def.Quad {
	InitCommand = function(self)
		self:xy(0, SCREEN_HEIGHT - bottomFrameHeight):halign(0):valign(0):zoomto(SCREEN_WIDTH, borderWidth):diffuse(
			getMainColor("highlight")
		):diffusealpha(0.5)
	end
}

return t
