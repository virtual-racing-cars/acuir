local sim = ac.getSim()

local bottomBarButtons = {
	{
		label = "BACK",
		enabled = true,
		func = function()
			storage.settingsTab = 1
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

local primaryActive = false
local secondaryActive = false

function appearanceSettings()
	contentWindow(
		"car_setup_window",
		storage.setupTab,
		vec2(60 * cui.scaleX(), 240 * cui.scaleY()),
		vec2(sim.windowWidth - 120 * cui.scaleX(), sim.windowHeight - 383 * cui.scaleY()),
		ui.WindowFlags.None,
		function()
			ui.drawLine(vec2(0, 2), vec2(ui.windowWidth(), 2), rgbm.colors.gray, 2)
			ui.drawRectFilled(vec2(0, 2), vec2(ui.windowWidth(), ui.windowHeight()), rgbm(0, 0, 0, 0.2))

			ui.setCursorY(60)
			ui.setCursorX(50)

			if ui.checkbox("Show 'Car Info' window on the setup page", settings.hideOtherTrackSetups) then
				settings.hideOtherTrackSetups = not settings.hideOtherTrackSetups
			end

			setCursorX(10)
			ui.text("Primary Theme Color:")
			ui.sameLine()
			setCursorX(210)
			ui.setNextItemWidth(275)
			local primaryColor, primaryOpacity = settings.uiPrimaryColor:unpack()
			local newPrimaryOpacity, primaryOpacityChanged =
				ui.slider("##ui_primary_slider", primaryOpacity * 100, 0, 100, "Opacity: %.0f%%")

			if primaryOpacityChanged then
				settings.uiPrimaryColor = settings.uiPrimaryColor:set(primaryColor, newPrimaryOpacity / 100)
			end

			ui.sameLine()
			if ui.colorButton("##primary", settings.uiPrimaryColor, ui.ColorPickerFlags.None) then
				primaryActive = not primaryActive
				secondaryActive = false
			end

			if primaryActive then
				ui.sameLine()
				local currentXPos = ui.getCursorX()
				ui.newLine()
				setCursorX(currentXPos - 304)
				ui.setNextItemWidth(300)
				if
					ui.colorPicker(
						"##ui_primary_picker",
						settings.uiPrimaryColor,
						ui.ColorPickerFlags.DisplayRGB + ui.ColorPickerFlags.NoAlpha + ui.ColorPickerFlags.NoSidePreview
					)
				then
					settings.uiPrimaryColor = settings.uiPrimaryColor
				end
			end

			setCursorX(10)
			ui.text("Secondary Theme Color:")
			ui.sameLine()
			setCursorX(210)
			ui.setNextItemWidth(275)
			local secondaryColor, secondaryOpacity = settings.uiSecondaryColor:unpack()
			local newSecondaryOpacity, secondaryOpacityChanged =
				ui.slider("##ui_secondary_slider", secondaryOpacity * 100, 0, 100, "Opacity: %.0f%%")

			if secondaryOpacityChanged then
				settings.uiSecondaryColor = settings.uiSecondaryColor:set(secondaryColor, newSecondaryOpacity / 100)
			end

			ui.sameLine()
			if ui.colorButton("##secondary", settings.uiSecondaryColor, ui.ColorPickerFlags.None) then
				secondaryActive = not secondaryActive
				primaryActive = false
			end

			if secondaryActive then
				ui.sameLine()
				local currentXPos = ui.getCursorX()
				ui.newLine()
				setCursorX(currentXPos - 304)
				ui.setNextItemWidth(300)
				if
					ui.colorPicker(
						"##ui_secondary_picker",
						settings.uiSecondaryColor,
						ui.ColorPickerFlags.DisplayRGB + ui.ColorPickerFlags.NoAlpha + ui.ColorPickerFlags.NoSidePreview
					)
				then
					settings.uiSecondaryColor = settings.uiSecondaryColor
				end
			end

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
end
