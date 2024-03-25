-- User Parameters
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
local jdgT = {
   -- Table of judgments for the judgecounter
   "TapNoteScore_W1",
   "TapNoteScore_W2",
   "TapNoteScore_W3",
   "TapNoteScore_W4",
   "TapNoteScore_W5",
   "TapNoteScore_Miss",
}
local jdgCounts = {} -- Child references for the judge counter
local spacing = 10 -- Spacing between the judgetypes
local frameWidth = 60 -- Width of the Frame
local frameHeight = ((#jdgT + 1) * spacing) -- Height of the Frame
local judgeFontSize = 0.40 -- Font sizes for different text elements
local countFontSize = 0.35
local gradeFontSize = 0.45
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--

local j =
	Def.ActorFrame {
	Name = "JudgeCounter",
	InitCommand = function(self)
		if (allowedCustomization) then
			Movable.DeviceButton_p.element = self
			Movable.DeviceButton_p.condition = true
		end
		self:xy(MovableValues.JudgeCounterX, MovableValues.JudgeCounterY)
	end,
	OnCommand = function(self)
		for i = 1, #jdgT do
			jdgCounts[jdgT[i]] = self:GetChild(jdgT[i])
		end
	end,
	SpottedOffsetCommand = function(self)
		if jdgCur and jdgCounts[jdgCur] ~= nil then
			jdgCounts[jdgCur]:settext(jdgct)
		end
	end,
}

local function makeJudgeText(judge, index) -- Makes text
	return LoadFont("Common normal") ..
		{
			InitCommand = function(self)
				self:xy(-frameWidth / 2 + 5, -frameHeight / 2 + (index * spacing)):zoom(judgeFontSize):halign(0)
			end,
			OnCommand = function(self)
				self:settext(getShortJudgeStrings(judge))
				self:diffuse(1,1,1,0)
			end
		}
end

local function makeJudgeCount(judge, index) -- Makes county things for taps....
	return LoadFont("Common Normal") ..
		{
			Name = judge,
			InitCommand = function(self)
				self:xy(frameWidth / 2 - 5, -frameHeight / 2 + (index * spacing)):zoom(countFontSize):halign(1):settext(0)
			end,
			PracticeModeResetMessageCommand= function(self)
				self:settext(0)
			end
		}
end

-- Build judgeboard
for i = 1, #jdgT do
	t[#j + 1] = makeJudgeText(jdgT[i], i)
	t[#j + 1] = makeJudgeCount(jdgT[i], i)
end

return t
