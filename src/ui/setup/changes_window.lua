local setupSpinnersWindowSize = vec2(335 * UI_SCALE_Y / 100, 730 * UI_SCALE_Y / 100 / 2 - 7.5 * UI_SCALE_Y / 100)

function ChangesWindow()
	setCursorX(1315)
	setCursorY(730 / 2 + 7.5)
	contentWindow("changes_window", "CHANGELOG", setupSpinnersWindowSize, ui.WindowFlags.None, function() end)
end
