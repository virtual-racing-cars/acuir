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

function page.draw()
        ui.drawRectFilled(vec2(0, 0), ui.windowSize(), settings.Appearance.uiColorBackgroundShade * 0.75)

        cui.pushWindowFitted("settings_audio_main_window")
        topSubBar("Audio")

        cui.pushContentWindow(
                "settings_AUDIO_window",
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

        local p = ui.getCursor()
        for i, v in ipairs(audioChannels) do
                local id = string.replace(v, " ", "")

                if i == 1 or i == #audioChannels then
                        ui.setCursorX(ui.windowWidth() * 0.25)
                elseif i % 2 == 0 then
                        ui.setCursorX(ui.windowWidth() * 0)
                        p = ui.getCursor()
                else
                        ui.setCursor(p)
                        ui.setCursorX(ui.windowWidth() * 0.5)
                end

                local value, changed = drawSpinner(
                        "##" .. id,
                        v,
                        ui.windowWidth() * 0.5,
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

        cui.popContentWindow()

        bottomBar(bottomBarButtons)

        cui.popWindow()

        return "finalize"
end

return page
