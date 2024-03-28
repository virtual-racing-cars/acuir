local sim = ac.getSim()

local acLogo = ac.getFolder(ac.FolderID.Root) .. "\\launcher\\themes\\default\\graphics\\btn_AC_logo.png"
local acLogoSize = ui.imageSize(acLogo) / 1.75 * UI_SCALE_X / 100

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

local function getWindDirection()
	return windDirection[math.floor((math.min(sim.windDirectionDeg, 179) + 180) / 360 * 8) + 1]
end

local personalBestINI = ac.INIConfig.load(ac.getFolder(ac.FolderID.ACDocuments) .. "\\personalbest.ini")
local personalBestLapTime = ac.lapTimeToString(
	personalBestINI:get(string.upper(ac.getCarID(0) .. "@" .. ac.getTrackID() .. "-" .. ac.getTrackLayout()), "TIME", 0)
)

local pageTitleFontSize = 70 * UI_SCALE_Y / 100
local sessionFontSize = 20 * UI_SCALE_Y / 100
local infoFontSize = 15 * UI_SCALE_Y / 100

local buttonSize = vec2(UI_SCALE_X, UI_SCALE_Y)

local infoText = {
	function()
		return 1, 1, raceSessiontTypeString[sim.raceSessionType + 1], "", "Microsoft JhengHei UI;Weight=Bold"
	end,
	function()
		return 1, 2, "Duration: ", ac.lapTimeToString(sim.currentSessionTime)
	end,
	function()
		return 1, 3, "Clock: ", string.format("%02d:%02d", sim.timeHours, sim.timeMinutes)
	end,
	function()
		return 1, 4, "Remaining: ", ac.lapTimeToString(sim.sessionTimeLeft)
	end,
	function()
		return 2, 1, "Air Temp: ", math.round(sim.ambientTemperature, 1)
	end,
	function()
		return 2, 2, "Track Temp: ", math.round(sim.roadTemperature, 1)
	end,
	function()
		return 2, 3, "Track Grip: ", math.round(sim.roadGrip * 100, 1)
	end,
	function()
		return 2, 4, "Wind: ", math.round(sim.windSpeedKmh, 1) .. " km/h " .. getWindDirection()
	end,
}

local carText = {
	function()
		return 1, 1, "", ac.getCarName(0)
	end,
	function()
		return 1, 2, "Personal best: ", personalBestLapTime
	end,
	function()
		return 1, 3, "Total Distance driven: ", math.round(ac.getCar(0).distanceDrivenTotalKm) .. " km"
	end,
	function()
		return 1, 4, "Session Distance driven: ", math.round(ac.getCar(0).distanceDrivenSessionKm) .. " km"
	end,
}

function TopBar()
	ui.drawRectFilled(
		vec2(0, 0),
		vec2(ui.availableSpaceX(), UI_SCALE_Y),
		settings.uiPrimaryColor,
		0,
		ui.CornerFlags.None
	)
	ui.drawRectFilledMultiColor(
		vec2(0, UI_SCALE_Y),
		vec2(ui.availableSpaceX(), 0),
		rgbm(1, 1, 1, 0.2),
		rgbm(1, 1, 1, 0.2),
		rgbm(0, 0, 0, 0),
		rgbm(0, 0, 0, 0)
	)

	setCursorX(10)
	setCursorY(15)

	ui.image(acLogo, acLogoSize, rgbm(1, 1, 1, 1))

	setCursorX(130)
	setCursorY(0)
	ui.dwriteTextAligned(
		string.upper(MenuPagesString[storage.page]),
		pageTitleFontSize,
		ui.Alignment.Start,
		ui.Alignment.Start,
		vec2(sim.windowWidth, sim.windowHeight),
		false,
		rgbm.colors.white
	)

	ui.setCursorX(sim.windowWidth - 300 * UI_SCALE_X / 100)
	setCursorY(0)
	if ui.modernButtonAdvanced("##Restart", buttonSize, ui.ButtonFlags.None, ui.Icons.Restart) then
		ac.tryToRestartSession()
	end

	ui.setCursorX(sim.windowWidth - 200 * UI_SCALE_X / 100)
	setCursorY(0)
	if ui.modernButtonAdvanced("##Skip", buttonSize, ui.ButtonFlags.None, ui.Icons.Skip) then
	end

	ui.setCursorX(sim.windowWidth - 100 * UI_SCALE_X / 100)
	setCursorY(0)
	if ui.modernButtonAdvanced("##Exit", buttonSize, ui.ButtonFlags.None, ui.Icons.Leave) then
		ac.shutdownAssettoCorsa()
	end

	for k, v in ipairs(carText) do
		local column, position, label, value, font = v()

		if not font then
			font = "Default"
		end
		ui.pushDWriteFont("font")

		setCursorY(-10 + (20 * position))
		setCursorX(1520 + 150 * column)

		ui.dwriteTextAligned(
			label .. value,
			infoFontSize,
			ui.Alignment.Start,
			ui.Alignment.Start,
			vec2(250, 22),
			false,
			rgbm.colors.white
		)
		ui.popDWriteFont()
	end

	ui.drawRectFilled(
		vec2(ui.availableSpaceX() - 600 * UI_SCALE_X / 100, 0),
		vec2(ui.availableSpaceX() - 300 * UI_SCALE_X / 100, UI_SCALE_Y),
		settings.uiSecondaryColor,
		0,
		ui.CornerFlags.None
	)

	for k, v in ipairs(infoText) do
		local column, position, label, value, font = v()

		if not font then
			font = "Default"
		end
		ui.pushDWriteFont("font")

		setCursorY(-10 + (20 * position))
		setCursorX(1820 + 150 * column)

		ui.dwriteTextAligned(
			label .. value,
			infoFontSize,
			ui.Alignment.Start,
			ui.Alignment.Start,
			vec2(200, 22),
			false,
			rgbm.colors.white
		)
		ui.popDWriteFont()
	end

	ui.drawLine(vec2(UI_SCALE_Y, UI_SCALE_Y), vec2(ui.availableSpaceX(), UI_SCALE_Y), rgbm(1, 1, 1, 0.25))
end
