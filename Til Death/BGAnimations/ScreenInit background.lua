local t = Def.ActorFrame {}

CurrentTidbit = "ScreenInit"

SeedPRNG()

local nymTab = shuffle(QUOTES.Minanyms)

local text = "Created by " .. nymTab[RandomNumber(#nymTab)]

t[#t + 1] =
	Def.Quad {
	InitCommand = function(self)
		self:xy(0, 0):halign(0):valign(0):zoomto(SCREEN_WIDTH, SCREEN_HEIGHT):diffuse(color("#111111")):diffusealpha(0):linear(
			1
		):diffusealpha(1):sleep(1.75):linear(2):diffusealpha(0)
	end
}

--Theme logo
t[#t + 1] = Def.ActorFrame {
	InitCommand=function(self)
		self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y-16):zoom(0.7)
		self:diffusealpha(0)
	end,
	OnCommand=function(self)
	   self:sleep(0.5):linear(0.5):diffusealpha(1)
	   self:sleep(1):linear(3):diffuse(color("#111111")):diffusealpha(0)
	end,
	Def.Quad {
	   InitCommand=function(self)
	      self:zoomto(15,2)
	      self:addx(-15)
	      self:addy(-15)
	      self:addrotationz(8)
	   end
	},
	Def.Quad {
	   InitCommand=function(self)
	      self:zoomto(15,2)
	      self:addx(15)
	      self:addy(-15)
	      self:addrotationz(-8)
	   end
	},
	LoadFont("Common normal") .. {
	   InitCommand=function(self)
	      self:zoom(1)
	      self:settext("w")
	   end
	}
}

t[#t + 1] =
Def.ActorFrame {
	InitCommand = function(self)
		self:Center()
	end,
	Def.ActorFrame {
		OnCommand = function(self)
			self:playcommandonchildren("ChildrenOn")
		end,
		ChildrenOnCommand = function(self)
			self:diffusealpha(0):sleep(0.5):linear(0.5):diffusealpha(1)
		end,
		LoadFont("Common Normal") .. {
				Text = text,
				InitCommand = function(self)
					self:y(16):zoom(0.75):maxwidth(SCREEN_WIDTH)
				end,
				OnCommand = function(self)
					self:sleep(1):linear(3):diffuse(color("#111111")):diffusealpha(0)
				end
		}
	}
}

return t
