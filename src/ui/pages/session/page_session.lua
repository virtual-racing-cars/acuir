local mapWidget = require("ui.widgets.map")
local units = require("units")
local car = ac.getCar(0)
local sim = ac.getSim()
local uis = ac.getUI()

local page = {}

local cui = require("ui.cui")
local race = require("race")
local settings = require("settings")
local simutils = require("simutils")
local assistsINI = ac.INIConfig.load(ac.getFolder(ac.FolderID.Cfg) .. "\\assists.ini")
local raceINI = ac.INIConfig.raceConfig()
local personalBestINI = ac.INIConfig.load(ac.getFolder(ac.FolderID.ACDocuments) .. "\\personalbest.ini")
local trackBestLapTime = ac.lapTimeToString(
        personalBestINI:get(string.upper(string.format("%s@%s", ac.getCarID(0), ac.getTrackFullID("-"))), "TIME", 0)
)
local leaderboardWidget = require("ui.widgets.leaderboard")
local timetableWidget = require("ui.widgets.time_table")

local electronicsState = { [0] = "Off", [1] = "Factory", [2] = "On" }
local assistState = { [0] = "Not Allowed", [1] = "Allowed" }
local jumpStartState = { [0] = "No Penalty", [1] = "Pits", [2] = "Drive-Through" }

local vec2Temp1 = vec2()

local leaderboardActive = true

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

local weatherTypeString = {
        [0] = "Light Thunderstorm",
        "Thunderstorm",
        "Heavy Thunderstorm",
        "Light Drizzle",
        "Drizzle",
        "Heavy Drizzle",
        "LightRain",
        "Rain",
        "Heavy Rain",
        "LightSnow",
        "Snow",
        "Heavy Snow",
        "Light Sleet",
        "Sleet",
        "Heavy Sleet",
        "Clear",
        "Few Clouds",
        "Scattered Clouds",
        "Broken Clouds",
        "Overcast Clouds",
        "Fog",
        "Mist",
        "Smoke",
        "Haze",
        "Sand",
        "Dust",
        "Squalls",
        "Tornado",
        "Hurricane",
        "Cold",
        "Hot",
        "Windy",
        "Hail",
}

local weatherTypeIcon = {
        [0] = ui.Icons.WeatherStormLight,
        ui.Icons.WeatherStorm,
        ui.Icons.WeatherStorm,
        ui.Icons.WeatherDrizzle,
        ui.Icons.WeatherDrizzle,
        ui.Icons.WeatherDrizzle,
        ui.Icons.WeatherRainLight,
        ui.Icons.WeatherRain,
        ui.Icons.WeatherRain,
        ui.Icons.WeatherSnowLight,
        ui.Icons.WeatherSnow,
        ui.Icons.WeatherSnow,
        ui.Icons.WeatherHail,
        ui.Icons.WeatherHail,
        ui.Icons.WeatherHail,
        ui.Icons.WeatherClear,
        ui.Icons.WeatherFewClouds,
        ui.Icons.WeatherFewClouds,
        ui.Icons.WeatherOvercast,
        ui.Icons.WeatherOvercast,
        ui.Icons.WeatherFog,
        ui.Icons.WeatherFog,
        ui.Icons.WeatherFog,
        ui.Icons.WeatherFog,
        ui.Icons.WeatherFog,
        ui.Icons.WeatherFog,
        ui.Icons.WeatherWindy,
        ui.Icons.WeatherTornado,
        ui.Icons.WeatherTornado,
        ui.Icons.WeatherCold,
        ui.Icons.WeatherHot,
        ui.Icons.WeatherWindy,
        ui.Icons.WeatherHail,
}

