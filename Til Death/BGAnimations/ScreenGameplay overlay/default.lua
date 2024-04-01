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
   t[#t+1] = LoadActor("elements/syncmachine")
end

return t
