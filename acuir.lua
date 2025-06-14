-- if true then return end

function isempty(str) return str == nil or str == "" end

function toCapitalCase(str)
        return (str:gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end))
end

ac.lapTimeToString = function(time, allowHours)
        allowHours = allowHours == true
        time = tonumber(time)

        if not time or time == 0 then return "--:--.---" end

        local totalSeconds = math.floor(time / 1000)
        local ms = time % 1000
        local seconds = totalSeconds % 60
        local minutes = math.floor(totalSeconds / 60) % 60
        local hours = math.floor(minutes / 60)

        if allowHours then
                local centiseconds = math.floor(ms / 10 + 0.5)
                return string.format("%d:%02d:%02d.%02d", hours, minutes, seconds, centiseconds)
        else
                local fullMinutes = math.floor(totalSeconds / 60)
                if fullMinutes < 10 then
                        return string.format("%d:%02d.%03d", fullMinutes, seconds, ms)
                else
                        return string.format("%02d:%02d.%03d", fullMinutes, seconds, ms)
                end
        end
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
local controls = require("controls")
local pitstop = require("pitstop")
local race = require("race")
local settings = require("settings")
local telemetry = require("telemetry")
local voting = require("voting")
local sim = ac.getSim()

controls:initialize()

app.state.appOpen = settings.General.autoStart
app.state.hasAppOpened = false

function script.update(dt)
        if ac.getLastError() and not app.state.debug then
                app.state.open = false
                settings.General.autoStart = false
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

-- ---Similar to `ui.invisibleButton()`, but this one can be activated similar to text input and if it is active, will monitor keyboard state.
-- ---@param id string? @Default value: `'nil'`.
-- ---@param size vec2? @Default value: `vec2(0, 0)`.
-- ---@return ui.CapturedKeyboard?
-- ---@return boolean @Set to `true` if area was just activated.
-- function ui.interactiveArea(id, size) end
