local pitstopStrategySpinners = {}

local pitstopSetupSpinners = {
	["FUEL"] = { xPos = 0.5, yPos = 1, zeroDefault = true, label = "Add Liters" },
	["COMPOUND"] = { xPos = 0.5, yPos = 3, zeroDefault = true },
	["PRESSURE_LF"] = { xPos = 0, yPos = 5, zeroDefault = false },
	["PRESSURE_RF"] = { xPos = 1, yPos = 5, zeroDefault = false },
	["PRESSURE_LR"] = { xPos = 0, yPos = 6, zeroDefault = false },
	["PRESSURE_RR"] = { xPos = 1, yPos = 6, zeroDefault = false },
}

local clonedSetupSpinners = table.clone(ac.getSetupSpinners(), true)

for k, v in pairs(clonedSetupSpinners) do
	if pitstopSetupSpinners[v.name] then
		if v.name == "COMPOUND" then
			table.insert(v.items, 1, "No Change")
			v.max = #v.items - 1
		end

		table.insert(
			pitstopStrategySpinners,
			SPINNER(
				v.name,
				"PITSTOP STRATEGY",
				v.label,
				v.min,
				v.max,
				v.step,
				v.displayMultiplier,
				v.items and v.items or {},
				(pitstopSetupSpinners[v.name]["label"] and pitstopSetupSpinners[v.name]["label"] or v.label)
					.. (v.displayMultiplier == 1 and ": %.0f " or ": %.1f ")
					.. (v["units"] and (v.units == "%" and "%%" or v.units) or ""),
				pitstopSetupSpinners[v.name].xPos,
				pitstopSetupSpinners[v.name].yPos,
				bit.tohex(ac.checksumXXH(os.clock())),
				true,
				pitstopSetupSpinners[v.name].zeroDefault
			)
		)
	end
end

local tempSpFile = ac.INIConfig.load(ac.getFolder(ac.FolderID.UserSetups) .. "\\" .. ac.getCarID(0) .. "\\_temp.sp")

tempSpFile:setAndSave("PRESET_0", "COMPOUND", -1)

local pitstopStrategyUpdated = false

function pitstopStrategyWindow()
	setCursorY(60)

	ui.combo("Preset", "Test", function()
		ui.selectable("hi")
	end)

	-- setCursorX(15)
	-- ui.modernButtonAdvanced("Preset 1", vec2(ui.availableSpaceX() / 3, 30 * UI_SCALE_Y / 100))

	-- ui.sameLine()
	-- ui.modernButtonAdvanced("Preset 2", vec2(ui.availableSpaceX() / 2, 30 * UI_SCALE_Y / 100))

	-- ui.sameLine()
	-- ui.modernButtonAdvanced("Preset 3", vec2(ui.availableSpaceX(), 30 * UI_SCALE_Y / 100))

	pitstopStrategyUpdated = false
	for k, v in pairs(pitstopStrategySpinners) do
		if v:run(true, false) then
			tempSpFile:setAndSave("PRESET_0", v.id, v.id == "COMPOUND" and v.value - 1 or v.value)
			pitstopStrategyUpdated = true
		end
	end

	if pitstopStrategyUpdated then
		ac.saveCurrentSetup("_temp.ini")
		ac.loadSetup("_temp.ini")
	end

	ui.newLine()
	ui.dwriteTextAligned(
		"Effective pressure adjustments will be limited to a range of 8 psi",
		20 * UI_SCALE_Y / 100,
		ui.Alignment.Center,
		ui.Alignment.Center,
		vec2(ui.availableSpaceX(), 30 * UI_SCALE_Y / 100)
	)
end
