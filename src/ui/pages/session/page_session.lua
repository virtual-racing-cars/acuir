local leaderboardWidget = require("ui.widgets.leaderboard")
local sessionControlWidget = require("ui.widgets.session_control")
local sessionModifiersWidget = require("ui.widgets.session_modifiers")
local settings = require("settings")
local timetableWidget = require("ui.widgets.time_table")
local trackMapWidget = require("ui.widgets.track_map")

local units = require("units")
local weather = require("weather")
local car = ac.getCar(0)
local sim = ac.getSim()
local uis = ac.getUI()

local page = {}

local cui = require("ui.cui")
local simutils = require("simutils")
local personalBestINI = ac.INIConfig.load(ac.getFolder(ac.FolderID.ACDocuments) .. "\\personalbest.ini")
local trackBestLapTime = ac.lapTimeToString(
        personalBestINI:get(string.upper(string.format("%s@%s", ac.getCarID(0), ac.getTrackFullID("-"))), "TIME", 0)
)

local genericButtonHeight = 40
local fontSize = genericButtonHeight

local vec2Temp1 = vec2()

local leaderboardActive = true

local sessionInfoTable = {
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
                label = "Grip",
                value = function() return string.format("%s - %.1f %%", simutils.trackGripString, sim.roadGrip * 100) end,
        },
        {
                label = "Air Temp",
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

local carInfoTable = {
        {
                label = "Fastest Lap",
                value = function() return string.format("%s", trackBestLapTime) end,
        },
        {
                label = "Session Fastest Lap",
                value = function() return string.format("%s", ac.lapTimeToString(car.bestLapTimeMs)) end,
        },
        {
                label = "Driven Total",
                value = function()
                        return string.format(
                                "%.1f %s",
                                units:speed(car.distanceDrivenTotalKm),
                                uis.useImperialUnits and "mi" or "km"
                        )
                end,
        },
        {
                label = "Driven Session",
                value = function()
                        return string.format(
                                "%.1f %s",
                                units:speed(car.distanceDrivenSessionKm),
                                uis.useImperialUnits and "mi" or "km"
                        )
                end,
        },
}

function page.update() end

local function trackMapWindow()
        trackMapWidget:setPosition(ui.windowWidth() * 0.5 + 7.5 * cui.uiScale(), 0)
        trackMapWidget:setSize(730 * cui.uiScale(), ui.windowHeight())
        trackMapWidget:draw()
end

local function sessionControlWindow()
        sessionControlWidget:setPosition(ui.windowWidth() - ui.windowWidth() / 5, 0)
        sessionControlWidget:setSize(ui.windowWidth() / 5, ui.windowHeight() * 0.2 - 7.5 * cui.uiScale())
        sessionControlWidget:draw()
end

local function conditionsWindow()
        cui.pushContentWindow(
                "session_conditions",
                ui.windowWidth() - ui.windowWidth() / 5,
                ui.windowHeight() * 0.2 + 7.5 * cui.uiScale(),
                ui.windowWidth() / 5,
                ui.windowHeight() * 0.4 - 15 * cui.uiScale(),
                function()
                        ui.setCursor(0)
                        if cui.windowTabButton("Conditions", 36, ui.ButtonFlags.None, false) then
                        end
                end
        )

        cui.offsetCursorY(10)

        for _, weatherInfo in ipairs(sessionInfoTable) do
                cui.setCursorX(15)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        weatherInfo.label,
                        fontSize,
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), fontSize * 1.5)
                )
                ui.sameLine()
                ui.setCursorX(ui.windowWidth() * 0.5)

                cui.snapCursor()
                ui.dwriteTextAligned(
                        weatherInfo.value(),
                        fontSize,
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), fontSize * 1.5)
                )
        end

        cui.popContentWindow()
end

local function modifiersWindow()
        sessionModifiersWidget:setPosition(
                ui.windowWidth() - ui.windowWidth() / 5,
                ui.windowHeight() * 0.6 + 7.5 * cui.uiScale()
        )
        sessionModifiersWidget:setSize(ui.windowWidth() / 5, ui.windowHeight() * 0.4 - 7.5 * cui.uiScale())
        sessionModifiersWidget:draw()
end

local function leaderboardWindow()
        cui.pushContentWindow(
                "home_leaderboard_window",
                0,
                0,
                ui.windowWidth() * 0.5 - 7.5 * cui.uiScale(),
                ui.windowHeight(),
                function()
                        ui.setCursor(0)
                        if cui.windowTabButton("LEADERBOARD", 36, ui.ButtonFlags.None, leaderboardActive) then
                                leaderboardActive = true
                        end
                        ui.sameLine()

                        if cui.windowTabButton("TIME TABLE", 36, ui.ButtonFlags.None, not leaderboardActive) then
                                leaderboardActive = false
                        end
                end,
                function()
                        if leaderboardActive then
                                leaderboardWidget:drawFooter()
                        else
                                timetableWidget:drawFooter()
                        end
                end
        )

        if leaderboardActive then
                leaderboardWidget:draw(0, 0, ui.windowWidth(), ui.windowHeight())
        else
                timetableWidget:draw(0, 0, ui.windowWidth(), ui.windowHeight())
        end

        cui.popContentWindow()
end

function page.draw()
        genericButtonHeight = 40 * cui.uiScale()
        fontSize = 18 * cui.uiScale()

        cui.pushWindow("session_box_window", 0, 0, ui.windowWidth(), ui.windowHeight() - 255 * cui.uiScale())

        leaderboardWindow()
        trackMapWindow()
        sessionControlWindow()
        conditionsWindow()
        modifiersWindow()

        cui.popWindow()

        bottomWidgetBar()

        return ""
end

return page
