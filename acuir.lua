-- if true then return end

function isempty(str) return str == nil or str == "" end

function toCapitalCase(str)
        return (str:gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end))
end

package.add("src")
require("audio")
require("laps")
require("controllers")
require("ui.hud")
local acc = require("ac_control")
local app = require("app")
local callback = require("callback")
local camera = require("camera")
local carSetup = require("car_setup")
local pitstop = require("pitstop")
local race = require("race")
local settings = require("settings")
local voting = require("voting")

app.state.appOpen = settings.General.autoStart
app.state.hasAppOpened = false

function script.update(dt)
        acc:step()

        if not app.state.appOpen then return end

        -- ac.blockEscapeButton()

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

function script.pause() end
