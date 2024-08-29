require("ui\\main\\bar_side")
require("ui\\setup\\page")
require("ui\\apps\\page")
require("ui\\time_table\\page")
require("ui\\settings\\page")

local sim = ac.getSim()

local manifestINI = ac.INIConfig.load("manifest.ini", ac.INIFormat.Extended)
local version = manifestINI:get("ABOUT", "VERSION", "0.0.0")

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

local function VersionText()
	setCursorX(0)
	setCursorY(0)
	if settings.showVersions then
		ui.dwriteTextAligned(
			"v" .. version .. ", CSP: " .. ac.getPatchVersion() .. " (" .. ac.getPatchVersionCode() .. ")",
			20,
			ui.Alignment.End,
			ui.Alignment.End,
			ui.availableSpace(),
			false,
			rgbm(0.8, 0.8, 0.8, 1)
		)
	end
end

local timer = os.clock() + settings.uiHideonIdleTime
local exclusiveHudMode = ""

function MainWindow()
	if settings.uiHideonIdleTime > 0 then
		if (ui.mouseDelta() ~= vec2(0, 0) and sim.isWindowForeground) or ui.mouseClicked(ui.MouseButton.Left) then
			timer = os.clock() + settings.uiHideonIdleTime
		end

		if timer < os.clock() then
			ac.setCurrentCamera(ac.CameraMode.Start)
			return ""
		end
	end

	local windowSize = vec2(sim.windowWidth, sim.windowHeight)
	setCursorX(0)
	setCursorY(0)

	if not storage.appOpen then
		windowSize = vec2(UI_SCALE_Y, UI_SCALE_Y)
	end

	childWindow(
		"main_window",
		windowSize,
		false,
		ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse,
		function()
			exclusiveHudMode = ""

			if ui.invisibleButton("ui_toggle", vec2(UI_SCALE_Y, UI_SCALE_Y)) then
				if not storage.appOpen then
					ac.tryToOpenRaceMenu("race")
					ac.tryToOpenRaceMenu("setup")
				end

				storage.appOpen = not storage.appOpen
			end

			if not storage.appOpen then
				exclusiveHudMode = nil
				return
			end

			storage.hasAppOpened = true

			ui.bringWindowToFront()

			if storage.page == MenuPages.Apps then
				AppsPage(sim)
				exclusiveHudMode = "apps"
			end

			-- TopBar()
			SideBar(sim)
			VersionText()

			setCursorX(1605)
			setCursorY(50)

			local fontSize = 18 * UI_SCALE_Y / 100

			childWindow(
				"session_window",
				vec2(330 * UI_SCALE_Y / 100, 100 * UI_SCALE_Y / 100),
				false,
				ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse,
				function()
					ui.drawRectFilled(
						vec2(0, 0),
						ui.availableSpace(),
						settings.uiSecondaryColor,
						0,
						ui.CornerFlags.None
					)

					setCursorX(10)
					ui.beginGroup()

					ui.pushDWriteFont("Defualt;Weight=Bold")
					ui.dwriteText(raceSessiontTypeString[sim.raceSessionType + 1], fontSize, rgbm.colors.white)
					ui.popDWriteFont()

					local saveYPos = ui.getCursorY()

					ui.dwriteText(
						"Duration: " .. ac.lapTimeToString(sim.currentSessionTime),
						fontSize,
						rgbm.colors.white
					)

					ui.dwriteText("Remaining: " .. ac.lapTimeToString(sim.sessionTimeLeft), fontSize, rgbm.colors.white)

					ui.endGroup()

					setCursorX(180)
					ui.setCursorY(saveYPos)

					ui.beginGroup(10)

					ui.dwriteText(
						"Sim Time: " .. string.format("%02d:%02d", sim.timeHours, sim.timeMinutes),
						fontSize,
						rgbm.colors.white
					)

					ui.dwriteText("Real Time: " .. os.date("%H:%M"), fontSize, rgbm.colors.white)

					ui.endGroup()

					setCursorX(355)
					setCursorY(20)
					if
						ui.modernButtonAdvanced(
							"##Restart",
							vec2(200, 200) * UI_SCALE_Y / 100 / 3,
							ui.ButtonFlags.None,
							ui.Icons.Restart
						)
					then
						ac.tryToRestartSession()
					end

					ui.sameLine()
					if
						ui.modernButtonAdvanced(
							"##Skip",
							vec2(200, 200) * UI_SCALE_Y / 100 / 3,
							sim.sessionsCount > 1 and ui.ButtonFlags.None or ui.ButtonFlags.Disabled,
							ui.Icons.Skip
						)
					then
						ac.tryToSkipSession()
					end
				end
			)

			setCursorX(1950)
			setCursorY(50)

			childWindow(
				"weather_window",
				vec2(335 * UI_SCALE_Y / 100, 100 * UI_SCALE_Y / 100),
				false,
				ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse,
				function()
					ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), settings.uiPrimaryColor, 0, ui.CornerFlags.None)

					setCursorX(10)
					ui.beginGroup()

					local saveYPos = ui.getCursorY()

					ui.dwriteText("Air Temp: " .. math.round(sim.ambientTemperature, 1), fontSize, rgbm.colors.white)
					ui.dwriteText("Track Temp: " .. math.round(sim.roadTemperature, 1), fontSize, rgbm.colors.white)
					ui.dwriteText("Track Grip: " .. math.round(sim.roadGrip * 100, 1), fontSize, rgbm.colors.white)

					ui.endGroup()

					setCursorX(180)
					ui.setCursorY(saveYPos)

					ui.beginGroup(10)

					ui.dwriteText("Weather: ", fontSize, rgbm.colors.white)
					ui.sameLine()
					ui.offsetCursorY(7)
					ui.icon(ui.weatherIcon(sim.weatherType), vec2(15, 15))
					ui.offsetCursorY(-7)

					ui.dwriteText(
						"Wind: " .. math.round(sim.windSpeedKmh, 1) .. " km/h " .. getWindDirection(),
						fontSize,
						rgbm.colors.white
					)
					ui.dwriteText("Wind: " .. math.round(sim.ambientTemperature, 1), fontSize, rgbm.colors.white)

					setCursorX(355)
					setCursorY(20)
					if
						ui.modernButtonAdvanced(
							"##Restart",
							vec2(200, 200) * UI_SCALE_Y / 100 / 3,
							ui.ButtonFlags.None,
							ui.Icons.Restart
						)
					then
						ac.tryToRestartSession()
					end

					ui.sameLine()
					if
						ui.modernButtonAdvanced(
							"##Skip",
							vec2(200, 200) * UI_SCALE_Y / 100 / 3,
							sim.sessionsCount > 1 and ui.ButtonFlags.None or ui.ButtonFlags.Disabled,
							ui.Icons.Skip
						)
					then
						ac.tryToSkipSession()
					end

					ui.sameLine()
				end
			)

			setCursorX(2300)
			setCursorY(50)

			childWindow(
				"session_control_window",
				vec2(220 * UI_SCALE_Y / 100, 100 * UI_SCALE_Y / 100),
				false,
				ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse,
				function()
					ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), settings.uiPrimaryColor, 0, ui.CornerFlags.None)

					ui.dwriteTextAligned(
						"Session Control",
						fontSize,
						ui.Alignment.Center,
						ui.Alignment.Center,
						vec2(ui.availableSpaceX(), 20 * UI_SCALE_Y / 100)
					)

					setCursorX(5)

					if
						ui.modernButtonAdvanced(
							"##Restart",
							vec2(200, 200) * UI_SCALE_Y / 100 / 3,
							ui.ButtonFlags.None,
							ui.Icons.Restart
						)
					then
						ac.tryToRestartSession()
					end

					ui.sameLine()
					if
						ui.modernButtonAdvanced(
							"##Skip",
							vec2(200, 200) * UI_SCALE_Y / 100 / 3,
							sim.sessionsCount > 1 and ui.ButtonFlags.None or ui.ButtonFlags.Disabled,
							ui.Icons.Skip
						)
					then
						ac.tryToSkipSession()
					end

					ui.sameLine()
					if
						ui.modernButtonAdvanced(
							"##ExitAC",
							vec2(200, 200) * UI_SCALE_Y / 100 / 3,
							ui.ButtonFlags.None,
							ui.Icons.Leave
						)
					then
						ac.shutdownAssettoCorsa()
					end
				end
			)

			setCursorX(237)
			setCursorY(200)
			childWindow(
				"page_windows",
				ui.availableSpace(),
				false,
				ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse,
				function()
					-- ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), rgbm(0.2, 0.8, 1, 0.25), 0, ui.CornerFlags.None)

					if storage.page == MenuPages.Setup then
						SetupPage(sim)
						exclusiveHudMode = "debug"
					end

					if storage.page == MenuPages.TimeTable then
						TimeTablePage(sim)
						exclusiveHudMode = "debug"
					end

					if storage.page == MenuPages.Settings then
						SettingsPage(sim)
						exclusiveHudMode = ""
					end
				end
			)

			-- ui.drawRectFilled(
			-- 	vec2(sim.windowWidth / 2 - 1, 0),
			-- 	vec2(sim.windowWidth / 2 + 1, sim.windowHeight),
			-- 	rgbm.colors.lime
			-- )

			-- ui.drawRectFilled(
			-- 	vec2(0, sim.windowHeight / 2 - 1),
			-- 	vec2(sim.windowWidth, sim.windowHeight / 2 + 1),
			-- 	rgbm.colors.lime
			-- )
		end
	)

	return exclusiveHudMode
end
