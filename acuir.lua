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
local controls = require("controls")
local cui = require("src.ui.cui")
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
