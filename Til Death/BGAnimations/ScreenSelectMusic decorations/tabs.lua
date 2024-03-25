local whee

-- for some reason, doing this shit fixes a weird heisenbug that violates all forms of logic
-- if you're trying to fix the bug by looking here, i wish you good luck
local tabNames = {"General", "MSD", "Scores", "Search", "Profile", "Goals", "Playlists", "Packs", "Tags", "null"} -- this probably should be in tabmanager.
local nums = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}

local function input(event)
   if event.type == "InputEventType_FirstPress" and not (INPUTFILTER:IsControlPressed() or
	      (SCREENMAN:GetTopScreen():GetName() ~= "ScreenSelectMusic" and
	       SCREENMAN:GetTopScreen():GetName() ~= "ScreenNetSelectMusic")) then
      for _, x in ipairs(nums) do
	 if event.DeviceInput.button == "DeviceButton_"..x then
	    local tind = getTabIndex()
	    -- prevents attempting to enter any number keys, even with ctrl, on the song search
	    -- this prevents tab switches while entering search strings
	    -- (HACK) (HACK) (HACK) (HACK) (HACK) (HACK) (HACK) (HACK) (HACK) (HACK)
	    -- exception is for ctrl+0, as it toggles the chatbox
	    -- just in case ;D
	    if tind == 3 and not (INPUTFILTER:IsControlPressed() and event.DeviceInput.button == "DeviceButton_0") then
	       return false
	    end
	 end
      end
      for i = 1, #tabNames do
	 local numpad = event.DeviceInput.button == "DeviceButton_KP "..event.char	-- explicitly ignore numpad inputs for tab swapping (doesn't care about numlock) -mina
	 if not numpad and event.char and tonumber(event.char) and tonumber(event.char) == i then
	    local tind = getTabIndex()
	    setTabIndex(i - 1)
	    MESSAGEMAN:Broadcast("TabChanged", {from = tind, to = i-1})
	 end
      end
   end
   return false
end
local t =
	Def.ActorFrame {
	BeginCommand = function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(MPinput)
		SCREENMAN:GetTopScreen():AddInputCallback(input)
		resetTabIndex()
	end,
}

-- hakko
-- subtracting 1 from the amount of tabs for the null tab
local frameWidth = capWideScale(get43size(450), 450) / (#tabNames - 2)
local frameX = frameWidth / 2 + 2
local frameY = SCREEN_HEIGHT - 70

local function tabs(index)
   if tabNames[index] ~= "null" then
	local t = Def.ActorFrame {
		Name = "Tab" .. index,
		InitCommand = function(self)
			self:xy(frameX + ((index - 1) * frameWidth), frameY)
		end,
		BeginCommand = function(self)
			self:queuecommand("Set")
		end,
		SetCommand = function(self)
			self:finishtweening()
			self:smooth(0.1)
			--show tab if it's the currently selected one
			if getTabIndex() == index - 1 then
				self:diffusealpha(1):y(frameY - 1)
				self:GetChild("TabBG"):diffusecolor(Brightness(getMainColor("positive"),0.3)):diffusealpha(0.5)
			else -- otherwise "Hide" them
				self:diffusealpha(0.7):y(frameY)
				self:GetChild("TabBG"):diffusecolor(getMainColor("frames")):diffusealpha(0.7)
			end
		end,
		TabChangedMessageCommand = function(self)
			self:queuecommand("Set")
		end
	}

	t[#t + 1] = Def.Quad {
		Name = "TabBG",
		InitCommand = function(self)
			self:y(2):valign(0):zoomto(frameWidth, 20):diffusecolor(getMainColor("frames")):diffusealpha(0.7)
		end
	}

	t[#t + 1] = LoadFont("Common Normal") .. {
		Name = "TabText",
		InitCommand = function(self)
			self:y(4):valign(0):zoom(0.4):diffuse(getMainColor("positive")):maxwidth(frameWidth * 2)
		end,
		BeginCommand = function(self)
			self:queuecommand("Set")
		end,
		SetCommand = function(self)
			self:settext(THEME:GetString("TabNames", tabNames[index]))
			if isTabEnabled(index) then
				if index == 6 and FILTERMAN:AnyActiveFilter() then
					self:diffuse(color("#cc2929"))
				else
					self:diffuse(getMainColor("positive"))
				end
			else
				self:diffuse(color("#666666"))
			end
		end
	}
	return t
   end
end

--Make tabs
for i = 1, #tabNames do
	t[#t + 1] = tabs(i)
end

return t
