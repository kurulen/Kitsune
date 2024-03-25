local width = THEME:GetMetric("ScreenChatOverlay","ChatWidth")
local height = THEME:GetMetric("ScreenChatOverlay","ChatHeight")
local maxlines = 20
local lineNumber = 20
local inputLineNumber = 2
local tabHeight = 1
local maxTabs = 5
local x, y = 5, SCREEN_HEIGHT - height * (maxlines + inputLineNumber + tabHeight)
local moveY = 0
local scale = 0.4
local minimised = true
local typing = false
local typingText = ""
local transparency = 0.667
local curmsgh = 0
local closeTabSize = 10
local tweentime = 0.25
local getMainColor = getMainColor or function(e) if e == "positive" then return color("#9654FD") else return color("2E2E2E99") end end
local topbaroffset = capWideScale(6,0)
local Colors = {
	background = getMainColor("tabs"),
	input = color("#888888"),
	activeInput = Brightness(getMainColor("positive"),0.2),
	chatSent = ColorMultiplier(getMainColor("positive"),1.5),
	output = color("#545454"),
	bar = color("#666666"),
	tab = color("#555555"),
	activeTab = color("#999999")
}
local translated_info = {
	WindowTitle = THEME:GetString("MultiPlayer", "ChatTitle"),
	LobbyTab = THEME:GetString("MultiPlayer", "LobbyTabName"),
	ServerTab = THEME:GetString("MultiPlayer", "ServerTabName"),
}
local chats = {}
chats[0] = {}
chats[1] = {}
chats[2] = {}
chats[0][""] = {}
local tabs = {{0, ""}}
--chats[tabName][tabType]
--tabtype: 0=lobby, 1=room, 2=pm
local messages = chats[0][""]
local currentTabName = ""
local currentTabType = 0
local currentTabIndex = 1
local isGameplay = false
local isInSinglePlayer = false
local currentScreen
local show = true
local online = IsNetSMOnline() and IsSMOnlineLoggedIn() and NSMAN:IsETTP()
local function changeTab(tabName, tabType)
	currentTabName = tabName
	currentTabType = tabType
	if not chats[tabType][tabName] then
		local i = 1
		local done = false
		while not done do
			if not tabs[i] then
				tabs[i] = {tabType, tabName}
				done = true
			end
		end
		chats[tabType][tabName] = {}
	end
	messages = chats[tabType][tabName]
end
local chat = Def.ActorFrame {
	BeginCommand = function(self)
		currentScreen = SCREENMAN:GetTopScreen()
		local updf = function(self)
			local s = SCREENMAN:GetTopScreen()
			if not s then
				return
			end
			local oldScreen = currentScreen
			currentScreen = s:GetName()
			if currentScreen == oldScreen then return end
		
			-- prevent the chat from showing in singleplayer because it can be annoying
			if
				oldScreen ~= currentScreen and
					(currentScreen == "ScreenSelectMusic" or currentScreen == "ScreenTitleMenu" or
						currentScreen == "ScreenOptionsService" or currentScreen == "ScreenInit" or
						currentScreen == "ScreenPackDownloader" or currentScreen == "ScreenBundleSelect")
			then
				isInSinglePlayer = true
			end
			if string.sub(currentScreen, 1, 9) == "ScreenNet" and currentScreen ~= "ScreenNetSelectProfile" then
				isInSinglePlayer = false
			end
		
			online = IsNetSMOnline() and IsSMOnlineLoggedIn() and NSMAN:IsETTP()
			isGameplay = (currentScreen:find("Gameplay") ~= nil or currentScreen:find("StageInformation") ~= nil
							or currentScreen:find("PlayerOptions") ~= nil)
		
			if isGameplay or isInSinglePlayer then
				self:visible(false)
				show = false
				typing = false
				s:setTimeout(
					function()
						self:visible(false)
					end,
					0.025
				)
			else
				self:visible(online and not isInSinglePlayer)
				show = true
			end
			if currentScreen == "ScreenNetSelectMusic" then
				for i = 1, #tabs do
					if tabs[i] and tabs[i][2] == NSMAN:GetCurrentRoomName() then
						changeTab(tabs[i][2], tabs[i][1])
					end
				end
			end
			MESSAGEMAN:Broadcast("UpdateChatOverlay")
		end
		self:SetUpdateFunction(updf)
		updf(self)
		self:SetUpdateFunctionInterval(0.1)
	end,
}

