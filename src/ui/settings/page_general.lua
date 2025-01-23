local page = {}

local sim = ac.getSim()

local bottomBarButtons = {
	{
		label = "BACK",
		enabled = true,
		func = function()
			goToSettingsPage()
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
	-- {
	-- 	label = "SETUP PRESETS",
	-- 	enabled = true,
	-- 	func = function() end,
	-- },
}

local but1 = ac.ControlButton("Lol")
local but2 = ac.ControlButton("Lol2")

function page.draw()
	contentWindow(
		"car_setup_window",
		storage.setupTab,
		vec2(60 * cui.scaleX(), 240 * cui.scaleY()),
		vec2(sim.windowWidth - 120 * cui.scaleX(), sim.windowHeight - 383 * cui.scaleY()),
		ui.WindowFlags.None,
		function()
			ui.drawLine(vec2(0, 2 * cui.scaleY()), vec2(ui.windowWidth(), 2 * cui.scaleY()), rgbm.colors.gray, 2)
			ui.drawRectFilled(vec2(0, 2 * cui.scaleY()), vec2(ui.windowWidth(), ui.windowHeight()), rgbm(0, 0, 0, 0.2))

			cui.setCursorX(50)
			cui.setCursorY(100)

			ui.beginGroup(0)

			if ui.checkbox("Auto-Start new UI", settings.autoStart) then
				settings.autoStart = not settings.autoStart
			end

			-- local value, changed, active = slider(
			-- 	"##afkhideui",
			-- 	settings.uiHideonIdleTime,
			-- 	0,
			-- 	300,
			-- 	0,
			-- 	"%s",
			-- 	nil,
			-- 	vec2(1000, 32),
			-- 	1,
			-- 	false,
			-- 	true,
			-- 	1,
			-- 	1
			-- )

			-- if changed then
			-- 	settings.uiHideonIdleTime = math.floor(value / 5 + 0.5) * 5
			-- end

			if ui.checkbox("Show app and CSP versions on bottom right of the screen", settings.showVersions) then
				settings.showVersions = not settings.showVersions
			end

			if ui.checkbox("Developer Mode", settings.showVersions) then
				settings.showVersions = not settings.showVersions
			end

			but1:control()
			but2:control()

			ui.endGroup()

			ui.drawLine(
				vec2(0, ui.windowHeight() - 2),
				vec2(ui.windowWidth(), ui.windowHeight() - 2),
				rgbm.colors.gray,
				2
			)
		end,
		false,
		true
	)

	bottomBar(bottomBarButtons)

	return "debug"
end

return page
