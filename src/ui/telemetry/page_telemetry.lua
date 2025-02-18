local page = {}

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

local mapCanvas

function findMinMax(t)
        if #t == 0 then return nil, nil end -- Handle empty table case

        local min, max = t[1], t[1] -- Initialize with first element

        for i = 2, #t do
                if t[i] < min then
                        min = t[i]
                elseif t[i] > max then
                        max = t[i]
                end
        end

        return min, max
end

function page:draw()
        cui.pushWindowFitted("telemetry_page_window")

        topBar("/ Telemetry")

        cui.pushWindow(
                "telemetry_viewer_window",
                0,
                200 * cui.scaleY(),
                ui.windowWidth(),
                ui.windowHeight() - 303 * cui.scaleY()
        )

        ui.setCursor(0)
        ui.drawRectFilled(0, ui.windowSize(), rgbm.colors.gray)

        ui.image(mapCanvas, ui.windowSize())

        cui.popWindow()

        bottomBar(bottomBarButtons)

        cui.popWindow()

        return "debug"
end

return page
