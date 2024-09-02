local setupSpinnersWindowSize = vec2(335 * UI_SCALE_X / 100, 730 * UI_SCALE_Y / 100)

HELP_TEXT = ""

function HelpWindow()
	contentWindow("help_window", "HELP", vec2(1365, 0), setupSpinnersWindowSize, ui.WindowFlags.None, function()
		local helpSections = string.split(HELP_TEXT, "\\n\\n")
		setCursorX(6)
		setCursorY(50)

		for i in ipairs(helpSections) do
			ui.textWrapped(helpSections[i], ui.availableSpaceX() - 10)
		end

		HELP_TEXT = ""
	end)
end
