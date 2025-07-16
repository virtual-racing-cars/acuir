local configs = require("configs")
local controllers = require("controllers")
local gamepad = require("gamepad")
local keys = require("keys")

local sim = ac.getSim()

local ControlButton = class("ControlButton")

local inputModeStringKeys = {
        "BUTTON",
        "XBOXBUTTON",
        "KEY",
}

local povStrings = {
        [0] = "Left",
        "Up",
        "Right",
        "Down",
}

function ControlButton:initialize(bind, defaults)
        self.bind = bind
        self.defaults = defaults
        self._button = ac.ControlButton(self.bind, self.defaults)

        self.listenerButton = -1
        self.listenerModificators = {}
        self.listenerController = -1
        self.listenerControllerModificator = -1
        self.listenerInputMode = -1
        self.inputModeBound = { [0] = false, false, false, false }
        self.listenerIsDpad = false
        self.listenerDpadStartValues = {}

        self:clearAssign()
end

function ControlButton:disabled() return self._button:disabled() end

function ControlButton:setDisabled(disabled) self._button:setDisabled(disabled) end

function ControlButton:boundToController()
        local con = configs.CONTROLS.ini:get(self.bind, "JOY", -1)
        local button = configs.CONTROLS.ini:get(self.bind, "BUTTON", -1)
        local buttonMod = configs.CONTROLS.ini:get(self.bind, "BUTTON_MODIFICATOR", -1)
        local cmPov = configs.CONTROLS.ini:get(self.bind, "__CM_POV", -1) >= 0
        local cmPovDir = configs.CONTROLS.ini:get(self.bind, "__CM_POV_DIR", -1)

        if con >= 0 and cmPov then
                local controllerString = "Joy %s" % con

                if controllers[con] then controllerString = controllers[con].CON end

                self.inputModeBound[1] = true

                if buttonMod == -1 then return controllerString, string.format("POV %s", povStrings[cmPovDir]) end

                return controllerString, string.format("Button %s + POV %s", buttonMod + 1, povStrings[cmPovDir])
        elseif con >= 0 and button ~= "" and tonumber(button) ~= -1 then
                local controllerString = "Joy %s" % con

                if controllers[con] then controllerString = controllers[con].CON end

                self.inputModeBound[1] = true

                if buttonMod == -1 then return controllerString, string.format("Button %s", button + 1) end

                return controllerString, string.format("Button %s + Button %s", buttonMod + 1, button + 1)
        else
                self.inputModeBound[1] = false
                return "", ""
        end
end

function ControlButton:boundToGamepad()
        local button = configs.CONTROLS.ini:get(self.bind, "XBOXBUTTON", "")

        if button and tonumber(button) ~= -1 and button ~= "" then
                self.inputModeBound[2] = true

                return "Gamepad", gamepad.codeStringList[button]
        else
                self.inputModeBound[2] = false

                return "", ""
        end
end

function ControlButton:boundToKey()
        local primaryKey, modifierKeys = -1, {}

        if string.startsWith(self.bind, "KEYBOARD_") then
                primaryKey = configs.CONTROLS.ini:get("KEYBOARD", self.bind:gsub("KEYBOARD_", ""), -1)
        else
                primaryKey = configs.CONTROLS.ini:get(self.bind, "KEY", -1)
                modifierKeys = configs.CONTROLS.ini:get(self.bind, "KEY_MODIFICATOR", {})
        end

        if type(modifierKeys[1]) == "table" then modifierKeys = modifierKeys[1] end

        local deviceString, bindingString = "", ""

        for _, modKey in ipairs(modifierKeys) do
                if modKey ~= nil and modKey ~= -1 and modKey ~= "-1" and modKey ~= "" then
                        bindingString = bindingString .. keys.indexStringList[tonumber(modKey)] .. "+"
                end
        end

        if primaryKey ~= nil and primaryKey ~= -1 and primaryKey ~= "-1" and primaryKey ~= "" then
                bindingString = bindingString .. keys:indexToString(primaryKey)
                deviceString = "Keyboard"
                self.inputModeBound[3] = true
        else
                bindingString = ""
                self.inputModeBound[3] = false
        end

        return deviceString, bindingString
end

function ControlButton:boundTo(inputMode)
        if inputMode == 1 then
                return self:boundToController()
        elseif inputMode == 2 then
                return self:boundToGamepad()
        elseif inputMode == 3 then
                return self:boundToKey()
        end
end

function ControlButton:listenControllerInputs()
        local anyButtonDown = false

        for con = 0, ac.getJoystickCount() - 1 do
                for dpad = 0, ac.getJoystickDpadsCount(con) - 1 do
                        local dpadValue = ac.getJoystickDpadValue(con, dpad)
                        if
                                dpadValue ~= -1
                                and dpadValue ~= self.listenerDpadStartValues[con][dpad]
                                and dpadValue % 9000 == 0
                        then
                                self.listenerController = con
                                self.listenerButton = dpadValue / 9000
                                self.listenerButton = self.listenerButton < 3 and self.listenerButton + 1 or 0

                                self.listenerIsDpad = true
                                self.listenerInputMode = 1

                                anyButtonDown = true
                        end
                end

                for button = 0, ac.getJoystickButtonsCount(con) - 1 do
                        if ac.isJoystickButtonPressed(con, button) then
                                if self.listenerIsDpad then
                                        self.listenerModificators = { button }
                                        self.listenerControllerModificator = self.listenerController
                                elseif
                                        self.listenerButton ~= -1
                                        and (button ~= self.listenerButton)
                                        and button ~= self.listenerModificators[1]
                                then
                                        self.listenerModificators = { self.listenerButton }
                                        self.listenerControllerModificator = self.listenerController

                                        self.listenerButton = button
                                        self.listenerController = con
                                elseif self.listenerButton == -1 then
                                        self.listenerButton = button
                                        self.listenerController = con
                                end

                                self.listenerInputMode = 1

                                anyButtonDown = true
                        end
                end
        end

        ac.debug("list", anyButtonDown)

        if not anyButtonDown or #self.listenerModificators > 0 then return true end
