local buttonSize = vec2(UI_SCALE_Y, UI_SCALE_Y)

function SideBar(sim)
	ui.drawRectFilled(
		vec2(0, UI_SCALE_Y),
		vec2(UI_SCALE_Y, sim.windowHeight),
		settings.uiPrimaryColor,
		0,
		ui.CornerFlags.None
	)
	ui.drawRectFilledMultiColor(
		vec2(0, UI_SCALE_Y),
		vec2(UI_SCALE_Y, ui.availableSpaceY()),
		rgbm(1, 1, 1, 0.2),
		rgbm(1, 1, 1, 0.2),
		rgbm(0, 0, 0, 0),
		rgbm(0, 0, 0, 0)
	)

	ui.drawLine(vec2(UI_SCALE_Y, UI_SCALE_Y), vec2(UI_SCALE_Y, ui.availableSpaceY()), rgbm(1, 1, 1, 0.25))

	setCursorY(100)
	if ui.modernButtonAdvanced("##drive", buttonSize, ui.ButtonFlags.None, ui.Icons.SteeringWheel, UI_SCALE_X / 2) then
		ac.tryToStart()
	end

	if ui.modernButtonAdvanced("##setup", buttonSize, ui.ButtonFlags.None, ui.Icons.Wrench, UI_SCALE_X / 2) then
		if storage.page == MenuPages.Setup then
			storage.page = -1
		else
			storage.page = MenuPages.Setup
		end
	end

	if ui.modernButtonAdvanced("##notes", buttonSize, ui.ButtonFlags.None, ui.Icons.Document, UI_SCALE_X / 2) then
		if storage.page == MenuPages.Notes then
			storage.page = -1
		else
			storage.page = MenuPages.Notes
		end
	end

	if ui.modernButtonAdvanced("##timetable", buttonSize, ui.ButtonFlags.None, ui.Icons.List, UI_SCALE_X / 2) then
		if storage.page == MenuPages.TimeTable then
			storage.page = -1
		else
			storage.page = MenuPages.TimeTable
		end
	end

	setCursorY(0)
	setCursorY(1235)
	-- setCursorY(1120)

	if ui.modernButtonAdvanced("##apps", buttonSize, ui.ButtonFlags.None, ui.Icons.Apps, UI_SCALE_X / 2) then
		if storage.page == MenuPages.Apps then
			storage.page = -1
		else
			storage.page = MenuPages.Apps
		end
	end

	if storage.page == MenuPages.Apps then
	end

	-- if
	-- 	ui.modernButtonAdvanced(
	-- 		"##manual",
	-- 		buttonSize,
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

	if ui.modernButtonAdvanced("##settings", buttonSize, ui.ButtonFlags.None, ui.Icons.SettingsAlt, UI_SCALE_X / 2) then
		if storage.page == MenuPages.Settings then
			storage.page = -1
		else
			storage.page = MenuPages.Settings
		end
	end
end
