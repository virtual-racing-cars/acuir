local configs = require("configs")
local controllers = require("controllers")
local gamepad = require("gamepad")
local sim = ac.getSim()

local abs = math.abs

local ControlAxis = class("ControlAxis")

function ControlAxis:initialize(bind, centered)
        self.bind = bind
        self.isCentered = centered
        self.joy = configs.CONTROLS.ini:get(bind, "JOY", -1)
        self.axle = configs.CONTROLS.ini:get(bind, "AXLE", -1)
        self.min = configs.CONTROLS.ini:get(bind, "MIN", -1)
        self.max = configs.CONTROLS.ini:get(bind, "MAX", 1)

        self.inputModeBound = false

        self.listenerGamepadStartValues = {}
        self.listenerControllerStartValues = {}

        self.listenerController = -1
        self.listenerAxis = -1

        self:clearAssign()
end

function ControlAxis:boundToController()
        local con = configs.CONTROLS.ini:get(self.bind, "JOY", -1)
        local axle = configs.CONTROLS.ini:get(self.bind, "AXLE", -1)

        if con >= 0 and axle ~= "" and axle ~= -1 then
                local controllerString = "Joy %s" % con

                if controllers[con] then controllerString = controllers[con].CON end

                self.inputModeBound = true

                return controllerString, string.format("Axle %s", axle + 1)
        else
                self.inputModeBound = false
                return "", ""
        end
end

function ControlAxis:boundToGamepad()
        local button

        if self.bind == "STEER" then
                button = configs.CONTROLS.ini:get("X360", "STEER_THUMB", "LEFT") == "LEFT" and 10 or 11
        else
                button = configs.CONTROLS.ini:get("X360", "AXIS_REMAP_" .. self.bind, -1)
        end

        if button and tonumber(button) ~= -1 and button ~= "" then
                self.inputModeBound = true

                return "Gamepad", gamepad.axisList[button].string
        else
                self.inputModeBound = false

                return "", ""
        end
end

function ControlAxis:boundTo(inputMode)
        if inputMode == 1 then
                return self:boundToController()
        elseif inputMode == 2 then
                return self:boundToGamepad()
        end

        return "", ""
end

function ControlAxis:assignController()
        for con = 0, ac.getJoystickCount() - 1 do
                for axis = 0, 7 do
                        local axisValue = ac.getJoystickAxisValue(con, axis)

                        if abs(axisValue - self.listenerControllerStartValues[con][axis]) > 0.1 and axisValue ~= 0 then
                                self.listenerController = con
                                self.listenerAxis = axis
                        end
                end
        end

        return (self.listenerController ~= -1), 0, self.listenerController, self.listenerAxis
end

function ControlAxis:assignGamepad()
        for con = 0, 7 do
                for axis = 0, 5 do
                        local axisValue = ac.getGamepadAxisValue(con, axis)

                        if abs(axisValue - self.listenerGamepadStartValues[con][axis]) > 0.1 and axisValue ~= 0 then
                                local axisValueNearest = math.ceil(axisValue)

                                if self.bind == "STEER" then
                                        if axis > 3 then
                                                self.listenerController = con
                                                self.listenerAxis = 1
                                        elseif axis > 1 then
                                                self.listenerController = con
                                                self.listenerAxis = 0
                                        end
                                elseif axis < 2 then
                                        self.listenerController = con
                                        self.listenerAxis = axis
                                elseif axis % 2 == 0 then
                                        self.listenerController = con
                                        self.listenerAxis = axis + 5 - axisValueNearest
                                else
                                        self.listenerController = con
                                        self.listenerAxis = axis - axisValueNearest
                                end
                        end
                end
        end

        return (self.listenerController ~= -1), 0, self.listenerController, self.listenerAxis
end

function ControlAxis:assign()
        if sim.inputMode == 0 then
                return self:assignController()
        elseif sim.inputMode == 1 then
                return self:assignGamepad()
        end

        return false, 0, -1, -1
end

