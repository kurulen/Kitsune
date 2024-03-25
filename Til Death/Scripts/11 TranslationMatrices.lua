TranslationMatrices = {}

TranslationMatrices["PlayerInfo"] = {
	ProfileNew = THEME:GetString("ProfileChanges", "ProfileNew"),
	NameChange = THEME:GetString("ProfileChanges", "ProfileNameChange"),
	ClickLogin = THEME:GetString("GeneralInfo", "ClickToLogin"),
	ClickLogout = THEME:GetString("GeneralInfo", "ClickToLogout"),
	NotLoggedIn = THEME:GetString("GeneralInfo", "NotLoggedIn"),
	LoggedIn = THEME:GetString("GeneralInfo", "LoggedIn"),
	LoggedInAs = THEME:GetString("GeneralInfo", "LoggedInAs.."),
	LoginFailed = THEME:GetString("GeneralInfo", "LoginFailed"),
	LoginSuccess = THEME:GetString("GeneralInfo", "LoginSuccess"),
	LoginCanceled = THEME:GetString("GeneralInfo", "LoginCanceled"),
	Password = THEME:GetString("GeneralInfo","Password"),
	Username = THEME:GetString("GeneralInfo","Username"),
	Plays = THEME:GetString("GeneralInfo", "ProfilePlays"),
	TapsHit = THEME:GetString("GeneralInfo", "ProfileTapsHit"),
	Judge = THEME:GetString("GeneralInfo", "ProfileJudge"),
	RefreshSongs = THEME:GetString("GeneralInfo", "DifferentialReloadTrigger"),
	SongsLoaded = THEME:GetString("GeneralInfo", "ProfileSongsLoaded"),
	SessionTime = THEME:GetString("GeneralInfo", "SessionTime")
}

TranslationMatrices["Profile"] = {
	Validated = THEME:GetString("TabProfile", "ScoreValidated"),
	Invalidated = THEME:GetString("TabProfile", "ScoreInvalidated"),
	Online = THEME:GetString("TabProfile", "Online"),
	Local = THEME:GetString("TabProfile", "Local"),
	Recent = THEME:GetString("TabProfile", "Recent"),
	NextPage = THEME:GetString("TabProfile", "NextPage"),
	PrevPage = THEME:GetString("TabProfile", "PreviousPage"),
	Save = THEME:GetString("TabProfile", "SaveProfile"),
	AssetSettings = THEME:GetString("TabProfile", "AssetSettingEntry"),
	Success = THEME:GetString("TabProfile", "SaveSuccess"),
	Failure = THEME:GetString("TabProfile", "SaveFail"),
	ValidateAll = THEME:GetString("TabProfile", "ValidateAllScores"),
	ForceRecalc = THEME:GetString("TabProfile", "ForceRecalcScores"),
}

TranslationMatrices["ScreenSelectProfile"] = {
	Title = THEME:GetString("ScreenSelectProfile", "Title"),
	SongPlayed = THEME:GetString("ScreenSelectProfile", "SongPlayed"),
	SongsPlayed = THEME:GetString("ScreenSelectProfile", "SongsPlayed"),
	NoProfile = THEME:GetString("GeneralInfo", "NoProfile"),
	PressStart = THEME:GetString("ScreenSelectProfile", "PressStartToJoin")
}

TranslationMatrices["ScreenColorEdit"] = {
	Title = THEME:GetString("ScreenColorEdit", "Title"),
	Description = THEME:GetString("ScreenColorEdit", "Description"),
	AboutToSave = THEME:GetString("ScreenColorEdit", "AboutToSave"),
	Hexadecimal = THEME:GetString("ScreenColorEdit", "Hexadecimal"),
	RGBA = THEME:GetString("ScreenColorEdit", "RedGreenBlueAlpha"),
	ManualEntry = THEME:GetString("ScreenColorEdit", "ManualEntry"),
	Alpha = THEME:GetString("ScreenColorEdit", "Alpha"),
	Saturation = THEME:GetString("ScreenColorEdit", "Saturation"),
	DefaultDescription = THEME:GetString("ScreenColorEdit", "DefaultDescription")
}

