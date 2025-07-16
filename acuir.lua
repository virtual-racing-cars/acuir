package.add("src")
require("audio")
require("laps")
require("controllers")
require("ui.hud")
require("ui.windows.entry_point_window")
require("utils")
local acc = require("ac_control")
local app = require("app")
local callback = require("callback")
local camera = require("camera")
local carSetup = require("car_setup")
local configs = require("configs")
local controls = require("controls")
local pitstop = require("pitstop")
local race = require("race")
local settings = require("settings")
local telemetry = require("telemetry")
local updater = require("updater")
local voting = require("voting")

controls:initialize()

app.state.appOpen = settings.General.autoStart
app.state.hasAppOpened = false

for _, v in pairs(settings.Appearance) do
        settings.Appearance[v.key] = v.default
end

function script.update(dt)
        if ac.getLastError() and not app.state.debug then
                app.state.open = false
                ui.toast(ui.Icons.Warning, "ACUIR ERROR!!! Open Lua Debug for more info\n\n" .. ac.getLastError())
                        :button(ui.Icons.RestartWarning, "Attempt Reload", function() ac.restartApp() end)
                return
        end

        if callback.update then callback.update() end

        acc:step()

        if not app.state.appOpen then return end

        voting:step()
        camera:step()
        carSetup:step()
        race:step()
        pitstop:step(dt)

        -- replay:step(dt)

        if callback.sim then
                if callback.sim() then callback.sim = nil end
        end
end
