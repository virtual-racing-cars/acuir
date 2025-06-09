local controllers = require("controllers")
local gamepad = require("gamepad")
local keys = require("keys")

local controlsINI = ac.INIConfig.load(ac.getFolder(ac.FolderID.Cfg) .. "\\controls.ini")
ac.onControlSettingsChanged(
        function() controlsINI = ac.INIConfig.load(ac.getFolder(ac.FolderID.Cfg) .. "\\controls.ini") end
)

local ControlButton = class("ControlButton")

local inputModeStringKeys = {
        "BUTTON",
        "BUTTON",
        "KEY",
}

local function buttonString(button, buttonMod)
        if button == -1 then return "" end
        if buttonMod == -1 then return string.format("Button %s", button) end

        return string.format("Button %s + Button %s", button, buttonMod)
end

local function gamepadString(button, buttonMod)
        if not button or button == -1 or button == "" then return "" end
        if not buttonMod or buttonMod == -1 or buttonMod == "" then return string.format("%s", button) end

        return string.format("%s + %s", button, buttonMod)
end

local function keybindString(key, keyMod)
        if not key or key == -1 then return "" end
        if not keyMod or keyMod == -1 then return string.format("%s", key) end

        return string.format("%s + %s", keyMod, key)
end

function ControlButton:initialize(bind, defaults)
        self.bind = bind
        self.defaults = defaults
        self._button = ac.ControlButton(self.bind, self.defaults)
        self.listenerButton = -1
        self.listenerModificator = -1
end

function ControlButton:disabled() return self._button:disabled() end

function ControlButton:setDisabled(disabled) self._button:setDisabled(disabled) end

function ControlButton:boundToController()
        local con = controlsINI:get(self.bind, "JOY", -1)
        local button = controlsINI:get(self.bind, "BUTTON", -1)
        local buttonMod = controlsINI:get(self.bind, "BUTTON_MODIFICATOR", -1)

        if con >= 0 then
                return controllers[con].CON, buttonString(button, buttonMod)
        else
                return "", "Click to Assign"
        end
end

function ControlButton:boundToGamepad()
        local button = controlsINI:get(self.bind, "XBOXBUTTON", "")
        local buttonMod = controlsINI:get(self.bind, "XBOXBUTTON_MODIFICATOR", "")

        if button and button ~= "-1" and button ~= "" then
                return "Gamepad", gamepadString(gamepad.codeStringList[button], gamepad.codeStringList[buttonMod])
        else
                return "", "Click to Assign"
        end
end

function ControlButton:boundToKey()
        local key = controlsINI:get(self.bind, "KEY", -1)
        local keyMod = controlsINI:get(self.bind, "KEY_MODIFICATOR", -1)

        if key and key ~= -1 and key ~= "" then
                return "Keyboard", keybindString(keys.indexStringList[key], keys.indexStringList[keyMod])
        else
                return "", "Click to Assign"
        end
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
                        if ac.isJoystickButtonPressed(con, button) and button ~= self.listenerButton then
                                if self.listenerButton ~= -1 then
                                        self.listenerModificator = self.listenerButton
                                        self.listenerButton = button
                                else
                                        self.listenerButton = button
                                end

                                anyButtonDown = true
                        end
                end
        end

        if not anyButtonDown then return true end

        return (self.listenerModificator ~= -1)
end

function ControlButton:listenGamepadInputs()
        local anyButtonDown = false

        for con = 0, 7 do
                for buttonString, buttonID in pairs(ac.GamepadButton) do
                        if ac.isGamepadButtonPressed(con, buttonID) and buttonString ~= self.listenerButton then
                                if self.listenerButton ~= -1 then
                                        self.listenerModificator = self.listenerButton
                                        self.listenerButton = buttonString
                                else
                                        self.listenerButton = buttonString
                                end

                                ac.log(con, buttonString)

                                anyButtonDown = true
                        end
                end
        end

        if not anyButtonDown then return true end

        return (self.listenerModificator ~= -1)
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
                        if ui.hotkeyCtrl() then
                                self.listenerModificator = ui.KeyIndex.Control
                        elseif ui.hotkeyAlt() then
                                self.listenerModificator = ui.KeyIndex.Menu
                        elseif ui.hotkeyShift() then
                                self.listenerModificator = ui.KeyIndex.Shift
                        end

                        self.listenerButton = v

                        anyButtonDown = true
                end
        end

        if not anyButtonDown then return true end

        return (self.listenerButton ~= -1)
end

ControlButton.listeners = {
        ControlButton.listenControllerInputs,
        ControlButton.listenControllerInputs,
        ControlButton.listenKeyboardInputs,
}

function ControlButton:assignBind(inputMode)
        local released = self.listeners[inputMode](self)

        if not released then return false, self.listenerButton, self.listenerModificator end

        return (self.listenerModificator ~= -1 or self.listenerButton ~= -1),
                self.listenerButton,
                self.listenerModificator
end

function ControlButton:clearAssign()
        self.listenerButton, self.listenerModificator = -1, -1
end

function ControlButton:saveBind(inputMode)
        if self.listenerButton and self.listenerButton ~= -1 and self.listenerButton ~= "" then
                controlsINI:setAndSave(self.bind, inputModeStringKeys[inputMode], self.listenerButton)

                if self.listenerModificator and self.listenerModificator ~= -1 and self.listenerModificator ~= "" then
                        controlsINI:setAndSave(
                                self.bind,
                                inputModeStringKeys[inputMode] .. "_MODIFICATOR",
                                self.listenerModificator
                        )
                else
                        controlsINI:setAndSave(self.bind, inputModeStringKeys[inputMode] .. "_MODIFICATOR", -1)
                end

                self:clearAssign()
                ac.reloadControlSettings()
                return true
        end

        self:clearAssign()
end

function ControlButton:unbind(inputMode)
        controlsINI:setAndSave(self.bind, inputModeStringKeys[inputMode], -1)
        controlsINI:setAndSave(self.bind, inputModeStringKeys[inputMode] .. "_MODIFICATOR", -1)
end

return ControlButton
