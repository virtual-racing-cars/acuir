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

        cui.setCursorY(100)
        for i, v in ipairs(settings.General) do
                local height = 95 * 0.7 * 0.3 * cui.uiScale()

                ac.log(v)

                if v.widget == 1 then
                        ui.setCursorX(ui.windowWidth() * 0.5 - height * 7)

                        local newValue, changed = drawCheckbox(v.label, v.label, height, false, settings.General[v.key])
                        ui.newLine()
                        ui.newLine()

                        if changed then settings.General[v.key] = newValue end
                elseif v.widget == 2 then
                        ui.setCursorX(ui.windowWidth() * 0.25)
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
                        ui.newLine()
                        ui.newLine()
                end
        end

        cui.popContentWindow()

        bottomBar(bottomBarButtons)

        cui.popWindow()

        return ""
end

return page
