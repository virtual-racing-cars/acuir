local sim = ac.getSim()

local fontRegular = ui.DWriteFont("Rajdhani"):weight(ui.DWriteFont.Weight.SemiBold)
local fontBold = ui.DWriteFont("Rajdhani"):weight(ui.DWriteFont.Weight.Bold)

local acLogo = ac.getFolder(ac.FolderID.Root) .. "\\launcher\\themes\\default\\graphics\\btn_AC_logo.png"
local acLogoSize = ui.imageSize(acLogo) * cui.scaleX()
local uiStartY = 40 * cui.scaleX()
local uiStartX = 60 * cui.scaleX()
local topBarHeight = 200 * cui.scaleX()
local bottomBarHeight = sim.windowHeight - 96 * cui.scaleY()

local menuButtonSize = 56
local manifestINI = ac.INIConfig.load("manifest.ini", ac.INIFormat.Extended)
local version = manifestINI:get("ABOUT", "VERSION", "0.0.0")

function bottomBar(buttons)
	ui.drawRectFilled(
		vec2(uiStartX, bottomBarHeight),
		vec2(sim.windowWidth - uiStartX, sim.windowHeight - 40 * cui.scaleY()),
		SETTINGS.uiColor1 / 3
	)

	ui.pushDWriteFont(fontRegular)
	ui.setCursor(0)
	ui.dwriteTextAligned(
		"v" .. version .. ", CSP: " .. ac.getPatchVersion() .. " (" .. ac.getPatchVersionCode() .. ")",
		26 * cui.scaleY(),
		ui.Alignment.End,
		ui.Alignment.End,
		ui.availableSpace() - vec2(250 * cui.scaleX(), 52 * cui.scaleY()),
		false,
		rgbm(0.8, 0.8, 0.8, 1)
	)

	ui.setCursor(0)
	ui.dwriteTextAligned(
		"OFFLINE",
		26 * cui.scaleY(),
		ui.Alignment.End,
		ui.Alignment.End,
		ui.availableSpace() - vec2(125 * cui.scaleX(), 52 * cui.scaleY()),
		false,
		rgbm(1, 0.9, 0, 1)
	)
	ui.popDWriteFont()

	ui.drawCircleFilled(
		vec2(sim.windowWidth - 95 * cui.scaleX(), sim.windowHeight - 68 * cui.scaleY()),
		10,
		rgbm.colors.orange
	)

	ui.pushStyleColor(ui.StyleColor.Button, rgbm.colors.transparent)
	ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)
	ui.setCursorX(uiStartX)
	ui.setCursorY(bottomBarHeight)
	for i in ipairs(buttons) do
		local menuButton = buttons[i]

		if
			cui.menuButton(
				menuButton.label,
				menuButtonSize,
				ui.Alignment.Center,
				ui.Alignment.Center,
				menuButton.enabled and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
			)
		then
			menuButton.func()
		end

		ui.sameLine()
	end
	ui.popStyleColor(1)
	ui.popStyleVar(1)
end

function homeBar(buttons)
	local xPos = uiStartX
	ui.setCursorX(xPos)
	ui.setCursorY(uiStartY + topBarHeight)

	ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)
	ui.pushStyleColor(ui.StyleColor.Button, SETTINGS.uiColor1)

	for i in ipairs(buttons) do
		local menuButton = buttons[i]

		if
			cui.menuButton(
				menuButton.label,
				menuButtonSize,
				ui.Alignment.Center,
				ui.Alignment.Center,
				menuButton.enabled and ui.ButtonFlags.None or ui.ButtonFlags.Disabled,
				false,
				i == 1
			)
		then
			menuButton.func()
		end

		ui.sameLine()
	end

	ui.popStyleColor(1)
	ui.popStyleVar(1)
end

local function findClosestIndex(input, numbers)
	local trackGripString = nil
	local smallestDifference = math.huge

	for i, num in ipairs(numbers) do
		local difference = math.abs(input - num[1])
		if difference < smallestDifference then
			smallestDifference = difference
			trackGripString = num[2]
		end
	end

	return trackGripString
end

local trackGrip = {
	{ 86, "DUSTY" },
	{ 89, "OLD" },
	{ 95, "GREEN" },
	{ 98, "RUBBERED" },
	{ 100, "OPTIMUM" },
}

local windDirection = {
	"N",
	"NE",
	"E",
	"SE",
	"S",
	"SW",
	"W",
	"NW",
}

