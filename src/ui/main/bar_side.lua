local sim = ac.getSim()

local acEvoLogo = ac.dirname() .. "\\acevo.png"

local acEvoLogoSize = ui.imageSize(acEvoLogo) * 0.38

local acLogo = ac.getFolder(ac.FolderID.Root) .. "\\launcher\\themes\\default\\graphics\\btn_AC_logo.png"
local acLogoSize = ui.imageSize(acEvoLogo) * 0.15

local setupPageFontSize = ui.Font.Title

if UI_SCALE_Y < 50 then
	setupPageFontSize = ui.Font.Tiny
elseif UI_SCALE_Y < 75 then
	setupPageFontSize = ui.Font.Small
elseif UI_SCALE_Y < 100 then
	setupPageFontSize = ui.Font.Main
end

local uiStartY = 40
local uiStartX = 60

local topBarHeight = 200

local menuButtonSizeX = 120
local menuButtonSizeY = 56
local menuButtonFontSize = 12

local fontLol = ui.DWriteFont("Panton-Trial"):weight(ui.DWriteFont.Weight.Black)

local manifestINI = ac.INIConfig.load("manifest.ini", ac.INIFormat.Extended)
local version = manifestINI:get("ABOUT", "VERSION", "0.0.0")

function bottomBar()
	ui.drawRectFilled(
		vec2(uiStartX * cui.scaleY(), sim.windowHeight - 96 * cui.scaleY()),
		vec2(sim.windowWidth - uiStartX * cui.scaleY(), sim.windowHeight - 40 * cui.scaleY()),
		settings.uiPrimaryColor
	)

	setCursorX(0)
	setCursorY(0)
	if settings.showVersions then
		ui.dwriteTextAligned(
			"v" .. version .. ", CSP: " .. ac.getPatchVersion() .. " (" .. ac.getPatchVersionCode() .. ")",
			26,
			ui.Alignment.End,
			ui.Alignment.End,
			ui.availableSpace() - vec2(250, 52),
			false,
			rgbm(0.8, 0.8, 0.8, 1)
		)
	end

	setCursorX(0)
	setCursorY(0)
	ui.dwriteTextAligned(
		"OFFLINE",
		26,
		ui.Alignment.End,
		ui.Alignment.End,
		ui.availableSpace() - vec2(125, 52),
		false,
		rgbm(1, 0.9, 0, 1)
	)

	ui.drawCircleFilled(vec2(sim.windowWidth - 95, sim.windowHeight - 68), 10, rgbm.colors.orange)

	if storage.page == MenuPages.Home then
		return
	end
	cui.setCursorX(uiStartX)
	cui.setCursorY(sim.windowHeight - 96)
	if
		cui.button(
			"Back",
			menuButtonSizeX,
			menuButtonSizeY,
			menuButtonFontSize,
			ui.Alignment.Center,
			ui.Alignment.Center,
			ui.ButtonFlags.None
		)
	then
		storage.page = MenuPages.Home
	end
end

