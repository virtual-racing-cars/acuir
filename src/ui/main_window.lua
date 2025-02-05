require("ui.common")
require("classes.PageManager")
local settings = require("settings")
local cui = require("ui.cui")
local app = require("app")
local style = require("style")
local pages = require("ui.pages")

pages.manager:registerPage("MainMenu", require("ui.home.page"))
pages.manager:registerPage("SetupPage", require("ui.setup.page_setup"))
pages.manager:registerPage("SettingsPage", require("ui.SETTINGS.page_settings"))
pages.manager:registerPage("SetupAppsPage", require("ui.setup.page_apps"))
pages.manager:registerPage("SettingsGeneralPage", require("ui.SETTINGS.page_general"))
pages.manager:registerPage("SettingsControlsPage", require("ui.SETTINGS.page_controls"))
pages.manager:registerPage("SettingsAudioPage", require("ui.SETTINGS.page_audio"))
pages.manager:registerPage("SettingsAppearancePage", require("ui.SETTINGS.page_appearance"))
pages.manager:registerPage("SettingsAiPage", require("ui.SETTINGS.page_ai"))

local exclusiveHudMode = ""

function MainMenuWindow(dt)
	local perfTime = os.preciseClock()

	ui.pushAllowKeyboardFocus(false)
	exclusiveHudMode = ""

	if ac.isKeyPressed(ui.KeyIndex.XButton1) then
		if pages:isUndoAvailable() then
			pages:undo()
		end
	end

	if ac.isKeyPressed(ui.KeyIndex.XButton2) then
		if pages:isRedoAvailable() then
			pages:redo()
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

			exclusiveHudMode = pages.manager:draw()
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
