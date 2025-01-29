require("classes.SetupItem")

local setupINI = ac.INIConfig.carData(0, "setup.ini")

local pitstopsINI =
	ac.INIConfig.load(string.format("%s\\%s", ac.getFolder(ac.FolderID.Root), "system\\cfg\\pitstop.ini"))
local presetsCount = pitstopsINI:get("SETTINGS", "PRESETS_COUNT", 1)

local pitstopSetupSpinners = {
	["FUEL"] = { xPos = 0.5, yPos = 2, zeroDefault = true, label = "Add Liters" },
	["COMPOUND"] = { xPos = 0.5, yPos = 3.5, zeroDefault = true },
	["PRESSURE_LF"] = { xPos = 0, yPos = 5, zeroDefault = false },
	["PRESSURE_RF"] = { xPos = 1, yPos = 5, zeroDefault = false },
	["PRESSURE_LR"] = { xPos = 0, yPos = 6, zeroDefault = false },
	["PRESSURE_RR"] = { xPos = 1, yPos = 6, zeroDefault = false },
	-- ["WING_1"] = { xPos = 1, yPos = 8, zeroDefault = true },
	-- ["WING_2"] = { xPos = 0, yPos = 8, zeroDefault = true },
}

local gearSetupSpinners = {}

for i = 1, ac.getCar(0).gearCount do
	gearSetupSpinners["INTERNAL_GEAR_" .. i] = { xPos = 0.5, yPos = i - 1, zeroDefault = false }
end
gearSetupSpinners["FINAL_RATIO"] = { xPos = 0.5, yPos = ac.getCar(0).gearCount, zeroDefault = false }

local function loadSetupSpinners()
	local populatedTabs = {}
	local pairedItems = {}
	local setupSpinners = {}

	local electronicsSetupItems = {
		"MGUK_DELIVERY",
		"MGUK_RECOVERY",
		"MGUH_MODE",
		"BRAKE_ENGINE",
		"ABS",
		"TRACTION_CONTROL",
	}

	for i in ipairs(setupSpinners) do
		setupSpinners[i] = nil
	end

	for _, v in pairs(ac.getSetupSpinners()) do
		local id = v["name"]

		local ext = setupINI:get(id, "EXT_CONTROLLER", "")

		if id == "" and ext ~= "" then
			return
		end

		local tab = setupINI:get(id, "TAB", "")
		local name = v["label"]
		local min = v["min"]
		local max = v["max"]
		local step = v["step"]
		local multiplier = v["displayMultiplier"] or 1
		local units = v["units"] or ""
		-- local format = name .. (multiplier == 1 and ": %.0f " or ": %.1f ") .. (units == "%" and "%%" or units)
		local format = (multiplier == 1 and "%.0f " or "%.2f ") .. (units == "%" and "%%" or units)
		local items = v["items"] or {}
		local xPos = setupINI:get(id, "POS_X", 0.5)
		local yPos = setupINI:get(id, "POS_Y", 0)

		for i in ipairs(items) do
			if string.find(items[i], "%%") then
				items[i] = string.replace(items[i], "%", "%%")
			end
		end

		table.findFirst(electronicsSetupItems, function(item, index, callbackData)
			if id == item then
				tab = "ELECTRONICS"
				yPos = index - 1
			end
		end)

		if tab == "ELECTRONICS" then
			yPos = math.round(yPos)
		end

		if v.name == "COMPOUND" then
			tab = "TYRES"
			min = 0
			max = #items - 1
		end

		if v.name == "GEARSET" then
			name = "GEAR SETS"
			tab = "GEARS"
			min = 0
			max = #items - 1
		end

		if gearSetupSpinners[id] then
			tab = "GEARS"
			xPos = gearSetupSpinners[id].xPos
			yPos = gearSetupSpinners[id].yPos
		end

		if v.name == "FUEL" then
			tab = "FUEL"
		end

		if not table.contains(populatedTabs, tab) then
			table.insert(populatedTabs, tab)
		end

		local uid = bit.tohex(ac.checksumXXH(stringify({ tab, xPos, yPos })))

		table.insert(
			setupSpinners,
			SetupItem(id, tab, name, min, max, step, multiplier, items, format, xPos, yPos, uid)
		)

		local insertedNoChange = false
		if pitstopSetupSpinners[id] then
			for i = 1, presetsCount do
				if not insertedNoChange and id == "COMPOUND" then
					items = table.clone(items, true)
					table.insert(items, 1, "No Change")
					max = #items - 1
					insertedNoChange = true
				end

				if id == "WING_1" or id == "WING_2" then
					min = -(max - min) * 2
					max = -min
				end

				table.insert(
					setupSpinners,
					SetupItem(
						id .. "_PRESET_" .. i - 1,
						"PITSTOP STRATEGY",
						name,
						min,
						max,
						step,
						multiplier,
						items,
						format,
						pitstopSetupSpinners[v.name].xPos,
						pitstopSetupSpinners[v.name].yPos,
						bit.tohex(ac.checksumXXH(stringify({
							"PITSTOP STRATEGY",
							pitstopSetupSpinners[v.name].xPos,
							pitstopSetupSpinners[v.name].yPos,
						}))),
						true,
						pitstopSetupSpinners[v.name].zeroDefault and 0 or v.value
					)
				)
			end
		end

		if not pairedItems[uid] then
			pairedItems[uid] = { id }
		else
			table.insert(pairedItems[uid], 1, id)
		end
	end

	table.insert(
		setupSpinners,
		SetupItem(
			"PRESET",
			"PITSTOP STRATEGY",
			"PRESET",
			1,
			presetsCount,
			1,
			1,
			{},
			"%.0f",
			0.5,
			0,
			bit.tohex(ac.checksumXXH(stringify({
				"PITSTOP STRATEGY",
				0.5,
				0,
			}))),
			true,
			1
		)
	)

	for uid, uidPairs in pairs(pairedItems) do
		if #uidPairs > 1 then
			for _, parent in pairs(setupSpinners) do
				if parent.uid == uid then
					if parent.id == uidPairs[1] then
						parent.idPairs = uidPairs
					else
						parent.child = true
					end
				end
			end
		end
	end

	return setupSpinners
