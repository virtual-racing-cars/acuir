function setupSettings()
	setCursorX(10)
	setCursorY(60)

	ui.beginGroup(0)

	if ui.checkbox("Auto-Load last setup", settings.autoLoadLastSetup) then
		settings.autoLoadLastSetup = not settings.autoLoadLastSetup
	end

	if ui.checkbox("Hide other track setups", settings.hideOtherTrackSetups) then
		settings.hideOtherTrackSetups = not settings.hideOtherTrackSetups
	end

	if ui.checkbox("Auto-Save setup when new personal best lap time achieved", settings.hideOtherTrackSetups) then
		settings.hideOtherTrackSetups = not settings.hideOtherTrackSetups
	end

	ui.endGroup()
end
