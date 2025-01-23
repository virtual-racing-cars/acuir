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

local primaryActive = false
local secondaryActive = false
local tertiaryActive = false

function page.draw()
	contentWindow(
		"car_setup_window",
		STORAGE.setupTab,
		vec2(60 * cui.scaleX(), 240 * cui.scaleY()),
		vec2(sim.windowWidth - 120 * cui.scaleX(), sim.windowHeight - 383 * cui.scaleY()),
		ui.WindowFlags.None,
		function()
			ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), SETTINGS.uiColor1 / 1.1)
			ui.drawLine(vec2(0, 2), vec2(ui.windowWidth(), 2), rgbm.colors.gray, 2)
			ui.drawRectFilled(vec2(0, 2), vec2(ui.windowWidth(), ui.windowHeight()), rgbm(0, 0, 0, 0.2))

			ui.setCursorY(60)
			ui.setCursorX(50)
			if ui.checkbox("Show 'Car Info' window on the setup page", SETTINGS.hideOtherTrackSetups) then
				SETTINGS.hideOtherTrackSetups = not SETTINGS.hideOtherTrackSetups
			end

			setCursorX(10)
			ui.text("Primary Theme Color:")
			ui.sameLine()
			setCursorX(210)
			ui.setNextItemWidth(275)
			local primaryColor, primaryOpacity = SETTINGS.uiColor1:unpack()
			local newPrimaryOpacity, primaryOpacityChanged =
				ui.slider("##ui_primary_slider", primaryOpacity * 100, 0, 100, "Opacity: %.0f%%")

			if primaryOpacityChanged then
				SETTINGS.uiColor1 = SETTINGS.uiColor1:set(primaryColor, newPrimaryOpacity / 100)
			end

			ui.sameLine()
			if ui.colorButton("##primary", SETTINGS.uiColor1, ui.ColorPickerFlags.None) then
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
						SETTINGS.uiColor1,
						ui.ColorPickerFlags.DisplayRGB + ui.ColorPickerFlags.NoAlpha + ui.ColorPickerFlags.NoSidePreview
					)
				then
					SETTINGS.uiColor1 = SETTINGS.uiColor1
				end
			end

			setCursorX(10)
			ui.text("Secondary Theme Color:")
			ui.sameLine()
			setCursorX(210)
			ui.setNextItemWidth(275)
			local secondaryColor, secondaryOpacity = SETTINGS.uiColor2:unpack()
			local newSecondaryOpacity, secondaryOpacityChanged =
				ui.slider("##ui_secondary_slider", secondaryOpacity * 100, 0, 100, "Opacity: %.0f%%")

			if secondaryOpacityChanged then
				SETTINGS.uiColor2 = SETTINGS.uiColor2:set(secondaryColor, newSecondaryOpacity / 100)
			end

			ui.sameLine()
			if ui.colorButton("##secondary", SETTINGS.uiColor2, ui.ColorPickerFlags.None) then
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
						SETTINGS.uiColor2,
						ui.ColorPickerFlags.DisplayRGB + ui.ColorPickerFlags.NoAlpha + ui.ColorPickerFlags.NoSidePreview
					)
				then
					SETTINGS.uiColor2 = SETTINGS.uiColor2
				end
			end

			setCursorX(10)
			ui.text("Tertiary Theme Color:")
			ui.sameLine()
			setCursorX(210)
			ui.setNextItemWidth(275)
			local tertiaryColor, tertiaryOpacity = SETTINGS.uiColor3:unpack()
			local newtertiaryOpacity, tertiaryOpacityChanged =
				ui.slider("##ui_tertiary_slider", tertiaryOpacity * 100, 0, 100, "Opacity: %.0f%%")

			if tertiaryOpacityChanged then
				SETTINGS.uiColor3 = SETTINGS.uiColor3:set(tertiaryColor, newtertiaryOpacity / 100)
			end

			ui.sameLine()
			if ui.colorButton("##tertiary", SETTINGS.uiColor3, ui.ColorPickerFlags.None) then
				tertiaryActive = not tertiaryActive
				primaryActive = false
			end

			if tertiaryActive then
				ui.sameLine()
				local currentXPos = ui.getCursorX()
				ui.newLine()
				setCursorX(currentXPos - 304)
				ui.setNextItemWidth(300)
				if
					ui.colorPicker(
						"##ui_tertiary_picker",
						SETTINGS.uiColor3,
						ui.ColorPickerFlags.DisplayRGB + ui.ColorPickerFlags.NoAlpha + ui.ColorPickerFlags.NoSidePreview
					)
				then
					SETTINGS.uiColor3 = SETTINGS.uiColor3
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

	return "debug"
end

return page