chat.MinimiseMessageCommand = function(self)
	self:decelerate(tweentime)
	moveY = minimised and height * (maxlines + inputLineNumber + tabHeight - 1) or 0
	self:y(moveY)
end
local i = 0
chat.InitCommand = function(self)
	online = IsNetSMOnline() and IsSMOnlineLoggedIn() and NSMAN:IsETTP()
	self:visible(false)
	MESSAGEMAN:Broadcast("Minimise")
end
chat.BeginTextEntryMessageCommand = function(self)
	if not minimised then
		minimised = not minimised
		MESSAGEMAN:Broadcast("Minimise")
	end
end

chat.MultiplayerDisconnectionMessageCommand = function(self)
	online = false
	self:visible(false)
	typing = false
	MESSAGEMAN:Broadcast("UpdateChatOverlay")
	chats = {}
	chats[0] = {}
	chats[1] = {}
	chats[2] = {}
	chats[0][""] = {}
	tabs = {{0, ""}}
	changeTab("", 0)
	SCREENMAN:set_input_redirected("PlayerNumber_P1", false)
end

local bg
chat[#chat + 1] = Def.Quad {
	Name = "Background",
	InitCommand = function(self)
		bg = self
		self:diffuse(Colors.background)
		self:diffusealpha(transparency)
		self:stretchto(x, y + height, width + x, height * (maxlines + inputLineNumber + tabHeight) + y)
	end
}
local minbar
chat[#chat + 1] = Def.Quad {
	Name = "Bar",
	InitCommand = function(self)
		minbar = self
		self:diffuse(Colors.bar)
		self:diffusealpha(transparency)
		self:zoomto(SCREEN_WIDTH, 2)
		self:CenterX()
		self:addy(SCREEN_BOTTOM / 4.39)
	end,
	ChatMessageCommand = function(self, params)
		if minimised and params.tab ~= ""
			and not (params.msg:find("System:") and not params.msg:find("The room is now")
			and not params.msg:find("Can't start") and not params.msg:find("room operator")
			and not params.msg:find("You're not in a room") and not params.msg:find("Starting in")) then
			self:hurrytweening(0.2)
			self:linear(tweentime)
			self:glowshift()
			self:effectcolor1(Colors.chatSent)
			self:effectcolor2(Colors.bar)
			self:effectperiod(1)
		end
	end,
	MinimiseMessageCommand = function(self)
		if minimised then
			self:linear(tweentime)
			self:diffuse(Colors.bar):diffusealpha(transparency)
			self:stopeffect()
		else
			self:linear(tweentime)
			self:diffuse(Colors.bar):diffusealpha(0)
		end
	end,
	StopEffectCommand = function(self)
		self:stopeffect()
	end,
}
--[[chat[#chat + 1] = LoadFont("Common Normal") .. {
	Name = "BarLabel",
	InitCommand = function(self)
		self:settext(translated_info["WindowTitle"])
		self:halign(0):valign(0.5)
		self:zoom(0.5)
		self:diffuse(color("#000000"))
		self:visible(true)
		self:xy(x + 3 + width * 0.425, y - 0.5 + height * 0.5)
		self:addx(topbaroffset)
	end,
	MinimiseMessageCommand = function(self)
		self:accelerate(tweentime):diffusealpha(minimised and 1 or 0)
	end
}
chat[#chat + 1] = LoadFont("Common Normal") .. {
	Name = "BarLabel2",
	InitCommand = function(self)
		self:settext("-")
		self:halign(1):valign(0.5)
		self:zoom(0.8)
		self:diffuse(color("#000000"))
		self:visible(true)
		self:xy(x - 3 + width * 0.575, y - 0.5 + height * 0.5)
		self:addx(topbaroffset)
	end,
	MinimiseMessageCommand = function(self)
		self:settext(minimised and "+" or "-")
		self:y(minimised and y - 1 + height * 0.5 or y - 2.5 + height * 0.5)
		self:accelerate(tweentime):diffusealpha(minimised and 1 or 0)
	end
}]]

