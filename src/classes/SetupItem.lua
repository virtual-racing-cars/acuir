local max = math.max

UI_SCALE_Y = 1
UI_SCALE_X = 1

local setupINI = ac.INIConfig.carData(0, "setup.ini")

local setupPageFontSize = { -20, 0, ui.Font.Title, 0.75 }
-- if UI_SCALE_Y < 75 then
-- 	setupPageFontSize = { 14, 44, ui.Font.Tiny, 1 }
-- elseif UI_SCALE_Y < 100 then
-- 	setupPageFontSize = { 0, 10, ui.Font.Small, 1 }
-- end

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

SetupItem = class("SetupItem")

function SetupItem:initialize(
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

	self.itemActive = false

	self.buttonHeldTimer = { [-1] = 0, [0] = 0, [1] = 0 }
	self.buttonHeldStart = 0

	self.helpWindowShow = false
end

function SetupItem:helpWindow()
	-- if self.help ~= "NULL" and self.help ~= "" then
	-- 	ui.tooltip(function()
	-- 		ui.dummy(vec2(230 * cui.scaleY(), 0))
	-- 		ui.bringWindowToFront()
	-- 		local helpSections = string.split(self.help, "\\n\\n")

	-- 		for i in ipairs(helpSections) do
	-- 			ui.dwriteTextWrapped(helpSections[i], 14 * cui.scaleY())
	-- 		end
	-- 	end)

	-- 	ui.transparentWindow(
	-- 		"##help" .. self.id,
	-- 		vec2(
	-- 			(265 * UI_SCALE_Y / 100) + (1315 + setupPageFontSize[1]) * UI_SCALE_X / 100,
	-- 			(200 + setupPageFontSize[2]) * UI_SCALE_Y / 100
	-- 		),
	-- 		vec2(325 * UI_SCALE_Y / 100, 730 * UI_SCALE_Y / 100 / 2),
	-- 		true,
	-- 		false,
	-- 		function() end
	-- 	)
	-- end
end

function SetupItem:getValue()
	if self.independentSpinner then
		return
	end

	self.value = ac.getSetupSpinnerValue(self.id)
end

function SetupItem:setValue(value)
	local changed = self.value ~= value

	self.value = math.clamp(math.floor(value / self.step + 0.5) * self.step, self.min, self.max)

	for _, id in pairs(self.idPairs) do
		ac.setSetupSpinnerValue(id, self.value)
	end

	return changed
end

function SetupItem:increaseValue()
	if self.value == self.max then
		return false
	else
		self:setValue(self.value + self.step)
		return true
	end
end

function SetupItem:decreaseValue()
	if self.value == self.min then
		return false
	else
		self:setValue(self.value - self.step)
		return true
	end
end

function SetupItem:resetValue()
	if self.value == self.default then
		return false
	else
		self:setValue(self.default)
		return true
	end
end

function SetupItem:mirror(id1, id2)
	if not self.idMirror then
		return
	end

	local mirrorValue = ac.getSetupSpinnerValue(self.idMirror, -12345)

	if mirrorValue == -12345 then
		return
	end

	if self.value ~= mirrorValue then
		self:setValue(mirrorValue)
	end
end

function SetupItem:run(mirror)
	ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0 * cui.scaleY())

	if self.name == "" or self.child then
		return
	end

	self:getValue()
	self.helpWindowShow = false

	if mirror then
		self:mirror()
	end
end
