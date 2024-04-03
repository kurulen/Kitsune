-- Initial code made by Creo (0x.creo).

-- Table that keeps track of all judgments.
local JudgePoints = {}

-- Amount of CB judgments in the file.
local CBs = 0

local Mode = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).Restrictor
local ModeFuncs = {
   function() end,
   function()
      -- SDCB: No more than 9 CBs are allowed.
      if CBs>9 then
	 RestartGameplay()
      end
   end,
   function()
      -- SDG: No more than 9 Goods are allowed, and no CBs either.
      if JudgePoints[3] > 9 or CBs > 0 then
	 RestartGameplay()
      end
   end,
   function()
      -- FC: No CBs.
      if CBs > 0 then
	 RestartGameplay()
      end
   end,
   function()
      -- PFC: No judgments below Perfect.
      if JudgePoints[3] > 0 or CBs > 0 then
	 RestartGameplay()
      end
   end,
   function()
      -- MFC: No judgments below Marvelous.
      if JudgePoints[2] > 0 or CBs > 0 then
	 RestartGameplay()
      end
   end,
}

for i,v in pairs(NSToJudgeTierEnum) do
   JudgePoints[v]=0
end

return Def.ActorFrame {
   JudgmentMessageCommand = function(self, params)
      pcall(function(params, CBs, Mode, ModeFuncs)
	    local jdg = nil
	    if params.TapNoteScore == nil then
	       jdg = NSToJudgeTierEnum[params.HoldNoteScore]
	    else
	       jdg = NSToJudgeTierEnum[params.TapNoteScore]
	    end
	    JudgePoints[jdg] = JudgePoints[jdg] + 1
	    
	    -- If the judgment is a CB, increment the CBs value.
	    if jdg > 4 then
	       CBs = CBs + 1
	    end
	    
	    -- Run restart eval function depending on mode.
	    ModeFuncs[Mode]()
      end, params, CBs, Mode, ModeFuncs)
   end
}
