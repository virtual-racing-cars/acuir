local page = {}

local cui = require("ui.cui")
local pages = require("ui.pages.pages")
local settings = require("settings")

local bottomBarButtons = {
        {
                label = "BACK",
                enabled = true,
                func = function() pages:undo() end,
        },
}

function page.draw()
        ui.drawRectFilled(
                vec2(0, 0),
                vec2(ui.windowWidth(), ui.windowHeight()),
                settings.Appearance.uiThemeColor1 / 1.1
        )

        cui.pushWindowFitted("general_page_window")

        topSubBar("General")

        ui.drawLine(vec2(0, 160 * cui.uiScale()), vec2(ui.windowWidth(), 160 * cui.uiScale()), rgbm.colors.gray, 2)
        ui.drawRectFilled(
                vec2(0, 160 * cui.uiScale()),
                vec2(ui.windowWidth(), ui.windowHeight() - 96 * cui.uiScale()),
                rgbm(0, 0, 0, 0.2)
        )

        cui.setCursorY(250)

        for i, v in ipairs(settings.General) do
                ui.setCursorX(ui.windowWidth() * 0.375)

                if v.widget == 1 then
                        local value = settings.General[v.key] and 1 or 0

                        local newValue, changed, active, hovered = drawSpinner(
                                v.label,
                                v.label,
                                ui.windowWidth() * 0.25,
                                95 * cui.uiScale(),
                                false,
                                value,
                                {
                                        section = "SETTINGS",
                                        id = v.label,
                                        label = v.label,
                                        min = v.min or 0,
                                        max = v.max or 1,
                                        step = 1,
                                        shiftStep = 1,
                                        multiplier = 1,
                                        offset = 0,
                                        format = settings.General[v.key] and "Enabled" or "Disabled",
                                        unit = "%",
                                        help = "",
                                },
                                true
                        )

                        settings.General[v.key] = newValue == 1 and true or false
                elseif v.widget == 2 then
                        settings.General[v.key] = drawSpinner(
                                v.label,
                                v.label,
                                ui.windowWidth() * 0.25,
                                95 * cui.uiScale(),
                                false,
                                settings.General[v.key],
                                {
                                        section = "SETTINGS",
                                        id = v.label,
                                        label = v.label,
                                        min = v.min or 0,
                                        max = v.max or 1,
                                        step = 1,
                                        shiftStep = 1,
                                        multiplier = 1,
                                        offset = 0,
                                        format = v.format,
                                        unit = "%",
                                        help = "",
                                },
                                true
                        )
                end
        end

        ui.drawLine(
                vec2(0, ui.windowHeight() - 96 * cui.uiScale()),
                vec2(ui.windowWidth(), ui.windowHeight() - 96 * cui.uiScale()),
                rgbm.colors.gray,
                2
        )

        bottomBar(bottomBarButtons)

        cui.popWindow()

        return ""
end

return page
