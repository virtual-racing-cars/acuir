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
        ui.drawRectFilled(vec2(0, 0), ui.windowSize(), settings.Appearance.uiColorBackgroundShade * 0.75)

        cui.pushWindowFitted("general_page_window")

        topSubBar("ACUIR")

        cui.pushContentWindow(
                "settings_general_window",
                ui.windowWidth() * 0.25,
                180 * cui.uiScale(),
                ui.windowWidth() * 0.5,
                ui.windowHeight() - 303 * cui.uiScale(),
                function()
                        if cui.menuButton("General", 40, 0, 0, 0, false, false, ui.CornerFlags.Top) then
                        end
                        ui.sameLine()
                end,
                nil,
                true
        )

        for i, v in ipairs(settings.General) do
                ui.setCursorX(ui.windowWidth() * 0.25)

                if v.widget == 1 then
                        local value = settings.General[v.key] and 1 or 0

                        local newValue, changed, active, hovered = drawSpinner(
                                v.label,
                                v.label,
                                ui.windowWidth() * 0.5,
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
                                ui.windowWidth() * 0.5,
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

        cui.popContentWindow()

        bottomBar(bottomBarButtons)

        cui.popWindow()

        return ""
end

return page
