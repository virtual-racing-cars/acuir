local page = {}

require("ui.setup.setup_window")
require("ui.setup.car_status_window")
require("src.ui.setup.setup_io")
require("classes.SetupManager")
local settings = require("settings")
local cui = require("ui.cui")
local app = require("app")
local pages = require("ui.pages")

local vec2Temp1 = vec2()

local bottomBarButtons = {
	{
		label = "BACK",
		enabled = true,
		func = function()
			pages:goToMainMenu()
		end,
	},
	{
		label = "RESET",
		enabled = true,
		func = function()
			sm:resetSetup()
		end,
	},
	{
		label = "UNDO",
		enabled = true,
		func = function()
			sm:undo()
		end,
	},
	{
		label = "REDO",
		enabled = true,
		func = function()
			sm:redo()
		end,
	},
}

sm = nil

local initTimer = 0

local acLogo = ac.getFolder(ac.FolderID.Root) .. "\\launcher\\themes\\default\\graphics\\btn_AC_logo.png"
local acLogoSize = ui.imageSize(acLogo) * 2 * cui.scaleY()

sm = SetupManager()

function page.draw()
	if not sm then
		if initTimer == 0 then
			initTimer = os.clock() + 2
		elseif initTimer < os.clock() then
			sm = SetupManager()
		end

		ui.drawRectFilled(vec2(0, 0), ui.windowSize(), settings.Appearance.uiColor1 / 1.25)
		acLogoSize = ui.imageSize(acLogo) * 2 * cui.scaleY()

		ui.setCursorX(ui.windowWidth() / 2 - acLogoSize.x / 2)
		ui.setCursorY(ui.windowHeight() / 2 - acLogoSize.y / 2)
		ui.image(acLogo, acLogoSize)

		return
	end

	topBar(false)

	cui.contentWindow(
		"car_setup_window",
		vec2(0, 200 * cui.scaleY()),
		vec2(ui.windowWidth(), ui.windowHeight() - 303 * cui.scaleY()),
		ui.WindowFlags.None,
		function()
			ui.setCursor(0)
			app.state.setupTab = setupTabBar(sm.setupTabs)

			ui.setCursor(0)
			cui.contentWindow(
				"car_setup_items_window",
				vec2(ui.windowWidth() / 4, 56 * cui.scaleY()),
				vec2(ui.windowWidth() / 2, ui.windowHeight() - 56 * cui.scaleY()),
				ui.WindowFlags.None,
				function()
					ui.setCursor(0)
					car_setup(sm)
				end,
				true
			)

			ui.setCursor(0)
			cui.contentWindow(
				"car_status_window",
				vec2((ui.windowWidth() / 4) * 3, 56 * cui.scaleY()),
				vec2(ui.windowWidth() / 4, ui.windowHeight() - 56 * cui.scaleY()),
				ui.WindowFlags.None,
				function()
					ui.setCursor(0)
					ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), rgbm(0, 0, 0, 0.25))
					ui.drawRectFilled(
						vec2(0, 0),
						vec2(ui.availableSpaceX(), ui.availableSpaceY() / 20),
						rgbm(0, 0, 0, 1)
					)

					cui.menuButton(
						"Car Status",
						vec2Temp1:set(ui.windowWidth() / 2, ui.windowHeight() / 20),
						0,
						0,
						0,
						false,
						false
					)
					ui.sameLine()

					cui.menuButton(
						"Last Outing",
						vec2Temp1:set(ui.windowWidth() / 2, ui.windowHeight() / 20),
						0,
						0,
						ui.ButtonFlags.Disabled,
						false,
						false
					)

					ui.setCursor(0)

					cui.contentWindow(
						"car_status_subwindow",
						vec2(0, ui.availableSpaceY() / 20),
						vec2(ui.windowWidth() + 20, ui.availableSpaceY() - ui.availableSpaceY() / 20),
						ui.WindowFlags.None,
						function()
							CarStatusWindow()
						end
					)
				end
			)

			ui.setCursor(0)
			cui.contentWindow(
				"setup_io_window",
				vec2(0, 56 * cui.scaleY()),
				vec2(ui.windowWidth() / 4, ui.windowHeight() - 56 * cui.scaleY()),
				ui.WindowFlags.None,
				function()
					ui.setCursor(0)
					ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), rgbm(0, 0, 0, 0.25))
					ui.drawRectFilled(vec2(0, 0), vec2(ui.availableSpaceX(), ui.windowHeight() / 20), rgbm(0, 0, 0, 1))

					cui.menuButton(
						"Local Setups",
						vec2Temp1:set(ui.windowWidth() / 2, ui.windowHeight() / 20),
						0,
						0,
						0,
						false,
						false
					)
					ui.sameLine()

					cui.menuButton(
						"Setup Exchange",
						vec2Temp1:set(ui.windowWidth() / 2, ui.windowHeight() / 20),
						0,
						0,
						ui.ButtonFlags.Disabled,
						false,
						false
					)

					ui.setCursor(0)
					cui.contentWindow(
						"setup_io_track_subwindow",
						vec2(0, ui.availableSpaceY() / 20),
						vec2(ui.windowWidth(), ui.windowHeight() - ui.windowHeight() / 20),
						ui.WindowFlags.None,
						function()
							setupIoDraw(sm)
						end
					)
				end
			)
		end
	)

	bottomBarButtons[#bottomBarButtons - 1].enabled = sm:isUndoAvailable()
	bottomBarButtons[#bottomBarButtons].enabled = sm:isRedoAvailable()

	bottomBar(bottomBarButtons)

	return ""
end

return page
