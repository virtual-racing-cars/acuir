local max = math.max

local setupPageFontSize = { -20, 0, ui.Font.Title, 0.75 }
if UI_SCALE_Y < 75 then
	setupPageFontSize = { 14, 44, ui.Font.Tiny, 1 }
elseif UI_SCALE_Y < 100 then
	setupPageFontSize = { 0, 10, ui.Font.Small, 1 }
end

local acHelpTags = {}

local acHelpTagFile = io.open(ac.getFolder(ac.FolderID.Root) .. "\\system\\locales\\setup\\en.tag", "r")

local currentSection = ""
for line in acHelpTagFile:lines() do
	if string.startsWith(line, "[") then
		currentSection = string.replace(string.replace(line, "[", ""), "]", "")
		acHelpTags[currentSection] = ""
	else
		acHelpTags[currentSection] = acHelpTags[currentSection] .. line .. "\n"
	end
end

SPINNER = class("SPINNER")

function SPINNER:initialize(
	id,
	tab,
	name,
	min,
	max,
	step,
	multiplier,
	items,
	format,
	xPos,
	yPos,
	uid,
	independentSpinner,
	zeroDefault
)
	self.id = id
	self.tab = tab
	self.name = name
	self.min = min
	self.max = max
	self.step = step
	self.multiplier = multiplier
	self.value = zeroDefault and 0 or ac.getSetupSpinnerValue(self.id)
	self.default = self.value
	self.items = items
	self.format = format
	self.xPos = xPos
	self.yPos = yPos
	self.help = setupINI:get(self.id, "HELP", "")

	if string.startsWith(self.help, "HELP") then
		self.help = acHelpTags[self.help] or ""
	end

	self.uid = uid
	self.idPairs = { self.id }
	self.child = false
	self.idMirror = nil
	self.independentSpinner = independentSpinner and true or false

	if string.find(self.id, "LF") then
		self.idMirror = string.replace(self.id, "LF", "RF")
	elseif string.find(self.id, "RF") then
		self.idMirror = string.replace(self.id, "RF", "LF")
	elseif string.find(self.id, "LR") then
		self.idMirror = string.replace(self.id, "LR", "RR")
	elseif string.find(self.id, "RR") then
		self.idMirror = string.replace(self.id, "RR", "LR")
	end

	if ac.getSetupSpinnerValue(self.idMirror, -12345) == -12345 then
		self.idMirror = nil
	end

	self._value = self.value

	self.itemSet = false
	self.itemActive = false

	self.buttonHeldTimer = { Left = 0, Right = 0 }
	self.buttonHeldStart = 0

	self.helpWindowShow = false
end

local buttonSize = vec2(0, 0)
local buttonResized = false

function SPINNER:button(direction)
	local changed = false

	if self.min == self.max then
		ui.dummy(buttonSize)
	elseif direction == "Reset" then
		if
			ui.modernButtonAdvanced(
				"##" .. direction .. self.id,
				buttonSize,
				ui.ButtonFlags.PressedOnClick,
				ui.Icons.Stay,
				16 * cui.scaleY()
			)
		then
			self.value = self.default
			changed = true
		end
	elseif
		ui.arrowButtonAdvanced("##" .. direction .. self.id, direction, buttonSize, ui.ButtonFlags.PressedOnClick)
	then
		self.value = direction == "Left" and (self.value - self.step) or (self.value + self.step)
		self.buttonHeldTimer[direction] = os.clock() + 0.5
		self.buttonHeldStart = os.clock()
		changed = true
	elseif self.buttonHeldTimer[direction] < os.clock() and ui.itemActive() and ui.mouseDown(ui.MouseButton.Left) then
		self.value = direction == "Left" and (self.value - self.step) or (self.value + self.step)
		self.buttonHeldTimer[direction] = (os.clock() - self.buttonHeldStart) < 2.5 and os.clock() + 0.1
			or os.clock() + 0.075
		changed = true
	end

	ui.sameLine()
	return changed
end

function SPINNER:helpWindow()
	if self.help ~= "NULL" and self.help ~= "" then
		ac.log(os.clock())

		ui.tooltip(function()
			ui.dummy(vec2(230 * cui.scaleY(), 0))
			ui.bringWindowToFront()
			local helpSections = string.split(self.help, "\\n\\n")

			for i in ipairs(helpSections) do
				ui.dwriteTextWrapped(helpSections[i], 14 * cui.scaleY())
			end
		end)

		ui.transparentWindow(
			"##help" .. self.id,
			vec2(
				(265 * UI_SCALE_Y / 100) + (1315 + setupPageFontSize[1]) * UI_SCALE_X / 100,
				(200 + setupPageFontSize[2]) * UI_SCALE_Y / 100
			),
			vec2(325 * UI_SCALE_Y / 100, 730 * UI_SCALE_Y / 100 / 2),
			true,
			false,
			function() end
		)
	else
		storage.helpOpen = false
	end
