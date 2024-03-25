-- Everything relating to the gameplay screen is gradually moved to WifeJudgmentSpotting.lua
local inReplay = GAMESTATE:GetPlayerState():GetPlayerController() == "PlayerController_Replay"
local inCustomize = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomizeGameplay
local isPractice = GAMESTATE:IsPracticeMode()

if not inReplay and not inCustomize and not isPractice then
	Arch.setCursorVisible(false)
end

local t = Def.ActorFrame {}
t[#t + 1] = LoadActor("WifeJudgmentSpotting")
t[#t + 1] = LoadActor("leaderboard")
if inReplay then
	t[#t + 1] = LoadActor("replayscrolling")
end

local snm = Var("LoadingScreen")
if snm ~= nil and snm == "ScreenGameplaySyncMachine" then
	local fading = themeConfig:get_data().global.FadeNoteFieldInSyncMachine
	if fading then
		local status = 0
		local maxstatus = 3 -- when status hits this fade the notefield to 0
		local judgeThreshold = Enum.Reverse(TapNoteScore)[ComboContinue()]
		local notdoingit = true
		t[#t+1] = Def.ActorFrame {
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
end

return t
