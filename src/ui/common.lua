local sim = ac.getSim()

local acLogo = ac.getFolder(ac.FolderID.Root) .. "\\launcher\\themes\\default\\graphics\\btn_AC_logo.png"
local acLogoSize = ui.imageSize(acLogo)

local uiStartY = 40
local uiStartX = 60

local topBarHeight = 200

local menuButtonSizeX = 120
local menuButtonSizeY = 56
local menuButtonFontSize = 12

local fontLol = ui.DWriteFont("Panton-Trial"):weight(ui.DWriteFont.Weight.Black)

local manifestINI = ac.INIConfig.load("manifest.ini", ac.INIFormat.Extended)
local version = manifestINI:get("ABOUT", "VERSION", "0.0.0")

function bottomBar(buttons)
	ui.drawRectFilled(
		vec2(uiStartX * cui.scaleY(), sim.windowHeight - 96 * cui.scaleY()),
		vec2(sim.windowWidth - uiStartX * cui.scaleY(), sim.windowHeight - 40 * cui.scaleY()),
		settings.uiPrimaryColor
	)

	setCursorX(0)
	setCursorY(0)
	ui.dwriteTextAligned(
		"v" .. version .. ", CSP: " .. ac.getPatchVersion() .. " (" .. ac.getPatchVersionCode() .. ")",
		26,
		ui.Alignment.End,
		ui.Alignment.End,
		ui.availableSpace() - vec2(250, 52),
		false,
		rgbm(0.8, 0.8, 0.8, 1)
	)

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

	ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)

	cui.setCursorX(uiStartX)
	cui.setCursorY(sim.windowHeight - 96)

	for i in ipairs(buttons) do
		local menuButton = buttons[i]

		if
			cui.menuButton(
				menuButton.label,
				menuButtonSizeY,
				menuButtonFontSize,
				ui.Alignment.Center,
				ui.Alignment.Center,
				menuButton.enabled and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
			)
		then
			menuButton.func()
		end

		ui.sameLine()
	end
	ui.popStyleVar(1)
end

function homeBar(buttons)
	setCursorY(uiStartY)

	local xPos = uiStartX
	cui.setCursorX(xPos)
	cui.setCursorY(uiStartY + topBarHeight)

	ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)

	for i in ipairs(buttons) do
		local menuButton = buttons[i]

		if
			cui.menuButton(
				menuButton.label,
				menuButtonSizeY,
				menuButtonFontSize,
				ui.Alignment.Center,
				ui.Alignment.Center,
				menuButton.enabled and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
			)
		then
			menuButton.func()
		end

		ui.sameLine()
	end

	ui.popStyleVar(1)

	-- ui.drawLine(vec2(1280, 0), vec2(1280, 1440), rgbm.colors.aqua)
end

local function sessionInfo()
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
end

function topBar(showSessionInfo)
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

	cui.setCursorX(sim.windowWidth / 2 - acLogoSize.x / 2)
	cui.setCursorY(77)
	ui.image(acLogo, acLogoSize * cui.scaleY())

	if showSessionInfo then
		sessionInfo()
	end
end
