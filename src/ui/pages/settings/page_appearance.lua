local page = {}

local cui = require("ui.cui")
local pages = require("ui.pages.pages")
local settings = require("settings")

local bottomBarButtons = {
        {
                label = "BACK",
                enabled = true,
                func = function() pages:goToSettings() end,
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
        ui.drawRectFilled(
                vec2(0, 0),
                vec2(ui.windowWidth(), ui.windowHeight()),
                settings.Appearance.uiColorPrimary / 1.1
        )

        cui.pushWindowFitted("settings_appearance_window")

        topSubBar("/Settings/UI")

        ui.drawRectFilled(
                vec2(0, 0),
                vec2(ui.windowWidth(), ui.windowHeight()),
                settings.Appearance.uiColorPrimary / 1.1
        )
        ui.drawRectFilled(vec2(0, 2), vec2(ui.windowWidth(), ui.windowHeight()), rgbm(0, 0, 0, 0.2))

        ui.setCursorY(60)
        ui.setCursorX(50)

        cui.setCursorX(10)
        ui.text("Primary Theme Color:")
        ui.sameLine()
        cui.setCursorX(210)
        ui.setNextItemWidth(275)
        local primaryColor, primaryOpacity = settings.Appearance.uiColorPrimary:unpack()
        local newPrimaryOpacity, primaryOpacityChanged =
                ui.slider("##ui_primary_slider", primaryOpacity * 100, 0, 100, "Opacity: %.0f%%")

        if primaryOpacityChanged then
                settings.Appearance.uiColorPrimary =
                        settings.Appearance.uiColorPrimary:set(primaryColor, newPrimaryOpacity / 100)
        end

        ui.sameLine()
        if ui.colorButton("##primary", settings.Appearance.uiColorPrimary, ui.ColorPickerFlags.None) then
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
                                settings.Appearance.uiColorPrimary,
                                ui.ColorPickerFlags.DisplayRGB
                                        + ui.ColorPickerFlags.NoAlpha
                                        + ui.ColorPickerFlags.NoSidePreview
                        )
                then
                        settings.Appearance.uiColorPrimary = settings.Appearance.uiColorPrimary
                end
        end

        cui.setCursorX(10)
        ui.text("Secondary Theme Color:")
        ui.sameLine()
        cui.setCursorX(210)
        ui.setNextItemWidth(275)
        local secondaryColor, secondaryOpacity = settings.Appearance.uiColorSecondary:unpack()
        local newSecondaryOpacity, secondaryOpacityChanged =
                ui.slider("##ui_secondary_slider", secondaryOpacity * 100, 0, 100, "Opacity: %.0f%%")

        if secondaryOpacityChanged then
                settings.Appearance.uiColorSecondary =
                        settings.Appearance.uiColorSecondary:set(secondaryColor, newSecondaryOpacity / 100)
        end

        ui.sameLine()
        if ui.colorButton("##secondary", settings.Appearance.uiColorSecondary, ui.ColorPickerFlags.None) then
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
                                settings.Appearance.uiColorSecondary,
                                ui.ColorPickerFlags.DisplayRGB
                                        + ui.ColorPickerFlags.NoAlpha
                                        + ui.ColorPickerFlags.NoSidePreview
                        )
                then
                        settings.Appearance.uiColorSecondary = settings.Appearance.uiColorSecondary
                end
        end

        cui.setCursorX(10)
        ui.text("Tertiary Theme Color:")
        ui.sameLine()
        cui.setCursorX(210)
        ui.setNextItemWidth(275)
        local tertiaryColor, tertiaryOpacity = settings.Appearance.uiColorAccent:unpack()
        local newtertiaryOpacity, tertiaryOpacityChanged =
                ui.slider("##ui_tertiary_slider", tertiaryOpacity * 100, 0, 100, "Opacity: %.0f%%")

        if tertiaryOpacityChanged then
                settings.Appearance.uiColorAccent =
                        settings.Appearance.uiColorAccent:set(tertiaryColor, newtertiaryOpacity / 100)
        end

        ui.sameLine()
        if ui.colorButton("##tertiary", settings.Appearance.uiColorAccent, ui.ColorPickerFlags.None) then
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
                                settings.Appearance.uiColorAccent,
                                ui.ColorPickerFlags.DisplayRGB
                                        + ui.ColorPickerFlags.NoAlpha
                                        + ui.ColorPickerFlags.NoSidePreview
                        )
                then
                        settings.Appearance.uiColorAccent = settings.Appearance.uiColorAccent
                end
        end

        bottomBar(bottomBarButtons)

        cui.popWindow()

        return ""
end

return page
