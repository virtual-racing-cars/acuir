require("ui.common")
require("classes.PageManager")
local settings = require("settings")
local cui = require("ui.cui")
local app = require("app")
local pages = require("ui.pages")

pages.pausePM:registerPage("HomePage", nil, require("ui.pause.page_pause_home"))
pages.mainMenuPM:registerPage("SettingsPage", "HomePage", require("ui.SETTINGS.page_settings"))
pages.pausePM:registerPage("SettingsGeneralPage", "SettingsPage", require("ui.SETTINGS.page_general"))
pages.pausePM:registerPage("SettingsControlsPage", "SettingsPage", require("ui.SETTINGS.page_controls"))
pages.pausePM:registerPage("SettingsAudioPage", "SettingsPage", require("ui.SETTINGS.page_audio"))
pages.pausePM:registerPage("SettingsAppearancePage", "SettingsPage", require("ui.SETTINGS.page_appearance"))
pages.pausePM:registerPage("SettingsAiPage", "SettingsPage", require("ui.SETTINGS.page_ai"))

local exclusiveHudMode = ""

local fontRegular = ui.DWriteFont("Rajdhani"):weight(ui.DWriteFont.Weight.SemiBold)
local fontBold = ui.DWriteFont("Rajdhani"):weight(ui.DWriteFont.Weight.Bold)
local fontSemiBold = ui.DWriteFont("Noto Sans SC"):weight(ui.DWriteFont.Weight.SemiBold)

function PauseMenuWindow(dt)
	exclusiveHudMode = ""

	ui.pushAllowKeyboardFocus(false)

	local perfTime = os.preciseClock()

	if ui.keyboardButtonPressed(ui.KeyIndex.Escape) or ac.isKeyPressed(ui.KeyIndex.XButton1) then
		if pages.pause:isUndoAvailable() then
			pages.pause:undo()
		end
	end

	if ac.isKeyPressed(ui.KeyIndex.XButton2) then
		if pages.pause:isRedoAvailable() then
			pages.pause:redo()
		end
	end

	ui.pushDWriteFont(fontRegular)
	ui.pushStyleColor(ui.StyleColor.ScrollbarGrab, settings.Appearance.uiColor2)
	ui.pushStyleVar(ui.StyleVar.ScrollbarSize, 3)
	ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)

	local childWindowWith = (2560 * cui.scaleX()) / 5
	local childWindowHeight = (1440 * cui.scaleY()) / 2
	local mainWindowFlags = ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse

	if cui.modalDialogCallback then
		mainWindowFlags = mainWindowFlags
			+ ui.WindowFlags.NoInputs
			+ ui.WindowFlags.NoMouseInputs
			+ ui.WindowFlags.NoFocusOnAppearing
	end

	cui.contentWindow(
		"pause_window",
		vec2((ui.windowWidth() - childWindowWith) / 2, (ui.windowHeight() - childWindowHeight) / 2),
		vec2(childWindowWith, childWindowHeight),
		mainWindowFlags,
		function()
			ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), settings.Appearance.uiColor1 / 1.5)

			exclusiveHudMode = ""
			exclusiveHudMode = pages.pausePM:draw()
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

	ui.popDWriteFont()
	ui.popStyleVar(2)
	ui.popStyleColor(1)
	ui.popAllowKeyboardFocus()

	ac.debug("perfTime", (os.preciseClock() - perfTime) * 1000)

	return app.state.debug and "debug" or exclusiveHudMode
end
