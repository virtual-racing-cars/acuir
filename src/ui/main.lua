require("ui\\common")
require("ui\\home\\page")
require("ui\\setup\\page")
require("ui\\apps\\page")
require("ui\\time_table\\page")
require("ui\\settings\\page")

local sim = ac.getSim()

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

	ui.setCursor(0)
	childWindow(
		"main_window",
		vec2(sim.windowWidth, sim.windowHeight),
		false,
		ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse,
		function()
			exclusiveHudMode = ""

			if not storage.appOpen then
				exclusiveHudMode = nil
				return
			end

			ui.bringWindowToFront()

			if storage.page == MenuPages.Home then
				HomePage(sim)
			end

			if storage.page == MenuPages.Setup then
				SetupPage()
				exclusiveHudMode = "debug"
			end

			if storage.page == MenuPages.Settings then
				SettingsPage(sim)
				exclusiveHudMode = ""
			end

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

			audioDriver()
		end
	)

	-- exclusiveHudMode = "apps"

	return exclusiveHudMode
end
