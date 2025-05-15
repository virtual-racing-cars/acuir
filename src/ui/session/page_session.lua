local sim = ac.getSim()

local page = {}

require("src.classes.PlayerListButton")
require("src.ui.session.map")
local cardWidget = require("ui.widgets.card")
local chatWidget = require("ui.widgets.chat")
local cui = require("ui.cui")
local race = require("race")
local replay = require("replay")
local replayWidget = require("ui.widgets.replay")
local settings = require("settings")
local assistsINI = ac.INIConfig.load(ac.getFolder(ac.FolderID.Cfg) .. "\\assists.ini")
local raceINI = ac.INIConfig.raceConfig()

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

local trackDescription
local function getTrackDescription()
        if not trackDescription then
                if ac.getTrackID() == "" then return nil end
                local path = ac.getFolder(ac.FolderID.ContentTracks) .. "/" .. ac.getTrackID() .. "/ui/"
                if ac.getTrackLayout() ~= "" then path = path .. ac.getTrackLayout() .. "/" end
                print(path .. "ui_track.json")
                local description = JSON.parse(io.load(path .. "ui_track.json")).description
                trackDescription = string.reggsub(description, [[\t|</?br\s*/?\s*>]], "")
        end
        return trackDescription
end

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

local border = 15

function page.update() end

function page.draw()
        cui.pushWindowFitted("session_page_window")

        topBar("/ Leaderboard")

        cui.contentWindow(
                "info_left_window",
                vec2(ui.windowWidth() - ui.windowWidth() / 5, 180 * cui.uiScale()),
                vec2(ui.windowWidth() / 5, ui.windowHeight() - 420 * cui.uiScale()),
                ui.WindowFlags.None,
                function()
                        ui.drawRectFilled(0, ui.windowSize(), rgbm(0.1, 0.1, 0.1, 0.55))

                        ui.dwriteTextAligned(
                                ac.getTrackName(),
                                36 * cui.uiScale(),
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), 40)
                        )

                        ui.dwriteTextAligned(
                                "%s" % getTrackDescription(),
                                26 * cui.uiScale(),
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), 40)
                        )

                        ui.dwriteTextAligned(
                                "%s" % getTrackLocation(),
                                26 * cui.uiScale(),
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), 40)
                        )

                        ui.dwriteTextAligned(
                                "Length: %s km" % math.round(sim.trackLengthM / 1000, 2),
                                26 * cui.uiScale(),
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), 40)
                        )

                        ui.newLine()
                        for _, assist in ipairs(assists) do
                                ui.dwriteTextAligned(
                                        string.format("%s: %s", assist.label, assist.value),
                                        26 * cui.uiScale(),
                                        ui.Alignment.Start,
                                        ui.Alignment.Center,
                                        vec2(ui.windowWidth(), 40)
                                )
                        end
                end
        )

        cui.pushWindow(
                "home_leaderboard_window",
                0,
                180 * cui.uiScale(),
                ui.windowWidth() * 0.5,
                ui.windowHeight() - 420 * cui.uiScale(),
                true
        )

        local height = 44 * cui.uiScale()
        playerListBanner(0, 0, ui.windowWidth(), height)

        cui.pushWindow("home_leaderboard_entrant_window", 0, height, ui.windowWidth(), ui.windowHeight() - height, true)
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

        cui.pushWindow(
                "home_bottom_bar",
                0,
                ui.windowHeight() - 240 * cui.uiScale(),
                ui.windowWidth(),
                240 * cui.uiScale(),
                true
        )
        ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), rgbm(0.1, 0.1, 0.1, 0.95))

        border = 15 * cui.uiScale()

        local widgetYPos = ui.windowHeight() - 240 * cui.uiScale() + border
        local widgetWidth = ui.windowWidth() / 3 - border
        local widgetHeight = 240 * cui.uiScale() - border * 2

        cardWidget:draw(border, widgetYPos, widgetWidth, widgetHeight)
        replayWidget:draw(ui.windowWidth() * 0.5 - widgetWidth * 0.5, widgetYPos, widgetWidth, widgetHeight)
        chatWidget:draw(
                ui.windowWidth() * 0.5 + widgetWidth * 0.5 + border * 0.5,
                widgetYPos,
                widgetWidth,
                widgetHeight
        )

        cui.popWindow()
        cui.popWindow()

        return ""
end

return page
