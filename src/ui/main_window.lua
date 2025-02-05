require("ui.common")
require("classes.PageManager")
local settings = require("settings")
local cui = require("ui.cui")
local app = require("app")
local style = require("style")
local pages = require("ui.pages")

pages.mainMenuPM:registerPage("HomePage", nil, require("ui.home.page"))
pages.mainMenuPM:registerPage("SetupPage", "HomePage", require("ui.setup.page_setup"))
pages.mainMenuPM:registerPage("SettingsPage", "HomePage", require("ui.SETTINGS.page_settings"))
pages.mainMenuPM:registerPage("SetupAppsPage", "SetupPage", require("ui.setup.page_apps"))
pages.mainMenuPM:registerPage("SettingsGeneralPage", "SettingsPage", require("ui.SETTINGS.page_general"))
pages.mainMenuPM:registerPage("SettingsControlsPage", "SettingsPage", require("ui.SETTINGS.page_controls"))
pages.mainMenuPM:registerPage("SettingsAudioPage", "SettingsPage", require("ui.SETTINGS.page_audio"))
pages.mainMenuPM:registerPage("SettingsAppearancePage", "SettingsPage", require("ui.SETTINGS.page_appearance"))
pages.mainMenuPM:registerPage("SettingsAiPage", "SettingsPage", require("ui.SETTINGS.page_ai"))

local exclusiveHudMode = ""

function MainMenuWindow(dt)
	local perfTime = os.preciseClock()

	ui.pushAllowKeyboardFocus(false)
	exclusiveHudMode = ""

	if ui.keyboardButtonPressed(ui.KeyIndex.Escape) or ac.isKeyPressed(ui.KeyIndex.XButton1) then
		if pages.mainMenuPM:isUndoAvailable() then
			pages.mainMenuPM:undo()
		end
	end

	if ac.isKeyPressed(ui.KeyIndex.XButton2) then
		if pages.mainMenuPM:isRedoAvailable() then
			pages.mainMenuPM:redo()
		end
	end

	style:pushStyleMain()

	local childWindowWith = (2560 - 120) * cui.scaleX()
	local childWindowHeight = (1440 - 80) * cui.scaleX()
	local mainWindowFlags = ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse

	if cui.modalDialogCallback then
		mainWindowFlags = mainWindowFlags
			+ ui.WindowFlags.NoInputs
			+ ui.WindowFlags.NoMouseInputs
			+ ui.WindowFlags.NoFocusOnAppearing
	end

	cui.contentWindow(
		"main_window",
		vec2((ui.windowWidth() - childWindowWith) / 2, (ui.windowHeight() - childWindowHeight) / 2),
		vec2(childWindowWith, childWindowHeight),
		mainWindowFlags,
		function()
			updateCommon()

			exclusiveHudMode = pages.mainMenuPM:draw()
		end
	)

	if cui.modalDialogCallback then
		cui.contentWindow(
			"callback_window",
			vec2(0, 0),
			ui.windowSize(),
			ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse,
			function()
				ui.setCursor(0)
				ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), settings.Appearance.uiColor1 / 1.2)
				local childWindowWith = ui.windowWidth() / 5
				local childWindowHeight = ui.windowHeight() / 5
				cui.contentWindow(
					"callback_subwindow",
					vec2((ui.windowWidth() - childWindowWith) / 2, (ui.windowHeight() - childWindowHeight) / 2),
					vec2(childWindowWith, childWindowHeight),
					ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse,
					function()
						ui.bringWindowToFront()
						ui.setCursor(0)
						if cui.modalDialogCallback() then
							cui.modalDialogCallback = nil
						end
					end
				)
			end
		)
	end

	style:popStyleMain()

	ui.popAllowKeyboardFocus()

	ac.debug("perfTime", (os.preciseClock() - perfTime) * 1000)

	return app.state.debug and "debug" or exclusiveHudMode
end
