local t = Def.ActorFrame {}

t[#t+1] = LoadActor(THEME:GetPathG("", "_crashUploadOptIn"))

t[#t+1] = Def.Actor {
   CodeMessageCommand = function(self, params)
      if params.Name == "LoadKitsuneIPC" then
	 SeedPRNG()
	 local choice = RandomNumber(1, 5)
	 choice = tostring(choice)
	 SOUND:PlayOnce(THEME:GetPathS("Common", "secret"..choice), true)
	 SCREENMAN:GetTopScreen():SetNextScreenName("ScreenNewOptions")
	 SCREENMAN:GetTopScreen():PostScreenMessage("SM_GoToNextScreen", 0)
      end
   end
}

return t
