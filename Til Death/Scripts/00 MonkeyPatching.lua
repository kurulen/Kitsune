-- Monkey-patching certain functions in vanilla sm5 to work better
-- with a try-except-finally program structure.
--
-- Additionally, we monkey-patch ActorDefs here to add more things.
--   <3 kurulen

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

notShit = {}
function notShit.floor(x, y)
	y = 10 ^ (y or 0)
	return math.floor(x * y) / y
end

function notShit.ceil(x, y)
	y = 10 ^ (y or 0)
	return math.ceil(x * y) / y
end

-- seriously what is math and how does it work
function notShit.round(x, y)
	y = 10 ^ (y or 0)
	return math.floor(x * y + 0.5) / y
end

-- basically just ReportScriptError from 5.0.12 but
-- without the massive dialog interrupting the game
function ReportScriptError(msg)
   MESSAGEMAN:Broadcast("ScriptError", {message = tostring(msg)})
end
