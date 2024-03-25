local t = Def.ActorFrame{ }

t[#t+1] = Def.Quad {
	InitCommand = function(self)
		local profileName = GetPlayerOrMachineProfile(PLAYER_1):GetDisplayName()
		if profileName == "Default Profile" or profileName == "" then
			self:zoomto(SCREEN_WIDTH-250,160):Center():addy(-18)
		else
			self:zoomto(SCREEN_WIDTH-250,140):Center():addy(-8)
		end
		self:diffuse(0,0,0,0)
	end,
	OnCommand = function(self)
		if inScreenSelectMusic then
			self:decelerate(0.1):diffusealpha(0.8)
		end
	end,
	OffCommand = function(self)
		self:decelerate(0.1):diffusealpha(0)
	end
}

return t
