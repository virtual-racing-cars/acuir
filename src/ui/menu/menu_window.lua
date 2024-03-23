function MenuWindow(sim)
	setCursorX(0)
	setCursorY(0)
	ui.childWindow(
		"bars",
		vec2(sim.windowWidth, sim.windowHeight),
		false,
		ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse,
		function()
			ui.bringWindowToFront()
			pushSetupListStyle()

			SideBar(sim)
			TopBar()

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
		end
	)
end
