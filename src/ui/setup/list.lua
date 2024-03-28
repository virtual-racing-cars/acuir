local listWidth = 335 * UI_SCALE_X / 100
local listMargins = 5
local setupTabHeight = 50

function SetupTabList()
	setCursorX(15)
	setCursorY(15)
	childWindow(
		"setup_tab_list",
		vec2(listWidth, ui.availableSpaceY() / 2) - vec2(0, setupTabHeight * UI_SCALE_Y / 100 + 8),
		false,
		ui.WindowFlags.NoScrollWithMouse + ui.WindowFlags.NoScrollbar,
		function()
			ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), settings.uiPrimaryColor, 0, ui.CornerFlags.None)
			ui.drawRect(vec2(0, 0), ui.availableSpace(), rgbm(1, 1, 1, 0.25), 0, ui.CornerFlags.None)

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
			end)

			popSetupListStyle()
		end
	)
end
