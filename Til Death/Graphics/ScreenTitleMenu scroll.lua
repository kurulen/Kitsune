local gc = Var("GameCommand")

return Def.ActorFrame {
	LoadFont("Common Normal") ..
		{
			Text = THEME:GetString("ScreenTitleMenu", gc:GetText()),
			OnCommand = function(self)
				self:xy(280, -72):align(0,0.5)
			end,
			GainFocusCommand = function(self)
				self:zoom(0.61):diffuse(1,1,1,1)
			end,
			LoseFocusCommand = function(self)
				self:zoom(0.55):diffuse(getMainColor('positive'))
			end
		}
}