function SideBar(sim)
	setCursorY(uiStartY)

	ui.pushFont(setupPageFontSize)

	ui.drawRectFilled(
		vec2(uiStartX, uiStartY),
		vec2(sim.windowWidth - uiStartX, uiStartY + topBarHeight * cui.scaleY()),
		settings.uiPrimaryColor
	)

	ui.drawRectFilled(
		vec2(uiStartX, uiStartY + topBarHeight * cui.scaleY()),
		vec2(sim.windowWidth - uiStartX, uiStartY + topBarHeight + menuButtonSizeY * cui.scaleY()),
		rgbm(0.231373, 0.223529, 0.262745, 0.85)
	)

	-- cui.setCursorX(sim.windowWidth / 2 - acEvoLogoSize.x / 2)
	-- cui.setCursorY(-55)
	-- ui.image(acEvoLogo, acEvoLogoSize * cui.scaleY())

	cui.setCursorX(sim.windowWidth / 2 - acLogoSize.x / 2)
	cui.setCursorY(65)
	ui.image(acLogo, acLogoSize * cui.scaleY())

	local xPos = uiStartX
	cui.setCursorX(xPos)
	cui.setCursorY(uiStartY + topBarHeight)

	ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)

	if
		cui.button(
			"Drive",
			menuButtonSizeX,
			menuButtonSizeY,
			menuButtonFontSize,
			ui.Alignment.Center,
			ui.Alignment.Center,
			ui.ButtonFlags.None
		)
	then
		ac.tryToStart()
	end
	ui.sameLine()

	if
		cui.button(
			"Vehicle Setup",
			menuButtonSizeX,
			menuButtonSizeY,
			menuButtonFontSize,
			ui.Alignment.Center,
			ui.Alignment.Center,
			ui.ButtonFlags.None
		)
	then
		if storage.page == MenuPages.Setup then
			storage.page = -1
		else
			storage.page = MenuPages.Setup
		end
	end
	ui.sameLine()

	if
		cui.button(
			"Replay",
			menuButtonSizeX,
			menuButtonSizeY,
			menuButtonFontSize,
			ui.Alignment.Center,
			ui.Alignment.Center,
			ui.ButtonFlags.Disabled
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
		cui.button(
			"Settings",
			menuButtonSizeX,
			menuButtonSizeY,
			menuButtonFontSize,
			ui.Alignment.Center,
			ui.Alignment.Center,
			ui.ButtonFlags.None
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
		cui.button(
			"Restart Session",
			menuButtonSizeX,
			menuButtonSizeY,
			menuButtonFontSize,
			ui.Alignment.Center,
			ui.Alignment.Center,
			ui.ButtonFlags.None
		)
	then
		ac.tryToRestartSession()
	end
	ui.sameLine()

	-- if
	-- 	cui.button(
	-- 		"Skip",
	-- 		menuButtonSizeX,
	-- 		menuButtonSizeY,
	-- 		menuButtonFontSize,
	-- 		ui.Alignment.Center,
	-- 		ui.Alignment.Center,
	-- 		ui.ButtonFlags.None
	-- 	)
	-- then
	-- 	ac.tryToSkipSession()
	-- end
	-- ui.sameLine()

	if
		cui.button(
			"Quit",
			menuButtonSizeX,
			menuButtonSizeY,
			menuButtonFontSize,
			ui.Alignment.Center,
			ui.Alignment.Center,
			ui.ButtonFlags.None
		)
	then
		ac.shutdownAssettoCorsa()
	end

	local startX = 1918
	local startY = 100
	local sizeX = 171
	local sizeY = 35
	local gap = 1

	ui.setCursor(vec2(startX, startY))

	ui.pushDWriteFont(fontLol)

	ui.drawRectFilled(ui.getCursor(), ui.getCursor() + vec2(sizeX, sizeY), rgbm(0, 0, 0, 0.6))
	ui.dwriteTextAligned(
		string.format("%02d:%02d", sim.timeHours, sim.timeMinutes),
		16,
		ui.Alignment.Center,
		ui.Alignment.Center,
		vec2(sizeX, sizeY)
	)
	ui.sameLine()

	ui.drawRectFilled(
		ui.getCursor() + vec2(gap, 0),
		ui.getCursor() + vec2(gap, 0) + vec2(sizeX, sizeY),
		rgbm(0, 0, 0, 0.6)
	)
	ui.dwriteTextAligned("Track", 16, ui.Alignment.Center, ui.Alignment.Center, vec2(sizeX, sizeY))
	ui.sameLine()

	ui.drawRectFilled(
		ui.getCursor() + vec2(gap * 2, 0),
		ui.getCursor() + vec2(gap, 0) + vec2(sizeX, sizeY),
		rgbm(0, 0, 0, 0.6)
	)
	ui.dwriteTextAligned("Practice", 16, ui.Alignment.Center, ui.Alignment.Center, vec2(sizeX, sizeY))

	ui.setCursor(vec2(startX, startY) + vec2(sizeX, sizeY))
	ui.drawRectFilled(
		ui.getCursor() + vec2(sizeX + gap, 0),
		ui.getCursor() + vec2(-sizeX + gap, 0) + vec2(sizeX, sizeY),
		rgbm(0.1, 0.1, 0.1, 0.5)
	)
	ui.dwriteTextAligned("OPTIMUM", 16, ui.Alignment.Center, ui.Alignment.Center, vec2(sizeX, sizeY))
	ui.sameLine()

	ui.popDWriteFont()
	ui.popStyleVar(1)
	ui.popFont()

	-- ui.drawLine(vec2(1280, 0), vec2(1280, 1440), rgbm.colors.aqua)
end
