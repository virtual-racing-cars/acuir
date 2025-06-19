-- if true then return end

function isempty(str) return str == nil or str == "" end

function toCapitalCase(str)
        return (str:gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end))
end

ac.lapTimeToString = function(time, allowHours)
        allowHours = allowHours == true
        time = tonumber(time)

        if not time or time <= 0 or math.abs(time) == math.huge then return "--:--.---" end

        local totalSeconds = math.floor(time / 1000)
        local ms = time % 1000
        local seconds = totalSeconds % 60
        local minutes = math.floor(totalSeconds / 60)
        local hours = math.floor(minutes / 60)
        minutes = minutes % 60

        if allowHours and hours > 0 then
                local centiseconds = math.floor(ms / 10 + 0.5)
                return string.format("%d:%d:%02d.%02d", hours, minutes, seconds, centiseconds)
        elseif allowHours then
                local centiseconds = math.floor(ms / 10 + 0.5)
                return string.format("%d:%02d.%02d", minutes, seconds, centiseconds)
        else
                return string.format("%d:%02d.%03d", math.floor(totalSeconds / 60), seconds, ms)
        end
end

package.add("src")
require("audio")
require("laps")
require("controllers")
require("ui.hud")
require("ui.windows.entry_point_window")
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

        acc:step()

        if not app.state.appOpen then return end

        voting:step()
        camera:step()
        carSetup:step()
        race:step()
        pitstop:step(dt)

        -- ac.log(telemetry)

        -- replay:step(dt)

        if callback.sim then
                if callback.sim() then callback.sim = nil end
        end
end