TranslationMatrices["WifeTwirl"] = {
	GoalTarget = THEME:GetString("ScreenSelectMusic", "GoalTargetString"),
	MaxCombo = THEME:GetString("ScreenSelectMusic", "MaxCombo"),
	BPM = THEME:GetString("ScreenSelectMusic", "BPM"),
	NameChange = THEME:GetString("ProfileChanges", "ProfileNameChange"),
	NegBPM = THEME:GetString("ScreenSelectMusic", "NegativeBPM"),
	UnForceStart = THEME:GetString("GeneralInfo", "UnforceStart"),
	ForceStart = THEME:GetString("GeneralInfo", "ForceStart"),
	Unready = THEME:GetString("GeneralInfo", "Unready"),
	Ready = THEME:GetString("GeneralInfo", "Ready"),
	TogglePreview = THEME:GetString("ScreenSelectMusic", "TogglePreview"),
	PlayerOptions = THEME:GetString("ScreenSelectMusic", "PlayerOptions"),
	OpenSort = THEME:GetString("ScreenSelectMusic", "OpenSortMenu")
}

TranslationMatrices["ScreenAssetSettings"] = {
	Title = THEME:GetString("ScreenAssetSettings","Title"),
	Selected = THEME:GetString("ScreenAssetSettings","Selected"),
	Hovered = THEME:GetString("ScreenAssetSettings","Hovered")
}

TranslationMatrices["ExitSSM"] = {
	PressStart = THEME:GetString("ScreenSelectMusic","PressStartForOptions"),
	EnteringOptions = THEME:GetString("ScreenSelectMusic","EnteringOptions"),
}

TranslationMatrices["OffsetPlot"] = {
	Left = THEME:GetString("OffsetPlot", "ExplainLeft"),
	Middle = THEME:GetString("OffsetPlot", "ExplainMiddle"),
	Right = THEME:GetString("OffsetPlot", "ExplainRight"),
	Down = THEME:GetString("OffsetPlot", "ExplainDown"),
	Early = THEME:GetString("OffsetPlot", "Early"),
	Late = THEME:GetString("OffsetPlot", "Late"),
	SD = THEME:GetString("ScreenEvaluation", "StandardDev"),
	Mean = THEME:GetString("ScreenEvaluation", "Mean"),
	UsingReprioritized = THEME:GetString("OffsetPlot", "UsingReprioritized"),
	TapNoteScore_W1 = getJudgeStrings("TapNoteScore_W1"),
	TapNoteScore_W2 = getJudgeStrings("TapNoteScore_W2"),
	TapNoteScore_W3 = getJudgeStrings("TapNoteScore_W3"),
	TapNoteScore_W4 = getJudgeStrings("TapNoteScore_W4"),
	TapNoteScore_W5 = getJudgeStrings("TapNoteScore_W5"),
	TapNoteScore_Miss = getJudgeStrings("TapNoteScore_Miss"),
}

TranslationMatrices["ChordDensityGraph"] = {
	nps = THEME:GetString("ChordDensityGraph", "NPS"),
	anps = THEME:GetString("TabMSD", "AverageNPS"),
}

TranslationMatrices["SongSearch"] = {
	Active = THEME:GetString("TabSearch", "Active"),
	Complete = THEME:GetString("TabSearch", "Complete"),
	ExplainStart = THEME:GetString("TabSearch", "ExplainStart"),
	ExplainBack = THEME:GetString("TabSearch", "ExplainBack"),
	ExplainTags = THEME:GetString("TabSearch", "ExplainTags"),
}

TranslationMatrices["RoomSearch"] = {
	Title = THEME:GetString("TabSearch", "RoomTitle"),
	Subtitle = THEME:GetString("TabSearch", "RoomSubtitle"),
	Opened = THEME:GetString("TabSearch", "RoomOpened"),
	Passworded = THEME:GetString("TabSearch", "RoomPassworded"),
	InGameplay = THEME:GetString("TabSearch", "RoomInGameplay"),
	TabTitle = THEME:GetString("TabSearch", "Title"),
	Explanation = THEME:GetString("TabSearch", "ExplainLimitation")
}

TranslationMatrices["SGPlayerInfo"] = {
	Judge = THEME:GetString("ScreenGameplay", "ScoringJudge"),
	Scoring = THEME:GetString("ScreenGameplay", "ScoringType")
}

TranslationMatrices["SGNPSCalc"] = {
	Peak = THEME:GetString("ScreenGameplay", "NPSGraphPeakNPS"),
	NPS = THEME:GetString("ScreenGameplay", "NPSGraphNPS")
}

