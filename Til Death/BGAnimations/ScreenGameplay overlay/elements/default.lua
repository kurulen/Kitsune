errorBarPresent = false

local t = Def.ActorFrame{}

t[#t+1] = LoadActor("musicrate")
t[#t+1] = LoadActor("bpmdisplay")
t[#t+1] = LoadActor("npscalc")

if playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).TargetTracker then
   t[#t+1] = LoadActor("targettracker")
end
if playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).DisplayPercent then
   t[#t+1] = LoadActor("displaypercent")
end
if playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).DisplayMean then
   t[#t+1] = LoadActor("displaymean")
end
if playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).JudgeCounter then
   t[#t+1] = LoadActor("judgecounter")
end
-- we have to do this check like 200,000 times uggggghhhhhhhhh
-- TODO: make this less hacky
if playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).ErrorBar ~= 0 then
   t[#t+1] = LoadActor("errorbar")
end
if playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).FullProgressBar then
   t[#t+1] = LoadActor("fullprogressbar")
end
if playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).MiniProgressBar then
   t[#t+1] = LoadActor("miniprogressbar")
end
if playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).LaneCover then
   t[#t+1] = LoadActor("lanecover")
end
if playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).PlayerInfo then
   t[#t+1] = LoadActor("playerinfo")
end
if playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomizeGameplay then
   t[#t+1] = LoadActor("messagebox")
end

return t
