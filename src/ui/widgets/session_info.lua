local cui = require("ui.cui")
local settings = require("settings")
local simutils = require("simutils")
local style = require("ui.cui.style")
local units = require("units")
local weather = require("weather")
local sim = ac.getSim()
local uis = ac.getUI()
local car = ac.getCar(0)

local sessionInfoWidget = {}

local assistsINI = ac.INIConfig.load(ac.getFolder(ac.FolderID.Cfg) .. "\\assists.ini")
local raceINI = ac.INIConfig.raceConfig()

local sessionInfo = {}

local sessionInfoTable = {

        {
                label = "Track Grip",
                value = function() return string.format("%.1f %% (%s)", sim.roadGrip * 100, simutils.trackGripString) end,
        },
        {
                label = "Track Temp",
                value = function()
                        return string.format(
                                "%.1f %s",
                                units:temperature(sim.roadTemperature),
                                uis.useImperialUnits and "°F" or "°C"
                        )
                end,
        },
        {
                label = "Ambient Temp",
                value = function()
                        return string.format(
                                "%.1f %s",
                                units:temperature(sim.ambientTemperature),
                                uis.useImperialUnits and "°F" or "°C"
                        )
                end,
        },
        {
                label = "Humidity",
                value = function() return string.format("%.0f %%", ac.getAirHumidity(vec3(0, 0, 0)) * 100) end,
        },
        {
                label = "Wind Speed",
                value = function()
                        return string.format(
                                "%.1f %s",
                                units:speed(sim.windSpeedKmh),
                                uis.useImperialUnits and "mph" or "kmh"
                        )
                end,
        },
        {
                label = "Wind Direction",
                value = function()
                        return string.format("%s - %.1f°", simutils.windDirectionString, sim.windDirectionDeg + 180)
                end,
        },
        {
                label = "Weather",
                value = function() return string.format("%s", weather.typeString[sim.weatherType]) end,
        },
}

local electronicsState = { [0] = "Off", [1] = "Factory", [2] = "On" }
local assistState = { [0] = "Not Allowed", [1] = "Allowed" }
local jumpStartState = { [0] = "No Penalty", [1] = "Pits", [2] = "Drive-Through" }

local assists = {
        { label = "Traction Control", value = electronicsState[assistsINI:get("ASSISTS", "TRACTION_CONTROL", 0)] },
        { label = "ABS", value = electronicsState[assistsINI:get("ASSISTS", "ABS", 0)] },
        {
                label = "Stability Control",
                value = assistState[math.clamp(assistsINI:get("ASSISTS", "STABILITY_CONTROL", 0), 0, 1)],
        },
        {
                label = "Auto Clutch",
                value = assistState[math.clamp(assistsINI:get("ASSISTS", "AUTO_CLUTCH", 0), 0, 1)],
        },
        {
                label = "Damage",
                value = assistsINI:get("ASSISTS", "DAMAGE", 0) .. " %",
        },
        {
                label = "Fuel Rate",
                value = assistsINI:get("ASSISTS", "FUEL_RATE", 0) * 100 .. " %",
        },
        {
                label = "Tyre Wear Rate",
                value = assistsINI:get("ASSISTS", "TYRE_WEAR", 0) * 100 .. " %",
        },
        {
                label = "Tyre Blankets",
                value = assistsINI:get("ASSISTS", "TYRE_BLANKETS", 0) == 1 and "Yes" or "No",
        },
        {
                label = "Jump-Start",
                value = jumpStartState[raceINI:get("RACE", "JUMP_START_PENALTY", 0)],
        },
}

function sessionInfoWidget:body()
        local bodyFontSize = style.main.font.body.size
        local bodyFontSpace = style.main.font.body.space

        local headerFontSize = style.main.font.header.size
        local headerFontSpace = style.main.font.header.space

        cui.setCursorX(0)
        cui.offsetCursorY(10)

        for sessionIndex = 0, sim.sessionsCount - 1 do
                local session = ac.getSession(sessionIndex)

                cui.setCursorX(0)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        string.format("%s ", simutils.sessionTypeStrings[session.type]),
                        bodyFontSize,
                        ui.Alignment.End,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth() * 0.5 - 15 * cui.scale(), bodyFontSpace),
                        false,
                        sim.currentSessionIndex == sessionIndex and settings.Appearance.uiColorSecondary
                                or settings.Appearance.uiColorText
                )
                ui.sameLine()
                ui.setCursorX(ui.windowWidth() * 0.5 + 15 * cui.scale())

                if session.durationMinutes == 0 then
                        if session.type == ac.SessionType.Race then
                                cui.snapCursor()
                                ui.dwriteTextAligned(
                                        string.format("%.0f laps", session.laps),
                                        bodyFontSize,
                                        ui.Alignment.Start,
                                        ui.Alignment.Center,
                                        vec2(ui.windowWidth(), bodyFontSpace),
                                        false,
                                        sim.currentSessionIndex == sessionIndex and settings.Appearance.uiColorSecondary
                                                or settings.Appearance.uiColorText
                                )
                        else
                                cui.snapCursor()
                                ui.dwriteTextAligned(
                                        string.format("%.0f laps", car.lapCount),
                                        bodyFontSize,
                                        ui.Alignment.Start,
                                        ui.Alignment.Center,
                                        vec2(ui.windowWidth(), bodyFontSpace),
                                        false,
                                        sim.currentSessionIndex == sessionIndex and settings.Appearance.uiColorSecondary
                                                or settings.Appearance.uiColorText
                                )
                        end
                else
                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                string.format("%.0f min", session.durationMinutes),
                                bodyFontSize,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), bodyFontSpace),
                                false,
                                sim.currentSessionIndex == sessionIndex and settings.Appearance.uiColorSecondary
                                        or settings.Appearance.uiColorText
                        )
                end
        end
        cui.offsetCursorY(5)

        cui.setCursorX(0)
        cui.snapCursor()
        style:pushFontBold()
        ui.dwriteTextAligned(
                "Conditions",
                bodyFontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth(), bodyFontSpace)
        )
        ui.popDWriteFont()

        for _, weatherInfo in ipairs(sessionInfoTable) do
                cui.setCursorX(0)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        weatherInfo.label,
                        bodyFontSize,
                        ui.Alignment.End,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth() * 0.5 - 15 * cui.scale(), bodyFontSpace)
                )
                ui.sameLine()
                ui.setCursorX(ui.windowWidth() * 0.5 + 15 * cui.scale())

                cui.snapCursor()
                ui.dwriteTextAligned(
                        weatherInfo.value(),
                        bodyFontSize,
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), bodyFontSpace)
                )
        end

        cui.offsetCursorY(5)

        cui.setCursorX(0)
        cui.snapCursor()
        style:pushFontBold()
        ui.dwriteTextAligned(
                "Modifiers",
                bodyFontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth(), bodyFontSpace)
        )
        ui.popDWriteFont()

        for _, assist in ipairs(assists) do
                cui.setCursorX(0)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        assist.label,
                        bodyFontSize,
                        ui.Alignment.End,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth() * 0.5 - 15 * cui.scale(), bodyFontSpace)
                )
                ui.sameLine()
                ui.setCursorX(ui.windowWidth() * 0.5 + 15 * cui.scale())
                cui.snapCursor()
                ui.dwriteTextAligned(
                        assist.value,
                        bodyFontSize,
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), bodyFontSpace)
                )
        end
end

return sessionInfoWidget
