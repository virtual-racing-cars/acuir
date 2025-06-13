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

local audioChannels = {
        "Main",
        "Engine",
        "Transmission",
        "Wipers",
        "Car Components",
        "Tyres",
        "Opponents",
        "Weather",
        "Wind",
        "Track",
        "Surfaces",
        "Dirt",
}

-- table.sort(audioChannels)

function page.draw()
        ui.drawRectFilled(
                vec2(0, 0),
                vec2(ui.windowWidth(), ui.windowHeight()),
                settings.Appearance.uiThemeColor1 / 1.1
        )

        cui.pushWindowFitted("settings_audio_main_window")
        topSubBar("Audio")

        cui.pushWindow(
                "settings_audio_window",
                0,
                180 * cui.uiScale(),
                ui.windowWidth(),
                ui.windowHeight() - 303 * cui.uiScale(),
                false
        )

        ui.drawLine(vec2(0, 2), vec2(ui.windowWidth(), 2), rgbm.colors.gray, 2)
        ui.drawRectFilled(vec2(0, 2), vec2(ui.windowWidth(), ui.windowHeight()), rgbm(0, 0, 0, 0.2))

        cui.setCursorY(160)

        local p = ui.getCursor()
        for i, v in ipairs(audioChannels) do
                local id = string.replace(v, " ", "")

                if i == 1 or i == #audioChannels then
                        ui.setCursorX(ui.windowWidth() * 0.375)
                elseif i % 2 == 0 then
                        ui.setCursorX(ui.windowWidth() * 0.25)
                        p = ui.getCursor()
                else
                        ui.setCursor(p)
                        ui.setCursorX(ui.windowWidth() * 0.5)
                end

                local value, changed = drawSpinner(
                        "##" .. id,
                        v,
                        ui.windowWidth() * 0.25,
                        95 * cui.uiScale(),
                        false,
                        ac.getAudioVolume(ac.AudioChannel[id]) * 100,
                        {
                                section = "SETTINGS",
                                id = id,
                                label = v,
                                min = 0,
                                max = 100,
                                step = 1,
                                shiftStep = 1,
                                multiplier = 1,
                                offset = 0,
                                format = "%.0f %s",
                                unit = "%",
                                help = "",
                        }
                )

                if changed then ac.setAudioVolume(ac.AudioChannel[id], value / 100) end
        end

        ui.drawLine(vec2(0, ui.windowHeight() - 2), vec2(ui.windowWidth(), ui.windowHeight() - 2), rgbm.colors.gray, 2)

        cui.popWindow()

        bottomBar(bottomBarButtons)

        cui.popWindow()

        return ""
end

return page
