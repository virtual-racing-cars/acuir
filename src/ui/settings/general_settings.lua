function generalSettings()
	setCursorX(10)
	setCursorY(60)

	ui.beginGroup(0)

	if ui.checkbox("Auto-Start new UI", settings.autoStart) then
		settings.autoStart = not settings.autoStart
	end

	local value, changed = ui.slider(
		"##afkhideui",
		settings.uiHideonIdleTime,
		0,
		300,
		settings.uiHideonIdleTime > 0 and "Hide UI after idle: %.0f seconds" or "Hide UI after idle: Disabled"
	)

	if changed then
		settings.uiHideonIdleTime = math.floor(value / 5 + 0.5) * 5
	end

	if ui.checkbox("Show app and CSP versions on bottom right of the screen", settings.showVersions) then
		settings.showVersions = not settings.showVersions
	end

	if ui.checkbox("Developer Mode", settings.showVersions) then
		settings.showVersions = not settings.showVersions
	end

	ui.endGroup()
end
