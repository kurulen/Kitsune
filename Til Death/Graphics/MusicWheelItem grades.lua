return Def.ActorFrame {
	Def.Quad {
		InitCommand = function(self)
			self:xy(2, -2):zoomto(4, 38)
		end,
		SetGradeCommand = function(self, params)
			if params.Grade then
				self:diffuse(getDifficultyColor("Difficulty_" .. params.Difficulty))
				self:diffusealpha(0.5)
			else
				self:diffusealpha(0)
			end
		end
	},
	Def.Quad {
		InitCommand = function(self)
			self:xy(2, -2):zoomto(4, 19)
		end,
		SetGradeCommand = function(self, params)
			if params.HasGoal then
				self:diffuse(getJudgmentColor("TapNoteScore_Miss"))
				self:diffusealpha(1)
			else
				self:diffusealpha(0)
			end
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(16, -1):zoom(0.5):maxwidth(WideScale(get43size(20), 20) / 0.5)
		end,
		SetGradeCommand = function(self, params)
			local sGrade = params.Grade or "Grade_None"
			self:valign(0.5)
			self:settext(THEME:GetString("Grade", ToEnumShortString(sGrade)) or "")
			self:diffuse(getGradeColor(sGrade))
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(-9, -9):zoomto(4, 19)
		end,
		SetGradeCommand = function(self, params)
			if params.PermaMirror then
				self:settext("M")
				self:zoomto(20, 20)
				self:diffuse(getMainColor("highlight"))
				self:visible(true)
			else
				self:visible(false)
			end
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(1, 6):zoomto(4, 19)
		end,
		SetGradeCommand = function(self, params)
			if params.Favorited then
				self:settext("<3")
				self:zoomto(16, 16)
				self:diffuse(getMainColor("highlight"))
				self:visible(true)
			else
				self:visible(false)
			end
		end
	}
}
