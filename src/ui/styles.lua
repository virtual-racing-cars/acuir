local listWidth = 320
local listMargins = 5
local setupTabHeight = 50
LIST_BUTTON_SIZE = vec2((listWidth - 12) * UI_SCALE_X / 100, setupTabHeight * UI_SCALE_Y / 100)

function pushSetupListStyle()
	ui.pushStyleColor(ui.StyleColor.Button, settings.uiPrimaryColor)
	ui.pushStyleColor(ui.StyleColor.ButtonHovered, settings.uiSecondaryColor)
	ui.pushStyleColor(ui.StyleColor.ButtonActive, settings.uiSecondaryColor)
	ui.pushStyleVar(ui.StyleVar.FramePadding, -20)
end

function popSetupListStyle()
	ui.popStyleVar(1)
	ui.popStyleColor(3)
end

function pushMainMenuStyle()
	ui.pushStyleColor(ui.StyleColor.SliderGrab, rgbm(0.5, 0.5, 0.5, 0.5 * 2))
	ui.pushStyleColor(ui.StyleColor.FrameBg, rgbm(0.1, 0.1, 0.1, 0.25 * 2))
	ui.pushStyleColor(ui.StyleColor.FrameBgHovered, rgbm(0.6, 0.2, 0.2, 0.5 * 2))
	ui.pushStyleColor(ui.StyleColor.FrameBgActive, rgbm(1, 0.2, 0.2, 0.75 * 2))
	ui.pushStyleColor(ui.StyleColor.Button, rgbm(0.1, 0.1, 0.1, 0.25 * 2))
	ui.pushStyleColor(ui.StyleColor.ButtonHovered, settings.uiSecondaryColor)
	ui.pushStyleColor(ui.StyleColor.ButtonActive, settings.uiSecondaryColor)
	ui.pushStyleColor(ui.StyleColor.Text, rgbm(1, 1, 1, 1 * 2))
end

function popMainMenuStyle()
	ui.popStyleColor(7)
end
