local allowedCustomization = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomizeGameplay
local targetTrackerMode = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).TargetTrackerMode

--[[~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 					    	**Player Target Differential: Ghost target rewrite, average score gone for now**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Point differential to AA.
]]
-- Mostly clientside now. We set our desired target goal and listen to the results rather than calculating ourselves.
local target = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).TargetGoal
GAMESTATE:GetPlayerState():SetTargetGoal(target / 100)

-- We can save space by wrapping the personal best and set percent trackers into one function, however
-- this would make the actor needlessly cumbersome and unnecessarily punish those who don't use the
-- personal best tracker (although everything is efficient enough now it probably wouldn't matter)

-- moved it for better manipulation
local t =
	Def.ActorFrame {
	Name = "TargetTracker",
	InitCommand = function(self)
		if (allowedCustomization) then
			Movable.DeviceButton_7.element = self
			Movable.DeviceButton_8.element = self
			Movable.DeviceButton_7.condition = true
			Movable.DeviceButton_8.condition = true
		end
		self:xy(MovableValues.TargetTrackerX, MovableValues.TargetTrackerY):zoom(MovableValues.TargetTrackerZoom)
	end,
}

-- to avoid repeating ourselves
local function prepareDiffBox(self)
   self:halign(0):valign(1)
   if allowedCustomization then
      self:settextf("%5.2f (%5.2f)", -100, 100)
   end
   self:settextf("")
end

if targetTrackerMode == 0 then
	t[#t + 1] =
		LoadFont("Common Normal") ..
		{
			Name = "PercentDifferential",
			InitCommand = prepareDiffBox,
			SpottedOffsetCommand = function(self)
				if tDiff >= 0 then
				   self:diffuse(positive)
				else
				   self:diffuse(negative)
				end
				self:settextf("%5.2f (%5.2f)", tDiff, target)
			end
		}
else
	t[#t + 1] =
		LoadFont("Common Normal") ..
		{
			Name = "PBDifferential",
			InitCommand = prepareDiffBox,
			SpottedOffsetCommand = function(self, msg)
				if pbtarget then
					if tDiff >= 0 then
						self:diffuse(color("#00ff00"))
					else
						self:diffuse(getMainColor("negative"))
					end
					self:settextf("%5.2f (%5.2f)", tDiff, pbtarget * 100)
				else
					if tDiff >= 0 then
						self:diffuse(getMainColor("positive"))
					else
						self:diffuse(getMainColor("negative"))
					end
					self:settextf("%5.2f (%5.2f)", tDiff, target)
				end
			end
		}
end

return t