end

function SPINNER:slider()
	if #self.items > 0 then
		self.format = (self.items[self.value + 1] and self.items[self.value + 1] or self.value)
	end

	-- ui.drawRectFilled(ui.getCursor(), ui.getCursor() + vec2(250, -20), rgbm.colors.red)
	ui.dwriteDrawText(self.name, 18 * cui.scaleY(), ui.getCursor() - vec2(0, 25 * cui.scaleY()))

	ui.setNextItemWidth(250 * cui.scaleY())

	local sliderGrabSize = max(350 * cui.scaleY() / (self.max - self.min + self.step) / self.step, 10)

	ui.pushStyleVar(ui.StyleVar.GrabMinSize, self.min == self.max and 0 or sliderGrabSize)
	local value, changed = ui.slider(
		"##" .. self.id .. self.name,
		self._value * self.multiplier,
		self.min * self.multiplier,
		self.max * self.multiplier,
		self.format,
		1
	)

	ui.popStyleVar(1)

	value = value / self.multiplier

	if ui.itemActive() then
		self.itemActive = true
		self._value = value
	elseif self.value ~= self._value then
		changed = true
		self.value = self._value
	elseif not self.independentSpinner then
		self.value = ac.getSetupSpinnerValue(self.id)
		self._value = self.value
	end

	ui.sameLine()

	if ui.itemHovered(ui.HoveredFlags.None) then
		if ui.mouseWheel() ~= 0 then
			changed = true
			self.value = ui.mouseWheel() < 0 and (self.value - self.step) or (self.value + self.step)
		end

		self.helpWindowShow = true
	end

	return changed
end

function SPINNER:get()
	if self.independentSpinner then
		return
	end

	if not self.itemActive then
		self.value = ac.getSetupSpinnerValue(self.id)
	end
end

function SPINNER:set()
	if self.itemSet then
		return
	end

	if self.independentSpinner then
		self.value = math.clamp(math.floor(self.value / self.step + 0.5) * self.step, self.min, self.max)
		self._value = self.value
		self.itemSet = true
		return
	end

	self.value = math.clamp(math.floor(self.value / self.step + 0.5) * self.step, self.min, self.max)
	self._value = self.value

	if self.value == ac.getSetupSpinnerValue(self.id) then
		self.itemSet = true
		return
	end

	for _key, id in pairs(self.idPairs) do
		ac.setSetupSpinnerValue(id, self.value)
	end

	self.itemSet = true
end

function SPINNER:mirror(id1, id2)
	if not self.idMirror then
		return
	end

	local mirrorValue = ac.getSetupSpinnerValue(self.idMirror)

	if mirrorValue == -12345 then
		return
	end

	if self.value ~= mirrorValue then
		self.value = mirrorValue
		self:set()
	end
end

function SPINNER:run(drawSpinner, mirror)
	ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0 * cui.scaleY())

	if self.name == "" or self.child then
		return
	end

	self.itemSet = false
	self:get()
	self.itemActive = false
	self.helpWindowShow = false

	if mirror then
		self:mirror()
	end

	if not drawSpinner then
		if self.value ~= self._value then
			self:set()
		end
		return
	end

	local setupitemwidth = (252 * cui.scaleY()) + (buttonSize.x * 3)

	local positions = {
		[0] = 15 * cui.scaleY(),
		[0.5] = (790 * cui.scaleY()) / 2 - setupitemwidth / 2,
		[1] = ((790 * cui.scaleY()) - setupitemwidth - (15 * cui.scaleY())),
	}

	ui.setCursorX(positions[self.xPos])
	cui.setCursorY(self.yPos * 70 + 100)
	if self:button("Left") then
		self:set()
	end
	if ui.itemHovered(ui.HoveredFlags.None) then
		self.helpWindowShow = true
	end

	if self:slider() and not self.itemActive then
		self:set()
	end
	if not buttonResized then
		buttonSize = vec2(ui.getItemRectSize().y, ui.getItemRectSize().y)
		buttonResized = true
	end

	if self:button("Right") then
		self:set()
	end
	if ui.itemHovered(ui.HoveredFlags.None) then
		self.helpWindowShow = true
	end

	if self:button("Reset") then
		self:set()
	end

	if self.helpWindowShow then
		HELP_TEXT = self.help

		ac.log(HELP_TEXT)

		storage.helpOpen = true
		self:helpWindow()
	end

	ui.popStyleVar(1)

	return self.itemSet
end
