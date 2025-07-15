local settings = require("settings")

local style = require("src.ui.style")
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

local WidgetWindow = require("src.classes.WidgetWindow")

local entryListWindow = WidgetWindow("entry_list")
entryListWindow:addWidget("Leaderboard", require("ui.widgets.leaderboard"))
entryListWindow:addWidget("Time Table", require("ui.widgets.time_table"))

local trackMapWindow = WidgetWindow("track_map")
trackMapWindow:addWidget("Track Map", require("ui.widgets.track_map"))

local sessionControlWindow = WidgetWindow("session_control")
sessionControlWindow:addWidget("Session Control", require("ui.widgets.session_control"))

local sessionInfoWindow = WidgetWindow("session_info")
sessionInfoWindow:addWidget("Session Info", require("ui.widgets.session_info"))

function page.draw()
        genericButtonHeight = 40 * cui.scale()
        fontSize = style.main.font.body.size

        cui.pushWindow("session_box_window", 0, 0, ui.windowWidth(), ui.windowHeight() - 255 * cui.scale())

        entryListWindow:setPosition(0, 0)
        entryListWindow:setSize(ui.windowWidth() * 0.5 - 7.5 * cui.scale(), ui.windowHeight())
        entryListWindow:draw()

        trackMapWindow:setPosition(ui.windowWidth() * 0.5 + 7.5 * cui.scale(), 0)
        trackMapWindow:setSize(ui.windowWidth() / 3 - 15 * cui.scale(), ui.windowHeight())
        trackMapWindow:draw()

        sessionControlWindow:setPosition((ui.windowWidth() / 6) * 5 + 7.5 * cui.scale(), 0)
        sessionControlWindow:setSize(
                (ui.windowWidth() / 6) - 7.5 * cui.scale(),
                ui.windowHeight() * 0.15 - 7.5 * cui.scale()
        )
        sessionControlWindow:draw()

        sessionInfoWindow:setPosition(
                (ui.windowWidth() / 6) * 5 + 7.5 * cui.scale(),
                ui.windowHeight() * 0.15 + 7.5 * cui.scale()
        )
        sessionInfoWindow:setSize(
                (ui.windowWidth() / 6) - 7.5 * cui.scale(),
                ui.windowHeight() * 0.85 - 7.5 * cui.scale()
        )
        sessionInfoWindow:draw()

        cui.popWindow()

        bottomWidgetBar()

        return "finalize"
end

return page
