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
		vec2(20 * cui.scaleY(), 20 * cui.scaleY()),
		vec2(sim.windowWidth - 20, 150 * cui.scaleY()),
		settings.uiPrimaryColor,
		10,
		ui.CornerFlags.All
	)

	ui.drawRectFilledMultiColor(
		vec2(20 * cui.scaleY(), 20 * cui.scaleY()),
		vec2(sim.windowWidth - 20 * cui.scaleY(), 150 * cui.scaleY()),
		rgbm(1, 1, 1, 0.2),
		rgbm(1, 1, 1, 0.2),
		rgbm(0, 0, 0, 0),
		rgbm(0, 0, 0, 0)
	)

	cui.setCursorX(1280 - 154 / 2)
	cui.setCursorY(20)

	ui.drawRectFilled(
		ui.getCursor() - vec2(450 * cui.scaleY(), 0),
		ui.getCursor() + acLogoSize + vec2(450 * cui.scaleY(), 0),
		rgbm(0, 0, 0, 0.2),
		10,
		ui.CornerFlags.All
	)

	-- ui.drawRectFilled(
	-- 	ui.getCursor() - vec2(30 * cui.scaleY(), 0),
	-- 	ui.getCursor() + acLogoSize + vec2(30 * cui.scaleY(), 0),
	-- 	settings.uiPrimaryColor,
	-- 	10,
	-- 	ui.CornerFlags.All
	-- )

	ui.image(acLogo, acLogoSize)

	cui.setCursorX(50)
	cui.setCursorY(38)

	ui.pushStyleVar(ui.StyleVar.ItemSpacing, 98 * cui.scaleY())

	if cui.menuButton("Drive", ui.Icons.SteeringWheel, 55, ui.ButtonFlags.None) then
		ac.tryToStart()
	end
	ui.sameLine()

	if cui.menuButton("Setup", ui.Icons.Wrench, 55, ui.ButtonFlags.None) then
		if storage.page == MenuPages.Setup then
			storage.page = -1
		else
			storage.page = MenuPages.Setup
		end
	end
	ui.sameLine()

	if cui.menuButton("Standings", ui.Icons.Trophy, 55, ui.ButtonFlags.Disabled) then
		if storage.page == MenuPages.Setup then
			storage.page = -1
		else
			storage.page = MenuPages.Setup
		end
	end
	ui.sameLine()

	if cui.menuButton("Lap Times", ui.Icons.List, 55, ui.ButtonFlags.Disabled) then
		if storage.page == MenuPages.TimeTable then
			storage.page = -1
		else
			storage.page = MenuPages.TimeTable
		end
	end
	ui.sameLine()

	-- if cui.menuButtonWide("Notes", ui.Icons.Document, 120, ui.ButtonFlags.Disabled) then
	-- 	if storage.page == MenuPages.Notes then
	-- 		storage.page = -1
	-- 	else
	-- 		storage.page = MenuPages.Notes
	-- 	end
	-- end
	-- ui.sameLine()

	if cui.menuButton("Telemetry", ui.Icons.Barcode, 55, ui.ButtonFlags.Disabled) then
		if storage.page == MenuPages.TimeTable then
			storage.page = -1
		else
			storage.page = MenuPages.TimeTable
		end
	end
	ui.sameLine()

	-- if ui.modernButtonAdvanced("Apps", buttonSize, ui.ButtonFlags.None, ui.Icons.Apps, UI_SCALE_X / 3) then
	-- 	if storage.page == MenuPages.Apps then
	-- 		storage.page = -1
	-- 	else
	-- 		storage.page = MenuPages.Apps
	-- 	end
	-- end
	-- ui.sameLine()

	cui.setCursorX(1835)

	if cui.menuButton("Info", ui.Icons.Info, 55, ui.ButtonFlags.Disabled) then
		if storage.page == MenuPages.Settings then
			storage.page = -1
		else
			storage.page = MenuPages.Settings
		end
	end
	ui.sameLine()

	if cui.menuButton("Settings", ui.Icons.Settings, 55, ui.ButtonFlags.Disabled) then
		if storage.page == MenuPages.Settings then
			storage.page = -1
		else
			storage.page = MenuPages.Settings
		end
	end
	ui.sameLine()

	if cui.menuButton("Restart", ui.Icons.Restart, 55, ui.ButtonFlags.None) then
		ac.tryToRestartSession()
	end
	ui.sameLine()

	if cui.menuButton("Skip", ui.Icons.Skip, 55, ui.ButtonFlags.None) then
		ac.tryToSkipSession()
	end
	ui.sameLine()

	if cui.menuButton("Exit", ui.Icons.Leave, 55, ui.ButtonFlags.None) then
		ac.shutdownAssettoCorsa()
	end

	ui.drawRectFilled(
		vec2(20 * cui.scaleY(), sim.windowHeight - 200 * cui.scaleY()),
		vec2(sim.windowWidth - 20 * cui.scaleY(), sim.windowHeight - 20 * cui.scaleY()),
		settings.uiPrimaryColor,
		10,
		ui.CornerFlags.All
	)

	ui.drawRectFilledMultiColor(
		vec2(20 * cui.scaleY(), sim.windowHeight - 200 * cui.scaleY()),
		vec2(sim.windowWidth - 20 * cui.scaleY(), sim.windowHeight - 20 * cui.scaleY()),
		rgbm(1, 1, 1, 0.2),
		rgbm(1, 1, 1, 0.2),
		rgbm(0, 0, 0, 0),
		rgbm(0, 0, 0, 0)
	)

	ui.popStyleVar(1)

	ui.popFont()

	-- ui.drawLine(vec2(1280, 0), vec2(1280, 1440), rgbm.colors.aqua)
end
