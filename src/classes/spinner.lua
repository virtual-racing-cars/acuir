local car = ac.getCar(0)

SPINNER = class("SPINNER")

function SPINNER:initialize(id, tab, name, min, max, step, multiplier, format, xPos, yPos, uid)
	self.id = id
	self.tab = tab
	self.name = name
	self.min = min
	self.max = max
	self.step = step
	self.multiplier = multiplier
	self.value = ac.getSetupSpinnerValue(self.id)
	self.default = self.value
	self.format = format
	self.xPos = xPos
	self.yPos = yPos
	self.help = setupINI:get(self.id, "HELP", "")
	self.uid = uid
	self.idPairs = { self.id }

	self._value = self.value

	self.itemSet = false
	self.itemActive = false

	self.buttonHeldTimer = { Left = 0, Right = 0 }
end

local buttonSize = vec2(32 * UI_SCALE_Y / 100, 32 * UI_SCALE_Y / 100)
function SPINNER:button(direction)
	if ui.arrowButtonAdvanced("##" .. direction .. self.id, direction, buttonSize, ui.ButtonFlags.PressedOnClick) then
		self.value = direction == "Left" and (self.value - self.step) or (self.value + self.step)
		self.buttonHeldTimer[direction] = os.clock() + 0.5

		return true
	elseif self.buttonHeldTimer[direction] < os.clock() and ui.itemActive() and ui.mouseDown(ui.MouseButton.Left) then
		self.value = direction == "Left" and (self.value - self.step) or (self.value + self.step)
		self.buttonHeldTimer[direction] = os.clock() + 0.1

		return true
	end

	return false
end

function SPINNER:helpWindow()
	if self.help ~= "NULL" and self.help ~= "" then
		local toolWindowSize = vec2(400, 400)
		setCursorX(1280)
		setCursorY(110)
		ui.transparentWindow(
			"##help" .. self.id,
			ui.getCursor(),
			vec2(400, 560 * UI_SCALE_Y / 100),
			true,
			false,
			function()
				ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), rgbm(0, 0, 0, 0.75))
				ui.drawRect(vec2(0, 0), ui.availableSpace(), rgbm(1, 1, 1, 0.25), 0, ui.CornerFlags.None)

				ui.bringWindowToFront()
				setCursorX(0)
				ui.pushDWriteFont("Default;Weight=Bold")
				ui.dwriteTextAligned(
					self.name,
					20,
					ui.Alignment.Center,
					ui.Alignment.Start,
					toolWindowSize,
					false,
					rgbm.colors.white
				)
				ui.popDWriteFont()

				ui.drawLine(vec2(15, 40), vec2(385, 40), rgbm.colors.white)

				setCursorX(10)
				setCursorY(50)

				local helpSections = string.split(self.help, "\\n\\n")

				for i in ipairs(helpSections) do
					ui.dwriteTextWrapped(helpSections[i], 16, rgbm.colors.white)
				end
			end
		)
	end
end

function SPINNER:slider()
	if self.id == "COMPOUND" then
		self.format = ac.getTyresLongName(0, car.compoundIndex)
	end

	ui.setNextItemWidth(300 * UI_SCALE_X / 100)
	local value, changed = ui.slider(
		"##" .. self.id .. self.name,
		self._value * self.multiplier,
		self.min * self.multiplier,
		self.max * self.multiplier,
		self.format,
		1
	)

	value = value / self.multiplier

	if ui.itemActive() then
		self.itemActive = true
		self._value = value
	elseif self.value ~= self._value then
		changed = true
		self.value = self._value
	else
		self.value = ac.getSetupSpinnerValue(self.id)
		self._value = self.value
	end

	if ui.itemHovered(ui.HoveredFlags.None) then
		if ui.mouseWheel() ~= 0 then
			changed = true
			self.value = ui.mouseWheel() < 0 and (self.value - self.step) or (self.value + self.step)
		end

		self:helpWindow()
	end

	return changed
end

function SPINNER:get()
	if not self.itemActive then
		self.value = ac.getSetupSpinnerValue(self.id)
	end
end

function SPINNER:set()
	if self.itemSet then
		return
	end

	self.value = math.clamp(math.floor(self.value / self.step + 0.5) * self.step, self.min, self.max)
	self._value = self.value

	for _key, id in pairs(self.idPairs) do
		ac.setSetupSpinnerValue(id, self.value)

		ui.toast(ui.Icons.Info, id .. " setup value set to: " .. self.value)
	end

	self.itemSet = true
end

function SPINNER:run(drawSpinner)
	if self.name == "" or (self.id == "MGUK_DELIVERY" and #self.idPairs > 1) then
		return
	end

	self.itemSet = false
	self:get()
	self.itemActive = false

	if not drawSpinner then
		if self.value ~= self._value then
			self:set()
		end
		return
	end

	setCursorX(self.xPos * 400 + 14)
	setCursorY(self.yPos * 50 + 85)
	if self:button("Left") then
		self:set()
	end
	if ui.itemHovered(ui.HoveredFlags.None) then
		self:helpWindow()
	end

	ui.sameLine()
	if self:slider() and not self.itemActive then
		self:set()
	end

	ui.sameLine()
	if self:button("Right") then
		self:set()
	end
	if ui.itemHovered(ui.HoveredFlags.None) then
		self:helpWindow()
	end
end
