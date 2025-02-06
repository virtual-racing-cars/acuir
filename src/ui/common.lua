local settings = require("settings")
local cui = require("ui.cui")
local app = require("app")
local csp = require("csp")
local simutils = require("sim")
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
			return simutils.raceSessionTypeString
		end,
		row1 = function()
			return simutils.simTimeString
		end,
		row2 = function()
			if sim.raceSessionType == ac.SessionType.Race then
				local hours = sim.timeToSessionStart / 3600000
				local minutes = (sim.timeToSessionStart % 3600000) / 60000

				return string.format("%02d:%02d", hours, minutes)
			else
				return
			end
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
	local startX = ui.windowWidth() / 50
	local startY = 50 * cui.scaleY()
	local sizeX = 170 * cui.scaleX()
	local sizeY = 35 * cui.scaleY()
	local gap = 3

	local fontSize = math.floor(sizeY * 0.6)
	fontSize = (fontSize % 2 ~= 0) and fontSize + 1 or fontSize

	ui.setCursor(vec2(startX, startY))
	for i in ipairs(sessionInfoTable) do
		ui.beginGroup()

		ui.offsetCursorX(-1)

		ui.drawRectFilled(ui.getCursor(), ui.getCursor() + vec2(sizeX, sizeY), rgbm(0, 0, 0, 0.6))

		ui.dwriteTextAligned(
			string.upper(sessionInfoTable[i].label()),
			fontSize,
			ui.Alignment.Center,
			ui.Alignment.Center,
			vec2(sizeX, sizeY)
		)

		local expanded = not sessionInfoTable[i].row2()
		ui.drawRectFilled(
			ui.getCursor(),
			ui.getCursor() + vec2(sizeX, expanded and sizeY * 2 or sizeY),
			rgbm(0.1, 0.1, 0.1, 0.5)
		)
		ui.dwriteTextAligned(
			sessionInfoTable[i].row1(),
			expanded and fontSize * 2 or fontSize,
			ui.Alignment.Center,
			ui.Alignment.Center,
			vec2(sizeX, expanded and sizeY * 2 or sizeY)
		)

		if not expanded then
			ui.drawRectFilled(ui.getCursor(), ui.getCursor() + vec2(sizeX, sizeY), rgbm(0.1, 0.1, 0.1, 0.5))
			ui.dwriteTextAligned(
				sessionInfoTable[i].row2(),
				fontSize,
				ui.Alignment.Center,
				ui.Alignment.Center,
				vec2(sizeX, sizeY)
			)
		end

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
		settings.Appearance.uiColor1 / 1.3
	)
	ui.setCursorX(ui.windowWidth() / 2 - acLogoSize.x / 2)
	ui.setCursorY(topBarHeight * 0.2)
	ui.image(acLogo, acLogoSize)

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
