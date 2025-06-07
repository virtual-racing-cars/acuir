local controllers = require("controllers")
local keys = require("keys")
local settings = require("settings")
local controlsINI = ac.INIConfig.controlsConfig()

local ControlBinding = class("ControlBinding")

local bindSectionKeyDefaults = {
        NAME = "",
        TAB = "Generic",
        ORDER = 0,
        REQUIRED = 0,
        ACTIVATION = 0,
        POS = 0,
        DN = 0,
        UP = 0,
        DN_LABEL = "Decrease",
        UP_LABEL = "Increase",
        POS_LABEL_OFFSET = 0,
        POS_LABEL = "Position",
        POS_UNIT = "",
        HOLD_MODE = 0,
        EXT_PHYSICS = 0,
        LUA = 0,
        HELP = "",
}

local function controlsINIDefaults(bind, bindSection, key, default, isCMBind)
        if not bindSection[key] or bindSection[key][1] == "" or bindSection[key][1] == nil then
                local initialValue = bindSection[key] and bindSection[key][1] or nil

                if key == "NAME" then default = bind end

                bindSection[key] = { default }

                if initialValue ~= "" and not isCMBind and settings.General.developerMode then
                        ac.log("[" .. bind .. "] Section is missing " .. key .. " key: Default value: " .. default)
                end
        end

        bindSection[key] = bindSection[key][1]
end

function ControlBinding:initialize(bind, ini)
        local bindSection = ini.sections[bind]

        for key, value in pairs(bindSectionKeyDefaults) do
                controlsINIDefaults(bind, bindSection, key, value)
        end

        local name = bindSection.NAME
        local tab = bindSection.TAB
        local order = tonumber(bindSection.ORDER)
        local isLuaControlled = tonumber(bindSection.LUA) == 1
        local isExtendedPhysics = tonumber(bindSection.EXT_PHYSICS) == 1
        local helpString = bindSection.HELP
        local isActivationBind = tonumber(bindSection.ACTIVATION) == 1
        local activationLabel = bindSection.ACTIVATION_LABEL
        local activationHoldMode = tonumber(bindSection.HOLD_MODE) == 1
        local isSequentialBind = tonumber(bindSection.DN) ~= 0 and tonumber(bindSection.UP) ~= 0
        local sequentialDownBind = bindSection.DN
        local sequentialDownLabel = bindSection.DN_LABEL
        local sequentialUpBind = bindSection.UP
        local sequentialUpLabel = bindSection.UP_LABEL
        local isMultiPositionSwitchBind = tonumber(bindSection.POS) > 0
        local multiPositionSwitchIndexOffset = tonumber(bindSection.POS_LABEL_OFFSET)
        local multiPositionSwitchLabel = bindSection.POS_LABEL
        local multiPositionSwitchLabelUnit = bindSection.POS_UNIT
        local multiPositionSwitchCount = tonumber(bindSection.POS)

        self.bind = bind

        if self.bind == nil or self.bind == "" then return nil end

        self.name = name and name or self.bind
        self.tab = tab and tab or -1
        self.order = order and order or -1
        self.isActivationBind = isActivationBind and isActivationBind or false
        self.isSequentialBind = isSequentialBind and isSequentialBind or false
        self.isMultiPositionSwitchBind = isMultiPositionSwitchBind and isMultiPositionSwitchBind or false
        self.isLuaControlled = isLuaControlled and isLuaControlled or false
        self.isExtendedPhysics = isExtendedPhysics and isExtendedPhysics or false
        self.help = helpString and helpString or ""

        if self.isActivationBind then
                self:bindActivation(activationLabel, activationHoldMode)
                return self
        end

        if self.isSequentialBind then
                self:bindSequential(bind, sequentialDownBind, sequentialDownLabel, sequentialUpBind, sequentialUpLabel)
        end

        if self.isMultiPositionSwitchBind then
                self:bindMultiPositionSwitch(
                        bind,
                        multiPositionSwitchCount,
                        multiPositionSwitchIndexOffset,
                        multiPositionSwitchLabel,
                        multiPositionSwitchLabelUnit
                )
        end
end

function ControlBinding:bindActivation(label, holdMode)
        if not string.startsWith(self.bind, "__EXT_LIGHT_") and self.isLuaControlled then
                self.bind = "__EXT_CAR_" .. self.bind
        end

        self.activationLabel = label and label or "Activate"
        self.button = ac.ControlButton(self.bind, { hold = holdMode and holdMode or nil })
end

function ControlBinding:bindSequential(bind, downBind, downLabel, upBind, upLabel)
        if string.startsWith(bind, "__EXT_LIGHT_") then
                self.bindDown = "__EXT_LIGHT_" .. downBind
                self.bindUp = "__EXT_LIGHT_" .. upBind
        elseif self.isLuaControlled then
                self.bindDown = "__EXT_CAR_" .. bind .. downBind
                self.bindUp = "__EXT_CAR_" .. bind .. upBind
        else
                self.bindDown = bind .. downBind
                self.bindUp = bind .. upBind
        end

        self.buttonDown = ac.ControlButton(self.bindDown)
        self.buttonUp = ac.ControlButton(self.bindUp)

        self.buttonDownLabel = not isempty(downLabel) and downLabel or "Decrease"
        self.buttonUpLabel = not isempty(upLabel) and upLabel or "Increase"
end

