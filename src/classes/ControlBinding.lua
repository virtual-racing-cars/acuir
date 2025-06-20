local ControlAxis = require("src.classes.ControlAxis")
local ControlButton = require("src.classes.ControlButton")
local configs = require("configs")
local settings = require("settings")

local ControlBinding = class("ControlBinding")

local bindSectionKeyDefaults = {
        NAME = "",
        TAB = "Generic",
        ORDER = -1,
        REQUIRED = -1,
        ACTIVATION = -1,
        AXIS = -1,
        AXIS_LABEL = "",
        AXIS_CENTERED = -1,
        POS = -1,
        DN = "",
        UP = "",
        DN_LABEL = "Decrease",
        UP_LABEL = "Increase",
        POS_LABEL_OFFSET = 0,
        POS_LABEL = "Position",
        POS_UNIT = "",
        HOLD_MODE = -1,
        EXT_PHYSICS = -1,
        LUA = -1,
        WHEEL = 1,
        X360 = 1,
        KEYBOARD = 1,
        HELP = "",
}

local function controlsINIDefaults(ini, bind, key, default)
        if not ini.sections[bind][key] then ini.sections[bind][key] = ini:get(bind, key, default) end
        if type(ini.sections[bind][key]) == "table" then ini.sections[bind][key] = ini.sections[bind][key][1] end
end

function ControlBinding:initialize(bind, ini)
        if bind == nil or bind == "" then return nil end

        for key, value in pairs(bindSectionKeyDefaults) do
                controlsINIDefaults(ini, bind, key, value)
        end

        local bindSection = ini.sections[bind]

        if tonumber(bindSection[configs.CONTROLS.data.HEADER.INPUT_METHOD]) < 1 then return nil end

        self.bind = bind
        self.name = bindSection.NAME ~= "" and bindSection.NAME or self.bind
        self.tab = bindSection.TAB
        self.order = tonumber(bindSection.ORDER)
        self.help = bindSection.HELP or ""

        self.isLuaControlled = tonumber(bindSection.LUA) > 0
        self.isExtendedPhysics = tonumber(bindSection.EXT_PHYSICS) > 0
        self.isAxis = tonumber(bindSection.AXIS) > 0
        self.isActivationBind = tonumber(bindSection.ACTIVATION) > 0
        self.isSequentialBind = bindSection.DN ~= "" and bindSection.UP ~= ""
        self.isMultiPositionSwitchBind = tonumber(bindSection.POS) > 0
        self.buttons = {}

        if self.isAxis then
                self:bindAxis(bindSection.AXIS_LABEL, tonumber(bindSection.AXIS_CENTERED) > 0)
                return
        end

        if self.isActivationBind then
                self:bindActivation(bindSection.ACTIVATION_LABEL, tonumber(bindSection.HOLD_MODE) > 0)
                return self
        end

        if self.isSequentialBind then
                self:bindSequential(bind, bindSection.DN, bindSection.DN_LABEL, bindSection.UP, bindSection.UP_LABEL)
        end

        if self.isMultiPositionSwitchBind then
                self:bindMultiPositionSwitch(

                        bind,
                        tonumber(bindSection.POS),
                        tonumber(bindSection.POS_LABEL_OFFSET),
                        bindSection.POS_LABEL,
                        bindSection.POS_UNIT
                )
        end
end

function ControlBinding:bindAxis(label, centered)
        if not string.startsWith(self.bind, "__EXT_LIGHT_") and self.isLuaControlled then
                self.bind = "__EXT_CAR_" .. self.bind
        end

        self.axisLabel = label and label or "Axis"
        self.button = ControlAxis(self.bind, centered)

        table.insert(self.buttons, self.button)
end

function ControlBinding:bindActivation(label, holdMode)
        if not string.startsWith(self.bind, "__EXT_LIGHT_") and self.isLuaControlled then
                self.bind = "__EXT_CAR_" .. self.bind
        end

        self.activationLabel = label and label or "Activate"
        self.button = ControlButton(self.bind, { hold = holdMode and holdMode or nil })

        table.insert(self.buttons, self.button)
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

        self.buttonDown = ControlButton(self.bindDown)
        self.buttonUp = ControlButton(self.bindUp)

        table.insert(self.buttons, self.buttonDown)
        table.insert(self.buttons, self.buttonUp)

        self.buttonDownLabel = not isempty(downLabel) and downLabel or "Decrease"
        self.buttonUpLabel = not isempty(upLabel) and upLabel or "Increase"
end

function ControlBinding:bindMultiPositionSwitch(bind, switchCount, switchIndexOffset, switchLabel, switchLabelUnit)
        self.multiPositionSwitchCount = switchCount
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
