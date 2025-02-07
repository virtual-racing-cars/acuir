local page = {}

local settings = require("settings")
local cui = require("ui.cui")
local pages = require("ui.pages")
local bindindWindow = require("ui.settings.binding_window")
local controls = require("controls")

local bottomBarButtons = {
	{
		label = "BACK",
		enabled = true,
		func = function()
			pages:goToSettings()
		end,
	},
	{
		label = "APPLY",
		enabled = false,
		func = function() end,
	},
	{
		label = "CANCEL",
		enabled = false,
		func = function() end,
	},
}

local boundDevices = { "Steering", "Throttle", "Brakes", "Clutch", "Handbrake" }

local function boundDevicesWindow()
	cui.pushWindow("settings_controls_bound_window", 0, 0, ui.windowWidth() / 5, ui.windowHeight(), false)
	ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), rgbm(0.4, 0.4, 0.4, 0.3))

	ui.setCursor(0)
	cui.snapCursor()
	ui.dwriteTextAligned(
		"Search by Action Name",
		24 * cui.scaleY(),
		ui.Alignment.Center,
		ui.Alignment.Center,
		vec2(ui.windowWidth(), 170 * cui.scaleY()),
		false,
		rgbm(1, 1, 1, 1)
	)

	local buttonWidth = (ui.windowWidth() / 24) * 22
	local groupBegin = (ui.windowWidth() / 24)

	local fontSize = math.floor(24 * cui.scaleY())
	fontSize = (fontSize % 2 == 0) and fontSize + 1 or fontSize

	ui.setCursor(0)
	ui.setCursorX(groupBegin)
	cui.setCursorY(130)
	cui.inputText("##actionSearch", nil, "Hello There", ui.InputTextFlags.None, vec2(buttonWidth, 40 * cui.scaleY()))

	ui.drawRectFilled(vec2(0, 230 * cui.scaleY()), vec2(ui.windowWidth(), 740 * cui.scaleY()), rgbm(0.1, 0.1, 0.1, 0.4))

	ui.setCursorX(0)
	cui.setCursorY(250)
	cui.snapCursor()
	ui.dwriteTextAligned(
		"Currently Active & Bound Devices",
		24 * cui.scaleY(),
		ui.Alignment.Center,
		ui.Alignment.Center,
		vec2(ui.windowWidth(), 48 * cui.scaleY()),
		false,
		rgbm(1, 1, 1, 1)
	)

	for i, k in ipairs(controls.boundDevices) do
		cui.snapCursor()
		ui.dwriteTextAligned(
			k[1],
			24 * cui.scaleY(),
			ui.Alignment.Center,
			ui.Alignment.Center,
			vec2(ui.windowWidth(), 40 * cui.scaleY()),
			false,
			rgbm(1, 1, 1, 1)
		)
		ui.dwriteTextAligned(
			k[2],
			24 * cui.scaleY(),
			ui.Alignment.Center,
			ui.Alignment.Center,
			vec2(ui.windowWidth(), 40 * cui.scaleY()),
			false,
			rgbm(1, 0.67, 0.3, 1)
		)
	end

	cui.popWindow()
end

local function controlsTabBar()
	cui.pushWindow(
		"settings_controls_window",
		ui.windowWidth() / 5,
		0,
		ui.windowWidth() - (ui.windowWidth() / 5),
		100,
		false
	)
	ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), rgbm(0, 0, 0, 1))

	ui.drawLine(vec2(0, 0), vec2(ui.windowWidth(), 0), rgbm.colors.white, 5)
	ui.drawLine(vec2(0, ui.windowHeight() - 1), vec2(ui.windowWidth(), ui.windowHeight() - 1), rgbm.colors.white, 5)

	cui.popWindow()
end

local function buttonBindingWindow()
	cui.pushWindow(
		"settings_controls_binding_window",
		ui.windowWidth() / 5,
		0,
		(ui.windowWidth() / 5) * 2,
		ui.windowHeight(),
		false
	)

	-- ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), rgbm(0.7, 0.3, 0.6, 1))
	ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), rgbm.colors.black)

	bindindWindow:draw()

	cui.popWindow()
end

local function ffbWindow()
	cui.pushWindow(
		"settings_controls_ffb_window",
		(ui.windowWidth() / 5) * 3,
		100 * cui.scaleY(),
		(ui.windowWidth() / 5) * 2,
		ui.windowHeight(),
		false
	)
	-- ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), rgbm(10, 0, 0, 1))

	cui.popWindow()
end

function page.draw()
	ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), settings.Appearance.uiColor1 / 1.1)

	cui.pushWindowFitted("settings_controls_main_window")
	topSubBar("/ Settings / Controls")

	cui.pushWindow(
		"settings_controls_window",
		0,
		200 * cui.scaleY(),
		ui.windowWidth(),
		ui.windowHeight() - 303 * cui.scaleY(),
		false
	)

	boundDevicesWindow()
	buttonBindingWindow()
	ffbWindow()

	cui.popWindow()

	bottomBar(bottomBarButtons)
	cui.popWindow()
	return ""
end

return page