---| `ui.Icons.WeatherClear` @![Icon](https://acstuff.ru/images/icons_24/weather_clear.png)
---| `ui.Icons.WeatherCold` @![Icon](https://acstuff.ru/images/icons_24/weather_cold.png)
---| `ui.Icons.WeatherDrizzle` @![Icon](https://acstuff.ru/images/icons_24/weather_drizzle.png)
---| `ui.Icons.WeatherFewClouds` @![Icon](https://acstuff.ru/images/icons_24/weather_few_clouds.png)
---| `ui.Icons.WeatherFog` @![Icon](https://acstuff.ru/images/icons_24/weather_fog.png)
---| `ui.Icons.WeatherHail` @![Icon](https://acstuff.ru/images/icons_24/weather_hail.png)
---| `ui.Icons.WeatherHot` @![Icon](https://acstuff.ru/images/icons_24/weather_hot.png)
---| `ui.Icons.WeatherHurricane` @![Icon](https://acstuff.ru/images/icons_24/weather_hurricane.png)
---| `ui.Icons.WeatherOvercast` @![Icon](https://acstuff.ru/images/icons_24/weather_overcast.png)
---| `ui.Icons.WeatherRainLight` @![Icon](https://acstuff.ru/images/icons_24/weather_rain_light.png)
---| `ui.Icons.WeatherRain` @![Icon](https://acstuff.ru/images/icons_24/weather_rain.png)
---| `ui.Icons.WeatherSleet` @![Icon](https://acstuff.ru/images/icons_24/weather_sleet.png)
---| `ui.Icons.WeatherSnowLight` @![Icon](https://acstuff.ru/images/icons_24/weather_snow_light.png)
---| `ui.Icons.WeatherSnow` @![Icon](https://acstuff.ru/images/icons_24/weather_snow.png)
---| `ui.Icons.WeatherStormLight` @![Icon](https://acstuff.ru/images/icons_24/weather_storm_light.png)
---| `ui.Icons.WeatherStorm` @![Icon](https://acstuff.ru/images/icons_24/weather_storm.png)
---| `ui.Icons.WeatherTornado` @![Icon](https://acstuff.ru/images/icons_24/weather_tornado.png)
---| `ui.Icons.WeatherWarm` @![Icon](https://acstuff.ru/images/icons_24/weather_warm.png)
---| `ui.Icons.WeatherWindySun` @![Icon](https://acstuff.ru/images/icons_24/weather_windy_sun.png)
---| `ui.Icons.WeatherWindy` @![Icon](https://acstuff.ru/images/icons_24/weather_windy.png)

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
                value = function() return string.format("%s", weatherTypeString[sim.weatherType]) end,
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

local trackLocation
local function getTrackLocation()
        if not trackLocation then
                if ac.getTrackID() == "" then return nil end
                local path = ac.getFolder(ac.FolderID.ContentTracks) .. "/" .. ac.getTrackID() .. "/ui/"
                if ac.getTrackLayout() ~= "" then path = path .. ac.getTrackLayout() .. "/" end
                print(path .. "ui_track.json")
                local city = JSON.parse(io.load(path .. "ui_track.json")).city
                local country = JSON.parse(io.load(path .. "ui_track.json")).country
                trackLocation = string.reggsub(city, [[\t|</?br\s*/?\s*>]], "")
                        .. ", "
                        .. string.reggsub(country, [[\t|</?br\s*/?\s*>]], "")
        end
        return trackLocation
end

function page.update() end

function page.draw()
        local genericButtonHeight = 50 * cui.uiScale()
        local fontSize = genericButtonHeight * 0.50
        local titleFontSize = genericButtonHeight * 0.55

        cui.contentWindow(
                "info_right_window_1",
                vec2(ui.windowWidth() - ui.windowWidth() / 5, 0),
                vec2(ui.windowWidth() / 5, 210 * cui.uiScale()),
                ui.WindowFlags.None,
                function()
                        ui.setCursor(0)

                        ui.drawRectFilled(0, ui.windowSize(), rgbm(0.1, 0.1, 0.1, 0.55))
                        ui.drawRectFilled(0, vec2(ui.windowWidth(), genericButtonHeight), rgbm(0.1, 0.1, 0.1, 0.95))

                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                "Session Control",
                                titleFontSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), genericButtonHeight)
                        )

                        local driveButtonHeight = 80

                        ui.setCursorX(driveButtonHeight)
                        cui.setCursorY(70)
                        if
                                cui.iconButton(
                                        sim.isOnlineRace and "Vote Restart" or "Restart",
                                        ui.Icons.Reset,
                                        driveButtonHeight,
                                        driveButtonHeight,
                                        simutils.sessionRestartable and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
                                )
                        then
                                if sim.isOnlineRace then
                                        ac.castVote("restart", true)
                                else
                                        ac.tryToRestartSession()
                                end
                        end

                        ui.setCursorX(ui.windowWidth() - driveButtonHeight * 2)

                        if
                                cui.iconButton(
                                        sim.isOnlineRace and "Vote Skip Session" or "Skip",
                                        ui.Icons.Skip,
                                        driveButtonHeight,
                                        driveButtonHeight,
                                        simutils.sessionSkippable and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
                                )
                        then
                                if sim.isOnlineRace then
                                        ac.castVote("skip", true)
                                else
                                        ac.tryToSkipSession()
                                end
                        end

                        if not ac.canCastVote() then
                                ui.setCursorX(0)
                                ui.setCursorY(ui.windowHeight() - 36 * cui.uiScale())
                                ui.dwriteTextAligned(
                                        "Voting Cooldown %.1f s" % ac.timeToNextVote(),
                                        18 * cui.uiScale(),
                                        ui.Alignment.Center,
                                        ui.Alignment.Center,
                                        vec2(ui.windowWidth(), 36 * cui.uiScale())
                                )
                        end
                end
        )

        cui.contentWindow(
                "info_left_window_3",
                vec2(ui.windowWidth() - ui.windowWidth() / 5, ui.getCursorY() + 15 * cui.uiScale()),
                vec2(ui.windowWidth() / 5, 310 * cui.uiScale()),
                ui.WindowFlags.None,
                function()
                        ui.setCursor(0)

                        ui.drawRectFilled(0, ui.windowSize(), rgbm(0.1, 0.1, 0.1, 0.55))
                        ui.drawRectFilled(0, vec2(ui.windowWidth(), genericButtonHeight), rgbm(0.1, 0.1, 0.1, 0.95))

                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                "CONDITIONS",
                                titleFontSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), genericButtonHeight)
                        )

                        cui.setCursorY(65)

                        for _, weather in ipairs(sessionInfoTable) do
                                ui.setCursorX(ui.windowWidth() * 0.05)
                                cui.snapCursor()
                                ui.dwriteTextAligned(
                                        weather.label,
                                        fontSize,
                                        ui.Alignment.Start,
                                        ui.Alignment.Center,
                                        vec2(ui.windowWidth(), fontSize * 1.25)
                                )
                                ui.sameLine()
                                ui.setCursorX(ui.windowWidth() * 0.5)

                                cui.snapCursor()
                                ui.dwriteTextAligned(
                                        weather.value(),
                                        fontSize,
                                        ui.Alignment.Start,
                                        ui.Alignment.Center,
                                        vec2(ui.windowWidth(), fontSize * 1.25)
                                )
                        end
                end
        )

        cui.contentWindow(
                "info_left_window_4",
                vec2(ui.windowWidth() - ui.windowWidth() / 5, ui.getCursorY() + 15 * cui.uiScale()),
                vec2(ui.windowWidth() / 5, 380 * cui.uiScale()),
                ui.WindowFlags.None,
                function()
                        ui.setCursor(0)

                        ui.drawRectFilled(0, ui.windowSize(), rgbm(0.1, 0.1, 0.1, 0.55))
                        ui.drawRectFilled(0, vec2(ui.windowWidth(), genericButtonHeight), rgbm(0.1, 0.1, 0.1, 0.95))

                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                "MODIFIERS",
                                titleFontSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), genericButtonHeight)
                        )

                        cui.setCursorY(65)

                        for _, assist in ipairs(assists) do
                                ui.setCursorX(ui.windowWidth() * 0.05)
                                cui.snapCursor()
                                ui.dwriteTextAligned(
                                        assist.label,
                                        fontSize,
                                        ui.Alignment.Start,
                                        ui.Alignment.Center,
                                        vec2(ui.windowWidth(), fontSize * 1.25)
                                )
                                ui.sameLine()
                                ui.setCursorX(ui.windowWidth() * 0.5)
                                cui.snapCursor()
                                ui.dwriteTextAligned(
                                        assist.value,
                                        fontSize,
                                        ui.Alignment.Start,
                                        ui.Alignment.Center,
                                        vec2(ui.windowWidth(), fontSize * 1.25)
                                )
                        end
                end
        )

        cui.contentWindow(
                "info_map_window",
                vec2(ui.windowWidth() * 0.5 + 7.5 * cui.uiScale(), 0),
                vec2(730 * cui.uiScale(), 930 * cui.uiScale()),
                ui.WindowFlags.None,
                function()
                        ui.drawRectFilled(0, ui.windowSize(), rgbm(0.1, 0.1, 0.1, 0.55))
                        ui.drawRectFilled(
                                vec2(0, 0),
                                vec2(ui.windowWidth(), 50 * cui.uiScale()),
                                rgbm(0.1, 0.1, 0.1, 1)
                        )

                        ui.setCursor(0)
                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                "TRACK MAP",
                                titleFontSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), genericButtonHeight)
                        )

                        local track = string.split(ac.getTrackName(), " - ")

                        for _, trackLine in ipairs(track) do
                                ui.dwriteTextAligned(
                                        trackLine,
                                        fontSize,
                                        ui.Alignment.Start,
                                        ui.Alignment.Center,
                                        vec2(ui.windowWidth(), fontSize * 1.2)
                                )
                        end

                        ui.dwriteTextAligned(
                                "%s" % getTrackLocation(),
                                fontSize,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), fontSize)
                        )

                        cui.contentWindow(
                                "info_map_window2",
                                vec2(0, 50 * cui.uiScale()),
                                vec2(ui.windowWidth(), ui.windowHeight() - 50 * cui.uiScale()),
                                ui.WindowFlags.None,
                                function() mapWidget:draw() end
                        )

                        local xStart = 80 * cui.uiScale()
                        local yStart = 100 * cui.uiScale()
                        local size = 50 * cui.uiScale()
                        local row = 0
                        local column = 0
                        local xGap = 100 * cui.uiScale()
                        local yGap = 120 * cui.uiScale()
                        local columnMax = 5

                        for i = 0, 24 do
                                column = column + 1

                                if i % columnMax == 0 then
                                        row = row + 1
                                        column = 0
                                end

                                local x = xStart + column * xGap
                                local y = yStart + row * yGap

                                if row % 2 ~= 0 then x = x + xGap end

                                ui.beginRotation()
                                ui.drawIcon(
                                        ui.Icons.UpAlt,
                                        vec2(x, y),
                                        vec2(x + size, y + size),
                                        rgbm(0.6, 0.7, 0.9, 0.1)
                                )
                                ui.endRotation(90 - sim.windDirectionDeg)
                        end

                        ui.drawIcon(
                                weatherTypeIcon[sim.weatherType],
                                vec2(25 * cui.uiScale(), ui.windowHeight() - 75 * cui.uiScale()),
                                vec2(75 * cui.uiScale(), ui.windowHeight() - 25 * cui.uiScale())
                        )

                        ui.drawIcon(
                                ui.Icons.Compass,
                                vec2(ui.windowWidth() - 75 * cui.uiScale(), ui.windowHeight() - 75 * cui.uiScale()),
                                vec2(ui.windowWidth() - 25 * cui.uiScale(), ui.windowHeight() - 25 * cui.uiScale())
                        )
                        ui.setCursorX(ui.windowWidth() - 62 * cui.uiScale())
                        ui.setCursorY(ui.windowHeight() - 125 * cui.uiScale())
                        ui.dwriteText("N", 40 * cui.uiScale())
                end
        )

        local height = 50 * cui.uiScale()

        cui.pushWindow(
                "home_leaderboard_window",
                0,
                0,
                ui.windowWidth() * 0.5 - 7.5 * cui.uiScale(),
                ui.windowHeight() - 255 * cui.uiScale(),
                false
        )
        ui.drawRectFilled(0, vec2(ui.windowWidth(), 50 * cui.uiScale()), rgbm(0, 0, 0, 1))

        ui.setCursor(0)
        if
                cui.menuButton(
                        "LEADERBOARD",
                        vec2Temp1:set(ui.windowWidth() / 2, height),
                        0,
                        0,
                        0,
                        leaderboardActive,
                        false
                )
        then
                leaderboardActive = true
        end
        ui.sameLine()

        if
                cui.menuButton(
                        "TIME TABLE",
                        vec2Temp1:set(ui.windowWidth() / 2, height),
                        0,
                        0,
                        ui.ButtonFlags.None,
                        not leaderboardActive,
                        false
                )
        then
                leaderboardActive = false
        end

        if leaderboardActive then
                leaderboardWidget:draw(0, height, ui.windowWidth(), ui.windowHeight() - height)
        else
                timetableWidget:draw(0, height, ui.windowWidth(), ui.windowHeight() - height)
        end

        cui.popWindow()

        bottomWidgetBar()

        return ""
end

return page
