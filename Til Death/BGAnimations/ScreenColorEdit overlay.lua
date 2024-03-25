local selected = getTableKeys()
local themeColor = colorConfig:get_data()[selected[1]][selected[2]]

local translated_info = TranslationMatrices["ScreenColorEdit"]

local colorBoxHeight = GetScreenAspectRatio() == 1 and 175 or 250
local saturationSliderWidth = 25
local genericSpacing = 15
local saturationOverlay = nil
local saturationSliderPos = nil
local colorPickPosition = nil
local colorPreview = nil
local aboutToSave = false

local satNum = 0 -- saturation percent
local hueNum = 0 -- degrees 0-360 exclusive
local valNum = 0 -- brightness percent
local alphaNum = 1 -- alpha percent
local currentColor = color("1,1,1")
local hexEntryString = "#"
local textCursorPos = 2

local function colorToHSV(color)
	local r = color[1]
	local g = color[2]
	local b = color[3]
	local cmax = math.max(r, g, b)
	local cmin = math.min(r, g, b)
	local dc = cmax - cmin -- delta c
	local h = 0
	if dc == 0 then
		h = 0
	elseif cmax == r then
		h = 60 * (((g-b)/dc) % 6)
	elseif cmax == g then
		h = 60 * (((b-r)/dc) + 2)
	elseif cmax == b then
		h = 60 * (((r-g)/dc) + 4)
	end
	local s = (cmax == 0 and 0 or dc / cmax)
	local v = cmax

	local alpha = (color[4] and color[4] or 1)

	return h, 1-s, 1-v, alpha
end

local function applyHSV()
	local newColor = HSV(hueNum, 1 - satNum, 1 - valNum)
	newColor[4] = alphaNum
	currentColor = newColor

	textCursorPos = 7
	hexEntryString = "#" .. ColorToHex(currentColor)

	MESSAGEMAN:Broadcast("ClickedNewColor")
end

-- set up the initial current color stuff
hueNum, satNum, valNum, alphaNum = colorToHSV(color(themeColor))

local function updateSaturation(percent)
	if percent < 0 then percent = 0 elseif percent > 1 then percent = 1 end

	satNum = percent
	applyHSV()
end

local function updateAlpha(percent)
	if percent < 0 then percent = 0 elseif percent > 1 then percent = 1 end

	alphaNum = 1 - percent
	applyHSV()
end

local function updateColor(percentX, percentY)
	if percentY < 0 then percentY = 0 elseif percentY > 1 then percentY = 1 end
	if percentX < 0 then percentX = 0 elseif percentX > 1 then percentX = 1 end

	hueNum = 360 * percentX
	valNum = percentY
	applyHSV()
end

local function getRotationZ(self)
	local parent = self:GetParent()
	if parent == nil then
		return self:GetRotationZ()
	else
		return self:GetRotationZ() + getRotationZ(parent)
	end
end

-- find the x position for a char in text relative to text left edge
local function getXPositionInText(self, index)
	local overallWidth = self:GetZoomedWidth()
	local tlChar1 = self:getGlyphRect(1) -- top left vertex of first char in text
	local tlCharIndex = self:getGlyphRect(index) -- top left of char at text
	-- the [1] index is the x coordinate of the vertex

	local theX = tlCharIndex[1] - tlChar1[1]

	return theX * self:GetZoom()
end

local function getWidthOfChar(self, index)
	local tl, bl, tr, br = self:getGlyphRect(index)
	local glyphWidth = tr[1] - bl[1]

	return glyphWidth / (self:GetZoom() * 10) -- im not really sure why this works
end

