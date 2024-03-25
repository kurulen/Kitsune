local t = Def.ActorFrame {}

local function genKeyboard()
   local base = 32
   local spacing = base + 8
   local ret = Def.ActorFrame {
      ShowKBHelpsMessageCommand = function(self)
	 self:xy(SCREEN_RIGHT*0.11925, -SCREEN_BOTTOM*0.05)
	 self:GetParent():GetChild("KBHelpBG"):visible(true)
	 self:GetParent():GetChild("KBHelpText"):visible(true)
	 self:RunCommandsOnChildren(function(self) self:RunCommandsOnChildren(function(self) self:visible(true) end) end)
      end,
      HideKBHelpsMessageCommand = function(self)
	 self:GetParent():GetChild("KBHelpBG"):visible(false)
	 self:GetParent():GetChild("KBHelpText"):visible(false)
	 self:RunCommandsOnChildren(function(self) self:RunCommandsOnChildren(function(self) self:visible(false) end) end)
      end,
      PressBitsChangedMessageCommand = function(self, params)
	 if params.Bits[1] == true then
	    self:GetChild("Key5.1"):GetChild("Quad"):diffuse(getMainColor("highlight"))
	 else
	    self:GetChild("Key5.1"):GetChild("Quad"):diffuse(getMainColor("positive"))
	 end
	 if params.Bits[2] == true then
	    self:GetChild("Key4.1"):GetChild("Quad"):diffuse(getMainColor("highlight"))
	 else
	    self:GetChild("Key4.1"):GetChild("Quad"):diffuse(getMainColor("positive"))
	 end
      end
   }

   local keyNames = {
      {"`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "bksp"},
      {"tab", "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "\\"},
      {"esc", "a", "s", "d", "f", "g", "h", "j", "k", "l", ";", "'"},
      {"shft", "z", "x", "c", "v", "b", "n", "m", ",", ".", "/", "entr"},
      {"ctrl", "alt", "win", "s-", "-p-", "-a-", "-c-", "-e", "<", "v", "^", ">"}
   }
   local getLayerMap = function(bits)
      local empty = {"_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_"}
      local default = {empty, empty, empty, empty, empty}
      if bits == "00" then
	 if CurrentTidbit == "ScreenTitleMenu" then
	    return {
	       empty,
	       empty,
	       empty,
	       empty,
	       {"_", "_", "_", "play\nmusic", "play\nmusic", "play\nmusic", "play\nmusic", "play\nmusic", "_", "_", "_", "_"}
	    }
	 else return default end
      elseif bits == "10" then
	 if CurrentSubTidbit == "SuperScoreboard" then
	    return {
	       {"_", "prev\nscore", "next\nscore", "toggle\nscore\nfilter", "valid\nscores\nonly", "current\nrate\nonly", "_", "_", "_", "_", "_", "_"},
	       empty,
	       empty,
	       empty,
	       empty
	    }
	 elseif CurrentSubTidbit == "LocalScoreboard" then
	    return {
	       {"_", "prev\nscore", "next\nscore", "upload\nall\nchart\nscores", "upload\nall\nprofile\nscores", "upload\nscore\nreplay\ndata", "_", "_", "_", "_", "_", "_"},
	       empty,
	       empty,
	       empty,
	       empty
	    }
	 elseif CurrentSubTidbit == "GoalDisplay" then
	    return {
	       {"_", "prev\ngoal", "next\ngoal", "tp\nto\ngoal", "sort\nby\nrate", "sort\nby\ntitle", "_", "_", "_", "_", "_", "_"},
	       empty,
	       empty,
	       empty,
	       empty
	    }
	 elseif CurrentTidbit == "ScreenSelectMusic" then
	    return {
	       {"_", "_", "_", "_", "rename\nprofile", "_", "_", "_", "_", "_", "_", "_"},
	       {"_", "_", "_", "pause\nmusic", "reload\npacks", "_", "open\nplayer\noptions", "toggle\nforce\nstart", "_", "_", "_", "login\nor\nlogout"},
	       {"_", "_", "_", "_", "_", "_", "toggle\nready", "_", "_", "_", "_", "_"},
	       empty,
	       {"_", "_", "_", "toggle\ncalc\ninfo", "toggle\ncalc\ninfo", "toggle\ncalc\ninfo", "toggle\ncalc\ninfo", "toggle\ncalc\ninfo", "_", "_", "_", "_"}
	    }
	 else return default end
      elseif bits == "11" then
	 if CurrentSubTidbit == "SuperScoreboard" then
	    return {
	       {"_", "prev\npage", "next\npage", "open\nuser\npage", "open\nscore\npage", "view\nreplay", "_", "_", "_", "_", "_", "_"},
	       empty,
	       {"_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "volume\nup", "volume\ndown"},
	       empty,
	       {"_", "_", "_", "show\noffset\nplot", "show\noffset\nplot", "show\noffset\nplot", "show\noffset\nplot", "show\noffset\nplot", "_", "_", "_", "_"}
	    }
	 elseif CurrentSubTidbit == "LocalScoreboard" then
	    return {
	       {"_", "prev\nrate", "next\nrate", "upload\nall\npack\nscores", "show\nscore\nscreen", "show\nreplay", "_", "_", "_", "_", "_", "_"},
	       empty,
	       {"_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "volume\nup", "volume\ndown"},
	       empty,
	       {"_", "_", "_", "show\noffset\nplot", "show\noffset\nplot", "show\noffset\nplot", "show\noffset\nplot", "show\noffset\nplot", "_", "_", "_", "_"}
	    }
	 elseif CurrentSubTidbit == "GoalDisplay" then
	    return {
	       {"_", "prev\npage", "next\npage", "sort\nby\ndate", "sort\nby\nmsd", "remove\ngoal", "_", "_", "_", "_", "_", "_"},
	       empty,
	       {"_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "volume\nup", "volume\ndown"},
	       empty,
	       empty
	    }
	 elseif CurrentTidbit == "ScreenSelectMusic" then
	    return {
	       empty,
	       empty,
	       {"_", "_", "_", "_", "_", "_", "shared\npacks\nfilter", "_", "_", "_", "volume\nup", "volume\ndown"},
	       empty,
	       empty
	    }
	 else
	    return {
	       empty,
	       empty,
	       {"_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "volume\nup", "volume\ndown"},
	       empty,
	       empty
	    }
	 end
      else return default end
   end

   for row = 1, 5 do
      for key = 1, 12 do
	 local keyStr = keyNames[row][key].."\n_"
	 ret[#ret + 1] = Def.ActorFrame {
	    Name = ("Key"..tostring(row).."."..tostring(key)),
	    Def.Quad {
	       Name = "Quad",
	       InitCommand = function(self)
		  self:xy( base+(spacing*key), (base+(spacing*row)) * 2)
		  self:zoomto(base, base*2)
		  self:diffuse(getMainColor("positive"))
		  self:visible(false)
	       end
	    },
	    LoadFont("Common Normal") .. {
	       Name = "Text",
	       InitCommand = function(self)
		  self:xy( (base+(spacing*key) - base*0.5) + 16, ((base+(spacing*row)) * 2) - 24+(4*GetLineCount(keyStr)))
		  self:zoom(0.35)
		  self:settext(keyStr)
		  self:diffuse(1,1,1,1)
		  self:visible(false)
	       end,
	       PressBitsChangedMessageCommand = function(self, params)
		  local bits = (params.Bits[1] == true and "1" or "0")..(params.Bits[2] == true and "1" or "0")
		  keyStr = keyNames[row][key].."\n"..getLayerMap(bits)[row][key]
		  self:xy( (base+(spacing*key) - base*0.5) + 16, ((base+(spacing*row)) * 2) - 24+(4*GetLineCount(keyStr)))
		  self:settext(keyStr)
	       end
            }
	 }
      end
   end

   return ret
end

t[#t + 1] = Def.ActorFrame {
   Def.Quad {
      Name = "KBHelpBG",
      InitCommand = function(self)
	 self:visible(false)
	 self:zoomto(SCREEN_WIDTH,SCREEN_HEIGHT)
	 self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
	 self:diffuse(0,0,0,0.85)
      end
   },
   LoadFont("Common Normal") .. {
      Name = "KBHelpText",
      InitCommand = function(self)
	 self:visible(false)
	 self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y * 0.28)
	 self:zoom(0.65)
	 self:diffuse(1,1,1,1)
	 self:settext("Press F1 to dismiss this help screen.\nPress Ctrl and/or Shift to show keybinds.")
      end
   },
   genKeyboard()
}

-- Text
t[#t + 1] = Def.ActorFrame {
	Def.Quad {
		InitCommand = function(self)
			self:zoomto(SCREEN_WIDTH * 0.5, 31):CenterX():diffuse(
				color("0,0,0,0")
			)
		end,
		OnCommand = function(self)
		   self:y(SCREEN_TOP - 30)
		   self:finishtweening():diffusealpha(0.85)
		   self:linear(0.35):addy(60)
		end,
		OffCommand = function(self)
			self:sleep(1.5):linear(1):diffusealpha(0)
		end
	},
	Def.BitmapText {
		Font = "Common Normal",
		Name = "Text",
		InitCommand = function(self)
			self:maxwidth(SCREEN_WIDTH * 0.5):CenterX():diffusealpha(
				0
			)
		end,
		OnCommand = function(self)
		   self:y(SCREEN_TOP - 30)
		   self:finishtweening():diffusealpha(1):zoom(0.5)
		   self:linear(0.35):addy(60)
		end,
		OffCommand = function(self)
			self:sleep(1.5):linear(1):diffusealpha(0)
		end
	},
	SystemMessageMessageCommand = function(self, params)
	   -- prevents our backoff loop from annoying the user
	        if not string.match(params.Message, "Connection to '.*' successful.") then
		   self:GetChild("Text"):settext(params.Message)
		   self:playcommand("On")
		   if params.NoAnimate then
		      self:finishtweening()
		   end
		   self:playcommand("Off")
		end
	end,
	HideSystemMessageMessageCommand = function(self)
		self:finishtweening()
	end
}

-- song reload
local www = 1366 * 0.8
local hhh = SCREEN_HEIGHT * 0.8
local rtzoom = 0.6

local function dooting(self)
	if self:IsVisible() then
		self:GetChild("BGQframe"):queuecommand("dooting")
	end
end

local translated_info = TranslationMatrices["ScreenSystemLayer"]

local dltzoom = 0.5
-- download queue/progress
t[#t + 1] = Def.ActorFrame {
	PausingDownloadsMessageCommand=function(self)
		self:visible(false)
	end,
	ResumingDownloadsMessageCommand=function(self)
		self:visible(false)
	end,
	AllDownloadsCompletedMessageCommand = function(self)
		self:visible(false)
	end,
	DLProgressAndQueueUpdateMessageCommand = function(self)
		self:visible(true)
	end,
	BeginCommand = function(self)
		self:SetUpdateFunction(dooting)
		self:visible(false)
		self:x(www / 8 + 10):y(SCREEN_TOP + hhh / 8 + 10)
	end,
	Def.Quad {
		Name = "BGQframe",
		InitCommand = function(self)
			self:zoomto(www / 4, hhh / 4):diffuse(color("0.1,0.1,0.1,0.8"))
		end,
		dootingCommand = function(self)
			if isOver(self) then
				self:GetParent():x(SCREEN_WIDTH - self:GetParent():GetX())
			end
		end
	},
	Def.BitmapText {
		Font = "Common Normal",
		InitCommand = function(self)
			self:xy(-www / 8 + 10, -hhh / 8):diffusealpha(0.9):settext("#################\n####\n#######"):maxwidth(
				(www / 4 - 20) / dltzoom
			):halign(0):valign(0):zoom(dltzoom)
		end,
		DLProgressAndQueueUpdateMessageCommand = function(self, params)
			self:settextf("%s %s\n%s\n\n%s %s:\n%s",
				params.dlsize,
				translated_info["ItemsDownloading"],
				params.dlprogress,
				params.queuesize,
				translated_info["ItemsLeftInQueue"],
				params.queuedpacks
			)
			self:GetParent():GetChild("BGQframe"):zoomy(self:GetHeight() - hhh / 4 + 10)
		end
	}
}

t[#t + 1] = Def.ActorFrame {
   DFRStartedMessageCommand = function(self)
      self:visible(true)
   end,
   DFRFinishedMessageCommand = function(self, params)
      self:visible(false)
   end,
   BeginCommand = function(self)
      self:visible(false)
      self:x(www / 8 + 10):y(SCREEN_BOTTOM - hhh / 8 - 70)
   end,
   Def.Quad {
      InitCommand = function(self)
	 self:zoomto(www / 4, hhh / 4):diffuse(color("0.1,0.1,0.1,0.8"))
      end
   },
   Def.BitmapText {
      Font = "Common Normal",
      InitCommand = function(self)
	 self:diffusealpha(0.9):settext(""):maxwidth((www / 4 - 40) / rtzoom):zoom(rtzoom)
      end,
      DFRUpdateMessageCommand = function(self, params)
	 self:settext(params.txt)
      end
   }
}

local PreviousVolume = CurrentVolume

t[#t+1] = Def.ActorFrame {
   Name = "Volume",
   InitCommand = function(self)
      self:diffusealpha(0)
      self:SetUpdateFunction(function(self)
	    if CurrentVolume ~= PreviousVolume then
	       PreviousVolume = CurrentVolume
	       self:diffusealpha(1)
	       self:GetChild("TopFill"):cropbottom(CurrentVolume)
	       self:sleep(0.1):diffusealpha(0)
	    end
      end)
   end,
   Def.Quad {
      Name = "BottomFill",
      InitCommand = function(self)
	 self:zoomto(64,256):Center()
	 self:diffuse(getMainColor("positive"))
      end
   },
   Def.Quad {
      Name = "MidFill",
      InitCommand = function(self)
	 self:zoomto(48, 192):Center()
	 self:diffuse(1,1,1,1)
      end
   },
   Def.Quad {
      Name = "TopFill",
      InitCommand = function(self)
	 self:zoomto(48, 192):Center()
	 self:diffuse(getMainColor("positive"))
      end
   }
}

return t