end

function ControlButton:listenGamepadInputs()
        local anyButtonDown = false

        for con = 0, 7 do
                for buttonString, buttonID in pairs(ac.GamepadButton) do
                        if ac.isGamepadButtonPressed(con, buttonID) and buttonString ~= self.listenerButton then
                                self.listenerButton = gamepad.indexCodeList[ac.GamepadButton[buttonString]]

                                anyButtonDown = true

                                self.listenerInputMode = 2
                        end
                end
        end

        if not anyButtonDown then return true end

        return (self.listenerButton ~= -1)
end

function ControlButton:listenKeyboardInputs()
        local anyButtonDown = false

        for k, v in pairs(keys.indexHexList) do
                if
                        ac.isKeyDown(k)
                        and k ~= ui.KeyIndex.Control
                        and k ~= ui.KeyIndex.Menu
                        and k ~= ui.KeyIndex.Shift
                then
                        local modifiers = {}

                        if ac.isKeyDown(ui.KeyIndex.Control) then
                                table.insert(modifiers, tostring(ui.KeyIndex.Control))
                        end
                        if ac.isKeyDown(ui.KeyIndex.Menu) then table.insert(modifiers, tostring(ui.KeyIndex.Menu)) end
                        if ac.isKeyDown(ui.KeyIndex.Shift) then table.insert(modifiers, tostring(ui.KeyIndex.Shift)) end

                        if #modifiers > 0 then self.listenerModificators = modifiers end

                        self.listenerButton = v

                        self.listenerInputMode = 3

                        anyButtonDown = true
                end
        end

        if not anyButtonDown then return true end

        return (self.listenerButton ~= -1)
end

function ControlButton:assign()
        local released = {}

        if sim.inputMode == 0 then
                released = { self:listenControllerInputs(), false, self:listenKeyboardInputs() }
        elseif sim.inputMode == 1 then
                released = { self:listenControllerInputs(), self:listenGamepadInputs(), self:listenKeyboardInputs() }
        else
                released = { false, false, self:listenKeyboardInputs() }
        end

        if self.listenerInputMode == -1 or not released[self.listenerInputMode] then
                return false, self.listenerButton, self.listenerModificators
        end

        return (#self.listenerModificators > 0 or self.listenerButton ~= -1),
                self.listenerInputMode,
                self.listenerController,
                self.listenerButton,
                self.listenerControllerModificator,
                self.listenerModificators
end

function ControlButton:clearAssign()
        for con = 0, ac.getJoystickCount() - 1 do
                self.listenerDpadStartValues[con] = {}
                for dpad = 0, ac.getJoystickDpadsCount(con) - 1 do
                        self.listenerDpadStartValues[con][dpad] = ac.getJoystickDpadValue(con, dpad)
                end
        end

        self.listenerInputMode, self.listenerButton, self.listenerModificators, self.listenerController, self.listenerIsDpad =
                -1, -1, {}, -1, false
end

function ControlButton:save(inputMode)
        if self.listenerButton and self.listenerButton ~= -1 and self.listenerButton ~= "" then
                if self.listenerIsDpad then
                        configs.CONTROLS.ini:setAndSave(self.bind, "__CM_POV", 0)
                        configs.CONTROLS.ini:setAndSave(self.bind, "__CM_POV_DIR", self.listenerButton)
                        configs.CONTROLS.ini:setAndSave(self.bind, "BUTTON", -1)
                        configs.CONTROLS.ini:setAndSave(self.bind, "JOY", self.listenerController)
                else
                        configs.CONTROLS.ini:setAndSave(self.bind, inputModeStringKeys[inputMode], self.listenerButton)
                end

                if inputMode == 1 then
                        configs.CONTROLS.ini:setAndSave(self.bind, "JOY", self.listenerController)

                        if not self.listenerIsDpad then configs.CONTROLS.ini:setAndSave(self.bind, "__CM_POV", -1) end
                end

                if #self.listenerModificators > 0 then
                        configs.CONTROLS.ini:setAndSave(
                                self.bind,
                                inputModeStringKeys[inputMode] .. "_MODIFICATOR",
                                { self.listenerModificators }
                        )

                        if inputMode == 1 then
                                configs.CONTROLS.ini:setAndSave(
                                        self.bind,
                                        "JOY_MODIFICATOR",
                                        self.listenerControllerModificator
                                )
                        end
                elseif inputMode ~= 2 then
                        configs.CONTROLS.ini:setAndSave(self.bind, inputModeStringKeys[inputMode] .. "_MODIFICATOR", -1)
                end

                self:clearAssign()

                ac.reloadControlSettings()
                return true
        end

        self:clearAssign()
end

function ControlButton:unbind(inputMode)
        configs.CONTROLS.ini:setAndSave(self.bind, inputModeStringKeys[inputMode], -1)

        if inputMode == 1 then
                configs.CONTROLS.ini:setAndSave(self.bind, "JOY", -1)
                configs.CONTROLS.ini:setAndSave(self.bind, "JOY_MODIFICATOR", -1)
                configs.CONTROLS.ini:setAndSave(self.bind, "__CM_POV", -1)
                configs.CONTROLS.ini:setAndSave(self.bind, "__CM_POV_DIR", -1)
        elseif inputMode == 2 then
                return
        end

        configs.CONTROLS.ini:setAndSave(self.bind, inputModeStringKeys[inputMode] .. "_MODIFICATOR", -1)
end

return ControlButton