local function cursorCanMove(speed)

	local maxTextSize = (#hexEntryString == 7 and 7 or #hexEntryString + 1)

	local tmpCursor = textCursorPos + speed
	if tmpCursor > maxTextSize or tmpCursor < 2 then
		return 0
	end

	return speed
end

local function colorToRGBNums(c)
	local r = c[1]
	local g = c[2]
	local b = c[3]
	local a = HasAlpha(c)

	local rX = scale(r, 0, 1, 0, 255)
	local gX = scale(g, 0, 1, 0, 255)
	local bX = scale(b, 0, 1, 0, 255)
	local aX = scale(a, 0, 1, 0, 255)

	return rX, gX, bX, aX
end

local function handleHexEntry(character)
	character = character:upper()

	if #hexEntryString <= 7 then -- #23 45 67 89 format
		if #hexEntryString == 7 and textCursorPos == 7 then
			hexEntryString = hexEntryString:sub(1,-2) .. character
		else
			if textCursorPos == #hexEntryString + 1 then
				hexEntryString = hexEntryString .. character
			else
				local left = hexEntryString:sub(1,textCursorPos-1)
				local right = hexEntryString:sub(textCursorPos+1)
				hexEntryString = left .. character .. right
			end
			textCursorPos = textCursorPos + 1
		end
	end
	if textCursorPos > 7 then textCursorPos = 7 end

	aboutToSave = false
	MESSAGEMAN:Broadcast("UpdateStringDisplay")
end

local function handleTextUpdate()
	local hxl = #hexEntryString - 1
	local finalcolor = color("1,1,1,1")

	if hxl == 3 or hxl == 4 or hxl == 5 then -- color 3/4/5 hex
		finalcolor[1] = tonumber("0x"..hexEntryString:sub(2,2)) / 15
		finalcolor[2] = tonumber("0x"..hexEntryString:sub(3,3)) / 15
		finalcolor[3] = tonumber("0x"..hexEntryString:sub(4,4)) / 15
		if hxl == 4 then finalcolor[4] = tonumber("0x"..hexEntryString:sub(5,5)) / 15 end
		if hxl == 5 then finalcolor[4] = tonumber("0x"..hexEntryString:sub(5,6)) / 255 end
	elseif hxl == 6 or hxl == 7 or hxl == 8 then -- color 6/7/8 hex
		finalcolor[1] = tonumber("0x"..hexEntryString:sub(2,3)) / 255
		finalcolor[2] = tonumber("0x"..hexEntryString:sub(4,5)) / 255
		finalcolor[3] = tonumber("0x"..hexEntryString:sub(6,7)) / 255
		if hxl == 7 then finalcolor[4] = tonumber("0x"..hexEntryString:sub(7,7)) / 15 end
		if hxl == 8 then finalcolor[4] = tonumber("0x"..hexEntryString:sub(8,9)) / 255 end
	else
		return
	end

	local r = finalcolor[1] -- [0,1]
	local g = finalcolor[2]
	local b = finalcolor[3]
	local cmax = math.max(r, g, b)
	local cmin = math.min(r, g, b)
	local dc = cmax - cmin -- delta c
	local h = 0
	if dc == 0 then
		h = 0
	elseif cmax == r then
		h = 60 * (((g-b)/dc) % 6)
	elseif cmax == g then
		h = 60 * (((b-r)/dc) + 2)
	elseif cmax == b then
		h = 60 * (((r-g)/dc) + 4)
	end
	local s = (cmax == 0 and 0 or dc / cmax)
	local v = cmax

	hueNum, satNum, valNum, alphaNum = colorToHSV(finalcolor)

	aboutToSave = true
	applyHSV()
end

local function inputeater(event)
	if event.type == "InputEventType_FirstPress" then
		if event.char and event.char:match('[%x]') then -- match all hex
			handleHexEntry(event.char)
		elseif event.DeviceInput.button == "DeviceButton_backspace" then
			if INPUTFILTER:IsControlPressed() then
				local default = getDefaultColorForCurColor()
				hueNum, satNum, valNum, alphaNum = colorToHSV(color(default))
				aboutToSave = false
				applyHSV()
			elseif INPUTFILTER:IsBeingPressed("right alt") or INPUTFILTER:IsBeingPressed("left alt") then
				hueNum, satNum, valNum, alphaNum = colorToHSV(color(themeColor))
				aboutToSave = false
				applyHSV()
			elseif #hexEntryString > 1 then
				if textCursorPos - 1 == #hexEntryString then
					hexEntryString = hexEntryString:sub(1, -2)
				else
					local left = hexEntryString:sub(1,textCursorPos-1)
					local right = hexEntryString:sub(textCursorPos+1)
					hexEntryString = left .. "0" .. right
				end
				textCursorPos = textCursorPos + cursorCanMove(-1)
				aboutToSave = false
			end
			MESSAGEMAN:Broadcast("UpdateStringDisplay")
		elseif event.button == "Left" or event.button == "MenuLeft" then
			local before = textCursorPos
			textCursorPos = textCursorPos + cursorCanMove(-1)
			if before ~= textCursorPos then
				MESSAGEMAN:Broadcast("UpdateStringDisplay")
			end
		elseif event.button == "Right" or event.button == "MenuRight" then
			local before = textCursorPos
			textCursorPos = textCursorPos + cursorCanMove(1)
			if before ~= textCursorPos then
				MESSAGEMAN:Broadcast("UpdateStringDisplay")
			end
		elseif event.button == "Up" or event.button == "MenuUp" then
			if textCursorPos <= #hexEntryString then
				local numInIndex = tonumber("0x"..hexEntryString:sub(textCursorPos,textCursorPos))
				numInIndex = numInIndex + 1
				if numInIndex > 15 then numInIndex = 0 end
				local theCharacter = ("%X"):format(numInIndex)

				local left = hexEntryString:sub(1,textCursorPos-1)
				local right = hexEntryString:sub(textCursorPos+1)
				hexEntryString = left .. theCharacter .. right
				aboutToSave = false
				MESSAGEMAN:Broadcast("UpdateStringDisplay")
			end
		elseif event.button == "Down" or event.button == "MenuDown" then
			if textCursorPos <= #hexEntryString then
				local numInIndex = tonumber("0x"..hexEntryString:sub(textCursorPos,textCursorPos))
				numInIndex = numInIndex - 1
				if numInIndex < 0 then numInIndex = 15 end
				local theCharacter = ("%X"):format(numInIndex)

				local left = hexEntryString:sub(1,textCursorPos-1)
				local right = hexEntryString:sub(textCursorPos+1)
				hexEntryString = left .. theCharacter .. right
				aboutToSave = false
				MESSAGEMAN:Broadcast("UpdateStringDisplay")
			end
		elseif event.button == "Back" then
			SCREENMAN:GetTopScreen():Cancel()
		elseif event.button == "Start" then
			if aboutToSave then
				colorConfig:get_data()[selected[1]][selected[2]] = "#" .. ColorToHex(currentColor)
				colorConfig:set_dirty()
				colorConfig:save()
				MESSAGEMAN:Broadcast("RowChanged", {level=1})
				THEME:ReloadMetrics()
				SCREENMAN:GetTopScreen():Cancel()
			else
				handleTextUpdate()
			end
		elseif event.DeviceInput.button == "DeviceButton_p"
		   and INPUTFILTER:IsControlPressed() and INPUTFILTER:IsShiftPressed() then
		   GAMESTATE:ApplyGameCommand("urlnoexit,https://colorpicker.me/"..hexEntryString)
		elseif event.DeviceInput.button == "DeviceButton_v"
		   and INPUTFILTER:IsControlPressed() then
		   hexString = Arch.getClipboard()
		   -- validate that our clipboard actually contains a hex string
		   if string.find(hexString, "^#%w%w%w%w%w%w$") then
		      hexEntryString = hexString
		      aboutToSave = false
		      MESSAGEMAN:Broadcast("UpdateStringDisplay")
		   else
		      SCREENMAN:SystemMessage("Invalid hex color in clipboard!")
		   end
		end
	end
end

local t = Def.ActorFrame {
	OnCommand = function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(inputeater)
		applyHSV()
	end,
	Def.Quad {
		Name = "MainBG",
		InitCommand = function(self)
			self:xy(0, 0):halign(0):valign(0):zoomto(SCREEN_WIDTH, SCREEN_HEIGHT):diffuse(color("#000000"))
			self:diffusealpha(0.9)
		end
	}
}

t[#t+1] = Def.ActorFrame {
	Name = "ManualEntryArea",
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X - capWideScale(80,160), SCREEN_HEIGHT / 8)
	end,

	LoadFont("Common Large") .. {
		InitCommand = function(self)
			self:halign(0):valign(0)
			self:zoom(0.4)
			self:settext(translated_info["ManualEntry"])
		end
	},
	LoadFont("Common Large") .. {
		Name = "Explanation",
		InitCommand = function(self)
			self:y(genericSpacing + 5)
			self:halign(0):valign(0)
			self:zoom(0.25)
			self:maxwidth((SCREEN_WIDTH - (SCREEN_WIDTH / 12 + saturationSliderWidth + 5 * colorBoxHeight / 4) - 25) / 0.25)
			self:settext(translated_info["Description"])
		end
	},
	LoadFont("Common Large") .. {
		Name = "InputText",
		InitCommand = function(self)
			self:y(genericSpacing * 5)
			self:halign(0):valign(0)
			self:zoom(0.4)
			self:settext("#")
		end,
		UpdateStringDisplayMessageCommand = function(self)
			self:settext(hexEntryString)
			self:GetParent():GetChild("CursorPosition"):playcommand("UpdateCursorDisplay")
		end,
		ClickedNewColorMessageCommand = function(self)
			self:playcommand("UpdateStringDisplay")
		end
	},
	Def.Quad {
		Name = "CursorPosition",
		InitCommand = function(self)
			self:x(11)
			self:halign(0):valign(0)
			self:zoomto(10,2)
			self:y(20 + genericSpacing * 5)
		end,
		UpdateCursorDisplayCommand = function(self)
			local pos = 11
			local txt = self:GetParent():GetChild("InputText")
			if textCursorPos ~= #hexEntryString + 1 then -- if the cursor is under an actual char
				local glyphWidth = getWidthOfChar(txt, textCursorPos) - 1
				self:zoomto(glyphWidth, 2)
				pos = getXPositionInText(txt, textCursorPos)
			else
				pos = getXPositionInText(txt, textCursorPos-1) + getWidthOfChar(txt, textCursorPos-1)
			end
			self:finishtweening()
			self:linear(0.05)
			self:x(pos)
		end
	},
	LoadFont("Common Large") .. {
	   Name = "ColorPickerText",
	   InitCommand = function(self)
	      self:y(genericSpacing * 10 - 45)
	      self:settext("Press <CTRL + Shift + P> to open a color picker.")
	      self:valign(0):halign(0)
	      self:zoom(0.3)
	      self:visible(true)
	   end
	},
	LoadFont("Common Large") .. {
		Name = "SavingIndicator",
		InitCommand = function(self)
			self:y(genericSpacing * 10 - 15)
			self:settext(translated_info["AboutToSave"])
			self:valign(0):halign(0)
			self:zoom(0.45)
			self:visible(false)
		end,
		ClickedNewColorMessageCommand = function(self)
			self:visible(aboutToSave)
		end,
		UpdateStringDisplayMessageCommand = function(self)
			self:visible(aboutToSave)
		end

	},
	LoadFont("Common Large") .. {
		Name = "SelectedTypeIndicator",
		InitCommand = function(self)
			self:y(genericSpacing * 10 + 25)
			self:valign(0):halign(0)
			self:settextf("%s - %s", THEME:GetString("ScreenColorChange", selected[1]), THEME:GetString("ScreenColorChange", selected[2]))
			self:zoom(0.4)
			self:maxwidth((SCREEN_WIDTH - (SCREEN_WIDTH / 12 + saturationSliderWidth + 5 * colorBoxHeight / 4) - 25) / 0.4)
		end
	}
}

