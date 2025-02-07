local settings = require("settings")
local cui = require("ui.cui")
local app = require("app")
local csp = require("csp")
local simutils = require("sim")
local style = require("style")
local sim = ac.getSim()

local acLogo = ac.getFolder(ac.FolderID.Root) .. "\\launcher\\themes\\default\\graphics\\btn_AC_logo.png"
local acLogoSize = ui.imageSize(acLogo) * cui.scaleY()

local topBarHeight = 200 * cui.scaleY()

local menuButtonSize = 56
local versionString = string.format("%s: %s, CSP: %s (%s)", app.name, app.version, csp.version, csp.versionCode)

function bottomBar(buttons)
	ui.drawRectFilled(
		vec2(0, ui.windowHeight() - 56 * cui.scaleY()),
		vec2(ui.windowWidth(), ui.windowHeight()),
		settings.Appearance.uiColor1 / 3
	)

	if settings.General.showVersions then
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
	end

	ui.pushStyleColor(ui.StyleColor.Button, rgbm.colors.transparent)
	ui.setCursorX(0)
	ui.setCursorY(ui.windowHeight() - 56 * cui.scaleY())
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
		ui.offsetCursor(-1)
	end
	ui.popStyleColor(1)
end

function homeBar(buttons)
	ui.setCursorX(0)
	ui.setCursorY(topBarHeight)

	ui.pushStyleColor(ui.StyleColor.Button, settings.Appearance.uiColor1)

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

local sessionInfoTable = {
	{
		label = function()
			return "Sim Time"
		end,
		row1 = function()
			return simutils.simDateString
		end,
		row2 = function()
			return simutils.simTimeString
		end,
	},

	{
		label = function()
			return simutils.raceSessionTypeString
		end,
		row1 = function()
			return simutils.sessionTotalTimeString
		end,
		row2 = function()
			return simutils.sessionTimeLeftString
		end,
	},
	{
		label = function()
			return "Track"
		end,
		row1 = function()
			return string.format("Temp - %.1f° C", sim.roadTemperature)
		end,
		row2 = function()
			return string.format("%s - %.1f %%", simutils.trackGripString, sim.roadGrip * 100)
		end,
	},
	{
		label = function()
			return "Air"
		end,
		row1 = function()
			return string.format("Temp - %.1f° C", sim.ambientTemperature)
		end,
		row2 = function()
			return string.format("Humidity - %.0f %%", ac.getAirHumidity(vec3(0, 0, 0)) * 100)
		end,
	},
	{
		label = function()
			return "Wind"
		end,
		row1 = function()
			return string.format("Speed - %.1f kmh", sim.windSpeedKmh)
		end,
		row2 = function()
			return string.format("%s - %.1f°", simutils.windDirectionString, sim.windDirectionDeg + 180)
		end,
	},
}

local function sessionInfo()
	local startX = (ui.windowWidth() / 4) * 3 + 20 * cui.scaleY()
	local startY = 12 * cui.scaleY()
	local sizeX = 192 * cui.scaleX()
	local sizeY = 35 * cui.scaleY()

	local fontSize = math.floor(sizeY * 0.7)
	fontSize = (fontSize % 2 ~= 0) and fontSize + 1 or fontSize

	ui.setCursor(vec2(startX, startY))
	for i in ipairs(sessionInfoTable) do
		ui.beginGroup()

		ui.pushDWriteFont("Rajdhani;weight=bold")
		cui.snapCursor()
		ui.dwriteTextAligned(
			string.upper(sessionInfoTable[i].label()) .. ":",
			fontSize,
			ui.Alignment.Start,
			ui.Alignment.Center,
			vec2(sizeX, sizeY)
		)
		ui.popDWriteFont()
		ui.sameLine()

		ui.offsetCursorX(-50 * cui.scaleY())

		cui.snapCursor()
		ui.dwriteTextAligned(
			sessionInfoTable[i].row1(),
			fontSize,
			ui.Alignment.Start,
			ui.Alignment.Center,
			vec2(sizeX, sizeY)
		)
		ui.sameLine()
		ui.offsetCursorX(20 * cui.scaleY())

		cui.snapCursor()
		ui.dwriteTextAligned(
			sessionInfoTable[i].row2(),
			fontSize,
			ui.Alignment.Start,
			ui.Alignment.Center,
			vec2(sizeX, sizeY)
		)

		ui.endGroup()
		ui.setCursorX(startX)
	end
end

function topSubBar(path)
	ui.setCursorX(ui.windowWidth() / 65)
	ui.setCursorY(topBarHeight / 2 - acLogoSize.y / 2)
	ui.image(acLogo, acLogoSize)

	cui.setCursorX(225)
	ui.setCursorY(topBarHeight / 2 - (100 * cui.scaleY()) / 2)
	ui.pushDWriteFont(ui.DWriteFont("Rajdhani"):weight(ui.DWriteFont.Weight.SemiBold))

	ui.dwriteTextAligned(
		path,
		60 * cui.scaleY(),
		ui.Alignment.Start,
		ui.Alignment.Center,
		vec2(450 * cui.scaleX(), 100 * cui.scaleY()),
		false,
		rgbm(1, 1, 1, 1)
	)
	ui.popDWriteFont()
end

function topBar(path)
	local driveButtonWidth = 500 * cui.scaleY()
	local driveButtonHeight = 80 * cui.scaleY()

	ui.drawRectFilled(0, vec2(ui.windowWidth(), topBarHeight), rgbm(0.1, 0.1, 0.1, 0.95))
	ui.drawRectFilled(
		vec2(0, topBarHeight),
		vec2(ui.windowWidth(), (topBarHeight + menuButtonSize * cui.scaleY())),
		settings.Appearance.uiColor1 / 1.3
	)

	topSubBar(path)

	ui.setCursorY(topBarHeight / 2 - driveButtonHeight / 2)
	ui.setCursorX(ui.windowWidth() / 2 - driveButtonWidth / 2)
	ui.offsetCursorX(-driveButtonHeight)
	if
		cui.iconButton(
			"##resetSession",
			ui.Icons.Reset,
			driveButtonHeight,
			driveButtonHeight,
			simutils.sessionRestartable and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
		)
	then
		ac.tryToRestartSession()
	end
	ui.sameLine()

	ui.pushStyleColor(ui.StyleColor.Button, rgbm.colors.green)
	if
		cui.specialButton(
			"Drive Now",
			vec2(driveButtonWidth, driveButtonHeight),
			ui.Alignment.Center,
			ui.Alignment.Center
		)
	then
		ac.tryToStart()
	end

	ui.popStyleColor(1)
	ui.sameLine()

	if
		cui.iconButton(
			"##skipSession",
			ui.Icons.Skip,
			driveButtonHeight,
			driveButtonHeight,
			simutils.sessionSkippable and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
		)
	then
		ac.tryToSkipSession()
	end

	sessionInfo()
end

function settingsMenuCommon(path, bottomBarButtons)
	ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), settings.Appearance.uiColor1 / 1.1)

	topSubBar("/Settings" .. path)
	bottomBar(bottomBarButtons)
end

function updateCommon()
	acLogoSize = ui.imageSize(acLogo) * cui.scaleY()
	topBarHeight = 200 * cui.scaleY()
end
