require("ui\\main\\bar_top")
require("ui\\main\\bar_side")
require("ui\\setup\\page")
require("ui\\apps\\page")
require("ui\\time_table\\page")
require("ui\\settings\\page")

function MainWindow(sim)
	setCursorX(0)
	setCursorY(0)
	childWindow(
		"bars",
		vec2(sim.windowWidth, sim.windowHeight),
		false,
		ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse,
		function()
			ui.bringWindowToFront()
			pushSetupListStyle()

			TopBar()
			SideBar(sim)

			if settings.showVersions then
				ui.dwriteTextAligned(
					"v0.1.0, CSP: " .. ac.getPatchVersion() .. " (" .. ac.getPatchVersionCode() .. ")",
					20,
					ui.Alignment.End,
					ui.Alignment.End,
					vec2(sim.windowWidth - 20, sim.windowHeight - 100),
					false,
					rgbm(0.8, 0.8, 0.8, 1)
				)
			end

			popSetupListStyle()

			ui.setCursorX(UI_SCALE_Y)
			ui.setCursorY(UI_SCALE_Y)
			childWindow(
				"page_windows",
				ui.availableSpace(),
				false,
				ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse,
				function()
					-- ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), rgbm(0.2, 0.8, 1, 0.25), 0, ui.CornerFlags.None)

					if storage.page == MenuPages.Setup then
						SetupPage(sim)
						return ""
					end

					if storage.page == MenuPages.TimeTable then
						TimeTablePage(sim)
						return "debug"
					end

					if storage.page == MenuPages.Apps then
						AppsPage(sim)
						return
					end

					if storage.page == MenuPages.Settings then
						SettingsPage(sim)
						return ""
					end
				end
			)

			ui.drawRectFilled(
				vec2(sim.windowWidth / 2 - 1, 0),
				vec2(sim.windowWidth / 2 + 1, sim.windowHeight),
				rgbm.colors.lime
			)

			ui.drawRectFilled(
				vec2(0, sim.windowHeight / 2 - 1),
				vec2(sim.windowWidth, sim.windowHeight / 2 + 1),
				rgbm.colors.lime
			)
		end
	)
end
