local mapWidget = require("ui.widgets.map")
local settings = require("settings")
local units = require("units")
local weather = require("weather")
local car = ac.getCar(0)
local sim = ac.getSim()
local uis = ac.getUI()

local page = {}

local cui = require("ui.cui")
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

local genericButtonHeight = 40
local fontSize = genericButtonHeight

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

local function trackMapWindow()
        cui.pushContentWindow(
                "info_map_window",
                ui.windowWidth() * 0.5 + 7.5 * cui.uiScale(),
                0,
                730 * cui.uiScale(),
                ui.windowHeight(),
                function()
                        ui.setCursor(0)
                        if cui.menuButton("TRACK MAP", 40, 0, 0, 0, false, false, ui.CornerFlags.Top) then
                        end
                end,
                function() mapWidget:drawFooter() end
        )

        local track = string.split(ac.getTrackName(), " - ")

        cui.offsetCursorY(10)
        for _, trackLine in ipairs(track) do
                cui.offsetCursorX(10)
                cui.snapCursor()

                ui.dwriteTextAligned(
                        trackLine,
                        fontSize,
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), fontSize * 1.2)
                )
        end

        cui.offsetCursorX(10)
        cui.snapCursor()
        ui.dwriteTextAligned(
                "%s" % getTrackLocation(),
                fontSize,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth(), fontSize)
        )

        mapWidget:draw()

        cui.popContentWindow()
end

local function sessionControlWindow()
        cui.pushContentWindow(
                "session_control",
                ui.windowWidth() - ui.windowWidth() / 5,
                0,
                ui.windowWidth() / 5,
                ui.windowHeight() * 0.16 - 7.5 * cui.uiScale(),
                function()
                        ui.setCursor(0)
                        if cui.menuButton("Session Control", 40, 0, 0, 0, false, false, ui.CornerFlags.Top) then
                        end
                end
        )

        local driveButtonHeight = ui.windowWidth() * 0.2

        ui.setCursorX(ui.windowWidth() * 0.2)
        ui.setCursorY(0)
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

        ui.setCursorX(ui.windowWidth() * 0.6)

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

        if not ac.canCastVote() and sim.isOnlineRace then
                ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorSecondary * 0.75, 6)
                ui.setCursor(0)
                ui.dwriteTextAligned(
                        "Voting Cooldown %.0f s" % ac.timeToNextVote(),
                        32 * cui.uiScale(),
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        ui.windowSize()
                )
        end

        cui.popContentWindow()
end

local function conditionsWindow()
        cui.pushContentWindow(
                "session_conditions",
                ui.windowWidth() - ui.windowWidth() / 5,
                ui.windowHeight() * 0.16 + 7.5 * cui.uiScale(),
                ui.windowWidth() / 5,
                ui.windowHeight() * 0.42 - 15 * cui.uiScale(),
                function()
                        ui.setCursor(0)
                        if cui.menuButton("Conditions", 40, 0, 0, 0, false, false, ui.CornerFlags.Top) then
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
        cui.pushContentWindow(
                "session_modifiers",
                ui.windowWidth() - ui.windowWidth() / 5,
                ui.windowHeight() * 0.58 + 7.5 * cui.uiScale(),
                ui.windowWidth() / 5,
                ui.windowHeight() * 0.42 - 7.5 * cui.uiScale(),
                function()
                        ui.setCursor(0)
                        if cui.menuButton("Modifiers", 40, 0, 0, 0, false, false, ui.CornerFlags.Top) then
                        end
                end
        )

        cui.offsetCursorY(10)

        for _, assist in ipairs(assists) do
                cui.setCursorX(15)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        assist.label,
                        fontSize,
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), fontSize * 1.5)
                )
                ui.sameLine()
                ui.setCursorX(ui.windowWidth() * 0.5)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        assist.value,
                        fontSize,
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth(), fontSize * 1.5)
                )
        end
        cui.popContentWindow()
end

function page.draw()
        genericButtonHeight = 40 * cui.uiScale()
        fontSize = 18 * cui.uiScale()

        cui.pushWindow("session_box_window", 0, 0, ui.windowWidth(), ui.windowHeight() - 255 * cui.uiScale())

        trackMapWindow()
        sessionControlWindow()
        conditionsWindow()
        modifiersWindow()

        cui.pushContentWindow(
                "home_leaderboard_window",
                0,
                0,
                ui.windowWidth() * 0.5 - 7.5 * cui.uiScale(),
                ui.windowHeight(),
                function()
                        ui.setCursor(0)
                        if cui.menuButton("LEADERBOARD", 40, 0, 0, 0, leaderboardActive, false, ui.CornerFlags.Top) then
                                leaderboardActive = true
                        end
                        ui.sameLine()

                        if
                                cui.menuButton(
                                        "TIME TABLE",
                                        40,
                                        0,
                                        0,
                                        ui.ButtonFlags.None,
                                        not leaderboardActive,
                                        false,
                                        ui.CornerFlags.Top
                                )
                        then
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

        cui.popWindow()

        bottomWidgetBar()

        return ""
end

return page
