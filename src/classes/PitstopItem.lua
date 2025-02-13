local sim = ac.getSim()

local function getPitstopSpinnerValue(pitstopSpinnerIndex, preset)
        return ac.getPitstopSpinners()[pitstopSpinnerIndex].values[preset + 1]
end

local function setPitstopSpinnerValue(pitstopSpinnerIndex, value, preset)
        local name = ac.getPitstopSpinners()[pitstopSpinnerIndex].name
        ac.setPitstopSpinnerValue(name, value, preset)
end

PitstopItem = class("PitstopItem")

function PitstopItem:initialize(
        id,
        index,
        preset,
        name,
        min,
        max,
        step,
        multiplier,
        items,
        format,
        xPos,
        yPos,
        independentSpinner,
        default,
        fixed
)
        self.id = id
        self.index = index
        self.preset = preset
        self.name = name
        self.min = min
        self.max = max
        self.step = step
        self.multiplier = multiplier
        self.value = default and default or getPitstopSpinnerValue(self.id, self.preset)
        self.default = self.value
        self.items = items
        self.format = format
        self.xPos = xPos
        self.yPos = yPos
        self.help = ""
        self.fixed = fixed and true or false

        if self.fixed then
                self.min = self.value
                self.max = self.value
        end

        if self.min == self.max then self.fixed = true end

        self.child = false
        self.independentSpinner = independentSpinner and true or false

        self.mirrored = false
        self.mirrorAvailable = false
        self.mirrorIndex = nil

        if string.find(self.id, "LF") or string.find(self.id, "LR") then self.mirrorIndex = self.index + 1 end

        if self.mirrorIndex ~= nil and ac.getPitstopSpinners()[self.mirrorIndex].value then
                self.mirrored = true
                self.mirrorAvailable = true
        end

        self.itemActive = false

        self.buttonHeldTimer = { [-1] = 0, [0] = 0, [1] = 0 }
        self.buttonHeldStart = 0

        self.helpWindowShow = false
end

function PitstopItem:getValue()
        if self.independentSpinner then
                self.value = sim.currentQuickPitPreset + 1
                return
        end

        if self.mirrored then
                self.value = getPitstopSpinnerValue(self.index + 1, self.preset)
        else
                self.value = getPitstopSpinnerValue(self.index, self.preset)
        end
end

function PitstopItem:setValue(value)
        local changed = self.value ~= value

        if self.index == -1 then
                self.value = value
                ac.setCurrentQuickPitPreset(self.value - 1)
        else
                self.value = value
                setPitstopSpinnerValue(self.index, self.value, self.preset)
        end

        if self.mirrored then self:mirror() end

        return changed
end

function PitstopItem:resetValue()
        if self.value == self.default then
                return false
        else
                self:setValue(self.default)
                return true
        end
end

function PitstopItem:toggleMirror() self.mirrored = not self.mirrored end

function PitstopItem:mirror()
        if not self.mirrorIndex then return end

        setPitstopSpinnerValue(self.mirrorIndex, self.value, self.preset)
end

function PitstopItem:run()
        if self.name == "" or self.child then return end

        self:getValue()
        self.helpWindowShow = false
end
