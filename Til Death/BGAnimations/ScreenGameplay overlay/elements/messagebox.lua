local isPractice = GAMESTATE:IsPracticeMode()
local isReplay = GAMESTATE:GetPlayerState():GetPlayerController() == "PlayerController_Replay"
local pc

local function transStr(line)
	return THEME:GetString("CustomizeGameplay", line)
end

local function getFromPC(key)
   pc = playerConfig:get_data(pn_to_profile_slot(PLAYER_1))
   local ret = pc[key]
   if ret then
      return ret
   end
   return nil
end

local lb = getFromPC("leaderboardEnabled") and DLMAN:IsLoggedIn()

return Def.ActorFrame {
	OnCommand = function(self)
		if SCREENMAN:GetTopScreen():GetName() == "ScreenGameplaySyncMachine" then 
			self:visible(false)
		end
		SCREENMAN:GetTopScreen():AddInputCallback(MovableInput)
	end,
	OffCommand = function(self)
		-- save CustomizeGameplay changes when leaving the screen
		playerConfig:save(pn_to_profile_slot(PLAYER_1))
	end,
	Def.BitmapText {
		Name = "message",
		Font = "Common Normal",
		InitCommand = function(self)
			Movable.message = self
			self:horizalign(left):vertalign(top):shadowlength(2):xy(10, 20):zoom(.5):visible(false)
		end
	},
	Def.BitmapText {
		Name = "Instructions",
		Font = "Common Normal",
		InitCommand = function(self)
			self:horizalign(left):vertalign(top):xy(SCREEN_WIDTH - 240, 20):zoom(.375):visible(true)
		end,
		OnCommand = function(self)
			local text = {
				transStr("InstructionAutoplay"),
				transStr("InstructionPressKeys"),
				transStr("InstructionCancel"),

				(getFromPC("JudgmentText") and "1: "..transStr("JudgmentPosition") or ""),
				(getFromPC("JudgmentText") and "2: "..transStr("JudgmentSize") or ""),

				(getFromPC("ComboText") and "3: "..transStr("ComboPosition") or ""),
				(getFromPC("ComboText") and "4: "..transStr("ComboSize") or ""),

				(errorBarPresent and "5: "..transStr("ErrorBarPosition") or ""),
				(errorBarPresent and "6: "..transStr("ErrorBarSize") or ""),

				(getFromPC("TargetTracker") and "7: "..transStr("TargetTrackerPosition") or ""),
				(getFromPC("TargetTracker") and "8: "..transStr("TargetTrackerSize") or ""),

				(getFromPC("FullProgressBar") and "9: "..transStr("FullProgressBarPosition") or ""),
				(getFromPC("FullProgressBar") and "0: "..transStr("FullProgressBarSize") or ""),

				(getFromPC("MiniProgressBar") and "q: "..transStr("MiniProgressBarPosition") or ""),

				(getFromPC("DisplayPercent") and "w: "..transStr("DisplayPercentPosition") or ""),
				(getFromPC("DisplayPercent") and "e: "..transStr("DisplayPercentSize") or ""),

				-- not movable
				"r: "..transStr("NotefieldPosition"),
				"t: "..transStr("NotefieldSize"),

				(getFromPC("NPSDisplay") and "y: "..transStr("NPSDisplayPosition") or ""),
				(getFromPC("NPSDisplay") and "u: "..transStr("NPSDisplaySize") or ""),

				(getFromPC("NPSGraph") and "i: "..transStr("NPSGraphPosition") or ""),
				(getFromPC("NPSGraph") and "o: "..transStr("NPSGraphSize") or ""),

				(getFromPC("JudgeCounter") and "p: "..transStr("JudgeCounterPosition") or ""),

				(lb and "a: "..transStr("LeaderboardPosition") or ""),
				(lb and "s: "..transStr("LeaderboardSize") or ""),
				(lb and "d: "..transStr("LeaderboardSpacing") or ""),

				(isReplay and "f: "..transStr("ReplayButtonPosition") or ""),
				(isReplay and "h: "..transStr("ReplayButtonSpacing") or ""),

				-- not movable
				"j: "..transStr("LifebarPosition"),
				"k: "..transStr("LifebarSize"),
				"l: "..transStr("LifebarRotation"),
				"x: "..transStr("BPMPosition"),
				"c: "..transStr("BPMSize"),
				"v: "..transStr("RatePosition"),
				"b: "..transStr("RateSize"),
				"n: "..transStr("NotefieldSpacing"),

				(getFromPC("DisplayMean") and "m: "..transStr("MeanPosition") or ""),
				(getFromPC("DisplayMean") and ",: "..transStr("MeanSize") or ""),
			}
			if playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).LaneCover ~= 0 then
				local selectStr = THEME:GetString("GameButton", "Select")
				table.insert(text, selectStr..": "..transStr("LaneCoverHeight"))
			end
			if isPractice then
				table.insert(text, "z: "..transStr("DensityGraphPosition"))
			end
			local finaltext = ""
			for _, s in ipairs(text) do
			   if s ~= "" then
			      if finaltext == "" then
				 finaltext = finaltext..s
			      else
				 finaltext = finaltext.."\n"..s
			      end
			   end
			end
			self:settext(finaltext)
		end
	}
}
