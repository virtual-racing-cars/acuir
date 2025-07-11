local page = { tab = 1 }

local app = require("app")
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

local function generalSettings()
        cui.setCursorY(100)
        for i, v in ipairs(settings.General) do
                local height = 95 * 0.7 * 0.3 * cui.scale()

                if v.widget == 1 then
                        ui.setCursorX(ui.windowWidth() * 0.5 - height * 7)

                        local newValue, changed = drawCheckbox(v.label, v.label, height, settings.General[v.key])
                        ui.newLine()
                        ui.newLine()

                        if changed then settings.General[v.key] = newValue end
                elseif v.widget == 2 then
                        local changed = false
                        ui.setCursorX(ui.windowWidth() * 0.25)
                        settings.General[v.key], changed = cui.spinner(
                                v.label,
                                v.label,
                                ui.windowWidth() * 0.5,
                                95 * cui.scale(),
                                false,
                                settings.General[v.key],
                                {
                                        section = "SETTINGS",
                                        id = v.label,
                                        label = v.label,
                                        min = v.min or 0,
                                        max = v.max or 1,
                                        step = v.step or 1,
                                        shiftStep = v.shiftStep or 1,
                                        multiplier = v.multiplier or 1,
                                        offset = 0,
                                        format = v.format,
                                        unit = "%",
                                        help = "",
                                },
                                true
                        )

                        if changed and v.onChanged then v.onChanged(settings.General[v.key]) end

                        ui.newLine()
                        ui.newLine()
                end
        end
end

local function uiSettings()
        cui.setCursorY(100)
        for i, v in ipairs(settings.UI) do
                local height = 95 * 0.7 * 0.3 * cui.scale()

                if v.widget == 1 then
                        ui.setCursorX(ui.windowWidth() * 0.5 - height * 7)

                        local newValue, changed = drawCheckbox(v.label, v.label, height, settings.UI[v.key])
                        ui.newLine()
                        ui.newLine()

                        if changed then settings.UI[v.key] = newValue end
                elseif v.widget == 2 then
                        local changed = false

                        ui.setCursorX(ui.windowWidth() * 0.25)
                        settings.UI[v.key], changed = cui.spinner(
                                v.label,
                                v.label,
                                ui.windowWidth() * 0.5,
                                95 * cui.scale(),
                                false,
                                settings.UI[v.key],
                                {
                                        section = "SETTINGS",
                                        id = v.label,
                                        label = v.label,
                                        min = v.min or 0,
                                        max = v.max or 1,
                                        step = v.step or 1,
                                        shiftStep = v.shiftStep or 1,
                                        multiplier = v.multiplier or 1,
                                        offset = 0,
                                        format = v.format,
                                        unit = "%",
                                        help = "",
                                },
                                true
                        )

                        if changed and v.onChanged then v.onChanged(settings.UI[v.key]) end

                        ui.newLine()
                        ui.newLine()
                end
        end
end

function page.draw()
        ui.drawRectFilled(vec2(0, 0), ui.windowSize(), settings.Appearance.uiColorBackgroundShade * 0.75)

        cui.pushFittedWindow("general_page_window")

        topSubBar(app.name)

        cui.pushContentWindow(
                "settings_general_window",
                ui.windowWidth() * 0.25,
                180 * cui.scale(),
                ui.windowWidth() * 0.5,
                ui.windowHeight() - 303 * cui.scale(),
                function()
                        if cui.menuButton("General", 40, 0, 0, 0, page.tab == 1, false, ui.CornerFlags.Top) then
                                page.tab = 1
                        end
                        ui.sameLine()

                        if cui.menuButton("UI", 40, 0, 0, 0, page.tab == 2, false, ui.CornerFlags.Top) then
                                page.tab = 2
                        end
                        ui.sameLine()
                end,
                nil,
                true
        )

        if page.tab == 1 then
                generalSettings()
        elseif page.tab == 2 then
                uiSettings()
        end

        cui.popContentWindow()

        bottomBar(bottomBarButtons)

        cui.popWindow()

        return "finalize"
end

return page
