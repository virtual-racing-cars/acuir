function SideBar(sim)
	ui.drawRectFilled(
		vec2(0, UI_SCALE_X),
		vec2(UI_SCALE_X, sim.windowHeight),
		settings.uiPrimaryColor,
		0,
		ui.CornerFlags.None
	)

	setCursorY(110)
	if
		ui.modernButtonAdvanced(
			"##drive",
			vec2(UI_SCALE_X, UI_SCALE_X),
			ui.ButtonFlags.None,
			ui.Icons.SteeringWheel,
			UI_SCALE_X / 2
		)
	then
		ac.tryToStart()
	end

	if
		ui.modernButtonAdvanced(
			"##setup",
			vec2(UI_SCALE_X, UI_SCALE_X),
			ui.ButtonFlags.None,
			ui.Icons.Wrench,
			UI_SCALE_X / 2
		)
	then
		if storage.page == MenuPages.Setup then
			storage.page = -1
		else
			storage.page = MenuPages.Setup
		end
	end

	if
		ui.modernButtonAdvanced(
			"##notes",
			vec2(UI_SCALE_X, UI_SCALE_X),
			ui.ButtonFlags.None,
			ui.Icons.Document,
			UI_SCALE_X / 2
		)
	then
		if storage.page == MenuPages.Notes then
			storage.page = -1
		else
			storage.page = MenuPages.Notes
		end
	end

	if
		ui.modernButtonAdvanced(
			"##timetable",
			vec2(UI_SCALE_X, UI_SCALE_X),
			ui.ButtonFlags.None,
			ui.Icons.List,
			UI_SCALE_X / 2
		)
	then
		if storage.page == MenuPages.TimeTable then
			storage.page = -1
		else
			storage.page = MenuPages.TimeTable
		end
	end

	setCursorY(0)
	setCursorY(1235)
	-- setCursorY(1120)

	if
		ui.modernButtonAdvanced(
			"##apps",
			vec2(UI_SCALE_X, UI_SCALE_X),
			ui.ButtonFlags.None,
			ui.Icons.Apps,
			UI_SCALE_X / 2
		)
	then
		if storage.page == MenuPages.Apps then
			storage.page = -1
		else
			storage.page = MenuPages.Apps
		end
	end

	-- if
	-- 	ui.modernButtonAdvanced(
	-- 		"##manual",
	-- 		vec2(UI_SCALE_X, UI_SCALE_X),
	-- 		ui.ButtonFlags.None,
	-- 		ui.Icons.Book,
	-- 		UI_SCALE_X / 2
	-- 	)
	-- then
	-- 	if storage.page == MenuPages.Manual then
	-- 		storage.page = -1
	-- 	else
	-- 		storage.page = MenuPages.Manual
	-- 	end
	-- end

	if
		ui.modernButtonAdvanced(
			"##settings",
			vec2(UI_SCALE_X, UI_SCALE_X),
			ui.ButtonFlags.None,
			ui.Icons.SettingsAlt,
			UI_SCALE_X / 2
		)
	then
		if storage.page == MenuPages.Settings then
			storage.page = -1
		else
			storage.page = MenuPages.Settings
		end
	end
end
