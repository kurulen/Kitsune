-- variables that are shared by all screens

CurrentTidbit = "ScreenInit" -- themer-friendly name for current focused screen
CurrentSubTidbit = "" -- themer-friendly (ish) name for current focused prominent element (like superscoreboard)
errorBarPresent = false
ShowingHelp = false
LastPress = { false, false }
JITProfilerStarted = false
MultiLoops = 0
CurrentVolume = PREFSMAN:GetPreference("SoundVolume")

EventLoop = function(event)
   local CtrlPressed = INPUTFILTER:IsControlPressed()
   local ShiftPressed = INPUTFILTER:IsShiftPressed()
   local function SetVolume(desired)
      CurrentVolume = clamp(desired, 0, 1)
      SOUND:SetVolume(CurrentVolume)
      PREFSMAN:SetPreference("SoundVolume", CurrentVolume)
      PREFSMAN:SavePreferences()
   end
   if event.DeviceInput.button == "DeviceButton_;" and (CtrlPressed and ShiftPressed) then
      SetVolume(CurrentVolume + 0.025)
   elseif event.DeviceInput.button == "DeviceButton_'" and (CtrlPressed and ShiftPressed) then
      SetVolume(CurrentVolume - 0.025)
   elseif event.DeviceInput.button == "DeviceButton_F7" then
      JITProfilerStarted = not JITProfilerStarted
      if JITProfilerStarted == true then
	 StartProfiler()
	 SCREENMAN:SystemMessage("JIT profiler started.")
      else
	 StopProfiler()
	 SCREENMAN:SystemMessage("JIT profiler stopped.")
      end
   end
end

KBHelpLoop = function()
   local press = LastPress
   press = { INPUTFILTER:IsControlPressed(), INPUTFILTER:IsShiftPressed() }
   if LastPress ~= press then
      MESSAGEMAN:Broadcast("PressBitsChanged", { Bits = press })
      LastPress = press
   end
end

RunLoops = function(event)
   KBHelpLoop()
   EventLoop(event)
end
