local hoverAlpha = 0.6

local t = Def.ActorFrame {
	BeginCommand = function(self)
		-- DAIIIDAIDAIDAIDAIDAIDAI KIRAII
		--   (was code that enabled the mouse)
		--   -kurulen
		setenv("NewOptions","Main")
	end
}

t[#t + 1] = Def.Actor {
	CodeMessageCommand = function(self, params)
		if params.Name == "AvatarShow" and getTabIndex() == 0 and not SCREENMAN:get_input_redirected(PLAYER_1) then
			SCREENMAN:SetNewScreen("ScreenAssetSettings")
		end
	end,
	OnCommand = function(self)
		inScreenSelectMusic = true
	end,
	EndCommand = function(self)
		inScreenSelectMusic = nil
	end,
}

t[#t + 1] = LoadActor("../_frame")
t[#t + 1] = LoadActor("../_PlayerInfo")

t[#t + 1] = LoadActor("currentsort")
t[#t + 1] = UIElements.TextToolTip(1, 1, "Common Large") .. {
	Name="rando",
	InitCommand = function(self)
		self:xy(5, 32):halign(0):valign(1):zoom(0.55):diffuse(getMainColor("positive"))
		self:settextf("%s:", THEME:GetString("ScreenSelectMusic", "Title"))
	end,
	MouseOverCommand = function(self)
		self:diffusealpha(hoverAlpha)
	end,
	MouseOutCommand = function(self)
		self:diffusealpha(1)
	end,
	MouseDownCommand = function(self, params)
		if params.event == "DeviceButton_left mouse button" then
			local w = SCREENMAN:GetTopScreen():GetMusicWheel()

			if INPUTFILTER:IsShiftPressed() and self.lastlastrandom ~= nil then

				-- if the last random song wasnt filtered out, we can select it
				-- so end early after jumping to it
				if w:SelectSong(self.lastlastrandom) then
					return
				end
				-- otherwise, just pick a new random song
			end

			local t = w:GetSongs()
			if #t == 0 then return end
			local random_song = t[math.random(#t)]
			w:SelectSong(random_song)
			self.lastlastrandom = self.lastrandom
			self.lastrandom = random_song
		end
	end
}

updateDiscordStatusForMenus()
updateNowPlaying()

return t
