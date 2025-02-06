local page = {}

local settings = require("settings")
local cui = require("ui.cui")
local pages = require("ui.pages")
local sim = ac.getSim()

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

local primaryActive = false
local secondaryActive = false
local tertiaryActive = false

function page.draw()
	ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), settings.Appearance.uiColor1 / 1.1)
	topSubBar("/Settings/UI")

	cui.contentWindow(
		"car_setup_window",
		vec2(60 * cui.scaleX(), 240 * cui.scaleY()),
		vec2(sim.windowWidth - 120 * cui.scaleX(), sim.windowHeight - 383 * cui.scaleY()),
		ui.WindowFlags.None,
		function()
			ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), settings.Appearance.uiColor1 / 1.1)
			ui.drawRectFilled(vec2(0, 2), vec2(ui.windowWidth(), ui.windowHeight()), rgbm(0, 0, 0, 0.2))

			ui.setCursorY(60)
			ui.setCursorX(50)

			cui.setCursorX(10)
			ui.text("Primary Theme Color:")
			ui.sameLine()
			cui.setCursorX(210)
			ui.setNextItemWidth(275)
			local primaryColor, primaryOpacity = settings.Appearance.uiColor1:unpack()
			local newPrimaryOpacity, primaryOpacityChanged =
				ui.slider("##ui_primary_slider", primaryOpacity * 100, 0, 100, "Opacity: %.0f%%")

			if primaryOpacityChanged then
				settings.Appearance.uiColor1 = settings.Appearance.uiColor1:set(primaryColor, newPrimaryOpacity / 100)
			end

			ui.sameLine()
			if ui.colorButton("##primary", settings.Appearance.uiColor1, ui.ColorPickerFlags.None) then
				primaryActive = not primaryActive
				secondaryActive = false
			end

			if primaryActive then
				ui.sameLine()
				local currentXPos = ui.getCursorX()
				ui.newLine()
				cui.setCursorX(currentXPos - 304)
				ui.setNextItemWidth(300)
				if
					ui.colorPicker(
						"##ui_primary_picker",
						settings.Appearance.uiColor1,
						ui.ColorPickerFlags.DisplayRGB + ui.ColorPickerFlags.NoAlpha + ui.ColorPickerFlags.NoSidePreview
					)
				then
					settings.Appearance.uiColor1 = settings.Appearance.uiColor1
				end
			end

			cui.setCursorX(10)
			ui.text("Secondary Theme Color:")
			ui.sameLine()
			cui.setCursorX(210)
			ui.setNextItemWidth(275)
			local secondaryColor, secondaryOpacity = settings.Appearance.uiColor2:unpack()
			local newSecondaryOpacity, secondaryOpacityChanged =
				ui.slider("##ui_secondary_slider", secondaryOpacity * 100, 0, 100, "Opacity: %.0f%%")

			if secondaryOpacityChanged then
				settings.Appearance.uiColor2 =
					settings.Appearance.uiColor2:set(secondaryColor, newSecondaryOpacity / 100)
			end

			ui.sameLine()
			if ui.colorButton("##secondary", settings.Appearance.uiColor2, ui.ColorPickerFlags.None) then
				secondaryActive = not secondaryActive
				primaryActive = false
			end

			if secondaryActive then
				ui.sameLine()
				local currentXPos = ui.getCursorX()
				ui.newLine()
				cui.setCursorX(currentXPos - 304)
				ui.setNextItemWidth(300)
				if
					ui.colorPicker(
						"##ui_secondary_picker",
						settings.Appearance.uiColor2,
						ui.ColorPickerFlags.DisplayRGB + ui.ColorPickerFlags.NoAlpha + ui.ColorPickerFlags.NoSidePreview
					)
				then
					settings.Appearance.uiColor2 = settings.Appearance.uiColor2
				end
			end

			cui.setCursorX(10)
			ui.text("Tertiary Theme Color:")
			ui.sameLine()
			cui.setCursorX(210)
			ui.setNextItemWidth(275)
			local tertiaryColor, tertiaryOpacity = settings.Appearance.uiColor3:unpack()
			local newtertiaryOpacity, tertiaryOpacityChanged =
				ui.slider("##ui_tertiary_slider", tertiaryOpacity * 100, 0, 100, "Opacity: %.0f%%")

			if tertiaryOpacityChanged then
				settings.Appearance.uiColor3 = settings.Appearance.uiColor3:set(tertiaryColor, newtertiaryOpacity / 100)
			end

			ui.sameLine()
			if ui.colorButton("##tertiary", settings.Appearance.uiColor3, ui.ColorPickerFlags.None) then
				tertiaryActive = not tertiaryActive
				primaryActive = false
			end

			if tertiaryActive then
				ui.sameLine()
				local currentXPos = ui.getCursorX()
				ui.newLine()
				cui.setCursorX(currentXPos - 304)
				ui.setNextItemWidth(300)
				if
					ui.colorPicker(
						"##ui_tertiary_picker",
						settings.Appearance.uiColor3,
						ui.ColorPickerFlags.DisplayRGB + ui.ColorPickerFlags.NoAlpha + ui.ColorPickerFlags.NoSidePreview
					)
				then
					settings.Appearance.uiColor3 = settings.Appearance.uiColor3
				end
			end

			bottomBar(bottomBarButtons)
		end
	)

	return ""
end

return page