end

SetupTab = class("SetupTab")

function SetupTab:initialize(name)
	self.name = name
	self.setupSpinners = {}
end

SetupManager = class("SetupManager")

function SetupManager:initialize()
	self._setupSpinners = loadSetupSpinners()
	self._defaultTabNames = { "ELECTRONICS", "PITSTOP STRATEGY", "FUEL", "TYRES", "GEARS" }
	self._tabNames = {}
	self._tabCount = 0
	self._defaultSetup = ac.stringifyCurrentSetup()

	for k, _ in pairs(setupINI.sections) do
		local tabName = setupINI:get(k, "TAB", "")

		if tabName ~= "" and not table.contains(self._defaultTabNames, tabName) then
			table.insert(self._tabNames, tabName)
		end
	end

	self._tabNames = table.distinct(self._tabNames)
	table.removeItem(self._tabNames, "")
	table.sort(self._tabNames)

	for i = 1, #self._defaultTabNames do
		local tab = self._defaultTabNames[i]
		table.insert(self._tabNames, 1, tab)
	end

	self.setupTabs = {}

	for i = 1, #self._tabNames do
		table.insert(self.setupTabs, SetupTab(self._tabNames[i]))
	end

	for k, v in pairs(self._setupSpinners) do
		for i in ipairs(self.setupTabs) do
			if self.setupTabs[i].name == v.tab then
				table.insert(self.setupTabs[i].setupSpinners, self._setupSpinners[k])
			end
		end
	end

	for _, v in pairs(self.setupTabs) do
		if v.name ~= "SETUP I/O" and v.name ~= "PITSTOP STRATEGY" and v.name ~= "GEARS" and #v.setupSpinners == 0 then
			table.removeItem(self.setupTabs, v)
		else
			self._tabCount = self._tabCount + 1
		end
	end

	self._history = {}
	self._history_pos = 0

	self:makeUndo()
end

function SetupManager:resetSetup()
	self:LoadStuff(self._defaultSetup)
end

function SetupManager:tabCount()
	return self._tabCount
end

function SetupManager:LoadStuff(tbl)
	ac.loadSetup(tbl)

	for _, v in pairs(self._setupSpinners) do
		if v.mirrored then
			if ac.getSetupSpinnerValue(v.idMirror) ~= ac.getSetupSpinnerValue(v.id) then
				v.mirrored = false
			end
		end

		v:setValue(ac.getSetupSpinnerValue(v.id))
	end
end

function SetupManager:undo()
	if self._history_pos > 1 then
		self._history_pos = self._history_pos - 1
		self:LoadStuff(self._history[self._history_pos])
	end
end

function SetupManager:isUndoAvailable()
	if self._history_pos > 1 then
		return true
	end
	return false
end

function SetupManager:redo()
	if self._history_pos < #self._history then
		self._history_pos = self._history_pos + 1
		self:LoadStuff(self._history[self._history_pos])
	end
end

function SetupManager:isRedoAvailable()
	if self._history_pos < #self._history then
		return true
	end
	return false
end

function SetupManager:cleanUndoHistory()
	-- delete higher undo steps
	for i = #self._history, self._history_pos + 1, -1 do
		table.remove(self._history, i)
	end
end

function SetupManager:makeUndo()
	local tmp = ac.stringifyCurrentSetup()

	self:cleanUndoHistory()

	table.insert(self._history, self._history_pos + 1, tmp)
	self._history_pos = #self._history
end

function SetupManager:resetUndo()
	self._history = {}
	self._history_pos = 0
	self:makeUndo()
end
