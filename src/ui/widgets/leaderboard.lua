local cui = require("ui.cui")
local race = require("race")
local settings = require("settings")

local leaderboard = {}

function leaderboard:draw(xPos, yPos, width, height)
        cui.pushWindow("leaderboard_widget_window", xPos, yPos, width, height, false)

        local height = 50 * cui.uiScale()
        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiThemeColor1 * 0.25)

        ui.setCursor(0)
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
        cui.dummy(height, height)

        cui.popWindow(true)
        cui.popWindow()
end

return leaderboard
