local cui = require("ui.cui")
local pages = require("ui.pages")
local settings = require("settings")

local settingsGeneral = {}

function settingsGeneral:body()
        ui.setCursor(0)
        local itemWidth = ui.availableSpaceX() - 60 * cui.scale()
        cui.offsetCursorY(15)

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

                        ui.setCursorX(ui.windowWidth() * 0.5 - itemWidth * 0.5)
                        settings.UI[v.key], changed =
                                cui.slider(v.label, v.label, itemWidth, 95 * cui.scale(), false, settings.UI[v.key], {
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
                                }, true)

                        if changed and v.onChanged then v.onChanged(settings.UI[v.key]) end

                        ui.newLine()
                        ui.newLine()
                end
        end
end

return settingsGeneral
