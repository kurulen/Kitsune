local fading = themeConfig:get_data().global.FadeNoteFieldInSyncMachine
if fading then
   local status = 0
   local maxstatus = 3 -- when status hits this fade the notefield to 0
   local judgeThreshold = Enum.Reverse(TapNoteScore)[ComboContinue()]
   local notdoingit = true
   return Def.ActorFrame {
      Name = "spooker",
      JudgmentMessageCommand = function(self, params)
	 if params.HoldNoteScore then return end
	 if params.TapNoteScore then
	    local enum  = Enum.Reverse(TapNoteScore)[params.TapNoteScore]
	    status = status + 1
	    if status >= maxstatus and notdoingit then
	       self:playcommand("doit")
	    end
	 end
      end,
      DoneLoadingNextSongMessageCommand = function(self)
	 if not SCREENMAN:GetTopScreen() then return end
	 self:playcommand("nowaitdont")
      end,
      nowaitdontCommand = function(self)
	 if not SCREENMAN:GetTopScreen() then return end
	 notdoingit = true
	 local nf = SCREENMAN:GetTopScreen():GetChild("PlayerP1"):GetChild("NoteField")
	 if nf then
	    self:stoptweening()
	    nf:diffusealpha(1)
	    -- this is the only other line that matters
	    GAMESTATE:GetPlayerState():GetPlayerOptions("ModsLevel_Song"):Stealth(0)
	 end
      end,
      doitCommand = function(self)
	 if not SCREENMAN:GetTopScreen() then return end
	 notdoingit = false
	 pcall(function()
	       local nf = SCREENMAN:GetTopScreen():GetChild("PlayerP1"):GetChild("NoteField")
	       if nf then
		  self:finishtweening()
		  nf:smooth(1)
		  nf:diffusealpha(0)
		  -- this is the only line that matters
		  GAMESTATE:GetPlayerState():GetPlayerOptions("ModsLevel_Song"):Stealth(1)
	       end
	 end)
      end,

      LoadFont("Common Large") .. {
	 Name = "Instruction",
	 InitCommand = function(self)
	    self:settext("Keep tapping\nto the beat!")
	    self:zoom(0.6)
	    self:CenterY():x(SCREEN_LEFT + (SCREEN_CENTER_X/2))
	    self:diffusealpha(0)
	 end,
	 nowaitdontCommand = function(self)
	    self:stoptweening()
	    self:diffusealpha(0)
	 end,
	 doitCommand = function(self)
	    self:finishtweening()
	    self:diffusealpha(0)
	    self:smooth(2)
	    self:diffusealpha(1)
	 end,
      }
   }
end