t[#t+1] = Def.ActorFrame {
	Name = "OldInfo",
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X - capWideScale(80,160), SCREEN_HEIGHT / 8 + colorBoxHeight + genericSpacing)
	end,

	LoadFont("Common Large") .. {
		InitCommand = function(self)
			self:settext("Saved Color")
			self:halign(0):valign(0)
			self:zoom(0.4)
		end
	},
	LoadFont("Common Large") .. {
		InitCommand = function(self)
			self:addy(-(colorBoxHeight/4))
			self:settext("Current Color")
			self:halign(0):valign(0)
			self:zoom(0.4)
		end
	},
	LoadFont("Common Large") .. {
		Name = "SelectedHex",
		InitCommand = function(self)
			self:y(40)
			self:valign(0):halign(0):zoom(0.4)
			self:settext(themeColor:upper())
			self:maxwidth((colorBoxHeight / 1.5) / 0.4)
		end,
		UpdateSavedColorMessageCommand = function(self)
			self:settext(themeColor:upper())
		end
	},
	Def.Quad {
		Name = "EditedPreview",
		InitCommand = function(self)
			self:x(colorBoxHeight / 1.5 + 5)
			self:addy(-(colorBoxHeight/4))
			self:halign(0):valign(0)
			self:zoomto(colorBoxHeight/4, colorBoxHeight/4)
			if hexEntryString == "#" then
				self:diffuse(color(themeColor))
			else
				self:diffuse(color(hexEntryString))
			end
		end,
		UpdateStringDisplayMessageCommand = function(self)
			if hexEntryString == "#" then
				self:diffuse(color(themeColor))
			else
				self:diffuse(color(hexEntryString))
			end
		end
	},
	Def.Quad {
		Name = "SavedPreview",
		InitCommand = function(self)
			self:x(colorBoxHeight / 1.5 + 5)
			self:halign(0):valign(0)
			self:zoomto(colorBoxHeight/4, colorBoxHeight/4)
			self:diffuse(color(themeColor))
		end,
		UpdateSavedColorMessageCommand = function(self)
			self:diffuse(color(themeColor))
		end
	},
	LoadFont("Common Large") .. {
		InitCommand = function(self)
			self:y(65)
			self:valign(0):halign(0)
			self:zoom(0.25)
			self:maxwidth((SCREEN_WIDTH - colorBoxHeight * 2 - 15) / 0.25)
			self:settext(translated_info["DefaultDescription"])
		end
	}
}

t[#t + 1] = LoadActor("_frame")

t[#t + 1] = LoadFont("Common Large") .. {
	Name = "ScreenTitleText",
	InitCommand = function(self)
		self:xy(5, 32):halign(0):valign(1):zoom(0.55):diffuse(getMainColor("highlight")):settext(translated_info["Title"])
	end
}

return t
