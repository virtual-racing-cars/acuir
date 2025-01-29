local sim = ac.getSim()

local fontRegular = ui.DWriteFont("Rajdhani"):weight(ui.DWriteFont.Weight.SemiBold)
local fontBold = ui.DWriteFont("Rajdhani"):weight(ui.DWriteFont.Weight.Bold)

local acLogo = ac.getFolder(ac.FolderID.Root) .. "\\launcher\\themes\\default\\graphics\\btn_AC_logo.png"
local acLogoSize = ui.imageSize(acLogo) * cui.scaleY()

local topBarHeight = 200 * cui.scaleY()
local bottomBarHeight = sim.windowHeight - 96 * cui.scaleY()

local menuButtonSize = 56
local manifestINI = ac.INIConfig.load("manifest.ini", ac.INIFormat.Extended)
local version = manifestINI:get("ABOUT", "VERSION", "0.0.0")
local versionString = "v " .. version .. ", CSP: " .. ac.getPatchVersion() .. " (" .. ac.getPatchVersionCode() .. ")"

function bottomBar(buttons)
	ui.drawRectFilled(vec2(0, bottomBarHeight), vec2(ui.windowWidth(), ui.windowHeight()), SETTINGS.uiColor1 / 3)

	ui.pushDWriteFont(fontRegular)
	ui.setCursorX(0)
	ui.setCursorY(10)
	ui.dwriteTextAligned(
		versionString,
		26 * cui.scaleY(),
		ui.Alignment.End,
		ui.Alignment.End,
		ui.availableSpace() - vec2(40, 10) * cui.scaleY(),
		false,
		rgbm(0.8, 0.8, 0.8, 1)
	)

	ui.setCursorX(0)
	ui.setCursorY(0)

	-- ui.dwriteTextAligned(
	-- 	"OFFLINE",
	-- 	26 * cui.scaleY(),
	-- 	ui.Alignment.End,
	-- 	ui.Alignment.End,
	-- 	ui.availableSpace() - vec2(100 * cui.scaleX(), 10 * cui.scaleY()),
	-- 	false,
	-- 	rgbm(1, 0.9, 0, 1)
	-- )
	-- ui.popDWriteFont()

	-- ui.drawCircleFilled(
	-- 	vec2(ui.windowWidth() - 30 * cui.scaleX(), ui.windowHeight() - 30 * cui.scaleY()),
	-- 	10 * cui.scaleX(),
	-- 	rgbm.colors.orange
	-- )

	ui.pushStyleColor(ui.StyleColor.Button, rgbm.colors.transparent)
	ui.setCursorX(0)
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
end

function homeBar(buttons)
	ui.setCursorX(0)
	ui.setCursorY(topBarHeight)

	ui.pushStyleColor(ui.StyleColor.Button, SETTINGS.uiColor1)

	for i in ipairs(buttons) do
		local menuButton = buttons[i]
		local enabled = menuButton.enabled
		local hidden = false

		if menuButton.condition() then
			hidden = true
		end

		if
			not hidden
			and cui.menuButton(
				menuButton.label,
				menuButtonSize,
				ui.Alignment.Center,
				ui.Alignment.Center,
				enabled and ui.ButtonFlags.None or ui.ButtonFlags.Disabled,
				false,
				i == 1
			)
		then
			menuButton.func()
		end

		ui.sameLine()
	end

	ui.popStyleColor(1)
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

local sessionInfoTable = {
	{
		label = function()
			return raceSessiontTypeString[sim.raceSessionType + 1]
		end,
		row1 = function()
			return string.format("%02d:%02d", sim.timeHours, sim.timeMinutes)
		end,
		row2 = function()
			if sim.raceSessionType == ac.SessionType.Race then
				return string.format("%.1f", sim.timeToSessionStart)
			else
				return ""
			end
		end,
	},
	{
		label = function()
			return "Road"
		end,
		row1 = function()
			return string.format("Track - %.1f C", sim.roadTemperature)
		end,
		row2 = function()
			return string.format(
				"%s - %s %%",
				findClosestIndex(sim.roadGrip * 100, trackGrip),
				math.round(sim.roadGrip * 100, 1)
			)
		end,
	},
	{
		label = function()
			return "Ambient"
		end,
		row1 = function()
			return string.format("Air - %.1f C", sim.ambientTemperature)
		end,
		row2 = function()
			return string.format("Humidity - %.0f %%", ac.getAirHumidity(vec3(0, 0, 0)) * 100)
		end,
	},
}

local function sessionInfo()
	local startX = ui.windowWidth() / 50
	local startY = 50 * cui.scaleY()
	local sizeX = 171 * cui.scaleX()
	local sizeY = 35 * cui.scaleY()
	local gap = 3

	local fontSize = math.floor(sizeY * 0.55)
	fontSize = (fontSize % 2 ~= 0) and fontSize or fontSize + 1

	ui.setCursor(vec2(startX, startY))
	for i in ipairs(sessionInfoTable) do
		ui.beginGroup()

		ui.offsetCursorX(-1)

		ui.drawRectFilled(ui.getCursor(), ui.getCursor() + vec2(sizeX, sizeY), rgbm(0, 0, 0, 0.6))
		ui.pushDWriteFont(fontBold)

		ui.dwriteTextAligned(
			string.upper(sessionInfoTable[i].label()),
			fontSize,
			ui.Alignment.Center,
			ui.Alignment.Center,
			vec2(sizeX, sizeY)
		)
		ui.popDWriteFont()

		ui.drawRectFilled(ui.getCursor(), ui.getCursor() + vec2(sizeX, sizeY), rgbm(0.1, 0.1, 0.1, 0.5))
		ui.dwriteTextAligned(
			sessionInfoTable[i].row1(),
			fontSize,
			ui.Alignment.Center,
			ui.Alignment.Center,
			vec2(sizeX, sizeY)
		)

		ui.drawRectFilled(ui.getCursor(), ui.getCursor() + vec2(sizeX, sizeY), rgbm(0.1, 0.1, 0.1, 0.5))

		ui.dwriteTextAligned(
			sessionInfoTable[i].row2(),
			fontSize,
			ui.Alignment.Center,
			ui.Alignment.Center,
			vec2(sizeX, sizeY)
		)

		ui.endGroup()
		ui.setCursor(vec2(startX + ((sizeX + gap) * i), startY))
	end
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
	ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), topBarHeight), rgbm(0.2, 0.2, 0.2, 0.5))

	ui.drawRectFilled(
		vec2(0, topBarHeight),
		vec2(ui.windowWidth(), (topBarHeight + menuButtonSize * cui.scaleY())),
		SETTINGS.uiColor1 / 1.3
	)
	ui.setCursorX(ui.windowWidth() / 2 - acLogoSize.x / 2)
	ui.setCursorY(topBarHeight * 0.2)
	ui.image(acLogo, acLogoSize)

	sessionInfo()
end

function settingsMenuCommon(path, bottomBarButtons, escapeAction)
	ui.drawRectFilled(vec2(0, 0), vec2(sim.windowWidth, sim.windowHeight), SETTINGS.uiColor1 / 1.1)

	-- local storagePath = STORAGE.settingsTab > 1 and "Settings/" .. page.label or "Settings/"
	topSubBar("/Settings" .. path)
	bottomBar(bottomBarButtons)
end

function updateCommon()
	acLogoSize = ui.imageSize(acLogo) * cui.scaleY()
	topBarHeight = 200 * cui.scaleY()
	bottomBarHeight = ui.windowHeight() - 56 * cui.scaleY()
end
