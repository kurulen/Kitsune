errorBarPresent = false

local t = Def.ActorFrame{}

local checks = {
   playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).TargetTracker,
   playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).DisplayPercent,
   playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).DisplayMean,
   playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).JudgeCounter,
   (playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).ErrorBar ~= 0),
   playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).FullProgressBar,
   playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).MiniProgressBar,
   playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).LaneCover,
   playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).PlayerInfo,
   (playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).Restrictor ~= "Clear"),
   playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomizeGameplay
}

local names = {
   "targettracker",
   "displaypercent",
   "displaymean",
   "judgecounter",
   "errorbar",
   "fullprogressbar",
   "miniprogressbar",
   "lanecover",
   "playerinfo",
   "restrictor",
   "messagebox"
}

t[#t+1] = LoadActor("musicrate")
t[#t+1] = LoadActor("bpmdisplay")
t[#t+1] = LoadActor("npscalc")

for x, y in zip(checks,names) do
   if x then
      t[#t+1] = LoadActor(y)
   end
end

return t
