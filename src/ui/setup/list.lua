local listWidth = 335 * UI_SCALE_X / 100
local listMargins = 5
local setupTabHeight = 50

function SetupTabList()
	childWindow(
		"setup_tab_list",
		vec2(listWidth, ui.availableSpaceY() / 2),
		false,
		ui.WindowFlags.ThinScrollbar + ui.WindowFlags.NoScrollWithMouse + ui.WindowFlags.NoScrollbar,
		function()
			ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), settings.uiPrimaryColor, 0, ui.CornerFlags.None)
			ui.drawLine(
				vec2(0, ui.availableSpaceY()),
				vec2(ui.availableSpaceX(), ui.availableSpaceY()),
				rgbm(1, 1, 1, 0.25),
				3
			)
			ui.drawLine(
				vec2(ui.availableSpaceX(), 0),
				vec2(ui.availableSpaceX(), ui.availableSpaceY()),
				rgbm(1, 1, 1, 0.25),
				3
			)

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

			childWindow(
				"setup_list",
				ui.availableSpace() - vec2(0, setupTabHeight * UI_SCALE_Y / 100 + listMargins),
				false,
				ui.WindowFlags.ThinScrollbar,
				function()
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
				end
			)

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
		end
	)
end
