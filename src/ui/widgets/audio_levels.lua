local cui = require("ui.cui")

local audioLevels = {}

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

function audioLevels:body()
        ui.setCursor(0)
        local itemWidth = ui.availableSpaceX() * 0.5 - 60 * cui.scale()
        cui.offsetCursorY(15)

        local p = ui.getCursor()
        for i, v in ipairs(audioChannels) do
                local id = string.replace(v, " ", "")

                if i == 1 or i == #audioChannels then
                        ui.setCursorX(ui.windowWidth() * 0.25)
                elseif i % 2 == 0 then
                        cui.setCursorX(30)
                        p = ui.getCursor()
                else
                        ui.setCursor(p)
                        ui.setCursorX(ui.windowWidth() * 0.5)
                        cui.offsetCursorX(30)
                end

                local value, changed = cui.spinner(
                        "##" .. id,
                        v,
                        itemWidth,
                        95 * cui.scale(),
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
end

return audioLevels
