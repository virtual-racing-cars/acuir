local sim = ac.getSim()

local page = {}

require("src.classes.PlayerListButton")
local cardWidget = require("ui.widgets.card")
local chatWidget = require("ui.widgets.chat")
local cui = require("ui.cui")
local race = require("race")
local replay = require("replay")
local replayWidget = require("ui.widgets.replay")
local settings = require("settings")

require("src.ui.main.map")

local border = 15

function page.update() end

function page.draw()
        cui.pushWindowFitted("main_menu_page_window")

        topBar("/ Leaderboard")

        cui.pushWindow(
                "home_leaderboard_window",
                0,
                216 * cui.scaleY(),
                ui.windowWidth() * 0.5,
                ui.windowHeight() - 500 * cui.scaleY(),
                true
        )

        local height = 50 * cui.scaleY()
        playerListBanner(0, 0, ui.windowWidth(), height)

        cui.pushWindow("home_leaderboard_entrant_window", 0, height, ui.windowWidth(), ui.windowHeight() - height, true)
        for i, car in ac.iterateCars.leaderboard() do
                playerListButton(car, 0, (i - 1) * height, ui.windowWidth(), height)
        end
        cui.popWindow(true)
        cui.popWindow()

        cui.pushWindow(
                "home_bottom_bar",
                0,
                ui.windowHeight() - 240 * cui.scaleY(),
                ui.windowWidth(),
                240 * cui.scaleY(),
                true
        )
        ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), rgbm(0.1, 0.1, 0.1, 0.95))

        border = 15 * cui.scaleY()

        local widgetYPos = ui.windowHeight() - 240 * cui.scaleY() + border
        local widgetWidth = ui.windowWidth() / 3 - border
        local widgetHeight = 240 * cui.scaleY() - border * 2

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
