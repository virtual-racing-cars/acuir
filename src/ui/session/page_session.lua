local car = ac.getCar(0)
local sim = ac.getSim()

local page = {}

require("src.classes.PlayerListButton")
require("src.ui.session.map")
local cui = require("ui.cui")
local race = require("race")
local trackMap = require("src.ui.session.map")
local assistsINI = ac.INIConfig.load(ac.getFolder(ac.FolderID.Cfg) .. "\\assists.ini")
local raceINI = ac.INIConfig.raceConfig()
local personalBestINI = ac.INIConfig.load(ac.getFolder(ac.FolderID.ACDocuments) .. "\\personalbest.ini")
local trackBestLapTime = ac.lapTimeToString(
        personalBestINI:get(string.upper(string.format("%s@%s", ac.getCarID(0), ac.getTrackFullID("-"))), "TIME", 0)
)

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
        local fontSize = 26 * cui.uiScale()

        cui.contentWindow(
                "info_right_window_1",
                vec2(ui.windowWidth() - ui.windowWidth() / 5, 0),
                vec2(ui.windowWidth() / 5, 280 * cui.uiScale()),
                ui.WindowFlags.None,
                function()
                        ui.setCursor(0)

                        ui.drawRectFilled(0, ui.windowSize(), rgbm(0.1, 0.1, 0.1, 0.55))
                        ui.drawRectFilled(0, vec2(ui.windowWidth(), fontSize * 2), rgbm(0.1, 0.1, 0.1, 0.95))

                        ui.dwriteTextAligned(
                                "CAR",
                                fontSize * 1.25,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), fontSize * 2)
                        )
                        ui.newLine()

                        ui.dwriteTextAligned(
                                ac.getCarName(0, true),
                                fontSize,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), fontSize * 1.25)
                        )

                        ui.dwriteTextAligned(
                                "Track Fastest Lap: %s" % trackBestLapTime,
                                fontSize,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), fontSize * 1.25)
                        )

                        ui.dwriteTextAligned(
                                "Session Fastest Lap: %s" % ac.lapTimeToString(car.bestLapTimeMs),
                                fontSize,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), fontSize * 1.25)
                        )

                        ui.dwriteTextAligned(
                                "Driven Total: %.0f km" % car.distanceDrivenTotalKm,
                                fontSize,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), fontSize * 1.25)
                        )

                        ui.dwriteTextAligned(
                                "Driven Session: %.0f km" % car.distanceDrivenSessionKm,
                                fontSize,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), fontSize * 1.25)
                        )
                end
        )

        cui.contentWindow(
                "info_left_window_3",
                vec2(ui.windowWidth() - ui.windowWidth() / 5, 305 * cui.uiScale()),
                vec2(ui.windowWidth() / 5, 405 * cui.uiScale()),
                ui.WindowFlags.None,
                function()
                        ui.setCursor(0)

                        ui.drawRectFilled(0, ui.windowSize(), rgbm(0.1, 0.1, 0.1, 0.55))
                        ui.drawRectFilled(0, vec2(ui.windowWidth(), fontSize * 2), rgbm(0.1, 0.1, 0.1, 0.95))

                        ui.dwriteTextAligned(
                                "MODIFIERS",
                                fontSize * 1.25,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), fontSize * 2)
                        )
                        ui.newLine()

                        for _, assist in ipairs(assists) do
                                ui.dwriteTextAligned(
                                        string.format("%s: %s", assist.label, assist.value),
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
                        ui.dwriteTextAligned(
                                "TRACK",
                                fontSize * 1.25,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), fontSize * 2)
                        )

                        local track = string.split(ac.getTrackName(), " - ")

                        for _, trackLine in ipairs(track) do
                                ui.dwriteTextAligned(
                                        trackLine,
                                        fontSize,
                                        ui.Alignment.Start,
                                        ui.Alignment.Center,
                                        vec2(ui.windowWidth(), fontSize * 1.25)
                                )
                        end

                        ui.dwriteTextAligned(
                                "%s" % getTrackLocation(),
                                fontSize,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), fontSize * 1.25)
                        )

                        ui.dwriteTextAligned(
                                "Length: %s km" % math.round(sim.trackLengthM / 1000, 2),
                                fontSize,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), fontSize * 1.25)
                        )

                        cui.contentWindow(
                                "info_map_window2",
                                vec2(0, 50 * cui.uiScale()),
                                vec2(ui.windowWidth(), ui.windowHeight() - 50 * cui.uiScale()),
                                ui.WindowFlags.None,
                                function() drawMap() end
                        )
                end
        )

        cui.pushWindow(
                "home_leaderboard_window",
                0,
                0,
                ui.windowWidth() * 0.5 - 7.5 * cui.uiScale(),
                ui.windowHeight() - 255 * cui.uiScale(),
                false
        )
        local height = 50 * cui.uiScale()

        ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), height), rgbm(0.1, 0.1, 0.1, 1))

        ui.setCursor(0)
        ui.dwriteTextAligned(
                "LEADERBOARD",
                fontSize * 1.25,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth(), fontSize * 2)
        )

        playerListBanner(0, height, ui.windowWidth(), height)

        cui.pushWindow(
                "home_leaderboard_entrant_window",
                0,
                height * 2,
                ui.windowWidth(),
                ui.windowHeight() - height,
                true
        )
        local leaderboardIndex = 0
        for _, slot in ipairs(race.leaderboard) do
                if slot.car.isConnected then
                        leaderboardIndex = leaderboardIndex + 1
                        playerListButton(
                                slot,
                                leaderboardIndex,
                                0,
                                (leaderboardIndex - 1) * height,
                                ui.windowWidth(),
                                height
                        )
                end
        end
        cui.popWindow(true)
        cui.popWindow()

        bottomWidgetBar()

        return ""
end

return page
