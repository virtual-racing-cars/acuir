local ControlButton = require("src.classes.ControlButton")
local settings = require("settings")

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

function ControlBinding:initialize(bind, ini, controls)
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
        self.buttons = {}

        if self.isActivationBind then
                self:bindActivation(controls, activationLabel, activationHoldMode)
                return self
        end

        if self.isSequentialBind then
                self:bindSequential(
                        controls,
                        bind,
                        sequentialDownBind,
                        sequentialDownLabel,
                        sequentialUpBind,
                        sequentialUpLabel
                )
        end

        if self.isMultiPositionSwitchBind then
                self:bindMultiPositionSwitch(
                        controls,
                        bind,
                        multiPositionSwitchCount,
                        multiPositionSwitchIndexOffset,
                        multiPositionSwitchLabel,
                        multiPositionSwitchLabelUnit
                )
        end
end

function ControlBinding:bindActivation(controls, label, holdMode)
        if not string.startsWith(self.bind, "__EXT_LIGHT_") and self.isLuaControlled then
                self.bind = "__EXT_CAR_" .. self.bind
        end

        self.activationLabel = label and label or "Activate"
        self.button = ControlButton(self.bind, { hold = holdMode and holdMode or nil })

        table.insert(self.buttons, self.button)
end

function ControlBinding:bindSequential(controls, bind, downBind, downLabel, upBind, upLabel)
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

        self.buttonDown = ControlButton(self.bindDown)
        self.buttonUp = ControlButton(self.bindUp)

        table.insert(self.buttons, self.buttonDown)
        table.insert(self.buttons, self.buttonUp)

        self.buttonDownLabel = not isempty(downLabel) and downLabel or "Decrease"
        self.buttonUpLabel = not isempty(upLabel) and upLabel or "Increase"
end

function ControlBinding:bindMultiPositionSwitch(
        controls,
        bind,
        switchCount,
        switchIndexOffset,
        switchLabel,
        switchLabelUnit
)
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
                        self.buttonPosition[i] = ControlButton(self.bindMps[i])
                else
                        self.bindMps[i] = bind .. "_" .. i
                        self.buttonPosition[i] = ControlButton(self.bindMps[i])
                end

                table.insert(self.buttons, self.buttonPosition[i])

                self.buttonPositionLabel[i] = self.buttonPositionLabelExplicit and switchLabel[i] .. switchLabelUnit
                        or (
                                (not isempty(switchLabel) and switchLabel or "Position")
                                .. " "
                                .. i + self.multiPositionSwitchIndex
                                .. " "
                                .. switchLabelUnit
                        )
        end
end

return ControlBinding