TranslationMatrices["WifeJudgmentSpotting"] = {
	ErrorLate = THEME:GetString("ScreenGameplay", "ErrorBarLate"),
	ErrorEarly = THEME:GetString("ScreenGameplay", "ErrorBarEarly"),
	NPS = THEME:GetString("ChordDensityGraph", "NPS"),
	BPM = THEME:GetString("ChordDensityGraph", "BPM"),
}

TranslationMatrices["ScreenEval"] = {
	Title = THEME:GetString("ScreenEvaluation", "Title"),
	Replay = THEME:GetString("ScreenEvaluation", "ReplayTitle"),
    CCOn = THEME:GetString("ScreenEvaluation", "ChordCohesionOn"),
	MAPARatio = THEME:GetString("ScreenEvaluation", "MAPARatio")
}

TranslationMatrices["SortOrder"] = {
	Sort = THEME:GetString("SortOrder", "SortWord")
}

TranslationMatrices["ScreenSystemLayer"] = {
	ItemsDownloading = THEME:GetString("ScreenSystemLayerOverlay", "ItemsDownloading"),
	ItemsLeftInQueue = THEME:GetString("ScreenSystemLayerOverlay", "ItemsLeftInQueue")
}

TranslationMatrices["ChartPreview"] = {
	Paused = THEME:GetString("ChartPreview", "Paused"),
	NPS = THEME:GetString("ChordDensityGraph", "NPS"),
	BPM = THEME:GetString("ChordDensityGraph", "BPM"),
}

TranslationMatrices["ScoreBoard"] = {
	LoginToView = THEME:GetString("NestedScores", "LoginToView"),
	NoScoresFound = THEME:GetString("NestedScores", "NoScoresFound"),
	RetrievingScores = THEME:GetString("NestedScores", "RetrievingScores"),
	Watch = THEME:GetString("NestedScores", "WatchReplay"),
	FilterAll = THEME:GetString("NestedScores", "FilterAll"),
	FilterCurrent = THEME:GetString("NestedScores", "FilterCurrent"),
	TopScoresOnly = THEME:GetString("NestedScores", "ScoresTop"),
	AllScores = THEME:GetString("NestedScores", "ScoresAll"),
	InvalidatedScoresOn = THEME:GetString("NestedScores", "ShowInvalid"),
	InvalidatedScoresOff = THEME:GetString("NestedScores", "HideInvalid")
}

TranslationMatrices["SSMScore"] = {
	MaxCombo = THEME:GetString("TabScore", "MaxCombo"),
	ComboBreaks = THEME:GetString("TabScore","ComboBreaks"),
	DateAchieved = THEME:GetString("TabScore", "DateAchieved"),
	Mods = THEME:GetString("TabScore", "Mods"),
	Rate = THEME:GetString("TabScore", "Rate"), -- used in conjunction with Showing
	Showing = THEME:GetString("TabScore", "Showing"), -- to produce a scuffed thing
	ChordCohesion = THEME:GetString("TabScore", "ChordCohesion"),
	Judge = THEME:GetString("TabScore", "ScoreJudge"),
	NoScores = THEME:GetString("TabScore", "NoScores"),
	Yes = THEME:GetString("OptionNames", "Yes"),
	No = THEME:GetString("OptionNames", "No"),
	ShowOffset = THEME:GetString("TabScore", "ShowOffsetPlot"),
	NoReplayData = THEME:GetString("TabScore", "NoReplayData"),
	ShowReplay = THEME:GetString("TabScore", "ShowReplay"),
	ShowEval = THEME:GetString("TabScore", "ShowEval"),
	ProfileUploadWarning = THEME:GetString("TabScore", "ProfileUploadWarning"),
	UploadReplay = THEME:GetString("TabScore", "UploadReplay"),
	UploadAllScoreChart=THEME:GetString("TabScore", "UploadAllScoreChart"),
	UploadAllScorePack=THEME:GetString("TabScore", "UploadAllScorePack"),
	UploadAllScore=THEME:GetString("TabScore", "UploadAllScore"),
	UploadingReplay = THEME:GetString("TabScore", "UploadingReplay"),
	UploadingScore = THEME:GetString("TabScore", "UploadingScore"),
	NotLoggedIn = THEME:GetString("GeneralInfo", "NotLoggedIn")
}