function ControlAxis:clearAssign()
        self.listenerController = -1
        self.listenerAxis = -1

        for con = 0, ac.getJoystickCount() - 1 do
                self.listenerControllerStartValues[con] = {}
                for axis = 0, 7 do
                        self.listenerControllerStartValues[con][axis] = ac.getJoystickAxisValue(con, axis)
                end
        end

        for con = 0, 7 do
                self.listenerGamepadStartValues[con] = {}

                for axis = 0, 5 do
                        self.listenerGamepadStartValues[con][axis] = ac.getGamepadAxisValue(con, axis)
                end
        end
end

function ControlAxis:saveController()
        if self.listenerAxis and self.listenerAxis ~= -1 and self.listenerAxis ~= "" then
                configs.CONTROLS.ini:setAndSave(self.bind, "JOY", self.listenerController)
                configs.CONTROLS.ini:setAndSave(self.bind, "AXLE", self.listenerAxis)

                ac.reloadControlSettings()
                self:clearAssign()

                return true
        end
end

function ControlAxis:saveGamepad()
        if self.listenerAxis and self.listenerAxis ~= -1 and self.listenerAxis ~= "" then
                if self.bind == "STEER" then
                        configs.CONTROLS.ini:setAndSave(
                                "X360",
                                "STEER_THUMB",
                                self.listenerAxis == 1 and "RIGHT" or "LEFT"
                        )
                else
                        configs.CONTROLS.ini:setAndSave("X360", "AXIS_REMAP_" .. self.bind, self.listenerAxis)
                end

                ac.reloadControlSettings()
                self:clearAssign()

                return true
        end
end

function ControlAxis:save()
        if sim.inputMode == 1 then
                if self:saveGamepad() then return true end
        elseif sim.inputMode == 0 then
                if self:saveController() then return true end
        end

        self:clearAssign()
end

function ControlAxis:unbind()
        configs.CONTROLS.ini:setAndSave(self.bind, "JOY", -1)
        configs.CONTROLS.ini:setAndSave(self.bind, "AXLE", -1)
end

function ControlAxis:getJoystickAxisValue()
        self.joy = configs.CONTROLS.ini:get(self.bind, "JOY", -1)
        self.axle = configs.CONTROLS.ini:get(self.bind, "AXLE", -1)
        self.min = configs.CONTROLS.ini:get(self.bind, "MIN", -1)
        self.max = configs.CONTROLS.ini:get(self.bind, "MAX", 1)

        return ac.getJoystickAxisValue(self.joy, self.axle)
end

function ControlAxis:getGamepadAxisValue()
        if self.bind == "STEER" then
                return ac.getGamepadAxisValue(
                        0,
                        configs.CONTROLS.data.X360.STEER_THUMB == "LEFT" and ac.GamepadAxis.LeftThumbX
                                or ac.GamepadAxis.RightThumbX
                )
        elseif self.bind == "THROTTLE" then
                local axisRemap = gamepad.axisList[configs.CONTROLS.ini:get("X360", "AXIS_REMAP_" .. self.bind, -1)]

                local axisValue = ac.getGamepadAxisValue(0, axisRemap.axis)
                local axisValueNorm = math.lerpInvSat(axisValue, axisRemap.min, axisRemap.max) * 2 - 1

                return axisValueNorm
        elseif self.bind == "BRAKES" then
                local axisRemap = gamepad.axisList[configs.CONTROLS.ini:get("X360", "AXIS_REMAP_" .. self.bind, -1)]

                local axisValue = ac.getGamepadAxisValue(0, axisRemap.axis)
                local axisValueNorm = math.lerpInvSat(axisValue, axisRemap.min, axisRemap.max) * 2 - 1

                return axisValueNorm
        end

        return 0
end

function ControlAxis:getValue()
        if sim.inputMode == 0 then
                return self:getJoystickAxisValue()
        elseif sim.inputMode == 1 then
                return self:getGamepadAxisValue()
        end

        return 0
end

return ControlAxis