local chatWindow = Def.ActorFrame {
	InitCommand = function(self)
		self:visible(true)
	end,
	ChatMessageCommand = function(self, params)
		local msgs = chats[params.type][params.tab]
		local newTab = false
		if not msgs then
			chats[params.type][params.tab] = {}
			msgs = chats[params.type][params.tab]
			tabs[#tabs + 1] = {params.type, params.tab}
			newTab = true
		end
		msgs[#msgs + 1] = os.date("%X") .. params.msg
		if msgs == messages or newTab then --if its the current tab
			MESSAGEMAN:Broadcast("UpdateChatOverlay")
		end
	end
}
local chatbg
chatWindow[#chatWindow + 1] = Def.Quad {
	Name = "ChatWindow",
	InitCommand = function(self)
		chatbg = self
		self:diffuse(Colors.output)
		self:diffusealpha(transparency)
	end,
	UpdateChatOverlayMessageCommand = function(self)
		self:stretchto(x, height * (1 + tabHeight) + y, width + x, height * (maxlines + tabHeight) + y)
		curmsgh = 0
		MESSAGEMAN:Broadcast("UpdateChatOverlayMsgs")
	end
}
chatWindow[#chatWindow + 1] = Def.Quad { --masking quad, hides any text outside chatwindow
	InitCommand = function(self)
		self:stretchto(x, -SCREEN_HEIGHT, width + x, height * 2 + y)
		self:zwrite(true):blend("BlendMode_NoEffect")
	end,
}
chatWindow[#chatWindow + 1] = LoadColorFont("Common Normal") .. {
	Name = "ChatText",
	InitCommand = function(self)
		self:settext("")
		self:halign(0):valign(1)
		self:vertspacing(0)
		self:zoom(scale)
		self:SetMaxLines(maxlines, 1)
		self:wrapwidthpixels((width - 8) / scale)
		self:xy(x + 4, y + height * (maxlines + tabHeight) - 4)
		self:ztest(true)
	end,
	UpdateChatOverlayMsgsMessageCommand = function(self)
		local t = ""
		for i = lineNumber - 1, lineNumber - maxlines, -1 do
			if messages[#messages - i] then
				t = t .. messages[#messages - i] .. "\n"
			end
		end
		self:settext(t)
	end
}

local tabWidth = width / maxTabs
for i = 0, maxTabs - 1 do
	chatWindow[#chatWindow + 1] = Def.ActorFrame {
		Name = "Tab" .. i + 1,
		UpdateChatOverlayMessageCommand = function(self)
			self:visible(not (not tabs[i + 1]))
		end,
		Def.Quad {
			InitCommand = function(self)
				self:diffuse(Colors.tab)
				self:diffusealpha(transparency)
			end,
			UpdateChatOverlayMessageCommand = function(self)
				self:diffuse(
					(tabs[i + 1] and currentTabName == tabs[i + 1][2] and currentTabType == tabs[i + 1][1]) and Colors.activeTab or
						Colors.tab
				)
				self:stretchto(x + tabWidth * i, y + height, x + tabWidth * (i + 1), y + height * (1 + tabHeight))
			end,
			ChatMessageCommand = function(self, params)
				if params.tab == self:GetParent():GetChild("TabName"):GetText() and params.tab ~= currentTabName
					and not (params.msg:find("System:") and not params.msg:find("The room is now")
					and not params.msg:find("Can't start") and not params.msg:find("room operator")
					and not params.msg:find("You're not in a room") and not params.msg:find("Starting in")) then
					self:decelerate(0.2):diffuse(Colors.chatSent)
				end
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self:diffuse(Color.Black)
				self:diffusealpha(transparency)
				self:halign(0.5)
				self:stretchto(x + tabWidth * (i + 1) - 1, y + height,x + tabWidth * (i + 1), y + height * (1 + tabHeight))
			end,
		},
		LoadFont("Common Normal") .. {
			Name = "TabName",
			InitCommand = function(self)
				self:halign(0):valign(0.5)
				self:maxwidth((tabWidth - 5) / scale)
				self:zoom(scale)
				self:diffuse(color("#000000"))
				self:xy(x + tabWidth * i + 4 - 1.5, y + height * (1 + (tabHeight / 2.3)))
			end,
			UpdateChatOverlayMessageCommand = function(self)
				if not tabs[i + 1] then
					self:settext("")
					return
				end
				if tabs[i + 1][1] == 0 and tabs[i + 1][2] == "" then
					self:settext(translated_info["LobbyTab"])
				elseif tabs[i + 1][1] ~= 0 and tabs[i + 1][2] == "" then
					self:settext(translated_info["ServerTab"])
				else
					self:settext(tabs[i + 1][2] or "")
				end
				if
					tabs[i + 1] and
						((tabs[i + 1][1] == 0 and tabs[i + 1][2] == "") or
							(tabs[i + 1][1] == 1 and tabs[i + 1][2] ~= nil and tabs[i + 1][2] == NSMAN:GetCurrentRoomName()))
					then
					self:maxwidth((tabWidth - 5) / scale)
				else
					self:maxwidth((tabWidth - 15) / scale)
				end
			end
		},
		Def.Sprite {
			Texture = THEME:GetPathG("","X.png"),
			InitCommand = function(self)
				self:halign(0):valign(0.5)
				self:zoom(scale - 0.1)
				self:diffuse(Color.Red)
				self:xy(x + tabWidth * (i + 1) - closeTabSize, y + height * (1 + (tabHeight / 2.1)))
			end,
			UpdateChatOverlayMessageCommand = function(self)
				if
					tabs[i + 1] and
						((tabs[i + 1][1] == 0 and tabs[i + 1][2] == "") or
							(tabs[i + 1][1] == 1 and tabs[i + 1][2] ~= nil and tabs[i + 1][2] == NSMAN:GetCurrentRoomName()))
					then
					self:visible(false)
				else
					self:visible(true)
				end
			end
		}
	}
end

local inbg
chatWindow[#chatWindow + 1] = Def.Quad {
	Name = "ChatBox",
	InitCommand = function(self)
		inbg = self
		self:diffuse(Colors.input)
		self:diffusealpha(transparency)
	end,
	UpdateChatOverlayMessageCommand = function(self)
		self:stretchto(x, height * (maxlines + 1) + y + 4, width + x, height * (maxlines + 1 + inputLineNumber) + y)
		self:diffuse(typing and Colors.activeInput or Colors.input):diffusealpha(transparency)
	end
}
chatWindow[#chatWindow + 1] = LoadColorFont("Common Normal") .. {
	Name = "ChatBoxText",
	InitCommand = function(self)
		self:settext("")
		self:halign(0):valign(0)
		self:vertspacing(0)
		self:zoom(scale)
		self:SetMaxLines(maxlines, 1)
		self:wrapwidthpixels((width - 8) / scale)
		self:diffuse(color("#FFFFFF"))
	end,
	UpdateChatOverlayMessageCommand = function(self)
		self:settext(typingText)
		self:xy(x + 4, height * (maxlines + 1) + y + 4 + 4)
	end
}

chat[#chat + 1] = chatWindow

chat.UpdateChatOverlayMessageCommand = function(self)
	SCREENMAN:set_input_redirected("PlayerNumber_P1", typing)
end

local function shiftTab(fromIndex, toIndex)
	-- tabs[index of tab][parameter table....]
	--					[1 is type, 2 is tab contents?]
	tabs[toIndex] = tabs[fromIndex]
	tabs[fromIndex] = nil
end

local function shiftAllTabs(emptyIndex)
	for i = emptyIndex + 1, maxTabs - 1 do
		shiftTab(i, i - 1)
	end
end

function MPinput(event)
	if (not show or not online) or isGameplay then
		return false
	end
	local update = false

	-- Ctrl-0 toggles the chat.
	if event.type == "InputEventType_FirstPress" and INPUTFILTER:IsControlPressed() and event.DeviceInput.button == "DeviceButton_0" then
	   minimised = not minimised
	   MESSAGEMAN:Broadcast("Minimise")
	   shouldOpen = not minimised
	   update = true
	   typing = not minimised
	   typingText = ""
	end

	-- Ctrl-Tab scrolls right 1 tab, Ctrl-Shift-Tab scrolls left 1 tab.
	if event.type == "InputEventType_FirstPress" and INPUTFILTER:IsControlPressed() and event.DeviceInput.button == "DeviceButton_tab" then
	   local tabIncrement = 1
	   if INPUTFILTER:IsShiftPressed() then tabIncrement = -1 end
	   currentTabIndex = currentTabIndex + tabIncrement
	   if currentTabIndex > #tabs then
	      currentTabIndex = 1
	   elseif currentTabIndex < 1 then
	      currentTabIndex = #tabs
	   end
	   changeTab(tabs[currentTabIndex][2], tabs[currentTabIndex][1])
	end

	-- Ctrl-W closes the current tab (if it has an X on it).
	if event.type == "InputEventType_FirstPress" and INPUTFILTER:IsControlPressed() and event.DeviceInput.button == "DeviceButton_w" then
	   local tabT = tabs[currentTabIndex][1]
	   local tabN = tabs[currentTabIndex][2]
	   if (tabT == 0 and tabN == "") or (tabT == 1 and tabN ~= nil and tabN == NSMAN:GetCurrentRoomName()) then
	      return false
	   end
	   tabs[currentTabIndex] = nil
	   if chats[tabT][tabN] == messages then
	      for i = #tabs, 1, -1 do
		 if tabs[i] then
		    changeTab(tabs[i][2], tabs[i][1])
		 end
	      end
	   end
	   chats[tabT][tabN] = nil
	   shiftAllTabs(currentTabIndex)
	end

	-- Emacs-like scrolling for messages (Ctrl-P is up, Ctrl-N is down).
	if event.DeviceInput.button == "DeviceButton_p" and event.type == "InputEventType_FirstPress" and INPUTFILTER:IsControlPressed() then
	   if lineNumber < #messages then
	      lineNumber = lineNumber + 1
	   end
	   update = true
	end
	if event.DeviceInput.button == "DeviceButton_n" and event.type == "InputEventType_FirstPress" and INPUTFILTER:IsControlPressed() then
	   if lineNumber > maxlines then
	      lineNumber = lineNumber - 1
	   end
	   update = true
	end

	if typing then
	   if event.type == "InputEventType_Release" then
	      if shouldOpen then
		 shouldOpen = false
		 typingText = ""
	      end
	      if event.DeviceInput.button == "DeviceButton_enter" then
		 if typingText:len() > 0 then
		    NSMAN:SendChatMsg(typingText, currentTabType, currentTabName)
		    typingText = ""
		 elseif typingText == "" then
		    typing = false -- pressing enter when text is empty to deactive chat is expected behavior -mina
		 end
		 update = true
	      end
	   elseif event.DeviceInput.button == "DeviceButton_space" then
	      typingText = typingText .. " "
	      update = true
	   elseif event.DeviceInput.button == "DeviceButton_backspace" and INPUTFILTER:IsControlPressed() then
	      typingText = ""
	      update = true
	   elseif INPUTFILTER:IsControlPressed() and
	      event.DeviceInput.button == "DeviceButton_v" then
	      typingText = typingText .. Arch.getClipboard()
	      update = true
	   elseif event.DeviceInput.button == "DeviceButton_backspace" then
	      typingText = typingText:sub(1, -2)
	      update = true
	   elseif event.char then
	      typingText = (tostring(typingText) .. tostring(event.char)):gsub("[^%g%s]", "")
	      update = true
	   end
	end

	if update then
	   if minimised then -- minimise will be set in the above blocks, disable input and clear text -mina
	      typing = false
	      typingText = ""
	   end
	   MESSAGEMAN:Broadcast("UpdateChatOverlay")
	end

	returnInput = update or typing
	return returnInput
end

return chat
