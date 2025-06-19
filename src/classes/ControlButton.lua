local configs = require("configs")
local controllers = require("controllers")
local gamepad = require("gamepad")
local keys = require("keys")

local ControlButton = class("ControlButton")

local inputModeStringKeys = {
        "BUTTON",
        "XBOXBUTTON",
        "KEY",
}

local function buttonString(button, buttonMod)
        if button == 0 then return "" end
        if buttonMod == 0 then return string.format("Button %s", button) end

        return string.format("Button %s + Button %s", buttonMod, button)
end

local function gamepadString(button, buttonMod)
        if not button or button == -1 or button == "" then return "" end
        if not buttonMod or buttonMod == -1 or buttonMod == "" then return string.format("%s", button) end

        return string.format("%s + %s", button, buttonMod)
end

local function keybindString(modifierKeys, primaryKey)
        local deviceString, bindingString = "", ""

        for _, modKey in ipairs(modifierKeys) do
                if modKey ~= nil and modKey ~= -1 and modKey ~= "-1" and modKey ~= "" then
                        bindingString = bindingString .. keys.indexStringList[tonumber(modKey)] .. "+"
                end
        end

        if primaryKey ~= nil and primaryKey ~= -1 and primaryKey ~= "-1" and primaryKey ~= "" then
                bindingString = bindingString .. keys:indexToString(primaryKey)
                deviceString = "Keyboard"
        else
                bindingString = ""
        end

        return deviceString, bindingString
end

function ControlButton:initialize(bind, defaults)
        self.bind = bind
        self.defaults = defaults
        self._button = ac.ControlButton(self.bind, self.defaults)
        self.listenerButton = -1
        self.listenerModificators = {}
        self.listenerController = -1
        self.listenerControllerModificator = -1
        self.listenerInputMode = -1
        self.inputModeBound = { false, false, false }
end

function ControlButton:disabled() return self._button:disabled() end

function ControlButton:setDisabled(disabled) self._button:setDisabled(disabled) end

function ControlButton:boundToController()
        local con = configs.CONTROLS.ini:get(self.bind, "JOY", -1)
        local button = configs.CONTROLS.ini:get(self.bind, "BUTTON", -1)
        local buttonMod = configs.CONTROLS.ini:get(self.bind, "BUTTON_MODIFICATOR", -1)

        if con >= 0 and button ~= "" and tonumber(button) ~= -1 then
                local controllerString = "Joy %s" % con

                if controllers[con] then controllerString = controllers[con].CON end

                self.inputModeBound[1] = true

                if buttonMod == 0 then return controllerString, string.format("Button %s", button + 1) end

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
        local primaryKey = configs.CONTROLS.ini:get(self.bind, "KEY", -1)
        local modifierKeys = configs.CONTROLS.ini:get(self.bind, "KEY_MODIFICATOR", {})

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
                for button = 0, ac.getJoystickButtonsCount(con) - 1 do
                        if ac.isJoystickButtonPressed(con, button) then
                                if
                                        self.listenerButton ~= -1
                                        and button ~= self.listenerButton
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

function ControlButton:assignBind(inputMode)
        local released = { self:listenControllerInputs(), self:listenGamepadInputs(), self:listenKeyboardInputs() }

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
        self.listenerInputMode, self.listenerButton, self.listenerModificators, self.listenerController = -1, -1, {}, -1
end

function ControlButton:saveBind(inputMode)
        if self.listenerButton and self.listenerButton ~= -1 and self.listenerButton ~= "" then
                configs.CONTROLS.ini:setAndSave(self.bind, inputModeStringKeys[inputMode], self.listenerButton)

                if inputMode == 1 then configs.CONTROLS.ini:setAndSave(self.bind, "JOY", self.listenerController) end

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
        elseif inputMode == 2 then
                return
        end

        configs.CONTROLS.ini:setAndSave(self.bind, inputModeStringKeys[inputMode] .. "_MODIFICATOR", -1)
end

return ControlButton