function ControlBinding:bindMultiPositionSwitch(bind, switchCount, switchIndexOffset, switchLabel, switchLabelUnit)
        self.mpsToggle = self.buttonUp:disabled() and self.buttonDown:disabled()
        self.multiPositionSwitchCount = switchCount and switchCount or 0
        self.multiPositionSwitchIndex = switchIndexOffset

        self.buttonPosition = {}
        self.buttonPositionLabel = {}
        self.buttonPositionLabelExplicit = false

        if string.find(switchLabel, ",") then
                switchLabel = string.split(switchLabel, ",")
                self.buttonPositionLabelExplicit = true
        end

        self.bindMps = {}
        for i = 1, self.multiPositionSwitchCount do
                if self.isLuaControlled then
                        self.bindMps[i] = "__EXT_CAR_" .. bind .. "_" .. i
                        self.buttonPosition[i] = ac.ControlButton(self.bindMps[i])
                else
                        self.bindMps[i] = bind .. "_" .. i
                        self.buttonPosition[i] = ac.ControlButton(self.bindMps[i])
                end

                if self.mpsToggle then
                        self.buttonPosition[i]:setDisabled(false)
                else
                        self.buttonPosition[i]:setDisabled(true)
                end

                self.buttonPositionLabel[i] = self.buttonPositionLabelExplicit and switchLabel[i] .. switchLabelUnit
                        or (
                                (not isempty(switchLabel) and switchLabel or "Position")
                                .. " "
                                .. i + self.multiPositionSwitchIndex
                                .. " "
                                .. switchLabelUnit
                        )
        end

        if self.mpsToggle then
                self.buttonDown:setDisabled(true)
                self.buttonUp:setDisabled(true)
        else
                self.buttonDown:setDisabled(false)
                self.buttonUp:setDisabled(false)
        end
end

function ControlBinding:toggleMPS()
        self.mpsToggle = not self.mpsToggle

        for i = 1, self.multiPositionSwitchCount do
                if self.mpsToggle then
                        self.buttonPosition[i]:setDisabled(false)
                else
                        self.buttonPosition[i]:setDisabled(true)
                end
        end

        if self.mpsToggle then
                self.buttonDown:setDisabled(true)
                self.buttonUp:setDisabled(true)
        else
                self.buttonDown:setDisabled(false)
                self.buttonUp:setDisabled(false)
        end
end

local function buttonString(button, buttonMod)
        if button == -1 then return "" end
        if buttonMod == -1 then return string.format("Button %s", button) end

        return string.format("Button %s + Button %s", button, buttonMod)
end

local function keybindString(key, keyMod)
        if not key or key == -1 then return "" end
        if not keyMod or keyMod == -1 then return string.format("%s", key) end

        return string.format("%s + %s", key, keyMod)
end

function ControlBinding:boundToController()
        local con = controlsINI:get(self.bind, "JOY", -1)
        local button = controlsINI:get(self.bind, "BUTTON", -1)
        local buttonMod = controlsINI:get(self.bind, "BUTTON_MODIFICATOR", -1)

        if con >= 0 then
                return controllers[con].CON, buttonString(button, buttonMod)
        else
                return "", "Click to Assign"
        end
end

function ControlBinding:boundToGamepad()
        local con = controlsINI:get(self.bind, "XBOXBUTTON", "")

        if con ~= "" then
                return "Gamepad", con
        else
                return "", "Click to Assign"
        end
end

function ControlBinding:boundToKey()
        local key = controlsINI:get(self.bind, "KEY", -1)
        local keyMod = controlsINI:get(self.bind, "KEY_MODIFICATOR", -1)

        if key ~= -1 then
                return "Keyboard", keybindString(keys.indexStringList[key], keys.indexStringList[keyMod])
        else
                return "", "Click to Assign"
        end
end

function ControlBinding:boundTo() return self:boundToController(), self:boundToGamepad(), self:boundToKey() end

function ControlBinding:assignControllerBind()
        local button1 = -1
        local button2 = -1

        for i = 0, ac.getJoystickCount() - 1 do
                for ii = 0, ac.getJoystickButtonsCount(i) do
                        if ac.isJoystickButtonPressed(i, ii) then
                                if button1 == -1 then
                                        button1 = ii
                                elseif button2 == -1 then
                                        button2 = ii

                                        return button1, button2
                                end
                        end
                end
        end

        return button1, button2
end

function ControlBinding:assignGamepadBind()
        local button1 = -1
        local button2 = -1

        for i = 0, 7 do
                for k, ii in pairs(ac.GamepadButton) do
                        if ac.isGamepadButtonPressed(i, ii) then
                                if button1 == -1 then
                                        button1 = k
                                elseif button2 == -1 then
                                        button2 = k

                                        return button1, button2
                                end
                        end
                end
        end

        return button1, button2
end

function ControlBinding:assignKeyboardBind()
        local firstKeyPressed, secondKeyPressed = -1, -1

        for k, v in pairs(keys.indexHexList) do
                if ac.isKeyPressed(k) then firstKeyPressed = v end
        end

        return firstKeyPressed, secondKeyPressed
end

function ControlBinding:assign() end

function isempty(string) return string == nil or string == "" end

function __genOrderedIndex(t)
        local orderedIndex = {}
        for key in pairs(t) do
                table.insert(orderedIndex, key)
        end
        table.sort(orderedIndex)
        return orderedIndex
end

function orderedNext(t, state)
        local key = nil
        if state == nil then
                t.__orderedIndex = __genOrderedIndex(t)
                key = t.__orderedIndex[1]
        else
                for i = 1, #t.__orderedIndex do
                        if t.__orderedIndex[i] == state then key = t.__orderedIndex[i + 1] end
                end
        end

        if key then return key, t[key] end

        t.__orderedIndex = nil
end

function orderedPairs(t) return orderedNext, t, nil end

return ControlBinding
