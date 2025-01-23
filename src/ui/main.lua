require("ui\\common")
require("classes.PageManager")

local HomePage = require("ui.home.page")
local SetupPage = require("ui.setup.page_setup")
local SetupAppsPage = require("ui.setup.page_apps")
local SetupIoPage = require("ui.setup.page_io")
local SettingsPage = require("ui.settings.page_settings")
local SettingsGeneralPage = require("ui.settings.page_general")
local SettingsControls = require("ui.settings.page_controls")
local SettingsAudioPage = require("ui.settings.page_audio")
local SettingsAppearancePage = require("ui.settings.page_appearance")
local SettingsAiPage = require("ui.settings.page_ai")

local pageManager = PageManager()
pageManager:registerPage("HomePage", nil, HomePage)
pageManager:registerPage("SetupPage", "HomePage", SetupPage)
pageManager:registerPage("SettingsPage", "HomePage", SettingsPage)
pageManager:registerPage("SetupAppsPage", "SetupPage", SetupAppsPage)
pageManager:registerPage("SetupIoPage", "SetupPage", SetupIoPage)
pageManager:registerPage("SettingsGeneralPage", "SettingsPage", SettingsGeneralPage)
pageManager:registerPage("SettingsControlsPage", "SettingsPage", SettingsControls)
pageManager:registerPage("SettingsAudioPage", "SettingsPage", SettingsAudioPage)
pageManager:registerPage("SettingsAppearancePage", "SettingsPage", SettingsAppearancePage)
pageManager:registerPage("SettingsAiPage", "SettingsPage", SettingsAiPage)

function goToHomePage()
	pageManager:setPage("HomePage")
end

function goToSetupPage()
	pageManager:setPage("SetupPage")
end

function goToSettingsPage()
	pageManager:setPage("SettingsPage")
end

function goToSetupAppsPage()
	pageManager:setPage("SetupAppsPage")
end

function goToSetupIoPage()
	pageManager:setPage("SetupIoPage")
end

function goToSettingsGeneralPage()
	pageManager:setPage("SettingsGeneralPage")
end

function goToSettingsControlsPage()
	pageManager:setPage("SettingsControlsPage")
end

function goToSettingsAudioPage()
	pageManager:setPage("SettingsAudioPage")
end

function goToSettingsAppearancePage()
	pageManager:setPage("SettingsAppearancePage")
end

function goToSettingsAiPage()
	pageManager:setPage("SettingsAiPage")
end

local sim = ac.getSim()
local timer = os.clock() + settings.uiHideonIdleTime
local exclusiveHudMode = ""

function MainWindow()
	local perfTime = os.preciseClock()

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

			exclusiveHudMode = pageManager:draw()

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

	ac.debug("perfTime", (os.preciseClock() - perfTime) * 1000)

	-- exclusiveHudMode = "apps"

	return exclusiveHudMode
end
