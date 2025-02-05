require("ui.common")
require("classes.PageManager")
local settings = require("settings")
local cui = require("ui.cui")
local app = require("app")
local style = require("style")

local HomePage = require("ui.home.page")
local SetupPage = require("ui.setup.page_setup")
local SetupAppsPage = require("ui.setup.page_apps")
local SettingsPage = require("ui.SETTINGS.page_settings")
local SettingsGeneralPage = require("ui.SETTINGS.page_general")
local SettingsControls = require("ui.SETTINGS.page_controls")
local SettingsAudioPage = require("ui.SETTINGS.page_audio")
local SettingsAppearancePage = require("ui.SETTINGS.page_appearance")
local SettingsAiPage = require("ui.SETTINGS.page_ai")

local pageManager = PageManager()
pageManager:registerPage("HomePage", nil, HomePage)
pageManager:registerPage("SetupPage", "HomePage", SetupPage)
pageManager:registerPage("SettingsPage", "HomePage", SettingsPage)
pageManager:registerPage("SetupAppsPage", "SetupPage", SetupAppsPage)
pageManager:registerPage("SettingsGeneralPage", "SettingsPage", SettingsGeneralPage)
pageManager:registerPage("SettingsControlsPage", "SettingsPage", SettingsControls)
pageManager:registerPage("SettingsAudioPage", "SettingsPage", SettingsAudioPage)
pageManager:registerPage("SettingsAppearancePage", "SettingsPage", SettingsAppearancePage)
pageManager:registerPage("SettingsAiPage", "SettingsPage", SettingsAiPage)

function goToHomePage()
	pageManager:setPage("HomePage")
	pageManager:makeUndo()
end

function goToSetupPage()
	pageManager:setPage("SetupPage")
	pageManager:makeUndo()
end

function goToSettingsPage()
	pageManager:setPage("SettingsPage")
	pageManager:makeUndo()
end

function goToSetupAppsPage()
	pageManager:setPage("SetupAppsPage")
	pageManager:makeUndo()
end

function goToSettingsGeneralPage()
	pageManager:setPage("SettingsGeneralPage")
	pageManager:makeUndo()
end

function goToSettingsControlsPage()
	pageManager:setPage("SettingsControlsPage")
	pageManager:makeUndo()
end

function goToSettingsAudioPage()
	pageManager:setPage("SettingsAudioPage")
	pageManager:makeUndo()
end

function goToSettingsAppearancePage()
	pageManager:setPage("SettingsAppearancePage")
	pageManager:makeUndo()
end

function goToSettingsAiPage()
	pageManager:setPage("SettingsAiPage")
	pageManager:makeUndo()
end

goToHomePage()
goToSetupPage()

local exclusiveHudMode = ""

function MainMenuWindow(dt)
	ui.pushAllowKeyboardFocus(false)

	if not app.state.appOpen then
		exclusiveHudMode = nil
		return
	end
	exclusiveHudMode = ""

	local perfTime = os.preciseClock()

	if ui.keyboardButtonPressed(ui.KeyIndex.Escape) or ac.isKeyPressed(ui.KeyIndex.XButton1) then
		if pageManager:isUndoAvailable() then
			pageManager:undo()
		end
	end

	if ac.isKeyPressed(ui.KeyIndex.XButton2) then
		if pageManager:isRedoAvailable() then
			pageManager:redo()
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

			exclusiveHudMode = pageManager:draw()
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

	exclusiveHudMode = "debug"

	return exclusiveHudMode
end
