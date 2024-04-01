-- Monkey-patching certain functions in vanilla sm5 to work better
-- with a try-except-finally program structure.
--
-- Additionally, we monkey-patch ActorDefs here to add more functionality.
--   <3 kurulen

-- basically just ReportScriptError from 5.0.12 but
-- without the massive dialog interrupting the game
function ReportScriptError(msg)
   MESSAGEMAN:Broadcast("ScriptError", {message = tostring(msg)})
end

-- patching CodeDetector for great profit
function GetCode(codeName)
   local codes = {
      -- steps
      PrevSteps1 = "Up,Up",
      PrevSteps2 = "MenuUp,MenuUp",
      NextSteps1 = "Down,Down",
      NextSteps2 = "MenuDown,MenuDown",
      -- group
      NextGroup = "",
      PrevGroup = "",
      CloseCurrentFolder1 = "MenuUp-MenuDown",
      CloseCurrentFolder2 = "Up-Down",
      -- sorts
      NextSort1 = "MenuLeft-MenuRight",
      NextSort2 = "",
      NextSort3 = "",
      NextSort4 = "",
      -- modemenu
      ModeMenu1 = "Up,Down,Up,Down",
      ModeMenu2 = "MenuUp,MenuDown,MenuUp,MenuDown",
      -- Evaluation:
      SaveScreenshot1 = "MenuLeft-MenuRight",
      SaveScreenshot2 = "Select",
      -- modifiers section
      CancelAll = "",
      --- specific modifiers
      Mirror = "",
      Left = "",
      Right = "",
      Shuffle = "",
      SuperShuffle = "",
      Reverse = "",
      Mines = "",
      Hidden = "",
      NextScrollSpeed = "",
      PreviousScrollSpeed = "",
      CancelAllPlayerOptions = "",
      LoadKitsuneIPC = "Up,Up,Down,Down,Left,Right,Left,Right,Start"
   }
   Trace("[KITSUNE:MonkeyPatching:53] Loaded code name "..codeName)
   return codes[codeName]
end

function Sprite:LoadFromSongBackground(song)
   if song then
      local Path = song:GetBackgroundPath()
      self:LoadBackground( Path )
   end
   return self
end

function Sprite:LoadFromSongBanner(song)
   if song then
      local Path = song:GetBannerPath()
      self:LoadBanner( Path )
   end
   return self
end

function Actor:ScaleToBounds(cw, ch, sw, sh)
   self:zoom(math.min(math.max(cw / sw, ch / sh), 1))
   return self
end

-- seriously what is math and how does it work
notShit = {}
function notShit.floor(x, y)
	y = 10 ^ (y or 0)
	return math.floor(x * y) / y
end

function notShit.ceil(x, y)
	y = 10 ^ (y or 0)
	return math.ceil(x * y) / y
end

function notShit.round(x, y)
	y = 10 ^ (y or 0)
	return math.floor(x * y + 0.5) / y
end

function table:slice(alpha, omega)
	local function oob(input, target)
		return ((input > target) and true or false)
	end
	local function nilCheck(obj)
		if obj ~= nil then return true else return false end
	end
	if nilCheck(omega) then if oob(omega, #self) then return nil end end
	if oob(alpha, #self) then return nil end

	local ret = {}
	for i = alpha, (nilCheck(omega) and omega or #self) do
		ret[#ret+1] = self[i]
	end

	return ret
end

function table:pop(alpha, omega)
	local sliced = self:slice(alpha, omega)

	if #sliced == #self then
		return sliced, nil
	end

	local ret = self:slice(omega+1)

	return sliced, ret
end

