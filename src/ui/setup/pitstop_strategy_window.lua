-- local pitstopsINI =
-- 	ac.INIConfig.load(string.format("%s\\%s", ac.getFolder(ac.FolderID.Root), "system\\cfg\\pitstop.ini"))
-- local presetsCount = pitstopsINI:get("SETTINGS", "PRESETS_COUNT", 1)

-- local pitstopSetupSpinners = {
-- 	["FUEL"] = { xPos = 0.5, yPos = 2, zeroDefault = true, label = "Add Liters" },
-- 	["COMPOUND"] = { xPos = 0.5, yPos = 3.5, zeroDefault = true },
-- 	["PRESSURE_LF"] = { xPos = 0, yPos = 5, zeroDefault = false },
-- 	["PRESSURE_RF"] = { xPos = 1, yPos = 5, zeroDefault = false },
-- 	["PRESSURE_LR"] = { xPos = 0, yPos = 6, zeroDefault = false },
-- 	["PRESSURE_RR"] = { xPos = 1, yPos = 6, zeroDefault = false },
-- }

-- local clonedSetupSpinners = table.clone(ac.getSetupSpinners(), true)

-- local pitstopStrategySpinners = {}
-- local insertedNoChange = false
-- for i = 1, presetsCount do
-- 	pitstopStrategySpinners[i] = {}

-- 	for k, v in pairs(clonedSetupSpinners) do
-- 		if pitstopSetupSpinners[v.name] then
-- 			if not insertedNoChange and v.name == "COMPOUND" then
-- 				table.insert(v.items, 1, "No Change")
-- 				v.max = #v.items - 1
-- 				insertedNoChange = true
-- 			end

-- 			table.insert(
-- 				pitstopStrategySpinners[i],
-- 				SetupItem(
-- 					v.name,
-- 					"PITSTOP STRATEGY",
-- 					v.label,
-- 					v.min,
-- 					v.max,
-- 					v.step,
-- 					v.displayMultiplier,
-- 					v.items and v.items or {},
-- 					(pitstopSetupSpinners[v.name]["label"] and pitstopSetupSpinners[v.name]["label"] or v.label)
-- 						.. (v.displayMultiplier == 1 and ": %.0f " or ": %.1f ")
-- 						.. (v["units"] and (v.units == "%" and "%%" or v.units) or ""),
-- 					pitstopSetupSpinners[v.name].xPos,
-- 					pitstopSetupSpinners[v.name].yPos,
-- 					bit.tohex(ac.checksumXXH(os.preciseClock())),
-- 					true,
-- 					pitstopSetupSpinners[v.name].zeroDefault
-- 				)
-- 			)
-- 		end
-- 	end
-- end

-- local pitstopStrategyPresetSpinner = SetupItem(
-- 	"PITSTOP_STRATEGY_PRESET",
-- 	"PITSTOP STRATEGY",
-- 	"Preset",
-- 	1,
-- 	presetsCount,
-- 	1,
-- 	1,
-- 	{},
-- 	"%.0f",
-- 	0.5,
-- 	0,
-- 	bit.tohex(ac.checksumXXH(os.preciseClock())),
-- 	true,
-- 	false
-- )
-- pitstopStrategyPresetSpinner.value = 1

-- local tempSpFile = ac.INIConfig.load(ac.getFolder(ac.FolderID.UserSetups) .. "\\" .. ac.getCarID(0) .. "\\_temp.sp")
-- tempSpFile:setAndSave("PRESET_0", "COMPOUND", -1)

-- local pitstopStrategyUpdated = false

-- function pitstopStrategyWindow()
-- 	cui.setCursorX(0)
-- 	cui.setCursorY(60)

-- 	pitstopStrategyPresetSpinner:run(true, false)

-- 	pitstopStrategyUpdated = false

-- 	for k, v in pairs(pitstopStrategySpinners[pitstopStrategyPresetSpinner.value]) do
-- 		if v:run(true, false) then
-- 			tempSpFile:setAndSave(
-- 				"PRESET_" .. pitstopStrategyPresetSpinner.value - 1,
-- 				v.id,
-- 				v.id == "COMPOUND" and v.value - 1 or v.value
-- 			)
-- 			pitstopStrategyUpdated = true
-- 		end
-- 	end

-- 	if pitstopStrategyUpdated then
-- 		ac.saveCurrentSetup("_temp.ini")
-- 		ac.loadSetup("_temp.ini")
-- 	end

-- 	cui.setCursorX(0)
-- 	cui.setCursorY(600)
-- 	ui.dwriteTextAligned(
-- 		"Effective pressure adjustments will be limited to a range of 8 psi",
-- 		20 * cui.scaleY(),
-- 		ui.Alignment.Center,
-- 		ui.Alignment.Center,
-- 		vec2(790, 30) * cui.scaleY()
-- 	)
-- end
