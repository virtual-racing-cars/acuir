local setupSpinnersWindowSize = vec2(335 * UI_SCALE_Y / 100, 730 * UI_SCALE_Y / 100 / 2 - 7.5 * UI_SCALE_Y / 100)

HELP_TEXT = ""

function HelpWindow()
	setCursorX(1365)
	setCursorY(0)
	contentWindow("help_window", "HELP", setupSpinnersWindowSize, ui.WindowFlags.None, function() end)
end
