local configs = require("configs")
local controllers = require("controllers")

local abs = math.abs

local ControlAxis = class("ControlAxis")

function ControlAxis:initialize(bind, centered)
        self.bind = bind
        self.isCentered = centered
        self.joy = configs.CONTROLS.ini:get(bind, "JOY", -1)
        self.axle = configs.CONTROLS.ini:get(bind, "AXLE", -1)
        self.min = configs.CONTROLS.ini:get(bind, "MIN", -1)
        self.max = configs.CONTROLS.ini:get(bind, "MAX", 1)

        self.listenerStartingValues = {}
        self:resetListeners()
end

function ControlAxis:resetListeners()
        for con = 0, ac.getJoystickCount() - 1 do
                self.listenerStartingValues[con] = {}
                for axis = 0, 7 do
                        self.listenerStartingValues[con][axis] = ac.getJoystickAxisValue(con, axis)
                end
        end
end

function ControlAxis:boundTo()
        local con = configs.CONTROLS.ini:get(self.bind, "JOY", -1)
        local axle = configs.CONTROLS.ini:get(self.bind, "AXLE", -1)

        if con >= 0 and axle ~= "" and tonumber(axle) ~= -1 then
                local controllerString = "Joy %s" % con

                if controllers[con] then controllerString = controllers[con].CON end

                return controllerString, string.format("Axle %s", axle + 1)
        else
                self.inputModeBound[1] = false
                return "", ""
        end
end

function ControlAxis:assign()
        for con = 0, ac.getJoystickCount() - 1 do
                for axis = 0, 7 do
                        local axisValue = ac.getJoystickAxisValue(con, axis)

                        if abs(axisValue) - abs(self.listenerStartingValues[con][axis]) > 0.5 then
                                self.joy = con
                                self.axle = axis

                                configs.CONTROLS:set(self.bind, "AXLE", axis)
                                configs.CONTROLS:set(self.bind, "JOY", con)
                                ac.reloadControlSettings()
                        end
                end
        end
end

function ControlAxis:clearAssign() self:resetListeners() end

function ControlAxis:save(inputMode)
        if self.listenerButton and self.listenerButton ~= -1 and self.listenerButton ~= "" then
                configs.CONTROLS.ini:setAndSave(self.bind, "JOY", self.listenerButton)
                configs.CONTROLS.ini:setAndSave(self.bind, "AXLE", -1)

                self:clearAssign()

                return true
        end

        self:clearAssign()
end

function ControlAxis:unbind(inputMode)
        configs.CONTROLS.ini:setAndSave(self.bind, "JOY", -1)
        configs.CONTROLS.ini:setAndSave(self.bind, "AXLE", -1)
end

function ControlAxis:getValue()
        self.min = configs.CONTROLS.ini:get(self.bind, "MIN", -1)
        self.max = configs.CONTROLS.ini:get(self.bind, "MAX", 1)

        return ac.getJoystickAxisValue(self.joy, self.axle)
end

return ControlAxis
