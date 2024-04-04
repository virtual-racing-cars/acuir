require("ui\\main\\bar_top")
require("ui\\main\\bar_side")
require("ui\\setup\\page")
require("ui\\apps\\page")
require("ui\\time_table\\page")
require("ui\\settings\\page")

local manifestINI = ac.INIConfig.load("manifest.ini", ac.INIFormat.Extended)
local version = manifestINI:get("ABOUT", "VERSION", "0.0.0")

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

local timer = os.clock() + 60
local exclusiveHudMode = ""

function MainWindow(sim)
	if settings.uiHideonIdle then
		if (ui.mouseDelta() ~= vec2(0, 0) and sim.isWindowForeground) or ui.mouseClicked(ui.MouseButton.Left) then
			timer = os.clock() + 60
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

	childWindow("bars", windowSize, false, ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse, function()
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

		pushSetupListStyle()

		if storage.page == MenuPages.Apps then
			AppsPage(sim)
			exclusiveHudMode = nil
		end

		TopBar()
		SideBar(sim)
		VersionText()

		popSetupListStyle()

		ui.setCursorX(UI_SCALE_Y)
		ui.setCursorY(UI_SCALE_Y)
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

		ui.drawRectFilled(
			vec2(sim.windowWidth / 2 - 1, 0),
			vec2(sim.windowWidth / 2 + 1, sim.windowHeight),
			rgbm.colors.lime
		)

		ui.drawRectFilled(
			vec2(0, sim.windowHeight / 2 - 1),
			vec2(sim.windowWidth, sim.windowHeight / 2 + 1),
			rgbm.colors.lime
		)
	end)

	return exclusiveHudMode
end