local raceSessiontTypeString = {
	"Undefined",
	"Practice",
	"Qualify",
	"Race",
	"Hotlap",
	"TimeAttack",
	"Drift",
	"Drag",
}

local function sessionInfo()
	local startX = 1918
	local startY = 100
	local sizeX = 171
	local sizeY = 35
	local gap = 1

	local fontSize = math.floor(sizeY * 0.55)
	fontSize = (fontSize % 2 ~= 0) and fontSize or fontSize + 1

	ui.pushStyleVar(ui.StyleVar.ItemSpacing, gap)
	ui.pushDWriteFont(fontBold)

	ui.setCursor(vec2(startX, startY))
	ui.drawRectFilled(ui.getCursor(), ui.getCursor() + vec2(sizeX, sizeY), rgbm(0, 0, 0, 0.6))
	ui.dwriteTextAligned(
		string.format("%02d:%02d", sim.timeHours, sim.timeMinutes),
		fontSize,
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
	ui.dwriteTextAligned("Track", fontSize, ui.Alignment.Center, ui.Alignment.Center, vec2(sizeX, sizeY))
	ui.sameLine()

	ui.drawRectFilled(
		ui.getCursor() + vec2(gap * 2, 0),
		ui.getCursor() + vec2(gap, 0) + vec2(sizeX, sizeY),
		rgbm(0, 0, 0, 0.6)
	)
	ui.dwriteTextAligned(
		raceSessiontTypeString[sim.raceSessionType + 1],
		fontSize,
		ui.Alignment.Center,
		ui.Alignment.Center,
		vec2(sizeX, sizeY)
	)

	ui.setCursor(vec2(startX, startY) + vec2(sizeX + gap, sizeY))
	ui.drawRectFilled(
		ui.getCursor() + vec2(sizeX + gap, 0),
		ui.getCursor() + vec2(-sizeX + gap, 0) + vec2(sizeX, sizeY),
		rgbm(0.1, 0.1, 0.1, 0.5)
	)
	ui.dwriteTextAligned(
		findClosestIndex(sim.roadGrip * 100, trackGrip),
		fontSize,
		ui.Alignment.Center,
		ui.Alignment.Center,
		vec2(sizeX, sizeY)
	)
	ui.sameLine()

	ui.popDWriteFont()
	ui.popStyleVar(1)
end

function topSubBar(path)
	cui.setCursorX(60)
	cui.setCursorY(33)
	ui.image(acLogo, acLogoSize)
	ui.drawLine(
		vec2(227 * cui.scaleX(), 105 * cui.scaleY()),
		vec2(1100 * cui.scaleX(), 105 * cui.scaleY()),
		rgbm.colors.white,
		3
	)

	cui.setCursorX(230)
	cui.setCursorY(28)

	ui.pushDWriteFont(ui.DWriteFont("Rajdhani"):weight(ui.DWriteFont.Weight.SemiBold))
	ui.dwriteTextAligned(
		path,
		38 * cui.scaleY(),
		ui.Alignment.Start,
		ui.Alignment.Center,
		vec2(450 * cui.scaleX(), 100 * cui.scaleY()),
		false,
		rgbm(1, 1, 1, 1)
	)
	ui.popDWriteFont()
end

function topBar(showSessionInfo)
	ui.drawRectFilled(
		vec2(uiStartX, uiStartY),
		vec2(sim.windowWidth - uiStartX, (uiStartY + topBarHeight)),
		SETTINGS.uiColor1 / 2
	)

	ui.drawRectFilled(
		vec2(uiStartX, (uiStartY + topBarHeight)),
		vec2(sim.windowWidth - uiStartX, (uiStartY + topBarHeight + menuButtonSize * cui.scaleY())),
		SETTINGS.uiColor1 / 1.5
	)
	ui.setCursorX(sim.windowWidth / 2 - acLogoSize.x / 2)
	ui.setCursorY((uiStartY + topBarHeight) * 0.32)
	ui.image(acLogo, acLogoSize)

	if showSessionInfo then
		sessionInfo()
	end
end

function settingsMenuCommon(path, bottomBarButtons, escapeAction)
	ui.drawRectFilled(vec2(0, 0), vec2(sim.windowWidth, sim.windowHeight), SETTINGS.uiColor1 / 1.1)

	-- local storagePath = STORAGE.settingsTab > 1 and "Settings/" .. page.label or "Settings/"
	topSubBar("/Settings" .. path)
	bottomBar(bottomBarButtons)

	if ui.keyboardButtonPressed(ui.KeyIndex.Escape) then
		escapeAction()
	end
end
