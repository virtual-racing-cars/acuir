function generalSettings()
	if ui.checkbox("Auto-Start Advanced Setup", settings.autoStart) then
		settings.autoStart = not settings.autoStart
	end

	if ui.checkbox("Show app and CSP versions on bottom right of the screen", settings.showVersions) then
		settings.showVersions = not settings.showVersions
	end

	if ui.checkbox("Auto-Load last setup", settings.autoLoadLastSetup) then
		settings.autoLoadLastSetup = not settings.autoLoadLastSetup
	end

	if ui.checkbox("Hide other track setups", settings.hideOtherTrackSetups) then
		settings.hideOtherTrackSetups = not settings.hideOtherTrackSetups
	end

	if ui.checkbox("Auto-Save setup when new personal best lap time achieved", settings.hideOtherTrackSetups) then
		settings.hideOtherTrackSetups = not settings.hideOtherTrackSetups
	end
end
