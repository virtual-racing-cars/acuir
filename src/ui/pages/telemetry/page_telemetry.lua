local page = {}

if true then return page end

package.path = package.path .. ";" .. ac.getFolder(ac.FolderID.ACAppsLua) .. "\\telemetrick\\?.lua"
-- require("telemetrick")
local acViewer = require("src\\telemetrick_acViewer")
local cui = require("ui.cui")
local pages = require("ui.pages")

local bottomBarButtons = {
        {
                label = "BACK",
                enabled = true,
                func = function() pages:goToMainMenu() end,
        },
}

local testScreen = { x = 1920, y = 1080 }
acViewer.getTelemetryFiles()
acViewer.open()

function page:draw(dt)
        cui.pushWindowFitted("telemetry_page_window")

        topBar("/ Telemetry")

        cui.pushWindow(
                "telemetry_viewer_window",
                0,
                180 * cui.uiScale(),
                ui.windowWidth(),
                ui.windowHeight() - 303 * cui.uiScale()
        )

        ui.setCursor(0)

        acViewer.setSize({
                x = 0,
                y = 0,
                w = ui.windowWidth(),
                h = ui.windowHeight(),
                th = (testScreen.y - 150) / 5,
        })

        if acViewer.isOpened then acViewer.draw(dt) end

        cui.popWindow()

        bottomBar(bottomBarButtons)

        cui.popWindow()

        return "debug"
end

return page
