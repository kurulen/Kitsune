local defaultConfig = {
	global = {
		RateSort = true,
		MeasureLines = false,
		ProgressBar = 1, -- 0 = bottom, 1 = top
		JudgmentTween = false,
		ComboTween = false,
		CenteredCombo = false,
		FadeNoteFieldInSyncMachine = true,
		ShowPlayerOptionsHint = true,
		ShowBanners = true, -- false to turn off banners everywhere
	},
	NPSDisplay = {
		MaxWindow = 2,
		MinWindow = 1 -- unused.
	},
}

themeConfig = create_setting("themeConfig", "themeConfig.lua", defaultConfig, -1)
themeConfig:load()

function JudgementTweensEnabled()
	return themeConfig:get_data().global.JudgmentTween
end
function ComboTweensEnabled()
	return themeConfig:get_data().global.ComboTween
end
function CenteredComboEnabled()
	return themeConfig:get_data().global.CenteredCombo
end
function BannersEnabled()
	return themeConfig:get_data().global.ShowBanners
end
