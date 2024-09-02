local buttonSize = vec2(200 * UI_SCALE_Y / 100, UI_SCALE_Y)

local acLogo = ac.getFolder(ac.FolderID.Root) .. "\\launcher\\themes\\default\\graphics\\btn_AC_logo.png"
local acLogoSize = ui.imageSize(acLogo) * vec2(UI_SCALE_Y / 100, UI_SCALE_Y / 100)

local setupPageFontSize = ui.Font.Title

if UI_SCALE_Y < 50 then
	setupPageFontSize = ui.Font.Tiny
elseif UI_SCALE_Y < 75 then
	setupPageFontSize = ui.Font.Small
elseif UI_SCALE_Y < 100 then
	setupPageFontSize = ui.Font.Main
end

function SideBar(sim)
	setCursorY(0)
	local availableSpaceY = ui.availableSpaceY()

	ui.pushFont(setupPageFontSize)

	ui.drawRectFilled(
		vec2(0, 0),
		vec2(200 * UI_SCALE_Y / 100, sim.windowHeight),
		settings.uiPrimaryColor,
		0,
		ui.CornerFlags.None
	)
	ui.drawRectFilledMultiColor(
		vec2(0, 0),
		vec2(200 * UI_SCALE_Y / 100, ui.availableSpaceY()),
		rgbm(1, 1, 1, 0.2),
		rgbm(1, 1, 1, 0.2),
		rgbm(0, 0, 0, 0),
		rgbm(0, 0, 0, 0)
	)

	ui.drawLine(
		vec2(200 * UI_SCALE_Y / 100, 0),
		vec2(200 * UI_SCALE_Y / 100, ui.availableSpaceY()),
		rgbm(1, 1, 1, 0.25)
	)

	setCursorX(5)
	setCursorY(15)
	if ui.invisibleButton("##ui_toggle", acLogoSize) then
		storage.appOpen = not storage.appOpen
	end

	setCursorX(25)
	setCursorY(15)
	ui.image(acLogo, acLogoSize)

	if ui.mousePos() > vec2(0, 0) and ui.mousePos() <= vec2(200, 200) then
		setCursorX(70)
		if
			ui.modernButtonAdvanced(
				"##settings",
				vec2(UI_SCALE_Y / 4, UI_SCALE_Y / 4),
				ui.ButtonFlags.None,
				ui.Icons.Settings,
				UI_SCALE_X / 8
			)
		then
			if storage.page == MenuPages.Settings then
				storage.page = -1
			else
				storage.page = MenuPages.Settings
			end
		end

		ui.sameLine()
		if
			ui.modernButtonAdvanced(
				"##appinfo",
				vec2(UI_SCALE_Y / 4, UI_SCALE_Y / 4),
				ui.ButtonFlags.None,
				ui.Icons.Info,
				UI_SCALE_X / 8
			)
		then
			if storage.page == MenuPages.Settings then
				storage.page = -1
			else
				storage.page = MenuPages.Settings
			end
		end
	end

	ui.pushStyleVar(ui.StyleVar.ItemSpacing, 2)

	setCursorY(200)
	if ui.modernButtonAdvanced("Drive", buttonSize, ui.ButtonFlags.None, ui.Icons.SteeringWheel, UI_SCALE_X / 3) then
		ac.tryToStart()
	end

	if ui.modernButtonAdvanced("Setup", buttonSize, ui.ButtonFlags.None, ui.Icons.Wrench, UI_SCALE_X / 3) then
		if storage.page == MenuPages.Setup then
			storage.page = -1
		else
			storage.page = MenuPages.Setup
		end
	end

	if ui.modernButtonAdvanced("Notes", buttonSize, ui.ButtonFlags.Disabled, ui.Icons.Document, UI_SCALE_X / 3) then
		if storage.page == MenuPages.Notes then
			storage.page = -1
		else
			storage.page = MenuPages.Notes
		end
	end

	if ui.modernButtonAdvanced("Lap Times", buttonSize, ui.ButtonFlags.None, ui.Icons.List, UI_SCALE_X / 3) then
		if storage.page == MenuPages.TimeTable then
			storage.page = -1
		else
			storage.page = MenuPages.TimeTable
		end
	end

	if ui.modernButtonAdvanced("Telemetry", buttonSize, ui.ButtonFlags.Disabled, ui.Icons.Barcode, UI_SCALE_X / 3) then
		if storage.page == MenuPages.TimeTable then
			storage.page = -1
		else
			storage.page = MenuPages.TimeTable
		end
	end

	if ui.modernButtonAdvanced("Apps", buttonSize, ui.ButtonFlags.None, ui.Icons.Apps, UI_SCALE_X / 3) then
		if storage.page == MenuPages.Apps then
			storage.page = -1
		else
			storage.page = MenuPages.Apps
		end
	end

	if ui.modernButtonAdvanced("Settings", buttonSize, ui.ButtonFlags.None, ui.Icons.Settings, UI_SCALE_X / 3) then
		if storage.page == MenuPages.Settings then
			storage.page = -1
		else
			storage.page = MenuPages.Settings
		end
	end

	ui.popStyleVar(1)

	ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)

	ui.dummy(buttonSize * vec2(1, 0.5))

	ui.offsetCursorY(ui.availableSpaceY() - 165)

	if ui.modernButtonAdvanced("Restart", buttonSize * vec2(1, 0.5), ui.ButtonFlags.None, ui.Icons.Restart) then
		ac.tryToRestartSession()
	end

	if
		ui.modernButtonAdvanced(
			"Skip",
			buttonSize * vec2(1, 0.5),
			sim.sessionsCount > 1 and ui.ButtonFlags.None or ui.ButtonFlags.Disabled,
			ui.Icons.Skip
		)
	then
		ac.tryToSkipSession()
	end

	if ui.modernButtonAdvanced("Exit", buttonSize * vec2(1, 0.5), ui.ButtonFlags.None, ui.Icons.Leave) then
		ac.shutdownAssettoCorsa()
	end

	ui.popStyleVar(1)
	ui.popFont()

	ui.drawLine(vec2(200 * UI_SCALE_Y / 100, 0), vec2(200 * UI_SCALE_Y / 100, availableSpaceY), rgbm(1, 1, 1, 0.25))
end
