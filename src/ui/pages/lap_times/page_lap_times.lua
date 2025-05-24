local car = ac.getCar(0)
local sim = ac.getSim()

local page = {}

require("src.classes.PlayerListButton")

local cui = require("ui.cui")
local race = require("race")

function page.update() end

local listtable = SortableListTable({
        { label = "Lap", proportion = 0.05 },
        { label = "Valid", proportion = 0.05 },
        { label = "Tyre", proportion = 0.15 },
        { label = "Time", proportion = 0.15 },
        { label = "S1", proportion = 0.15 },
        { label = "S2", proportion = 0.15 },
        { label = "S3", proportion = 0.15 },
        { label = "Diff-Best", proportion = 0.15 },
})

function page.draw()
        cui.pushWindow(
                "home_leaderboard_window",
                0,
                0,
                ui.windowWidth() * 0.5,
                ui.windowHeight() - 420 * cui.uiScale(),
                true
        )

        local height = 44 * cui.uiScale()

        listtable:draw({
                race.laps[0],
        }, ui.windowWidth(), ui.windowHeight() - height, height)

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

        cui.popWindow()

        bottomWidgetBar()

        return ""
end

return page
