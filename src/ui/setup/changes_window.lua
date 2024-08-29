CHANGE_LOG = {}

local setupSpinnersWindowSize = vec2(335 * UI_SCALE_Y / 100, 730 * UI_SCALE_Y / 100 / 2 - 7.5 * UI_SCALE_Y / 100)

function ChangesWindow()
	setCursorX(1365)
	setCursorY(730 / 2 + 7.5)
	contentWindow("changes_window", "CHANGELOG", setupSpinnersWindowSize, ui.WindowFlags.None, function()
		setCursorY(38)

		childWindow("changes_list", ui.availableSpace(), false, ui.WindowFlags.None, function()
			setCursorX(10)

			ui.beginGroup()
			ui.pushFont(ui.Font.Small)
			for k, v in pairs(CHANGE_LOG) do
				ui.modernButtonAdvanced(
					v.label,
					vec2(ui.availableSpaceX() - 10 * UI_SCALE_Y / 100, 20 * UI_SCALE_Y / 100),
					ui.ButtonFlags.None
				)
			end
			ui.popFont()
			ui.endGroup()
		end)
	end)
end
