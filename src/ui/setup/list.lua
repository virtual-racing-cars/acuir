local listWidth = 335 * UI_SCALE_X / 100
local listMargins = 5
local setupTabHeight = 50

local scrollY = 0
local scrollYMax = 0

function SetupTabList()
	setCursorX(15)
	setCursorY(15)
	childWindow(
		"setup_tab_list",
		vec2(listWidth, 605 * UI_SCALE_Y / 100),
		false,
		ui.WindowFlags.NoScrollWithMouse + ui.WindowFlags.NoScrollbar,
		function()
			ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), settings.uiPrimaryColor, 0, ui.CornerFlags.None)
			ui.drawRect(vec2(0, 0), ui.availableSpace(), rgbm(1, 1, 1, 0.25), 0, ui.CornerFlags.None)

			local windowHeight = ui.availableSpaceY()

			pushSetupListStyle()

			setCursorY(0)
			local buttonFlags = ui.ButtonFlags.None

			if storage.setupTab == "SETUP I/O" then
				buttonFlags = ui.ButtonFlags.Active
			end

			if
				ui.modernButtonAdvanced(
					"SETUP I/O",
					vec2(ui.availableSpaceX(), setupTabHeight * UI_SCALE_Y / 100),
					buttonFlags
				)
			then
				storage.setupTab = "SETUP I/O"
			end

			setCursorY(setupTabHeight + listMargins)

			local buttonFlags = ui.ButtonFlags.None

			if storage.setupTab == "PIT STRATEGY" then
				buttonFlags = ui.ButtonFlags.Active
			end

			if
				ui.modernButtonAdvanced(
					"PIT STRATEGY",
					vec2(ui.availableSpaceX(), setupTabHeight * UI_SCALE_Y / 100),
					buttonFlags
				)
			then
				storage.setupTab = "PIT STRATEGY"
			end

			popSetupListStyle()

			pushSetupListStyle()

			ui.drawLine(
				vec2(1, ui.getCursorY() - 7),
				vec2(ui.availableSpaceX() - 1, ui.getCursorY() - 7),
				rgbm(1, 1, 1, 0.25)
			)

			setCursorY((setupTabHeight + listMargins) * 2)

			childWindow("setup_list", ui.availableSpace(), false, ui.WindowFlags.ThinScrollbar, function()
				local buttonXPos = 0
				local buttonYPos = 0
				for tab in ipairs(tabs) do
					local buttonFlags = ui.ButtonFlags.None

					if storage.setupTab == tabs[tab] then
						buttonFlags = ui.ButtonFlags.Active
					end

					setCursorX(buttonXPos)
					setCursorY(buttonYPos)
					if
						ui.modernButtonAdvanced(
							tabs[tab],
							vec2(ui.availableSpaceX(), setupTabHeight * UI_SCALE_Y / 100),
							buttonFlags
						)
					then
						storage.setupTab = tabs[tab]
					end

					buttonYPos = buttonYPos + setupTabHeight + listMargins
				end

				scrollY = ui.getScrollY()
				scrollYMax = ui.getScrollMaxY()
			end)

			if scrollY > 0 then
				ui.drawRectFilledMultiColor(
					vec2(0, (setupTabHeight * UI_SCALE_Y / 100 + 2) * 2),
					vec2(ui.availableSpaceX(), (setupTabHeight * UI_SCALE_Y / 100 + 5) * 4),
					rgbm(1, 1, 1, 0.2),
					rgbm(1, 1, 1, 0.2),
					rgbm(0, 0, 0, 0),
					rgbm(0, 0, 0, 0)
				)
			end

			if scrollY < scrollYMax then
				ui.drawRectFilledMultiColor(
					vec2(0, windowHeight - (setupTabHeight * UI_SCALE_Y / 100 + 5) * 2),
					vec2(ui.availableSpaceX(), windowHeight),
					rgbm(0, 0, 0, 0),
					rgbm(0, 0, 0, 0),
					rgbm(1, 1, 1, 0.2),
					rgbm(1, 1, 1, 0.2)
				)
			end

			popSetupListStyle()
		end
	)
end
