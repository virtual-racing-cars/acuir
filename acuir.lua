package.add("src")
require("audio")
require("ui.main_menu_window")
require("ui.pause_window")
require("ui.pitstop_window")
require("ui.results_window")
require("ui.settings_window")
require("ui.hud")
local acc = require("ac_control")
local app = require("app")
local callback = require("callback")
local camera = require("camera")
local carSetup = require("car_setup")
local pitstop = require("pitstop")
local race = require("race")
local settings = require("settings")

app.state.appOpen = settings.General.autoStart
app.state.hasAppOpened = false

function script.update(dt)
        acc:step()

        if not app.state.appOpen then return end

        camera:step()
        carSetup:step()
        race:step()
        pitstop:step(dt)
        -- replay:step(dt)

        if callback.sim then
                if callback.sim() then callback.sim = nil end
        end
end

function script.pause() end
