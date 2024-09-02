local listWidth = 320
local listMargins = 5
local setupTabHeight = 50
LIST_BUTTON_SIZE = vec2((listWidth - 12) * UI_SCALE_X / 100, setupTabHeight * UI_SCALE_Y / 100)

function pushSetupListStyle(padding)
	if not padding then
		padding = -25
	end

	ui.pushStyleColor(ui.StyleColor.Button, rgbm(0, 0, 0, 0))
	ui.pushStyleColor(ui.StyleColor.ButtonHovered, settings.uiSecondaryColor / 2)
	ui.pushStyleColor(ui.StyleColor.ButtonActive, rgbm(0, 0, 0, 0))
	ui.pushStyleVar(ui.StyleVar.FramePadding, padding)
end

function popSetupListStyle()
	ui.popStyleVar(1)
	ui.popStyleColor(3)
end

function pushMainMenuStyle()
	ui.pushStyleColor(ui.StyleColor.SliderGrab, rgbm(0.5, 0.5, 0.5, 1))
	ui.pushStyleColor(ui.StyleColor.FrameBg, rgbm(0.1, 0.1, 0.1, 0.75))
	ui.pushStyleColor(ui.StyleColor.FrameBgHovered, settings.uiSecondaryColor / 2)
	ui.pushStyleColor(ui.StyleColor.FrameBgActive, settings.uiSecondaryColor)
	ui.pushStyleColor(ui.StyleColor.Button, rgbm(0.1, 0.1, 0.1, 0.75))
	ui.pushStyleColor(ui.StyleColor.ButtonHovered, settings.uiSecondaryColor / 2)
	ui.pushStyleColor(ui.StyleColor.ButtonActive, settings.uiSecondaryColor)
end

function popMainMenuStyle()
	ui.popStyleColor(7)
end
